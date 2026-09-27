/// Represents a single lookup or quiz entry in the history log.
class LookupHistory {
  final int? id;
  final DateTime timestamp;
  final String word;
  final String article;
  final bool correct; // true = correct answer in quiz, or just a lookup
  final String mode; // "lookup" | "quiz"

  const LookupHistory({
    this.id,
    required this.timestamp,
    required this.word,
    required this.article,
    required this.correct,
    required this.mode,
  });

  /// Convert to a map for SQLite insertion.
  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'word': word,
      'article': article,
      'correct': correct ? 1 : 0,
      'mode': mode,
    };
  }

  /// Create a LookupHistory from a SQLite row map.
  factory LookupHistory.fromMap(Map<String, dynamic> map) {
    return LookupHistory(
      id: map['id'] as int?,
      timestamp: DateTime.parse(map['timestamp'] as String),
      word: map['word'] as String,
      article: map['article'] as String,
      correct: (map['correct'] as int) == 1,
      mode: map['mode'] as String,
    );
  }
}
