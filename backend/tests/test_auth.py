import pytest
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
    generated_otp = _MOCK_OTP_STORE[phone]
    assert len(generated_otp) == 6

    # 2. Verify with the actual generated OTP
    verify_resp = client.post("/auth/otp/verify", json={"phone_e164": phone, "otp": generated_otp})
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
    # If the randomly generated OTP happened to be 123456, force mock store to something else
    _MOCK_OTP_STORE[phone] = "654321"

    resp_mismatch = client.post("/auth/otp/verify", json={"phone_e164": phone, "otp": "123456"})
    assert resp_mismatch.status_code == 400
    assert "Incorrect OTP" in resp_mismatch.json()["detail"]


def test_demo_mode_true_allows_universal_otp(client, monkeypatch):
    """When DEMO_MODE is True, 123456 is accepted as universal bypass."""
    monkeypatch.setattr(settings, "DEMO_MODE", True)
    phone = "+919876542222"

    client.post("/auth/otp/send", json={"phone_e164": phone})
    _MOCK_OTP_STORE[phone] = "999888"

    verify_resp = client.post("/auth/otp/verify", json={"phone_e164": phone, "otp": "123456"})
    assert verify_resp.status_code == 200
    assert "access_token" in verify_resp.json()


def test_verify_wrong_otp(client):
    client.post("/auth/otp/send", json={"phone_e164": "+919876549999"})
    verify_resp = client.post("/auth/otp/verify", json={"phone_e164": "+919876549999", "otp": "000000"})
    assert verify_resp.status_code == 400
    assert "Incorrect OTP" in verify_resp.json()["detail"]


def test_protected_route_without_token(client):
    resp = client.get("/auth/me")
    assert resp.status_code == 403 or resp.status_code == 401
