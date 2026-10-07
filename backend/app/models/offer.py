from __future__ import annotations
import uuid
from datetime import date, datetime
from typing import Optional
from sqlalchemy import Date, DateTime, Numeric, SmallInteger, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.core.database import Base
from app.models.base import UUIDTimestampMixin

class Offer(UUIDTimestampMixin, Base):
    __tablename__ = "offers"

    estimate_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("estimates.id", ondelete="CASCADE"), nullable=False)
    machine_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("machines.id"), nullable=False)
    truck_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("trucks.id"), nullable=False)
    buyer_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("buyers.id"), nullable=False)
    proposed_pickup_date: Mapped[Optional[date]] = mapped_column(Date, nullable=True)
    machine_cost_inr: Mapped[Optional[float]] = mapped_column(Numeric(10, 2), nullable=True)
    transport_cost_inr: Mapped[Optional[float]] = mapped_column(Numeric(10, 2), nullable=True)
    gross_income_inr: Mapped[Optional[float]] = mapped_column(Numeric(10, 2), nullable=True)
    net_income_inr: Mapped[Optional[float]] = mapped_column(Numeric(10, 2), nullable=True)
    rank: Mapped[Optional[int]] = mapped_column(SmallInteger, nullable=True)
    expires_at: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True), nullable=True)

    estimate = relationship("Estimate", back_populates="offers")
    machine = relationship("Machine", back_populates="offers")
    truck = relationship("Truck", back_populates="offers")
    buyer = relationship("Buyer", back_populates="offers")
    booking = relationship("Booking", back_populates="offer", uselist=False)
