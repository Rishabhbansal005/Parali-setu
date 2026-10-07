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

## 6. Known limitations

- **In-Memory OTP Store:** The OTP store `_MOCK_OTP_STORE` lives in process memory. It operates on a single Python process only; restarting the server clears pending state, and multi-process deployments (`uvicorn --workers N`) cannot share state without Redis.
- **OTP Expiry & Rate Limiting (Implemented):** OTP expiry is enforced using `OTP_EXPIRY_SECONDS` (300s); expired codes are rejected. Throttling is enforced per phone number via `OTP_MAX_SENDS_PER_WINDOW` (5 requests / 10 min) and `OTP_MAX_VERIFY_ATTEMPTS` (5 consecutive wrong attempts triggers a 5-minute lockout). Note: Because storage is in-process memory, limits apply per worker process.
- **Mocked Payments:** The escrow payment adapter (`MockPaymentProvider`) simulates authorization and release; it does not connect to live payment gateways.
- **Simulated Demo Data:** All records populated by `scripts/seed.py` (farmers, farms, machines, bookings) are simulated test datasets for demo presentation purposes.

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
