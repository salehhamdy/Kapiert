import '../models/lookup_history.dart';
import 'storage_service.dart';
import 'supabase_service.dart';

/// Cloud sync layer — prepared for account-based history/streak sync.
///
/// All methods are no-ops until the user is signed in via [SupabaseService].
/// Local guest mode continues to work unchanged.
class SyncService {
  static bool get canSync =>
      SupabaseService.isEnabled && SupabaseService.isSignedIn;

  /// Merge local SQLite history into Supabase after first sign-in.
  static Future<void> mergeLocalHistoryToCloud() async {
    if (!canSync) return;

    final client = SupabaseService.client!;
    final userId = SupabaseService.currentUser!.id;
    final localHistory = await StorageService.getHistory();

    if (localHistory.isEmpty) return;

    final rows = localHistory
        .map(
          (entry) => {
            'user_id': userId,
            'timestamp': entry.timestamp.toIso8601String(),
            'word': entry.word,
            'article': entry.article,
            'correct': entry.correct,
            'mode': entry.mode,
          },
        )
        .toList();

    await client.from('lookup_history').upsert(rows);
  }

  /// Push a single history entry to Supabase when signed in.
  static Future<void> pushHistoryEntry(LookupHistory entry) async {
    if (!canSync) return;

    final client = SupabaseService.client!;
    await client.from('lookup_history').insert({
      'user_id': SupabaseService.currentUser!.id,
      'timestamp': entry.timestamp.toIso8601String(),
      'word': entry.word,
      'article': entry.article,
      'correct': entry.correct,
      'mode': entry.mode,
    });
  }

  /// Sync streak to Supabase when signed in.
  static Future<void> pushStreak() async {
    if (!canSync) return;

    final client = SupabaseService.client!;
    await client.from('streaks').upsert({
      'user_id': SupabaseService.currentUser!.id,
      'current_streak': StorageService.getStreak(),
      'last_active_date': DateTime.now().toIso8601String().substring(0, 10),
    });
  }
}
