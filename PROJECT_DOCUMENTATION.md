# 🇩🇪 Kapiert — Comprehensive Project Documentation

> **Kapiert** (*German: "got it"*) is a modern, cross-platform language learning application designed to help students master German noun genders (**der**, **die**, **das**) through instant lookups, drill quizzes, spaced repetition scheduling, streak tracking, and article mastery analytics.

---

## 📑 Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [High-Level Architecture](#2-high-level-architecture)
3. [FastAPI Backend Service](#3-fastapi-backend-service)
   - [In-Memory Dataset Engine](#in-memory-dataset-engine)
   - [Wiktionary Fallback Pipeline](#wiktionary-fallback-pipeline)
   - [Balanced Quiz Distribution & Anti-Clumping](#balanced-quiz-distribution--anti-clumping)
   - [Example Sentences Generator & Multilingual Bank](#example-sentences-generator--multilingual-bank)
   - [API Endpoints Reference](#api-endpoints-reference)
4. [Flutter Client Application](#4-flutter-client-application)
   - [Clean Architecture & Directory Layout](#clean-architecture--directory-layout)
   - [State Management & Dependency Injection](#state-management--dependency-injection)
   - [Local-First Storage Engine](#local-first-storage-engine)
   - [Multilingual Localization & RTL Engine](#multilingual-localization--rtl-engine)
   - [Core Features & UI Modules](#core-features--ui-modules)
   - [Spaced Repetition System (SRS) Mechanics](#spaced-repetition-system-srs-mechanics)
   - [Weekly Activity Heatmap & Progress Trends](#weekly-activity-heatmap--progress-trends)
   - [Achievements & Gamification Milestones](#achievements--gamification-milestones)
5. [Supabase Cloud & Sync Architecture](#5-supabase-cloud--sync-architecture)
   - [Relational Database Schema](#relational-database-schema)
   - [Row Level Security (RLS) Policies](#row-level-security-rls-policies)
   - [Two-Way Synchronization Protocol](#two-way-synchronization-protocol)
   - [The `merge_streak` Stored Procedure](#the-merge_streak-stored-procedure)
6. [Design System & UI/UX](#6-design-system--uiux)
7. [Testing & Quality Assurance](#7-testing--quality-assurance)
8. [Setup & Deployment Guide](#8-setup--deployment-guide)

---

## 1. Executive Summary

In the German language, grammatical gender is notoriously arbitrary for learners: there is no universal grammatical rule to determine whether a noun is masculine (*der*), feminine (*die*), or neuter (*das*). Rote memorization often fails without structured reinforcement.

**Kapiert** solves this by combining:
1. **Instant, reliable lookup**: An offline in-memory dictionary of 90,927 German nouns with plural forms, transcription variant resolution (for foreign keyboards without umlauts/ß), and automatic fallback to Wiktionary.
2. **Interactive quiz drilling**: A 3-button tap quiz with balanced gender distribution and streak incentives.
3. **Spaced Repetition System (SRS)**: An expanding-interval Leitner scheduler (Stages 1–5) that automatically schedules review intervals (4h, 1d, 3d, 7d, 14d) based on answer accuracy.
4. **Deep analytics**: Mastery percentages broken down per article (*der*, *die*, *das*), automated weakest-article identification and recommendation, and SRS retention tracking.
5. **Universal accessibility**: Works 100% offline in Guest mode, with optional cross-device synchronization via Supabase.

---

## 2. High-Level Architecture

The project is structured into three decoupled layers:

```mermaid
graph TD
    Client["📱 Flutter Client<br/>(Android · Windows · Web)"]
    LocalDB[("💾 Local SQLite & SharedPreferences<br/>(Local-first reads/writes)")]
    Backend["⚡ FastAPI Backend<br/>(Python 3.13 / Uvicorn)"]
    Dataset[("📚 90k In-Memory Nouns<br/>(nouns.csv)")]
    Wiktionary["🌐 Wiktionary REST API<br/>(en/de fallback)"]
    Cloud[("☁️ Supabase PostgreSQL<br/>(Auth, RLS, Sync, Stored Procedures)")]

    Client <-->|Reads & Writes| LocalDB
    Client -->|HTTP /lookup, /random| Backend
    Backend -->|Search| Dataset
    Backend -->|Fallback HTTP| Wiktionary
    Client <-->|Background Sync & OAuth| Cloud
```

### Key Principles
- **Local-First Reliability**: The Flutter app reads and writes from local SQLite and SharedPreferences. The app operates smoothly with zero latency and zero internet connection.
- **Microservice Separation**: The FastAPI backend handles word search and dictionary logic; Supabase handles authentication and persistent user data synchronization.
- **Deterministic Sync**: Network interruptions never cause data loss. Writes are queued locally and pushed idempotently using client-generated UUIDs.

---

## 3. FastAPI Backend Service

The backend source code is located in [`backend/`](file:///c:/Users/ASUS/Downloads/German_Articles/backend) and is entrypointed by [`backend/main.py`](file:///c:/Users/ASUS/Downloads/German_Articles/backend/main.py).

### In-Memory Dataset Engine
Implemented in [`backend/dataset.py`](file:///c:/Users/ASUS/Downloads/German_Articles/backend/dataset.py):
- **Startup Loading**: Reads [`nouns.csv`](file:///c:/Users/ASUS/Downloads/German_Articles/nouns.csv) (containing 90,927 lemmas with gender, plural, and grammar tags) into memory at application boot.
- **Normalization**: Strips punctuation, whitespace, and leading articles (`der`, `die`, `das`, `ein`, `eine`, `den`, `dem`, `des`, etc.).
- **Keyboard Transcription Variants**: Automatically maps ASCII substitutes from foreign keyboards:
  - `ae` $\rightarrow$ `ä` (e.g. *Maedchen* $\rightarrow$ *Mädchen*)
  - `oe` $\rightarrow$ `ö` (e.g. *Oel* $\rightarrow$ *Öl*)
  - `ue` $\rightarrow$ `ü` (e.g. *Uebung* $\rightarrow$ *Übung*)
  - `ss` $\rightarrow$ `ß` (e.g. *Strasse* $\rightarrow$ *Straße*, *Fuss* $\rightarrow$ *Fuß*)
- **Plural Reversal**: Maintains a reverse plural index. Entering a plural form (e.g., *Bücher*) automatically resolves to the base singular lemma (*das Buch*).
- **Compound Word Head Matcher**: In German, compound nouns take the gender of their final component (head noun). If a compound word like *Notizbuch* is missing, the algorithm scans suffixes to match the head lemma (*Buch* $\rightarrow$ *das*).

### Wiktionary Fallback Pipeline
Implemented in [`backend/wiktionary.py`](file:///c:/Users/ASUS/Downloads/German_Articles/backend/wiktionary.py):
- If a word is not found in the local dataset or compound matcher, the backend queries the English and German Wiktionary REST APIs using `httpx`.
- Extracts grammatical tags (`{{de-noun|...}}`), plural forms, and English translations.

### Balanced Quiz Distribution & Anti-Clumping
Implemented in [`backend/routes/random.py`](file:///c:/Users/ASUS/Downloads/German_Articles/backend/routes/random.py):
- Maintains pre-partitioned pools of nouns for each gender (`der`, `die`, `das`).
- `/random/batch/{count}` guarantees an exact 1:1:1 quota distribution among masculine, feminine, and neuter nouns.
- **Anti-clumping Algorithm**: Scans the generated list and swaps adjacent items to guarantee that no more than 2 consecutive nouns share the same article.

### Example Sentences Generator & Multilingual Bank
Implemented in [`backend/sentences.py`](file:///c:/Users/ASUS/Downloads/German_Articles/backend/sentences.py):
- **Curated Sentence Bank**: Rich bank of authentic, high-quality German example sentences with natural, idiomatic translations in English (`en`), Arabic (`ar`), and Turkish (`tr`) for high-frequency German nouns across all daily life categories (food, family, objects, places, animals, weather, feelings, abstract ideas).
- **Compound Noun Head Deconstruction**: Recognizes productive head suffixes (e.g. `*tasse`, `*glas`, `*suppe`, `*kuchen`, `*zimmer`, `*haus`, `*tür`, `*fenster`, `*buch`, `*schlüssel`, `*uhr`, `*auto`, `*zug`, `*tasche`, `*schule`, `*spiel`, etc.) and automatically embeds compound nouns into natural, semantically appropriate contexts.
- **Morphological Suffix Intelligence**: Matches grammatical noun suffixes (`-ung`, `-heit`, `-keit`, `-schaft`, `-ion`, `-tät`, `-er`, `-chen`, `-ment`) to appropriate abstract, qualitative, or collective sentence structures.
- **Communicative Learner Fallback**: Avoids nonsensical physical claims (e.g. "hier steht der schmerz") by using authentic German language-learning contexts that clearly demonstrate noun gender, case, and English translation if known.
- Returns a structured dictionary of translations for `en`, `ar`, and `tr`, enriched automatically on `/lookup/{word}` and `/random` endpoints.

### API Endpoints Reference

| Endpoint | Method | Response Model | Description |
|---|---|---|---|
| `/health` | `GET` | `HealthResponse` | Returns service status, version, and noun count loaded. |
| `/` | `GET` | `HealthResponse` | Root alias for Render and cloud health-checks. |
| `/lookup/{word}` | `GET` | `WordResponse` | Queries dataset $\rightarrow$ Wiktionary $\rightarrow$ compound head. |
| `/random` | `GET` | `WordResponse` | Returns a single random noun with equal 1/3 gender odds. |
| `/random/batch/{count}` | `GET` | `list[WordResponse]` | Returns up to 50 balanced, anti-clumped nouns for quizzes. |

#### Sample Response (`WordResponse`)
```json
{
  "word": "Buch",
  "article": "das",
  "gender": "n",
  "plural": "Bücher",
  "translation": "book",
  "example_sentence": "Das Buch liegt auf dem Tisch.",
  "example_translation": "The book is on the table.",
  "example_translations": {
    "en": "The book is on the table.",
    "ar": "الكتاب موجود على الطاولة.",
    "tr": "Kitap masanın üzerinde."
  },
  "source": "dataset",
  "found": true
}
```

---

## 4. Flutter Client Application

The mobile and desktop client lives in [`flutter_app/`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app) and targets Android, Windows Desktop (via FFI SQLite), and Web.

### Clean Architecture & Directory Layout

```
flutter_app/lib/
├── config/              # AppConfig (URL resolution & build flags)
├── constants/           # Core constants
├── core/                # Infrastructure & Foundation
│   ├── di/              # Riverpod dependency injection registry (providers.dart)
│   ├── errors/          # Strongly typed Failure hierarchy (failures.dart)
│   ├── localization/    # AppLocalizations, AppLocalizationsDelegate, supported locales
│   ├── network/         # ApiClient (HTTP client wrapper)
│   ├── storage/         # StorageService (SQLite & SharedPreferences)
│   └── utils/           # UUID generator and helper utilities
├── data/                # Data Access Layer
│   ├── datasources/     # Remote & local datasources (Auth, Sync, Article)
│   ├── dto/             # Data Transfer Objects & JSON serialization
│   └── repositories/    # Concrete implementations of Domain repositories
├── domain/              # Business Domain (Pure Dart, Zero Framework Dependencies)
│   ├── models/          # WordModel, ExampleSentence, LocalSentenceProvider, LookupHistory, AuthUser, SrsItem, SrsStats
│   └── repositories/    # Abstract interfaces (IArticleRepository, ISrsRepository, etc.)
├── features/            # Presentation & Feature Slices
│   ├── auth/            # Sign-in, sign-up, email OTP, OAuth, Supabase setup sheet
│   ├── favorites/       # Word bookmarking & focused review quiz
│   ├── history/         # Chronological log, filter tabs, stats calculation
│   ├── legal/           # First-use consent gate, Terms of Use, Privacy Policy
│   ├── lookup/          # Instant search bar, article badges, result cards, sentence view
│   ├── profile/         # User profile, mastery breakdown, name editor, SRS metrics
│   ├── quiz/            # 3-button quiz trainer, streak progression, queue prefetch, sentence reveal
│   ├── settings/        # Theme toggle, language selector sheet, hints toggle, streak reset
│   ├── srs/             # Spaced Repetition providers and state
│   └── sync/            # Local-first background synchronization
└── shared/              # Shared Design System & UI
    ├── router/          # AppRouter & MainScaffold (4-tab localized bottom navigation)
    ├── theme/           # AppColors & AppTheme (Light & Dark mode)
    └── widgets/         # AppButton, AppTextField, AuthWidgets
```

### State Management & Dependency Injection
- Driven by **Riverpod 2.x**.
- All datasources and repositories are registered with interfaces in [`core/di/providers.dart`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/lib/core/di/providers.dart).
- Feature screens consume reactive `StateNotifier` and `Notifier` models (e.g., [`QuizNotifier`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/lib/features/quiz/providers/quiz_provider.dart), [`HistoryNotifier`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/lib/features/history/providers/history_provider.dart), [`SrsNotifier`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/lib/features/srs/providers/srs_provider.dart), [`SettingsNotifier`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/lib/features/settings/providers/settings_provider.dart)).

### Local-First Storage Engine
Implemented in [`StorageService`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/lib/core/storage/storage_service.dart):
- **Desktop FFI Support**: Automatically initializes `sqfliteFfiInit()` and `databaseFactoryFfi` when running on Windows, Linux, or macOS.
- **SQLite Database (`derdiedas.db`, schema version 6)**:
  - `history`: Log of lookups and quiz answers (`word`, `article`, `correct`, `mode`, `client_id`, `synced`, `timestamp`).
  - `favorites`: User-bookmarked words (`word`, `article`, `gender`, `plural`, `translation`, `created_at`).
  - `srs_items`: Spaced repetition state (`word`, `article`, `gender`, `stage`, `consecutive_correct`, `total_attempts`, `total_correct`, `last_reviewed`, `next_review`).
  - `achievements`: Unlocked and in-progress milestones (`id`, `title`, `description`, `category`, `icon_name`, `target_value`, `current_value`, `is_unlocked`, `unlocked_at`, `notified`).
  - `article_cache`: Offline article dictionary cache (`id`, `word`, `article`, `gender`, `plural`, `translation`, `source`, `examples`, `cached_at`) indexed by `LOWER(word)`.
- **SharedPreferences**: Stores light/dark theme preference, selected UI language (`en`, `ar`, `tr`, `de`), hints toggle, current streak count, sync timestamps, and push notification preferences (`notification_settings`: `enabled`, `hour`, `minute`, `streakAlerts`, `srsAlerts`).

### Core Features & UI Modules

#### 1. Instant Lookup ([`LookupScreen`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/lib/features/lookup/screens/lookup_screen.dart))
- Real-time search with clear buttons, instant submit, and localized input placeholders.
- Displays color-coded article badges, plural forms, gender labels, Wiktionary definitions, and contextual example sentences.
- Star button to toggle favorites directly from the result card.

#### 2. Quiz Trainer ([`QuizScreen`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/lib/features/quiz/screens/quiz_screen.dart))
- Three large, tactile buttons: **der** (blue), **die** (red), **das** (green).
- Immediate color and haptic feedback on selection.
- Reveals example sentences with active UI language translations upon answer submission.
- Streak progression counter (🔥) with animated accuracy progress bar.
- Offline fallback pool of 60 balanced nouns ensures the quiz functions without network connectivity.

#### 3. Lookup & Quiz History ([`HistoryScreen`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/lib/features/history/screens/history_screen.dart))
- Filter tabs: `All`, `Correct`, `Incorrect`, `Quiz`, and `Lookup`.
- Displays timestamps, full nouns with gender colors, and outcome checkmarks.

#### 4. Favorites & Focused Review ([`FavoritesProvider`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/lib/features/favorites/providers/favorites_provider.dart))
- Star words to create a custom study list.
- Tapping **`Review (X)`** initiates a dedicated quiz session restricted to favorited vocabulary.

#### 5. User Profile & Article Mastery ([`ProfileScreen`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/lib/features/profile/screens/profile_screen.dart))
- **Article Mastery Card**: Calculates individual accuracy percentages for *der*, *die*, and *das*.
- **Weakest Article Recommendation**: When at least 5 quiz attempts have been made on an article and accuracy is $<90\%$, displays an alert:
  > 💡 **Focus on [article]** — it's your lowest quiz accuracy.
- **Display Name Editor & Avatar**: Editable display name with custom initials avatar and sign-in method badges.

#### 6. In-App Legal Gate ([`FirstUseConsentScreen`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/lib/features/legal/screens/first_use_consent_screen.dart))
- Gated first-use modal requiring agreement to Terms of Use and Privacy Policy before accessing the app.
- Full markdown viewers for [TERMS_OF_USE.md](file:///c:/Users/ASUS/Downloads/German_Articles/TERMS_OF_USE.md) and [PRIVACY_POLICY.md](file:///c:/Users/ASUS/Downloads/German_Articles/PRIVACY_POLICY.md).

#### 7. Example Sentences with Multilingual Translation
Implemented across [`ExampleSentence`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/lib/domain/models/example_sentence.dart), [`LocalSentenceProvider`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/lib/domain/models/local_sentence_provider.dart), and [`_ExampleSentenceView`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/lib/features/lookup/screens/result_card.dart):
- **Domain Representation**: Encapsulates the German sentence and dynamic translation mapping (`Map<String, String>`).
- **Result Card Presentation**:
  - Highlights German example in an accent card container with italic quotation styling.
  - Automatically translates the sentence into the user's active UI language (`en`, `ar`, `tr`, or `de`).
  - Includes a quick-copy icon button with animated clipboard confirmation.
- **Quiz Feedback Reveal**: Contextual reinforcement after each quiz answer displays the example sentence and translated meaning before proceeding to the next noun.
- **Offline Guarantee & Semantic Intelligence**: When API responses do not contain sentences, `LocalSentenceProvider` mirrors the backend engine with an extensive curated bank (over 250 nouns), compound head matching across common suffixes, morphological derivations (`-ung`, `-heit`, `-keit`, `-chen`, `-lein`), and communicative language learning fallbacks that eliminate nonsensical generated sentences.

#### 8. Multilingual Localization & RTL System
Implemented in [`AppLocalizations`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/lib/core/localization/app_localizations.dart) and [`SettingsNotifier`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/lib/features/settings/providers/settings_provider.dart):
- **Supported Locales**:
  - 🇬🇧 English (`en`) — International baseline locale.
  - 🇸🇦 Arabic (`ar`) — Complete Right-to-Left (RTL) layout switching, directional navigation, and Arabic typography.
  - 🇹🇷 Turkish (`tr`) — Full Turkish locale coverage.
  - 🇩🇪 German (`de`) — Native German interface strings.
- **End-to-End Screen Coverage**: Zero hardcoded English strings remaining across the app:
  - **Lookup & Result Cards**: "Check Article" action, loading indicators, localized gender badges (*maskulin*, *feminin*, *neutral*), word source badges, and sentence copy tooltips.
  - **Quiz Mode**: Quiz headers, instructions, answer feedback banners, next word actions, SRS scheduled review badges, milestone unlock alerts, session completion, and error states.
  - **History Screen**: History titles, aggregate count labels, accuracy metric labels, filter chips (*All*, *Correct*, *Incorrect*, *Favorites*), focused review prompts, empty state explanations, and word action chips.
  - **Settings**: Section group headers, preferences, dark mode, server status, clear history dialog, streak reset, password change, legal document links, consent status, and data source citations.
  - **Auth & Session**: Modal logout confirmation dialog with localized titles, blur backdrop, cancel, and confirmed log out buttons.
  - **Profile & Progress**: User header badges, guest state indicators, cloud sync status, progress section headings, article mastery analytics, weakest-article advice, spaced repetition retention metrics, milestone preview cards, gallery sheets, and weekly activity heatmap controls.
- **Synchronous First-Frame Delegate**: `AppLocalizationsDelegate` resolves strings synchronously using `SynchronousFuture` to eliminate async microtask delay during widget bootstrapping and golden frame rendering.
- **Scrollable Modal Bottom Sheet**: Language selection sheet in Settings uses bounded scroll physics and high-contrast active checkmarks, eliminating any RenderFlex bottom overflow on compact devices.
- **Global Reactive Propagation**: Riverpod `localeProvider` drives instant UI layout and string re-rendering across navigation bars, headers, cards, dialogs, and snackbars without restarting the application.

#### 9. Daily Practice Reminders & Push Notifications
Implemented across [`NotificationSettings`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/lib/domain/models/notification_settings.dart), [`NotificationService`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/lib/core/notifications/notification_service.dart), [`NotificationNotifier`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/lib/features/notifications/providers/notification_provider.dart), and [`NotificationSettingsSheet`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/lib/features/notifications/widgets/notification_settings_sheet.dart):
- **Cross-Platform Scheduling Engine**: Backed by `flutter_local_notifications` 22.x and `timezone`. Features automated initialization with platform guards (Android notification channel `derdiedas_daily_reminders`, Darwin settings, Linux actions) that safely adapt to any desktop or test environment without unhandled native plugin crashes.
- **Customizable Daily Reminders**: Users can configure reminder times via an interactive Flutter `TimeOfDay` time picker with immediate `zonedSchedule` daily repeating synchronization.
- **Streak Saver & SRS Review Due Alerts**: Granular toggles to enable or disable evening streak protection nudges and notifications when spaced repetition cards become due for review.
- **Interactive Verification**: Includes an instant "Send Test Notification" action directly within Settings with floating SnackBar confirmation.
- **Zero-Friction Persistence**: All user preferences persist locally in SharedPreferences and restore automatically on application reboot.
- **Full Localization**: Completely localized across English, German, Arabic (RTL), and Turkish.

#### 10. Full Offline Mode & Local Article Cache
Implemented across [`ArticleLocalDS`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/lib/data/datasources/article_local_ds.dart), [`ArticleRepositoryImpl`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/lib/data/repositories/article_repository_impl.dart), and [`OfflineCacheSheet`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/lib/features/settings/widgets/offline_cache_sheet.dart):
- **Local-First SQLite Article Cache**: Backed by SQLite table `article_cache` (schema version 6) with case-insensitive `LOWER(word)` indexing.
- **Transparent Offline Fallback Pipeline**: `ArticleRepositoryImpl` implements remote-first lookup with automated background caching. Upon network failure, timeout, or server unavailability, queries automatically and transparently resolve from local cache without throwing uncaught UI exceptions.
- **Pre-Seeded Core Vocabulary**: Bundles 100+ high-frequency A1–B1 German nouns with definitive articles, genders, plural forms, multilingual translations (`en`, `ar`, `tr`), and contextual example sentences. Available immediately even on clean app installs before any network requests are performed.
- **Smart Query Normalization & Compound Matcher**: Strips leading definite/indefinite articles (`der`, `die`, `das`, `ein`, `eine`), cleans punctuation, resolves umlaut/transcription variants (`ae`/`ä`, `oe`/`ö`, `ue`/`ü`, `ss`/`ß`), and performs suffix head analysis on German compound nouns to inherit base gender.
- **Visual Offline Badging**: When an article is served offline, `ResultCard` displays a distinctive green offline badge with an `Icons.offline_pin_rounded` icon and localized label.
- **Cache Management Dashboard**: In Settings -> Data -> Offline Article Cache, users can inspect stored word counts, pre-seed vocabulary on demand, and clear local cache.

#### 11. English Translations & Wiktionary Enrichment
Implemented across [`translations.py`](file:///c:/Users/ASUS/Downloads/German_Articles/backend/translations.py), [`wiktionary.py`](file:///c:/Users/ASUS/Downloads/German_Articles/backend/wiktionary.py), [`lookup.py`](file:///c:/Users/ASUS/Downloads/German_Articles/backend/routes/lookup.py), [`random.py`](file:///c:/Users/ASUS/Downloads/German_Articles/backend/routes/random.py), [`enrich_wiktionary.py`](file:///c:/Users/ASUS/Downloads/German_Articles/backend/scripts/enrich_wiktionary.py), and [`article_local_ds.dart`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/lib/data/datasources/article_local_ds.dart):
- **Curated A1–B2 Translation Bank**: 1,200+ high-frequency German nouns mapped to clean, concise English glosses (`translations.py`) for instantaneous (<1ms) in-memory resolution without remote latency.
- **Dynamic Wiktionary REST Enrichment**: When a noun is not in the curated bank, the backend queries Wikimedia REST API (`/page/definition/{word}`) with compliant Wikimedia user-agent headers and a polite timeout. Definitions are cleaned by stripping HTML tags, removing Latin taxonomic binomials, unnesting multi-sense semicolons, and truncating long parentheticals.
- **Persistent Translations Cache**: Dynamically fetched Wiktionary translations are saved to `backend/translations_cache.json` on disk, guaranteeing that each unique German noun is only fetched from Wikimedia once.
- **Lookup & Compound Enrichment**: `/lookup/{word}` enriches dataset words, compound nouns (via head suffix decomposition, e.g. `Küchentisch` -> `Tisch` -> `table`), and plural forms (`Bücher` -> `Buch` -> `book`) with English translations.
- **Quiz Vocabulary Prioritization**: `/random` and `/random/batch/{count}` actively prioritize nouns with verified English translations, ensuring learners always see clear `= translation` feedback on answer cards.
- **Batch Enrichment CLI Utility**: Standalone tool [`enrich_wiktionary.py`](file:///c:/Users/ASUS/Downloads/German_Articles/backend/scripts/enrich_wiktionary.py) to inspect coverage statistics, batch-enrich word lists, or pre-populate top quiz vocabulary offline.
- **Seamless Frontend Presentation**: Flutter's `ResultCard`, `QuizScreen`, and `HistoryScreen` render sleek English translation chips with `Icons.translate_rounded`.

#### 12. Concentrated Mistakes Review Mode & SRS Due Persistence Fix
Implemented across [`QuizProvider`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/lib/features/quiz/providers/quiz_provider.dart), [`QuizScreen`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/lib/features/quiz/screens/quiz_screen.dart), [`HistoryScreen`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/lib/features/history/screens/history_screen.dart), [`StorageService`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/lib/core/storage/storage_service.dart), and [`SrsNotifier`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/lib/features/srs/providers/srs_provider.dart):
- **SRS Due Count Reset on Clear History**: Fixed bug where clearing history purged SQLite `srs_items` but left the in-memory `srsProvider` due count and due queue active. `HistoryNotifier.clearAll()` and `SettingsScreen._confirmClearHistory` now explicitly invoke `srsProvider.notifier.reset()` and `achievementsProvider.notifier.refresh()`. In addition, `SrsNotifier.reset()` wipes in-memory due counts and items.
- **Targeted Mistakes Review Session**: Added focused quiz session exclusively querying nouns the learner answered incorrectly (`correct == false` in history).
- **History Mistakes Drill Banner**: When browsing the `Incorrect` tab in `HistoryScreen`, a gradient banner displays the number of challenging words with a direct 1-tap "Review Mistakes" button opening a focused quiz session.
- **Mistakes Mode Banner & Dynamic Counters**: Quiz header displays a distinct red mistake counter chip and top notification banner with quick exit action to return to standard practice.

#### 13. Profile Password Management, Auth Guard & Offline Cache Handling
Implemented across [`ProfileScreen`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/lib/features/profile/screens/profile_screen.dart), [`ChangePasswordSheet`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/lib/features/profile/widgets/change_password_sheet.dart), [`ResetPasswordScreen`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/lib/features/auth/screens/reset_password_screen.dart), [`OfflineCacheSheet`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/lib/features/settings/widgets/offline_cache_sheet.dart), and [`ArticleLocalDS`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/lib/data/datasources/article_local_ds.dart):
- **Change Password Relocated to Profile**: Moved password update controls from Settings into Profile -> Account.
- **Guest Authentication Guard**: If an unauthenticated guest user taps "Change password", a dialog prompts them that sign-in is required with direct navigation to `SignInScreen`.
- **Change Password Bottom Sheet**: Modal sheet with password validation, minimum character checks, matching verification, and Supabase auth update password integration.
- **Dedicated Reset Password Flow**: Screen providing email password reset instructions dispatched via Supabase email recovery.
- **Offline Cache Status & Gender Breakdown**: `OfflineCacheSheet` displays live cache readiness badge ("Ready for Offline Use" or "Cache Empty"), individual gender counts for `der`, `die`, and `das`, and extended core vocabulary pre-seeding (130+ words).

#### 14. Reactive "Show Hints & Explanations" Preference & German Grammar Rule Engine
Implemented across [`GrammarRuleHint`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/lib/domain/models/grammar_rule_hint.dart), [`ResultCard`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/lib/features/lookup/screens/result_card.dart), [`QuizScreen`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/lib/features/quiz/screens/quiz_screen.dart), [`SettingsProvider`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/lib/features/settings/providers/settings_provider.dart), and [`AppLocalizations`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/lib/core/localization/app_localizations.dart):
- **Full Reactive Preference Integration**: Connected `showHintsProvider` directly to `ResultCard` and `QuizScreen`. When disabled by the user ("Show hints & explanations: Display extra info on result cards" toggled off), all contextual hints, example sentences, and grammar explanations are cleanly hidden from result cards and quiz feedback cards, leaving a minimal, clean article presentation.
- **German Grammar Suffix Rule Engine**: Added `GrammarRuleHint` domain model detecting 20+ canonical German noun gender suffixes:
  - **Feminine (*die*)**: `-ung`, `-heit`, `-keit`, `-schaft`, `-tion`, `-ion`, `-tät`, `-ik`, `-ei`, `-ie`, `-ur`, `-in` (female titles/professions)
  - **Neuter (*das*)**: `-chen` (diminutives), `-lein` (diminutives), `-ment`, `-um` (Latin loans), `-tum`, `-ma` (Greek loans)
  - **Masculine (*der*)**: `-ismus`, `-ling`, `-or`, `-ist` (person nouns), `-ant`, `-ent`
- **Multilingual Explanations**: Grammar rules are fully localized across English, German, Arabic (RTL), and Turkish.
- **Clean ResultCard Presentation**: When enabled, `ResultCard` displays the `_GrammarHintView` (`Icons.lightbulb_outline_rounded`) alongside `_ExampleSentenceView`. When toggled off, both disappear reactively without disrupting core word lookups.
- **Quiz Feedback Integration**: Quiz feedback card conditionally renders example sentences and grammar hints when `showHints` is true, and suppresses them when false for rapid quiz drilling.

---

### Spaced Repetition System (SRS) Mechanics

The Spaced Repetition System schedules noun practice using an expanding Leitner interval algorithm:

```mermaid
stateDiagram-v2
    [*] --> Stage1: New word or wrong answer
    Stage1 --> Stage2: Correct (Interval: 1 day)
    Stage2 --> Stage3: Correct (Interval: 3 days)
    Stage3 --> Stage4: Correct (Interval: 7 days)
    Stage4 --> Stage5: Correct (Interval: 14 days)
    Stage5 --> Stage5: Correct (Interval: 14 days, Mastered ⭐)

    Stage5 --> Stage3: Incorrect (demote 2 stages, review in 4h)
    Stage4 --> Stage2: Incorrect (demote 2 stages, review in 4h)
    Stage3 --> Stage1: Incorrect (demote 2 stages, review in 4h)
    Stage2 --> Stage1: Incorrect (demote to stage 1, review in 4h)
    Stage1 --> Stage1: Incorrect (review in 4h)
```

#### Stages & Interval Schedule

| Stage | Name | Interval | Criteria |
|---|---|---|---|
| **1** | **Learning** | **4 hours** | Newly introduced or recently failed word |
| **2** | **Review** | **1 day** | 1 correct quiz answer |
| **3** | **Familiar** | **3 days** | 2 consecutive correct answers |
| **4** | **Solid** | **7 days** | 3 consecutive correct answers |
| **5** | **Mastered** 🌟 | **14 days** | 4+ consecutive correct answers |

#### Scheduling Features
1. **Automatic Interleaving**: In standard quiz mode, [`QuizNotifier._fetchSmartBatch()`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/lib/features/quiz/providers/quiz_provider.dart) queries overdue words (`nextReview <= now`) and queues them at the head of the question queue, followed by fresh vocabulary.
2. **Dedicated SRS Review Mode**: When due words are available, a **`Due (X)`** chip appears in the Quiz header. Tapping it starts an isolated session on due cards with an exit control.
3. **Completion Celebration**: Once all due words are practiced, an automated celebratory view confirms the learner is caught up.
4. **Card Feedback**: Each question displays its current stage tag; answering renders a feedback banner with the updated stage and next scheduled review date.
5. **Profile Metrics**: The Profile Screen displays aggregate counts for **Due now**, **Learning**, **Reviewing**, **Mastered**, and an overall retention mastery bar.

---

### Weekly Activity Heatmap & Progress Trends

To provide learners with visual feedback on consistency and habit formation, Kapiert tracks daily learning actions across rolling multi-day windows (default 14 days, displayed in a 7-day weekly view).

#### 1. Activity Domain Models
- [`DailyActivity`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/lib/domain/models/daily_activity.dart): Aggregates daily lookup and quiz metrics (`totalCount`, `quizCount`, `quizCorrect`, `lookupCount`, `uniqueWords`, `accuracy`). Calculates intensity level `0–4` based on action thresholds:
  - Level 0: 0 actions (unfilled / subtle background)
  - Level 1: 1–4 actions (light tint)
  - Level 2: 5–9 actions (moderate tint)
  - Level 3: 10–19 actions (vibrant tint)
  - Level 4: 20+ actions (high intensity primary glow)
- [`AdvancedStats`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/lib/domain/models/advanced_stats.dart): Computes week-over-week trends, active day count (out of 7), daily average actions, overall accuracy rate, and identifies the learner's peak practice day (`bestDayCount`, `bestDayDate`).

#### 2. Local Aggregation Engine
Implemented in [`StorageService.getAdvancedStats()`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/lib/core/storage/storage_service.dart):
- Queries SQLite `history` with SQL date aggregation:
  ```sql
  SELECT
    strftime('%Y-%m-%d', timestamp) as day_str,
    COUNT(*) as total_count,
    SUM(CASE WHEN mode = 'quiz' THEN 1 ELSE 0 END) as quiz_count,
    SUM(CASE WHEN mode = 'quiz' AND correct = 1 THEN 1 ELSE 0 END) as quiz_correct,
    SUM(CASE WHEN mode = 'lookup' THEN 1 ELSE 0 END) as lookup_count,
    COUNT(DISTINCT word) as unique_words
  FROM history
  WHERE timestamp >= ?
  GROUP BY day_str
  ORDER BY day_str ASC
  ```
- Fills missing calendar days with zero-count `DailyActivity` instances so that every day in the rolling window is represented continuously.

#### 3. Interactive Visualization Cards
- [`AdvancedStatsCard`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/lib/features/profile/widgets/advanced_stats_card.dart):
  - **7-Day Activity Heatmap Grid**: Rendered with smooth rounded cells colored by intensity level. Displays weekday initial (`M`, `D`, `M`, `D`, `F`, `S`, `S`) and day numbers.
  - **Interactive Day Inspector Pill**: Tapping any day cell highlights it with a focused outline and reveals an animated inspection badge displaying exact counts (e.g. `12 actions · 10 quiz (80%) · 2 lookups · 9 words`).
  - **Daily Practice Volume Bar Chart**: An animated vertical bar chart displaying proportional volume per day with a baseline bar for rest days.
  - **Key Metrics Grid**: Displays 7-Day Total volume, Week-over-Week trend badge (`+15% vs last week`), Daily Average, and Best Day record.

---

### Achievements & Gamification Milestones

Kapiert features a gamification engine designed to reward learner consistency, vocabulary acquisition volume, quiz accuracy, SRS mastery, and curation.

#### 1. Milestone Categories & Badges
Achievements are modeled in [`Achievement`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/lib/domain/models/achievement.dart) across 5 distinct categories, spanning from Day 1 to a 6-month mastery roadmap:

| Category | Icon | 6-Month Spanning Milestones |
|---|---|---|
| **Streak & Consistency** (`streak`) | 🔥 | Streak Starter (3d), Flame Keeper (7d), Iron Discipline (14d), Monthly Titan (30d / 1 month), Two-Month Flame (60d / 2 months), Quarterly Champion (90d / 3 months), Seasoned Scholar (120d / 4 months), Iron Will (150d / 5 months), Half-Year Legend (180d / 6 months), Consistent Learner (30 active days), Season of Practice (90 active days), Half-Year Odyssey (180 active days over 6 months) |
| **Vocabulary Volume** (`vocabulary`) | 📚 | First Step (1 word), Curious Learner (10 words), Vocabulary Builder (50 words), Century Club (100 words), Word Master (250 words), Lexicon Explorer (500 words), Dictionary Devotee (1,000 words), German Lexicographer (2,000 unique words) |
| **Quiz Mastery** (`mastery`) | 🎯 | Quiz Novice (10 questions), Quiz Enthusiast (50 questions), Quiz Veteran (200 questions), Quiz Champion (500 questions), Quiz Grandmaster (1,000 questions), Legend of Articles (2,500 questions over 6 months), Der / Die / Das Grandmasters (25 correct per gender), Mistake Vanquishers (10 and 50 mistakes cleared) |
| **Spaced Repetition** (`srs`) | 🃏 | First Retention (5 words to Stage 5), Memory Master (20 words to Stage 5), Stage 3 Adept (25 words to Stage 3), Long-Term Retainer (25 words to Stage 5), Memory Legend (100 words mastered to Stage 5) |
| **Favorites** (`favorites`) | ⭐ | Curator (5 favorites), Lexicon Collector (20 favorites), Vocabulary Vault (50 favorites) |

#### 2. Evaluation & Unnotified Unlock Detection
Implemented in [`StorageService.getAchievements()`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/lib/core/storage/storage_service.dart) and [`AchievementsRepositoryImpl`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/lib/data/repositories/achievements_repository_impl.dart):
- Reads active streak from `SharedPreferences`, unique words, quiz answer count, and accuracy from SQLite `history`, SRS mastery counts from `srs_items`, and total bookmarked count from `favorites`.
- Cross-references current metrics against target thresholds.
- When an achievement threshold is crossed for the first time, it is committed to SQLite `achievements` table with `is_unlocked = 1`, current UTC timestamp, and `notified = 0`.
- Calling `checkNewUnlocks()` queries unnotified unlocks, returns them for in-app celebration, and marks them `notified = 1`.

#### 3. Real-Time In-Quiz Celebration & Modal Gallery
- **Live Celebration Pill**: When an answer during a quiz session unlocks an achievement, [`QuizScreen`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/lib/features/quiz/screens/quiz_screen.dart) displays an animated achievement banner with a glowing trophy icon and milestone title:
  > 🏆 **Milestone Unlocked!** [Achievement Title]
- **Profile Summary Card** ([`AchievementsCard`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/lib/features/profile/widgets/achievements_card.dart)): Shows overall progress bar, preview badge tiles with subtle glow effects for unlocked badges, and category filter chips.
- **Milestone Detail Sheet** ([`MilestoneDetailSheet`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/lib/features/profile/widgets/milestone_detail_sheet.dart)): Full-screen modal gallery displaying all badges spanning the 6-month roadmap, unlocked timestamps, progress bars for in-progress items, and category tabs (`All`, `Streaks`, `Vocabulary`, `Quiz`, `SRS`, `Favorites`).

---

## 5. Supabase Cloud & Sync Architecture

Supabase provides cloud authentication, database persistence, and cross-device synchronization. Migration scripts are maintained in [`supabase/migrations/`](file:///c:/Users/ASUS/Downloads/German_Articles/supabase/migrations).

### Relational Database Schema

```mermaid
erDiagram
    PROFILES {
        uuid id PK "references auth.users"
        text display_name
        timestamptz created_at
        timestamptz updated_at
    }
    LOOKUP_HISTORY {
        bigint id PK
        uuid user_id FK
        uuid client_id "UNIQUE(user_id, client_id)"
        timestamptz timestamp
        text word
        text article
        boolean correct
        text mode
    }
    STREAKS {
        uuid user_id PK
        int current_streak
        date last_active_date
        timestamptz updated_at
    }
    FAVORITES {
        bigint id PK
        uuid user_id FK
        text word
        text article
        text gender
        text plural
        text translation
        timestamptz created_at
    }
    USER_SETTINGS {
        uuid user_id PK
        boolean show_hints
        boolean dark_mode
        timestamptz updated_at
    }

    PROFILES ||--o| LOOKUP_HISTORY : owns
    PROFILES ||--o| STREAKS : owns
    PROFILES ||--o| FAVORITES : owns
    PROFILES ||--o| USER_SETTINGS : owns
```

### Row Level Security (RLS) Policies
Every table enforces Postgres Row Level Security (`alter table ... enable row level security`):
- `SELECT`, `INSERT`, `UPDATE`, `DELETE` policies enforce `auth.uid() = user_id`.
- Defaults are set to `auth.uid()` on insert to prevent accidental spoofing.

### Two-Way Synchronization Protocol
Managed by [`SyncNotifier`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/lib/features/sync/providers/sync_provider.dart):
1. **Local-First Writes**: When offline or in guest mode, entries write instantly to SQLite with `synced = 0`.
2. **Pushes**: When online and signed in, unpushed rows are batched to Supabase. Client UUIDs (`client_id`) ensure idempotent upserts. On success, SQLite rows are marked `synced = 1`.
3. **Pulls**: Queries records where `id > last_pulled_cursor` to fetch new data from other devices.
4. **Guest Migration**: Upon first sign-in, any local guest history is automatically merged into the user's cloud account.
5. **Sign-out Safety**: Before logging out, pending local changes are flushed to the cloud before local account data is cleared.

### The `merge_streak` Stored Procedure
Defined in [`20261004000000_cloud_sync.sql`](file:///c:/Users/ASUS/Downloads/German_Articles/supabase/migrations/20261004000000_cloud_sync.sql):
- Solves multi-device streak sync where two devices were used on different days or offline.
- Calculates contiguous day intervals $[L - N + 1, L]$. If device and server runs overlap or touch, it creates their mathematical union; otherwise, the newest active date wins without overwriting longer streaks with zeros.

---

## 6. Design System & UI/UX

Implemented in [`AppColors`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/lib/shared/theme/app_colors.dart) and [`AppTheme`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/lib/shared/theme/app_theme.dart):

### Color Palette
- 🔵 **Der (Masculine)**: `#1A5CAA` (Light) / `#3B82F6` (Dark)
- 🔴 **Die (Feminine)**: `#C02626` (Light) / `#EF4444` (Dark)
- 🟢 **Das (Neuter)**: `#2D7A3A` (Light) / `#22C55E` (Dark)
- 🟠 **Streak / Due Alert**: `#F97316` / `#FB923C`
- 🟡 **Favorites / Mastered**: `#FFB800`
- ⚪/⚫ **Surfaces**: Curated neutral slate/zinc layers (`#F8F9FA` light / `#161822` dark) with border-defined contrast.

### Typography & Polish
- Google Font **Nunito** for rounded, friendly, high-legibility German characters with umlauts and uppercase nouns.
- Smooth transitions and micro-animations via `flutter_animate`.
- Scrollable constrained wrappers ensure zero layout overflows regardless of screen aspect ratio or on-screen keyboards.

---

## 7. Testing & Quality Assurance

Both the backend and Flutter applications maintain comprehensive automated test suites.

### Test Execution Commands

```bash
# 1. Backend API & Translation Tests (21 tests)
cd backend
python -m pytest tests/ -v

# 2. Flutter Unit, Widget & Integration Tests (165 tests)
cd flutter_app
flutter test

# 3. Flutter Static Analysis (0 issues)
flutter analyze
```

### Coverage Overview

| Test Suite | File | Tests | Validates |
|---|---|---|---|
| **API Contract & Sentences** | [`backend/tests/test_api.py`](file:///c:/Users/ASUS/Downloads/German_Articles/backend/tests/test_api.py) | 13 | Query normalization, exact lookup, plural lookup, umlaut variants, Wiktionary fallback, random batch balance, anti-clumping, and multilingual example sentences (`de`, `en`, `ar`, `tr`). |
| **Translation & Wiktionary Engine** | [`backend/tests/test_translations.py`](file:///c:/Users/ASUS/Downloads/German_Articles/backend/tests/test_translations.py) | 8 | Curated vocabulary bank (1,200+ words), clean HTML/markup definition formatter, transcription variant lookups, live/cached English translation retrieval, compound noun glosses, plural lemma resolution, and translated quiz batches. |
| **Grammar Rule Hint Model** | [`flutter_app/test/domain/models/grammar_rule_hint_test.dart`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/test/domain/models/grammar_rule_hint_test.dart) | 5 | Suffix pattern matching for feminine (`-ung`, `-heit`, `-keit`, `-schaft`, `-tion`, `-tät`), neuter (`-chen`, `-lein`, `-ment`, `-um`), masculine (`-ismus`, `-ling`, `-or`, `-ist`), non-matching exception guards, and 4-language localized explanations. |
| **Localization Engine** | [`flutter_app/test/core/localization/app_localizations_test.dart`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/test/core/localization/app_localizations_test.dart) | 6 | All 4 locales (`en`, `ar`, `tr`, `de`), RTL directionality detection, translation fallbacks, delegate resolution, and dynamic parameterized helper methods. |
| **Sentence Domain Models** | [`flutter_app/test/domain/models/example_sentence_test.dart`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/test/domain/models/example_sentence_test.dart) | 5 | Translation retrieval by language code, fallback order, JSON serialization/deserialization, and offline sentence provider. |
| **Network Client** | [`flutter_app/test/core/network/api_client_test.dart`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/test/core/network/api_client_test.dart) | 4 | HTTP GET parsing, timeout handling, error mapping. |
| **Word Models** | [`flutter_app/test/domain/models/word_model_test.dart`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/test/domain/models/word_model_test.dart) | 7 | Equality, JSON conversion, gender labels, backward-compatible sentence serialization. |
| **Result Card & Sentences** | [`flutter_app/test/features/lookup/screens/result_card_test.dart`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/test/features/lookup/screens/result_card_test.dart) | 7 | Article badge, German word, translation, example sentence rendering with active locale translation, clipboard copy, offline cache badge, reactive suppression of hints/sentences when `showHints` is false, and grammar rule hint card when `showHints` is true. |
| **Settings & Bottom Sheets** | [`flutter_app/test/features/settings/screens/settings_screen_test.dart`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/test/features/settings/screens/settings_screen_test.dart) | 5 | Language tile, 4-language bottom sheet, Arabic RTL dynamic update, notifications sheet opening, and offline cache sheet opening with gender breakdown chips. |
| **Notification Settings Model** | [`flutter_app/test/domain/models/notification_settings_test.dart`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/test/domain/models/notification_settings_test.dart) | 5 | Default values, TimeOfDay reminderTime conversion, copyWith updates, symmetric JSON serialization, equality, and hash code. |
| **Notification Scheduler** | [`flutter_app/test/features/notifications/providers/notification_provider_test.dart`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/test/features/notifications/providers/notification_provider_test.dart) | 7 | State initialization, toggling daily reminders, permission requests, zonedSchedule daily reminders, cancel schedules, time picker updates, streak/SRS switches, and instant test notification. |
| **Notification Settings Widget** | [`flutter_app/test/features/notifications/widgets/notification_settings_sheet_test.dart`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/test/features/notifications/widgets/notification_settings_sheet_test.dart) | 3 | Modal bottom sheet header, master switch toggle, revealed reminder controls, time picker trigger, and test notification button with confirmation SnackBar. |
| **Article Local Data Source** | [`flutter_app/test/data/datasources/article_local_ds_test.dart`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/test/data/datasources/article_local_ds_test.dart) | 11 | Leading article query normalization (`der`, `die`, `das`, `ein`, `eine`), punctuation cleanup, case-insensitivity, masculine/feminine/neuter core lookups, English translation verification, compound noun head suffix analysis, random word batching, and unknown word fallbacks. |
| **Article Repository Fallback** | [`flutter_app/test/data/repositories/article_repository_impl_test.dart`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/test/data/repositories/article_repository_impl_test.dart) | 8 | Remote-first lookup with auto-caching, transparent offline fallback to local SQLite cache on network failure, error rethrow when absent, random/randomBatch offline fallbacks, and health checks. |
| **Offline Cache Sheet Widget** | [`flutter_app/test/features/settings/widgets/offline_cache_sheet_test.dart`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/test/features/settings/widgets/offline_cache_sheet_test.dart) | 3 | Stored article count metric display, readiness status badge, individual gender breakdown pills (`der`, `die`, `das`), pre-seed extended vocabulary button invocation with feedback SnackBar, and clear offline cache button with confirmation. |
| **Daily Activity Model** | [`flutter_app/test/domain/models/daily_activity_test.dart`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/test/domain/models/daily_activity_test.dart) | 3 | Intensity levels 0–4 thresholds, accuracy calculation, model immutability. |
| **Advanced Stats Model** | [`flutter_app/test/domain/models/advanced_stats_test.dart`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/test/domain/models/advanced_stats_test.dart) | 4 | Aggregation logic, week-over-week trends, rolling slice computations, best day tracking. |
| **Achievements Model** | [`flutter_app/test/domain/models/achievement_test.dart`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/test/domain/models/achievement_test.dart) | 3 | Categories, unlock status, progress percentage, copyWith behavior. |
| **SRS Domain Model** | [`flutter_app/test/domain/models/srs_item_test.dart`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/test/domain/models/srs_item_test.dart) | 6 | Stages 1–5 advancement, incorrect answer regression, interval durations, `isDue` logic, SQLite serialization. |
| **SRS Scheduling** | [`flutter_app/test/features/quiz/srs_scheduling_test.dart`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/test/features/quiz/srs_scheduling_test.dart) | 3 | Smart batch prioritization of due words, review mode entry/exit, session completion. |
| **SRS Quiz Widgets** | [`flutter_app/test/features/quiz/srs_quiz_widget_test.dart`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/test/features/quiz/srs_quiz_widget_test.dart) | 3 | Due chip rendering, mode banner toggle, feedback badge with review scheduling, and reactive suppression of feedback sentence/grammar hint when `showHints` is false. |
| **SRS Profile Stats** | [`flutter_app/test/features/profile/srs_profile_test.dart`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/test/features/profile/srs_profile_test.dart) | 1 | Spaced repetition section rendering, retention metric tiles, mastery bar. |
| **Advanced Stats Widget** | [`flutter_app/test/features/profile/advanced_stats_widget_test.dart`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/test/features/profile/advanced_stats_widget_test.dart) | 2 | 7-day activity heatmap grid, interactive day inspector pill, volume bar chart, key metric tiles. |
| **Achievements Widget** | [`flutter_app/test/features/profile/achievements_widget_test.dart`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/test/features/profile/achievements_widget_test.dart) | 1 | Milestones summary card, badge previews, modal gallery sheet invocation. |
| **Quiz Core** | [`flutter_app/test/features/quiz/quiz_randomization_test.dart`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/test/features/quiz/quiz_randomization_test.dart) | 4 | Word deduplication, anti-clumping, offline fallback pool. |
| **Mistakes Quiz Mode** | [`flutter_app/test/features/quiz/mistakes_quiz_test.dart`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/test/features/quiz/mistakes_quiz_test.dart) | 3 | Dedicated incorrect article review session initiation, distinct incorrect words queue, mistakes counter refresh, and session exit back to standard quiz practice. |
| **Profile & Mastery** | [`flutter_app/test/features/profile/profile_screen_test.dart`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/test/features/profile/profile_screen_test.dart) | 3 | Guest vs signed-in states, article mastery bars, weakest article recommendation. |
| **Change Password & Auth Guard** | [`flutter_app/test/features/profile/change_password_test.dart`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/test/features/profile/change_password_test.dart) | 4 | Change password bottom sheet fields, password mismatch validation, authenticated password update via remote datasource, and guest login requirement guard dialog. |
| **Password Reset Flow** | [`flutter_app/test/features/auth/reset_password_screen_test.dart`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/test/features/auth/reset_password_screen_test.dart) | 2 | Reset password form presentation, valid email submission triggering Supabase recovery email, and confirmation card rendering. |
| **History & SRS Reset** | [`flutter_app/test/features/history/history_srs_reset_test.dart`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/test/features/history/history_srs_reset_test.dart) | 1 | Verifies that clearing history synchronously resets Spaced Repetition (SRS) provider state, wiping due items and resetting due count to zero. |
| **Favorites** | [`flutter_app/test/features/favorites/favorites_widget_test.dart`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/test/features/favorites/favorites_widget_test.dart) | 5 | Star toggling, history favorites tab, focused review quiz. |
| **Legal Consent Gate** | [`flutter_app/test/features/legal/app_first_use_gate_test.dart`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/test/features/legal/app_first_use_gate_test.dart) | 5 | First-launch lock, legal document markdown viewers, unlock upon acceptance. |
| **Auth & Verification** | [`flutter_app/test/features/auth/verify_email_screen_test.dart`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/test/features/auth/verify_email_screen_test.dart) | 7 | OTP inputs, pasting 6-digit codes, validation errors. |

---

## 8. Setup & Deployment Guide

### 1. Running the FastAPI Backend

#### Via Docker Compose
```bash
docker compose up -d
# Server available at http://127.0.0.1:8000
```

#### Via Local Python
```bash
cd backend
pip install -r requirements.txt
python main.py
```

### 2. Running the Flutter App

```bash
cd flutter_app
flutter pub get

# Windows Desktop (connects to local backend at 127.0.0.1:8000)
flutter run -d windows

# Chrome (Web)
flutter run -d chrome

# Android Emulator (connects to 10.0.2.2:8000)
flutter run
```

#### Connecting to Supabase Cloud
Provide build parameters via `--dart-define` or use the in-app **`Setup Supabase`** sheet:
```bash
flutter run \
  --dart-define=API_BASE_URL=https://your-backend.onrender.com \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJhbGciOi...
```

### 3. Deploying to Render
The repository includes [`render.yaml`](file:///c:/Users/ASUS/Downloads/German_Articles/render.yaml):
1. Connect the repository at [dashboard.render.com](https://dashboard.render.com).
2. Render reads `render.yaml`, downloads `nouns.csv`, installs dependencies, and launches `uvicorn main:app`.
3. Use the deployed URL as `API_BASE_URL` in Flutter builds.
