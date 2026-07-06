import 'package:flutter/material.dart';
import '../constants/colors.dart';

/// Represents a German noun with its article, gender, and metadata.
class WordModel {
  final String word;
  final String article; // "der" | "die" | "das"
  final String gender; // "m" | "f" | "n"
  final String? plural;
  final String? translation;
  final String source; // "dataset" | "wiktionary"

  const WordModel({
    required this.word,
    required this.article,
    required this.gender,
    this.plural,
    this.translation,
    required this.source,
  });

  /// Full form with article, e.g. "das Buch"
  String get fullForm => '$article $word';

  /// Human-readable gender label
  String get genderLabel {
    switch (gender) {
      case 'm':
        return 'masculine';
      case 'f':
        return 'feminine';
      case 'n':
        return 'neuter';
      default:
        return gender;
    }
  }

  /// Color associated with this word's article
  Color get articleColor => AppColors.colorForArticle(article);

  /// Light background color for this word's article
  Color get articleColorLight => AppColors.colorForArticleLight(article);

  /// Source label for display
  String get sourceLabel {
    switch (source) {
      case 'dataset':
        return 'from dataset';
      case 'wiktionary':
        return 'via Wiktionary';
      default:
        return source;
    }
  }

  factory WordModel.fromJson(Map<String, dynamic> json) {
    return WordModel(
      word: json['word'] as String,
      article: json['article'] as String,
      gender: json['gender'] as String,
      plural: json['plural'] as String?,
      translation: json['translation'] as String?,
      source: json['source'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'article': article,
      'gender': gender,
      'plural': plural,
      'translation': translation,
      'source': source,
    };
  }
}
