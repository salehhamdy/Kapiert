import '../../domain/models/word_model.dart';
import '../../domain/repositories/i_article_repository.dart';
import '../datasources/article_local_ds.dart';
import '../datasources/article_remote_ds.dart';

/// Concrete implementation of [IArticleRepository] coordinating [ArticleRemoteDS]
/// with [ArticleLocalDS] for offline-first resilience.
class ArticleRepositoryImpl implements IArticleRepository {
  ArticleRepositoryImpl(this._remoteDS, [this._localDS]);

  final ArticleRemoteDS _remoteDS;
  final ArticleLocalDS? _localDS;

  @override
  Future<WordModel> lookup(String word) async {
    try {
      final result = await _remoteDS.lookup(word);
      // Asynchronously cache remote response for future offline use
      _localDS?.cacheWord(result).catchError((_) {});
      return result;
    } catch (e) {
      if (_localDS != null) {
        final cached = await _localDS.lookup(word);
        if (cached != null) return cached;
      }
      rethrow;
    }
  }

  @override
  Future<WordModel> random() async {
    try {
      final result = await _remoteDS.random();
      _localDS?.cacheWord(result).catchError((_) {});
      return result;
    } catch (e) {
      if (_localDS != null) {
        final cached = await _localDS.getRandomWord();
        if (cached != null) return cached;
      }
      rethrow;
    }
  }

  @override
  Future<List<WordModel>> randomBatch({int count = 15}) async {
    try {
      final results = await _remoteDS.randomBatch(count: count);
      _localDS?.cacheWords(results).catchError((_) {});
      return results;
    } catch (e) {
      if (_localDS != null) {
        final cachedBatch = await _localDS.getRandomBatch(count: count);
        if (cachedBatch.isNotEmpty) return cachedBatch;
      }
      rethrow;
    }
  }

  @override
  Future<bool> checkHealth() => _remoteDS.checkHealth();
}
