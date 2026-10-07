from __future__ import annotations
import uuid
from datetime import datetime
from typing import Optional
from sqlalchemy import String, Text, DateTime, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.core.database import Base
from app.models.base import UUIDTimestampMixin

class Booking(UUIDTimestampMixin, Base):
    __tablename__ = "bookings"

    offer_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("offers.id"), nullable=False, unique=True)
    farmer_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    proxy_user_id: Mapped[Optional[uuid.UUID]] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=True)
    status: Mapped[str] = mapped_column(String(30), nullable=False, default="requested")
    cancelled_reason: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    cancellation_actor: Mapped[Optional[str]] = mapped_column(String(30), nullable=True)
    confirmed_at: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True), nullable=True)
    picked_up_at: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True), nullable=True)
    weighed_at: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True), nullable=True)
    paid_at: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True), nullable=True)
    verified_at: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True), nullable=True)

    offer = relationship("Offer", back_populates="booking")
    farmer = relationship("User", foreign_keys=[farmer_id], back_populates="bookings")
    payment = relationship("Payment", back_populates="booking", uselist=False)
    weighbridge_record = relationship("WeighbridgeRecord", back_populates="booking", uselist=False)
    burn_check = relationship("BurnCheck", back_populates="booking", uselist=False)
    impact_log = relationship("ImpactLog", back_populates="booking", uselist=False)
