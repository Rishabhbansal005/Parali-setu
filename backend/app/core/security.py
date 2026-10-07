# Adapted from SIH2022 (miniproject-master) OTP+JWT flow pattern with owner permission.
# Original: miniproject-master/src/api/authAPI.js (JS/React, dead Heroku backend)
# Ported to Python / python-jose / passlib.  Malformed Authorization header bug
# (REFERENCE_NOTES.md §4.5) is NOT replicated here.
# See docs/COPIED_CODE.md for the full reuse log entry.

from __future__ import annotations

import random
import string
from datetime import datetime, timedelta, timezone
from typing import Any, Dict, List

from jose import JWTError, jwt

from app.core.config import settings

# ── OTP helpers ───────────────────────────────────────────────────────────────

def generate_otp(length: int = 6) -> str:
    """Return a random numeric OTP string of the given length."""
    return "".join(random.choices(string.digits, k=length))


# ── JWT helpers ───────────────────────────────────────────────────────────────

def _now_utc() -> datetime:
    return datetime.now(tz=timezone.utc)


def create_access_token(payload: Dict[str, Any]) -> str:
    """
    Create a short-lived JWT access token.
    payload must contain at least {"sub": <user_id>, "roles": [...]}.
    """
    data = payload.copy()
    data["exp"] = _now_utc() + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    data["type"] = "access"
    return jwt.encode(data, settings.JWT_SECRET_KEY, algorithm=settings.JWT_ALGORITHM)


def create_refresh_token(payload: Dict[str, Any]) -> str:
    """Create a long-lived JWT refresh token."""
    data = payload.copy()
    data["exp"] = _now_utc() + timedelta(days=settings.REFRESH_TOKEN_EXPIRE_DAYS)
    data["type"] = "refresh"
    return jwt.encode(data, settings.JWT_SECRET_KEY, algorithm=settings.JWT_ALGORITHM)


def decode_token(token: str) -> Dict[str, Any]:
    """
    Decode and validate a JWT.  Raises JWTError on invalid / expired tokens.
    Callers should catch JWTError and return HTTP 401.
    """
    return jwt.decode(token, settings.JWT_SECRET_KEY, algorithms=[settings.JWT_ALGORITHM])


# ── Role guard helper ─────────────────────────────────────────────────────────

def assert_roles(token_payload: Dict[str, Any], required: List[str]) -> None:
    """
    Raise PermissionError if the token does not contain at least one of the
    required roles.  See SPEC.md §2 for the full role list.
    """
    user_roles: List[str] = token_payload.get("roles", [])
    if not any(r in user_roles for r in required):
        raise PermissionError(
            f"Required one of {required}, user has {user_roles}"
        )
