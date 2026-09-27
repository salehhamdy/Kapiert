/// Abstract contract for user settings/preferences.
abstract interface class ISettingsRepository {
  bool getDarkMode();
  Future<void> setDarkMode(bool value);
  bool getShowHints();
  Future<void> setShowHints(bool value);
}
