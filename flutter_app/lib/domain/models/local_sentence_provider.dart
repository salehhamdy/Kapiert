import 'example_sentence.dart';

/// Provides offline contextual example sentences with English, Arabic, and Turkish translations.
class LocalSentenceProvider {
  LocalSentenceProvider._();

  static const Map<String, ExampleSentence> _curated = {
    'buch': ExampleSentence(
      german: 'Das Buch liegt auf dem Tisch.',
      english: 'The book is lying on the table.',
      arabic: 'الكتاب موضوع على الطاولة.',
      turkish: 'Kitap masanın üzerinde duruyor.',
    ),
    'haus': ExampleSentence(
      german: 'Das Haus hat einen schönen grünen Garten.',
      english: 'The house has a beautiful green garden.',
      arabic: 'المنزل يحتوي على حديقة خضراء جميلة.',
      turkish: 'Evin güzel yeşil bir bahçesi var.',
    ),
    'auto': ExampleSentence(
      german: 'Das Auto steht vor der Garage.',
      english: 'The car is parked in front of the garage.',
      arabic: 'السيارة متوقفة أمام المرآب.',
      turkish: 'Araba garajın önünde duruyor.',
    ),
    'hund': ExampleSentence(
      german: 'Der Hund spielt fröhlich im Park.',
      english: 'The dog is playing happily in the park.',
      arabic: 'الكلب يلعب بمرح في الحديقة.',
      turkish: 'Köpek parkta neşeyle oynuyor.',
    ),
    'katze': ExampleSentence(
      german: 'Die Katze schläft friedlich auf dem Sofa.',
      english: 'The cat is sleeping peacefully on the sofa.',
      arabic: 'القطة تنام بسلام على الأريكة.',
      turkish: 'Kedi kanepede huzurla uyuyor.',
    ),
    'tisch': ExampleSentence(
      german: 'Der Tisch ist aus massivem Holz gemacht.',
      english: 'The table is made of solid wood.',
      arabic: 'الطاولة مصنوعة من الخشب الصلب.',
      turkish: 'Masa masif ahşaptan yapılmıştır.',
    ),
    'stuhl': ExampleSentence(
      german: 'Der Stuhl ist sehr bequem zu sitzen.',
      english: 'The chair is very comfortable to sit on.',
      arabic: 'الكرسي مريح جداً للجلوس.',
      turkish: 'Sandalye oturmak için çok rahat.',
    ),
    'apfel': ExampleSentence(
      german: 'Der Apfel schmeckt frisch und süß.',
      english: 'The apple tastes fresh and sweet.',
      arabic: 'التفاحة طعمها طازج وحلو.',
      turkish: 'Elmanın tadı taze ve tatlı.',
    ),
    'wasser': ExampleSentence(
      german: 'Das Wasser ist kühl und erfrischend.',
      english: 'The water is cool and refreshing.',
      arabic: 'الماء بارد ومنعش.',
      turkish: 'Su serin ve ferahlatıcı.',
    ),
    'brot': ExampleSentence(
      german: 'Das Brot kommt frisch aus der Bäckerei.',
      english: 'The bread is fresh from the bakery.',
      arabic: 'الخبز طازج من المخبز.',
      turkish: 'Ekmek fırından taze çıktı.',
    ),
    'mann': ExampleSentence(
      german: 'Der Mann liest morgens die Zeitung.',
      english: 'The man reads the newspaper in the morning.',
      arabic: 'الرجل يقرأ الجريدة في الصباح.',
      turkish: 'Adam sabahları gazete okur.',
    ),
    'frau': ExampleSentence(
      german: 'Die Frau arbeitet an einem wichtigen Projekt.',
      english: 'The woman is working on an important project.',
      arabic: 'المرأة تعمل على مشروع مهم.',
      turkish: 'Kadın önemli bir proje üzerinde çalışıyor.',
    ),
    'kind': ExampleSentence(
      german: 'Das Kind malt ein buntes Bild.',
      english: 'The child paints a colorful picture.',
      arabic: 'الطفل يرسم لوحة ملونة.',
      turkish: 'Çocuk renkli bir resim çiziyor.',
    ),
    'stadt': ExampleSentence(
      german: 'Die Stadt hat viele historische Sehenswürdigkeiten.',
      english: 'The city has many historical sights.',
      arabic: 'المدينة بها العديد من المعالم التاريخية.',
      turkish: 'Şehir birçok tarihi mekana sahiptir.',
    ),
    'schule': ExampleSentence(
      german: 'Die Schule beginnt pünktlich um acht Uhr.',
      english: 'School starts punctually at eight o\'clock.',
      arabic: 'المدرسة تبدأ في تمام الساعة الثامنة.',
      turkish: 'Okul tam saat sekizde başlıyor.',
    ),
    'zeit': ExampleSentence(
      german: 'Die Zeit vergeht wie im Fluge.',
      english: 'Time flies so quickly.',
      arabic: 'الوقت يمر بسرعة البرق.',
      turkish: 'Zaman su gibi akıp geçiyor.',
    ),
    'tag': ExampleSentence(
      german: 'Der Tag war lang und produktiv.',
      english: 'The day was long and productive.',
      arabic: 'كان اليوم طويلاً ومثمراً.',
      turkish: 'Gün uzun ve verimliydi.',
    ),
    'nacht': ExampleSentence(
      german: 'Die Nacht ist ruhig und voller Sterne.',
      english: 'The night is calm and full of stars.',
      arabic: 'الليل هادئ ومليء بالنجوم.',
      turkish: 'Gece sakin ve yıldızlarla dolu.',
    ),
    'freund': ExampleSentence(
      german: 'Der Freund hilft mir in schwierigen Momenten.',
      english: 'The friend helps me in difficult moments.',
      arabic: 'الصديق يساعدني في الأوقات الصعبة.',
      turkish: 'Arkadaş zor anlarımda bana yardım eder.',
    ),
    'sonne': ExampleSentence(
      german: 'Die Sonne scheint hell am blauen Himmel.',
      english: 'The sun shines brightly in the blue sky.',
      arabic: 'الشمس تسطع ببراعة في السماء الزرقاء.',
      turkish: 'Güneş mavi gökyüzünde parlak bir şekilde parlıyor.',
    ),
  };

  /// Returns a curated or dynamically framed sentence for any German noun.
  static ExampleSentence getSentence(String word, String article) {
    final key = word.trim().toLowerCase();
    if (_curated.containsKey(key)) {
      return _curated[key]!;
    }

    final formatted = word.isEmpty
        ? 'Wort'
        : word[0].toUpperCase() + word.substring(1).toLowerCase();

    switch (article.toLowerCase()) {
      case 'der':
        return ExampleSentence(
          german: 'Hier steht der $formatted.',
          english: 'Here stands the ${word.toLowerCase()}.',
          arabic: 'هنا يوجد الـ$formatted.',
          turkish: 'İşte burada ${word.toLowerCase()}.',
        );
      case 'die':
        return ExampleSentence(
          german: 'Hier ist die $formatted.',
          english: 'Here is the ${word.toLowerCase()}.',
          arabic: 'هنا توجد الـ$formatted.',
          turkish: 'İşte burada ${word.toLowerCase()}.',
        );
      case 'das':
      default:
        return ExampleSentence(
          german: 'Hier liegt das $formatted.',
          english: 'Here lies the ${word.toLowerCase()}.',
          arabic: 'هنا يقع الـ$formatted.',
          turkish: 'İşte burada ${word.toLowerCase()} duruyor.',
        );
    }
  }
}
