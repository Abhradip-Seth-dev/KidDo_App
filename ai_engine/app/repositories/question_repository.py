from sqlmodel import Session, select
from app.models.question import Question
from app.models.subject import Subject, Topic

def get_subject_by_code(session: Session, code: str) -> Subject | None:
    return session.exec(select(Subject).where(Subject.code == code)).first()

def get_topic_by_code(session: Session, code: str) -> Topic | None:
    return session.exec(select(Topic).where(Topic.code == code)).first()

def get_published_questions_for_topic(
    session: Session,
    topic_id: int,
    difficulty: str,
) -> list[Question]:
    return list(session.exec(
        select(Question).where(
            Question.topic_id == topic_id,
            Question.difficulty == difficulty,
            Question.status == "published",
        )
    ).all())

def get_question_by_db_id(session: Session, question_id: int) -> Question | None:
    return session.get(Question, question_id)

def get_all_topics_for_subject(session: Session, subject_id: int) -> list[Topic]:
    return list(session.exec(select(Topic).where(Topic.subject_id == subject_id)).all())
