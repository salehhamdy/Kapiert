KAPIERT — SETUP & CHANGELOG
============================

This document describes all infrastructure changes for Supabase readiness,
deployment, and backend/frontend alignment. Existing app behaviour is
unchanged in guest mode (local SQLite + SharedPreferences).


ARCHITECTURE
------------

  Flutter App
      ├── FastAPI backend  → article lookups, quiz random words
      └── Supabase (future) → auth, synced history, streaks, favorites

  MongoDB is NOT used.


WHAT CHANGED
------------

BACKEND (backend/)
  • Refactored single-file main.py into modules:
      config.py       — environment-based settings
      models.py       — Pydantic models aligned with Flutter WordModel
      dataset.py      — in-memory german-nouns CSV loader
      wiktionary.py   — Wiktionary fallback lookup
      routes/         — health, lookup, random endpoints
  • Added GET /health (also serves GET / for Render health checks)
  • Added .env.example for local configuration
  • Added Dockerfile for container deployment
  • Added scripts/download_nouns.py to fetch the dataset
  • Added tests/test_api.py — API contract verification
  • Added requirements-dev.txt (pytest)

SUPABASE (supabase/)
  • migrations/20260101000000_initial_schema.sql
      - profiles, lookup_history, streaks, favorites, user_settings
      - Row Level Security (RLS) on all tables
      - Auto-create profile trigger on signup
  • config.toml — optional local Supabase CLI config

FLUTTER (flutter_app/)
  • lib/config/app_config.dart — central API/Supabase config
  • lib/services/supabase_service.dart — Supabase init (inactive until keys set)
  • lib/services/sync_service.dart — cloud sync stubs (no-op in guest mode)
  • lib/services/article_service.dart — uses AppConfig, adds checkHealth()
  • lib/main.dart — initializes AppConfig + SupabaseService
  • lib/screens/settings_screen.dart — shows backend URL + online status
  • pubspec.yaml — added supabase_flutter
  • env.example — documents --dart-define flags

DEPLOYMENT
  • render.yaml — auto-downloads nouns.csv during build
  • .gitignore — excludes nouns.csv, .env files


API ENDPOINTS (unchanged contract)
----------------------------------

  GET /health              Service status + nouns_loaded count
  GET /                    Same as /health (Render health check)
  GET /lookup/{word}       Article lookup (dataset → Wiktionary fallback)
  GET /random              Single random noun (quiz)
  GET /random/batch/{count} Batch random nouns (quiz pre-fetch, max 50)

Response fields (matches Flutter WordModel):
  word, article, gender, plural, translation, source, found


MANUAL ENTRIES REQUIRED
-----------------------

These cannot be auto-generated — you must provide them:

  NOUNS_CSV_PATH / optional locally
      Default: backend/nouns.csv (run download script below)

  RENDER_API_KEY / needed (for Render CLI deploy only)
      From: https://dashboard.render.com → Account Settings → API Keys

  API_BASE_URL / needed (for production Flutter builds)
      Your deployed backend URL, e.g. https://kapiert-backend.onrender.com
      Pass via: --dart-define=API_BASE_URL=<url>

  SUPABASE_URL / needed (when enabling accounts)
      From: Supabase Dashboard → Project Settings → API → Project URL

  SUPABASE_ANON_KEY / needed (when enabling accounts)
      From: Supabase Dashboard → Project Settings → API → anon public key

  SUPABASE_JWT_SECRET / needed (optional, backend only — future protected routes)
      From: Supabase Dashboard → Project Settings → API → JWT Secret

  SUPABASE_SERVICE_ROLE_KEY / needed (server-side admin tasks only — never in Flutter)
      From: Supabase Dashboard → Project Settings → API → service_role key


HOW TO START — LOCAL BACKEND
-----------------------------

  1. Download the noun dataset:
       cd backend
       python scripts/download_nouns.py

  2. Install dependencies:
       pip install -r requirements.txt

  3. (Optional) Copy environment file:
       cp .env.example .env

  4. Start the server:
       uvicorn main:app --reload --port 8000

  5. Verify:
       curl http://127.0.0.1:8000/health
       curl http://127.0.0.1:8000/lookup/Buch


HOW TO START — FLUTTER APP
---------------------------

  1. Install dependencies:
       cd flutter_app
       flutter pub get

  2. Run locally (connects to localhost / Android emulator automatically):
       flutter run

  3. Run against deployed backend:
       flutter run --dart-define=API_BASE_URL=https://your-backend.onrender.com

  4. Enable Supabase (when ready — app still works without these):
       flutter run \
         --dart-define=API_BASE_URL=https://your-backend.onrender.com \
         --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
         --dart-define=SUPABASE_ANON_KEY=eyJ...


HOW TO DEPLOY BACKEND (Render)
-------------------------------

  1. Push repo to GitHub

  2. Connect repo at https://dashboard.render.com
     Render reads render.yaml automatically

  3. Build downloads nouns.csv and starts uvicorn

  4. Copy the deployed URL → use as API_BASE_URL in Flutter builds


HOW TO SET UP SUPABASE (when ready for accounts)
-------------------------------------------------

  1. Create project at https://supabase.com

  2. Run the migration:
       Option A — Supabase Dashboard → SQL Editor → paste contents of
                  supabase/migrations/20260101000000_initial_schema.sql
       Option B — supabase db push (with Supabase CLI)

  3. Enable auth providers (Email, Google, Apple) in Supabase Dashboard

  4. Add SUPABASE_URL and SUPABASE_ANON_KEY to Flutter --dart-define

  5. Build sign-in UI (next phase) using SupabaseService stubs


RUN TESTS
---------

  Backend:
    cd backend
    pip install -r requirements-dev.txt
    pytest tests/ -v

  Flutter:
    cd flutter_app
    flutter analyze


GUEST MODE vs SIGNED-IN (future)
---------------------------------

  Today (guest mode — unchanged):
    • History → local SQLite
    • Streak/settings → SharedPreferences
    • Lookups → FastAPI backend

  Future (when Supabase keys are set + auth UI added):
    • Sign up / sign in via SupabaseService
    • SyncService.mergeLocalHistoryToCloud() on first login
    • History/streak sync to Supabase Postgres
    • Lookups still go through FastAPI (unchanged)
