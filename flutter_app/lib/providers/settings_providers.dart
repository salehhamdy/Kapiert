import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';
import 'article_providers.dart';

// ---------------------------------------------------------------------------
// Theme
// ---------------------------------------------------------------------------

class ThemeNotifier extends StateNotifier<bool> {
  ThemeNotifier() : super(StorageService.getDarkMode());

  void toggle() {
    state = !state;
    StorageService.setDarkMode(state);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, bool>(
  (_) => ThemeNotifier(),
);

// ---------------------------------------------------------------------------
// Show hints
// ---------------------------------------------------------------------------

class ShowHintsNotifier extends StateNotifier<bool> {
  ShowHintsNotifier() : super(StorageService.getShowHints());

  void toggle(bool value) {
    state = value;
    StorageService.setShowHints(value);
  }
}

final showHintsProvider = StateNotifierProvider<ShowHintsNotifier, bool>(
  (_) => ShowHintsNotifier(),
);

// ---------------------------------------------------------------------------
// Server health
// ---------------------------------------------------------------------------

final serverHealthProvider = FutureProvider.autoDispose<bool>((ref) async {
  final repo = ref.watch(wordRepositoryProvider);
  return repo.checkHealth();
});
