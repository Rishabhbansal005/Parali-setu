# ParaliSetu — Product Specification (SPEC.md)

**Version:** 0.1 — 7 October 2026
**Status:** Living document. All agents must read this file before writing code.
**Owner:** Team ParaliSetu (Amazon Environmental Hacks, Oct 8–11, 2026)

> This is the single source of truth for the ParaliSetu project.
> If anything contradicts REFERENCE_NOTES.md, this file wins.
> Update this file (with a version bump) whenever the spec changes.

---

## Table of Contents

1. Problem, Solution, Target Users
2. User Roles
3. Full Farmer Flow
4. Other User Flows
5. Database Schema
6. State Machines
7. REST API
8. Matching Engine Design
9. Stubble Quantity Estimation
10. Impact Calculation
11. Satellite Verification
12. Voice Pipeline
13. UX Rules for Non-Tech Farmers
14. Demo Data Plan
15. Scope Tiers
16. Risks and Honest Limitations
17. Credits and Code Reuse
18. 4-Day Build Plan (Oct 8–11)

---

## §1 Problem, Solution, Target Users

**Problem.** Every October and November, farmers across Punjab, Haryana, and
Uttar Pradesh burn the paddy stubble (parali) left after harvest. They burn
it not because they want to, but because they have only 10–15 days between
rice harvest and the next wheat sowing, and no affordable, convenient way to
remove it. The resulting smoke is a primary cause of the hazardous air quality
that chokes Delhi-NCR for weeks. Government fines have failed to stop the
burning because they only create a cost without providing a realistic
alternative. Stubble also has real economic value as biogas feedstock, brick
kiln fuel, or agri-pellets, but the farmer has no easy way to find a buyer, a
harvesting machine, and a truck all available within the same narrow window.

**Solution.** ParaliSetu ("parali bridge") is a voice-first Android app that
removes every barrier between a farmer and a complete stubble-management deal
in one tap. A farmer speaks in Hindi or Punjabi to give his field size and
harvest date. The app estimates the stubble yield and expected income, then
presents 2–3 matched bundles — each bundle is a machine + truck + buyer already
confirmed available within the farmer's harvest window, shown as a net profit
figure alongside a "cost of burning" comparison. One tap books the full bundle.
The buyer's payment is held in a simulated escrow; the actual payout is
calculated from the weighbridge weight (not the estimate), so the farmer is
always paid for what was actually collected. After the transaction, satellite
imagery is used to verify that the field was not burnt, and a compliance
certificate is generated. A KVK/FPO web dashboard shows burn hotspots and
where more machines are needed across the district.

**Target users.** The primary user is a small or marginal farmer (1–5 acres,
low literacy, first smartphone) in Punjab, Haryana, or western UP who grows
paddy and faces the stubble problem every October–November. The app is
specifically designed for someone who may never have used an app before and
may hand their phone to a local Kisan Mitra (community tech helper) to
complete the booking on their behalf. Secondary users are biogas plant managers,
brick kiln operators, and agri-pellet factories (buyers), harvesting machine
owners, truck operators, and KVK/FPO extension officers who need district-level
data. All UI text, voice prompts, and notifications are in Hindi and Punjabi
only; English appears only in the admin/KVK dashboard.

---

## §2 User Roles

| Role | Hindi label | Who they are | Key permissions |
|---|---|---|---|
| **farmer** | किसान | Paddy farmer; primary app user | Create estimate, view and book offers, view own bookings and payments, rate service |
| **kisan_mitra** | किसान मित्र | Local tech-literate community agent who books on behalf of farmers | Everything a farmer can do, but must get the farmer's OTP consent before booking; can manage a list of linked farmers |
| **buyer** | खरीदार | Biogas plant, brick kiln, pellet factory | Post demand (quantity, price, moisture limit, deadline), view matched offers, confirm or counter-offer, trigger weighbridge payment |
| **machine_owner** | मशीन मालिक | Tractor/harvester/SMAM machine operator | Register machine with location and availability window, receive and accept booking requests |
| **truck_owner** | ट्रक मालिक | Transport operator | Register truck with capacity and availability, receive and accept booking requests |
| **kvk_officer** | KVK अधिकारी | Krishi Vigyan Kendra / FPO extension officer | Read-only dashboard: burn hotspot map, machine demand heatmap, district booking pipeline |

**Role assignment:** A user may hold multiple roles (e.g., a farmer who also owns a tractor). Roles are selected at registration and can be updated. The `kisan_mitra` role requires admin approval (Day 2+ feature).

---

## §3 Full Farmer Flow

Every screen follows UX Rule §13.1: one task per screen, large buttons,
voice prompt available on every screen, Hindi/Punjabi only.

1. **Splash / install.** App opens. If first launch, show a 3-slide onboarding
   in Hindi (problem → solution → income earned by other farmers).
   [SIMULATED income figures on onboarding slide: mark clearly as DEMO DATA]

2. **OTP login.** Enter mobile number (numeric keypad only, no keyboard).
   Receive OTP via SMS. Enter 6-digit OTP. On success, receive JWT access +
   refresh tokens, stored in Flutter Secure Storage. If the number is new,
   go to minimal registration (name, village, district — voice-fillable).

3. **Language select.** Two large buttons: हिंदी | ਪੰਜਾਬੀ. Choice persisted
   in local storage. All subsequent text and TTS in the chosen language.

4. **Voice intake — acres and harvest date.**
   - Screen shows a large microphone button and the prompt (TTS):
     "कितने एकड़ में धान है और कब काटेंगे?"
     ("How many acres of paddy, and when will you harvest?")
   - Farmer speaks. Speech-to-text (see §12) transcribes. LLM extracts
     `{acres: float, harvest_date: date}`.
   - If extraction fails or confidence is low, fall back to two simple
     numeric pickers (acres wheel, calendar date picker).
   - User confirms the extracted values before proceeding.

5. **Two quick questions (form, large buttons).**
   - Q1: Paddy variety — [Pusa-44 | PR-126 | Basmati | अन्य (Other)]
     (variety affects yield; ASSUMPTION — verify yield factors with KVK/ICAR)
   - Q2: Harvest method — [Combine harvester | हाथ से (manual)]
     (combine leaves more stubble than manual; ASSUMPTION — verify with KVK)

6. **Immediate estimate screen.**
   - Shows: estimated stubble (tonnes, with ± range), expected income range
     (₹ low–high), and the key message: "यह पराली जलाने की जरूरत नहीं।"
   - All numbers generated by the estimate formula in §9.
   - Large button: "मेरे लिए विकल्प देखें" (Show me options).

7. **Loading / matching.** Brief animated screen (2–3 seconds max). Backend
   runs matching engine (§8) and returns 2–3 offers.

8. **Options screen — 2–3 matched bundles.**
   Each bundle card shows (in large text):
   - Machine name + available date
   - Truck operator name
   - Buyer name + price per tonne (₹)
   - Estimated net income (₹), with range
   - **"अभी जलाते तो" (Cost of burning):** fine risk + soil cost + health cost
     (ASSUMPTION — use placeholder figures until verified)
   - Pickup date within the farmer's window

9. **One-tap booking.**
   Farmer taps "बुक करें" (Book). A confirmation dialog reads the bundle
   details aloud via TTS. Farmer taps "हाँ, बुक करो" (Yes, book it).

10. **Escrow hold screen.**
    Screen shows: "खरीदार ने ₹X जमा किया है। पराली उठाने के बाद मिलेगा।"
    ("Buyer has deposited ₹X. You will receive it after pickup.")
    UI clearly states: "यह एक डेमो सिमुलेशन है। वास्तविक भुगतान गेटवे बाद में जुड़ेगा।"
    ("This is a demo simulation. Real payment gateway will be integrated later.")
    Booking status: `confirmed`.

11. **Pickup day — live status screen.**
    Push notification on pickup day morning. Screen shows machine name,
    operator contact, ETA (from OSRM, refreshed periodically).
    Booking status: `picked_up` when operator marks arrival.

12. **Weighbridge weight entry.**
    Operator submits weighbridge ticket (weight in kg, ticket number,
    timestamp). Farmer sees: "तुम्हारी पराली का वजन: X टन।" Farmer and
    operator both confirm. If disputed, status moves to `disputed` and KVK
    officer is notified. Booking status: `weighed`.

13. **Payment release — ACTUAL weight.**
    System calculates: `final_payment = weighbridge_weight_kg * buyer_price_per_tonne / 1000`.
    Payment released from simulated escrow to farmer's registered bank/UPI.
    Screen shows breakdown: weight × price, platform fee (ASSUMPTION — define
    fee structure), net payout. Booking status: `paid`.

14. **Impact screen.**
    Shows: CO2-eq avoided (placeholder formula, §10), equivalent trees saved
    (placeholder), air quality improvement (qualitative only — avoid
    inventing quantitative claims). Shareable graphic.

15. **Satellite verification — result.**
    7–10 days post-booking, background job runs §11 satellite check.
    Push notification: "आपके खेत की जाँच हो गई।" (Your field has been verified.)
    Result states: `verified_no_burn` / `unclear` / `burn_detected`.
    Screen shows the Sentinel-2 false-colour image thumbnail and the result.
    If `burn_detected`, KVK officer is notified. Booking status: `verified`.

16. **Rating screen.**
    Farmer rates machine operator (1–5 stars), truck operator (1–5 stars),
    and overall experience (1–5 stars). Optional voice comment. One button
    to submit. Rating persisted to `ratings` table and averaged on provider
    profiles.

---

## §4 Other User Flows

### 4a. Buyer flow

1. Register as `buyer`. Provide GST number, business address, lat/lon of facility.
2. Post a demand notice: commodity type (biogas/brick/pellet), price per tonne
   (₹), moisture limit (%), minimum batch size (tonnes), pickup window (dates),
   maximum distance from facility (km). Demand stored in `buyers` table.
3. Receive matched offers from the matching engine. Accept or counter-offer.
4. When booking is confirmed, buyer's payment is held in simulated escrow.
5. On weighbridge event, buyer confirms or disputes weight.
6. On confirmation, escrow released to farmer minus platform fee.
7. Buyer receives compliance certificate (field not burnt, verified by satellite).

### 4b. Machine owner flow

1. Register machine: type (SMAM super straw management, baler, shredder),
   brand, capacity (acres/day), current location (lat/lon), availability
   window (start date, end date), price per acre (₹), and photos.
2. Receive booking requests. Accept or decline within 2 hours (configurable).
3. On pickup day, mark arrival at field. Submit weighbridge ticket details.
4. Receive service fee from platform after weighbridge confirmation.
5. Build reputation through farmer ratings.

### 4c. Truck owner flow

1. Register truck: capacity (tonnes), current location, availability window,
   price per tonne-km (₹), and photos.
2. Matching engine assigns truck to a booking (farmer is not shown truck
   selection separately — it is bundled with the machine).
3. On pickup day, collect stubble from field, deliver to buyer facility.
4. Submit delivery confirmation (buyer signs off).
5. Receive transport fee from platform.

### 4d. Kisan Mitra (proxy booking) flow

1. Kisan Mitra logs in with their own credentials.
2. Selects a linked farmer from their farmer list (or searches by phone number).
3. Initiates a booking on the farmer's behalf.
4. System sends an OTP to the **farmer's** phone.
5. Kisan Mitra reads the OTP to the farmer (face-to-face) and enters it.
6. Booking proceeds as a normal farmer booking, attributed to the farmer's
   account. Kisan Mitra is recorded as `proxy_user_id` in the booking.
7. All notifications go to the farmer's phone, not the Kisan Mitra's.

### 4e. KVK/FPO dashboard flow

1. Login via email/password (web, not mobile).
2. `/map` — MapLibre map showing:
   - Live FIRMS VIIRS fire hotspots (last 48 hours)
   - Sentinel-2 burn scar overlay (last pass, cloud-permitting)
   - District-level booking density heat map
3. `/machines` — machine availability by district; where supply gaps exist.
4. `/bookings` — full booking pipeline; filter by date, district, status.
5. `/demand` — buyer demand vs estimated stubble supply gap per district.
6. Receive notifications when `burn_detected` for a field that had a booking.
7. Read-only. No ability to create or modify bookings.

---

## §5 Database Schema

**Engine:** PostgreSQL 15+ with PostGIS 3.4+
**ORM:** SQLAlchemy 2.0 with mapped classes
**Migrations:** Alembic

All tables have: `id UUID PRIMARY KEY DEFAULT gen_random_uuid()`,
`created_at TIMESTAMPTZ NOT NULL DEFAULT now()`,
`updated_at TIMESTAMPTZ NOT NULL DEFAULT now()`.

---

### 5.1 users

| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| phone_e164 | VARCHAR(20) UNIQUE NOT NULL | e.g. +919876543210 |
| name | VARCHAR(100) | |
| preferred_language | VARCHAR(10) NOT NULL DEFAULT 'hi' | 'hi' or 'pa' |
| roles | VARCHAR[] NOT NULL | e.g. ['farmer','machine_owner'] |
| village | VARCHAR(100) | |
| district | VARCHAR(100) | |
| state | VARCHAR(100) DEFAULT 'Punjab' | |
| fcm_token | TEXT | Firebase Cloud Messaging device token |
| is_active | BOOLEAN NOT NULL DEFAULT true | |

---

### 5.2 farms

| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| farmer_id | UUID FK users.id NOT NULL | |
| name | VARCHAR(100) | e.g. "North field" |
| area_acres | NUMERIC(6,2) NOT NULL | ASSUMPTION — max precision needed |
| paddy_variety | VARCHAR(50) | 'PR-126', 'Pusa-44', 'Basmati', 'other' |
| harvest_method | VARCHAR(20) | 'combine', 'manual' |
| location | GEOMETRY(Point, 4326) | PostGIS point (centroid of field) |
| boundary | GEOMETRY(Polygon, 4326) | PostGIS polygon (for satellite query) |
| khasra_number | VARCHAR(50) | Land record ID (optional) |

---

### 5.3 estimates

| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| farm_id | UUID FK farms.id NOT NULL | |
| requested_at | TIMESTAMPTZ NOT NULL | |
| harvest_date | DATE NOT NULL | Farmer's stated harvest date |
| wheat_sow_date | DATE | Latest acceptable pickup date |
| stubble_tonnes_low | NUMERIC(6,2) | Lower bound of estimate |
| stubble_tonnes_mid | NUMERIC(6,2) | Central estimate |
| stubble_tonnes_high | NUMERIC(6,2) | Upper bound of estimate |
| income_low_inr | NUMERIC(10,2) | |
| income_high_inr | NUMERIC(10,2) | |
| config_snapshot | JSONB | Snapshot of CONFIG values used (§9) |

---

### 5.4 buyers

| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| user_id | UUID FK users.id NOT NULL | |
| business_name | VARCHAR(200) | |
| business_type | VARCHAR(50) | 'biogas', 'brick_kiln', 'pellet', 'other' |
| location | GEOMETRY(Point, 4326) | Facility location |
| max_distance_km | NUMERIC(6,1) | Won't accept stubble from further than this |
| price_per_tonne_inr | NUMERIC(8,2) | Current offer price |
| moisture_limit_pct | NUMERIC(4,1) | ASSUMPTION — typical value varies by buyer type |
| min_batch_tonnes | NUMERIC(6,2) | Minimum pickup quantity |
| max_batch_tonnes | NUMERIC(6,2) | Maximum per booking |
| demand_window_start | DATE | |
| demand_window_end | DATE | |
| is_active | BOOLEAN NOT NULL DEFAULT true | |

---

### 5.5 machines

| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| owner_id | UUID FK users.id NOT NULL | |
| machine_type | VARCHAR(50) | 'SMAM_straw_mgmt', 'baler', 'shredder', 'other' |
| brand | VARCHAR(100) | |
| capacity_acres_per_day | NUMERIC(5,2) | ASSUMPTION — verify with machine owners |
| location | GEOMETRY(Point, 4326) | Current home location |
| price_per_acre_inr | NUMERIC(8,2) | |
| availability_start | DATE | |
| availability_end | DATE | |
| is_active | BOOLEAN NOT NULL DEFAULT true | |
| photos | TEXT[] | URLs |

---

### 5.6 trucks

| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| owner_id | UUID FK users.id NOT NULL | |
| capacity_tonnes | NUMERIC(6,2) | |
| location | GEOMETRY(Point, 4326) | Current home location |
| price_per_tonne_km_inr | NUMERIC(8,4) | ASSUMPTION — verify with transporters |
| availability_start | DATE | |
| availability_end | DATE | |
| is_active | BOOLEAN NOT NULL DEFAULT true | |
| photos | TEXT[] | URLs |

---

### 5.7 offers

Stores the output of the matching engine — one row per candidate bundle
shown to the farmer.

| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| estimate_id | UUID FK estimates.id NOT NULL | |
| machine_id | UUID FK machines.id NOT NULL | |
| truck_id | UUID FK trucks.id NOT NULL | |
| buyer_id | UUID FK buyers.id NOT NULL | |
| proposed_pickup_date | DATE | Computed by matching engine |
| machine_cost_inr | NUMERIC(10,2) | |
| transport_cost_inr | NUMERIC(10,2) | |
| gross_income_inr | NUMERIC(10,2) | buyer_price × estimated_weight |
| net_income_inr | NUMERIC(10,2) | gross - machine_cost - transport_cost |
| rank | SMALLINT | 1 = best for farmer |
| expires_at | TIMESTAMPTZ | Offer validity window |

---

### 5.8 bookings

| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| offer_id | UUID FK offers.id NOT NULL | |
| farmer_id | UUID FK users.id NOT NULL | |
| proxy_user_id | UUID FK users.id | NULL unless Kisan Mitra booked |
| status | VARCHAR(30) NOT NULL DEFAULT 'requested' | See §6 FSM |
| cancelled_reason | TEXT | |
| cancellation_actor | VARCHAR(30) | 'farmer','machine_owner','system' |
| confirmed_at | TIMESTAMPTZ | |
| picked_up_at | TIMESTAMPTZ | |
| weighed_at | TIMESTAMPTZ | |
| paid_at | TIMESTAMPTZ | |
| verified_at | TIMESTAMPTZ | |

---

### 5.9 payments

| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| booking_id | UUID FK bookings.id NOT NULL | |
| provider | VARCHAR(30) NOT NULL DEFAULT 'mock' | 'mock' or 'razorpay' |
| provider_order_id | VARCHAR(200) | NULL for mock |
| escrow_amount_inr | NUMERIC(10,2) | Amount held from buyer |
| final_amount_inr | NUMERIC(10,2) | Amount released to farmer (after weighbridge) |
| platform_fee_inr | NUMERIC(10,2) | ASSUMPTION — define fee structure |
| status | VARCHAR(30) NOT NULL DEFAULT 'held' | See §6 escrow FSM |
| held_at | TIMESTAMPTZ | |
| released_at | TIMESTAMPTZ | |
| refunded_at | TIMESTAMPTZ | |
| notes | TEXT | e.g. "SIMULATED — MockPaymentProvider" |

---

### 5.10 weighbridge_records

| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| booking_id | UUID FK bookings.id NOT NULL | |
| submitted_by | UUID FK users.id | Machine owner who submits ticket |
| weight_kg | NUMERIC(10,2) NOT NULL | Actual weight from weighbridge |
| ticket_number | VARCHAR(100) | Physical receipt number |
| ticket_image_url | TEXT | Photo of weighbridge ticket |
| farmer_confirmed | BOOLEAN | |
| buyer_confirmed | BOOLEAN | |
| disputed | BOOLEAN NOT NULL DEFAULT false | |
| dispute_notes | TEXT | |
| measured_at | TIMESTAMPTZ | Time on weighbridge receipt |

---

### 5.11 burn_checks

| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| booking_id | UUID FK bookings.id NOT NULL | |
| farm_id | UUID FK farms.id NOT NULL | |
| checked_at | TIMESTAMPTZ | When the satellite query was run |
| satellite_source | VARCHAR(30) | 'sentinel2', 'firms_viirs' |
| image_date | DATE | Date of the satellite pass used |
| cloud_cover_pct | NUMERIC(5,2) | At time of image — affects reliability |
| burn_detected | BOOLEAN | NULL = inconclusive |
| burn_severity | VARCHAR(20) | 'none','low','moderate','high', or NULL |
| burn_fraction | NUMERIC(5,4) | 0–1, fraction of field boundary with burn scar |
| result_state | VARCHAR(30) NOT NULL | 'verified_no_burn','unclear','burn_detected' |
| vlm_raw_response | JSONB | Full JSON from LFM2.5-VL-450M |
| notes | TEXT | |

---

### 5.12 impact_log

| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| booking_id | UUID FK bookings.id NOT NULL | |
| stubble_kg | NUMERIC(10,2) | From weighbridge_records |
| co2_eq_kg_avoided | NUMERIC(12,2) | FILL FROM PUBLISHED SOURCE (ICAR/CPCB/peer-reviewed paper) |
| pm25_kg_avoided | NUMERIC(10,4) | FILL FROM PUBLISHED SOURCE |
| equivalent_trees | NUMERIC(10,2) | FILL FROM PUBLISHED SOURCE (conversion formula) |
| calculation_version | VARCHAR(20) | Version of emission factors used |
| notes | TEXT | |

---

## §6 State Machines

### 6.1 Booking FSM

```
                    ┌──────────────────────────────────────────────────────┐
                    │                                                      │
   [farmer taps book]                                                      │
         │                                                                 │
         v                                                                 │
    REQUESTED ──(machine/truck confirm within SLA)──> CONFIRMED            │
         │                                                 │               │
         │ (any party cancels)                             │ (pickup day)  │
         v                                                 v               │
    CANCELLED                                         PICKED_UP            │
                                                           │               │
                                                (weighbridge submitted)    │
                                                           v               │
                                                        WEIGHED            │
                                                           │               │
                                                  (both parties confirm)   │
                                                           v               │
                                                          PAID             │
                                                           │               │
                                                (satellite check done)     │
                                                           v               │
                                                       VERIFIED ───────────┘

    At any point after CONFIRMED:
    CONFIRMED / PICKED_UP / WEIGHED ──(unresolvable dispute)──> FAILED
```

**Transition rules:**
- `REQUESTED -> CONFIRMED`: Machine owner AND truck owner both accept. Buyer escrow hold triggered.
- `CONFIRMED -> CANCELLED`: Farmer, machine owner, or system can cancel before `picked_up_at`. Escrow refunded.
- `CONFIRMED -> PICKED_UP`: Machine owner submits arrival confirmation.
- `PICKED_UP -> WEIGHED`: Machine owner submits weighbridge record.
- `WEIGHED -> PAID`: Both farmer and buyer confirm weight. Payment released.
- `WEIGHED -> DISPUTED`: Either party disputes weight. KVK officer notified.
- `PAID -> VERIFIED`: Satellite check completes (result any of the three states — `paid` is final regardless).
- `* -> FAILED`: System admin action after unresolvable dispute.

---

### 6.2 Escrow FSM

```
   [buyer confirms booking]
            │
            v
          HELD ──(weighbridge confirmed by both parties)──> RELEASED
            │                                                (to farmer)
            │
            └──(booking cancelled before picked_up)──> REFUNDED
                                                        (to buyer)
            │
            └──(FAILED status)──> REFUNDED (or partial, per dispute ruling)
```

**Payment adapter interface (MockPaymentProvider):**
The `PaymentProvider` interface exposes:
- `hold(booking_id, amount_inr) -> order_id`
- `release(order_id, final_amount_inr) -> receipt`
- `refund(order_id, reason) -> receipt`

`MockPaymentProvider` implements the interface with in-memory/DB state and
returns `SIMULATED` receipts. `RazorpayProvider` will implement the same
interface using Razorpay's `capture_later` flow. Business logic never calls
Razorpay directly — only calls the interface.

---

## §7 REST API

**Base URL:** `/api/v1`
**Auth:** Bearer JWT in `Authorization` header. OTP endpoints are public.
**Roles in "Who may call":** F = farmer, KM = kisan_mitra, B = buyer, MO = machine_owner, TO = truck_owner, KVK = kvk_officer, * = any authenticated

---

### 7.1 Authentication

| Method | Path | Request body | Response | Who |
|---|---|---|---|---|
| POST | `/auth/otp/send` | `{phone_e164}` | `{message}` | Public |
| POST | `/auth/otp/verify` | `{phone_e164, otp}` | `{access_token, refresh_token, user}` | Public |
| POST | `/auth/token/refresh` | `{refresh_token}` | `{access_token}` | Public |
| GET | `/auth/me` | — | `{user}` | * |

### 7.2 Farmers & Farms

| Method | Path | Request body | Response | Who |
|---|---|---|---|---|
| POST | `/farmers/register` | `{name, village, district, language}` | `{user}` | F, KM |
| GET | `/farmers/{id}` | — | `{user, farms}` | F (own), KM, KVK |
| POST | `/farmers/{id}/farms` | `{area_acres, paddy_variety, harvest_method, location_geojson, boundary_geojson, khasra_number?}` | `{farm}` | F, KM |
| GET | `/farmers/{id}/farms` | — | `[farm]` | F (own), KM |

### 7.3 Estimates

| Method | Path | Request body | Response | Who |
|---|---|---|---|---|
| POST | `/estimates` | `{farm_id, harvest_date, wheat_sow_date?}` | `{estimate}` with low/mid/high tonnes and income range | F, KM |
| GET | `/estimates/{id}` | — | `{estimate}` | F (own), KM |

### 7.4 Matching & Offers

| Method | Path | Request body | Response | Who |
|---|---|---|---|---|
| POST | `/offers/match` | `{estimate_id}` | `[offer]` — 2–3 ranked bundles | F, KM |
| GET | `/offers/{id}` | — | `{offer}` | F, KM, MO, TO, B |

### 7.5 Bookings

| Method | Path | Request body | Response | Who |
|---|---|---|---|---|
| POST | `/bookings` | `{offer_id, proxy_otp?}` | `{booking}` | F, KM |
| GET | `/bookings/{id}` | — | `{booking, offer, payment}` | F (own), MO, TO, B, KVK |
| GET | `/bookings` | `?status=&district=&page=` | `[booking]` | KVK (all), F (own), MO/TO/B (theirs) |
| PATCH | `/bookings/{id}/confirm` | — | `{booking}` | MO, TO |
| PATCH | `/bookings/{id}/cancel` | `{reason}` | `{booking}` | F, MO, system |
| PATCH | `/bookings/{id}/pickup` | — | `{booking}` | MO |

### 7.6 Weighbridge

| Method | Path | Request body | Response | Who |
|---|---|---|---|---|
| POST | `/bookings/{id}/weighbridge` | `{weight_kg, ticket_number, ticket_image_url?, measured_at}` | `{weighbridge_record}` | MO |
| PATCH | `/bookings/{id}/weighbridge/confirm` | `{actor: "farmer"|"buyer"}` | `{weighbridge_record}` | F, B |
| PATCH | `/bookings/{id}/weighbridge/dispute` | `{notes}` | `{weighbridge_record}` | F, B |

### 7.7 Payments

| Method | Path | Request body | Response | Who |
|---|---|---|---|---|
| GET | `/bookings/{id}/payment` | — | `{payment}` | F, B, MO |
| POST | `/payments/webhook` | Provider-specific payload | 200 OK | System only |

### 7.8 Satellite Verification

| Method | Path | Request body | Response | Who |
|---|---|---|---|---|
| POST | `/verify/burn` | `{booking_id}` | `{burn_check}` — queued async | System (cron), KVK |
| GET | `/verify/burn/{booking_id}` | — | `{burn_check}` | F (own), KVK |

### 7.9 Buyers

| Method | Path | Request body | Response | Who |
|---|---|---|---|---|
| POST | `/buyers` | `{business_name, business_type, location_geojson, price_per_tonne_inr, moisture_limit_pct, min_batch_tonnes, max_batch_tonnes, demand_window_start, demand_window_end, max_distance_km}` | `{buyer}` | B |
| GET | `/buyers/{id}` | — | `{buyer}` | * |
| PATCH | `/buyers/{id}` | any subset | `{buyer}` | B (own) |

### 7.10 Machines & Trucks

| Method | Path | Request body | Response | Who |
|---|---|---|---|---|
| POST | `/machines` | `{machine_type, brand, capacity_acres_per_day, location_geojson, price_per_acre_inr, availability_start, availability_end}` | `{machine}` | MO |
| GET | `/machines` | `?district=&available_from=&available_to=` | `[machine]` | *, KVK |
| PATCH | `/machines/{id}` | any subset | `{machine}` | MO (own) |
| POST | `/trucks` | `{capacity_tonnes, location_geojson, price_per_tonne_km_inr, availability_start, availability_end}` | `{truck}` | TO |
| GET | `/trucks` | `?district=&available_from=&available_to=` | `[truck]` | *, KVK |
| PATCH | `/trucks/{id}` | any subset | `{truck}` | TO (own) |

### 7.11 KVK Dashboard

| Method | Path | Request body | Response | Who |
|---|---|---|---|---|
| GET | `/kvk/hotspots` | `?days=3` | FIRMS VIIRS data parsed into GeoJSON | KVK |
| GET | `/kvk/burn-trend` | `?district=&year=` | District-level burn event counts | KVK |
| GET | `/kvk/demand-gap` | `?district=` | Supply estimate vs buyer demand | KVK |

### 7.12 Impact

| Method | Path | Request body | Response | Who |
|---|---|---|---|---|
| GET | `/bookings/{id}/impact` | — | `{impact_log}` | F, KVK |

### 7.13 Ratings

| Method | Path | Request body | Response | Who |
|---|---|---|---|---|
| POST | `/bookings/{id}/ratings` | `{machine_stars, truck_stars, overall_stars, voice_comment?}` | `{rating}` | F |

---

## §8 Matching Engine Design

**File:** `backend/app/services/matching.py`
**Libraries:** `ortools.sat.python.cp_model` (CP-SAT solver), `requests` (OSRM calls)

### 8.1 Inputs

For a given `estimate_id`:
- Farmer's field location (lat/lon centroid), `area_acres`, `stubble_tonnes_mid`
- Harvest window: `[harvest_date, wheat_sow_date]` (typically 10–15 days)
- All active machines within `MAX_MACHINE_SEARCH_RADIUS_KM`
  (CONFIG — ASSUMPTION: 30 km default, verify with machine owners)
- All active trucks within `MAX_TRUCK_SEARCH_RADIUS_KM`
  (CONFIG — ASSUMPTION: 50 km default)
- All active buyers within `MAX_BUYER_SEARCH_RADIUS_KM`
  (CONFIG — ASSUMPTION: 100 km default)
- OSRM road-distance matrix between all relevant points

### 8.2 Constraints (hard — must all be satisfied)

1. Machine is not already booked on the proposed pickup date.
2. Machine capacity (acres/day) × available days ≥ `farm.area_acres`.
3. Truck capacity (tonnes) ≥ `estimate.stubble_tonnes_mid`.
4. Truck is not already booked on the proposed transport date.
5. `proposed_pickup_date` ∈ `[harvest_date, wheat_sow_date]`.
6. Buyer's `demand_window_start ≤ proposed_pickup_date ≤ demand_window_end`.
7. OSRM road distance from field to buyer ≤ `buyer.max_distance_km`.
8. Buyer's `moisture_limit_pct` — flagged if paddy variety known to be high-moisture
   (ASSUMPTION — moisture mapping per variety; verify with buyers and KVK).
9. `stubble_tonnes_mid ≥ buyer.min_batch_tonnes`.

### 8.3 Objective function (optimise in this priority order)

1. **Maximise farmer net income:** `(buyer_price × stubble_mid) - machine_cost - transport_cost`
2. **Minimise total transport distance:** sum of OSRM distances machine→field + truck→field + truck→buyer
3. **Minimise number of days to pickup:** earlier in the window is better
4. **Minimise unmet buyer demand:** cluster neighbouring farmers to fill buyer's minimum batch

### 8.4 Cluster booking for neighbouring farmers

When a single farmer's stubble volume is below a buyer's `min_batch_tonnes`,
the matching engine looks for farmers within `CLUSTER_RADIUS_KM`
(CONFIG — ASSUMPTION: 5 km) with overlapping harvest windows and the same machine
already allocated, and groups them into a combined booking to meet the buyer's minimum.
The machine is routed across all fields in one pass. Individual payments are
calculated per farmer at weighbridge time.

### 8.5 OR-Tools usage

The CP-SAT model assigns:
- Boolean variable `x[machine_i, truck_j, buyer_k, date_d]` = 1 if this combination is offered.
- At most `MAX_OFFERS` (CONFIG: 3) combinations returned per farmer.
- Solver timeout: `MATCHING_TIMEOUT_SECONDS` (CONFIG: 10 seconds).
- If no feasible solution within timeout, return partial matches (relax radius constraints progressively).

### 8.6 OSRM usage

OSRM `table` API (multi-point distance matrix) is called once per matching run.
Use the public OSRM demo server for the hackathon demo.
For production, self-host an OSRM instance with India road data (Geofabrik).

---

## §9 Stubble Quantity Estimation

**File:** `backend/app/services/estimation.py`
**CONFIG file:** `backend/app/core/stubble_config.py` (or YAML — never hard-code in business logic)

### 9.1 Formula

```
stubble_dry_weight_tonnes = area_acres * YIELD_FACTOR[variety][harvest_method]
```

```
income_gross = stubble_dry_weight_tonnes * buyer_price_per_tonne_inr
```

### 9.2 CONFIG values (all marked ASSUMPTION — must be verified with KVK/ICAR)

```python
# stubble_config.py
# ASSUMPTION — all values below must be verified with KVK / ICAR
# before using in a real payment calculation.

YIELD_FACTOR = {
    # tonnes of dry stubble per acre, by paddy variety and harvest method
    "PR-126":  {"combine": 2.0, "manual": 1.2},   # ASSUMPTION
    "Pusa-44": {"combine": 2.5, "manual": 1.5},    # ASSUMPTION
    "Basmati": {"combine": 1.5, "manual": 0.9},    # ASSUMPTION
    "other":   {"combine": 2.0, "manual": 1.2},    # ASSUMPTION (use PR-126 default)
}

YIELD_RANGE_FACTOR_LOW  = 0.80   # ASSUMPTION — ± 20% range
YIELD_RANGE_FACTOR_HIGH = 1.20   # ASSUMPTION

PLATFORM_FEE_PCT = 0.05          # ASSUMPTION — 5%; define before launch
```

### 9.3 Range logic

```
low  = mid * YIELD_RANGE_FACTOR_LOW
high = mid * YIELD_RANGE_FACTOR_HIGH
```

### 9.4 Calibration from weighbridge data

After each completed booking, a background job compares `estimates.stubble_tonnes_mid`
with `weighbridge_records.weight_kg / 1000`. The ratio is logged to `impact_log`
and periodically used to update `YIELD_FACTOR` values in the CONFIG.
This is a SHOULD-HAVE feature; initial values are assumptions.

---

## §10 Impact Calculation

**File:** `backend/app/services/impact.py`

> **CRITICAL: All emission factors below are PLACEHOLDERS.**
> Replace every value marked "FILL FROM PUBLISHED SOURCE" with a
> cited figure from ICAR, CPCB, or a peer-reviewed paper before
> making any public claim. Never quote a number you cannot cite.

### 10.1 Formula

```
co2_eq_kg_avoided = stubble_kg * CO2_EQ_FACTOR_KG_PER_KG_STUBBLE

pm25_kg_avoided   = stubble_kg * PM25_FACTOR_KG_PER_KG_STUBBLE

equivalent_trees  = co2_eq_kg_avoided / CO2_PER_TREE_PER_YEAR_KG
```

### 10.2 Factors (all placeholders)

```python
CO2_EQ_FACTOR_KG_PER_KG_STUBBLE = None   # FILL FROM PUBLISHED SOURCE (ICAR/CPCB/peer-reviewed)
PM25_FACTOR_KG_PER_KG_STUBBLE   = None   # FILL FROM PUBLISHED SOURCE
CO2_PER_TREE_PER_YEAR_KG        = None   # FILL FROM PUBLISHED SOURCE
```

The `impact_log` table stores `calculation_version` so old records are not
retroactively changed when factors are updated.

### 10.3 What to display when factors are not yet filled

During the demo, display only qualitative impact language:
"X tonnes of stubble collected = X tonnes not burnt"
Do **not** display CO2-eq or PM2.5 numbers until a cited source is in place.

---

## §11 Satellite Verification

**File:** `backend/app/services/satellite.py`
**Adapted from:** `parali` repo, `orchestrator/main.py` (with owner permission)

### 11.1 What the two data sources give us

| Source | What it provides | Resolution | Revisit | Best for |
|---|---|---|---|---|
| NASA FIRMS VIIRS | Active fire detections in near-real-time | 375 m | 12 h | Detecting active burning on the day |
| Sentinel-2 SWIR (via Copernicus CDSE) | Post-event burn scar detection using SWIR band composite (B12-B8-B4) | 10 m | 5 days | Verifying a field was NOT burnt, after the event |

### 11.2 Verification pipeline

1. Background cron runs 7–10 days after `booking.paid_at`.
2. Fetches `farm.boundary` (PostGIS polygon) for the booking.
3. Calls Copernicus CDSE (or SimSat API during hackathon demo) for the
   nearest cloud-free Sentinel-2 pass within the post-booking window.
4. Sends RGB + SWIR composites (base64) to LFM2.5-VL-450M via llama-server.
5. VLM returns structured JSON (see §7.8 for fields).
6. Result stored in `burn_checks`. Booking status moves to `verified`.
7. If `burn_detected`, KVK officer is notified and booking is flagged.

### 11.3 Result states

| State | Meaning |
|---|---|
| `verified_no_burn` | Sentinel-2 SWIR shows no burn scar within the field boundary. High confidence. |
| `unclear` | Cloud cover > threshold, or image quality insufficient for confident assessment. |
| `burn_detected` | SWIR burn scar detected within the field boundary. KVK notified. |

### 11.4 Honest limits

- Cloud cover during Oct–Nov over Punjab/Haryana can be significant — a
  `verified_no_burn` result may not be possible until clouds clear.
- Sentinel-2 revisit is 5 days; there may be a 5–10 day gap after burning
  before a usable image is available.
- The LFM2.5-VL-450M model has 74.8% accuracy (see REFERENCE_NOTES.md §7).
  This is not good enough for a legal compliance claim — it is an
  **indicator only**.
- VIIRS at 375 m will miss small fires on fields under ~2 ha.
- This system is a **screening tool**, not a legal substitute for ground
  inspection by a revenue officer.

---

## §12 Voice Pipeline

### 12.1 Speech-to-text options (in priority order for hackathon)

| Option | Language support | Cost | Integration |
|---|---|---|---|
| Android SpeechRecognizer (on-device) | Hindi (hi-IN), Punjabi (pa-IN) | Free | Native Flutter via `speech_to_text` plugin |
| Bhashini ASR API (government, MeitY) | Hindi, Punjabi + 21 other Indian languages | Free (API key needed) | HTTP POST with audio bytes |
| Google Cloud Speech-to-Text | Hindi, Punjabi | Paid (~$0.016/min) | REST API |

**Hackathon choice:** Use Android SpeechRecognizer first (zero cost, works offline
on modern devices). Fall back to Bhashini ASR for better Punjabi accuracy.

### 12.2 LLM extraction of acres and date

After transcription, send the raw text string to a small on-device or
cloud LLM with this prompt (adapt from SIH2022 voice approach):

```
Extract two values from this farmer's statement in Hindi or Punjabi.
Return JSON only: {"acres": <float or null>, "harvest_date": <"YYYY-MM-DD" or null>}.
If you cannot extract a value, set it to null. Do not invent values.
Statement: "{transcription}"
Today's date: {today}
```

Options for the LLM:
- Google Gemini Flash (fast, cheap, supports Hindi)
- A small local model via Ollama (offline capable)

### 12.3 Fallback

If both `acres` and `harvest_date` are null after LLM extraction, or if the
farmer taps the "समझ नहीं आया" (Did not understand) button:
- Show two large numeric pickers: acres (0.5 increments), date (calendar).
- Play TTS prompt: "कृपया संख्या चुनें।" (Please choose a number.)
- Farmers can always skip voice and use the picker directly.

---

## §13 UX Rules for Non-Tech Farmers

These rules apply to every screen in the Android app. Any agent building the
app must follow them. They take priority over standard mobile UX conventions.

1. **One screen, one task.** Each screen has exactly one primary action.
   No multi-step forms on a single screen.

2. **Big buttons.** Minimum touch target: 64 dp height. Primary action button
   spans the full width of the screen.

3. **Voice on every screen.** Every screen has a microphone button (top-right
   or bottom-centre). Tapping it reads the screen content aloud via TTS and
   accepts voice input for the current task.

4. **Hindi and Punjabi only.** All UI text, labels, error messages, and push
   notifications are in the user's chosen language. No English in the farmer
   app. Transliteration is acceptable where a technical term has no
   vernacular equivalent; always add a spoken explanation.

5. **Show benefit before asking for details.** The estimate screen (benefit)
   comes before the 2-question form (details). Never ask for data before
   showing what the farmer will gain.

6. **Offline-first.** All screens that do not require a network call must work
   without internet. The estimate formula runs locally. Booking requests are
   queued locally and synced when connectivity returns.

7. **APK under 25 MB.** Use deferred loading for rarely-used assets. Compress
   images. Do not bundle large model files in the APK; load from network on
   first use.

8. **Never show a raw error message.** Translate all errors to friendly Hindi
   sentences with a suggested action. Log the technical error server-side.

---

## §14 Demo Data Plan

> **ALL DATA IN THIS SECTION IS SIMULATED.**
> It exists solely to demonstrate the app during the hackathon.
> No real farmers, buyers, or transactions are represented.

### Simulated farmers (20)

Fields: name, village, district, acres, variety, harvest_date, lat/lon

| # | Name | Village | District | Acres | Variety | Harvest date |
|---|---|---|---|---|---|---|
| 1 | Gurpreet Singh | Bhikhiwind | Tarn Taran | 4.0 | PR-126 | 2026-10-18 |
| 2 | Amarjit Kaur | Patti | Tarn Taran | 2.5 | PR-126 | 2026-10-19 |
| 3 | Sukhwinder Singh | Harike | Ferozepur | 6.0 | Pusa-44 | 2026-10-20 |
| 4 | Paramjit Singh | Zira | Ferozepur | 3.5 | Basmati | 2026-10-22 |
| 5 | Kulwant Kaur | Makhu | Ferozepur | 2.0 | PR-126 | 2026-10-17 |
| 6 | Balwinder Singh | Kartarpur | Jalandhar | 5.0 | PR-126 | 2026-10-21 |
| 7 | Harjinder Singh | Nakodar | Jalandhar | 3.0 | Pusa-44 | 2026-10-23 |
| 8 | Manpreet Singh | Khanna | Ludhiana | 4.5 | PR-126 | 2026-10-18 |
| 9 | Rajwinder Kaur | Raikot | Ludhiana | 2.5 | PR-126 | 2026-10-20 |
| 10 | Satnam Singh | Moga | Moga | 3.0 | Pusa-44 | 2026-10-19 |
| 11 | Daljit Singh | Nihal Singh Wala | Moga | 5.5 | PR-126 | 2026-10-21 |
| 12 | Gurmail Singh | Jalalabad | Fazilka | 4.0 | Basmati | 2026-10-22 |
| 13 | Avtar Singh | Abohar | Fazilka | 6.5 | PR-126 | 2026-10-17 |
| 14 | Lakhvir Kaur | Malout | Sri Muktsar Sahib | 3.0 | PR-126 | 2026-10-18 |
| 15 | Jaswant Singh | Lambi | Sri Muktsar Sahib | 2.0 | Pusa-44 | 2026-10-20 |
| 16 | Ranjit Singh | Hansi | Hisar | 4.0 | Pusa-44 | 2026-10-23 |
| 17 | Ramesh Kumar | Tohana | Fatehabad | 3.5 | Pusa-44 | 2026-10-19 |
| 18 | Sunder Lal | Narwana | Jind | 2.5 | Pusa-44 | 2026-10-21 |
| 19 | Dharamvir Singh | Kaithal | Kaithal | 4.5 | PR-126 | 2026-10-18 |
| 20 | Ram Singh | Shamli | Shamli | 3.0 | PR-126 | 2026-10-22 |

*(lat/lon to be filled from approximate village centroids — use OpenStreetMap Nominatim.)*

### Simulated buyers (5) — SIMULATED

| # | Business name | Type | District | Price/tonne (₹) | Min batch (t) | Window |
|---|---|---|---|---|---|---|
| 1 | Punjab Biogas Cooperative | biogas | Ludhiana | 1,200 | 50 | Oct 15 – Nov 15 |
| 2 | Ferozepur Brick Kiln | brick_kiln | Ferozepur | 900 | 30 | Oct 15 – Nov 10 |
| 3 | GreenFuel Pellets Pvt Ltd | pellet | Jalandhar | 1,100 | 40 | Oct 18 – Nov 20 |
| 4 | Agri Energy Ltd | biogas | Hisar | 1,150 | 60 | Oct 20 – Nov 25 |
| 5 | Haryana Agri Power | pellet | Jind | 1,050 | 25 | Oct 17 – Nov 15 |

*(All prices are SIMULATED and do not reflect actual market rates.)*

### Simulated machines (6) — SIMULATED

| # | Type | Owner | District | Capacity (acres/day) | Price (₹/acre) |
|---|---|---|---|---|---|
| 1 | SMAM straw mgmt | Avtar Machinery | Tarn Taran | 8 | 800 |
| 2 | Baler | Kisan Services | Ferozepur | 10 | 750 |
| 3 | SMAM straw mgmt | Singh Agri Works | Ludhiana | 8 | 820 |
| 4 | Shredder | Punjab Agri | Jalandhar | 12 | 700 |
| 5 | Baler | Haryana Agri | Hisar | 10 | 780 |
| 6 | SMAM straw mgmt | Jind Machinery | Jind | 8 | 800 |

*(All prices are SIMULATED.)*

### Simulated trucks (5) — SIMULATED

| # | Owner | Home district | Capacity (t) | Rate (₹/t-km) |
|---|---|---|---|---|
| 1 | Gurpreet Transport | Tarn Taran | 10 | 2.5 |
| 2 | Singh Logistics | Ferozepur | 12 | 2.3 |
| 3 | Ludhiana Carriers | Ludhiana | 15 | 2.2 |
| 4 | Haryana Transport Co | Hisar | 10 | 2.4 |
| 5 | Jind Freight | Jind | 12 | 2.3 |

*(All rates are SIMULATED and do not reflect actual market rates.)*

---

## §15 Scope Tiers

### MUST-HAVE (hackathon demo, Oct 8–11)

- Voice intake → stubble estimate → matched options (2–3 bundles)
- One-tap booking
- Simulated escrow hold (MockPaymentProvider, clearly labelled)
- Pickup day status screen (machine ETA)
- Weighbridge weight entry by machine owner
- Payment release on actual weight (simulated payout)
- Impact screen (qualitative language only — no invented numbers)
- KVK dashboard: FIRMS hotspot map + booking pipeline list

### SHOULD-HAVE (build if MUST-HAVEs complete by Saturday night)

- Satellite verification result screen (burn_check)
- Kisan Mitra proxy booking (with OTP consent)
- Push notifications (booking status changes)
- Farmer and provider rating screen
- District burn trend chart on KVK dashboard

### CUT-IF-LATE (post-hackathon)

- WhatsApp chat between farmer and machine operator
- Photo-based moisture grading (camera → ML → moisture estimate)
- Razorpay test-mode integration (replace MockPaymentProvider)
- Buyer portal (separate Next.js app)
- Calibration of yield factors from weighbridge data

---

## §16 Risks and Honest Limitations

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Bhashini ASR fails for Punjabi dialects | Medium | High | Fallback to numeric pickers (§12.3); never block the flow |
| OR-Tools finds no feasible match in 10 s | Low | High | Progressive radius relaxation; return "no match found" with next available date estimate |
| SimSat API unavailable on hack day | Medium | Medium | Implement Copernicus CDSE path as backup; FIRMS hotspot map still works |
| llama-server needs GPU not available | Medium | Medium | Use ONNX export with CPU onnxruntime; slower but functional |
| Stubble yield estimates are inaccurate | High | Medium | Show ± range; always label as estimate; weighbridge settles payment |
| Weighbridge data submitted fraudulently | Medium | High | Require ticket photo + ticket number; buyer must confirm; dispute path to KVK |
| Satellite cloud cover prevents verification | High | Low | Return `unclear` result; do not make a false claim; KVK can request ground check |
| Demo data looks unrealistic | Low | Low | All demo data clearly marked SIMULATED on every screen |
| APK exceeds 25 MB | Medium | Low | Enable deferred loading; monitor with `flutter build apk --analyze-size` |
| Battery drain from background location | Low | Low | Request location only when user opens map; no background location polling |

---

## §17 Credits and Code Reuse

All 8 reference repositories were analysed during project planning.
Code from these repositories **may be copied and adapted** into this project with the
written permission of the respective owners. Permission emails are stored by the team
and are not committed to this repository.
See [docs/permissions/README.md](docs/permissions/README.md) for the permission status
of each repository, and [docs/COPIED_CODE.md](docs/COPIED_CODE.md) for a full log of
every file that has been reused or adapted.

| Repo | Owner | License | Relevant contribution |
|---|---|---|---|
| ViridiApp | (see docs/permissions/) | MIT | 5-screen bottom-nav UX for stubble management; booking concept |
| Farmlink | (see docs/permissions/) | No LICENSE (all rights reserved — permission obtained) | Flutter project structure, booking data model, equipment list/detail pattern |
| Lima-App | (see docs/permissions/) | MIT | Booking accept/reject controller pattern; notification on status change |
| miniproject (SIH2022) | (see docs/permissions/) | MIT | Phone OTP + JWT login flow; date-range booking API pattern |
| tractor-rental-backend | (see docs/permissions/) | MIT | Rent model schema; JWT guard pattern; role-based access design |
| tractor-rental-frontend | (see docs/permissions/) | MIT | Redux slice pattern for auth/bookings |
| parali | (see docs/permissions/) | CC-BY-4.0 | Satellite burn detection pipeline (orchestrator/main.py); FIRMS route; VLM prompt |
| rewire-app | (see docs/permissions/) | No LICENSE (all rights reserved — permission obtained) | Escrow/wallet ledger pattern; pickup request status machine; bcrypt+JWT pattern |

---

## §18 4-Day Build Plan (Oct 8–11, 2026)

### Day 1 — Wednesday Oct 8: Foundation

**Backend**
- `flutter create` the app project inside `app/`
- Initialise FastAPI + SQLAlchemy + Alembic; run first migration (all 12 tables)
- Implement OTP send/verify endpoints (Firebase Phone Auth)
- Implement JWT issue + refresh + /auth/me

**App (Flutter)**
- Project creation, package dependencies in pubspec.yaml
- Navigation shell (bottom nav or route stack)
- Splash → OTP login → Language select screens (working, connected to backend)

**Web (KVK dashboard)**
- `npx create-next-app` in `web/kvk-dashboard/`
- FIRMS hotspot map page (adapted from parali repo — first port)

**Deliverable:** A farmer can log in with OTP on a real Android device.
KVK map shows live fire hotspots.

---

### Day 2 — Thursday Oct 9: Core farmer flow

**Backend**
- Farm creation endpoint + PostGIS geometry storage
- Estimate service (§9 formula, CONFIG values)
- Matching engine v1 (greedy, not OR-Tools yet) — returns hardcoded demo offers
- Booking create + escrow hold (MockPaymentProvider)
- Weighbridge submit + confirm endpoints

**App (Flutter)**
- Voice intake screen (SpeechRecognizer + Bhashini fallback)
- 2-question form screen
- Estimate screen
- Options/match screen (2–3 bundle cards)
- Booking confirmation + escrow hold screen
- Pickup status screen

**Deliverable:** End-to-end farmer flow works on device with demo data,
from voice intake through booking confirmation.

---

### Day 3 — Friday Oct 10: Weighbridge + payment + OR-Tools

**Backend**
- Weighbridge record + both-party confirm + dispute path
- Payment release (MockPaymentProvider `release()`)
- Impact log (qualitative only)
- OR-Tools matching engine (replace greedy v1)
- Satellite verification endpoint (satellite.py from parali orchestrator)
- KVK dashboard endpoints (/kvk/hotspots, /kvk/bookings)

**App (Flutter)**
- Weighbridge weight entry screen (machine owner)
- Payment + impact screen (farmer)
- Satellite verification result screen
- Rating screen

**Web (KVK dashboard)**
- Booking pipeline page (/bookings)
- Machine demand view (/machines)

**Deliverable:** Full booking lifecycle works end-to-end on device.
Payment release from weighbridge weight is shown to the farmer.
KVK dashboard shows live bookings and hotspot map.

---

### Day 4 — Saturday Oct 11: Polish, demo data, submission

- Load all 20 simulated farmers, 5 buyers, 6 machines, 5 trucks into DB
- Mark every SIMULATED label clearly in UI
- Record a 3-minute demo video covering the full farmer flow
- Test on a real low-end Android device (target: ≤ 2 GB RAM)
- Measure APK size (`flutter build apk --analyze-size`); reduce if > 25 MB
- Write the hackathon project description (use §1 text)
- Final README.md at root with team name, problem, screenshots, and build instructions
- Submit by 11:59 PM (IST)

**Buffer tasks (if ahead of schedule):**
- Kisan Mitra proxy flow
- Push notifications
- Farmer + provider rating
