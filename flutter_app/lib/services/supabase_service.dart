import 'package:google_sign_in/google_sign_in.dart';
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

  /// Stream that emits whenever the auth state changes (sign-in / sign-out).
  static Stream<AuthState> get onAuthStateChange =>
      _initialized ? Supabase.instance.client.auth.onAuthStateChange : const Stream.empty();

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
  // Auth — email / password
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

  // ---------------------------------------------------------------------------
  // Auth — OTP / email verification
  // ---------------------------------------------------------------------------

  /// Verify the 6-digit OTP that Supabase emailed after sign-up.
  static Future<AuthResponse> verifyOTP({
    required String email,
    required String token,
  }) async {
    _requireClient();
    return client!.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.signup,
    );
  }

  /// Re-send the sign-up confirmation OTP to [email].
  static Future<void> resendOTP({required String email}) async {
    _requireClient();
    await client!.auth.resend(type: OtpType.signup, email: email);
  }

  // ---------------------------------------------------------------------------
  // Auth — password reset
  // ---------------------------------------------------------------------------

  /// Send a password-reset email. Works even when no session is active.
  static Future<void> resetPassword({required String email}) async {
    _requireClient();
    await client!.auth.resetPasswordForEmail(email);
  }

  // ---------------------------------------------------------------------------
  // Auth — Google OAuth (native mobile via google_sign_in)
  // ---------------------------------------------------------------------------

  /// Sign in with Google on Android / iOS.
  ///
  /// Flow:
  ///   1. Open the native Google picker with [GoogleSignIn].
  ///   2. Exchange the returned id/access tokens with Supabase
  ///      via [signInWithIdToken] so the user gets a full Supabase session.
  ///
  /// Throws a [StateError] when Supabase is not configured, a
  /// [SignInCancelledException] when the user dismisses the picker, or
  /// any Supabase [AuthException] on failure.
  static Future<AuthResponse> signInWithGoogle() async {
    _requireClient();

    final googleSignIn = GoogleSignIn(
      scopes: ['email', 'profile'],
    );

    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      throw SignInCancelledException();
    }

    final googleAuth = await googleUser.authentication;

    final idToken = googleAuth.idToken;
    if (idToken == null) {
      throw AuthException('Google Sign-In did not return an ID token. '
          'Check your OAuth client configuration.');
    }

    return client!.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: googleAuth.accessToken,
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static void _requireClient() {
    if (!_initialized) {
      throw StateError(
        'Supabase is not configured. Provide SUPABASE_URL and SUPABASE_ANON_KEY.',
      );
    }
  }
}

// ---------------------------------------------------------------------------
// Custom exceptions
// ---------------------------------------------------------------------------

/// Thrown when the user cancels the Google Sign-In picker without choosing
/// an account. Callers should swallow this silently.
class SignInCancelledException implements Exception {
  @override
  String toString() => 'SignInCancelledException: user dismissed the picker.';
}
