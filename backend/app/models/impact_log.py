from __future__ import annotations
import uuid
from typing import Optional
from sqlalchemy import String, Numeric, Text, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.core.database import Base
from app.models.base import UUIDTimestampMixin

class ImpactLog(UUIDTimestampMixin, Base):
    __tablename__ = "impact_log"

    booking_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("bookings.id", ondelete="CASCADE"), nullable=False, unique=True)
    stubble_kg: Mapped[Optional[float]] = mapped_column(Numeric(10, 2), nullable=True)
    co2_eq_kg_avoided: Mapped[Optional[float]] = mapped_column(Numeric(12, 2), nullable=True)
    pm25_kg_avoided: Mapped[Optional[float]] = mapped_column(Numeric(10, 4), nullable=True)
    equivalent_trees: Mapped[Optional[float]] = mapped_column(Numeric(10, 2), nullable=True)
    calculation_version: Mapped[Optional[str]] = mapped_column(String(20), nullable=True)
    notes: Mapped[Optional[str]] = mapped_column(Text, nullable=True)

    booking = relationship("Booking", back_populates="impact_log")
