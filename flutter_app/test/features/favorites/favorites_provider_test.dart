import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:derdiedas/domain/models/word_model.dart';
import 'package:derdiedas/domain/repositories/i_favorites_repository.dart';
import 'package:derdiedas/core/di/providers.dart';
import 'package:derdiedas/features/favorites/providers/favorites_provider.dart';

class MockFavoritesRepository extends Mock implements IFavoritesRepository {}

void main() {
  late MockFavoritesRepository mockRepo;

  setUpAll(() {
    registerFallbackValue(
      const WordModel(word: 'Ball', article: 'der', gender: 'm', source: 'db'),
    );
  });

  setUp(() {
    mockRepo = MockFavoritesRepository();
  });

  test('FavoritesNotifier loads favorites on initialization', () async {
    final list = [
      const WordModel(word: 'Ball', article: 'der', gender: 'm', source: 'favorites'),
      const WordModel(word: 'Katze', article: 'die', gender: 'f', source: 'favorites'),
    ];

    when(() => mockRepo.getFavorites()).thenAnswer((_) async => list);

    final container = ProviderContainer(
      overrides: [
        favoritesRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );
    addTearDown(container.dispose);

    container.read(favoritesProvider.notifier);
    await Future.delayed(const Duration(milliseconds: 10));

    final state = container.read(favoritesProvider);
    expect(state.loading, false);
    expect(state.favorites.length, 2);
    expect(state.isFavorite('Ball'), true);
    expect(state.isFavorite('ball'), true); // Case-insensitive
    expect(state.isFavorite('Katze'), true);
    expect(state.isFavorite('Hund'), false);
  });

  test('FavoritesNotifier toggleFavorite adds and removes correctly', () async {
    when(() => mockRepo.getFavorites()).thenAnswer((_) async => []);
    when(() => mockRepo.addFavorite(any())).thenAnswer((_) async {});
    when(() => mockRepo.removeFavorite(any())).thenAnswer((_) async {});

    final container = ProviderContainer(
      overrides: [
        favoritesRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(favoritesProvider.notifier);
    await Future.delayed(const Duration(milliseconds: 10));

    const word = WordModel(word: 'Tisch', article: 'der', gender: 'm', source: 'test');

    // Toggle on
    final added = await notifier.toggleFavorite(word);
    expect(added, true);
    expect(container.read(favoritesProvider).isFavorite('Tisch'), true);
    verify(() => mockRepo.addFavorite(word)).called(1);

    // Toggle off
    final removed = await notifier.toggleFavorite(word);
    expect(removed, false);
    expect(container.read(favoritesProvider).isFavorite('Tisch'), false);
    verify(() => mockRepo.removeFavorite('Tisch')).called(1);
  });

  test('FavoritesNotifier clearAll resets the state and clears repo', () async {
    final list = [
      const WordModel(word: 'Buch', article: 'das', gender: 'n', source: 'favorites'),
    ];

    when(() => mockRepo.getFavorites()).thenAnswer((_) async => list);
    when(() => mockRepo.clearFavorites()).thenAnswer((_) async {});

    final container = ProviderContainer(
      overrides: [
        favoritesRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(favoritesProvider.notifier);
    await Future.delayed(const Duration(milliseconds: 10));

    expect(container.read(favoritesProvider).favorites.length, 1);

    await notifier.clearAll();
    expect(container.read(favoritesProvider).favorites, isEmpty);
    expect(container.read(favoritesProvider).favoriteWordSet, isEmpty);
    verify(() => mockRepo.clearFavorites()).called(1);
  });
}
