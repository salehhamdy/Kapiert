import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/word_model.dart';

// ---------------------------------------------------------------------------
// Sealed result types
// ---------------------------------------------------------------------------

/// Base class for lookup results.
sealed class LookupResult {}

/// Successful lookup — contains the word data.
class LookupSuccess extends LookupResult {
  final WordModel word;
  LookupSuccess(this.word);
}

/// Word was not found in any source.
class LookupNotFound extends LookupResult {
  final String query;
  LookupNotFound(this.query);
}

/// An error occurred during the lookup.
class LookupError extends LookupResult {
  final String message;
  LookupError(this.message);
}

// ---------------------------------------------------------------------------
// Article Service
// ---------------------------------------------------------------------------

class ArticleService {
  final String baseUrl;

  ArticleService({String? baseUrl}) : baseUrl = baseUrl ?? AppConfig.apiBaseUrl;

  /// Create a service using the resolved [AppConfig.apiBaseUrl].
  factory ArticleService.forPlatform() {
    return ArticleService(baseUrl: AppConfig.apiBaseUrl);
  }

  /// Check backend connectivity (used by Settings screen).
  Future<bool> checkHealth() async {
    try {
      final uri = Uri.parse('$baseUrl/health');
      final response = await http.get(uri).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Look up the article for a German noun.
  Future<LookupResult> lookupWord(String word) async {
    if (word.trim().isEmpty) {
      return LookupError('Please enter a word');
    }

    try {
      final uri = Uri.parse(
        '$baseUrl/lookup/${Uri.encodeComponent(word.trim())}',
      );
      // 30s timeout — words not in the CSV trigger a Wiktionary fallback
      // (3 word variants × 2 Wiktionary APIs), which can take ~20s.
      final response = await http.get(uri).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return LookupSuccess(WordModel.fromJson(data));
      } else if (response.statusCode == 404) {
        return LookupNotFound(word.trim());
      } else {
        return LookupError('Server error (${response.statusCode})');
      }
    } on SocketException {
      return LookupError('Cannot reach the server. Is the backend running?');
    } on http.ClientException catch (e) {
      return LookupError('Connection failed: ${e.message}');
    } catch (e) {
      return LookupError('Unexpected error: $e');
    }
  }

  /// Fetch a random word from the dataset (for Quiz mode).
  Future<LookupResult> getRandomWord() async {
    try {
      final uri = Uri.parse('$baseUrl/random');
      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return LookupSuccess(WordModel.fromJson(data));
      } else {
        return LookupError('Could not fetch a random word');
      }
    } catch (e) {
      return LookupError(
        'Could not connect to the server. Is the backend running?',
      );
    }
  }

  /// Fetch a batch of random words (for Quiz pre-fetching).
  Future<List<WordModel>> getRandomBatch({int count = 10}) async {
    try {
      final uri = Uri.parse('$baseUrl/random/batch/$count');
      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data
            .map((e) => WordModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return [];
  }
}
