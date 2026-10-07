# ParaliSetu — Architecture Explained

> High-level system architecture, component breakdown, and an end-to-end request walkthrough for ParaliSetu.

---

## 1. System Architecture Diagram

```mermaid
graph TD
    subgraph Clients["Clients Layer"]
        FarmerApp["Farmer Mobile App<br/>(Flutter / Offline-first)<br/><b>[PLANNED]</b>"]
        AggregatorWeb["Aggregator Dashboard<br/>(Next.js 14 Web)<br/><b>[PLANNED]</b>"]
        BuyerWeb["Buyer Portal & B2B<br/>(Next.js 14 Web)<br/><b>[PLANNED]</b>"]
    end

    subgraph Gateway["API & Security Layer (FastAPI) [BUILT]"]
        AuthRouter["/api/v1/auth<br/>(OTP, JWT PyJWT, Rate Limiting)"]
        FarmsRouter["/api/v1/farms<br/>(Farms, Geometry Validation)"]
        EstimateRouter["/api/v1/estimate<br/>(Agronomic Yield & Emissions)"]
        BookingRouter["/api/v1/bookings<br/>(Collection Bookings & Status)"]
    end

    subgraph Services["Core Logic & Engine Services"]
        EstService["Estimation Service<br/>(Crop multipliers, Tonnes, PM2.5/CO₂)<br/><b>[BUILT]</b>"]
        SpatialService["Spatial Query Service<br/>(GeoAlchemy2, Shapely)<br/><b>[BUILT]</b>"]
        RoutingEngine["Dispatch & Routing Engine<br/>(Google OR-Tools + OSRM)<br/><b>[PLANNED]</b>"]
        SatelliteEngine["Satellite Burn Verifier<br/>(Sentinel-2 / GEE API)<br/><b>[PLANNED]</b>"]
    end

    subgraph DataLayer["Persistence & Spatial Store [BUILT]"]
        SupabasePooler["Supabase PgBouncer Pooler<br/>(Port 6543 / 5432, TLS)"]
        PostgresDB[("PostgreSQL 15 (Supabase)<br/>12 Application Tables")]
        PostGIS["PostGIS 3.3 Spatial Engine<br/>(Geometry, ST_DWithin, ST_Distance)"]
    end

    FarmerApp -->|HTTPS / REST| AuthRouter
    FarmerApp -->|HTTPS / REST| FarmsRouter
    FarmerApp -->|HTTPS / REST| EstimateRouter
    AggregatorWeb -->|HTTPS / REST| BookingRouter
    BuyerWeb -->|HTTPS / REST| BookingRouter

    AuthRouter --> PostgresDB
    FarmsRouter --> SpatialService
    EstimateRouter --> EstService
    SpatialService --> SupabasePooler
    SupabasePooler --> PostgresDB
    PostgresDB --- PostGIS
```

---

## 2. Component Status Classification

| Layer / Component | Technology | Implementation Status | Description |
| :--- | :--- | :--- | :--- |
| **Auth API** | FastAPI, PyJWT, Passlib | **BUILT** | Phone OTP verification, token generation, 5-minute lockout on brute force, demo mode toggle. |
| **Farms & Geography API** | FastAPI, GeoAlchemy2, PostGIS | **BUILT** | Register land holdings with WGS84 GPS point coordinates, area in acres, and harvest dates. |
| **Stubble Estimation Service** | Python (ICAR agronomic factors) | **BUILT** | Calculates expected stubble tonnage from crop type + acreage, and potential CO₂, PM2.5, and ash emissions avoided. |
| **Relational & Spatial Database** | PostgreSQL 15 + PostGIS 3.3 | **BUILT** | 12 tables active on Supabase: `users`, `farms`, `buyers`, `machines`, `trucks`, `bookings`, `estimates`, `offers`, `payments`, `burn_checks`, `impact_log`, `weighbridge_records`. |
| **Farmer Mobile Client** | Flutter / Dart | **PLANNED** | Vernacular UI (Hindi/Punjabi), offline SQLite storage, 3-step stubble pickup booking. |
| **Aggregator & Buyer Dashboards** | Next.js 14 / TypeScript | **PLANNED** | Live cluster maps, dispatch schedules, digital weighbridge slips, and escrow payment processing. |
| **Baler & Truck Dispatch Optimizer** | Google OR-Tools + OSRM | **PLANNED** | Solves vehicle routing with capacity and time windows across rural Punjab road networks. |
| **Satellite Burn Detection** | Google Earth Engine / Sentinel-2 | **PLANNED** | Post-harvest spectral verification (NDVI/NBR delta) to ensure stubble was not burnt before releasing green payments. |

---

## 3. End-to-End Request Walkthrough: Login -> Create Farm -> Estimate

This walkthrough details the exact data flow executed across the system during a farmer's primary onboarding journey.

### Step 1: Authentication (`POST /api/v1/auth/otp/send` & `POST /api/v1/auth/otp/verify`) — **[BUILT]**
1. **User Action:** The farmer enters their mobile number `+919810000001` in the mobile client.
2. **API Request (`/auth/otp/send`):**
   - Payload: `{"phone_e164": "+919810000001"}`
   - The backend checks the rate limiter (`OTP_MAX_SENDS_PER_WINDOW`).
   - In production, it sends an SMS via Twilio/Fast2SMS. In demo mode (`DEMO_MODE=true`), it stores a 6-digit mock OTP with a timestamp in-memory.
3. **API Request (`/auth/otp/verify`):**
   - Payload: `{"phone_e164": "+919810000001", "otp": "123456"}`
   - Backend verifies the code, checks that `now - created_at <= OTP_EXPIRY_SECONDS` (300 seconds), and queries the `users` table.
   - If the user does not exist, it inserts a new `User` record with role `farmer`.
   - Backend generates a signed JWT access token using `PyJWT` with subject `user_id` and expiry.
   - Response: `{"access_token": "eyJhbGciOi...", "token_type": "bearer", "role": "farmer"}`

### Step 2: Register Farm Plot (`POST /api/v1/farms/`) — **[BUILT]**
1. **User Action:** The farmer inputs farm details: 4.0 acres of `PR-126` paddy in Bhikhiwind, Tarn Taran, with GPS coordinates `(31.4519° N, 74.9272° E)`.
2. **API Request:**
   - Headers: `Authorization: Bearer eyJhbGciOi...`
   - Payload:
     ```json
     {
       "village": "Bhikhiwind",
       "district": "Tarn Taran",
       "state": "Punjab",
       "area_acres": 4.0,
       "crop_type": "PR-126",
       "sowing_date": "2026-06-20",
       "expected_harvest_date": "2026-10-18",
       "latitude": 31.4519,
       "longitude": 74.9272
     }
     ```
3. **Database Processing:**
   - FastAPI extracts `user_id` from the decoded JWT.
   - GeoAlchemy2 wraps the coordinates into a WGS84 point: `Point(74.9272, 31.4519)` with SRID `4326`.
   - SQLAlchemy executes an `INSERT INTO farms (...) VALUES (...)` in PostgreSQL.
   - Supabase PostGIS stores the `location` column as native binary geometry with spatial index `idx_farms_location`.
   - Response: Returns the saved farm record with unique UUID `id: "3fa85f64-5717-4562-b3fc-2c963f66afa6"`.

### Step 3: Stubble & Environmental Impact Calculation (`POST /api/v1/estimate/`) — **[BUILT]**
1. **User Action:** The farmer taps *"Calculate Stubble & Earnings"* on their screen.
2. **API Request:**
   - Payload:
     ```json
     {
       "crop_type": "PR-126",
       "area_acres": 4.0,
       "harvest_method": "combine_with_super_sms"
     }
     ```
3. **Backend Service Calculation (`app/services/estimation.py`):**
   - Applies the agronomic stubble yield factor for `PR-126` (approx. 2.5 tonnes/acre):
     $$\text{Stubble (tonnes)} = 4.0 \times 2.5 = 10.0 \text{ tonnes}$$
   - Computes avoided atmospheric emissions based on CPCB/ICAR emission factors:
     - $\text{CO}_2 \text{ avoided} = 10.0 \times 1.51 \approx 15.1 \text{ tonnes}$
     - $\text{PM}_{2.5} \text{ avoided} = 10.0 \times 0.003 \approx 30 \text{ kg}$
   - Computes estimated net earnings based on prevailing biomass ex-factory rate:
     $$\text{Estimated Payout} = 10.0 \text{ tonnes} \times ₹1,800/\text{tonne} = ₹18,000$$
   - Records the estimate in `estimates` table.
   - Response:
     ```json
     {
       "estimated_tonnes": 10.0,
       "estimated_bales": 333,
       "estimated_payout_inr": 18000,
       "co2_avoided_tonnes": 15.1,
       "pm25_avoided_kg": 30.0
     }
     ```

### Subsequent Flow: Dispatch, Pickup & Verification — **[PLANNED]**
- **Step 4 (Planned):** Booking is dispatched to the nearest available baler via the Google OR-Tools optimization engine.
- **Step 5 (Planned):** Tractor driver confirms bale collection; truck passes industrial weighbridge (digital slip generated in `weighbridge_records`).
- **Step 6 (Planned):** Satellite Sentinel-2 pass verifies that zero thermal/scar anomalies exist on farm coordinates.
- **Step 7 (Planned):** Direct bank transfer (DBT) is triggered to the farmer's registered UPI/account.
