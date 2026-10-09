import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:derdiedas/features/quiz/screens/quiz_screen.dart';
import 'package:derdiedas/domain/repositories/i_article_repository.dart';
import 'package:derdiedas/domain/repositories/i_history_repository.dart';
import 'package:derdiedas/domain/repositories/i_srs_repository.dart';
import 'package:derdiedas/domain/repositories/i_favorites_repository.dart';
import 'package:derdiedas/core/di/providers.dart';
import 'package:derdiedas/domain/models/word_model.dart';
import 'package:derdiedas/domain/models/lookup_history.dart';
import 'package:derdiedas/domain/models/srs_item.dart';
import 'package:derdiedas/domain/models/srs_stats.dart';
import 'package:derdiedas/features/settings/providers/settings_provider.dart';

class MockArticleRepository extends Mock implements IArticleRepository {}
class MockHistoryRepository extends Mock implements IHistoryRepository {}
class MockSrsRepository extends Mock implements ISrsRepository {}
class MockFavoritesRepository extends Mock implements IFavoritesRepository {}

class FakeLookupHistory extends Fake implements LookupHistory {}
class FakeWordModel extends Fake implements WordModel {}

void main() {
  late MockArticleRepository mockArticleRepo;
  late MockHistoryRepository mockHistoryRepo;
  late MockSrsRepository mockSrsRepo;
  late MockFavoritesRepository mockFavRepo;

  setUpAll(() {
    registerFallbackValue(FakeLookupHistory());
    registerFallbackValue(FakeWordModel());
  });

  setUp(() {
    mockArticleRepo = MockArticleRepository();
    mockHistoryRepo = MockHistoryRepository();
    mockSrsRepo = MockSrsRepository();
    mockFavRepo = MockFavoritesRepository();

    when(() => mockHistoryRepo.getStreak()).thenReturn(5);
    when(() => mockHistoryRepo.getHistory(filter: any(named: 'filter')))
        .thenAnswer((_) async => []);
    when(() => mockHistoryRepo.getStats()).thenAnswer((_) async => {
          'streak': 5,
          'total': 20,
          'totalQuiz': 15,
          'correct': 12,
          'accuracy': 80.0,
        });
    when(() => mockHistoryRepo.addEntry(any())).thenAnswer((_) async {});
    when(() => mockHistoryRepo.updateStreak()).thenAnswer((_) async {});

    when(() => mockFavRepo.getFavorites()).thenAnswer((_) async => []);
    when(() => mockFavRepo.isFavorite(any())).thenAnswer((_) async => false);

    when(() => mockArticleRepo.randomBatch(count: any(named: 'count')))
        .thenAnswer((_) async => [
              const WordModel(word: 'Apfel', article: 'der', gender: 'm', source: 'db'),
              const WordModel(word: 'Katze', article: 'die', gender: 'f', source: 'db'),
              const WordModel(word: 'Buch', article: 'das', gender: 'n', source: 'db'),
            ]);
    when(() => mockArticleRepo.random()).thenAnswer((_) async =>
        const WordModel(word: 'Buch', article: 'das', gender: 'n', source: 'db'));

    when(() => mockSrsRepo.getDueItems(limit: any(named: 'limit')))
        .thenAnswer((_) async => [
              SrsItem(
                word: 'Apfel',
                article: 'der',
                gender: 'm',
                stage: 2,
                nextReview: DateTime.now().toUtc(),
              ),
            ]);
    when(() => mockSrsRepo.getItem(any())).thenAnswer((_) async => null);
    when(() => mockSrsRepo.getStats()).thenAnswer((_) async => const SrsStats(
          totalCount: 5,
          dueCount: 2,
          learningCount: 2,
          reviewingCount: 2,
          masteredCount: 1,
        ));
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
        stage: correct ? 3 : 1,
        consecutiveCorrect: correct ? 2 : 0,
        totalAttempts: 2,
        totalCorrect: correct ? 2 : 1,
        nextReview: DateTime.now().toUtc().add(const Duration(days: 3)),
      );
    });
  });

  Widget createWidgetUnderTest({bool showHints = true}) {
    return ProviderScope(
      overrides: [
        articleRepositoryProvider.overrideWithValue(mockArticleRepo),
        historyRepositoryProvider.overrideWithValue(mockHistoryRepo),
        srsRepositoryProvider.overrideWithValue(mockSrsRepo),
        favoritesRepositoryProvider.overrideWithValue(mockFavRepo),
        showHintsProvider.overrideWithValue(showHints),
      ],
      child: const MaterialApp(
        home: Scaffold(body: QuizScreen()),
      ),
    );
  }

  testWidgets('QuizScreen renders Due chip and shows feedback with SRS badge on answer',
      (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Check Due ActionChip is present
    expect(find.byKey(const Key('quiz_srs_due_chip')), findsOneWidget);
    expect(find.text('Due (2)'), findsOneWidget);

    // Answer the question by tapping "der"
    final derButton = find.byKey(const Key('quiz_button_der'));
    expect(derButton, findsOneWidget);
    await tester.tap(derButton);
    await tester.pumpAndSettle();

    // Feedback and Next button are shown
    expect(find.byKey(const Key('quiz_next_button')), findsOneWidget);
    expect(find.byKey(const Key('quiz_feedback_sentence')), findsOneWidget);
  });

  testWidgets('QuizScreen feedback hides extra sentence when showHints is false',
      (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(showHints: false));
    await tester.pumpAndSettle();

    final derButton = find.byKey(const Key('quiz_button_der'));
    expect(derButton, findsOneWidget);
    await tester.tap(derButton);
    await tester.pumpAndSettle();

    // Feedback and Next button are shown
    expect(find.byKey(const Key('quiz_next_button')), findsOneWidget);
    // But hints/example sentence is suppressed
    expect(find.byKey(const Key('quiz_feedback_sentence')), findsNothing);
    expect(find.byKey(const Key('quiz_feedback_grammar_hint')), findsNothing);
  });

  testWidgets('Tapping Due chip enters SRS mode and shows Spaced Repetition banner',
      (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    final dueChip = find.byKey(const Key('quiz_srs_due_chip'));
    expect(dueChip, findsOneWidget);
    await tester.tap(dueChip);
    await tester.pumpAndSettle();

    expect(find.text('Spaced Repetition Review'), findsOneWidget);
    expect(find.byKey(const Key('quiz_exit_srs')), findsOneWidget);

    // Exit SRS mode
    await tester.tap(find.byKey(const Key('quiz_exit_srs')));
    await tester.pumpAndSettle();

    expect(find.text('Spaced Repetition Review'), findsNothing);
  });
}

