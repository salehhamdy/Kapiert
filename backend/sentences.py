"""
German example sentence generation and curated sentence bank.
Provides authentic contextual example sentences for German nouns
with translations in English (en), Arabic (ar), and Turkish (tr).
"""

from __future__ import annotations

# Curated bank of authentic example sentences for high-frequency German nouns
CURATED_SENTENCES: dict[str, dict[str, str]] = {
    # --- Foods, Beverages & Kitchen ---
    "apfel": {
        "de": "Der rote Apfel ist saftig, knackig und schmeckt süß.",
        "en": "The red apple is juicy, crisp, and tastes sweet.",
        "ar": "التفاحة الحمراء طازجة ومقرمشة وطعمها حلو ولذيذ.",
        "tr": "Kırmızı elma sulu, çıtır ve tatlıdır.",
    },
    "banane": {
        "de": "Die gelbe Banane ist reif und schmeckt herrlich süß.",
        "en": "The yellow banana is ripe and tastes wonderfully sweet.",
        "ar": "الموزة الصفراء ناضجة وطعمها حلو ورائع.",
        "tr": "Sarı muz olgun ve harika bir şekilde tatlı.",
    },
    "orange": {
        "de": "Die frische Orange liefert viel gesundes Vitamin C.",
        "en": "The fresh orange provides plenty of healthy vitamin C.",
        "ar": "البرتقالة الطازجة تمد الجسم بالكثير من فيتامين C الصحي.",
        "tr": "Taze portakal bol miktarda sağlıklı C vitamini sağlar.",
    },
    "zitrone": {
        "de": "Die gelbe Zitrone verleiht dem Tee einen erfrischenden Geschmack.",
        "en": "The yellow lemon gives the tea a refreshing taste.",
        "ar": "الليمونة الصفراء تمنح الشاي طعماً منعشاً.",
        "tr": "Sarı limon çaya ferahlatıcı bir tat verir.",
    },
    "kartoffel": {
        "de": "Die gekochte Kartoffel ist eine beliebte Beilage in der deutschen Küche.",
        "en": "The boiled potato is a popular side dish in German cuisine.",
        "ar": "البطاطا المسلوقة طبق جانبي محبوب في المطبخ الألماني.",
        "tr": "Haşlanmış patates Alman mutfağında sevilen bir garnitürdür.",
    },
    "tomate": {
        "de": "Die reife Tomate passt hervorragend in einen frischen Sommersalat.",
        "en": "The ripe tomato fits excellently in a fresh summer salad.",
        "ar": "الطماطم الناضجة تتناسب بشكل رائع مع سلطة الصيف الطازجة.",
        "tr": "Olgun domates taze bir yaz salatasına çok yakışır.",
    },
    "salat": {
        "de": "Der bunte Salat wird mit feinem Olivenöl und Essig zubereitet.",
        "en": "The colorful salad is prepared with fine olive oil and vinegar.",
        "ar": "السلطة الملونة تُحضر بزيت الزيتون الممتاز والخل.",
        "tr": "Renkli salata kaliteli zeytinyağı ve sirke ile hazırlanır.",
    },
    "suppe": {
        "de": "Die heiße Gemüsesuppe wärmt wunderbar an kalten Wintertagen.",
        "en": "The hot vegetable soup warms wonderfully on cold winter days.",
        "ar": "حساء الخضار الساخن يبعث على الدفء بشكل رائع في أيام الشتاء الباردة.",
        "tr": "Sıcak sebze çorbası soğuk kış günlerinde harika bir şekilde ısıtır.",
    },
    "brot": {
        "de": "Das knusprige Brot kommt morgens frisch aus der Handwerksbäckerei.",
        "en": "The crusty bread comes fresh from the artisan bakery in the morning.",
        "ar": "الخبز المقرمش يأتي صباحاً طازجاً من المخبز التقليدي.",
        "tr": "Çıtır ekmek sabahları fırından taze çıkar.",
    },
    "brötchen": {
        "de": "Am Sonntag essen wir zum Frühstück warme, goldbraune Brötchen.",
        "en": "On Sundays we eat warm, golden-brown rolls for breakfast.",
        "ar": "في يوم الأحد نتناول لفائف الخبز الدافئة والذهبية على الإفطار.",
        "tr": "Pazar günleri kahvaltıda sıcak, altın sarısı küçük ekmekler yeriz.",
    },
    "butter": {
        "de": "Die weiche Butter lässt sich leicht auf das frische Brot streichen.",
        "en": "The soft butter spreads easily onto the fresh bread.",
        "ar": "الزبدة الطرية تُدهن بسهولة على الخبز الطازج.",
        "tr": "Yumuşak tereyağı taze ekmeğe kolayca sürülür.",
    },
    "käse": {
        "de": "Der würzige Käse schmeckt besonders intensiv zu frischem Baguette.",
        "en": "The savory cheese tastes especially intense with a fresh baguette.",
        "ar": "الجبن المبهر له نكهة قوية وطيبة مع الخبز الفرنسي الطازج.",
        "tr": "Baharatlı peynir taze baget ekmekle özellikle yoğun bir tada sahiptir.",
    },
    "ei": {
        "de": "Das weichgekochte Ei schmeckt mit einer Prise Salz hervorragend.",
        "en": "The soft-boiled egg tastes outstanding with a pinch of salt.",
        "ar": "البيضة المسلوقة طرية ومذاقها رائع مع رشة ملح.",
        "tr": "Rafadan yumurta bir tutam tuzla harika bir tada sahiptir.",
    },
    "fleisch": {
        "de": "Das zarte Fleisch wird schonend in der heißen Pfanne gebraten.",
        "en": "The tender meat is gently fried in the hot pan.",
        "ar": "اللحم الطري يُقلى بلطف في المقلاة الساخنة.",
        "tr": "Yumuşak et sıcak tavada nazikçe kızartılır.",
    },
    "fisch": {
        "de": "Der frische Fisch wird mit Zitrone und feinen Kräutern serviert.",
        "en": "The fresh fish is served with lemon and fine herbs.",
        "ar": "السمك الطازج يُقدم مع الليمون والأعشاب العطرية الفاخرة.",
        "tr": "Taze balık limon ve ince otlarla servis edilir.",
    },
    "kuchen": {
        "de": "Der frisch gebackene Apfelkuchen duftet herrlich nach Zimt.",
        "en": "The freshly baked apple cake smells delightfully of cinnamon.",
        "ar": "كعكة التفاح المخبوزة طازجة تفوح برائحة القرفة الزكية.",
        "tr": "Taze pişmiş elmalı pasta nefis tarçın kokuyor.",
    },
    "schokolade": {
        "de": "Die feine Schweizer Schokolade schmilzt langsam und zart auf der Zunge.",
        "en": "The fine Swiss chocolate melts slowly and delicately on the tongue.",
        "ar": "الشوكولاتة السويسرية الفاخرة تذوب بنعومة وببطء في الفم.",
        "tr": "Seçkin İsviçre çikolatası dilde yavaşça ve zarifçe erir.",
    },
    "zucker": {
        "de": "Ein kleiner Teelöffel Zucker macht den Espresso angenehm mild.",
        "en": "A small teaspoon of sugar makes the espresso pleasantly mild.",
        "ar": "ملعقة صغيرة من السكر تجعل الإسبريسو حلواً ولطيفاً.",
        "tr": "Küçük bir çay kaşığı şeker espressoyu hoş bir şekilde hafifletir.",
    },
    "salz": {
        "de": "Eine Prise Salz bringt den natürlichen Geschmack der Speisen hervor.",
        "en": "A pinch of salt brings out the natural flavor of the food.",
        "ar": "رشة من الملح تبرز النكهة الطبيعية للطعام.",
        "tr": "Bir tutam tuz yemeklerin doğal lezzetini ortaya çıkarır.",
    },
    "wasser": {
        "de": "Ein kühles Glas Wasser löscht den Durst an heißen Tagen am besten.",
        "en": "A cool glass of water quenches thirst best on hot days.",
        "ar": "كوب من الماء البارد يروي العطش بشكل أفضل في الأيام الحارة.",
        "tr": "Soğuk bir bardak su sıcak günlerde susuzluğu en iyi şekilde giderir.",
    },
    "kaffee": {
        "de": "Der heiße Kaffee weckt die Lebensgeister am frühen Morgen.",
        "en": "The hot coffee awakens the spirits early in the morning.",
        "ar": "القهوة الساخنة توقظ الحواس والنشاط في الصباح الباكر.",
        "tr": "Sıcak kahve sabahın erken saatlerinde zindelik verir.",
    },
    "tee": {
        "de": "Der frisch aufgebrühte Kamillentee beruhigt und entspannt den Körper.",
        "en": "The freshly brewed chamomile tea calms and relaxes the body.",
        "ar": "شاي البابونج الطازج يهدئ الجسم ويمنحه الاسترخاء.",
        "tr": "Taze demlenmiş papatya çayı vücudu sakinleştirir ve dinlendirir.",
    },
    "milch": {
        "de": "Die kalte Milch steht im oberen Fach des Kühlschranks.",
        "en": "The cold milk sits in the upper shelf of the refrigerator.",
        "ar": "الحليب البارد موجود في الرف العلوي من الثلاجة.",
        "tr": "Soğuk süt buzdolabının üst rafında duruyor.",
    },
    "saft": {
        "de": "Der frisch gepresste Orangensaft schmeckt herrlich fruchtig.",
        "en": "The freshly squeezed orange juice tastes delightfully fruity.",
        "ar": "عصير البرتقال الطازج طعمه فاكهي ومنعش للغاية.",
        "tr": "Taze sıkılmış portakal suyu harika bir meyve tadına sahiptir.",
    },
    "bier": {
        "de": "Ein kühles Bier gehört für viele zum gemütlichen Feierabend.",
        "en": "A cold beer is part of a cozy evening after work for many.",
        "ar": "المشروب البارد جزء من الأمسيات الهادئة بعد يوم عمل طويل.",
        "tr": "Soğuk içecek iş sonrası dinlenmenin vazgeçilmez bir parçasıdır.",
    },
    "wein": {
        "de": "Der rote Wein passt geschmacklich exzellent zu gutem Käse.",
        "en": "The red wine pairs excellently in flavor with good cheese.",
        "ar": "العصير الأحمر الفاخر يتناغم مذاقه بشكل رائع مع الجبن اللذيذ.",
        "tr": "Kırmızı içecek iyi peynirle lezzet açısından mükemmel uyum sağlar.",
    },

    # --- Home, Furniture & Objects ---
    "haus": {
        "de": "Das Haus hat einen sonnigen Garten und eine moderne Architektur.",
        "en": "The house has a sunny garden and modern architecture.",
        "ar": "المنزل يحتوي على حديقة مشمسة وتصميم معماري عصري.",
        "tr": "Evin güneşli bir bahçesi ve modern bir mimarisi var.",
    },
    "wohnung": {
        "de": "Die helle Wohnung liegt ruhig im obersten Stockwerk des Gebäudes.",
        "en": "The bright apartment is situated quietly on the top floor of the building.",
        "ar": "الشقة المضيئة تقع في هدوء في الطابق العلوي من المبنى.",
        "tr": "Aydınlık daire binanın en üst katında sakin bir konumdadır.",
    },
    "zimmer": {
        "de": "Das gemütliche Zimmer ist liebevoll und zweckmäßig eingerichtet.",
        "en": "The cozy room is lovingly and practically furnished.",
        "ar": "الغرفة المريحة مؤثثة بذوق رفيع وبشكل عملي.",
        "tr": "Rahat oda özenle ve kullanışlı bir şekilde döşenmiştir.",
    },
    "küche": {
        "de": "In der geräumigen Küche bereitet die Familie gemeinsam das Essen zu.",
        "en": "In the spacious kitchen, the family prepares the meal together.",
        "ar": "في المطبخ الواسع تحضر العائلة الطعام معاً.",
        "tr": "Geniş mutfakta aile birlikte yemek hazırlar.",
    },
    "tisch": {
        "de": "Der massive Tisch aus Eichenholz bietet Platz für viele Gäste.",
        "en": "The solid oak table offers plenty of seating for guests.",
        "ar": "الطاولة المصنوعة من خشب البلوط الصلب تتسع لضيوف عديدين.",
        "tr": "Masif meşe masa birçok misafir için yer sunar.",
    },
    "stuhl": {
        "de": "Der gepolsterte Stuhl ermöglicht stundenlanges bequemes Sitzen.",
        "en": "The upholstered chair enables hours of comfortable sitting.",
        "ar": "الكرسي المنجد يتيح الجلوس براحة لساعات طويلة.",
        "tr": "Döşemeli sandalye saatlerce rahatça oturmayı sağlar.",
    },
    "bett": {
        "de": "Das bequeme Bett sorgt jede Nacht für einen tiefen, erholsamen Schlaf.",
        "en": "The comfortable bed ensures deep, restful sleep every night.",
        "ar": "السرير المريح يوفر نوماً عميقاً ومريحاً كل ليلة.",
        "tr": "Rahat yatak her gece derin ve dinlendirici bir uyku sağlar.",
    },
    "sofa": {
        "de": "Auf dem breiten Sofa kann man sich nach der Arbeit herrlich entspannen.",
        "en": "On the wide sofa you can relax wonderfully after work.",
        "ar": "على الأريكة العريضة يمكن للمرء الاسترخاء بروعة بعد العمل.",
        "tr": "Geniş kanepede işten sonra harika bir şekilde dinlenebilirsiniz.",
    },
    "schrank": {
        "de": "Der weiße Schrank bietet überraschend viel Stauraum für Kleidung.",
        "en": "The white closet offers surprisingly much storage space for clothes.",
        "ar": "الخزانة البيضاء توفر مساحة تخزين واسعة للملابس بشكل مفاجئ.",
        "tr": "Beyaz dolap kıyafetler için şaşırtıcı derecede geniş saklama alanı sunar.",
    },
    "lampe": {
        "de": "Die elegante Lampe spendet ein angenehm warmes Licht im Raum.",
        "en": "The elegant lamp gives off a pleasantly warm light in the room.",
        "ar": "المصباح الأنيق يشع ضوءاً دافئاً ومريحاً في الغرفة.",
        "tr": "Zarif lamba odada hoş ve sıcak bir ışık verir.",
    },
    "spiegel": {
        "de": "Der große Spiegel im Flur reflektiert das Tageslicht.",
        "en": "The large mirror in the hallway reflects the natural daylight.",
        "ar": "المرآة الكبيرة في الردهة تعكس ضوء النهار الطبيعي.",
        "tr": "Koridordaki büyük ayna gün ışığını yansıtır.",
    },
    "teppich": {
        "de": "Der weiche Teppich fühlt sich barfuß wunderbar warm an.",
        "en": "The soft carpet feels wonderfully warm under bare feet.",
        "ar": "السجادة الناعمة تعطي شعوراً دافئاً رائعاً عند المشي حافي القدمين.",
        "tr": "Yumuşak halı çıplak ayakla harika bir sıcaklık hissi verir.",
    },
    "tür": {
        "de": "Die massive Tür schließt leise und schützt vor Geräuschen aus dem Treppenhaus.",
        "en": "The solid door closes quietly and shields against stairway noise.",
        "ar": "الباب المتين يغلق بهدوء ويحمي من ضوضاء الدرج.",
        "tr": "Sağlam kapı sessizce kapanır ve merdiven boşluğundaki gürültüden korur.",
    },
    "fenster": {
        "de": "Durch das große Fenster blickt man direkt in den grünen Garten.",
        "en": "Through the large window you look directly into the green garden.",
        "ar": "من خلال النافذة الكبيرة يطل المرء مباشرة على الحديقة الخضراء.",
        "tr": "Büyük pencereden doğrudan yeşil bahçeye bakılır.",
    },
    "schlüssel": {
        "de": "Der silberne Schlüssel öffnet die Eingangstür mit einer leichten Drehung.",
        "en": "The silver key opens the front door with a slight turn.",
        "ar": "المفتاح الفضي يفتح باب المدخل بلفّة خفيفة.",
        "tr": "Gümüş anahtar hafif bir çevirmeyle ön kapıyı açar.",
    },
    "uhr": {
        "de": "Die antike Uhr schlägt zu jeder vollen Stunde mit einem klaren Klang.",
        "en": "The antique clock strikes on the hour with a clear tone.",
        "ar": "الساعة الأثرية تدق عند رأس كل ساعة بنغمة صافية.",
        "tr": "Antika saat her saat başında net bir sesle çalar.",
    },
    "handy": {
        "de": "Das neue Handy hat eine bemerkenswert scharfe Kamera und lange Akkulaufzeit.",
        "en": "The new mobile phone has a remarkably sharp camera and long battery life.",
        "ar": "الهاتف الذكي الجديد مزود بكاميرا فائقة الوضوح وبطارية تدوم طويلاً.",
        "tr": "Yeni cep telefonu son derece net bir kameraya ve uzun pil ömrüne sahiptir.",
    },
    "computer": {
        "de": "Der schnelle Computer startet alle anspruchsvollen Programme im Handumdrehen.",
        "en": "The fast computer launches all demanding programs in the blink of an eye.",
        "ar": "الكمبيوتر السريع يفتح البرامج المتقدمة في طرفة عين.",
        "tr": "Hızlı bilgisayar tüm zorlu programları göz açıp kapayıncaya kadar başlatır.",
    },
    "buch": {
        "de": "Das spannende Buch fesselt den Leser von der ersten bis zur letzten Seite.",
        "en": "The exciting book captivates the reader from the first to the last page.",
        "ar": "الكتاب المشوق يأسر القارئ من الصفحة الأولى وحتى الأخيرة.",
        "tr": "Heyecan verici kitap okuyucuyu ilk sayfadan son sayfaya kadar büyülüyor.",
    },
    "kugelschreiber": {
        "de": "Der Kugelschreiber schreibt flüssig und liegt besonders gut in der Hand.",
        "en": "The ballpoint pen writes smoothly and sits particularly well in the hand.",
        "ar": "قلم الحبر الجاف يكتب بسلاسة ومريح جداً عند الإمساك به.",
        "tr": "Tükenmez kalem akıcı bir şekilde yazar ve ele çok iyi oturur.",
    },
    "bleistift": {
        "de": "Mit dem gespitzten Bleistift zeichnet die Schülerin saubere geometrische Linien.",
        "en": "With the sharpened pencil, the student draws clean geometric lines.",
        "ar": "بالقلم الرصاص المبري ترسم الطالبة خطوطاً هندسية دقيقة.",
        "tr": "Açılmış kurşun kalemle öğrenci temiz geometrik çizgiler çizer.",
    },
    "tasche": {
        "de": "Die elegante Ledertasche bietet reichlich Platz für alle Alltagsgegenstände.",
        "en": "The elegant leather bag offers plenty of space for all everyday items.",
        "ar": "الحقيبة الجلدية الأنيقة توفر متسعاً كبيراً لكافة الأغراض اليومية.",
        "tr": "Zarif deri çanta tüm günlük eşyalar için bolca alan sunar.",
    },
    "koffer": {
        "de": "Der stabile Koffer ist bereits fertig gepackt für die Urlaubsreise.",
        "en": "The sturdy suitcase is already fully packed for the vacation trip.",
        "ar": "الحقيبة المتينة مجهزة وجاهزة تماماً لرحلة العطلة.",
        "tr": "Sağlam bavul tatil seyahati için çoktan hazırlandı.",
    },
    "rucksack": {
        "de": "Der gepolsterte Rucksack eignet sich perfekt für anspruchsvolle Bergtouren.",
        "en": "The padded backpack is perfect for challenging mountain hikes.",
        "ar": "حقيبة الظهر المبطنة مثالية لجولات تسلق الجبال الشاقة.",
        "tr": "Dolgulu sırt çantası zorlu dağ yürüyüşleri için mükemmeldir.",
    },
    "flasche": {
        "de": "Die wiederverwendbare Flasche hält das Wasser über viele Stunden eiskalt.",
        "en": "The reusable bottle keeps the water ice-cold for many hours.",
        "ar": "القارورة القابلة لإعادة الاستخدام تحافظ على برودة الماء لعدة ساعات.",
        "tr": "Yeniden kullanılabilir şişe suyu saatlerce buz gibi tutar.",
    },
    "glas": {
        "de": "Das durchsichtige Glas wird mit kühlem Mineralwasser gefüllt.",
        "en": "The transparent glass is filled with cool sparkling water.",
        "ar": "الكأس الشفاف يُملأ بالماء المعدني البارد.",
        "tr": "Şeffaf bardak soğuk maden suyu ile doldurulur.",
    },
    "tasse": {
        "de": "Aus der Keramiktasse steigt der angenehme Duft von frisch gebrühtem Kaffee.",
        "en": "The pleasant aroma of freshly brewed coffee rises from the ceramic cup.",
        "ar": "يتصاعد من الكوب الخزفي عبق القهوة المعدة طازجاً.",
        "tr": "Seramik fincandan taze demlenmiş kahvenin hoş kokusu yükseliyor.",
    },
    "teller": {
        "de": "Auf dem weißen Teller liegt eine köstlich zubereitete Pasta.",
        "en": "On the white plate lies a deliciously prepared pasta dish.",
        "ar": "على الصحن الأبيض توجد معكرونة محضرة بطريقة شهية.",
        "tr": "Beyaz tabakta lezzetli bir şekilde hazırlanmış makarna duruyor.",
    },
    "messer": {
        "de": "Das geschliffene Messer schneidet mühelos durch das ofenfrische Brot.",
        "en": "The sharpened knife cuts effortlessly through the oven-fresh bread.",
        "ar": "السكين الحاد يقطع بسهولة الخبز الطازج الخارج من الفرن.",
        "tr": "Bilenmiş bıçak fırından yeni çıkmış ekmeği zahmetsizce keser.",
    },
    "gabel": {
        "de": "Die silberne Gabel liegt exakt links neben dem flachen Teller.",
        "en": "The silver fork lies precisely to the left of the shallow plate.",
        "ar": "الشوكة الفضية موضوعة بدقة على يسار الصحن المنبسط.",
        "tr": "Gümüş çatal düz tabağın tam solunda duruyor.",
    },
    "löffel": {
        "de": "Mit dem großen Löffel schöpft der Koch die aromatische Brühe in die Schale.",
        "en": "With the large spoon, the cook ladles the aromatic broth into the bowl.",
        "ar": "بملعقة كبيرة يسكب الطاهي المرق الزكي في الوعاء.",
        "tr": "Aşçı büyük kaşıkla aromatik çorbayı kaseye koyar.",
    },
    "zeitung": {
        "de": "Die seriöse Zeitung liefert fundierte Analysen zu den aktuellen Geschehnissen.",
        "en": "The reputable newspaper provides in-depth analyses of current events.",
        "ar": "الجريدة الموثوقة تقدم تحليلات معمقة للأحداث الجارية.",
        "tr": "Güvenilir gazete güncel olaylara ilişkin derinlemesine analizler sunar.",
    },
    "brief": {
        "de": "Der persönliche Brief erreichte den Empfänger nach zwei Tagen per Post.",
        "en": "The personal letter reached the recipient after two days by post.",
        "ar": "الرسالة الشخصية وصلت إلى المستلم بعد يومين بالبريد.",
        "tr": "Kişisel mektup iki gün sonra posta yoluyla alıcıya ulaştı.",
    },

    # --- People, Family & Roles ---
    "mann": {
        "de": "Der freundliche Mann half der Familie hilfsbereit beim Tragen des Koffers.",
        "en": "The friendly man helpfully helped the family carry the suitcase.",
        "ar": "ساعد الرجل اللطيف العائلة بتعاون في حمل الحقيبة.",
        "tr": "Güler yüzlü adam bavulun taşınmasında aileye yardımseverce yardımcı oldu.",
    },
    "frau": {
        "de": "Die erfahrene Frau leitet das Unternehmen mit Weitblick und Empathie.",
        "en": "The experienced woman leads the enterprise with foresight and empathy.",
        "ar": "تقود المرأة ذات الخبرة الشركة بنظرة مستقبلية وتعاطف كبير.",
        "tr": "Deneyimli kadın şirketi ileri görüşlülük ve empatiyle yönetiyor.",
    },
    "kind": {
        "de": "Das neugierige Kind entdeckt jeden Tag spielerisch die bunte Welt.",
        "en": "The curious child playfully discovers the colorful world every day.",
        "ar": "الطفل الفضولي يكتشف العالم الملون كل يوم من خلال اللعب.",
        "tr": "Meraklı çocuk her gün renkli dünyayı oyun oynayarak keşfeder.",
    },
    "junge": {
        "de": "Der sportliche Junge schießt den Fußball gekonnt direkt ins obere Toreck.",
        "en": "The athletic boy skillfully kicks the soccer ball into the top corner.",
        "ar": "الفتى الرياضي يسدد كرة القدم بمهارة في الزاوية العليا للمرمى.",
        "tr": "Sportif çocuk futbol topunu ustalıkla kalenin üst köşesine vurur.",
    },
    "mädchen": {
        "de": "Das begabte Mädchen spielt mit großer Begeisterung auf dem Klavier.",
        "en": "The gifted girl plays the piano with great enthusiasm.",
        "ar": "الفتاة الموهوبة تعزف على البيانو بحماس وشغف كبيرين.",
        "tr": "Yetenekli kız piyano çalmayı büyük bir şevkle sürdürüyor.",
    },
    "baby": {
        "de": "Das kleine Baby schläft tief und friedlich in seiner kuscheligen Wiege.",
        "en": "The little baby sleeps deeply and peacefully in its cozy cradle.",
        "ar": "الطفل الرضيع ينام نوماً عميقاً وهادئاً في مهده الدافئ.",
        "tr": "Küçük bebek sıcacık beşiğinde derin ve huzurlu bir uyku çekiyor.",
    },
    "vater": {
        "de": "Der fürsorgliche Vater liest seinen Kindern jeden Abend eine Geschichte vor.",
        "en": "The caring father reads a bedtime story to his children every evening.",
        "ar": "الأب الحنون يقرأ لأطفاله قصة كل مساء قبل النوم.",
        "tr": "Şefkatli baba her akşam çocuklarına masal okur.",
    },
    "mutter": {
        "de": "Die liebevolle Mutter unterstützt ihre Familie in allen Lebenslagen.",
        "en": "The loving mother supports her family in all situations of life.",
        "ar": "الأم المحبة تدعم عائلتها في شتى ظروف الحياة.",
        "tr": "Sevgi dolu anne ailesini hayatın her anında destekler.",
    },
    "eltern": {
        "de": "Verständnisvolle Eltern schenken ihren heranwachsenden Kindern Vertrauen.",
        "en": "Understanding parents grant trust to their growing children.",
        "ar": "الوالدان المتفهمان يمنحان الثقة لأبنائهما أثناء نموهم.",
        "tr": "Anlayışlı ebeveynler büyüyen çocuklarına güven aşılar.",
    },
    "sohn": {
        "de": "Der stolze Sohn schloss seine universitäre Ausbildung mit Bestnote ab.",
        "en": "The proud son completed his university degree with top grades.",
        "ar": "الابن الفخور أتم دراسته الجامعية بأعلى الدرجات التقديرية.",
        "tr": "Gururlu oğul üniversite eğitimini en yüksek dereceyle tamamladı.",
    },
    "tochter": {
        "de": "Die engagierte Tochter engagiert sich aktiv für den Schutz der Umwelt.",
        "en": "The dedicated daughter is actively involved in environmental protection.",
        "ar": "الابنة المخلصة تنشط بفاعلية في حماية البيئة.",
        "tr": "Özverili kız çocuğu çevre koruma konusunda aktif olarak yer alıyor.",
    },
    "bruder": {
        "de": "Mein jüngerer Bruder teilt seine Spielsachen bereitwillig mit Freunden.",
        "en": "My younger brother willingly shares his toys with friends.",
        "ar": "أخي الأصغر يشارك ألعابه بكل سرور مع أصدقائه.",
        "tr": "Küçük kardeşim oyuncaklarını arkadaşlarıyla seve seve paylaşır.",
    },
    "schwester": {
        "de": "Meine ältere Schwester gibt mir wertvolle Ratschläge für meine Prüfungen.",
        "en": "My older sister gives me valuable advice for my exams.",
        "ar": "أختي الكبرى تقدم لي نصائح ثمينة من أجل امتحاناتي.",
        "tr": "Ablam sınavlarım için bana çok değerli tavsiyeler verir.",
    },
    "freund": {
        "de": "Ein verlässlicher Freund ist auch in stürmischen Zeiten immer für dich da.",
        "en": "A reliable friend is always there for you even in stormy times.",
        "ar": "الصديق الموثوق يكون دائماً بجانبك حتى في أحلك الأوقات.",
        "tr": "Güvenilir bir dost fırtınalı zamanlarda bile her zaman yanındadır.",
    },
    "freundin": {
        "de": "Meine beste Freundin versteht mich oft ganz ohne viele Worte.",
        "en": "My best friend often understands me without needing many words.",
        "ar": "صديقتي المقربة تفهمني في كثير من الأحيان دون الحاجة إلى الكثير من الكلمات.",
        "tr": "En iyi kız arkadaşım beni çoğu zaman kelimelere gerek kalmadan anlar.",
    },
    "arzt": {
        "de": "Der erfahrene Arzt nimmt sich viel Zeit für eine gründliche Untersuchung.",
        "en": "The experienced doctor takes plenty of time for a thorough check-up.",
        "ar": "الطبيب المتمرس يخصص وقتاً كافياً لإجراء فحص طبي دقيق وشامل.",
        "tr": "Deneyimli doktor kapsamlı bir muayene için bolca zaman ayırır.",
    },
    "lehrer": {
        "de": "Der motivierte Lehrer erklärt grammatische Zusammenhänge sehr anschaulich.",
        "en": "The motivated teacher explains grammatical concepts very clearly.",
        "ar": "المعلم المتميز يشرح القواعد النحوية بطريقة مبسطة وشديدة الوضوح.",
        "tr": "Motivasyonu yüksek öğretmen dilbilgisi kurallarını son derece anlaşılır anlatır.",
    },
    "schüler": {
        "de": "Der fleißige Schüler bereitet sich konzentriert auf das Abitur vor.",
        "en": "The diligent student prepares with focus for the graduation exam.",
        "ar": "التلميذ المجتهد يستعد بتركيز لامتحانات الثانوية العامة.",
        "tr": "Çalışkan öğrenci mezuniyet sınavına odaklanarak hazırlanıyor.",
    },
    "student": {
        "de": "Der Student verbringt die Nachmittage konzentriert in der Universitätsbibliothek.",
        "en": "The university student spends afternoons focused in the campus library.",
        "ar": "الطالب الجامعي يقضي فترات بعد الظهر بتركيز في مكتبة الجامعة.",
        "tr": "Üniversite öğrencisi öğleden sonraları kütüphanede odaklanarak geçirir.",
    },
    "kollege": {
        "de": "Mein freundlicher Kollege unterstützt mich tatkräftig bei der Projektarbeit.",
        "en": "My friendly colleague actively supports me with project work.",
        "ar": "زميلي اللطيف يدعمني بفاعلية في مهام المشروع المشترك.",
        "tr": "Güler yüzlü iş arkadaşım proje çalışmasında bana aktif destek veriyor.",
    },
    "chef": {
        "de": "Der verlässliche Chef fördert die Talente seiner Mitarbeiter gezielt.",
        "en": "The reliable boss purposefully nurtures the talents of his staff.",
        "ar": "المدير الجيد يرعى مواهب موظفيه بشكل مستمر ومدروس.",
        "tr": "Güvenilir yönetici çalışanlarının yeteneklerini bilinçli şekilde destekler.",
    },

    # --- City, Places, Transport & Travel ---
    "stadt": {
        "de": "Die alte Stadt besticht durch ihren mittelalterlichen Charme und bunte Gassen.",
        "en": "The old town charms with its medieval flair and colorful alleys.",
        "ar": "المدينة القديمة تسحر بأجوائها التراثية وأزقتها الملونة الجميلة.",
        "tr": "Eski şehir orta çağ cazibesi ve renkli sokaklarıyla büyülüyor.",
    },
    "dorf": {
        "de": "Das friedliche Dorf liegt idyllisch inmitten grüner Wiesen und Wälder.",
        "en": "The peaceful village is idyllically nestled amidst green meadows and woods.",
        "ar": "القرية الهادئة تقع في موقع شاعري وسط المروج والمراعي الخضراء.",
        "tr": "Huzurlu köy yeşil çayırlar ve ormanlar arasında pastoral bir konumdadır.",
    },
    "straße": {
        "de": "Die gepflasterte Straße schlängelt sich hinauf zur alten Burgruine.",
        "en": "The cobblestone street winds up to the ancient castle ruin.",
        "ar": "الشارع المرصوف بالحصى يتعرج صعوداً نحو أطلال القلعة القديمة.",
        "tr": "Arnavut kaldırımlı cadde eski kale kalıntısına doğru kıvrılıyor.",
    },
    "brücke": {
        "de": "Die historische Brücke verbindet die beiden Flussufer seit Jahrhunderten.",
        "en": "The historic bridge has connected both river banks for centuries.",
        "ar": "الجسر التاريخي يربط بين ضفتي النهر منذ قرون طويلة.",
        "tr": "Tarihi köprü yüzyıllardır nehrin iki yakasını birbirine bağlıyor.",
    },
    "park": {
        "de": "Im schattigen Park blühen im Frühjahr unzählige bunte Tulpen.",
        "en": "In the shady park, countless colorful tulips bloom in spring.",
        "ar": "في الحديقة الظليلة تتفتح في الربيع زهور التوليب الملونة بلا حصر.",
        "tr": "Gölgeli parkta ilkbaharda sayısız renkli lale açar.",
    },
    "schule": {
        "de": "Die moderne Schule fördert kreatives Denken und digitale Medienkompetenz.",
        "en": "The modern school promotes creative thinking and digital media literacy.",
        "ar": "المدرسة الحديثة تشجع التفكير الإبداعي والمهارات الرقمية المتقدمة.",
        "tr": "Modern okul yaratıcı düşünmeyi ve dijital medya yetkinliğini destekler.",
    },
    "universität": {
        "de": "Die berühmte Universität betreibt Spitzenforschung auf internationalem Niveau.",
        "en": "The famous university conducts top research at an international level.",
        "ar": "الجامعة الشهيرة تجري أبحاثاً رائدة على أعلى المستويات الدولية.",
        "tr": "Ünlü üniversite uluslararası düzeyde üst düzey araştırmalar yürütmektedir.",
    },
    "bibliothek": {
        "de": "Die ruhige Bibliothek bietet eine riesige Auswahl an Büchern und Fachzeitschriften.",
        "en": "The quiet library provides a vast selection of books and journals.",
        "ar": "المكتبة الهادئة توفر تشكيلة هائلة من الكتب والمجلات العلمية.",
        "tr": "Sessiz kütüphane zengin bir kitap ve uzman dergi seçkisi sunar.",
    },
    "krankenhaus": {
        "de": "Das moderne Krankenhaus gewährleistet eine erstklassige medizinische Betreuung.",
        "en": "The modern hospital guarantees first-class medical care.",
        "ar": "المستشفى الحديث يضمن تقديم رعاية طبية متطورة ومن الدرجة الأولى.",
        "tr": "Modern hastane birinci sınıf tıbbi bakımı garanti eder.",
    },
    "apotheke": {
        "de": "In der Notdienst-Apotheke bekommt man auch nachts dringend benötigte Arznei.",
        "en": "At the emergency pharmacy you get urgently needed medicine even at night.",
        "ar": "في صيدلية الطوارئ يحصل المرء على الأدوية العاجلة حتى في ساعات الليل.",
        "tr": "Nöbetçi eczaneden gece vakti de acil ilaçlar temin edilebilir.",
    },
    "hotel": {
        "de": "Das komfortable Hotel empfängt Reisende mit einem ausgezeichneten Service.",
        "en": "The comfortable hotel welcomes travelers with excellent service.",
        "ar": "الفندق المريح يستقبل المسافرين بخدمة استثنائية وضيافة راقية.",
        "tr": "Konforlu otel seyahat edenleri mükemmel bir hizmetle ağırlar.",
    },
    "restaurant": {
        "de": "Das traditionelle Restaurant serviert regionale Köstlichkeiten in stilvollem Ambiente.",
        "en": "The traditional restaurant serves regional delicacies in a stylish atmosphere.",
        "ar": "المطعم التقليدي يقدم أشهى الأطباق المحلية في أجواء راقية وأنيقة.",
        "tr": "Geleneksel restoran şık bir ortamda yöresel lezzetler sunuyor.",
    },
    "café": {
        "de": "Im sonnigen Café genießt man hausgemachten Kuchen bei sanfter Klaviermusik.",
        "en": "In the sunny café you enjoy homemade cake accompanied by soft piano music.",
        "ar": "في المقهى المشمس يستمتع الزوار بالكعك المصنوع منزلياً مع موسيقى البيانو الهادئة.",
        "tr": "Güneşli kafede hafif piyano müziği eşliğinde ev yapımı pastanın tadı çıkarılır.",
    },
    "bäckerei": {
        "de": "Der Duft von warmem Gebäck strömt schon frühmorgens aus der Bäckerei.",
        "en": "The smell of warm pastry streams from the bakery early in the morning.",
        "ar": "رائحة المخبوزات الدافئة تفوح في الصباح الباكر من المخبز.",
        "tr": "Sıcak hamur işlerinin kokusu sabahın erken saatlerinde fırından yayılır.",
    },
    "supermarkt": {
        "de": "Der gut sortierte Supermarkt bietet täglich frisches Obst und Gemüse an.",
        "en": "The well-stocked supermarket offers fresh fruits and vegetables daily.",
        "ar": "السوبرماركت المنظم يقدم يومياً خضروات وفواكه طازجة.",
        "tr": "Düzenli süpermarket günlük olarak taze meyve ve sebze sunar.",
    },
    "bank": {
        "de": "Die lokale Bank berät ihre Kunden kompetent in allen Finanzierungsfragen.",
        "en": "The local bank advises its clients competently on all financing matters.",
        "ar": "البنك المحلي يقدم استشارات متخصصة لعملائه في كافة الأمور التمويلية.",
        "tr": "Yerel banka tüm finansman konularında müşterilerine yetkin danışmanlık sağlar.",
    },
    "bahnhof": {
        "de": "Am zentralen Bahnhof kommen im Minutentakt Züge aus ganz Europa an.",
        "en": "At the central train station, trains from across Europe arrive every minute.",
        "ar": "في محطة القطارات المركزية تصل القطارات من كل أنحاء أوروبا على مدار الدقائق.",
        "tr": "Merkez tren istasyonuna Avrupa'nın her yerinden dakikalar içinde trenler gelir.",
    },
    "flughafen": {
        "de": "Am internationalen Flughafen starten Langstreckenflüge in alle Kontinente.",
        "en": "At the international airport, long-haul flights depart to all continents.",
        "ar": "في المطار الدولي تقلع رحلات الطيران الطويلة إلى كافة قارات العالم.",
        "tr": "Uluslararası havalimanında tüm kıtalara uzun mesafeli uçuşlar kalkar.",
    },
    "auto": {
        "de": "Das sparsame Auto gleitet geräuscharm über die neu asphaltierte Autobahn.",
        "en": "The economical car glides quietly over the newly paved highway.",
        "ar": "السيارة الاقتصادية تسير بهدوء وسلاسة على الطريق السريع الجديد.",
        "tr": "Tasarruflu araba yeni asfaltlanmış otoyolda sessizce ilerliyor.",
    },
    "bus": {
        "de": "Der pünktliche Bus bringt die Pendler sicher durch den dichten Stadtverkehr.",
        "en": "The punctual bus brings commuters safely through dense city traffic.",
        "ar": "الحافلة المنتظمة تنقل الركاب بأمان عبر حركة المرور الحضرية المزدحمة.",
        "tr": "Dakik otobüs yolcuları yoğun şehir trafiğinde güvenle ulaştırır.",
    },
    "zug": {
        "de": "Der moderne ICE-Zug erreicht Reisegeschwindigkeiten von über 250 Stundenkilometern.",
        "en": "The modern high-speed train reaches travel speeds of over 250 km/h.",
        "ar": "القطار فائق السرعة الحديث يسير بسرعات تتجاوز 250 كيلومتراً في الساعة.",
        "tr": "Modern hızlı tren saatte 250 kilometrenin üzerinde seyahat hızına ulaşır.",
    },
    "fahrrad": {
        "de": "Das wendige Fahrrad ist das schnellste Verkehrsmittel in der Innenstadt.",
        "en": "The agile bicycle is the fastest means of transport in the city center.",
        "ar": "الدراجة الهوائية الرشيقة هي أسرع وسيلة للتنقل في وسط المدينة.",
        "tr": "Çevik bisiklet şehir merkezindeki en hızlı ulaşım aracıdır.",
    },
    "flugzeug": {
        "de": "Das große Flugzeug hebt kraftvoll in den wolkenlosen Morgenhimmel ab.",
        "en": "The large airliner takes off powerfully into the cloudless morning sky.",
        "ar": "الطائرة الضخمة تقلع بقوة نحو سماء الصباح الخالية من الغيوم.",
        "tr": "Büyük uçak bulutsuz sabah gökyüzüne güçlü bir şekilde havalanır.",
    },
    "schiff": {
        "de": "Das majestätische Schiff fährt gemächlich in den geschützten Hafen ein.",
        "en": "The majestic ship sails leisurely into the protected harbor.",
        "ar": "السفينة المهيبة تبحر بهدوء واعتدال نحو الميناء المحمي.",
        "tr": "Görkemli gemi korunaklı limana sakince yanaşıyor.",
    },

    # --- Nature, Animals & Weather ---
    "hund": {
        "de": "Der verspielte Hund wedelt freudig mit dem Schwanz, wenn Besuch kommt.",
        "en": "The playful dog wags its tail joyfully when visitors arrive.",
        "ar": "الكلب المرح يهز ذيله بفرح عندما يأتي الضيوف.",
        "tr": "Oyuncu köpek misafir geldiğinde kuyruğunu neşeyle sallar.",
    },
    "katze": {
        "de": "Die zierliche Katze fängt geschickt eine Schnur mit ihren Pfoten.",
        "en": "The dainty cat skillfully catches a string with its paws.",
        "ar": "القطة الرشيقة تلتقط الخيط بمهارة بمخالبها.",
        "tr": "Zarif kedi patileriyle bir ipi ustalıkla yakalar.",
    },
    "vogel": {
        "de": "Der bunte Vogel zwitschert früh morgens eine wunderschöne Melodie.",
        "en": "The colorful bird chirps a wonderful melody early in the morning.",
        "ar": "الطائر الملون يغرد بلحن جميل في الصباح الباكر.",
        "tr": "Renkli kuş sabahın erken saatlerinde harika bir melodi şakıyor.",
    },
    "pferd": {
        "de": "Das anmutige Pferd trabt elegant über die sonnenüberflutete Weide.",
        "en": "The graceful horse trots elegantly across the sun-drenched pasture.",
        "ar": "الحصان الرشيق يخب بأناقة عبر المرعى المغمور بأشعة الشمس.",
        "tr": "Zarif at güneşle aydınlanan otlakta zarafetle tırıs gidiyor.",
    },
    "kuh": {
        "de": "Die gescheckte Kuh gibt nahrhafte Milch und grast friedlich auf der Weide.",
        "en": "The spotted cow gives nutritious milk and grazes peacefully in the field.",
        "ar": "البقرة المرقطة تدر حليباً مغذياً وترعى بسلام في المرعى الأخضر.",
        "tr": "Alacalı inek besleyici süt verir ve çayırda huzurla otlar.",
    },
    "maus": {
        "de": "Die kleine graue Maus huscht flink hinter die schützende Fußleiste.",
        "en": "The small gray mouse scurries swiftly behind the protective baseboard.",
        "ar": "الفأر الرمادي الصغير ينسل بخفة وسرعة خلف لوح الحائط.",
        "tr": "Küçük gri fare koruyucu süpürgeliğin arkasına çevikçe kaybolur.",
    },
    "fisch": {
        "de": "Der schillernde Fisch gleitet lautlos durch das klare Wasser des Aquariums.",
        "en": "The shimmering fish glides silently through the clear water of the aquarium.",
        "ar": "السمكة البراقة تنزلق بصمت عبر الماء الصافي في الحوض.",
        "tr": "Işıltılı balık akvaryumun berrak suyunda sessizce süzülür.",
    },
    "baum": {
        "de": "Die alte Eiche breitet ihre mächtigen Äste schützend über der Parkbank aus.",
        "en": "The ancient oak spreads its mighty branches protectively over the bench.",
        "ar": "شجرة البلوط العتيقة تبسط أغصانها القوية لتحمي مقعد الحديقة.",
        "tr": "Yaşlı meşe ağacı güçlü dallarını park bankının üzerine koruyucu şekilde yayar.",
    },
    "blume": {
        "de": "Die duftende Blume öffnet bei den ersten Sonnenstrahlen ihre Blütenpracht.",
        "en": "The fragrant flower opens its splendid blossoms with the first sunbeams.",
        "ar": "الزهرة العطرة تفتح بتلاتها البهية مع بزوغ أولى خيوط الشمس.",
        "tr": "Mis kokulu çiçek ilk güneş ışınlarıyla birlikte çiçeklerini açar.",
    },
    "wald": {
        "de": "Im tiefen Nadelwald herrscht eine wohltuende, kühle Stille.",
        "en": "In the deep coniferous forest reigns a soothing, cool quiet.",
        "ar": "في أعماق الغابة الصنوبرية يسود هدوء بارد ومريح للنفس.",
        "tr": "Derin iğne yapraklı ormanda dinlendirici, serin bir sessizlik hüküm sürer.",
    },
    "sonne": {
        "de": "Die strahlende Sonne erwärmt die Natur nach den kalten Wintermonaten.",
        "en": "The radiant sun warms nature after the cold winter months.",
        "ar": "الشمس الساطعة تدفئ الطبيعة وتنعشها بعد أشهر الشتاء الباردة.",
        "tr": "Parlak güneş soğuk kış aylarının ardından doğayı ısıtır.",
    },
    "mond": {
        "de": "Der volle Mond beleuchtet die glänzende Oberfläche des ruhigen Sees.",
        "en": "The full moon illuminates the glossy surface of the calm lake.",
        "ar": "البدر المكتمل ينير سطح البحيرة الهادئة اللامع.",
        "tr": "Dolunay sakin gölün parlak yüzeyini aydınlatır.",
    },
    "stern": {
        "de": "Am tiefschwarzen Nachthimmel leuchtet ein einsamer, funkelnder Stern.",
        "en": "In the deep black night sky, a lone, twinkling star shines brightly.",
        "ar": "في سماء الليل الحالكة السواد، يلمع نجم وحيد وساطع.",
        "tr": "Karanlık gece gökyüzünde yalnız, parıldayan bir yıldız parlıyor.",
    },
    "himmel": {
        "de": "Der wolkenlose Himmel erstrahlt in einem tiefen, klaren Blau.",
        "en": "The cloudless sky radiates in a deep, clear blue.",
        "ar": "السماء الصافية الخالية من الغيوم تشع بزرقة عميقة ونقية.",
        "tr": "Bulutsuz gökyüzü derin, berrak bir maviyle parıldar.",
    },
    "regen": {
        "de": "Der warme Sommerregen erfrischt die Pflanzen und reinigt die staubige Luft.",
        "en": "The warm summer rain refreshes the plants and cleanses the dusty air.",
        "ar": "مطر الصيف الدافئ ينعش النباتات وينقي الهواء من الغبار.",
        "tr": "Sıcak yaz yağmuru bitkileri tazeler ve tozlu havayı temizler.",
    },
    "schnee": {
        "de": "Der lautlos fallende Schnee hüllt die winterliche Landschaft in reines Weiß.",
        "en": "The silently falling snow envelops the winter landscape in pure white.",
        "ar": "الثلج المتساقط بصمت يغلف الطبيعة الشتوية برداء أبيض ناصع.",
        "tr": "Sessizce yağan kar kış manzarasını saf beyaza bürür.",
    },
    "wind": {
        "de": "Ein kräftiger Wind treibt die weißen Wolken rasch über die Berggipfel.",
        "en": "A strong wind drives the white clouds swiftly over the mountain peaks.",
        "ar": "رياح عاتية تدفع السحب البيضاء بسرعة فوق قمم الجبال.",
        "tr": "Kuvvetli rüzgar beyaz bulutları dağ zirvelerinin üzerinden hızla sürükler.",
    },

    # --- Time, Calendar & Seasons ---
    "zeit": {
        "de": "Die Zeit vergeht besonders schnell, wenn man sich gut amüsiert.",
        "en": "Time passes especially quickly when you are having a good time.",
        "ar": "الوقت يمر بسرعة فائقة عندما يقضي المرء وقتاً ممتعاً.",
        "tr": "İyi vakit geçirirken zaman özellikle hızlı akar.",
    },
    "tag": {
        "de": "Ein sonniger Tag am Meer lädt zum Entspannen und Durchatmen ein.",
        "en": "A sunny day by the sea invites relaxation and taking a deep breath.",
        "ar": "يوم مشمس على شاطئ البحر يدعو للاسترخاء والتنفس بعمق.",
        "tr": "Deniz kenarında güneşli bir gün dinlenmeye ve derin bir nefes almaya davet eder.",
    },
    "nacht": {
        "de": "In der stillen Nacht findet der Körper die nötige Ruhe zur Erholung.",
        "en": "In the still night the body finds the needed rest for recovery.",
        "ar": "في سكون الليل يجد الجسد الراحة الضرورية لتجديد طاقته.",
        "tr": "Sessiz gecede beden toparlanmak için gerekli dinlenmeyi bulur.",
    },
    "morgen": {
        "de": "Am frühen Morgen genieße ich die Ruhe bei einer Tasse heißem Kaffee.",
        "en": "In the early morning I enjoy the silence with a cup of hot coffee.",
        "ar": "في الصباح الباكر أستمتع بالهدوء مع فنجان من القهوة الساخنة.",
        "tr": "Sabahın erken saatlerinde bir fincan sıcak kahve eşliğinde sessizliğin tadını çıkarırım.",
    },
    "abend": {
        "de": "Am gemütlichen Abend liest die Familie gerne gemeinsam bei Kerzenschein.",
        "en": "In the cozy evening the family enjoys reading together by candlelight.",
        "ar": "في المساء المريح تحب العائلة القراءة معاً على ضوء الشموع.",
        "tr": "Huzurlu akşamda aile mum ışığında birlikte kitap okumayı sever.",
    },
    "woche": {
        "de": "Die neue Arbeitswoche startet mit einer klaren Priorisierung aller Aufgaben.",
        "en": "The new work week begins with clear prioritization of all tasks.",
        "ar": "يبدأ أسبوع العمل الجديد بترتيب أولويات المهام بوضوح.",
        "tr": "Yeni çalışma haftası tüm görevlerin net bir önceliklendirilmesiyle başlar.",
    },
    "monat": {
        "de": "In diesem Monat haben wir erfreulich große Lernfortschritte erzielt.",
        "en": "In this month we have achieved pleasingly great learning progress.",
        "ar": "في هذا الشهر حققنا تقدماً لغوياً ملموساً ورائعاً.",
        "tr": "Bu ay içinde memnuniyet verici derecede büyük öğrenme ilerlemesi kaydettik.",
    },
    "jahr": {
        "de": "Das vergangene Jahr brachte viele bereichernde Begegnungen und Erfolge.",
        "en": "The past year brought many enriching encounters and successes.",
        "ar": "العام المنصرم جلب معه العديد من اللقاءات المثمرة والنجاحات.",
        "tr": "Geçtiğimiz yıl birçok zenginleştirici karşılaşma ve başarı getirdi.",
    },
    "stunde": {
        "de": "Eine konzentrierte Stunde täglichen Übens festigt den Wortschatz dauerhaft.",
        "en": "A focused hour of daily practice cements vocabulary permanently.",
        "ar": "ساعة تدريب يومية بتركيز ترسخ المفردات في الذاكرة بشكل دائم.",
        "tr": "Günde bir saatlik odaklanmış pratik kelime dağarcığını kalıcı olarak pekiştirir.",
    },
    "minute": {
        "de": "Jede freie Minute eignet sich, um kurz ein paar neue Wörter zu wiederholen.",
        "en": "Every spare minute is great for quickly reviewing a few new words.",
        "ar": "كل دقيقة فراغ مناسبة لمراجعة بضع كلمات جديدة سريعاً.",
        "tr": "Her boş dakika birkaç yeni kelimeyi hızlıca tekrar etmek için harikadır.",
    },

    # --- Abstract & Learning Core Concepts ---
    "sprache": {
        "de": "Die deutsche Sprache hat faszinierende Regeln und präzise Ausdrucksweisen.",
        "en": "The German language has fascinating rules and precise expressions.",
        "ar": "اللغة الألمانية تتميز بقواعد مشوقة وأساليب تعبير شديدة الدقة.",
        "tr": "Almanca dili büyüleyici kurallara ve kesin ifadelere sahiptir.",
    },
    "wort": {
        "de": "Ein neues deutsches Wort lernt man am besten direkt im passenden Beispielsatz.",
        "en": "A new German word is learned best directly in a suitable example sentence.",
        "ar": "الكلمة الألمانية الجديدة تُتعلم على النحو الأمثل داخل جملة سياقية ملائمة.",
        "tr": "Yeni bir Almanca kelime en iyi doğrudan uygun bir örnek cümle içinde öğrenilir.",
    },
    "artikel": {
        "de": "Der grammatische Artikel 'der', 'die' oder 'das' bestimmt das Geschlecht des Nomens.",
        "en": "The grammatical article 'der', 'die', or 'das' determines the noun's gender.",
        "ar": "أداة التعريف النحوية 'der' أو 'die' أو 'das' تحدد جنس الاسم في الألمانية.",
        "tr": "Dilbilgisel artikel 'der', 'die' veya 'das' ismin cinsiyetini belirler.",
    },
    "satz": {
        "de": "Ein klar strukturierter Satz erleichtert das Verständnis komplexer Gedanken.",
        "en": "A clearly structured sentence eases understanding of complex thoughts.",
        "ar": "الجملة واضحة التركيب تسهل فهم الأفكار المعقدة.",
        "tr": "Net yapılandırılmış bir cümle karmaşık düşüncelerin anlaşılmasını kolaylaştırır.",
    },
    "frage": {
        "de": "Eine gezielte Frage hilft dabei, ein schwieriges Thema besser zu durchdringen.",
        "en": "A targeted question helps to better understand a difficult topic.",
        "ar": "السؤال الدقيق والمحدد يساعد على استيعاب موضوع صعب بشكل أعمق.",
        "tr": "Hedefe yönelik bir soru zor bir konuyu daha iyi kavramaya yardımcı olur.",
    },
    "antwort": {
        "de": "Die präzise Antwort klärte alle offenen Unklarheiten der Schüler sofort.",
        "en": "The precise answer immediately resolved all students' open uncertainties.",
        "ar": "الإجابة الدقيقة أزالت على الفور كافة التساؤلات والغموض لدى الطلاب.",
        "tr": "Kesin cevap öğrencilerin aklındaki tüm soru işaretlerini hemen giderdi.",
    },
    "regel": {
        "de": "Eine einfache Faustregel erleichtert das Merken vieler deutscher Wortendungen.",
        "en": "A simple rule of thumb makes memorizing many German noun endings easier.",
        "ar": "قاعدة استرشادية بسيطة تسهل تذكر نهايات الكلمات الألمانية الكثيرة.",
        "tr": "Basit bir pratik kural birçok Almanca kelime sonunu ezberlemeyi kolaylaştırır.",
    },
    "beispiel": {
        "de": "Ein anschauliches Beispiel macht die grammatische Erklärung sofort verständlich.",
        "en": "A clear example makes the grammatical explanation instantly understandable.",
        "ar": "المثال التوضيحي الواضح يجعل الشرح النحوي مفهوماً في الحال.",
        "tr": "Canlı bir örnek dilbilgisi açıklamasını hemen anlaşılır hale getirir.",
    },
    "problem": {
        "de": "Für jedes scheinbar unlösbare Problem gibt es eine schrittweise Lösung.",
        "en": "For every seemingly unsolvable problem there is a step-by-step solution.",
        "ar": "لكل مشكلة تبدو مستعصية يوجد حل يمكن تحقيقه خطوة بخطوة.",
        "tr": "Görünüşte çözümsüz her sorun için adım adım bir çözüm vardır.",
    },
    "lösung": {
        "de": "Die kreative Lösung überraschte alle Beteiligten durch ihre Einfachheit.",
        "en": "The creative solution surprised all involved by its simplicity.",
        "ar": "الحل الإبداعي فاجأ جميع المعنيين ببساطته وفاعليته.",
        "tr": "Yaratıcı çözüm sadeliğiyle katılan herkesi şaşırttı.",
    },
    "idee": {
        "de": "Eine brillante Idee kann der Ausgangspunkt für eine große Veränderung sein.",
        "en": "A brilliant idea can be the starting point for a major change.",
        "ar": "الفكرة العبقرية قد تكون نقطة الانطلاق لتغيير عظيم.",
        "tr": "Parlak bir fikir büyük bir değişimin başlangıç noktası olabilir.",
    },
    "gedanke": {
        "de": "Ein positiver Gedanke am Morgen beeinflusst den gesamten Verlauf des Tages.",
        "en": "A positive thought in the morning influences the whole course of the day.",
        "ar": "الفكرة الإيجابية في الصباح تؤثر على مجرى اليوم بأكمله.",
        "tr": "Sabahki olumlu bir düşünce günün tüm gidişatını etkiler.",
    },
    "leben": {
        "de": "Das Leben bietet jeden Tag neue Gelegenheiten, etwas Schönes zu lernen.",
        "en": "Life offers fresh opportunities every day to learn something wonderful.",
        "ar": "الحياة تتيح كل يوم فرصاً جديدة لتعلم أمور جميلة وقيمة.",
        "tr": "Hayat her gün güzel bir şeyler öğrenmek için taze fırsatlar sunar.",
    },
    "freiheit": {
        "de": "Die persönliche Freiheit gehört zu den kostbarsten Gütern aller Menschen.",
        "en": "Personal freedom is among the most precious assets of all human beings.",
        "ar": "الحرية الشخصية من أثمن الحقوق الإنسانية لجميع البشر.",
        "tr": "Kişisel özgürlük tüm insanların en değerli varlıkları arasındadır.",
    },
    "wahrheit": {
        "de": "Die ehrliche Wahrheit schafft langfristig tiefes Vertrauen zwischen Menschen.",
        "en": "The honest truth creates deep, long-term trust between people.",
        "ar": "الحقيقة الصادقة تبني ثقة عميقة ودائمة بين البشر.",
        "tr": "Dürüst gerçek insanlar arasında uzun vadeli derin bir güven yaratır.",
    },
    "glück": {
        "de": "Wirkliches Glück findet man oft in den kleinen, stillen Momenten des Alltags.",
        "en": "True happiness is often found in the small, quiet moments of daily life.",
        "ar": "السعادة الحقيقية توجد غالباً في اللحظات الهادئة والبسيطة من الحياة اليومية.",
        "tr": "Gerçek mutluluk genellikle günlük yaşamın küçük, sessiz anlarında bulunur.",
    },
    "hoffnung": {
        "de": "Die unerschütterliche Hoffnung gibt auch in schwierigen Lebensphasen Kraft.",
        "en": "Steadfast hope gives strength even in difficult phases of life.",
        "ar": "الأمل الراسخ يمنح الإنسان القوة حتى في أصعب مراحل الحياة.",
        "tr": "Sarsılmaz umut hayatın zorlu evrelerinde bile güç verir.",
    },
    "liebe": {
        "de": "Die aufrichtige Liebe zur Familie und Freunden bereichert unser ganzes Dasein.",
        "en": "Sincere love for family and friends enriches our entire existence.",
        "ar": "المحبة الصادقة للعائلة والأصدقاء تثري كياننا ووجودنا بالكامل.",
        "tr": "Aileye ve arkadaşlara duyulan samimi sevgi tüm varlığımızı zenginleştirir.",
    },
    "erfolg": {
        "de": "Ausdauernder Fleiß und stetige Übung führen beim Sprachenlernen zum Erfolg.",
        "en": "Persistent diligence and steady practice lead to success in language learning.",
        "ar": "الاجتهاد المستمر والممارسة اليومية هما طريق النجاح في تعلم اللغات.",
        "tr": "Azimli çalışma ve sürekli pratik dil öğreniminde başarıya götürür.",
    },
    "erfahrung": {
        "de": "Praktische Erfahrung vertieft das theoretische Wissen auf unersetzliche Weise.",
        "en": "Practical experience deepens theoretical knowledge in an irreplaceable way.",
        "ar": "الخبرة العملية تعمق المعرفة النظرية بطريقة لا غنى عنها.",
        "tr": "Pratik deneyim teorik bilgiyi yeri doldurulamaz şekilde derinleştirir.",
    },
}

# Productive compound head nouns and their idiomatic sentence patterns
COMPOUND_HEADS: dict[str, dict[str, str]] = {
    "tasse": {
        "de": "Die {word} steht frisch eingeschenkt und dampfend auf dem Tisch.",
        "en": "The {word} sits freshly poured and steaming on the table.",
        "ar": "توضع الـ {word} مسكوبة طازجة ويتصاعد منها البخار على الطاولة.",
        "tr": "{word} masada taze doldurulmuş ve dumanı tüterek duruyor.",
    },
    "glas": {
        "de": "Das {word} ist bis zum Rand mit einem kühlen Getränk gefüllt.",
        "en": "The {word} is filled to the brim with a cool beverage.",
        "ar": "تم ملء الـ {word} حتى حافتها بمشروب بارد ومنعش.",
        "tr": "{word} ağzına kadar serin bir içecekle doldurulmuştur.",
    },
    "flasche": {
        "de": "Die {word} wurde vor dem Ausflug sicher im Rucksack verstaut.",
        "en": "The {word} was securely stowed in the backpack before the trip.",
        "ar": "وضعت الـ {word} بأمان في حقيبة الظهر قبل الانطلاق في الرحلة.",
        "tr": "{word} geziden önce sırt çantasında güvenle muhafaza edildi.",
    },
    "teller": {
        "de": "Auf dem {word} ist die Mahlzeit sehr appetitlich angerichtet.",
        "en": "On the {word}, the meal is presented very appetizingly.",
        "ar": "على الـ {word} تم تقديم الوجبة بطريقة شهية وجذابة.",
        "tr": "{word} üzerinde yemek son derece iştah açıcı şekilde sunulmuştur.",
    },
    "suppe": {
        "de": "Die {word} schmeckt hausgemacht und wärmt angenehm von innen.",
        "en": "The {word} tastes homemade and warms pleasantly from within.",
        "ar": "تتميز الـ {word} بمذاق منزلي أصيل وتمنح دفئاً ممتعاً.",
        "tr": "{word} ev yapımı tadındadır ve insanı içten içe ısıtır.",
    },
    "kuchen": {
        "de": "Der {word} wurde nach traditionellem Familienrezept gebacken.",
        "en": "The {word} was baked following a traditional family recipe.",
        "ar": "تم خبز الـ {word} وفق وصفة عائلية تقليدية متوارثة.",
        "tr": "{word} geleneksel aile tarifine göre pişirilmiştir.",
    },
    "brot": {
        "de": "Das frische {word} hat eine wunderbar knusprige Rinde.",
        "en": "The fresh {word} has a wonderfully crispy crust.",
        "ar": "يتميز الـ {word} الطازج بقشرة مقرمشة ولذيذة للغاية.",
        "tr": "Taze {word} harika çıtır bir kabuğa sahiptir.",
    },
    "zimmer": {
        "de": "Das {word} ist geschmackvoll eingerichtet und bietet viel Ruhe.",
        "en": "The {word} is tastefully furnished and offers great tranquility.",
        "ar": "تتميز الـ {word} بأثاث أنيق وتوفر الكثير من الهدوء والراحة.",
        "tr": "{word} zevkle döşenmiştir ve büyük bir huzur sunmaktadır.",
    },
    "haus": {
        "de": "Das {word} fügt sich harmonisch in das Bild der Umgebung ein.",
        "en": "The {word} blends harmoniously into the surrounding scenery.",
        "ar": "يتناغم الـ {word} بشكل رائع مع المشهد العام المحيط به.",
        "tr": "{word} çevredeki manzarayla uyum içinde bütünleşmektedir.",
    },
    "tür": {
        "de": "Die {word} lässt sich mit dem passenden Schlüssel leicht öffnen.",
        "en": "The {word} opens easily with the corresponding key.",
        "ar": "يفتح الـ {word} بكل سهولة وسلاسة باستخدام المفتاح المناسب.",
        "tr": "{word} uygun anahtarla kolayca açılır.",
    },
    "fenster": {
        "de": "Das {word} lässt viel natürliches Tageslicht in den Innenraum.",
        "en": "The {word} lets plenty of natural daylight into the interior.",
        "ar": "تسمح الـ {word} بدخول الكثير من ضوء النهار الطبيعي إلى الداخل.",
        "tr": "{word} iç mekana bol miktarda doğal gün ışığı girmesini sağlar.",
    },
    "tisch": {
        "de": "Der {word} steht stabil und bietet eine großzügige Arbeitsfläche.",
        "en": "The {word} stands sturdy and provides a generous work surface.",
        "ar": "تقف الـ {word} بثبات وتوفر مساحة عمل مريحة وواسعة.",
        "tr": "{word} sağlam durur ve geniş bir çalışma alanı sunar.",
    },
    "stuhl": {
        "de": "Der {word} unterstützt eine rückenschonende und aufrechte Haltung.",
        "en": "The {word} supports an upright posture that is easy on the back.",
        "ar": "يدعم الـ {word} وضعية جلوس صحية ومستقيمة تحمي الظهر.",
        "tr": "{word} sırtı koruyan dik bir duruşu destekler.",
    },
    "schrank": {
        "de": "Der geräumige {word} sorgt für Ordnung und Übersichtlichkeit.",
        "en": "The spacious {word} ensures neat order and good overview.",
        "ar": "توفر الـ {word} الواسعة ترتيباً ممتازاً وتنظيماً لكافة الأغراض.",
        "tr": "Geniş {word} düzen ve genel bir ferahlık sağlar.",
    },
    "tasche": {
        "de": "Die praktische {word} lässt sich bequem über der Schulter tragen.",
        "en": "The practical {word} can be carried comfortably over the shoulder.",
        "ar": "يمكن حمل الـ {word} العملية بكل راحة على الكتف.",
        "tr": "Kullanışlı {word} omuzda rahatça taşınabilir.",
    },
    "koffer": {
        "de": "Der {word} rollt dank der vier leichtgängigen Räder mühelos.",
        "en": "The {word} rolls effortlessly thanks to four smooth-running wheels.",
        "ar": "تتحرك الـ {word} بسلاسة بفضل العجلات الأربع سهلة الدوران.",
        "tr": "{word} dört akıcı tekerleği sayesinde zahmetsizce ilerler.",
    },
    "schlüssel": {
        "de": "Der {word} passt exakt in das Schloss und dreht sich leicht.",
        "en": "The {word} fits precisely into the lock and turns easily.",
        "ar": "يناسب الـ {word} القفل تماماً ويدور بسلاسة.",
        "tr": "{word} kilide tam olarak uyar ve kolayca döner.",
    },
    "uhr": {
        "de": "Die {word} zeigt die verbleibende Zeit präzise an.",
        "en": "The {word} shows the remaining time with high precision.",
        "ar": "تعرض الـ {word} الوقت المتبقي بدقة متناهية.",
        "tr": "{word} kalan süreyi yüksek hassasiyetle gösterir.",
    },
    "brille": {
        "de": "Die {word} schützt die Augen zuverlässig vor äußeren Einflüssen.",
        "en": "The {word} reliably protects the eyes from external influences.",
        "ar": "تحمي الـ {word} العينين بموثوقية عالية من العوامل الخارجية.",
        "tr": "{word} gözleri dış etkenlere karşı güvenle korur.",
    },
    "buch": {
        "de": "Das {word} enthält viele lehrreiche Kapitel und wertvolle Tipps.",
        "en": "The {word} contains many instructive chapters and valuable tips.",
        "ar": "يحتوي الـ {word} على فصول تعليمية ثرية ونصائح قيمة.",
        "tr": "{word} birçok öğretici bölüm ve değerli ipucu içerir.",
    },
    "karte": {
        "de": "Die {word} zeigt alle wichtigen Details übersichtlich dargestellt.",
        "en": "The {word} displays all important details clearly arranged.",
        "ar": "تعرض الـ {word} كافة التفاصيل المهمة بوضوح وسهولة.",
        "tr": "{word} tüm önemli ayrıntıları net bir şekilde gösterir.",
    },
    "plan": {
        "de": "Der {word} hilft dabei, alle anstehenden Termine strukturiert einzuhalten.",
        "en": "The {word} helps to keep all upcoming appointments structured.",
        "ar": "تساعد الـ {word} على تنظيم كافة المواعيد والالتزامات بكفاءة.",
        "tr": "{word} yaklaşan tüm randevuların planlı tutulmasına yardımcı olur.",
    },
    "baum": {
        "de": "Der {word} trägt im Spätsommer reiche und saftige Früchte.",
        "en": "The {word} bears rich and juicy fruits in late summer.",
        "ar": "تثمر شجرة الـ {word} ثماراً يانعة ووفيرة في أواخر الصيف.",
        "tr": "{word} yaz sonunda bol ve sulu meyveler verir.",
    },
    "blume": {
        "de": "Die {word} erfreut das Auge mit ihren leuchtenden Farbtönen.",
        "en": "The {word} delights the eye with its vibrant hues.",
        "ar": "تسُر زهرة الـ {word} الأعين بألوانها البهيجة والمشرقة.",
        "tr": "{word} canlı renk tonlarıyla gözü sevindirir.",
    },
    "auto": {
        "de": "Das {word} zeichnet sich durch moderne Sicherheitssysteme aus.",
        "en": "The {word} is distinguished by modern safety systems.",
        "ar": "تتميز سيارة الـ {word} بأنظمة أمان ومساعدة حديثة ومتطورة.",
        "tr": "{word} modern güvenlik sistemleriyle öne çıkmaktadır.",
    },
    "zug": {
        "de": "Der {word} verkehrt mehrmals täglich zwischen beiden Großstädten.",
        "en": "The {word} runs several times a day between the two major cities.",
        "ar": "ينطلق قطار الـ {word} عدة مرات يومياً بين المدينتين الكبريين.",
        "tr": "{word} iki büyük şehir arasında günde birkaç kez sefer yapar.",
    },
    "schuh": {
        "de": "Der {word} bietet hervorragenden Halt und maximalen Gehkomfort.",
        "en": "The {word} provides excellent grip and maximum walking comfort.",
        "ar": "يوفر حذاء الـ {word} ثباتاً ممتازاً وراحة قصوى أثناء المشي.",
        "tr": "{word} mükemmel bir tutuş ve maksimum yürüme konforu sağlar.",
    },
    "jacke": {
        "de": "Die {word} hält den Körper auch bei kühlem Wetter angenehm warm.",
        "en": "The {word} keeps the body comfortably warm even in cool weather.",
        "ar": "سترة الـ {word} تبقي الجسم دافئاً ومرتاحاً حتى في الطقس البارد.",
        "tr": "{word} serin havalarda bile vücudu hoş bir şekilde sıcak tutar.",
    },
    "kleid": {
        "de": "Das {word} zieht bei festlichen Feiern alle Blicke auf sich.",
        "en": "The {word} attracts all eyes at festive celebrations.",
        "ar": "فستان الـ {word} يلفت جميع الأنظار في المناسبات الاحتفالية.",
        "tr": "{word} kutlama ve davetlerde tüm bakışları üzerine çeker.",
    },
    "schule": {
        "de": "Die {word} legt großen Wert auf eine individuelle Förderung der Lernenden.",
        "en": "The {word} places great emphasis on individualized learner support.",
        "ar": "تولي مدرسة الـ {word} اهتماماً بالغاً بالتطوير الفردي للمتعلمين.",
        "tr": "{word} öğrencilerin bireysel gelişimine büyük önem verir.",
    },
    "spiel": {
        "de": "Das {word} sorgt für große Unterhaltung und Spannung in der Runde.",
        "en": "The {word} provides great entertainment and excitement in the group.",
        "ar": "تضفي لعبة الـ {word} متعة وإثارة كبيرة على أجواء المجموعة.",
        "tr": "{word} grup içinde büyük bir eğlence ve heyecan yaratır.",
    },
    "tag": {
        "de": "Der {word} wurde mit vielen schönen Momenten im Kreis der Liebsten gefeiert.",
        "en": "The {word} was celebrated with many fond moments among loved ones.",
        "ar": "تم الاحتفال بـ {word} بالعديد من اللحظات الجميلة بصحبة الأحباء.",
        "tr": "{word} sevdiklerimizle birlikte birçok güzel anıyla kutlandı.",
    },
    "zeit": {
        "de": "Die {word} lässt sich wunderbar für erholsame Hobbys nutzen.",
        "en": "The {word} can be used wonderfully for relaxing hobbies.",
        "ar": "يمكن استغلال أوقات الـ {word} بشكل رائع في ممارسة الهوايات المفيدة.",
        "tr": "{word} dinlendirici hobiler için harika bir şekilde değerlendirilebilir.",
    },
}

# Semantic suffix templates for morphological derivations
SUFFIX_TEMPLATES: list[tuple[list[str], str, dict[str, str]]] = [
    # -ung (die)
    (
        ["ung"],
        "die",
        {
            "de": "Die {word} spielt für den Gesamterfolg eine entscheidende Rolle.",
            "en": "The {word} plays a decisive role in the overall success.",
            "ar": "تلعب الـ {word} دوراً حاسماً في تحقيق النجاح الشامل.",
            "tr": "{word} genel başarı için belirleyici bir rol oynamaktadır.",
        },
    ),
    # -heit, -keit (die)
    (
        ["heit", "keit"],
        "die",
        {
            "de": "Die {word} ist ein wertvolles Gut, das man stets schätzen sollte.",
            "en": "The {word} is a valuable asset that one should always cherish.",
            "ar": "تعتبر الـ {word} قيمة ثمينة ينبغي تقديرها ورعايتها دائماً.",
            "tr": "{word} her zaman değer verilmesi gereken kıymetli bir unsurdur.",
        },
    ),
    # -schaft (die)
    (
        ["schaft"],
        "die",
        {
            "de": "Die {word} zeichnet sich durch Zusammenhalt und Vertrauen aus.",
            "en": "The {word} is characterized by solidarity and mutual trust.",
            "ar": "تتميز الـ {word} بروح التعاون والتضامن والثقة المتبادلة.",
            "tr": "{word} dayanışma ve karşılıklı güvenle öne çıkmaktadır.",
        },
    ),
    # -ion, -tät, -ie, -ur (die)
    (
        ["ion", "tät", "anz", "enz"],
        "die",
        {
            "de": "Die {word} wird im theoretischen und praktischen Kontext analysiert.",
            "en": "The {word} is analyzed in both theoretical and practical contexts.",
            "ar": "تتم دراسة وتحليل الـ {word} في السياقين النظري والعملي.",
            "tr": "{word} hem teorik hem de pratik bağlamda incelenmektedir.",
        },
    ),
    # -er, -or, -ist (der)
    (
        ["ist", "oge", "ant", "ent"],
        "der",
        {
            "de": "Der {word} zeichnet sich durch Engagement und Zuverlässigkeit aus.",
            "en": "The {word} is characterized by commitment and reliability.",
            "ar": "يتميز الـ {word} بالالتزام والمسؤولية والكفاءة العالية.",
            "tr": "{word} bağlılık ve güvenilirlikle kendini göstermektedir.",
        },
    ),
    # -chen, -lein, -ment, -um (das)
    (
        ["chen", "lein", "ment", "um"],
        "das",
        {
            "de": "Das {word} ist ein bemerkenswerter Bestandteil des Ganzen.",
            "en": "The {word} is a noteworthy component of the whole.",
            "ar": "يعتبر الـ {word} عنصراً بارزاً وجزءاً مهماً من البناء المتكامل.",
            "tr": "{word} bütünün kayda değer ve önemli bir parçasıdır.",
        },
    ),
]


def get_example_sentence(
    word: str,
    article: str,
    translation: str | None = None,
) -> dict[str, str]:
    """
    Retrieve or dynamically generate a sensible, contextual example sentence for the noun.
    Returns a dict with 'de', 'en', 'ar', and 'tr' translations.
    """
    key = word.strip().lower()

    # 1. Direct curated bank lookup
    if key in CURATED_SENTENCES:
        return CURATED_SENTENCES[key]

    formatted_word = word.strip().capitalize()
    art = article.strip().lower()

    # 2. Check for compound noun head matches
    for head, tmpl in COMPOUND_HEADS.items():
        if key.endswith(head) and len(key) > len(head):
            return {
                "de": tmpl["de"].format(word=formatted_word),
                "en": tmpl["en"].format(word=formatted_word),
                "ar": tmpl["ar"].format(word=formatted_word),
                "tr": tmpl["tr"].format(word=formatted_word),
            }

    # 3. Check for derivational morphological suffix matches
    for suffixes, suffix_gender, tmpl in SUFFIX_TEMPLATES:
        if art == suffix_gender and any(key.endswith(s) for s in suffixes):
            return {
                "de": tmpl["de"].format(word=formatted_word),
                "en": tmpl["en"].format(word=formatted_word),
                "ar": tmpl["ar"].format(word=formatted_word),
                "tr": tmpl["tr"].format(word=formatted_word),
            }

    # 4. Universal natural language-learning fallback sentence
    # This sentence is 100% natural, grammatically sound, and contextually makes sense
    # for ANY German noun without making absurd claims about physical position or usage.
    art_labels = {
        "der": ("der", "masculine", "المذكر", "eril"),
        "die": ("die", "feminine", "المؤنث", "dişil"),
        "das": ("das", "neuter", "المحايد", "nötr"),
    }
    art_info = art_labels.get(art, (art, "German", "الألماني", "Almanca"))

    if translation and len(translation.strip()) > 1:
        clean_tr = translation.strip()
        return {
            "de": f"Im Deutschkurs haben wir heute das Nomen '{art} {formatted_word}' gelernt.",
            "en": f"The German noun '{art} {formatted_word}' means '{clean_tr}' in English.",
            "ar": f"الاسم {art_info[2]} '{art} {formatted_word}' يعني بالإنجليزية '{clean_tr}'.",
            "tr": f"Almanca {art_info[3]} '{art} {formatted_word}' ismi İngilizcede '{clean_tr}' anlamına gelir.",
        }

    return {
        "de": f"Im heutigen Deutschunterricht haben wir das Nomen '{art} {formatted_word}' geübt.",
        "en": f"In today's German class, we practiced the {art_info[1]} noun '{art} {formatted_word}'.",
        "ar": f"تدربنا اليوم في درس اللغة الألمانية على الاسم {art_info[2]} '{art} {formatted_word}'.",
        "tr": f"Bugünkü Almanca dersinde {art_info[3]} '{art} {formatted_word}' ismini çalıştık.",
    }
