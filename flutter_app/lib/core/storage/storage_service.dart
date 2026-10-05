import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/lookup_history.dart';
import '../../domain/models/word_model.dart';
import '../utils/uuid.dart';

/// Manages local storage: SQLite for history and favorites, SharedPreferences for settings.
class StorageService {
  static Database? _database;
  static SharedPreferences? _prefs;

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
      version: 3,
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

  /// Clear all history.
  static Future<void> clearHistory() async {
    await _db.delete('history');
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
  static const _keySettingsUpdatedAt = 'settings_updated_at';

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
}
