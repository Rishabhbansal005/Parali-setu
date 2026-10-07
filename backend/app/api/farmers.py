from __future__ import annotations
import uuid
from typing import List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from geoalchemy2.shape import from_shape
from shapely.geometry import Point

from app.dependencies import get_db, get_current_user
from app.models.user import User
from app.models.farm import Farm
from app.schemas.farm import FarmCreate, FarmResponse

router = APIRouter(prefix="/farmers", tags=["farmers"])

@router.post("/{farmer_id}/farms", response_model=FarmResponse)
def add_farm(
    farmer_id: str,
    farm_data: FarmCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    try:
        farmer_uuid = uuid.UUID(farmer_id)
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid farmer UUID")

    # Authorisation: only the farmer themselves or a kisan_mitra/admin can add a farm
    if current_user.id != farmer_uuid and not any(r in current_user.roles for r in ["kisan_mitra", "admin"]):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Cannot add farms to another user's profile",
        )

    # Point geometry if lat/long provided
    pt_geom = None
    if farm_data.latitude is not None and farm_data.longitude is not None:
        try:
            pt = Point(farm_data.longitude, farm_data.latitude)
            pt_geom = from_shape(pt, srid=4326)
        except Exception:
            pt_geom = None

    farm = Farm(
        farmer_id=farmer_uuid,
        name=farm_data.name,
        area_acres=farm_data.area_acres,
        paddy_variety=farm_data.paddy_variety,
        harvest_method=farm_data.harvest_method,
        location=pt_geom,
        khasra_number=farm_data.khasra_number,
    )
    db.add(farm)
    db.commit()
    db.refresh(farm)

    return FarmResponse(
        id=str(farm.id),
        farmer_id=str(farm.farmer_id),
        name=farm.name,
        area_acres=float(farm.area_acres),
        paddy_variety=farm.paddy_variety,
        harvest_method=farm.harvest_method,
        latitude=farm_data.latitude,
        longitude=farm_data.longitude,
        khasra_number=farm.khasra_number,
    )

@router.get("/{farmer_id}/farms", response_model=List[FarmResponse])
def list_farms(
    farmer_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    try:
        farmer_uuid = uuid.UUID(farmer_id)
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid farmer UUID")

    farms = db.query(Farm).filter(Farm.farmer_id == farmer_uuid).all()
    results = []
    for f in farms:
        results.append(
            FarmResponse(
                id=str(f.id),
                farmer_id=str(f.farmer_id),
                name=f.name,
                area_acres=float(f.area_acres),
                paddy_variety=f.paddy_variety,
                harvest_method=f.harvest_method,
                latitude=None,
                longitude=None,
                khasra_number=f.khasra_number,
            )
        )
    return results
