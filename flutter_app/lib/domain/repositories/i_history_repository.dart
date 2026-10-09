import '../models/advanced_stats.dart';
import '../models/lookup_history.dart';

import '../models/word_model.dart';

/// Abstract contract for history and streak operations.
abstract interface class IHistoryRepository {
  Future<List<LookupHistory>> getHistory({String? filter});
  Future<Map<String, dynamic>> getStats();
  Future<AdvancedStats> getAdvancedStats({int days = 14});
  Future<void> addEntry(LookupHistory entry);
  Future<void> clearHistory();
  Future<List<WordModel>> getIncorrectWords({int limit = 50});
  Future<int> getIncorrectWordsCount();
  int getStreak();
  Future<void> updateStreak();
  Future<void> resetStreak();
}
