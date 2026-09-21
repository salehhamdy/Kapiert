import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../domain/models/lookup_history.dart';
import '../../../domain/repositories/i_history_repository.dart';

// ---------------------------------------------------------------------------
// History state
// ---------------------------------------------------------------------------

class HistoryState {
  const HistoryState({
    this.entries = const [],
    this.stats = const {},
    this.filter = 'all',
    this.loading = true,
  });

  final List<LookupHistory> entries;
  final Map<String, dynamic> stats;
  final String filter; // 'all' | 'correct' | 'incorrect'
  final bool loading;

  HistoryState copyWith({
    List<LookupHistory>? entries,
    Map<String, dynamic>? stats,
    String? filter,
    bool? loading,
  }) {
    return HistoryState(
      entries: entries ?? this.entries,
      stats: stats ?? this.stats,
      filter: filter ?? this.filter,
      loading: loading ?? this.loading,
    );
  }
}

// ---------------------------------------------------------------------------
// History notifier
// ---------------------------------------------------------------------------

class HistoryNotifier extends StateNotifier<HistoryState> {
  HistoryNotifier(this._repo) : super(const HistoryState()) {
    load();
  }

  final IHistoryRepository _repo;

  Future<void> load() async {
    state = state.copyWith(loading: true);
    final filterArg = state.filter == 'all' ? null : state.filter;
    final entries = await _repo.getHistory(filter: filterArg);
    final stats = await _repo.getStats();
    state = state.copyWith(entries: entries, stats: stats, loading: false);
  }

  Future<void> setFilter(String filter) async {
    if (filter == state.filter) return;
    state = state.copyWith(filter: filter);
    await load();
  }

  Future<void> clearAll() async {
    await _repo.clearHistory();
    await load();
  }

  Future<void> resetStreak() async {
    await _repo.resetStreak();
    await load();
  }

  Future<void> refresh() => load();
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final historyProvider =
    StateNotifierProvider<HistoryNotifier, HistoryState>((ref) {
  return HistoryNotifier(ref.watch(historyRepositoryProvider));
});
