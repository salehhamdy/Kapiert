import 'package:supabase_flutter/supabase_flutter.dart';

/// Thin wrapper around the Supabase tables/RPCs used for cloud sync.
///
/// All calls run as the signed-in user; Row Level Security on the server
/// guarantees users can only touch their own rows.
class SyncRemoteDS {
  SyncRemoteDS(this._client);

  final SupabaseClient _client;

  String? get currentUserId => _client.auth.currentUser?.id;

  // ---------------------------------------------------------------------------
  // History
  // ---------------------------------------------------------------------------

  static const _historyColumns =
      'id, client_id, timestamp, word, article, correct, mode';

  /// Insert rows, silently skipping any `client_id` already on the server.
  Future<void> upsertHistory(List<Map<String, dynamic>> rows) async {
    if (rows.isEmpty) return;
    await _client.from('lookup_history').upsert(
          rows,
          onConflict: 'user_id,client_id',
          ignoreDuplicates: true,
        );
  }

  /// Rows with `id > afterId`, ascending.
  Future<List<Map<String, dynamic>>> fetchHistoryAfter(
    int afterId, {
    int limit = 1000,
  }) async {
    final rows = await _client
        .from('lookup_history')
        .select(_historyColumns)
        .gt('id', afterId)
        .order('id', ascending: true)
        .limit(limit);
    return List<Map<String, dynamic>>.from(rows);
  }

  Future<void> deleteAllHistory(String userId) async {
    await _client.from('lookup_history').delete().eq('user_id', userId);
  }

  // ---------------------------------------------------------------------------
  // Streak
  // ---------------------------------------------------------------------------

  /// Merge the local streak into the server copy; returns the merged row.
  Future<Map<String, dynamic>> mergeStreak({
    required int currentStreak,
    required String? lastActiveDate,
  }) async {
    final result = await _client.rpc('merge_streak', params: {
      'p_current_streak': currentStreak,
      'p_last_active_date': lastActiveDate,
    });
    return Map<String, dynamic>.from(result as Map);
  }

  Future<void> resetStreak() async {
    await _client.rpc('reset_streak');
  }

  // ---------------------------------------------------------------------------
  // Settings
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>?> fetchSettings() async {
    final row = await _client
        .from('user_settings')
        .select('show_hints, dark_mode, updated_at')
        .maybeSingle();
    return row == null ? null : Map<String, dynamic>.from(row);
  }

  Future<void> upsertSettings({
    required String userId,
    required bool showHints,
    required bool darkMode,
    required DateTime updatedAt,
  }) async {
    await _client.from('user_settings').upsert({
      'user_id': userId,
      'show_hints': showHints,
      'dark_mode': darkMode,
      'updated_at': updatedAt.toUtc().toIso8601String(),
    }, onConflict: 'user_id');
  }
}
