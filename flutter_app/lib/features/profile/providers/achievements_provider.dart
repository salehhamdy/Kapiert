import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../domain/models/achievement.dart';
import '../../../domain/repositories/i_achievements_repository.dart';
import '../../history/providers/history_provider.dart';
import '../../srs/providers/srs_provider.dart';
import '../../sync/providers/sync_provider.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class AchievementsState {
  const AchievementsState({
    this.achievements = const [],
    this.loading = true,
    this.filter = 'all',
    this.recentUnlocks = const [],
  });

  final List<Achievement> achievements;
  final bool loading;

  /// Active filter category ('all' | 'streak' | 'vocabulary' | 'mastery' | 'srs' | 'favorites').
  final String filter;

  /// Milestones that were unlocked in the latest session.
  final List<Achievement> recentUnlocks;

  int get unlockedCount =>
      achievements.where((a) => a.isUnlocked).length;

  int get totalCount => achievements.length;

  double get unlockedRate =>
      totalCount > 0 ? (unlockedCount / totalCount) : 0.0;

  List<Achievement> get filteredAchievements {
    if (filter == 'all') return achievements;
    return achievements.where((a) => a.category.name == filter).toList();
  }

  AchievementsState copyWith({
    List<Achievement>? achievements,
    bool? loading,
    String? filter,
    List<Achievement>? recentUnlocks,
  }) {
    return AchievementsState(
      achievements: achievements ?? this.achievements,
      loading: loading ?? this.loading,
      filter: filter ?? this.filter,
      recentUnlocks: recentUnlocks ?? this.recentUnlocks,
    );
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class AchievementsNotifier extends StateNotifier<AchievementsState> {
  AchievementsNotifier(this._repo) : super(const AchievementsState()) {
    load();
  }

  final IAchievementsRepository _repo;

  Future<void> load() async {
    if (!mounted) return;
    try {
      final list = await _repo.getAchievements();
      final newUnlocks = await _repo.checkNewUnlocks();
      if (!mounted) return;
      state = state.copyWith(
        achievements: list,
        recentUnlocks: newUnlocks,
        loading: false,
      );
    } catch (_) {
      if (!mounted) return;
      state = state.copyWith(loading: false);
    }
  }

  void setFilter(String filter) {
    if (state.filter == filter) return;
    state = state.copyWith(filter: filter);
  }

  void dismissRecentUnlock(String id) {
    state = state.copyWith(
      recentUnlocks:
          state.recentUnlocks.where((a) => a.id != id).toList(),
    );
  }

  Future<void> refresh() => load();
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final achievementsProvider =
    StateNotifierProvider<AchievementsNotifier, AchievementsState>((ref) {
  final notifier =
      AchievementsNotifier(ref.watch(achievementsRepositoryProvider));
  ref.listen(historyProvider, (_, _) => notifier.refresh());
  ref.listen(srsProvider, (_, _) => notifier.refresh());
  ref.listen<int>(syncRevisionProvider, (_, _) => notifier.refresh());
  return notifier;
});
