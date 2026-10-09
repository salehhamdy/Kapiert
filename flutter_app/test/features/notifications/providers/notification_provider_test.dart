import 'package:flutter/material.dart' show Locale, TimeOfDay;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:derdiedas/core/localization/app_localizations.dart';
import 'package:derdiedas/core/notifications/notification_service.dart';
import 'package:derdiedas/features/notifications/providers/notification_provider.dart';

class MockNotificationService extends Mock implements INotificationService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockNotificationService mockService;
  late NotificationNotifier notifier;

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

    notifier = NotificationNotifier(mockService);
  });

  group('NotificationNotifier Tests', () {
    test('initial state has default configuration', () {
      expect(notifier.state.hour, equals(19));
      expect(notifier.state.minute, equals(0));
      expect(notifier.state.streakAlerts, isTrue);
      expect(notifier.state.srsAlerts, isTrue);
    });

    test('toggleEnabled enables reminders and schedules notification', () async {
      // Act
      await notifier.toggleEnabled();

      // Assert
      expect(notifier.state.enabled, isTrue);
      verify(() => mockService.requestPermissions()).called(1);
      verify(() => mockService.scheduleDailyReminder(
            id: NotificationNotifier.dailyReminderId,
            title: any(named: 'title'),
            body: any(named: 'body'),
            hour: 19,
            minute: 0,
          )).called(1);
    });

    test('toggleEnabled disables reminders and cancels scheduled notification', () async {
      // Arrange - first enable
      await notifier.toggleEnabled();
      clearInteractions(mockService);

      // Act - disable
      await notifier.toggleEnabled();

      // Assert
      expect(notifier.state.enabled, isFalse);
      verify(() => mockService.cancel(NotificationNotifier.dailyReminderId)).called(1);
    });

    test('setReminderTime updates reminder hour and minute', () async {
      // Act
      await notifier.setReminderTime(const TimeOfDay(hour: 8, minute: 30));

      // Assert
      expect(notifier.state.hour, equals(8));
      expect(notifier.state.minute, equals(30));
    });

    test('toggleStreakAlerts toggles streakAlerts flag', () async {
      expect(notifier.state.streakAlerts, isTrue);
      await notifier.toggleStreakAlerts();
      expect(notifier.state.streakAlerts, isFalse);
      await notifier.toggleStreakAlerts();
      expect(notifier.state.streakAlerts, isTrue);
    });

    test('toggleSrsAlerts toggles srsAlerts flag', () async {
      expect(notifier.state.srsAlerts, isTrue);
      await notifier.toggleSrsAlerts();
      expect(notifier.state.srsAlerts, isFalse);
      await notifier.toggleSrsAlerts();
      expect(notifier.state.srsAlerts, isTrue);
    });

    test('sendTestNotification requests permission and sends test notification', () async {
      final l10n = AppLocalizations(const Locale('en'));
      final result = await notifier.sendTestNotification(l10n);

      expect(result, isTrue);
      verify(() => mockService.requestPermissions()).called(1);
      verify(() => mockService.showInstantNotification(
            id: NotificationNotifier.testNotificationId,
            title: any(named: 'title'),
            body: any(named: 'body'),
          )).called(1);
    });
  });
}
