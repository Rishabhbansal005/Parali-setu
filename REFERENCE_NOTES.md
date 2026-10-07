# REFERENCE_NOTES.md — ParaliSetu Hackathon

> **Purpose:** Deep analysis of all 8 reference repositories.
> Code was read directly; READMEs were cross-checked against actual source files.
>
> **Folder name mapping** (ZIPs unpacked with nested same-name folders):
> - Farmlink-main/Farmlink-main/ -> **Farmlink**
> - Lima-App-main/ -> **Lima-App**
> - ViridiApp-main/ -> **ViridiApp**
> - miniproject-master/miniproject-master/ -> **SIH2022**
> - tractor-rental-backend-main/ -> **tractor-rental-backend**
> - tractor-rental-frontend-main/ -> **tractor-rental-frontend**
> - parali-main/parali-main/ -> **parali**
> - rewire-app-main/rewire-app-main/ -> **rewire-app**

---

## 1. ViridiApp

### 1.1 What it does / Tech stack

Android native app (Java + Kotlin, Firebase Realtime Database + Firebase Auth) for stubble management. Five features through a bottom-navigation bar:

| Screen | Purpose |
|---|---|
| Sell Stubble | Farmer posts stubble for pickup/sale |
| Buy Stubble | Buyer searches and orders stubble |
| Book Machine | Two ImageView buttons (shipping vehicle / stubble remover) |
| Craft Market | E-commerce for stubble-derived handicraft products |
| Learn Skills | YouTube video player with educational content |

Auth: phone-number + password stored in Firebase Realtime DB **without** Firebase Phone Auth OTP. `SignUpActivity.java` imports `PhoneAuthProvider` and calls `verifyPhoneNumber()` at registration, but **login** uses a plain phone + password check against the Realtime DB node. Password stored **in plain text**.

### 1.2 Parali / stubble relevance

**YES - direct.** Specifically about paddy stubble burning in India. The README cites stubble burning and air pollution as the problem. Concept-level alignment is very high.

### 1.3 Key feature analysis

| Feature | Status / Notes |
|---|---|
| Login / OTP | Phone + plaintext password. PhoneAuth only wired at signup, not login. |
| Booking / scheduling | `BookActivity.java`: two buttons both route to `DemoActivity` (empty stub). **No booking logic whatsoever.** |
| Payments | None. Cart total calculated in-memory only. |
| Ratings | None in code; README mentions it conceptually. |
| Notifications | None in code. |
| Chat | None in code. |

### 1.4 Ideas worth re-implementing

- **5-section bottom nav** (Buy / Sell / Book / Learn / Craft) - good UX skeleton for a farmer-facing app.
- The concept of "book a stubble-removal machine + shipping vehicle together" maps directly to ParaliSetu core flow (even though the code is a stub).
- `CartActivity.java` shows how Firebase Realtime DB can hold a simple order record with item + quantity.

### 1.5 Weaknesses / bugs / things to avoid

- `BookActivity.java` is **entirely a placeholder** - both buttons open `DemoActivity` which only sets an empty layout.
- **Plaintext passwords** in Firebase Realtime DB - critical security flaw; never replicate.
- `LoginActivity` does `userData.getPassword().equals(password)` directly - no hashing.
- No geo-matching; no time-window logic.
- `google-services.json` with live Firebase keys committed to the repo.

### 1.6 License

**MIT** (stated in README; links to MIT license on GitHub).

### 1.7 Runnable as-is?

**Mostly no.** Needs a working Firebase project + YouTube API key + a booking backend (which does not exist in this repo).

---

## 2. Farmlink

### 2.1 What it does / Tech stack

Flutter app (Dart, Firebase Firestore + Firebase Auth) for renting agricultural equipment in **Kenya** (prices in KES). Targets farmers as renters and equipment owners as listers.

Key screens: `onboarding.dart`, `login_screen.dart`, `register_page.dart`, `equipment_list_screen.dart`, `equipment_details.dart`, `checkout_screen.dart`, `bookings_screen.dart`, `order_screen.dart`, `in_app_chat_screen.dart`, `profile_screen.dart`.

Payment: **M-Pesa** (`mpesa_flutter_plugin`).
Chat: **Kommunicate** (`kommunicate_flutter` - third-party SaaS SDK).
Maps: `google_maps_flutter`. Auth: email/password via `firebase_auth`.

### 2.2 Parali / stubble relevance

**NO.** Generic equipment rental for Kenyan farmers. No stubble / parali content anywhere in code or README.

### 2.3 Key feature analysis

| Feature | Status / Notes |
|---|---|
| Login / OTP | Email + password only. Phone field captured at signup but no OTP flow. |
| Booking / scheduling | **Implemented.** `BookingManager.saveBookingDetails()` writes `{equipmentId, pickUp, dropOff, landSize, totalAmount, duration, rate, date}` to Firestore. Full booking form in `checkout_screen.dart`. |
| Payments | M-Pesa only - inapplicable to India. No escrow. |
| Ratings | `flutter_rating_bar` widget shown; `onRatingUpdate` callback is **empty** - ratings never saved. |
| Notifications | None implemented. |
| Chat | Kommunicate SDK - paid, requires API key; not self-hosted. |

### 2.4 Ideas worth re-implementing

- **Booking data model** in `booking_manager.dart`: `{userId, equipmentId, pickUp, dropOff, landSize, totalAmount, duration, rate, date}` - maps cleanly to our `{farmerId, machineId, truckId, fieldSizeAcres, estimatedWeight, windowStart, windowEnd}`.
- `checkout_screen.dart` auto-calculates total from `landSize x rate` via `onChanged` in real time - reuse pattern for our stubble-quantity to price estimation.
- **Flutter project structure** (screens / services / models / components) is well-organised - use as skeleton for ParaliSetu app.
- `equipment_list_screen` + `equipment_details` browsing pattern.

### 2.5 Weaknesses / bugs / things to avoid

- Rating callback is empty - do not copy.
- Payment is M-Pesa only - replace with Razorpay.
- Chat is Kommunicate (paid SaaS, ~$50/month) - avoid; use Firebase Realtime DB instead.
- `"Location: Juja Farm"` **hardcoded** as a string in `checkout_screen.dart` line 127.
- `date` field is `DateTime.now().toString()` - no start/end window support.
- Firebase and Google Maps keys required.

### 2.6 License

**No LICENSE file.** Default copyright - all rights reserved. Use ideas/patterns only; do not copy code verbatim.

### 2.7 Runnable as-is?

**No.** Needs valid Firebase project, Google Maps key, Kommunicate API key, M-Pesa credentials.

---

## 3. Lima-App (Tractor Hailing Web App)

### 3.1 What it does / Tech stack

Laravel 10 + MySQL web app for booking tractors. Stack: PHP/Laravel 10, Blade templates, MySQL, Tailwind CSS v3, Pusher (real-time), Vite.

Controllers: `HomeController`, `ProductController`, `SellerController`, `UserController`, `BookingController`.
Models: `Booking` (`user_id, product_id, date, time, location, instructions, status`), `Product`, `User`.
Notifications: `TractorBookingNotification` class used in `BookingController.accept()` / `reject()`.

### 3.2 Parali / stubble relevance

**NO.** Generic tractor rental/hailing platform; no stubble logic.

### 3.3 Key feature analysis

| Feature | Status / Notes |
|---|---|
| Login / OTP | Laravel Breeze - standard email/password + "verified" middleware. No OTP. |
| Booking / scheduling | Partially implemented. `Booking` model has `status` field. `BookingController.accept()` and `reject()` dispatch notifications. No `store()` method visible - creation flow may be incomplete. |
| Payments | Planned but **not implemented**. No payment model or route. |
| Ratings | None in code. |
| Notifications | Partial - `TractorBookingNotification` sent on accept/reject. |
| Chat | None. |
| GPS / real-time | Planned via Pusher - not implemented. |

### 3.4 Ideas worth re-implementing

- `BookingController.accept()` / `reject()` with `Notification::send()` - clean FSM pattern, replicable in FastAPI.
- Booking status machine (`pending -> accepted -> rejected`) - extend to `confirmed -> in_progress -> weighed -> settled`.

### 3.5 Weaknesses / bugs / things to avoid

- Most README features are **not implemented** in code (GPS, payments, ratings are README-only).
- Laravel/PHP incompatible with our Python FastAPI plan - reference only.
- Single `date` + `time` fields - no date-range / harvest-window support.
- Booking creation (`store()`) appears missing from the viewed controller code.

### 3.6 License

**MIT** (stated in README; Laravel scaffold is MIT).

### 3.7 Runnable as-is?

**No.** Needs PHP 8.1+, Composer, MySQL, .env keys. Booking creation flow appears incomplete.

---

## 4. SIH2022 (Team Gryffindor -- Krishi Sadhan)

### 4.1 What it does / Tech stack

Smart India Hackathon 2022 (Problem DB887 - Ministry of Skill Development). Web platform for renting agricultural equipment during off-season.

**This ZIP contains frontend only** (master branch). The backend was a separate Django + DRF + PostgreSQL branch not included here. The frontend hits a dead Heroku URL: `https://krishi-sadhan-app.herokuapp.com`.

Frontend: React 17, Redux, React Router, Tailwind CSS, Axios, js-cookie, Netlify.

Pages: `Login.js` (email+password OR phone+OTP), `Register.js`, `bookingRequest/BookingRequest.jsx`, `bookingHistory/`, `chat/`, `dashboard/`, `addProduct/`, `feedback/`, `cancellationPage/`.

### 4.2 Parali / stubble relevance

**NO.** Generic agricultural equipment rental; no stubble / burn-detection component.

### 4.3 Key feature analysis

| Feature | Status / Notes |
|---|---|
| Login / OTP | **Both email+password AND phone+OTP fully implemented.** `postLoginDataPhone()` -> `verifyOtpLogin()`. JWT access + refresh tokens stored in `js-cookie`. |
| Booking / scheduling | **Implemented (frontend).** `createBooking()` posts `{equipment, start_date, end_date, start_time, end_time}`. `BookingRequest.jsx` is 17 KB - full date-range booking form. Owner can accept/reject via `BookingUpdate()` PATCH. |
| Payments | None. |
| Ratings | `feedback/` page exists - API hits dead Heroku, untestable. |
| Notifications | None visible in frontend code. |
| Chat | `chat/` directory + `ChatSupport` component - backend dead. |

### 4.4 Ideas worth re-implementing

- **Phone OTP login flow** - the most complete across all 8 repos. `postLoginDataPhone -> verifyOtpLogin` with JWT cookie storage is exactly the pattern ParaliSetu needs.
- **Date-range booking** (`start_date, end_date, start_time, end_time`) - maps directly to harvest-window booking.
- `verify-otp` UI component - reusable pattern for the farmer OTP screen.
- `BookingUpdate()` PATCH - clean owner-side accept/reject.

### 4.5 Weaknesses / bugs / things to avoid

- Backend not in this ZIP; Heroku URL dead - nothing runnable end-to-end.
- **Bug in `bookingAPI.js` line 89:** Authorization header has extra surrounding quotes - token sent malformed.
- No payment integration.
- ML branch (`vociecallapi`) not in this ZIP.

### 4.6 License

**MIT License** (full text in `LICENSE` file - Copyright 2022 Rudrakshi).

### 4.7 Runnable as-is?

**No.** Frontend starts with `npm install && npm start` but all API calls fail (dead backend).

---

## 5. tractor-rental-backend

### 5.1 What it does / Tech stack

Ruby on Rails 7 + PostgreSQL JSON API for tractor rental. Three models: `User` (Devise + JWT, `jti` column), `Tractor`, `Rent`. Versioned API: `/api/v1/`. Auth: Devise + devise-jwt. Authorization: CanCanCan. CORS: rack-cors.

DB schema (from `db/schema.rb`):
- `rents`: `user_id, tractor_id, estimated_time, total_costs, new_farm (bool), farm_size, rent_date`
- `tractors`: `photo, name, description, price, new_farm_price, completion, demand`
- `users`: `name, role (int), email, encrypted_password, jti`

### 5.2 Parali / stubble relevance

**NO.** Generic tractor rental; no stubble or India-specific focus.

### 5.3 Key feature analysis

| Feature | Status / Notes |
|---|---|
| Login / OTP | Email + password with JWT (Devise). No OTP. |
| Booking / scheduling | **Fully implemented.** Full CRUD `RentsController` - scoped to authenticated user via `before_action :authenticate_user!`. |
| Payments | None. |
| Ratings | None. |
| Notifications | None. |
| Chat | None. |

### 5.4 Ideas worth re-implementing

- `before_action :authenticate_user!` guard - replicate as `Depends(get_current_user)` in FastAPI.
- `after_save :update_demand` callback - simple popularity counter for machine demand tracking.
- CanCanCan roles pattern - template for our Farmer / MachineOperator / TruckDriver / Buyer / KVKAdmin roles.
- Clean `farm_size + estimated_time + total_costs` booking schema.

### 5.5 Weaknesses / bugs / things to avoid

- Rails/Ruby incompatible with our Python plan - reference only.
- Single `rent_date` - no date-range window.
- **No double-booking check** - same tractor can be booked by two users on the same date.
- `role` column defaults to integer `866933` - looks like an accidental default value.
- No geospatial matching (no location on `Tractor` or `Rent`).

### 5.6 License

**MIT** (stated in README).

### 5.7 Runnable as-is?

**Mostly yes** (local demo). `bundle install` + `rails db:migrate` + `rails db:seed` + `rails server`. No external API keys needed.

---

## 6. tractor-rental-frontend

### 6.1 What it does / Tech stack

React 17 + Redux + Axios frontend for `tractor-rental-backend`. Netlify deployment. Pages: `Home`, `TractorsList`, `TractorDetails`, `Login`, `Signup`, `MyRent`, `UpdateProfile`, `NotFound`.

### 6.2 Parali / stubble relevance

**NO.** Generic tractor rental frontend.

### 6.3 Key feature analysis

| Feature | Status / Notes |
|---|---|
| Login / OTP | Email + password; Redux-managed auth state. |
| Booking / scheduling | Tractor detail page has a booking form (single date + farm size). |
| Payments | None. |
| Ratings | None. |
| Notifications | None. |
| Chat | None. |

### 6.4 Ideas worth re-implementing

- Redux slice pattern for auth + bookings - template for a React-based KVK dashboard.
- `TractorsList -> TractorDetails -> booking form` navigation - UX reference.

### 6.5 Weaknesses / bugs / things to avoid

- API base URL hardcoded to `localhost:3000` - no `.env` configuration.
- Single-date booking; no geospatial matching.

### 6.6 License

**MIT** (stated in README).

### 6.7 Runnable as-is?

**Yes** (frontend), but all API calls fail without the Rails backend running locally.

---

## 7. parali (Satellite Crop Burn Detection)

### 7.1 What it does / Tech stack

**The most technically sophisticated repo in the set.** Next.js 16 + FastAPI platform for real-time paddy stubble burn detection using Sentinel-2 satellite imagery and a fine-tuned Vision Language Model. **Built for Liquid Space Hack, May 2026.**

Stack: Next.js 16 (App Router), React 19, TypeScript, Tailwind CSS v4, Framer Motion, MapLibre GL, Recharts, FastAPI (Python 3.11+), llama-server (GGUF runtime).

Four pages: `/` (landing), `/dashboard` (Sentinel-2 map), `/monitor` (live NASA FIRMS hotspots), `/trends` (district burn trends 2020-2026).

**Data pipeline:**
1. User clicks map point (lat/lon)
2. `POST /api/analyse` -> Copernicus CDSE auth -> fetches RGB (B4-B3-B2) + SWIR (B12-B8-B4) composites for nearest cloud-free Sentinel-2 pass (5-day lookback via SimSat API)
3. Both images (base64) -> LFM2.5-VL-450M via llama-server (OpenAI-compatible API)
4. VLM returns structured JSON: `{burn_detected, burn_severity, burn_fraction_estimate, burn_freshness, active_smoke_visible, vegetation_phase, image_quality_limited, notes}`
5. `GET /api/firms?days=3` -> dual-satellite VIIRS CSV (SNPP + NOAA-20) from NASA FIRMS -> state-level fire counts

**Model:** Fine-tuned LFM2.5-VL-450M (LoRA rank 32) on 1,370 Sentinel-2 tile pairs (5 km x 5 km, 55 districts, 5 Indian states). Accuracy: 74.8% vs 21.9% base. ONNX export: `munish0838/parali-v1-onnx` on HuggingFace. Training: ~16 min on RTX A4000.

**Alternate backend:** `orchestrator/main.py` - standalone FastAPI implementation (~200 lines, 5 deps: `fastapi, uvicorn, requests, openai, pydantic`).

### 7.2 Parali / stubble relevance

**YES - direct and the most relevant repo.** Specifically targets Punjab/Haryana/UP/MP/Rajasthan paddy stubble burn detection during Oct-Nov. Same districts, same time window, same satellite sources as ParaliSetu post-transaction verification layer.

### 7.3 Key feature analysis -- burn-detection pipeline

| Component | Details |
|---|---|
| **Inputs** | `{lat, lon, district}` from user click |
| **Imagery source** | Copernicus CDSE (free account: `CDSE_CLIENT_ID` + `CDSE_CLIENT_SECRET`) or DPhi SimSat API |
| **Satellite** | Sentinel-2 L2A, 10 m resolution, 5-day revisit |
| **Bands** | RGB (B4-B3-B2) + SWIR composite (B12-B8-B4) |
| **ML model** | LFM2.5-VL-450M fine-tuned, served via llama-server (`LLAMA_URL`) |
| **FIRMS key** | `FIRMS_MAP_KEY` - free from NASA |
| **Outputs** | `burn_detected`, `burn_severity`, `burn_fraction_estimate`, `burn_freshness`, `active_smoke_visible`, `vegetation_phase`, `latency_s` |
| **Login** | None - public dashboard |
| **Payments** | None |
| **Chat** | None |

### 7.4 Ideas worth re-implementing

- **`orchestrator/main.py`** is almost directly deployable as our satellite verification microservice. Port to `backend/app/services/satellite.py` - expose as `POST /verify-burn` accepting a field polygon instead of a single point.
- **`GET /api/firms/route.ts`** - production-quality dual-satellite VIIRS fetch with confidence filter and FRP sum. Drop directly into the KVK dashboard.
- **VLM system + user prompt** - carefully engineered for Sentinel-2 SWIR interpretation. Reuse verbatim as the basis for our verification prompt.
- **ONNX export** (`munish0838/parali-v1-onnx`) - runs without llama-server using `onnxruntime`; better for hackathon deploy if no GPU is available.
- **State bounding boxes** in `firms/route.ts` - Punjab, Haryana, UP, MP, Rajasthan, Delhi - exactly our geography.

### 7.5 Weaknesses / bugs / things to avoid

- Imagery path depends on **DPhi SimSat API** - a hackathon simulation service, not a production data source. Verify it is still live; for production use the real Copernicus CDSE client library.
- **Inconsistency between implementations:** `/api/analyse` Next.js route sets `window_seconds = 730 * 24 * 60 * 60` (2 years lookback) vs `orchestrator/main.py` which uses 5 days. Use 5 days.
- `llama-server` needs at least 8 GB VRAM GPU. If unavailable, use ONNX + `onnxruntime` (CPU-capable).
- No user auth, no per-field record linkage - this is a public dashboard, not a booking-linked system.
- VIIRS is 375 m resolution - misses individual small fields (< 2 ha). Sentinel-2 SWIR at 10 m is the correct tool for field-level verification (which this app correctly uses).

### 7.6 License

**CC-BY-4.0** (stated in README model card). No separate `LICENSE` file for the web code - treat entire repo as CC-BY-4.0.

### 7.7 Runnable as-is?

**Partial.** Frontend + FIRMS tab works with only `FIRMS_MAP_KEY` (free, sign up at NASA). Full imagery analysis needs `CDSE_CLIENT_ID/SECRET` (free Copernicus account) + SimSat service running + llama-server with fine-tuned model loaded.

---

## 8. rewire-app

### 8.1 What it does / Tech stack

Full-stack monorepo for e-waste collection and recycling. Connects households with CPCB-authorised recyclers.

Frontend: React + Vite + React Router + Vanilla CSS + Stripe Elements.
Backend: Node.js + Express + MongoDB (Mongoose) + JWT (bcrypt) + Stripe SDK.
Deployment: Vercel (serverless functions).

Models:
- `User`: `{username, email, password (bcrypt), role: user|recycler, points, plan: Starter|Pro|Enterprise}`
- `PickupRequest`: `{userId, wasteType, weight, area, estimatedPoints, status: pending|completed}`
- `Transaction`: `{userId, pointsRedeemed, cashValue}`

Routes: `authRoutes` (register/login), `userRoutes` (profile, request-pickup, pickups, redeem), `recyclerRoutes` (partner dashboard), `paymentRoutes` (`POST /create-intent` - Stripe).

### 8.2 Parali / stubble relevance

**NO.** E-waste (electronics), not agricultural waste. Domain, actors, and tech all differ.

### 8.3 Key feature analysis

| Feature | Status / Notes |
|---|---|
| Login / OTP | Email + password with JWT; bcrypt via `bcryptjs`. No OTP. |
| Booking / scheduling | `POST /request-pickup` creates a `PickupRequest`. Status: `pending -> completed`. No time-window. |
| Payments | Stripe `POST /payment/create-intent` - creates intent only. No escrow, no conditional release, no webhook. |
| Ratings | None. |
| Notifications | None. |
| Chat | None. |
| Points / wallet | `user.points` + `Transaction` ledger. `POST /user/redeem` deducts points and creates a transaction record. |

### 8.4 Ideas worth re-implementing

- **Points/wallet ledger pattern** (`User.points` + `Transaction.cashValue`) - template for our escrow. Replace "points" with "INR held in escrow" and "cashValue" with "weighbridge-settled payout".
- **`PickupRequest` status machine** (`pending -> completed`) - extend to `pending -> matched -> confirmed -> in_progress -> weighed -> settled`.
- **bcrypt + JWT** auth pattern - translate to Python with `passlib[bcrypt]` + `python-jose`.
- **Stripe PaymentIntent pattern** (server creates intent, client confirms) - conceptual basis for Razorpay order + capture.
- Two-role model (`user` / `recycler`) - template for our multi-role system.

### 8.5 Weaknesses / bugs / things to avoid

- Stripe not available for Indian merchants in most cases - use Razorpay.
- Payment is incomplete: no webhook, no capture, no refund, no escrow hold/release logic.
- MongoDB is a poor fit for relational booking data - use PostgreSQL as planned.
- `estimatedPoints` is set by the **client** in the request body - a server-side trust issue. Our weighbridge weight must be server-authoritative.

### 8.6 License

**No LICENSE file.** Default copyright applies.

### 8.7 Runnable as-is?

**Yes** (local dev). Needs Node 18+, MongoDB URI, JWT secret, Stripe secret key. Live demo may still be at `https://rewire-app1.vercel.app/`.

---

## Task 2 -- Cross-Repo Summary

### 2a. Which repo helps with which part of ParaliSetu

| ParaliSetu Feature | Relevant Repos | Confidence |
|---|---|---|
| Phone / OTP auth for farmers | **SIH2022** (full OTP flow, JWT), **ViridiApp** (Firebase Phone Auth at signup) | High |
| Equipment listing and browsing | **Farmlink** (Flutter), **SIH2022** (React), **tractor-rental-frontend** (React) | High |
| Booking with date-range window | **SIH2022** (start/end date+time fields) | Medium |
| Booking accept/reject FSM | **Lima-App** (BookingController), **SIH2022** (BookingUpdate PATCH) | High |
| Payment / wallet / ledger | **rewire-app** (points ledger + Stripe intent pattern) | Medium |
| Notifications on booking status | **Lima-App** (TractorBookingNotification) | Low |
| Stubble buy/sell marketplace | **ViridiApp** (concept + screen layout only) | Concept only |
| Satellite burn detection | **parali** (FIRMS + Sentinel-2 + VLM, production-quality) | High |
| District burn hotspot map (KVK) | **parali** (MapLibre + FIRMS route) | High |
| FastAPI backend structure | **parali** (orchestrator/main.py) | High |
| KVK / admin dashboard | **SIH2022** (dashboard page), **parali** (/dashboard route) | Medium |
| Chat between farmer and operator | **Farmlink** (Kommunicate, 3rd-party), **SIH2022** (chat page, dead backend) | Low - neither self-contained |
| Ratings / feedback | **SIH2022** (feedback page, dead), **Farmlink** (widget not wired) | None - all incomplete |

### 2b. What NO repo covers

The following critical ParaliSetu features are **completely absent** from all 8 repos:

1. **Time-window matching of machine + truck + buyer simultaneously.** All booking systems are 1-farmer <-> 1-machine. The constraint-satisfaction problem (machine available in farmer 10-15 day window AND a truck AND a committed buyer, all overlapping) requires OR-Tools or a greedy interval-overlap algorithm. **This is the biggest original engineering challenge.**

2. **Weighbridge-based escrow settlement.** rewire-app has a Stripe PaymentIntent and a points ledger, but no conditional release based on an external physical measurement. "Hold payment at booking; release only after weighbridge weight is submitted and verified" requires: Razorpay `capture_later`, a `weighbridge_weight_kg` event from the operator, a dispute window, and auto-release. **Completely absent from all repos.**

3. **Satellite verification of a specific named field.** parali detects burn scars on a public click-on-map dashboard - it has no linkage to a farmer record, a booking, or a payment. The pipeline `booking.field_polygon -> POST /verify -> burn_detected == false -> mark verified_no_burn` is new engineering. **Completely absent.**

4. **Voice-first Hindi/Punjabi input.** Not attempted in any repo. All apps are English text-form-first. ParaliSetu needs Android SpeechRecognizer (or Bhashini ASR) with NLU to extract intent from "meri 5 acre zameen hai, 20 October tak kaam chahiye." **Completely absent.**

5. **Stubble quantity estimation from land size.** Farmlink calculates cost from land area, but no repo converts "X acres of paddy" to "Y tonnes of stubble" using an agronomic yield factor (Indian average: ~2.0-2.5 t/acre for paddy). **Absent from all repos.**

6. **Low-network / offline mode.** All apps assume reliable internet. None implement offline-first caching, retry queues, or SMS fallback for rural 2G areas. **Absent from all repos.**

7. **Kisan Mitra proxy booking.** The delegated-auth pattern (agent logs in, selects farmer from a list, books on their behalf) is absent from all repos. **Absent from all repos.**

> **Confirmation of your expectation:** You correctly anticipated items 1-3.
> Items 4-7 are additional gaps discovered during analysis.

### 2c. Flutter vs Native Kotlin/Compose -- hackathon recommendation

**I cannot make a final recommendation without knowing what you already know.** Here is the honest trade-off for a 4-day sprint:

| Criterion | Flutter | Native Kotlin/Compose |
|---|---|---|
| Single codebase (Android + iOS) | Yes | Android only |
| Hot reload during hackathon | Excellent | Good (Compose preview) |
| Voice input (SpeechRecognizer) | `speech_to_text` plugin | Native Android API (direct) |
| Firebase integration | First-class (`firebase_flutter`) | First-class |
| Razorpay SDK | `razorpay_flutter` plugin exists | Native SDK |
| Reference code in this set | **Farmlink** (Flutter, same domain) | None |
| State management learning curve | Medium (Provider / Riverpod) | Medium (ViewModel / StateFlow) |
| Low-end Android performance | Skia renderer - good | Native - slightly better |
| UI iteration speed in 4 days | Faster | Slower (more boilerplate) |

**Tentative lean: Flutter**, because Farmlink is a ready Flutter skeleton in the exact problem domain, and `speech_to_text` + `razorpay_flutter` + `google_maps_flutter` all have stable pub.dev plugins. Hot reload cuts iteration time drastically in a 4-day sprint.

**However: please tell me which you know better - Flutter/Dart or Kotlin/Compose - before this is finalised.**

---

## Task 3 -- Proposed Project Folder Structure

> Proposal only. No folders or files will be created until you approve.

```
parali-setu/                          <- project root (this folder)
|
+-- REFERENCE_NOTES.md                <- this file
+-- SPEC.md                           <- (to create) high-level product specification
|
+-- backend/                          <- Python FastAPI + PostgreSQL/PostGIS
|   +-- app/
|   |   +-- api/                      <- route handlers
|   |   |   +-- auth.py               <- OTP send/verify, JWT issue
|   |   |   +-- farmers.py            <- farmer profile + field polygon
|   |   |   +-- machines.py           <- machine/truck listing + availability
|   |   |   +-- bookings.py           <- booking create/update/FSM
|   |   |   +-- escrow.py             <- weighbridge event + payment release
|   |   |   +-- verify.py             <- satellite burn verification
|   |   |   +-- kvk.py               <- KVK/FPO dashboard endpoints
|   |   +-- models/                   <- SQLAlchemy ORM models
|   |   +-- schemas/                  <- Pydantic request/response schemas
|   |   +-- services/
|   |   |   +-- matching.py           <- OR-Tools time-window matching
|   |   |   +-- weighbridge.py        <- weighbridge event processing + escrow release
|   |   |   +-- satellite.py          <- Sentinel-2 / FIRMS burn verification (from parali)
|   |   |   +-- razorpay.py           <- payment hold / capture / split payout
|   |   |   +-- notifications.py      <- SMS (MSG91) + Firebase push
|   |   +-- core/
|   |   |   +-- config.py             <- pydantic-settings, env vars
|   |   |   +-- database.py           <- SQLAlchemy session factory
|   |   |   +-- security.py           <- JWT + OTP helpers
|   |   +-- main.py                   <- FastAPI app entry point + CORS
|   +-- alembic/                      <- DB migrations
|   +-- tests/
|   +-- requirements.txt
|   +-- .env.example
|
+-- app/                              <- Android app (Flutter or Kotlin -- TBD)
|   |                                 <- Flutter: pubspec.yaml, lib/, android/, assets/
|   |                                 <- Kotlin: app/src/main/java/, res/, gradle/
|   +-- README.md
|
+-- web/                              <- Next.js dashboards
|   +-- kvk-dashboard/                <- KVK/FPO admin portal
|   |   +-- src/app/
|   |   |   +-- map/                  <- MapLibre + FIRMS hotspot + Sentinel-2 overlay
|   |   |   |                            (adapted from parali /dashboard + /monitor)
|   |   |   +-- machines/             <- machine availability + dispatch view
|   |   |   +-- bookings/             <- booking pipeline tracker
|   |   +-- package.json
|   +-- buyer-portal/                 <- (optional) web UI for biogas/brick buyers
|
+-- docs/
    +-- SPEC.md                       <- full product spec: data models, API contracts,
    |                                    user flows, matching algorithm pseudocode
    +-- ADR/                          <- Architecture Decision Records
    |   +-- 001-flutter-vs-kotlin.md
    |   +-- 002-matching-algorithm.md
    |   +-- 003-escrow-razorpay.md
    +-- wireframes/                   <- exported PNGs (Figma / Excalidraw)
    +-- api/                          <- OpenAPI YAML (auto-exported from FastAPI)
```

| Folder | Contents |
|---|---|
| `backend/` | FastAPI app with 5 core services: OTP auth, booking+matching, weighbridge escrow, satellite verification, notifications. PostgreSQL + PostGIS for geospatial queries. |
| `app/` | Farmer-facing mobile app. Voice-first, Hindi/Punjabi, designed for 2G and low-literacy users. Single-tap booking after voice intake. |
| `web/kvk-dashboard/` | KVK/FPO admin dashboard (Next.js). Live burn hotspot map (reusing parali code). Machine demand heatmap. Booking pipeline tracker. |
| `web/buyer-portal/` | (Optional) Web interface for registered buyers (biogas plants, brick kilns) to set demand, price, and pickup capacity. |
| `docs/` | Full SPEC.md with data models, API contracts, FSM diagrams, matching algorithm pseudocode. ADRs for key decisions. Wireframes. OpenAPI export. |
| `SPEC.md` | Root-level specification - judges-facing summary / pointer to `docs/SPEC.md`. |

---

## Top 5 Most Important Findings

1. **`parali` (repo 7) is the single most valuable reference.** `orchestrator/main.py` is almost directly deployable as our satellite verification microservice. The FIRMS route is production-quality code. The VLM prompt engineering is reusable verbatim. This repo alone saves 2-3 days of satellite integration work.

2. **`SIH2022` (repo 4) has the only complete OTP login flow across all 8 repos.** The `postLoginDataPhone -> verifyOtpLogin` JWT pattern is exactly what ParaliSetu needs. Its booking API is also the only one with proper `start_date / end_date / start_time / end_time` fields.

3. **`Farmlink` (repo 2) is the only Flutter codebase and is in the right problem domain.** Its project structure, Firebase wiring, booking data model, and `landSize x rate` auto-calculation can be used as a skeleton - saving Flutter project setup time in a 4-day sprint.

4. **No repo implements the three hardest ParaliSetu features.** Time-window multi-party matching, weighbridge-conditional escrow release, and satellite-to-booking-record linkage are all original engineering problems. These should be the Thursday-Saturday coding priority.

5. **ViridiApp (repo 1) proves the concept but is nearly all stub code.** `BookActivity.java` is completely empty. The 5-screen stubble UX is a valid design reference, but do not assume any booking or payment logic exists in the code - it does not.

---

## Open Questions Before Next Step

1. **Flutter or Kotlin/Compose?** Which do you know better? This is the most important architectural decision before Thursday.

2. **OTP provider:** Firebase Phone Auth (free, works natively in Flutter) or Twilio/MSG91 (paid, more control, works with any backend)? For a 4-day hackathon, Firebase Phone Auth is simplest if you choose Flutter.

3. **Satellite verification trigger:** Automatic (a cron job calls `/verify-burn` N days after booking closes) or manually triggered by a KVK officer from the dashboard? This affects `services/satellite.py` design.

4. **Buyer type:** Always a registered business (biogas plant / brick kiln) with a fixed address and pre-agreed price, or can another farmer also buy stubble? This affects matching algorithm complexity and the buyer-portal scope.

5. **Hackathon demo scope:** Build a fully working Razorpay test-mode escrow flow, or mock the payment step and focus the demo on voice-intake + matching + satellite dashboard? A mocked escrow with a visible state machine may be more reliable and impressive in 4 days.
