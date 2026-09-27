/// Represents a German noun with its article, gender, and metadata.
/// Pure domain model — no Flutter or SDK imports.
class WordModel {
  final String word;
  final String article; // "der" | "die" | "das"
  final String gender;  // "m" | "f" | "n"
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

  Map<String, dynamic> toJson() => {
        'word': word,
        'article': article,
        'gender': gender,
        'plural': plural,
        'translation': translation,
        'source': source,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WordModel &&
          word == other.word &&
          article == other.article;

  @override
  int get hashCode => Object.hash(word, article);
}
