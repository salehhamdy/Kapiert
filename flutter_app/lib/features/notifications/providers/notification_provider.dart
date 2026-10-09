import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../core/storage/storage_service.dart';
import '../../../domain/models/notification_settings.dart';

/// Provider for notification service abstraction.
final notificationServiceProvider = Provider<INotificationService>((ref) {
  final service = NotificationService();
  service.init();
  return service;
});

/// Provider for user notification preferences and scheduler.
final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationSettings>((ref) {
  final service = ref.watch(notificationServiceProvider);
  return NotificationNotifier(service);
});

class NotificationNotifier extends StateNotifier<NotificationSettings> {
  NotificationNotifier(this._service)
      : super(StorageService.getNotificationSettings()) {
    // Re-sync schedule upon app startup if enabled
    if (state.enabled) {
      _schedule(state);
    }
  }

  final INotificationService _service;
  static const int dailyReminderId = 1001;
  static const int testNotificationId = 9999;

  /// Toggles daily practice reminders on or off.
  Future<void> toggleEnabled() async {
    final next = state.copyWith(enabled: !state.enabled);
    await _updateSettings(next);
  }

  /// Updates the scheduled reminder time.
  Future<void> setReminderTime(TimeOfDay time) async {
    final next = state.copyWith(hour: time.hour, minute: time.minute);
    await _updateSettings(next);
  }

  /// Toggles streak protection alerts.
  Future<void> toggleStreakAlerts() async {
    final next = state.copyWith(streakAlerts: !state.streakAlerts);
    await _updateSettings(next);
  }

  /// Toggles spaced repetition due alerts.
  Future<void> toggleSrsAlerts() async {
    final next = state.copyWith(srsAlerts: !state.srsAlerts);
    await _updateSettings(next);
  }

  /// Sends an immediate test notification to verify device notifications.
  Future<bool> sendTestNotification(AppLocalizations l10n) async {
    await _service.requestPermissions();
    await _service.showInstantNotification(
      id: testNotificationId,
      title: 'Kapiert! 🇩🇪',
      body: l10n.testNotificationSent,
    );
    return true;
  }

  Future<void> _updateSettings(NotificationSettings newSettings) async {
    state = newSettings;
    await StorageService.setNotificationSettings(newSettings);

    if (newSettings.enabled) {
      await _service.requestPermissions();
      await _schedule(newSettings);
    } else {
      await _service.cancel(dailyReminderId);
    }
  }

  Future<void> _schedule(NotificationSettings settings) async {
    await _service.scheduleDailyReminder(
      id: dailyReminderId,
      title: 'Zeit für Deutsch! 🇩🇪',
      body: 'Keep your German streak going! Practice articles for 5 minutes.',
      hour: settings.hour,
      minute: settings.minute,
    );
  }
}
