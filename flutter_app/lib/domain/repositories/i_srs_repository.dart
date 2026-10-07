import '../models/srs_item.dart';
import '../models/srs_stats.dart';
import '../models/word_model.dart';

/// Abstract repository for Spaced Repetition System operations.
abstract class ISrsRepository {
  /// Fetches items that are currently due for spaced review.
  Future<List<SrsItem>> getDueItems({int limit = 30});

  /// Fetches all tracked SRS items, sorted by mastery stage.
  Future<List<SrsItem>> getAllItems();

  /// Gets the SRS status of a specific noun, or null if never practiced.
  Future<SrsItem?> getItem(String word);

  /// Records a quiz review attempt (correct or incorrect) and calculates the next review time.
  Future<SrsItem> recordReview(
    WordModel word, {
    required bool correct,
    DateTime? now,
  });

  /// Retrieves aggregate SRS mastery and due statistics.
  Future<SrsStats> getStats();

  /// Resets all SRS data.
  Future<void> resetSrs();
}
