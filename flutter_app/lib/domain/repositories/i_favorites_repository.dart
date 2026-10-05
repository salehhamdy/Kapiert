import '../models/word_model.dart';

/// Abstract contract for favorites storage and retrieval.
abstract interface class IFavoritesRepository {
  Future<List<WordModel>> getFavorites();
  Future<void> addFavorite(WordModel word);
  Future<void> removeFavorite(String word);
  Future<bool> isFavorite(String word);
  Future<void> clearFavorites();
}
