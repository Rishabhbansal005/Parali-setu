from __future__ import annotations
from datetime import date
from typing import Optional, Dict, Any
from pydantic import BaseModel, Field

class EstimateCreate(BaseModel):
    farm_id: str
    harvest_date: date
    wheat_sow_date: Optional[date] = None
    buyer_price_per_tonne_inr: Optional[float] = 1200.0

class EstimateResponse(BaseModel):
    id: str
    farm_id: str
    harvest_date: date
    wheat_sow_date: Optional[date] = None
    stubble_tonnes_low: Optional[float]
    stubble_tonnes_mid: Optional[float]
    stubble_tonnes_high: Optional[float]
    income_low_inr: Optional[float]
    income_high_inr: Optional[float]
    config_snapshot: Optional[Dict[str, Any]] = None

    class Config:
        from_attributes = True
