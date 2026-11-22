"""
Progress routes — GET /api/v1/students/{student_id}/progress
"""

from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import Session

from app.core.database import get_session
from app.models.subject import Subject, Topic
from app.schemas.progress import (
    StudentProgressResponse,
    SubjectProgress,
    TopicProgress,
)
from app.repositories.progress_repository import (
    get_all_active_subject_scores,
    calculate_overall_score,
    get_all_topic_mastery_for_student,
)
from app.services.mastery_service import mastery_label

router = APIRouter()


@router.get(
    "/{student_id}/progress",
    response_model=StudentProgressResponse,
)
def get_student_progress(
    student_id: str,
    db: Session = Depends(get_session),
):
    # 1. Get all active subject scores
    subject_scores = get_all_active_subject_scores(db, student_id)
    overall = calculate_overall_score(subject_scores)

    # 2. Build subject list with names
    subjects_out: list[SubjectProgress] = []
    for ss in subject_scores:
        subject = db.get(Subject, ss.subject_id)
        if subject:
            subjects_out.append(
                SubjectProgress(
                    subject_code=subject.code,
                    subject_name=subject.name,
                    score=ss.score,
                )
            )

    # 3. Get all topic mastery records
    topic_mastery_records = get_all_topic_mastery_for_student(db, student_id)
    topics_out: list[TopicProgress] = []
    for tm in topic_mastery_records:
        topic = db.get(Topic, tm.topic_id)
        if not topic:
            continue
        subject = db.get(Subject, topic.subject_id)
        topics_out.append(
            TopicProgress(
                topic_code=topic.code,
                topic_name=topic.name,
                subject_code=subject.code if subject else "",
                mastery=tm.mastery_value,
                mastery_label=mastery_label(tm.mastery_value),
                difficulty=tm.current_difficulty,
                evidence_count=tm.evidence_count,
            )
        )

    return StudentProgressResponse(
        student_id=student_id,
        overall_score=overall,
        active_subject_count=len(subject_scores),
        subjects=subjects_out,
        topics=topics_out,
    )
