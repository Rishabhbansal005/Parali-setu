# ParaliSetu — Backend

**Stack:** Python · FastAPI · PostgreSQL + PostGIS · SQLAlchemy · Alembic

## Quick start (Day 1, Oct 8)

```bash
cd backend
python -m venv .venv && .venv\Scripts\activate   # Windows
pip install -r requirements.txt
cp .env.example .env          # fill in your values
alembic upgrade head
uvicorn app.main:app --reload
```

## Folder layout

```
app/
  api/        Route handlers (one file per domain)
  models/     SQLAlchemy ORM models
  schemas/    Pydantic request / response schemas
  services/   Business logic (matching, escrow, satellite, …)
  core/       Config, DB session, security helpers
  main.py     FastAPI app entry point
alembic/      DB migrations
tests/        pytest test suite
```

> Read SPEC.md and docs/AGENT_RULES.md before writing any code.
