from __future__ import annotations
import uuid
from datetime import datetime, timezone
from typing import Dict
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from jose import JWTError

from app.core.database import SessionLocal
from app.dependencies import get_db, get_current_user
from app.core.security import (
    generate_otp,
    create_access_token,
    create_refresh_token,
    decode_token,
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

# In-memory OTP store for Mock mode: {phone: (otp, expiry_timestamp)}
_MOCK_OTP_STORE: Dict[str, str] = {}

@router.post("/otp/send", response_model=SendOtpResponse)
def send_otp(req: SendOtpRequest):
    phone = req.phone_e164.strip()
    if not phone.startswith("+"):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Phone number must be in E.164 format (e.g. +919876543210)",
        )
    otp = generate_otp(6)
    _MOCK_OTP_STORE[phone] = otp

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
    expected_otp = _MOCK_OTP_STORE.get(phone)

    # For dev convenience, also allow "123456" as universal bypass if no OTP stored or test
    if not expected_otp and req.otp != "123456":
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="No OTP requested for this number or expired",
        )
    if expected_otp and req.otp != expected_otp and req.otp != "123456":
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Incorrect OTP",
        )

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

    # Consume OTP
    if phone in _MOCK_OTP_STORE:
        del _MOCK_OTP_STORE[phone]

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
                detail="User inactive or not found",
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
def get_my_profile(current_user: User = Depends(get_current_user)):
    return UserProfileResponse(
        id=str(current_user.id),
        phone_e164=current_user.phone_e164,
        name=current_user.name,
        preferred_language=current_user.preferred_language,
        roles=current_user.roles,
        village=current_user.village,
        district=current_user.district,
        state=current_user.state,
    )
