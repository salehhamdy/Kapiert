"""Application configuration loaded from environment variables."""

from __future__ import annotations

import os
from functools import lru_cache
from pathlib import Path

from dotenv import load_dotenv

load_dotenv()


def _split_csv(value: str | None) -> list[str]:
    if not value:
        return []
    return [item.strip() for item in value.split(",") if item.strip()]


class Settings:
    """Runtime settings for the FastAPI backend."""

    app_name: str = "Der Die Das API"
    app_version: str = "1.0.0"
    app_description: str = "German noun article lookup with Wiktionary fallback"

    # Dataset
    nouns_csv_path: str | None = os.environ.get("NOUNS_CSV_PATH")

    # Server
    host: str = os.environ.get("HOST", "0.0.0.0")
    port: int = int(os.environ.get("PORT", "8000"))
    reload: bool = os.environ.get("RELOAD", "false").lower() == "true"

    # CORS — comma-separated origins; "*" allows all (default for mobile clients)
    allowed_origins: list[str] = _split_csv(os.environ.get("ALLOWED_ORIGINS")) or ["*"]

    # Wiktionary
    wiktionary_timeout_seconds: float = float(os.environ.get("WIKTIONARY_TIMEOUT", "5.0"))
    wiktionary_user_agent: str = os.environ.get(
        "WIKTIONARY_USER_AGENT",
        "Kapiert/1.0 (https://github.com/kapiert) httpx/0.28",
    )

    # Supabase (optional — reserved for future protected endpoints)
    supabase_url: str | None = os.environ.get("SUPABASE_URL")
    supabase_jwt_secret: str | None = os.environ.get("SUPABASE_JWT_SECRET")
    supabase_enabled: bool = bool(supabase_url and supabase_jwt_secret)

    # OTP verification service (see docs/OTP_SERVICE.md)
    otp_db_path: str = os.environ.get(
        "OTP_DB_PATH", str(Path(__file__).with_name("otp.sqlite3"))
    )
    otp_pepper: str | None = os.environ.get("OTP_PEPPER")
    otp_delivery: str = os.environ.get("OTP_DELIVERY", "mock").strip().lower()
    otp_ttl_seconds: int = int(os.environ.get("OTP_TTL_SECONDS", "300"))
    otp_max_attempts: int = int(os.environ.get("OTP_MAX_ATTEMPTS", "5"))
    otp_resend_cooldown_seconds: int = int(os.environ.get("OTP_RESEND_COOLDOWN_SECONDS", "60"))
    otp_max_sends_per_hour: int = int(os.environ.get("OTP_MAX_SENDS_PER_HOUR", "5"))

    # SMTP (only used when OTP_DELIVERY=smtp)
    smtp_host: str | None = os.environ.get("SMTP_HOST")
    smtp_port: int = int(os.environ.get("SMTP_PORT", "587"))
    smtp_username: str | None = os.environ.get("SMTP_USERNAME")
    smtp_password: str | None = os.environ.get("SMTP_PASSWORD")
    smtp_from: str | None = os.environ.get("SMTP_FROM")


@lru_cache
def get_settings() -> Settings:
    return Settings()
