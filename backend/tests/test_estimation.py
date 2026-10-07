import pytest
from app.services.estimation import estimate_stubble

def test_estimate_stubble_pr126_combine():
    # 4 acres of PR-126 harvested by combine
    # Yield factor in yield_config.yaml is 2.0 t/acre (ASSUMPTION)
    res = estimate_stubble(area_acres=4.0, paddy_variety="PR-126", harvest_method="combine", buyer_price_per_tonne_inr=1200.0)

    # 4.0 * 2.0 = 8.0 tonnes
    assert res["stubble_tonnes_mid"] == 8.0
    # ± 20%: low = 8.0 * 0.8 = 6.4, high = 8.0 * 1.2 = 9.6
    assert res["stubble_tonnes_low"] == 6.4
    assert res["stubble_tonnes_high"] == 9.6

    # Income: 6.4 * 1200 = 7680, 9.6 * 1200 = 11520
    assert res["income_low_inr"] == 7680.0
    assert res["income_high_inr"] == 11520.0
    assert "assumption_notice" in res["config_snapshot"]

def test_estimate_stubble_pusa44_manual():
    # 2.5 acres of Pusa-44 harvested manually
    # Yield factor in yield_config.yaml is 1.5 t/acre (ASSUMPTION)
    res = estimate_stubble(area_acres=2.5, paddy_variety="Pusa-44", harvest_method="manual", buyer_price_per_tonne_inr=1000.0)

    # 2.5 * 1.5 = 3.75 tonnes
    assert res["stubble_tonnes_mid"] == 3.75
    # ± 20%: low = 3.75 * 0.8 = 3.0, high = 3.75 * 1.2 = 4.5
    assert res["stubble_tonnes_low"] == 3.0
    assert res["stubble_tonnes_high"] == 4.5

    assert res["income_low_inr"] == 3000.0
    assert res["income_high_inr"] == 4500.0

def test_estimate_stubble_fallback_variety():
    # Unknown variety falls back to 'other' (2.0 combine)
    res = estimate_stubble(area_acres=5.0, paddy_variety="Unknown-Paddy-X", harvest_method="combine")
    assert res["stubble_tonnes_mid"] == 10.0
