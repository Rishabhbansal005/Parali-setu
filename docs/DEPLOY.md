# Deploying ParaliSetu Backend on Render (Free Tier)

> A step-by-step student guide to deploying the FastAPI backend on Render with a public HTTPS URL connected to Supabase PostgreSQL + PostGIS.

---

## 1. Prerequisites Checklist

Before you begin, have these ready:
1. Your GitHub repository with the pushed code: `https://github.com/Rishabhbansal005/Parali-setu`
2. A free account on [render.com](https://render.com) (sign up using your GitHub account).
3. Your Supabase PostgreSQL database URL (the same connection string configured in your local `backend/.env`).
4. A secure JWT secret key (you will generate this in Step 3).

> [!IMPORTANT]
> **No Credit Card Required:** Render's free tier for Web Services does **NOT** require a credit card. If you are prompted for billing details, double-check that you selected the **Free** instance type ($0/mo), not Starter or Standard.

---

## 2. Step-by-Step Render Setup (Exact Clicks)

1. **Log in to Render Dashboard:**
   - Go to [dashboard.render.com](https://dashboard.render.com).
2. **Create New Web Service:**
   - Click the blue **+ New** button in the top navigation bar.
   - Select **Web Service**.
3. **Connect Your GitHub Repository:**
   - Under *Connect a repository*, find `Rishabhbansal005/Parali-setu`.
   - Click **Connect**. (If not visible, click *Configure account* to grant Render access to your repo).
4. **Configure the Service Settings:**
   - **Name:** `paralisetu-api` (or any name you prefer; your public URL will be `https://paralisetu-api.onrender.com`).
   - **Region:** Choose **Singapore** (closest to India for lowest network latency) or **Frankfurt**.
   - **Branch:** `main` (or `chore/deploy` if testing the branch before merge).
   - **Root Directory:** Type `backend` *(CRITICAL: this tells Render to run inside the `backend/` directory)*.
   - **Runtime:** **Python 3**.
   - **Build Command:**
     ```bash
     pip install --upgrade pip && pip install -r requirements.txt
     ```
   - **Start Command:**
     ```bash
     uvicorn app.main:app --host 0.0.0.0 --port $PORT
     ```
   - **Instance Type:** Select **Free** ($0 / month).
5. **Add Environment Variables (under "Environment Variables" section):**
   Click **Add Environment Variable** for each of the following:

   | Key (Name Only) | Value Description |
   | :--- | :--- |
   | `PYTHON_VERSION` | `3.12.3` |
   | `DEBUG` | `false` |
   | `DEMO_MODE` | `true` |
   | `DEMO_PHONES` | `+919810000001,+919810000002,+919810000003` *(Simulated seeded farmers only)* |
   | `DATABASE_URL` | *Paste your Supabase connection string* *(Must contain `postgresql+psycopg2://`)* |
   | `JWT_SECRET_KEY` | *Paste a newly generated 32-byte secret* *(See Step 3 below)* |

6. **Deploy:**
   - Click **Create Web Service**.
   - Render will begin building. The first build typically takes 2–4 minutes.

---

## 3. Generating a Secure `JWT_SECRET_KEY`

Because `DEBUG=false` is set in production, the app **refuses to start** if `JWT_SECRET_KEY` is missing or uses the default placeholder.

To generate a random 256-bit key:
- **On Linux / macOS / Git Bash:**
  ```bash
  openssl rand -hex 32
  ```
- **On Windows PowerShell:**
  ```powershell
  [Convert]::ToHexString((1..32 | ForEach-Object { Get-Random -Maximum 256 } | [byte[]]::new))
  ```
Copy the 64-character hexadecimal output and paste it into Render as the value for `JWT_SECRET_KEY`. **Never commit this secret to Git.**

---

## 4. Why We Use `DEMO_PHONES` (No Real SMS Sent)

> [!NOTE]
> On the public hackathon server, no real SMS provider (Twilio / MSG91) is connected, which avoids SMS gateway fees. Therefore, **only phone numbers explicitly listed in `DEMO_PHONES` can log in using code `123456`**. All other phone numbers will be rejected. This is an intentional security design so that random internet visitors cannot register or pollute demo data.
>
> **Recommended Demo Phone Numbers:**
> - `+919810000001` (Gurpreet Singh — 4.0 acres, PR-126, Bhikhiwind, Tarn Taran)
> - `+919810000002` (Amarjit Kaur — 2.5 acres, PR-126, Patti, Tarn Taran)
> - `+919810000003` (Sukhwinder Singh — 6.0 acres, Pusa-44, Harike, Ferozepur)
>
> These numbers are already seeded in your Supabase database. Never use real personal phone numbers in demo logs.

---

## 5. Testing the Deployed API with `curl`

Replace `https://paralisetu-api.onrender.com` with your actual Render service URL.

### 1. Test Health Endpoint (Lightweight server wake-up)
```bash
curl -X GET "https://paralisetu-api.onrender.com/health"
```
**Expected Response (HTTP 200):**
```json
{"status":"ok","app":"ParaliSetu API","mode":"development","simulation":true}
```

### 2. Test OTP Send (Simulated)
```bash
curl -X POST "https://paralisetu-api.onrender.com/auth/otp/send" \
  -H "Content-Type: application/json" \
  -d '{"phone_e164": "+919810000001"}'
```
**Expected Response (HTTP 200):**
```json
{"message":"OTP sent successfully (simulated)","phone_e164":"+919810000001","is_mock":true}
```

### 3. Test OTP Verify for Allow-Listed Demo Phone
```bash
curl -X POST "https://paralisetu-api.onrender.com/auth/otp/verify" \
  -H "Content-Type: application/json" \
  -d '{"phone_e164": "+919810000001", "otp": "123456"}'
```
**Expected Response (HTTP 200):**
```json
{
  "access_token": "eyJhbGciOi...",
  "refresh_token": "eyJhbGciOi...",
  "token_type": "bearer"
}
```

### 4. Verify Non-Allow-Listed Phone is Rejected
```bash
curl -X POST "https://paralisetu-api.onrender.com/auth/otp/verify" \
  -H "Content-Type: application/json" \
  -d '{"phone_e164": "+919999999999", "otp": "123456"}'
```
**Expected Response (HTTP 400):**
```json
{"detail":"No OTP requested for this number or expired"}
```

---

## 6. How to Read Render Logs

1. In the Render Dashboard, click your service (`paralisetu-api`).
2. Click **Logs** in the left sidebar menu.
3. You will see real-time stdout/stderr streams:
   - Successful startup: `Uvicorn running on http://0.0.0.0:10000`
   - Requests: `INFO: 127.0.0.1 - "GET /health HTTP/1.1" 200 OK`
   - If `JWT_SECRET_KEY` is missing: `ValueError: Production configuration error: JWT_SECRET_KEY is missing...`

---

## 7. "Before the Demo" Checklist (Judge Presentation Prep)

Complete these 3 steps **10 minutes before** demonstrating to judges:

- [ ] **Wake the Render Service 3 Minutes Early:**
  Render free services go to sleep after 15 minutes of inactivity. The first request takes **30–50 seconds** to spin up the container. Open `https://your-service.onrender.com/health` in your browser 3 minutes before the demo so the server is warm and responds in <100ms during the live presentation.
- [ ] **Check Supabase is Active:**
  Log in to [supabase.com/dashboard](https://supabase.com/dashboard) and confirm your project status is **Active** (not paused due to free tier inactivity).
- [ ] **Test on Mobile Data:**
  Disconnect your test phone from laptop Wi-Fi, turn on cellular 4G/5G data, open the app, and log in with `+919810000001` and `123456` to confirm cross-network connectivity works flawlessly.
