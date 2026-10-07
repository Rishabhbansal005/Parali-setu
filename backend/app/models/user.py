from __future__ import annotations
import uuid
import json
from typing import List, Optional
from sqlalchemy import String, Boolean, Text, JSON
from sqlalchemy.dialects.postgresql import ARRAY
from sqlalchemy.types import TypeDecorator
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.core.database import Base
from app.models.base import UUIDTimestampMixin

class JSONCompatibleList(TypeDecorator):
    """Stores list as Postgres ARRAY in Postgres, and JSON string/list in SQLite."""
    impl = JSON
    cache_ok = True

    def load_dialect_impl(self, dialect):
        if dialect.name == 'postgresql':
            return dialect.type_descriptor(ARRAY(String))
        else:
            return dialect.type_descriptor(JSON())

    def process_bind_param(self, value, dialect):
        if value is None:
            return [] if dialect.name == 'postgresql' else "[]"
        return value

    def process_result_value(self, value, dialect):
        if value is None:
            return []
        if isinstance(value, str):
            try:
                return json.loads(value)
            except Exception:
                return [value]
        return list(value)

class User(UUIDTimestampMixin, Base):
    __tablename__ = "users"

    phone_e164: Mapped[str] = mapped_column(String(20), unique=True, nullable=False, index=True)
    name: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)
    preferred_language: Mapped[str] = mapped_column(String(10), nullable=False, default="hi")
    roles: Mapped[List[str]] = mapped_column(JSONCompatibleList(), nullable=False, default=list)
    village: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)
    district: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)
    state: Mapped[str] = mapped_column(String(100), nullable=False, default="Punjab")
    fcm_token: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    is_active: Mapped[bool] = mapped_column(Boolean, nullable=False, default=True)

    # Relationships
    farms = relationship("Farm", back_populates="farmer", cascade="all, delete-orphan")
    machines = relationship("Machine", back_populates="owner")
    trucks = relationship("Truck", back_populates="owner")
    buyers = relationship("Buyer", back_populates="user")
    bookings = relationship("Booking", foreign_keys="[Booking.farmer_id]", back_populates="farmer")
