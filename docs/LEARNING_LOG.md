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
- **Estimation Service:** Implemented agronomic algorithms modeling stubble yield range (low/mid/high) by rice variety (e.g. `PR-126`, `Pusa-44`, `Basmati`) and estimated gross income range. Note: Avoided emissions ($\text{CO}_2$, $\text{PM}_{2.5}$, ash) remain **PLANNED** placeholders (`None`) in `impact_log` awaiting verified published factors per Rule 6.
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
| Agronomic Estimation Formulas | **BUILT** | Stubble tonnage range and income estimates. Avoided emissions remain PLANNED placeholders. |

| Live Seed Data on Supabase | **BUILT** | 37 users, 20 farms, 5 buyers, 6 machines, 5 trucks. |
| Flutter Farmer Mobile App (Phase 1) | **BUILT** | Vernacular UI (Hindi/Punjabi), offline mock repo fallback, live API client with 60s timeout, auto-retry, secure storage. |
| Aggregator & Buyer Web Dashboards (Phase 2 & 3) | **PLANNED** | Next.js 14, interactive maps, live dispatch view. |
| Vehicle Routing & Dispatch Engine | **PLANNED** | Google OR-Tools + OSRM distance matrix integration. |
| Satellite Burn Verification Pipeline | **PLANNED** | Sentinel-2 / Google Earth Engine post-harvest verification. |
| Automated Weighbridge & Payment Escrow | **PLANNED** | Razorpay / UPI direct bank transfer integration. |

---

## Entry 3: Backend Deployment Preparation & Targeted Demo Allow-List

- **Date:** 2026-10-08
- **Branch:** `chore/deploy`
- **Milestone:** Production JWT Secret Guard, Demo Phone Allow-List, and Render Deployment Configuration
- **Status:** **BUILT**

### 1. What Was Built
- **Production Secret Guard (`app/core/config.py`):** Added `model_validator` enforcing that when `DEBUG=False`, the application strictly refuses to start if `JWT_SECRET_KEY` is missing or remains the default placeholder. Provides a student-friendly error message instructing how to generate a 32-byte secret using `openssl rand -hex 32`.
- **Targeted Demo Phone Allow-List (`app/api/auth.py`):** Replaced universal `123456` OTP bypass with an allow-list: `123456` is accepted only when `DEMO_MODE=True` AND the requested phone number is present in `DEMO_PHONES`. All other numbers are rejected. Retained all expiry, rate limiting, and 5-attempt lockout security controls.
- **Render Host Configuration:** Added `render.yaml`, `.python-version` (pinning Python `3.12.3`), dynamic start command using `$PORT` (`uvicorn app.main:app --host 0.0.0.0 --port $PORT`), and lightweight `/health` check.
- **Deployment Documentation (`docs/DEPLOY.md`):** Authored complete step-by-step student deployment instructions covering Render UI clicks, variable configuration, verification curl scripts, log analysis, and pre-demo checklist.

### 2. Engineering Challenges & Verified Facts
- **Render Python Version Pinning:** Verified from official Render documentation that Render uses `PYTHON_VERSION` environment variable or `.python-version` file, and does not use `runtime.txt`.
- **Test Harness Secret Isolation:** Added test-only cryptographic secret in `tests/conftest.py` so unit tests execute cleanly without needing local `.env` overrides or weakening production guards.

### 3. Verification Metrics
- Pytest suite: 18 passed tests (100% pass rate) covering JWT secret guard in production mode, allow-listed demo OTP verification, non-allowlisted phone rejection, and live PostGIS geometry rollback tests.

---

## Entry 4: Phase 1 Farmer Vernacular Mobile App (Flutter)

- **Date:** 2026-10-08
- **Branch:** `feat/app-v1`
- **Milestone:** Phase 1 Farmer Vernacular Mobile Application
- **Status:** **BUILT**

### 1. What Was Built
- **4-Screen Vernacular User Flow:**
  - **Language Selection Screen (`LanguageChoiceScreen`):** Full bilingual support for Hindi (हिंदी) and Punjabi (ਪੰਜਾਬੀ). Large accessible cards, persisting locale state across app lifecycle.
  - **Phone & OTP Login Screen (`PhoneLoginScreen`):** Phone validation, 6-digit OTP entry, debug-only `"123456"` hint via `kDebugMode` (never shown in release builds), and optional seeded farmer quick-login button (`--dart-define=DEMO_LOGIN=true`).
  - **Field Details Screen (`FieldDetailsScreen`):** Prominent microphone button placeholder routing directly to intuitive touch inputs, 0.5-acre stepper, variety ChoiceChips (`PR-126`, `Pusa-44`, `Basmati`, `other`), harvest method selector (Combine Harvester / Manual), and harvest date picker.
  - **Estimate Screen (`EstimateScreen`):** Displays stubble tonnage range (`low - high` and `~mid`), estimated income range (`₹ low - ₹ high` at ₹1,200/tonne), clear weighbridge measurement disclaimer, and next-step advisory cards.
- **Vernacular Localization & Accessibility:**
  - All UI strings centralized in `app/lib/l10n/app_strings.dart` with Hindi and Punjabi dictionaries.
  - Per Rule 10, all Gurmukhi Punjabi strings are explicitly tagged with `/* NEEDS NATIVE REVIEW */` annotations for domain verification.
  - Typography tuned for Devanagari and Gurmukhi script readability with minimum 56dp interactive touch targets and high-contrast agricultural palette.
- **Resilient Network Client & Repositories (`farmer_repository.dart`):**
  - **Cold-Start Resilience:** 60-second request timeout with friendly waking message ("सर्वर शुरू हो रहा है, कृपया प्रतीक्षा करें" / "ਸਰਵਰ ਸ਼ੁਰੂ ਹੋ ਰਿਹਾ ਹੈ, ਕਿਰਪਾ ਕਰਕੇ ਉਡੀਕ ਕਰੋ").
  - **Auto-Retry & Offline Handling:** Automatic single-retry on transient 502/503/504 or network socket failures; clear offline banners when device has no internet connection.
  - **Secure Token Persistence:** Implemented `FlutterSecureStorage` for encrypted JWT storage (no plaintext shared preferences).
  - **Pluggable Architecture:** Automatic fallback to `MockFarmerRepository` when running without a backend or when `--dart-define=API_BASE_URL` is omitted, allowing smooth offline judging demos.
- **Platform Configuration & Security:**
  - Flutter default Android SDK versions maintained (`compileSdk = 35`, `minSdk = 21`, `targetSdk = 35`).
  - Cleartext HTTP allowed **strictly** in `app/android/app/src/debug/AndroidManifest.xml` (`android:usesCleartextTraffic="true"`) for local testing. The release manifest (`app/android/app/src/main/AndroidManifest.xml`) strictly forbids cleartext traffic.

### 2. Engineering Challenges & Lessons Learned
- **Challenge 1: RenderFlex Overflow on Language Selection Screen:**
  - *Symptom:* `A RenderFlex overflowed by 11 pixels on the right` during first launch on 360dp width physical device.
  - *Root Cause:* The language title and subtitle `Column` inside the selection card `Row` expanded to its intrinsic content width without flex constraint.
  - *Fix:* Wrapped the column in `Expanded(child: Column(...))`, allowing flexible text flow and preventing horizontal overflow.
- **Challenge 3: Flutter 3.47 Color API Deprecations:**
  - *Symptom:* Deprecation warnings when calling `.withOpacity()`.
  - *Fix:* Modernized theme tokens in `theme.dart` to use `.withValues(alpha: ...)`.

### 3. Verification Metrics
- `flutter analyze`: **0 issues found** (clean lint).
- `flutter test`: **5/5 unit & widget tests passed** (100% pass rate).
- Physical Device Test: Deployed and tested live on physical Android device (`Realme RMX3780 / 5L4DS8BALB6XIJ9H`, Android 15 API 35) using Impeller Vulkan backend.
- Release APK Build: Built production release bundle `build/app/outputs/flutter-apk/app-release.apk` (48.1 MB) successfully without debug flags or cleartext permissions.

