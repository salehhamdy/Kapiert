"""OTP endpoints: POST /api/send-otp and POST /api/verify-otp (plus a demo page)."""

from __future__ import annotations

from functools import lru_cache
from pathlib import Path

from fastapi import APIRouter, Depends, HTTPException, Response
from fastapi.responses import FileResponse
from pydantic import BaseModel, Field, field_validator

from config import get_settings
from otp_auth import OtpError, OtpService, normalize_email
from otp_auth.factory import build_otp_service

router = APIRouter(tags=["otp"])

_DEMO_PAGE = Path(__file__).resolve().parent.parent / "static" / "otp_demo.html"


@lru_cache
def get_otp_service() -> OtpService:
    """Built lazily on first use so the dictionary API never depends on OTP config."""
    return build_otp_service(get_settings())


class SendOtpRequest(BaseModel):
    email: str = Field(max_length=254)

    @field_validator("email")
    @classmethod
    def _normalise_email(cls, value: str) -> str:
        return normalize_email(value)


class VerifyOtpRequest(SendOtpRequest):
    # [0-9] rather than \d: \d also matches non-ASCII digits (e.g. Arabic-Indic).
    code: str = Field(pattern=r"^[0-9]{6}$")


class SendOtpResponse(BaseModel):
    status: str = "sent"
    expires_in_seconds: int
    resend_after_seconds: int


class VerifyOtpResponse(BaseModel):
    verified: bool
    email: str


def _to_http(exc: OtpError) -> HTTPException:
    detail: dict[str, object] = {"code": exc.code, "message": exc.message, **exc.extra}
    headers: dict[str, str] | None = None
    if exc.retry_after is not None:
        detail["retry_after_seconds"] = exc.retry_after
        headers = {"Retry-After": str(exc.retry_after)}
    return HTTPException(status_code=exc.status_code, detail=detail, headers=headers)


@router.post("/api/send-otp", response_model=SendOtpResponse)
def send_otp(
    body: SendOtpRequest,
    response: Response,
    service: OtpService = Depends(get_otp_service),
) -> SendOtpResponse:
    """Generate a 6-digit code, store only its keyed hash, and deliver it."""
    response.headers["Cache-Control"] = "no-store"
    try:
        result = service.send_otp(body.email)
    except OtpError as exc:
        raise _to_http(exc) from None
    return SendOtpResponse(
        expires_in_seconds=result.expires_in_seconds,
        resend_after_seconds=result.resend_after_seconds,
    )


@router.post("/api/verify-otp", response_model=VerifyOtpResponse)
def verify_otp(
    body: VerifyOtpRequest,
    response: Response,
    service: OtpService = Depends(get_otp_service),
) -> VerifyOtpResponse:
    """Check the code: must match, be unexpired, unused, and within the attempt limit."""
    response.headers["Cache-Control"] = "no-store"
    try:
        result = service.verify_otp(body.email, body.code)
    except OtpError as exc:
        raise _to_http(exc) from None
    return VerifyOtpResponse(verified=True, email=result.email)


@router.get("/otp-demo", include_in_schema=False)
def otp_demo_page() -> FileResponse:
    """Standalone frontend for trying the two endpoints in a browser."""
    return FileResponse(_DEMO_PAGE, media_type="text/html")
