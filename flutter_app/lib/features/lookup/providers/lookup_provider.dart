import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/models/lookup_history.dart';
import '../../../domain/models/word_model.dart';
import '../../../domain/repositories/i_article_repository.dart';
import '../../../domain/repositories/i_history_repository.dart';
import '../../history/providers/history_provider.dart';

// ---------------------------------------------------------------------------
// Lookup state
// ---------------------------------------------------------------------------

class LookupState {
  const LookupState({
    this.result,
    this.query = '',
    this.loading = false,
    this.streak = 0,
    this.errorMessage,
  });

  final WordModel? result;
  final String query;
  final bool loading;
  final int streak;
  final String? errorMessage;

  bool get hasError => errorMessage != null && !loading;

  LookupState copyWith({
    WordModel? result,
    String? query,
    bool? loading,
    int? streak,
    String? errorMessage,
    bool clearResult = false,
    bool clearError = false,
  }) {
    return LookupState(
      result: clearResult ? null : result ?? this.result,
      query: query ?? this.query,
      loading: loading ?? this.loading,
      streak: streak ?? this.streak,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

// ---------------------------------------------------------------------------
// Lookup notifier
// ---------------------------------------------------------------------------

class LookupNotifier extends StateNotifier<LookupState> {
  LookupNotifier(this._articleRepo, this._historyRepo, this._ref)
      : super(LookupState(streak: _historyRepo.getStreak()));

  final IArticleRepository _articleRepo;
  final IHistoryRepository _historyRepo;
  final Ref _ref;

  Future<void> lookup(String word) async {
    final trimmed = word.trim();
    if (trimmed.isEmpty) return;

    state = state.copyWith(
        loading: true, clearResult: true, clearError: true, query: trimmed);

    try {
      final result = await _articleRepo.lookup(trimmed);
      await _historyRepo.updateStreak();
      await _historyRepo.addEntry(LookupHistory(
        timestamp: DateTime.now(),
        word: result.word,
        article: result.article,
        correct: true,
        mode: 'lookup',
      ));
      _ref.invalidate(historyProvider);
      state = state.copyWith(
        result: result,
        loading: false,
        streak: _historyRepo.getStreak(),
        clearError: true,
      );
    } on NotFoundFailure catch (f) {
      state = state.copyWith(
          loading: false, clearResult: true, errorMessage: f.message);
    } catch (e) {
      state = state.copyWith(
          loading: false,
          clearResult: true,
          errorMessage: e.toString());
    }
  }

  void clear() {
    state = state.copyWith(clearResult: true, clearError: true, query: '');
  }

  void refreshStreak() {
    state = state.copyWith(streak: _historyRepo.getStreak());
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final lookupProvider =
    StateNotifierProvider<LookupNotifier, LookupState>((ref) {
  return LookupNotifier(
    ref.watch(articleRepositoryProvider),
    ref.watch(historyRepositoryProvider),
    ref,
  );
});
