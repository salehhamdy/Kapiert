import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:derdiedas/config/app_config.dart';
import 'package:derdiedas/features/history/providers/history_provider.dart';
import 'package:derdiedas/features/srs/providers/srs_provider.dart';
import 'package:derdiedas/domain/repositories/i_history_repository.dart';
import 'package:derdiedas/domain/repositories/i_srs_repository.dart';
import 'package:derdiedas/domain/repositories/i_article_repository.dart';
import 'package:derdiedas/domain/repositories/i_achievements_repository.dart';
import 'package:derdiedas/core/di/providers.dart';
import 'package:derdiedas/domain/models/srs_item.dart';
import 'package:derdiedas/domain/models/srs_stats.dart';

class MockHistoryRepository extends Mock implements IHistoryRepository {}
class MockSrsRepository extends Mock implements ISrsRepository {}
class MockArticleRepository extends Mock implements IArticleRepository {}
class MockAchievementsRepository extends Mock implements IAchievementsRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockHistoryRepository mockHistoryRepo;
  late MockSrsRepository mockSrsRepo;
  late MockArticleRepository mockArticleRepo;
  late MockAchievementsRepository mockAchievementsRepo;

  setUp(() {
    AppConfig.apiBaseUrl = 'http://127.0.0.1:8000';
    mockHistoryRepo = MockHistoryRepository();
    mockSrsRepo = MockSrsRepository();
    mockArticleRepo = MockArticleRepository();
    mockAchievementsRepo = MockAchievementsRepository();

    when(() => mockHistoryRepo.getHistory(filter: any(named: 'filter')))
        .thenAnswer((_) async => []);
    when(() => mockHistoryRepo.getStats()).thenAnswer((_) async => {});
    when(() => mockHistoryRepo.clearHistory()).thenAnswer((_) async {});
    when(() => mockHistoryRepo.getStreak()).thenReturn(0);

    when(() => mockArticleRepo.randomBatch(count: any(named: 'count')))
        .thenAnswer((_) async => []);

    var isReset = false;

    when(() => mockSrsRepo.getDueItems(limit: any(named: 'limit')))
        .thenAnswer((_) async => isReset
            ? []
            : [
                SrsItem(
                  id: 1,
                  word: 'Stuhl',
                  article: 'der',
                  gender: 'm',
                  nextReview: DateTime.now().subtract(const Duration(hours: 1)),
                ),
              ]);
    when(() => mockSrsRepo.getStats()).thenAnswer((_) async => isReset
        ? const SrsStats.empty()
        : const SrsStats(
            totalCount: 1,
            dueCount: 1,
            masteredCount: 0,
          ));
    when(() => mockSrsRepo.resetSrs()).thenAnswer((_) async {
      isReset = true;
    });

    when(() => mockAchievementsRepo.getAchievements()).thenAnswer((_) async => []);
    when(() => mockAchievementsRepo.checkNewUnlocks()).thenAnswer((_) async => []);
  });

  test('clearing history resets SRS provider state and due count', () async {
    final container = ProviderContainer(
      overrides: [
        historyRepositoryProvider.overrideWithValue(mockHistoryRepo),
        srsRepositoryProvider.overrideWithValue(mockSrsRepo),
        articleRepositoryProvider.overrideWithValue(mockArticleRepo),
        achievementsRepositoryProvider.overrideWithValue(mockAchievementsRepo),
      ],
    );
    addTearDown(container.dispose);

    // Initial load of SRS state has 1 due item
    final srsNotifier = container.read(srsProvider.notifier);
    await srsNotifier.refresh();

    expect(container.read(srsProvider).stats.dueCount, equals(1));
    expect(container.read(srsProvider).dueItems.length, equals(1));

    // Clear history via historyProvider
    final historyNotifier = container.read(historyProvider.notifier);
    await historyNotifier.clearAll();

    // SRS state should now be reset to 0 due items
    expect(container.read(srsProvider).stats.dueCount, equals(0));
    expect(container.read(srsProvider).dueItems, isEmpty);
    verify(() => mockHistoryRepo.clearHistory()).called(1);
    verify(() => mockSrsRepo.resetSrs()).called(1);
  });
}
