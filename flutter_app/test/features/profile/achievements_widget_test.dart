import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:derdiedas/features/profile/widgets/achievements_card.dart';
import 'package:derdiedas/domain/repositories/i_achievements_repository.dart';
import 'package:derdiedas/core/di/providers.dart';
import 'package:derdiedas/domain/models/achievement.dart';

import 'package:derdiedas/domain/repositories/i_history_repository.dart';
import 'package:derdiedas/domain/repositories/i_srs_repository.dart';
import 'package:derdiedas/domain/models/srs_stats.dart';

class MockAchievementsRepository extends Mock
    implements IAchievementsRepository {}
class MockHistoryRepository extends Mock implements IHistoryRepository {}
class MockSrsRepository extends Mock implements ISrsRepository {}

void main() {
  late MockAchievementsRepository mockAchievementsRepo;
  late MockHistoryRepository mockHistoryRepo;
  late MockSrsRepository mockSrsRepo;

  setUp(() {
    mockAchievementsRepo = MockAchievementsRepository();
    mockHistoryRepo = MockHistoryRepository();
    mockSrsRepo = MockSrsRepository();

    when(() => mockAchievementsRepo.checkNewUnlocks())
        .thenAnswer((_) async => []);
    when(() => mockHistoryRepo.getHistory(filter: any(named: 'filter')))
        .thenAnswer((_) async => []);
    when(() => mockHistoryRepo.getStats())
        .thenAnswer((_) async => {'streak': 0, 'total': 0});
    when(() => mockSrsRepo.getStats())
        .thenAnswer((_) async => const SrsStats.empty());
    when(() => mockSrsRepo.getDueItems(limit: any(named: 'limit')))
        .thenAnswer((_) async => []);
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        achievementsRepositoryProvider.overrideWithValue(mockAchievementsRepo),
        historyRepositoryProvider.overrideWithValue(mockHistoryRepo),
        srsRepositoryProvider.overrideWithValue(mockSrsRepo),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: AchievementsCard(isDark: false),
          ),
        ),
      ),
    );
  }

  testWidgets('renders achievements summary and previews milestones', (tester) async {
    final list = [
      Achievement(
        id: 'streak_7',
        title: 'Flame Keeper',
        description: 'Maintain a 7-day learning streak',
        category: AchievementCategory.streak,
        icon: Icons.whatshot_rounded,
        targetValue: 7,
        currentValue: 7,
        isUnlocked: true,
        unlockedAt: DateTime.utc(2026, 10, 5),
      ),
      const Achievement(
        id: 'words_100',
        title: 'Century Club',
        description: 'Practice 100 unique German nouns',
        category: AchievementCategory.vocabulary,
        icon: Icons.military_tech_rounded,
        targetValue: 100,
        currentValue: 45,
        isUnlocked: false,
      ),
      const Achievement(
        id: 'quiz_50',
        title: 'Quiz Enthusiast',
        description: 'Answer 50 quiz questions',
        category: AchievementCategory.mastery,
        icon: Icons.sports_score_rounded,
        targetValue: 50,
        currentValue: 12,
        isUnlocked: false,
      ),
    ];

    when(() => mockAchievementsRepo.getAchievements())
        .thenAnswer((_) async => list);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Summary header
    expect(find.text('Milestones & Badges'), findsOneWidget);
    expect(find.text('1 of 3 badges earned (33%)'), findsOneWidget);

    // Milestones preview
    expect(find.text('Flame Keeper'), findsOneWidget);
    expect(find.text('Century Club'), findsOneWidget);
    expect(find.text('Quiz Enthusiast'), findsOneWidget);

    // View all button
    final viewAllBtn = find.byKey(const Key('profile_view_all_achievements'));
    expect(viewAllBtn, findsOneWidget);

    // Tap View all to open the bottom sheet
    await tester.tap(viewAllBtn);
    await tester.pumpAndSettle();

    // Bottom sheet content
    expect(find.text('Achievements & Milestones'), findsOneWidget);
    expect(find.text('1 of 3 unlocked'), findsOneWidget);
  });
}
