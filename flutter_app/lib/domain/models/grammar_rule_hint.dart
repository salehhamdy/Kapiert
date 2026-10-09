/// Represents a grammatical gender rule or suffix guideline for German nouns.
/// Pure domain model — no Flutter or SDK imports.
class GrammarRuleHint {
  final String suffix;
  final String article; // "der" | "die" | "das"
  final String ruleEn;
  final String ruleDe;
  final String ruleAr;
  final String ruleTr;

  const GrammarRuleHint({
    required this.suffix,
    required this.article,
    required this.ruleEn,
    required this.ruleDe,
    required this.ruleAr,
    required this.ruleTr,
  });

  /// Returns the localized explanation for the given language code.
  String localizedRule(String languageCode) {
    switch (languageCode) {
      case 'de':
        return ruleDe;
      case 'ar':
        return ruleAr;
      case 'tr':
        return ruleTr;
      case 'en':
      default:
        return ruleEn;
    }
  }

  /// Finds a matching grammar rule for a noun and its known article.
  /// Returns null if no rule applies or if the noun is merely the suffix itself.
  static GrammarRuleHint? findFor(String word, String article) {
    final lower = word.trim().toLowerCase();
    final art = article.trim().toLowerCase();

    for (final rule in _rules) {
      if (rule.article == art && lower.endsWith(rule.suffix.toLowerCase())) {
        if (lower.length > rule.suffix.length) {
          return rule;
        }
      }
    }
    return null;
  }

  static const List<GrammarRuleHint> _rules = [
    // ── Feminine (die) ─────────────────────────────────────────────────────────
    GrammarRuleHint(
      suffix: 'ung',
      article: 'die',
      ruleEn: "Nouns ending in '-ung' are feminine (die).",
      ruleDe: "Nomen mit der Endung '-ung' sind feminin (die).",
      ruleAr: "الأسماء المنتهية بـ '-ung' تكون دائماً مؤنثة (die).",
      ruleTr: "'-ung' ekiyle biten isimler her zaman dişildir (die).",
    ),
    GrammarRuleHint(
      suffix: 'heit',
      article: 'die',
      ruleEn: "Nouns ending in '-heit' are feminine (die).",
      ruleDe: "Nomen mit der Endung '-heit' sind feminin (die).",
      ruleAr: "الأسماء المنتهية بـ '-heit' تكون دائماً مؤنثة (die).",
      ruleTr: "'-heit' ekiyle biten isimler her zaman dişildir (die).",
    ),
    GrammarRuleHint(
      suffix: 'keit',
      article: 'die',
      ruleEn: "Nouns ending in '-keit' are feminine (die).",
      ruleDe: "Nomen mit der Endung '-keit' sind feminin (die).",
      ruleAr: "الأسماء المنتهية بـ '-keit' تكون دائماً مؤنثة (die).",
      ruleTr: "'-keit' ekiyle biten isimler her zaman dişildir (die).",
    ),
    GrammarRuleHint(
      suffix: 'schaft',
      article: 'die',
      ruleEn: "Nouns ending in '-schaft' are feminine (die).",
      ruleDe: "Nomen mit der Endung '-schaft' sind feminin (die).",
      ruleAr: "الأسماء المنتهية بـ '-schaft' تكون دائماً مؤنثة (die).",
      ruleTr: "'-schaft' ekiyle biten isimler her zaman dişildir (die).",
    ),
    GrammarRuleHint(
      suffix: 'tion',
      article: 'die',
      ruleEn: "Nouns ending in '-tion' are feminine (die).",
      ruleDe: "Nomen mit der Endung '-tion' sind feminin (die).",
      ruleAr: "الأسماء المنتهية بـ '-tion' تكون دائماً مؤنثة (die).",
      ruleTr: "'-tion' ekiyle biten isimler her zaman dişildir (die).",
    ),
    GrammarRuleHint(
      suffix: 'ion',
      article: 'die',
      ruleEn: "Nouns ending in '-ion' are feminine (die).",
      ruleDe: "Nomen mit der Endung '-ion' sind feminin (die).",
      ruleAr: "الأسماء المنتهية بـ '-ion' تكون مؤنثة (die).",
      ruleTr: "'-ion' ekiyle biten isimler dişildir (die).",
    ),
    GrammarRuleHint(
      suffix: 'tät',
      article: 'die',
      ruleEn: "Nouns ending in '-tät' are feminine (die).",
      ruleDe: "Nomen mit der Endung '-tät' sind feminin (die).",
      ruleAr: "الأسماء المنتهية بـ '-tät' تكون دائماً مؤنثة (die).",
      ruleTr: "'-tät' ekiyle biten isimler her zaman dişildir (die).",
    ),
    GrammarRuleHint(
      suffix: 'ik',
      article: 'die',
      ruleEn: "Nouns ending in '-ik' are typically feminine (die).",
      ruleDe: "Nomen mit der Endung '-ik' sind meist feminin (die).",
      ruleAr: "الأسماء المنتهية بـ '-ik' تكون غالباً مؤنثة (die).",
      ruleTr: "'-ik' ekiyle biten isimler genellikle dişildir (die).",
    ),
    GrammarRuleHint(
      suffix: 'ei',
      article: 'die',
      ruleEn: "Nouns ending in '-ei' are feminine (die).",
      ruleDe: "Nomen mit der Endung '-ei' sind feminin (die).",
      ruleAr: "الأسماء المنتهية بـ '-ei' تكون مؤنثة (die).",
      ruleTr: "'-ei' ekiyle biten isimler dişildir (die).",
    ),
    GrammarRuleHint(
      suffix: 'ie',
      article: 'die',
      ruleEn: "Nouns ending in '-ie' are feminine (die).",
      ruleDe: "Nomen mit der Endung '-ie' sind feminin (die).",
      ruleAr: "الأسماء المنتهية بـ '-ie' تكون مؤنثة (die).",
      ruleTr: "'-ie' ekiyle biten isimler dişildir (die).",
    ),
    GrammarRuleHint(
      suffix: 'ur',
      article: 'die',
      ruleEn: "Nouns ending in '-ur' are feminine (die).",
      ruleDe: "Nomen mit der Endung '-ur' sind feminin (die).",
      ruleAr: "الأسماء المنتهية بـ '-ur' تكون مؤنثة (die).",
      ruleTr: "'-ur' ekiyle biten isimler dişildir (die).",
    ),
    GrammarRuleHint(
      suffix: 'in',
      article: 'die',
      ruleEn: "Female titles and professions ending in '-in' are feminine (die).",
      ruleDe: "Weibliche Berufs- und Personenbezeichnungen auf '-in' sind feminin (die).",
      ruleAr: "أسماء المهن والمؤنث المنتهية بـ '-in' تكون مؤنثة (die).",
      ruleTr: "'-in' ile biten kadın meslek ve şahıs isimleri dişildir (die).",
    ),

    // ── Neuter (das) ───────────────────────────────────────────────────────────
    GrammarRuleHint(
      suffix: 'chen',
      article: 'das',
      ruleEn: "Diminutives ending in '-chen' are always neuter (das).",
      ruleDe: "Verkleinerungsformen auf '-chen' sind immer neutral (das).",
      ruleAr: "صيغ التصغير المنتهية بـ '-chen' تكون محايدة دائماً (das).",
      ruleTr: "'-chen' küçültme ekiyle biten isimler her zaman nötrdür (das).",
    ),
    GrammarRuleHint(
      suffix: 'lein',
      article: 'das',
      ruleEn: "Diminutives ending in '-lein' are always neuter (das).",
      ruleDe: "Verkleinerungsformen auf '-lein' sind immer neutral (das).",
      ruleAr: "صيغ التصغير المنتهية بـ '-lein' تكون محايدة دائماً (das).",
      ruleTr: "'-lein' küçültme ekiyle biten isimler her zaman nötrdür (das).",
    ),
    GrammarRuleHint(
      suffix: 'ment',
      article: 'das',
      ruleEn: "Nouns ending in '-ment' are neuter (das).",
      ruleDe: "Nomen mit der Endung '-ment' sind neutral (das).",
      ruleAr: "الأسماء المنتهية بـ '-ment' تكون محايدة (das).",
      ruleTr: "'-ment' ekiyle biten isimler nötrdür (das).",
    ),
    GrammarRuleHint(
      suffix: 'um',
      article: 'das',
      ruleEn: "Latin-origin nouns ending in '-um' are neuter (das).",
      ruleDe: "Lateinische Fremdwörter auf '-um' sind neutral (das).",
      ruleAr: "الأسماء ذات الأصل اللاتيني المنتهية بـ '-um' تكون محايدة (das).",
      ruleTr: "'-um' ekiyle biten Latince kökenli isimler nötrdür (das).",
    ),
    GrammarRuleHint(
      suffix: 'tum',
      article: 'das',
      ruleEn: "Nouns ending in '-tum' are neuter (das).",
      ruleDe: "Nomen mit der Endung '-tum' sind neutral (das).",
      ruleAr: "الأسماء المنتهية بـ '-tum' تكون محايدة (das).",
      ruleTr: "'-tum' ekiyle biten isimler nötrdür (das).",
    ),
    GrammarRuleHint(
      suffix: 'ma',
      article: 'das',
      ruleEn: "Greek-origin nouns ending in '-ma' are neuter (das).",
      ruleDe: "Griechische Fremdwörter auf '-ma' sind neutral (das).",
      ruleAr: "الأسماء ذات الأصل اليوناني المنتهية بـ '-ma' تكون محايدة (das).",
      ruleTr: "'-ma' ile biten Yunanca kökenli isimler nötrdür (das).",
    ),

    // ── Masculine (der) ────────────────────────────────────────────────────────
    GrammarRuleHint(
      suffix: 'ismus',
      article: 'der',
      ruleEn: "Nouns ending in '-ismus' are always masculine (der).",
      ruleDe: "Nomen mit der Endung '-ismus' sind immer maskulin (der).",
      ruleAr: "الأسماء المنتهية بـ '-ismus' تكون دائماً مذكرة (der).",
      ruleTr: "'-ismus' ekiyle biten isimler her zaman erildir (der).",
    ),
    GrammarRuleHint(
      suffix: 'ling',
      article: 'der',
      ruleEn: "Nouns ending in '-ling' are masculine (der).",
      ruleDe: "Nomen mit der Endung '-ling' sind maskulin (der).",
      ruleAr: "الأسماء المنتهية بـ '-ling' تكون مذكرة (der).",
      ruleTr: "'-ling' ekiyle biten isimler erildir (der).",
    ),
    GrammarRuleHint(
      suffix: 'ist',
      article: 'der',
      ruleEn: "Person nouns ending in '-ist' are masculine (der).",
      ruleDe: "Personenbezeichnungen auf '-ist' sind maskulin (der).",
      ruleAr: "أسماء الأشخاص المنتهية بـ '-ist' تكون مذكرة (der).",
      ruleTr: "'-ist' ekiyle biten kişi isimleri erildir (der).",
    ),
    GrammarRuleHint(
      suffix: 'or',
      article: 'der',
      ruleEn: "Nouns ending in '-or' are masculine (der).",
      ruleDe: "Nomen mit der Endung '-or' sind maskulin (der).",
      ruleAr: "الأسماء المنتهية بـ '-or' تكون مذكرة (der).",
      ruleTr: "'-or' ekiyle biten isimler erildir (der).",
    ),
    GrammarRuleHint(
      suffix: 'ant',
      article: 'der',
      ruleEn: "Nouns ending in '-ant' are masculine (der).",
      ruleDe: "Nomen mit der Endung '-ant' sind maskulin (der).",
      ruleAr: "الأسماء المنتهية بـ '-ant' تكون مذكرة (der).",
      ruleTr: "'-ant' ekiyle biten isimler erildir (der).",
    ),
    GrammarRuleHint(
      suffix: 'ent',
      article: 'der',
      ruleEn: "Nouns ending in '-ent' are masculine (der).",
      ruleDe: "Nomen mit der Endung '-ent' sind maskulin (der).",
      ruleAr: "الأسماء المنتهية بـ '-ent' تكون مذكرة (der).",
      ruleTr: "'-ent' ekiyle biten isimler erildir (der).",
    ),
  ];
}
