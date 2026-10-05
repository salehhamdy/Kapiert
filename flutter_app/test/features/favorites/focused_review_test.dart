import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:derdiedas/features/quiz/providers/quiz_provider.dart';
import 'package:derdiedas/domain/repositories/i_article_repository.dart';
import 'package:derdiedas/domain/repositories/i_history_repository.dart';
import 'package:derdiedas/core/di/providers.dart';
import 'package:derdiedas/domain/models/word_model.dart';
import 'package:derdiedas/domain/models/lookup_history.dart';

class MockArticleRepository extends Mock implements IArticleRepository {}
class MockHistoryRepository extends Mock implements IHistoryRepository {}

class FakeLookupHistory extends Fake implements LookupHistory {}

void main() {
  late MockArticleRepository mockArticleRepo;
  late MockHistoryRepository mockHistoryRepo;

  setUpAll(() {
    registerFallbackValue(FakeLookupHistory());
  });

  setUp(() {
    mockArticleRepo = MockArticleRepository();
    mockHistoryRepo = MockHistoryRepository();

    when(() => mockHistoryRepo.getStreak()).thenReturn(0);
    when(() => mockHistoryRepo.getHistory(filter: any(named: 'filter')))
        .thenAnswer((_) async => []);
    when(() => mockHistoryRepo.getStats()).thenAnswer((_) async => {});
    when(() => mockHistoryRepo.addEntry(any())).thenAnswer((_) async {});
    when(() => mockHistoryRepo.updateStreak()).thenAnswer((_) async {});

    when(() => mockArticleRepo.randomBatch(count: any(named: 'count')))
        .thenAnswer((_) async => [
              const WordModel(word: 'Stuhl', article: 'der', gender: 'm', source: 'db'),
              const WordModel(word: 'Katze', article: 'die', gender: 'f', source: 'db'),
            ]);
    when(() => mockArticleRepo.random()).thenAnswer((_) async =>
        const WordModel(word: 'Haus', article: 'das', gender: 'n', source: 'db'));
  });

  test('QuizNotifier startFavoritesReview enters favorites mode and reviews saved words', () async {
    final favorites = [
      const WordModel(word: 'Ball', article: 'der', gender: 'm', source: 'fav'),
      const WordModel(word: 'Sonne', article: 'die', gender: 'f', source: 'fav'),
    ];

    final container = ProviderContainer(
      overrides: [
        articleRepositoryProvider.overrideWithValue(mockArticleRepo),
        historyRepositoryProvider.overrideWithValue(mockHistoryRepo),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(quizProvider.notifier);
    await Future.delayed(const Duration(milliseconds: 10));

    expect(container.read(quizProvider).isFavoritesMode, false);

    // Start favorites review
    notifier.startFavoritesReview(favorites);
    await Future.delayed(const Duration(milliseconds: 10));

    final state = container.read(quizProvider);
    expect(state.isFavoritesMode, true);
    expect(state.currentWord, isNotNull);
    expect(['Ball', 'Sonne'], contains(state.currentWord!.word));

    // Exit review mode
    notifier.exitFavoritesReview();
    await Future.delayed(const Duration(milliseconds: 10));

    expect(container.read(quizProvider).isFavoritesMode, false);
  });
}
