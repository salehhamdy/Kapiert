import '../models/achievement.dart';

/// Abstract contract for milestones and achievement tracking.
abstract interface class IAchievementsRepository {
  /// Evaluates and returns all milestones with live progress.
  Future<List<Achievement>> getAchievements();

  /// Returns milestones that were newly unlocked but not yet notified/celebrated.
  Future<List<Achievement>> checkNewUnlocks();

  /// Clears stored unlock history.
  Future<void> resetAchievements();
}
