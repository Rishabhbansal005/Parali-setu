import pytest
import uuid
from datetime import date, timedelta
from fastapi.testclient import TestClient

from app.main import app
from app.models.user import User
from app.models.offer import Offer
from app.models.booking import Booking

def test_booking_and_weighbridge_lifecycle(client: TestClient, db_session):
    # 1. Setup seed records in DB if not present
    farmer = db_session.query(User).filter(User.phone_e164 == "+919810000001").first()
    if not farmer:
        farmer = User(phone_e164="+919810000001", name="Gurpreet Singh")
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
        machine_cost_inr=4800.0,
        transport_cost_inr=540.0,
        gross_income_inr=10800.0,
        net_income_inr=5460.0,
        rank=1,
    )
    db_session.add(offer)
    db_session.commit()

    # 2. Step 1: Create Booking -> locks simulated escrow in 'held'
    res_book = client.post("/bookings", json={"offer_id": str(offer_uuid)})
    assert res_book.status_code == 201
    book_data = res_book.json()
    booking_id = book_data["id"]

    assert book_data["status"] == "confirmed"
    assert book_data["confirmed_at"] is not None
    assert book_data["payment"] is not None
    assert book_data["payment"]["status"] == "held"
    assert book_data["payment"]["escrow_amount_inr"] == 5460.0

    # 3. Step 2: Transition status to 'picked_up'
    res_status = client.patch(f"/bookings/{booking_id}/status", json={"status": "picked_up"})
    assert res_status.status_code == 200
    assert res_status.json()["status"] == "picked_up"
    assert res_status.json()["picked_up_at"] is not None

    # 4. Step 3: Weighbridge error check (Gross <= Tare)
    res_err = client.post(
        f"/bookings/{booking_id}/weighbridge",
        json={"gross_weight_tonnes": 5.0, "tare_weight_tonnes": 6.2},
    )
    assert res_err.status_code == 400

    # 5. Step 4: Submit certified weighbridge ticket (Gross 14.2t - Tare 6.2t = 8.0t Net)
    res_wb = client.post(
        f"/bookings/{booking_id}/weighbridge",
        json={
            "gross_weight_tonnes": 14.2,
            "tare_weight_tonnes": 6.2,
            "ticket_number": "DK-889900",
        },
    )
    assert res_wb.status_code == 200
    wb_data = res_wb.json()

    # Verify Weighbridge Net weight
    assert wb_data["status"] == "paid"
    assert wb_data["weighed_at"] is not None
    assert wb_data["paid_at"] is not None
    assert wb_data["weighbridge_record"] is not None
    assert wb_data["weighbridge_record"]["weight_tonnes"] == 8.0
    assert wb_data["weighbridge_record"]["weight_kg"] == 8000.0
    assert wb_data["weighbridge_record"]["ticket_number"] == "DK-889900"

    # Verify Escrow release to farmer
    assert wb_data["payment"]["status"] == "released"
    assert wb_data["payment"]["released_at"] is not None
    assert wb_data["final_payout_inr"] == 5460.0
