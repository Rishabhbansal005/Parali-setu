from __future__ import annotations
import uuid
from datetime import date
from typing import Optional, List
from pydantic import BaseModel, Field

class MatchBundleRequest(BaseModel):
    estimate_id: Optional[str] = Field(None, description="UUID of existing stubble estimate")
    farm_id: Optional[str] = Field(None, description="UUID of farm")
    acres: Optional[float] = Field(4.0, ge=0.5, le=500.0, description="Acres of paddy land")
    paddy_variety: Optional[str] = Field("PR-126", description="Paddy variety")
    harvest_date: Optional[date] = Field(None, description="Estimated harvest date")
    stubble_tonnes: Optional[float] = Field(None, description="Estimated recoverable stubble in tonnes")
    latitude: Optional[float] = Field(30.25, ge=28.0, le=33.0, description="Farm latitude (Punjab/Haryana)")
    longitude: Optional[float] = Field(75.85, ge=73.0, le=78.0, description="Farm longitude")

class MatchedBundle(BaseModel):
    offer_id: Optional[str] = None
    rank: int = Field(..., ge=1, le=5)
    tag: str = Field(..., example="BEST_VALUE")
    tag_label_en: str
    tag_label_hi: str
    tag_label_pa: str
    proposed_pickup_date: date
    days_after_harvest: int
    
    # Machine (Baler) details
    machine_id: Optional[str] = None
    machine_name: str
    machine_type: str
    machine_cost_inr: float
    
    # Truck details
    truck_id: Optional[str] = None
    truck_name: str
    truck_capacity_tonnes: float
    transport_cost_inr: float
    
    # Buyer details
    buyer_id: Optional[str] = None
    buyer_name: str
    buyer_type: str
    buyer_distance_km: float
    buyer_price_per_tonne_inr: float
    
    # Financial breakdown
    stubble_tonnes: float
    gross_income_inr: float
    net_income_inr: float
    
    # Environmental impact
    co2_saved_tonnes: float
    pm25_avoided_kg: float
    
    expires_in_hours: int = 24

class MatchBundleResponse(BaseModel):
    bundles: List[MatchedBundle]
    total_candidates_evaluated: int
    solver_status: str
    execution_time_ms: float
    stubble_tonnes: float
    harvest_date: date
