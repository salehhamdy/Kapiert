# Kapiert 🇩🇪

> **Master German articles — der, die & das — through smart quizzes, instant lookup, and spaced repetition.**

Kapiert is a Flutter mobile app (Android & iOS) that helps German learners memorise the grammatical gender of nouns. It combines a local SQLite word database with optional Supabase cloud sync and Google Sign-In so progress follows the learner across devices.

---

## Features

| Feature | Description |
|---|---|
| 🔍 **Word Lookup** | Search any German noun and instantly see its article, meaning, and gender colour |
| 🧠 **Quiz Mode** | Rapid-fire der / die / das quiz with streak tracking and performance history |
| 📜 **History** | Review every word you've looked up, filterable by article |
| ☁️ **Cloud Sync** | Optional Supabase backend syncs progress when signed in |
| 🔐 **Auth** | Email/password sign-up with OTP verification **and** native Google Sign-In |
| 🌙 **Dark Mode** | Full light & dark theme support |
| 📴 **Offline First** | All core features work without an internet connection via local SQLite |

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3 / Dart |
| Local storage | SQLite (`sqflite`) + `shared_preferences` |
| Cloud backend | Supabase (Auth + Database) |
| Google Sign-In | `google_sign_in` (native Android & iOS) |
| Animations | `flutter_animate` |
| Fonts | `google_fonts` (Nunito) |
| HTTP | `http` |

---

## Project Structure

```
lib/
├── config/            # App-level config (Supabase URL, keys via --dart-define)
├── constants/         # Colour palette (AppColors)
├── models/            # Data models
├── screens/
│   ├── auth/
│   │   ├── welcome_screen.dart
│   │   ├── sign_in_screen.dart      # gitignored
│   │   ├── sign_up_screen.dart      # gitignored
│   │   └── verify_email_screen.dart
│   ├── history_screen.dart
│   ├── lookup_screen.dart
│   ├── quiz_screen.dart
│   └── settings_screen.dart
├── services/
│   ├── article_service.dart   # SQLite word DB queries
│   ├── storage_service.dart   # Local persistence
│   ├── supabase_service.dart  # Supabase Auth + Google Sign-In
│   └── sync_service.dart      # Cloud sync logic
├── widgets/
│   ├── auth_logo_header.dart
│   └── auth_widgets.dart      # Shared auth UI components
└── main.dart
```

---

## Getting Started

### Prerequisites

- Flutter SDK `^3.11`
- An Android or iOS device / emulator
- (Optional) A Supabase project with Google OAuth configured

### 1. Clone & install dependencies

```bash
git clone https://github.com/salehhamdy/Kapiert.git
cd Kapiert/flutter_app
flutter pub get
```

### 2. Run without cloud (guest / offline mode)

```bash
flutter run
```

No credentials needed — the app runs fully offline using the local SQLite database.

### 3. Run with Supabase (cloud sync + auth)

Pass your project credentials via `--dart-define`:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

---

## Google Sign-In Setup

Google Sign-In uses the native `google_sign_in` package and Supabase's `signInWithIdToken` for the token exchange.

### Google Cloud Console

1. Create an **OAuth 2.0 Client ID** for:
   - **Android** — use `applicationId` + SHA-1 fingerprint from `keytool`
   - **iOS** — use your bundle identifier
2. Also create a **Web** client ID (required by Supabase for token exchange)

### Android — `android/app/src/main/res/values/strings.xml`

```xml
<resources>
  <string name="default_web_client_id">YOUR_WEB_CLIENT_ID.apps.googleusercontent.com</string>
</resources>
```

### Supabase Dashboard

1. Go to **Authentication → Providers → Google**
2. Enable it and paste your **Web Client ID + Secret**

---

## Branches

| Branch | Purpose |
|---|---|
| `main` | Stable production code |
| `loggingfeatures` | Google Sign-In + auth UI + .gitignore updates |

---

## .gitignore Notes

The following are intentionally excluded from version control:

- `/web/` and `/windows/` — unused platform targets
- `/test/` — test files
- `lib/screens/auth/sign_in_screen.dart` and `sign_up_screen.dart` — sensitive in-progress screens
- `../signinup/` — local design prototype assets

---

## Contributing

1. Fork the repo and create a feature branch off `main`
2. Follow the existing code style (Nunito font, `AppColors` palette, `flutter_animate` for animations)
3. Run `flutter analyze` — zero issues expected before opening a PR
4. Open a pull request with a clear description of your changes

---

## License

MIT © Saleh Hamdy
