from pydantic import BaseModel
from typing import Optional


class SelectedAnswer(BaseModel):
    option_id: str    # "A", "B", "C", or "D"


class SubmitAttemptRequest(BaseModel):
    session_id: str
    question_db_id: int         # DB primary key of question
    submission_id: str          # client-generated UUID for idempotency
    selected_answer: SelectedAnswer
    hints_used: int = 0
    time_taken_seconds: Optional[int] = None


class AttemptFeedback(BaseModel):
    message: str           # "Great work!" or "Keep trying!"
    explanation: str       # from answer_key


class ScoreUpdate(BaseModel):
    points_change: int
    subject_score: int
    overall_score: float


class ProgressUpdate(BaseModel):
    topic_mastery: Optional[float]
    mastery_label: str
    current_difficulty: str
    recommended_difficulty: str


class SubmitAttemptResponse(BaseModel):
    attempt_id: str
    is_correct: bool
    feedback: AttemptFeedback
    score: ScoreUpdate
    progress: ProgressUpdate
