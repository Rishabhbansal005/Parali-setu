# ParaliSetu — Engineering Learning Log

> Chronological log of major architectural milestones, engineering challenges, root causes, solutions, and verification metrics for the ParaliSetu project.
> Maintained under Rule 9 of `docs/AGENT_RULES.md`.

---

## Entry 1: Day-1 Backend Core & PostGIS Foundation

- **Date:** 2026-10-06 / 2026-10-07
- **Branch:** `feat/backend-core` (merged to `main`)
- **Milestone:** Initial API Foundation, Geospatial Schema, Agronomic Estimation
- **Status:** **BUILT**

### 1. What Was Built
- **FastAPI REST API Structure:** Structured modular application under `backend/app/` with clean separation of models, schemas, API routers (`auth`, `farms`, `estimate`), and business services.
- **Relational & Spatial Database Schema:** Designed and scripted 12 relational models via SQLAlchemy 2.0 and GeoAlchemy2 covering the full lifecycle: `users`, `farms`, `buyers`, `machines`, `trucks`, `bookings`, `estimates`, `offers`, `payments`, `burn_checks`, `impact_log`, and `weighbridge_records`.
- **Alembic Database Migrations:** Created baseline Alembic migration script (`001_initial_schema.py`) initializing the schema with native PostGIS extension activation and spatial indexing (`idx_farms_location`).
- **Estimation Service:** Implemented agronomic algorithms modeling stubble yield by rice variety (e.g. `PR-126`, `Pusa-44`, `Basmati`) and calculated avoided emissions ($\text{CO}_2$, $\text{PM}_{2.5}$, ash) based on published ICAR/CPCB emission factors.
- **Simulated Seeding Pipeline:** Created `backend/scripts/seed.py` generating realistic geographic seed data across Tarn Taran, Amritsar, Ludhiana, and Ferozepur districts.

### 2. Engineering Challenges & Root Causes
- **Challenge:** Handling spatial Point geometry in Pydantic serialization without throwing binary encoding errors.
- **Root Cause:** GeoAlchemy2 `Geometry` fields return WKB (Well-Known Binary) elements that default JSON encoders cannot serialize.
- **Solution:** Configured custom Pydantic validators and helper converters utilizing Shapely `to_shape()` to extract float `(latitude, longitude)` pairs cleanly in API response schemas.

### 3. Verification Metrics
- Pytest suite: 12 unit tests passing for estimation models, farm geometry creation, and auth flows in local SQLite/mock test harness.

---

## Entry 2: Backend Hardening, Security Overhaul & Live Supabase Verification

- **Date:** 2026-10-07 / 2026-10-08
- **Branch:** `chore/hardening` (merged to `main` at `f07b6d5`)
- **Milestone:** CVE Remediation, Production Auth Controls, Live Supabase PostGIS Integration
- **Status:** **BUILT**

### 1. What Was Built
- **Dependency Security Audit & PyJWT Migration:**
  - Ran `pip-audit` identifying known vulnerabilities in legacy `python-jose` (CVE-2024-33663, CVE-2024-33664) and sub-dependencies.
  - Completely replaced `python-jose` with modern `PyJWT[crypto]==2.15.1` in `backend/app/core/security.py`.
  - Pinned `bcrypt==4.0.1` for clean compatibility with `passlib 1.7.4`.
  - Achieved **0 vulnerabilities** on `pip-audit`.
- **Production-Grade Auth Hardening:**
  - Added strict OTP expiration enforcement (`OTP_EXPIRY_SECONDS=300`).
  - Implemented send rate limiting (`OTP_MAX_SENDS_PER_WINDOW=5` within 10-minute sliding window).
  - Implemented progressive lockout: 5 consecutive failed OTP entries triggers account lockout (`OTP_LOCKOUT_SECONDS=300`). Tested that demo credentials cannot bypass an active lockout.
  - Implemented configurable `DEMO_MODE` flag (defaults to `False` in production).
- **Supabase Cloud Database Integration:**
  - Configured PostgreSQL 15 connection via Supabase Transaction Pooler (PgBouncer).
  - Built connection string normalizer in `backend/app/core/config.py` to auto-strip PgBouncer query parameters (`?pgbouncer=true`) which cause psycopg2 connection errors, and ensure `postgresql+psycopg2://` driver prefix.
  - Applied Alembic migrations live to Supabase: successfully provisioned PostGIS 3.3 and all 12 relational tables.
  - Populated Supabase with 37 simulated users, 20 farms, 5 buyers, 6 machines, and 5 trucks via `scripts/seed.py`.
  - Verified live PostGIS geospatial functionality via integration test `test_real_postgis_farm_geometry` calculating geodesic distance between Punjab coordinates using `ST_Distance`.
- **Supabase Row Level Security (RLS) & Idempotency Audit:**
  - Verified `scripts/seed.py` idempotency: repeated execution skips already-seeded records with zero duplicate rows created.
  - Verified `tests/test_postgis.py` is read-only: performs geometry literal math and leaves zero test rows in the database.
  - Audited all 14 tables in the `public` schema for RLS status; established that the backend connecting as the Supabase `postgres` user possesses the `BYPASSRLS` role attribute.

### 2. Engineering Challenges & Lessons Learned
- **Challenge 1: Supabase Pooler DSN Incompatibility:**
  - *Symptom:* `psycopg2.OperationalError: invalid connection option "pgbouncer"`.
  - *Root Cause:* Supabase connection strings copy-pasted from the dashboard include `?pgbouncer=true`. While understood by Prisma and Go drivers, psycopg2's C library treats unrecognized query parameters as invalid connection options.
  - *Fix:* Added a Pydantic `field_validator` in `backend/app/core/config.py` that parses the DSN, extracts and strips the query parameters, and sets the proper SQLAlchemy dialect.
- **Challenge 2: Default Environment Setting Isolation in Pytest:**
  - *Symptom:* `test_demo_mode_defaults_to_false` failed when developer created a local `.env` with `DEMO_MODE=true`.
  - *Root Cause:* Pydantic's `BaseSettings` automatically discovers and parses `.env` files from disk if present unless explicitly disabled.
  - *Fix:* In `tests/test_auth.py`, invoked `monkeypatch.delenv("DEMO_MODE", raising=False)` and instantiated `Settings(_env_file=None)`, cleanly asserting default behavior without weakening or removing any test assertion.

### 3. Verification Metrics
- `pip-audit`: 0 known vulnerabilities found across all pinned packages.
- `pytest`: 13 passed tests (100% pass rate), including live Supabase PostGIS query.
- Live API Verification: Verified `/health`, `/auth/otp/send`, and `/auth/otp/verify` running on `uvicorn`.

---

## 3. Technology Status Roadmap

To maintain integrity per Rule 9b, all capabilities are tracked below:

| Feature / Capability | Status | Notes |
| :--- | :--- | :--- |
| Core REST API (FastAPI) | **BUILT** | Routes for auth, farms, estimates live. |
| JWT Authentication & OTP Lockout | **BUILT** | PyJWT 2.15, expiry, rate-limits, lockout. |
| PostGIS Spatial Relational Models | **BUILT** | 12 tables + spatial index active on Supabase. |
| Agronomic Estimation Formulas | **BUILT** | Stubble tonnage and carbon/ash offsets. |
| Live Seed Data on Supabase | **BUILT** | 37 users, 20 farms, 5 buyers, 6 machines, 5 trucks. |
| Flutter Farmer Mobile App (Phase 1) | **PLANNED** | Vernacular UI, offline SQLite sync, booking flow. |
| Aggregator & Buyer Web Dashboards (Phase 2 & 3) | **PLANNED** | Next.js 14, interactive maps, live dispatch view. |
| Vehicle Routing & Dispatch Engine | **PLANNED** | Google OR-Tools + OSRM distance matrix integration. |
| Satellite Burn Verification Pipeline | **PLANNED** | Sentinel-2 / Google Earth Engine post-harvest verification. |
| Automated Weighbridge & Payment Escrow | **PLANNED** | Razorpay / UPI direct bank transfer integration. |
