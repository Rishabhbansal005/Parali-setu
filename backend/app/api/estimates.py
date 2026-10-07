from __future__ import annotations
import uuid
from datetime import datetime, timezone
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.dependencies import get_db, get_current_user
from app.models.user import User
from app.models.farm import Farm
from app.models.estimate import Estimate
from app.schemas.estimate import EstimateCreate, EstimateResponse
from app.services.estimation import estimate_stubble

router = APIRouter(prefix="/estimates", tags=["estimates"])

@router.post("", response_model=EstimateResponse)
def create_estimate(
    req: EstimateCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    try:
        farm_uuid = uuid.UUID(req.farm_id)
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid farm UUID")

    farm = db.query(Farm).filter(Farm.id == farm_uuid).first()
    if not farm:
        raise HTTPException(status_code=404, detail="Farm not found")

    # Call stubble estimation service
    est_data = estimate_stubble(
        area_acres=float(farm.area_acres),
        paddy_variety=farm.paddy_variety or "PR-126",
        harvest_method=farm.harvest_method or "combine",
        buyer_price_per_tonne_inr=req.buyer_price_per_tonne_inr or 1200.0,
    )

    estimate = Estimate(
        farm_id=farm.id,
        requested_at=datetime.now(timezone.utc),
        harvest_date=req.harvest_date,
        wheat_sow_date=req.wheat_sow_date,
        stubble_tonnes_low=est_data["stubble_tonnes_low"],
        stubble_tonnes_mid=est_data["stubble_tonnes_mid"],
        stubble_tonnes_high=est_data["stubble_tonnes_high"],
        income_low_inr=est_data["income_low_inr"],
        income_high_inr=est_data["income_high_inr"],
        config_snapshot=est_data["config_snapshot"],
    )
    db.add(estimate)
    db.commit()
    db.refresh(estimate)

    return EstimateResponse(
        id=str(estimate.id),
        farm_id=str(estimate.farm_id),
        harvest_date=estimate.harvest_date,
        wheat_sow_date=estimate.wheat_sow_date,
        stubble_tonnes_low=float(estimate.stubble_tonnes_low) if estimate.stubble_tonnes_low else None,
        stubble_tonnes_mid=float(estimate.stubble_tonnes_mid) if estimate.stubble_tonnes_mid else None,
        stubble_tonnes_high=float(estimate.stubble_tonnes_high) if estimate.stubble_tonnes_high else None,
        income_low_inr=float(estimate.income_low_inr) if estimate.income_low_inr else None,
        income_high_inr=float(estimate.income_high_inr) if estimate.income_high_inr else None,
        config_snapshot=estimate.config_snapshot,
    )

@router.get("/{estimate_id}", response_model=EstimateResponse)
def get_estimate(
    estimate_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    try:
        est_uuid = uuid.UUID(estimate_id)
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid estimate UUID")

    estimate = db.query(Estimate).filter(Estimate.id == est_uuid).first()
    if not estimate:
        raise HTTPException(status_code=404, detail="Estimate not found")

    return EstimateResponse(
        id=str(estimate.id),
        farm_id=str(estimate.farm_id),
        harvest_date=estimate.harvest_date,
        wheat_sow_date=estimate.wheat_sow_date,
        stubble_tonnes_low=float(estimate.stubble_tonnes_low) if estimate.stubble_tonnes_low else None,
        stubble_tonnes_mid=float(estimate.stubble_tonnes_mid) if estimate.stubble_tonnes_mid else None,
        stubble_tonnes_high=float(estimate.stubble_tonnes_high) if estimate.stubble_tonnes_high else None,
        income_low_inr=float(estimate.income_low_inr) if estimate.income_low_inr else None,
        income_high_inr=float(estimate.income_high_inr) if estimate.income_high_inr else None,
        config_snapshot=estimate.config_snapshot,
    )
