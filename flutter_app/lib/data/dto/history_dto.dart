import '../../domain/models/lookup_history.dart';

/// Data Transfer Object for history entries stored in SQLite.
class HistoryDto {
  static LookupHistory fromMap(Map<String, dynamic> map) {
    return LookupHistory(
      id: map['id'] as int?,
      clientId: map['client_id'] as String?,
      timestamp: DateTime.parse(map['timestamp'] as String),
      word: map['word'] as String,
      article: map['article'] as String,
      correct: (map['correct'] as int) == 1,
      mode: map['mode'] as String,
    );
  }

  static Map<String, dynamic> toMap(LookupHistory entry) {
    return {
      if (entry.clientId != null) 'client_id': entry.clientId,
      'timestamp': entry.timestamp.toIso8601String(),
      'word': entry.word,
      'article': entry.article,
      'correct': entry.correct ? 1 : 0,
      'mode': entry.mode,
    };
  }

  // ---------------------------------------------------------------------------
  // Supabase (public.lookup_history)
  // ---------------------------------------------------------------------------

  /// Local SQLite row -> Supabase insert payload.
  static Map<String, dynamic> toRemote(
    Map<String, dynamic> localRow,
    String userId,
  ) {
    return {
      'user_id': userId,
      'client_id': localRow['client_id'],
      'timestamp':
          DateTime.parse(localRow['timestamp'] as String).toUtc().toIso8601String(),
      'word': localRow['word'],
      'article': localRow['article'],
      'correct': (localRow['correct'] as int) == 1,
      'mode': localRow['mode'],
    };
  }

  /// Supabase row -> local SQLite row (already synced).
  static Map<String, dynamic> fromRemote(Map<String, dynamic> remote) {
    return {
      'client_id': remote['client_id'],
      'timestamp':
          DateTime.parse(remote['timestamp'] as String).toLocal().toIso8601String(),
      'word': remote['word'],
      'article': remote['article'],
      'correct': remote['correct'] == true ? 1 : 0,
      'mode': remote['mode'],
      'synced': 1,
    };
  }
}
