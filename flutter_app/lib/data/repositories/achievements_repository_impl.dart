import '../../core/storage/storage_service.dart';
import '../../domain/models/achievement.dart';
import '../../domain/repositories/i_achievements_repository.dart';

/// Concrete implementation of [IAchievementsRepository].
class AchievementsRepositoryImpl implements IAchievementsRepository {
  const AchievementsRepositoryImpl();

  @override
  Future<List<Achievement>> getAchievements() =>
      StorageService.getAchievements();

  @override
  Future<List<Achievement>> checkNewUnlocks() =>
      StorageService.checkNewUnlocks();

  @override
  Future<void> resetAchievements() =>
      StorageService.resetAchievements();
}
