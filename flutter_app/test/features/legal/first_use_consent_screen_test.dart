import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:derdiedas/config/app_config.dart';
import 'package:derdiedas/features/legal/screens/first_use_consent_screen.dart';
import 'package:derdiedas/features/legal/screens/legal_document_screen.dart';
import 'package:derdiedas/features/legal/providers/terms_consent_provider.dart';

void main() {
  setUp(() {
    AppConfig.apiBaseUrl = 'http://127.0.0.1:8000';
  });

  testWidgets(
      'FirstUseConsentScreen renders welcome, commitments, and document tiles',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: FirstUseConsentScreen(),
        ),
      ),
    );

    expect(find.text('Welcome to Kapiert'), findsOneWidget);
    expect(find.text('German Article & Vocabulary Trainer'), findsOneWidget);
    expect(find.text('Privacy-First & Zero Ads'), findsOneWidget);
    expect(find.text('Local-First Storage'), findsOneWidget);
    expect(find.byKey(const Key('consent_open_terms_button')), findsOneWidget);
    expect(find.byKey(const Key('consent_open_privacy_button')), findsOneWidget);
    expect(find.byKey(const Key('consent_terms_checkbox')), findsOneWidget);
    expect(find.byKey(const Key('consent_agree_button')), findsOneWidget);
  });

  testWidgets(
      'FirstUseConsentScreen shows snackbar error if button tapped without checking box',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: FirstUseConsentScreen(),
        ),
      ),
    );

    // Tap Agree without checking box
    await tester.tap(find.byKey(const Key('consent_agree_button')));
    await tester.pump();

    expect(
      find.text('Please check the box to accept the Terms of Use and Privacy Policy.'),
      findsOneWidget,
    );
  });

  testWidgets(
      'FirstUseConsentScreen checking box and tapping Agree updates termsConsentProvider',
      (tester) async {
    final notifier = TermsConsentNotifier(false);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          termsConsentProvider.overrideWith((_) => notifier),
        ],
        child: const MaterialApp(
          home: FirstUseConsentScreen(),
        ),
      ),
    );

    expect(notifier.state, false);

    // Tap the checkbox
    await tester.tap(find.byKey(const Key('consent_terms_checkbox')));
    await tester.pump();

    // Tap Agree
    await tester.tap(find.byKey(const Key('consent_agree_button')));
    await tester.pumpAndSettle();

    expect(notifier.state, true);
  });

  testWidgets(
      'FirstUseConsentScreen document tiles navigate to LegalDocumentScreen',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: FirstUseConsentScreen(),
        ),
      ),
    );

    // Scroll down to ensure terms button is visible
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
    await tester.pumpAndSettle();

    // Tap Terms of Use tile
    await tester.tap(find.byKey(const Key('consent_open_terms_button')));
    await tester.pumpAndSettle();

    expect(find.byType(LegalDocumentScreen), findsOneWidget);
    expect(find.text('1. Acceptance of Terms'), findsOneWidget);

    // Go back
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    expect(find.byType(FirstUseConsentScreen), findsOneWidget);

    // Tap Privacy Policy tile
    await tester.tap(find.byKey(const Key('consent_open_privacy_button')));
    await tester.pumpAndSettle();

    expect(find.byType(LegalDocumentScreen), findsOneWidget);
    expect(find.text('1. Privacy-First Commitment'), findsOneWidget);
  });
}
