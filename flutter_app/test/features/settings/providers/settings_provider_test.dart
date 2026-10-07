import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:derdiedas/domain/repositories/i_settings_repository.dart';
import 'package:derdiedas/features/settings/providers/settings_provider.dart';

class MockSettingsRepository extends Mock implements ISettingsRepository {}

void main() {
  late MockSettingsRepository mockRepo;

  setUp(() {
    mockRepo = MockSettingsRepository();
    when(() => mockRepo.getDarkMode()).thenReturn(false);
    when(() => mockRepo.getShowHints()).thenReturn(true);
    when(() => mockRepo.getLanguage()).thenReturn('en');
    when(() => mockRepo.setDarkMode(any())).thenAnswer((_) async {});
    when(() => mockRepo.setShowHints(any())).thenAnswer((_) async {});
    when(() => mockRepo.setLanguage(any())).thenAnswer((_) async {});
  });

  group('SettingsNotifier', () {
    test('initializes with repository values', () {
      final notifier = SettingsNotifier(mockRepo);
      expect(notifier.state.isDarkMode, isFalse);
      expect(notifier.state.showHints, isTrue);
      expect(notifier.state.languageCode, 'en');
    });

    test('setLanguage updates state and calls repo', () async {
      final notifier = SettingsNotifier(mockRepo);

      await notifier.setLanguage('ar');
      expect(notifier.state.languageCode, 'ar');
      verify(() => mockRepo.setLanguage('ar')).called(1);

      await notifier.setLanguage('tr');
      expect(notifier.state.languageCode, 'tr');
      verify(() => mockRepo.setLanguage('tr')).called(1);

      await notifier.setLanguage('de');
      expect(notifier.state.languageCode, 'de');
      verify(() => mockRepo.setLanguage('de')).called(1);
    });

    test('toggleDarkMode toggles state and calls repo', () async {
      final notifier = SettingsNotifier(mockRepo);

      await notifier.toggleDarkMode();
      expect(notifier.state.isDarkMode, isTrue);
      verify(() => mockRepo.setDarkMode(true)).called(1);

      await notifier.toggleDarkMode();
      expect(notifier.state.isDarkMode, isFalse);
      verify(() => mockRepo.setDarkMode(false)).called(1);
    });

    test('setShowHints updates state and calls repo', () async {
      final notifier = SettingsNotifier(mockRepo);

      await notifier.setShowHints(false);
      expect(notifier.state.showHints, isFalse);
      verify(() => mockRepo.setShowHints(false)).called(1);
    });

    test('reload fetches latest state from repo', () {
      final notifier = SettingsNotifier(mockRepo);
      expect(notifier.state.languageCode, 'en');

      when(() => mockRepo.getLanguage()).thenReturn('ar');
      when(() => mockRepo.getDarkMode()).thenReturn(true);
      when(() => mockRepo.getShowHints()).thenReturn(false);

      notifier.reload();

      expect(notifier.state.languageCode, 'ar');
      expect(notifier.state.isDarkMode, isTrue);
      expect(notifier.state.showHints, isFalse);
    });
  });
}
