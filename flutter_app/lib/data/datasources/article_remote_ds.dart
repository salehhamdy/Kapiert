import '../../core/network/api_client.dart';
import '../../domain/models/word_model.dart';
import '../dto/word_dto.dart';

/// Remote data source — communicates with the FastAPI backend.
class ArticleRemoteDS {
  ArticleRemoteDS(this._client);

  final ApiClient _client;

  Future<WordModel> lookup(String word) async {
    final data = await _client.get(
      '/lookup/${Uri.encodeComponent(word.trim())}',
      timeout: const Duration(seconds: 30),
    );
    return WordDto.fromJson(data);
  }

  Future<WordModel> random() async {
    final data = await _client.get('/random');
    return WordDto.fromJson(data);
  }

  Future<List<WordModel>> randomBatch({int count = 15}) async {
    final list = await _client.getList('/random/batch/$count');
    return list
        .map((e) => WordDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<bool> checkHealth() => _client.checkHealth();
}
