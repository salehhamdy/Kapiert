import 'package:flutter_test/flutter_test.dart';
import 'package:derdiedas/domain/models/word_model.dart';

void main() {
  group('WordModel', () {
    test('fullForm returns article and word', () {
      const word = WordModel(
        word: 'Buch',
        article: 'das',
        gender: 'n',
        source: 'dataset',
      );

      expect(word.fullForm, 'das Buch');
    });

    test('genderLabel returns human readable gender', () {
      const mWord = WordModel(word: 'Hund', article: 'der', gender: 'm', source: 'dataset');
      const fWord = WordModel(word: 'Katze', article: 'die', gender: 'f', source: 'dataset');
      const nWord = WordModel(word: 'Haus', article: 'das', gender: 'n', source: 'dataset');
      const otherWord = WordModel(word: 'Eltern', article: 'die', gender: 'pl', source: 'dataset');

      expect(mWord.genderLabel, 'masculine');
      expect(fWord.genderLabel, 'feminine');
      expect(nWord.genderLabel, 'neuter');
      expect(otherWord.genderLabel, 'pl');
    });

    test('sourceLabel returns readable source', () {
      const dbWord = WordModel(word: 'Apfel', article: 'der', gender: 'm', source: 'dataset');
      const wikiWord = WordModel(word: 'Computer', article: 'der', gender: 'm', source: 'wiktionary');
      const unknownWord = WordModel(word: 'Test', article: 'der', gender: 'm', source: 'other');

      expect(dbWord.sourceLabel, 'from dataset');
      expect(wikiWord.sourceLabel, 'via Wiktionary');
      expect(unknownWord.sourceLabel, 'other');
    });

    test('toJson returns correct map', () {
      const word = WordModel(
        word: 'Tisch',
        article: 'der',
        gender: 'm',
        plural: 'Tische',
        translation: 'table',
        source: 'dataset',
      );

      final json = word.toJson();

      expect(json, {
        'word': 'Tisch',
        'article': 'der',
        'gender': 'm',
        'plural': 'Tische',
        'translation': 'table',
        'source': 'dataset',
      });
    });

    test('equality checks word and article', () {
      const word1 = WordModel(word: 'Stuhl', article: 'der', gender: 'm', source: 'dataset');
      const word2 = WordModel(word: 'Stuhl', article: 'der', gender: 'm', source: 'dataset');
      const word3 = WordModel(word: 'Stuhl', article: 'die', gender: 'f', source: 'dataset');
      const word4 = WordModel(word: 'Haus', article: 'der', gender: 'n', source: 'dataset');

      expect(word1, equals(word2));
      expect(word1, isNot(equals(word3)));
      expect(word1, isNot(equals(word4)));
    });
  });
}
