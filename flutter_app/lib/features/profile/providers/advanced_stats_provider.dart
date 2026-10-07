import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../domain/models/advanced_stats.dart';
import '../../../domain/models/daily_activity.dart';
import '../../../domain/repositories/i_history_repository.dart';
import '../../history/providers/history_provider.dart';
import '../../sync/providers/sync_provider.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class AdvancedStatsState {
  const AdvancedStatsState({
    required this.stats,
    this.loading = true,
    this.selectedDayIndex,
  });

  final AdvancedStats stats;
  final bool loading;

  /// Index into [stats.last7Days] currently inspected by the user.
  final int? selectedDayIndex;

  DailyActivity? get selectedDay {
    if (selectedDayIndex == null) return null;
    final list = stats.last7Days;
    if (selectedDayIndex! >= 0 && selectedDayIndex! < list.length) {
      return list[selectedDayIndex!];
    }
    return null;
  }

  AdvancedStatsState copyWith({
    AdvancedStats? stats,
    bool? loading,
    int? selectedDayIndex,
    bool clearSelectedDay = false,
  }) {
    return AdvancedStatsState(
      stats: stats ?? this.stats,
      loading: loading ?? this.loading,
      selectedDayIndex: clearSelectedDay
          ? null
          : (selectedDayIndex ?? this.selectedDayIndex),
    );
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class AdvancedStatsNotifier extends StateNotifier<AdvancedStatsState> {
  AdvancedStatsNotifier(this._historyRepo)
      : super(AdvancedStatsState(stats: AdvancedStats.empty())) {
    load();
  }

  final IHistoryRepository _historyRepo;

  Future<void> load() async {
    if (!mounted) return;
    try {
      final stats = await _historyRepo.getAdvancedStats(days: 14);
      if (!mounted) return;
      state = state.copyWith(stats: stats, loading: false);
    } catch (_) {
      if (!mounted) return;
      state = state.copyWith(loading: false);
    }
  }

  void selectDay(int index) {
    if (state.selectedDayIndex == index) {
      state = state.copyWith(clearSelectedDay: true);
    } else {
      state = state.copyWith(selectedDayIndex: index);
    }
  }

  Future<void> refresh() => load();
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final advancedStatsProvider =
    StateNotifierProvider<AdvancedStatsNotifier, AdvancedStatsState>((ref) {
  final notifier =
      AdvancedStatsNotifier(ref.watch(historyRepositoryProvider));
  // Refresh when history changes or sync revision bumps.
  ref.listen(historyProvider, (_, _) => notifier.refresh());
  ref.listen<int>(syncRevisionProvider, (_, _) => notifier.refresh());
  return notifier;
});
