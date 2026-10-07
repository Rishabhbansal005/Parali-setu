from __future__ import annotations
import uuid
from datetime import date
from typing import Optional
from sqlalchemy import String, Numeric, Date, Boolean, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship
from geoalchemy2 import Geometry
from app.core.database import Base
from app.models.base import UUIDTimestampMixin

class Buyer(UUIDTimestampMixin, Base):
    __tablename__ = "buyers"

    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    business_name: Mapped[str] = mapped_column(String(200), nullable=False)
    business_type: Mapped[str] = mapped_column(String(50), nullable=False)
    location = mapped_column(Geometry(geometry_type="POINT", srid=4326), nullable=True)
    max_distance_km: Mapped[Optional[float]] = mapped_column(Numeric(6, 1), nullable=True)
    price_per_tonne_inr: Mapped[Optional[float]] = mapped_column(Numeric(8, 2), nullable=True)
    moisture_limit_pct: Mapped[Optional[float]] = mapped_column(Numeric(4, 1), nullable=True)
    min_batch_tonnes: Mapped[Optional[float]] = mapped_column(Numeric(6, 2), nullable=True)
    max_batch_tonnes: Mapped[Optional[float]] = mapped_column(Numeric(6, 2), nullable=True)
    demand_window_start: Mapped[Optional[date]] = mapped_column(Date, nullable=True)
    demand_window_end: Mapped[Optional[date]] = mapped_column(Date, nullable=True)
    is_active: Mapped[bool] = mapped_column(Boolean, nullable=False, default=True)

    user = relationship("User", back_populates="buyers")
    offers = relationship("Offer", back_populates="buyer")
