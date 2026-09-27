import '../../core/storage/storage_service.dart';
import '../../domain/models/lookup_history.dart';
import '../../domain/repositories/i_history_repository.dart';

/// Concrete implementation of [IHistoryRepository] using local [StorageService].
class HistoryRepositoryImpl implements IHistoryRepository {
  @override
  Future<List<LookupHistory>> getHistory({String? filter}) =>
      StorageService.getHistory(filter: filter);

  @override
  Future<Map<String, dynamic>> getStats() => StorageService.getStats();

  @override
  Future<void> addEntry(LookupHistory entry) =>
      StorageService.addHistory(entry);

  @override
  Future<void> clearHistory() => StorageService.clearHistory();

  @override
  int getStreak() => StorageService.getStreak();

  @override
  Future<void> updateStreak() => StorageService.updateStreak();

  @override
  Future<void> resetStreak() => StorageService.resetStreak();
}
