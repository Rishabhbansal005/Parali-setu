from __future__ import annotations

import os
from pathlib import Path
from typing import List

from pydantic import field_validator, model_validator
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

    @field_validator("DATABASE_URL", mode="after")
    @classmethod
    def clean_database_url(cls, v: str) -> str:
        if not v:
            return v
        import urllib.parse
        # Ensure scheme is postgresql+psycopg2 for SQLAlchemy
        if v.startswith("postgres://"):
            v = v.replace("postgres://", "postgresql+psycopg2://", 1)
        elif v.startswith("postgresql://") and not v.startswith("postgresql+"):
            v = v.replace("postgresql://", "postgresql+psycopg2://", 1)
        # Strip pgbouncer query parameter which libpq / psycopg2 rejects
        parsed = urllib.parse.urlsplit(v)
        if "pgbouncer" in parsed.query:
            qs = urllib.parse.parse_qs(parsed.query)
            qs.pop("pgbouncer", None)
            new_query = urllib.parse.urlencode(qs, doseq=True)
            v = urllib.parse.urlunsplit((parsed.scheme, parsed.netloc, parsed.path, new_query, parsed.fragment))
        return v

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
    DEMO_MODE: bool = False             # If True, universal OTP '123456' is accepted for DEMO_PHONES only
    DEMO_PHONES: str = ""               # Comma-separated E.164 phone numbers (e.g. "+919810000001,+919810000002")
    ALLOWED_ORIGINS: List[str] = ["http://localhost:3000", "http://localhost:8000"]

    # ── Yield config path ─────────────────────────────────────────────────────
    YIELD_CONFIG_PATH: str = str(Path(__file__).parent / "yield_config.yaml")

    @property
    def demo_phones_list(self) -> List[str]:
        if not self.DEMO_PHONES:
            return []
        return [p.strip() for p in self.DEMO_PHONES.split(",") if p.strip()]

    @model_validator(mode="after")
    def validate_production_secrets(self) -> "Settings":
        if not self.DEBUG:
            placeholders = {
                "",
                "CHANGE_ME_BEFORE_ANY_REAL_DEPLOYMENT",
                "CHANGE_ME_BEFORE_COMMIT",
                "changeme",
                "secret",
            }
            if not self.JWT_SECRET_KEY or self.JWT_SECRET_KEY.strip() in placeholders:
                raise ValueError(
                    "Production configuration error: JWT_SECRET_KEY is missing or still set to a default placeholder "
                    "while running in production mode (DEBUG=False).\n"
                    "How to fix this:\n"
                    "1. On Render / production: Generate a strong random key (e.g. run 'openssl rand -hex 32') and "
                    "set it as the JWT_SECRET_KEY environment variable in your dashboard settings.\n"
                    "2. For local development only: Set DEBUG=true or specify JWT_SECRET_KEY in your backend/.env file."
                )
        return self


settings = Settings()

