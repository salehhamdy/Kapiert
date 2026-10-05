import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:derdiedas/features/quiz/providers/quiz_provider.dart';
import 'package:derdiedas/features/history/providers/history_provider.dart';
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
    when(() => mockHistoryRepo.getStats()).thenAnswer((_) async => {
          'streak': 0,
          'total': 0,
          'totalQuiz': 0,
          'correct': 0,
          'accuracy': 0.0,
        });
    when(() => mockHistoryRepo.addEntry(any())).thenAnswer((_) async {});
    when(() => mockHistoryRepo.updateStreak()).thenAnswer((_) async {});
    when(() => mockHistoryRepo.clearHistory()).thenAnswer((_) async {});

    when(() => mockArticleRepo.randomBatch(count: any(named: 'count')))
        .thenAnswer((_) async => [
              const WordModel(word: 'Haus', article: 'das', gender: 'n', source: 'db'),
              const WordModel(word: 'Hund', article: 'der', gender: 'm', source: 'db'),
              const WordModel(word: 'Katze', article: 'die', gender: 'f', source: 'db'),
            ]);
    when(() => mockArticleRepo.random()).thenAnswer((_) async =>
        const WordModel(word: 'Baum', article: 'der', gender: 'm', source: 'db'));
  });

  test('QuizNotifier answer increments score/total and reset() resets to 0', () async {
    final container = ProviderContainer(
      overrides: [
        articleRepositoryProvider.overrideWithValue(mockArticleRepo),
        historyRepositoryProvider.overrideWithValue(mockHistoryRepo),
      ],
    );
    addTearDown(container.dispose);

    final quizNotifier = container.read(quizProvider.notifier);

    // Allow initial loadNext() to complete
    await Future.delayed(const Duration(milliseconds: 10));

    expect(container.read(quizProvider).score, 0);
    expect(container.read(quizProvider).total, 0);

    // Answer correctly based on the current word
    final word = container.read(quizProvider).currentWord!;
    quizNotifier.answer(word.article);

    expect(container.read(quizProvider).score, 1);
    expect(container.read(quizProvider).total, 1);
    expect(container.read(quizProvider).accuracy, 1.0);

    // Call reset
    quizNotifier.reset();

    expect(container.read(quizProvider).score, 0);
    expect(container.read(quizProvider).total, 0);
    expect(container.read(quizProvider).accuracy, 0.0);
    expect(container.read(quizProvider).hasAnswered, false);
  });

  test('Clearing history resets the quiz session', () async {
    final container = ProviderContainer(
      overrides: [
        articleRepositoryProvider.overrideWithValue(mockArticleRepo),
        historyRepositoryProvider.overrideWithValue(mockHistoryRepo),
      ],
    );
    addTearDown(container.dispose);

    final quizNotifier = container.read(quizProvider.notifier);

    await Future.delayed(const Duration(milliseconds: 10));

    // Answer with the current word's article
    final firstWord = container.read(quizProvider).currentWord!;
    quizNotifier.answer(firstWord.article);
    expect(container.read(quizProvider).total, 1);

    // Now clear history via historyProvider
    await container.read(historyProvider.notifier).clearAll();

    // Verify clearHistory was called on repository
    verify(() => mockHistoryRepo.clearHistory()).called(1);

    // Verify quiz session has been reset
    expect(container.read(quizProvider).score, 0);
    expect(container.read(quizProvider).total, 0);
    expect(container.read(quizProvider).accuracy, 0.0);
    expect(container.read(quizProvider).hasAnswered, false);
  });
}
