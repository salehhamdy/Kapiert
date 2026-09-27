import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:derdiedas/features/lookup/screens/lookup_screen.dart';
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
    when(() => mockHistoryRepo.getHistory()).thenAnswer((_) async => []);
    when(() => mockHistoryRepo.getStats()).thenAnswer((_) async => {});
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        articleRepositoryProvider.overrideWithValue(mockArticleRepo),
        historyRepositoryProvider.overrideWithValue(mockHistoryRepo),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: LookupScreen(),
        ),
      ),
    );
  }

  group('LookupScreen Widget Tests', () {
    testWidgets('renders LookupScreen with initial state', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(Image), findsWidgets);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Check Article'), findsOneWidget);
      
      // Allow animations to finish
      await tester.pumpAndSettle();
    });

    testWidgets('shows loading indicator during lookup', (tester) async {
      // We need to return a delayed future to keep it in loading state
      // while we check the UI.
      when(() => mockArticleRepo.lookup(any())).thenAnswer(
        (_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return const WordModel(word: 'Test', article: 'der', gender: 'm', source: 'db');
        }
      );
      
      when(() => mockHistoryRepo.updateStreak()).thenAnswer((_) async {});
      when(() => mockHistoryRepo.addEntry(any())).thenAnswer((_) async {});
      when(() => mockHistoryRepo.getStreak()).thenReturn(1);

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byType(TextField), 'Test');
      await tester.tap(find.text('Check Article'));
      
      await tester.pump(); // Start the async operation
      
      // Now it should be loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Wait for it to finish
      await tester.pumpAndSettle();
      
      // Loading is gone, result is shown
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('der'), findsWidgets); // Article pill
      expect(find.text('Test'), findsWidgets);
      
      // Allow invalidated historyProvider to load before dispose
      await tester.pumpAndSettle();
    });
  });
}
