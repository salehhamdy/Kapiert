import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/lookup_history.dart';

/// Manages local storage: SQLite for history, SharedPreferences for settings.
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
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            timestamp TEXT NOT NULL,
            word TEXT NOT NULL,
            article TEXT NOT NULL,
            correct INTEGER NOT NULL DEFAULT 1,
            mode TEXT NOT NULL DEFAULT 'lookup'
          )
        ''');
      },
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

  /// Add an entry to the history log.
  static Future<void> addHistory(LookupHistory entry) async {
    await _db.insert('history', entry.toMap());
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

    return {
      'total': total,
      'totalQuiz': totalQuiz,
      'correct': correct,
      'accuracy': accuracy,
    };
  }

  /// Clear all history.
  static Future<void> clearHistory() async {
    await _db.delete('history');
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

  // ---------------------------------------------------------------------------
  // Settings (SharedPreferences)
  // ---------------------------------------------------------------------------

  static const _keyShowHints = 'show_hints';
  static const _keyDarkMode = 'dark_mode';

  static bool getShowHints() => _p.getBool(_keyShowHints) ?? true;
  static Future<void> setShowHints(bool value) => _p.setBool(_keyShowHints, value);

  static bool getDarkMode() => _p.getBool(_keyDarkMode) ?? false;
  static Future<void> setDarkMode(bool value) => _p.setBool(_keyDarkMode, value);
}
