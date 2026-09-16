# 🇩🇪 Kapiert — German Article Trainer

<p align="center">
  <img src="kapiert_logo_wordmark.png" alt="Kapiert Logo" width="260"/>
</p>

<p align="center">
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white" alt="Flutter"/></a>
  <a href="https://fastapi.tiangolo.com"><img src="https://img.shields.io/badge/FastAPI-0.115-009688?logo=fastapi&logoColor=white" alt="FastAPI"/></a>
  <a href="https://supabase.com"><img src="https://img.shields.io/badge/Supabase-ready-3ECF8E?logo=supabase&logoColor=white" alt="Supabase"/></a>
  <a href="https://render.com"><img src="https://img.shields.io/badge/Render-deployed-46E3B7?logo=render&logoColor=white" alt="Render"/></a>
  <img src="https://img.shields.io/badge/license-MIT-blue" alt="License"/>
</p>

> **Kapiert** (*German: "got it"*) is a cross-platform app that helps you master German noun genders — one word at a time. Look up any German noun to get its article (der / die / das), quiz yourself, track your streak, and build real recall through daily practice.

---

## ✨ Features

| Feature | Status |
|---|---|
| 🔍 Instant article lookup (90,000+ nouns) | ✅ Live |
| 🎯 Quiz mode with correct/incorrect tracking | ✅ Live |
| 📜 Full lookup history with filters | ✅ Live |
| 🔥 Daily streak tracking | ✅ Live |
| 🌙 Dark / Light mode | ✅ Live |
| 🌐 Wiktionary fallback for unknown words | ✅ Live |
| 📱 Android, Windows, Web | ✅ Live |
| ☁️ Cloud sync via Supabase | 🔜 Planned |
| 🔐 User accounts (email, Google, Apple) | 🔜 Planned |

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────┐
│              Flutter App                    │
│  ┌──────────┐ ┌──────────┐ ┌─────────────┐ │
│  │  Lookup  │ │   Quiz   │ │   History   │ │
│  └────┬─────┘ └────┬─────┘ └──────┬──────┘ │
│       └────────────┼───────────────┘        │
│              ┌─────▼──────┐                 │
│              │AppConfig   │  dart-define /  │
│              │(base URL)  │  SharedPrefs    │
│              └─────┬──────┘                 │
└────────────────────┼────────────────────────┘
                     │ HTTP
       ┌─────────────▼─────────────┐
       │     FastAPI Backend        │
       │  ┌──────────────────────┐ │
       │  │  In-memory noun dict │ │  ← 90,927 nouns (nouns.csv)
       │  │  (dataset.py)        │ │
       │  └──────────┬───────────┘ │
       │             │ fallback     │
       │  ┌──────────▼───────────┐ │
       │  │  Wiktionary REST API │ │
       │  └──────────────────────┘ │
       └───────────────────────────┘
                     │ (future)
       ┌─────────────▼─────────────┐
       │        Supabase            │
       │  auth · history · streaks  │
       │  favorites · settings      │
       └───────────────────────────┘
```

**Guest mode** (default): All data stored locally — SQLite for history, SharedPreferences for settings. Zero sign-in required.

**Signed-in mode** (future): History, streaks, and favorites sync to Supabase Postgres across all devices.

---

## 🚀 Quick Start

### 1. Backend

```bash
cd backend

# Install dependencies
pip install -r requirements.txt

# Copy environment file (optional — defaults work out of the box)
cp .env.example .env

# Start the server
python main.py
# → http://127.0.0.1:8000
```

> **Note:** The backend auto-discovers `nouns.csv` at `backend/nouns.csv` or `../nouns.csv`.
> If it's missing, run: `python scripts/download_nouns.py`

Verify it's running:
```bash
curl http://127.0.0.1:8000/health
curl http://127.0.0.1:8000/lookup/Buch
```

### 2. Flutter App

```bash
cd flutter_app

# Install dependencies
flutter pub get

# Run locally (auto-detects platform URL)
flutter run                        # Android emulator → 10.0.2.2:8000
flutter run -d windows             # Windows desktop → 127.0.0.1:8000
flutter run -d chrome              # Chrome → 127.0.0.1:8000

# Run against deployed backend
flutter run --dart-define=API_BASE_URL=https://your-backend.onrender.com

# Run with Supabase enabled
flutter run \
  --dart-define=API_BASE_URL=https://your-backend.onrender.com \
  --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJ...
```

---

## 🌐 API Reference

Base URL: `http://127.0.0.1:8000` (local) or your Render deployment URL.

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/health` | Service status, nouns loaded count |
| `GET` | `/` | Same as `/health` (Render health check) |
| `GET` | `/lookup/{word}` | Article lookup — dataset → Wiktionary fallback |
| `GET` | `/random` | Single random noun for quiz |
| `GET` | `/random/batch/{count}` | Batch random nouns (max 50) |

**Response shape** (matches Flutter `WordModel`):
```json
{
  "word": "Buch",
  "article": "das",
  "gender": "n",
  "plural": "Bücher",
  "translation": null,
  "source": "dataset",
  "found": true
}
```

---

## 🔧 Environment Variables

### Backend (`backend/.env`)

| Variable | Default | Description |
|---|---|---|
| `NOUNS_CSV_PATH` | `../nouns.csv` | Path to German nouns CSV |
| `HOST` | `0.0.0.0` | Server host |
| `PORT` | `8000` | Server port |
| `RELOAD` | `true` | Uvicorn hot reload (dev only) |
| `ALLOWED_ORIGINS` | `*` | CORS origins |
| `WIKTIONARY_TIMEOUT` | `5.0` | Fallback timeout (seconds) |

### Flutter (`--dart-define` flags)

| Flag | Required | Description |
|---|---|---|
| `API_BASE_URL` | Production only | Deployed FastAPI URL |
| `SUPABASE_URL` | When enabling accounts | Supabase project URL |
| `SUPABASE_ANON_KEY` | When enabling accounts | Supabase anon/public key |

---

## ☁️ Deploy to Render

1. Push this repo to GitHub
2. Connect at [dashboard.render.com](https://dashboard.render.com) — Render reads `render.yaml` automatically
3. Build downloads `nouns.csv` and starts `uvicorn`
4. Copy the deployed URL → use as `API_BASE_URL` in Flutter builds

---

## 🗄️ Supabase Setup (when enabling accounts)

1. Create a project at [supabase.com](https://supabase.com)
2. Run the migration:
   - **Option A** — Supabase Dashboard → SQL Editor → paste `supabase/migrations/20260101000000_initial_schema.sql`
   - **Option B** — `supabase db push` (with Supabase CLI)
3. Enable auth providers (Email, Google, Apple) in the Supabase Dashboard
4. Pass `SUPABASE_URL` and `SUPABASE_ANON_KEY` via `--dart-define`
5. Build the sign-in UI using the `SupabaseService` stubs already in place

**Database schema:**
- `profiles` — user display name, avatar
- `lookup_history` — word, article, correct/incorrect, mode, timestamp
- `streaks` — current streak, last active date
- `favorites` — saved words
- `user_settings` — dark mode, hints toggle, quiz difficulty

All tables have **Row Level Security (RLS)** — users can only access their own data.

---

## 🧪 Tests

```bash
# Backend API tests
cd backend
pip install -r requirements-dev.txt
pytest tests/ -v

# Flutter static analysis
cd flutter_app
flutter analyze
```

---

## 🗺️ Roadmap

### Phase 2 — Accounts & Sync
- [ ] Sign-up / sign-in UI (email + OAuth)
- [ ] Merge local history to cloud on first login (`SyncService`)
- [ ] Cross-device history & streak sync via Supabase
- [ ] User profile screen

### Phase 3 — Learning Features
- [ ] ⭐ Favorites — save words for focused review
- [ ] 🃏 Spaced repetition (SRS) — smart quiz scheduling based on past performance
- [ ] 📊 Advanced stats — weekly heatmap, accuracy over time, weakest articles
- [ ] 🏆 Achievements & milestones (7-day streak, 100 words, etc.)

### Phase 4 — Content & Polish
- [ ] 🌍 English translations for all nouns (Wiktionary enrichment)
- [ ] 🔊 Audio pronunciation (text-to-speech)
- [ ] 📝 Example sentences per word
- [ ] 🌐 Multi-language UI (Arabic, Turkish, English)

### Phase 5 — Platform & Release
- [ ] 🔔 Daily practice reminders (push notifications)
- [ ] 📴 Full offline mode (local article cache)
- [ ] 🍎 iOS support (TestFlight → App Store)
- [ ] 🤖 Android Play Store release
- [ ] 🖥️ Windows Store / direct APK distribution

---

## 📁 Project Structure

```
Kapiert/
├── backend/                  # FastAPI backend
│   ├── main.py               # App factory
│   ├── config.py             # Settings (env-based)
│   ├── dataset.py            # In-memory noun loader
│   ├── wiktionary.py         # Wiktionary fallback
│   ├── models.py             # Pydantic models
│   ├── routes/               # health · lookup · random
│   ├── tests/                # pytest API tests
│   └── scripts/              # download_nouns.py
├── flutter_app/              # Flutter cross-platform app
│   ├── lib/
│   │   ├── config/           # AppConfig (URL resolution)
│   │   ├── constants/        # Colors, themes
│   │   ├── models/           # WordModel, LookupHistory
│   │   ├── screens/          # Lookup, Quiz, History, Settings
│   │   ├── services/         # ArticleService, StorageService,
│   │   │                     # SupabaseService, SyncService
│   │   └── widgets/          # Shared UI components
│   └── pubspec.yaml
├── supabase/
│   └── migrations/           # Initial DB schema (RLS enabled)
├── render.yaml               # Render deployment config
└── README.md
```

---

## 🤝 Contributing

Pull requests are welcome! For major changes, open an issue first to discuss what you'd like to change.

1. Fork the repo
2. Create a feature branch (`git checkout -b feature/my-feature`)
3. Commit your changes (`git commit -m 'feat: add my feature'`)
4. Push to the branch (`git push origin feature/my-feature`)
5. Open a Pull Request

---

## 📄 License

MIT — see [LICENSE](LICENSE) for details.
