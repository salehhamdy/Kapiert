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

  Widget createWidgetUnderTest({Locale locale = const Locale('en')}) {
    return ProviderScope(
      overrides: [
        favoritesRepositoryProvider.overrideWithValue(mockFavRepo),
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
        home: const Scaffold(
          body: SingleChildScrollView(
            child: ResultCard(word: testWord),
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
  });
}
