from sqlmodel import SQLModel, Session, create_engine

from app.core.config import settings

# SQLite requires check_same_thread=False for multi-threaded use in FastAPI.
_connect_args = (
    {"check_same_thread": False}
    if settings.database_url.startswith("sqlite")
    else {}
)

engine = create_engine(
    settings.database_url,
    connect_args=_connect_args,
    echo=settings.app_env == "development",
)


def create_db_and_tables() -> None:
    """Create all SQLModel tables. Called once at application startup."""
    SQLModel.metadata.create_all(engine)


def get_session():
    """FastAPI dependency that yields a database session."""
    with Session(engine) as session:
        yield session
