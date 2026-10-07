from __future__ import annotations
import uuid
from datetime import date, datetime
from typing import Optional, Dict, Any
from sqlalchemy import Date, DateTime, Numeric, ForeignKey
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.core.database import Base
from app.models.base import UUIDTimestampMixin

class Estimate(UUIDTimestampMixin, Base):
    __tablename__ = "estimates"

    farm_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("farms.id", ondelete="CASCADE"), nullable=False)
    requested_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    harvest_date: Mapped[date] = mapped_column(Date, nullable=False)
    wheat_sow_date: Mapped[Optional[date]] = mapped_column(Date, nullable=True)
    stubble_tonnes_low: Mapped[Optional[float]] = mapped_column(Numeric(6, 2), nullable=True)
    stubble_tonnes_mid: Mapped[Optional[float]] = mapped_column(Numeric(6, 2), nullable=True)
    stubble_tonnes_high: Mapped[Optional[float]] = mapped_column(Numeric(6, 2), nullable=True)
    income_low_inr: Mapped[Optional[float]] = mapped_column(Numeric(10, 2), nullable=True)
    income_high_inr: Mapped[Optional[float]] = mapped_column(Numeric(10, 2), nullable=True)
    config_snapshot: Mapped[Optional[Dict[str, Any]]] = mapped_column(JSONB, nullable=True)

    farm = relationship("Farm", back_populates="estimates")
    offers = relationship("Offer", back_populates="estimate", cascade="all, delete-orphan")
