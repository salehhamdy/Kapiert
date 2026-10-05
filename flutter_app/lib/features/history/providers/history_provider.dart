import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../domain/models/lookup_history.dart';
import '../../../domain/repositories/i_history_repository.dart';
import '../../quiz/providers/quiz_provider.dart';
import '../../sync/providers/sync_provider.dart';

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
  HistoryNotifier(this._repo, [this._ref]) : super(const HistoryState()) {
    load();
  }

  final IHistoryRepository _repo;
  final Ref? _ref;

  Future<void> load() async {
    if (!mounted) return;
    state = state.copyWith(loading: true);
    final filterArg = state.filter == 'all' ? null : state.filter;
    final entries = await _repo.getHistory(filter: filterArg);
    final stats = await _repo.getStats();
    if (!mounted) return;
    state = state.copyWith(entries: entries, stats: stats, loading: false);
  }

  Future<void> setFilter(String filter) async {
    if (!mounted || filter == state.filter) return;
    state = state.copyWith(filter: filter);
    await load();
  }

  Future<void> clearAll() async {
    await _repo.clearHistory();
    _ref?.read(quizProvider.notifier).reset();
    if (!mounted) return;
    await load();
  }

  Future<void> resetStreak() async {
    await _repo.resetStreak();
    if (!mounted) return;
    await load();
  }

  Future<void> refresh() => load();
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final historyProvider =
    StateNotifierProvider<HistoryNotifier, HistoryState>((ref) {
  final notifier = HistoryNotifier(ref.watch(historyRepositoryProvider), ref);
  // Reload when cloud sync pulls new entries or clears account data.
  ref.listen<int>(syncRevisionProvider, (_, _) => notifier.refresh());
  return notifier;
});

