from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core.config import settings
from app.core.database import create_db_and_tables


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    create_db_and_tables()
    from app.services.question_bank_seeder import seed_question_bank
    seed_question_bank()
    yield
    # Shutdown (nothing to clean up for now)


app = FastAPI(
    title="KidDo AI Engine",
    version="1.0.0",
    description="Adaptive learning engine",
    lifespan=lifespan,
)

# ---------------------------------------------------------------------------
# CORS
# ---------------------------------------------------------------------------
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ---------------------------------------------------------------------------
# Routers  (imported lazily so missing modules don't break the skeleton)
# ---------------------------------------------------------------------------
try:
    from app.api.routes.sessions import router as sessions_router
    app.include_router(sessions_router, prefix="/api/v1/sessions", tags=["sessions"])
except ImportError:
    pass

try:
    from app.api.routes.attempts import router as attempts_router
    app.include_router(attempts_router, prefix="/api/v1/attempts", tags=["attempts"])
except ImportError:
    pass

try:
    from app.api.routes.progress import router as progress_router
    app.include_router(progress_router, prefix="/api/v1/students", tags=["progress"])
except ImportError:
    pass

try:
    from app.api.routes.questions import router as questions_router
    app.include_router(questions_router, prefix="/api/v1/questions", tags=["questions"])
except ImportError:
    pass


# ---------------------------------------------------------------------------
# Root endpoints
# ---------------------------------------------------------------------------

@app.get("/")
async def root():
    return {"status": "ok", "service": "KidDo AI Engine", "version": "1.0.0"}


@app.get("/health")
async def health():
    return {"status": "healthy", "database": "connected"}
