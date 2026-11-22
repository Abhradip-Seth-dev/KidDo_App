from pydantic import BaseModel
from typing import Optional


class QuestionOption(BaseModel):
    option_id: str    # "A", "B", "C", "D"
    text: str


class QuestionContent(BaseModel):
    question: str
    options: list[QuestionOption]
    media_url: Optional[str] = None


class NextQuestionResponse(BaseModel):
    question_id: str           # internal ID string like "MATH-U1-Q001"
    question_db_id: int        # DB primary key (used in submit)
    grade_class: str
    subject: str
    topic: str
    difficulty: str
    question_type: str
    content: QuestionContent
    available_hints: int       # always 2 for now
    # NO answer_key field — ever
