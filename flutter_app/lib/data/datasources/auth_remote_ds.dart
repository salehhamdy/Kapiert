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
    await _client!.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.signup,
    );
  }

  static Future<void> resendOTP({required String email}) async {
    _requireClient();
    await _client!.auth.resend(type: OtpType.signup, email: email);
  }

  static Future<void> resetPassword({required String email}) async {
    _requireClient();
    await _client!.auth.resetPasswordForEmail(email);
  }

  static Future<void> signInWithGoogle() async {
    _requireClient();
    final googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) throw SignInCancelledException();
    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;
    if (idToken == null) {
      throw const AuthFailure(
        'Google Sign-In did not return an ID token. Check your OAuth client configuration.',
      );
    }
    await _client!.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: googleAuth.accessToken,
    );
  }
}
