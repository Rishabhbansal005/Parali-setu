from __future__ import annotations
from typing import Optional, List
from pydantic import BaseModel, Field

class FarmCreate(BaseModel):
    name: Optional[str] = "North Field"
    area_acres: float = Field(..., gt=0.0, description="Area in acres")
    paddy_variety: Optional[str] = Field("PR-126", description="'PR-126', 'Pusa-44', 'Basmati', 'other'")
    harvest_method: Optional[str] = Field("combine", description="'combine', 'manual'")
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    khasra_number: Optional[str] = None

class FarmResponse(BaseModel):
    id: str
    farmer_id: str
    name: Optional[str]
    area_acres: float
    paddy_variety: Optional[str]
    harvest_method: Optional[str]
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    khasra_number: Optional[str] = None

    class Config:
        from_attributes = True
