from __future__ import annotations
import uuid
from datetime import datetime
from typing import Optional
from sqlalchemy import String, Numeric, Text, DateTime, Boolean, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.core.database import Base
from app.models.base import UUIDTimestampMixin

class WeighbridgeRecord(UUIDTimestampMixin, Base):
    __tablename__ = "weighbridge_records"

    booking_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("bookings.id", ondelete="CASCADE"), nullable=False, unique=True)
    submitted_by: Mapped[Optional[uuid.UUID]] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=True)
    weight_kg: Mapped[float] = mapped_column(Numeric(10, 2), nullable=False)
    ticket_number: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)
    ticket_image_url: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    farmer_confirmed: Mapped[Optional[bool]] = mapped_column(Boolean, nullable=True)
    buyer_confirmed: Mapped[Optional[bool]] = mapped_column(Boolean, nullable=True)
    disputed: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)
    dispute_notes: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    measured_at: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True), nullable=True)

    booking = relationship("Booking", back_populates="weighbridge_record")
