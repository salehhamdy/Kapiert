import 'dart:math';

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
    this.isFavoritesMode = false,
  });

  final WordModel? currentWord;
  final List<WordModel> wordQueue;
  final int score;
  final int total;
  final String? selectedArticle;
  final bool? isCorrect;
  final bool loading;
  final bool isFavoritesMode;

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
    bool? isFavoritesMode,
    bool clearAnswer = false,
    bool clearWord = false,
  }) {
    return QuizState(
      currentWord: clearWord ? null : currentWord ?? this.currentWord,
      wordQueue: wordQueue ?? this.wordQueue,
      score: score ?? this.score,
      total: total ?? this.total,
      selectedArticle:
          clearAnswer ? null : selectedArticle ?? this.selectedArticle,
      isCorrect: clearAnswer ? null : isCorrect ?? this.isCorrect,
      loading: loading ?? this.loading,
      isFavoritesMode: isFavoritesMode ?? this.isFavoritesMode,
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

  final Set<String> _seenWords = {};
  final List<String> _recentArticles = [];
  bool _isFetchingMore = false;
  final _random = Random();
  bool _isFavoritesMode = false;
  List<WordModel> _favoritesPool = [];

  /// Curated fallback pool of 60 common, balanced German nouns (20 der, 20 die, 20 das)
  /// used when offline or network requests fail.
  static const List<WordModel> _fallbackPool = [
    // Masculine (der)
    WordModel(word: 'Mann', article: 'der', gender: 'm', source: 'offline'),
    WordModel(word: 'Tisch', article: 'der', gender: 'm', source: 'offline'),
    WordModel(word: 'Stuhl', article: 'der', gender: 'm', source: 'offline'),
    WordModel(word: 'Hund', article: 'der', gender: 'm', source: 'offline'),
    WordModel(word: 'Apfel', article: 'der', gender: 'm', source: 'offline'),
    WordModel(word: 'Tag', article: 'der', gender: 'm', source: 'offline'),
    WordModel(word: 'Monat', article: 'der', gender: 'm', source: 'offline'),
    WordModel(word: 'Vater', article: 'der', gender: 'm', source: 'offline'),
    WordModel(word: 'Bruder', article: 'der', gender: 'm', source: 'offline'),
    WordModel(word: 'Kaffee', article: 'der', gender: 'm', source: 'offline'),
    WordModel(word: 'Tee', article: 'der', gender: 'm', source: 'offline'),
    WordModel(word: 'Bahnhof', article: 'der', gender: 'm', source: 'offline'),
    WordModel(word: 'Zug', article: 'der', gender: 'm', source: 'offline'),
    WordModel(word: 'Garten', article: 'der', gender: 'm', source: 'offline'),
    WordModel(word: 'Kopf', article: 'der', gender: 'm', source: 'offline'),
    WordModel(word: 'Schlüssel', article: 'der', gender: 'm', source: 'offline'),
    WordModel(word: 'Löffel', article: 'der', gender: 'm', source: 'offline'),
    WordModel(word: 'Koffer', article: 'der', gender: 'm', source: 'offline'),
    WordModel(word: 'Schrank', article: 'der', gender: 'm', source: 'offline'),
    WordModel(word: 'Wagen', article: 'der', gender: 'm', source: 'offline'),

    // Feminine (die)
    WordModel(word: 'Frau', article: 'die', gender: 'f', source: 'offline'),
    WordModel(word: 'Katze', article: 'die', gender: 'f', source: 'offline'),
    WordModel(word: 'Sonne', article: 'die', gender: 'f', source: 'offline'),
    WordModel(word: 'Stadt', article: 'die', gender: 'f', source: 'offline'),
    WordModel(word: 'Straße', article: 'die', gender: 'f', source: 'offline'),
    WordModel(word: 'Hand', article: 'die', gender: 'f', source: 'offline'),
    WordModel(word: 'Nacht', article: 'die', gender: 'f', source: 'offline'),
    WordModel(word: 'Zeit', article: 'die', gender: 'f', source: 'offline'),
    WordModel(word: 'Mutter', article: 'die', gender: 'f', source: 'offline'),
    WordModel(word: 'Schwester', article: 'die', gender: 'f', source: 'offline'),
    WordModel(word: 'Milch', article: 'die', gender: 'f', source: 'offline'),
    WordModel(word: 'Blume', article: 'die', gender: 'f', source: 'offline'),
    WordModel(word: 'Tasche', article: 'die', gender: 'f', source: 'offline'),
    WordModel(word: 'Tür', article: 'die', gender: 'f', source: 'offline'),
    WordModel(word: 'Brille', article: 'die', gender: 'f', source: 'offline'),
    WordModel(word: 'Lampe', article: 'die', gender: 'f', source: 'offline'),
    WordModel(word: 'Gabel', article: 'die', gender: 'f', source: 'offline'),
    WordModel(word: 'Reise', article: 'die', gender: 'f', source: 'offline'),
    WordModel(word: 'Frage', article: 'die', gender: 'f', source: 'offline'),
    WordModel(word: 'Musik', article: 'die', gender: 'f', source: 'offline'),

    // Neuter (das)
    WordModel(word: 'Kind', article: 'das', gender: 'n', source: 'offline'),
    WordModel(word: 'Haus', article: 'das', gender: 'n', source: 'offline'),
    WordModel(word: 'Buch', article: 'das', gender: 'n', source: 'offline'),
    WordModel(word: 'Auto', article: 'das', gender: 'n', source: 'offline'),
    WordModel(word: 'Bild', article: 'das', gender: 'n', source: 'offline'),
    WordModel(word: 'Fenster', article: 'das', gender: 'n', source: 'offline'),
    WordModel(word: 'Wasser', article: 'das', gender: 'n', source: 'offline'),
    WordModel(word: 'Brot', article: 'das', gender: 'n', source: 'offline'),
    WordModel(word: 'Jahr', article: 'das', gender: 'n', source: 'offline'),
    WordModel(word: 'Mädchen', article: 'das', gender: 'n', source: 'offline'),
    WordModel(word: 'Zimmer', article: 'das', gender: 'n', source: 'offline'),
    WordModel(word: 'Telefon', article: 'das', gender: 'n', source: 'offline'),
    WordModel(word: 'Bett', article: 'das', gender: 'n', source: 'offline'),
    WordModel(word: 'Messer', article: 'das', gender: 'n', source: 'offline'),
    WordModel(word: 'Kleid', article: 'das', gender: 'n', source: 'offline'),
    WordModel(word: 'Glas', article: 'das', gender: 'n', source: 'offline'),
    WordModel(word: 'Spiel', article: 'das', gender: 'n', source: 'offline'),
    WordModel(word: 'Tier', article: 'das', gender: 'n', source: 'offline'),
    WordModel(word: 'Hotel', article: 'das', gender: 'n', source: 'offline'),
    WordModel(word: 'Fahrrad', article: 'das', gender: 'n', source: 'offline'),
  ];

  Future<void> loadNext() async {
    if (!mounted) return;
    state = state.copyWith(loading: true, clearAnswer: true);

    var queue = List<WordModel>.from(state.wordQueue);

    // Prune any words that have already been seen in this session
    queue.removeWhere((w) => _seenWords.contains(w.word.toLowerCase()));

    if (_isFavoritesMode) {
      if (queue.isEmpty && _favoritesPool.isNotEmpty) {
        _seenWords.clear();
        queue = List<WordModel>.from(_favoritesPool)..shuffle(_random);
      }
    } else {
      if (queue.isEmpty) {
        queue = await _fetchBatch();
        if (!mounted) return;
      }
    }

    if (queue.isNotEmpty) {
      // Anti-clumping: if the previous 2 questions had the same article,
      // pick the next word with a different article to avoid 3 identical articles in a row.
      if (_recentArticles.length >= 2 &&
          _recentArticles.last == _recentArticles[_recentArticles.length - 2]) {
        final repeatedArticle = _recentArticles.last;
        final differentIndex =
            queue.indexWhere((w) => w.article != repeatedArticle);
        if (differentIndex > 0) {
          final chosen = queue.removeAt(differentIndex);
          queue.insert(0, chosen);
        }
      }

      final next = queue.removeAt(0);
      _seenWords.add(next.word.toLowerCase());
      _recentArticles.add(next.article);
      if (_recentArticles.length > 5) {
        _recentArticles.removeAt(0);
      }

      if (!mounted) return;
      state = state.copyWith(
        currentWord: next,
        wordQueue: queue,
        loading: false,
        clearAnswer: true,
      );

      // Background pre-fetch when queue runs low (only in standard mode)
      if (!_isFavoritesMode && queue.length <= 4 && !_isFetchingMore) {
        _prefetchMore();
      }
    } else if (_isFavoritesMode && _favoritesPool.isNotEmpty) {
      _seenWords.clear();
      final word = _favoritesPool[_random.nextInt(_favoritesPool.length)];
      _seenWords.add(word.word.toLowerCase());
      _recentArticles.add(word.article);
      if (!mounted) return;
      state = state.copyWith(
        currentWord: word,
        loading: false,
        clearAnswer: true,
      );
    } else {
      // Direct fallback
      try {
        final word = await _articleRepo.random();
        if (!mounted) return;
        _seenWords.add(word.word.toLowerCase());
        _recentArticles.add(word.article);
        state = state.copyWith(
          currentWord: word,
          loading: false,
          clearAnswer: true,
        );
      } catch (_) {
        if (!mounted) return;
        final fallback = _getOfflineFallbackWord();
        if (fallback != null) {
          _seenWords.add(fallback.word.toLowerCase());
          _recentArticles.add(fallback.article);
          state = state.copyWith(
            currentWord: fallback,
            loading: false,
            clearAnswer: true,
          );
        } else {
          state = state.copyWith(
            loading: false,
            clearAnswer: true,
            clearWord: true,
          );
        }
      }
    }
  }

  Future<void> _prefetchMore() async {
    if (_isFavoritesMode) return;
    _isFetchingMore = true;
    try {
      final newWords = await _fetchBatch();
      if (!mounted) return;
      if (newWords.isNotEmpty) {
        final currentQueue = List<WordModel>.from(state.wordQueue);
        final existing = <String>{
          ..._seenWords,
          ...currentQueue.map((w) => w.word.toLowerCase()),
          if (state.currentWord != null) state.currentWord!.word.toLowerCase(),
        };
        for (final w in newWords) {
          final key = w.word.toLowerCase();
          if (existing.add(key)) {
            currentQueue.add(w);
          }
        }
        state = state.copyWith(wordQueue: currentQueue);
      }
    } finally {
      _isFetchingMore = false;
    }
  }

  Future<List<WordModel>> _fetchBatch() async {
    try {
      final batch = await _articleRepo.randomBatch(count: 15);
      if (!mounted) return [];
      // Filter out words seen in this session or already queued, and deduplicate within batch
      final existing = <String>{
        ..._seenWords,
        ...state.wordQueue.map((w) => w.word.toLowerCase()),
        if (state.currentWord != null) state.currentWord!.word.toLowerCase(),
      };
      final fresh = <WordModel>[];
      for (final w in batch) {
        final key = w.word.toLowerCase();
        if (existing.add(key)) {
          fresh.add(w);
        }
      }
      fresh.shuffle(_random);
      if (fresh.isNotEmpty) return fresh;

      // If all words were already seen/queued, deduplicate raw batch
      final uniqueBatch = <WordModel>[];
      final seenInBatch = <String>{};
      for (final w in batch) {
        final key = w.word.toLowerCase();
        if (seenInBatch.add(key)) {
          uniqueBatch.add(w);
        }
      }
      return uniqueBatch..shuffle(_random);
    } catch (_) {
      if (!mounted) return [];
      return _getOfflineFallbackBatch(count: 15);
    }
  }

  List<WordModel> _getOfflineFallbackBatch({int count = 15}) {
    if (!mounted) return [];
    final existing = <String>{
      ..._seenWords,
      ...state.wordQueue.map((w) => w.word.toLowerCase()),
      if (state.currentWord != null) state.currentWord!.word.toLowerCase(),
    };
    final available = _fallbackPool
        .where((w) => !existing.contains(w.word.toLowerCase()))
        .toList();
    final sourceList = available.length >= count ? available : _fallbackPool;

    final der = sourceList.where((w) => w.article == 'der').toList()..shuffle(_random);
    final die = sourceList.where((w) => w.article == 'die').toList()..shuffle(_random);
    final das = sourceList.where((w) => w.article == 'das').toList()..shuffle(_random);

    final perArticle = count ~/ 3;
    final batch = <WordModel>[
      ...der.take(perArticle),
      ...die.take(perArticle),
      ...das.take(perArticle),
    ];
    batch.shuffle(_random);
    return batch;
  }

  WordModel? _getOfflineFallbackWord() {
    final available = _fallbackPool
        .where((w) => !_seenWords.contains(w.word.toLowerCase()))
        .toList();
    final pool = available.isNotEmpty ? available : _fallbackPool;
    return pool[_random.nextInt(pool.length)];
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

  /// Start focused review quiz on a list of favorite words.
  void startFavoritesReview(List<WordModel> favorites) {
    if (favorites.isEmpty) return;
    _isFavoritesMode = true;
    _favoritesPool = List<WordModel>.from(favorites);
    _seenWords.clear();
    _recentArticles.clear();

    final queue = List<WordModel>.from(_favoritesPool)..shuffle(_random);
    state = state.copyWith(
      score: 0,
      total: 0,
      isFavoritesMode: true,
      wordQueue: queue,
      clearAnswer: true,
      clearWord: true,
    );
    loadNext();
  }

  /// Exit focused review quiz and return to general noun practice.
  void exitFavoritesReview() {
    _isFavoritesMode = false;
    _favoritesPool.clear();
    _seenWords.clear();
    _recentArticles.clear();
    state = state.copyWith(
      score: 0,
      total: 0,
      isFavoritesMode: false,
      wordQueue: const [],
      clearAnswer: true,
      clearWord: true,
    );
    loadNext();
  }

  /// Resets the quiz score, total, and answer state, and loads a fresh question.
  void reset() {
    _seenWords.clear();
    _recentArticles.clear();
    if (_isFavoritesMode && _favoritesPool.isNotEmpty) {
      final queue = List<WordModel>.from(_favoritesPool)..shuffle(_random);
      state = state.copyWith(
        score: 0,
        total: 0,
        clearAnswer: true,
        wordQueue: queue,
      );
    } else {
      state = state.copyWith(
        score: 0,
        total: 0,
        clearAnswer: true,
        wordQueue: const [],
      );
    }
    loadNext();
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
