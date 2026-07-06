# Der Die Das — German Article Trainer
### Flutter App UI & Structure Document

---

## Overview

A focused mobile application for German language students. The student types a German noun, taps **Check Article**, and the app returns the correct article (*der*, *die*, or *das*) along with gender, plural form, and an English translation.

The app works fully **online** — a FastAPI backend serves ~100,000 German nouns from the `german-nouns` dataset, with automatic fallback to the Wiktionary REST API for any word not found in the dataset.

---

## Architecture

```
Flutter App
    │
    │  GET /lookup/{word}
    ▼
FastAPI Backend
    │
    ├─ 1️⃣  german-nouns dataset (nouns.csv, ~100k words)  ──▶ found → return instantly
    │
    └─ 2️⃣  Wiktionary REST API (fallback)                 ──▶ found → parse + return
                                                           ──▶ not found → 404
```

---

## Screens

### 1. Lookup Screen (Home)

The core experience of the app.

**Elements:**
- App header with title, subtitle, and streak badge (e.g. 🔥 5-day streak)
- Article legend pills at the top showing all three articles color-coded:
  - **der** → Blue (masculine)
  - **die** → Red (feminine)
  - **das** → Green (neuter)
- Text input field labeled "Enter a German noun"
- "Check Article →" button
- Result card showing:
  - Article in large color-coded type
  - The word itself
  - Gender label + plural form
  - English translation (when available from Wiktionary)
  - Source badge: `from dataset` or `via Wiktionary`
  - Warning badge for common mistakes (e.g. *das Kind* is often wrongly assumed to be *der*)

---

### 2. Quiz Screen

Drill mode for practicing without typing.

**Elements:**
- Three large tappable buttons: **der / die / das**
- A random word displayed in the center
- Instant color feedback on tap:
  - ✅ Green = correct answer
  - ❌ Red = wrong, with correct answer revealed
- Score counter and progress indicator
- Result explanation card after each answer (e.g. *"Das Fenster = window (neuter)"*)

---

### 3. History Screen

A log of all past lookups and quiz attempts.

**Elements:**
- Scrollable list of entries: word + article + correct/incorrect indicator
- Color indicators:
  - ✓ Green = got it right
  - ✗ Red = got it wrong
- Option to filter by correct / incorrect
- Summary stats at the top (e.g. total lookups, accuracy %)

---

### 4. Settings Screen

User preferences and data management.

**Elements:**
- Toggle: Show hints and explanations
- Toggle: Light / Dark theme
- Option: Clear history
- Option: Reset streak
- About section (version, credits)

---

## Navigation

A persistent **Bottom Navigation Bar** with 4 tabs:

| Tab | Icon | Screen |
|-----|------|--------|
| Lookup | 🔍 | LookupScreen |
| Quiz | 🎮 | QuizScreen |
| History | 📋 | HistoryScreen |
| Settings | ⚙️ | SettingsScreen |

---

## App Structure

### Layer 1 — UI (Screens & Widgets)

```
DerDieDasApp (MaterialApp)
└── MainScaffold (BottomNavigationBar)
    ├── LookupScreen        → TextField + result card
    ├── QuizScreen          → 3-option tap quiz
    ├── HistoryScreen       → Lookup log + stats
    └── SettingsScreen      → Hints, theme, data controls
```

State management starts with `setState`, can upgrade to **Riverpod** or **Bloc** as the app grows.

---

### Layer 2 — Services

| Service | Responsibility |
|---------|---------------|
| `ArticleService` | Calls the backend `/lookup/{word}` endpoint; returns a sealed `LookupResult` (success / not found / error) |
| `StorageService` | Wraps `SharedPreferences` (streak, settings) and `sqflite` SQLite (history log) |

#### LookupResult (sealed class)

```dart
sealed class LookupResult {}

class LookupSuccess  extends LookupResult { final WordModel word; }
class LookupNotFound extends LookupResult { final String query;   }
class LookupError    extends LookupResult { final String message; }
```

---

### Layer 3 — Data

#### WordModel

```dart
class WordModel {
  final String  word;         // e.g. "Buch"
  final String  article;      // "der" | "die" | "das"
  final String  gender;       // "m" | "f" | "n"
  final String? plural;       // e.g. "Bücher"
  final String? translation;  // e.g. "book" (from Wiktionary fallback)
  final String  source;       // "dataset" | "wiktionary"

  String get fullForm    => '$article $word';   // "das Buch"
  String get colorHex    => ...;                // "#2D7A3A"
  String get genderLabel => ...;                // "neuter"
}
```

#### LookupHistory

```dart
class LookupHistory {
  final DateTime timestamp;
  final String   word;
  final String   article;
  final bool     correct;   // used in quiz mode
}
```

---

## Data Sources

| Source | Words | Speed | Coverage |
|--------|-------|-------|----------|
| `german-nouns` dataset (primary) | ~100,000 | Instant (in-memory dict) | Common + rare nouns |
| Wiktionary REST API (fallback) | 700,000+ | ~300–800 ms | Compound words, neologisms |

### API endpoint

```
GET /lookup/{word}
```

#### Success response (200)

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

#### Wiktionary fallback response (200)

```json
{
  "word": "Lieblingswort",
  "article": "das",
  "gender": "n",
  "plural": null,
  "translation": "favourite word",
  "source": "wiktionary",
  "found": true
}
```

#### Not found (404)

```json
{
  "detail": "'xyz' was not found in the dataset or Wiktionary."
}
```

---

## Backend Setup

### 1. Get the dataset

```bash
git clone https://github.com/gambolputty/german-nouns
cp german-nouns/german_nouns/nouns.csv backend/nouns.csv
```

### 2. Run locally

```bash
cd backend
pip install -r requirements.txt
uvicorn main:app --reload --port 8000
```

### 3. Deploy to Railway (free tier)

```bash
npm install -g @railway/cli
railway login
railway init
railway up
```

Copy the deployed URL and update `_defaultUrl` in `article_service.dart`.

---

## Color Coding System

| Article | Gender | Color | Hex |
|---------|--------|-------|-----|
| der | Masculine | Blue | `#1A5CAA` |
| die | Feminine | Red | `#C4373A` |
| das | Neuter | Green | `#2D7A3A` |

This color system is applied consistently across all screens — result cards, quiz buttons, history indicators, and article legend pills.

---

## Flutter Packages

| Package | Purpose |
|---------|---------|
| `http` | HTTP calls to the backend API |
| `sqflite` | Local SQLite database for history |
| `shared_preferences` | Lightweight key-value storage for settings and streak |
| `riverpod` or `provider` | State management (optional upgrade) |
| `flutter_animate` | Smooth answer feedback animations |
| `google_fonts` | Typography (e.g. Nunito for a friendly feel) |

---

## Project Folder Structure

```
derdiedas/
│
├── backend/                        ← FastAPI server
│   ├── main.py                     ← Dataset lookup + Wiktionary fallback
│   ├── nouns.csv                   ← ~100k German nouns (download separately)
│   ├── requirements.txt
│   └── Dockerfile
│
└── flutter/                        ← Flutter app
    ├── pubspec.yaml
    └── lib/
        ├── main.dart
        ├── models/
        │   ├── word_model.dart     ← WordModel data class
        │   └── lookup_history.dart
        ├── services/
        │   ├── article_service.dart  ← API calls + sealed LookupResult
        │   └── storage_service.dart  ← SharedPreferences + SQLite
        ├── screens/
        │   ├── lookup_screen.dart
        │   ├── quiz_screen.dart
        │   ├── history_screen.dart
        │   └── settings_screen.dart
        ├── widgets/
        │   ├── article_pill.dart
        │   ├── result_card.dart
        │   └── history_tile.dart
        └── constants/
            └── colors.dart
```

---

## UI Design Principles

- **Color-first feedback** — articles are always color-coded so students build visual memory
- **Minimal friction** — one text field, one button, instant result
- **Online-first** — all lookups go through the backend; no bundled word list needed
- **Transparent sourcing** — result card shows whether the answer came from the dataset or Wiktionary
- **Streak motivation** — daily streak counter on the home header
- **Common mistakes flagged** — warning badges for words students frequently get wrong
- **Dark mode ready** — via `ThemeData` with light/dark variants

---

*Document generated for the Der Die Das Flutter app — German article trainer.*
