/// Represents aggregated user activity for a single calendar day.
class DailyActivity {
  const DailyActivity({
    required this.date,
    required this.totalCount,
    required this.quizCount,
    required this.quizCorrect,
    required this.lookupCount,
    required this.uniqueWords,
  });

  /// The normalized date (00:00:00 UTC/local).
  final DateTime date;

  /// Total actions taken on this day (quiz answers + lookups).
  final int totalCount;

  /// Number of quiz answers submitted.
  final int quizCount;

  /// Number of correct quiz answers.
  final int quizCorrect;

  /// Number of manual dictionary lookups.
  final int lookupCount;

  /// Number of unique German words encountered.
  final int uniqueWords;

  /// Quiz accuracy percentage (0.0 to 100.0).
  double get accuracy =>
      quizCount > 0 ? (quizCorrect / quizCount * 100) : 0.0;

  /// Whether any learning activity took place on this day.
  bool get hasActivity => totalCount > 0;

  /// Visual intensity level for activity heatmaps:
  /// - 0: No activity
  /// - 1: 1–4 actions
  /// - 2: 5–9 actions
  /// - 3: 10–19 actions
  /// - 4: 20+ actions
  int get intensityLevel {
    if (totalCount <= 0) return 0;
    if (totalCount <= 4) return 1;
    if (totalCount <= 9) return 2;
    if (totalCount <= 19) return 3;
    return 4;
  }

  /// Create a zero-activity entry for a given day.
  factory DailyActivity.empty(DateTime date) {
    return DailyActivity(
      date: DateTime.utc(date.year, date.month, date.day),
      totalCount: 0,
      quizCount: 0,
      quizCorrect: 0,
      lookupCount: 0,
      uniqueWords: 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String().substring(0, 10),
      'totalCount': totalCount,
      'quizCount': quizCount,
      'quizCorrect': quizCorrect,
      'lookupCount': lookupCount,
      'uniqueWords': uniqueWords,
    };
  }

  @override
  String toString() =>
      'DailyActivity(${date.toIso8601String().substring(0, 10)}: total=$totalCount, quiz=$quizCount, correct=$quizCorrect)';
}
