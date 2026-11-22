# Import all models so SQLModel.metadata.create_all() can discover them
from app.models.subject import Subject, Topic
from app.models.question import Question
from app.models.student import (
    StudentSubjectScore,
    StudentTopicMastery,
    LearningSession,
    QuestionAttempt,
    ScoreTransaction,
    ScoringRule,
)

__all__ = [
    "Subject",
    "Topic",
    "Question",
    "StudentSubjectScore",
    "StudentTopicMastery",
    "LearningSession",
    "QuestionAttempt",
    "ScoreTransaction",
    "ScoringRule",
]
