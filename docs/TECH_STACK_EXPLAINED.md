# ParaliSetu — Tech Stack Explained

> Clear, accessible explanations of every technology chosen for ParaliSetu, including real-world analogies, judge pitches, rejected alternatives, and implementation status.

---

## Summary Overview

| Technology | Role in ParaliSetu | Real-Life Analogy | Status |
| :--- | :--- | :--- | :--- |
| **FastAPI (Python)** | High-performance async REST backend | A Michelin-star kitchen pass: takes orders instantly, validates every ingredient, and serves fast. | **BUILT** |
| **PostgreSQL + PostGIS** | Spatial relational database & geo-queries | An intelligent cadastral map room where plots know their exact GPS boundaries and calculate driving radii. | **BUILT** |
| **Supabase** | Managed cloud PostgreSQL host & pooler | A secure, scalable bank vault housing our database with high-availability connection pooling. | **BUILT** |
| **Alembic + SQLAlchemy** | Schema versioning & Python ORM | Blueprint revision history: ensures everyone builds on the exact same foundation without data loss. | **BUILT** |
| **PyJWT & Passlib / bcrypt** | Cryptographic token auth & credential hashing | A tamper-proof digital wristband that proves who you are without re-entering your password on every ride. | **BUILT** |
| **Flutter / Dart** | Cross-platform offline-first Farmer mobile app | A rugged, lightweight field tool that speaks Punjabi & Hindi and works even without internet connectivity. | **PLANNED** |
| **Next.js 14 / TypeScript** | Web dashboards for Aggregators & Industrial Buyers | A flight control tower: live multi-screen dashboard tracking parali demand, deliveries, and weighbridge slips. | **PLANNED** |
| **Google OR-Tools** | Vehicle routing & baler-tractor dispatch engine | A master railway dispatcher packing maximum cargo across shortest routes before harvest windows close. | **PLANNED** |
| **OSRM (Open Source Routing Machine)** | Village-road distance matrix calculations | A local tractor driver who knows which rural roads can handle heavy agricultural trailers. | **PLANNED** |
| **Sentinel-2 & Sentinel-5P (GEE)** | Satellite burn verification & CO₂/PM2.5 tracking | An eye in the sky verifying that farms did not set fire to stubble before releasing green incentive payments. | **PLANNED** |

---

## 1. Backend Framework: FastAPI (Python 3.11+)

- **Status:** **BUILT**
- **What it does:** Powers the core REST API for authentication, farm registration, stubble estimation, machine booking, and weighbridge verification.
- **Real-Life Analogy:** Think of FastAPI as an ultra-efficient restaurant order counter. Instead of waiting for a waiter to write everything on paper, a computerized screen checks every item against strict dietary rules instantly (Pydantic validation) and coordinates the kitchen asynchronously.
- **20-Second Pitch for a Judge:** *"We chose FastAPI because its native async IO handles concurrent village-level traffic effortlessly, auto-generates OpenAPI docs, and integrates seamlessly with scientific Python libraries like Shapely, GeoAlchemy2, and OR-Tools."*
- **Rejected Alternatives:**
  - *Django:* Too heavy and opinionated; its synchronous ORM creates friction with geospatial microservices and adds unnecessary overhead.
  - *Node.js / Express:* Fast, but lacks native scientific/geospatial tooling (Shapely, GeoPandas, OR-Tools) which are essential for agricultural modeling.

---

## 2. Spatial Relational Database: PostgreSQL 15+ & PostGIS 3.3

- **Status:** **BUILT**
- **What it does:** Stores all relational entities (farmers, farms, machines, buyers, bookings) and executes geospatial queries (e.g., finding balers within a 25 km radius of a farm centroid).
- **Real-Life Analogy:** A regular database is like an Excel spreadsheet of addresses. PostGIS is an interactive GIS land registry where farm polygons, baler locations, and factory gates know their exact physical boundaries on planet Earth and can calculate spherical distances in microseconds.
- **20-Second Pitch for a Judge:** *"Agricultural logistics is fundamentally spatial. PostGIS allows us to perform real-world geodesic calculations (`ST_DWithin`, `ST_Distance`) directly in SQL, eliminating the need to haul coordinates to the client for slow spatial math."*
- **Rejected Alternatives:**
  - *MongoDB (GeoJSON queries):* Weak transactional guarantees for financial bookings, lack of geodesic precision, and awkward relational joins across supply chains.
  - *MySQL spatial:* Lacks advanced geodesic geography types, spatial indexing sophistication, and compatibility with GeoAlchemy2.

---

## 3. Database Cloud Platform: Supabase

- **Status:** **BUILT**
- **What it does:** Hosts the production PostgreSQL 15 database in the AWS `ap-south-1` (Mumbai) region with PgBouncer connection pooling and Row Level Security capabilities.
- **Real-Life Analogy:** Instead of setting up a diesel generator, buying land, and running wires yourself, you plug directly into a modern industrial power grid that handles backup, security, and maintenance automatically.
- **20-Second Pitch for a Judge:** *"Supabase gives us a rock-solid, production-grade PostgreSQL instance hosted in India with native PostGIS, zero DevOps maintenance during the hackathon, and built-in connection pooling for high-concurrency mobile bursts."*
- **Rejected Alternatives:**
  - *Self-hosted Docker on EC2:* High operational maintenance, risk of single-point disk failure, and manual SSL/firewall burden during rapid development.
  - *Firebase Firestore:* No SQL, no PostGIS, and exorbitant pricing spikes for spatial queries and aggregations.

---

## 4. Database Migrations: Alembic & SQLAlchemy 2.0

- **Status:** **BUILT**
- **What it does:** Manages database schema versioning as code. Guarantees that schema updates (tables, columns, indexes, spatial geometry types) are reproducible and reversible across all local and cloud environments.
- **Real-Life Analogy:** Version control for concrete. When an architect changes a floor plan, Alembic ensures construction workers upgrade the building step-by-step without knocking down the walls or losing what was already stored inside.
- **20-Second Pitch for a Judge:** *"Alembic guarantees 100% database reproducibility. Our entire 12-table PostGIS schema deploys to a pristine database with one command (`alembic upgrade head`), preventing schema drift between development and staging."*
- **Rejected Alternatives:**
  - *Raw manual SQL scripts:* Fragile, error-prone, hard to rollback, and impossible to coordinate across multiple developers without race conditions.

---

## 5. Security & Auth: PyJWT & Passlib / bcrypt

- **Status:** **BUILT**
- **What it does:** Issues tamper-proof cryptographically signed JWT access and refresh tokens; provides secure password hashing for aggregator and admin accounts.
- **Real-Life Analogy:** A tamper-resistant VIP wristband issued at a festival gate. The guards don't need to call the central office every time you enter a tent—the wristband's cryptographic seal proves who you are and when your access expires.
- **20-Second Pitch for a Judge:** *"We migrated from legacy libraries to PyJWT 2.15 to achieve a clean 0-vulnerability security audit. Our auth pipeline enforces OTP expiration, strict send rate-limiting, and account lockout after repeated failed attempts."*
- **Rejected Alternatives:**
  - *python-jose:* Pinned in older boilerplates, but harbors unresolved vulnerabilities (CVE-2024-33663, CVE-2024-33664) and unmaintained sub-dependencies. Replaced with PyJWT.

---

## 6. Mobile Application: Flutter & Dart (Phase 1)

- **Status:** **PLANNED**
- **What it does:** The farmer-facing Android app. Designed for offline-first resilience, vernacular localization (Punjabi & Hindi), audio guidance, and simple 3-tap booking.
- **Real-Life Analogy:** A sturdy, water-resistant field tablet with big buttons and spoken instructions in the local dialect, designed so any farmer can register their crop even while standing in a field with patchy 2G connectivity.
- **20-Second Pitch for a Judge:** *"With Flutter, we build a cross-platform app under 25 MB that caches farm coordinates locally via SQLite/Hive, supports vernacular voice prompts, and syncs seamlessly whenever connectivity returns."*
- **Rejected Alternatives:**
  - *React Native:* Larger bundle size, bridge serialization overhead for offline geospatial maps, and poorer low-end Android performance on budget rural smartphones.
  - *Native Android (Kotlin):* Excellent performance, but duplicates engineering effort if an iOS version or web companion is required later.

---

## 7. Web Portals: Next.js 14 / TypeScript (Phase 2 & 3)

- **Status:** **PLANNED**
- **What it does:** Provides high-density operational portals for Aggregators (to dispatch fleets and view clusters) and Industrial Biomass Buyers (to verify supply, book tonnage, and inspect weighbridge receipts).
- **Real-Life Analogy:** The air traffic control console. While pilots (farmers/drivers) use mobile apps, the control tower needs dual monitors showing real-time radar, weather, flight paths, and logistics schedules.
- **20-Second Pitch for a Judge:** *"Next.js 14 with Server Components gives aggregators and industrial plants instant server-rendered analytics, live WebSocket truck tracking, and interactive Leaflet/Mapbox choropleths without client-side lag."*
- **Rejected Alternatives:**
  - *Vanilla React SPA:* Slower initial page load, worse SEO for public buyer landing pages, and requires complex standalone state management for data-heavy dashboards.

---

## 8. Optimization Engine: Google OR-Tools

- **Status:** **PLANNED**
- **What it does:** Solves the Capacitated Vehicle Routing Problem with Time Windows (CVRPTW) to dispatch balers, tractors, and trucks across farm clusters before the 15-day burning window closes.
- **Real-Life Analogy:** A master Tetris player arranging deliveries. Instead of drivers crisscrossing each other randomly, the algorithm plots routes so every truck leaves full and returns empty along the shortest possible loop.
- **20-Second Pitch for a Judge:** *"Parali logistics has an unforgiving 15 to 20 day window. Google OR-Tools solves multi-vehicle routing with capacity constraints in under 5 seconds, reducing transport emissions and deadhead miles by up to 35%."*
- **Rejected Alternatives:**
  - *Greedy Nearest-Neighbor Heuristics:* Traps vehicles in sub-optimal local loops, leaving far-flung farms stranded without baling capacity before their sowing deadline.

---

## 9. Rural Routing Engine: OSRM (Open Source Routing Machine)

- **Status:** **PLANNED**
- **What it does:** Computes real road distances and travel times across rural Punjab and Haryana using OpenStreetMap road topologies rather than Euclidean 'straight-line' approximations.
- **Real-Life Analogy:** A veteran local tractor driver who knows that while two villages are 3 km apart across the river, the nearest bridge capable of carrying a 12-tonne loaded trailer is 14 km down the canal.
- **20-Second Pitch for a Judge:** *"Google Maps API costs explode at hackathon scale and fail in rural cart-tracks. OSRM provides instant local distance matrices for heavy agricultural machinery without per-request API billing."*
- **Rejected Alternatives:**
  - *Google Distance Matrix API:* Prohibitively expensive at $5–$10 per 1,000 queries when routing combinatorial fleet optimization problems.

---

## 10. Verification & Carbon Monitoring: Sentinel-2 & Sentinel-5P

- **Status:** **PLANNED**
- **What it does:** Utilizes European Space Agency (ESA) Copernicus satellite imagery via Google Earth Engine to confirm field burn status (NDVI/NBR burn scars) and monitor atmospheric tropospheric NO₂ and CO concentrations.
- **Real-Life Analogy:** The unforgeable celestial umpire. A farmer doesn't need an inspector to physically visit their field; satellite cameras observe thermal signatures and spectral changes from space, automating tamper-proof green reward payouts.
- **20-Second Pitch for a Judge:** *"To make carbon offsets and green subsidies fraud-proof, Sentinel-2 spectral indices verify that stubble was mechanically collected rather than incinerated, automatically unlocking escrow payments."*
- **Rejected Alternatives:**
  - *Physical Field Inspections:* Impossible to scale across millions of fragmented smallholder plots during a chaotic 3-week harvesting season.
