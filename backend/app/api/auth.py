from __future__ import annotations
import uuid
import time
from dataclasses import dataclass, field
from datetime import datetime, timezone
from typing import Dict, List, Optional
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.config import settings
from app.core.database import SessionLocal
from app.dependencies import get_db, get_current_user
from app.core.security import (
    generate_otp,
    create_access_token,
    create_refresh_token,
    decode_token,
    JWTError,
)
from app.models.user import User
from app.schemas.auth import (
    SendOtpRequest,
    SendOtpResponse,
    VerifyOtpRequest,
    TokenResponse,
    RefreshTokenRequest,
    UserProfileResponse,
)
from app.services.otp_provider import get_otp_provider

router = APIRouter(prefix="/auth", tags=["auth"])


@dataclass
class OtpState:
    otp: str = ""
    created_at: float = 0.0
    send_timestamps: List[float] = field(default_factory=list)
    failed_attempts: int = 0
    locked_until: float = 0.0


# In-memory OTP store for Mock mode: {phone: OtpState}
_MOCK_OTP_STORE: Dict[str, OtpState] = {}


@router.post("/otp/send", response_model=SendOtpResponse)
def send_otp(req: SendOtpRequest):
    phone = req.phone_e164.strip()
    if not phone.startswith("+"):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Phone number must be in E.164 format (e.g. +919876543210)",
        )

    now = time.time()
    state = _MOCK_OTP_STORE.setdefault(phone, OtpState())

    # Check lockout
    if now < state.locked_until:
        remaining_lock = int(state.locked_until - now)
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail=f"Account locked due to too many failed attempts. Try again in {remaining_lock} seconds.",
        )

    # Prune expired send timestamps outside the throttling window
    cutoff = now - settings.OTP_SEND_WINDOW_SECONDS
    state.send_timestamps = [t for t in state.send_timestamps if t > cutoff]

    # Enforce send rate limit
    if len(state.send_timestamps) >= settings.OTP_MAX_SENDS_PER_WINDOW:
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail=f"Too many OTP requests. Maximum {settings.OTP_MAX_SENDS_PER_WINDOW} requests per {settings.OTP_SEND_WINDOW_SECONDS // 60} minutes.",
        )

    otp = generate_otp(6)
    state.otp = otp
    state.created_at = now
    state.send_timestamps.append(now)

    provider = get_otp_provider()
    provider.send_otp(phone, otp)

    return SendOtpResponse(
        message="OTP sent successfully (simulated)",
        phone_e164=phone,
        is_mock=True,
    )


@router.post("/otp/verify", response_model=TokenResponse)
def verify_otp(req: VerifyOtpRequest, db: Session = Depends(get_db)):
    phone = req.phone_e164.strip()
    now = time.time()
    state = _MOCK_OTP_STORE.get(phone)

    # 1. Lockout check: applies even if DEMO_MODE is enabled
    if state and now < state.locked_until:
        remaining_lock = int(state.locked_until - now)
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail=f"Account temporarily locked due to excessive failed attempts. Try again in {remaining_lock} seconds.",
        )

    # Allow-listed demo bypass: active only when DEMO_MODE is true, code is 123456,
    # and the phone number is explicitly present in the DEMO_PHONES allow-list.
    is_demo_bypass = bool(
        settings.DEMO_MODE
        and req.otp == "123456"
        and (phone in settings.demo_phones_list)
    )

    # 2. Check if OTP exists
    if not state or not state.otp:
        if is_demo_bypass:
            pass  # Allowed for allow-listed demo phones without prior send
        else:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="No OTP requested for this number or expired",
            )
    else:
        # 3. Enforce time-based OTP expiry
        if (now - state.created_at) > settings.OTP_EXPIRY_SECONDS:
            state.otp = ""  # Invalidate expired OTP
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="OTP has expired. Please request a new one.",
            )

        # 4. Check OTP match (with allow-listed DEMO_MODE bypass)
        if req.otp != state.otp and not is_demo_bypass:
            state.failed_attempts += 1

            if state.failed_attempts >= settings.OTP_MAX_VERIFY_ATTEMPTS:
                state.locked_until = now + settings.OTP_LOCKOUT_SECONDS
                state.failed_attempts = 0
                state.otp = ""
                raise HTTPException(
                    status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                    detail=f"Too many failed OTP attempts. Account locked for {settings.OTP_LOCKOUT_SECONDS // 60} minutes.",
                )
            remaining = settings.OTP_MAX_VERIFY_ATTEMPTS - state.failed_attempts
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Incorrect OTP. {remaining} attempt(s) remaining.",
            )

        # Reset failed attempts and consume OTP on successful verification
        state.failed_attempts = 0
        state.otp = ""

    # Find or auto-register user with role ['farmer']
    user = db.query(User).filter(User.phone_e164 == phone).first()
    if not user:
        user = User(
            phone_e164=phone,
            name="New Farmer",
            preferred_language="hi",
            roles=["farmer"],
            state="Punjab",
        )
        db.add(user)
        db.commit()
        db.refresh(user)

    payload = {
        "sub": str(user.id),
        "roles": user.roles,
        "phone": user.phone_e164,
    }
    access_token = create_access_token(payload)
    refresh_token = create_refresh_token(payload)

    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
    )


@router.post("/token/refresh", response_model=TokenResponse)
def refresh_token(req: RefreshTokenRequest, db: Session = Depends(get_db)):
    try:
        payload = decode_token(req.refresh_token)
        if payload.get("type") != "refresh":
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token type (expected refresh token)",
            )
        user_id = payload.get("sub")
        try:
            user_uuid = uuid.UUID(user_id)
        except (ValueError, TypeError):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid user id in token",
            )
        user = db.query(User).filter(User.id == user_uuid).first()
        if not user or not user.is_active:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="User not found or deactivated",
            )

        new_payload = {
            "sub": str(user.id),
            "roles": user.roles,
            "phone": user.phone_e164,
        }
        return TokenResponse(
            access_token=create_access_token(new_payload),
            refresh_token=create_refresh_token(new_payload),
        )
    except JWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired refresh token",
        )


@router.get("/me", response_model=UserProfileResponse)
def get_current_user_profile(user: User = Depends(get_current_user)):
    return UserProfileResponse(
        id=str(user.id),
        phone_e164=user.phone_e164,
        name=user.name,
        preferred_language=user.preferred_language,
        roles=user.roles,
        village=user.village,
        district=user.district,
        state=user.state,
    )
