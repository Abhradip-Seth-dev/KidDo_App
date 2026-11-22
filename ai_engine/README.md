# KidDo AI Engine

Standalone **FastAPI** adaptive learning engine for the KidDo Conquer app.

## Overview

The AI Engine is a self-contained Python microservice responsible for:

- **Adaptive difficulty** – dynamically adjusts question difficulty per student based on recent performance.
- **Session management** – tracks active quiz sessions and time-on-task.
- **Attempt recording** – stores every answer, calculates scores, and triggers level adjustments.
- **Progress & mastery** – exposes per-student, per-topic mastery profiles consumed by the Flutter client.
- **Question bank** – seeded SQLite (dev) or PostgreSQL (prod) store of curriculum questions.

## Architecture

```
Flutter Client  ──►  /api/v1/*  ──►  FastAPI AI Engine (port 8000)
                                          │
                              ┌───────────┴────────────┐
                              │  SQLite (dev)           │
                              │  PostgreSQL (prod)       │
                              └────────────────────────-┘
```

The engine **does not** issue its own auth tokens in production — it validates JWTs minted by the Node.js backend (`NODE_BACKEND_URL`).

## Quick Start

```bash
cd ai_engine
python -m venv .venv
# Windows
.venv\Scripts\activate
# macOS / Linux
source .venv/bin/activate

pip install -r requirements.txt
cp .env.example .env          # edit SECRET_KEY at minimum
uvicorn main:app --reload --port 8000
```

API docs available at **http://localhost:8000/docs** once the server is running.

## Key Routes

| Prefix | Purpose |
|---|---|
| `GET /` | Health ping |
| `GET /health` | Database connectivity check |
| `/api/v1/sessions` | Create / end quiz sessions |
| `/api/v1/attempts` | Submit answers, get scored results |
| `/api/v1/students` | Per-student progress & mastery |
| `/api/v1/questions` | Browse / filter question bank |

## Configuration

All tuneable parameters (scoring points, difficulty thresholds) live in `.env` — no code changes required. See `.env.example` for the full list.

## Dev vs Production

| Setting | Development | Production |
|---|---|---|
| `DATABASE_URL` | `sqlite:///./ai_engine_dev.db` | `postgresql://user:pass@host/db` |
| `APP_ENV` | `development` | `production` |
| `SECRET_KEY` | any string | 32+ char random secret |
