import 'package:flutter_test/flutter_test.dart';
import 'package:derdiedas/domain/models/grammar_rule_hint.dart';

void main() {
  group('GrammarRuleHint Tests', () {
    test('identifies feminine suffixes correctly', () {
      final ungHint = GrammarRuleHint.findFor('Zeitung', 'die');
      expect(ungHint, isNotNull);
      expect(ungHint!.suffix, 'ung');
      expect(ungHint.article, 'die');

      final heitHint = GrammarRuleHint.findFor('Freiheit', 'die');
      expect(heitHint, isNotNull);
      expect(heitHint!.suffix, 'heit');

      final keitHint = GrammarRuleHint.findFor('Möglichkeit', 'die');
      expect(keitHint, isNotNull);
      expect(keitHint!.suffix, 'keit');

      final schaftHint = GrammarRuleHint.findFor('Freundschaft', 'die');
      expect(schaftHint, isNotNull);
      expect(schaftHint!.suffix, 'schaft');

      final ionHint = GrammarRuleHint.findFor('Station', 'die');
      expect(ionHint, isNotNull);

      final tatHint = GrammarRuleHint.findFor('Universität', 'die');
      expect(tatHint, isNotNull);
      expect(tatHint!.suffix, 'tät');
    });

    test('identifies neuter suffixes correctly', () {
      final chenHint = GrammarRuleHint.findFor('Mädchen', 'das');
      expect(chenHint, isNotNull);
      expect(chenHint!.suffix, 'chen');
      expect(chenHint.article, 'das');

      final leinHint = GrammarRuleHint.findFor('Fräulein', 'das');
      expect(leinHint, isNotNull);
      expect(leinHint!.suffix, 'lein');

      final mentHint = GrammarRuleHint.findFor('Dokument', 'das');
      expect(mentHint, isNotNull);
      expect(mentHint!.suffix, 'ment');

      final umHint = GrammarRuleHint.findFor('Museum', 'das');
      expect(umHint, isNotNull);
      expect(umHint!.suffix, 'um');
    });

    test('identifies masculine suffixes correctly', () {
      final ismusHint = GrammarRuleHint.findFor('Optimismus', 'der');
      expect(ismusHint, isNotNull);
      expect(ismusHint!.suffix, 'ismus');
      expect(ismusHint.article, 'der');

      final lingHint = GrammarRuleHint.findFor('Schmetterling', 'der');
      expect(lingHint, isNotNull);
      expect(lingHint!.suffix, 'ling');

      final orHint = GrammarRuleHint.findFor('Motor', 'der');
      expect(orHint, isNotNull);
      expect(orHint!.suffix, 'or');

      final istHint = GrammarRuleHint.findFor('Tourist', 'der');
      expect(istHint, isNotNull);
      expect(istHint!.suffix, 'ist');
    });

    test('returns null if word does not match known rule or article differs', () {
      // "Tisch" has no suffix rule
      expect(GrammarRuleHint.findFor('Tisch', 'der'), isNull);

      // Suffix without matching article doesn't produce false rule
      expect(GrammarRuleHint.findFor('Sprung', 'der'), isNull);

      // Word identical to suffix with no stem returns null
      expect(GrammarRuleHint.findFor('ung', 'die'), isNull);
    });

    test('returns localized rule string across all 4 languages', () {
      final hint = GrammarRuleHint.findFor('Zeitung', 'die')!;
      expect(hint.localizedRule('en'), contains("Nouns ending in '-ung'"));
      expect(hint.localizedRule('de'), contains("Nomen mit der Endung '-ung'"));
      expect(hint.localizedRule('ar'), contains("الأسماء المنتهية بـ '-ung'"));
      expect(hint.localizedRule('tr'), contains("'-ung' ekiyle biten"));
    });

    test('allRules exposes full catalog of German article suffix guidelines', () {
      final rules = GrammarRuleHint.allRules;
      expect(rules.length, greaterThanOrEqualTo(24));

      final derRules = rules.where((r) => r.article == 'der').toList();
      final dieRules = rules.where((r) => r.article == 'die').toList();
      final dasRules = rules.where((r) => r.article == 'das').toList();

      expect(derRules.isNotEmpty, isTrue);
      expect(dieRules.isNotEmpty, isTrue);
      expect(dasRules.isNotEmpty, isTrue);

      for (final rule in rules) {
        expect(rule.suffix, isNotEmpty);
        expect(['der', 'die', 'das'].contains(rule.article), isTrue);
        expect(rule.reliabilityPercent, inInclusiveRange(70, 100));
        expect(rule.examples, isNotEmpty);
        for (final ex in rule.examples) {
          expect(ex.toLowerCase(), endsWith(rule.suffix.toLowerCase()));
        }
      }
    });
  });
}
