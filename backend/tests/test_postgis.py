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


@pytest.mark.skipif(not POSTGRES_AVAILABLE, reason="PostgreSQL + PostGIS database is not running at DATABASE_URL")
def test_postgis_farm_point_transaction_rollback():
    """
    Inserts a Farm with a Point geometry inside a transaction that is ROLLED BACK at the end
    (no rows left behind), reads it back within the transaction, and checks coordinates.
    """
    from sqlalchemy.orm import Session
    from geoalchemy2.shape import from_shape, to_shape
    from shapely.geometry import Point
    from app.models.user import User
    from app.models.farm import Farm

    engine = create_engine(settings.DATABASE_URL)
    with engine.connect() as conn:
        trans = conn.begin()
        db = Session(bind=conn)
        try:
            # Query an existing user from the database
            farmer = db.query(User).first()
            assert farmer is not None, "Database must have at least one user"

            # Create test farm with Point geometry (74.9272 E, 31.4519 N)
            test_lon, test_lat = 74.9272, 31.4519
            test_point = Point(test_lon, test_lat)
            temp_farm = Farm(
                farmer_id=farmer.id,
                name="Rollback Test Farm",
                area_acres=4.5,
                paddy_variety="PR-126",
                location=from_shape(test_point, srid=4326),
            )
            db.add(temp_farm)
            db.flush()

            saved_farm_id = temp_farm.id
            assert saved_farm_id is not None

            # Read back within transaction
            retrieved = db.query(Farm).filter(Farm.id == saved_farm_id).first()
            assert retrieved is not None
            assert retrieved.name == "Rollback Test Farm"

            # Check coordinates
            pt_shape = to_shape(retrieved.location)
            assert isinstance(pt_shape, Point)
            assert round(pt_shape.x, 4) == test_lon
            assert round(pt_shape.y, 4) == test_lat
        finally:
            trans.rollback()
            db.close()

    # Verify outside transaction that no rows were left behind
    with engine.connect() as conn:
        count = conn.execute(
            text("SELECT count(*) FROM farms WHERE name = 'Rollback Test Farm';")
        ).scalar()
        assert count == 0

