import '../../domain/models/example_sentence.dart';
import '../../domain/models/word_model.dart';

/// Data Transfer Object for word data received from the API.
class WordDto {
  static WordModel fromJson(Map<String, dynamic> json) {
    ExampleSentence? sentence;
    if (json.containsKey('example_sentence') ||
        json.containsKey('example_translations')) {
      sentence = ExampleSentence.fromJson(json);
    }
    return WordModel(
      word: json['word'] as String,
      article: json['article'] as String,
      gender: json['gender'] as String,
      plural: json['plural'] as String?,
      translation: json['translation'] as String?,
      exampleSentence: sentence,
      source: json['source'] as String,
    );
  }
}

