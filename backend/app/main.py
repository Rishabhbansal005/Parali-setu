from __future__ import annotations
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core.config import settings
from app.api import auth, farmers, estimates, matching, bookings, voice

app = FastAPI(
    title=settings.APP_NAME,
    description="ParaliSetu Backend API — Stubble aggregation, logistics matching, and simulated escrow",
    version="0.1.0",
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register routers
app.include_router(auth.router)
app.include_router(farmers.router)
app.include_router(estimates.router)
app.include_router(matching.router)
app.include_router(bookings.router)
app.include_router(voice.router)


@app.get("/health", tags=["system"])
def health_check():
    return {
        "status": "ok",
        "app": settings.APP_NAME,
        "mode": "development",
        "simulation": True,
    }
