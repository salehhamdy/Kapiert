"""Builds an ``OtpService`` from environment-driven settings."""

from __future__ import annotations

import logging
import secrets

from config import Settings

from .delivery import MockDelivery, OtpDelivery, SmtpConfig, SmtpDelivery
from .service import OtpConfig, OtpService
from .store import OtpStore

logger = logging.getLogger("otp.factory")


def build_delivery(settings: Settings) -> OtpDelivery:
    if settings.otp_delivery == "smtp":
        if not settings.smtp_host:
            raise RuntimeError("OTP_DELIVERY=smtp requires SMTP_HOST to be set.")
        return SmtpDelivery(
            SmtpConfig(
                host=settings.smtp_host,
                port=settings.smtp_port,
                username=settings.smtp_username,
                password=settings.smtp_password,
                sender=settings.smtp_from or settings.smtp_username or "no-reply@localhost",
            )
        )
    if settings.otp_delivery == "mock":
        logger.warning("OTP_DELIVERY=mock: codes are written to the log. Development only.")
        return MockDelivery()
    raise RuntimeError(f"Unknown OTP_DELIVERY '{settings.otp_delivery}' (use 'mock' or 'smtp').")


def build_otp_service(settings: Settings) -> OtpService:
    pepper = settings.otp_pepper
    if not pepper:
        if settings.otp_delivery != "mock":
            # An ephemeral pepper would invalidate every outstanding code on restart and
            # break multi-worker deployments, so refuse to start instead.
            raise RuntimeError("OTP_PEPPER must be set unless OTP_DELIVERY=mock.")
        pepper = secrets.token_hex(32)
        logger.warning("OTP_PEPPER not set: using a random per-process pepper (dev only).")

    return OtpService(
        store=OtpStore(settings.otp_db_path),
        delivery=build_delivery(settings),
        config=OtpConfig(
            pepper=pepper,
            ttl_seconds=settings.otp_ttl_seconds,
            max_attempts=settings.otp_max_attempts,
            resend_cooldown_seconds=settings.otp_resend_cooldown_seconds,
            max_sends_per_hour=settings.otp_max_sends_per_hour,
        ),
    )
