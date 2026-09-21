import '../../domain/models/lookup_history.dart';

/// Data Transfer Object for history entries stored in SQLite.
class HistoryDto {
  static LookupHistory fromMap(Map<String, dynamic> map) {
    return LookupHistory(
      id: map['id'] as int?,
      timestamp: DateTime.parse(map['timestamp'] as String),
      word: map['word'] as String,
      article: map['article'] as String,
      correct: (map['correct'] as int) == 1,
      mode: map['mode'] as String,
    );
  }

  static Map<String, dynamic> toMap(LookupHistory entry) {
    return {
      'timestamp': entry.timestamp.toIso8601String(),
      'word': entry.word,
      'article': entry.article,
      'correct': entry.correct ? 1 : 0,
      'mode': entry.mode,
    };
  }
}
