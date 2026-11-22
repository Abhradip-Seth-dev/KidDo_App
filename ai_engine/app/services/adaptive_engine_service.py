from app.core.config import settings

DIFFICULTY_ORDER = ["beginner", "intermediate", "expert"]

def evaluate_difficulty_decision(recent_attempts: list[bool]) -> str:
    """
    Analyses the last N valid attempts for a topic.
    Returns: 'level_up' | 'level_down' | 'keep'
    Requires exactly `difficulty_window` attempts to make a decision.
    """
    if len(recent_attempts) < settings.difficulty_window:
        return "keep"
    window = recent_attempts[-settings.difficulty_window:]
    correct_count = sum(1 for r in window if r)
    if correct_count >= settings.level_up_threshold:
        return "level_up"
    if correct_count <= settings.level_down_threshold:
        return "level_down"
    return "keep"

def apply_difficulty_progression(current: str, decision: str) -> str:
    """
    Applies a difficulty decision. Clamps between beginner and expert.
    Never skips levels: beginner → intermediate → expert only.
    """
    idx = DIFFICULTY_ORDER.index(current) if current in DIFFICULTY_ORDER else 0
    if decision == "level_up":
        idx = min(idx + 1, len(DIFFICULTY_ORDER) - 1)
    elif decision == "level_down":
        idx = max(idx - 1, 0)
    return DIFFICULTY_ORDER[idx]

def get_recommended_difficulty(current: str, recent_attempts: list[bool]) -> str:
    """Convenience: returns what difficulty WOULD be next (read-only, doesn't mutate)."""
    decision = evaluate_difficulty_decision(recent_attempts)
    return apply_difficulty_progression(current, decision)
