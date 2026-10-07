import pytest
import time
from app.core.config import settings, Settings
from app.api.auth import _MOCK_OTP_STORE

def test_demo_mode_defaults_to_false():
    """Verify DEMO_MODE defaults to False if the variable is missing."""
    fresh_settings = Settings()
    assert fresh_settings.DEMO_MODE is False


def test_otp_send_and_verify_cycle(client):
    phone = "+919876543210"

    # 1. Send OTP
    send_resp = client.post("/auth/otp/send", json={"phone_e164": phone})
    assert send_resp.status_code == 200
    data = send_resp.json()
    assert data["phone_e164"] == phone
    assert data["is_mock"] is True

    # Retrieve generated mock OTP from memory store
    state = _MOCK_OTP_STORE[phone]
    assert len(state.otp) == 6

    # 2. Verify with the actual generated OTP
    verify_resp = client.post("/auth/otp/verify", json={"phone_e164": phone, "otp": state.otp})
    assert verify_resp.status_code == 200
    tokens = verify_resp.json()
    assert "access_token" in tokens
    assert "refresh_token" in tokens
    assert tokens["token_type"] == "bearer"

    # 3. Access protected /auth/me
    headers = {"Authorization": f"Bearer {tokens['access_token']}"}
    me_resp = client.get("/auth/me", headers=headers)
    assert me_resp.status_code == 200
    profile = me_resp.json()
    assert profile["phone_e164"] == phone
    assert "farmer" in profile["roles"]

    # 4. Refresh token
    refresh_resp = client.post("/auth/token/refresh", json={"refresh_token": tokens["refresh_token"]})
    assert refresh_resp.status_code == 200
    new_tokens = refresh_resp.json()
    assert "access_token" in new_tokens


def test_demo_mode_false_rejects_universal_otp(client, monkeypatch):
    """When DEMO_MODE is False (default), 123456 must be rejected."""
    monkeypatch.setattr(settings, "DEMO_MODE", False)
    phone = "+919876541111"

    # Case A: No OTP requested
    resp_no_req = client.post("/auth/otp/verify", json={"phone_e164": phone, "otp": "123456"})
    assert resp_no_req.status_code == 400
    assert "No OTP requested" in resp_no_req.json()["detail"]

    # Case B: OTP requested, but user provides 123456 instead of the actual generated code
    client.post("/auth/otp/send", json={"phone_e164": phone})
    _MOCK_OTP_STORE[phone].otp = "654321"

    resp_mismatch = client.post("/auth/otp/verify", json={"phone_e164": phone, "otp": "123456"})
    assert resp_mismatch.status_code == 400
    assert "Incorrect OTP" in resp_mismatch.json()["detail"]


def test_demo_mode_true_allows_universal_otp(client, monkeypatch):
    """When DEMO_MODE is True, 123456 is accepted as universal bypass."""
    monkeypatch.setattr(settings, "DEMO_MODE", True)
    phone = "+919876542222"

    client.post("/auth/otp/send", json={"phone_e164": phone})
    _MOCK_OTP_STORE[phone].otp = "999888"

    verify_resp = client.post("/auth/otp/verify", json={"phone_e164": phone, "otp": "123456"})
    assert verify_resp.status_code == 200
    assert "access_token" in verify_resp.json()


def test_verify_wrong_otp(client):
    phone = "+919876549999"
    client.post("/auth/otp/send", json={"phone_e164": phone})
    verify_resp = client.post("/auth/otp/verify", json={"phone_e164": phone, "otp": "000000"})
    assert verify_resp.status_code == 400
    assert "Incorrect OTP" in verify_resp.json()["detail"]


def test_otp_expiry(client, monkeypatch):
    """Verify that an OTP older than OTP_EXPIRY_SECONDS is rejected."""
    phone = "+919876543333"
    client.post("/auth/otp/send", json={"phone_e164": phone})
    state = _MOCK_OTP_STORE[phone]

    # Fast forward creation time by 301 seconds (past 300s expiry)
    state.created_at = time.time() - (settings.OTP_EXPIRY_SECONDS + 1)

    verify_resp = client.post("/auth/otp/verify", json={"phone_e164": phone, "otp": state.otp})
    assert verify_resp.status_code == 400
    assert "OTP has expired" in verify_resp.json()["detail"]


def test_otp_send_rate_limiting(client, monkeypatch):
    """Verify that exceeding OTP_MAX_SENDS_PER_WINDOW triggers 429 Too Many Requests."""
    phone = "+919876544444"
    # Set limit to 3 for quick test
    monkeypatch.setattr(settings, "OTP_MAX_SENDS_PER_WINDOW", 3)

    for i in range(3):
        resp = client.post("/auth/otp/send", json={"phone_e164": phone})
        assert resp.status_code == 200

    # 4th attempt should be blocked
    resp_blocked = client.post("/auth/otp/send", json={"phone_e164": phone})
    assert resp_blocked.status_code == 429
    assert "Too many OTP requests" in resp_blocked.json()["detail"]


def test_wrong_otp_lockout_and_demo_mode_cannot_bypass_lockout(client, monkeypatch):
    """
    Verify that 5 failed attempts locks the account (429), and even DEMO_MODE=True
    cannot bypass an active lockout.
    """
    phone = "+919876545555"
    monkeypatch.setattr(settings, "OTP_MAX_VERIFY_ATTEMPTS", 5)
    monkeypatch.setattr(settings, "OTP_LOCKOUT_SECONDS", 180)

    client.post("/auth/otp/send", json={"phone_e164": phone})

    # Fail 4 times (returns 400 with remaining attempts count)
    for attempt in range(1, 5):
        resp = client.post("/auth/otp/verify", json={"phone_e164": phone, "otp": "000000"})
        assert resp.status_code == 400
        assert f"{5 - attempt} attempt(s) remaining" in resp.json()["detail"]

    # 5th failed attempt triggers lockout (429)
    resp_5 = client.post("/auth/otp/verify", json={"phone_e164": phone, "otp": "000000"})
    assert resp_5.status_code == 429
    assert "Account locked" in resp_5.json()["detail"]

    # Now enable DEMO_MODE=True: attempt with 123456 must STILL be blocked by lockout!
    monkeypatch.setattr(settings, "DEMO_MODE", True)
    demo_resp = client.post("/auth/otp/verify", json={"phone_e164": phone, "otp": "123456"})
    assert demo_resp.status_code == 429
    assert "temporarily locked" in demo_resp.json()["detail"]


def test_protected_route_without_token(client):
    resp = client.get("/auth/me")
    assert resp.status_code == 403 or resp.status_code == 401
