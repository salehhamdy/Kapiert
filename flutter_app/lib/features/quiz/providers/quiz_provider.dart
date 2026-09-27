import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../domain/models/lookup_history.dart';
import '../../../domain/models/word_model.dart';
import '../../../domain/repositories/i_article_repository.dart';
import '../../../domain/repositories/i_history_repository.dart';
import '../../history/providers/history_provider.dart';

// ---------------------------------------------------------------------------
// Quiz state
// ---------------------------------------------------------------------------

class QuizState {
  const QuizState({
    this.currentWord,
    this.wordQueue = const [],
    this.score = 0,
    this.total = 0,
    this.selectedArticle,
    this.isCorrect,
    this.loading = true,
  });

  final WordModel? currentWord;
  final List<WordModel> wordQueue;
  final int score;
  final int total;
  final String? selectedArticle;
  final bool? isCorrect;
  final bool loading;

  bool get hasAnswered => selectedArticle != null;
  double get accuracy => total > 0 ? score / total : 0;

  QuizState copyWith({
    WordModel? currentWord,
    List<WordModel>? wordQueue,
    int? score,
    int? total,
    String? selectedArticle,
    bool? isCorrect,
    bool? loading,
    bool clearAnswer = false,
    bool clearWord = false,
  }) {
    return QuizState(
      currentWord: clearWord ? null : currentWord ?? this.currentWord,
      wordQueue: wordQueue ?? this.wordQueue,
      score: score ?? this.score,
      total: total ?? this.total,
      selectedArticle: clearAnswer ? null : selectedArticle ?? this.selectedArticle,
      isCorrect: clearAnswer ? null : isCorrect ?? this.isCorrect,
      loading: loading ?? this.loading,
    );
  }
}

// ---------------------------------------------------------------------------
// Quiz notifier
// ---------------------------------------------------------------------------

class QuizNotifier extends StateNotifier<QuizState> {
  QuizNotifier(this._articleRepo, this._historyRepo, this._ref)
      : super(const QuizState()) {
    loadNext();
  }

  final IArticleRepository _articleRepo;
  final IHistoryRepository _historyRepo;
  final Ref _ref;

  Future<void> loadNext() async {
    state = state.copyWith(loading: true, clearAnswer: true);

    var queue = List<WordModel>.from(state.wordQueue);

    if (queue.isEmpty) {
      try {
        queue = await _articleRepo.randomBatch(count: 15);
      } catch (_) {
        queue = [];
      }
    }

    if (queue.isNotEmpty) {
      final next = queue.removeAt(0);
      state = state.copyWith(
        currentWord: next,
        wordQueue: queue,
        loading: false,
        clearAnswer: true,
      );
    } else {
      try {
        final word = await _articleRepo.random();
        state = state.copyWith(
            currentWord: word, loading: false, clearAnswer: true);
      } catch (_) {
        state = state.copyWith(loading: false, clearAnswer: true, clearWord: true);
      }
    }
  }

  void answer(String article) {
    final word = state.currentWord;
    if (word == null || state.hasAnswered) return;

    final correct = article == word.article;
    state = state.copyWith(
      selectedArticle: article,
      isCorrect: correct,
      score: correct ? state.score + 1 : state.score,
      total: state.total + 1,
    );

    _historyRepo.addEntry(LookupHistory(
      timestamp: DateTime.now(),
      word: word.word,
      article: word.article,
      correct: correct,
      mode: 'quiz',
    ));
    _historyRepo.updateStreak();
    _ref.invalidate(historyProvider);
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final quizProvider =
    StateNotifierProvider<QuizNotifier, QuizState>((ref) {
  return QuizNotifier(
    ref.watch(articleRepositoryProvider),
    ref.watch(historyRepositoryProvider),
    ref,
  );
});

