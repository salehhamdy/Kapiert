import 'dart:async';

import '../../core/storage/storage_service.dart';
import '../../domain/models/advanced_stats.dart';
import '../../domain/models/lookup_history.dart';
import '../../domain/models/word_model.dart';
import '../../domain/repositories/i_history_repository.dart';
import '../../domain/repositories/i_sync_repository.dart';

/// Concrete implementation of [IHistoryRepository].
///
/// Reads and writes always hit local [StorageService] first (fast, offline);
/// changes are then pushed to the cloud in the background via [ISyncRepository].
class HistoryRepositoryImpl implements IHistoryRepository {
  HistoryRepositoryImpl(this._sync);

  final ISyncRepository _sync;

  @override
  Future<List<LookupHistory>> getHistory({String? filter}) =>
      StorageService.getHistory(filter: filter);

  @override
  Future<Map<String, dynamic>> getStats() => StorageService.getStats();

  @override
  Future<AdvancedStats> getAdvancedStats({int days = 14}) =>
      StorageService.getAdvancedStats(days: days);

  @override
  Future<void> addEntry(LookupHistory entry) async {
    await StorageService.addHistory(entry);
    unawaited(_sync.pushHistory());
  }

  @override
  Future<void> clearHistory() async {
    await StorageService.clearHistory();
    unawaited(_sync.clearRemoteHistory());
  }

  @override
  Future<List<WordModel>> getIncorrectWords({int limit = 50}) =>
      StorageService.getIncorrectQuizWords(limit: limit);

  @override
  Future<int> getIncorrectWordsCount() =>
      StorageService.getIncorrectWordsCount();

  @override
  int getStreak() => StorageService.getStreak();

  @override
  Future<void> updateStreak() async {
    await StorageService.updateStreak();
    unawaited(_sync.pushStreak());
  }

  @override
  Future<void> resetStreak() async {
    await StorageService.resetStreak();
    unawaited(_sync.resetRemoteStreak());
  }
}
