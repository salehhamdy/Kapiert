import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Central configuration for API and Supabase endpoints.
///
/// Values are resolved in this order:
/// 1. `--dart-define` build flags (production)
/// 2. SharedPreferences override (optional dev/testing)
/// 3. Platform defaults (local development)
class AppConfig {
  static const String _apiBaseUrlDefine = String.fromEnvironment('API_BASE_URL');
  static const String _supabaseUrlDefine = String.fromEnvironment('SUPABASE_URL');
  static const String _supabaseAnonKeyDefine =
      String.fromEnvironment('SUPABASE_ANON_KEY');

  static const String _prefsApiBaseUrlKey = 'api_base_url';

  static const String _androidEmulatorUrl = 'http://10.0.2.2:8000';
  static const String _localUrl = 'http://127.0.0.1:8000';

  static late String apiBaseUrl;
  static late String supabaseUrl;
  static late String supabaseAnonKey;

  static bool get supabaseConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  /// Initialize configuration. Must be called before runApp().
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    apiBaseUrl = _resolveApiBaseUrl(prefs);
    supabaseUrl = _supabaseUrlDefine;
    supabaseAnonKey = _supabaseAnonKeyDefine;
  }

  static String _resolveApiBaseUrl(SharedPreferences prefs) {
    if (_apiBaseUrlDefine.isNotEmpty) {
      return _apiBaseUrlDefine;
    }

    final saved = prefs.getString(_prefsApiBaseUrlKey);
    if (saved != null && saved.isNotEmpty) {
      return saved;
    }

    return _platformDefaultUrl();
  }

  static String _platformDefaultUrl() {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return _androidEmulatorUrl;
    }
    return _localUrl;
  }

  /// Optional override for testing a deployed backend without rebuilding.
  static Future<void> setApiBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsApiBaseUrlKey, url);
    apiBaseUrl = url;
  }

  /// Reset to platform default (clears saved override).
  static Future<void> resetApiBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsApiBaseUrlKey);
    apiBaseUrl = _apiBaseUrlDefine.isNotEmpty
        ? _apiBaseUrlDefine
        : _platformDefaultUrl();
  }
}
