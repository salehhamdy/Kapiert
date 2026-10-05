import '../../core/storage/storage_service.dart';
import '../../domain/models/word_model.dart';
import '../../domain/repositories/i_favorites_repository.dart';

/// Concrete implementation of [IFavoritesRepository] backed by local SQLite storage.
class FavoritesRepositoryImpl implements IFavoritesRepository {
  @override
  Future<List<WordModel>> getFavorites() async {
    try {
      return await StorageService.getFavorites();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> addFavorite(WordModel word) async {
    try {
      await StorageService.addFavorite(word);
    } catch (_) {}
  }

  @override
  Future<void> removeFavorite(String word) async {
    try {
      await StorageService.removeFavorite(word);
    } catch (_) {}
  }

  @override
  Future<bool> isFavorite(String word) async {
    try {
      return await StorageService.isFavorite(word);
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> clearFavorites() async {
    try {
      await StorageService.clearFavorites();
    } catch (_) {}
  }
}
