import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:derdiedas/features/profile/widgets/advanced_stats_card.dart';
import 'package:derdiedas/domain/repositories/i_history_repository.dart';
import 'package:derdiedas/core/di/providers.dart';
import 'package:derdiedas/domain/models/advanced_stats.dart';
import 'package:derdiedas/domain/models/daily_activity.dart';

class MockHistoryRepository extends Mock implements IHistoryRepository {}

void main() {
  late MockHistoryRepository mockHistoryRepo;

  setUp(() {
    mockHistoryRepo = MockHistoryRepository();
    when(() => mockHistoryRepo.getHistory(filter: any(named: 'filter')))
        .thenAnswer((_) async => []);
    when(() => mockHistoryRepo.getStats())
        .thenAnswer((_) async => {'streak': 0, 'total': 0});
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        historyRepositoryProvider.overrideWithValue(mockHistoryRepo),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: AdvancedStatsCard(isDark: false),
          ),
        ),
      ),
    );
  }

  testWidgets('renders empty placeholder when no learning activity exists', (tester) async {
    when(() => mockHistoryRepo.getAdvancedStats(days: any(named: 'days')))
        .thenAnswer((_) async => AdvancedStats.empty());

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.textContaining('Complete quizzes or look up words'), findsOneWidget);
  });

  testWidgets('renders heatmap, volume chart, and metrics when activity exists', (tester) async {
    final days = List.generate(7, (i) {
      return DailyActivity(
        date: DateTime.utc(2026, 10, i + 1),
        totalCount: (i + 1) * 3,
        quizCount: (i + 1) * 2,
        quizCorrect: (i + 1),
        lookupCount: (i + 1),
        uniqueWords: i + 2,
      );
    });

    final stats = AdvancedStats(
      dailyActivities: days,
      totalActivities: 84,
      currentWeekTotal: 84,
      previousWeekTotal: 60,
      bestDayCount: 21,
      bestDayDate: DateTime.utc(2026, 10, 7),
      activeDaysCount: 7,
      dailyAverage: 12.0,
      overallAccuracy: 75.0,
    );

    when(() => mockHistoryRepo.getAdvancedStats(days: any(named: 'days')))
        .thenAnswer((_) async => stats);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Headers & Labels
    expect(find.text('Activity Heatmap'), findsOneWidget);
    expect(find.text('7 of 7 active days this week'), findsOneWidget);
    expect(find.text('Daily Practice Volume'), findsOneWidget);

    // Metric tiles
    expect(find.text('7-Day Total'), findsOneWidget);
    expect(find.text('84'), findsOneWidget);
    expect(find.text('Daily Avg'), findsOneWidget);
    expect(find.text('12.0'), findsOneWidget);
    expect(find.text('Best Day'), findsOneWidget);
    expect(find.text('21'), findsWidgets); // Shown in column header & Best Day tile

    // Tap a heatmap cell (first day) to inspect details
    final cell = find.text('1'); // day 1
    expect(cell, findsWidgets);
    await tester.tap(cell.first);
    await tester.pumpAndSettle();

    // Verify detail pill displayed
    expect(find.textContaining('actions'), findsWidgets);
  });
}
