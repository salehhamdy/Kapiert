---
name: kapiert-supabase-sync
description: >-
  Outlines the two-way cloud synchronization and authentication protocol with Supabase.
  Use when working with user authentication (email OTP, Google OAuth), offline queue flushing,
  row level security (RLS) policies, or the merge_streak database function.
---

# Supabase Cloud Sync & Authentication

Kapiert provides a seamless dual-mode experience:
1. **Guest Mode**: 100% offline local reads and writes via SQLite.
2. **Signed-in Mode**: Multi-device sync backed by Supabase PostgreSQL.

## Two-Way Sync Protocol

Located in [`flutter_app/lib/data/repositories/sync_repository_impl.dart`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/lib/data/repositories/sync_repository_impl.dart).

### 1. Client-Generated UUIDs
Every row in SQLite `history` generates a unique `client_id` (`UUIDv4`).
- Ensures idempotent synchronization across devices.
- Network retries never duplicate history rows in PostgreSQL.

### 2. Synchronization Cycle
1. **Push Unsynced Rows**: Query local rows where `synced = 0`, upsert to Supabase PostgreSQL, and mark `synced = 1`.
2. **Pull Remote Updates**: Fetch rows with `created_at` greater than last sync timestamp.
3. **Merge Streaks**: Invoke the PostgreSQL RPC `merge_streak(user_id, client_streak)`:
   - Evaluates whether the cloud streak or client streak represents the authoritative active streak.

## Security & Row Level Security (RLS)
All PostgreSQL tables (`profiles`, `history`, `user_streaks`, `user_settings`) enforce strict RLS:
- `auth.uid() = user_id`: Users can only read and write their own records.
- Service role access is reserved exclusively for system maintenance.
