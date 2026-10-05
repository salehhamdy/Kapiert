import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../domain/models/word_model.dart';
import '../../../domain/repositories/i_favorites_repository.dart';

// ---------------------------------------------------------------------------
// Favorites state
// ---------------------------------------------------------------------------

class FavoritesState {
  const FavoritesState({
    this.favorites = const [],
    this.favoriteWordSet = const {},
    this.loading = true,
  });

  final List<WordModel> favorites;
  final Set<String> favoriteWordSet;
  final bool loading;

  bool isFavorite(String word) => favoriteWordSet.contains(word.toLowerCase());

  FavoritesState copyWith({
    List<WordModel>? favorites,
    Set<String>? favoriteWordSet,
    bool? loading,
  }) {
    return FavoritesState(
      favorites: favorites ?? this.favorites,
      favoriteWordSet: favoriteWordSet ?? this.favoriteWordSet,
      loading: loading ?? this.loading,
    );
  }
}

// ---------------------------------------------------------------------------
// Favorites notifier
// ---------------------------------------------------------------------------

class FavoritesNotifier extends StateNotifier<FavoritesState> {
  FavoritesNotifier(this._repo) : super(const FavoritesState()) {
    load();
  }

  final IFavoritesRepository _repo;

  Future<void> load() async {
    if (!mounted) return;
    state = state.copyWith(loading: true);
    final items = await _repo.getFavorites();
    if (!mounted) return;
    final set = items.map((w) => w.word.toLowerCase()).toSet();
    state = state.copyWith(
      favorites: items,
      favoriteWordSet: set,
      loading: false,
    );
  }

  /// Toggle favorite status of [word]. Returns true if now favorited, false if removed.
  Future<bool> toggleFavorite(WordModel word) async {
    final key = word.word.toLowerCase();
    final isFav = state.isFavorite(key);

    if (isFav) {
      final newFavorites =
          state.favorites.where((w) => w.word.toLowerCase() != key).toList();
      final newSet = Set<String>.from(state.favoriteWordSet)..remove(key);
      state = state.copyWith(favorites: newFavorites, favoriteWordSet: newSet);
      await _repo.removeFavorite(word.word);
      return false;
    } else {
      final newFavorites = [word, ...state.favorites];
      final newSet = Set<String>.from(state.favoriteWordSet)..add(key);
      state = state.copyWith(favorites: newFavorites, favoriteWordSet: newSet);
      await _repo.addFavorite(word);
      return true;
    }
  }

  Future<void> removeFavorite(String word) async {
    final key = word.toLowerCase();
    final newFavorites =
        state.favorites.where((w) => w.word.toLowerCase() != key).toList();
    final newSet = Set<String>.from(state.favoriteWordSet)..remove(key);
    state = state.copyWith(favorites: newFavorites, favoriteWordSet: newSet);
    await _repo.removeFavorite(word);
  }

  Future<void> clearAll() async {
    state = state.copyWith(favorites: const [], favoriteWordSet: const {});
    await _repo.clearFavorites();
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, FavoritesState>((ref) {
  return FavoritesNotifier(ref.watch(favoritesRepositoryProvider));
});
