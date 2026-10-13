# Secure OTP Verification Service

This document describes the complete architecture, database schema, security guarantees, API specifications, and frontend integration of the Kapiert OTP verification service.

---

## 1. Overview & Security Architecture

The OTP service provides a zero-trust, brute-force-resilient email/phone verification pipeline built into the FastAPI backend ([`backend/routes/otp.py`](file:///c:/Users/ASUS/Downloads/German_Articles/backend/routes/otp.py) and [`backend/otp_auth/`](file:///c:/Users/ASUS/Downloads/German_Articles/backend/otp_auth/)).

### Core Security Principles

1. **CSPRNG Generation**:
   OTPs are 6-digit numeric strings (`000000` to `999999`) generated using Python's `secrets.randbelow(10**6)` from operating system cryptographic entropy. The standard pseudo-random `random` module is strictly avoided to prevent state prediction attacks.
2. **Never Plaintext in Database**:
   Codes are never persisted in plaintext. Each code is hashed with **HMAC-SHA256** using:
   - A server-side secret **pepper** stored in environment variables (`OTP_PEPPER`), never written to disk.
   - A unique 16-byte cryptographically random **salt** generated per code (`secrets.token_hex(16)`).
   - Binding to the normalized recipient email/phone (`email:salt:code`). Even if the database leaks, an attacker cannot reverse or precompute the 1,000,000 combinations without the pepper, nor replay hashes between accounts.
3. **Constant-Time Verification**:
   Validation uses `hmac.compare_digest(candidate, expected_hash)` to protect against timing attacks that leak matching prefix characters.
4. **Strict TTL Expiration**:
   Tokens have an automatic 5-minute Time-To-Live (`OTP_TTL_SECONDS = 300`). Expired tokens are immediately rejected.
5. **Single-Use Consumption & Invalidation**:
   Once successfully verified, `is_used` is set to `1` within the same transaction. When a new code is requested for a user, any existing unverified codes are immediately invalidated to prevent concurrent guessing across multiple codes.
6. **Atomic Rate Limiting & Brute-Force Lockout**:
   - Verification attempts per code are tracked in the database (`attempts`).
   - Each guess increments `attempts` inside a `BEGIN IMMEDIATE` write lock (or PostgreSQL `SELECT ... FOR UPDATE`).
   - After **5 failed attempts** (`OTP_MAX_ATTEMPTS`), the code is permanently locked (`too_many_attempts`, HTTP 429), forcing the requester to request a fresh code.
   - Resend requests have a 60-second cooldown (`OTP_RESEND_COOLDOWN_SECONDS`) and an hourly cap of 5 codes (`OTP_MAX_SENDS_PER_HOUR`).

---

## 2. Database Schema Design

### SQLite Implementation ([`backend/otp_auth/schema.sql`](file:///c:/Users/ASUS/Downloads/German_Articles/backend/otp_auth/schema.sql))

```sql
CREATE TABLE IF NOT EXISTS users (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    email       TEXT    NOT NULL UNIQUE,              -- normalised: trimmed + lower-cased
    is_verified INTEGER NOT NULL DEFAULT 0 CHECK (is_verified IN (0, 1)),
    verified_at REAL,
    created_at  REAL    NOT NULL
);

CREATE TABLE IF NOT EXISTS otps (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id    INTEGER NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    code_hash  TEXT    NOT NULL,                      -- HMAC-SHA256 hex digest
    salt       TEXT    NOT NULL,                      -- 32-char per-code random hex salt
    expires_at REAL    NOT NULL,                      -- Unix epoch seconds
    attempts   INTEGER NOT NULL DEFAULT 0,            -- Failed + successful tries
    is_used    INTEGER NOT NULL DEFAULT 0 CHECK (is_used IN (0, 1)),
    created_at REAL    NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_otps_user_created ON otps (user_id, created_at DESC);
```

### PostgreSQL Implementation (Production Cloud)

```sql
CREATE TABLE IF NOT EXISTS users (
    id          BIGSERIAL PRIMARY KEY,
    email       VARCHAR(254) NOT NULL UNIQUE,
    is_verified BOOLEAN NOT NULL DEFAULT FALSE,
    verified_at TIMESTAMPTZ,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS otps (
    id         BIGSERIAL PRIMARY KEY,
    user_id    BIGINT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    code_hash  VARCHAR(64) NOT NULL,
    salt       VARCHAR(32) NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    attempts   INT NOT NULL DEFAULT 0,
    is_used    BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_otps_user_created ON otps (user_id, created_at DESC);
```

### In-Memory Redis Implementation Alternative

If using Redis as the transient store:
- Key: `otp:{normalized_email}`
- Value JSON: `{"hash": "<hmac_sha256>", "salt": "<salt>", "attempts": 0}`
- Key TTL: `SETEX otp:{email} 300 <json_data>`
- Atomic attempt tracking using Redis transaction or Lua script (`HINCRBY`).

---

## 3. API Endpoints

### 1. `POST /api/send-otp`

Request:
```json
{
  "email": "user@example.com"
}
```

Response (200 OK):
```json
{
  "status": "sent",
  "expires_in_seconds": 300,
  "resend_after_seconds": 60
}
```

Error Responses:
- `400 Bad Request`: `{"detail": {"code": "validation", "message": "Enter a valid email address."}}`
- `429 Too Many Requests` (cooldown):
  - Headers: `Retry-After: 48`
  - Body: `{"detail": {"code": "resend_too_soon", "message": "Please wait 48s before requesting another code.", "retry_after_seconds": 48}}`
- `429 Too Many Requests` (hourly limit):
  - Headers: `Retry-After: 1800`
  - Body: `{"detail": {"code": "send_limit_exceeded", "message": "Too many codes requested. Try again later.", "retry_after_seconds": 1800}}`
- `502 Bad Gateway`: Delivery provider down. Code is deleted/invalidated so user can re-try.

---

### 2. `POST /api/verify-otp`

Request:
```json
{
  "email": "user@example.com",
  "code": "847291"
}
```

Response (200 OK):
```json
{
  "verified": true,
  "email": "user@example.com"
}
```

Error Responses:
- `400 Bad Request` (Incorrect code with attempts remaining):
  ```json
  {
    "detail": {
      "code": "invalid_code",
      "message": "Incorrect code.",
      "attempts_remaining": 4
    }
  }
  ```
- `400 Bad Request` (Expired):
  ```json
  {
    "detail": {
      "code": "expired_code",
      "message": "This code has expired. Request a new one."
    }
  }
  ```
- `429 Too Many Requests` (Lockout on 5th failure):
  ```json
  {
    "detail": {
      "code": "too_many_attempts",
      "message": "Too many incorrect attempts. Request a new code."
    }
  }
  ```

---

## 4. Frontend Form Integration

The service includes an interactive reference demo located at:
- Endpoint: `GET /otp-demo`
- Source: [`backend/static/otp_demo.html`](file:///c:/Users/ASUS/Downloads/German_Articles/backend/static/otp_demo.html)

Key UX features:
- **Mobile Number Pad**: `inputmode="numeric"` on each box triggers the OS numeric keypad.
- **SMS / Email Autofill**: `autocomplete="one-time-code"` allows 1-tap pasting from OS clipboard notifications.
- **Auto-Advance & Backspace**: Focus shifts automatically to the next box upon typing a digit. Backspace clears and returns focus to the previous box.
- **Full Paste Support**: Pasting a 6-digit string populates all 6 boxes at once.
- **Error Shake & Feedback**: Failed submissions trigger CSS animations and display exact attempts remaining.
- **Dual Timers**: Live countdown for expiration (5:00) alongside resend cooldown button enablement.
