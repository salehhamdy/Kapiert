import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:derdiedas/features/legal/screens/legal_document_screen.dart';
import 'package:derdiedas/features/settings/screens/settings_screen.dart';
import 'package:derdiedas/domain/repositories/i_auth_repository.dart';
import 'package:derdiedas/domain/repositories/i_history_repository.dart';
import 'package:derdiedas/domain/repositories/i_sync_repository.dart';
import 'package:derdiedas/domain/repositories/i_settings_repository.dart';
import 'package:derdiedas/core/di/providers.dart';

import 'package:derdiedas/config/app_config.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}
class MockHistoryRepository extends Mock implements IHistoryRepository {}
class MockSyncRepository extends Mock implements ISyncRepository {}
class MockSettingsRepository extends Mock implements ISettingsRepository {}

void main() {
  late MockAuthRepository mockAuthRepo;
  late MockHistoryRepository mockHistoryRepo;
  late MockSyncRepository mockSyncRepo;
  late MockSettingsRepository mockSettingsRepo;

  setUp(() {
    AppConfig.apiBaseUrl = 'http://127.0.0.1:8000';
    mockAuthRepo = MockAuthRepository();
    mockHistoryRepo = MockHistoryRepository();
    mockSyncRepo = MockSyncRepository();
    mockSettingsRepo = MockSettingsRepository();

    when(() => mockAuthRepo.currentUser).thenReturn(null);
    when(() => mockAuthRepo.isEnabled).thenReturn(false);
    when(() => mockSyncRepo.isActive).thenReturn(false);
    when(() => mockSyncRepo.syncAll()).thenAnswer((_) async {});
    when(() => mockHistoryRepo.getStreak()).thenReturn(0);
    when(() => mockHistoryRepo.getHistory()).thenAnswer((_) async => []);
    when(() => mockSettingsRepo.getDarkMode()).thenReturn(false);
    when(() => mockSettingsRepo.getShowHints()).thenReturn(true);
    when(() => mockSettingsRepo.getLanguage()).thenReturn('en');
  });

  testWidgets('LegalDocumentScreen renders Terms of Use by default and switches to Privacy Policy',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LegalDocumentScreen(),
      ),
    );

    // Initial state: Terms of Use
    expect(find.text('Legal & Policies'), findsOneWidget);
    expect(find.text('1. Acceptance of Terms'), findsOneWidget);
    expect(find.text('2. Description of Service'), findsOneWidget);
    expect(find.text('3. License & Intellectual Property'), findsOneWidget);

    // Tap Privacy Policy tab
    await tester.tap(find.text('Privacy Policy'));
    await tester.pumpAndSettle();

    // Switched state: Privacy Policy
    expect(find.text('1. Privacy-First Commitment'), findsOneWidget);
    expect(find.text('2. Data Stored Locally (Guest Mode)'), findsOneWidget);
    expect(find.text('3. Cloud Sync (Signed-In Mode)'), findsOneWidget);
  });

  testWidgets('LegalDocumentScreen renders Privacy Policy directly when initialType is privacy',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LegalDocumentScreen(
          initialType: LegalDocType.privacy,
        ),
      ),
    );

    expect(find.text('1. Privacy-First Commitment'), findsOneWidget);
    expect(find.text('5. Your Rights (GDPR & CCPA)'), findsOneWidget);
    expect(find.text('1. Acceptance of Terms'), findsNothing);
  });

  testWidgets('SettingsScreen contains Terms of Use and Privacy Policy tiles',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepo),
          historyRepositoryProvider.overrideWithValue(mockHistoryRepo),
          syncRepositoryProvider.overrideWithValue(mockSyncRepo),
          settingsRepositoryProvider.overrideWithValue(mockSettingsRepo),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: SettingsScreen(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Scroll down to reveal Legal section
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -600));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('settings_terms_tile')), findsOneWidget);
    expect(find.byKey(const Key('settings_privacy_tile')), findsOneWidget);
    expect(find.text('Terms of Use'), findsOneWidget);
    expect(find.text('Privacy Policy'), findsOneWidget);
  });
}
