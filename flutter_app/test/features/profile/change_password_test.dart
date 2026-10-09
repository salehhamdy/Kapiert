import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:derdiedas/core/di/providers.dart';
import 'package:derdiedas/core/localization/app_localizations.dart';
import 'package:derdiedas/domain/models/advanced_stats.dart';
import 'package:derdiedas/domain/models/auth_user.dart';
import 'package:derdiedas/domain/repositories/i_achievements_repository.dart';
import 'package:derdiedas/domain/repositories/i_auth_repository.dart';
import 'package:derdiedas/domain/repositories/i_history_repository.dart';
import 'package:derdiedas/domain/repositories/i_sync_repository.dart';
import 'package:derdiedas/features/profile/widgets/change_password_sheet.dart';
import 'package:derdiedas/features/profile/screens/profile_screen.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}
class MockHistoryRepository extends Mock implements IHistoryRepository {}
class MockSyncRepository extends Mock implements ISyncRepository {}
class MockAchievementsRepository extends Mock implements IAchievementsRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockAuthRepository mockAuthRepo;
  late MockHistoryRepository mockHistoryRepo;
  late MockSyncRepository mockSyncRepo;
  late MockAchievementsRepository mockAchievementsRepo;

  setUp(() {
    mockAuthRepo = MockAuthRepository();
    mockHistoryRepo = MockHistoryRepository();
    mockSyncRepo = MockSyncRepository();
    mockAchievementsRepo = MockAchievementsRepository();

    when(() => mockAuthRepo.currentUser).thenReturn(null);
    when(() => mockAuthRepo.isEnabled).thenReturn(true);

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

  group('ChangePasswordSheet Widget Tests', () {
    testWidgets('renders new and confirm password fields and save button', (tester) async {
      await tester.pumpWidget(createChangePasswordTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Change password'), findsOneWidget);
      expect(find.byKey(const Key('change_password_new_field')), findsOneWidget);
      expect(find.byKey(const Key('change_password_confirm_field')), findsOneWidget);
      expect(find.byKey(const Key('change_password_save_btn')), findsOneWidget);
    });

    testWidgets('shows mismatch error when new and confirm passwords differ', (tester) async {
      await tester.pumpWidget(createChangePasswordTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('change_password_new_field')), 'password123');
      await tester.enterText(find.byKey(const Key('change_password_confirm_field')), 'password999');
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('change_password_save_btn')));
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match'), findsOneWidget);
      verifyNever(() => mockAuthRepo.updatePassword(any()));
    });

    testWidgets('submits new password when passwords match', (tester) async {
      final authRepo = MockAuthRepository();
      when(() => authRepo.currentUser).thenReturn(
        const AppUser(
          id: 'test_uid',
          email: 'user@example.com',
          provider: 'email',
        ),
      );
      when(() => authRepo.isEnabled).thenReturn(true);
      when(() => authRepo.updatePassword('securePass123')).thenAnswer((_) async {});

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(authRepo),
          ],
          child: const MaterialApp(
            localizationsDelegates: [
              AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLanguage.supportedLocales,
            home: Scaffold(
              body: ChangePasswordSheet(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('change_password_new_field')), 'securePass123');
      await tester.enterText(find.byKey(const Key('change_password_confirm_field')), 'securePass123');
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('change_password_save_btn')));
      await tester.pumpAndSettle();

      verify(() => authRepo.updatePassword('securePass123')).called(1);
    });
  });

  group('ProfileScreen Auth Guard Tests', () {
    testWidgets('guest user tapping Change password shows login required dialog', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockAuthRepo),
            historyRepositoryProvider.overrideWithValue(mockHistoryRepo),
            syncRepositoryProvider.overrideWithValue(mockSyncRepo),
            achievementsRepositoryProvider.overrideWithValue(mockAchievementsRepo),
          ],
          child: const MaterialApp(
            localizationsDelegates: [
              AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLanguage.supportedLocales,
            home: ProfileScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find guest change password tile and tap it
      final tile = find.byKey(const Key('profile_guest_change_password_tile'));
      expect(tile, findsOneWidget);

      await tester.ensureVisible(tile);
      await tester.tap(tile);
      await tester.pumpAndSettle();

      // Dialog should appear
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('You must be signed in to change your password.'), findsOneWidget);
      expect(find.byKey(const Key('guest_dialog_sign_in_btn')), findsOneWidget);
    });
  });
}

Widget createChangePasswordTestWidget() {
  final mockAuthRepo = MockAuthRepository();
  when(() => mockAuthRepo.currentUser).thenReturn(
    const AppUser(
      id: 'test_uid',
      email: 'user@example.com',
      provider: 'email',
    ),
  );
  when(() => mockAuthRepo.isEnabled).thenReturn(true);

  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(mockAuthRepo),
    ],
    child: const MaterialApp(
      localizationsDelegates: [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLanguage.supportedLocales,
      home: Scaffold(
        body: ChangePasswordSheet(),
      ),
    ),
  );
}
