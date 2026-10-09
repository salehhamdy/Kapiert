import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:derdiedas/core/localization/app_localizations.dart';
import 'package:derdiedas/features/quiz/providers/suffix_quiz_provider.dart';
import 'package:derdiedas/features/quiz/screens/suffix_quiz_screen.dart';

void main() {
  Widget createWidgetUnderTest({
    Locale locale = const Locale('en'),
    SuffixQuizNotifier? notifier,
  }) {
    return ProviderScope(
      overrides: [
        if (notifier != null)
          suffixQuizProvider.overrideWith((ref) => notifier),
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
        home: const SuffixQuizScreen(),
      ),
    );
  }

  group('SuffixQuizScreen Widget Tests', () {
    testWidgets('renders screen with header, question target, and article buttons', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('suffix_quiz_screen')), findsOneWidget);
      expect(find.text('Suffix Rules Quiz'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.byKey(const Key('suffix_button_der')), findsOneWidget);
      expect(find.byKey(const Key('suffix_button_die')), findsOneWidget);
      expect(find.byKey(const Key('suffix_button_das')), findsOneWidget);
    });

    testWidgets('answering shows feedback card with rule explanation and next button', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap 'die' button
      await tester.tap(find.byKey(const Key('suffix_button_die')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('suffix_quiz_feedback_card')), findsOneWidget);
      expect(find.byKey(const Key('suffix_quiz_next_button')), findsOneWidget);
    });

    testWidgets('tapping next button advances question and clears feedback', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Answer first question
      await tester.tap(find.byKey(const Key('suffix_button_die')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('suffix_quiz_next_button')), findsOneWidget);

      // Tap Next
      await tester.tap(find.byKey(const Key('suffix_quiz_next_button')));
      await tester.pumpAndSettle();

      // Next question is presented, feedback card is dismissed
      expect(find.byKey(const Key('suffix_quiz_feedback_card')), findsNothing);
      expect(find.byKey(const Key('suffix_quiz_next_button')), findsNothing);
    });

    testWidgets('round completion displays celebration screen and allows restart', (tester) async {
      final customNotifier = SuffixQuizNotifier(random: Random(42));
      customNotifier.startRound(length: 1); // 1-question round

      await tester.pumpWidget(createWidgetUnderTest(notifier: customNotifier));
      await tester.pumpAndSettle();

      // Answer the single question
      final correctArticle = customNotifier.state.currentQuestion!.correctArticle;
      await tester.tap(find.byKey(Key('suffix_button_$correctArticle')));
      await tester.pumpAndSettle();

      // Tap complete
      await tester.tap(find.byKey(const Key('suffix_quiz_next_button')));
      await tester.pumpAndSettle();

      expect(find.text('Round Complete!'), findsOneWidget);
      expect(find.byKey(const Key('suffix_quiz_restart_button')), findsOneWidget);
      expect(find.byKey(const Key('suffix_quiz_review_button')), findsOneWidget);

      // Tap restart
      await tester.tap(find.byKey(const Key('suffix_quiz_restart_button')));
      await tester.pumpAndSettle();

      // Re-enters quiz mode
      expect(find.byKey(const Key('suffix_button_der')), findsOneWidget);
      expect(find.text('Round Complete!'), findsNothing);
    });

    testWidgets('renders localized content in German and Arabic', (tester) async {
      // German
      await tester.pumpWidget(createWidgetUnderTest(locale: const Locale('de')));
      await tester.pumpAndSettle();

      expect(find.text('Endungs-Quiz'), findsOneWidget);

      // Arabic
      await tester.pumpWidget(createWidgetUnderTest(locale: const Locale('ar')));
      await tester.pumpAndSettle();

      expect(find.text('اختبار قواعد اللواحق'), findsOneWidget);
    });
  });
}
