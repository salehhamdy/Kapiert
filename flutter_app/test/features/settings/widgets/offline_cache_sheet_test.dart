import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:derdiedas/core/di/providers.dart';
import 'package:derdiedas/core/localization/app_localizations.dart';
import 'package:derdiedas/data/datasources/article_local_ds.dart';
import 'package:derdiedas/features/settings/widgets/offline_cache_sheet.dart';

class MockArticleLocalDS extends Mock implements ArticleLocalDS {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockArticleLocalDS mockLocalDS;

  setUp(() {
    mockLocalDS = MockArticleLocalDS();
    when(() => mockLocalDS.getCachedCount()).thenAnswer((_) async => 42);
    when(() => mockLocalDS.preseedCoreVocabulary()).thenAnswer((_) async => 100);
    when(() => mockLocalDS.clearCache()).thenAnswer((_) async {});
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        articleLocalDSProvider.overrideWithValue(mockLocalDS),
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
          body: OfflineCacheSheet(),
        ),
      ),
    );
  }

  group('OfflineCacheSheet Widget Tests', () {
    testWidgets('renders title, article count, and action buttons', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Offline Article Cache'), findsOneWidget);
      expect(find.text('42 words'), findsOneWidget);
      expect(find.byKey(const Key('preseed_vocab_btn')), findsOneWidget);
      expect(find.byKey(const Key('clear_offline_cache_btn')), findsOneWidget);
    });

    testWidgets('tapping pre-seed button calls localDS and displays SnackBar',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('preseed_vocab_btn')));
      await tester.pumpAndSettle();

      verify(() => mockLocalDS.preseedCoreVocabulary()).called(1);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text('Essential offline vocabulary loaded successfully!'),
        findsOneWidget,
      );
    });

    testWidgets('tapping clear cache button calls localDS and displays SnackBar',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('clear_offline_cache_btn')));
      await tester.pumpAndSettle();

      verify(() => mockLocalDS.clearCache()).called(1);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Offline cache cleared.'), findsOneWidget);
    });
  });
}
