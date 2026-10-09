import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:derdiedas/core/di/providers.dart';
import 'package:derdiedas/core/localization/app_localizations.dart';
import 'package:derdiedas/domain/models/lookup_history.dart';
import 'package:derdiedas/domain/models/word_model.dart';
import 'package:derdiedas/domain/repositories/i_article_repository.dart';
import 'package:derdiedas/domain/repositories/i_history_repository.dart';
import 'package:derdiedas/features/lookup/screens/grammar_rules_screen.dart';

class MockArticleRepository extends Mock implements IArticleRepository {}
class MockHistoryRepository extends Mock implements IHistoryRepository {}
class FakeLookupHistory extends Fake implements LookupHistory {}

void main() {
  late MockArticleRepository mockArticleRepo;
  late MockHistoryRepository mockHistoryRepo;

  setUpAll(() {
    registerFallbackValue(FakeLookupHistory());
  });

  setUp(() {
    mockArticleRepo = MockArticleRepository();
    mockHistoryRepo = MockHistoryRepository();

    when(() => mockHistoryRepo.getStreak()).thenReturn(0);
    when(() => mockHistoryRepo.getHistory()).thenAnswer((_) async => []);
    when(() => mockHistoryRepo.getStats()).thenAnswer((_) async => {});
  });

  Widget createWidgetUnderTest({
    Locale locale = const Locale('en'),
  }) {
    return ProviderScope(
      overrides: [
        articleRepositoryProvider.overrideWithValue(mockArticleRepo),
        historyRepositoryProvider.overrideWithValue(mockHistoryRepo),
      ],
      child: MaterialApp(
        locale: locale,
        supportedLocales: AppLanguage.supportedLocales,
        localizationsDelegates: const [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const GrammarRulesScreen(),
      ),
    );
  }

  group('GrammarRulesScreen Widget Tests', () {
    testWidgets('renders screen with header, search bar, filter tabs, and rules', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('grammar_rules_screen')), findsOneWidget);
      expect(find.byKey(const Key('grammar_rules_search_field')), findsOneWidget);
      expect(find.byKey(const Key('filter_all')), findsOneWidget);
      expect(find.byKey(const Key('filter_der')), findsOneWidget);
      expect(find.byKey(const Key('filter_die')), findsOneWidget);
      expect(find.byKey(const Key('filter_das')), findsOneWidget);

      expect(find.text('-ung'), findsOneWidget);
      expect(find.text('-heit'), findsOneWidget);
      expect(find.text('24/24'), findsOneWidget);
    });

    testWidgets('filters rules when tapping article filter pills', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap 'der' filter
      await tester.tap(find.byKey(const Key('filter_der')));
      await tester.pumpAndSettle();

      expect(find.text('-ismus'), findsOneWidget);
      expect(find.text('-ung'), findsNothing);
      expect(find.text('-chen'), findsNothing);

      // Tap 'die' filter
      await tester.tap(find.byKey(const Key('filter_die')));
      await tester.pumpAndSettle();

      expect(find.text('-ung'), findsOneWidget);
      expect(find.text('-ismus'), findsNothing);
      expect(find.text('-chen'), findsNothing);

      // Tap 'das' filter
      await tester.tap(find.byKey(const Key('filter_das')));
      await tester.pumpAndSettle();

      expect(find.text('-chen'), findsOneWidget);
      expect(find.text('-ung'), findsNothing);
      expect(find.text('-ismus'), findsNothing);

      // Tap 'All' filter
      await tester.tap(find.byKey(const Key('filter_all')));
      await tester.pumpAndSettle();

      expect(find.text('-ung'), findsOneWidget);
      expect(find.text('-heit'), findsOneWidget);
    });

    testWidgets('filters rules by search query in real time', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Search for 'chen'
      await tester.enterText(find.byKey(const Key('grammar_rules_search_field')), 'chen');
      await tester.pumpAndSettle();

      expect(find.text('-chen'), findsOneWidget);
      expect(find.text('-ung'), findsNothing);

      // Clear search via clear button
      expect(find.byKey(const Key('grammar_rules_clear_search_button')), findsOneWidget);
      await tester.tap(find.byKey(const Key('grammar_rules_clear_search_button')));
      await tester.pumpAndSettle();

      expect(find.text('-ung'), findsOneWidget);
      expect(find.text('-heit'), findsOneWidget);
    });

    testWidgets('shows empty state when search returns no matches', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('grammar_rules_search_field')),
        'zzxyznotfound',
      );
      await tester.pumpAndSettle();

      expect(find.text('No grammar rules match your search.'), findsOneWidget);
      expect(find.byIcon(Icons.search_off_rounded), findsOneWidget);
    });

    testWidgets('tapping an example triggers lookup and closes screen', (tester) async {
      when(() => mockArticleRepo.lookup('Zeitung')).thenAnswer(
        (_) async => const WordModel(
          word: 'Zeitung',
          article: 'die',
          gender: 'f',
          source: 'dataset',
        ),
      );
      when(() => mockHistoryRepo.updateStreak()).thenAnswer((_) async {});
      when(() => mockHistoryRepo.addEntry(any())).thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('example_chip_Zeitung')), findsOneWidget);
      await tester.tap(find.byKey(const Key('example_chip_Zeitung')));
      await tester.pumpAndSettle();

      verify(() => mockArticleRepo.lookup('Zeitung')).called(1);
    });

    testWidgets('renders localized content correctly in German and Arabic', (tester) async {
      // German
      await tester.pumpWidget(createWidgetUnderTest(locale: const Locale('de')));
      await tester.pumpAndSettle();

      expect(find.text('Grammatikregeln & Endungen'), findsOneWidget);
      expect(find.text('Endung oder Regel suchen (z. B. -ung, -chen)...'), findsOneWidget);

      // Arabic
      await tester.pumpWidget(createWidgetUnderTest(locale: const Locale('ar')));
      await tester.pumpAndSettle();

      expect(find.text('قواعد التذكير والتأنيث واللواحق'), findsOneWidget);
    });
  });
}
