import pytest
import time
from app.core.config import settings, Settings
from app.api.auth import _MOCK_OTP_STORE

def test_demo_mode_defaults_to_false(monkeypatch):
    """Verify DEMO_MODE defaults to False if the variable is missing."""
    monkeypatch.delenv("DEMO_MODE", raising=False)
    fresh_settings = Settings(_env_file=None)
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


def test_jwt_secret_guard_refuses_placeholder_in_production(monkeypatch):
    """When DEBUG=False, app/Settings must refuse to start if JWT_SECRET_KEY is empty or placeholder."""
    monkeypatch.delenv("JWT_SECRET_KEY", raising=False)
    with pytest.raises(ValueError, match="JWT_SECRET_KEY is missing or still set to a default placeholder"):
        Settings(_env_file=None, DEBUG=False, JWT_SECRET_KEY="CHANGE_ME_BEFORE_ANY_REAL_DEPLOYMENT")

    with pytest.raises(ValueError, match="JWT_SECRET_KEY is missing or still set to a default placeholder"):
        Settings(_env_file=None, DEBUG=False, JWT_SECRET_KEY="your-super-secret-jwt-key-change-in-production")

    with pytest.raises(ValueError, match="JWT_SECRET_KEY is missing or still set to a default placeholder"):
        Settings(_env_file=None, DEBUG=False, JWT_SECRET_KEY="")


def test_jwt_secret_guard_refuses_short_secret_in_production(monkeypatch):
    """When DEBUG=False, app/Settings must refuse to start if JWT_SECRET_KEY is shorter than 32 characters."""
    monkeypatch.delenv("JWT_SECRET_KEY", raising=False)
    with pytest.raises(ValueError, match="JWT_SECRET_KEY is shorter than 32 characters"):
        Settings(_env_file=None, DEBUG=False, JWT_SECRET_KEY="too-short-key-under-32-chars")


def test_jwt_secret_guard_allows_valid_secret_in_production():
    """When DEBUG=False, a strong non-placeholder secret of at least 32 characters must start normally."""
    s = Settings(_env_file=None, DEBUG=False, JWT_SECRET_KEY="a-very-strong-32-byte-secret-key-for-prod")
    assert s.JWT_SECRET_KEY == "a-very-strong-32-byte-secret-key-for-prod"


def test_jwt_secret_guard_allows_placeholder_when_debug_is_true():
    """When DEBUG=True, placeholder is allowed for local developer ease."""
    s = Settings(_env_file=None, DEBUG=True, JWT_SECRET_KEY="CHANGE_ME_BEFORE_ANY_REAL_DEPLOYMENT")
    assert s.JWT_SECRET_KEY == "CHANGE_ME_BEFORE_ANY_REAL_DEPLOYMENT"


def test_demo_mode_false_rejects_universal_otp(client, monkeypatch):
    """When DEMO_MODE is False (default), 123456 must be rejected for all numbers, even if in DEMO_PHONES."""
    monkeypatch.setattr(settings, "DEMO_MODE", False)
    monkeypatch.setattr(settings, "DEMO_PHONES", "+919810000001,+919810000002")
    phone = "+919810000001"

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


def test_demo_mode_true_with_allow_list(client, monkeypatch):
    """When DEMO_MODE is True, 123456 is accepted ONLY for phone numbers in DEMO_PHONES."""
    monkeypatch.setattr(settings, "DEMO_MODE", True)
    monkeypatch.setattr(settings, "DEMO_PHONES", "+919810000001,+919810000002")

    demo_phone = "+919810000001"
    non_demo_phone = "+919810000099"

    # 1. Allow-listed demo phone with 123456 is accepted
    verify_resp = client.post("/auth/otp/verify", json={"phone_e164": demo_phone, "otp": "123456"})
    assert verify_resp.status_code == 200
    assert "access_token" in verify_resp.json()

    # 2. Non-demo phone without prior send: rejected
    resp_no_req = client.post("/auth/otp/verify", json={"phone_e164": non_demo_phone, "otp": "123456"})
    assert resp_no_req.status_code == 400

    # 3. Non-demo phone with OTP sent: 123456 is rejected if it doesn't match generated OTP
    client.post("/auth/otp/send", json={"phone_e164": non_demo_phone})
    _MOCK_OTP_STORE[non_demo_phone].otp = "777888"
    resp_other = client.post("/auth/otp/verify", json={"phone_e164": non_demo_phone, "otp": "123456"})
    assert resp_other.status_code == 400
    assert "Incorrect OTP" in resp_other.json()["detail"]



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


def test_get_and_patch_profile(client):
    phone = "+919876547777"
    client.post("/auth/otp/send", json={"phone_e164": phone})
    otp = _MOCK_OTP_STORE[phone].otp
    auth_resp = client.post("/auth/otp/verify", json={"phone_e164": phone, "otp": otp})
    assert auth_resp.status_code == 200
    token = auth_resp.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    # 1. GET /auth/me returns name, phone, role, language, village, district
    get_resp = client.get("/auth/me", headers=headers)
    assert get_resp.status_code == 200
    data = get_resp.json()
    assert data["phone"] == phone
    assert data["phone_e164"] == phone
    assert data["role"] == "farmer"
    assert data["roles"] == ["farmer"]
    assert data["language"] in ("en", "hi", "pa")
    assert data["name"] is not None

    # 2. PATCH /auth/me with Punjabi language and village/district
    patch_resp = client.patch(
        "/auth/me",
        headers=headers,
        json={
            "name": "Gurpreet Singh",
            "language": "pa",
            "village": "Kot Buddha",
            "district": "Tarn Taran",
        },
    )
    assert patch_resp.status_code == 200
    updated = patch_resp.json()
    assert updated["name"] == "Gurpreet Singh"
    assert updated["language"] == "pa"
    assert updated["preferred_language"] == "pa"
    assert updated["village"] == "Kot Buddha"
    assert updated["district"] == "Tarn Taran"

    # 3. GET /auth/me verifies persistence
    verify_get = client.get("/auth/me", headers=headers)
    assert verify_get.status_code == 200
    assert verify_get.json()["name"] == "Gurpreet Singh"
    assert verify_get.json()["language"] == "pa"
    assert verify_get.json()["village"] == "Kot Buddha"

    # 4. PATCH with English and Hindi works
    patch_en = client.patch("/auth/me", headers=headers, json={"language": "en"})
    assert patch_en.status_code == 200
    assert patch_en.json()["language"] == "en"

    patch_hi = client.patch("/auth/me", headers=headers, json={"language": "hi"})
    assert patch_hi.status_code == 200
    assert patch_hi.json()["language"] == "hi"

    # 5. Invalid language rejected with 400
    invalid_lang = client.patch("/auth/me", headers=headers, json={"language": "fr"})
    assert invalid_lang.status_code == 400
    assert "Invalid language" in invalid_lang.json()["detail"]

    # 6. Name exceeding 100 characters rejected with 400 or 422
    long_name = client.patch("/auth/me", headers=headers, json={"name": "A" * 105})
    assert long_name.status_code in (400, 422)


def test_patch_profile_unauthorized(client):
    """Only the authenticated owner can update their profile."""
    resp = client.patch("/auth/me", json={"name": "Unauthorized Haxor"})
    assert resp.status_code in (401, 403)


def test_token_refresh_lifecycle(client):
    phone = "+919876548888"
    client.post("/auth/otp/send", json={"phone_e164": phone})
    otp = _MOCK_OTP_STORE[phone].otp
    auth_resp = client.post("/auth/otp/verify", json={"phone_e164": phone, "otp": otp})
    assert auth_resp.status_code == 200
    tokens = auth_resp.json()

    # 1. Successful refresh
    refresh_resp = client.post("/auth/token/refresh", json={"refresh_token": tokens["refresh_token"]})
    assert refresh_resp.status_code == 200
    new_tokens = refresh_resp.json()
    assert "access_token" in new_tokens
    assert "refresh_token" in new_tokens

    # 2. Access /auth/me with newly minted access token
    headers = {"Authorization": f"Bearer {new_tokens['access_token']}"}
    me_resp = client.get("/auth/me", headers=headers)
    assert me_resp.status_code == 200
    assert me_resp.json()["phone"] == phone

    # 3. Invalid token rejected
    bad_resp = client.post("/auth/token/refresh", json={"refresh_token": "malformed.jwt.token"})
    assert bad_resp.status_code == 401

    # 4. Access token passed as refresh token rejected
    wrong_type = client.post("/auth/token/refresh", json={"refresh_token": tokens["access_token"]})
    assert wrong_type.status_code == 401

