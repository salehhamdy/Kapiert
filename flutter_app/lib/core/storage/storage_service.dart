import 'dart:convert';
import 'package:flutter/material.dart' show Icons, IconData;
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/achievement.dart';
import '../../domain/models/advanced_stats.dart';
import '../../domain/models/daily_activity.dart';
import '../../domain/models/example_sentence.dart';
import '../../domain/models/lookup_history.dart';
import '../../domain/models/notification_settings.dart';
import '../../domain/models/srs_item.dart';
import '../../domain/models/srs_stats.dart';
import '../../domain/models/word_model.dart';
import '../utils/uuid.dart';

/// Manages local storage: SQLite for history, favorites, and SRS, SharedPreferences for settings.
class StorageService {
  static Database? _database;
  static SharedPreferences? _prefs;

  /// Whether the database has been initialized.
  static bool get isInitialized => _database != null;

  // ---------------------------------------------------------------------------
  // Initialization
  // ---------------------------------------------------------------------------

  /// Initialize both SQLite and SharedPreferences.
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _database = await _openDatabase();
  }

  static Future<Database> _openDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = '$dbPath/derdiedas.db';

    return openDatabase(
      path,
      version: 6,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            client_id TEXT NOT NULL,
            timestamp TEXT NOT NULL,
            word TEXT NOT NULL,
            article TEXT NOT NULL,
            correct INTEGER NOT NULL DEFAULT 1,
            mode TEXT NOT NULL DEFAULT 'lookup',
            synced INTEGER NOT NULL DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE favorites (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            word TEXT NOT NULL UNIQUE,
            article TEXT NOT NULL,
            gender TEXT NOT NULL,
            plural TEXT,
            translation TEXT,
            timestamp TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE srs_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            word TEXT NOT NULL UNIQUE,
            article TEXT NOT NULL,
            gender TEXT NOT NULL,
            plural TEXT,
            translation TEXT,
            stage INTEGER NOT NULL DEFAULT 1,
            consecutive_correct INTEGER NOT NULL DEFAULT 0,
            total_attempts INTEGER NOT NULL DEFAULT 0,
            total_correct INTEGER NOT NULL DEFAULT 0,
            last_reviewed TEXT,
            next_review TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE achievements (
            id TEXT PRIMARY KEY,
            unlocked_at TEXT NOT NULL,
            notified INTEGER NOT NULL DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE article_cache (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            word TEXT NOT NULL UNIQUE,
            article TEXT NOT NULL,
            gender TEXT NOT NULL,
            plural TEXT,
            translation TEXT,
            source TEXT NOT NULL DEFAULT 'offline_cache',
            examples TEXT,
            cached_at TEXT NOT NULL
          )
        ''');
        await _createSyncIndexes(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE history ADD COLUMN client_id TEXT');
          await db.execute(
            'ALTER TABLE history ADD COLUMN synced INTEGER NOT NULL DEFAULT 0',
          );
          final rows = await db.query('history', columns: ['id']);
          final batch = db.batch();
          for (final row in rows) {
            batch.update(
              'history',
              {'client_id': uuidV4()},
              where: 'id = ?',
              whereArgs: [row['id']],
            );
          }
          await batch.commit(noResult: true);
        }
        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS favorites (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              word TEXT NOT NULL UNIQUE,
              article TEXT NOT NULL,
              gender TEXT NOT NULL,
              plural TEXT,
              translation TEXT,
              timestamp TEXT NOT NULL
            )
          ''');
        }
        if (oldVersion < 4) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS srs_items (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              word TEXT NOT NULL UNIQUE,
              article TEXT NOT NULL,
              gender TEXT NOT NULL,
              plural TEXT,
              translation TEXT,
              stage INTEGER NOT NULL DEFAULT 1,
              consecutive_correct INTEGER NOT NULL DEFAULT 0,
              total_attempts INTEGER NOT NULL DEFAULT 0,
              total_correct INTEGER NOT NULL DEFAULT 0,
              last_reviewed TEXT,
              next_review TEXT NOT NULL
            )
          ''');
          await _bootstrapSrsFromHistory(db);
        }
        if (oldVersion < 5) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS achievements (
              id TEXT PRIMARY KEY,
              unlocked_at TEXT NOT NULL,
              notified INTEGER NOT NULL DEFAULT 0
            )
          ''');
        }
        if (oldVersion < 6) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS article_cache (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              word TEXT NOT NULL UNIQUE,
              article TEXT NOT NULL,
              gender TEXT NOT NULL,
              plural TEXT,
              translation TEXT,
              source TEXT NOT NULL DEFAULT 'offline_cache',
              examples TEXT,
              cached_at TEXT NOT NULL
            )
          ''');
        }
        await _createSyncIndexes(db);
      },
    );
  }

  static Future<void> _createSyncIndexes(Database db) async {
    await db.execute(
      'CREATE UNIQUE INDEX IF NOT EXISTS history_client_id_idx ON history (client_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS history_synced_idx ON history (synced)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS favorites_word_idx ON favorites (LOWER(word))',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS srs_next_review_idx ON srs_items (next_review)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS srs_word_idx ON srs_items (LOWER(word))',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS achievements_notified_idx ON achievements (notified)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS article_cache_word_idx ON article_cache (LOWER(word))',
    );
  }

  static Database get _db {
    if (_database == null) throw StateError('StorageService not initialized');
    return _database!;
  }

  static SharedPreferences get _p {
    if (_prefs == null) throw StateError('StorageService not initialized');
    return _prefs!;
  }

  // ---------------------------------------------------------------------------
  // History (SQLite)
  // ---------------------------------------------------------------------------

  /// Add an entry to the history log (marked as not yet synced).
  static Future<void> addHistory(LookupHistory entry) async {
    await _db.insert('history', {
      ...entry.toMap(),
      'client_id': entry.clientId ?? uuidV4(),
      'synced': 0,
    });
  }

  /// Get all history entries, most recent first.
  static Future<List<LookupHistory>> getHistory({String? filter}) async {
    String? where;
    List<dynamic>? whereArgs;

    if (filter == 'correct') {
      where = 'correct = ?';
      whereArgs = [1];
    } else if (filter == 'incorrect') {
      where = 'correct = ?';
      whereArgs = [0];
    }

    final rows = await _db.query(
      'history',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'timestamp DESC',
      limit: 500,
    );

    return rows.map((row) => LookupHistory.fromMap(row)).toList();
  }

  /// Get summary statistics.
  static Future<Map<String, dynamic>> getStats() async {
    final total = Sqflite.firstIntValue(
      await _db.rawQuery('SELECT COUNT(*) FROM history'),
    ) ?? 0;

    final correct = Sqflite.firstIntValue(
      await _db.rawQuery('SELECT COUNT(*) FROM history WHERE correct = 1 AND mode = ?', ['quiz']),
    ) ?? 0;

    final totalQuiz = Sqflite.firstIntValue(
      await _db.rawQuery('SELECT COUNT(*) FROM history WHERE mode = ?', ['quiz']),
    ) ?? 0;

    final accuracy = totalQuiz > 0 ? (correct / totalQuiz * 100) : 0.0;

    final uniqueWords = Sqflite.firstIntValue(
      await _db.rawQuery('SELECT COUNT(DISTINCT LOWER(word)) FROM history'),
    ) ?? 0;

    // Per-article totals and quiz performance: {der: {total, quiz, correct}}
    final articleRows = await _db.rawQuery('''
      SELECT LOWER(article) AS article,
             COUNT(*) AS total,
             SUM(CASE WHEN mode = 'quiz' THEN 1 ELSE 0 END) AS quiz,
             SUM(CASE WHEN mode = 'quiz' AND correct = 1 THEN 1 ELSE 0 END) AS correct
      FROM history
      GROUP BY LOWER(article)
    ''');
    final byArticle = <String, Map<String, int>>{
      for (final row in articleRows)
        row['article'] as String: {
          'total': (row['total'] as int?) ?? 0,
          'quiz': (row['quiz'] as int?) ?? 0,
          'correct': (row['correct'] as int?) ?? 0,
        },
    };

    final firstRow = await _db.rawQuery('SELECT MIN(timestamp) AS first FROM history');
    final firstActivity = firstRow.isEmpty
        ? null
        : DateTime.tryParse((firstRow.first['first'] as String?) ?? '');

    return {
      'total': total,
      'totalQuiz': totalQuiz,
      'totalLookups': total - totalQuiz,
      'correct': correct,
      'accuracy': accuracy,
      'uniqueWords': uniqueWords,
      'byArticle': byArticle,
      'firstActivity': firstActivity,
      'streak': getStreak(),
    };
  }

  /// Clear all history, reset SRS records, and reset achievements.
  static Future<void> clearHistory() async {
    await _db.delete('history');
    await _db.delete('srs_items');
    await _db.delete('achievements');
  }

  /// Retrieves multi-day learning activity and progress metrics for the past [days] days.
  static Future<AdvancedStats> getAdvancedStats({
    int days = 14,
    DateTime? now,
  }) async {
    final currentNow = now ?? DateTime.now().toUtc();
    final today =
        DateTime.utc(currentNow.year, currentNow.month, currentNow.day);
    final startDate = today.subtract(Duration(days: days - 1));
    final startIso = startDate.toIso8601String().substring(0, 10);

    final rows = await _db.rawQuery('''
      SELECT substr(timestamp, 1, 10) AS day_str,
             COUNT(*) AS total_count,
             SUM(CASE WHEN mode = 'quiz' THEN 1 ELSE 0 END) AS quiz_count,
             SUM(CASE WHEN mode = 'quiz' AND correct = 1 THEN 1 ELSE 0 END) AS quiz_correct,
             SUM(CASE WHEN mode = 'lookup' THEN 1 ELSE 0 END) AS lookup_count,
             COUNT(DISTINCT LOWER(word)) AS unique_words
      FROM history
      WHERE substr(timestamp, 1, 10) >= ?
      GROUP BY substr(timestamp, 1, 10)
    ''', [startIso]);

    final rowMap = <String, Map<String, dynamic>>{
      for (final r in rows) (r['day_str'] as String): r,
    };

    final dailyList = <DailyActivity>[];
    int totalActivities = 0;
    int bestDayCount = 0;
    DateTime? bestDayDate;
    int totalQuiz = 0;
    int totalCorrect = 0;

    for (int i = 0; i < days; i++) {
      final date = startDate.add(Duration(days: i));
      final dateKey = date.toIso8601String().substring(0, 10);
      final r = rowMap[dateKey];

      if (r != null) {
        final total = (r['total_count'] as int?) ?? 0;
        final quiz = (r['quiz_count'] as int?) ?? 0;
        final correct = (r['quiz_correct'] as int?) ?? 0;
        final lookup = (r['lookup_count'] as int?) ?? 0;
        final unique = (r['unique_words'] as int?) ?? 0;

        totalActivities += total;
        totalQuiz += quiz;
        totalCorrect += correct;

        if (total > bestDayCount) {
          bestDayCount = total;
          bestDayDate = date;
        }

        dailyList.add(DailyActivity(
          date: date,
          totalCount: total,
          quizCount: quiz,
          quizCorrect: correct,
          lookupCount: lookup,
          uniqueWords: unique,
        ));
      } else {
        dailyList.add(DailyActivity.empty(date));
      }
    }

    // Last 7 days metrics
    final last7 = dailyList.length <= 7
        ? dailyList
        : dailyList.sublist(dailyList.length - 7);
    final currentWeekTotal =
        last7.fold<int>(0, (sum, d) => sum + d.totalCount);
    final activeDaysCount = last7.where((d) => d.hasActivity).length;
    final dailyAverage = currentWeekTotal / 7.0;

    // Previous 7 days metrics (days 8-14 from today)
    int previousWeekTotal = 0;
    if (dailyList.length >= 14) {
      final prev7 =
          dailyList.sublist(dailyList.length - 14, dailyList.length - 7);
      previousWeekTotal = prev7.fold<int>(0, (sum, d) => sum + d.totalCount);
    }

    final overallAccuracy =
        totalQuiz > 0 ? (totalCorrect / totalQuiz * 100) : 0.0;

    return AdvancedStats(
      dailyActivities: dailyList,
      totalActivities: totalActivities,
      currentWeekTotal: currentWeekTotal,
      previousWeekTotal: previousWeekTotal,
      bestDayCount: bestDayCount,
      bestDayDate: bestDayDate,
      activeDaysCount: activeDaysCount,
      dailyAverage: dailyAverage,
      overallAccuracy: overallAccuracy,
    );
  }

  // ---------------------------------------------------------------------------
  // Favorites (SQLite)
  // ---------------------------------------------------------------------------

  /// Add or update a word in favorites.
  static Future<void> addFavorite(WordModel word) async {
    await _db.insert(
      'favorites',
      {
        'word': word.word,
        'article': word.article,
        'gender': word.gender,
        'plural': word.plural,
        'translation': word.translation,
        'timestamp': DateTime.now().toUtc().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Remove a word from favorites.
  static Future<void> removeFavorite(String word) async {
    await _db.delete(
      'favorites',
      where: 'LOWER(word) = ?',
      whereArgs: [word.toLowerCase()],
    );
  }

  /// Check whether a word is in favorites.
  static Future<bool> isFavorite(String word) async {
    final count = Sqflite.firstIntValue(
      await _db.rawQuery(
        'SELECT COUNT(*) FROM favorites WHERE LOWER(word) = ?',
        [word.toLowerCase()],
      ),
    ) ?? 0;
    return count > 0;
  }

  /// Get all favorites, sorted by most recently added.
  static Future<List<WordModel>> getFavorites() async {
    final rows = await _db.query(
      'favorites',
      orderBy: 'timestamp DESC',
    );
    return rows.map((r) => WordModel(
      word: r['word'] as String,
      article: r['article'] as String,
      gender: (r['gender'] as String?) ?? 'm',
      plural: r['plural'] as String?,
      translation: r['translation'] as String?,
      source: 'favorites',
    )).toList();
  }

  /// Clear all favorites.
  static Future<void> clearFavorites() async {
    await _db.delete('favorites');
  }

  // ---------------------------------------------------------------------------
  // History sync helpers
  // ---------------------------------------------------------------------------

  /// Raw rows that have not been pushed to the cloud yet, oldest first.
  static Future<List<Map<String, dynamic>>> getUnsyncedHistory({
    int limit = 500,
  }) {
    return _db.query(
      'history',
      where: 'synced = 0',
      orderBy: 'id ASC',
      limit: limit,
    );
  }

  /// Mark rows as pushed.
  static Future<void> markHistorySynced(List<String> clientIds) async {
    if (clientIds.isEmpty) return;
    final batch = _db.batch();
    for (final id in clientIds) {
      batch.update(
        'history',
        {'synced': 1},
        where: 'client_id = ?',
        whereArgs: [id],
      );
    }
    await batch.commit(noResult: true);
  }

  /// Insert rows pulled from the cloud. Rows we already have (same
  /// client_id) are ignored.
  static Future<void> insertSyncedHistory(
    List<Map<String, dynamic>> rows,
  ) async {
    if (rows.isEmpty) return;
    final batch = _db.batch();
    for (final row in rows) {
      batch.insert(
        'history',
        {...row, 'synced': 1},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
    await batch.commit(noResult: true);
  }

  /// Delete rows that came from (or were pushed to) the cloud, keeping any
  /// local-only guest entries.
  static Future<void> deleteSyncedHistory() async {
    await _db.delete('history', where: 'synced = 1');
  }

  // ---------------------------------------------------------------------------
  // Streak (SharedPreferences)
  // ---------------------------------------------------------------------------

  static const _keyStreak = 'streak_count';
  static const _keyLastActive = 'last_active_date';

  /// Get the current streak count.
  static int getStreak() => _p.getInt(_keyStreak) ?? 0;

  /// Update the streak based on today's activity.
  static Future<void> updateStreak() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final lastActive = _p.getString(_keyLastActive);

    if (lastActive == today) return; // Already counted today

    if (lastActive != null) {
      final lastDate = DateTime.parse(lastActive);
      final diff = DateTime.now().difference(lastDate).inDays;

      if (diff == 1) {
        // Consecutive day — increment
        await _p.setInt(_keyStreak, getStreak() + 1);
      } else if (diff > 1) {
        // Streak broken — reset
        await _p.setInt(_keyStreak, 1);
      }
    } else {
      // First time
      await _p.setInt(_keyStreak, 1);
    }

    await _p.setString(_keyLastActive, today);
  }

  /// Reset the streak to 0.
  static Future<void> resetStreak() async {
    await _p.setInt(_keyStreak, 0);
    await _p.remove(_keyLastActive);
  }

  /// Last active day as `yyyy-MM-dd`, or null if never active.
  static String? getLastActiveDate() => _p.getString(_keyLastActive);

  /// Overwrite the local streak (used when applying the merged cloud value).
  static Future<void> setStreak(int count, String? lastActiveDate) async {
    await _p.setInt(_keyStreak, count);
    if (lastActiveDate == null) {
      await _p.remove(_keyLastActive);
    } else {
      await _p.setString(_keyLastActive, lastActiveDate);
    }
  }

  // ---------------------------------------------------------------------------
  // Settings (SharedPreferences)
  // ---------------------------------------------------------------------------

  static const _keyShowHints = 'show_hints';
  static const _keyDarkMode = 'dark_mode';
  static const _keyLanguage = 'app_language';
  static const _keySettingsUpdatedAt = 'settings_updated_at';
  static const _keyHasAcceptedTerms = 'has_accepted_terms_and_policy';
  static const _keyTermsAcceptedAt = 'terms_accepted_at';

  /// Whether the user has explicitly accepted the Terms of Use and Privacy Policy.
  static bool hasAcceptedTerms() {
    if (_prefs == null) return false;
    return _p.getBool(_keyHasAcceptedTerms) ?? false;
  }

  /// Record user consent for Terms of Use and Privacy Policy.
  static Future<void> setAcceptedTerms(bool value) async {
    if (_prefs == null) return;
    await _p.setBool(_keyHasAcceptedTerms, value);
    if (value) {
      await _p.setString(
        _keyTermsAcceptedAt,
        DateTime.now().toUtc().toIso8601String(),
      );
    } else {
      await _p.remove(_keyTermsAcceptedAt);
    }
  }

  /// ISO-8601 UTC timestamp of when terms were accepted, or null if never accepted.
  static String? getTermsAcceptedAt() {
    if (_prefs == null) return null;
    return _p.getString(_keyTermsAcceptedAt);
  }

  static bool getShowHints() => _p.getBool(_keyShowHints) ?? true;
  static Future<void> setShowHints(bool value) async {
    await _p.setBool(_keyShowHints, value);
    await _touchSettings();
  }

  static bool getDarkMode() => _p.getBool(_keyDarkMode) ?? false;
  static Future<void> setDarkMode(bool value) async {
    await _p.setBool(_keyDarkMode, value);
    await _touchSettings();
  }

  static String getLanguage() => _p.getString(_keyLanguage) ?? 'en';
  static Future<void> setLanguage(String code) async {
    await _p.setString(_keyLanguage, code);
    await _touchSettings();
  }

  static const _keyNotificationSettings = 'notification_settings';

  /// Retrieves user notification preferences.
  static NotificationSettings getNotificationSettings() {
    if (_prefs == null) return const NotificationSettings();
    final raw = _p.getString(_keyNotificationSettings);
    if (raw == null || raw.isEmpty) return const NotificationSettings();
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return NotificationSettings.fromJson(decoded);
    } catch (_) {
      return const NotificationSettings();
    }
  }

  /// Saves user notification preferences.
  static Future<void> setNotificationSettings(
      NotificationSettings settings) async {
    if (_prefs == null) return;
    await _p.setString(
      _keyNotificationSettings,
      jsonEncode(settings.toJson()),
    );
    await _touchSettings();
  }

  /// When settings were last changed on this device (null = never changed).
  static DateTime? getSettingsUpdatedAt() {
    final raw = _p.getString(_keySettingsUpdatedAt);
    return raw == null ? null : DateTime.tryParse(raw);
  }

  static Future<void> _touchSettings() => _p.setString(
        _keySettingsUpdatedAt,
        DateTime.now().toUtc().toIso8601String(),
      );

  /// Apply settings that came from the cloud without bumping the timestamp.
  static Future<void> applySyncedSettings({
    required bool showHints,
    required bool darkMode,
    required DateTime updatedAt,
  }) async {
    await _p.setBool(_keyShowHints, showHints);
    await _p.setBool(_keyDarkMode, darkMode);
    await _p.setString(
      _keySettingsUpdatedAt,
      updatedAt.toUtc().toIso8601String(),
    );
  }

  // ---------------------------------------------------------------------------
  // Sync metadata (SharedPreferences)
  // ---------------------------------------------------------------------------

  static const _keySyncOwner = 'sync_owner_uid';
  static const _keySyncCursorPrefix = 'sync_history_cursor_';

  /// The user whose cloud data is currently mirrored locally.
  static String? getSyncOwner() => _p.getString(_keySyncOwner);
  static Future<void> setSyncOwner(String? uid) => uid == null
      ? _p.remove(_keySyncOwner)
      : _p.setString(_keySyncOwner, uid);

  /// Highest remote `lookup_history.id` already pulled for [uid].
  static int getHistoryCursor(String uid) =>
      _p.getInt('$_keySyncCursorPrefix$uid') ?? 0;
  static Future<void> setHistoryCursor(String uid, int cursor) =>
      _p.setInt('$_keySyncCursorPrefix$uid', cursor);
  static Future<void> clearHistoryCursor(String uid) =>
      _p.remove('$_keySyncCursorPrefix$uid');

  // ---------------------------------------------------------------------------
  // Spaced Repetition System (SRS) (SQLite)
  // ---------------------------------------------------------------------------

  /// Records a quiz review result for a noun and recalculates its SRS stage and next review.
  static Future<SrsItem> recordSrsReview(
    WordModel word, {
    required bool correct,
    DateTime? now,
  }) async {
    final currentNow = now ?? DateTime.now().toUtc();
    final existing = await getSrsItem(word.word);
    SrsItem updated;

    if (existing != null) {
      updated = existing.recordAttempt(correct: correct, now: currentNow);
      await _db.update(
        'srs_items',
        updated.toMap()..remove('id'),
        where: 'LOWER(word) = ?',
        whereArgs: [word.word.toLowerCase()],
      );
    } else {
      final interval = correct
          ? SrsItem.intervalForStage(2)
          : const Duration(hours: 4);
      updated = SrsItem(
        word: word.word,
        article: word.article,
        gender: word.gender,
        plural: word.plural,
        translation: word.translation,
        stage: correct ? 2 : 1,
        consecutiveCorrect: correct ? 1 : 0,
        totalAttempts: 1,
        totalCorrect: correct ? 1 : 0,
        lastReviewed: currentNow,
        nextReview: currentNow.add(interval),
      );
      await _db.insert(
        'srs_items',
        updated.toMap()..remove('id'),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    return updated;
  }

  /// Gets the SRS status of a single word by name.
  static Future<SrsItem?> getSrsItem(String word) async {
    final rows = await _db.query(
      'srs_items',
      where: 'LOWER(word) = ?',
      whereArgs: [word.toLowerCase()],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return SrsItem.fromMap(rows.first);
  }

  /// Gets nouns that are currently due for spaced review, earliest due date first.
  static Future<List<SrsItem>> getDueSrsItems({int limit = 50}) async {
    final nowIso = DateTime.now().toUtc().toIso8601String();
    final rows = await _db.query(
      'srs_items',
      where: 'next_review <= ?',
      whereArgs: [nowIso],
      orderBy: 'next_review ASC',
      limit: limit,
    );
    return rows.map((r) => SrsItem.fromMap(r)).toList();
  }

  /// Gets all tracked SRS nouns, sorted by stage descending and next review ascending.
  static Future<List<SrsItem>> getAllSrsItems() async {
    final rows = await _db.query(
      'srs_items',
      orderBy: 'stage DESC, next_review ASC',
    );
    return rows.map((r) => SrsItem.fromMap(r)).toList();
  }

  /// Gets summary SRS metrics for the learner.
  static Future<SrsStats> getSrsStats() async {
    final nowIso = DateTime.now().toUtc().toIso8601String();
    final total = Sqflite.firstIntValue(
      await _db.rawQuery('SELECT COUNT(*) FROM srs_items'),
    ) ?? 0;

    final due = Sqflite.firstIntValue(
      await _db.rawQuery(
        'SELECT COUNT(*) FROM srs_items WHERE next_review <= ?',
        [nowIso],
      ),
    ) ?? 0;

    final learning = Sqflite.firstIntValue(
      await _db.rawQuery(
        'SELECT COUNT(*) FROM srs_items WHERE stage IN (1, 2)',
      ),
    ) ?? 0;

    final reviewing = Sqflite.firstIntValue(
      await _db.rawQuery(
        'SELECT COUNT(*) FROM srs_items WHERE stage IN (3, 4)',
      ),
    ) ?? 0;

    final mastered = Sqflite.firstIntValue(
      await _db.rawQuery(
        'SELECT COUNT(*) FROM srs_items WHERE stage >= 5',
      ),
    ) ?? 0;

    return SrsStats(
      totalCount: total,
      dueCount: due,
      learningCount: learning,
      reviewingCount: reviewing,
      masteredCount: mastered,
    );
  }

  /// Deletes all SRS entries.
  static Future<void> resetSrs() async {
    await _db.delete('srs_items');
  }

  /// Seeds initial SRS cards from existing quiz history if srs_items is empty.
  static Future<void> _bootstrapSrsFromHistory(Database db) async {
    try {
      final rows = await db.rawQuery('''
        SELECT word, article,
               COUNT(*) as attempts,
               SUM(CASE WHEN correct = 1 THEN 1 ELSE 0 END) as correct_count,
               MAX(timestamp) as last_ts
        FROM history
        WHERE mode = 'quiz'
        GROUP BY LOWER(word)
      ''');
      if (rows.isEmpty) return;
      final now = DateTime.now().toUtc();
      final batch = db.batch();
      for (final r in rows) {
        final word = r['word'] as String;
        final article = r['article'] as String;
        final attempts = (r['attempts'] as int?) ?? 1;
        final correctCount = (r['correct_count'] as int?) ?? 0;
        final gender = article == 'der'
            ? 'm'
            : (article == 'die' ? 'f' : 'n');
        final acc = correctCount / attempts;
        int stage = 1;
        if (acc >= 0.9 && attempts >= 3) {
          stage = 3;
        } else if (acc >= 0.7 && attempts >= 2) {
          stage = 2;
        }
        final nextReview = acc < 0.6
            ? now
            : now.add(SrsItem.intervalForStage(stage));

        batch.insert(
          'srs_items',
          {
            'word': word,
            'article': article,
            'gender': gender,
            'stage': stage,
            'consecutive_correct': correctCount,
            'total_attempts': attempts,
            'total_correct': correctCount,
            'last_reviewed': r['last_ts'],
            'next_review': nextReview.toIso8601String(),
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
      await batch.commit(noResult: true);
    } catch (_) {}
  }

  // ---------------------------------------------------------------------------
  // Achievements & Milestones (SQLite & Evaluation)
  // ---------------------------------------------------------------------------

  /// Evaluates and returns all milestones with live user progress.
  static Future<List<Achievement>> getAchievements({DateTime? now}) async {
    final currentNow = now ?? DateTime.now().toUtc();

    // 1. Gather current user stats
    final streak = getStreak();
    final uniqueWords = Sqflite.firstIntValue(
          await _db.rawQuery('SELECT COUNT(DISTINCT LOWER(word)) FROM history'),
        ) ?? 0;
    final totalQuiz = Sqflite.firstIntValue(
          await _db.rawQuery(
            'SELECT COUNT(*) FROM history WHERE mode = ?',
            ['quiz'],
          ),
        ) ?? 0;
    final derCorrect = Sqflite.firstIntValue(
          await _db.rawQuery(
            'SELECT COUNT(*) FROM history WHERE mode = ? AND correct = 1 AND LOWER(article) = ?',
            ['quiz', 'der'],
          ),
        ) ?? 0;
    final dieCorrect = Sqflite.firstIntValue(
          await _db.rawQuery(
            'SELECT COUNT(*) FROM history WHERE mode = ? AND correct = 1 AND LOWER(article) = ?',
            ['quiz', 'die'],
          ),
        ) ?? 0;
    final dasCorrect = Sqflite.firstIntValue(
          await _db.rawQuery(
            'SELECT COUNT(*) FROM history WHERE mode = ? AND correct = 1 AND LOWER(article) = ?',
            ['quiz', 'das'],
          ),
        ) ?? 0;

    final totalSrs = Sqflite.firstIntValue(
          await _db.rawQuery('SELECT COUNT(*) FROM srs_items'),
        ) ?? 0;
    final srsStage3Plus = Sqflite.firstIntValue(
          await _db.rawQuery('SELECT COUNT(*) FROM srs_items WHERE stage >= 3'),
        ) ?? 0;
    final srsMastered = Sqflite.firstIntValue(
          await _db.rawQuery('SELECT COUNT(*) FROM srs_items WHERE stage >= 5'),
        ) ?? 0;

    final favCount = Sqflite.firstIntValue(
          await _db.rawQuery('SELECT COUNT(*) FROM favorites'),
        ) ?? 0;

    // 2. Query already-unlocked achievements
    final unlockedRows = await _db.query('achievements');
    final unlockedMap = <String, DateTime>{
      for (final r in unlockedRows)
        (r['id'] as String): DateTime.parse(r['unlocked_at'] as String),
    };

    // 3. Define all standard milestones
    final definitions = <({
      String id,
      String title,
      String description,
      AchievementCategory category,
      IconData icon,
      int target,
      int current,
    })>[
      // Streaks
      (
        id: 'streak_3',
        title: 'Streak Starter',
        description: 'Maintain a 3-day learning streak',
        category: AchievementCategory.streak,
        icon: Icons.local_fire_department_rounded,
        target: 3,
        current: streak,
      ),
      (
        id: 'streak_7',
        title: 'Flame Keeper',
        description: 'Maintain a 7-day learning streak',
        category: AchievementCategory.streak,
        icon: Icons.whatshot_rounded,
        target: 7,
        current: streak,
      ),
      (
        id: 'streak_14',
        title: 'Iron Discipline',
        description: 'Reach a 14-day learning streak',
        category: AchievementCategory.streak,
        icon: Icons.bolt_rounded,
        target: 14,
        current: streak,
      ),
      (
        id: 'streak_30',
        title: 'Monthly Titan',
        description: 'Achieve an epic 30-day streak',
        category: AchievementCategory.streak,
        icon: Icons.workspace_premium_rounded,
        target: 30,
        current: streak,
      ),

      // Vocabulary
      (
        id: 'first_word',
        title: 'First Step',
        description: 'Practice or look up your first German noun',
        category: AchievementCategory.vocabulary,
        icon: Icons.flag_rounded,
        target: 1,
        current: uniqueWords,
      ),
      (
        id: 'words_10',
        title: 'Curious Learner',
        description: 'Practice 10 unique German nouns',
        category: AchievementCategory.vocabulary,
        icon: Icons.menu_book_rounded,
        target: 10,
        current: uniqueWords,
      ),
      (
        id: 'words_50',
        title: 'Vocabulary Builder',
        description: 'Practice 50 unique German nouns',
        category: AchievementCategory.vocabulary,
        icon: Icons.auto_stories_rounded,
        target: 50,
        current: uniqueWords,
      ),
      (
        id: 'words_100',
        title: 'Century Club',
        description: 'Practice 100 unique German nouns',
        category: AchievementCategory.vocabulary,
        icon: Icons.military_tech_rounded,
        target: 100,
        current: uniqueWords,
      ),
      (
        id: 'words_250',
        title: 'Word Master',
        description: 'Practice 250 unique German nouns',
        category: AchievementCategory.vocabulary,
        icon: Icons.school_rounded,
        target: 250,
        current: uniqueWords,
      ),

      // Mastery
      (
        id: 'quiz_10',
        title: 'Quiz Novice',
        description: 'Answer 10 quiz questions',
        category: AchievementCategory.mastery,
        icon: Icons.quiz_rounded,
        target: 10,
        current: totalQuiz,
      ),
      (
        id: 'quiz_50',
        title: 'Quiz Enthusiast',
        description: 'Answer 50 quiz questions',
        category: AchievementCategory.mastery,
        icon: Icons.sports_score_rounded,
        target: 50,
        current: totalQuiz,
      ),
      (
        id: 'quiz_200',
        title: 'Quiz Veteran',
        description: 'Answer 200 quiz questions',
        category: AchievementCategory.mastery,
        icon: Icons.emoji_events_rounded,
        target: 200,
        current: totalQuiz,
      ),
      (
        id: 'der_master',
        title: 'Herr der Wörter',
        description: 'Answer 20 "der" questions correctly',
        category: AchievementCategory.mastery,
        icon: Icons.male_rounded,
        target: 20,
        current: derCorrect,
      ),
      (
        id: 'die_master',
        title: 'Königin der Grammatik',
        description: 'Answer 20 "die" questions correctly',
        category: AchievementCategory.mastery,
        icon: Icons.female_rounded,
        target: 20,
        current: dieCorrect,
      ),
      (
        id: 'das_master',
        title: 'Meister des Neutrums',
        description: 'Answer 20 "das" questions correctly',
        category: AchievementCategory.mastery,
        icon: Icons.diamond_rounded,
        target: 20,
        current: dasCorrect,
      ),

      // Spaced Repetition
      (
        id: 'srs_first',
        title: 'Memory Seed',
        description: 'Add your first noun to Spaced Repetition',
        category: AchievementCategory.srs,
        icon: Icons.psychology_rounded,
        target: 1,
        current: totalSrs,
      ),
      (
        id: 'srs_stage3',
        title: 'Solid Ground',
        description: 'Advance 5 nouns to SRS Stage 3 or higher',
        category: AchievementCategory.srs,
        icon: Icons.trending_up_rounded,
        target: 5,
        current: srsStage3Plus,
      ),
      (
        id: 'srs_mastered',
        title: 'Gold Standard',
        description: 'Reach Stage 5 (Mastered ⭐) with 5 nouns',
        category: AchievementCategory.srs,
        icon: Icons.star_rounded,
        target: 5,
        current: srsMastered,
      ),

      // Favorites
      (
        id: 'fav_5',
        title: 'Word Collector',
        description: 'Save 5 nouns to your Favorites',
        category: AchievementCategory.favorites,
        icon: Icons.bookmark_added_rounded,
        target: 5,
        current: favCount,
      ),
    ];

    final result = <Achievement>[];
    final batch = _db.batch();
    bool hasNewUnlocks = false;

    for (final def in definitions) {
      final isNowEligible = def.current >= def.target;
      DateTime? unlockDate = unlockedMap[def.id];

      if (isNowEligible && unlockDate == null) {
        // Newly unlocked!
        unlockDate = currentNow;
        batch.insert(
          'achievements',
          {
            'id': def.id,
            'unlocked_at': currentNow.toIso8601String(),
            'notified': 0,
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
        hasNewUnlocks = true;
      }

      result.add(Achievement(
        id: def.id,
        title: def.title,
        description: def.description,
        category: def.category,
        icon: def.icon,
        targetValue: def.target,
        currentValue: def.current,
        isUnlocked: unlockDate != null,
        unlockedAt: unlockDate,
      ));
    }

    if (hasNewUnlocks) {
      await batch.commit(noResult: true);
    }

    return result;
  }

  /// Returns any milestones that were recently unlocked and marks them notified.
  static Future<List<Achievement>> checkNewUnlocks() async {
    final unnotifiedRows = await _db.query(
      'achievements',
      where: 'notified = 0',
    );
    if (unnotifiedRows.isEmpty) return const [];

    final unnotifiedIds = unnotifiedRows.map((r) => r['id'] as String).toSet();
    final all = await getAchievements();
    final newlyUnlocked =
        all.where((a) => unnotifiedIds.contains(a.id)).toList();

    await _db.update(
      'achievements',
      {'notified': 1},
      where: 'notified = 0',
    );

    return newlyUnlocked;
  }

  /// Clears stored achievements.
  static Future<void> resetAchievements() async {
    await _db.delete('achievements');
  }

  // ---------------------------------------------------------------------------
  // Article Cache (SQLite) - Offline Mode
  // ---------------------------------------------------------------------------

  /// Caches an individual article for offline availability.
  static Future<void> cacheArticle(WordModel word) async {
    final examplesJson = word.exampleSentence != null
        ? jsonEncode(word.exampleSentence!.toJson())
        : null;

    await _db.insert(
      'article_cache',
      {
        'word': word.word,
        'article': word.article,
        'gender': word.gender,
        'plural': word.plural,
        'translation': word.translation,
        'source': word.source,
        'examples': examplesJson,
        'cached_at': DateTime.now().toUtc().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Bulk caches multiple articles in a single SQLite transaction.
  static Future<void> cacheArticles(List<WordModel> words) async {
    if (words.isEmpty) return;
    final batch = _db.batch();
    final now = DateTime.now().toUtc().toIso8601String();

    for (final word in words) {
      final examplesJson = word.exampleSentence != null
          ? jsonEncode(word.exampleSentence!.toJson())
          : null;

      batch.insert(
        'article_cache',
        {
          'word': word.word,
          'article': word.article,
          'gender': word.gender,
          'plural': word.plural,
          'translation': word.translation,
          'source': word.source,
          'examples': examplesJson,
          'cached_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  /// Retrieves a cached article by exact or lowercase word.
  static Future<WordModel?> getCachedArticle(String word) async {
    final clean = word.trim().toLowerCase();
    final rows = await _db.query(
      'article_cache',
      where: 'LOWER(word) = ?',
      whereArgs: [clean],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _mapRowToCachedWord(rows.first);
  }

  /// Searches cached articles with prefix or substring matching.
  static Future<List<WordModel>> searchCachedArticles(String query, {int limit = 20}) async {
    final clean = query.trim().toLowerCase();
    if (clean.isEmpty) return const [];
    final rows = await _db.query(
      'article_cache',
      where: 'LOWER(word) LIKE ?',
      whereArgs: ['%$clean%'],
      limit: limit,
    );
    return rows.map(_mapRowToCachedWord).toList();
  }

  /// Returns random cached articles (useful for offline quiz batching).
  static Future<List<WordModel>> getRandomCachedArticles({int count = 15}) async {
    final rows = await _db.query(
      'article_cache',
      orderBy: 'RANDOM()',
      limit: count,
    );
    return rows.map(_mapRowToCachedWord).toList();
  }

  /// Returns the total number of cached articles stored offline.
  static Future<int> getCachedArticlesCount() async {
    final result =
        await _db.rawQuery('SELECT COUNT(*) as count FROM article_cache');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Clears all offline cached articles.
  static Future<void> clearArticleCache() async {
    await _db.delete('article_cache');
  }

  static WordModel _mapRowToCachedWord(Map<String, dynamic> row) {
    ExampleSentence? exampleSentence;
    final examplesRaw = row['examples'] as String?;
    if (examplesRaw != null && examplesRaw.isNotEmpty) {
      try {
        final decoded = jsonDecode(examplesRaw) as Map<String, dynamic>;
        exampleSentence = ExampleSentence.fromJson(decoded);
      } catch (_) {}
    }

    return WordModel(
      word: row['word'] as String,
      article: row['article'] as String,
      gender: row['gender'] as String,
      plural: row['plural'] as String?,
      translation: row['translation'] as String?,
      exampleSentence: exampleSentence,
      source: 'offline_cache',
    );
  }
}

