/// Contract for keeping local data in sync with the signed-in user's cloud
/// copy. Every method is a no-op when Supabase isn't configured or nobody
/// is signed in, so callers never need to check.
abstract interface class ISyncRepository {
  /// True when a user is signed in and cloud sync is available.
  bool get isActive;

  /// Full two-way sync: push pending history, pull new history, merge
  /// streak and settings. Throws on network/server errors.
  Future<void> syncAll();

  /// Push unsynced history rows. Never throws (retried on next sync).
  Future<void> pushHistory();

  /// Merge the local streak into the cloud. Never throws.
  Future<void> pushStreak();

  /// Push local settings. Never throws.
  Future<void> pushSettings();

  /// Delete all of the user's history in the cloud. Never throws.
  Future<void> clearRemoteHistory();

  /// Reset the user's streak in the cloud. Never throws.
  Future<void> resetRemoteStreak();

  /// Best-effort flush of pending changes before signing out.
  Future<void> flushBeforeSignOut();

  /// Remove the signed-out user's cloud data from this device.
  Future<void> clearLocalAccountData();
}
