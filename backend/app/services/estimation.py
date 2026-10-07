from __future__ import annotations
from pathlib import Path
from typing import Dict, Any, Tuple
import yaml
from app.core.config import settings

def load_yield_config() -> Dict[str, Any]:
    """Reads yield parameters from backend/app/core/yield_config.yaml."""
    cfg_path = Path(settings.YIELD_CONFIG_PATH)
    if not cfg_path.exists():
        raise FileNotFoundError(f"Yield config not found at: {cfg_path}")
    with open(cfg_path, "r", encoding="utf-8") as f:
        return yaml.safe_load(f)

def estimate_stubble(
    area_acres: float,
    paddy_variety: str = "PR-126",
    harvest_method: str = "combine",
    buyer_price_per_tonne_inr: float = 1200.0,
) -> Dict[str, Any]:
    """
    Computes dry stubble yield (tonnes) and estimated gross income range.
    Per SPEC.md §9:
      stubble_dry_weight_tonnes = area_acres * YIELD_FACTOR[variety][harvest_method]
      income_gross = stubble_dry_weight_tonnes * buyer_price_per_tonne_inr
      low = mid * YIELD_RANGE_FACTOR_LOW
      high = mid * YIELD_RANGE_FACTOR_HIGH

    NOTE: All yield values and factors are ASSUMPTIONS and must be verified with KVK/ICAR.
    """
    config = load_yield_config()

    yield_factor_table = config.get("yield_factor", {})
    # Fallback to 'other' or default if variety not in table
    variety_cfg = yield_factor_table.get(paddy_variety) or yield_factor_table.get("other", {"combine": 2.0, "manual": 1.2})
    
    factor = variety_cfg.get(harvest_method, variety_cfg.get("combine", 2.0))

    stubble_mid = round(area_acres * factor, 2)
    range_low = config.get("yield_range_factor_low", 0.80)
    range_high = config.get("yield_range_factor_high", 1.20)

    stubble_low = round(stubble_mid * range_low, 2)
    stubble_high = round(stubble_mid * range_high, 2)

    income_low = round(stubble_low * buyer_price_per_tonne_inr, 2)
    income_high = round(stubble_high * buyer_price_per_tonne_inr, 2)

    return {
        "stubble_tonnes_low": stubble_low,
        "stubble_tonnes_mid": stubble_mid,
        "stubble_tonnes_high": stubble_high,
        "income_low_inr": income_low,
        "income_high_inr": income_high,
        "config_snapshot": {
            "paddy_variety": paddy_variety,
            "harvest_method": harvest_method,
            "yield_factor_t_per_acre": factor,
            "yield_range_factor_low": range_low,
            "yield_range_factor_high": range_high,
            "buyer_price_used_inr": buyer_price_per_tonne_inr,
            "assumption_notice": "ALL FIGURES ARE SIMULATED ESTIMATES (ASSUMPTIONS) PENDING KVK/ICAR VERIFICATION"
        }
    }
