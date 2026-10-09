import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_test/flutter_test.dart';
import 'package:derdiedas/domain/models/notification_settings.dart';

void main() {
  group('NotificationSettings', () {
    test('default constructor creates expected default values', () {
      const settings = NotificationSettings();

      expect(settings.enabled, isFalse);
      expect(settings.hour, equals(19));
      expect(settings.minute, equals(0));
      expect(settings.streakAlerts, isTrue);
      expect(settings.srsAlerts, isTrue);
      expect(settings.reminderTime, equals(const TimeOfDay(hour: 19, minute: 0)));
    });

    test('copyWith updates specified fields only', () {
      const original = NotificationSettings();
      final updated = original.copyWith(
        enabled: true,
        hour: 20,
        minute: 30,
        streakAlerts: false,
        srsAlerts: false,
      );

      expect(updated.enabled, isTrue);
      expect(updated.hour, equals(20));
      expect(updated.minute, equals(30));
      expect(updated.streakAlerts, isFalse);
      expect(updated.srsAlerts, isFalse);
      expect(updated.reminderTime, equals(const TimeOfDay(hour: 20, minute: 30)));
    });

    test('toJson and fromJson serialize and deserialize symmetrically', () {
      const settings = NotificationSettings(
        enabled: true,
        hour: 8,
        minute: 15,
        streakAlerts: false,
        srsAlerts: true,
      );

      final json = settings.toJson();
      expect(json, equals({
        'enabled': true,
        'hour': 8,
        'minute': 15,
        'streakAlerts': false,
        'srsAlerts': true,
      }));

      final fromJson = NotificationSettings.fromJson(json);
      expect(fromJson, equals(settings));
    });

    test('fromJson handles empty or partial JSON gracefully with defaults', () {
      final settings = NotificationSettings.fromJson(const {});

      expect(settings.enabled, isFalse);
      expect(settings.hour, equals(19));
      expect(settings.minute, equals(0));
      expect(settings.streakAlerts, isTrue);
      expect(settings.srsAlerts, isTrue);
    });

    test('equality and hashCode work properly', () {
      const s1 = NotificationSettings(enabled: true, hour: 10, minute: 45);
      const s2 = NotificationSettings(enabled: true, hour: 10, minute: 45);
      const s3 = NotificationSettings(enabled: false, hour: 10, minute: 45);

      expect(s1, equals(s2));
      expect(s1.hashCode, equals(s2.hashCode));
      expect(s1, isNot(equals(s3)));
    });
  });
}
