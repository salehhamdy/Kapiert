import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/di/providers.dart';
import '../../../data/datasources/auth_remote_ds.dart';
import '../../../domain/repositories/i_sync_repository.dart';

// ---------------------------------------------------------------------------
// Sync state
// ---------------------------------------------------------------------------

enum SyncStatus { idle, syncing, error }

class SyncState {
  const SyncState({
    this.status = SyncStatus.idle,
    this.lastSyncedAt,
    this.error,
    this.revision = 0,
  });

  final SyncStatus status;
  final DateTime? lastSyncedAt;
  final String? error;

  /// Bumped whenever local data may have changed due to sync (pull or
  /// sign-out wipe). Screens listen to this to reload.
  final int revision;

  bool get isSyncing => status == SyncStatus.syncing;

  SyncState copyWith({
    SyncStatus? status,
    DateTime? lastSyncedAt,
    String? error,
    bool clearError = false,
    int? revision,
  }) {
    return SyncState(
      status: status ?? this.status,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      error: clearError ? null : error ?? this.error,
      revision: revision ?? this.revision,
    );
  }
}

// ---------------------------------------------------------------------------
// Sync notifier
// ---------------------------------------------------------------------------

/// Drives cloud sync from auth events:
/// - initial session / sign-in → full sync (guest history is merged in)
/// - sign-out → remove the account's data from this device
class SyncNotifier extends StateNotifier<SyncState> {
  SyncNotifier(this._repo, Stream<AuthState> authEvents)
      : super(const SyncState()) {
    _authSub = authEvents.listen(_onAuthEvent);
    // Covers the case where the initial auth event fired before we listened.
    if (_repo.isActive) Future.microtask(sync);
  }

  final ISyncRepository _repo;
  late final StreamSubscription<AuthState> _authSub;

  Future<void> _onAuthEvent(AuthState event) async {
    switch (event.event) {
      case AuthChangeEvent.initialSession:
      case AuthChangeEvent.signedIn:
        if (event.session != null) await sync();
      case AuthChangeEvent.signedOut:
        await _repo.clearLocalAccountData();
        if (mounted) {
          state = SyncState(revision: state.revision + 1);
        }
      default:
        break;
    }
  }

  /// Run a full sync. Safe to call repeatedly (e.g. pull-to-refresh).
  Future<void> sync() async {
    if (!_repo.isActive || state.isSyncing) return;
    state = state.copyWith(status: SyncStatus.syncing, clearError: true);
    try {
      await _repo.syncAll();
      if (!mounted) return;
      state = state.copyWith(
        status: SyncStatus.idle,
        lastSyncedAt: DateTime.now(),
        revision: state.revision + 1,
      );
    } catch (e) {
      debugPrint('[sync] syncAll failed: $e');
      if (!mounted) return;
      state = state.copyWith(status: SyncStatus.error, error: e.toString());
    }
  }

  @override
  void dispose() {
    _authSub.cancel();
    super.dispose();
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final syncProvider = StateNotifierProvider<SyncNotifier, SyncState>((ref) {
  return SyncNotifier(
    ref.watch(syncRepositoryProvider),
    AuthRemoteDS.onAuthStateChange,
  );
});

/// Convenience: changes whenever synced data lands locally.
final syncRevisionProvider = Provider<int>(
  (ref) => ref.watch(syncProvider.select((s) => s.revision)),
);
