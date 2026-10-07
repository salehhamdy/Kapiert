import '../../core/storage/storage_service.dart';
import '../../domain/models/srs_item.dart';
import '../../domain/models/srs_stats.dart';
import '../../domain/models/word_model.dart';
import '../../domain/repositories/i_srs_repository.dart';

/// Concrete implementation of [ISrsRepository] backed by local SQLite [StorageService].
class SrsRepositoryImpl implements ISrsRepository {
  @override
  Future<List<SrsItem>> getDueItems({int limit = 30}) {
    if (!StorageService.isInitialized) return Future.value([]);
    return StorageService.getDueSrsItems(limit: limit);
  }

  @override
  Future<List<SrsItem>> getAllItems() {
    if (!StorageService.isInitialized) return Future.value([]);
    return StorageService.getAllSrsItems();
  }

  @override
  Future<SrsItem?> getItem(String word) {
    if (!StorageService.isInitialized) return Future.value(null);
    return StorageService.getSrsItem(word);
  }

  @override
  Future<SrsItem> recordReview(
    WordModel word, {
    required bool correct,
    DateTime? now,
  }) {
    if (!StorageService.isInitialized) {
      final nowTime = now ?? DateTime.now().toUtc();
      final item = SrsItem(
        word: word.word,
        article: word.article,
        gender: word.gender,
        plural: word.plural,
        translation: word.translation,
        stage: correct ? 2 : 1,
        consecutiveCorrect: correct ? 1 : 0,
        totalAttempts: 1,
        totalCorrect: correct ? 1 : 0,
        lastReviewed: nowTime,
        nextReview: nowTime.add(
          correct ? const Duration(days: 1) : const Duration(hours: 4),
        ),
      );
      return Future.value(item);
    }
    return StorageService.recordSrsReview(word, correct: correct, now: now);
  }

  @override
  Future<SrsStats> getStats() {
    if (!StorageService.isInitialized) return Future.value(const SrsStats());
    return StorageService.getSrsStats();
  }

  @override
  Future<void> resetSrs() {
    if (!StorageService.isInitialized) return Future.value();
    return StorageService.resetSrs();
  }
}
