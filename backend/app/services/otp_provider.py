from __future__ import annotations
from abc import ABC, abstractmethod

class OtpProvider(ABC):
    """Abstract base class for SMS/WhatsApp OTP delivery."""

    @abstractmethod
    def send_otp(self, phone_e164: str, otp: str) -> bool:
        """Deliver the OTP to the specified E.164 phone number."""
        pass


class MockOtpProvider(OtpProvider):
    """
    Mock implementation for local development and tests.
    Prints the OTP to the console/logs instead of sending a real SMS.
    """

    def send_otp(self, phone_e164: str, otp: str) -> bool:
        print(f"\n==========================================")
        print(f" [MOCK OTP] Sent to: {phone_e164} | OTP: {otp}")
        print(f"==========================================\n")
        return True


def get_otp_provider() -> OtpProvider:
    # Always returns MockOtpProvider for now; can switch on settings.OTP_PROVIDER
    return MockOtpProvider()
