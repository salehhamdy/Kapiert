import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:derdiedas/config/app_config.dart';
import 'package:derdiedas/main.dart';
import 'package:derdiedas/shared/router/app_router.dart';
import 'package:derdiedas/features/legal/screens/first_use_consent_screen.dart';
import 'package:derdiedas/features/legal/providers/terms_consent_provider.dart';
import 'package:derdiedas/domain/repositories/i_auth_repository.dart';
import 'package:derdiedas/domain/repositories/i_history_repository.dart';
import 'package:derdiedas/domain/repositories/i_sync_repository.dart';
import 'package:derdiedas/domain/repositories/i_settings_repository.dart';
import 'package:derdiedas/domain/repositories/i_article_repository.dart';
import 'package:derdiedas/domain/repositories/i_favorites_repository.dart';
import 'package:derdiedas/core/di/providers.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}
class MockHistoryRepository extends Mock implements IHistoryRepository {}
class MockSyncRepository extends Mock implements ISyncRepository {}
class MockSettingsRepository extends Mock implements ISettingsRepository {}
class MockArticleRepository extends Mock implements IArticleRepository {}
class MockFavoritesRepository extends Mock implements IFavoritesRepository {}

void main() {
  late MockAuthRepository mockAuthRepo;
  late MockHistoryRepository mockHistoryRepo;
  late MockSyncRepository mockSyncRepo;
  late MockSettingsRepository mockSettingsRepo;
  late MockArticleRepository mockArticleRepo;
  late MockFavoritesRepository mockFavoritesRepo;

  setUp(() {
    AppConfig.apiBaseUrl = 'http://127.0.0.1:8000';
    mockAuthRepo = MockAuthRepository();
    mockHistoryRepo = MockHistoryRepository();
    mockSyncRepo = MockSyncRepository();
    mockSettingsRepo = MockSettingsRepository();
    mockArticleRepo = MockArticleRepository();
    mockFavoritesRepo = MockFavoritesRepository();

    when(() => mockAuthRepo.currentUser).thenReturn(null);
    when(() => mockAuthRepo.isEnabled).thenReturn(false);
    when(() => mockSyncRepo.isActive).thenReturn(false);
    when(() => mockSyncRepo.syncAll()).thenAnswer((_) async {});
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
    when(() => mockFavoritesRepo.getFavorites()).thenAnswer((_) async => []);
    when(() => mockSettingsRepo.getDarkMode()).thenReturn(false);
    when(() => mockSettingsRepo.getShowHints()).thenReturn(true);
  });

  testWidgets(
      'KapiertApp gates access with FirstUseConsentScreen before first use and unlocks on agree',
      (tester) async {
    final notifier = TermsConsentNotifier(false);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          termsConsentProvider.overrideWith((_) => notifier),
          authRepositoryProvider.overrideWithValue(mockAuthRepo),
          historyRepositoryProvider.overrideWithValue(mockHistoryRepo),
          syncRepositoryProvider.overrideWithValue(mockSyncRepo),
          settingsRepositoryProvider.overrideWithValue(mockSettingsRepo),
          articleRepositoryProvider.overrideWithValue(mockArticleRepo),
          favoritesRepositoryProvider.overrideWithValue(mockFavoritesRepo),
        ],
        child: const KapiertApp(),
      ),
    );

    // Initial launch: User has NOT agreed to terms.
    // FirstUseConsentScreen is shown; MainScaffold is NOT displayed.
    expect(find.byType(FirstUseConsentScreen), findsOneWidget);
    expect(find.byType(MainScaffold), findsNothing);

    // Tap checkbox to agree
    await tester.tap(find.byKey(const Key('consent_terms_checkbox')));
    await tester.pump();

    // Tap Agree button
    await tester.tap(find.byKey(const Key('consent_agree_button')));
    await tester.pumpAndSettle();

    // State is now accepted and KapiertApp seamlessly transitions to MainScaffold!
    expect(find.byType(FirstUseConsentScreen), findsNothing);
    expect(find.byType(MainScaffold), findsOneWidget);
  });
}
