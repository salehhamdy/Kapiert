import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:derdiedas/domain/models/achievement.dart';

void main() {
  group('Achievement Model Tests', () {
    test('progress clamps between 0.0 and 1.0 and percent calculates correctly', () {
      final achZero = Achievement(
        id: 'streak_7',
        title: 'Flame Keeper',
        description: 'Maintain a 7-day streak',
        category: AchievementCategory.streak,
        icon: Icons.whatshot_rounded,
        targetValue: 7,
        currentValue: 0,
        isUnlocked: false,
      );
      expect(achZero.progress, 0.0);
      expect(achZero.percent, 0);

      final achPartial = achZero.copyWith(currentValue: 5);
      expect(achPartial.progress, closeTo(5 / 7, 0.001));
      expect(achPartial.percent, 71);

      final achExceed = achZero.copyWith(currentValue: 10, isUnlocked: true);
      expect(achExceed.progress, 1.0);
      expect(achExceed.percent, 100);
    });

    test('copyWith updates properties properly', () {
      final now = DateTime.utc(2026, 10, 7);
      final ach = Achievement(
        id: 'words_100',
        title: 'Century Club',
        description: 'Practice 100 words',
        category: AchievementCategory.vocabulary,
        icon: Icons.military_tech_rounded,
        targetValue: 100,
        currentValue: 42,
        isUnlocked: false,
      );

      final unlocked = ach.copyWith(
        currentValue: 100,
        isUnlocked: true,
        unlockedAt: now,
      );

      expect(unlocked.id, 'words_100');
      expect(unlocked.currentValue, 100);
      expect(unlocked.isUnlocked, isTrue);
      expect(unlocked.unlockedAt, now);
      expect(unlocked.progress, 1.0);
    });

    test('AchievementCategory extension provides label and icon', () {
      expect(AchievementCategory.streak.label, 'Streaks');
      expect(AchievementCategory.vocabulary.label, 'Vocabulary');
      expect(AchievementCategory.mastery.label, 'Mastery');
      expect(AchievementCategory.srs.label, 'Retention');
      expect(AchievementCategory.favorites.label, 'Favorites');

      expect(AchievementCategory.streak.icon, Icons.local_fire_department_rounded);
      expect(AchievementCategory.vocabulary.icon, Icons.menu_book_rounded);
    });
  });
}
