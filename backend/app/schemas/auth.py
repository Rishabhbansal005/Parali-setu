from __future__ import annotations
from typing import List, Optional
from pydantic import BaseModel, Field

class SendOtpRequest(BaseModel):
    phone_e164: str = Field(..., example="+919876543210")

class SendOtpResponse(BaseModel):
    message: str
    phone_e164: str
    is_mock: bool = True

class VerifyOtpRequest(BaseModel):
    phone_e164: str = Field(..., example="+919876543210")
    otp: str = Field(..., example="123456")

class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"

class RefreshTokenRequest(BaseModel):
    refresh_token: str

class UserProfileResponse(BaseModel):
    id: str
    phone_e164: str
    name: Optional[str] = None
    preferred_language: str
    roles: List[str]
    village: Optional[str] = None
    district: Optional[str] = None
    state: str
