import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/material.dart';

/// Supported application languages.
enum AppLanguage {
  english(code: 'en', englishName: 'English', nativeName: 'English', flag: '🇬🇧'),
  arabic(code: 'ar', englishName: 'Arabic', nativeName: 'العربية', flag: '🇸🇦', isRtl: true),
  turkish(code: 'tr', englishName: 'Turkish', nativeName: 'Türkçe', flag: '🇹🇷'),
  german(code: 'de', englishName: 'German', nativeName: 'Deutsch', flag: '🇩🇪');

  final String code;
  final String englishName;
  final String nativeName;
  final String flag;
  final bool isRtl;

  const AppLanguage({
    required this.code,
    required this.englishName,
    required this.nativeName,
    required this.flag,
    this.isRtl = false,
  });

  static AppLanguage fromCode(String code) {
    return AppLanguage.values.firstWhere(
      (lang) => lang.code == code,
      orElse: () => AppLanguage.english,
    );
  }

  Locale get locale => Locale(code);

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('ar'),
    Locale('tr'),
    Locale('de'),
  ];
}

/// Provides localized strings across English, Arabic, Turkish, and German.
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('en'));
  }

  String get languageCode => locale.languageCode;
  bool get isRtl => languageCode == 'ar';
  TextDirection get textDirection =>
      isRtl ? TextDirection.rtl : TextDirection.ltr;

  // ── Navigation Tabs ────────────────────────────────────────────────────────
  String get tabLookup => _t({
        'en': 'Lookup',
        'ar': 'البحث',
        'tr': 'Arama',
        'de': 'Nachschlagen',
      });

  String get tabQuiz => _t({
        'en': 'Quiz',
        'ar': 'اختبار',
        'tr': 'Alıştırma',
        'de': 'Quiz',
      });

  String get tabHistory => _t({
        'en': 'History',
        'ar': 'السجل',
        'tr': 'Geçmiş',
        'de': 'Verlauf',
      });

  String get tabSettings => _t({
        'en': 'Settings',
        'ar': 'الإعدادات',
        'tr': 'Ayarlar',
        'de': 'Einstellungen',
      });

  // ── Lookup Screen ──────────────────────────────────────────────────────────
  String get searchHint => _t({
        'en': 'Search German noun… (e.g. Buch, Katze)',
        'ar': 'ابحث عن اسم ألماني… (مثل Buch, Katze)',
        'tr': 'Almanca isim ara… (örn. Buch, Katze)',
        'de': 'Deutsches Nomen suchen… (z.B. Buch, Katze)',
      });

  String get lookupTitle => _t({
        'en': 'German Articles',
        'ar': 'أدوات التعريف الألمانية',
        'tr': 'Almanca Tanımlıklar',
        'de': 'Deutsche Artikel',
      });

  String get lookupSubtitle => _t({
        'en': 'Master der, die, das with instant lookup and rich context.',
        'ar': 'أتقن der و die و das مع البحث الفوري والسياق الغني.',
        'tr': 'Anında arama ve zengin bağlamla der, die, das tanımlıklarını öğrenin.',
        'de': 'Meistere der, die, das mit Sofortsuche und Kontext.',
      });

  String get searchEmptyPrompt => _t({
        'en': 'Type any German noun to find its article, plural form, and examples.',
        'ar': 'اكتب أي اسم ألماني لمعرفة أداة تعريفه، صيغة الجمع، وجمل الأمثلة.',
        'tr': 'Tanımlığını, çoğul halini ve örnek cümlelerini görmek için bir isim yazın.',
        'de': 'Gib ein deutsches Nomen ein, um Artikel, Plural und Beispiele zu sehen.',
      });

  String get masculine => _t({
        'en': 'masculine',
        'ar': 'مذكر',
        'tr': 'eril',
        'de': 'maskulin',
      });

  String get feminine => _t({
        'en': 'feminine',
        'ar': 'مؤنث',
        'tr': 'dişil',
        'de': 'feminin',
      });

  String get neuter => _t({
        'en': 'neuter',
        'ar': 'محايد',
        'tr': 'nötr',
        'de': 'neutral',
      });

  String get pluralLabel => _t({
        'en': 'Plural',
        'ar': 'الجمع',
        'tr': 'Çoğul',
        'de': 'Plural',
      });

  // ── Example Sentences ──────────────────────────────────────────────────────
  String get exampleSentenceHeader => _t({
        'en': 'Example in context',
        'ar': 'مثال في سياق الجملة',
        'tr': 'Cümle içinde kullanım',
        'de': 'Beispielsatz im Kontext',
      });

  String get exampleSentenceSubtitle => _t({
        'en': 'See how the noun and article are used in a sentence:',
        'ar': 'شاهد كيف يُستخدم الاسم وأداة التعريف في جملة مفيدة:',
        'tr': 'İsmin ve tanımlığın cümle içinde nasıl kullanıldığını görün:',
        'de': 'Sieh, wie das Nomen und der Artikel im Satz verwendet werden:',
      });

  String get copySentence => _t({
        'en': 'Copy sentence',
        'ar': 'نسخ الجملة',
        'tr': 'Cümleyi kopyala',
        'de': 'Satz kopieren',
      });

  String get sentenceCopied => _t({
        'en': 'Example sentence copied to clipboard!',
        'ar': 'تم نسخ جملة المثال إلى الحافظة!',
        'tr': 'Örnek cümle panoya kopyalandı!',
        'de': 'Beispielsatz in die Zwischenablage kopiert!',
      });

  // ── Quiz Screen ────────────────────────────────────────────────────────────
  String get quizTitle => _t({
        'en': 'Article Trainer',
        'ar': 'مدرب أدوات التعريف',
        'tr': 'Tanımlık Antrenörü',
        'de': 'Artikel-Trainer',
      });

  String get chooseArticle => _t({
        'en': 'Choose the correct article:',
        'ar': 'اختر أداة التعريف الصحيحة:',
        'tr': 'Doğru tanımlığı seçin:',
        'de': 'Wähle den richtigen Artikel:',
      });

  String get correct => _t({
        'en': 'Correct!',
        'ar': 'صحيح!',
        'tr': 'Doğru!',
        'de': 'Richtig!',
      });

  String get incorrect => _t({
        'en': 'Not quite!',
        'ar': 'إجابة غير صحيحة!',
        'tr': 'Yanlış!',
        'de': 'Falsch!',
      });

  String get nextWord => _t({
        'en': 'Next noun',
        'ar': 'الكلمة التالية',
        'tr': 'Sonraki kelime',
        'de': 'Nächstes Wort',
      });

  String get streakLabel => _t({
        'en': 'Streak',
        'ar': 'التتابع اليومي',
        'tr': 'Seri',
        'de': 'Serie',
      });

  String get dueChipLabel => _t({
        'en': 'Due for Review',
        'ar': 'مستحق للمراجعة',
        'tr': 'Tekrar Zamanı',
        'de': 'Fällig zur Wiederholung',
      });

  String get dueReviewsTitle => _t({
        'en': 'Spaced Repetition Review',
        'ar': 'مراجعة التكرار المتباعد',
        'tr': 'Aralıklı Tekrar İncelemesi',
        'de': 'Spaced Repetition Wiederholung',
      });

  String get allCaughtUpTitle => _t({
        'en': 'All caught up! 🎉',
        'ar': 'أتممت جميع المراجعات! 🎉',
        'tr': 'Tüm tekrarlar bitti! 🎉',
        'de': 'Alles wiederholt! 🎉',
      });

  String get allCaughtUpSubtitle => _t({
        'en': 'No words are due for review right now. Keep practicing with fresh words!',
        'ar': 'لا توجد كلمات مستحقة للمراجعة الآن. واصل التدرب بكلمات جديدة!',
        'tr': 'Şu anda tekrar edilecek kelime yok. Yeni kelimelerle çalışmaya devam edin!',
        'de': 'Keine Wörter zur Wiederholung fällig. Übe weiter mit neuen Wörtern!',
      });

  // ── History Screen ─────────────────────────────────────────────────────────
  String get historyTitle => _t({
        'en': 'Learning History',
        'ar': 'سجل التعلم',
        'tr': 'Öğrenme Geçmişi',
        'de': 'Lernverlauf',
      });

  String get filterAll => _t({
        'en': 'All',
        'ar': 'الكل',
        'tr': 'Tümü',
        'de': 'Alle',
      });

  String get filterCorrect => _t({
        'en': 'Correct',
        'ar': 'الصحيحة',
        'tr': 'Doğru',
        'de': 'Richtig',
      });

  String get filterIncorrect => _t({
        'en': 'Incorrect',
        'ar': 'الخاطئة',
        'tr': 'Yanlış',
        'de': 'Falsch',
      });

  String get filterFavorites => _t({
        'en': 'Favorites',
        'ar': 'المفضلة',
        'tr': 'Favoriler',
        'de': 'Favoriten',
      });

  String get clearHistory => _t({
        'en': 'Clear History',
        'ar': 'مسح السجل',
        'tr': 'Geçmişi Temizle',
        'de': 'Verlauf löschen',
      });

  String get emptyHistory => _t({
        'en': 'No activity recorded yet.',
        'ar': 'لم يتم تسجيل أي نشاط بعد.',
        'tr': 'Henüz kaydedilmiş etkinlik yok.',
        'de': 'Noch keine Aktivitäten aufgezeichnet.',
      });

  // ── Settings Screen ────────────────────────────────────────────────────────
  String get settingsTitle => _t({
        'en': 'Settings',
        'ar': 'الإعدادات',
        'tr': 'Ayarlar',
        'de': 'Einstellungen',
      });

  String get sectionAccount => _t({
        'en': 'Account',
        'ar': 'الحساب',
        'tr': 'Hesap',
        'de': 'Konto',
      });

  String get sectionAppearance => _t({
        'en': 'Appearance & Language',
        'ar': 'المظهر واللغة',
        'tr': 'Görünüm ve Dil',
        'de': 'Erscheinungsbild & Sprache',
      });

  String get sectionPreferences => _t({
        'en': 'Preferences',
        'ar': 'التفضيلات',
        'tr': 'Tercihler',
        'de': 'Einstellungen',
      });

  String get darkMode => _t({
        'en': 'Dark mode',
        'ar': 'الوضع الداكن',
        'tr': 'Karanlık mod',
        'de': 'Dunkelmodus',
      });

  String get language => _t({
        'en': 'App Language',
        'ar': 'لغة التطبيق',
        'tr': 'Uygulama Dili',
        'de': 'App-Sprache',
      });

  String get selectLanguage => _t({
        'en': 'Select Language',
        'ar': 'اختر لغة التطبيق',
        'tr': 'Dil Seçin',
        'de': 'Sprache auswählen',
      });

  String get showHints => _t({
        'en': 'Show hints & explanations',
        'ar': 'إظهار التلميحات والشروحات',
        'tr': 'İpuçlarını ve açıklamaları göster',
        'de': 'Hinweise & Erklärungen anzeigen',
      });

  String get termsOfUse => _t({
        'en': 'Terms of Use',
        'ar': 'شروط الاستخدام',
        'tr': 'Kullanım Koşulları',
        'de': 'Nutzungsbedingungen',
      });

  String get privacyPolicy => _t({
        'en': 'Privacy Policy',
        'ar': 'سياسة الخصوصية',
        'tr': 'Gizlilik Politikası',
        'de': 'Datenschutzerklärung',
      });

  // ── Profile & Achievements ─────────────────────────────────────────────────
  String get profileTitle => _t({
        'en': 'Profile',
        'ar': 'الملف الشخصي',
        'tr': 'Profil',
        'de': 'Profil',
      });

  String get activityHeatmap => _t({
        'en': 'Activity Heatmap',
        'ar': 'مخطط النشاط الأسبوعي',
        'tr': 'Etkinlik Isı Haritası',
        'de': 'Aktivitäts-Heatmap',
      });

  String get practiceVolume => _t({
        'en': 'Daily Practice Volume',
        'ar': 'حجم الممارسة اليومية',
        'tr': 'Günlük Alıştırma Hacmi',
        'de': 'Tägliches Übungsvolumen',
      });

  String get milestonesAndBadges => _t({
        'en': 'Milestones & Badges',
        'ar': 'الإنجازات والأوسمة',
        'tr': 'Başarılar ve Rozetler',
        'de': 'Meilensteine & Abzeichen',
      });

  String get viewAll => _t({
        'en': 'View all',
        'ar': 'عرض الكل',
        'tr': 'Tümünü gör',
        'de': 'Alle anzeigen',
      });

  String get articleMastery => _t({
        'en': 'Article Mastery',
        'ar': 'إتقان أدوات التعريف',
        'tr': 'Tanımlık Ustalığı',
        'de': 'Artikel-Meisterschaft',
      });

  // ── Internal translation selector ──────────────────────────────────────────
  String _t(Map<String, String> values) {
    return values[languageCode] ?? values['en'] ?? '';
  }
}

/// Delegate that registers [AppLocalizations] with Flutter's localization system.
class AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLanguage.supportedLocales.any((l) => l.languageCode == locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
