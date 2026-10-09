import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../domain/models/achievement.dart';
import '../../../domain/models/lookup_history.dart';
import '../../../domain/models/srs_item.dart';
import '../../../domain/models/word_model.dart';
import '../../../domain/repositories/i_achievements_repository.dart';
import '../../../domain/repositories/i_article_repository.dart';
import '../../../domain/repositories/i_history_repository.dart';
import '../../../domain/repositories/i_srs_repository.dart';
import '../../history/providers/history_provider.dart';
import '../../profile/providers/achievements_provider.dart';
import '../../srs/providers/srs_provider.dart';

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
    this.isSrsMode = false,
    this.isMistakesMode = false,
    this.mistakesCount = 0,
    this.currentSrsItem,
    this.isSessionComplete = false,
    this.unlockedMilestone,
  });

  final WordModel? currentWord;
  final List<WordModel> wordQueue;
  final int score;
  final int total;
  final String? selectedArticle;
  final bool? isCorrect;
  final bool loading;
  final bool isFavoritesMode;
  final bool isSrsMode;
  final bool isMistakesMode;
  final int mistakesCount;
  final SrsItem? currentSrsItem;
  final bool isSessionComplete;
  final Achievement? unlockedMilestone;

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
    bool? isSrsMode,
    bool? isMistakesMode,
    int? mistakesCount,
    SrsItem? currentSrsItem,
    bool? isSessionComplete,
    Achievement? unlockedMilestone,
    bool clearAnswer = false,
    bool clearWord = false,
    bool clearSrsItem = false,
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
      isSrsMode: isSrsMode ?? this.isSrsMode,
      isMistakesMode: isMistakesMode ?? this.isMistakesMode,
      mistakesCount: mistakesCount ?? this.mistakesCount,
      currentSrsItem:
          clearSrsItem ? null : currentSrsItem ?? this.currentSrsItem,
      isSessionComplete: isSessionComplete ?? this.isSessionComplete,
      unlockedMilestone: clearAnswer
          ? null
          : (unlockedMilestone ?? this.unlockedMilestone),
    );
  }
}

// ---------------------------------------------------------------------------
// Quiz notifier
// ---------------------------------------------------------------------------

class QuizNotifier extends StateNotifier<QuizState> {
  QuizNotifier(
    this._articleRepo,
    this._historyRepo,
    this._ref, {
    ISrsRepository? srsRepo,
    IAchievementsRepository? achievementsRepo,
  })  : _srsRepo = srsRepo ?? _ref.read(srsRepositoryProvider),
        _achievementsRepo = achievementsRepo ??
            _ref.read(achievementsRepositoryProvider),
        super(const QuizState()) {
    refreshMistakesCount();
    loadNext();
  }

  final IArticleRepository _articleRepo;
  final IHistoryRepository _historyRepo;
  final ISrsRepository _srsRepo;
  final IAchievementsRepository _achievementsRepo;
  final Ref _ref;

  final Set<String> _seenWords = {};
  final List<String> _recentArticles = [];
  bool _isFetchingMore = false;
  final _random = Random();
  bool _isFavoritesMode = false;
  bool _isSrsMode = false;
  bool _isMistakesMode = false;
  List<WordModel> _favoritesPool = [];
  List<WordModel> _srsPool = [];
  List<WordModel> _mistakesPool = [];

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

    if (_isSrsMode) {
      if (queue.isEmpty) {
        if (_srsPool.isNotEmpty) {
          final remaining = _srsPool
              .where((w) => !_seenWords.contains(w.word.toLowerCase()))
              .toList();
          if (remaining.isNotEmpty) {
            queue = remaining..shuffle(_random);
          } else {
            // User finished all due words in this session!
            if (!mounted) return;
            state = state.copyWith(
              loading: false,
              clearAnswer: true,
              clearWord: true,
              isSessionComplete: true,
            );
            return;
          }
        } else {
          final freshDue = await _srsRepo.getDueItems(limit: 30);
          final freshWords = freshDue
              .map((i) => i.toWordModel())
              .where((w) => !_seenWords.contains(w.word.toLowerCase()))
              .toList();
          if (freshWords.isNotEmpty) {
            _srsPool = freshWords;
            queue = List<WordModel>.from(_srsPool)..shuffle(_random);
          } else {
            if (!mounted) return;
            state = state.copyWith(
              loading: false,
              clearAnswer: true,
              clearWord: true,
              isSessionComplete: true,
            );
            return;
          }
        }
      }
    } else if (_isFavoritesMode) {
      if (queue.isEmpty && _favoritesPool.isNotEmpty) {
        _seenWords.clear();
        queue = List<WordModel>.from(_favoritesPool)..shuffle(_random);
      }
    } else if (_isMistakesMode) {
      if (queue.isEmpty) {
        if (!mounted) return;
        state = state.copyWith(
          loading: false,
          clearAnswer: true,
          clearWord: true,
          isSessionComplete: true,
        );
        return;
      }
    } else {
      if (queue.isEmpty) {
        queue = await _fetchSmartBatch();
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

      // Check current SRS item status for this word
      SrsItem? srsItem;
      try {
        srsItem = await _srsRepo.getItem(next.word);
      } catch (_) {}

      if (!mounted) return;
      state = state.copyWith(
        currentWord: next,
        currentSrsItem: srsItem,
        wordQueue: queue,
        loading: false,
        clearAnswer: true,
        clearSrsItem: srsItem == null,
        isSessionComplete: false,
      );

      // Background pre-fetch when queue runs low (only in standard mode)
      if (!_isFavoritesMode && !_isSrsMode && !_isMistakesMode && queue.length <= 4 && !_isFetchingMore) {
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

        SrsItem? srsItem;
        try {
          srsItem = await _srsRepo.getItem(word.word);
        } catch (_) {}

        state = state.copyWith(
          currentWord: word,
          currentSrsItem: srsItem,
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
    if (_isFavoritesMode || _isSrsMode) return;
    _isFetchingMore = true;
    try {
      final newWords = await _fetchSmartBatch();
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

  /// Smart scheduling batch: prioritizes due spaced repetition words,
  /// then supplements with fresh/balanced random words from the repository.
  Future<List<WordModel>> _fetchSmartBatch() async {
    final batch = <WordModel>[];
    final existing = <String>{
      ..._seenWords,
      ...state.wordQueue.map((w) => w.word.toLowerCase()),
      if (state.currentWord != null) state.currentWord!.word.toLowerCase(),
    };

    // 1. Spaced Repetition Due Words (highest scheduling priority)
    try {
      final dueItems = await _srsRepo.getDueItems(limit: 6);
      for (final item in dueItems) {
        final key = item.word.toLowerCase();
        if (existing.add(key)) {
          batch.add(item.toWordModel());
        }
      }
    } catch (_) {}

    // 2. Fresh random words from backend/dataset
    try {
      final freshCount = max(5, 15 - batch.length);
      final randomWords = await _articleRepo.randomBatch(count: freshCount);
      for (final w in randomWords) {
        final key = w.word.toLowerCase();
        if (existing.add(key)) {
          batch.add(w);
        }
      }
    } catch (_) {
      // Fallback pool if offline
      final offlineWords = _getOfflineFallbackBatch(count: 15);
      for (final w in offlineWords) {
        final key = w.word.toLowerCase();
        if (existing.add(key)) {
          batch.add(w);
        }
      }
    }

    batch.shuffle(_random);
    return batch;
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

    // Spaced repetition record update
    _srsRepo.recordReview(word, correct: correct).then((updatedItem) {
      if (mounted) {
        state = state.copyWith(currentSrsItem: updatedItem);
        _ref.invalidate(srsProvider);
      }
    }).catchError((_) {});

    // Milestones and achievements update
    _achievementsRepo.checkNewUnlocks().then((unlocked) {
      if (mounted && unlocked.isNotEmpty) {
        state = state.copyWith(unlockedMilestone: unlocked.first);
        _ref.invalidate(achievementsProvider);
      }
    }).catchError((_) {});

    _ref.invalidate(historyProvider);
    refreshMistakesCount();
  }

  /// Start focused review quiz on a list of favorite words.
  void startFavoritesReview(List<WordModel> favorites) {
    if (favorites.isEmpty) return;
    _isFavoritesMode = true;
    _isSrsMode = false;
    _favoritesPool = List<WordModel>.from(favorites);
    _seenWords.clear();
    _recentArticles.clear();

    final queue = List<WordModel>.from(_favoritesPool)..shuffle(_random);
    state = state.copyWith(
      score: 0,
      total: 0,
      isFavoritesMode: true,
      isSrsMode: false,
      isSessionComplete: false,
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
      isSessionComplete: false,
      wordQueue: const [],
      clearAnswer: true,
      clearWord: true,
    );
    loadNext();
  }

  /// Start a Spaced Repetition (SRS) review session on due cards.
  Future<void> startSrsReview([List<SrsItem>? dueItems]) async {
    _isSrsMode = true;
    _isFavoritesMode = false;
    _favoritesPool.clear();
    _seenWords.clear();
    _recentArticles.clear();

    List<SrsItem> items = dueItems ?? [];
    if (items.isEmpty) {
      try {
        items = await _srsRepo.getDueItems(limit: 50);
      } catch (_) {}
    }

    _srsPool = items.map((i) => i.toWordModel()).toList();

    if (_srsPool.isEmpty) {
      state = state.copyWith(
        score: 0,
        total: 0,
        isSrsMode: true,
        isFavoritesMode: false,
        isSessionComplete: true,
        loading: false,
        clearAnswer: true,
        clearWord: true,
      );
      return;
    }

    final queue = List<WordModel>.from(_srsPool)..shuffle(_random);
    state = state.copyWith(
      score: 0,
      total: 0,
      isSrsMode: true,
      isFavoritesMode: false,
      isSessionComplete: false,
      wordQueue: queue,
      clearAnswer: true,
      clearWord: true,
    );
    loadNext();
  }

  /// Exit SRS review session and return to general noun practice.
  void exitSrsReview() {
    _isSrsMode = false;
    _srsPool.clear();
    _seenWords.clear();
    _recentArticles.clear();
    state = state.copyWith(
      score: 0,
      total: 0,
      isSrsMode: false,
      isSessionComplete: false,
      wordQueue: const [],
      clearAnswer: true,
      clearWord: true,
    );
    loadNext();
  }

  /// Refresh the count of distinct incorrect words.
  Future<void> refreshMistakesCount() async {
    try {
      final count = await _historyRepo.getIncorrectWordsCount();
      if (mounted) {
        state = state.copyWith(mistakesCount: count);
      }
    } catch (_) {}
  }

  /// Start a concentrated review session focusing strictly on words answered incorrectly.
  Future<void> startMistakesReview([List<WordModel>? mistakes]) async {
    _isMistakesMode = true;
    _isFavoritesMode = false;
    _isSrsMode = false;
    _favoritesPool.clear();
    _srsPool.clear();
    _seenWords.clear();
    _recentArticles.clear();

    List<WordModel> pool = mistakes ?? [];
    if (pool.isEmpty) {
      try {
        pool = await _historyRepo.getIncorrectWords(limit: 50);
      } catch (_) {}
    }

    _mistakesPool = List<WordModel>.from(pool);
    if (_mistakesPool.isEmpty) {
      state = state.copyWith(
        score: 0,
        total: 0,
        isMistakesMode: true,
        isFavoritesMode: false,
        isSrsMode: false,
        isSessionComplete: true,
        loading: false,
        clearAnswer: true,
        clearWord: true,
      );
      return;
    }

    final queue = List<WordModel>.from(_mistakesPool)..shuffle(_random);
    state = state.copyWith(
      score: 0,
      total: 0,
      isMistakesMode: true,
      isFavoritesMode: false,
      isSrsMode: false,
      isSessionComplete: false,
      wordQueue: queue,
      clearAnswer: true,
      clearWord: true,
    );
    await loadNext();
  }

  /// Exit mistakes review session and return to general noun practice.
  Future<void> exitMistakesReview() async {
    _isMistakesMode = false;
    _mistakesPool.clear();
    _seenWords.clear();
    _recentArticles.clear();
    state = state.copyWith(
      score: 0,
      total: 0,
      isMistakesMode: false,
      isSessionComplete: false,
      wordQueue: const [],
      clearAnswer: true,
      clearWord: true,
    );
    await refreshMistakesCount();
    await loadNext();
  }

  /// Resets the quiz score, total, and answer state, and loads a fresh question.
  void reset() {
    _seenWords.clear();
    _recentArticles.clear();
    if (_isSrsMode && _srsPool.isNotEmpty) {
      final queue = List<WordModel>.from(_srsPool)..shuffle(_random);
      state = state.copyWith(
        score: 0,
        total: 0,
        clearAnswer: true,
        isSessionComplete: false,
        wordQueue: queue,
      );
    } else if (_isFavoritesMode && _favoritesPool.isNotEmpty) {
      final queue = List<WordModel>.from(_favoritesPool)..shuffle(_random);
      state = state.copyWith(
        score: 0,
        total: 0,
        clearAnswer: true,
        wordQueue: queue,
      );
    } else if (_isMistakesMode && _mistakesPool.isNotEmpty) {
      final queue = List<WordModel>.from(_mistakesPool)..shuffle(_random);
      state = state.copyWith(
        score: 0,
        total: 0,
        clearAnswer: true,
        isSessionComplete: false,
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
    refreshMistakesCount();
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
    srsRepo: ref.watch(srsRepositoryProvider),
  );
});
