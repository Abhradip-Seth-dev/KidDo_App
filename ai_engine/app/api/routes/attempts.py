"""
Attempt routes — POST /api/v1/attempts

The core answer-submission transaction:
validate → check answer → score → mastery → difficulty → commit
"""

import uuid
from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException, status
from sqlmodel import Session

from app.core.config import settings
from app.core.database import get_session
from app.models.subject import Subject, Topic
from app.schemas.attempt import (
    SubmitAttemptRequest,
    SubmitAttemptResponse,
    AttemptFeedback,
    ScoreUpdate,
    ProgressUpdate,
)
from app.models.student import QuestionAttempt
from app.repositories.question_repository import get_question_by_db_id
from app.repositories.progress_repository import (
    get_or_create_subject_score,
    get_or_create_topic_mastery,
    get_recent_topic_attempts,
    get_all_active_subject_scores,
    calculate_overall_score,
    get_attempt_by_submission_id,
    get_learning_session,
    record_score_transaction,
)
from app.services.scoring_service import (
    calculate_points,
    clamp_score,
    get_score_reason,
    get_active_scoring_rule_version,
)
from app.services.mastery_service import calculate_mastery, mastery_label
from app.services.adaptive_engine_service import (
    evaluate_difficulty_decision,
    apply_difficulty_progression,
    get_recommended_difficulty,
)

router = APIRouter()


@router.post(
    "/",
    response_model=SubmitAttemptResponse,
    status_code=status.HTTP_201_CREATED,
)
def submit_attempt(
    body: SubmitAttemptRequest,
    db: Session = Depends(get_session),
):
    # ── 1. Idempotency check ───────────────────────────────────────────────
    existing = get_attempt_by_submission_id(db, body.submission_id)
    if existing:
        # Re-derive the same response from the existing attempt
        return _build_response_from_existing(db, existing)

    # ── 2. Load session ────────────────────────────────────────────────────
    learning_session = get_learning_session(db, body.session_id)
    if not learning_session:
        raise HTTPException(status_code=404, detail="Session not found")
    if learning_session.status != "active":
        raise HTTPException(status_code=422, detail="Session is not active")

    # ── 3. Load question ───────────────────────────────────────────────────
    question = get_question_by_db_id(db, body.question_db_id)
    if not question:
        raise HTTPException(status_code=404, detail="Question not found")

    # ── 4. Check answer PRIVATELY ──────────────────────────────────────────
    correct_option_id = question.answer_key.get("correct_option_id", "")
    is_correct = body.selected_answer.option_id.strip().upper() == correct_option_id.strip().upper()

    # ── 5. Load subject score ──────────────────────────────────────────────
    subject_score = get_or_create_subject_score(
        db, learning_session.student_id, learning_session.subject_id
    )

    # ── 6. Calculate points ────────────────────────────────────────────────
    points_delta = calculate_points(
        question.difficulty, is_correct, body.hints_used
    )
    new_score = clamp_score(subject_score.score, points_delta)
    reason = get_score_reason(question.difficulty, is_correct)

    # ── 7. Create immutable attempt record ─────────────────────────────────
    attempt_id = str(uuid.uuid4())
    attempt = QuestionAttempt(
        id=attempt_id,
        submission_id=body.submission_id,
        session_id=body.session_id,
        student_id=learning_session.student_id,
        question_id=question.id,
        question_version=question.content_version,
        selected_answer={"option_id": body.selected_answer.option_id},
        is_correct=is_correct,
        hints_used=body.hints_used,
        attempt_number=1,
        time_taken_seconds=body.time_taken_seconds,
    )
    db.add(attempt)
    db.flush()

    # ── 8. Record score transaction ────────────────────────────────────────
    record_score_transaction(
        db,
        student_id=learning_session.student_id,
        subject_id=learning_session.subject_id,
        attempt_id=attempt_id,
        points_change=points_delta,
        score_after=new_score,
        reason=reason,
    )

    # ── 9. Update subject score ────────────────────────────────────────────
    subject_score.score = new_score
    subject_score.updated_at = datetime.now(timezone.utc)

    # ── 10. Update mastery ─────────────────────────────────────────────────
    topic_mastery = get_or_create_topic_mastery(
        db, learning_session.student_id, learning_session.topic_id
    )
    recent = get_recent_topic_attempts(
        db, learning_session.student_id, learning_session.topic_id
    )
    # Include the current attempt
    recent_with_current = recent + [is_correct]
    mastery_val = calculate_mastery(recent_with_current)
    topic_mastery.mastery_value = mastery_val
    topic_mastery.evidence_count = len(recent_with_current)
    topic_mastery.last_practiced_at = datetime.now(timezone.utc)
    topic_mastery.updated_at = datetime.now(timezone.utc)

    # ── 11. Evaluate difficulty progression ────────────────────────────────
    decision = evaluate_difficulty_decision(recent_with_current)
    new_difficulty = apply_difficulty_progression(
        topic_mastery.current_difficulty, decision
    )
    recommended = get_recommended_difficulty(
        topic_mastery.current_difficulty, recent_with_current
    )
    topic_mastery.current_difficulty = new_difficulty

    # ── 12. Calculate overall score ────────────────────────────────────────
    all_scores = get_all_active_subject_scores(db, learning_session.student_id)
    overall = calculate_overall_score(all_scores)

    # ── 13. Commit everything atomically ───────────────────────────────────
    db.commit()

    # ── 14. Build response ─────────────────────────────────────────────────
    explanation = question.answer_key.get("explanation", "")
    feedback_message = "Great work!" if is_correct else "Keep trying!"

    return SubmitAttemptResponse(
        attempt_id=attempt_id,
        is_correct=is_correct,
        feedback=AttemptFeedback(
            message=feedback_message,
            explanation=explanation,
        ),
        score=ScoreUpdate(
            points_change=points_delta,
            subject_score=new_score,
            overall_score=overall,
        ),
        progress=ProgressUpdate(
            topic_mastery=mastery_val,
            mastery_label=mastery_label(mastery_val),
            current_difficulty=new_difficulty,
            recommended_difficulty=recommended,
        ),
    )


def _build_response_from_existing(db: Session, attempt: QuestionAttempt) -> SubmitAttemptResponse:
    """Re-derive the response for an already-processed submission (idempotency)."""
    question = get_question_by_db_id(db, attempt.question_id)
    learning_session = get_learning_session(db, attempt.session_id)

    subject_score = get_or_create_subject_score(
        db, attempt.student_id, learning_session.subject_id
    )
    topic_mastery = get_or_create_topic_mastery(
        db, attempt.student_id, learning_session.topic_id
    )
    all_scores = get_all_active_subject_scores(db, attempt.student_id)
    overall = calculate_overall_score(all_scores)

    explanation = question.answer_key.get("explanation", "") if question else ""
    feedback_message = "Great work!" if attempt.is_correct else "Keep trying!"

    return SubmitAttemptResponse(
        attempt_id=attempt.id,
        is_correct=attempt.is_correct,
        feedback=AttemptFeedback(
            message=feedback_message,
            explanation=explanation,
        ),
        score=ScoreUpdate(
            points_change=0,  # Already applied
            subject_score=subject_score.score,
            overall_score=overall,
        ),
        progress=ProgressUpdate(
            topic_mastery=topic_mastery.mastery_value,
            mastery_label=mastery_label(topic_mastery.mastery_value),
            current_difficulty=topic_mastery.current_difficulty,
            recommended_difficulty=topic_mastery.current_difficulty,
        ),
    )
