import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:derdiedas/core/di/providers.dart';
import 'package:derdiedas/core/localization/app_localizations.dart';
import 'package:derdiedas/domain/repositories/i_auth_repository.dart';
import 'package:derdiedas/features/auth/screens/reset_password_screen.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepo;

  setUp(() {
    mockAuthRepo = MockAuthRepository();
    when(() => mockAuthRepo.currentUser).thenReturn(null);
    when(() => mockAuthRepo.isEnabled).thenReturn(true);
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockAuthRepo),
      ],
      child: const MaterialApp(
        localizationsDelegates: [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLanguage.supportedLocales,
        home: ResetPasswordScreen(),
      ),
    );
  }

  group('ResetPasswordScreen Widget Tests', () {
    testWidgets('renders reset password header and form controls', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Reset Password'), findsWidgets);
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.byKey(const Key('reset_password_submit_btn')), findsOneWidget);
      expect(find.byKey(const Key('reset_password_back_btn')), findsOneWidget);
    });

    testWidgets('submitting valid email calls resetPassword and shows success screen',
        (tester) async {
      when(() => mockAuthRepo.resetPassword(email: any(named: 'email')))
          .thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), 'learner@example.com');
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('reset_password_submit_btn')));
      await tester.pumpAndSettle();

      verify(() => mockAuthRepo.resetPassword(email: 'learner@example.com')).called(1);
      expect(find.byIcon(Icons.mark_email_read_rounded), findsOneWidget);
      expect(find.text('Password reset link sent to your email.'), findsOneWidget);
    });
  });
}
