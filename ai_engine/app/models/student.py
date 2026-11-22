from sqlmodel import SQLModel, Field, Column
from sqlalchemy import JSON, UniqueConstraint
from typing import Optional
from datetime import datetime, timezone

def utc_now() -> datetime:
    return datetime.now(timezone.utc)

class StudentSubjectScore(SQLModel, table=True):
    """One row per student per activated subject. Score starts at 100."""
    __tablename__ = "student_subject_scores"
    __table_args__ = (
        UniqueConstraint("student_id", "subject_id", name="uq_student_subject_score"),
    )

    id: Optional[int] = Field(default=None, primary_key=True)
    student_id: str = Field(index=True)   # UUID from Node.js User.id
    subject_id: int = Field(foreign_key="subjects.id", index=True)
    score: int = Field(default=100)        # min 0
    activated_at: datetime = Field(default_factory=utc_now)
    updated_at: datetime = Field(default_factory=utc_now)


class StudentTopicMastery(SQLModel, table=True):
    """Per-topic mastery + difficulty tracking."""
    __tablename__ = "student_topic_mastery"
    __table_args__ = (
        UniqueConstraint("student_id", "topic_id", name="uq_student_topic_mastery"),
    )

    id: Optional[int] = Field(default=None, primary_key=True)
    student_id: str = Field(index=True)
    topic_id: int = Field(foreign_key="topics.id", index=True)
    mastery_value: Optional[float] = Field(default=None)  # 0–100, None = insufficient evidence
    evidence_count: int = Field(default=0)
    current_difficulty: str = Field(default="beginner")
    last_practiced_at: Optional[datetime] = Field(default=None)
    mastery_formula_version: int = Field(default=1)
    updated_at: datetime = Field(default_factory=utc_now)


class LearningSession(SQLModel, table=True):
    __tablename__ = "learning_sessions"

    id: Optional[str] = Field(default=None, primary_key=True)  # UUID string
    student_id: str = Field(index=True)
    subject_id: int = Field(foreign_key="subjects.id")
    topic_id: int = Field(foreign_key="topics.id")
    started_at: datetime = Field(default_factory=utc_now)
    ended_at: Optional[datetime] = Field(default=None)
    status: str = Field(default="active")  # active/completed/abandoned
    questions_served: int = Field(default=0)


class QuestionAttempt(SQLModel, table=True):
    """Immutable record of every answer submitted."""
    __tablename__ = "question_attempts"

    id: Optional[str] = Field(default=None, primary_key=True)  # UUID string
    submission_id: str = Field(unique=True, index=True)  # client idempotency key
    session_id: str = Field(foreign_key="learning_sessions.id", index=True)
    student_id: str = Field(index=True)
    question_id: int = Field(foreign_key="questions.id")
    question_version: int = Field(default=1)
    selected_answer: dict = Field(default_factory=dict, sa_column=Column(JSON))
    is_correct: bool = Field(default=False)
    hints_used: int = Field(default=0)
    attempt_number: int = Field(default=1)
    time_taken_seconds: Optional[int] = Field(default=None)
    submitted_at: datetime = Field(default_factory=utc_now)


class ScoreTransaction(SQLModel, table=True):
    """Auditable record of every point change."""
    __tablename__ = "score_transactions"

    id: Optional[int] = Field(default=None, primary_key=True)
    student_id: str = Field(index=True)
    subject_id: int = Field(foreign_key="subjects.id")
    attempt_id: str = Field(foreign_key="question_attempts.id")
    points_change: int
    score_after: int
    reason: str    # "correct_beginner_answer", "incorrect_expert_answer", "hint_penalty"
    scoring_rule_version: int = Field(default=1)
    created_at: datetime = Field(default_factory=utc_now)


class ScoringRule(SQLModel, table=True):
    """Configurable scoring rules — no hardcoded values."""
    __tablename__ = "scoring_rules"

    id: Optional[int] = Field(default=None, primary_key=True)
    difficulty: str   # beginner/intermediate/expert
    correct_points: int
    incorrect_points: int
    hint_penalty: int = Field(default=1)
    version: int = Field(default=1)
    is_active: bool = Field(default=True)
    active_from: datetime = Field(default_factory=utc_now)
