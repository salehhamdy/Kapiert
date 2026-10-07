import 'package:flutter/material.dart' show Locale;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../domain/repositories/i_settings_repository.dart';
import '../../sync/providers/sync_provider.dart';

// ---------------------------------------------------------------------------
// Settings state
// ---------------------------------------------------------------------------

class SettingsState {
  const SettingsState({
    this.isDarkMode = false,
    this.showHints = true,
    this.languageCode = 'en',
  });

  final bool isDarkMode;
  final bool showHints;
  final String languageCode;

  SettingsState copyWith({
    bool? isDarkMode,
    bool? showHints,
    String? languageCode,
  }) {
    return SettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      showHints: showHints ?? this.showHints,
      languageCode: languageCode ?? this.languageCode,
    );
  }
}

// ---------------------------------------------------------------------------
// Settings notifier
// ---------------------------------------------------------------------------

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier(this._repo)
      : super(SettingsState(
          isDarkMode: _repo.getDarkMode(),
          showHints: _repo.getShowHints(),
          languageCode: _getSafeLanguage(_repo),
        ));

  final ISettingsRepository _repo;

  static String _getSafeLanguage(ISettingsRepository repo) {
    try {
      final dynamic lang = (repo as dynamic).getLanguage();
      if (lang is String && lang.isNotEmpty) return lang;
    } catch (_) {}
    return 'en';
  }

  Future<void> toggleDarkMode() async {
    final next = !state.isDarkMode;
    state = state.copyWith(isDarkMode: next);
    await _repo.setDarkMode(next);
  }

  Future<void> setShowHints(bool value) async {
    state = state.copyWith(showHints: value);
    await _repo.setShowHints(value);
  }

  Future<void> setLanguage(String code) async {
    state = state.copyWith(languageCode: code);
    await _repo.setLanguage(code);
  }

  /// Re-read settings from storage (e.g. after cloud sync applied changes).
  void reload() {
    state = SettingsState(
      isDarkMode: _repo.getDarkMode(),
      showHints: _repo.getShowHints(),
      languageCode: _getSafeLanguage(_repo),
    );
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  final notifier = SettingsNotifier(ref.watch(settingsRepositoryProvider));
  ref.listen<int>(syncRevisionProvider, (_, _) => notifier.reload());
  return notifier;
});

/// Convenience derived provider for theme - used by [MaterialApp.themeMode].
final themeProvider = Provider<bool>(
  (ref) => ref.watch(settingsProvider).isDarkMode,
);

final showHintsProvider = Provider<bool>(
  (ref) => ref.watch(settingsProvider).showHints,
);

final languageProvider = Provider<String>(
  (ref) => ref.watch(settingsProvider).languageCode,
);

final localeProvider = Provider<Locale>(
  (ref) => Locale(ref.watch(settingsProvider).languageCode),
);

/// Server health check for the Settings screen.
final serverHealthProvider = FutureProvider.autoDispose<bool>((ref) async {
  final repo = ref.watch(articleRepositoryProvider);
  return repo.checkHealth();
});