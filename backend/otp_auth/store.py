"""SQLite-backed storage for users and OTP records.

Every public operation runs inside a ``BEGIN IMMEDIATE`` transaction. That takes the
write lock up front, so two concurrent verification requests cannot both read the same
``attempts`` value and slip extra guesses past the limit.

To move to PostgreSQL, implement the same ``OtpStore.transaction()`` / ``_Tx`` surface
(use ``SELECT ... FOR UPDATE`` on the otps row) - ``OtpService`` does not care.
"""

from __future__ import annotations

import sqlite3
import threading
from contextlib import contextmanager
from dataclasses import dataclass
from pathlib import Path
from typing import Iterator

_SCHEMA_PATH = Path(__file__).with_name("schema.sql")


@dataclass(frozen=True)
class OtpRecord:
    id: int
    user_id: int
    code_hash: str
    salt: str
    expires_at: float
    attempts: int
    is_used: bool
    created_at: float


def _row_to_otp(row: sqlite3.Row | None) -> OtpRecord | None:
    if row is None:
        return None
    return OtpRecord(
        id=row["id"],
        user_id=row["user_id"],
        code_hash=row["code_hash"],
        salt=row["salt"],
        expires_at=row["expires_at"],
        attempts=row["attempts"],
        is_used=bool(row["is_used"]),
        created_at=row["created_at"],
    )


class _Tx:
    """Operations available inside one open transaction."""

    def __init__(self, conn: sqlite3.Connection) -> None:
        self._conn = conn

    # -- users ---------------------------------------------------------------
    def get_user_id(self, email: str) -> int | None:
        row = self._conn.execute(
            "SELECT id FROM users WHERE email = ?", (email,)
        ).fetchone()
        return row["id"] if row else None

    def get_or_create_user(self, email: str, now: float) -> int:
        self._conn.execute(
            "INSERT OR IGNORE INTO users (email, created_at) VALUES (?, ?)",
            (email, now),
        )
        user_id = self.get_user_id(email)
        assert user_id is not None
        return user_id

    def mark_user_verified(self, user_id: int, now: float) -> None:
        self._conn.execute(
            "UPDATE users SET is_verified = 1, verified_at = ? WHERE id = ?",
            (now, user_id),
        )

    def is_user_verified(self, user_id: int) -> bool:
        row = self._conn.execute(
            "SELECT is_verified FROM users WHERE id = ?", (user_id,)
        ).fetchone()
        return bool(row and row["is_verified"])

    # -- otps ----------------------------------------------------------------
    def latest_otp(self, user_id: int) -> OtpRecord | None:
        return _row_to_otp(
            self._conn.execute(
                "SELECT * FROM otps WHERE user_id = ? ORDER BY created_at DESC, id DESC LIMIT 1",
                (user_id,),
            ).fetchone()
        )

    def count_created_since(self, user_id: int, since: float) -> int:
        row = self._conn.execute(
            "SELECT COUNT(*) AS n FROM otps WHERE user_id = ? AND created_at > ?",
            (user_id, since),
        ).fetchone()
        return int(row["n"])

    def nth_latest_created_since(
        self, user_id: int, since: float, n: int
    ) -> float | None:
        """created_at of the n-th most recent OTP inside the window (1 = newest)."""
        row = self._conn.execute(
            "SELECT created_at FROM otps WHERE user_id = ? AND created_at > ? "
            "ORDER BY created_at DESC, id DESC LIMIT 1 OFFSET ?",
            (user_id, since, n - 1),
        ).fetchone()
        return float(row["created_at"]) if row else None

    def invalidate_unused(self, user_id: int) -> None:
        self._conn.execute(
            "UPDATE otps SET is_used = 1 WHERE user_id = ? AND is_used = 0", (user_id,)
        )

    def insert_otp(
        self,
        user_id: int,
        code_hash: str,
        salt: str,
        expires_at: float,
        now: float,
    ) -> int:
        cur = self._conn.execute(
            "INSERT INTO otps (user_id, code_hash, salt, expires_at, created_at) "
            "VALUES (?, ?, ?, ?, ?)",
            (user_id, code_hash, salt, expires_at, now),
        )
        return int(cur.lastrowid)

    def increment_attempts(self, otp_id: int) -> int:
        self._conn.execute(
            "UPDATE otps SET attempts = attempts + 1 WHERE id = ?", (otp_id,)
        )
        row = self._conn.execute(
            "SELECT attempts FROM otps WHERE id = ?", (otp_id,)
        ).fetchone()
        return int(row["attempts"])

    def mark_used(self, otp_id: int) -> None:
        self._conn.execute("UPDATE otps SET is_used = 1 WHERE id = ?", (otp_id,))

    def purge_older_than(self, cutoff: float) -> None:
        self._conn.execute("DELETE FROM otps WHERE created_at < ?", (cutoff,))


class OtpStore:
    def __init__(self, path: str) -> None:
        self._path = path
        self._init_lock = threading.Lock()
        self._init_schema()

    def _connect(self) -> sqlite3.Connection:
        # isolation_level=None -> autocommit; transactions are opened explicitly below.
        conn = sqlite3.connect(self._path, timeout=10, isolation_level=None)
        conn.row_factory = sqlite3.Row
        conn.execute("PRAGMA foreign_keys = ON")
        return conn

    def _init_schema(self) -> None:
        with self._init_lock:
            Path(self._path).parent.mkdir(parents=True, exist_ok=True)
            conn = self._connect()
            try:
                conn.execute("PRAGMA journal_mode = WAL")
                conn.executescript(_SCHEMA_PATH.read_text(encoding="utf-8"))
            finally:
                conn.close()

    @contextmanager
    def transaction(self) -> Iterator[_Tx]:
        """Open a write transaction; commit on success, roll back on any exception."""
        conn = self._connect()
        try:
            conn.execute("BEGIN IMMEDIATE")
            yield _Tx(conn)
            conn.execute("COMMIT")
        except BaseException:
            if conn.in_transaction:
                conn.execute("ROLLBACK")
            raise
        finally:
            conn.close()
