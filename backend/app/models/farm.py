from __future__ import annotations
import uuid
from typing import Optional
from sqlalchemy import String, Numeric, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship
from geoalchemy2 import Geometry
from app.core.database import Base
from app.models.base import UUIDTimestampMixin

class Farm(UUIDTimestampMixin, Base):
    __tablename__ = "farms"

    farmer_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    name: Mapped[Optional[str]] = mapped_column(String(100), nullable=True, default="Farm")
    area_acres: Mapped[float] = mapped_column(Numeric(6, 2), nullable=False)
    paddy_variety: Mapped[Optional[str]] = mapped_column(String(50), nullable=True)
    harvest_method: Mapped[Optional[str]] = mapped_column(String(20), nullable=True)
    location = mapped_column(Geometry(geometry_type="POINT", srid=4326), nullable=True)
    boundary = mapped_column(Geometry(geometry_type="POLYGON", srid=4326), nullable=True)
    khasra_number: Mapped[Optional[str]] = mapped_column(String(50), nullable=True)

    farmer = relationship("User", back_populates="farms")
    estimates = relationship("Estimate", back_populates="farm", cascade="all, delete-orphan")
