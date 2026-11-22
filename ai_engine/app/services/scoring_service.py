from app.core.config import settings

SCORING_RULES = {
    "beginner":     {"correct": settings.beginner_correct_points,     "incorrect": settings.beginner_incorrect_points},
    "intermediate": {"correct": settings.intermediate_correct_points, "incorrect": settings.intermediate_incorrect_points},
    "expert":       {"correct": settings.expert_correct_points,       "incorrect": settings.expert_incorrect_points},
}

def calculate_points(difficulty: str, is_correct: bool, hints_used: int = 0) -> int:
    """Returns net point change (can be negative). Includes hint penalty."""
    rule = SCORING_RULES.get(difficulty, SCORING_RULES["beginner"])
    base = rule["correct"] if is_correct else rule["incorrect"]
    hint_deduction = hints_used * settings.hint_penalty if is_correct else 0
    return base - hint_deduction

def clamp_score(current_score: int, delta: int, minimum: int = 0) -> int:
    """Apply delta to score and clamp to minimum (default 0)."""
    return max(minimum, current_score + delta)

def get_score_reason(difficulty: str, is_correct: bool) -> str:
    """Human-readable reason string for score transaction."""
    action = "correct" if is_correct else "incorrect"
    return f"{action}_{difficulty}_answer"

def get_active_scoring_rule_version() -> int:
    return 1
