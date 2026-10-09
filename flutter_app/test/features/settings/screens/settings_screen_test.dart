import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:derdiedas/config/app_config.dart';
import 'package:derdiedas/core/di/providers.dart';
import 'package:derdiedas/core/localization/app_localizations.dart';
import 'package:derdiedas/core/notifications/notification_service.dart';
import 'package:derdiedas/data/datasources/article_local_ds.dart';
import 'package:derdiedas/domain/repositories/i_article_repository.dart';
import 'package:derdiedas/domain/repositories/i_auth_repository.dart';
import 'package:derdiedas/domain/repositories/i_settings_repository.dart';
import 'package:derdiedas/features/legal/providers/terms_consent_provider.dart';
import 'package:derdiedas/features/notifications/providers/notification_provider.dart';
import 'package:derdiedas/features/settings/providers/settings_provider.dart';
import 'package:derdiedas/features/settings/screens/settings_screen.dart';

class MockSettingsRepository extends Mock implements ISettingsRepository {}
class MockArticleRepository extends Mock implements IArticleRepository {}
class MockAuthRepository extends Mock implements IAuthRepository {}
class MockNotificationService extends Mock implements INotificationService {}
class MockArticleLocalDS extends Mock implements ArticleLocalDS {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockSettingsRepository mockSettingsRepo;
  late MockArticleRepository mockArticleRepo;
  late MockAuthRepository mockAuthRepo;
  late MockNotificationService mockNotificationService;
  late MockArticleLocalDS mockLocalDS;

  setUp(() {
    AppConfig.apiBaseUrl = 'http://127.0.0.1:8000';
    mockSettingsRepo = MockSettingsRepository();
    mockArticleRepo = MockArticleRepository();
    mockAuthRepo = MockAuthRepository();
    mockNotificationService = MockNotificationService();
    mockLocalDS = MockArticleLocalDS();

    when(() => mockSettingsRepo.getDarkMode()).thenReturn(false);
    when(() => mockSettingsRepo.getShowHints()).thenReturn(true);
    when(() => mockSettingsRepo.getLanguage()).thenReturn('en');
    when(() => mockSettingsRepo.setDarkMode(any())).thenAnswer((_) async {});
    when(() => mockSettingsRepo.setShowHints(any())).thenAnswer((_) async {});
    when(() => mockSettingsRepo.setLanguage(any())).thenAnswer((_) async {});
    when(() => mockArticleRepo.checkHealth()).thenAnswer((_) async => true);
    when(() => mockAuthRepo.currentUser).thenReturn(null);

    when(() => mockNotificationService.requestPermissions()).thenAnswer((_) async => true);
    when(() => mockNotificationService.scheduleDailyReminder(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          hour: any(named: 'hour'),
          minute: any(named: 'minute'),
        )).thenAnswer((_) async {});
    when(() => mockNotificationService.cancel(any())).thenAnswer((_) async {});

    when(() => mockLocalDS.getCachedCount()).thenAnswer((_) async => 25);
    when(() => mockLocalDS.preseedCoreVocabulary()).thenAnswer((_) async => 100);
    when(() => mockLocalDS.clearCache()).thenAnswer((_) async {});
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(mockSettingsRepo),
        articleRepositoryProvider.overrideWithValue(mockArticleRepo),
        authRepositoryProvider.overrideWithValue(mockAuthRepo),
        termsConsentProvider.overrideWith((_) => TermsConsentNotifier(true)),
        notificationServiceProvider.overrideWithValue(mockNotificationService),
        articleLocalDSProvider.overrideWithValue(mockLocalDS),
      ],
      child: Consumer(
        builder: (context, ref, child) {
          final locale = ref.watch(localeProvider);
          return MaterialApp(
            locale: locale,
            supportedLocales: AppLanguage.supportedLocales,
            localizationsDelegates: const [
              AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const Scaffold(
              body: SettingsScreen(),
            ),
          );
        },
      ),
    );
  }

  group('SettingsScreen Tests', () {
    testWidgets('renders language tile with initial language', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final languageTile = find.byKey(const Key('settings_language_tile'));
      expect(languageTile, findsOneWidget);
      expect(find.textContaining('English'), findsWidgets);
    });

    testWidgets('tapping language tile opens bottom sheet with all 4 languages',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final languageTile = find.byKey(const Key('settings_language_tile'));
      await tester.tap(languageTile);
      await tester.pumpAndSettle();

      // Bottom sheet header
      expect(find.text('Select Language'), findsOneWidget);

      // 4 language options
      expect(find.byKey(const Key('lang_option_en')), findsOneWidget);
      expect(find.byKey(const Key('lang_option_ar')), findsOneWidget);
      expect(find.byKey(const Key('lang_option_tr')), findsOneWidget);
      expect(find.byKey(const Key('lang_option_de')), findsOneWidget);

      expect(find.text('العربية'), findsOneWidget);
      expect(find.text('Türkçe'), findsOneWidget);
      expect(find.text('Deutsch'), findsOneWidget);
    });

    testWidgets('selecting Arabic switches locale and updates UI strings',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Open bottom sheet
      await tester.tap(find.byKey(const Key('settings_language_tile')));
      await tester.pumpAndSettle();

      // Tap Arabic option
      await tester.tap(find.byKey(const Key('lang_option_ar')));
      await tester.pumpAndSettle();

      // Repo should be called
      verify(() => mockSettingsRepo.setLanguage('ar')).called(1);

      // UI should now show Arabic headers
      expect(find.text('الحساب'), findsOneWidget); // Account
      expect(find.text('لغة التطبيق'), findsOneWidget); // App Language
    });

    testWidgets('tapping notifications tile opens NotificationSettingsSheet',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final notifTile = find.byKey(const Key('settings_notifications_tile'));
      expect(notifTile, findsOneWidget);
      await tester.tap(notifTile);
      await tester.pumpAndSettle();

      expect(find.text('Daily Reminders'), findsOneWidget);
      expect(find.byKey(const Key('notification_master_switch')), findsOneWidget);
    });

    testWidgets('tapping offline cache tile opens OfflineCacheSheet',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final cacheTile = find.byKey(const Key('settings_offline_cache_tile'));
      expect(cacheTile, findsOneWidget);
      await tester.ensureVisible(cacheTile);
      await tester.tap(cacheTile);
      await tester.pumpAndSettle();

      expect(find.text('Offline Article Cache'), findsNWidgets(2));
      expect(find.text('25 words'), findsOneWidget);
      expect(find.byKey(const Key('preseed_vocab_btn')), findsOneWidget);
    });
  });
}
