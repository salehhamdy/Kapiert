import 'package:flutter/material.dart' show TimeOfDay;

/// Domain model representing user preferences for push notifications and reminders.
class NotificationSettings {
  const NotificationSettings({
    this.enabled = false,
    this.hour = 19,
    this.minute = 0,
    this.streakAlerts = true,
    this.srsAlerts = true,
  });

  /// Whether daily practice reminders are active.
  final bool enabled;

  /// Hour of the day for the daily reminder (0-23, default 19 = 7:00 PM).
  final int hour;

  /// Minute of the hour for the daily reminder (0-59, default 0).
  final int minute;

  /// Whether to send streak protection warnings if not practiced yet today.
  final bool streakAlerts;

  /// Whether to notify when spaced repetition cards become due for review.
  final bool srsAlerts;

  /// Returns [TimeOfDay] representation of the reminder time.
  TimeOfDay get reminderTime => TimeOfDay(hour: hour, minute: minute);

  /// Creates a copy with the given fields replaced by new values.
  NotificationSettings copyWith({
    bool? enabled,
    int? hour,
    int? minute,
    bool? streakAlerts,
    bool? srsAlerts,
  }) {
    return NotificationSettings(
      enabled: enabled ?? this.enabled,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      streakAlerts: streakAlerts ?? this.streakAlerts,
      srsAlerts: srsAlerts ?? this.srsAlerts,
    );
  }

  /// Serializes settings to JSON map.
  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'hour': hour,
        'minute': minute,
        'streakAlerts': streakAlerts,
        'srsAlerts': srsAlerts,
      };

  /// Deserializes settings from JSON map.
  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      enabled: json['enabled'] as bool? ?? false,
      hour: json['hour'] as int? ?? 19,
      minute: json['minute'] as int? ?? 0,
      streakAlerts: json['streakAlerts'] as bool? ?? true,
      srsAlerts: json['srsAlerts'] as bool? ?? true,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationSettings &&
          runtimeType == other.runtimeType &&
          enabled == other.enabled &&
          hour == other.hour &&
          minute == other.minute &&
          streakAlerts == other.streakAlerts &&
          srsAlerts == other.srsAlerts;

  @override
  int get hashCode =>
      Object.hash(enabled, hour, minute, streakAlerts, srsAlerts);
}
