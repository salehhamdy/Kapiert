import '../models/word_model.dart';
import '../../core/errors/failures.dart';

/// Abstract contract for word/article data operations.
/// Implemented in data/repositories/article_repository_impl.dart
abstract interface class IArticleRepository {
  /// Look up the article for a German noun.
  /// Returns [WordModel] on success, throws a [Failure] on error.
  Future<WordModel> lookup(String word);

  /// Fetch a single random word.
  Future<WordModel> random();

  /// Fetch a batch of [count] random words.
  Future<List<WordModel>> randomBatch({int count = 15});

  /// Check backend connectivity.
  Future<bool> checkHealth();
}
