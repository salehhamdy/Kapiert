"""OTP delivery channels: a console mock for development and SMTP for real email."""

from __future__ import annotations

import logging
import smtplib
import ssl
from dataclasses import dataclass, field
from email.message import EmailMessage
from typing import Protocol

logger = logging.getLogger("otp.delivery")


class DeliveryError(Exception):
    """The code could not be handed to the delivery channel."""


class OtpDelivery(Protocol):
    def send(self, email: str, code: str, ttl_minutes: int) -> None: ...


@dataclass
class MockDelivery:
    """Development/test channel: keeps codes in memory and logs them.

    Never use in production - it writes the plaintext code to the server log.
    """

    log: bool = True
    outbox: list[tuple[str, str]] = field(default_factory=list)

    def send(self, email: str, code: str, ttl_minutes: int) -> None:
        self.outbox.append((email, code))
        if self.log:
            logger.warning("[MOCK OTP] code for %s is %s (valid %d min)", email, code, ttl_minutes)

    def last_code(self, email: str) -> str | None:
        for to, code in reversed(self.outbox):
            if to == email:
                return code
        return None


@dataclass(frozen=True)
class SmtpConfig:
    host: str
    port: int = 587
    username: str | None = None
    password: str | None = None
    sender: str = "no-reply@localhost"
    timeout_seconds: float = 10.0


class SmtpDelivery:
    """Sends the code by email. Port 465 uses implicit TLS, anything else uses STARTTLS."""

    def __init__(self, config: SmtpConfig) -> None:
        self._config = config

    def send(self, email: str, code: str, ttl_minutes: int) -> None:
        cfg = self._config
        message = EmailMessage()
        message["Subject"] = f"Your Kapiert verification code: {code}"
        message["From"] = cfg.sender
        message["To"] = email
        message.set_content(
            f"Your Kapiert verification code is {code}.\n\n"
            f"It expires in {ttl_minutes} minutes. If you did not request it, ignore this email."
        )
        message.add_alternative(
            "<div style=\"font-family:Arial,sans-serif;max-width:420px\">"
            "<h2>Verify your email</h2>"
            "<p>Your verification code is:</p>"
            f"<p style=\"font-size:32px;letter-spacing:8px;font-weight:700\">{code}</p>"
            f"<p>It expires in {ttl_minutes} minutes. If you did not request it, ignore this email.</p>"
            "</div>",
            subtype="html",
        )

        try:
            context = ssl.create_default_context()
            if cfg.port == 465:
                with smtplib.SMTP_SSL(
                    cfg.host, cfg.port, timeout=cfg.timeout_seconds, context=context
                ) as server:
                    self._login_and_send(server, message)
            else:
                with smtplib.SMTP(cfg.host, cfg.port, timeout=cfg.timeout_seconds) as server:
                    server.starttls(context=context)
                    self._login_and_send(server, message)
        except (smtplib.SMTPException, OSError) as exc:
            raise DeliveryError(str(exc)) from exc

    def _login_and_send(self, server: smtplib.SMTP, message: EmailMessage) -> None:
        if self._config.username:
            server.login(self._config.username, self._config.password or "")
        server.send_message(message)
