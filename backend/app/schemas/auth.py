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
    phone: Optional[str] = None
    name: Optional[str] = None
    preferred_language: str
    language: Optional[str] = None
    roles: List[str] = Field(default_factory=list)
    role: Optional[str] = None
    village: Optional[str] = None
    district: Optional[str] = None
    state: Optional[str] = None


class UpdateProfileRequest(BaseModel):
    name: Optional[str] = Field(None, max_length=100)
    language: Optional[str] = None
    village: Optional[str] = Field(None, max_length=100)
    district: Optional[str] = Field(None, max_length=100)
    state: Optional[str] = Field(None, max_length=100)
