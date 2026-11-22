from sqlmodel import Session, select
from app.models.student import (
    StudentSubjectScore, StudentTopicMastery,
    LearningSession, QuestionAttempt, ScoreTransaction, ScoringRule
)
from datetime import datetime
from typing import Optional

def get_or_create_subject_score(session: Session, student_id: str, subject_id: int) -> StudentSubjectScore:
    record = session.exec(
        select(StudentSubjectScore).where(
            StudentSubjectScore.student_id == student_id,
            StudentSubjectScore.subject_id == subject_id,
        )
    ).first()
    if not record:
        record = StudentSubjectScore(student_id=student_id, subject_id=subject_id, score=100)
        session.add(record)
        session.flush()
    return record

def get_or_create_topic_mastery(session: Session, student_id: str, topic_id: int) -> StudentTopicMastery:
    record = session.exec(
        select(StudentTopicMastery).where(
            StudentTopicMastery.student_id == student_id,
            StudentTopicMastery.topic_id == topic_id,
        )
    ).first()
    if not record:
        record = StudentTopicMastery(student_id=student_id, topic_id=topic_id)
        session.add(record)
        session.flush()
    return record

def get_recent_topic_attempts(
    session: Session, student_id: str, topic_id: int, limit: int = 10
) -> list[bool]:
    """Returns list of is_correct booleans for recent valid attempts on a topic."""
    attempts = session.exec(
        select(QuestionAttempt)
        .join(LearningSession, QuestionAttempt.session_id == LearningSession.id)
        .where(
            QuestionAttempt.student_id == student_id,
            LearningSession.topic_id == topic_id,
        )
        .order_by(QuestionAttempt.submitted_at.desc())
        .limit(limit)
    ).all()
    return [a.is_correct for a in reversed(attempts)]

def get_recently_seen_question_ids(
    session: Session, student_id: str, topic_id: int, lookback: int = 10
) -> list[int]:
    """Returns question DB IDs recently served in this topic."""
    attempts = session.exec(
        select(QuestionAttempt)
        .join(LearningSession, QuestionAttempt.session_id == LearningSession.id)
        .where(
            QuestionAttempt.student_id == student_id,
            LearningSession.topic_id == topic_id,
        )
        .order_by(QuestionAttempt.submitted_at.desc())
        .limit(lookback)
    ).all()
    return [a.question_id for a in attempts]

def get_all_active_subject_scores(session: Session, student_id: str) -> list[StudentSubjectScore]:
    return list(session.exec(
        select(StudentSubjectScore).where(StudentSubjectScore.student_id == student_id)
    ).all())

def calculate_overall_score(scores: list[StudentSubjectScore]) -> float:
    if not scores:
        return 100.0
    return round(sum(s.score for s in scores) / len(scores), 2)

def get_attempt_by_submission_id(session: Session, submission_id: str) -> Optional[QuestionAttempt]:
    return session.exec(
        select(QuestionAttempt).where(QuestionAttempt.submission_id == submission_id)
    ).first()

def get_all_topic_mastery_for_student(session: Session, student_id: str) -> list[StudentTopicMastery]:
    return list(session.exec(
        select(StudentTopicMastery).where(StudentTopicMastery.student_id == student_id)
    ).all())

def create_learning_session(
    session: Session, session_id: str, student_id: str, subject_id: int, topic_id: int
) -> LearningSession:
    ls = LearningSession(
        id=session_id,
        student_id=student_id,
        subject_id=subject_id,
        topic_id=topic_id,
    )
    session.add(ls)
    session.flush()
    return ls

def get_learning_session(session: Session, session_id: str) -> Optional[LearningSession]:
    return session.get(LearningSession, session_id)

def record_score_transaction(
    session: Session,
    student_id: str,
    subject_id: int,
    attempt_id: str,
    points_change: int,
    score_after: int,
    reason: str,
) -> ScoreTransaction:
    tx = ScoreTransaction(
        student_id=student_id,
        subject_id=subject_id,
        attempt_id=attempt_id,
        points_change=points_change,
        score_after=score_after,
        reason=reason,
    )
    session.add(tx)
    return tx
