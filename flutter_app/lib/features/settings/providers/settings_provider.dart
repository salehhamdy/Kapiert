import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../domain/repositories/i_settings_repository.dart';

// ---------------------------------------------------------------------------
// Settings state
// ---------------------------------------------------------------------------

class SettingsState {
  const SettingsState({
    this.isDarkMode = false,
    this.showHints = true,
  });

  final bool isDarkMode;
  final bool showHints;

  SettingsState copyWith({bool? isDarkMode, bool? showHints}) {
    return SettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      showHints: showHints ?? this.showHints,
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
        ));

  final ISettingsRepository _repo;

  Future<void> toggleDarkMode() async {
    final next = !state.isDarkMode;
    state = state.copyWith(isDarkMode: next);
    await _repo.setDarkMode(next);
  }

  Future<void> setShowHints(bool value) async {
    state = state.copyWith(showHints: value);
    await _repo.setShowHints(value);
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier(ref.watch(settingsRepositoryProvider));
});

/// Convenience derived provider for theme - used by [MaterialApp.themeMode].
final themeProvider = Provider<bool>(
  (ref) => ref.watch(settingsProvider).isDarkMode,
);

final showHintsProvider = Provider<bool>(
  (ref) => ref.watch(settingsProvider).showHints,
);

/// Server health check for the Settings screen.
final serverHealthProvider = FutureProvider.autoDispose<bool>((ref) async {
  final repo = ref.watch(articleRepositoryProvider);
  return repo.checkHealth();
});