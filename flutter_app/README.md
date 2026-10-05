# Kapiert 🇩🇪

> **Master German articles — der, die & das — through smart quizzes, instant lookup, and spaced repetition.**

Kapiert is a Flutter mobile and desktop application (Android, iOS, Windows, Web) that helps German learners memorise the grammatical gender of nouns. It combines a local SQLite word database with optional Supabase cloud sync and Google Sign-In so progress follows the learner across devices.

---

## ✨ Features

| Feature | Description |
|---|---|
| 🔍 **Word Lookup** | Search any German noun and instantly see its article, meaning, and gender colour |
| 🧠 **Quiz Mode** | Rapid-fire der / die / das quiz with streak tracking and performance history |
| 📜 **History** | Review every word you've looked up, filterable by article and outcome |
| 🔥 **Streak Tracking** | Daily activity tracker and streak counter |
| 👤 **User Profile** | Avatar with fallback, display name editor, 2×2 stats grid & article mastery breakdown |
| ☁️ **Cloud Sync** | Local-first architecture synced via Supabase backend when signed in |
| 🔐 **Authentication** | Email OTP verification **and** native Google Sign-In |
| ⚙️ **In-App Config** | Connect Supabase URL & Anon Key directly via an in-app setup sheet without rebuilds |
| 🌙 **Dark Mode** | Full light & dark theme support with custom AppColors palette |
| 📴 **Offline First** | All core features work without an internet connection via local SQLite |

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x / Dart 3.x |
| Local Storage | SQLite (`sqflite` / `sqflite_common_ffi`) + `shared_preferences` |
| Cloud Backend | Supabase (`supabase_flutter` Auth + Postgres Database) |
| Google Sign-In | `google_sign_in` (native Android & Web OAuth flow) |
| Animations | `flutter_animate` |
| Typography | `google_fonts` (Nunito) |
| Networking | `http` |

---

## 📁 Project Structure

```
lib/
├── config/                      # AppConfig (API base URLs, dynamic Supabase credentials)
├── constants/                   # Colour palette (AppColors), UI constants
├── data/                        # Data layer
│   ├── datasources/             # Remote & Local data sources (auth_remote_ds, etc.)
│   ├── repositories/            # Concrete repository implementations
│   └── services/                # Local SQLite database & sync services
├── domain/                      # Domain layer
│   ├── models/                  # WordModel, HistoryEntry, SyncStatus
│   └── repositories/            # Abstract contracts
├── features/                    # Feature modules (Clean Architecture)
│   ├── auth/                    # Sign In, Sign Up, Verify Email (OTP), Configure Supabase
│   ├── history/                 # Search & quiz history with filter tabs
│   ├── lookup/                  # Word lookup and dictionary details
│   ├── profile/                 # User profile, display name editor, mastery cards
│   ├── quiz/                    # der/die/das training and answer evaluation
│   ├── settings/                # Themes, account info, cloud sync status
│   └── sync/                    # Two-way Supabase background synchronization
├── shared/                      # Reusable UI components & auth widgets
└── main.dart                    # Application entry point & theme initialization
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK `^3.11`
- An Android / iOS device / emulator or Chrome / Desktop target
- (Optional) A Supabase project with Google OAuth configured

### 1. Clone & install dependencies

```bash
git clone https://github.com/salehhamdy/Kapiert.git
cd Kapiert/flutter_app
flutter pub get
```

### 2. Run without cloud (Guest / Offline mode)

```bash
flutter run
```

No credentials required — the app runs fully offline using the local SQLite database.

### 3. Connect Supabase & Google Sign-In

You can configure Supabase in two ways:

#### Option A: In-App Setup (Easiest)
Run the app, go to the Sign In or Sign Up screen, and tap **Setup Supabase** (or click the warning banner). Enter your Supabase Project URL and Anon Key. The configuration is securely saved to local preferences and takes effect immediately without rebuilding!

#### Option B: Compile-time `--dart-define`
```bash
flutter run \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

---

## 🔐 Google Sign-In Configuration

Google Sign-In uses native token exchange on Android (`google_sign_in`) and browser OAuth on Web.

### 1. Android Package & SHA-1
- **Package Name**: `com.kapiert.app`
- Get your debug keystore SHA-1 fingerprint:
  ```bash
  keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
  ```

### 2. Google Cloud Console
1. Create an **Android OAuth Client ID**:
   - Package name: `com.kapiert.app`
   - SHA-1 certificate fingerprint: *(your debug/release SHA-1)*
2. Create a **Web Application OAuth Client ID**:
   - Save the Web Client ID and Client Secret.

### 3. Android Resources — `android/app/src/main/res/values/strings.xml`
Ensure the Web Client ID is defined:
```xml
<resources>
  <string name="default_web_client_id">YOUR_WEB_CLIENT_ID.apps.googleusercontent.com</string>
</resources>
```

### 4. Supabase Dashboard
1. Under **Authentication → Providers → Google**:
   - Enable Google provider.
   - Enter your **Web Client ID** and **Client Secret**.
   - Add your Android Client ID to **Authorized Client IDs**.
2. Under **Authentication → URL Configuration → Redirect URLs**, add:
   - `io.supabase.kapiert://login-callback/` (for Android deep linking)
   - `http://localhost:**` (for local Web testing)

---

## 🧪 Testing

Run all unit and widget tests:

```bash
flutter test
```

All 39 tests cover data source serialization, word models, sync mapping, auth screens (including OTP verification focus navigation), profile formatting and avatar widgets, and user profile state management.

---

## 📄 License

MIT © Saleh Hamdy
