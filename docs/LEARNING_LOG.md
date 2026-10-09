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

---

## Entry 5: User Profile Management API & Long-Lived Farmer Sessions

- **Date:** 2026-10-08
- **Branch:** `feat/profile-api`
- **Milestone:** User Profile API & Refresh Lifecycle
- **Status:** **BUILT**

### 1. What Was Built
- **Enriched `GET /auth/me` Endpoint:** Returns full profile including `name`, `phone`, `phone_e164`, `role`, `roles`, `language`, `preferred_language`, `village`, `district`, and `state`.
- **Owner-Only `PATCH /auth/me` Endpoint:** Allows authenticated farmers to update their name, language preference (`en`, `hi`, `pa`), village, and district. Strict input length validation (max 100 characters) and allowed language enumeration enforcement. Secured via FastAPI `Depends(get_current_user)` ensuring strict owner-only mutations.
- **Configurable Token Lifetimes:**
  - `ACCESS_TOKEN_EXPIRE_MINUTES`: Configured to 60 minutes.
  - `REFRESH_TOKEN_EXPIRE_DAYS`: Configured to 30 days, specifically sized so farmers do not encounter repeated session expirations during the compact 10-15 day stubble harvest and clearing window.
- **Token Refresh Verification:** Validated `POST /auth/token/refresh` with full roundtrip tests, confirming new access and refresh tokens are issued and malformed/access tokens are rejected with 401.
- **Supabase Schema Verification:** Audited existing PostgreSQL schema from `0001_initial_schema.py`; verified that `users` already contains `name`, `phone_e164`, `preferred_language`, `roles`, `village`, `district`, and `state`. No Alembic migration needed.

### 2. Verification Metrics
- Pytest suite: **21 passed tests** (100% pass rate) covering profile retrieval, profile updates, language validation, unauthorized update rejection, and token refresh lifecycle.

---

## Entry 6: Trilingual Farmer UX, Offline Architecture, Split APKs & Physical Device Validation

- **Date:** 2026-10-08
- **Branch:** `feat/app-ux`
- **Milestone:** Farmer-First UX Overhaul, Offline Resilience & Device Verification
- **Status:** **BUILT & VERIFIED**

### 1. What Was Built
- **Trilingual Accessibility (English Default, Hindi, Punjabi):**
  - Configured English as the default application language per SPEC.md §13 v0.2.
  - Implemented complete string maps for English, Hindi, and Punjabi (all Punjabi strings explicitly annotated with `/* NEEDS NATIVE REVIEW */`).
  - Added visible language chips to Onboarding and a dedicated language picker in Profile with persistent storage in `FlutterSecureStorage`.
- **First-Launch Onboarding Flow:**
  - 3-slide swipeable carousel covering key farmer value propositions (Slide 1: "Do not burn it. Sell it.", Slide 2: "We find the machine, truck and buyer for you.", Slide 3: "Get paid on the actual weight, safely.").
  - Interactive language chips, animated page indicator dots, and Skip/Next controls.
  - 100% vector-drawn custom illustrations using Flutter `CustomPainter` (sun and golden stubble, machine and truck logistics, certified digital weighbridge scale); zero copyrighted external assets.
- **Robust Farmer Session Lifecycle:**
  - Seamless auto-login on app launch if valid tokens exist in `FlutterSecureStorage`.
  - Silent 401 token refresh interceptor via `POST /auth/token/refresh`.
  - Offline cache fallback with a warm amber offline banner if device network is unavailable.
  - Log out securely wipes auth tokens while preserving the farmer's selected language.
- **Farmer-Friendly Auth UX:**
  - Phone login with prominent `+91` badge, large input typography, and plain-language validation errors.
  - 6-box OTP entry with auto-focus traversal, auto-submission at 6 digits, 30-second resend countdown timer, and "Change Number" navigation.
  - Debug-only demo hint ("123456") that is completely stripped in release builds.
- **Home & Profile Screens:**
  - Personalized greeting with farmer name lookup (`Welcome, Gurpreet Singh`).
  - High-visibility primary action card ("Check my stubble value") and "How It Works" educational flow.
  - Strict 2-tab bottom navigation (`Home` and `Profile`), with future features clearly badged as "Coming soon".
  - Profile tab featuring editable name modal bottom sheet, read-only phone number, village & district display, language switcher, prototype simulation note, and red-accented log out button.
- **Agronomic Stubble & Earnings Estimation:**
  - High-impact range card displaying low-to-high dry stubble yield (e.g., `6.4 - 9.6 Tonnes`, central estimate `~8.0 Tonnes` for 4.0 acres PR-126).
  - Custom gradient range bar visualizing central estimate positioning.
  - Estimated earnings calculated from a single centralized constant (`AppConstants.assumedPricePerTonneInr = 1200.0`), displaying assumed price badge and certified weighbridge disclaimer.
- **Design Tokens & Bundled Offline Fonts:**
  - Deep agricultural green (`#1C6B32`), warm paper background (`#F9FAF7`), wheat gold accent (`#D99B26`), rounded card geometry (16-24dp), and minimum 56dp touch targets.
  - Bundled offline Noto Sans, Noto Sans Devanagari, and Noto Sans Gurmukhi fonts (~136 KB total), eliminating online font download delays.

### 2. Physical Device Verification (Realme RMX3780 / 5L4DS8BALB6XIJ9H)
- Successfully deployed release build to physical hardware over ADB.
- Captured 6 production screenshots saved in `docs/screenshots/`:
  1. `docs/screenshots/onboarding.png`
  2. `docs/screenshots/login.png`
  3. `docs/screenshots/otp.png`
  4. `docs/screenshots/home.png`
  5. `docs/screenshots/profile.png`
  6. `docs/screenshots/estimate.png`

### 3. Verification Metrics & APK Sizes
- `flutter analyze`: **0 issues found** (clean lint).
- `flutter test`: **8/8 unit & widget tests passed** (100% pass rate).
- Production Release Split APKs (`flutter build apk --release --split-per-abi`):
  - `app-arm64-v8a-release.apk`: **17.03 MB** (well below the 25 MB budget limit; 32% headroom remaining).
  - `app-armeabi-v7a-release.apk`: **14.47 MB**
  - `app-x86_64-release.apk`: **18.45 MB**

---

## Entry 5: Core Matching Engine & Options Screen (Google OR-Tools CP-SAT)

- **Date:** 2026-10-08
- **Branch:** `feat/matching-engine`
- **Goal:** Implement multi-stakeholder constraint optimization matching farmer harvest windows to nearby baler machines, transport trucks, and biomass buyers, and present 2–3 ranked options to the farmer on mobile.

### 1. What Was Built
- **Backend Matching Service (`backend/app/services/matching.py`):**
  - Integrated `ortools.sat.python.cp_model` (Google OR-Tools CP-SAT solver).
  - Implemented Haversine great-circle distance algorithm for geo-spatial filtering.
  - Formulated constraint optimization model:
    - Distance bounds (balers $\le 45\text{ km}$, buyers $\le 85\text{ km}$).
    - Time-window feasibility ($t_{pickup} \ge \text{harvest\_date}$).
    - Financial objective maximizing net earnings ($\text{gross} - \text{baler\_cost} - \text{transport\_cost}$).
    - Environmental emission calculation: Avoided $1.5\text{ tonnes } CO_2$ and $18.0\text{ kg } PM_{2.5}$ per tonne diverted (CEEW / NEERI factors).
  - Returns 3 ranked bundle profiles:
    1. *Best Value* (Maximum net in-hand payout).
    2. *Fastest Pickup* (Earliest pickup within 24–48 hours).
    3. *Local Green Energy* (Prioritizing Bio-CNG refineries).
- **Matching API Endpoints (`backend/app/api/matching.py`):**
  - `POST /matching/find-bundles`: Solves CP-SAT optimization; persists `Offer` records in Supabase PostGIS when `estimate_id` is passed.
  - `GET /matching/estimate/{estimate_id}/bundles`: Convenience query for existing field estimates.
  - Configured optional bearer token dependency so exploratory requests work without prior login friction.
- **Flutter Options Screen (`app/lib/screens/options_screen.dart`):**
  - Top field summary banner displaying acres, crop variety, and estimated recoverable biomass tonnage.
  - 3 ranked bundle cards with color-coded chips, partner identity breakdown (Baler CHC, Truck Logistics, Factory Buyer), pickup schedule, transparent net in-hand calculation, and environmental impact pill.
  - 56dp primary CTA button with interactive modal bottom sheet displaying booking confirmation and simulated factory escrow lock notice.
- **Repository & Navigation Wiring:**
  - Added `getMatchedBundles` to `FarmerRepository`, `ApiFarmerRepository`, and `MockFarmerRepository`.
  - Added primary "Choose Stubble Pickup Bundle" navigation button in `EstimateScreen`.
  - Added trilingual localization keys in English, Hindi, and Punjabi (`AppStrings`).

### 2. Verification Metrics
- `pytest`: **24/24 tests passed** (including `test_haversine_distance`, `test_matching_engine_solver`, and `test_matching_api_endpoint`).
- `flutter analyze`: **0 issues found** (100% clean lint).
- `flutter test`: **10/10 unit & widget tests passed** (including `test/options_screen_test.dart`).

---

## Entry 8: Booking Lifecycle State Machine, Escrow Hold & Dharamkanta Certified Weighbridge Release

- **Date:** 2026-10-09
- **Branch:** `feat/booking-lifecycle`
- **Goal:** Implement the complete end-to-end booking state machine, simulated factory escrow fund locking, and certified Dharamkanta weighbridge ticket gross/tare calculation releasing net payout directly to the farmer.

### 1. What Was Built
- **Pydantic Schemas (`backend/app/schemas/booking.py`):**
  - `BookingCreateRequest`: Validates `offer_id` and optional notes.
  - `BookingStatusUpdateRequest`: Governs lifecycle state transitions (`confirmed` -> `picked_up` -> `cancelled`).
  - `WeighbridgeSubmitRequest`: Accepts `gross_weight_tonnes`, `tare_weight_tonnes`, `ticket_number`, and ticket image URL.
  - `WeighbridgeSummary`, `PaymentSummary`, and `BookingResponse`: Comprehensive serializable contracts for payment and weighbridge data.
- **Booking Lifecycle Endpoints (`backend/app/api/bookings.py`):**
  - `POST /bookings`: Creates booking record, transitions state to `confirmed`, and locks estimated payout into simulated factory escrow (`Payment(status="held")`).
  - `GET /bookings/{id}`: Detailed query endpoint returning real-time status, escrow balances, and weighbridge certificate information.
  - `PATCH /bookings/{id}/status`: Transitions booking state to `picked_up` with timestamp recording, or `cancelled` with automatic escrow refund.
  - `POST /bookings/{id}/weighbridge`: Dharamkanta certified weighbridge entry endpoint. Enforces `gross_weight > tare_weight`, calculates exact net metric tonnes and kg, records ticket number and timestamp, recalculates final farmer payout based on verified net yield, and instantly releases escrow (`Payment(status="released")`) transitioning booking to `paid`.
- **Database Isolation & Model Robustness:**
  - Added non-geom table setups (`Booking`, `Offer`, `Payment`, `WeighbridgeRecord`) in `backend/tests/conftest.py`.
  - Implemented safe fallback buyer rate lookups in `submit_weighbridge_ticket` to maintain SQLite test compatibility alongside production PostgreSQL/PostGIS.
- **Lifecycle Integration Test Suite (`backend/tests/test_booking_lifecycle.py`):**
  - Validates full 4-step sequence: Booking Escrow Hold -> Pickup Transition -> Gross/Tare validation error -> Dharamkanta Ticket Net calculation & instant escrow payout release.
- **Mobile Frontend (`app/lib/screens/booking_detail_screen.dart` & `OptionsScreen`):**
  - Added `BookingResult`, `PaymentSummary`, and `WeighbridgeSummary` data models in `app/lib/models/booking_result.dart`.
  - Added repository methods (`createBooking`, `getBooking`, `submitWeighbridgeTicket`) with offline mock fallbacks and live API connectivity.
  - Built `BookingDetailScreen` featuring real-time 4-step progress stepper (Confirmed -> Picked Up -> Weighed -> Paid), escrow locked/released hero badge, trip logistics card, environmental impact pill, and on-device Dharamkanta slip simulator for instant live testing.
  - Linked `OptionsScreen` "Book This Pickup" button to initiate backend booking and transition directly to the live escrow screen.
  - Added trilingual localization keys in English, Hindi, and Punjabi.

### 2. Verification Metrics
- `pytest`: **25/25 tests passed** (100% green across backend unit and integration test suites).
- `flutter analyze`: **0 issues found** (clean lint).
- `flutter test`: **13/13 tests passed** (100% green across mobile unit and widget test suites).

---

## Entry 9: Sentinel-2 Satellite Burn Verification & No-Burn Green Certificate

- **Date:** 2026-10-09
- **Branch:** `feat/satellite-certificate`
- **Milestone:** Step 7 of Golden Path (Satellite Remote Sensing & Official Green Certification)
- **Status:** **BUILT & VERIFIED**

### 1. What Was Built
- **Sentinel-2 SWIR Spectral Verification Service (`backend/app/services/satellite.py`):**
  - Normalized Burn Ratio: $NBR = \frac{\text{Band 8 (NIR)} - \text{Band 12 (SWIR)}}{\text{Band 8 (NIR)} + \text{Band 12 (SWIR)}}$.
  - Burn Severity Index: $\Delta NBR = NBR_{\text{pre-harvest}} - NBR_{\text{post-harvest}}$.
  - Deterministic evaluation rule: $\Delta NBR < 0.10$ threshold confirms zero fire scar within the field polygon, moving status to `verified_no_burn`.
  - Cloud cover sanity check: Flags images with $> 30\%$ cloud cover as `unclear` instead of false positives.
  - Published CEEW/NEERI emission factor calculations:
    - Avoided $CO_2$: $1.5\text{ tonnes}$ ($1,500\text{ kg}$) per tonne stubble diverted.
    - Avoided $PM_{2.5}$ smoke: $18.0\text{ kg}$ per tonne stubble diverted.
    - Tree equivalency: $CO_{2\text{ avoided}} / 21.77\text{ kg/tree/year}$.
- **Certificate API Endpoint (`backend/app/api/bookings.py` & `schemas/certificate.py`):**
  - `GET /bookings/{id}/certificate`: Generates official verifiable No-Burn Green Certificate record (`CERT-PSETU-XXXXXX`), timestamps verification, and associates farmer village, district, straw tonnage, and spectral metrics.
- **Mobile Certificate UX (`app/lib/screens/certificate_screen.dart`):**
  - Diploma parchment layout featuring ornamental gold border and green seal emblem (`Icons.verified`).
  - Farmer identity: Name, Village, District, State, and verified residue tonnage.
  - Spectral badge: `✓ Sentinel-2 SWIR Verified (ΔNBR < 0.10)`.
  - 3-card environmental impact grid: Avoided $CO_2$, avoided $PM_{2.5}$ smoke, and equivalent trees planted.
  - Interactive "Share Certificate" action for easy transmission to KVK officers and village Panchayats.
  - Integrated direct launch button ("View No-Burn Certificate") from `BookingDetailScreen` once a booking reaches the `paid` state.
  - Trilingual localization in English, Hindi, and Punjabi.
- **Automated Test Coverage:**
  - `backend/tests/test_satellite_verification.py`: Validates NBR calculation, severity thresholds, environmental factors, and the certificate API.
  - `app/test/certificate_screen_test.dart`: Validates JSON parsing and UI rendering of the official certificate diploma and share flow.

### 2. Verification Metrics
- `pytest`: **29/29 tests passed** (100% green across all unit and integration test suites).
- `flutter analyze`: **0 issues found** (100% clean lint).
- `flutter test`: **15/15 tests passed** (100% green across all widget and unit test suites).

---

## Entry 10: Vernacular Voice Intake & AI Directive 1 Confirmation

- **Date:** 2026-10-09
- **Branch:** `feat/voice-intake`
- **Milestone:** Step 1 of Golden Path (Voice-First Vernacular Intake & Farmer Confirmation)
- **Status:** **BUILT & VERIFIED**

### 1. What Was Built
- **Vernacular Voice Parser Engine (`backend/app/services/voice_parser.py`):**
  - Land area normalization: Punjab/Haryana Killa ($1.0\text{ Acre}$), Punjab Bigha ($0.20\text{ Acre}$), and Hectares ($2.471\text{ Acres}$).
  - Multi-script numeral parsing: Supports words and digits across Devanagari (एक, दो, तीन, चार), Gurmukhi (ਇੱਕ, ਦੋ, ਤਿੰਨ, ਚਾਰ), Hinglish, and English.
  - Paddy variety matching: Standardizes mentions to `PR-126`, `Pusa-44`, `Basmati`, or `other`.
  - Date resolution: Handles relative terms (`aaj`, `kal`, `parso`, `tarso`) as well as explicit dates (`25 tareek`, `25 October`, `25 ਅਕਤੂਬਰ`).
  - Conversational verification prompt generator enforcing **AI Directive #1** (*"आपने बोला: 4 किल्ला PR-126, 25 अक्टूबर। सही है?"* / *"ਤੁਸੀਂ ਕਿਹਾ: 4 ਕਿੱਲਾ PR-126, 25 ਅਕਤੂਬਰ। ਕੀ ਇਹ ਸਹੀ ਹੈ?"*).
- **FastAPI Endpoint (`backend/app/api/voice.py` & `schemas/voice.py`):**
  - `POST /voice/parse`: Returns normalized `acres`, `variety`, `harvest_date`, `confidence`, and conversational `confirmation_prompt`.
  - Registered in `backend/app/main.py`.
- **Mobile Frontend UX (`app/lib/screens/field_details_screen.dart`):**
  - Active microphone CTA with animated ripple indicator.
  - Interactive bottom sheet with sound visualizer, direct transcript input, and 3 one-tap speech sample chips for seamless judge demonstration.
  - Mandatory AI Directive 1 Confirmation Card: Displays spoken text, 3-metric entity breakdown, and [Yes, Correct] vs [Speak Again] buttons.
  - One-tap pre-fill: Automatically sets acres stepper, variety choice chips, and harvest date calendar upon farmer confirmation, displaying the "Voice Auto-Filled" badge.
  - Retains 100% manual control over all inputs as fallback (AI Directive #3).
- **Client Architecture & Localization:**
  - Added `VoiceIntakeResult` data model in `app/lib/models/voice_intake_result.dart`.
  - Added `parseVoiceInput` method to `FarmerRepository`, `ApiFarmerRepository`, and `MockFarmerRepository`.
  - Added trilingual localization keys in English, Hindi, and Punjabi in `app/lib/l10n/app_strings.dart`.
- **Automated Test Coverage:**
  - `backend/tests/test_voice_parser.py`: 6 tests validating unit conversions (Killa, Bigha), varieties, relative dates, and the `/voice/parse` endpoint.
  - `app/test/voice_intake_test.dart`: 5 tests covering mock repository extraction and the complete Flutter widget flow (Mic Tap -> Sample Chip -> Confirmation Card -> Apply -> Auto-Fill).

### 2. Verification Metrics
- `pytest`: **35/35 tests passed** (100% green).
- `flutter analyze`: **0 issues found** (100% clean lint).
- `flutter test`: **20/20 tests passed** (100% green).

---

## Entry 11: Operations Web Portal (Biomass Buyer & Dharamkanta Weighbridge Terminal)

- **Date:** 2026-10-09
- **Branch:** `feat/web-portal`
- **Milestone:** Step 5 of Golden Path & Multi-Stakeholder Operations Portal
- **Status:** **BUILT & VERIFIED**

### 1. What Was Built
- **Unified Next.js 15 Web Portal (`web/portal`):**
  - Modern TypeScript + Tailwind CSS App Router architecture with glassmorphic cards and dark slate visual aesthetic.
  - Automated backend health checker communicating with FastAPI `/health`.
- **Dharamkanta Weighbridge Operator Terminal (Step 5 Golden Path Hero):**
  - Mobile-responsive digital slip entry form: Gross & Tare weight inputs with automated certified net tonnage calculation.
  - Anti-tamper sanity validation enforcing $|\text{Gross} - \text{Tare} - \text{Net}| \le 0.02\text{ t}$.
  - Printed Dharamkanta thermal receipt replica with barcode, truck number, and gross/tare metrics.
  - Direct 1-click **"Certify Weighbridge Ticket & Release Escrow"** action: Synchronizes with backend `/bookings/{id}/weighbridge` to update booking state to `paid` and release simulated farmer payout.
- **Biomass Buyer Command Center (Bio-CNG & Pellet Plants):**
  - Daily straw intake quota manager (50–500 tonnes/day) and purchase rate setter (₹/tonne).
  - Simulated escrow balance indicator (₹3,00,000) securing incoming farmer contracts.
  - Real-time incoming delivery tracker showing truck numbers, assigned transporters, and field tonnages.
- **KVK & District Agriculture Officer Compliance:**
  - District diversion metrics: 1,420 Tonnes diverted, 2,130 Tonnes CO₂ prevented, 25,560 kg PM₂.₅ smoke avoided, 97,841 trees saved.
  - Sentinel-2 SWIR NBR spectral verification monitor displaying clean fields ($\Delta NBR < 0.10$).
  - 1-click ₹1,000/Acre state ex-situ management subsidy approval queue.
- **Golden Path Live Bridge:**
  - Interactive end-to-end milestone tracker linking the Flutter farmer app with the Next.js operations portal.

### 2. Verification Metrics
- `npm run build` (Next.js): **100% clean build (Turbopack, TypeScript, Static Pages)**.
- `pytest`: **35/35 tests passed** (100% green).
- `flutter test`: **20/20 tests passed** (100% green).
- `flutter analyze`: **0 issues found** (clean lint).


