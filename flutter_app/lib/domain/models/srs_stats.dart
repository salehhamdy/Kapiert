/// Aggregate statistics for the user's Spaced Repetition System.
class SrsStats {
  final int totalCount;
  final int dueCount;
  final int learningCount;   // Stage 1-2
  final int reviewingCount;  // Stage 3-4
  final int masteredCount;   // Stage 5

  const SrsStats({
    this.totalCount = 0,
    this.dueCount = 0,
    this.learningCount = 0,
    this.reviewingCount = 0,
    this.masteredCount = 0,
  });

  const SrsStats.empty()
      : totalCount = 0,
        dueCount = 0,
        learningCount = 0,
        reviewingCount = 0,
        masteredCount = 0;

  /// Percentage of tracked words that have reached mastery (0.0 to 1.0).
  double get masteryRate =>
      totalCount > 0 ? masteredCount / totalCount : 0.0;
}
