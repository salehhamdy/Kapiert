import 'word_model.dart';

/// Represents a noun's Spaced Repetition System (SRS) status.
///
/// Tracks learning stages (1 to 5), consecutive correct answers,
/// and review scheduling timestamps based on the Leitner / SM-2 spaced interval principles.
class SrsItem {
  final int? id;
  final String word;
  final String article;
  final String gender;
  final String? plural;
  final String? translation;
  final int stage; // 1: Learning, 2: Review, 3: Familiar, 4: Solid, 5: Mastered
  final int consecutiveCorrect;
  final int totalAttempts;
  final int totalCorrect;
  final DateTime? lastReviewed;
  final DateTime nextReview;

  const SrsItem({
    this.id,
    required this.word,
    required this.article,
    required this.gender,
    this.plural,
    this.translation,
    this.stage = 1,
    this.consecutiveCorrect = 0,
    this.totalAttempts = 0,
    this.totalCorrect = 0,
    this.lastReviewed,
    required this.nextReview,
  });

  /// True if the word is ready for spaced review.
  bool get isDue => DateTime.now().toUtc().isAfter(nextReview.toUtc());

  /// Historical accuracy percentage (0.0 to 1.0).
  double get accuracy => totalAttempts > 0 ? totalCorrect / totalAttempts : 0.0;

  /// Human-friendly name of the current learning stage.
  String get stageName {
    switch (stage) {
      case 1:
        return 'Learning';
      case 2:
        return 'Review';
      case 3:
        return 'Familiar';
      case 4:
        return 'Solid';
      case 5:
        return 'Mastered';
      default:
        return 'Stage $stage';
    }
  }

  /// Whether the word has reached top retention mastery.
  bool get isMastered => stage >= 5;

  /// Converts this SRS item into a [WordModel] for quiz and lookup consumers.
  WordModel toWordModel() => WordModel(
        word: word,
        article: article,
        gender: gender,
        plural: plural,
        translation: translation,
        source: 'srs',
      );

  /// Spaced review intervals for each stage:
  /// - Stage 1: 4 hours (immediate reinforcement)
  /// - Stage 2: 1 day (short retention)
  /// - Stage 3: 3 days (medium retention)
  /// - Stage 4: 7 days (long retention)
  /// - Stage 5: 14 days (mastered long-term)
  static Duration intervalForStage(int stage) {
    switch (stage) {
      case 1:
        return const Duration(hours: 4);
      case 2:
        return const Duration(days: 1);
      case 3:
        return const Duration(days: 3);
      case 4:
        return const Duration(days: 7);
      case 5:
      default:
        return const Duration(days: 14);
    }
  }

  /// Calculates the next spaced repetition state based on the quiz result.
  ///
  /// - Correct answer: increments consecutive correct, advances stage (up to 5),
  ///   and schedules review based on the new stage's interval.
  /// - Incorrect answer: resets consecutive correct, decreases stage by up to 2 steps,
  ///   and schedules quick re-review in 4 hours.
  SrsItem recordAttempt({required bool correct, DateTime? now}) {
    final currentNow = now ?? DateTime.now().toUtc();
    int newStage;
    int newConsecutive;
    Duration interval;

    if (correct) {
      newConsecutive = consecutiveCorrect + 1;
      newStage = (stage + 1).clamp(1, 5);
      interval = intervalForStage(newStage);
    } else {
      newConsecutive = 0;
      newStage = (stage - 2).clamp(1, 5);
      interval = const Duration(hours: 4);
    }

    return SrsItem(
      id: id,
      word: word,
      article: article,
      gender: gender,
      plural: plural,
      translation: translation,
      stage: newStage,
      consecutiveCorrect: newConsecutive,
      totalAttempts: totalAttempts + 1,
      totalCorrect: correct ? totalCorrect + 1 : totalCorrect,
      lastReviewed: currentNow,
      nextReview: currentNow.add(interval),
    );
  }

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'word': word,
        'article': article,
        'gender': gender,
        'plural': plural,
        'translation': translation,
        'stage': stage,
        'consecutive_correct': consecutiveCorrect,
        'total_attempts': totalAttempts,
        'total_correct': totalCorrect,
        'last_reviewed': lastReviewed?.toUtc().toIso8601String(),
        'next_review': nextReview.toUtc().toIso8601String(),
      };

  factory SrsItem.fromMap(Map<String, dynamic> map) {
    return SrsItem(
      id: map['id'] as int?,
      word: map['word'] as String,
      article: map['article'] as String,
      gender: (map['gender'] as String?) ?? 'm',
      plural: map['plural'] as String?,
      translation: map['translation'] as String?,
      stage: (map['stage'] as int?) ?? 1,
      consecutiveCorrect: (map['consecutive_correct'] as int?) ?? 0,
      totalAttempts: (map['total_attempts'] as int?) ?? 0,
      totalCorrect: (map['total_correct'] as int?) ?? 0,
      lastReviewed: map['last_reviewed'] != null
          ? DateTime.tryParse(map['last_reviewed'] as String)
          : null,
      nextReview: DateTime.parse(map['next_review'] as String),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SrsItem &&
          word.toLowerCase() == other.word.toLowerCase() &&
          stage == other.stage &&
          consecutiveCorrect == other.consecutiveCorrect;

  @override
  int get hashCode => Object.hash(word.toLowerCase(), stage, consecutiveCorrect);
}
