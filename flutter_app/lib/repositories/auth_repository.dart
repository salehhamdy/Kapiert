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

  dynamic get currentUser => SupabaseService.currentUser;

  bool get isEnabled => SupabaseService.isEnabled;
}
