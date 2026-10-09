from __future__ import annotations

import pytest
from fastapi.testclient import TestClient
from app.main import app
from app.services.voice_parser import parse_voice_transcript


client = TestClient(app)


def test_voice_parser_hindi_killa():
    transcript = "4 killa PR-126, 25 October"
    res = parse_voice_transcript(transcript, language="hi", reference_date_str="2026-10-20")

    assert res["acres"] == 4.0
    assert res["variety"] == "PR-126"
    assert res["harvest_date"] == "2026-10-25"
    assert res["confidence"] >= 0.90
    assert "4 किल्ला PR-126" in res["confirmation_prompt"]
    assert "सही है?" in res["confirmation_prompt"]


def test_voice_parser_punjabi_gurmukhi():
    transcript = "6 ਕਿੱਲੇ Pusa-44, 28 ਅਕਤੂਬਰ"
    res = parse_voice_transcript(transcript, language="pa", reference_date_str="2026-10-20")

    assert res["acres"] == 6.0
    assert res["variety"] == "Pusa-44"
    assert res["harvest_date"] == "2026-10-28"
    assert res["confidence"] >= 0.90
    assert "6 ਕਿੱਲਾ Pusa-44" in res["confirmation_prompt"]
    assert "ਕੀ ਇਹ ਸਹੀ ਹੈ?" in res["confirmation_prompt"]


def test_voice_parser_bigha_conversion():
    # In Punjab agronomic standard, 5 Bigha = 1 Killa (1 Bigha = 0.20 Acre)
    transcript = "10 bigha Basmati, kal"
    res = parse_voice_transcript(transcript, language="hi", reference_date_str="2026-10-20")

    assert res["acres"] == 2.0  # 10 * 0.20 = 2.0 acres
    assert res["variety"] == "Basmati"
    assert res["harvest_date"] == "2026-10-21"  # kal -> base + 1 day
    assert "2 किल्ला Basmati" in res["confirmation_prompt"]


def test_voice_parser_relative_dates():
    transcript = "चार किल्ले PR 126 परसों"
    res = parse_voice_transcript(transcript, language="hi", reference_date_str="2026-10-20")

    assert res["acres"] == 4.0
    assert res["variety"] == "PR-126"
    assert res["harvest_date"] == "2026-10-22"  # parso -> base + 2 days
    assert res["confidence"] >= 0.85


def test_voice_api_parse_endpoint():
    response = client.post(
        "/voice/parse",
        json={
            "transcript": "5 killa PR-126, 26 October",
            "language": "hi",
            "reference_date": "2026-10-20",
        },
    )
    assert response.status_code == 200
    data = response.json()
    assert data["acres"] == 5.0
    assert data["variety"] == "PR-126"
    assert data["harvest_date"] == "2026-10-26"
    assert "confirmation_prompt" in data
    assert data["confidence"] > 0.85


def test_voice_api_empty_transcript_validation():
    response = client.post(
        "/voice/parse",
        json={"transcript": "   "},
    )
    assert response.status_code == 422
