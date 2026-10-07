# ParaliSetu — Backend

**Stack:** Python · FastAPI · PostgreSQL + PostGIS · SQLAlchemy · Alembic

---

## 1. Set up a virtual environment

Always use an isolated virtual environment to avoid package conflicts:

### Windows (PowerShell)
```powershell
cd backend
python -m venv .venv
.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
pip install -r requirements.txt
```

### Linux / macOS (Bash / Zsh)
```bash
cd backend
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
pip install -r requirements.txt
```

---

## 2. Configuration & Environment Variables

Copy the template configuration file:
```bash
cp .env.example .env
```
Key settings in `.env`:
- `DATABASE_URL`: Connection string for PostgreSQL + PostGIS (e.g. `postgresql+psycopg2://paralisetu:paralisetu_dev@localhost:5432/paralisetu`).
- `DEMO_MODE`: Set to `true` to allow the universal OTP `123456` during offline presentations. Default is `false`.
- `JWT_SECRET_KEY`: Set a secure secret key before deployment.

---

## 3. Database & Local Services

Start PostgreSQL with PostGIS (requires Docker Desktop):
```bash
docker compose up -d
```

Run database migrations:
```bash
alembic upgrade head
```

Seed initial simulated demo data (farms, stubble lots, machines, trucks):
```bash
python scripts/seed.py
```

---

## 4. Run Development Server

```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```
Interactive API docs are available at: `http://localhost:8000/docs`

---

## 5. Run Test Suite

```bash
python -m pytest tests -v
```
- In-memory SQLite tests run automatically and test Auth, Token Refresh, and Stubble Estimation.
- Live PostGIS tests in `tests/test_postgis.py` run automatically when PostgreSQL + PostGIS is accessible and skip gracefully when offline.

---

## Folder layout

```
app/
  api/        Route handlers (auth, farmers, estimates)
  models/     SQLAlchemy ORM models
  schemas/    Pydantic request / response schemas
  services/   Business logic (estimation, OTP provider, payment adapter)
  core/       Config, DB session, security helpers, yield config
  main.py     FastAPI app entry point
alembic/      DB migrations (0001_initial_schema.py)
scripts/      seed.py demo dataset
tests/        pytest test suite
```
