import '../services/supabase_service.dart';

/// Repository wrapping [SupabaseService] for authentication operations.
class AuthRepository {
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) =>
      SupabaseService.signInWithEmail(email: email, password: password);

  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) =>
      SupabaseService.signUpWithEmail(
        email: email,
        password: password,
      );

  Future<void> signInWithGoogle() => SupabaseService.signInWithGoogle();

  Future<void> signOut() => SupabaseService.signOut();

  Future<void> resetPassword({required String email}) =>
      SupabaseService.resetPassword(email: email);

  Future<void> verifyOTP({required String email, required String token}) =>
      SupabaseService.verifyOTP(email: email, token: token);

  Future<void> resendOTP({required String email}) =>
      SupabaseService.resendOTP(email: email);

  dynamic get currentUser => SupabaseService.currentUser;

  bool get isEnabled => SupabaseService.isEnabled;
}
