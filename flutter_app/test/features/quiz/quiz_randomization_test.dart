import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:derdiedas/features/quiz/providers/quiz_provider.dart';
import 'package:derdiedas/domain/repositories/i_article_repository.dart';
import 'package:derdiedas/domain/repositories/i_history_repository.dart';
import 'package:derdiedas/core/di/providers.dart';
import 'package:derdiedas/domain/models/word_model.dart';
import 'package:derdiedas/domain/models/lookup_history.dart';

class MockArticleRepository extends Mock implements IArticleRepository {}
class MockHistoryRepository extends Mock implements IHistoryRepository {}

class FakeLookupHistory extends Fake implements LookupHistory {}

void main() {
  late MockArticleRepository mockArticleRepo;
  late MockHistoryRepository mockHistoryRepo;

  setUpAll(() {
    registerFallbackValue(FakeLookupHistory());
  });

  setUp(() {
    mockArticleRepo = MockArticleRepository();
    mockHistoryRepo = MockHistoryRepository();

    when(() => mockHistoryRepo.getStreak()).thenReturn(0);
    when(() => mockHistoryRepo.getHistory(filter: any(named: 'filter')))
        .thenAnswer((_) async => []);
    when(() => mockHistoryRepo.getStats()).thenAnswer((_) async => {});
    when(() => mockHistoryRepo.addEntry(any())).thenAnswer((_) async {});
    when(() => mockHistoryRepo.updateStreak()).thenAnswer((_) async {});
  });

  test('QuizNotifier does not serve the same word twice in a session', () async {
    final batch = [
      const WordModel(word: 'Tisch', article: 'der', gender: 'm', source: 'db'),
      const WordModel(word: 'Lampe', article: 'die', gender: 'f', source: 'db'),
      const WordModel(word: 'Buch', article: 'das', gender: 'n', source: 'db'),
      const WordModel(word: 'Tisch', article: 'der', gender: 'm', source: 'db'), // Duplicate
      const WordModel(word: 'Auto', article: 'das', gender: 'n', source: 'db'),
    ];

    when(() => mockArticleRepo.randomBatch(count: any(named: 'count')))
        .thenAnswer((_) async => List<WordModel>.from(batch));
    when(() => mockArticleRepo.random()).thenAnswer((_) async =>
        const WordModel(word: 'Sonne', article: 'die', gender: 'f', source: 'db'));

    final container = ProviderContainer(
      overrides: [
        articleRepositoryProvider.overrideWithValue(mockArticleRepo),
        historyRepositoryProvider.overrideWithValue(mockHistoryRepo),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(quizProvider.notifier);
    await Future.delayed(const Duration(milliseconds: 10));

    final seenWords = <String>[];
    for (int i = 0; i < 4; i++) {
      final word = container.read(quizProvider).currentWord;
      if (word != null) {
        seenWords.add(word.word);
      }
      notifier.answer(word?.article ?? 'der');
      await notifier.loadNext();
    }

    // "Tisch" should only appear once
    expect(seenWords.where((w) => w == 'Tisch').length, 1);
  });

  test('Anti-clumping prevents 3 consecutive identical articles', () async {
    // A batch with 4 'die' words in a row followed by 'der'
    final batch = [
      const WordModel(word: 'Katze', article: 'die', gender: 'f', source: 'db'),
      const WordModel(word: 'Sonne', article: 'die', gender: 'f', source: 'db'),
      const WordModel(word: 'Lampe', article: 'die', gender: 'f', source: 'db'),
      const WordModel(word: 'Frau', article: 'die', gender: 'f', source: 'db'),
      const WordModel(word: 'Tisch', article: 'der', gender: 'm', source: 'db'),
      const WordModel(word: 'Buch', article: 'das', gender: 'n', source: 'db'),
    ];

    when(() => mockArticleRepo.randomBatch(count: any(named: 'count')))
        .thenAnswer((_) async => List<WordModel>.from(batch));
    when(() => mockArticleRepo.random()).thenAnswer((_) async =>
        const WordModel(word: 'Auto', article: 'das', gender: 'n', source: 'db'));

    final container = ProviderContainer(
      overrides: [
        articleRepositoryProvider.overrideWithValue(mockArticleRepo),
        historyRepositoryProvider.overrideWithValue(mockHistoryRepo),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(quizProvider.notifier);
    await Future.delayed(const Duration(milliseconds: 10));

    final articles = <String>[];
    for (int i = 0; i < 4; i++) {
      final word = container.read(quizProvider).currentWord;
      if (word != null) {
        articles.add(word.article);
      }
      notifier.answer(word?.article ?? 'der');
      await notifier.loadNext();
    }

    // Check no 3 in a row
    for (int i = 2; i < articles.length; i++) {
      final threeInARow = articles[i] == articles[i - 1] && articles[i] == articles[i - 2];
      expect(threeInARow, false,
          reason: '3 consecutive identical articles: ${articles[i-2]}, ${articles[i-1]}, ${articles[i]}');
    }
  });

  test('Fallback pool works offline when network throws', () async {
    when(() => mockArticleRepo.randomBatch(count: any(named: 'count')))
        .thenThrow(Exception('No internet'));
    when(() => mockArticleRepo.random()).thenThrow(Exception('No internet'));

    final container = ProviderContainer(
      overrides: [
        articleRepositoryProvider.overrideWithValue(mockArticleRepo),
        historyRepositoryProvider.overrideWithValue(mockHistoryRepo),
      ],
    );
    addTearDown(container.dispose);

    container.read(quizProvider.notifier);
    await Future.delayed(const Duration(milliseconds: 10));

    final word = container.read(quizProvider).currentWord;
    expect(word, isNotNull);
    expect(['der', 'die', 'das'], contains(word!.article));
    expect(word.source, 'offline');
  });
}
