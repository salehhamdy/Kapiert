import 'package:flutter_test/flutter_test.dart';
import 'package:derdiedas/domain/models/auth_user.dart';
import 'package:derdiedas/features/profile/profile_format.dart';
import 'package:derdiedas/shared/utils/validators.dart';

void main() {
  group('AppUser', () {
    test('shownName falls back to email local part', () {
      const u = AppUser(id: '1', email: 'anna.schmidt@example.com');
      expect(u.shownName, 'anna.schmidt');
      expect(u.initials, 'A');
    });

    test('initials use first and last word of display name', () {
      const u = AppUser(
        id: '1',
        email: 'x@y.z',
        displayName: ' Anna  Maria Schmidt ',
      );
      expect(u.shownName, 'Anna  Maria Schmidt');
      expect(u.initials, 'AS');
    });
  });

  group('formatRelative', () {
    final now = DateTime(2026, 10, 5, 12);
    test('buckets', () {
      expect(
        formatRelative(now.subtract(const Duration(seconds: 10)), now: now),
        'just now',
      );
      expect(
        formatRelative(now.subtract(const Duration(minutes: 5)), now: now),
        '5 min ago',
      );
      expect(
        formatRelative(now.subtract(const Duration(hours: 3)), now: now),
        '3 h ago',
      );
      expect(
        formatRelative(now.subtract(const Duration(days: 1)), now: now),
        'yesterday',
      );
      expect(
        formatRelative(now.subtract(const Duration(days: 4)), now: now),
        '4 days ago',
      );
      expect(formatRelative(DateTime(2025, 1, 2), now: now), 'Jan 2025');
    });
  });

  test('providerLabel', () {
    expect(providerLabel('google'), 'Google');
    expect(providerLabel('email'), 'Email');
    expect(providerLabel('azure'), 'Azure');
  });

  test('displayName validator', () {
    expect(Validators.displayName('  '), isNotNull);
    expect(Validators.displayName('a' * 41), isNotNull);
    expect(Validators.displayName('Anna'), isNull);
  });
}
