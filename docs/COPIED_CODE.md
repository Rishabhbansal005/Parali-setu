# Copied and Adapted Code Log

Every time code from `references/` is reused or adapted in this project, add a row here.
This file is the audit trail required by AGENT_RULES.md Rule 5c.

| Source repo | Source file | Destination file | What was changed | Date |
|---|---|---|---|---|
| miniproject (SIH2022) | `src/api/authAPI.js` | `backend/app/core/security.py`, `backend/app/api/auth.py` | **Pattern followed (not copied verbatim):** Reimplemented the 2-step phone OTP request and verification workflow in Python/FastAPI with `PyJWT` (replaced `python-jose` to clear CVEs). The original JavaScript frontend called a remote backend; our implementation is clean native Python. | 2026-10-07 |
| rewire-app | `backend/middleware/auth.js` | `backend/app/dependencies.py` | **Pattern followed (not copied verbatim):** Express.js JWT Bearer extraction middleware was adapted into FastAPI's dependency injection (`Depends(HTTPBearer())`) pattern. Config moved to `.env`. | 2026-10-07 |
