import 'daily_activity.dart';

/// Aggregated multi-day learning activity, weekly metrics, and progress trends.
class AdvancedStats {
  const AdvancedStats({
    required this.dailyActivities,
    required this.totalActivities,
    required this.currentWeekTotal,
    required this.previousWeekTotal,
    required this.bestDayCount,
    this.bestDayDate,
    required this.activeDaysCount,
    required this.dailyAverage,
    required this.overallAccuracy,
  });

  /// Chronological daily activity records (oldest to newest).
  final List<DailyActivity> dailyActivities;

  /// Total actions across the full analyzed window.
  final int totalActivities;

  /// Total actions in the current 7-day period.
  final int currentWeekTotal;

  /// Total actions in the preceding 7-day period (days 8–14).
  final int previousWeekTotal;

  /// Highest action count recorded in a single calendar day.
  final int bestDayCount;

  /// Date when [bestDayCount] was achieved.
  final DateTime? bestDayDate;

  /// Number of active learning days in the current 7-day period.
  final int activeDaysCount;

  /// Daily average action count over the current 7-day period.
  final double dailyAverage;

  /// Overall quiz accuracy percentage across the analyzed window (0–100).
  final double overallAccuracy;

  /// Sublist of the last 7 calendar days (including today).
  List<DailyActivity> get last7Days {
    if (dailyActivities.isEmpty) return const [];
    if (dailyActivities.length <= 7) return dailyActivities;
    return dailyActivities.sublist(dailyActivities.length - 7);
  }

  /// Sublist of the last 14 calendar days.
  List<DailyActivity> get last14Days {
    if (dailyActivities.isEmpty) return const [];
    if (dailyActivities.length <= 14) return dailyActivities;
    return dailyActivities.sublist(dailyActivities.length - 14);
  }

  /// Percentage growth in practice volume comparing current week to prior week.
  /// Null if prior week had zero activity.
  double? get weekOverWeekPercentage {
    if (previousWeekTotal == 0) return null;
    return ((currentWeekTotal - previousWeekTotal) / previousWeekTotal) * 100;
  }

  /// Create an empty instance when no activity records exist.
  factory AdvancedStats.empty() {
    return const AdvancedStats(
      dailyActivities: [],
      totalActivities: 0,
      currentWeekTotal: 0,
      previousWeekTotal: 0,
      bestDayCount: 0,
      bestDayDate: null,
      activeDaysCount: 0,
      dailyAverage: 0.0,
      overallAccuracy: 0.0,
    );
  }
}
