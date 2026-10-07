# Copied and Adapted Code Log

Every time code from `references/` is reused in this project, add a row here.
This file is the audit trail required by AGENT_RULES.md Rule 5c.

| Source repo | Source file | Destination file | What was changed | Date |
|---|---|---|---|---|
| miniproject (SIH2022) | `src/api/authAPI.js` | `backend/app/core/security.py`, `backend/app/api/auth.py` | Ported 2-step phone OTP request and verification to FastAPI + python-jose JWT. Stripped Heroku URL and dead endpoints; fixed malformed Authorization header bug. | 2026-10-07 |
| rewire-app | `backend/middleware/auth.js` | `backend/app/dependencies.py` | Adapted bearer token decoding and user extraction middleware into FastAPI Depends() security pattern. Secrets moved to .env. | 2026-10-07 |
