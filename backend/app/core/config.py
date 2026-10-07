from __future__ import annotations

import os
from pathlib import Path
from typing import List

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """
    All configuration is read from environment variables or a .env file.
    Never hard-code secrets here or anywhere else in the codebase.
    """

    model_config = SettingsConfigDict(
        env_file=Path(__file__).resolve().parents[3] / ".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )

    # ── Database ──────────────────────────────────────────────────────────────
    DATABASE_URL: str = (
        "postgresql+psycopg2://paralisetu:paralisetu_dev@localhost:5432/paralisetu"
    )

    # ── JWT ───────────────────────────────────────────────────────────────────
    JWT_SECRET_KEY: str = "CHANGE_ME_BEFORE_ANY_REAL_DEPLOYMENT"
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60
    REFRESH_TOKEN_EXPIRE_DAYS: int = 30

    # ── OTP ───────────────────────────────────────────────────────────────────
    OTP_PROVIDER: str = "mock"          # 'mock' | 'firebase' | 'msg91'
    OTP_EXPIRY_SECONDS: int = 300       # 5 minutes

    # ── Payment ───────────────────────────────────────────────────────────────
    PAYMENT_PROVIDER: str = "mock"      # 'mock' | 'razorpay'

    # ── App ───────────────────────────────────────────────────────────────────
    APP_NAME: str = "ParaliSetu API"
    DEBUG: bool = False
    ALLOWED_ORIGINS: List[str] = ["http://localhost:3000", "http://localhost:8000"]

    # ── Yield config path ─────────────────────────────────────────────────────
    YIELD_CONFIG_PATH: str = str(Path(__file__).parent / "yield_config.yaml")


settings = Settings()
