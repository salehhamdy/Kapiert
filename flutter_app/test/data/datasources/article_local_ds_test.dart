import 'package:flutter_test/flutter_test.dart';
import 'package:derdiedas/data/datasources/article_local_ds.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ArticleLocalDS localDS;

  setUp(() {
    localDS = const ArticleLocalDS();
  });

  group('ArticleLocalDS Core Lookups & Normalization', () {
    test('normalizes leading articles and looks up masculine noun', () async {
      final result1 = await localDS.lookup('Tisch');
      expect(result1, isNotNull);
      expect(result1!.article, equals('der'));
      expect(result1.gender, equals('m'));
      expect(result1.word, equals('Tisch'));

      final result2 = await localDS.lookup('der Tisch');
      expect(result2, isNotNull);
      expect(result2!.article, equals('der'));

      final result3 = await localDS.lookup(' ein Tisch! ');
      expect(result3, isNotNull);
      expect(result3!.article, equals('der'));
    });

    test('normalizes and looks up feminine noun', () async {
      final result1 = await localDS.lookup('Katze');
      expect(result1, isNotNull);
      expect(result1!.article, equals('die'));
      expect(result1.gender, equals('f'));

      final result2 = await localDS.lookup('die Katze');
      expect(result2, isNotNull);
      expect(result2!.article, equals('die'));

      final result3 = await localDS.lookup('eine Katze');
      expect(result3, isNotNull);
      expect(result3!.article, equals('die'));
    });

    test('normalizes and looks up neuter noun', () async {
      final result1 = await localDS.lookup('Buch');
      expect(result1, isNotNull);
      expect(result1!.article, equals('das'));
      expect(result1.gender, equals('n'));

      final result2 = await localDS.lookup('das Buch');
      expect(result2, isNotNull);
      expect(result2!.article, equals('das'));
    });

    test('handles case insensitivity cleanly', () async {
      final result = await localDS.lookup('apfel');
      expect(result, isNotNull);
      expect(result!.word, equals('Apfel'));
      expect(result.article, equals('der'));
    });

    test('performs compound noun suffix inheritance for masculine base', () async {
      // "Küchentisch" ends with "tisch" -> should inherit "der"
      final result = await localDS.lookup('Küchentisch');
      expect(result, isNotNull);
      expect(result!.article, equals('der'));
      expect(result.gender, equals('m'));
      expect(result.word, equals('Küchentisch'));
    });

    test('performs compound noun suffix inheritance for feminine base', () async {
      // "Haustür" ends with "tür" -> should inherit "die"
      final result = await localDS.lookup('Haustür');
      expect(result, isNotNull);
      expect(result!.article, equals('die'));
      expect(result.gender, equals('f'));
    });

    test('performs compound noun suffix inheritance for neuter base', () async {
      // "Wohnzimmer" ends with "zimmer" -> should inherit "das"
      final result = await localDS.lookup('Wohnzimmer');
      expect(result, isNotNull);
      expect(result!.article, equals('das'));
      expect(result.gender, equals('n'));
    });

    test('returns null for unknown non-existent words', () async {
      final result = await localDS.lookup('xyzrandomword123');
      expect(result, isNull);
    });

    test('getRandomWord returns a valid core vocabulary WordModel', () async {
      final word = await localDS.getRandomWord();
      expect(word, isNotNull);
      expect(['der', 'die', 'das'], contains(word!.article));
    });

    test('getRandomBatch returns requested batch count of unique words', () async {
      final batch = await localDS.getRandomBatch(count: 10);
      expect(batch.length, equals(10));
      for (final word in batch) {
        expect(['der', 'die', 'das'], contains(word.article));
      }
    });
  });
}
