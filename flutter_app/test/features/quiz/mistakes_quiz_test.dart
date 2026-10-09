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
    when(() => mockHistoryRepo.getIncorrectWords(limit: any(named: 'limit')))
        .thenAnswer((_) async => []);
    when(() => mockHistoryRepo.getIncorrectWordsCount())
        .thenAnswer((_) async => 0);

    when(() => mockArticleRepo.randomBatch(count: any(named: 'count')))
        .thenAnswer((_) async => [
              const WordModel(word: 'Tisch', article: 'der', gender: 'm', source: 'db'),
              const WordModel(word: 'Lampe', article: 'die', gender: 'f', source: 'db'),
            ]);
    when(() => mockArticleRepo.random()).thenAnswer((_) async =>
        const WordModel(word: 'Sonne', article: 'die', gender: 'f', source: 'db'));
  });

  test('QuizNotifier initial state has isMistakesMode false and checks count', () async {
    when(() => mockHistoryRepo.getIncorrectWordsCount()).thenAnswer((_) async => 7);

    final container = ProviderContainer(
      overrides: [
        articleRepositoryProvider.overrideWithValue(mockArticleRepo),
        historyRepositoryProvider.overrideWithValue(mockHistoryRepo),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(quizProvider.notifier);
    await Future.delayed(const Duration(milliseconds: 20));

    expect(container.read(quizProvider).isMistakesMode, isFalse);
    await notifier.refreshMistakesCount();
    expect(container.read(quizProvider).mistakesCount, equals(7));
  });

  test('startMistakesReview loads incorrect words and sets isMistakesMode true', () async {
    final incorrectList = [
      const WordModel(word: 'Hund', article: 'der', gender: 'm', source: 'db'),
      const WordModel(word: 'Katze', article: 'die', gender: 'f', source: 'db'),
    ];

    when(() => mockHistoryRepo.getIncorrectWords(limit: any(named: 'limit')))
        .thenAnswer((_) async => List<WordModel>.from(incorrectList));

    final container = ProviderContainer(
      overrides: [
        articleRepositoryProvider.overrideWithValue(mockArticleRepo),
        historyRepositoryProvider.overrideWithValue(mockHistoryRepo),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(quizProvider.notifier);
    await Future.delayed(const Duration(milliseconds: 20));

    await notifier.startMistakesReview();
    final state = container.read(quizProvider);

    expect(state.isMistakesMode, isTrue);
    expect(state.currentWord, isNotNull);
    expect(state.wordQueue.length + (state.currentWord != null ? 1 : 0), equals(2));
    expect(state.currentWord?.word, anyOf('Hund', 'Katze'));
  });

  test('exitMistakesReview restores standard quiz mode', () async {
    final incorrectList = [
      const WordModel(word: 'Hund', article: 'der', gender: 'm', source: 'db'),
    ];

    when(() => mockHistoryRepo.getIncorrectWords(limit: any(named: 'limit')))
        .thenAnswer((_) async => List<WordModel>.from(incorrectList));

    final container = ProviderContainer(
      overrides: [
        articleRepositoryProvider.overrideWithValue(mockArticleRepo),
        historyRepositoryProvider.overrideWithValue(mockHistoryRepo),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(quizProvider.notifier);
    await Future.delayed(const Duration(milliseconds: 20));

    await notifier.startMistakesReview();
    expect(container.read(quizProvider).isMistakesMode, isTrue);

    await notifier.exitMistakesReview();
    expect(container.read(quizProvider).isMistakesMode, isFalse);
  });
}
