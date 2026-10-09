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

  /// Returns article cache stats breakdown: total, der, die, das counts.
  Future<Map<String, int>> getCachedStats() async {
    if (StorageService.isInitialized) {
      return StorageService.getCachedArticlesStats();
    }
    int der = 0, die = 0, das = 0;
    for (final w in _coreVocabulary.values) {
      if (w.article == 'der') {
        der++;
      } else if (w.article == 'die') {
        die++;
      } else if (w.article == 'das') {
        das++;
      }
    }
    return {
      'total': _coreVocabulary.length,
      'der': der,
      'die': die,
      'das': das,
    };
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

  /// Pre-seeds the SQLite cache with extended high-frequency German vocabulary.
  Future<int> preseedExtendedVocabulary() async {
    return preseedCoreVocabulary();
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
      ('Apfel', 'der', 'm', 'Äpfel', 'apple'),
      ('Salat', 'der', 'm', 'Salate', 'salad, lettuce'),
      ('Kuchen', 'der', 'm', 'Kuchen', 'cake'),
      ('Tee', 'der', 'm', 'Tees', 'tea'),
      ('Kaffee', 'der', 'm', 'Kaffees', 'coffee'),
      ('Saft', 'der', 'm', 'Säfte', 'juice'),
      ('Wein', 'der', 'm', 'Weine', 'wine'),
      ('Zucker', 'der', 'm', null, 'sugar'),
      ('Käse', 'der', 'm', 'Käse', 'cheese'),
      ('Fisch', 'der', 'm', 'Fische', 'fish'),

      // Masculine (der) - Home & Daily Objects
      ('Tisch', 'der', 'm', 'Tische', 'table'),
      ('Stuhl', 'der', 'm', 'Stühle', 'chair'),
      ('Schrank', 'der', 'm', 'Schränke', 'closet, wardrobe'),
      ('Teppich', 'der', 'm', 'Teppiche', 'carpet, rug'),
      ('Garten', 'der', 'm', 'Gärten', 'garden'),
      ('Balkon', 'der', 'm', 'Balkone', 'balcony'),
      ('Teller', 'der', 'm', 'Teller', 'plate'),
      ('Löffel', 'der', 'm', 'Löffel', 'spoon'),
      ('Schlüssel', 'der', 'm', 'Schlüssel', 'key'),
      ('Bleistift', 'der', 'm', 'Bleistifte', 'pencil'),
      ('Stift', 'der', 'm', 'Stifte', 'pen'),
      ('Computer', 'der', 'm', 'Computer', 'computer'),

      // Masculine (der) - Nature, People & Places
      ('Hund', 'der', 'm', 'Hunde', 'dog'),
      ('Vogel', 'der', 'm', 'Vögel', 'bird'),
      ('Mann', 'der', 'm', 'Männer', 'man, husband'),
      ('Junge', 'der', 'm', 'Jungen', 'boy'),
      ('Vater', 'der', 'm', 'Väter', 'father'),
      ('Sohn', 'der', 'm', 'Söhne', 'son'),
      ('Bruder', 'der', 'm', 'Brüder', 'brother'),
      ('Freund', 'der', 'm', 'Freunde', 'friend, boyfriend'),
      ('Arzt', 'der', 'm', 'Ärzte', 'doctor, physician'),
      ('Lehrer', 'der', 'm', 'Lehrer', 'teacher'),
      ('Bus', 'der', 'm', 'Busse', 'bus'),
      ('Zug', 'der', 'm', 'Züge', 'train'),
      ('Bahnhof', 'der', 'm', 'Bahnhöfe', 'train station'),
      ('Flughafen', 'der', 'm', 'Flughäfen', 'airport'),
      ('Baum', 'der', 'm', 'Bäume', 'tree'),
      ('Berg', 'der', 'm', 'Berge', 'mountain'),
      ('Fluss', 'der', 'm', 'Flüsse', 'river'),
      ('Mond', 'der', 'm', 'Monde', 'moon'),
      ('Stern', 'der', 'm', 'Sterne', 'star'),
      ('Himmel', 'der', 'm', null, 'sky, heaven'),
      ('Regen', 'der', 'm', null, 'rain'),
      ('Schnee', 'der', 'm', null, 'snow'),
      ('Wind', 'der', 'm', 'Winde', 'wind'),

      // Feminine (die) - Foods & Drinks
      ('Banane', 'die', 'f', 'Bananen', 'banana'),
      ('Orange', 'die', 'f', 'Orangen', 'orange'),
      ('Zitrone', 'die', 'f', 'Zitronen', 'lemon'),
      ('Kartoffel', 'die', 'f', 'Kartoffeln', 'potato'),
      ('Tomate', 'die', 'f', 'Tomaten', 'tomato'),
      ('Suppe', 'die', 'f', 'Suppen', 'soup'),
      ('Milch', 'die', 'f', null, 'milk'),
      ('Schokolade', 'die', 'f', 'Schokoladen', 'chocolate'),

      // Feminine (die) - Home & Daily Objects
      ('Lampe', 'die', 'f', 'Lampen', 'lamp'),
      ('Tür', 'die', 'f', 'Türen', 'door'),
      ('Küche', 'die', 'f', 'Küchen', 'kitchen'),
      ('Wohnung', 'die', 'f', 'Wohnungen', 'apartment, flat'),
      ('Tasse', 'die', 'f', 'Tassen', 'cup, mug'),
      ('Gabel', 'die', 'f', 'Gabeln', 'fork'),
      ('Tasche', 'die', 'f', 'Taschen', 'bag, purse'),
      ('Uhr', 'die', 'f', 'Uhren', 'clock, watch'),
      ('Zeitung', 'die', 'f', 'Zeitungen', 'newspaper'),

      // Feminine (die) - Nature, People & Places
      ('Frau', 'die', 'f', 'Frauen', 'woman, wife'),
      ('Mutter', 'die', 'f', 'Mütter', 'mother'),
      ('Tochter', 'die', 'f', 'Töchter', 'daughter'),
      ('Schwester', 'die', 'f', 'Schwestern', 'sister'),
      ('Freundin', 'die', 'f', 'Freundinnen', 'friend, girlfriend'),
      ('Ärztin', 'die', 'f', 'Ärztinnen', 'female doctor'),
      ('Familie', 'die', 'f', 'Familien', 'family'),
      ('Katze', 'die', 'f', 'Katzen', 'cat'),
      ('Kuh', 'die', 'f', 'Kühe', 'cow'),
      ('Blume', 'die', 'f', 'Blumen', 'flower'),
      ('Sonne', 'die', 'f', null, 'sun'),
      ('Straße', 'die', 'f', 'Straßen', 'street, road'),
      ('Stadt', 'die', 'f', 'Städte', 'city, town'),
      ('Schule', 'die', 'f', 'Schulen', 'school'),
      ('Universität', 'die', 'f', 'Universitäten', 'university'),
      ('Bahn', 'die', 'f', 'Bahnen', 'railway, train'),

      // Neuter (das) - Foods & Drinks
      ('Brot', 'das', 'n', 'Brote', 'bread'),
      ('Brötchen', 'das', 'n', 'Brötchen', 'bread roll'),
      ('Fleisch', 'das', 'n', null, 'meat'),
      ('Wasser', 'das', 'n', 'Wässer', 'water'),
      ('Bier', 'das', 'n', 'Biere', 'beer'),
      ('Salz', 'das', 'n', 'Salze', 'salt'),
      ('Ei', 'das', 'n', 'Eier', 'egg'),

      // Neuter (das) - Home & Daily Objects
      ('Bett', 'das', 'n', 'Betten', 'bed'),
      ('Sofa', 'das', 'n', 'Sofas', 'sofa, couch'),
      ('Fenster', 'das', 'n', 'Fenster', 'window'),
      ('Zimmer', 'das', 'n', 'Zimmer', 'room'),
      ('Bad', 'das', 'n', 'Bäder', 'bathroom, bath'),
      ('Haus', 'das', 'n', 'Häuser', 'house, building'),
      ('Glas', 'das', 'n', 'Gläser', 'glass'),
      ('Messer', 'das', 'n', 'Messer', 'knife'),
      ('Buch', 'das', 'n', 'Bücher', 'book'),
      ('Heft', 'das', 'n', 'Hefte', 'notebook'),
      ('Handy', 'das', 'n', 'Handys', 'cellphone, mobile phone'),
      ('Geld', 'das', 'n', 'Gelder', 'money'),

      // Neuter (das) - Nature, People & Places
      ('Auto', 'das', 'n', 'Autos', 'car, automobile'),
      ('Fahrrad', 'das', 'n', 'Fahrräder', 'bicycle, bike'),
      ('Flugzeug', 'das', 'n', 'Flugzeuge', 'airplane, plane'),
      ('Kind', 'das', 'n', 'Kinder', 'child'),
      ('Mädchen', 'das', 'n', 'Mädchen', 'girl'),
      ('Pferd', 'das', 'n', 'Pferde', 'horse'),
      ('Land', 'das', 'n', 'Länder', 'country, land'),
      ('Meer', 'das', 'n', 'Meere', 'sea, ocean'),
      ('Wetter', 'das', 'n', null, 'weather'),

      // Extended High-Frequency Vocabulary
      // Masculine (der)
      ('Körper', 'der', 'm', 'Körper', 'body'),
      ('Kopf', 'der', 'm', 'Köpfe', 'head'),
      ('Arm', 'der', 'm', 'Arme', 'arm'),
      ('Fuß', 'der', 'm', 'Füße', 'foot'),
      ('Mund', 'der', 'm', 'Münder', 'mouth'),
      ('Tag', 'der', 'm', 'Tage', 'day'),
      ('Monat', 'der', 'm', 'Monate', 'month'),
      ('Abend', 'der', 'm', 'Abende', 'evening'),
      ('Morgen', 'der', 'm', 'Morgen', 'morning'),
      ('Sommer', 'der', 'm', 'Sommer', 'summer'),
      ('Winter', 'der', 'm', 'Winter', 'winter'),
      ('Herbst', 'der', 'm', 'Herbste', 'autumn, fall'),
      ('Frühling', 'der', 'm', 'Frühlinge', 'spring'),
      ('Urlaub', 'der', 'm', 'Urlaube', 'vacation, holiday'),
      ('Brief', 'der', 'm', 'Briefe', 'letter'),
      ('Koffer', 'der', 'm', 'Koffer', 'suitcase'),
      ('Wald', 'der', 'm', 'Wälder', 'forest, woods'),
      ('See', 'der', 'm', 'Seen', 'lake'),

      // Feminine (die)
      ('Hand', 'die', 'f', 'Hände', 'hand'),
      ('Nase', 'die', 'f', 'Nasen', 'nose'),
      ('Nacht', 'die', 'f', 'Nächte', 'night'),
      ('Woche', 'die', 'f', 'Wochen', 'week'),
      ('Stunde', 'die', 'f', 'Stunden', 'hour'),
      ('Minute', 'die', 'f', 'Minuten', 'minute'),
      ('Zeit', 'die', 'f', 'Zeiten', 'time'),
      ('Arbeit', 'die', 'f', 'Arbeiten', 'work, job'),
      ('Musik', 'die', 'f', null, 'music'),
      ('Farbe', 'die', 'f', 'Farben', 'color'),
      ('Frage', 'die', 'f', 'Fragen', 'question'),
      ('Antwort', 'die', 'f', 'Antworten', 'answer'),
      ('Reise', 'die', 'f', 'Reisen', 'journey, travel'),
      ('Karte', 'die', 'f', 'Karten', 'card, map, ticket'),
      ('Welt', 'die', 'f', 'Welten', 'world'),
      ('Luft', 'die', 'f', null, 'air'),
      ('Erde', 'die', 'f', null, 'earth, soil'),
      ('Brille', 'die', 'f', 'Brillen', 'glasses, spectacles'),

      // Neuter (das)
      ('Auge', 'das', 'n', 'Augen', 'eye'),
      ('Ohr', 'das', 'n', 'Ohren', 'ear'),
      ('Bein', 'das', 'n', 'Beine', 'leg'),
      ('Haar', 'das', 'n', 'Haare', 'hair'),
      ('Jahr', 'das', 'n', 'Jahre', 'year'),
      ('Leben', 'das', 'n', 'Leben', 'life'),
      ('Bild', 'das', 'n', 'Bilder', 'picture, image'),
      ('Lied', 'das', 'n', 'Lieder', 'song'),
      ('Wort', 'das', 'n', 'Wörter', 'word'),
      ('Problem', 'das', 'n', 'Probleme', 'problem'),
      ('Spiel', 'das', 'n', 'Spiele', 'game'),
      ('Tier', 'das', 'n', 'Tiere', 'animal'),
      ('Feuer', 'das', 'n', 'Feuer', 'fire'),
      ('Licht', 'das', 'n', 'Lichter', 'light'),
      ('Gesicht', 'das', 'n', 'Gesichter', 'face'),
      ('Hotel', 'das', 'n', 'Hotels', 'hotel'),
      ('Kino', 'das', 'n', 'Kinos', 'cinema, movie theater'),
      ('Restaurant', 'das', 'n', 'Restaurants', 'restaurant'),
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
