import 'package:flutter_test/flutter_test.dart';
import 'package:derdiedas/domain/models/example_sentence.dart';
import 'package:derdiedas/domain/models/local_sentence_provider.dart';
import 'package:derdiedas/domain/models/word_model.dart';

void main() {
  group('ExampleSentence Model', () {
    test('instantiates with German and multilingual translations', () {
      const sentence = ExampleSentence(
        german: 'Das Buch liegt auf dem Tisch.',
        english: 'The book is on the table.',
        arabic: 'الكتاب موجود على الطاولة.',
        turkish: 'Kitap masanın üstünde duruyor.',
      );

      expect(sentence.german, 'Das Buch liegt auf dem Tisch.');
      expect(sentence.sentence, 'Das Buch liegt auf dem Tisch.');
      expect(sentence.english, 'The book is on the table.');
      expect(sentence.translation, 'The book is on the table.');
      expect(sentence.arabic, 'الكتاب موجود على الطاولة.');
      expect(sentence.turkish, 'Kitap masanın üstünde duruyor.');
    });

    test('translationFor returns appropriate translation for each language', () {
      const sentence = ExampleSentence(
        german: 'Die Katze schläft auf dem Sofa.',
        english: 'The cat is sleeping on the couch.',
        arabic: 'القطة تنام على الأريكة.',
        turkish: 'Kedi kanepede uyuyor.',
      );

      expect(sentence.translationFor('de'), 'Die Katze schläft auf dem Sofa.');
      expect(sentence.translationFor('en'), 'The cat is sleeping on the couch.');
      expect(sentence.translationFor('ar'), 'القطة تنام على الأريكة.');
      expect(sentence.translationFor('tr'), 'Kedi kanepede uyuyor.');
    });

    test('translationFor falls back gracefully to English when language missing', () {
      const sentence = ExampleSentence(
        german: 'Der Hund bellt laut.',
        english: 'The dog barks loudly.',
      );

      expect(sentence.translationFor('ar'), 'The dog barks loudly.');
      expect(sentence.translationFor('tr'), 'The dog barks loudly.');
      expect(sentence.translationFor('fr'), 'The dog barks loudly.');
      expect(sentence.translationFor('de'), 'Der Hund bellt laut.');
    });

    test('fromJson parses API payload correctly', () {
      final json = {
        'example_sentence': 'Der Tisch ist aus Holz.',
        'example_translation': 'The table is made of wood.',
        'example_translations': {
          'de': 'Der Tisch ist aus Holz.',
          'en': 'The table is made of wood.',
          'ar': 'الطاولة مصنوعة من الخشب.',
          'tr': 'Masa ahşaptan yapılmıştır.',
        },
      };

      final parsed = ExampleSentence.fromJson(json);

      expect(parsed.german, 'Der Tisch ist aus Holz.');
      expect(parsed.english, 'The table is made of wood.');
      expect(parsed.arabic, 'الطاولة مصنوعة من الخشب.');
      expect(parsed.turkish, 'Masa ahşaptan yapılmıştır.');
    });

    test('toJson serializes correctly', () {
      const sentence = ExampleSentence(
        german: 'Das Haus ist sehr groß.',
        english: 'The house is very big.',
        arabic: 'المنزل كبير جداً.',
        turkish: 'Ev çok büyüktür.',
      );

      final map = sentence.toJson();
      expect(map['german'], 'Das Haus ist sehr groß.');
      expect(map['english'], 'The house is very big.');
      expect(map['arabic'], 'المنزل كبير جداً.');
      expect(map['turkish'], 'Ev çok büyüktür.');
    });
  });

  group('LocalSentenceProvider', () {
    test('returns curated sentence for known nouns', () {
      final tisch = LocalSentenceProvider.getSentence('Tisch', 'der');
      expect(tisch.german, contains('Tisch'));
      expect(tisch.arabic, isNotNull);
      expect(tisch.turkish, isNotNull);

      final buch = LocalSentenceProvider.getSentence('buch', 'das');
      expect(buch.german, contains('Buch'));

      final katze = LocalSentenceProvider.getSentence('Katze', 'die');
      expect(katze.german, contains('Katze'));
    });

    test('generates sensible dynamic sentences for arbitrary words', () {
      final mWord = LocalSentenceProvider.getSentence('Zeppelin', 'der');
      expect(mWord.german, contains('Zeppelin'));
      expect(mWord.german, contains('der'));
      expect(mWord.english, contains('Zeppelin'));
      expect(mWord.english, contains('masculine'));
      expect(mWord.arabic, contains('Zeppelin'));
      expect(mWord.turkish, contains('Zeppelin'));

      final fWord = LocalSentenceProvider.getSentence('Rakete', 'die');
      expect(fWord.german, contains('Rakete'));
      expect(fWord.german, contains('die'));
      expect(fWord.english, contains('feminine'));

      final nWord = LocalSentenceProvider.getSentence(
        'Mikroskop',
        'das',
        translation: 'microscope',
      );
      expect(nWord.german, contains('Mikroskop'));
      expect(nWord.english, contains('microscope'));
    });

    test('WordModel integrates with resolvedExampleSentence', () {
      const wordWithApiSentence = WordModel(
        word: 'Fenster',
        article: 'das',
        gender: 'n',
        source: 'api',
        exampleSentence: ExampleSentence(
          german: 'Das Fenster ist offen.',
          english: 'The window is open.',
        ),
      );

      expect(
        wordWithApiSentence.resolvedExampleSentence.german,
        'Das Fenster ist offen.',
      );

      const wordWithoutSentence = WordModel(
        word: 'Kaffee',
        article: 'der',
        gender: 'm',
        source: 'local',
      );

      expect(
        wordWithoutSentence.resolvedExampleSentence.german,
        contains('Kaffee'),
      );
    });
  });
}
