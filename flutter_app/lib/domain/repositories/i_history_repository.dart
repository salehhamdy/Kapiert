import '../models/lookup_history.dart';

/// Abstract contract for history and streak operations.
abstract interface class IHistoryRepository {
  Future<List<LookupHistory>> getHistory({String? filter});
  Future<Map<String, dynamic>> getStats();
  Future<void> addEntry(LookupHistory entry);
  Future<void> clearHistory();
  int getStreak();
  Future<void> updateStreak();
  Future<void> resetStreak();
}
