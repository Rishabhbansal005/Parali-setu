from __future__ import annotations
import uuid
from datetime import date, datetime
from typing import Optional, Dict, Any
from sqlalchemy import String, Numeric, Text, Date, DateTime, Boolean, ForeignKey
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.core.database import Base
from app.models.base import UUIDTimestampMixin

class BurnCheck(UUIDTimestampMixin, Base):
    __tablename__ = "burn_checks"

    booking_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("bookings.id", ondelete="CASCADE"), nullable=False, unique=True)
    farm_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("farms.id"), nullable=False)
    checked_at: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True), nullable=True)
    satellite_source: Mapped[Optional[str]] = mapped_column(String(30), nullable=True)
    image_date: Mapped[Optional[date]] = mapped_column(Date, nullable=True)
    cloud_cover_pct: Mapped[Optional[float]] = mapped_column(Numeric(5, 2), nullable=True)
    burn_detected: Mapped[Optional[bool]] = mapped_column(Boolean, nullable=True)
    burn_severity: Mapped[Optional[str]] = mapped_column(String(20), nullable=True)
    burn_fraction: Mapped[Optional[float]] = mapped_column(Numeric(5, 4), nullable=True)
    result_state: Mapped[str] = mapped_column(String(30), nullable=False, default="unclear")
    vlm_raw_response: Mapped[Optional[Dict[str, Any]]] = mapped_column(JSONB, nullable=True)
    notes: Mapped[Optional[str]] = mapped_column(Text, nullable=True)

    booking = relationship("Booking", back_populates="burn_check")
