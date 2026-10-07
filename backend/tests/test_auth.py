import pytest

def test_otp_send_and_verify_cycle(client):
    phone = "+919876543210"

    # 1. Send OTP
    send_resp = client.post("/auth/otp/send", json={"phone_e164": phone})
    assert send_resp.status_code == 200
    data = send_resp.json()
    assert data["phone_e164"] == phone
    assert data["is_mock"] is True

    # 2. Verify OTP with universal test OTP 123456
    verify_resp = client.post("/auth/otp/verify", json={"phone_e164": phone, "otp": "123456"})
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

def test_verify_wrong_otp(client):
    client.post("/auth/otp/send", json={"phone_e164": "+919876549999"})
    verify_resp = client.post("/auth/otp/verify", json={"phone_e164": "+919876549999", "otp": "000000"})
    assert verify_resp.status_code == 400
    assert "Incorrect OTP" in verify_resp.json()["detail"]

def test_protected_route_without_token(client):
    resp = client.get("/auth/me")
    assert resp.status_code == 403 or resp.status_code == 401
