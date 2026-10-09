import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../domain/models/srs_item.dart';
import '../../../domain/models/srs_stats.dart';
import '../../../domain/models/word_model.dart';
import '../../../domain/repositories/i_srs_repository.dart';

/// State of the Spaced Repetition System.
class SrsState {
  final SrsStats stats;
  final List<SrsItem> dueItems;
  final bool isLoading;

  const SrsState({
    this.stats = const SrsStats.empty(),
    this.dueItems = const [],
    this.isLoading = false,
  });

  int get dueCount => stats.dueCount;

  SrsState copyWith({
    SrsStats? stats,
    List<SrsItem>? dueItems,
    bool? isLoading,
  }) {
    return SrsState(
      stats: stats ?? this.stats,
      dueItems: dueItems ?? this.dueItems,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Manages SRS state, refresh cycles, and reviews.
class SrsNotifier extends StateNotifier<SrsState> {
  SrsNotifier(this._repo) : super(const SrsState()) {
    refresh();
  }

  final ISrsRepository _repo;

  /// Refreshes due words and retention metrics.
  Future<void> refresh() async {
    if (!mounted) return;
    state = state.copyWith(isLoading: true);
    final stats = await _repo.getStats();
    if (!mounted) return;
    final due = await _repo.getDueItems(limit: 50);
    if (!mounted) return;
    state = state.copyWith(
      stats: stats,
      dueItems: due,
      isLoading: false,
    );
  }

  /// Records a review attempt and refreshes state.
  Future<SrsItem> recordReview(WordModel word, {required bool correct}) async {
    final updated = await _repo.recordReview(word, correct: correct);
    if (mounted) await refresh();
    return updated;
  }

  /// Resets all SRS data.
  Future<void> reset() async {
    state = const SrsState();
    await _repo.resetSrs();
    await refresh();
  }
}

/// Global provider for SRS state.
final srsProvider = StateNotifierProvider<SrsNotifier, SrsState>((ref) {
  return SrsNotifier(ref.watch(srsRepositoryProvider));
});
