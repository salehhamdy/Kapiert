import 'package:flutter_test/flutter_test.dart';
import 'package:derdiedas/domain/models/advanced_stats.dart';
import 'package:derdiedas/domain/models/daily_activity.dart';

void main() {
  group('AdvancedStats Model Tests', () {
    test('empty factory creates zero-valued instance', () {
      final empty = AdvancedStats.empty();
      expect(empty.dailyActivities, isEmpty);
      expect(empty.totalActivities, 0);
      expect(empty.currentWeekTotal, 0);
      expect(empty.previousWeekTotal, 0);
      expect(empty.bestDayCount, 0);
      expect(empty.bestDayDate, isNull);
      expect(empty.activeDaysCount, 0);
      expect(empty.dailyAverage, 0.0);
      expect(empty.overallAccuracy, 0.0);
      expect(empty.weekOverWeekPercentage, isNull);
      expect(empty.last7Days, isEmpty);
      expect(empty.last14Days, isEmpty);
    });

    test('slices last7Days and last14Days accurately', () {
      final days = List.generate(14, (i) {
        return DailyActivity(
          date: DateTime.utc(2026, 10, i + 1),
          totalCount: i + 1,
          quizCount: i + 1,
          quizCorrect: i,
          lookupCount: 0,
          uniqueWords: i + 1,
        );
      });

      final stats = AdvancedStats(
        dailyActivities: days,
        totalActivities: 105,
        currentWeekTotal: 77,
        previousWeekTotal: 28,
        bestDayCount: 14,
        bestDayDate: DateTime.utc(2026, 10, 14),
        activeDaysCount: 7,
        dailyAverage: 11.0,
        overallAccuracy: 88.0,
      );

      expect(stats.last7Days.length, 7);
      expect(stats.last7Days.first.date.day, 8);
      expect(stats.last7Days.last.date.day, 14);

      expect(stats.last14Days.length, 14);
      expect(stats.last14Days.first.date.day, 1);
      expect(stats.last14Days.last.date.day, 14);
    });

    test('calculates weekOverWeekPercentage growth and decline', () {
      final statsGrowing = AdvancedStats(
        dailyActivities: const [],
        totalActivities: 50,
        currentWeekTotal: 30,
        previousWeekTotal: 20,
        bestDayCount: 8,
        activeDaysCount: 5,
        dailyAverage: 4.2,
        overallAccuracy: 85.0,
      );
      expect(statsGrowing.weekOverWeekPercentage, 50.0); // +50%

      final statsDeclining = AdvancedStats(
        dailyActivities: const [],
        totalActivities: 50,
        currentWeekTotal: 10,
        previousWeekTotal: 20,
        bestDayCount: 5,
        activeDaysCount: 3,
        dailyAverage: 1.4,
        overallAccuracy: 75.0,
      );
      expect(statsDeclining.weekOverWeekPercentage, -50.0); // -50%

      final statsNoPrior = AdvancedStats(
        dailyActivities: const [],
        totalActivities: 20,
        currentWeekTotal: 20,
        previousWeekTotal: 0,
        bestDayCount: 5,
        activeDaysCount: 4,
        dailyAverage: 2.8,
        overallAccuracy: 80.0,
      );
      expect(statsNoPrior.weekOverWeekPercentage, isNull);
    });
  });
}
