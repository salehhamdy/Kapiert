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

  // ── Common Actions & Statuses ──────────────────────────────────────────────
  String get cancel => _t({
        'en': 'Cancel',
        'ar': 'إلغاء',
        'tr': 'İptal',
        'de': 'Abbrechen',
      });

  String get confirm => _t({
        'en': 'Confirm',
        'ar': 'تأكيد',
        'tr': 'Onayla',
        'de': 'Bestätigen',
      });

  String get clear => _t({
        'en': 'Clear',
        'ar': 'مسح',
        'tr': 'Temizle',
        'de': 'Löschen',
      });

  String get reset => _t({
        'en': 'Reset',
        'ar': 'إعادة ضبط',
        'tr': 'Sıfırla',
        'de': 'Zurücksetzen',
      });

  String get exit => _t({
        'en': 'Exit',
        'ar': 'خروج',
        'tr': 'Çıkış',
        'de': 'Beenden',
      });

  String get save => _t({
        'en': 'Save',
        'ar': 'حفظ',
        'tr': 'Kaydet',
        'de': 'Speichern',
      });

  String get retry => _t({
        'en': 'Retry',
        'ar': 'إعادة المحاولة',
        'tr': 'Tekrar Dene',
        'de': 'Wiederholen',
      });

  String get close => _t({
        'en': 'Close',
        'ar': 'إغلاق',
        'tr': 'Kapat',
        'de': 'Schließen',
      });

  String get back => _t({
        'en': 'Back',
        'ar': 'رجوع',
        'tr': 'Geri',
        'de': 'Zurück',
      });

  String get guest => _t({
        'en': 'Guest',
        'ar': 'ضيف',
        'tr': 'Misafir',
        'de': 'Gast',
      });

  String get guestOnDevice => _t({
        'en': 'Guest · on this device',
        'ar': 'ضيف · على هذا الجهاز',
        'tr': 'Misafir · bu cihazda',
        'de': 'Gast · auf diesem Gerät',
      });

  String get online => _t({
        'en': 'online',
        'ar': 'متصل',
        'tr': 'çevrimiçi',
        'de': 'online',
      });

  String get offline => _t({
        'en': 'offline',
        'ar': 'غير متصل',
        'tr': 'çevrimdışı',
        'de': 'offline',
      });

  String get checking => _t({
        'en': 'checking…',
        'ar': 'جاري التحقق…',
        'tr': 'kontrol ediliyor…',
        'de': 'prüfe…',
      });

  String get unknown => _t({
        'en': 'unknown',
        'ar': 'غير معروف',
        'tr': 'bilinmiyor',
        'de': 'unbekannt',
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

  String get checkArticle => _t({
        'en': 'Check Article',
        'ar': 'تحقق من الأداة',
        'tr': 'Tanımlığı Kontrol Et',
        'de': 'Artikel prüfen',
      });

  String get lookingUp => _t({
        'en': 'Looking up…',
        'ar': 'جاري البحث…',
        'tr': 'Aranıyor…',
        'de': 'Suche…',
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

  String get saveToFavorites => _t({
        'en': 'Save to Favorites for focused review',
        'ar': 'حفظ في المفضلة للمراجعة المركزة',
        'tr': 'Odaklı tekrar için Favorilere ekle',
        'de': 'Zu Favoriten für Wiederholung hinzufügen',
      });

  String get removeFromFavorites => _t({
        'en': 'Remove from Favorites',
        'ar': 'إزالة من المفضلة',
        'tr': 'Favorilerden çıkar',
        'de': 'Aus Favoriten entfernen',
      });

  String get favorited => _t({
        'en': 'Favorited',
        'ar': 'مفضلة',
        'tr': 'Favorilere eklendi',
        'de': 'Favorisiert',
      });

  String get savedToFavorites => _t({
        'en': 'saved to Favorites',
        'ar': 'تم الحفظ في المفضلة',
        'tr': 'Favorilere eklendi',
        'de': 'zu Favoriten hinzugefügt',
      });

  String get removedFromFavorites => _t({
        'en': 'removed from Favorites',
        'ar': 'تمت الإزالة من المفضلة',
        'tr': 'Favorilerden çıkarıldı',
        'de': 'aus Favoriten entfernt',
      });

  String get sourceFromDataset => _t({
        'en': 'from dataset',
        'ar': 'من قاعدة البيانات',
        'tr': 'veritabanından',
        'de': 'aus Datensatz',
      });

  String get sourceViaWiktionary => _t({
        'en': 'via Wiktionary',
        'ar': 'عبر ويكاموس',
        'tr': 'Wiktionary aracılığıyla',
        'de': 'über Wiktionary',
      });

  String get sourceOfflineCache => _t({
        'en': 'offline cache',
        'ar': 'ذاكرة دون اتصال',
        'tr': 'çevrimdışı önbellek',
        'de': 'Offline-Speicher',
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

  String get quizMode => _t({
        'en': 'Quiz Mode',
        'ar': 'وضع الاختبار',
        'tr': 'Alıştırma Modu',
        'de': 'Quiz-Modus',
      });

  String get tapCorrectArticle => _t({
        'en': 'Tap the correct article',
        'ar': 'المس أداة التعريف الصحيحة',
        'tr': 'Doğru tanımlığa dokunun',
        'de': 'Tippe auf den richtigen Artikel',
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

  String get due => _t({
        'en': 'Due',
        'ar': 'مستحق',
        'tr': 'Tekrar',
        'de': 'Fällig',
      });

  String get review => _t({
        'en': 'Review',
        'ar': 'مراجعة',
        'tr': 'İnceleme',
        'de': 'Wiederholen',
      });

  String get accuracy => _t({
        'en': 'accuracy',
        'ar': 'دقة',
        'tr': 'isabet oranı',
        'de': 'Genauigkeit',
      });

  String get srsReview => _t({
        'en': 'SRS Review',
        'ar': 'مراجعة التكرار المتباعد',
        'tr': 'SRS Tekrarı',
        'de': 'SRS-Wiederholung',
      });

  String get spacedRepetitionReview => _t({
        'en': 'Spaced Repetition Review',
        'ar': 'مراجعة التكرار المتباعد',
        'tr': 'Aralıklı Tekrar İncelemesi',
        'de': 'Spaced Repetition Wiederholung',
      });

  String get practicingDueWords => _t({
        'en': 'Practicing scheduled due words',
        'ar': 'ممارسة الكلمات المستحقة المجدولة',
        'tr': 'Planlanan kelimeleri çalışma',
        'de': 'Fällige Wörter üben',
      });

  String get focusedQuiz => _t({
        'en': 'Focused Quiz',
        'ar': 'اختبار مركز',
        'tr': 'Odaklı Alıştırma',
        'de': 'Fokussiertes Quiz',
      });

  String get focusedReviewMode => _t({
        'en': 'Focused Review Mode',
        'ar': 'وضع المراجعة المركزة',
        'tr': 'Odaklı Tekrar Modu',
        'de': 'Fokussierter Wiederholungsmodus',
      });

  String get reviewingFavorites => _t({
        'en': 'Reviewing saved favorites',
        'ar': 'مراجعة الكلمات المفضلة المحفوظة',
        'tr': 'Kaydedilen favorileri tekrar etme',
        'de': 'Gespeicherte Favoriten wiederholen',
      });

  String get stage => _t({
        'en': 'Stage',
        'ar': 'المرحلة',
        'tr': 'Aşama',
        'de': 'Stufe',
      });

  String get stageLearning => _t({
        'en': 'Learning',
        'ar': 'قيد التعلم',
        'tr': 'Öğreniliyor',
        'de': 'Lernen',
      });

  String get stageReviewWord => _t({
        'en': 'Review',
        'ar': 'مراجعة',
        'tr': 'Tekrar',
        'de': 'Wiederholen',
      });

  String get stageSolid => _t({
        'en': 'Solid',
        'ar': 'ثابت',
        'tr': 'Pekiştirildi',
        'de': 'Gefestigt',
      });

  String get stageMastered => _t({
        'en': 'Mastered',
        'ar': 'متقن',
        'tr': 'Ustalaşıldı',
        'de': 'Gemeistert',
      });

  String get masteredExclamation => _t({
        'en': 'Mastered!',
        'ar': 'متقن!',
        'tr': 'Ustalaşıldı!',
        'de': 'Gemeistert!',
      });

  String get dueReviewsTitle => _t({
        'en': 'Spaced Repetition Review',
        'ar': 'مراجعة التكرار المتباعد',
        'tr': 'Aralıklı Tekrar İncelemesi',
        'de': 'Spaced Repetition Wiederholung',
      });

  String get allCaughtUpTitle => _t({
        'en': 'All Due Reviews Caught Up!',
        'ar': 'أتممت جميع المراجعات المستحقة! 🎉',
        'tr': 'Tüm Tekrarlar Tamamlandı! 🎉',
        'de': 'Alle fälligen Wiederholungen erledigt! 🎉',
      });

  String get allCaughtUpSubtitle => _t({
        'en': 'You have reviewed all scheduled nouns for now. Keep practicing with fresh words!',
        'ar': 'لقد راجعت جميع الأسماء المجدولة حالياً. واصل التدرب بكلمات جديدة!',
        'tr': 'Şu anda tekrar edilecek kelime yok. Yeni kelimelerle çalışmaya devam edin!',
        'de': 'Keine Wörter zur Wiederholung fällig. Übe weiter mit neuen Wörtern!',
      });

  String get backToQuiz => _t({
        'en': 'Back to General Quiz',
        'ar': 'العودة إلى الاختبار العام',
        'tr': 'Genel Alıştırmaya Dön',
        'de': 'Zurück zum Hauptquiz',
      });

  String get loadingWord => _t({
        'en': 'Loading word…',
        'ar': 'جاري تحميل الكلمة…',
        'tr': 'Kelime yükleniyor…',
        'de': 'Wort wird geladen…',
      });

  String get couldNotLoadWord => _t({
        'en': 'Could not load a word.\nIs the backend running?',
        'ar': 'تعذر تحميل كلمة.\nهل الخادم يعمل؟',
        'tr': 'Kelime yüklenemedi.\nSunucu çalışıyor mu?',
        'de': 'Wort konnte nicht geladen werden.\nLäuft das Backend?',
      });

  // ── History Screen ─────────────────────────────────────────────────────────
  String get historyTitle => _t({
        'en': 'History',
        'ar': 'السجل',
        'tr': 'Geçmiş',
        'de': 'Verlauf',
      });

  String get statQuiz => _t({
        'en': 'Quiz',
        'ar': 'الاختبار',
        'tr': 'Alıştırma',
        'de': 'Quiz',
      });

  String get statAccuracy => _t({
        'en': 'Accuracy',
        'ar': 'الدقة',
        'tr': 'İsabet',
        'de': 'Genauigkeit',
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

  String get emptyHistorySubtitle => _t({
        'en': 'Look up words or take quizzes\nto see your history here.',
        'ar': 'ابحث عن كلمات أو أجرِ اختبارات\nلترى سجلك هنا.',
        'tr': 'Geçmişinizi burada görmek için\nkelimeleri arayın veya alıştırma yapın.',
        'de': 'Schlage Wörter nach oder mache Quizzes,\num deinen Verlauf hier zu sehen.',
      });

  String get statTotal => _t({
        'en': 'Total',
        'ar': 'الإجمالي',
        'tr': 'Toplam',
        'de': 'Gesamt',
      });

  String get focusedReview => _t({
        'en': 'Focused Review',
        'ar': 'مراجعة مركزة',
        'tr': 'Odaklı Tekrar',
        'de': 'Fokussierte Wiederholung',
      });

  String get noFavoritesYet => _t({
        'en': 'No favorites yet',
        'ar': 'لا توجد مفضلات بعد',
        'tr': 'Henüz favori yok',
        'de': 'Noch keine Favoriten',
      });

  String get noFavoritesSubtitle => _t({
        'en': 'Tap the star ⭐ on any word card in Lookup\nor Quiz to save it for focused review.',
        'ar': 'اضغط على النجمة ⭐ في أي بطاقة كلمة في البحث\nأو الاختبار لحفظها للمراجعة المركزة.',
        'tr': 'Arama veya Alıştırma kartlarındaki yıldıza ⭐\ndokunarak odaklı tekrar için kaydedin.',
        'de': 'Tippe auf den Stern ⭐ bei einer Wortkarte,\num sie für die Wiederholung zu speichern.',
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

  String get sectionServer => _t({
        'en': 'Server',
        'ar': 'الخادم',
        'tr': 'Sunucu',
        'de': 'Server',
      });

  String get sectionData => _t({
        'en': 'Data',
        'ar': 'البيانات',
        'tr': 'Veriler',
        'de': 'Daten',
      });

  String get sectionSession => _t({
        'en': 'Session',
        'ar': 'الجلسة',
        'tr': 'Oturum',
        'de': 'Sitzung',
      });

  String get sectionLegal => _t({
        'en': 'Legal',
        'ar': 'قانوني',
        'tr': 'Yasal',
        'de': 'Rechtliches',
      });

  String get sectionAbout => _t({
        'en': 'About',
        'ar': 'حول التطبيق',
        'tr': 'Hakkında',
        'de': 'Über',
      });

  String get darkMode => _t({
        'en': 'Dark mode',
        'ar': 'الوضع الداكن',
        'tr': 'Karanlık mod',
        'de': 'Dunkelmodus',
      });

  String get darkModeSubtitle => _t({
        'en': 'Switch app appearance',
        'ar': 'تبديل مظهر التطبيق',
        'tr': 'Uygulama görünümünü değiştir',
        'de': 'Erscheinungsbild der App anpassen',
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

  String get showHintsSubtitle => _t({
        'en': 'Display extra info on result cards',
        'ar': 'عرض معلومات إضافية على بطاقات النتائج',
        'tr': 'Sonuç kartlarında ekstra bilgi göster',
        'de': 'Zusatzinfos auf Ergebniskarten anzeigen',
      });

  String get profileSubtitle => _t({
        'en': 'Your name, progress and account details',
        'ar': 'اسمك وتقدمك وتفاصيل حسابك',
        'tr': 'Adınız, ilerlemeniz ve hesap detaylarınız',
        'de': 'Dein Name, Fortschritt und Kontodetails',
      });

  String get notifications => _t({
        'en': 'Notifications',
        'ar': 'الإشعارات',
        'tr': 'Bildirimler',
        'de': 'Benachrichtigungen',
      });

  String get notificationsSubtitle => _t({
        'en': 'Daily reminders and streak alerts',
        'ar': 'تذكيرات يومية وتنبيهات الحماس',
        'tr': 'Günlük hatırlatıcılar ve seri uyarıları',
        'de': 'Tägliche Erinnerungen und Serien-Benachrichtigungen',
      });

  String get dailyReminders => _t({
        'en': 'Daily Reminders',
        'ar': 'التذكيرات اليومية',
        'tr': 'Günlük Hatırlatıcılar',
        'de': 'Tägliche Erinnerungen',
      });

  String get dailyRemindersDesc => _t({
        'en': 'Set daily practice reminders to maintain your German learning routine',
        'ar': 'اضبط تذكيرات يومية للحفاظ على استمرارية تعلم الألمانية',
        'tr': 'Almanca öğrenme rutininizi sürdürmek için günlük hatırlatıcılar ayarlayın',
        'de': 'Stellen Sie tägliche Erinnerungen ein, um Ihre Lernroutine beizubehalten',
      });

  String get reminderTime => _t({
        'en': 'Reminder Time',
        'ar': 'وقت التذكير',
        'tr': 'Hatırlatıcı Saati',
        'de': 'Erinnerungszeit',
      });

  String get enableReminders => _t({
        'en': 'Enable Daily Reminders',
        'ar': 'تفعيل التذكيرات اليومية',
        'tr': 'Günlük Hatırlatıcıları Etkinleştir',
        'de': 'Tägliche Erinnerungen aktivieren',
      });

  String get streakProtectionAlerts => _t({
        'en': 'Streak Saver Alerts',
        'ar': 'تنبيهات حماية السلسلة',
        'tr': 'Seri Koruma Uyarıları',
        'de': 'Streak-Schutzhinweise',
      });

  String get streakProtectionAlertsDesc => _t({
        'en': 'Get an evening alert if you haven\'t practiced today',
        'ar': 'تنبيه مسائي إذا لم تتدرب اليوم للحفاظ على سلسلتك',
        'tr': 'Bugün henüz pratik yapmadıysanız akşam uyarısı alın',
        'de': 'Erinnerung am Abend, falls Sie heute noch nicht geübt haben',
      });

  String get srsDueAlerts => _t({
        'en': 'SRS Reviews Due Alerts',
        'ar': 'تنبيهات مراجعة الكلمات المستحقة',
        'tr': 'Zamanı Gelen SRS Uyarıları',
        'de': 'SRS-Wiederholungshinweise',
      });

  String get srsDueAlertsDesc => _t({
        'en': 'Get notified when spaced repetition flashcards are due for review',
        'ar': 'تلقي إشعارات عندما يحين وقت مراجعة البطاقات التعليمية',
        'tr': 'Aralıklı tekrar kartlarının zamanı geldiğinde bildirim alın',
        'de': 'Benachrichtigung erhalten, wenn Karteikarten wiederholt werden müssen',
      });

  String get sendTestNotification => _t({
        'en': 'Send Test Notification',
        'ar': 'إرسال إشعار تجريبي',
        'tr': 'Test Bildirimi Gönder',
        'de': 'Test-Benachrichtigung senden',
      });

  String get testNotificationSent => _t({
        'en': 'Test notification sent! Check your notification tray.',
        'ar': 'تم إرسال الإشعار التجريبي! تحقق من لوحة الإشعارات.',
        'tr': 'Test bildirimi gönderildi! Bildirim panelinizi kontrol edin.',
        'de': 'Test-Benachrichtigung gesendet! Prüfen Sie Ihre Benachrichtigungen.',
      });

  String get offlineCacheTitle => _t({
        'en': 'Offline Article Cache',
        'ar': 'ذاكرة المقالات دون اتصال',
        'tr': 'Çevrimdışı Sözlük Önbelleği',
        'de': 'Offline-Artikelspeicher',
      });

  String get offlineCacheSubtitle => _t({
        'en': 'Pre-seed vocabulary and manage offline storage',
        'ar': 'تحميل الكلمات مسبقاً وإدارة التخزين دون اتصال',
        'tr': 'Kelimeleri önceden yükle ve çevrimdışı depolamayı yönet',
        'de': 'Grundwortschatz vorladen & Offline-Speicher verwalten',
      });

  String get offlineArticlesStored => _t({
        'en': 'Stored Offline Articles',
        'ar': 'المقالات المحفوظة دون اتصال',
        'tr': 'Kayıtlı Çevrimdışı Kelimeler',
        'de': 'Gespeicherte Offline-Artikel',
      });

  String get preseedOfflineVocab => _t({
        'en': 'Pre-seed Essential Vocabulary',
        'ar': 'تحميل المفردات الأساسية مسبقاً',
        'tr': 'Temel Kelimeleri Önceden Yükle',
        'de': 'Grundwortschatz vorladen',
      });

  String get preseedOfflineVocabDesc => _t({
        'en': 'Save 100+ high-frequency German nouns with plurals, translations and examples for instant offline lookups and quizzes.',
        'ar': 'حفظ أكثر من 100 اسم ألماني شائع مع الجموع والترجمات والأمثلة للبحث والاختبار دون اتصال.',
        'tr': 'Anında çevrimdışı arama ve alıştırmalar için çoğulları, çevirileri ve örnekleriyle 100+ yaygın Almanca ismi kaydedin.',
        'de': 'Speichere 100+ häufige deutsche Nomen mit Pluralen, Übersetzungen und Beispielen für sofortige Offline-Abfragen & Quizzes.',
      });

  String get preseedSuccess => _t({
        'en': 'Essential offline vocabulary loaded successfully!',
        'ar': 'تم تحميل المفردات الأساسية دون اتصال بنجاح!',
        'tr': 'Temel çevrimdışı kelimeler başarıyla yüklendi!',
        'de': 'Grundwortschatz erfolgreich offline gespeichert!',
      });

  String get clearOfflineCache => _t({
        'en': 'Clear Offline Cache',
        'ar': 'مسح الذاكرة المؤقتة دون اتصال',
        'tr': 'Çevrimdışı Önbelleği Temizle',
        'de': 'Offline-Speicher leeren',
      });

  String get clearOfflineCacheSubtitle => _t({
        'en': 'Remove all cached articles from local device',
        'ar': 'إزالة جميع الكلمات المخزنة مؤقتاً من الجهاز',
        'tr': 'Cihazdaki tüm önbelleğe alınmış kelimeleri sil',
        'de': 'Alle zwischengespeicherten Artikel vom Gerät löschen',
      });

  String get offlineCacheCleared => _t({
        'en': 'Offline cache cleared.',
        'ar': 'تم مسح الذاكرة المؤقتة دون اتصال.',
        'tr': 'Çevrimdışı önbellek temizlendi.',
        'de': 'Offline-Speicher geleert.',
      });

  String get viewProfile => _t({
        'en': 'View profile',
        'ar': 'عرض الملف الشخصي',
        'tr': 'Profili görüntüle',
        'de': 'Profil anzeigen',
      });

  String get backendApi => _t({
        'en': 'Backend API',
        'ar': 'واجهة الخادم البرمجية',
        'tr': 'Arka Uç API',
        'de': 'Backend-API',
      });

  String get clearHistorySubtitle => _t({
        'en': 'Remove all lookup and quiz history',
        'ar': 'حذف جميع سجلات البحث والاختبار',
        'tr': 'Tüm arama ve alıştırma geçmişini sil',
        'de': 'Gesamten Such- und Quizverlauf löschen',
      });

  String get clearHistoryDialogTitle => _t({
        'en': 'Clear History?',
        'ar': 'مسح السجل؟',
        'tr': 'Geçmişi Temizle?',
        'de': 'Verlauf löschen?',
      });

  String get clearHistoryDialogContent => _t({
        'en': 'This will remove all your lookup and quiz history. This cannot be undone.',
        'ar': 'سيؤدي هذا إلى إزالة جميع سجلات البحث والاختبارات. لا يمكن التراجع عن هذا الإجراء.',
        'tr': 'Bu işlem tüm arama ve alıştırma geçmişinizi siler. Geri alınamaz.',
        'de': 'Dadurch wird dein gesamter Such- und Quizverlauf gelöscht. Dies kann nicht rückgängig gemacht werden.',
      });

  String get historyCleared => _t({
        'en': 'History cleared',
        'ar': 'تم مسح السجل',
        'tr': 'Geçmiş temizlendi',
        'de': 'Verlauf gelöscht',
      });

  String get resetStreak => _t({
        'en': 'Reset streak',
        'ar': 'إعادة ضبط التتابع',
        'tr': 'Seriyi sıfırla',
        'de': 'Serie zurücksetzen',
      });

  String get resetStreakSubtitle => _t({
        'en': 'Set your streak back to 0',
        'ar': 'إعادة ضبط تتابعك اليومي إلى 0',
        'tr': 'Serinizi 0\'a sıfırlayın',
        'de': 'Setzt deine Serie auf 0 zurück',
      });

  String get resetStreakDialogTitle => _t({
        'en': 'Reset Streak?',
        'ar': 'إعادة ضبط التتابع؟',
        'tr': 'Seri Sıfırlansın mı?',
        'de': 'Serie zurücksetzen?',
      });

  String get resetStreakDialogContent => _t({
        'en': 'Your streak will be reset to 0. This cannot be undone.',
        'ar': 'سيتم إعادة ضبط تتابعك إلى 0. لا يمكن التراجع عن هذا الإجراء.',
        'tr': 'Seriniz 0\'a sıfırlanacak. Bu işlem geri alınamaz.',
        'de': 'Deine Serie wird auf 0 zurückgesetzt. Dies kann nicht rückgängig gemacht werden.',
      });

  String get streakReset => _t({
        'en': 'Streak reset',
        'ar': 'تمت إعادة ضبط التتابع',
        'tr': 'Seri sıfırlandı',
        'de': 'Serie zurückgesetzt',
      });

  String get changePassword => _t({
        'en': 'Change password',
        'ar': 'تغيير كلمة المرور',
        'tr': 'Şifreyi değiştir',
        'de': 'Passwort ändern',
      });

  String get changePasswordSubtitle => _t({
        'en': 'Update your account password',
        'ar': 'تحديث كلمة مرور حسابك',
        'tr': 'Hesap şifrenizi güncelleyin',
        'de': 'Aktualisiere dein Kontopasswort',
      });

  String get logOut => _t({
        'en': 'Log out',
        'ar': 'تسجيل الخروج',
        'tr': 'Çıkış yap',
        'de': 'Abmelden',
      });

  String get logOutSubtitle => _t({
        'en': 'Sign out of your account',
        'ar': 'تسجيل الخروج من حسابك',
        'tr': 'Hesabınızdan çıkış yapın',
        'de': 'Von deinem Konto abmelden',
      });

  String get logOutDialogTitle => _t({
        'en': 'Log out?',
        'ar': 'تسجيل الخروج؟',
        'tr': 'Çıkış yapılsın mı?',
        'de': 'Abmelden?',
      });

  String get logOutDialogContent => _t({
        'en': 'Your streak and history will be saved.\nYou can sign back in anytime.',
        'ar': 'سيتم حفظ تتابعك وسجلك.\nيمكنك تسجيل الدخول مرة أخرى في أي وقت.',
        'tr': 'Seriniz ve geçmişiniz korunur.\nİstediğiniz zaman tekrar giriş yapabilirsiniz.',
        'de': 'Deine Serie und dein Verlauf bleiben gespeichert.\nDu kannst dich jederzeit wieder anmelden.',
      });

  String get termsOfUse => _t({
        'en': 'Terms of Use',
        'ar': 'شروط الاستخدام',
        'tr': 'Kullanım Koşulları',
        'de': 'Nutzungsbedingungen',
      });

  String get termsSubtitle => _t({
        'en': 'Usage rules, license and disclaimer',
        'ar': 'قواعد الاستخدام والترخيص وإخلاء المسؤولية',
        'tr': 'Kullanım kuralları, lisans ve feragatname',
        'de': 'Nutzungsregeln, Lizenz und Haftungsausschluss',
      });

  String get privacyPolicy => _t({
        'en': 'Privacy Policy',
        'ar': 'سياسة الخصوصية',
        'tr': 'Gizlilik Politikası',
        'de': 'Datenschutzerklärung',
      });

  String get privacySubtitle => _t({
        'en': 'Local-first storage, cloud sync & user rights',
        'ar': 'تخزين محلي أولاً، مزامنة سحابية وحقوق المستخدم',
        'tr': 'Öncelikli yerel depolama, bulut senkronizasyonu ve haklar',
        'de': 'Lokale Speicherung, Cloud-Synchronisierung & Nutzerrechte',
      });

  String get consentStatus => _t({
        'en': 'Consent status',
        'ar': 'حالة الموافقة',
        'tr': 'Onay durumu',
        'de': 'Zustimmungsstatus',
      });

  String get consentAcceptedSubtitle => _t({
        'en': 'Terms of Use & Privacy Policy accepted',
        'ar': 'تمت الموافقة على شروط الاستخدام وسياسة الخصوصية',
        'tr': 'Kullanım Koşulları ve Gizlilik Politikası kabul edildi',
        'de': 'Nutzungsbedingungen & Datenschutzerklärung akzeptiert',
      });

  String get consentPendingSubtitle => _t({
        'en': 'Pending agreement',
        'ar': 'في انتظار الموافقة',
        'tr': 'Onay bekleniyor',
        'de': 'Ausstehende Zustimmung',
      });

  String get accepted => _t({
        'en': 'Accepted',
        'ar': 'مقبول',
        'tr': 'Kabul edildi',
        'de': 'Akzeptiert',
      });

  String get pending => _t({
        'en': 'Pending',
        'ar': 'معلق',
        'tr': 'Beklemede',
        'de': 'Ausstehend',
      });

  String get aboutSubtitle => _t({
        'en': 'Version 1.0.0 • German Article Trainer',
        'ar': 'الإصدار 1.0.0 • مدرب أدوات التعريف الألمانية',
        'tr': 'Sürüm 1.0.0 • Almanca Tanımlık Eğitmeni',
        'de': 'Version 1.0.0 • Deutscher Artikel-Trainer',
      });

  String get dataSources => _t({
        'en': 'Data sources',
        'ar': 'مصادر البيانات',
        'tr': 'Veri kaynakları',
        'de': 'Datenquellen',
      });

  String get dataSourcesSubtitle => _t({
        'en': 'german-nouns dataset (~100k) + Wiktionary API',
        'ar': 'مجموعة بيانات german-nouns (~100k) + واجهة ويكاموس',
        'tr': 'german-nouns veri kümesi (~100k) + Wiktionary API',
        'de': 'german-nouns Datensatz (~100k) + Wiktionary API',
      });

  // ── Profile & Achievements ─────────────────────────────────────────────────
  String get profileTitle => _t({
        'en': 'Profile',
        'ar': 'الملف الشخصي',
        'tr': 'Profil',
        'de': 'Profil',
      });

  String get yourProgress => _t({
        'en': 'Your progress',
        'ar': 'تقدمك',
        'tr': 'İlerlemeniz',
        'de': 'Dein Fortschritt',
      });

  String get activityAndTrends => _t({
        'en': 'Activity & trends',
        'ar': 'النشاط والاتجاهات',
        'tr': 'Etkinlik ve eğilimler',
        'de': 'Aktivität & Trends',
      });

  String get achievements => _t({
        'en': 'Achievements',
        'ar': 'الإنجازات',
        'tr': 'Başarılar',
        'de': 'Erfolge',
      });

  String get articleMastery => _t({
        'en': 'Article mastery',
        'ar': 'إتقان أدوات التعريف',
        'tr': 'Tanımlık Ustalığı',
        'de': 'Artikel-Meisterschaft',
      });

  String get spacedRepetition => _t({
        'en': 'Spaced repetition',
        'ar': 'التكرار المتباعد',
        'tr': 'Aralıklı tekrar',
        'de': 'Spaced Repetition',
      });

  String get dayStreak => _t({
        'en': 'Day streak',
        'ar': 'أيام التتابع',
        'tr': 'Günlük seri',
        'de': 'Tage Serie',
      });

  String get daysStreak => _t({
        'en': 'Days streak',
        'ar': 'أيام التتابع',
        'tr': 'Günlük seri',
        'de': 'Tage Serie',
      });

  String get wordsPractised => _t({
        'en': 'Words practised',
        'ar': 'الكلمات المتدرب عليها',
        'tr': 'Çalışılan kelimeler',
        'de': 'Geübte Wörter',
      });

  String get quizAnswers => _t({
        'en': 'Quiz answers',
        'ar': 'إجابات الاختبار',
        'tr': 'Alıştırma cevapları',
        'de': 'Quiz-Antworten',
      });

  String get quizAccuracy => _t({
        'en': 'Quiz accuracy',
        'ar': 'دقة الاختبار',
        'tr': 'Alıştırma isabeti',
        'de': 'Quiz-Genauigkeit',
      });

  String get displayName => _t({
        'en': 'Display name',
        'ar': 'اسم العرض',
        'tr': 'Görünen ad',
        'de': 'Anzeigename',
      });

  String get email => _t({
        'en': 'Email',
        'ar': 'البريد الإلكتروني',
        'tr': 'E-posta',
        'de': 'E-Mail',
      });

  String get signInMethod => _t({
        'en': 'Sign-in method',
        'ar': 'طريقة تسجيل الدخول',
        'tr': 'Giriş yöntemi',
        'de': 'Anmeldemethode',
      });

  String get emailAndPassword => _t({
        'en': 'Email & password',
        'ar': 'البريد الإلكتروني وكلمة المرور',
        'tr': 'E-posta ve şifre',
        'de': 'E-Mail & Passwort',
      });

  String get nameUpdated => _t({
        'en': 'Name updated',
        'ar': 'تم تحديث الاسم',
        'tr': 'İsim güncellendi',
        'de': 'Name aktualisiert',
      });

  String get editName => _t({
        'en': 'Edit name',
        'ar': 'تعديل الاسم',
        'tr': 'İsmi düzenle',
        'de': 'Name bearbeiten',
      });

  String get syncing => _t({
        'en': 'Syncing…',
        'ar': 'جاري المزامنة…',
        'tr': 'Senkronize ediliyor…',
        'de': 'Synchronisiere…',
      });

  String get syncingSubtitle => _t({
        'en': 'Updating history, streak and settings',
        'ar': 'تحديث السجل والتتابع والإعدادات',
        'tr': 'Geçmiş, seri ve ayarlar güncelleniyor',
        'de': 'Verlauf, Serie und Einstellungen werden aktualisiert',
      });

  String get syncPaused => _t({
        'en': 'Sync paused',
        'ar': 'المزامنة متوقفة مؤقتاً',
        'tr': 'Senkronizasyon duraklatıldı',
        'de': 'Synchronisierung pausiert',
      });

  String get syncPausedSubtitle => _t({
        'en': 'We\'ll retry automatically — or tap Sync now',
        'ar': 'سنعيد المحاولة تلقائياً — أو اضغط مزامنة الآن',
        'tr': 'Otomatik olarak tekrar denenecek — veya şimdi dokunun',
        'de': 'Wird automatisch wiederholt — oder tippe auf Jetzt synchronisieren',
      });

  String get cloudSyncOn => _t({
        'en': 'Cloud sync on',
        'ar': 'المزامنة السحابية مفعّلة',
        'tr': 'Bulut senkronizasyonu açık',
        'de': 'Cloud-Sync aktiv',
      });

  String get cloudSyncBackedUp => _t({
        'en': 'Your progress is backed up to your account',
        'ar': 'تم نسخ تقدمك احتياطياً في حسابك',
        'tr': 'İlerlemeniz hesabınıza yedeklendi',
        'de': 'Dein Fortschritt ist in deinem Konto gesichert',
      });

  String get syncNow => _t({
        'en': 'Sync now',
        'ar': 'مزامنة الآن',
        'tr': 'Şimdi senkronize et',
        'de': 'Jetzt synchronisieren',
      });

  String get keepProgressSafe => _t({
        'en': 'Keep your progress safe',
        'ar': 'حافظ على تقدمك آمناً',
        'tr': 'İlerlemenizi güvende tutun',
        'de': 'Sichere deinen Lernfortschritt',
      });

  String get keepProgressSafeSubtitle => _t({
        'en': 'Create a free account to sync your history and streak across all your devices.',
        'ar': 'أنشئ حساباً مجانياً لمزامنة سجلك وتتابعك عبر جميع أجهزتك.',
        'tr': 'Geçmişinizi ve serinizi tüm cihazlarınızda senkronize etmek için ücretsiz hesap oluşturun.',
        'de': 'Erstelle ein kostenloses Konto, um Verlauf und Serie geräteübergreifend zu synchronisieren.',
      });

  String get signIn => _t({
        'en': 'Sign in',
        'ar': 'تسجيل الدخول',
        'tr': 'Giriş yap',
        'de': 'Anmelden',
      });

  String get createAccount => _t({
        'en': 'Create account',
        'ar': 'إنشاء حساب',
        'tr': 'Hesap oluştur',
        'de': 'Konto erstellen',
      });

  String get dueNow => _t({
        'en': 'Due now',
        'ar': 'مستحق الآن',
        'tr': 'Şimdi tekrar',
        'de': 'Jetzt fällig',
      });

  String get reviewing => _t({
        'en': 'Reviewing',
        'ar': 'قيد المراجعة',
        'tr': 'İnceleniyor',
        'de': 'Wiederholen',
      });

  String get mastered => _t({
        'en': 'Mastered',
        'ar': 'متقن',
        'tr': 'Ustalaşıldı',
        'de': 'Gemeistert',
      });

  String get masteryRate => _t({
        'en': 'Mastery rate',
        'ar': 'معدل الإتقان',
        'tr': 'Ustalık oranı',
        'de': 'Meisterungsrate',
      });

  String get ofTrackedWords => _t({
        'en': 'of tracked words',
        'ar': 'من الكلمات المسجلة',
        'tr': 'takip edilen kelimeden',
        'de': 'der erfassten Wörter',
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

  String get achievementsAndMilestones => _t({
        'en': 'Achievements & Milestones',
        'ar': 'الإنجازات والمراحل',
        'tr': 'Başarılar ve Aşamalar',
        'de': 'Erfolge & Meilensteine',
      });

  String get viewAll => _t({
        'en': 'View all',
        'ar': 'عرض الكل',
        'tr': 'Tümünü gör',
        'de': 'Alle anzeigen',
      });

  String get sevenDayTotal => _t({
        'en': '7-Day Total',
        'ar': 'إجمالي 7 أيام',
        'tr': '7 Günlük Toplam',
        'de': '7-Tage-Gesamt',
      });

  String get dailyAvg => _t({
        'en': 'Daily Avg',
        'ar': 'المعدل اليومي',
        'tr': 'Günlük Ort.',
        'de': 'Tagesdurchschnitt',
      });

  String get bestDay => _t({
        'en': 'Best Day',
        'ar': 'أفضل يوم',
        'tr': 'En İyi Gün',
        'de': 'Bester Tag',
      });

  String get less => _t({
        'en': 'Less',
        'ar': 'أقل',
        'tr': 'Az',
        'de': 'Weniger',
      });

  String get more => _t({
        'en': 'More',
        'ar': 'أكثر',
        'tr': 'Çok',
        'de': 'Mehr',
      });

  String get actionsUnit => _t({
        'en': 'actions',
        'ar': 'عمليات',
        'tr': 'işlem',
        'de': 'Aktionen',
      });

  String get perDayUnit => _t({
        'en': '/ day',
        'ar': '/ يوم',
        'tr': '/ gün',
        'de': '/ Tag',
      });

  String get maxUnit => _t({
        'en': 'max',
        'ar': 'الأقصى',
        'tr': 'maks',
        'de': 'Max',
      });

  // ── Dynamic Formatted String Helpers ───────────────────────────────────────
  String practiceSavedWords(int count) => _t({
        'en': 'Practice your $count saved words in Quiz mode',
        'ar': 'تدرب على $count كلمة محفوظة في وضع الاختبار',
        'tr': 'Kaydedilen $count kelimenizi alıştırma modunda çalışın',
        'de': 'Übe deine $count gespeicherten Wörter im Quiz-Modus',
      });

  String focusOnLowestAccuracy(String article) => _t({
        'en': 'Focus on $article — it\'s your lowest quiz accuracy.',
        'ar': 'ركز على $article — هي الأقل دقة في اختباراتك.',
        'tr': '$article üzerine odaklanın — en düşük alıştırma isabetiniz.',
        'de': 'Fokus auf $article — hier hast du die niedrigste Quiz-Genauigkeit.',
      });

  String badgesEarned(int unlocked, int total, int percentage) => _t({
        'en': '$unlocked of $total badges earned ($percentage%)',
        'ar': 'تم كسب $unlocked من $total أوسمة ($percentage%)',
        'tr': '$total rozetten $unlocked tanesi kazanıldı (%$percentage)',
        'de': '$unlocked von $total Abzeichen verdient ($percentage%)',
      });

  String unlockedCountOfTotal(int unlocked, int total) => _t({
        'en': '$unlocked of $total unlocked',
        'ar': 'تم فتح $unlocked من $total',
        'tr': '$total taneden $unlocked tanesi açıldı',
        'de': '$unlocked von $total freigeschaltet',
      });

  String exploreAllMilestones(int count) => _t({
        'en': 'Explore all $count milestones',
        'ar': 'استكشف جميع الإنجازات الـ $count',
        'tr': 'Tüm $count başarıyı keşfedin',
        'de': 'Alle $count Meilensteine ansehen',
      });

  String activeDaysThisWeek(int count) => _t({
        'en': '$count of 7 active days this week',
        'ar': '$count من 7 أيام نشطة هذا الأسبوع',
        'tr': 'Bu hafta 7 günün $count günü aktif',
        'de': '$count von 7 aktiven Tagen diese Woche',
      });

  String milestoneUnlocked(String title) => _t({
        'en': '🏆 Milestone Unlocked: $title!',
        'ar': '🏆 تم فتح إنجاز: $title!',
        'tr': '🏆 Başarı Açıldı: $title!',
        'de': '🏆 Meilenstein freigeschaltet: $title!',
      });

  String nextReviewIn(String time) => _t({
        'en': 'Next review: $time',
        'ar': 'المراجعة التالية: $time',
        'tr': 'Sonraki tekrar: $time',
        'de': 'Nächste Wiederholung: $time',
      });

  String reviewIn(String time) => _t({
        'en': 'Review in $time',
        'ar': 'المراجعة خلال $time',
        'tr': '$time içinde tekrar',
        'de': 'Wiederholung in $time',
      });

  String get saveForReview => _t({
        'en': 'Save for focused review',
        'ar': 'حفظ للمراجعة المركزة',
        'tr': 'Odaklı tekrar için kaydet',
        'de': 'Für Wiederholung speichern',
      });

  String memberSince(String date) => _t({
        'en': 'Member since $date',
        'ar': 'عضو منذ $date',
        'tr': '$date tarihinden beri üye',
        'de': 'Mitglied seit $date',
      });

  String learningSince(String date) => _t({
        'en': 'Learning since $date',
        'ar': 'يتعلم منذ $date',
        'tr': '$date tarihinden beri öğreniyor',
        'de': 'Lernt seit $date',
      });

  String wordsCount(int count) => _t({
        'en': '$count ${count == 1 ? 'word' : 'words'}',
        'ar': '$count كلمة',
        'tr': '$count kelime',
        'de': '$count ${count == 1 ? 'Wort' : 'Wörter'}',
      });

  String get noQuizYet => _t({
        'en': 'no quiz yet',
        'ar': 'لا توجد اختبارات بعد',
        'tr': 'henüz alıştırma yok',
        'de': 'noch kein Quiz',
      });

  String percentCorrect(int percent) => _t({
        'en': '$percent% correct',
        'ar': '$percent% صحيح',
        'tr': '%$percent doğru',
        'de': '$percent% richtig',
      });

  String percentOfTrackedWords(int percent) => _t({
        'en': '$percent% of tracked words',
        'ar': '$percent% من الكلمات المسجلة',
        'tr': 'takip edilen kelimelerin %$percent\'i',
        'de': '$percent% der erfassten Wörter',
      });

  String get articleMasteryEmpty => _t({
        'en': 'Look up or quiz a few words to see how you do with der, die and das.',
        'ar': 'ابحث عن كلمات أو أجرِ اختبارات لترى أداءك مع der و die و das.',
        'tr': 'der, die ve das ile performansınızı görmek için kelimeleri arayın veya alıştırma yapın.',
        'de': 'Schlage Wörter nach oder mache Quizzes, um deine Trefferquote für der, die und das zu sehen.',
      });

  String get srsMasteryEmpty => _t({
        'en': 'Quiz nouns to begin spaced repetition tracking and retention intervals.',
        'ar': 'أجرِ اختبارات للأسماء لبدء تتبع التكرار المتباعد وفترات التثبيت.',
        'tr': 'Aralıklı tekrar takibi ve aralıkları başlatmak için isimlerle alıştırma yapın.',
        'de': 'Übe Nomen im Quiz, um das Spaced Repetition Tracking und Wiederholungsintervalle zu starten.',
      });

  String get advancedStatsEmpty => _t({
        'en': 'Complete quizzes or look up words to build your weekly activity heatmap and progress trends.',
        'ar': 'أكمل الاختبارات أو ابحث عن كلمات لبناء مخطط النشاط الأسبوعي واتجاهات التقدم.',
        'tr': 'Haftalık etkinlik haritanızı ve eğilimlerinizi oluşturmak için alıştırmaları tamamlayın veya kelime arayın.',
        'de': 'Mache Quizzes oder schlage Wörter nach, um deine wöchentliche Aktivitäts-Heatmap und Fortschrittstrends aufzubauen.',
      });

  String get editDisplayNameTitle => _t({
        'en': 'Display name',
        'ar': 'اسم العرض',
        'tr': 'Görünen ad',
        'de': 'Anzeigename',
      });

  String get editDisplayNameSubtitle => _t({
        'en': 'This is how you\'ll appear across Kapiert.',
        'ar': 'هكذا سيظهر اسمك في تطبيق Kapiert.',
        'tr': 'Kapiert genelinde bu şekilde görüneceksiniz.',
        'de': 'So wirst du in Kapiert angezeigt.',
      });

  String get nameLabel => _t({
        'en': 'Name',
        'ar': 'الاسم',
        'tr': 'İsim',
        'de': 'Name',
      });

  String get couldNotSaveName => _t({
        'en': 'Couldn\'t save your name. Check your connection and try again.',
        'ar': 'تعذر حفظ اسمك. تحقق من اتصالك وحاول مرة أخرى.',
        'tr': 'İsminiz kaydedilemedi. Bağlantınızı kontrol edip tekrar deneyin.',
        'de': 'Name konnte nicht gespeichert werden. Bitte Verbindung prüfen und erneut versuchen.',
      });

  String get noActivityOnDay => _t({
        'en': 'No activity recorded on this day.',
        'ar': 'لم يتم تسجيل أي نشاط في هذا اليوم.',
        'tr': 'Bu günde kaydedilmiş etkinlik yok.',
        'de': 'Keine Aktivitäten an diesem Tag aufgezeichnet.',
      });

  String dayActivitySummary(int actions, int quizzes, int accuracy, int words) => _t({
        'en': '$actions actions ($quizzes quizzes, $accuracy% accuracy, $words words)',
        'ar': '$actions عملية ($quizzes اختبار، دقة $accuracy%، $words كلمة)',
        'tr': '$actions işlem ($quizzes alıştırma, %$accuracy isabet, $words kelime)',
        'de': '$actions Aktionen ($quizzes Quizzes, $accuracy% Genauigkeit, $words Wörter)',
      });

  String categoryLabel(String category) {
    switch (category.toLowerCase()) {
      case 'streak':
      case 'streaks':
        return _t({
          'en': 'Streaks',
          'ar': 'التتابع',
          'tr': 'Seriler',
          'de': 'Serien',
        });
      case 'vocabulary':
        return _t({
          'en': 'Vocabulary',
          'ar': 'المفردات',
          'tr': 'Kelime Bilgisi',
          'de': 'Wortschatz',
        });
      case 'mastery':
        return _t({
          'en': 'Mastery',
          'ar': 'الإتقان',
          'tr': 'Ustalık',
          'de': 'Meisterschaft',
        });
      case 'srs':
      case 'retention':
        return _t({
          'en': 'Retention',
          'ar': 'التثبيت',
          'tr': 'Hatırlama',
          'de': 'Wiederholung',
        });
      case 'favorites':
        return _t({
          'en': 'Favorites',
          'ar': 'المفضلة',
          'tr': 'Favoriler',
          'de': 'Favoriten',
        });
      default:
        return category;
    }
  }

  String srsIntervalText(int stage, {bool isCorrect = true}) {
    switch (stage) {
      case 1:
        return isCorrect
            ? _t({
                'en': '4 hours',
                'ar': '4 ساعات',
                'tr': '4 saat',
                'de': '4 Stunden',
              })
            : _t({
                'en': '4 hours (review soon)',
                'ar': '4 ساعات (مراجعة قريباً)',
                'tr': '4 saat (yakında tekrar)',
                'de': '4 Stunden (bald wiederholen)',
              });
      case 2:
        return _t({
          'en': '1 day',
          'ar': 'يوم واحد',
          'tr': '1 gün',
          'de': '1 Tag',
        });
      case 3:
        return _t({
          'en': '3 days',
          'ar': '3 أيام',
          'tr': '3 gün',
          'de': '3 Tage',
        });
      case 4:
        return _t({
          'en': '7 days',
          'ar': '7 أيام',
          'tr': '7 gün',
          'de': '7 Tage',
        });
      case 5:
      default:
        return _t({
          'en': '14 days',
          'ar': '14 يوماً',
          'tr': '14 gün',
          'de': '14 Tage',
        });
    }
  }

  String srsStageName(int stage) {
    switch (stage) {
      case 1:
        return stageLearning;
      case 2:
        return stageReviewWord;
      case 3:
        return stageSolid;
      case 4:
      case 5:
      default:
        return stageMastered;
    }
  }

  String genderLabel(String gender) {
    switch (gender.toLowerCase()) {
      case 'm':
      case 'masculine':
        return masculine;
      case 'f':
      case 'feminine':
        return feminine;
      case 'n':
      case 'neuter':
        return neuter;
      default:
        return gender;
    }
  }

  String sourceLabel(String source) {
    switch (source.toLowerCase()) {
      case 'dataset':
        return sourceFromDataset;
      case 'wiktionary':
        return sourceViaWiktionary;
      case 'offline':
      case 'offline_cache':
        return sourceOfflineCache;
      default:
        return source;
    }
  }

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
