import '../../core/storage/storage_service.dart';
import '../../domain/models/local_sentence_provider.dart';
import '../../domain/models/word_model.dart';

/// Local data source providing offline SQLite article cache, query normalization,
/// compound noun analysis, and pre-seeded high-frequency German vocabulary.
class ArticleLocalDS {
  const ArticleLocalDS();

  // ---------------------------------------------------------------------------
  // Core Lookups & Normalization
  // ---------------------------------------------------------------------------

  /// Looks up a German word from the offline cache with robust normalization.
  Future<WordModel?> lookup(String word) async {
    final clean = _normalize(word);
    if (clean.isEmpty) return null;

    if (StorageService.isInitialized) {
      // 1. Direct SQLite cache lookup
      final directMatch = await StorageService.getCachedArticle(clean);
      if (directMatch != null) return directMatch;

      // 2. Umlaut & spelling variation lookups
      for (final variant in _spellingVariants(clean)) {
        final variantMatch = await StorageService.getCachedArticle(variant);
        if (variantMatch != null) return variantMatch;
      }
    }

    // 3. Fallback to built-in core vocabulary
    final coreMatch = _coreVocabulary[clean.toLowerCase()];
    if (coreMatch != null) {
      if (StorageService.isInitialized) {
        await StorageService.cacheArticle(coreMatch);
      }
      return coreMatch;
    }

    // 4. Compound noun suffix analysis:
    // In German, compound nouns ALWAYS inherit their gender and article from the final base noun
    // (e.g. "Küchentisch" -> ends with "Tisch" -> "der Tisch").
    final compoundMatch = _findCompoundBase(clean);
    if (compoundMatch != null) {
      final compoundWord = WordModel(
        word: _capitalize(clean),
        article: compoundMatch.article,
        gender: compoundMatch.gender,
        plural: compoundMatch.plural != null
            ? '${_capitalize(clean.substring(0, clean.length - compoundMatch.word.length))}${compoundMatch.plural}'
            : null,
        translation: compoundMatch.translation != null
            ? 'Compound of ${compoundMatch.word} (${compoundMatch.translation})'
            : null,
        exampleSentence: LocalSentenceProvider.getSentence(
          clean,
          compoundMatch.article,
          translation: compoundMatch.translation,
        ),
        source: 'offline_cache',
      );
      if (StorageService.isInitialized) {
        await StorageService.cacheArticle(compoundWord);
      }
      return compoundWord;
    }

    return null;
  }

  /// Caches a single article into the local SQLite store.
  Future<void> cacheWord(WordModel word) async {
    if (StorageService.isInitialized) {
      await StorageService.cacheArticle(word);
    }
  }

  /// Bulk caches multiple articles in a single database transaction.
  Future<void> cacheWords(List<WordModel> words) async {
    if (StorageService.isInitialized) {
      await StorageService.cacheArticles(words);
    }
  }

  /// Retrieves a random cached word.
  Future<WordModel?> getRandomWord() async {
    if (StorageService.isInitialized) {
      final list = await StorageService.getRandomCachedArticles(count: 1);
      if (list.isNotEmpty) return list.first;
    }

    // If cache is currently empty or uninitialized, draw from core vocabulary
    if (_coreVocabulary.isNotEmpty) {
      final randomKey = (_coreVocabulary.keys.toList()..shuffle()).first;
      return _coreVocabulary[randomKey];
    }
    return null;
  }

  /// Retrieves a batch of random cached words for offline quizzes.
  Future<List<WordModel>> getRandomBatch({int count = 15}) async {
    final cached = StorageService.isInitialized
        ? await StorageService.getRandomCachedArticles(count: count)
        : <WordModel>[];
    if (cached.length >= count) return cached;

    // Supplement with pre-seeded core vocabulary if cache has fewer items
    final results = <String, WordModel>{};
    for (final word in cached) {
      results[word.word.toLowerCase()] = word;
    }

    final shuffledCore = _coreVocabulary.values.toList()..shuffle();
    for (final word in shuffledCore) {
      if (results.length >= count) break;
      results[word.word.toLowerCase()] = word;
    }

    return results.values.toList();
  }

  /// Searches cached articles by substring.
  Future<List<WordModel>> search(String query, {int limit = 20}) async {
    if (StorageService.isInitialized) {
      return StorageService.searchCachedArticles(query, limit: limit);
    }
    final clean = query.trim().toLowerCase();
    if (clean.isEmpty) return const [];
    return _coreVocabulary.values
        .where((w) => w.word.toLowerCase().contains(clean))
        .take(limit)
        .toList();
  }

  /// Returns total count of words in SQLite offline cache.
  Future<int> getCachedCount() async {
    if (StorageService.isInitialized) {
      return StorageService.getCachedArticlesCount();
    }
    return _coreVocabulary.length;
  }

  /// Clears the local offline article cache.
  Future<void> clearCache() async {
    if (StorageService.isInitialized) {
      await StorageService.clearArticleCache();
    }
  }

  /// Pre-seeds the SQLite cache with all essential core German vocabulary.
  Future<int> preseedCoreVocabulary() async {
    final allCore = _coreVocabulary.values.toList();
    if (StorageService.isInitialized) {
      await StorageService.cacheArticles(allCore);
    }
    return allCore.length;
  }

  // ---------------------------------------------------------------------------
  // Normalization Helpers
  // ---------------------------------------------------------------------------

  /// Strips leading German definite and indefinite articles, whitespace, and punctuation.
  static String _normalize(String input) {
    var text = input.trim();
    // Strip leading articles (der, die, das, ein, eine, etc.)
    final articlePrefixRegex = RegExp(
      r'^(?:der|die|das|dem|den|des|ein|eine|einen|einem|eines)\s+',
      caseSensitive: false,
    );
    text = text.replaceAll(articlePrefixRegex, '').trim();
    // Remove any trailing punctuation
    text = text.replaceAll(RegExp(r'[.,!?:;]+$'), '').trim();
    return text;
  }

  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  /// Generates umlaut and sharp-s transcriptions for fuzzy matching.
  static List<String> _spellingVariants(String word) {
    final variants = <String>{};
    final lower = word.toLowerCase();

    // From transcription to umlaut
    if (lower.contains('ae') ||
        lower.contains('oe') ||
        lower.contains('ue') ||
        lower.contains('ss')) {
      final transformed = lower
          .replaceAll('ae', 'ä')
          .replaceAll('oe', 'ö')
          .replaceAll('ue', 'ü')
          .replaceAll('ss', 'ß');
      variants.add(transformed);
    }

    // From umlaut to transcription
    if (lower.contains('ä') ||
        lower.contains('ö') ||
        lower.contains('ü') ||
        lower.contains('ß')) {
      final transformed = lower
          .replaceAll('ä', 'ae')
          .replaceAll('ö', 'oe')
          .replaceAll('ü', 'ue')
          .replaceAll('ß', 'ss');
      variants.add(transformed);
    }

    return variants.toList();
  }

  /// Matches the compound head noun (the last noun segment).
  WordModel? _findCompoundBase(String query) {
    final lower = query.toLowerCase();
    // Try matching suffixes of length >= 3
    WordModel? bestMatch;
    var maxLen = 0;

    for (final entry in _coreVocabulary.entries) {
      final base = entry.key;
      if (base.length >= 3 && lower.endsWith(base) && lower.length > base.length) {
        if (base.length > maxLen) {
          maxLen = base.length;
          bestMatch = entry.value;
        }
      }
    }
    return bestMatch;
  }

  // ---------------------------------------------------------------------------
  // Built-in Core Vocabulary (100+ Essential German Nouns)
  // ---------------------------------------------------------------------------

  static final Map<String, WordModel> _coreVocabulary = _buildCoreVocabulary();

  static Map<String, WordModel> _buildCoreVocabulary() {
    final defs = <(String, String, String, String?, String)>[
      // Masculine (der) - Foods & Drinks
      ('Apfel', 'der', 'm', 'Äpfel', 'apple / تفاحة / elma'),
      ('Salat', 'der', 'm', 'Salate', 'salad / سلطة / salata'),
      ('Kuchen', 'der', 'm', 'Kuchen', 'cake / كعكة / kek'),
      ('Tee', 'der', 'm', 'Tees', 'tea / شاي / çay'),
      ('Kaffee', 'der', 'm', 'Kaffees', 'coffee / قهوة / kahve'),
      ('Saft', 'der', 'm', 'Säfte', 'juice / عصير / meyve suyu'),
      ('Wein', 'der', 'm', 'Weine', 'wine / نبيذ / şarap'),
      ('Zucker', 'der', 'm', null, 'sugar / سكر / şeker'),
      ('Käse', 'der', 'm', 'Käse', 'cheese / جبن / peynir'),
      ('Fisch', 'der', 'm', 'Fische', 'fish / سمك / balık'),

      // Masculine (der) - Home & Daily Objects
      ('Tisch', 'der', 'm', 'Tische', 'table / طاولة / masa'),
      ('Stuhl', 'der', 'm', 'Stühle', 'chair / كرسي / sandalye'),
      ('Schrank', 'der', 'm', 'Schränke', 'closet / خزانة / dolap'),
      ('Teppich', 'der', 'm', 'Teppiche', 'carpet / سجادة / halı'),
      ('Garten', 'der', 'm', 'Gärten', 'garden / حديقة / bahçe'),
      ('Balkon', 'der', 'm', 'Balkone', 'balcony / شرفة / balkon'),
      ('Teller', 'der', 'm', 'Teller', 'plate / صحن / tabak'),
      ('Löffel', 'der', 'm', 'Löffel', 'spoon / ملعقة / kaşık'),
      ('Schlüssel', 'der', 'm', 'Schlüssel', 'key / مفتاح / anahtar'),
      ('Bleistift', 'der', 'm', 'Bleistifte', 'pencil / قلم رصاص / kurşun kalem'),
      ('Stift', 'der', 'm', 'Stifte', 'pen / قلم / tükenmez kalem'),
      ('Computer', 'der', 'm', 'Computer', 'computer / حاسوب / bilgisayar'),

      // Masculine (der) - Nature, People & Places
      ('Hund', 'der', 'm', 'Hunde', 'dog / كلب / köpek'),
      ('Vogel', 'der', 'm', 'Vögel', 'bird / عصفور / kuş'),
      ('Mann', 'der', 'm', 'Männer', 'man / رجل / adam'),
      ('Junge', 'der', 'm', 'Jungen', 'boy / صبي / erkek çocuk'),
      ('Vater', 'der', 'm', 'Väter', 'father / أب / baba'),
      ('Sohn', 'der', 'm', 'Söhne', 'son / ابن / oğul'),
      ('Bruder', 'der', 'm', 'Brüder', 'brother / أخ / erkek kardeş'),
      ('Freund', 'der', 'm', 'Freunde', 'friend / صديق / arkadaş'),
      ('Arzt', 'der', 'm', 'Ärzte', 'doctor / طبيب / doktor'),
      ('Lehrer', 'der', 'm', 'Lehrer', 'teacher / معلم / öğretmen'),
      ('Bus', 'der', 'm', 'Busse', 'bus / حافلة / otobüs'),
      ('Zug', 'der', 'm', 'Züge', 'train / قطار / tren'),
      ('Bahnhof', 'der', 'm', 'Bahnhöfe', 'train station / محطة قطار / tren istasyonu'),
      ('Flughafen', 'der', 'm', 'Flughäfen', 'airport / مطار / havalimanı'),
      ('Baum', 'der', 'm', 'Bäume', 'tree / شجرة / ağaç'),
      ('Berg', 'der', 'm', 'Berge', 'mountain / جبل / dağ'),
      ('Fluss', 'der', 'm', 'Flüsse', 'river / نهر / nehir'),
      ('Mond', 'der', 'm', 'Monde', 'moon / قمر / ay'),
      ('Stern', 'der', 'm', 'Sterne', 'star / نجم / yıldız'),
      ('Himmel', 'der', 'm', null, 'sky / سماء / gökyüzü'),
      ('Regen', 'der', 'm', null, 'rain / مطر / yağmur'),
      ('Schnee', 'der', 'm', null, 'snow / ثلج / kar'),
      ('Wind', 'der', 'm', 'Winde', 'wind / رياح / rüzgar'),

      // Feminine (die) - Foods & Drinks
      ('Banane', 'die', 'f', 'Bananen', 'banana / موزة / muz'),
      ('Orange', 'die', 'f', 'Orangen', 'orange / برتقالة / portakal'),
      ('Zitrone', 'die', 'f', 'Zitronen', 'lemon / ليمونة / limon'),
      ('Kartoffel', 'die', 'f', 'Kartoffeln', 'potato / بطاطا / patates'),
      ('Tomate', 'die', 'f', 'Tomaten', 'tomato / طماطم / domates'),
      ('Suppe', 'die', 'f', 'Suppen', 'soup / حساء / çorba'),
      ('Milch', 'die', 'f', null, 'milk / حليب / süt'),
      ('Schokolade', 'die', 'f', 'Schokoladen', 'chocolate / شوكولاتة / çikolata'),

      // Feminine (die) - Home & Daily Objects
      ('Lampe', 'die', 'f', 'Lampen', 'lamp / مصباح / lamba'),
      ('Tür', 'die', 'f', 'Türen', 'door / باب / kapı'),
      ('Küche', 'die', 'f', 'Küchen', 'kitchen / مطبخ / mutfak'),
      ('Wohnung', 'die', 'f', 'Wohnungen', 'apartment / شقة / daire'),
      ('Tasse', 'die', 'f', 'Tassen', 'cup / كوب / fincan'),
      ('Gabel', 'die', 'f', 'Gabeln', 'fork / شوكة / çatal'),
      ('Tasche', 'die', 'f', 'Taschen', 'bag / حقيبة / çanta'),
      ('Uhr', 'die', 'f', 'Uhren', 'clock / ساعة / saat'),
      ('Zeitung', 'die', 'f', 'Zeitungen', 'newspaper / جريدة / gazete'),

      // Feminine (die) - Nature, People & Places
      ('Frau', 'die', 'f', 'Frauen', 'woman / امرأة / kadın'),
      ('Mutter', 'die', 'f', 'Mütter', 'mother / أم / anne'),
      ('Tochter', 'die', 'f', 'Töchter', 'daughter / ابنة / kız evlat'),
      ('Schwester', 'die', 'f', 'Schwestern', 'sister / أخت / kız kardeş'),
      ('Freundin', 'die', 'f', 'Freundinnen', 'friend / صديقة / kız arkadaş'),
      ('Ärztin', 'die', 'f', 'Ärztinnen', 'female doctor / طبيبة / kadın doktor'),
      ('Familie', 'die', 'f', 'Familien', 'family / عائلة / aile'),
      ('Katze', 'die', 'f', 'Katzen', 'cat / قطة / kedi'),
      ('Kuh', 'die', 'f', 'Kühe', 'cow / بقرة / inek'),
      ('Blume', 'die', 'f', 'Blumen', 'flower / زهرة / çiçek'),
      ('Sonne', 'die', 'f', null, 'sun / شمس / güneş'),
      ('Straße', 'die', 'f', 'Straßen', 'street / شارع / sokak'),
      ('Stadt', 'die', 'f', 'Städte', 'city / مدينة / şehir'),
      ('Schule', 'die', 'f', 'Schulen', 'school / مدرسة / okul'),
      ('Universität', 'die', 'f', 'Universitäten', 'university / جامعة / üniversite'),
      ('Bahn', 'die', 'f', 'Bahnen', 'railway / قطار / tren'),

      // Neuter (das) - Foods & Drinks
      ('Brot', 'das', 'n', 'Brote', 'bread / خبز / ekmek'),
      ('Brötchen', 'das', 'n', 'Brötchen', 'bread roll / لفة خبز / küçük ekmek'),
      ('Fleisch', 'das', 'n', null, 'meat / لحم / et'),
      ('Wasser', 'das', 'n', 'Wässer', 'water / ماء / su'),
      ('Bier', 'das', 'n', 'Biere', 'beer / بيرة / bira'),
      ('Salz', 'das', 'n', 'Salze', 'salt / ملح / tuz'),
      ('Ei', 'das', 'n', 'Eier', 'egg / بيضة / yumurta'),

      // Neuter (das) - Home & Daily Objects
      ('Bett', 'das', 'n', 'Betten', 'bed / سرير / yatak'),
      ('Sofa', 'das', 'n', 'Sofas', 'sofa / أريكة / kanepe'),
      ('Fenster', 'das', 'n', 'Fenster', 'window / نافذة / pencere'),
      ('Zimmer', 'das', 'n', 'Zimmer', 'room / غرفة / oda'),
      ('Bad', 'das', 'n', 'Bäder', 'bathroom / حمام / banyo'),
      ('Haus', 'das', 'n', 'Häuser', 'house / منزل / ev'),
      ('Glas', 'das', 'n', 'Gläser', 'glass / كأس / bardak'),
      ('Messer', 'das', 'n', 'Messer', 'knife / سكين / bıçak'),
      ('Buch', 'das', 'n', 'Bücher', 'book / كتاب / kitap'),
      ('Heft', 'das', 'n', 'Hefte', 'notebook / دفتر / defter'),
      ('Handy', 'das', 'n', 'Handys', 'cellphone / هاتف محمول / cep telefonu'),
      ('Geld', 'das', 'n', 'Gelder', 'money / نقود / para'),

      // Neuter (das) - Nature, People & Places
      ('Auto', 'das', 'n', 'Autos', 'car / سيارة / araba'),
      ('Fahrrad', 'das', 'n', 'Fahrräder', 'bicycle / دراجة / bisiklet'),
      ('Flugzeug', 'das', 'n', 'Flugzeuge', 'airplane / طائرة / uçak'),
      ('Kind', 'das', 'n', 'Kinder', 'child / طفل / çocuk'),
      ('Mädchen', 'das', 'n', 'Mädchen', 'girl / فتاة / kız'),
      ('Pferd', 'das', 'n', 'Pferde', 'horse / حصان / at'),
      ('Land', 'das', 'n', 'Länder', 'country / بلد / ülke'),
      ('Meer', 'das', 'n', 'Meere', 'sea / بحر / deniz'),
      ('Wetter', 'das', 'n', null, 'weather / طقس / hava'),
    ];

    final map = <String, WordModel>{};
    for (final (word, article, gender, plural, translation) in defs) {
      final sentence = LocalSentenceProvider.getSentence(
        word,
        article,
        translation: translation,
      );
      map[word.toLowerCase()] = WordModel(
        word: word,
        article: article,
        gender: gender,
        plural: plural,
        translation: translation,
        exampleSentence: sentence,
        source: 'offline_cache',
      );
    }
    return map;
  }
}
