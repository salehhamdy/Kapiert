import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/lookup_history.dart';
import '../models/word_model.dart';
import '../repositories/history_repository.dart';
import '../repositories/word_repository.dart';
import '../services/article_service.dart';
import 'article_providers.dart';
import 'history_providers.dart';

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
  QuizNotifier(this._wordRepo, this._historyRepo, this._ref)
      : super(const QuizState()) {
    loadNext();
  }

  final WordRepository _wordRepo;
  final HistoryRepository _historyRepo;
  final Ref _ref;

  Future<void> loadNext() async {
    state = state.copyWith(loading: true, clearAnswer: true);

    var queue = List<WordModel>.from(state.wordQueue);

    if (queue.isEmpty) {
      final batch = await _wordRepo.randomBatch(count: 15);
      queue = batch;
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
      // Fallback to single fetch
      final result = await _wordRepo.random();
      final word = result is LookupSuccess ? result.word : null;
      state = state.copyWith(
        currentWord: word,
        loading: false,
        clearAnswer: true,
        clearWord: word == null,
      );
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

final quizProvider = StateNotifierProvider<QuizNotifier, QuizState>((ref) {
  return QuizNotifier(
    ref.watch(wordRepositoryProvider),
    ref.watch(historyRepositoryProvider),
    ref,
  );
});
