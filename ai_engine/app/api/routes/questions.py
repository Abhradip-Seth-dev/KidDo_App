"""
Question routes — browse subjects/topics and get hints.
GET /api/v1/questions/subjects
GET /api/v1/questions/topics?subject_code=MATH
GET /api/v1/questions/{question_id}/hint
"""

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlmodel import Session, select

from app.core.database import get_session
from app.models.subject import Subject, Topic
from app.models.question import Question
from app.repositories.question_repository import (
    get_subject_by_code,
    get_all_topics_for_subject,
)

router = APIRouter()


# ── GET /subjects ──────────────────────────────────────────────────────────
@router.get("/subjects")
def list_subjects(db: Session = Depends(get_session)):
    subjects = db.exec(
        select(Subject).where(Subject.is_active == True)
    ).all()
    return [
        {
            "id": s.id,
            "code": s.code,
            "name": s.name,
            "grade_class": s.grade_class,
        }
        for s in subjects
    ]


# ── GET /topics?subject_code=MATH ──────────────────────────────────────────
@router.get("/topics")
def list_topics(
    subject_code: str = Query(..., description="Subject code, e.g. MATH"),
    db: Session = Depends(get_session),
):
    subject = get_subject_by_code(db, subject_code)
    if not subject:
        raise HTTPException(status_code=404, detail=f"Subject '{subject_code}' not found")

    topics = get_all_topics_for_subject(db, subject.id)
    return [
        {
            "id": t.id,
            "code": t.code,
            "name": t.name,
            "unit_number": t.unit_number,
            "grade_class": t.grade_class,
            "subject_code": subject.code,
        }
        for t in topics
    ]


# ── GET /{question_id}/hint ────────────────────────────────────────────────
@router.get("/{question_db_id}/hint")
def get_question_hint(
    question_db_id: int,
    hint_index: int = Query(0, description="Which hint to retrieve (0-based)"),
    db: Session = Depends(get_session),
):
    """
    Returns a hint for the given question.
    IMPORTANT: This endpoint NEVER returns the correct answer — only hint text.
    """
    question = db.get(Question, question_db_id)
    if not question:
        raise HTTPException(status_code=404, detail="Question not found")

    hints = question.answer_key.get("hints", [])
    if not hints or hint_index >= len(hints):
        return {"hint": "No hints available for this question.", "hint_index": hint_index}

    return {"hint": hints[hint_index], "hint_index": hint_index, "total_hints": len(hints)}
