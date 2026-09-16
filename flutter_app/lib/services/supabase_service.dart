import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';

/// Supabase integration layer — inactive until credentials are provided.
///
/// When [AppConfig.supabaseConfigured] is false the app runs in guest mode
/// using local SQLite / SharedPreferences only (current behaviour).
class SupabaseService {
  static bool _initialized = false;

  static bool get isEnabled => _initialized;

  static SupabaseClient? get client =>
      _initialized ? Supabase.instance.client : null;

  static bool get isSignedIn =>
      client?.auth.currentSession != null;

  static User? get currentUser => client?.auth.currentUser;

  /// Initialize Supabase if credentials are configured via `--dart-define`.
  static Future<void> init() async {
    if (!AppConfig.supabaseConfigured) {
      return;
    }

    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      publishableKey: AppConfig.supabaseAnonKey,
    );
    _initialized = true;
  }

  // ---------------------------------------------------------------------------
  // Auth stubs — wire up UI in a future release
  // ---------------------------------------------------------------------------

  static Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    _requireClient();
    return client!.auth.signUp(email: email, password: password);
  }

  static Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _requireClient();
    return client!.auth.signInWithPassword(email: email, password: password);
  }

  static Future<void> signOut() async {
    if (!_initialized) return;
    await client!.auth.signOut();
  }

  static void _requireClient() {
    if (!_initialized) {
      throw StateError(
        'Supabase is not configured. Provide SUPABASE_URL and SUPABASE_ANON_KEY.',
      );
    }
  }
}
