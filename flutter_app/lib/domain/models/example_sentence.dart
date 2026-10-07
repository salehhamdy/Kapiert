/// Represents a contextual example sentence for a German noun with multilingual translations.
class ExampleSentence {
  final String german;
  final String? english;
  final String? arabic;
  final String? turkish;

  const ExampleSentence({
    required this.german,
    this.english,
    this.arabic,
    this.turkish,
  });

  /// Convenience getter for German sentence text.
  String get sentence => german;

  /// Convenience getter for English translation text.
  String get translation => english ?? '';

  /// Returns the translation matching the active language code, falling back to English.
  String translationFor(String languageCode) {
    switch (languageCode) {
      case 'ar':
        return (arabic != null && arabic!.isNotEmpty)
            ? arabic!
            : (english ?? german);
      case 'tr':
        return (turkish != null && turkish!.isNotEmpty)
            ? turkish!
            : (english ?? german);
      case 'de':
        return german;
      case 'en':
      default:
        return english ?? '';
    }
  }

  factory ExampleSentence.fromJson(Map<String, dynamic> json) {
    final translations = json['example_translations'] as Map<String, dynamic>?;

    final german = json['example_sentence'] as String? ??
        translations?['de'] as String? ??
        json['german'] as String? ??
        '';

    final english = json['example_translation'] as String? ??
        translations?['en'] as String? ??
        json['english'] as String?;

    final arabic = translations?['ar'] as String? ?? json['arabic'] as String?;
    final turkish = translations?['tr'] as String? ?? json['turkish'] as String?;

    return ExampleSentence(
      german: german,
      english: english,
      arabic: arabic,
      turkish: turkish,
    );
  }

  Map<String, dynamic> toJson() => {
        'german': german,
        'english': english,
        'arabic': arabic,
        'turkish': turkish,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExampleSentence &&
          german == other.german &&
          english == other.english &&
          arabic == other.arabic &&
          turkish == other.turkish;

  @override
  int get hashCode => Object.hash(german, english, arabic, turkish);
}
