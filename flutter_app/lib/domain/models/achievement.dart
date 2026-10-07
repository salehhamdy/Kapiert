import 'package:flutter/material.dart';

/// Categories of learning milestones and achievements.
enum AchievementCategory {
  streak,
  vocabulary,
  mastery,
  srs,
  favorites,
}

extension AchievementCategoryX on AchievementCategory {
  String get label {
    switch (this) {
      case AchievementCategory.streak:
        return 'Streaks';
      case AchievementCategory.vocabulary:
        return 'Vocabulary';
      case AchievementCategory.mastery:
        return 'Mastery';
      case AchievementCategory.srs:
        return 'Retention';
      case AchievementCategory.favorites:
        return 'Favorites';
    }
  }

  IconData get icon {
    switch (this) {
      case AchievementCategory.streak:
        return Icons.local_fire_department_rounded;
      case AchievementCategory.vocabulary:
        return Icons.menu_book_rounded;
      case AchievementCategory.mastery:
        return Icons.track_changes_rounded;
      case AchievementCategory.srs:
        return Icons.psychology_rounded;
      case AchievementCategory.favorites:
        return Icons.star_rounded;
    }
  }
}

/// Represents an unlocked or in-progress learning milestone.
class Achievement {
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.icon,
    required this.targetValue,
    required this.currentValue,
    required this.isUnlocked,
    this.unlockedAt,
  });

  /// Unique stable identifier (e.g., 'streak_7', 'words_100').
  final String id;

  /// Display title.
  final String title;

  /// Description explaining the goal or criteria.
  final String description;

  /// Milestones category.
  final AchievementCategory category;

  /// Iconic badge visual.
  final IconData icon;

  /// Numeric target to achieve.
  final int targetValue;

  /// Current learner progress toward [targetValue].
  final int currentValue;

  /// Whether the criteria have been fulfilled.
  final bool isUnlocked;

  /// Timestamp when the milestone was first unlocked.
  final DateTime? unlockedAt;

  /// Fractional progress between 0.0 and 1.0.
  double get progress =>
      targetValue > 0 ? (currentValue / targetValue).clamp(0.0, 1.0) : 0.0;

  /// Percentage progress rounded to the nearest integer (0–100).
  int get percent => (progress * 100).toInt();

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    AchievementCategory? category,
    IconData? icon,
    int? targetValue,
    int? currentValue,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}
