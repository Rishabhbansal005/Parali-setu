import pytest
from datetime import date, timedelta
from fastapi.testclient import TestClient

from app.main import app
from app.services.matching import find_matched_bundles, haversine_distance
from app.schemas.matching import MatchBundleRequest

def test_haversine_distance():
    # Distance between Sangrur (30.25, 75.85) and Nabha (30.37, 76.15) is ~32 km
    dist = haversine_distance(30.25, 75.85, 30.37, 76.15)
    assert 28.0 <= dist <= 36.0

    # Same location should be 0.0
    zero_dist = haversine_distance(30.25, 75.85, 30.25, 75.85)
    assert zero_dist == 0.0

def test_matching_engine_solver():
    harvest_d = date.today() + timedelta(days=3)
    req = MatchBundleRequest(
        acres=5.0,
        paddy_variety="PR-126",
        harvest_date=harvest_d,
        stubble_tonnes=10.0,
        latitude=30.25,
        longitude=75.85,
    )

    response = find_matched_bundles(req=req)
    assert response.solver_status in ["OPTIMAL", "FEASIBLE"]
    assert len(response.bundles) >= 2
    assert response.stubble_tonnes == 10.0
    assert response.execution_time_ms >= 0.0

    # Check top bundle
    top_bundle = response.bundles[0]
    assert top_bundle.rank == 1
    assert top_bundle.tag in ["BEST_VALUE", "FASTEST", "LOCAL_GREEN"]
    assert top_bundle.machine_cost_inr > 0
    assert top_bundle.transport_cost_inr > 0
    assert top_bundle.gross_income_inr > 0
    
    # Financial sanity check: Gross - Machine - Transport == Net
    expected_net = round(top_bundle.gross_income_inr - top_bundle.machine_cost_inr - top_bundle.transport_cost_inr, 2)
    assert abs(top_bundle.net_income_inr - expected_net) <= 0.05

    # Environmental impact check: CO2 = 1.5 * 10 = 15.0 t, PM2.5 = 18.0 * 10 = 180.0 kg
    assert top_bundle.co2_saved_tonnes == 15.0
    assert top_bundle.pm25_avoided_kg == 180.0

def test_matching_api_endpoint(client: TestClient):
    payload = {
        "acres": 4.0,
        "paddy_variety": "PR-126",
        "harvest_date": str(date.today() + timedelta(days=2)),
        "stubble_tonnes": 8.0,
        "latitude": 30.25,
        "longitude": 75.85,
    }

    res = client.post("/matching/find-bundles", json=payload)
    assert res.status_code == 200
    data = res.json()
    assert "bundles" in data
    assert len(data["bundles"]) >= 2
    assert data["stubble_tonnes"] == 8.0

    # Check languages are populated for bundle tags
    b1 = data["bundles"][0]
    assert "tag_label_en" in b1
    assert "tag_label_hi" in b1
    assert "tag_label_pa" in b1
