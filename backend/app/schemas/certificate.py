from __future__ import annotations
from typing import Optional
from pydantic import BaseModel, ConfigDict

class CertificateResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    certificate_id: str
    booking_id: str
    farmer_name: str
    village: str
    district: str
    state: str
    stubble_tonnes: float
    satellite_source: str
    image_date: str
    cloud_cover_pct: float
    delta_nbr: float
    result_state: str
    burn_detected: Optional[bool]
    burn_severity: str
    co2_avoided_tonnes: float
    pm25_avoided_kg: float
    equivalent_trees: int
    issued_at: str
    is_valid: bool
    authority: str
    verification_notes: str
