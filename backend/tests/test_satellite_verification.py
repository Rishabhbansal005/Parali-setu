import uuid
from datetime import date, timedelta
from fastapi.testclient import TestClient

from app.models.user import User
from app.models.offer import Offer
from app.models.booking import Booking
from app.models.weighbridge import WeighbridgeRecord
from app.services.satellite import (
    calculate_nbr,
    calculate_delta_nbr,
    evaluate_burn_status,
    calculate_environmental_impact,
    generate_no_burn_certificate,
    DELTA_NBR_NO_BURN_THRESHOLD,
)

def test_spectral_nbr_calculation():
    # NIR high, SWIR low => healthy vegetation (high positive NBR)
    nbr_healthy = calculate_nbr(nir=0.6, swir=0.1)
    assert nbr_healthy == 0.7143

    # NIR low, SWIR high => burned surface (negative NBR)
    nbr_burned = calculate_nbr(nir=0.1, swir=0.5)
    assert nbr_burned == -0.6667

    # Edge case: zero reflectance
    assert calculate_nbr(nir=0.0, swir=0.0) == 0.0

def test_burn_evaluation_thresholds():
    # Delta NBR < 0.10 => Verified No-Burn
    clean = evaluate_burn_status(delta_nbr=0.045, cloud_cover_pct=5.0)
    assert clean["result_state"] == "verified_no_burn"
    assert clean["burn_detected"] is False
    assert clean["burn_severity"] == "NONE"

    # Delta NBR >= 0.10 => Burn Detected
    burned = evaluate_burn_status(delta_nbr=0.18, cloud_cover_pct=5.0)
    assert burned["result_state"] == "burn_detected"
    assert burned["burn_detected"] is True
    assert burned["burn_severity"] == "MODERATE"

    # Delta NBR >= 0.27 => High Severity Burn
    severe = evaluate_burn_status(delta_nbr=0.35, cloud_cover_pct=2.0)
    assert severe["result_state"] == "burn_detected"
    assert severe["burn_detected"] is True
    assert severe["burn_severity"] == "HIGH"

    # Cloud cover > 30% => Unclear
    cloudy = evaluate_burn_status(delta_nbr=0.02, cloud_cover_pct=45.0)
    assert cloudy["result_state"] == "unclear"
    assert cloudy["burn_detected"] is None

def test_environmental_impact_math():
    impact = calculate_environmental_impact(stubble_tonnes=8.0)
    # 8 tonnes * 1500 kg = 12000 kg CO2 = 12.0 tonnes
    assert impact["co2_avoided_tonnes"] == 12.0
    assert impact["co2_avoided_kg"] == 12000.0
    # 8 tonnes * 18 kg = 144 kg PM2.5
    assert impact["pm25_avoided_kg"] == 144.0
    assert impact["equivalent_trees_planted"] > 0

def test_no_burn_certificate_api_endpoint(client: TestClient, db_session):
    # Setup farmer and booking
    farmer = db_session.query(User).filter(User.phone_e164 == "+919810000001").first()
    if not farmer:
        farmer = User(phone_e164="+919810000001", name="Gurpreet Singh", village="Kot Buddha", district="Tarn Taran")
        db_session.add(farmer)
        db_session.commit()

    offer_uuid = uuid.uuid4()
    offer = Offer(
        id=offer_uuid,
        estimate_id=uuid.uuid4(),
        machine_id=uuid.uuid4(),
        truck_id=uuid.uuid4(),
        buyer_id=uuid.uuid4(),
        proposed_pickup_date=date.today() + timedelta(days=2),
        gross_income_inr=10800.0,
        net_income_inr=5460.0,
    )
    db_session.add(offer)
    db_session.commit()

    booking = Booking(
        id=uuid.uuid4(),
        offer_id=offer.id,
        farmer_id=farmer.id,
        status="paid",
    )
    db_session.add(booking)
    db_session.commit()

    wb = WeighbridgeRecord(
        id=uuid.uuid4(),
        booking_id=booking.id,
        weight_kg=8000.0,
        ticket_number="DK-990011",
        farmer_confirmed=True,
        buyer_confirmed=True,
    )
    db_session.add(wb)
    db_session.commit()

    # Call certificate endpoint
    res = client.get(f"/bookings/{booking.id}/certificate")
    assert res.status_code == 200
    data = res.json()

    assert data["certificate_id"].startswith("CERT-PSETU-")
    assert data["booking_id"] == str(booking.id)
    assert data["farmer_name"] == "Gurpreet Singh"
    assert data["stubble_tonnes"] == 8.0
    assert data["result_state"] == "verified_no_burn"
    assert data["is_valid"] is True
    assert data["co2_avoided_tonnes"] == 12.0
    assert data["pm25_avoided_kg"] == 144.0
    assert data["delta_nbr"] < DELTA_NBR_NO_BURN_THRESHOLD
