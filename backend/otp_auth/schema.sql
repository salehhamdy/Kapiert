-- OTP verification schema (SQLite dialect; a PostgreSQL variant is in docs/OTP_SERVICE.md).
-- Timestamps are Unix epoch seconds (REAL) so expiry maths never depends on time zones.

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
    code_hash  TEXT    NOT NULL,                      -- HMAC-SHA256 hex digest, never the raw code
    salt       TEXT    NOT NULL,                      -- per-code random salt
    expires_at REAL    NOT NULL,
    attempts   INTEGER NOT NULL DEFAULT 0,            -- failed + successful verification tries
    is_used    INTEGER NOT NULL DEFAULT 0 CHECK (is_used IN (0, 1)),
    created_at REAL    NOT NULL
);

-- "latest OTP for this user" and "how many OTPs in the last hour" both use this index.
CREATE INDEX IF NOT EXISTS idx_otps_user_created ON otps (user_id, created_at DESC);
