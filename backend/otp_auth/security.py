"""Cryptographic helpers: OTP generation, keyed hashing, constant-time comparison."""

from __future__ import annotations

import hashlib
import hmac
import secrets

OTP_LENGTH = 6


def generate_otp(length: int = OTP_LENGTH) -> str:
    """Return a zero-padded numeric code drawn from the OS CSPRNG (``secrets``).

    ``random`` is deliberately not used: its output is predictable once enough
    values have been observed.
    """
    return f"{secrets.randbelow(10**length):0{length}d}"


def generate_salt() -> str:
    return secrets.token_hex(16)


def hash_otp(code: str, *, email: str, salt: str, pepper: str) -> str:
    """HMAC-SHA256 of ``email:salt:code`` keyed with a server-side secret (the pepper).

    A 6-digit code has only 1,000,000 possible values, so a plain hash could be
    brute-forced offline in milliseconds if the database leaked. Keying the hash
    with a secret that lives outside the database (``OTP_PEPPER``) removes that
    shortcut; the per-code salt and email binding stop one code being replayed
    against another account.
    """
    message = f"{email}:{salt}:{code}".encode("utf-8")
    return hmac.new(pepper.encode("utf-8"), message, hashlib.sha256).hexdigest()


def verify_otp_hash(
    code: str,
    expected_hash: str,
    *,
    email: str,
    salt: str,
    pepper: str,
) -> bool:
    """Constant-time check so response timing leaks nothing about matching digits."""
    candidate = hash_otp(code, email=email, salt=salt, pepper=pepper)
    return hmac.compare_digest(candidate, expected_hash)
