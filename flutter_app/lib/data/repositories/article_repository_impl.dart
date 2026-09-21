import '../../domain/models/word_model.dart';
import '../../domain/repositories/i_article_repository.dart';
import '../datasources/article_remote_ds.dart';

/// Concrete implementation of [IArticleRepository] using [ArticleRemoteDS].
class ArticleRepositoryImpl implements IArticleRepository {
  ArticleRepositoryImpl(this._remoteDS);

  final ArticleRemoteDS _remoteDS;

  @override
  Future<WordModel> lookup(String word) => _remoteDS.lookup(word);

  @override
  Future<WordModel> random() => _remoteDS.random();

  @override
  Future<List<WordModel>> randomBatch({int count = 15}) =>
      _remoteDS.randomBatch(count: count);

  @override
  Future<bool> checkHealth() => _remoteDS.checkHealth();
}

