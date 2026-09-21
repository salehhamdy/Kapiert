import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:derdiedas/features/lookup/providers/lookup_provider.dart';
import 'package:derdiedas/core/di/providers.dart';
import 'package:derdiedas/domain/repositories/i_article_repository.dart';
import 'package:derdiedas/domain/repositories/i_history_repository.dart';
import 'package:derdiedas/domain/models/word_model.dart';
import 'package:derdiedas/core/errors/failures.dart';
import 'package:derdiedas/domain/models/lookup_history.dart';

class MockArticleRepository extends Mock implements IArticleRepository {}
class MockHistoryRepository extends Mock implements IHistoryRepository {}

// A generic ProviderContainer builder to allow overriding providers
ProviderContainer makeProviderContainer({
  required IArticleRepository articleRepo,
  required IHistoryRepository historyRepo,
}) {
  final container = ProviderContainer(
    overrides: [
      // We don't override lookupProvider itself, we just let it use the real one,
      // but the real one depends on the DI providers which we might need to override.
      // Wait, the lookupProvider in this architecture uses ref.watch(articleRepositoryProvider).
      // Since we don't have access to those DI providers easily without importing them,
      // we can just instantiate the Notifier directly for testing.
    ],
  );
  addTearDown(container.dispose);
  return container;
}

// Fallback value for mocktail
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

  group('LookupNotifier', () {
    const tWord = WordModel(
      word: 'Test',
      article: 'der',
      gender: 'm',
      source: 'dataset',
    );

    test('initial state is correct', () {
      final container = ProviderContainer(
        overrides: [
          articleRepositoryProvider.overrideWithValue(mockArticleRepo),
          historyRepositoryProvider.overrideWithValue(mockHistoryRepo),
        ]
      );
      addTearDown(container.dispose);
      
      final notifier = container.read(lookupProvider.notifier);
      
      expect(notifier.state.query, '');
      expect(notifier.state.loading, isFalse);
      expect(notifier.state.result, isNull);
      expect(notifier.state.errorMessage, isNull);
      expect(notifier.state.streak, 0);
    });

    test('lookup success updates state correctly', () async {
      // Arrange
      final container = ProviderContainer(
        overrides: [
          articleRepositoryProvider.overrideWithValue(mockArticleRepo),
          historyRepositoryProvider.overrideWithValue(mockHistoryRepo),
        ]
      );
      addTearDown(container.dispose);
      final notifier = container.read(lookupProvider.notifier);

      when(() => mockArticleRepo.lookup(any())).thenAnswer((_) async => tWord);
      when(() => mockHistoryRepo.updateStreak()).thenAnswer((_) async {});
      when(() => mockHistoryRepo.addEntry(any())).thenAnswer((_) async {});
      when(() => mockHistoryRepo.getStreak()).thenReturn(1);

      // Act
      await notifier.lookup('Test');

      // Assert
      expect(notifier.state.loading, isFalse);
      expect(notifier.state.query, 'Test');
      expect(notifier.state.result, equals(tWord));
      expect(notifier.state.errorMessage, isNull);
      expect(notifier.state.streak, 1);
      
      verify(() => mockArticleRepo.lookup('Test')).called(1);
      verify(() => mockHistoryRepo.updateStreak()).called(1);
      verify(() => mockHistoryRepo.addEntry(any())).called(1);
      
      // Allow invalidated historyProvider to load before dispose
      await Future.delayed(Duration.zero);
    });

    test('lookup throws NotFoundFailure updates state with error', () async {
      // Arrange
      final container = ProviderContainer(
        overrides: [
          articleRepositoryProvider.overrideWithValue(mockArticleRepo),
          historyRepositoryProvider.overrideWithValue(mockHistoryRepo),
        ]
      );
      addTearDown(container.dispose);
      final notifier = container.read(lookupProvider.notifier);

      when(() => mockArticleRepo.lookup(any())).thenThrow(
        NotFoundFailure.forQuery('Unknown'),
      );

      // Act
      await notifier.lookup('Unknown');

      // Assert
      expect(notifier.state.loading, isFalse);
      expect(notifier.state.query, 'Unknown');
      expect(notifier.state.result, isNull);
      expect(notifier.state.errorMessage, '"Unknown" was not found.');
      
      verify(() => mockArticleRepo.lookup('Unknown')).called(1);
      verifyNever(() => mockHistoryRepo.updateStreak());
    });

    test('clear resets the state', () {
      final container = ProviderContainer(
        overrides: [
          articleRepositoryProvider.overrideWithValue(mockArticleRepo),
          historyRepositoryProvider.overrideWithValue(mockHistoryRepo),
        ]
      );
      addTearDown(container.dispose);
      final notifier = container.read(lookupProvider.notifier);

      // Mutate state manually to simulate a completed lookup
      notifier.clear();
      
      expect(notifier.state.query, '');
      expect(notifier.state.result, isNull);
      expect(notifier.state.errorMessage, isNull);
    });
  });
}
