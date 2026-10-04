import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:derdiedas/features/auth/screens/verify_email_screen.dart';
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
    testWidgets('renders VerifyEmailScreen without focus assertion errors', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(email: 'salehhamdy599@gmail.com'));
      await tester.pumpAndSettle();

      // Heading and email address displayed
      expect(find.text('Check your email'), findsOneWidget);
      expect(
        find.byWidgetPredicate((widget) =>
            widget is RichText &&
            widget.text.toPlainText().contains('salehhamdy599@gmail.com')),
        findsOneWidget,
      );

      // Exactly 6 OTP input text fields
      expect(find.byType(TextFormField), findsNWidgets(6));

      // Verify button present
      expect(find.text('Verify email'), findsOneWidget);
    });

    testWidgets('typing a 6-digit code enables verify button and triggers verifyOTP', (tester) async {
      when(() => mockAuthRepo.verifyOTP(
            email: 'user@example.com',
            token: '123456',
          )).thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetUnderTest(email: 'user@example.com'));
      await tester.pumpAndSettle();

      final textFields = find.byType(TextFormField);

      // Type digits into each field
      for (int i = 0; i < 6; i++) {
        await tester.enterText(textFields.at(i), '${i + 1}');
        await tester.pump();
      }

      await tester.pumpAndSettle();

      verify(() => mockAuthRepo.verifyOTP(
            email: 'user@example.com',
            token: '123456',
          )).called(1);
    });

    testWidgets('pasting full 6-digit code fills all boxes', (tester) async {
      when(() => mockAuthRepo.verifyOTP(
            email: 'user@example.com',
            token: '654321',
          )).thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetUnderTest(email: 'user@example.com'));
      await tester.pumpAndSettle();

      final firstField = find.byType(TextFormField).first;
      await tester.enterText(firstField, '654321');
      await tester.pumpAndSettle();

      verify(() => mockAuthRepo.verifyOTP(
            email: 'user@example.com',
            token: '654321',
          )).called(1);
    });

    testWidgets('shows friendly error message when verification fails', (tester) async {
      when(() => mockAuthRepo.verifyOTP(
            email: 'user@example.com',
            token: '000000',
          )).thenThrow(Exception('Token is invalid'));

      await tester.pumpWidget(createWidgetUnderTest(email: 'user@example.com'));
      await tester.pumpAndSettle();

      final firstField = find.byType(TextFormField).first;
      await tester.enterText(firstField, '000000');
      await tester.pumpAndSettle();

      expect(find.text('Incorrect code. Check your email and try again.'), findsOneWidget);
    });
  });
}
