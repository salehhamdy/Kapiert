import 'package:flutter_test/flutter_test.dart';
import 'package:derdiedas/domain/models/daily_activity.dart';

void main() {
  group('DailyActivity Model Tests', () {
    test('calculates accuracy percentage accurately', () {
      final act1 = DailyActivity(
        date: DateTime.utc(2026, 10, 7),
        totalCount: 15,
        quizCount: 10,
        quizCorrect: 8,
        lookupCount: 5,
        uniqueWords: 12,
      );
      expect(act1.accuracy, 80.0);
      expect(act1.hasActivity, isTrue);

      final actEmpty = DailyActivity.empty(DateTime.utc(2026, 10, 6));
      expect(actEmpty.accuracy, 0.0);
      expect(actEmpty.hasActivity, isFalse);
      expect(actEmpty.intensityLevel, 0);
    });

    test('intensityLevel categorizes counts according to scale', () {
      DailyActivity make(int total) => DailyActivity(
            date: DateTime.utc(2026, 10, 7),
            totalCount: total,
            quizCount: total,
            quizCorrect: total,
            lookupCount: 0,
            uniqueWords: total,
          );

      expect(make(0).intensityLevel, 0);
      expect(make(1).intensityLevel, 1);
      expect(make(4).intensityLevel, 1);
      expect(make(5).intensityLevel, 2);
      expect(make(9).intensityLevel, 2);
      expect(make(10).intensityLevel, 3);
      expect(make(19).intensityLevel, 3);
      expect(make(20).intensityLevel, 4);
      expect(make(50).intensityLevel, 4);
    });

    test('toMap converts date to yyyy-MM-dd string and holds values', () {
      final act = DailyActivity(
        date: DateTime.utc(2026, 10, 7, 14, 30),
        totalCount: 12,
        quizCount: 8,
        quizCorrect: 7,
        lookupCount: 4,
        uniqueWords: 9,
      );
      final map = act.toMap();
      expect(map['date'], '2026-10-07');
      expect(map['totalCount'], 12);
      expect(map['quizCount'], 8);
      expect(map['quizCorrect'], 7);
      expect(map['lookupCount'], 4);
      expect(map['uniqueWords'], 9);
    });
  });
}
