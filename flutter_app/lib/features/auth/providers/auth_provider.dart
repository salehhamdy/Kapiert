import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../domain/models/auth_user.dart';
import '../../../domain/repositories/i_auth_repository.dart';
import '../../../data/datasources/auth_remote_ds.dart';

// ---------------------------------------------------------------------------
// Auth state
// ---------------------------------------------------------------------------

class AuthState {
  const AuthState({
    this.user,
    this.loading = false,
    this.error,
  });

  final AppUser? user;
  final bool loading;
  final String? error;

  bool get isSignedIn => user != null;

  AuthState copyWith({
    AppUser? user,
    bool? loading,
    String? error,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : user ?? this.user,
      loading: loading ?? this.loading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

// ---------------------------------------------------------------------------
// Auth notifier
// ---------------------------------------------------------------------------

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repo)
      : super(AuthState(user: _repo.currentUser));

  final IAuthRepository _repo;

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      await _repo.signInWithEmail(email: email, password: password);
      state = state.copyWith(user: _repo.currentUser, loading: false);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      await _repo.signUpWithEmail(email: email, password: password);
      state = state.copyWith(user: _repo.currentUser, loading: false);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      await _repo.signInWithGoogle();
      state = state.copyWith(user: _repo.currentUser, loading: false);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      await _repo.signOut();
      state = state.copyWith(loading: false, clearUser: true);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> verifyOTP({required String email, required String token}) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      await _repo.verifyOTP(email: email, token: token);
      state = state.copyWith(user: _repo.currentUser, loading: false);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> resendOTP({required String email}) async {
    try {
      await _repo.resendOTP(email: email);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> resetPassword({required String email}) async {
    try {
      await _repo.resetPassword(email: email);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearError() => state = state.copyWith(clearError: true);
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref.watch(authRepositoryProvider)),
);

/// Stream-based provider for reactive auth state changes.
final authStateStreamProvider = StreamProvider<dynamic>(
  (_) => AuthRemoteDS.onAuthStateChange,
);
