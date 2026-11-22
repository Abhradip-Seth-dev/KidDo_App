from sqlmodel import SQLModel, Field
from typing import Optional
from datetime import datetime


class Subject(SQLModel, table=True):
    __tablename__ = "subjects"

    id: Optional[int] = Field(default=None, primary_key=True)
    code: str = Field(unique=True, index=True)   # "MATH", "GK", "ENGLISH", "COMPUTER"
    name: str                                      # "Mathematics", "General Knowledge", etc.
    grade_class: str = Field(default="Class 3")
    is_active: bool = Field(default=True)
    created_at: datetime = Field(default_factory=datetime.utcnow)


class Topic(SQLModel, table=True):
    __tablename__ = "topics"

    id: Optional[int] = Field(default=None, primary_key=True)
    subject_id: int = Field(foreign_key="subjects.id", index=True)
    code: str = Field(index=True)   # "MATH-U1", "MATH-U2"
    name: str                        # "Unit 1: Number Sense"
    unit_number: int
    grade_class: str = Field(default="Class 3")
    created_at: datetime = Field(default_factory=datetime.utcnow)
