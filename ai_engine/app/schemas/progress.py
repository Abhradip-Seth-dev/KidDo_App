from pydantic import BaseModel
from typing import Optional


class SubjectProgress(BaseModel):
    subject_code: str
    subject_name: str
    score: int


class TopicProgress(BaseModel):
    topic_code: str
    topic_name: str
    subject_code: str
    mastery: Optional[float]
    mastery_label: str
    difficulty: str
    evidence_count: int


class StudentProgressResponse(BaseModel):
    student_id: str
    overall_score: float
    active_subject_count: int
    subjects: list[SubjectProgress]
    topics: list[TopicProgress]
