import '../../core/storage/storage_service.dart';
import '../../domain/repositories/i_settings_repository.dart';

/// Concrete implementation of [ISettingsRepository] using [StorageService].
class SettingsRepositoryImpl implements ISettingsRepository {
  @override
  bool getDarkMode() => StorageService.getDarkMode();

  @override
  Future<void> setDarkMode(bool value) => StorageService.setDarkMode(value);

  @override
  bool getShowHints() => StorageService.getShowHints();

  @override
  Future<void> setShowHints(bool value) => StorageService.setShowHints(value);
}
