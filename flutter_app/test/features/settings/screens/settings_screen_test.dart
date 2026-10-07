import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:derdiedas/config/app_config.dart';
import 'package:derdiedas/core/di/providers.dart';
import 'package:derdiedas/core/localization/app_localizations.dart';
import 'package:derdiedas/domain/repositories/i_article_repository.dart';
import 'package:derdiedas/domain/repositories/i_auth_repository.dart';
import 'package:derdiedas/domain/repositories/i_settings_repository.dart';
import 'package:derdiedas/features/legal/providers/terms_consent_provider.dart';
import 'package:derdiedas/features/settings/providers/settings_provider.dart';
import 'package:derdiedas/features/settings/screens/settings_screen.dart';

class MockSettingsRepository extends Mock implements ISettingsRepository {}
class MockArticleRepository extends Mock implements IArticleRepository {}
class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late MockSettingsRepository mockSettingsRepo;
  late MockArticleRepository mockArticleRepo;
  late MockAuthRepository mockAuthRepo;

  setUp(() {
    AppConfig.apiBaseUrl = 'http://127.0.0.1:8000';
    mockSettingsRepo = MockSettingsRepository();
    mockArticleRepo = MockArticleRepository();
    mockAuthRepo = MockAuthRepository();

    when(() => mockSettingsRepo.getDarkMode()).thenReturn(false);
    when(() => mockSettingsRepo.getShowHints()).thenReturn(true);
    when(() => mockSettingsRepo.getLanguage()).thenReturn('en');
    when(() => mockSettingsRepo.setDarkMode(any())).thenAnswer((_) async {});
    when(() => mockSettingsRepo.setShowHints(any())).thenAnswer((_) async {});
    when(() => mockSettingsRepo.setLanguage(any())).thenAnswer((_) async {});
    when(() => mockArticleRepo.checkHealth()).thenAnswer((_) async => true);
    when(() => mockAuthRepo.currentUser).thenReturn(null);
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(mockSettingsRepo),
        articleRepositoryProvider.overrideWithValue(mockArticleRepo),
        authRepositoryProvider.overrideWithValue(mockAuthRepo),
        termsConsentProvider.overrideWith((_) => TermsConsentNotifier(true)),
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

  group('SettingsScreen Language Selection Tests', () {
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
  });
}
