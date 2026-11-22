from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    # Application
    app_env: str = "development"
    app_port: int = 8000

    # Database
    database_url: str = "postgresql://kiddo_user:kiddo_password@localhost:5432/kiddodb"

    # Security
    secret_key: str = "dev-secret-key"

    # External services
    node_backend_url: str = "http://localhost:3000"

    # CORS
    cors_origins: list[str] = [
        "http://localhost:3000",
        "http://10.0.2.2:8000",
    ]

    # Scoring rules
    beginner_correct_points: int = 5
    beginner_incorrect_points: int = -2
    intermediate_correct_points: int = 10
    intermediate_incorrect_points: int = -5
    expert_correct_points: int = 15
    expert_incorrect_points: int = -8
    hint_penalty: int = 1

    # Adaptive engine knobs
    difficulty_window: int = 5
    level_up_threshold: int = 4
    level_down_threshold: int = 1
    recent_question_lookback: int = 10
    min_mastery_evidence: int = 3


settings = Settings()
