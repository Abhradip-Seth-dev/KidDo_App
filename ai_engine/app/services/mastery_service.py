from app.core.config import settings
from typing import Optional

def calculate_mastery(valid_attempt_results: list[bool]) -> Optional[float]:
    """
    Returns mastery % (0–100) or None if insufficient evidence.
    Uses last `recent_question_lookback` valid attempts.
    """
    if len(valid_attempt_results) < settings.min_mastery_evidence:
        return None
    window = valid_attempt_results[-settings.recent_question_lookback:]
    correct = sum(1 for r in window if r)
    return round((correct / len(window)) * 100, 1)

def mastery_label(mastery: Optional[float]) -> str:
    if mastery is None:
        return "not_enough_data"
    if mastery >= 80:
        return "mastered"
    if mastery >= 50:
        return "developing"
    return "needs_practice"
