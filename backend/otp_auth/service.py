"""OTP business logic: issue codes, verify them, enforce expiry and rate limits."""

from __future__ import annotations

import math
import re
import time
from dataclasses import dataclass
from typing import Callable

from .delivery import DeliveryError, OtpDelivery
from .security import generate_otp, generate_salt, hash_otp, verify_otp_hash
from .store import OtpStore

_EMAIL_RE = re.compile(r"^[^@\s]+@[^@\s]+\.[^@\s]+$")
_PURGE_AFTER_SECONDS = 24 * 3600
_HOUR = 3600


def normalize_email(raw: str) -> str:
    """Trim + lower-case, then validate. Raises ``ValueError`` for anything malformed."""
    email = raw.strip().lower()
    if len(email) > 254 or not _EMAIL_RE.match(email):
        raise ValueError("Enter a valid email address.")
    return email


class OtpError(Exception):
    """A client-facing failure. ``code`` is stable and machine-readable for the frontend."""

    def __init__(
        self,
        code: str,
        message: str,
        status_code: int = 400,
        *,
        retry_after: int | None = None,
        **extra: object,
    ) -> None:
        super().__init__(message)
        self.code = code
        self.message = message
        self.status_code = status_code
        self.retry_after = retry_after
        self.extra = extra


@dataclass(frozen=True)
class OtpConfig:
    pepper: str
    ttl_seconds: int = 300  # 5 minutes
    max_attempts: int = 5  # wrong guesses allowed per code
    resend_cooldown_seconds: int = 60
    max_sends_per_hour: int = 5


@dataclass(frozen=True)
class SendResult:
    expires_in_seconds: int
    resend_after_seconds: int


@dataclass(frozen=True)
class VerifyResult:
    email: str
    verified_at: float


class OtpService:
    def __init__(
        self,
        store: OtpStore,
        delivery: OtpDelivery,
        config: OtpConfig,
        clock: Callable[[], float] = time.time,
    ) -> None:
        if not config.pepper:
            raise ValueError("OtpConfig.pepper must not be empty.")
        self._store = store
        self._delivery = delivery
        self._config = config
        self._clock = clock

    # ------------------------------------------------------------------ send
    def send_otp(self, email: str) -> SendResult:
        email = normalize_email(email)
        cfg = self._config
        now = self._clock()
        code = generate_otp()
        salt = generate_salt()
        code_hash = hash_otp(code, email=email, salt=salt, pepper=cfg.pepper)

        with self._store.transaction() as tx:
            tx.purge_older_than(now - _PURGE_AFTER_SECONDS)
            user_id = tx.get_or_create_user(email, now)

            last = tx.latest_otp(user_id)
            if last is not None and now - last.created_at < cfg.resend_cooldown_seconds:
                wait = math.ceil(cfg.resend_cooldown_seconds - (now - last.created_at))
                raise OtpError(
                    "resend_too_soon",
                    f"Please wait {wait}s before requesting another code.",
                    429,
                    retry_after=wait,
                )

            window_start = now - _HOUR
            if tx.count_created_since(user_id, window_start) >= cfg.max_sends_per_hour:
                oldest_blocking = tx.nth_latest_created_since(
                    user_id, window_start, cfg.max_sends_per_hour
                )
                wait = (
                    max(1, math.ceil(oldest_blocking + _HOUR - now))
                    if oldest_blocking is not None
                    else _HOUR
                )
                raise OtpError(
                    "send_limit_exceeded",
                    "Too many codes requested. Try again later.",
                    429,
                    retry_after=wait,
                )

            # Only the newest code may be valid, so old ones can't be guessed in parallel.
            tx.invalidate_unused(user_id)
            tx.insert_otp(user_id, code_hash, salt, now + cfg.ttl_seconds, now)

        try:
            self._delivery.send(email, code, max(1, cfg.ttl_seconds // 60))
        except DeliveryError:
            with self._store.transaction() as tx:
                user_id = tx.get_user_id(email)
                if user_id is not None:
                    tx.invalidate_unused(user_id)
            raise OtpError(
                "delivery_failed",
                "We could not send the code. Please try again shortly.",
                502,
            ) from None

        return SendResult(
            expires_in_seconds=cfg.ttl_seconds,
            resend_after_seconds=cfg.resend_cooldown_seconds,
        )

    # ---------------------------------------------------------------- verify
    def verify_otp(self, email: str, code: str) -> VerifyResult:
        email = normalize_email(email)
        cfg = self._config
        now = self._clock()

        error: OtpError | None = None
        result: VerifyResult | None = None

        # One IMMEDIATE transaction: read, count the attempt, compare and mark used are
        # atomic, so parallel guesses cannot exceed ``max_attempts``.
        with self._store.transaction() as tx:
            user_id = tx.get_user_id(email)
            otp = tx.latest_otp(user_id) if user_id is not None else None

            if otp is None or otp.is_used:
                error = OtpError(
                    "no_active_code", "No active code. Request a new one.", 400
                )
            elif otp.expires_at <= now:
                error = OtpError(
                    "expired_code", "This code has expired. Request a new one.", 400
                )
            elif otp.attempts >= cfg.max_attempts:
                error = self._locked_error()
            else:
                # Count the attempt first: it is persisted even when the code is wrong.
                attempts = tx.increment_attempts(otp.id)
                if verify_otp_hash(
                    code,
                    otp.code_hash,
                    email=email,
                    salt=otp.salt,
                    pepper=cfg.pepper,
                ):
                    tx.mark_used(otp.id)
                    tx.mark_user_verified(otp.user_id, now)
                    result = VerifyResult(email=email, verified_at=now)
                else:
                    remaining = cfg.max_attempts - attempts
                    if remaining <= 0:
                        error = self._locked_error()
                    else:
                        error = OtpError(
                            "invalid_code",
                            "Incorrect code.",
                            400,
                            attempts_remaining=remaining,
                        )

        if error is not None:
            raise error
        assert result is not None
        return result

    @staticmethod
    def _locked_error() -> OtpError:
        return OtpError(
            "too_many_attempts",
            "Too many incorrect attempts. Request a new code.",
            429,
        )
