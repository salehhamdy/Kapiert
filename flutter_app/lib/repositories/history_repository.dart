import '../models/lookup_history.dart';
import '../services/storage_service.dart';

/// Repository wrapping [StorageService] for history and streak data.
class HistoryRepository {
  Future<List<LookupHistory>> getHistory({String? filter}) =>
      StorageService.getHistory(filter: filter);

  Future<Map<String, dynamic>> getStats() => StorageService.getStats();

  Future<void> addEntry(LookupHistory entry) =>
      StorageService.addHistory(entry);

  Future<void> clearHistory() => StorageService.clearHistory();

  int getStreak() => StorageService.getStreak();

  Future<void> updateStreak() => StorageService.updateStreak();

  Future<void> resetStreak() => StorageService.resetStreak();
}
