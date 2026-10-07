import 'dart:async';

import '../../core/storage/storage_service.dart';
import '../../domain/repositories/i_settings_repository.dart';
import '../../domain/repositories/i_sync_repository.dart';

/// Concrete implementation of [ISettingsRepository] using [StorageService],
/// with background cloud sync via [ISyncRepository].
class SettingsRepositoryImpl implements ISettingsRepository {
  SettingsRepositoryImpl(this._sync);

  final ISyncRepository _sync;

  @override
  bool getDarkMode() => StorageService.getDarkMode();

  @override
  Future<void> setDarkMode(bool value) async {
    await StorageService.setDarkMode(value);
    unawaited(_sync.pushSettings());
  }

  @override
  bool getShowHints() => StorageService.getShowHints();

  @override
  Future<void> setShowHints(bool value) async {
    await StorageService.setShowHints(value);
    unawaited(_sync.pushSettings());
  }

  @override
  String getLanguage() => StorageService.getLanguage();

  @override
  Future<void> setLanguage(String code) async {
    await StorageService.setLanguage(code);
    unawaited(_sync.pushSettings());
  }
}
