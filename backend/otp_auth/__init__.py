"""Self-contained OTP verification service (generate, deliver, verify, rate-limit)."""

from .delivery import DeliveryError, MockDelivery, OtpDelivery, SmtpConfig, SmtpDelivery
from .service import (
    OtpConfig,
    OtpError,
    OtpService,
    SendResult,
    VerifyResult,
    normalize_email,
)
from .store import OtpStore

__all__ = [
    "DeliveryError",
    "MockDelivery",
    "OtpConfig",
    "OtpDelivery",
    "OtpError",
    "OtpService",
    "OtpStore",
    "SendResult",
    "SmtpConfig",
    "SmtpDelivery",
    "VerifyResult",
    "normalize_email",
]
