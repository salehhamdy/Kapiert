import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:derdiedas/features/auth/screens/verify_email_screen.dart';
import 'package:derdiedas/features/auth/screens/welcome_screen.dart';
import 'package:derdiedas/domain/repositories/i_auth_repository.dart';
import 'package:derdiedas/core/di/providers.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepo;

  setUp(() {
    mockAuthRepo = MockAuthRepository();
    when(() => mockAuthRepo.currentUser).thenReturn(null);
    when(() => mockAuthRepo.isEnabled).thenReturn(true);
  });

  Widget createWidgetUnderTest({String email = 'user@example.com'}) {
    return ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockAuthRepo),
      ],
      child: MaterialApp(
        home: VerifyEmailScreen(email: email),
      ),
    );
  }

  group('VerifyEmailScreen Widget Tests', () {
    testWidgets('renders VerifyEmailScreen with 8 OTP input boxes', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(email: 'user@example.com'));
      await tester.pumpAndSettle();

      // Heading and email address displayed
      expect(find.text('Check your email'), findsOneWidget);
      expect(
        find.byWidgetPredicate((widget) =>
            widget is RichText &&
            widget.text.toPlainText().contains('user@example.com') &&
            widget.text.toPlainText().contains('8-digit')),
        findsOneWidget,
      );

      // Exactly 8 OTP input text fields
      expect(find.byType(TextFormField), findsNWidgets(8));

      // No toggle button present
      expect(find.textContaining('Switch to'), findsNothing);

      // Verify button present
      expect(find.text('Verify email'), findsOneWidget);
    });

    testWidgets('typing an 8-digit code enables verify button and triggers verifyOTP', (tester) async {
      when(() => mockAuthRepo.verifyOTP(
            email: 'user@example.com',
            token: '12345678',
          )).thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetUnderTest(email: 'user@example.com'));
      await tester.pumpAndSettle();

      final textFields = find.byType(TextFormField);

      // Type digits into each of the 8 fields
      for (int i = 0; i < 8; i++) {
        await tester.enterText(textFields.at(i), '${i + 1}');
        await tester.pump();
      }

      await tester.pumpAndSettle();

      verify(() => mockAuthRepo.verifyOTP(
            email: 'user@example.com',
            token: '12345678',
          )).called(1);
    });

    testWidgets('pasting full 8-digit code fills all boxes and triggers verifyOTP', (tester) async {
      when(() => mockAuthRepo.verifyOTP(
            email: 'user@example.com',
            token: '16623998',
          )).thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetUnderTest(email: 'user@example.com'));
      await tester.pumpAndSettle();

      final firstField = find.byType(TextFormField).first;
      await tester.enterText(firstField, '16623998');
      await tester.pumpAndSettle();

      verify(() => mockAuthRepo.verifyOTP(
            email: 'user@example.com',
            token: '16623998',
          )).called(1);
      expect(find.byType(WelcomeScreen), findsOneWidget);
    });

    testWidgets('shows friendly error message when verification fails', (tester) async {
      when(() => mockAuthRepo.verifyOTP(
            email: 'user@example.com',
            token: '00000000',
          )).thenThrow(Exception('Token is invalid'));

      await tester.pumpWidget(createWidgetUnderTest(email: 'user@example.com'));
      await tester.pumpAndSettle();

      final firstField = find.byType(TextFormField).first;
      await tester.enterText(firstField, '00000000');
      await tester.pumpAndSettle();

      expect(find.text('Incorrect code. Check your email and try again.'), findsOneWidget);
    });

    testWidgets('tapping Resend code triggers resendOTP and enters cooldown', (tester) async {
      when(() => mockAuthRepo.resendOTP(email: 'user@example.com'))
          .thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetUnderTest(email: 'user@example.com'));
      await tester.pumpAndSettle();

      expect(find.text('Resend code'), findsOneWidget);
      await tester.tap(find.text('Resend code'));
      await tester.pump();

      verify(() => mockAuthRepo.resendOTP(email: 'user@example.com')).called(1);
      expect(find.textContaining('A new verification code was sent'), findsOneWidget);
      expect(find.textContaining('Resend code ('), findsOneWidget);
    });

    testWidgets('tapping Resend code when rate limited displays rate limit message', (tester) async {
      when(() => mockAuthRepo.resendOTP(email: 'user@example.com'))
          .thenThrow(Exception('over_email_send_rate_limit: 429'));

      await tester.pumpWidget(createWidgetUnderTest(email: 'user@example.com'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Resend code'));
      await tester.pump();

      expect(find.textContaining('Too many requests'), findsOneWidget);
    });
  });
}
