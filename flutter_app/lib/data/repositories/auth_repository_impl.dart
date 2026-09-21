import '../../domain/models/auth_user.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../datasources/auth_remote_ds.dart';

/// Concrete implementation of [IAuthRepository] using [AuthRemoteDS].
class AuthRepositoryImpl implements IAuthRepository {
  @override
  AppUser? get currentUser => AuthRemoteDS.currentUser;

  @override
  bool get isEnabled => AuthRemoteDS.isEnabled;

  @override
  Future<void> signInWithEmail({required String email, required String password}) =>
      AuthRemoteDS.signInWithEmail(email: email, password: password);

  @override
  Future<void> signUpWithEmail({required String email, required String password}) =>
      AuthRemoteDS.signUpWithEmail(email: email, password: password);

  @override
  Future<void> signInWithGoogle() => AuthRemoteDS.signInWithGoogle();

  @override
  Future<void> signOut() => AuthRemoteDS.signOut();

  @override
  Future<void> resetPassword({required String email}) =>
      AuthRemoteDS.resetPassword(email: email);

  @override
  Future<void> verifyOTP({required String email, required String token}) =>
      AuthRemoteDS.verifyOTP(email: email, token: token);

  @override
  Future<void> resendOTP({required String email}) =>
      AuthRemoteDS.resendOTP(email: email);
}
