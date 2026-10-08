from __future__ import annotations
import uuid
from typing import Optional
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.dependencies import get_db, get_current_user, get_optional_current_user
from app.models.user import User
from app.models.estimate import Estimate
from app.models.farm import Farm
from app.schemas.matching import MatchBundleRequest, MatchBundleResponse
from app.services.matching import find_matched_bundles

router = APIRouter(prefix="/matching", tags=["matching"])

@router.post("/find-bundles", response_model=MatchBundleResponse)
def get_matched_bundles(
    req: MatchBundleRequest,
    db: Session = Depends(get_db),
    current_user: Optional[User] = Depends(get_optional_current_user),
):
    """
    Solves multi-point matching optimization using Google OR-Tools CP-SAT.
    Returns 2-3 ranked bundles (Baler + Truck + Biomass Buyer).
    """
    # If estimate_id provided, load farm details to populate accurate acres and variety
    if req.estimate_id:
        try:
            est_uuid = uuid.UUID(req.estimate_id)
            estimate = db.query(Estimate).filter(Estimate.id == est_uuid).first()
            if estimate:
                req.harvest_date = req.harvest_date or estimate.harvest_date
                req.stubble_tonnes = req.stubble_tonnes or float(estimate.stubble_tonnes_mid or 8.0)
                
                farm = db.query(Farm).filter(Farm.id == estimate.farm_id).first()
                if farm:
                    req.acres = req.acres or float(farm.area_acres or 4.0)
                    req.paddy_variety = req.paddy_variety or farm.paddy_variety
        except ValueError:
            raise HTTPException(status_code=400, detail="Invalid estimate UUID format")

    response = find_matched_bundles(req=req, db=db)
    return response

@router.get("/estimate/{estimate_id}/bundles", response_model=MatchBundleResponse)
def get_bundles_for_estimate(
    estimate_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Convenience endpoint to retrieve or compute matched bundles for an existing estimate ID."""
    try:
        est_uuid = uuid.UUID(estimate_id)
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid estimate UUID format")
        
    estimate = db.query(Estimate).filter(Estimate.id == est_uuid).first()
    if not estimate:
        raise HTTPException(status_code=404, detail="Estimate not found")

    farm = db.query(Farm).filter(Farm.id == estimate.farm_id).first()
    acres = float(farm.area_acres) if (farm and farm.area_acres) else 4.0
    variety = farm.paddy_variety if farm else "PR-126"
    stubble = float(estimate.stubble_tonnes_mid or 8.0)

    req = MatchBundleRequest(
        estimate_id=str(estimate.id),
        farm_id=str(estimate.farm_id),
        acres=acres,
        paddy_variety=variety,
        harvest_date=estimate.harvest_date,
        stubble_tonnes=stubble,
    )
    return find_matched_bundles(req=req, db=db)
