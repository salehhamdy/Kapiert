import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:derdiedas/core/localization/app_localizations.dart';

void main() {
  group('AppLanguage Enum', () {
    test('resolves supported languages from code', () {
      expect(AppLanguage.fromCode('en'), AppLanguage.english);
      expect(AppLanguage.fromCode('ar'), AppLanguage.arabic);
      expect(AppLanguage.fromCode('tr'), AppLanguage.turkish);
      expect(AppLanguage.fromCode('de'), AppLanguage.german);
      expect(AppLanguage.fromCode('unknown'), AppLanguage.english);
    });

    test('arabic is flagged as RTL', () {
      expect(AppLanguage.arabic.isRtl, isTrue);
      expect(AppLanguage.english.isRtl, isFalse);
      expect(AppLanguage.turkish.isRtl, isFalse);
      expect(AppLanguage.german.isRtl, isFalse);
    });

    test('supportedLocales contains all 4 supported language codes', () {
      final codes = AppLanguage.supportedLocales.map((l) => l.languageCode).toList();
      expect(codes, containsAll(['en', 'ar', 'tr', 'de']));
    });
  });

  group('AppLocalizations Strings', () {
    test('provides English translations', () {
      final l10n = AppLocalizations(const Locale('en'));
      expect(l10n.tabLookup, 'Lookup');
      expect(l10n.tabQuiz, 'Quiz');
      expect(l10n.tabHistory, 'History');
      expect(l10n.tabSettings, 'Settings');
      expect(l10n.exampleSentenceHeader, 'Example in context');
      expect(l10n.isRtl, isFalse);
      expect(l10n.textDirection, TextDirection.ltr);
    });

    test('provides Arabic translations and RTL layout', () {
      final l10n = AppLocalizations(const Locale('ar'));
      expect(l10n.tabLookup, 'البحث');
      expect(l10n.tabQuiz, 'اختبار');
      expect(l10n.tabHistory, 'السجل');
      expect(l10n.tabSettings, 'الإعدادات');
      expect(l10n.exampleSentenceHeader, 'مثال في سياق الجملة');
      expect(l10n.isRtl, isTrue);
      expect(l10n.textDirection, TextDirection.rtl);
    });

    test('provides Turkish translations', () {
      final l10n = AppLocalizations(const Locale('tr'));
      expect(l10n.tabLookup, 'Arama');
      expect(l10n.tabQuiz, 'Alıştırma');
      expect(l10n.tabHistory, 'Geçmiş');
      expect(l10n.tabSettings, 'Ayarlar');
      expect(l10n.exampleSentenceHeader, 'Cümle içinde kullanım');
      expect(l10n.isRtl, isFalse);
    });

    test('provides German translations', () {
      final l10n = AppLocalizations(const Locale('de'));
      expect(l10n.tabLookup, 'Nachschlagen');
      expect(l10n.tabQuiz, 'Quiz');
      expect(l10n.tabHistory, 'Verlauf');
      expect(l10n.tabSettings, 'Einstellungen');
      expect(l10n.exampleSentenceHeader, 'Beispielsatz im Kontext');
      expect(l10n.isRtl, isFalse);
    });

    test('delegate reports supported locales properly', () {
      const delegate = AppLocalizationsDelegate();
      expect(delegate.isSupported(const Locale('en')), isTrue);
      expect(delegate.isSupported(const Locale('ar')), isTrue);
      expect(delegate.isSupported(const Locale('tr')), isTrue);
      expect(delegate.isSupported(const Locale('de')), isTrue);
      expect(delegate.isSupported(const Locale('fr')), isFalse);
    });

    test('dynamic helpers and parameterized strings return correct translations for all locales', () {
      for (final code in ['en', 'ar', 'tr', 'de']) {
        final l = AppLocalizations(Locale(code));
        expect(l.srsStageName(1), isNotEmpty);
        expect(l.srsStageName(2), isNotEmpty);
        expect(l.srsStageName(4), isNotEmpty);
        expect(l.srsIntervalText(1), isNotEmpty);
        expect(l.genderLabel('m'), isNotEmpty);
        expect(l.genderLabel('f'), isNotEmpty);
        expect(l.genderLabel('n'), isNotEmpty);
        expect(l.sourceLabel('dataset'), isNotEmpty);
        expect(l.sourceLabel('wiktionary'), isNotEmpty);
        expect(l.wordsCount(5), isNotEmpty);
        expect(l.percentCorrect(85), isNotEmpty);
        expect(l.percentOfTrackedWords(70), isNotEmpty);
        expect(l.badgesEarned(3, 10, 30), isNotEmpty);
        expect(l.unlockedCountOfTotal(3, 10), isNotEmpty);
        expect(l.exploreAllMilestones(12), isNotEmpty);
        expect(l.activeDaysThisWeek(5), isNotEmpty);
        expect(l.focusOnLowestAccuracy('der'), isNotEmpty);
        expect(l.dayActivitySummary(10, 8, 90, 6), isNotEmpty);
        expect(l.categoryLabel('streak'), isNotEmpty);
        expect(l.categoryLabel('vocabulary'), isNotEmpty);
        expect(l.milestoneUnlocked('First Step'), isNotEmpty);
        expect(l.nextReviewIn('1 day'), isNotEmpty);
        expect(l.reviewIn('4 hours'), isNotEmpty);
      }

      final en = AppLocalizations(const Locale('en'));
      expect(en.genderLabel('m'), 'masculine');
      expect(en.srsIntervalText(2), '1 day');
      expect(en.wordsCount(1), '1 word');
      expect(en.wordsCount(2), '2 words');

      final de = AppLocalizations(const Locale('de'));
      expect(de.genderLabel('m'), 'maskulin');
      expect(de.srsIntervalText(2), '1 Tag');
      expect(de.wordsCount(1), '1 Wort');
      expect(de.wordsCount(2), '2 Wörter');

      final ar = AppLocalizations(const Locale('ar'));
      expect(ar.genderLabel('f'), 'مؤنث');
      expect(ar.srsIntervalText(2), 'يوم واحد');

      final tr = AppLocalizations(const Locale('tr'));
      expect(tr.genderLabel('n'), 'nötr');
      expect(tr.srsIntervalText(2), '1 gün');
    });
  });
}

