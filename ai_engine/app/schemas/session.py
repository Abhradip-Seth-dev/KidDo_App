from pydantic import BaseModel
from typing import Optional


class StartSessionRequest(BaseModel):
    student_id: str
    subject_code: str    # "MATH", "GK", "ENGLISH", "COMPUTER"
    topic_code: str      # "MATH-U1", "MATH-U2", etc.


class StartSessionResponse(BaseModel):
    session_id: str
    subject_score: int
    overall_score: float
    topic_mastery: Optional[float]      # None = not enough data yet
    mastery_label: str                  # "not_enough_data" | "needs_practice" | "developing" | "mastered"
    current_difficulty: str             # "beginner" | "intermediate" | "expert"
    subject_code: str
    topic_code: str
