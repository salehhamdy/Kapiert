import '../../domain/models/auth_user.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../domain/repositories/i_sync_repository.dart';
import '../datasources/auth_remote_ds.dart';

/// Concrete implementation of [IAuthRepository] using [AuthRemoteDS].
class AuthRepositoryImpl implements IAuthRepository {
  AuthRepositoryImpl(this._sync);

  final ISyncRepository _sync;

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
  Future<void> signOut() async {
    // Push anything still pending; local account data is wiped after sign-out.
    await _sync.flushBeforeSignOut();
    await AuthRemoteDS.signOut();
  }

  @override
  Future<void> resetPassword({required String email}) =>
      AuthRemoteDS.resetPassword(email: email);

  @override
  Future<void> verifyOTP({required String email, required String token}) =>
      AuthRemoteDS.verifyOTP(email: email, token: token);

  @override
  Future<void> resendOTP({required String email}) =>
      AuthRemoteDS.resendOTP(email: email);

  @override
  Future<void> updateDisplayName(String name) =>
      AuthRemoteDS.updateDisplayName(name);

  @override
  Future<void> updatePassword(String newPassword) =>
      AuthRemoteDS.updatePassword(newPassword);
}
