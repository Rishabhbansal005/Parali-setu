from __future__ import annotations
from abc import ABC, abstractmethod
from typing import Dict, Any, Optional

class PaymentProvider(ABC):
    """
    Abstract interface for escrow and payment handling.
    Decouples business logic from external gateways (e.g. Razorpay test mode).
    """

    @abstractmethod
    def create_order(self, amount_inr: float, booking_id: str) -> Dict[str, Any]:
        """Create an order / intent."""
        pass

    @abstractmethod
    def hold_escrow(self, order_id: str, amount_inr: float) -> Dict[str, Any]:
        """Simulate holding funds in escrow."""
        pass

    @abstractmethod
    def release_escrow(self, order_id: str, amount_inr: float, destination_account: Optional[str] = None) -> Dict[str, Any]:
        """Release funds to the farmer after weighbridge verification."""
        pass

    @abstractmethod
    def refund(self, order_id: str, amount_inr: float, reason: str) -> Dict[str, Any]:
        """Refund held funds to buyer on cancellation."""
        pass


class MockPaymentProvider(PaymentProvider):
    """
    Skeleton implementation for Day 1.
    All payments are simulated and logged.
    """

    def create_order(self, amount_inr: float, booking_id: str) -> Dict[str, Any]:
        return {
            "status": "SIMULATED_ORDER_CREATED",
            "provider": "mock",
            "order_id": f"mock_order_{booking_id[:8]}",
            "amount_inr": amount_inr,
            "simulated": True
        }

    def hold_escrow(self, order_id: str, amount_inr: float) -> Dict[str, Any]:
        return {
            "status": "SIMULATED_ESCROW_HELD",
            "provider": "mock",
            "order_id": order_id,
            "amount_inr": amount_inr,
            "simulated": True
        }

    def release_escrow(self, order_id: str, amount_inr: float, destination_account: Optional[str] = None) -> Dict[str, Any]:
        return {
            "status": "SIMULATED_ESCROW_RELEASED",
            "provider": "mock",
            "order_id": order_id,
            "amount_inr": amount_inr,
            "destination": destination_account or "farmer_mock_wallet",
            "simulated": True
        }

    def refund(self, order_id: str, amount_inr: float, reason: str) -> Dict[str, Any]:
        return {
            "status": "SIMULATED_REFUNDED",
            "provider": "mock",
            "order_id": order_id,
            "amount_inr": amount_inr,
            "reason": reason,
            "simulated": True
        }


def get_payment_provider() -> PaymentProvider:
    return MockPaymentProvider()
