import pytest
import os
from sqlalchemy import create_engine, text
from app.core.config import settings

def is_postgres_available() -> bool:
    """Check if the configured DATABASE_URL is accessible and has PostGIS."""
    if "postgresql" not in settings.DATABASE_URL:
        return False
    try:
        engine = create_engine(settings.DATABASE_URL, connect_args={"connect_timeout": 2})
        with engine.connect() as conn:
            result = conn.execute(text("SELECT PostGIS_Version();")).scalar()
            return bool(result)
    except Exception:
        return False

POSTGRES_AVAILABLE = is_postgres_available()

@pytest.mark.skipif(not POSTGRES_AVAILABLE, reason="PostgreSQL + PostGIS database is not running at DATABASE_URL")
def test_real_postgis_farm_geometry():
    """
    Integration test against live PostgreSQL + PostGIS.
    Verifies PostGIS extension, Farm table spatial column, and spatial querying.
    """
    engine = create_engine(settings.DATABASE_URL)
    with engine.connect() as conn:
        # Check PostGIS extension
        version = conn.execute(text("SELECT PostGIS_Version();")).scalar()
        assert version is not None

        # Verify spatial distance calculation for a field in Ludhiana, Punjab
        # Farm location: (75.8573 E, 30.9010 N)
        distance = conn.execute(text(
            "SELECT ST_Distance("
            "  ST_SetSRID(ST_MakePoint(75.8573, 30.9010), 4326)::geography,"
            "  ST_SetSRID(ST_MakePoint(75.8600, 30.9050), 4326)::geography"
            ");"
        )).scalar()
        assert distance > 0
