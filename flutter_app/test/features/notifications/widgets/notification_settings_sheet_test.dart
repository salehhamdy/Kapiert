import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:derdiedas/core/localization/app_localizations.dart';
import 'package:derdiedas/core/notifications/notification_service.dart';
import 'package:derdiedas/features/notifications/providers/notification_provider.dart';
import 'package:derdiedas/features/notifications/widgets/notification_settings_sheet.dart';

class MockNotificationService extends Mock implements INotificationService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockNotificationService mockService;

  setUp(() {
    mockService = MockNotificationService();
    when(() => mockService.requestPermissions()).thenAnswer((_) async => true);
    when(() => mockService.scheduleDailyReminder(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          hour: any(named: 'hour'),
          minute: any(named: 'minute'),
        )).thenAnswer((_) async {});
    when(() => mockService.showInstantNotification(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
        )).thenAnswer((_) async {});
    when(() => mockService.cancel(any())).thenAnswer((_) async {});
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        notificationServiceProvider.overrideWithValue(mockService),
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
          body: NotificationSettingsSheet(),
        ),
      ),
    );
  }

  group('NotificationSettingsSheet Widget Tests', () {
    testWidgets('renders header and master switch initially', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Daily Reminders'), findsOneWidget);
      expect(find.byKey(const Key('notification_master_switch')), findsOneWidget);
    });

    testWidgets('enabling master switch reveals reminder controls', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap master switch to enable
      await tester.tap(find.byKey(const Key('notification_master_switch')));
      await tester.pumpAndSettle();

      // Now reminder time and alert switches should appear
      expect(find.byKey(const Key('notification_time_tile')), findsOneWidget);
      expect(find.byKey(const Key('notification_streak_switch')), findsOneWidget);
      expect(find.byKey(const Key('notification_srs_switch')), findsOneWidget);
      expect(find.byKey(const Key('send_test_notification_btn')), findsOneWidget);
    });

    testWidgets('tapping test notification button calls service and shows SnackBar',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Enable reminders
      await tester.tap(find.byKey(const Key('notification_master_switch')));
      await tester.pumpAndSettle();

      // Tap test button
      await tester.tap(find.byKey(const Key('send_test_notification_btn')));
      await tester.pumpAndSettle();

      verify(() => mockService.showInstantNotification(
            id: NotificationNotifier.testNotificationId,
            title: any(named: 'title'),
            body: any(named: 'body'),
          )).called(1);

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Test notification sent!'), findsOneWidget);
    });
  });
}
