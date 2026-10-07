from __future__ import annotations
import uuid
from datetime import date
from typing import Optional, List
from sqlalchemy import String, Numeric, Date, Boolean, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship
from geoalchemy2 import Geometry
from app.core.database import Base
from app.models.base import UUIDTimestampMixin
from app.models.user import JSONCompatibleList

class Machine(UUIDTimestampMixin, Base):
    __tablename__ = "machines"

    owner_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    machine_type: Mapped[str] = mapped_column(String(50), nullable=False)
    brand: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)
    capacity_acres_per_day: Mapped[Optional[float]] = mapped_column(Numeric(5, 2), nullable=True)
    location = mapped_column(Geometry(geometry_type="POINT", srid=4326), nullable=True)
    price_per_acre_inr: Mapped[Optional[float]] = mapped_column(Numeric(8, 2), nullable=True)
    availability_start: Mapped[Optional[date]] = mapped_column(Date, nullable=True)
    availability_end: Mapped[Optional[date]] = mapped_column(Date, nullable=True)
    is_active: Mapped[bool] = mapped_column(Boolean, nullable=False, default=True)
    photos: Mapped[Optional[List[str]]] = mapped_column(JSONCompatibleList(), nullable=True)

    owner = relationship("User", back_populates="machines")
    offers = relationship("Offer", back_populates="machine")
