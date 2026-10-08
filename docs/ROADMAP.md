# ParaliSetu — Comprehensive Project Roadmap, Ground Truth & Anti-Hallucination Guide

**Document Status:** LIVING SOURCE OF TRUTH  
**Last Updated:** 8 October 2026 (Evening Hackathon Sync)  
**Authors:** DeepMind Antigravity + Claude System Analysis + Core Team  
**Purpose:** Eliminate AI agent hallucinations, preserve architectural decisions, provide agronomic ground truth, and define the exact Golden Path for the hackathon prototype.

---

## 1. Executive Status & Ground Truth (What is BUILT vs PLANNED)

| Component | Status | Details & Current Location |
| :--- | :--- | :--- |
| **Database & Schema** | **BUILT** | Supabase PostgreSQL + PostGIS (12 core tables). RLS enabled on all 12 tables. Schema in `backend/alembic/versions/0001_initial_schema.py`. |
| **Authentication & Guard** | **BUILT** | FastAPI phone OTP (`/auth/otp/send`, `/auth/otp/verify`). Demo phone allow-list. Hard production JWT secret guard rejecting placeholders and keys < 32 chars in `backend/app/core/config.py`. |
| **Profile API** | **BUILT** | `GET /auth/me` and owner-only `PATCH /auth/me` with input length and language validation (`en`, `hi`, `pa`) in `backend/app/api/auth.py`. 60-min access token, 30-day refresh token. |
| **Farmer Mobile App** | **BUILT** | Trilingual Flutter App (English default, Hindi, Punjabi with `/* NEEDS NATIVE REVIEW */`). 3-slide onboarding, session auto-restore, 6-box OTP, Home greeting, Profile editor, Stubble Estimate screen. Release split APK arm64 is **17.03 MB** (budget < 25 MB). Physical device verified (`docs/screenshots/`). |
| **Offline & Mock Support**| **BUILT** | In-memory `MockFarmerRepository` in `app/lib/repositories/farmer_repository.dart` mirrors all endpoints. 100% functional without live backend. |
| **Matching Engine** | **PLANNED** | OR-Tools CP-SAT multi-point constraint optimization (`backend/app/services/matching.py`). Not implemented yet. |
| **Options / Bundle Screen** | **PLANNED** | Farmer UI displaying 2–3 ranked bundles (Baler + Truck + Buyer). Not implemented yet. |
| **1-Tap Booking & Escrow** | **PLANNED** | State machine transition `requested` → `confirmed` with simulated escrow hold. Not implemented yet. |
| **Weighbridge & Payout** | **PLANNED** | Dharamkanta gross/tare entry and actual-weight payment calculation. Not implemented yet. |
| **Voice Intake (AI/ML)** | **PLANNED** | Whisper / Bhashini ASR + Gemini 1.5 Flash entity extractor. UI mic placeholder exists; backend integration pending. |
| **Web Portal (Next.js)** | **PLANNED** | Single responsive web interface for Buyers, Baler Owners, and KVK officers. Pending. |
| **Satellite Verification** | **PLANNED** | Sentinel-2 SWIR NBR post-harvest check for No-Burn Certificate. Pending. |

---

## 2. Agronomic Ground Truth: How Parali Weight is Calculated

### The Discrepancy Explained (Total Biomass vs. Baler Recovery)
* **Biological Biomass Generated (PAU / ICAR Research):**
  Field trials by Punjab Agricultural University (PAU Ludhiana) show that Punjab paddy produces **8.5 to 9.5 tonnes of total residue per hectare**, which equals **~3.4 to 3.8 tonnes per acre**.
* **Baler Recoverable Residue (Real Farm Practice):**
  A mechanical baler **does NOT collect 100% of the straw**. 
  - Combine harvesters cut at 25–40 cm height, leaving heavy rooted stubble in the soil.
  - Harvester straw walkers shred finer leaves and chaff that settle into the dirt.
  - **Actual recovery efficiency of balers is 55% to 60%.**
  - Therefore, the collected and tradable stubble is:
    $$\text{Tradable Stubble} \approx 3.6 \text{ t/acre} \times 0.58 \approx 2.0 \text{ to } 2.2 \text{ tonnes/acre}$$

### Official Yield Factors (Configured in `backend/app/core/stubble_config.py`)
```python
YIELD_FACTOR = {
    # Recoverable dry baled stubble tonnes per acre
    "PR-126":  {"combine": 2.0, "manual": 1.2},   # Short duration (123 days)
    "Pusa-44": {"combine": 2.5, "manual": 1.5},   # Long duration (160 days), thicker biomass
    "Basmati": {"combine": 1.5, "manual": 0.9},   # Softer straw, partly retained for animal fodder
    "other":   {"combine": 2.0, "manual": 1.2},
}

YIELD_RANGE_FACTOR_LOW  = 0.80   # -20% lower boundary (dry soil / low density)
YIELD_RANGE_FACTOR_HIGH = 1.20   # +20% upper boundary (heavy crop / high moisture)
```

### Presentation & Farmer Trust Rule:
1. **Never hide the distinction:** Show both on the app:
   - *Estimated Field Residue:* ~3.6 Tonnes/acre
   - *Recoverable Baled Stubble:* 2.0 Tonnes/acre (What the factory buys)
2. **Ironclad Payment Safeguard:**
   - The app estimate is solely for **logistics sizing** (how many trucks/balers to assign).
   - **Final payment is NEVER released on the formula.** It is released exclusively on the **actual certified weighbridge (Dharamkanta) net weight ticket**.

---

## 3. Pragmatic AI & ML Strategy (Useful, Not Just Buzzwords)

### Current Reality Check:
* **There is currently ZERO Machine Learning in the repository.**
* Stubble calculation is a deterministic agronomic formula.
* Matching is Operations Research (Google OR-Tools CP-SAT mathematical optimization). Do not call pure optimization "Deep Learning" in front of technical judges; pitch it as **"AI-driven Constraint Optimization"**.

### The 3 High-Impact AI/ML Features to Add:

#### P0. Vernacular Voice Intake (Speech-to-Text + Small LLM / Gemini Flash)
* **Problem Solved:** Non-tech farmers struggle with text fields, date pickers, and sliders.
* **Architecture:**
  1. Farmer taps mic and speaks in Punjabi or Hindi: *"ਮੇਰੇ ਕੋਲ 4 ਕਿੱਲੇ PR-126 ਹੈ, 25 ਤਰੀਕ ਨੂੰ ਵੱਢਣਾ ਹੈ"* (I have 4 killa PR-126, harvesting on 25th).
  2. ASR (Android SpeechRecognizer / Bhashini / Whisper) transcribes audio.
  3. LLM extracts JSON: `{"acres": 4.0, "variety": "PR-126", "harvest_date": "2026-10-25"}`. (Crucial: Model understands 1 Killa = 1.0 Acre in Punjab/Haryana).
  4. **Strict Confirmation Screen:** The UI speaks back: *"4 Killa PR-126, 25 October. Sahi hai?"* Farmer taps a large green button to confirm.
  5. **Fallback:** If voice fails, manual stepper and date picker remain immediately accessible.

#### P1. Post-Weighbridge Dynamic ML Calibration
* **Problem Solved:** Land soil fertility and moisture vary by district (e.g. Sangrur vs Bathinda).
* **Architecture:** Every time a completed Dharamkanta ticket is confirmed, a simple regression model compares `estimated_weight` vs `actual_weighbridge_weight` and calibrates district-level `YIELD_FACTOR` coefficients over time.

#### P2. Satellite Post-Harvest Verification (Sentinel-2 SWIR + Classifier)
* **Problem Solved:** Proof of no-burning for KVK subsidies and CAQM fine waivers.
* **Architecture:** 7–10 days post-harvest, query Sentinel-2 B12 (SWIR) and B8 (NIR) bands for the farm boundary. Compute Normalized Burn Ratio ($\Delta NBR$). If clean, generate a verifiable **"No-Burn Green Certificate"** with thumbnail.

---

## 4. Product & System Architecture (Why 1 App + 1 Web Portal)

**Do NOT build 3 separate mobile apps.** That is a common hackathon trap that dilutes quality.

1. **Farmer Mobile App (Flutter — Built & Hero of the Project):**
   - High accessibility, vernacular (EN/HI/PA), offline capable, big touch targets (56dp+).
   - Contains a role toggle for **Kisan Mitra** (community village agents helping elderly farmers book on their behalf).
2. **Operations & Buyer Web Portal (Next.js / Responsive Web — To Be Built):**
   - Accessible on desktop and mobile browsers.
   - Used by **Biomass Buyers / Factories** to set demand and price per tonne.
   - Used by **Weighbridge Operators / Drivers** to input gross/tare weight and upload Dharamkanta ticket photos.
   - Used by **KVK / Agriculture Officers** to monitor district stubble collection.

---

## 5. The "Golden Path" (End-to-End Demo Workflow)

For the final hackathon presentation, this single unbroken sequence MUST execute smoothly:

```
[1. Voice Intake] 
   └── Farmer taps mic → "4 killa PR-126, 25 Oct" → Confirm screen
[2. Instant Value] 
   └── Shows 8.0 Tonnes (~₹9,600 assumed payout)
[3. Matched Bundles] 
   └── OR-Tools matching returns 2-3 bundles (Baler + Truck + Bio-CNG plant)
[4. 1-Tap Booking] 
   └── Farmer books → Factory escrow hold displayed (Simulated)
[5. Pickup & Weighbridge] 
   └── Truck delivers → Dharamkanta slip: Gross 14.2t, Tare 6.2t = 8.0t Net
[6. Real Payout] 
   └── Escrow releases ₹9,600 to farmer bank account
[7. Green Impact] 
   └── Satellite verified no-burn certificate + Avoided CO2/PM2.5 badge
```

---

## 6. Implementation Priorities & Schedule

### Phase 1: Merges & Live Deployment (Immediate)
- [x] Part 1: JWT Startup Guard and merge `chore/deploy` & `feat/app-v1` into `main`.
- [x] Part 2: Profile API on `feat/profile-api` (pushed).
- [x] Part 3: Farmer UX on `feat/app-ux` with offline fonts, vector art, split APKs, physical screenshots (pushed).
- [ ] Merge `feat/profile-api` into `main`.
- [ ] Merge `feat/app-ux` into `main`.
- [ ] Deploy backend to public HTTPS host (Render) and configure `--dart-define=API_BASE_URL`.

### Phase 2: Core Matching Engine & Booking Lifecycle (Next)
- [ ] `backend/app/services/matching.py`: Implement OR-Tools CP-SAT solver matching Farmer harvest window to Balers, Trucks, and Buyers within operating radius.
- [ ] Flutter `OptionsScreen`: Render 2–3 matched bundle cards with net earnings and pickup dates.
- [ ] `POST /bookings`: Booking creation with simulated escrow hold screen.
- [ ] Weighbridge flow: `POST /bookings/{id}/weighbridge` + weight release calculation.

### Phase 3: AI Voice & Web Operations Portal
- [ ] Vernacular Voice Intake endpoint and Flutter confirmation dialog.
- [ ] Next.js responsive web portal for Buyers and Dharamkanta slip entry.

### Phase 4: Polish, Video & Pitch (Final Day)
- [ ] Record 2-minute live demo video showing Phone App + Web Portal live sync.
- [ ] Prepare Judge Q&A cheat-sheet addressing agronomic citations and OR-Tools optimization.

---

## 7. Anti-Hallucination Ground Rules for AI Agents

Every agent working on this codebase MUST follow these instructions:
1. **Never invent database columns:** Always inspect `backend/alembic/versions/` and the live SQLAlchemy models in `backend/app/models/` before writing backend endpoints.
2. **Never commit secrets:** Never write or print `.env`, JWT secrets, or Supabase connection strings.
3. **Always separate BUILT vs PLANNED:** Never tell the user or write documentation claiming a mock or stub is production-ready.
4. **Preserve existing files and tests:** Run `pytest` in `backend/` and `flutter test` in `app/` before creating a PR or asking for merges.
5. **Read this file (`docs/ROADMAP.md`) first** before executing any prompt.
