"""OTP service tests: crypto helpers, expiry, single-use, brute-force limits, HTTP contract."""

from __future__ import annotations

import sqlite3
import threading
from types import SimpleNamespace

import pytest
from fastapi.testclient import TestClient

import otp_auth.service as otp_service_module
from main import app
from otp_auth import (
    MockDelivery,
    OtpConfig,
    OtpError,
    OtpService,
    OtpStore,
)
from otp_auth.delivery import DeliveryError
from otp_auth.security import generate_otp, hash_otp, verify_otp_hash
from routes.otp import get_otp_service

EMAIL = "learner@example.com"


class FakeClock:
    def __init__(self, start: float = 1_000_000.0) -> None:
        self.now = start

    def __call__(self) -> float:
        return self.now

    def advance(self, seconds: float) -> None:
        self.now += seconds


class FailingDelivery:
    def send(self, email: str, code: str, ttl_minutes: int) -> None:
        raise DeliveryError("smtp down")


@pytest.fixture
def make_ctx(tmp_path):
    made = []

    def _make(delivery=None, **config_overrides):
        clock = FakeClock()
        delivery = delivery if delivery is not None else MockDelivery(log=False)
        db = str(tmp_path / f"otp{len(made)}.db")
        service = OtpService(
            OtpStore(db),
            delivery,
            OtpConfig(pepper="test-pepper", **config_overrides),
            clock=clock,
        )
        app.dependency_overrides[get_otp_service] = lambda: service
        # No context manager: skips the lifespan, so the 100k-word dataset isn't loaded.
        ctx = SimpleNamespace(
            client=TestClient(app),
            clock=clock,
            delivery=delivery,
            service=service,
            db=db,
        )
        made.append(ctx)
        return ctx

    yield _make
    app.dependency_overrides.clear()


@pytest.fixture
def ctx(make_ctx):
    return make_ctx()


def send(ctx, email: str = EMAIL):
    return ctx.client.post("/api/send-otp", json={"email": email})


def verify(ctx, code: str, email: str = EMAIL):
    return ctx.client.post("/api/verify-otp", json={"email": email, "code": code})


def issued_code(ctx, email: str = EMAIL) -> str:
    resp = send(ctx, email)
    assert resp.status_code == 200, resp.text
    code = ctx.delivery.last_code(email.strip().lower())
    assert code is not None
    return code


def wrong_code(real: str) -> str:
    return "000000" if real != "000000" else "000001"


# --------------------------------------------------------------------- crypto helpers
def test_generate_otp_is_six_digits_and_not_constant():
    codes = {generate_otp() for _ in range(200)}
    assert all(len(c) == 6 and c.isdigit() for c in codes)
    assert len(codes) > 150  # CSPRNG output, not a fixed or tiny set


def test_hash_is_keyed_salted_and_checked_in_constant_time_helper():
    h = hash_otp("123456", email=EMAIL, salt="s1", pepper="p")
    assert h != hash_otp("123456", email=EMAIL, salt="s2", pepper="p")  # salt matters
    assert h != hash_otp("123456", email=EMAIL, salt="s1", pepper="other")  # pepper matters
    assert h != hash_otp("123456", email="b@example.com", salt="s1", pepper="p")  # bound to email
    assert verify_otp_hash("123456", h, email=EMAIL, salt="s1", pepper="p")
    assert not verify_otp_hash("123457", h, email=EMAIL, salt="s1", pepper="p")


# -------------------------------------------------------------------------- happy path
def test_send_response_and_hashed_storage(ctx):
    resp = send(ctx)
    assert resp.status_code == 200
    assert resp.json() == {
        "status": "sent",
        "expires_in_seconds": 300,
        "resend_after_seconds": 60,
    }
    assert resp.headers["cache-control"] == "no-store"
    assert "code" not in resp.json()  # the code must never be returned to the caller

    code = ctx.delivery.last_code(EMAIL)
    conn = sqlite3.connect(ctx.db)
    row = conn.execute("SELECT code_hash, salt, expires_at, attempts, is_used FROM otps").fetchone()
    conn.close()
    assert len(row[0]) == 64
    assert all(code not in str(value) for value in row)  # no plaintext anywhere
    assert row[2] == ctx.clock.now + 300  # 5-minute expiry
    assert row[3] == 0 and row[4] == 0


def test_verify_success_marks_user_verified(ctx):
    code = issued_code(ctx)
    resp = verify(ctx, code)
    assert resp.status_code == 200
    assert resp.json() == {"verified": True, "email": EMAIL}

    conn = sqlite3.connect(ctx.db)
    is_verified = conn.execute("SELECT is_verified FROM users WHERE email = ?", (EMAIL,)).fetchone()[0]
    conn.close()
    assert is_verified == 1


def test_email_is_normalised(ctx):
    code = issued_code(ctx, "  Learner@Example.COM ")
    assert verify(ctx, code, "learner@example.com").status_code == 200


def test_code_is_single_use(ctx):
    code = issued_code(ctx)
    assert verify(ctx, code).status_code == 200
    again = verify(ctx, code)
    assert again.status_code == 400
    assert again.json()["detail"]["code"] == "no_active_code"


# ------------------------------------------------------------------------------ expiry
def test_code_valid_just_before_expiry(ctx):
    code = issued_code(ctx)
    ctx.clock.advance(299)
    assert verify(ctx, code).status_code == 200


def test_expired_code_is_rejected(ctx):
    code = issued_code(ctx)
    ctx.clock.advance(300)
    resp = verify(ctx, code)
    assert resp.status_code == 400
    assert resp.json()["detail"]["code"] == "expired_code"


# ------------------------------------------------------------------------ brute force
def test_wrong_code_reports_remaining_attempts(ctx):
    bad = wrong_code(issued_code(ctx))
    for expected_left in (4, 3, 2, 1):
        resp = verify(ctx, bad)
        assert resp.status_code == 400
        detail = resp.json()["detail"]
        assert detail["code"] == "invalid_code"
        assert detail["attempts_remaining"] == expected_left


def test_lockout_after_max_attempts_even_for_correct_code(ctx):
    code = issued_code(ctx)
    bad = wrong_code(code)
    for _ in range(4):
        assert verify(ctx, bad).status_code == 400
    fifth = verify(ctx, bad)
    assert fifth.status_code == 429
    assert fifth.json()["detail"]["code"] == "too_many_attempts"

    # The right code no longer works once the attempt budget is spent.
    locked = verify(ctx, code)
    assert locked.status_code == 429
    assert locked.json()["detail"]["code"] == "too_many_attempts"


def test_custom_attempt_limit_is_honoured(make_ctx):
    ctx = make_ctx(max_attempts=3)
    bad = wrong_code(issued_code(ctx))
    assert verify(ctx, bad).json()["detail"]["attempts_remaining"] == 2
    assert verify(ctx, bad).json()["detail"]["attempts_remaining"] == 1
    assert verify(ctx, bad).status_code == 429


def test_parallel_guesses_cannot_exceed_attempt_limit(ctx):
    code = issued_code(ctx)
    bad = wrong_code(code)
    outcomes: list[str] = []
    lock = threading.Lock()

    def guess():
        try:
            ctx.service.verify_otp(EMAIL, bad)
        except OtpError as exc:
            with lock:
                outcomes.append(exc.code)

    threads = [threading.Thread(target=guess) for _ in range(20)]
    for t in threads:
        t.start()
    for t in threads:
        t.join()

    conn = sqlite3.connect(ctx.db)
    attempts = conn.execute("SELECT attempts FROM otps").fetchone()[0]
    conn.close()
    assert attempts == 5  # never more than max_attempts, however the threads interleave
    assert len(outcomes) == 20
    assert outcomes.count("invalid_code") == 4  # attempts 1-4; the 5th and later are locked


# --------------------------------------------------------------------------- resending
def test_resend_cooldown(ctx):
    send(ctx)
    ctx.clock.advance(10)
    resp = send(ctx)
    assert resp.status_code == 429
    detail = resp.json()["detail"]
    assert detail["code"] == "resend_too_soon"
    assert detail["retry_after_seconds"] == 50
    assert resp.headers["retry-after"] == "50"


def test_new_code_invalidates_the_previous_one(ctx, monkeypatch):
    codes = iter(["111111", "222222"])
    monkeypatch.setattr(otp_service_module, "generate_otp", lambda: next(codes))

    assert send(ctx).status_code == 200
    ctx.clock.advance(61)
    assert send(ctx).status_code == 200

    old = verify(ctx, "111111")
    assert old.status_code == 400
    assert old.json()["detail"]["code"] == "invalid_code"
    assert verify(ctx, "222222").status_code == 200


def test_hourly_send_cap_with_retry_after(ctx):
    start = ctx.clock.now
    for _ in range(5):
        assert send(ctx).status_code == 200
        ctx.clock.advance(61)

    resp = send(ctx)
    assert resp.status_code == 429
    detail = resp.json()["detail"]
    assert detail["code"] == "send_limit_exceeded"
    # The first code leaves the 1-hour window at start + 3600.
    assert detail["retry_after_seconds"] == int(start + 3600 - ctx.clock.now)

    ctx.clock.advance(detail["retry_after_seconds"])
    assert send(ctx).status_code == 200


# --------------------------------------------------------------------------- no oracle
def test_unknown_email_looks_like_email_without_code(ctx):
    unknown = verify(ctx, "123456", "nobody@example.com")
    assert unknown.status_code == 400
    assert unknown.json()["detail"]["code"] == "no_active_code"


# ------------------------------------------------------------------------- validation
@pytest.mark.parametrize("email", ["", "not-an-email", "a@b", "x@y@z.com", " ", "a" * 250 + "@x.com"])
def test_send_rejects_invalid_email(ctx, email):
    assert send(ctx, email).status_code == 422


@pytest.mark.parametrize("code", ["12345", "1234567", "abcdef", "12 456", "١٢٣٤٥٦", ""])
def test_verify_rejects_malformed_code(ctx, code):
    assert verify(ctx, code).status_code == 422


# ----------------------------------------------------------------------------- delivery
def test_delivery_failure_returns_502_and_invalidates_code(make_ctx):
    ctx = make_ctx(delivery=FailingDelivery())
    resp = send(ctx)
    assert resp.status_code == 502
    assert resp.json()["detail"]["code"] == "delivery_failed"

    conn = sqlite3.connect(ctx.db)
    unused = conn.execute("SELECT COUNT(*) FROM otps WHERE is_used = 0").fetchone()[0]
    conn.close()
    assert unused == 0  # an undelivered code must not stay guessable


# ---------------------------------------------------------------------------- frontend
def test_demo_page_uses_numeric_keypad(ctx):
    resp = ctx.client.get("/otp-demo")
    assert resp.status_code == 200
    assert "text/html" in resp.headers["content-type"]
    assert "inputMode = 'numeric'" in resp.text
    assert "one-time-code" in resp.text
