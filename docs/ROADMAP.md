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

---

## 2. Multi-Stakeholder Matrix: Tailored Differently for Every Target User

We do NOT treat all users the same. Parali management involves 6 distinct stakeholders with radically different needs, devices, and literacy levels:

| Stakeholder | Primary Interface | Core Pain Point | Tailored Solution in ParaliSetu |
| :--- | :--- | :--- | :--- |
| **1. Marginal Farmer (Kisaan)** | **Flutter Mobile App (The Hero)** | 15-day deadline before wheat sowing; low digital literacy; ₹5,000–₹15,000 fine fear; commercial balers refuse small 2–4 acre fields. | **Voice-first intake** in Punjabi/Hindi; automatic clustering with neighboring farms; guaranteed cash via Dharamkanta weighbridge slip; No-Burn certificate. |
| **2. Kisan Mitra (Village Agent)** | **Role Mode in Flutter App** | Elderly or illiterate farmers in the village cannot use smartphones alone. | In-app toggle (`role: kisan_mitra`) allowing youth/agents to register and manage bookings for multiple farmers in their village. |
| **3. Biomass Buyer (Bio-CNG / Pellet Plants)** | **Next.js Web Portal (Desktop & Mobile)** | Unpredictable daily straw supply; boilers shutdown if moisture or deliveries stop; dealing with hundreds of individual farmers is chaotic. | Web dashboard to set daily demand (e.g. 200 tonnes/day) and purchase price (₹/tonne); simulated escrow deposit guarantees supply. |
| **4. Baler & Truck Owners (Aggregators)** | **Next.js Web Portal + SMS/WhatsApp** | Cannot afford deadhead travel for small 2-acre fields; need high equipment utilization during the 20-day peak. | OR-Tools groups neighboring small farms into **25–40 acre contiguous clusters**, giving operators maximum throughput per fuel litre. |
| **5. Dharamkanta (Weighbridge Operator)** | **Next.js Web Portal (Mobile Browser)** | Long truck queues; manual paper receipts prone to fraud and disputes between farmer and factory. | Fast mobile browser form: enter Gross & Tare weight, snap slip photo with automatic OCR sanity validation. |
| **6. KVK / Agriculture Officer / SDM** | **Next.js Web Portal (Admin View)** | Need proof of compliance for CAQM guidelines; manual field inspections are physically impossible across thousands of villages. | District-level dashboard tracking total diverted biomass; Sentinel-2 satellite burn verification; 1-click ₹1,000/acre subsidy approval. |

---

## 3. Claude's Core AI Directives & What to Build vs. What to SKIP

To ensure AI provides real value and is not just a hackathon gimmick, we adhere to 3 non-negotiable rules:

### The 3 Golden Rules of AI in ParaliSetu:
1. **Always Require Farmer Confirmation:** The voice model NEVER automatically finalizes a booking. After speech processing, the UI always shows and speaks back: *"Aapne bola: 4 Killa PR-126, 25 October. Sahi hai?"* If the speech model misheard, the farmer catches it before any financial commitment.
2. **LLM Never Invents Numbers:** The LLM NEVER generates stubble weights or prices. Numbers are calculated 100% deterministically by the backend agronomic formula and OR-Tools optimization. The LLM only translates numbers into simple, conversational vernacular explanations (*"Ye daam kyun mila: 15 km doori aur PR-126 variety ki wajah se"*).
3. **Fallback is Always Active:** If voice transcription fails, network drops, or the dialect is unrecognized, the manual form with steppers and dropdowns remains instantly accessible.

### Pragmatic Feature Prioritization (What to Build vs. What to SKIP):
* **Photo-based Moisture Estimation:** **SKIP.** (Phone cameras cannot measure internal bale moisture accurately; lack of verified training data; high risk of disputes).
* **NDVI Satellite Harvest Prediction:** **DEFER TO LATER.** (Farmers already know their exact harvest date; satellite time-series adds high complexity without immediate farmer utility).
* **3 Separate Mobile Apps:** **REJECTED.** (Building 3 native apps dilutes quality. 1 high-polish Flutter app for farmers + 1 responsive Next.js web portal for buyers/operators is the industry-standard architecture).


---

## 4. Agronomic Ground Truth: How Parali Weight is Calculated

### The Discrepancy Explained (Total Biomass vs. Baler Recovery)
* **Biological Residue Generated (PAU / ICAR Research):**
  Field trials by Punjab Agricultural University (PAU Ludhiana) show that Punjab paddy produces **8.5 to 9.5 tonnes of total residue per hectare**, which equals **~3.4 to 3.8 tonnes per acre**.
* **Baler Recoverable Residue (Real Farm Practice):**
  A mechanical baler **does NOT collect 100% of the straw**. 
  - Combine harvesters cut at 25–40 cm height, leaving heavy rooted stubble in the soil.
  - Harvester straw walkers shred finer leaves and chaff that settle into the dirt.
  - **Actual recovery efficiency of balers is 55% to 60%.**
  - Therefore, the collected and tradable stubble is:
    $$\text{Tradable Stubble} = \text{Total Generated} \times \text{Recovery Efficiency} \approx 3.6 \text{ t/acre} \times 0.58 \approx 2.0 \text{ to } 2.2 \text{ tonnes/acre}$$

### Two Ways for the Farmer to Estimate:
1. **Method A (Default - Land & Variety Based):**
   $$\text{Tradable Stubble} = \text{Acres} \times \text{YIELD\_FACTOR}[\text{variety}][\text{harvest\_method}]$$
2. **Method B (Secondary High-Confidence Check - Grain Yield Based):**
   Punjab farmers always know their exact harvest output: *"Pichhli baar kitne quintal dhaan nikla?"*
   - Agricultural Harvest Index ($HI$) for dwarf rice varieties is $\approx 0.45 - 0.50$.
   - **Grain-to-Straw Ratio:** $1\text{ Quintal Grain} \approx 1.15 - 1.25\text{ Quintals Straw}$.
   - If a farmer harvested 30 quintals/acre of paddy $\rightarrow$ generates $\approx 36\text{ quintals} = 3.6\text{ t/acre}$ total residue $\rightarrow \approx 2.1\text{ t/acre}$ baled recoverable residue.
   - Adding this optional prompt creates instant field credibility with judges and farmers.

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
1. **Show Both Numbers Transparently:**
   - *Estimated Field Residue (Total biomass):* ~3.6 Tonnes/acre
   - *Recoverable Baled Stubble (Tradable biomass):* 2.0 Tonnes/acre (What the factory buys)
2. **Ironclad Payment Safeguard:**
   - The app estimate is solely for **logistics sizing** (how many trucks/balers to assign).
   - **Final payment is NEVER released on the formula.** It is released exclusively on the **actual certified weighbridge (Dharamkanta) net weight ticket**.

---

## 5. Deep-Dive: All AI & ML Models in the System

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
* **Guardrail (Zero-Guess Audio Feedback):**
  The app displays and speaks a clear modal: *"Aapne bola: 4 Killa PR-126, 25 October. Sahi hai?"* with two prominent buttons: [Haan, Sahi Hai (Confirm)] and [Dobara Boliye (Retry)].

### Model 2: AI Constraint Optimization (Google OR-Tools CP-SAT)
* **Goal:** Solve the multi-sided matching problem between Farmers, Baler Operators, Logistics Transporters, and Biomass Buyers.
* **Why it's not standard ML:** Supervised ML cannot guarantee that truck capacities are never exceeded or that balers are physically reachable. Operations Research (CP-SAT) provides mathematically optimal, feasible solutions in < 2 seconds.
* **Mathematical Formulation (`backend/app/services/matching.py`):**
  - **Decision Variable:** $x_{i,j,k,m} \in \{0, 1\}$ denoting farmer $i$ is serviced by baler $j$, transported by truck $k$, and delivered to buyer $m$.
  - **Key Constraints:**
    1. *Time Window:* $t_{harvest}(i) \le t_{baling}(j) \le t_{delivery}(k) \le t_{sowing}(i)$.
    2. *Operating Radius:* $\text{Distance}(i, j) \le 25\text{ km}$, $\text{Distance}(i, m) \le 60\text{ km}$.
    3. *Capacity & Contiguity:* Group adjacent fields into 25–40 acre runs to maximize baler throughput.
  - **Objective:** Maximize farmer net earnings while minimizing logistics deadhead distance.

### Model 3: Post-Weighbridge Dynamic Calibration (Self-Improving Yield Model)
* **Goal:** Automatically refine per-acre stubble estimates as real weighbridge slips are logged.
* **Mechanism:**
  - Initial estimate is static: $\hat{W} = \text{Acres} \times Y_{\text{variety}}$.
  - Every completed trip logs actual net weighbridge weight $W_{\text{actual}}$.
  - A ridge regression / moving Bayesian model updates the district-level yield multiplier:
    $$Y_{\text{calibrated}}(d, v) = \alpha Y_{\text{base}}(v) + (1 - \alpha) \frac{\sum_{k} W_{\text{actual}}^{(k)}}{\sum_{k} \text{Acres}^{(k)}}$$
  - *Honest Demo Boundary:* For the hackathon presentation, we show this dynamic mechanism using simulated historical Dharamkanta tickets to demonstrate self-improving predictions.

### Model 4: Satellite Remote Sensing Burn Verification (Sentinel-2 SWIR NBR)
* **Goal:** Independent verification that the farmer did not burn their field, unlocking government subsidies and green certificate badges.
* **Spectral Formula:**
  - Normalized Burn Ratio: $NBR = \frac{\text{Band 8 (NIR)} - \text{Band 12 (SWIR)}}{\text{Band 8 (NIR)} + \text{Band 12 (SWIR)}}$.
  - Burn Severity Index: $\Delta NBR = NBR_{\text{pre-harvest}} - NBR_{\text{post-harvest}}$.
  - Rule: If $\Delta NBR < 0.10 \rightarrow$ Clean harvest, issue **No-Burn Certificate**.

### Model 5: Dharamkanta Weighbridge Ticket OCR & Anti-Fraud Engine
* **Goal:** Prevent manual input tampering when entering weighbridge slips.
* **Validation Rule:** $|\text{Gross} - \text{Tare} - \text{Net}| \le 0.02\text{ tonnes}$.

---

## 6. System Architecture: 1 Flutter App + 1 Next.js Web Portal

We strictly avoid the 3-native-apps trap. The architecture is cleanly divided:

```
┌─────────────────────────────────┐       ┌─────────────────────────────────┐
│     Farmer Mobile App (Flutter) │       │   Operations Web Portal (Next)  │
│  • Punjabi / Hindi / English    │       │  • Factory Buyers (Set Demand)  │
│  • Voice Intake & Bundle Picker │       │  • Weighbridge Ticket Entry     │
│  • Kisan Mitra toggle mode      │       │  • KVK Subsidy & Hotspot Map    │
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

## 7. The 7-Step "Golden Path" End-to-End Demo Workflow

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

## 8. Hackathon Execution Schedule & Merge Protocol

### Critical Branch Merge Order (When Ready to Merge):
1. **Step 1:** Merge `feat/profile-api` into `main`. Verify modified file is `backend/app/api/auth.py` (not endpoints/auth.py).
2. **Step 2:** Merge `feat/app-ux` into `main`. Keep both learning logs if any merge markers occur.
3. **Step 3:** Run `pytest` (21/21) and `flutter test` (8/8) on `main`.

### 3-Day Sprint Timeline:
* **Friday (Today):** Deploy backend to Render, implement OR-Tools matching engine, build Flutter Options screen.
* **Saturday (DTU Hackathon Day):** Booking state machine + simulated escrow + Dharamkanta slip entry + Buyer Web portal + Voice Intake confirmation.
* **Sunday (Presentation Day):** Polish 2-minute demo video showing physical phone sync with web portal, finalize pitch deck, print Judge Q&A cheat-sheet.

---

## 9. Anti-Hallucination Directives for AI Agents

Every agent working on this codebase MUST follow these instructions:
1. **Never invent database columns:** Always inspect `backend/alembic/versions/` and the live SQLAlchemy models in `backend/app/models/` before writing backend endpoints.
2. **Never commit secrets:** Never write or print `.env`, JWT secrets, or Supabase connection strings.
3. **Always separate BUILT vs PLANNED:** Never tell the user or write documentation claiming a mock or stub is production-ready.
4. **Preserve existing files and tests:** Run `pytest` in `backend/` and `flutter test` in `app/` before creating a PR or asking for merges.
5. **Read this file (`docs/ROADMAP.md`) first** before executing any prompt.


