import '../services/article_service.dart';
import '../models/word_model.dart';

/// Repository wrapping [ArticleService] — the single source of truth for word
/// data. Providers inject this so screens never touch the service directly.
class WordRepository {
  WordRepository(this._service);

  final ArticleService _service;

  Future<LookupResult> lookup(String word) => _service.lookupWord(word);

  Future<LookupResult> random() => _service.getRandomWord();

  Future<List<WordModel>> randomBatch({int count = 15}) =>
      _service.getRandomBatch(count: count);

  Future<bool> checkHealth() => _service.checkHealth();
}
