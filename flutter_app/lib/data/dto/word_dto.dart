import '../../domain/models/word_model.dart';

/// Data Transfer Object for word data received from the API.
class WordDto {
  static WordModel fromJson(Map<String, dynamic> json) {
    return WordModel(
      word: json['word'] as String,
      article: json['article'] as String,
      gender: json['gender'] as String,
      plural: json['plural'] as String?,
      translation: json['translation'] as String?,
      source: json['source'] as String,
    );
  }
}
