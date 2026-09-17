import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/lookup_history.dart';
import '../models/word_model.dart';
import '../repositories/history_repository.dart';
import '../repositories/word_repository.dart';
import '../services/article_service.dart';
import 'history_providers.dart';

// ---------------------------------------------------------------------------
// Infrastructure providers
// ---------------------------------------------------------------------------

final articleServiceProvider = Provider<ArticleService>(
  (_) => ArticleService.forPlatform(),
);

final wordRepositoryProvider = Provider<WordRepository>(
  (ref) => WordRepository(ref.watch(articleServiceProvider)),
);

final historyRepositoryProvider = Provider<HistoryRepository>(
  (_) => HistoryRepository(),
);

// ---------------------------------------------------------------------------
// Lookup state
// ---------------------------------------------------------------------------

class LookupState {
  const LookupState({
    this.result,
    this.query = '',
    this.loading = false,
    this.streak = 0,
  });

  final WordModel? result;
  final String query;
  final bool loading;
  final int streak;

  // null result + null query means idle (no error)
  bool get hasError => result == null && query.isNotEmpty && !loading;

  LookupState copyWith({
    WordModel? result,
    String? query,
    bool? loading,
    int? streak,
    bool clearResult = false,
  }) {
    return LookupState(
      result: clearResult ? null : result ?? this.result,
      query: query ?? this.query,
      loading: loading ?? this.loading,
      streak: streak ?? this.streak,
    );
  }
}

// ---------------------------------------------------------------------------
// Lookup notifier
// ---------------------------------------------------------------------------

class LookupNotifier extends StateNotifier<LookupState> {
  LookupNotifier(this._wordRepo, this._historyRepo, this._ref)
      : super(LookupState(streak: _historyRepo.getStreak()));

  final WordRepository _wordRepo;
  final HistoryRepository _historyRepo;
  final Ref _ref;

  // Non-null means word was not found; reuse `query` for the error text.
  String? notFoundQuery;

  Future<void> lookup(String word) async {
    final trimmed = word.trim();
    if (trimmed.isEmpty) return;

    state = state.copyWith(loading: true, clearResult: true, query: '');
    notFoundQuery = null;

    final result = await _wordRepo.lookup(trimmed);
    await _historyRepo.updateStreak();

    switch (result) {
      case LookupSuccess(:final word):
        await _historyRepo.addEntry(LookupHistory(
          timestamp: DateTime.now(),
          word: word.word,
          article: word.article,
          correct: true,
          mode: 'lookup',
        ));
        _ref.invalidate(historyProvider);
        state = state.copyWith(
          result: word,
          loading: false,
          streak: _historyRepo.getStreak(),
          clearResult: false,
        );
      case LookupNotFound(:final query):
        notFoundQuery = '"$query" was not found.';
        state = state.copyWith(loading: false, query: query, clearResult: true);
      case LookupError(:final message):
        notFoundQuery = message;
        state = state.copyWith(
            loading: false, query: trimmed, clearResult: true);
    }
  }

  void clear() {
    notFoundQuery = null;
    state = state.copyWith(clearResult: true, query: '');
  }

  void refreshStreak() {
    state = state.copyWith(streak: _historyRepo.getStreak());
  }
}

final lookupProvider =
    StateNotifierProvider<LookupNotifier, LookupState>((ref) {
  return LookupNotifier(
    ref.watch(wordRepositoryProvider),
    ref.watch(historyRepositoryProvider),
    ref,
  );
});
