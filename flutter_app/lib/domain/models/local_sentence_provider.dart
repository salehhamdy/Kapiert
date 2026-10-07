import 'example_sentence.dart';

/// Provides offline contextual example sentences with English, Arabic, and Turkish translations.
class LocalSentenceProvider {
  LocalSentenceProvider._();

  static const Map<String, ExampleSentence> _curated = {
    // --- Foods, Beverages & Kitchen ---
    'apfel': ExampleSentence(
      german: 'Der rote Apfel ist saftig, knackig und schmeckt süß.',
      english: 'The red apple is juicy, crisp, and tastes sweet.',
      arabic: 'التفاحة الحمراء طازجة ومقرمشة وطعمها حلو ولذيذ.',
      turkish: 'Kırmızı elma sulu, çıtır ve tatlıdır.',
    ),
    'banane': ExampleSentence(
      german: 'Die gelbe Banane ist reif und schmeckt herrlich süß.',
      english: 'The yellow banana is ripe and tastes wonderfully sweet.',
      arabic: 'الموزة الصفراء ناضجة وطعمها حلو ورائع.',
      turkish: 'Sarı muz olgun ve harika bir şekilde tatlı.',
    ),
    'orange': ExampleSentence(
      german: 'Die frische Orange liefert viel gesundes Vitamin C.',
      english: 'The fresh orange provides plenty of healthy vitamin C.',
      arabic: 'البرتقالة الطازجة تمد الجسم بالكثير من فيتامين C الصحي.',
      turkish: 'Taze portakal bol miktarda sağlıklı C vitamini sağlar.',
    ),
    'zitrone': ExampleSentence(
      german: 'Die gelbe Zitrone verleiht dem Tee einen erfrischenden Geschmack.',
      english: 'The yellow lemon gives the tea a refreshing taste.',
      arabic: 'الليمونة الصفراء تمنح الشاي طعماً منعشاً.',
      turkish: 'Sarı limon çaya ferahlatıcı bir tat verir.',
    ),
    'kartoffel': ExampleSentence(
      german: 'Die gekochte Kartoffel ist eine beliebte Beilage in der deutschen Küche.',
      english: 'The boiled potato is a popular side dish in German cuisine.',
      arabic: 'البطاطا المسلوقة طبق جانبي محبوب في المطبخ الألماني.',
      turkish: 'Haşlanmış patates Alman mutfağında sevilen bir garnitürdür.',
    ),
    'tomate': ExampleSentence(
      german: 'Die reife Tomate passt hervorragend in einen frischen Sommersalat.',
      english: 'The ripe tomato fits excellently in a fresh summer salad.',
      arabic: 'الطماطم الناضجة تتناسب بشكل رائع مع سلطة الصيف الطازجة.',
      turkish: 'Olgun domates taze bir yaz salatasına çok yakışır.',
    ),
    'salat': ExampleSentence(
      german: 'Der bunte Salat wird mit feinem Olivenöl und Essig zubereitet.',
      english: 'The colorful salad is prepared with fine olive oil and vinegar.',
      arabic: 'السلطة الملونة تُحضر بزيت الزيتون الممتاز والخل.',
      turkish: 'Renkli salata kaliteli zeytinyağı ve sirke ile hazırlanır.',
    ),
    'suppe': ExampleSentence(
      german: 'Die heiße Gemüsesuppe wärmt wunderbar an kalten Wintertagen.',
      english: 'The hot vegetable soup warms wonderfully on cold winter days.',
      arabic: 'حساء الخضار الساخن يبعث على الدفء بشكل رائع في أيام الشتاء الباردة.',
      turkish: 'Sıcak sebze çorbası soğuk kış günlerinde harika bir şekilde ısıtır.',
    ),
    'brot': ExampleSentence(
      german: 'Das knusprige Brot kommt morgens frisch aus der Handwerksbäckerei.',
      english: 'The crusty bread comes fresh from the artisan bakery in the morning.',
      arabic: 'الخبز المقرمش يأتي صباحاً طازجاً من المخبز التقليدي.',
      turkish: 'Çıtır ekmek sabahları fırından taze çıkar.',
    ),
    'brötchen': ExampleSentence(
      german: 'Am Sonntag essen wir zum Frühstück warme, goldbraune Brötchen.',
      english: 'On Sundays we eat warm, golden-brown rolls for breakfast.',
      arabic: 'في يوم الأحد نتناول لفائف الخبز الدافئة والذهبية على الإفطار.',
      turkish: 'Pazar günleri kahvaltıda sıcak, altın sarısı küçük ekmekler yeriz.',
    ),
    'butter': ExampleSentence(
      german: 'Die weiche Butter lässt sich leicht auf das frische Brot streichen.',
      english: 'The soft butter spreads easily onto the fresh bread.',
      arabic: 'الزبدة الطرية تُدهن بسهولة على الخبز الطازج.',
      turkish: 'Yumuşak tereyağı taze ekmeğe kolayca sürülür.',
    ),
    'käse': ExampleSentence(
      german: 'Der würzige Käse schmeckt besonders intensiv zu frischem Baguette.',
      english: 'The savory cheese tastes especially intense with a fresh baguette.',
      arabic: 'الجبن المبهر له نكهة قوية وطيبة مع الخبز الفرنسي الطازج.',
      turkish: 'Baharatlı peynir taze baget ekmekle özellikle yoğun bir tada sahiptir.',
    ),
    'ei': ExampleSentence(
      german: 'Das weichgekochte Ei schmeckt mit einer Prise Salz hervorragend.',
      english: 'The soft-boiled egg tastes outstanding with a pinch of salt.',
      arabic: 'البيضة المسلوقة طرية ومذاقها رائع مع رشة ملح.',
      turkish: 'Rafadan yumurta bir tutam tuzla harika bir tada sahiptir.',
    ),
    'fleisch': ExampleSentence(
      german: 'Das zarte Fleisch wird schonend in der heißen Pfanne gebraten.',
      english: 'The tender meat is gently fried in the hot pan.',
      arabic: 'اللحم الطري يُقلى بلطف في المقلاة الساخنة.',
      turkish: 'Yumuşak et sıcak tavada nazikçe kızartılır.',
    ),
    'fisch': ExampleSentence(
      german: 'Der frische Fisch wird mit Zitrone und feinen Kräutern serviert.',
      english: 'The fresh fish is served with lemon and fine herbs.',
      arabic: 'السمك الطازج يُقدم مع الليمون والأعشاب العطرية الفاخرة.',
      turkish: 'Taze balık limon ve ince otlarla servis edilir.',
    ),
    'kuchen': ExampleSentence(
      german: 'Der frisch gebackene Apfelkuchen duftet herrlich nach Zimt.',
      english: 'The freshly baked apple cake smells delightfully of cinnamon.',
      arabic: 'كعكة التفاح المخبوزة طازجة تفوح برائحة القرفة الزكية.',
      turkish: 'Taze pişmiş elmalı pasta nefis tarçın kokuyor.',
    ),
    'schokolade': ExampleSentence(
      german: 'Die feine Schweizer Schokolade schmilzt langsam und zart auf der Zunge.',
      english: 'The fine Swiss chocolate melts slowly and delicately on the tongue.',
      arabic: 'الشوكولاتة السويسرية الفاخرة تذوب بنعومة وببطء في الفم.',
      turkish: 'Seçkin İsviçre çikolatası dilde yavaşça ve zarifçe erir.',
    ),
    'zucker': ExampleSentence(
      german: 'Ein kleiner Teelöffel Zucker macht den Espresso angenehm mild.',
      english: 'A small teaspoon of sugar makes the espresso pleasantly mild.',
      arabic: 'ملعقة صغيرة من السكر تجعل الإسبريسو حلواً ولطيفاً.',
      turkish: 'Küçük bir çay kaşığı şeker espressoyu hoş bir şekilde hafifletir.',
    ),
    'salz': ExampleSentence(
      german: 'Eine Prise Salz bringt den natürlichen Geschmack der Speisen hervor.',
      english: 'A pinch of salt brings out the natural flavor of the food.',
      arabic: 'رشة من الملح تبرز النكهة الطبيعية للطعام.',
      turkish: 'Bir tutam tuz yemeklerin doğal lezzetini ortaya çıkarır.',
    ),
    'wasser': ExampleSentence(
      german: 'Ein kühles Glas Wasser löscht den Durst an heißen Tagen am besten.',
      english: 'A cool glass of water quenches thirst best on hot days.',
      arabic: 'كوب من الماء البارد يروي العطش بشكل أفضل في الأيام الحارة.',
      turkish: 'Soğuk bir bardak su sıcak günlerde susuzluğu en iyi şekilde giderir.',
    ),
    'kaffee': ExampleSentence(
      german: 'Der heiße Kaffee weckt die Lebensgeister am frühen Morgen.',
      english: 'The hot coffee awakens the spirits early in the morning.',
      arabic: 'القهوة الساخنة توقظ الحواس والنشاط في الصباح الباكر.',
      turkish: 'Sıcak kahve sabahın erken saatlerinde zindelik verir.',
    ),
    'tee': ExampleSentence(
      german: 'Der frisch aufgebrühte Kamillentee beruhigt und entspannt den Körper.',
      english: 'The freshly brewed chamomile tea calms and relaxes the body.',
      arabic: 'شاي البابونج الطازج يهدئ الجسم ويمنحه الاسترخاء.',
      turkish: 'Taze demlenmiş papatya çayı vücudu sakinleştirir ve dinlendirir.',
    ),
    'milch': ExampleSentence(
      german: 'Die kalte Milch steht im oberen Fach des Kühlschranks.',
      english: 'The cold milk sits in the upper shelf of the refrigerator.',
      arabic: 'الحليب البارد موجود في الرف العلوي من الثلاجة.',
      turkish: 'Soğuk süt buzdolabının üst rafında duruyor.',
    ),
    'saft': ExampleSentence(
      german: 'Der frisch gepresste Orangensaft schmeckt herrlich fruchtig.',
      english: 'The freshly squeezed orange juice tastes delightfully fruity.',
      arabic: 'عصير البرتقال الطازج طعمه فاكهي ومنعش للغاية.',
      turkish: 'Taze sıkılmış portakal suyu harika bir meyve tadına sahiptir.',
    ),
    'bier': ExampleSentence(
      german: 'Ein kühles Bier gehört für viele zum gemütlichen Feierabend.',
      english: 'A cold beer is part of a cozy evening after work for many.',
      arabic: 'المشروب البارد جزء من الأمسيات الهادئة بعد يوم عمل طويل.',
      turkish: 'Soğuk içecek iş sonrası dinlenmenin vazgeçilmez bir parçasıdır.',
    ),
    'wein': ExampleSentence(
      german: 'Der rote Wein passt geschmacklich exzellent zu gutem Käse.',
      english: 'The red wine pairs excellently in flavor with good cheese.',
      arabic: 'العصير الأحمر الفاخر يتناغم مذاقه بشكل رائع مع الجبن اللذيذ.',
      turkish: 'Kırmızı içecek iyi peynirle lezzet açısından mükemmel uyum sağlar.',
    ),

    // --- Home, Furniture & Objects ---
    'haus': ExampleSentence(
      german: 'Das Haus hat einen sonnigen Garten und eine moderne Architektur.',
      english: 'The house has a sunny garden and modern architecture.',
      arabic: 'المنزل يحتوي على حديقة مشمسة وتصميم معماري عصري.',
      turkish: 'Evin güneşli bir bahçesi ve modern bir mimarisi var.',
    ),
    'wohnung': ExampleSentence(
      german: 'Die helle Wohnung liegt ruhig im obersten Stockwerk des Gebäudes.',
      english: 'The bright apartment is situated quietly on the top floor of the building.',
      arabic: 'الشقة المضيئة تقع في هدوء في الطابق العلوي من المبنى.',
      turkish: 'Aydınlık daire binanın en üst katında sakin bir konumdadır.',
    ),
    'zimmer': ExampleSentence(
      german: 'Das gemütliche Zimmer ist liebevoll und zweckmäßig eingerichtet.',
      english: 'The cozy room is lovingly and practically furnished.',
      arabic: 'الغرفة المريحة مؤثثة بذوق رفيع وبشكل عملي.',
      turkish: 'Rahat oda özenle ve kullanışlı bir şekilde döşenmiştir.',
    ),
    'küche': ExampleSentence(
      german: 'In der geräumigen Küche bereitet die Familie gemeinsam das Essen zu.',
      english: 'In the spacious kitchen, the family prepares the meal together.',
      arabic: 'في المطبخ الواسع تحضر العائلة الطعام معاً.',
      turkish: 'Geniş mutfakta aile birlikte yemek hazırlar.',
    ),
    'tisch': ExampleSentence(
      german: 'Der massive Tisch aus Eichenholz bietet Platz für viele Gäste.',
      english: 'The solid oak table offers plenty of seating for guests.',
      arabic: 'الطاولة المصنوعة من خشب البلوط الصلب تتسع لضيوف عديدين.',
      turkish: 'Masif meşe masa birçok misafir için yer sunar.',
    ),
    'stuhl': ExampleSentence(
      german: 'Der gepolsterte Stuhl ermöglicht stundenlanges bequemes Sitzen.',
      english: 'The upholstered chair enables hours of comfortable sitting.',
      arabic: 'الكرسي المنجد يتيح الجلوس براحة لساعات طويلة.',
      turkish: 'Döşemeli sandalye saatlerce rahatça oturmayı sağlar.',
    ),
    'bett': ExampleSentence(
      german: 'Das bequeme Bett sorgt jede Nacht für einen tiefen, erholsamen Schlaf.',
      english: 'The comfortable bed ensures deep, restful sleep every night.',
      arabic: 'السرير المريح يوفر نوماً عميقاً ومريحاً كل ليلة.',
      turkish: 'Rahat yatak her gece derin ve dinlendirici bir uyku sağlar.',
    ),
    'sofa': ExampleSentence(
      german: 'Auf dem breiten Sofa kann man sich nach der Arbeit herrlich entspannen.',
      english: 'On the wide sofa you can relax wonderfully after work.',
      arabic: 'على الأريكة العريضة يمكن للمرء الاسترخاء بروعة بعد العمل.',
      turkish: 'Geniş kanepede işten sonra harika bir şekilde dinlenebilirsiniz.',
    ),
    'schrank': ExampleSentence(
      german: 'Der weiße Schrank bietet überraschend viel Stauraum für Kleidung.',
      english: 'The white closet offers surprisingly much storage space for clothes.',
      arabic: 'الخزانة البيضاء توفر مساحة تخزين واسعة للملابس بشكل مفاجئ.',
      turkish: 'Beyaz dolap kıyafetler için şaşırtıcı derecede geniş saklama alanı sunar.',
    ),
    'lampe': ExampleSentence(
      german: 'Die elegante Lampe spendet ein angenehm warmes Licht im Raum.',
      english: 'The elegant lamp gives off a pleasantly warm light in the room.',
      arabic: 'المصباح الأنيق يشع ضوءاً دافئاً ومريحاً في الغرفة.',
      turkish: 'Zarif lamba odada hoş ve sıcak bir ışık verir.',
    ),
    'spiegel': ExampleSentence(
      german: 'Der große Spiegel im Flur reflektiert das Tageslicht.',
      english: 'The large mirror in the hallway reflects the natural daylight.',
      arabic: 'المرآة الكبيرة في الردهة تعكس ضوء النهار الطبيعي.',
      turkish: 'Koridordaki büyük ayna gün ışığını yansıtır.',
    ),
    'teppich': ExampleSentence(
      german: 'Der weiche Teppich fühlt sich barfuß wunderbar warm an.',
      english: 'The soft carpet feels wonderfully warm under bare feet.',
      arabic: 'السجادة الناعمة تعطي شعوراً دافئاً رائعاً عند المشي حافي القدمين.',
      turkish: 'Yumuşak halı çıplak ayakla harika bir sıcaklık hissi verir.',
    ),
    'tür': ExampleSentence(
      german: 'Die massive Tür schließt leise und schützt vor Geräuschen aus dem Treppenhaus.',
      english: 'The solid door closes quietly and shields against stairway noise.',
      arabic: 'الباب المتين يغلق بهدوء ويحمي من ضوضاء الدرج.',
      turkish: 'Sağlam kapı sessizce kapanır ve merdiven boşluğundaki gürültüden korur.',
    ),
    'fenster': ExampleSentence(
      german: 'Durch das große Fenster blickt man direkt in den grünen Garten.',
      english: 'Through the large window you look directly into the green garden.',
      arabic: 'من خلال النافذة الكبيرة يطل المرء مباشرة على الحديقة الخضراء.',
      turkish: 'Büyük pencereden doğrudan yeşil bahçeye bakılır.',
    ),
    'schlüssel': ExampleSentence(
      german: 'Der silberne Schlüssel öffnet die Eingangstür mit einer leichten Drehung.',
      english: 'The silver key opens the front door with a slight turn.',
      arabic: 'المفتاح الفضي يفتح باب المدخل بلفّة خفيفة.',
      turkish: 'Gümüş anahtar hafif bir çevirmeyle ön kapıyı açar.',
    ),
    'uhr': ExampleSentence(
      german: 'Die antike Uhr schlägt zu jeder vollen Stunde mit einem klaren Klang.',
      english: 'The antique clock strikes on the hour with a clear tone.',
      arabic: 'الساعة الأثرية تدق عند رأس كل ساعة بنغمة صافية.',
      turkish: 'Antika saat her saat başında net bir sesle çalar.',
    ),
    'handy': ExampleSentence(
      german: 'Das neue Handy hat eine bemerkenswert scharfe Kamera und lange Akkulaufzeit.',
      english: 'The new mobile phone has a remarkably sharp camera and long battery life.',
      arabic: 'الهاتف الذكي الجديد مزود بكاميرا فائقة الوضوح وبطارية تدوم طويلاً.',
      turkish: 'Yeni cep telefonu son derece net bir kameraya ve uzun pil ömrüne sahiptir.',
    ),
    'computer': ExampleSentence(
      german: 'Der schnelle Computer startet alle anspruchsvollen Programme im Handumdrehen.',
      english: 'The fast computer launches all demanding programs in the blink of an eye.',
      arabic: 'الكمبيوتر السريع يفتح البرامج المتقدمة في طرفة عين.',
      turkish: 'Hızlı bilgisayar tüm zorlu programları göz açıp kapayıncaya kadar başlatır.',
    ),
    'buch': ExampleSentence(
      german: 'Das spannende Buch fesselt den Leser von der ersten bis zur letzten Seite.',
      english: 'The exciting book captivates the reader from the first to the last page.',
      arabic: 'الكتاب المشوق يأسر القارئ من الصفحة الأولى وحتى الأخيرة.',
      turkish: 'Heyecan verici kitap okuyucuyu ilk sayfadan son sayfaya kadar büyülüyor.',
    ),
    'kugelschreiber': ExampleSentence(
      german: 'Der Kugelschreiber schreibt flüssig und liegt besonders gut in der Hand.',
      english: 'The ballpoint pen writes smoothly and sits particularly well in the hand.',
      arabic: 'قلم الحبر الجاف يكتب بسلاسة ومريح جداً عند الإمساك به.',
      turkish: 'Tükenmez kalem akıcı bir şekilde yazar ve ele çok iyi oturur.',
    ),
    'bleistift': ExampleSentence(
      german: 'Mit dem gespitzten Bleistift zeichnet die Schülerin saubere geometrische Linien.',
      english: 'With the sharpened pencil, the student draws clean geometric lines.',
      arabic: 'بالقلم الرصاص المبري ترسم الطالبة خطوطاً هندسية دقيقة.',
      turkish: 'Açılmış kurşun kalemle öğrenci temiz geometrik çizgiler çizer.',
    ),
    'tasche': ExampleSentence(
      german: 'Die elegante Ledertasche bietet reichlich Platz für alle Alltagsgegenstände.',
      english: 'The elegant leather bag offers plenty of space for all everyday items.',
      arabic: 'الحقيبة الجلدية الأنيقة توفر متسعاً كبيراً لكافة الأغراض اليومية.',
      turkish: 'Zarif deri çanta tüm günlük eşyalar için bolca alan sunar.',
    ),
    'koffer': ExampleSentence(
      german: 'Der stabile Koffer ist bereits fertig gepackt für die Urlaubsreise.',
      english: 'The sturdy suitcase is already fully packed for the vacation trip.',
      arabic: 'الحقيبة المتينة مجهزة وجاهزة تماماً لرحلة العطلة.',
      turkish: 'Sağlam bavul tatil seyahati için çoktan hazırlandı.',
    ),
    'rucksack': ExampleSentence(
      german: 'Der gepolsterte Rucksack eignet sich perfekt für anspruchsvolle Bergtouren.',
      english: 'The padded backpack is perfect for challenging mountain hikes.',
      arabic: 'حقيبة الظهر المبطنة مثالية لجولات تسلق الجبال الشاقة.',
      turkish: 'Dolgulu sırt çantası zorlu dağ yürüyüşleri için mükemmeldir.',
    ),
    'flasche': ExampleSentence(
      german: 'Die wiederverwendbare Flasche hält das Wasser über viele Stunden eiskalt.',
      english: 'The reusable bottle keeps the water ice-cold for many hours.',
      arabic: 'القارورة القابلة لإعادة الاستخدام تحافظ على برودة الماء لعدة ساعات.',
      turkish: 'Yeniden kullanılabilir şişe suyu saatlerce buz gibi tutar.',
    ),
    'glas': ExampleSentence(
      german: 'Das durchsichtige Glas wird mit kühlem Mineralwasser gefüllt.',
      english: 'The transparent glass is filled with cool sparkling water.',
      arabic: 'الكأس الشفاف يُملأ بالماء المعدني البارد.',
      turkish: 'Şeffaf bardak soğuk maden suyu ile doldurulur.',
    ),
    'tasse': ExampleSentence(
      german: 'Aus der Keramiktasse steigt der angenehme Duft von frisch gebrühtem Kaffee.',
      english: 'The pleasant aroma of freshly brewed coffee rises from the ceramic cup.',
      arabic: 'يتصاعد من الكوب الخزفي عبق القهوة المعدة طازجاً.',
      turkish: 'Seramik fincandan taze demlenmiş kahvenin hoş kokusu yükseliyor.',
    ),
    'teller': ExampleSentence(
      german: 'Auf dem weißen Teller liegt eine köstlich zubereitete Pasta.',
      english: 'On the white plate lies a deliciously prepared pasta dish.',
      arabic: 'على الصحن الأبيض توجد معكرونة محضرة بطريقة شهية.',
      turkish: 'Beyaz tabakta lezzetli bir şekilde hazırlanmış makarna duruyor.',
    ),
    'messer': ExampleSentence(
      german: 'Das geschliffene Messer schneidet mühelos durch das ofenfrische Brot.',
      english: 'The sharpened knife cuts effortlessly through the oven-fresh bread.',
      arabic: 'السكين الحاد يقطع بسهولة الخبز الطازج الخارج من الفرن.',
      turkish: 'Bilenmiş bıçak fırından yeni çıkmış ekmeği zahmetsizce keser.',
    ),
    'gabel': ExampleSentence(
      german: 'Die silberne Gabel liegt exakt links neben dem flachen Teller.',
      english: 'The silver fork lies precisely to the left of the shallow plate.',
      arabic: 'الشوكة الفضية موضوعة بدقة على يسار الصحن المنبسط.',
      turkish: 'Gümüş çatal düz tabağın tam solunda duruyor.',
    ),
    'löffel': ExampleSentence(
      german: 'Mit dem großen Löffel schöpft der Koch die aromatische Brühe in die Schale.',
      english: 'With the large spoon, the cook ladles the aromatic broth into the bowl.',
      arabic: 'بملعقة كبيرة يسكب الطاهي المرق الزكي في الوعاء.',
      turkish: 'Aşçı büyük kaşıkla aromatik çorbayı kaseye koyar.',
    ),
    'zeitung': ExampleSentence(
      german: 'Die seriöse Zeitung liefert fundierte Analysen zu den aktuellen Geschehnissen.',
      english: 'The reputable newspaper provides in-depth analyses of current events.',
      arabic: 'الجريدة الموثوقة تقدم تحليلات معمقة للأحداث الجارية.',
      turkish: 'Güvenilir gazete güncel olaylara ilişkin derinlemesine analizler sunar.',
    ),
    'brief': ExampleSentence(
      german: 'Der persönliche Brief erreichte den Empfänger nach zwei Tagen per Post.',
      english: 'The personal letter reached the recipient after two days by post.',
      arabic: 'الرسالة الشخصية وصلت إلى المستلم بعد يومين بالبريد.',
      turkish: 'Kişisel mektup iki gün sonra posta yoluyla alıcıya ulaştı.',
    ),

    // --- People & Roles ---
    'mann': ExampleSentence(
      german: 'Der freundliche Mann half der Familie hilfsbereit beim Tragen des Koffers.',
      english: 'The friendly man helpfully helped the family carry the suitcase.',
      arabic: 'ساعد الرجل اللطيف العائلة بتعاون في حمل الحقيبة.',
      turkish: 'Güler yüzlü adam bavulun taşınmasında aileye yardımseverce yardımcı oldu.',
    ),
    'frau': ExampleSentence(
      german: 'Die erfahrene Frau leitet das Unternehmen mit Weitblick und Empathie.',
      english: 'The experienced woman leads the enterprise with foresight and empathy.',
      arabic: 'تقود المرأة ذات الخبرة الشركة بنظرة مستقبلية وتعاطف كبير.',
      turkish: 'Deneyimli kadın şirketi ileri görüşlülük ve empatiyle yönetiyor.',
    ),
    'kind': ExampleSentence(
      german: 'Das neugierige Kind entdeckt jeden Tag spielerisch die bunte Welt.',
      english: 'The curious child playfully discovers the colorful world every day.',
      arabic: 'الطفل الفضولي يكتشف العالم الملون كل يوم من خلال اللعب.',
      turkish: 'Meraklı çocuk her gün renkli dünyayı oyun oynayarak keşfeder.',
    ),
    'junge': ExampleSentence(
      german: 'Der sportliche Junge schießt den Fußball gekonnt direkt ins obere Toreck.',
      english: 'The athletic boy skillfully kicks the soccer ball into the top corner.',
      arabic: 'الفتى الرياضي يسدد كرة القدم بمهارة في الزاوية العليا للمرمى.',
      turkish: 'Sportif çocuk futbol topunu ustalıkla kalenin üst köşesine vurur.',
    ),
    'mädchen': ExampleSentence(
      german: 'Das begabte Mädchen spielt mit großer Begeisterung auf dem Klavier.',
      english: 'The gifted girl plays the piano with great enthusiasm.',
      arabic: 'الفتاة الموهوبة تعزف على البيانو بحماس وشغف كبيرين.',
      turkish: 'Yetenekli kız piyano çalmayı büyük bir şevkle sürdürüyor.',
    ),
    'vater': ExampleSentence(
      german: 'Der fürsorgliche Vater liest seinen Kindern jeden Abend eine Geschichte vor.',
      english: 'The caring father reads a bedtime story to his children every evening.',
      arabic: 'الأب الحنون يقرأ لأطفاله قصة كل مساء قبل النوم.',
      turkish: 'Şefkatli baba her akşam çocuklarına masal okur.',
    ),
    'mutter': ExampleSentence(
      german: 'Die liebevolle Mutter unterstützt ihre Familie in allen Lebenslagen.',
      english: 'The loving mother supports her family in all situations of life.',
      arabic: 'الأم المحبة تدعم عائلتها في شتى ظروف الحياة.',
      turkish: 'Sevgi dolu anne ailesini hayatın her anında destekler.',
    ),
    'freund': ExampleSentence(
      german: 'Ein verlässlicher Freund ist auch in stürmischen Zeiten immer für dich da.',
      english: 'A reliable friend is always there for you even in stormy times.',
      arabic: 'الصديق الموثوق يكون دائماً بجانبك حتى في أحلك الأوقات.',
      turkish: 'Güvenilir bir dost fırtınalı zamanlarda bile her zaman yanındadır.',
    ),
    'schule': ExampleSentence(
      german: 'Die moderne Schule fördert kreatives Denken und digitale Medienkompetenz.',
      english: 'The modern school promotes creative thinking and digital media literacy.',
      arabic: 'المدرسة الحديثة تشجع التفكير الإبداعي والمهارات الرقمية المتقدمة.',
      turkish: 'Modern okul yaratıcı düşünmeyi ve dijital medya yetkinliğini destekler.',
    ),
    'universität': ExampleSentence(
      german: 'Die berühmte Universität betreibt Spitzenforschung auf internationalem Niveau.',
      english: 'The famous university conducts top research at an international level.',
      arabic: 'الجامعة الشهيرة تجري أبحاثاً رائدة على أعلى المستويات الدولية.',
      turkish: 'Ünlü üniversite uluslararası düzeyde üst düzey araştırmalar yürütmektedir.',
    ),
    'stadt': ExampleSentence(
      german: 'Die alte Stadt besticht durch ihren mittelalterlichen Charme und bunte Gassen.',
      english: 'The old town charms with its medieval flair and colorful alleys.',
      arabic: 'المدينة القديمة تسحر بأجوائها التراثية وأزقتها الملونة الجميلة.',
      turkish: 'Eski şehir orta çağ cazibesi ve renkli sokaklarıyla büyülüyor.',
    ),
    'sonne': ExampleSentence(
      german: 'Die strahlende Sonne erwärmt die Natur nach den kalten Wintermonaten.',
      english: 'The radiant sun warms nature after the cold winter months.',
      arabic: 'الشمس الساطعة تدفئ الطبيعة وتنعشها بعد أشهر الشتاء الباردة.',
      turkish: 'Parlak güneş soğuk kış aylarının ardından doğayı ısıtır.',
    ),
    'zeit': ExampleSentence(
      german: 'Die Zeit vergeht besonders schnell, wenn man sich gut amüsiert.',
      english: 'Time passes especially quickly when you are having a good time.',
      arabic: 'الوقت يمر بسرعة فائقة عندما يقضي المرء وقتاً ممتعاً.',
      turkish: 'İyi vakit geçirirken zaman özellikle hızlı akar.',
    ),
    'tag': ExampleSentence(
      german: 'Ein sonniger Tag am Meer lädt zum Entspannen und Durchatmen ein.',
      english: 'A sunny day by the sea invites relaxation and taking a deep breath.',
      arabic: 'يوم مشمس على شاطئ البحر يدعو للاسترخاء والتنفس بعمق.',
      turkish: 'Deniz kenarında güneşli bir gün dinlenmeye ve derin bir nefes almaya davet eder.',
    ),
    'nacht': ExampleSentence(
      german: 'In der stillen Nacht findet der Körper die nötige Ruhe zur Erholung.',
      english: 'In the still night the body finds the needed rest for recovery.',
      arabic: 'في سكون الليل يجد الجسد الراحة الضرورية لتجديد طاقته.',
      turkish: 'Sessiz gecede beden toparlanmak için gerekli dinlenmeyi bulur.',
    ),
  };

  /// Productive compound head nouns and their tailored patterns
  static const Map<String, Map<String, String>> _compoundHeads = {
    'tasse': {
      'de': 'Die {word} steht frisch eingeschenkt und dampfend auf dem Tisch.',
      'en': 'The {word} sits freshly poured and steaming on the table.',
      'ar': 'توضع الـ {word} مسكوبة طازجة ويتصاعد منها البخار على الطاولة.',
      'tr': '{word} masada taze doldurulmuş ve dumanı tüterek duruyor.',
    },
    'glas': {
      'de': 'Das {word} ist bis zum Rand mit einem kühlen Getränk gefüllt.',
      'en': 'The {word} is filled to the brim with a cool beverage.',
      'ar': 'تم ملء الـ {word} حتى حافتها بمشروب بارد ومنعش.',
      'tr': '{word} ağzına kadar serin bir içecekle doldurulmuştur.',
    },
    'zimmer': {
      'de': 'Das {word} ist geschmackvoll eingerichtet und bietet viel Ruhe.',
      'en': 'The {word} is tastefully furnished and offers great tranquility.',
      'ar': 'تتميز الـ {word} بأثاث أنيق وتوفر الكثير من الهدوء والراحة.',
      'tr': '{word} zevkle döşenmiştir ve büyük bir huzur sunmaktadır.',
    },
    'haus': {
      'de': 'Das {word} fügt sich harmonisch in das Bild der Umgebung ein.',
      'en': 'The {word} blends harmoniously into the surrounding scenery.',
      'ar': 'يتناغم الـ {word} بشكل رائع مع المشهد العام المحيط به.',
      'tr': '{word} çevredeki manzarayla uyum içinde bütünleşmektedir.',
    },
    'tür': {
      'de': 'Die {word} lässt sich mit dem passenden Schlüssel leicht öffnen.',
      'en': 'The {word} opens easily with the corresponding key.',
      'ar': 'يفتح الـ {word} بكل سهولة وسلاسة باستخدام المفتاح المناسب.',
      'tr': '{word} uygun anahtarla kolayca açılır.',
    },
    'fenster': {
      'de': 'Das {word} lässt viel natürliches Tageslicht in den Innenraum.',
      'en': 'The {word} lets plenty of natural daylight into the interior.',
      'ar': 'تسمح الـ {word} بدخول الكثير من ضوء النهار الطبيعي إلى الداخل.',
      'tr': '{word} iç mekana bol miktarda doğal gün ışığı girmesini sağlar.',
    },
    'buch': {
      'de': 'Das {word} enthält viele lehrreiche Kapitel und wertvolle Tipps.',
      'en': 'The {word} contains many instructive chapters and valuable tips.',
      'ar': 'يحتوي الـ {word} على فصول تعليمية ثرية ونصائح قيمة.',
      'tr': '{word} birçok öğretici bölüm ve değerli ipucu içerir.',
    },
    'schlüssel': {
      'de': 'Der {word} passt exakt in das Schloss und dreht sich leicht.',
      'en': 'The {word} fits precisely into the lock and turns easily.',
      'ar': 'يناسب الـ {word} القفل تماماً ويدور بسلاسة.',
      'tr': '{word} kilide tam olarak uyar ve kolayca döner.',
    },
    'auto': {
      'de': 'Das {word} zeichnet sich durch moderne Sicherheitssysteme aus.',
      'en': 'The {word} is distinguished by modern safety systems.',
      'ar': 'تتميز سيارة الـ {word} بأنظمة أمان ومساعدة حديثة ومتطورة.',
      'tr': '{word} modern güvenlik sistemleriyle öne çıkmaktadır.',
    },
    'zug': {
      'de': 'Der {word} verkehrt mehrmals täglich zwischen beiden Großstädten.',
      'en': 'The {word} runs several times a day between the two major cities.',
      'ar': 'ينطلق قطار الـ {word} عدة مرات يومياً بين المدينتين الكبريين.',
      'tr': '{word} iki büyük şehir arasında günde birkaç kez sefer yapar.',
    },
    'tasche': {
      'de': 'Die praktische {word} lässt sich bequem über der Schulter tragen.',
      'en': 'The practical {word} can be carried comfortably over the shoulder.',
      'ar': 'يمكن حمل الـ {word} العملية بكل راحة على الكتف.',
      'tr': 'Kullanışlı {word} omuzda rahatça taşınabilir.',
    },
  };

  /// Returns a curated or dynamically framed sentence for any German noun.
  static ExampleSentence getSentence(
    String word,
    String article, {
    String? translation,
  }) {
    final key = word.trim().toLowerCase();
    if (_curated.containsKey(key)) {
      return _curated[key]!;
    }

    final formatted = word.isEmpty
        ? 'Wort'
        : word[0].toUpperCase() + word.substring(1).toLowerCase();
    final art = article.trim().toLowerCase();

    // 1. Compound head match
    for (final entry in _compoundHeads.entries) {
      if (key.endsWith(entry.key) && key.length > entry.key.length) {
        final tmpl = entry.value;
        return ExampleSentence(
          german: tmpl['de']!.replaceAll('{word}', formatted),
          english: tmpl['en']!.replaceAll('{word}', formatted),
          arabic: tmpl['ar']!.replaceAll('{word}', formatted),
          turkish: tmpl['tr']!.replaceAll('{word}', formatted),
        );
      }
    }

    // 2. Morphological suffix patterns
    if (art == 'die' && (key.endsWith('ung') || key.endsWith('heit') || key.endsWith('keit'))) {
      return ExampleSentence(
        german: 'Die $formatted spielt für den Gesamterfolg eine entscheidende Rolle.',
        english: 'The $formatted plays a decisive role in the overall success.',
        arabic: 'تلعب الـ $formatted دوراً حاسماً في تحقيق النجاح الشامل.',
        turkish: '$formatted genel başarı için belirleyici bir rol oynamaktadır.',
      );
    }

    if (art == 'das' && (key.endsWith('chen') || key.endsWith('lein') || key.endsWith('ment'))) {
      return ExampleSentence(
        german: 'Das $formatted ist ein bemerkenswerter Bestandteil des Ganzen.',
        english: 'The $formatted is a noteworthy component of the whole.',
        arabic: 'يعتبر الـ $formatted عنصراً بارزاً وجزءاً مهماً من البناء المتكامل.',
        turkish: '$formatted bütünün kayda değer ve önemli bir parçasıdır.',
      );
    }

    // 3. Sensible universal language-learning fallback
    if (translation != null && translation.trim().length > 1) {
      final tr = translation.trim();
      return ExampleSentence(
        german: "Im Deutschkurs haben wir heute das Nomen '$art $formatted' gelernt.",
        english: "The German noun '$art $formatted' means '$tr' in English.",
        arabic: "الاسم الألماني '$art $formatted' يعني بالإنجليزية '$tr'.",
        turkish: "Almanca '$art $formatted' ismi İngilizcede '$tr' anlamına gelir.",
      );
    }

    switch (art) {
      case 'der':
        return ExampleSentence(
          german: "Im heutigen Deutschunterricht haben wir das Nomen 'der $formatted' geübt.",
          english: "In today's German class, we practiced the masculine noun 'der $formatted'.",
          arabic: "تدربنا اليوم في درس اللغة الألمانية على الاسم المذكر 'der $formatted'.",
          turkish: "Bugünkü Almanca dersinde eril 'der $formatted' ismini çalıştık.",
        );
      case 'die':
        return ExampleSentence(
          german: "Im heutigen Deutschunterricht haben wir das Nomen 'die $formatted' geübt.",
          english: "In today's German class, we practiced the feminine noun 'die $formatted'.",
          arabic: "تدربنا اليوم في درس اللغة الألمانية على الاسم المؤنث 'die $formatted'.",
          turkish: "Bugünkü Almanca dersinde dişil 'die $formatted' ismini çalıştık.",
        );
      case 'das':
      default:
        return ExampleSentence(
          german: "Im heutigen Deutschunterricht haben wir das Nomen 'das $formatted' geübt.",
          english: "In today's German class, we practiced the neuter noun 'das $formatted'.",
          arabic: "تدربنا اليوم في درس اللغة الألمانية على الاسم المحايد 'das $formatted'.",
          turkish: "Bugünkü Almanca dersinde nötr 'das $formatted' ismini çalıştık.",
        );
    }
  }
}
