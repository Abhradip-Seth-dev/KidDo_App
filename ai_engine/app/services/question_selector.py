import random
from typing import Optional
from app.core.config import settings

def select_next_question(
    candidate_questions: list[dict],   # list of dicts with keys: id, difficulty, topic_id
    current_difficulty: str,
    recently_seen_ids: list[int],
    fallback_allow_seen: bool = True,
) -> Optional[dict]:
    """
    Implements controlled randomisation per the adaptive learning spec:
    1. Filter to current difficulty
    2. Exclude recently seen (lookback window)
    3. Shuffle and pick first
    4. If pool exhausted, optionally fall back to including seen questions (revision mode)
    Returns the selected question dict or None if pool is truly empty.
    """
    eligible = [
        q for q in candidate_questions
        if q["difficulty"] == current_difficulty
        and q["id"] not in recently_seen_ids
    ]

    if not eligible:
        if fallback_allow_seen:
            # Revision fallback: allow recently seen questions
            eligible = [
                q for q in candidate_questions
                if q["difficulty"] == current_difficulty
            ]
        if not eligible:
            return None   # Pool exhausted — caller returns 404 with pool_exhausted reason

    random.shuffle(eligible)
    return eligible[0]
