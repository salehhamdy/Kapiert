import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/storage/storage_service.dart';
import '../../domain/repositories/i_sync_repository.dart';
import '../datasources/sync_remote_ds.dart';
import '../dto/history_dto.dart';

/// Local-first sync between [StorageService] and Supabase.
///
/// - **History**: append-only. Each row has a client-generated UUID, so pushes
///   are idempotent. New remote rows are pulled using an id cursor.
/// - **Streak**: merged server-side by the `merge_streak` RPC.
/// - **Settings**: last-write-wins on `updated_at`.
///
/// All operations are serialized so pushes and pulls never interleave.
class SyncRepositoryImpl implements ISyncRepository {
  SyncRepositoryImpl(this._remoteFactory);

  /// Returns null when Supabase isn't configured.
  final SyncRemoteDS? Function() _remoteFactory;

  static const _pushBatch = 500;
  static const _pullBatch = 1000;

  Future<void> _queue = Future.value();

  Future<T> _serial<T>(Future<T> Function() op) {
    final next = _queue.then((_) => op());
    _queue = next.then((_) {}, onError: (_) {});
    return next;
  }

  /// Resolves the remote + uid, or null when sync is unavailable.
  ({SyncRemoteDS remote, String uid})? _session() {
    final remote = _remoteFactory();
    final uid = remote?.currentUserId;
    if (remote == null || uid == null) return null;
    return (remote: remote, uid: uid);
  }

  @override
  bool get isActive => _session() != null;

  // ---------------------------------------------------------------------------
  // Full sync
  // ---------------------------------------------------------------------------

  @override
  Future<void> syncAll() => _serial(() async {
        final s = _session();
        if (s == null) return;
        await _adoptOwner(s.uid);
        await _pushHistory(s.remote, s.uid);
        await _pullHistory(s.remote, s.uid);
        await _mergeStreak(s.remote);
        await _syncSettings(s.remote, s.uid);
      });

  /// If this device still holds another account's synced data, drop it
  /// before merging (guest-only rows are kept and adopted).
  Future<void> _adoptOwner(String uid) async {
    final owner = StorageService.getSyncOwner();
    if (owner != null && owner != uid) {
      await StorageService.deleteSyncedHistory();
      await StorageService.resetStreak();
      await StorageService.clearHistoryCursor(owner);
    }
    if (owner != uid) await StorageService.setSyncOwner(uid);
  }

  Future<void> _pushHistory(SyncRemoteDS remote, String uid) async {
    while (true) {
      final rows = await StorageService.getUnsyncedHistory(limit: _pushBatch);
      if (rows.isEmpty) return;
      await remote.upsertHistory(
        rows.map((r) => HistoryDto.toRemote(r, uid)).toList(),
      );
      await StorageService.markHistorySynced(
        rows.map((r) => r['client_id'] as String).toList(),
      );
      if (rows.length < _pushBatch) return;
    }
  }

  Future<void> _pullHistory(SyncRemoteDS remote, String uid) async {
    var cursor = StorageService.getHistoryCursor(uid);
    while (true) {
      final rows = await remote.fetchHistoryAfter(cursor, limit: _pullBatch);
      if (rows.isEmpty) return;
      await StorageService.insertSyncedHistory(
        rows.map(HistoryDto.fromRemote).toList(),
      );
      cursor = (rows.last['id'] as num).toInt();
      await StorageService.setHistoryCursor(uid, cursor);
      if (rows.length < _pullBatch) return;
    }
  }

  Future<void> _mergeStreak(SyncRemoteDS remote) async {
    final merged = await remote.mergeStreak(
      currentStreak: StorageService.getStreak(),
      lastActiveDate: StorageService.getLastActiveDate(),
    );
    await StorageService.setStreak(
      (merged['current_streak'] as num?)?.toInt() ?? 0,
      merged['last_active_date'] as String?,
    );
  }

  Future<void> _syncSettings(SyncRemoteDS remote, String uid) async {
    final localAt = StorageService.getSettingsUpdatedAt();
    final row = await remote.fetchSettings();
    final remoteAt =
        row == null ? null : DateTime.tryParse(row['updated_at'] as String);

    final localWins = remoteAt == null ||
        (localAt != null && localAt.isAfter(remoteAt));

    if (localWins) {
      await _pushSettings(remote, uid, localAt ?? DateTime.now().toUtc());
    } else if (localAt == null || remoteAt.isAfter(localAt)) {
      await StorageService.applySyncedSettings(
        showHints: row!['show_hints'] as bool,
        darkMode: row['dark_mode'] as bool,
        updatedAt: remoteAt,
      );
    }
  }

  Future<void> _pushSettings(
    SyncRemoteDS remote,
    String uid,
    DateTime updatedAt,
  ) {
    return remote.upsertSettings(
      userId: uid,
      showHints: StorageService.getShowHints(),
      darkMode: StorageService.getDarkMode(),
      updatedAt: updatedAt,
    );
  }

  // ---------------------------------------------------------------------------
  // Incremental, fire-and-forget operations
  // ---------------------------------------------------------------------------

  Future<void> _bestEffort(
    String label,
    Future<void> Function(SyncRemoteDS remote, String uid) op,
  ) async {
    try {
      await _serial(() async {
        final s = _session();
        if (s == null) return;
        await op(s.remote, s.uid);
      });
    } catch (e) {
      debugPrint('[sync] $label failed: $e');
    }
  }

  @override
  Future<void> pushHistory() => _bestEffort('pushHistory', _pushHistory);

  @override
  Future<void> pushStreak() =>
      _bestEffort('pushStreak', (remote, _) => _mergeStreak(remote));

  @override
  Future<void> pushSettings() => _bestEffort(
        'pushSettings',
        (remote, uid) => _pushSettings(
          remote,
          uid,
          StorageService.getSettingsUpdatedAt() ?? DateTime.now().toUtc(),
        ),
      );

  @override
  Future<void> clearRemoteHistory() => _bestEffort(
        'clearRemoteHistory',
        (remote, uid) => remote.deleteAllHistory(uid),
      );

  @override
  Future<void> resetRemoteStreak() => _bestEffort(
        'resetRemoteStreak',
        (remote, _) => remote.resetStreak(),
      );

  // ---------------------------------------------------------------------------
  // Sign-out
  // ---------------------------------------------------------------------------

  @override
  Future<void> flushBeforeSignOut() async {
    try {
      await _serial(() async {
        final s = _session();
        if (s == null) return;
        await _pushHistory(s.remote, s.uid);
        await _mergeStreak(s.remote);
      }).timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('[sync] flushBeforeSignOut failed: $e');
    }
  }

  @override
  Future<void> clearLocalAccountData() => _serial(() async {
        final owner = StorageService.getSyncOwner();
        if (owner == null) return; // nothing was ever synced
        await StorageService.clearHistory();
        await StorageService.resetStreak();
        await StorageService.clearHistoryCursor(owner);
        await StorageService.setSyncOwner(null);
      });
}
