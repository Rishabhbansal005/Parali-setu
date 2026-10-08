import os
import sys
from pathlib import Path

# Test-only secret so tests run with valid cryptographic key without touching production
os.environ.setdefault("JWT_SECRET_KEY", "test-secret-key-32-chars-long-strictly-for-unit-tests-only")
os.environ.setdefault("DEBUG", "true")

# Ensure backend directory is in sys.path
backend_path = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(backend_path))

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

from app.core.database import Base

from app.dependencies import get_db
from app.main import app
from app.models.user import User
from app.models.offer import Offer
from app.models.booking import Booking
from app.models.payment import Payment
from app.models.weighbridge import WeighbridgeRecord

# In-memory SQLite for testing
SQLALCHEMY_DATABASE_URL = "sqlite:///:memory:"

engine = create_engine(
    SQLALCHEMY_DATABASE_URL,
    connect_args={"check_same_thread": False},
    poolclass=StaticPool,
)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

@pytest.fixture(scope="session", autouse=True)
def setup_test_db():
    # Only create tables without Geometry triggers for standard unit testing
    tables = [
        User.__table__,
        Offer.__table__,
        Booking.__table__,
        Payment.__table__,
        WeighbridgeRecord.__table__,
    ]
    for table in tables:
        table.create(bind=engine, checkfirst=True)
    yield
    for table in reversed(tables):
        table.drop(bind=engine, checkfirst=True)


@pytest.fixture
def db_session():
    connection = engine.connect()
    transaction = connection.begin()
    session = TestingSessionLocal(bind=connection)
    yield session
    session.close()
    transaction.rollback()
    connection.close()

@pytest.fixture
def client(db_session):
    def override_get_db():
        try:
            yield db_session
        finally:
            pass

    app.dependency_overrides[get_db] = override_get_db
    with TestClient(app) as test_client:
        yield test_client
    app.dependency_overrides.clear()
