import json
import uuid
import os
from pathlib import Path
from sqlmodel import Session, select
from app.core.database import engine
from app.models.subject import Subject, Topic
from app.models.question import Question

# Map folder names to subject metadata
SUBJECT_MAP = {
    "math":     {"code": "MATH",     "name": "Mathematics"},
    "gk":       {"code": "GK",       "name": "General Knowledge"},
    "english":  {"code": "ENGLISH",  "name": "English"},
    "computer": {"code": "COMPUTER", "name": "Computer Science"},
}

# Map unit number to difficulty based on progression
def infer_difficulty(unit_number: int) -> tuple[str, int]:
    """Units 1-3 = beginner, 4-7 = intermediate, 8-10 = expert"""
    if unit_number <= 3:
        return "beginner", 1
    elif unit_number <= 7:
        return "intermediate", 2
    else:
        return "expert", 3

def map_question_type(raw_type: str) -> str:
    mapping = {
        "MCQ": "multiple_choice",
        "IMG_MCQ": "multiple_choice",
        "TRUE_FALSE": "true_false",
        "MATCH": "matching",
    }
    return mapping.get(raw_type.upper(), "multiple_choice")

def build_options(item: dict) -> list[dict]:
    """Convert option_1..option_4 to [{option_id, text}] format, skipping nulls."""
    options = []
    for key, label in [("option_1","A"),("option_2","B"),("option_3","C"),("option_4","D")]:
        val = item.get(key)
        if val is not None:
            options.append({"option_id": label, "text": str(val)})
    return options

def find_correct_option_id(options: list[dict], correct_ans: str) -> str:
    """Find which option_id matches the correct answer text."""
    for opt in options:
        if opt["text"].strip().lower() == str(correct_ans).strip().lower():
            return opt["option_id"]
    return options[0]["option_id"] if options else "A"

# Try to find the assets directory - look relative to this file and common locations
def find_assets_dir() -> Path:
    candidates = [
        Path(__file__).parents[3] / "kiddo_app" / "assets" / "data" / "json_files",
        Path("E:/KidDo/Conquer/kiddo_app/assets/data/json_files"),
        Path("../kiddo_app/assets/data/json_files"),
    ]
    for p in candidates:
        if p.exists():
            return p
    return candidates[0]  # Return first candidate even if not found (seeder will just skip)

def seed_question_bank():
    """Idempotent seeder: skips if data already exists."""
    with Session(engine) as session:
        existing = session.exec(select(Subject)).first()
        if existing:
            return  # Already seeded

        assets_dir = find_assets_dir()

        for folder, meta in SUBJECT_MAP.items():
            # Create subject
            subject = Subject(code=meta["code"], name=meta["name"])
            session.add(subject)
            session.flush()

            subject_dir = assets_dir / folder
            if not subject_dir.exists():
                continue

            for unit_num in range(1, 11):
                json_file = subject_dir / f"{folder}_unit_{unit_num}.json"
                if not json_file.exists():
                    continue

                with open(json_file, encoding="utf-8") as f:
                    items = json.load(f)

                if not items:
                    continue

                unit_name = items[0].get("unit_name", f"Unit {unit_num}")
                topic_code = f"{meta['code']}-U{unit_num}"
                difficulty, diff_rank = infer_difficulty(unit_num)

                # Create topic
                topic = Topic(
                    subject_id=subject.id,
                    code=topic_code,
                    name=unit_name,
                    unit_number=unit_num,
                )
                session.add(topic)
                session.flush()

                for idx, item in enumerate(items, start=1):
                    options = build_options(item)
                    correct_ans = item.get("correct_ans", "")
                    correct_option_id = find_correct_option_id(options, correct_ans)
                    q_type = map_question_type(item.get("Question_type", "MCQ"))
                    media_url = item.get("image")

                    question = Question(
                        question_id=f"{meta['code']}-U{unit_num}-Q{idx:03d}",
                        subject_id=subject.id,
                        topic_id=topic.id,
                        grade_class="Class 3",
                        difficulty=difficulty,
                        difficulty_rank=diff_rank,
                        question_type=q_type,
                        content={
                            "question": item.get("question", ""),
                            "options": options,
                            "media_url": media_url,
                        },
                        answer_key={
                            "correct_option_id": correct_option_id,
                            "explanation": f"The correct answer is {correct_ans}.",
                            "hints": [],
                        },
                        status="published",
                        content_version=1,
                    )
                    session.add(question)

        session.commit()
        print("✅ Question bank seeded successfully.")
