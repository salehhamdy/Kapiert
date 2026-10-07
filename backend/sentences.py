"""
German example sentence generation and curated sentence bank.
Provides authentic contextual example sentences for German nouns
with translations in English (en), Arabic (ar), and Turkish (tr).
"""

from __future__ import annotations

# Curated bank of authentic example sentences for common German nouns
CURATED_SENTENCES: dict[str, dict[str, str]] = {
    "buch": {
        "de": "Das Buch liegt auf dem Tisch.",
        "en": "The book is lying on the table.",
        "ar": "الكتاب موضوع على الطاولة.",
        "tr": "Kitap masanın üzerinde duruyor.",
    },
    "haus": {
        "de": "Das Haus hat einen schönen grünen Garten.",
        "en": "The house has a beautiful green garden.",
        "ar": "المنزل يحتوي على حديقة خضراء جميلة.",
        "tr": "Evin güzel yeşil bir bahçesi var.",
    },
    "auto": {
        "de": "Das Auto steht vor der Garage.",
        "en": "The car is parked in front of the garage.",
        "ar": "السيارة متوقفة أمام المرآب.",
        "tr": "Araba garajın önünde duruyor.",
    },
    "hund": {
        "de": "Der Hund spielt fröhlich im Park.",
        "en": "The dog is playing happily in the park.",
        "ar": "الكلب يلعب بمرح في الحديقة.",
        "tr": "Köpek parkta neşeyle oynuyor.",
    },
    "katze": {
        "de": "Die Katze schläft friedlich auf dem Sofa.",
        "en": "The cat is sleeping peacefully on the sofa.",
        "ar": "القطة تنام بسلام على الأريكة.",
        "tr": "Kedi kanepede huzurla uyuyor.",
    },
    "tisch": {
        "de": "Der Tisch ist aus massivem Holz gemacht.",
        "en": "The table is made of solid wood.",
        "ar": "الطاولة مصنوعة من الخشب الصلب.",
        "tr": "Masa masif ahşaptan yapılmıştır.",
    },
    "stuhl": {
        "de": "Der Stuhl ist sehr bequem zu sitzen.",
        "en": "The chair is very comfortable to sit on.",
        "ar": "الكرسي مريح جداً للجلوس.",
        "tr": "Sandalye oturmak için çok rahat.",
    },
    "apfel": {
        "de": "Der Apfel schmeckt frisch und süß.",
        "en": "The apple tastes fresh and sweet.",
        "ar": "التفاحة طعمها طازج وحلو.",
        "tr": "Elmanın tadı taze ve tatlı.",
    },
    "wasser": {
        "de": "Das Wasser ist kühl und erfrischend.",
        "en": "The water is cool and refreshing.",
        "ar": "الماء بارد ومنعش.",
        "tr": "Su serin ve ferahlatıcı.",
    },
    "brot": {
        "de": "Das Brot kommt frisch aus der Bäckerei.",
        "en": "The bread is fresh from the bakery.",
        "ar": "الخبز طازج من المخبز.",
        "tr": "Ekmek fırından taze çıktı.",
    },
    "mann": {
        "de": "Der Mann liest morgens die Zeitung.",
        "en": "The man reads the newspaper in the morning.",
        "ar": "الرجل يقرأ الجريدة في الصباح.",
        "tr": "Adam sabahları gazete okur.",
    },
    "frau": {
        "de": "Die Frau arbeitet an einem wichtigen Projekt.",
        "en": "The woman is working on an important project.",
        "ar": "المرأة تعمل على مشروع مهم.",
        "tr": "Kadın önemli bir proje üzerinde çalışıyor.",
    },
    "kind": {
        "de": "Das Kind malt ein buntes Bild.",
        "en": "The child paints a colorful picture.",
        "ar": "الطفل يرسم لوحة ملونة.",
        "tr": "Çocuk renkli bir resim çiziyor.",
    },
    "stadt": {
        "de": "Die Stadt hat viele historische Sehenswürdigkeiten.",
        "en": "The city has many historical sights.",
        "ar": "المدينة بها العديد من المعالم التاريخية.",
        "tr": "Şehir birçok tarihi mekana sahiptir.",
    },
    "schule": {
        "de": "Die Schule beginnt pünktlich um acht Uhr.",
        "en": "School starts punctually at eight o'clock.",
        "ar": "المدرسة تبدأ في تمام الساعة الثامنة.",
        "tr": "Okul tam saat sekizde başlıyor.",
    },
    "zeit": {
        "de": "Die Zeit vergeht wie im Fluge.",
        "en": "Time flies so quickly.",
        "ar": "الوقت يمر بسرعة البرق.",
        "tr": "Zaman su gibi akıp geçiyor.",
    },
    "tag": {
        "de": "Der Tag war lang und produktiv.",
        "en": "The day was long and productive.",
        "ar": "كان اليوم طويلاً ومثمراً.",
        "tr": "Gün uzun ve verimliydi.",
    },
    "nacht": {
        "de": "Die Nacht ist ruhig und voller Sterne.",
        "en": "The night is calm and full of stars.",
        "ar": "الليل هادئ ومليء بالنجوم.",
        "tr": "Gece sakin ve yıldızlarla dolu.",
    },
    "freund": {
        "de": "Der Freund hilft mir in schwierigen Momenten.",
        "en": "The friend helps me in difficult moments.",
        "ar": "الصديق يساعدني في الأوقات الصعبة.",
        "tr": "Arkadaş zor anlarımda bana yardım eder.",
    },
    "arbeit": {
        "de": "Die Arbeit erfordert viel Konzentration.",
        "en": "The work requires a lot of concentration.",
        "ar": "العمل يتطلب الكثير من التركيز.",
        "tr": "İş çok fazla konsantrasyon gerektirir.",
    },
    "fenster": {
        "de": "Das Fenster lässt frische Luft ins Zimmer.",
        "en": "The window lets fresh air into the room.",
        "ar": "النافذة تدخل الهواء النقي إلى الغرفة.",
        "tr": "Pencere odaya temiz hava girmesini sağlar.",
    },
    "tür": {
        "de": "Die Tür öffnet sich automatisch.",
        "en": "The door opens automatically.",
        "ar": "الباب يفتح تلقائياً.",
        "tr": "Kapı otomatik olarak açılır.",
    },
    "sonne": {
        "de": "Die Sonne scheint hell am blauen Himmel.",
        "en": "The sun shines brightly in the blue sky.",
        "ar": "الشمس تسطع ببراعة في السماء الزرقاء.",
        "tr": "Güneş mavi gökyüzünde parlak bir şekilde parlıyor.",
    },
    "mond": {
        "de": "Der Mond erleuchtet die dunkle Nacht.",
        "en": "The moon illuminates the dark night.",
        "ar": "القمر يضيء ظلمة الليل.",
        "tr": "Ay karanlık geceyi aydınlatır.",
    },
    "stern": {
        "de": "Der Stern funkelt weit entfernt am Himmel.",
        "en": "The star twinkles far away in the sky.",
        "ar": "النجم يتلألأ بعيداً في السماء.",
        "tr": "Yıldız gökyüzünde uzakta parıldıyor.",
    },
}

# Dynamic template patterns based on gender/article
TEMPLATES_BY_ARTICLE: dict[str, list[dict[str, str]]] = {
    "der": [
        {
            "de": "Hier steht der {word}.",
            "en": "Here stands the {word}.",
            "ar": "هنا يوجد {word}.",
            "tr": "İşte burada {word}.",
        },
        {
            "de": "Der {word} ist sehr nützlich im Alltag.",
            "en": "The {word} is very useful in everyday life.",
            "ar": "{word} مفيد جداً في الحياة اليومية.",
            "tr": "{word} günlük hayatta çok faydalıdır.",
        },
        {
            "de": "Ich sehe den {word} vor mir.",
            "en": "I see the {word} in front of me.",
            "ar": "أرى {word} أمامي.",
            "tr": "Önümde {word} görüyorum.",
        },
    ],
    "die": [
        {
            "de": "Hier ist die {word}.",
            "en": "Here is the {word}.",
            "ar": "هنا توجد {word}.",
            "tr": "İşte burada {word}.",
        },
        {
            "de": "Die {word} ist sehr wichtig für uns.",
            "en": "The {word} is very important for us.",
            "ar": "{word} مهمة جداً بالنسبة لنا.",
            "tr": "{word} bizim için çok önemlidir.",
        },
        {
            "de": "Wir nutzen die {word} jeden Tag.",
            "en": "We use the {word} every day.",
            "ar": "نحن نستخدم {word} كل يوم.",
            "tr": "Her gün {word} kullanıyoruz.",
        },
    ],
    "das": [
        {
            "de": "Hier liegt das {word}.",
            "en": "Here lies the {word}.",
            "ar": "هنا يقع {word}.",
            "tr": "İşte burada {word} duruyor.",
        },
        {
            "de": "Das {word} gefällt mir besonders gut.",
            "en": "I like the {word} especially well.",
            "ar": "يعجبني {word} بشكل خاص.",
            "tr": "{word} özellikle çok hoşuma gidiyor.",
        },
        {
            "de": "Ich habe das {word} gestern gesehen.",
            "en": "I saw the {word} yesterday.",
            "ar": "لقد رأيت {word} بالأمس.",
            "tr": "Dün {word} gördüm.",
        },
    ],
}


def get_example_sentence(word: str, article: str) -> dict[str, str]:
    """
    Retrieve or dynamically generate a contextual example sentence for the noun.
    Returns a dict with 'de', 'en', 'ar', and 'tr' translations.
    """
    key = word.strip().lower()
    if key in CURATED_SENTENCES:
        return CURATED_SENTENCES[key]

    art = article.strip().lower()
    templates = TEMPLATES_BY_ARTICLE.get(art, TEMPLATES_BY_ARTICLE["das"])
    # Deterministic choice based on word hash so it remains stable
    idx = abs(hash(key)) % len(templates)
    tmpl = templates[idx]

    formatted_word = word.capitalize()
    return {
        "de": tmpl["de"].format(word=formatted_word),
        "en": tmpl["en"].format(word=word.lower()),
        "ar": tmpl["ar"].format(word=f"الـ{formatted_word}"),
        "tr": tmpl["tr"].format(word=word.lower()),
    }
