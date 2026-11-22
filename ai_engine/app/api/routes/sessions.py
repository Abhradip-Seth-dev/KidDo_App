"""
Session routes — POST /api/v1/sessions  &  GET /api/v1/sessions/{id}/next-question
"""

import uuid
from fastapi import APIRouter, Depends, HTTPException, status
from sqlmodel import Session

from app.core.config import settings
from app.core.database import get_session
from app.schemas.session import StartSessionRequest, StartSessionResponse
from app.schemas.question import NextQuestionResponse, QuestionContent, QuestionOption
from app.repositories.question_repository import (
    get_subject_by_code,
    get_topic_by_code,
    get_published_questions_for_topic,
)
from app.repositories.progress_repository import (
    get_or_create_subject_score,
    get_or_create_topic_mastery,
    get_recent_topic_attempts,
    get_recently_seen_question_ids,
    get_all_active_subject_scores,
    calculate_overall_score,
    create_learning_session,
    get_learning_session,
)
from app.services.mastery_service import calculate_mastery, mastery_label
from app.services.question_selector import select_next_question

router = APIRouter()


# ── POST / — Start a new practice session ──────────────────────────────────
@router.post(
    "/",
    response_model=StartSessionResponse,
    status_code=status.HTTP_201_CREATED,
)
def start_session(
    body: StartSessionRequest,
    db: Session = Depends(get_session),
):
    # 1. Look up subject & topic
    subject = get_subject_by_code(db, body.subject_code)
    if not subject:
        raise HTTPException(status_code=404, detail=f"Subject '{body.subject_code}' not found")

    topic = get_topic_by_code(db, body.topic_code)
    if not topic:
        raise HTTPException(status_code=404, detail=f"Topic '{body.topic_code}' not found")

    if topic.subject_id != subject.id:
        raise HTTPException(status_code=422, detail="Topic does not belong to specified subject")

    # 2. Get or create student progress records
    subject_score = get_or_create_subject_score(db, body.student_id, subject.id)
    topic_mastery = get_or_create_topic_mastery(db, body.student_id, topic.id)

    # 3. Compute current mastery from recent attempts
    recent = get_recent_topic_attempts(db, body.student_id, topic.id)
    mastery_val = calculate_mastery(recent)

    # 4. Compute overall score
    all_scores = get_all_active_subject_scores(db, body.student_id)
    overall = calculate_overall_score(all_scores)

    # 5. Create learning session
    session_id = str(uuid.uuid4())
    create_learning_session(db, session_id, body.student_id, subject.id, topic.id)
    db.commit()

    return StartSessionResponse(
        session_id=session_id,
        subject_score=subject_score.score,
        overall_score=overall,
        topic_mastery=mastery_val,
        mastery_label=mastery_label(mastery_val),
        current_difficulty=topic_mastery.current_difficulty,
        subject_code=subject.code,
        topic_code=topic.code,
    )


# ── GET /{session_id}/next-question ────────────────────────────────────────
@router.get(
    "/{session_id}/next-question",
    response_model=NextQuestionResponse,
)
def get_next_question(
    session_id: str,
    db: Session = Depends(get_session),
):
    # 1. Load session
    learning_session = get_learning_session(db, session_id)
    if not learning_session or learning_session.status != "active":
        raise HTTPException(status_code=404, detail="Session not found or not active")

    # 2. Load topic mastery → get current difficulty
    topic_mastery = get_or_create_topic_mastery(
        db, learning_session.student_id, learning_session.topic_id
    )

    # 3. Get recently seen question IDs
    recently_seen = get_recently_seen_question_ids(
        db,
        learning_session.student_id,
        learning_session.topic_id,
        lookback=settings.recent_question_lookback,
    )

    # 4. Get candidate questions from the pool
    questions = get_published_questions_for_topic(
        db, learning_session.topic_id, topic_mastery.current_difficulty
    )

    # Convert to dicts for the selector
    candidates = [
        {"id": q.id, "difficulty": q.difficulty, "topic_id": q.topic_id, "question": q}
        for q in questions
    ]

    # 5. Select next question using controlled randomisation
    selected = select_next_question(
        candidate_questions=candidates,
        current_difficulty=topic_mastery.current_difficulty,
        recently_seen_ids=recently_seen,
    )

    if not selected:
        raise HTTPException(
            status_code=404,
            detail="pool_exhausted",
        )

    q = selected["question"]

    # 6. Increment questions_served
    learning_session.questions_served += 1
    db.commit()

    # 7. Build safe response — NO answer_key
    options = [
        QuestionOption(option_id=opt["option_id"], text=opt["text"])
        for opt in q.content.get("options", [])
    ]

    # Look up subject/topic names
    from app.repositories.question_repository import get_subject_by_code, get_topic_by_code
    from app.models.subject import Subject, Topic
    subject = db.get(Subject, learning_session.subject_id)
    topic = db.get(Topic, learning_session.topic_id)

    return NextQuestionResponse(
        question_id=q.question_id,
        question_db_id=q.id,
        grade_class=q.grade_class,
        subject=subject.name if subject else "",
        topic=topic.name if topic else "",
        difficulty=q.difficulty,
        question_type=q.question_type,
        content=QuestionContent(
            question=q.content.get("question", ""),
            options=options,
            media_url=q.content.get("media_url"),
        ),
        available_hints=len(q.answer_key.get("hints", [])) or 2,
    )
