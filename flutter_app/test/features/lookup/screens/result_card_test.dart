import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:derdiedas/core/di/providers.dart';
import 'package:derdiedas/core/localization/app_localizations.dart';
import 'package:derdiedas/domain/models/example_sentence.dart';
import 'package:derdiedas/domain/models/word_model.dart';
import 'package:derdiedas/domain/repositories/i_favorites_repository.dart';
import 'package:derdiedas/features/lookup/screens/result_card.dart';
import 'package:derdiedas/features/settings/providers/settings_provider.dart';

class MockFavoritesRepository extends Mock implements IFavoritesRepository {}

void main() {
  late MockFavoritesRepository mockFavRepo;

  setUp(() {
    mockFavRepo = MockFavoritesRepository();
    when(() => mockFavRepo.getFavorites()).thenAnswer((_) async => []);
    when(() => mockFavRepo.isFavorite(any())).thenAnswer((_) async => false);
  });

  const testWord = WordModel(
    word: 'Buch',
    article: 'das',
    gender: 'n',
    source: 'dataset',
    plural: 'Bücher',
    translation: 'book',
    exampleSentence: ExampleSentence(
      german: 'Das Buch liegt auf dem Tisch.',
      english: 'The book is on the table.',
      arabic: 'الكتاب موجود على الطاولة.',
      turkish: 'Kitap masanın üstünde duruyor.',
    ),
  );

  Widget createWidgetUnderTest({
    Locale locale = const Locale('en'),
    WordModel word = testWord,
    bool showHints = true,
  }) {
    return ProviderScope(
      overrides: [
        favoritesRepositoryProvider.overrideWithValue(mockFavRepo),
        showHintsProvider.overrideWithValue(showHints),
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
        home: Scaffold(
          body: SingleChildScrollView(
            child: ResultCard(word: word),
          ),
        ),
      ),
    );
  }

  group('ResultCard with ExampleSentence Widget Tests', () {
    testWidgets('renders article, word, translation, and example sentence in English',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(locale: const Locale('en')));
      await tester.pumpAndSettle();

      expect(find.text('das'), findsOneWidget);
      expect(find.text('Buch'), findsOneWidget);
      expect(find.text('book'), findsOneWidget);

      // Example sentence container
      expect(find.byKey(const Key('example_sentence_card')), findsOneWidget);
      expect(find.text('Example in context'), findsOneWidget);
      expect(find.text('Das Buch liegt auf dem Tisch.'), findsOneWidget);
      expect(find.text('The book is on the table.'), findsOneWidget);
    });

    testWidgets('renders Arabic translation in Arabic locale', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(locale: const Locale('ar')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('example_sentence_card')), findsOneWidget);
      expect(find.text('مثال في سياق الجملة'), findsOneWidget);
      expect(find.text('Das Buch liegt auf dem Tisch.'), findsOneWidget);
      expect(find.text('الكتاب موجود على الطاولة.'), findsOneWidget);
    });

    testWidgets('renders Turkish translation in Turkish locale', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(locale: const Locale('tr')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('example_sentence_card')), findsOneWidget);
      expect(find.text('Cümle içinde kullanım'), findsOneWidget);
      expect(find.text('Das Buch liegt auf dem Tisch.'), findsOneWidget);
      expect(find.text('Kitap masanın üstünde duruyor.'), findsOneWidget);
    });

    testWidgets('copy button shows confirmation snackbar on press', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(locale: const Locale('en')));
      await tester.pumpAndSettle();

      final copyBtn = find.byKey(const Key('copy_sentence_button'));
      expect(copyBtn, findsOneWidget);

      await tester.tap(copyBtn);
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Example sentence copied to clipboard!'), findsOneWidget);
    });

    testWidgets('renders offline cache badge and icon when source is offline_cache',
        (tester) async {
      const offlineWord = WordModel(
        word: 'Tisch',
        article: 'der',
        gender: 'm',
        source: 'offline_cache',
      );

      await tester.pumpWidget(createWidgetUnderTest(word: offlineWord));
      await tester.pumpAndSettle();

      expect(find.text('offline cache'), findsOneWidget);
      expect(find.byIcon(Icons.offline_pin_rounded), findsOneWidget);
    });

    testWidgets('hides example sentence and grammar hints when showHints is false',
        (tester) async {
      const zeitungWord = WordModel(
        word: 'Zeitung',
        article: 'die',
        gender: 'f',
        source: 'dataset',
        plural: 'Zeitungen',
        translation: 'newspaper',
        exampleSentence: ExampleSentence(
          german: 'Ich lese die Zeitung jeden Morgen.',
          english: 'I read the newspaper every morning.',
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest(
        word: zeitungWord,
        showHints: false,
      ));
      await tester.pumpAndSettle();

      // Core word details remain visible
      expect(find.text('die'), findsOneWidget);
      expect(find.text('Zeitung'), findsOneWidget);
      expect(find.text('newspaper'), findsOneWidget);
      expect(find.text('pl. Zeitungen'), findsOneWidget);

      // Extra hints and explanations are hidden
      expect(find.byKey(const Key('example_sentence_card')), findsNothing);
      expect(find.byKey(const Key('grammar_rule_hint')), findsNothing);
      expect(find.text('Ich lese die Zeitung jeden Morgen.'), findsNothing);
    });

    testWidgets('shows grammar rule hint when showHints is true and word matches rule',
        (tester) async {
      const zeitungWord = WordModel(
        word: 'Zeitung',
        article: 'die',
        gender: 'f',
        source: 'dataset',
        plural: 'Zeitungen',
        translation: 'newspaper',
        exampleSentence: ExampleSentence(
          german: 'Ich lese die Zeitung jeden Morgen.',
          english: 'I read the newspaper every morning.',
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest(
        word: zeitungWord,
        showHints: true,
      ));
      await tester.pumpAndSettle();

      // Both grammar hint and example sentence are visible
      expect(find.byKey(const Key('grammar_rule_hint')), findsOneWidget);
      expect(find.text('Grammar Hint'), findsOneWidget);
      expect(find.text("Nouns ending in '-ung' are feminine (die)."), findsOneWidget);
      expect(find.byKey(const Key('example_sentence_card')), findsOneWidget);
    });
  });
}

