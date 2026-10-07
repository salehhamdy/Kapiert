import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:derdiedas/features/profile/screens/profile_screen.dart';
import 'package:derdiedas/domain/repositories/i_achievements_repository.dart';
import 'package:derdiedas/domain/repositories/i_auth_repository.dart';
import 'package:derdiedas/domain/repositories/i_history_repository.dart';
import 'package:derdiedas/domain/repositories/i_sync_repository.dart';
import 'package:derdiedas/core/di/providers.dart';
import 'package:derdiedas/domain/models/advanced_stats.dart';
import 'package:derdiedas/domain/models/auth_user.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}
class MockHistoryRepository extends Mock implements IHistoryRepository {}
class MockSyncRepository extends Mock implements ISyncRepository {}
class MockAchievementsRepository extends Mock implements IAchievementsRepository {}

void main() {
  late MockAuthRepository mockAuthRepo;
  late MockHistoryRepository mockHistoryRepo;
  late MockSyncRepository mockSyncRepo;
  late MockAchievementsRepository mockAchievementsRepo;

  setUp(() {
    mockAuthRepo = MockAuthRepository();
    mockHistoryRepo = MockHistoryRepository();
    mockSyncRepo = MockSyncRepository();
    mockAchievementsRepo = MockAchievementsRepository();

    when(() => mockSyncRepo.isActive).thenReturn(false);
    when(() => mockSyncRepo.syncAll()).thenAnswer((_) async {});
    when(() => mockSyncRepo.flushBeforeSignOut()).thenAnswer((_) async {});
    when(() => mockHistoryRepo.getStreak()).thenReturn(0);
    when(() => mockHistoryRepo.getHistory()).thenAnswer((_) async => []);
    when(() => mockHistoryRepo.getStats()).thenAnswer((_) async => {
          'streak': 0,
          'total': 0,
          'totalQuiz': 0,
          'totalLookups': 0,
          'correct': 0,
          'accuracy': 0.0,
          'uniqueWords': 0,
          'byArticle': <String, Map<String, int>>{},
        });
    when(() => mockHistoryRepo.getAdvancedStats(days: any(named: 'days')))
        .thenAnswer((_) async => AdvancedStats.empty());
    when(() => mockAchievementsRepo.getAchievements())
        .thenAnswer((_) async => []);
    when(() => mockAchievementsRepo.checkNewUnlocks())
        .thenAnswer((_) async => []);
  });

  Widget createWidgetUnderTest({AppUser? user}) {
    when(() => mockAuthRepo.currentUser).thenReturn(user);
    when(() => mockAuthRepo.isEnabled).thenReturn(true);

    return ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockAuthRepo),
        historyRepositoryProvider.overrideWithValue(mockHistoryRepo),
        syncRepositoryProvider.overrideWithValue(mockSyncRepo),
        achievementsRepositoryProvider.overrideWithValue(mockAchievementsRepo),
      ],
      child: const MaterialApp(
        home: ProfileScreen(),
      ),
    );
  }

  group('ProfileScreen Widget Tests', () {
    testWidgets('renders guest state correctly', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(user: null));
      await tester.pumpAndSettle();

      expect(find.text('Profile'), findsOneWidget);
      expect(find.byKey(const Key('profile_display_name')), findsOneWidget);
      expect(find.text('Guest'), findsWidgets);
      expect(find.text('Guest · on this device'), findsOneWidget);

      // Guest CTA card
      expect(find.text('Keep your progress safe'), findsOneWidget);
      expect(find.byKey(const Key('profile_guest_sign_in')), findsOneWidget);
      expect(find.byKey(const Key('profile_guest_sign_up')), findsOneWidget);

      // Stats section
      expect(find.text('YOUR PROGRESS'), findsOneWidget);
      expect(find.text('ACTIVITY & TRENDS'), findsOneWidget);
      expect(find.text('ACHIEVEMENTS'), findsOneWidget);
      expect(find.text('ARTICLE MASTERY'), findsOneWidget);

      // No account edit or logout for guests
      expect(find.byKey(const Key('profile_logout')), findsNothing);
      expect(find.byKey(const Key('profile_edit_name_tile')), findsNothing);
    });

    testWidgets('renders signed in user with stats and mastery', (tester) async {
      final testUser = AppUser(
        id: 'u-123',
        email: 'anna@kapiert.de',
        displayName: 'Anna Müller',
        provider: 'email',
        createdAt: DateTime(2026, 3, 15),
      );

      when(() => mockSyncRepo.isActive).thenReturn(true);
      when(() => mockHistoryRepo.getStreak()).thenReturn(7);
      when(() => mockHistoryRepo.getStats()).thenAnswer((_) async => {
            'streak': 7,
            'total': 30,
            'totalQuiz': 20,
            'totalLookups': 10,
            'correct': 16,
            'accuracy': 80.0,
            'uniqueWords': 25,
            'firstActivity': DateTime(2026, 3, 16),
            'byArticle': {
              'der': {'total': 10, 'quiz': 8, 'correct': 7},
              'die': {'total': 12, 'quiz': 7, 'correct': 6},
              'das': {'total': 8, 'quiz': 5, 'correct': 3},
            },
          });

      await tester.pumpWidget(createWidgetUnderTest(user: testUser));
      await tester.pumpAndSettle();

      // Header info
      expect(find.text('Anna Müller'), findsWidgets);
      expect(find.text('anna@kapiert.de'), findsWidgets);
      expect(find.text('Member since Mar 2026'), findsOneWidget);

      // Cloud sync card
      expect(find.text('Cloud sync on'), findsOneWidget);
      expect(find.byKey(const Key('profile_sync_now')), findsOneWidget);

      // Stats grid
      expect(find.text('7'), findsOneWidget);
      expect(find.text('Days streak'), findsOneWidget);
      expect(find.text('25'), findsOneWidget);
      expect(find.text('Words practised'), findsOneWidget);
      expect(find.text('20'), findsOneWidget);
      expect(find.text('Quiz answers'), findsOneWidget);
      expect(find.text('80%'), findsOneWidget);

      // Article mastery
      expect(find.text('der'), findsOneWidget);
      expect(find.text('die'), findsOneWidget);
      expect(find.text('das'), findsOneWidget);

      // Weakest article hint (das: 3/5 = 60%)
      expect(find.textContaining('Focus on'), findsOneWidget);

      // Account tiles
      expect(find.byKey(const Key('profile_edit_name_tile')), findsOneWidget);
      expect(find.text('Sign-in method'), findsOneWidget);
      expect(find.text('Email & password'), findsOneWidget);
      expect(find.byKey(const Key('profile_logout')), findsOneWidget);
    });

    testWidgets('editing display name calls updateDisplayName', (tester) async {
      final testUser = AppUser(
        id: 'u-123',
        email: 'anna@kapiert.de',
        displayName: 'Anna',
      );

      when(() => mockAuthRepo.updateDisplayName(any())).thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetUnderTest(user: testUser));
      await tester.pumpAndSettle();

      // Tap edit name button in header
      await tester.tap(find.byKey(const Key('profile_edit_name_button')));
      await tester.pumpAndSettle();

      // Bottom sheet appears
      expect(find.text('Display name'), findsWidgets);
      expect(find.byKey(const Key('profile_name_field')), findsOneWidget);

      // Type new name
      await tester.enterText(find.byKey(const Key('profile_name_field')), 'Anna Schmidt');
      await tester.pumpAndSettle();

      // Tap save
      await tester.tap(find.byKey(const Key('profile_name_save')));
      await tester.pumpAndSettle();

      verify(() => mockAuthRepo.updateDisplayName('Anna Schmidt')).called(1);
    });
  });
}
