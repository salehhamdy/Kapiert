import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:derdiedas/features/profile/screens/profile_screen.dart';
import 'package:derdiedas/domain/repositories/i_achievements_repository.dart';
import 'package:derdiedas/domain/repositories/i_auth_repository.dart';
import 'package:derdiedas/domain/repositories/i_history_repository.dart';
import 'package:derdiedas/domain/repositories/i_sync_repository.dart';
import 'package:derdiedas/domain/repositories/i_srs_repository.dart';
import 'package:derdiedas/core/di/providers.dart';
import 'package:derdiedas/domain/models/advanced_stats.dart';
import 'package:derdiedas/domain/models/srs_stats.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}
class MockHistoryRepository extends Mock implements IHistoryRepository {}
class MockSyncRepository extends Mock implements ISyncRepository {}
class MockSrsRepository extends Mock implements ISrsRepository {}
class MockAchievementsRepository extends Mock implements IAchievementsRepository {}

void main() {
  late MockAuthRepository mockAuthRepo;
  late MockHistoryRepository mockHistoryRepo;
  late MockSyncRepository mockSyncRepo;
  late MockSrsRepository mockSrsRepo;
  late MockAchievementsRepository mockAchievementsRepo;

  setUp(() {
    mockAuthRepo = MockAuthRepository();
    mockHistoryRepo = MockHistoryRepository();
    mockSyncRepo = MockSyncRepository();
    mockSrsRepo = MockSrsRepository();
    mockAchievementsRepo = MockAchievementsRepository();

    when(() => mockSyncRepo.isActive).thenReturn(false);
    when(() => mockSyncRepo.syncAll()).thenAnswer((_) async {});
    when(() => mockHistoryRepo.getStreak()).thenReturn(5);
    when(() => mockHistoryRepo.getHistory(filter: any(named: 'filter')))
        .thenAnswer((_) async => []);
    when(() => mockHistoryRepo.getStats()).thenAnswer((_) async => {
          'streak': 5,
          'total': 20,
          'totalQuiz': 15,
          'correct': 12,
          'accuracy': 80.0,
        });
    when(() => mockHistoryRepo.getAdvancedStats(days: any(named: 'days')))
        .thenAnswer((_) async => AdvancedStats.empty());
    when(() => mockAchievementsRepo.getAchievements())
        .thenAnswer((_) async => []);
    when(() => mockAchievementsRepo.checkNewUnlocks())
        .thenAnswer((_) async => []);

    when(() => mockSrsRepo.getDueItems(limit: any(named: 'limit')))
        .thenAnswer((_) async => []);
    when(() => mockSrsRepo.getStats()).thenAnswer((_) async => const SrsStats(
          totalCount: 15,
          dueCount: 4,
          learningCount: 5,
          reviewingCount: 6,
          masteredCount: 4,
        ));
  });

  Widget createWidgetUnderTest() {
    when(() => mockAuthRepo.currentUser).thenReturn(null);
    when(() => mockAuthRepo.isEnabled).thenReturn(true);

    return ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockAuthRepo),
        historyRepositoryProvider.overrideWithValue(mockHistoryRepo),
        syncRepositoryProvider.overrideWithValue(mockSyncRepo),
        srsRepositoryProvider.overrideWithValue(mockSrsRepo),
        achievementsRepositoryProvider.overrideWithValue(mockAchievementsRepo),
      ],
      child: const MaterialApp(
        home: ProfileScreen(),
      ),
    );
  }

  testWidgets('ProfileScreen renders Spaced Repetition section with metrics',
      (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('SPACED REPETITION'), findsOneWidget);
    expect(find.text('Due now'), findsOneWidget);
    expect(find.text('4'), findsWidgets); // Due now count & mastered count
    expect(find.text('Learning'), findsOneWidget);
    expect(find.text('5'), findsWidgets); // Learning count and streak
    expect(find.text('Reviewing'), findsOneWidget);
    expect(find.text('6'), findsOneWidget); // Reviewing count
    expect(find.text('Mastered'), findsOneWidget);
    expect(find.text('Mastery rate'), findsOneWidget);
  });
}
