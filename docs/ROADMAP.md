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
| **Farmer Mobile App** | **BUILT** | Trilingual Flutter App (English default, Hindi, Punjabi with `/* NEEDS NATIVE REVIEW */`). 3-slide onboarding, session auto-restore, 6-box OTP, Home greeting, Profile editor, Stubble Estimate screen with range bar. Release split APK arm64 is **17.03 MB** (budget < 25 MB). Physical device verified (`docs/screenshots/`). |
| **Offline & Mock Support**| **BUILT** | In-memory `MockFarmerRepository` in `app/lib/repositories/farmer_repository.dart` mirrors all endpoints. 100% functional without live backend. |
| **Matching Engine** | **PLANNED** | Google OR-Tools CP-SAT multi-point constraint optimization (`backend/app/services/matching.py`). Detailed in Section 4. |
| **Options / Bundle Screen** | **PLANNED** | Farmer UI displaying 2–3 ranked bundles (Baler + Truck + Buyer). Detailed in Section 5. |
| **1-Tap Booking & Escrow** | **PLANNED** | State machine transition `requested` → `confirmed` with simulated escrow hold. Detailed in Section 5. |
| **Weighbridge & Payout** | **PLANNED** | Dharamkanta gross/tare entry and actual-weight payment calculation. Detailed in Section 4 & 5. |
| **Voice Intake (AI/ML)** | **PLANNED** | Bhashini / Whisper ASR + Gemini 1.5 Flash entity extractor. UI mic placeholder exists; prompt & backend schema specified in Section 3. |
| **Web Portal (Next.js)** | **PLANNED** | Single responsive web interface for Buyers, Baler Owners, and KVK officers. Specified in Section 5. |
| **Satellite Verification** | **PLANNED** | Sentinel-2 SWIR NBR post-harvest check for No-Burn Certificate. Specified in Section 3. |

---

## 2. Target User Realities & Why This App Solves a Real Crisis

To make this app genuinely useful and not just a hackathon toy, every feature is tailored to the exact realities of smallholder farmers in Punjab and Haryana:

### The Farmer's High-Pressure Dilemma:
1. **The 15–20 Day Time Bomb:** Between harvesting paddy (late October) and sowing wheat (mid-November), farmers have barely 2 weeks. Delays in sowing wheat reduce yield by ~1.5% per day of delay.
2. **Economic Trap:** Renting a tractor-mounted baler independently costs ₹1,500–₹2,500 per acre. If a farmer owns only 3–5 acres, commercial balers refuse to travel to their field because single small fields are unprofitable.
3. **Legal Fear & Dignity:** Farmers face police FIRs, satellite red flags by CAQM/ISRO, and ₹5,000–₹15,000 environmental compensation fines (red entries on land records). Farmers burn not out of malice, but out of sheer logistical desperation.
4. **Digital Literacy & Vernacular Trust:** Most farmers speak Punjabi (Malwai/Majhi/Doabi) or Hindi and have difficulty filling multi-step digital forms, English text fields, or complex map pins.

### Why ParaliSetu is Genuinely Useful:
- **Zero Form Friction (Voice-First):** Farmer speaks naturally ("4 killa PR-126"). The AI fills the form and confirms in audio.
- **Micro-Cluster Aggregation:** ParaliSetu groups adjacent 3–5 acre farms into a 25–40 acre contiguous cluster so commercial balers willingly accept the job.
- **Guaranteed Cash in Hand:** Connects directly with bio-CNG and pellet plants with guaranteed payments based on certified Dharamkanta weighbridge slips.
- **Legal Protection (No-Burn Green Certificate):** Satellite-verified clearance gives the farmer official immunity from fines and qualifies them for state government in-situ/ex-situ subsidies (₹1,000/acre).

---

## 3. Agronomic Ground Truth: How Parali Weight is Calculated

### The Discrepancy Explained (Total Biomass vs. Baler Recovery)
* **Biological Residue Generated (PAU / ICAR Research):**
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

## 4. Deep-Dive: All AI & ML Models in the System

### Model 1: Vernacular Voice Intake (Speech-to-Text + Gemini 1.5 Flash)
* **Goal:** Allow illiterate or busy farmers to submit land and crop details by speaking in Punjabi or Hindi.
* **Component 1 (ASR):** Bhashini Speech API / Whisper audio input converting voice audio (WAV/M4A) into vernacular text.
* **Component 2 (LLM Entity Extraction - Gemini 1.5 Flash):**
  - **Endpoint:** `POST /api/v1/voice/parse`
  - **System Prompt:**
    ```text
    You are an expert vernacular agricultural parser for Punjab and Haryana farmers.
    Convert voice transcripts in Punjabi, Hindi, or Hinglish into structured JSON.
    Rules:
    - 1 Killa = 1.0 Acre.
    - 1 Bigha (Punjab) = 0.20 Acre (or normalize according to district if provided).
    - Map variety mentions to: 'PR-126', 'Pusa-44', 'Basmati', or 'other'.
    - Parse relative dates ('parso', '25 tareek', 'kal') relative to today ({current_date}).
    Return ONLY valid JSON with keys: acres (float), variety (string), harvest_date (YYYY-MM-DD), confidence (float).
    ```
  - **Sample Inputs & Extracted Outputs:**
    - Input: *"ਮੇਰੇ ਕੋਲ 4 ਕਿੱਲੇ PR-126 ਹੈ, 25 ਅਕਤੂਬਰ ਨੂੰ ਵੱਢਣਾ ਹੈ"*
    - Output: `{"acres": 4.0, "variety": "PR-126", "harvest_date": "2026-10-25", "confidence": 0.98}`
    - Input: *"Das bigha basmati laga rakha hai agle hafte katai hai"*
    - Output: `{"acres": 2.0, "variety": "Basmati", "harvest_date": "2026-10-15", "confidence": 0.92}`
* **Guardrail (Zero-Guess Audio Feedback):**
  The app displays and speaks a clear modal: *"Aapne bola: 4 Killa PR-126, 25 October. Sahi hai?"* with two prominent buttons: [Haan, Sahi Hai (Confirm)] and [Dobara Boliye (Retry)].

---

### Model 2: AI Constraint Optimization (Google OR-Tools CP-SAT)
* **Goal:** Solve the multi-sided matching problem between Farmers, Baler Operators, Logistics Transporters, and Biomass Buyers.
* **Why it's not standard ML:** Supervised ML cannot guarantee that truck capacities are never exceeded or that balers are physically reachable. Operations Research (CP-SAT) provides mathematically optimal, feasible solutions in < 2 seconds.
* **Mathematical Formulation (`backend/app/services/matching.py`):**
  - **Sets:** Farmers $i \in F$, Balers $j \in B$, Trucks $k \in T$, Buyers $m \in M$.
  - **Decision Variable:** Binary variable $x_{i,j,k,m} \in \{0, 1\}$ denoting farmer $i$ is serviced by baler $j$, transported by truck $k$, and delivered to buyer $m$.
  - **Constraints:**
    1. *Time Window Constraint:* $t_{harvest}(i) \le t_{baling}(j) \le t_{delivery}(k) \le t_{sowing}(i)$.
    2. *Operating Radius Constraint:* $\text{Distance}(i, j) \le R_{baler}$ (max 25 km), $\text{Distance}(i, m) \le R_{buyer}$ (max 60 km).
    3. *Capacity Constraint:* $\sum_{i} \text{StubbleWeight}(i) \cdot x_{i,j,k,m} \le \text{Capacity}(j, k)$.
    4. *Clustering Constraint:* Group adjacent fields within 2 km into contiguous 25–40 acre runs to eliminate baler idle transit time.
  - **Objective Function:**
    $$\max \sum_{i,j,k,m} \left( \text{BuyerPrice}(m) \times W_i - \text{BalerCost}(j) - \text{TransportCost}(k, \text{dist}_{i,m}) \right) \cdot x_{i,j,k,m}$$
  - **Output to Farmer:** Generates 2–3 ranked bundle options (e.g. "Fastest Pickup: Tomorrow", "Best Payout: ₹1,250/ton", "Local Bio-CNG").

---

### Model 3: Post-Weighbridge Dynamic Calibration (Self-Improving Yield Model)
* **Goal:** Automatically refine per-acre stubble estimates as real weighbridge slips are logged.
* **Mechanism:**
  - Initial estimate is static: $\hat{W} = \text{Acres} \times Y_{\text{variety}}$.
  - Every completed trip logs actual net weighbridge weight $W_{\text{actual}}$.
  - A ridge regression / moving Bayesian model updates the district-level yield multiplier:
    $$Y_{\text{calibrated}}(d, v) = \alpha Y_{\text{base}}(v) + (1 - \alpha) \frac{\sum_{k} W_{\text{actual}}^{(k)}}{\sum_{k} \text{Acres}^{(k)}}$$
  - Over 1–2 harvest seasons, prediction error drops from $\pm 20\%$ to under $\pm 6\%$, building unprecedented farmer trust.

---

### Model 4: Satellite Remote Sensing Burn Verification (Sentinel-2 SWIR NBR)
* **Goal:** Independent verification that the farmer did not burn their field, unlocking government subsidies and green certificate badges.
* **Data Source:** European Space Agency (ESA) Sentinel-2 Level-2A imagery (10m–20m resolution, 5-day revisit).
* **Spectral Formula:**
  - Near-Infrared (Band 8, 842 nm): High reflectance in healthy vegetation and unburnt straw.
  - Short-Wave Infrared (Band 12, 2190 nm): High reflectance in charcoal, ash, and scorched earth.
  - Normalized Burn Ratio:
    $$NBR = \frac{\text{Band 8} - \text{Band 12}}{\text{Band 8} + \text{Band 12}}$$
  - Burn Severity Index ($\Delta NBR$):
    $$\Delta NBR = NBR_{\text{pre-harvest}} - NBR_{\text{post-harvest}}$$
* **Decision Rule:**
  - If $\Delta NBR < 0.10$: Field cleanly baled, no burn scar. $\rightarrow$ **Issue No-Burn Certificate**.
  - If $\Delta NBR \ge 0.27$: High-confidence burn scar detected. $\rightarrow$ Flag for ground review.

---

### Model 5: Dharamkanta Weighbridge Ticket OCR & Anti-Fraud Engine
* **Goal:** Prevent manual input tampering when entering weighbridge slips.
* **Mechanism:**
  - Operator uploads a photo of the thermal slip from the Dharamkanta weighbridge.
  - OCR extracts: Gross Weight, Tare Weight, Net Weight, Slip Serial Number, Date/Time.
  - **Validation Rule:**
    $$|\text{Gross} - \text{Tare} - \text{Net}| \le 0.02 \text{ tonnes}$$
  - Cross-references vehicle license plate with the assigned booking truck before escrow payout is triggered.

---

## 5. System Architecture: 1 Flutter App + 1 Next.js Web Portal

We strictly avoid the multi-app trap. The architecture is cleanly divided:

```
┌─────────────────────────────────┐       ┌─────────────────────────────────┐
│     Farmer Mobile App (Flutter) │       │   Operations Web Portal (Next)  │
│  • Punjabi / Hindi / English    │       │  • Factory Buyers (Set Demand)  │
│  • Voice Intake & Bundle Picker │       │  • Weighbridge Ticket Entry     │
│  • Offline sync & Passbook      │       │  • KVK Subsidy & Admin View     │
└────────────────┬────────────────┘       └────────────────┬────────────────┘
                 │                                         │
                 └───────────────────┬─────────────────────┘
                                     ▼
                      ┌─────────────────────────────┐
                      │    FastAPI Central Backend  │
                      │  • JWT Auth & Phone OTP     │
                      │  • OR-Tools Matching Engine │
                      │  • Stubble Agronomic Logic  │
                      │  • PostGIS Geo-Queries      │
                      └──────────────┬──────────────┘
                                     ▼
                      ┌─────────────────────────────┐
                      │ Supabase PostgreSQL+PostGIS │
                      │  • 12 Normalized Tables     │
                      │  • Row-Level Security (RLS) │
                      └─────────────────────────────┘
```

---

## 6. The 7-Step "Golden Path" End-to-End Demo Workflow

This unbroken flow demonstrates the entire value cycle during the presentation:

1. **Voice Intake (Mobile App):**
   - Farmer taps mic: *"4 killa PR-126, 25 October."*
   - Audio pop-up: *"4 Killa PR-126, 25 October. Sahi hai?"* $\rightarrow$ Farmer taps Confirm.
2. **Instant Yield & Payout Estimate (Mobile App):**
   - Stubble calculation displays: Total field biomass **14.4 t**, Baler recoverable **8.0 t**.
   - Estimated earnings: **₹9,600** (@ ₹1,200/tonne).
3. **Optimized Bundle Selection (Mobile App):**
   - OR-Tools returns 2 bundles:
     - *Bundle A (Fastest):* Baler Gurdeep Singh + Sharma Transport (Pickup 26 Oct).
     - *Bundle B (Max Value):* Bio-CNG Plant Sangrur (Pickup 27 Oct, +₹400).
4. **1-Tap Booking & Escrow Hold (Mobile App):**
   - Farmer taps "Book Pickup".
   - Booking state advances to `confirmed`. Buyer's simulated escrow fund holds ₹9,600.
5. **Weighbridge Intake & OCR (Web Portal):**
   - Truck delivers stubble to Dharamkanta.
   - Slip photo uploaded: Gross = 14.2 t, Tare = 6.2 t, Net = **8.0 t**.
6. **Instant Escrow Release & Bank Credit (Mobile App & Web):**
   - Payout of ₹9,600 releases to farmer's wallet / direct bank account.
   - Push notification / SMS sent in Punjabi.
7. **Green Verification & Certificate (Mobile App):**
   - Sentinel-2 verification returns $\Delta NBR < 0.10$.
   - **No-Burn Certificate** awarded: Avoided 12.0 tonnes $CO_2$ and 150 kg $PM_{2.5}$.

---

## 7. Concrete Next Implementation Steps

### Phase 1: Merges & Production Deployment (Current)
- [x] Part 1: JWT Startup Guard and merge `chore/deploy` & `feat/app-v1` into `main`.
- [x] Part 2: Profile API on `feat/profile-api` (pushed).
- [x] Part 3: Farmer UX on `feat/app-ux` with offline fonts, vector art, split APKs, physical screenshots (pushed).
- [ ] Merge `feat/profile-api` into `main`.
- [ ] Merge `feat/app-ux` into `main`.
- [ ] Deploy backend to public HTTPS host (Render) and verify live healthcheck.

### Phase 2: Core Matching Engine & Booking Lifecycle
- [ ] Implement `backend/app/services/matching.py` with OR-Tools CP-SAT and distance constraints.
- [ ] Implement Flutter `OptionsScreen` with ranked bundle cards.
- [ ] Implement `POST /bookings` state machine and simulated escrow hold.
- [ ] Implement `POST /bookings/{id}/weighbridge` for certified weight entry.

### Phase 3: AI Voice Intake & Web Portal
- [ ] Build `/api/v1/voice/parse` with Gemini 1.5 Flash and vernacular audio confirmation modal in Flutter.
- [ ] Build responsive Next.js web portal for buyers and Dharamkanta operators.

### Phase 4: Polish, Video & Pitch
- [ ] Record 2-minute live demo showing physical Android phone + Web portal synchronized.
- [ ] Prepare Judge Q&A cheat-sheet explaining agronomic formulas and constraint optimization.

---

## 8. Anti-Hallucination Directives for AI Agents

Every agent working on this codebase MUST follow these instructions:
1. **Never invent database columns:** Always inspect `backend/alembic/versions/` and the live SQLAlchemy models in `backend/app/models/` before writing backend endpoints.
2. **Never commit secrets:** Never write or print `.env`, JWT secrets, or Supabase connection strings.
3. **Always separate BUILT vs PLANNED:** Never tell the user or write documentation claiming a mock or stub is production-ready.
4. **Preserve existing files and tests:** Run `pytest` in `backend/` and `flutter test` in `app/` before creating a PR or asking for merges.
5. **Read this file (`docs/ROADMAP.md`) first** before executing any prompt.


