import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:derdiedas/features/quiz/providers/quiz_provider.dart';
import 'package:derdiedas/domain/repositories/i_article_repository.dart';
import 'package:derdiedas/domain/repositories/i_history_repository.dart';
import 'package:derdiedas/domain/repositories/i_srs_repository.dart';
import 'package:derdiedas/core/di/providers.dart';
import 'package:derdiedas/domain/models/word_model.dart';
import 'package:derdiedas/domain/models/lookup_history.dart';
import 'package:derdiedas/domain/models/srs_item.dart';
import 'package:derdiedas/domain/models/srs_stats.dart';

class MockArticleRepository extends Mock implements IArticleRepository {}
class MockHistoryRepository extends Mock implements IHistoryRepository {}
class MockSrsRepository extends Mock implements ISrsRepository {}

class FakeLookupHistory extends Fake implements LookupHistory {}
class FakeWordModel extends Fake implements WordModel {}

void main() {
  late MockArticleRepository mockArticleRepo;
  late MockHistoryRepository mockHistoryRepo;
  late MockSrsRepository mockSrsRepo;

  setUpAll(() {
    registerFallbackValue(FakeLookupHistory());
    registerFallbackValue(FakeWordModel());
  });

  setUp(() {
    mockArticleRepo = MockArticleRepository();
    mockHistoryRepo = MockHistoryRepository();
    mockSrsRepo = MockSrsRepository();

    when(() => mockHistoryRepo.getStreak()).thenReturn(3);
    when(() => mockHistoryRepo.getHistory(filter: any(named: 'filter')))
        .thenAnswer((_) async => []);
    when(() => mockHistoryRepo.getStats()).thenAnswer((_) async => {
          'streak': 3,
          'total': 10,
          'totalQuiz': 10,
          'correct': 8,
          'accuracy': 80.0,
        });
    when(() => mockHistoryRepo.addEntry(any())).thenAnswer((_) async {});
    when(() => mockHistoryRepo.updateStreak()).thenAnswer((_) async {});

    when(() => mockArticleRepo.randomBatch(count: any(named: 'count')))
        .thenAnswer((_) async => [
              const WordModel(word: 'Stuhl', article: 'der', gender: 'm', source: 'db'),
              const WordModel(word: 'Lampe', article: 'die', gender: 'f', source: 'db'),
              const WordModel(word: 'Bett', article: 'das', gender: 'n', source: 'db'),
            ]);
    when(() => mockArticleRepo.random()).thenAnswer((_) async =>
        const WordModel(word: 'Kopf', article: 'der', gender: 'm', source: 'db'));

    when(() => mockSrsRepo.getDueItems(limit: any(named: 'limit')))
        .thenAnswer((_) async => []);
    when(() => mockSrsRepo.getItem(any())).thenAnswer((_) async => null);
    when(() => mockSrsRepo.getStats()).thenAnswer((_) async => const SrsStats.empty());
    when(() => mockSrsRepo.recordReview(
          any(),
          correct: any(named: 'correct'),
          now: any(named: 'now'),
        )).thenAnswer((invocation) async {
      final word = invocation.positionalArguments[0] as WordModel;
      final correct = invocation.namedArguments[#correct] as bool;
      return SrsItem(
        word: word.word,
        article: word.article,
        gender: word.gender,
        stage: correct ? 2 : 1,
        consecutiveCorrect: correct ? 1 : 0,
        totalAttempts: 1,
        totalCorrect: correct ? 1 : 0,
        nextReview: DateTime.now().toUtc().add(const Duration(days: 1)),
      );
    });
  });

  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [
        articleRepositoryProvider.overrideWithValue(mockArticleRepo),
        historyRepositoryProvider.overrideWithValue(mockHistoryRepo),
        srsRepositoryProvider.overrideWithValue(mockSrsRepo),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('QuizNotifier smartly prioritizes due SRS items in initial batch', () async {
    final dueItem = SrsItem(
      word: 'Fenster',
      article: 'das',
      gender: 'n',
      stage: 2,
      consecutiveCorrect: 1,
      totalAttempts: 2,
      totalCorrect: 1,
      nextReview: DateTime.now().toUtc().subtract(const Duration(hours: 1)),
    );

    when(() => mockSrsRepo.getDueItems(limit: any(named: 'limit')))
        .thenAnswer((_) async => [dueItem]);
    when(() => mockSrsRepo.getItem('Fenster')).thenAnswer((_) async => dueItem);

    final container = createContainer();
    final notifier = container.read(quizProvider.notifier);

    await Future.delayed(const Duration(milliseconds: 20));

    final state = container.read(quizProvider);
    // Fenster should be loaded or queued
    final loadedWord = state.currentWord?.word;
    final inQueue = state.wordQueue.any((w) => w.word == 'Fenster');
    expect(loadedWord == 'Fenster' || inQueue, isTrue);

    // Answer the question
    notifier.answer(state.currentWord!.article);
    expect(container.read(quizProvider).hasAnswered, isTrue);
    verify(() => mockSrsRepo.recordReview(any(), correct: true)).called(1);
  });

  test('startSrsReview enters SRS mode and loads due cards', () async {
    final due1 = SrsItem(
      word: 'Auto',
      article: 'das',
      gender: 'n',
      stage: 1,
      nextReview: DateTime.now().toUtc(),
    );
    final due2 = SrsItem(
      word: 'Hund',
      article: 'der',
      gender: 'm',
      stage: 1,
      nextReview: DateTime.now().toUtc(),
    );

    when(() => mockSrsRepo.getDueItems(limit: any(named: 'limit')))
        .thenAnswer((_) async => [due1, due2]);

    final container = createContainer();
    final notifier = container.read(quizProvider.notifier);

    await Future.delayed(const Duration(milliseconds: 20));

    await notifier.startSrsReview([due1, due2]);
    await Future.delayed(const Duration(milliseconds: 10));

    final srsState = container.read(quizProvider);
    expect(srsState.isSrsMode, isTrue);
    expect(srsState.score, 0);
    expect(srsState.total, 0);
    expect(srsState.currentWord, isNotNull);

    // Exit SRS mode
    notifier.exitSrsReview();
    expect(container.read(quizProvider).isSrsMode, isFalse);
  });

  test('startSrsReview with empty due items marks session as complete', () async {
    when(() => mockSrsRepo.getDueItems(limit: any(named: 'limit')))
        .thenAnswer((_) async => []);

    final container = createContainer();
    final notifier = container.read(quizProvider.notifier);

    await Future.delayed(const Duration(milliseconds: 20));

    await notifier.startSrsReview([]);
    await Future.delayed(const Duration(milliseconds: 10));

    final srsState = container.read(quizProvider);
    expect(srsState.isSrsMode, isTrue);
    expect(srsState.isSessionComplete, isTrue);
  });
}
