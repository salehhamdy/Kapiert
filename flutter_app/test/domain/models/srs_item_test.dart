import 'package:flutter_test/flutter_test.dart';
import 'package:derdiedas/domain/models/srs_item.dart';

void main() {
  group('SrsItem Domain Model', () {
    final baseDate = DateTime.utc(2026, 10, 7, 12, 0, 0);

    test('Initial item properties and getters', () {
      final item = SrsItem(
        word: 'Buch',
        article: 'das',
        gender: 'n',
        stage: 1,
        consecutiveCorrect: 0,
        totalAttempts: 0,
        totalCorrect: 0,
        nextReview: baseDate.add(const Duration(hours: 4)),
      );

      expect(item.word, 'Buch');
      expect(item.article, 'das');
      expect(item.stage, 1);
      expect(item.stageName, 'Learning');
      expect(item.isMastered, false);
      expect(item.accuracy, 0.0);
    });

    test('isDue correctly detects overdue vs future review dates', () {
      final past = DateTime.now().toUtc().subtract(const Duration(minutes: 5));
      final future = DateTime.now().toUtc().add(const Duration(hours: 2));

      final overdueItem = SrsItem(
        word: 'Hund',
        article: 'der',
        gender: 'm',
        nextReview: past,
      );
      final futureItem = SrsItem(
        word: 'Katze',
        article: 'die',
        gender: 'f',
        nextReview: future,
      );

      expect(overdueItem.isDue, isTrue);
      expect(futureItem.isDue, isFalse);
    });

    test('recordAttempt with correct answer advances stages and intervals', () {
      final start = SrsItem(
        word: 'Tisch',
        article: 'der',
        gender: 'm',
        stage: 1,
        consecutiveCorrect: 0,
        totalAttempts: 0,
        totalCorrect: 0,
        nextReview: baseDate,
      );

      // Attempt 1: Stage 1 -> 2 (1 day interval)
      final step1 = start.recordAttempt(correct: true, now: baseDate);
      expect(step1.stage, 2);
      expect(step1.stageName, 'Review');
      expect(step1.consecutiveCorrect, 1);
      expect(step1.totalAttempts, 1);
      expect(step1.totalCorrect, 1);
      expect(step1.nextReview, baseDate.add(const Duration(days: 1)));

      // Attempt 2: Stage 2 -> 3 (3 days interval)
      final step2 = step1.recordAttempt(correct: true, now: baseDate);
      expect(step2.stage, 3);
      expect(step2.stageName, 'Familiar');
      expect(step2.consecutiveCorrect, 2);
      expect(step2.nextReview, baseDate.add(const Duration(days: 3)));

      // Attempt 3: Stage 3 -> 4 (7 days interval)
      final step3 = step2.recordAttempt(correct: true, now: baseDate);
      expect(step3.stage, 4);
      expect(step3.stageName, 'Solid');
      expect(step3.consecutiveCorrect, 3);
      expect(step3.nextReview, baseDate.add(const Duration(days: 7)));

      // Attempt 4: Stage 4 -> 5 (14 days interval, Mastered)
      final step4 = step3.recordAttempt(correct: true, now: baseDate);
      expect(step4.stage, 5);
      expect(step4.stageName, 'Mastered');
      expect(step4.isMastered, isTrue);
      expect(step4.consecutiveCorrect, 4);
      expect(step4.nextReview, baseDate.add(const Duration(days: 14)));

      // Attempt 5: Caps at Stage 5
      final step5 = step4.recordAttempt(correct: true, now: baseDate);
      expect(step5.stage, 5);
      expect(step5.consecutiveCorrect, 5);
    });

    test('recordAttempt with incorrect answer resets streak and demotes stage', () {
      final mastered = SrsItem(
        word: 'Fenster',
        article: 'das',
        gender: 'n',
        stage: 4,
        consecutiveCorrect: 3,
        totalAttempts: 5,
        totalCorrect: 4,
        nextReview: baseDate,
      );

      final failed = mastered.recordAttempt(correct: false, now: baseDate);
      expect(failed.stage, 2); // Drops from 4 to 2
      expect(failed.consecutiveCorrect, 0);
      expect(failed.totalAttempts, 6);
      expect(failed.totalCorrect, 4);
      expect(failed.nextReview, baseDate.add(const Duration(hours: 4))); // Due soon
    });

    test('toMap and fromMap preserves all fields', () {
      final original = SrsItem(
        id: 42,
        word: 'Zeitung',
        article: 'die',
        gender: 'f',
        plural: 'Zeitungen',
        translation: 'newspaper',
        stage: 3,
        consecutiveCorrect: 2,
        totalAttempts: 4,
        totalCorrect: 3,
        lastReviewed: baseDate,
        nextReview: baseDate.add(const Duration(days: 3)),
      );

      final map = original.toMap();
      final reconstructed = SrsItem.fromMap(map);

      expect(reconstructed.id, 42);
      expect(reconstructed.word, 'Zeitung');
      expect(reconstructed.article, 'die');
      expect(reconstructed.gender, 'f');
      expect(reconstructed.plural, 'Zeitungen');
      expect(reconstructed.translation, 'newspaper');
      expect(reconstructed.stage, 3);
      expect(reconstructed.consecutiveCorrect, 2);
      expect(reconstructed.totalAttempts, 4);
      expect(reconstructed.totalCorrect, 3);
      expect(reconstructed.lastReviewed, baseDate);
      expect(reconstructed.nextReview, baseDate.add(const Duration(days: 3)));
    });

    test('toWordModel converts correctly', () {
      final item = SrsItem(
        word: 'Auto',
        article: 'das',
        gender: 'n',
        plural: 'Autos',
        translation: 'car',
        nextReview: baseDate,
      );

      final wordModel = item.toWordModel();
      expect(wordModel.word, 'Auto');
      expect(wordModel.article, 'das');
      expect(wordModel.gender, 'n');
      expect(wordModel.plural, 'Autos');
      expect(wordModel.translation, 'car');
      expect(wordModel.source, 'srs');
    });
  });
}
