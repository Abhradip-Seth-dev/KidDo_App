from sqlmodel import SQLModel, Field, Column
from sqlalchemy import JSON
from typing import Optional
from datetime import datetime


class Question(SQLModel, table=True):
    __tablename__ = "questions"

    id: Optional[int] = Field(default=None, primary_key=True)
    question_id: str = Field(unique=True, index=True)  # e.g. "MATH-U1-Q001"
    subject_id: int = Field(foreign_key="subjects.id", index=True)
    topic_id: int = Field(foreign_key="topics.id", index=True)
    grade_class: str = Field(default="Class 3", index=True)
    difficulty: str = Field(default="beginner", index=True)  # beginner/intermediate/expert
    difficulty_rank: int = Field(default=1)                   # 1=beginner, 2=intermediate, 3=expert
    question_type: str = Field(default="multiple_choice")     # multiple_choice/true_false/matching
    # content stores: {question, options:[{option_id, text}], media_url}
    content: dict = Field(default_factory=dict, sa_column=Column(JSON))
    # answer_key NEVER sent to client: {correct_option_id, explanation, hints:[]}
    answer_key: dict = Field(default_factory=dict, sa_column=Column(JSON))
    status: str = Field(default="published")  # draft/published/archived
    content_version: int = Field(default=1)
    created_at: datetime = Field(default_factory=datetime.utcnow)
