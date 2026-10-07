---
name: kapiert-sqlite-storage
description: >-
  Provides procedures for managing Kapiert's local-first SQLite database and SharedPreferences storage.
  Use when modifying the database schema, adding tables or indexes, writing date aggregation queries
  for daily activity heatmaps, streaks, SRS Leitner tables, or milestones.
---

# SQLite & Local-First Storage Engineering

Kapiert implements an offline-first storage engine that provides zero-latency reads and writes for desktop and mobile platforms.

## Core Component: `StorageService`

Located in [`flutter_app/lib/core/storage/storage_service.dart`](file:///c:/Users/ASUS/Downloads/German_Articles/flutter_app/lib/core/storage/storage_service.dart).

### 1. Desktop FFI & Platform Initialization
On Windows, Linux, and macOS desktop environments, SQLite is loaded via FFI:
```dart
if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}
```

### 2. Schema Evolution & Versioning
Current Database Schema: **Version 5** (`derdiedas.db`).

| Version | Tables Added / Migrated |
|---|---|
| **v1** | `history` table (`word`, `article`, `correct`, `timestamp`, `mode`, `client_id`, `synced`) |
| **v2** | Index on `history(client_id)` and `history(timestamp)` |
| **v3** | `favorites` table (`word`, `article`, `gender`, `plural`, `translation`, `created_at`) |
| **v4** | `srs_items` table (Leitner stages 1–5, review intervals, attempts, correct counters) |
| **v5** | `achievements` table (`id`, `title`, `description`, `category`, `icon_name`, `target_value`, `current_value`, `is_unlocked`, `unlocked_at`, `notified`) + index on `achievements(notified)` |

When modifying or adding tables:
1. Increment `_dbVersion` in `StorageService`.
2. Implement migration block in `onUpgrade(db, oldVersion, newVersion)`:
   ```dart
   if (oldVersion < 5) {
     await _createAchievementsTable(db);
   }
   ```
3. Update `PROJECT_DOCUMENTATION.md` and test suite.

### 3. Date Aggregation & Activity Heatmap Queries
To calculate rolling activity across days without missing empty calendar days:
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
- In Dart, generate a complete continuous list of `DateTime.utc(year, month, day)` for each day in the window.
- Map SQL rows to their corresponding calendar day; default missing days to `DailyActivity` with count 0.

### 4. Streak Calculation Logic
Streaks are calculated based on calendar days with activity:
- An active day requires at least 1 quiz or lookup action.
- The streak continues if the learner practised today OR yesterday.
- If more than 1 day has passed without practice, the streak resets to 0.
