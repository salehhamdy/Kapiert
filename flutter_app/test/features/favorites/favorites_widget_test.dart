import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:derdiedas/domain/models/word_model.dart';
import 'package:derdiedas/domain/repositories/i_favorites_repository.dart';
import 'package:derdiedas/domain/repositories/i_history_repository.dart';
import 'package:derdiedas/domain/repositories/i_article_repository.dart';
import 'package:derdiedas/core/di/providers.dart';
import 'package:derdiedas/features/lookup/screens/result_card.dart';
import 'package:derdiedas/features/history/screens/history_screen.dart';

class MockFavoritesRepository extends Mock implements IFavoritesRepository {}
class MockHistoryRepository extends Mock implements IHistoryRepository {}
class MockArticleRepository extends Mock implements IArticleRepository {}

void main() {
  late MockFavoritesRepository mockFavRepo;
  late MockHistoryRepository mockHistoryRepo;
  late MockArticleRepository mockArticleRepo;

  setUpAll(() {
    registerFallbackValue(
      const WordModel(word: 'dummy', article: 'der', gender: 'm', source: 'db'),
    );
  });

  setUp(() {
    mockFavRepo = MockFavoritesRepository();
    mockHistoryRepo = MockHistoryRepository();
    mockArticleRepo = MockArticleRepository();

    when(() => mockFavRepo.getFavorites()).thenAnswer((_) async => []);
    when(() => mockFavRepo.addFavorite(any())).thenAnswer((_) async {});
    when(() => mockFavRepo.removeFavorite(any())).thenAnswer((_) async {});

    when(() => mockHistoryRepo.getStreak()).thenReturn(0);
    when(() => mockHistoryRepo.getHistory(filter: any(named: 'filter')))
        .thenAnswer((_) async => []);
    when(() => mockHistoryRepo.getStats()).thenAnswer((_) async => {
          'total': 0,
          'totalQuiz': 0,
          'accuracy': 0.0,
        });

    when(() => mockArticleRepo.randomBatch(count: any(named: 'count')))
        .thenAnswer((_) async => []);
    when(() => mockArticleRepo.random()).thenAnswer((_) async =>
        const WordModel(word: 'Haus', article: 'das', gender: 'n', source: 'db'));
  });

  testWidgets('ResultCard displays star button in upper right corner and toggles favorite',
      (tester) async {
    const word = WordModel(
      word: 'Ball',
      article: 'der',
      gender: 'm',
      plural: 'Bälle',
      source: 'dataset',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          favoritesRepositoryProvider.overrideWithValue(mockFavRepo),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: Center(
              child: ResultCard(word: word),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify word and article are rendered
    expect(find.text('Ball'), findsOneWidget);
    expect(find.text('der'), findsOneWidget);

    // Verify star button exists
    final starButtonFinder = find.byKey(const Key('favorite_star_button'));
    expect(starButtonFinder, findsOneWidget);

    // Initial state: star outline icon
    expect(find.byIcon(Icons.star_outline_rounded), findsOneWidget);

    // Tap star button to favorite
    await tester.tap(starButtonFinder);
    await tester.pumpAndSettle();

    // Now it should show filled star
    expect(find.byIcon(Icons.star_rounded), findsWidgets);
    verify(() => mockFavRepo.addFavorite(word)).called(1);
  });

  testWidgets('HistoryScreen displays Favorites tab and renders empty/populated states',
      (tester) async {
    final favorites = [
      const WordModel(
        word: 'Kaffee',
        article: 'der',
        gender: 'm',
        source: 'favorites',
      ),
    ];

    when(() => mockFavRepo.getFavorites()).thenAnswer((_) async => favorites);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          favoritesRepositoryProvider.overrideWithValue(mockFavRepo),
          historyRepositoryProvider.overrideWithValue(mockHistoryRepo),
          articleRepositoryProvider.overrideWithValue(mockArticleRepo),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: HistoryScreen(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Favorites filter chip is displayed
    final favChipFinder = find.text('⭐ Favorites');
    expect(favChipFinder, findsOneWidget);

    // Tap ⭐ Favorites tab
    await tester.tap(favChipFinder);
    await tester.pumpAndSettle();

    // Verify Focused Review card is shown
    expect(find.text('Focused Review'), findsOneWidget);
    expect(find.text('Kaffee'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Quiz'), findsOneWidget);
  });
}
