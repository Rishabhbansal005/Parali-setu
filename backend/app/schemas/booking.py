from __future__ import annotations
import uuid
from datetime import datetime
from typing import Optional, List
from pydantic import BaseModel, Field

class BookingCreateRequest(BaseModel):
    offer_id: str = Field(..., description="UUID of the selected offer")
    notes: Optional[str] = Field(None, description="Optional special pickup instructions")

class BookingStatusUpdateRequest(BaseModel):
    status: str = Field(..., description="Target status: confirmed, picked_up, cancelled")
    cancelled_reason: Optional[str] = None

class WeighbridgeSubmitRequest(BaseModel):
    gross_weight_tonnes: float = Field(..., gt=0, description="Gross loaded truck weight in tonnes")
    tare_weight_tonnes: float = Field(..., gt=0, description="Empty tare truck weight in tonnes")
    ticket_number: Optional[str] = Field(None, description="Dharamkanta physical serial ticket number")
    ticket_image_url: Optional[str] = Field(None, description="Photo of weighbridge thermal ticket")

class WeighbridgeSummary(BaseModel):
    id: str
    booking_id: str
    weight_kg: float
    weight_tonnes: float
    ticket_number: Optional[str]
    ticket_image_url: Optional[str]
    disputed: bool
    measured_at: Optional[datetime]

    class Config:
        from_attributes = True

class PaymentSummary(BaseModel):
    id: str
    booking_id: str
    provider: str
    escrow_amount_inr: Optional[float]
    final_amount_inr: Optional[float]
    status: str
    held_at: Optional[datetime]
    released_at: Optional[datetime]

    class Config:
        from_attributes = True

class BookingResponse(BaseModel):
    id: str
    offer_id: str
    farmer_id: str
    status: str
    escrow_amount_inr: Optional[float]
    final_payout_inr: Optional[float]
    confirmed_at: Optional[datetime]
    picked_up_at: Optional[datetime]
    weighed_at: Optional[datetime]
    paid_at: Optional[datetime]
    cancelled_reason: Optional[str] = None
    payment: Optional[PaymentSummary] = None
    weighbridge_record: Optional[WeighbridgeSummary] = None

    class Config:
        from_attributes = True
