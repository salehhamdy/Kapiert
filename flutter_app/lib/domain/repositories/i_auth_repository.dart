import '../models/auth_user.dart';

/// Abstract contract for authentication operations.
abstract interface class IAuthRepository {
  AppUser? get currentUser;
  bool get isEnabled;

  Future<void> signInWithEmail({required String email, required String password});
  Future<void> signUpWithEmail({required String email, required String password});
  Future<void> signInWithGoogle();
  Future<void> signOut();
  Future<void> resetPassword({required String email});
  Future<void> verifyOTP({required String email, required String token});
  Future<void> resendOTP({required String email});
}
