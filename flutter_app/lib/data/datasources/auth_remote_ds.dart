import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/app_config.dart';
import '../../core/errors/failures.dart';
import '../../domain/models/auth_user.dart';
import '../dto/auth_dto.dart';

/// Remote data source for authentication.
class AuthRemoteDS {
  static bool _initialized = false;

  static bool get isEnabled => _initialized;

  static SupabaseClient? get _client =>
      _initialized ? Supabase.instance.client : null;

  static bool get isSignedIn => _client?.auth.currentSession != null;

  static AppUser? get currentUser {
    final user = _client?.auth.currentUser;
    return user == null ? null : AuthDto.fromSupabaseUser(user);
  }

  static Stream<AuthState> get onAuthStateChange =>
      _initialized
          ? Supabase.instance.client.auth.onAuthStateChange
          : const Stream.empty();

  static Future<void> init() async {
    if (!AppConfig.supabaseConfigured) return;
    if (_initialized) return;
    try {
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        publishableKey: AppConfig.supabaseAnonKey,
      );
      _initialized = true;
    } catch (_) {
      try {
        Supabase.instance.client;
        _initialized = true;
      } catch (_) {}
    }
  }

  static Future<void> configure({
    required String url,
    required String anonKey,
  }) async {
    await AppConfig.setSupabaseCredentials(url: url, anonKey: anonKey);
    if (_initialized) {
      try {
        await Supabase.instance.dispose();
      } catch (_) {}
      _initialized = false;
    }
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      publishableKey: AppConfig.supabaseAnonKey,
    );
    _initialized = true;
  }

  static void _requireClient() {
    if (!_initialized) {
      throw const AuthFailure(
        'Supabase is not configured. Provide SUPABASE_URL and SUPABASE_ANON_KEY.',
      );
    }
  }

  static Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    _requireClient();
    await _client!.auth.signUp(email: email, password: password);
  }

  static Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _requireClient();
    await _client!.auth.signInWithPassword(email: email, password: password);
  }

  static Future<void> signOut() async {
    if (!_initialized) return;
    await _client!.auth.signOut();
  }

  static Future<void> verifyOTP({
    required String email,
    required String token,
  }) async {
    _requireClient();
    try {
      await _client!.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.signup,
      );
    } catch (e) {
      try {
        await _client!.auth.verifyOTP(
          email: email,
          token: token,
          type: OtpType.email,
        );
      } catch (_) {
        throw e;
      }
    }
  }

  static Future<void> resendOTP({required String email}) async {
    _requireClient();
    try {
      await _client!.auth.resend(type: OtpType.signup, email: email);
    } catch (e) {
      try {
        await _client!.auth.resend(type: OtpType.email, email: email);
      } catch (_) {
        throw e;
      }
    }
  }

  static Future<void> resetPassword({required String email}) async {
    _requireClient();
    await _client!.auth.resetPasswordForEmail(email);
  }

  /// Update the user's display name.
  ///
  /// Auth user metadata is the source of truth (it's what [currentUser]
  /// reads); the `profiles` row is mirrored best-effort so server-side
  /// queries see the same name.
  static Future<void> updateDisplayName(String name) async {
    _requireClient();
    final trimmed = name.trim();
    final res = await _client!.auth.updateUser(
      UserAttributes(data: {'display_name': trimmed}),
    );
    final uid = res.user?.id ?? _client!.auth.currentUser?.id;
    if (uid == null) return;
    try {
      await _client!.from('profiles').upsert({
        'id': uid,
        'display_name': trimmed,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e) {
      debugPrint('[auth] profiles mirror failed: $e');
    }
  }

  static Future<void> signInWithGoogle() async {
    _requireClient();

    if (kIsWeb) {
      await _client!.auth.signInWithOAuth(OAuthProvider.google);
      return;
    }

    // Try native Google Sign-In first on Android/iOS
    try {
      final googleSignIn = GoogleSignIn(
        serverClientId:
            '313248263818-it8fb3rllht9orifqrut6v49bav37pbf.apps.googleusercontent.com',
        scopes: ['email', 'profile'],
      );
      final googleUser = await googleSignIn.signIn();
      if (googleUser != null) {
        final googleAuth = await googleUser.authentication;
        final idToken = googleAuth.idToken;
        if (idToken != null) {
          await _client!.auth.signInWithIdToken(
            provider: OAuthProvider.google,
            idToken: idToken,
            accessToken: googleAuth.accessToken,
          );
          return;
        }
      } else {
        throw SignInCancelledException();
      }
    } on SignInCancelledException {
      rethrow;
    } catch (_) {
      // Fallback to Supabase browser OAuth with deep linking on mobile
    }

    await _client!.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.kapiert://login-callback/',
    );
  }
}
