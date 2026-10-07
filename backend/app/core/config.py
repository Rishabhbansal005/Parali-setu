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
        env_file=[
            Path(__file__).resolve().parents[2] / ".env",  # backend/.env
            Path(__file__).resolve().parents[3] / ".env",  # root/.env
        ],
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

    # ── OTP & Rate Limiting ───────────────────────────────────────────────────
    OTP_PROVIDER: str = "mock"          # 'mock' | 'firebase' | 'msg91'
    OTP_EXPIRY_SECONDS: int = 300       # 5 minutes
    OTP_MAX_SENDS_PER_WINDOW: int = 5   # Max OTP send requests within window
    OTP_SEND_WINDOW_SECONDS: int = 600  # 10 minute send throttling window
    OTP_MAX_VERIFY_ATTEMPTS: int = 5    # Max wrong OTP attempts before lockout
    OTP_LOCKOUT_SECONDS: int = 300      # 5 minute lockout duration

    # ── Payment ───────────────────────────────────────────────────────────────
    PAYMENT_PROVIDER: str = "mock"      # 'mock' | 'razorpay'

    # ── App ───────────────────────────────────────────────────────────────────
    APP_NAME: str = "ParaliSetu API"
    DEBUG: bool = False
    DEMO_MODE: bool = False             # If True, universal OTP '123456' is accepted
    ALLOWED_ORIGINS: List[str] = ["http://localhost:3000", "http://localhost:8000"]

    # ── Yield config path ─────────────────────────────────────────────────────
    YIELD_CONFIG_PATH: str = str(Path(__file__).parent / "yield_config.yaml")


settings = Settings()
