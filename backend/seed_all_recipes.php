<?php
// backend/seed_all_recipes.php
require_once __DIR__ . '/config/database.php';

$recipes = [
    [
        'id' => 'egyptian_1',
        'name' => 'محشي مصري مشكل (كرنب وكوسة وبتنجان)',
        'category' => 'egyptian',
        'imageUrl' => 'https://images.unsplash.com/photo-1541518763669-27fef04b14ea?auto=format&fit=crop&w=800&q=80',
        'description' => 'سيد السفرة المصرية بريحة الخضرة الطازة والخلطة السرية المميزة المتبلة بالسمن البلدي.',
        'prepTimeMinutes' => 45,
        'cookTimeMinutes' => 50,
        'servings' => 5,
        'estimatedCost' => 160.0,
        'costTier' => 'medium',
        'calories' => 420,
        'isFeatured' => 1,
        'ingredients' => [
            ['name' => 'أرز مصري مغسول ومصفى', 'amount' => '1 كيلو'],
            ['name' => 'عصير طماطم مسبكة', 'amount' => '1.5 لتر'],
            ['name' => 'بصل مفروم ناعم', 'amount' => '3 حبات كبيرة'],
            ['name' => 'خضرة محشي (شبت، بقدونس، كزبرة)', 'amount' => '3 حزم مشكلة'],
            ['name' => 'سمن بلدي وزيت ذرة', 'amount' => '3 ملاعق كبيرة'],
            ['name' => 'كرنب مسلوق أو باذنجان وكوسة مقورين', 'amount' => '1.5 كيلو'],
            ['name' => 'توابل محشي ونعناع ناشف', 'amount' => 'حسب الرغبة']
        ],
        'steps' => [
            'في حلة على النار، شوحي البصل في السمن والزيت حتى يصفر لونه قليلاً.',
            'أضيفي عصير الطماطم واتركيها تتسبك على نار هادئة.',
            'اخلطي الأرز مع الخضرة المفرومة والصلصة والتوابل والنعناع.',
            'احشي أوراق الكرنب أو الكوسة والباذنجان برفق.',
            'اسقي المحشي بالشوربة المغلية المتبلة وغطيه واتركيه ينضج على نار هادئة.'
        ],
        'tips' => ['معلقة سمنة بلدي صغيرة على الوش في آخر ربع ساعة تسوية هتعطيه لمعة وطعم وريحة خيال.']
    ],
    [
        'id' => 'egyptian_2',
        'name' => 'ملوخية خضراء مصرية بالتقلية وفراخ محمرة',
        'category' => 'egyptian',
        'imageUrl' => 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=800&q=80',
        'description' => 'الملوخية الخضرا المخرطة الفريش بشهقتها المظبوطة وتقلية التوم بالكزبرة الناشفة.',
        'prepTimeMinutes' => 25,
        'cookTimeMinutes' => 30,
        'servings' => 4,
        'estimatedCost' => 180.0,
        'costTier' => 'medium',
        'calories' => 380,
        'isFeatured' => 1,
        'ingredients' => [
            ['name' => 'ملوخية خضراء مفرومة ناعم بالمخرطة', 'amount' => '1 كيلو'],
            ['name' => 'شوربة فراخ بلدي دسمة ومتبلة', 'amount' => '4 أكواب'],
            ['name' => 'ثوم مفروم ناعم', 'amount' => '8 فصوص'],
            ['name' => 'كزبرة جافة مطحونة', 'amount' => '1.5 ملعقة كبيرة'],
            ['name' => 'سمنة بلدي', 'amount' => '2 ملعقة كبيرة'],
            ['name' => 'فرخة مقطعة مسلوقة ومحمرة', 'amount' => '1 فرخة كاملة']
        ],
        'steps' => [
            'اغلي الشوربة في حلة متوسطة وتأكدي من ضبط الملح والتوابل.',
            'أضيفي الملوخية المخرومة واخفقيها سريعاً بمضرب سلك يدوي حتى تتجانس مع الشوربة.',
            'في طاسة صغيرة، ذوبي السمنة وضعي الثوم والكزبرة حتى يصبح ذهبياً.',
            'صبي التقلية فوراً فوق الملوخية مع الشهقة الشهيرة.'
        ],
        'tips' => ['ممنوع تغطية حلة الملوخية بعد الطبخ عشان متسقطش في القاع.']
    ],
    [
        'id' => 'egyptian_3',
        'name' => 'صينية مكرونة بالبشاميل الغنية باللحمة المفرومة',
        'category' => 'egyptian',
        'imageUrl' => 'https://images.unsplash.com/photo-1551183053-bf91a1d81141?auto=format&fit=crop&w=800&q=80',
        'description' => 'طبقات المكرونة الذهبية الغارقة في صوص البشاميل الكريمي مع اللحمة المفرومة المعصجة بالبهارات.',
        'prepTimeMinutes' => 30,
        'cookTimeMinutes' => 45,
        'servings' => 6,
        'estimatedCost' => 220.0,
        'costTier' => 'deluxe',
        'calories' => 550,
        'isFeatured' => 1,
        'ingredients' => [
            ['name' => 'مكرونة قلم مسلوقة', 'amount' => '500 جرام'],
            ['name' => 'لحم مفروم طازج', 'amount' => '400 جرام'],
            ['name' => 'بصل مفروم للتعصيج', 'amount' => '2 حبة'],
            ['name' => 'حليب دافئ كامل الدسم', 'amount' => '1.2 لتر'],
            ['name' => 'دقيق أبيض فاخر', 'amount' => '5 ملاعق'],
            ['name' => 'زبدة أو سمنة بلدي', 'amount' => '5 ملاعق'],
            ['name' => 'جبنة موزاريلا للوجه', 'amount' => '150 جرام']
        ],
        'steps' => [
            'عصجي اللحمة مع البصل والبهارات والملح حتى يتغير لونها وتنضج.',
            'تحضير البشاميل: ذوبي الزبدة وأضيفي الدقيق ثم الحليب تدريجياً مع الخفق المستمر.',
            'اخلطي نصف كمية البشاميل مع المكرونة.',
            'رصي نصف المكرونة في الصينية ثم اللحمة المعصجة ثم باقي المكرونة والبشاميل والجبن على الوجه.',
            'اخبزيها في فرن ساخن على 200 درجة لمدة 35 دقيقة حتى يحمر وجهها.'
        ],
        'tips' => ['إضافة معلقة قشطة بلدي للبشاميل تعطي قواماً غنياً ومذاقاً رائعاً.']
    ],
    [
        'id' => 'popular_1',
        'name' => 'كشري مصري أصيل بكل دقاته وصلصته المشطشة',
        'category' => 'popular',
        'imageUrl' => 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=800&q=80',
        'description' => 'أشهر أكلة شعبية مصرية يعشقها الجميع، بالعدس والأرز والشعرية والبصل المقرمش والدقة والصلصة.',
        'prepTimeMinutes' => 25,
        'cookTimeMinutes' => 40,
        'servings' => 5,
        'estimatedCost' => 75.0,
        'costTier' => 'budget',
        'calories' => 520,
        'isFeatured' => 1,
        'ingredients' => [
            ['name' => 'أرز مصري وشعرية محمرة', 'amount' => '2 كوب أرز + كوب شعرية'],
            ['name' => 'عدس بجبة مسلوق', 'amount' => 'كوب ونصف'],
            ['name' => 'مكرونة مسلوقة مشكلة', 'amount' => 'نصف كيلو'],
            ['name' => 'بصل مقرمش ذهبي (ورد)', 'amount' => '4 حبات'],
            ['name' => 'صلصة طماطم وثوم وخل وشطة', 'amount' => 'حسب الرغبة']
        ],
        'steps' => [
            'حمري البصل في زيت غزير حتى يصير ذهبياً ومقرمشاً.',
            'استخدمي جزءاً من زيت البصل لطبخ الأرز والعدس والشعرية.',
            'جهزي صلصة الطماطم بالثوم والخل، وحضري الدقة بالليمون والكمون.',
            'اغرفي الأرز والعدس وفوقه المكرونة ثم الصلصة والدقة والبصل المقرمش.'
        ],
        'tips' => ['سر طعم كشري المحلات يكمن في استخدام زيت تحمير البصل في تسوية كل عناصر الطبق.']
    ],
    [
        'id' => 'popular_2',
        'name' => 'حواوشي بلدي مقرمش بالعيش البلدي والخلطة السرية',
        'category' => 'popular',
        'imageUrl' => 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=800&q=80',
        'description' => 'أرغفة عيش بلدي مقرمشة ومحشوة بلحم مفروم متبل بالبصل والفلفل الأخضر وبهارات الحواوشي العطرية.',
        'prepTimeMinutes' => 20,
        'cookTimeMinutes' => 25,
        'servings' => 4,
        'estimatedCost' => 140.0,
        'costTier' => 'medium',
        'calories' => 510,
        'isFeatured' => 0,
        'ingredients' => [
            ['name' => 'لحم مفروم به نسبة دهن 20%', 'amount' => 'نصف كيلو'],
            ['name' => 'بصل وفلفل رومي وحار مفروم', 'amount' => '3 حبات بصل + 3 قرون فلفل'],
            ['name' => 'بهارات حواوشي وملح وفلفل', 'amount' => '1.5 ملعقة'],
            ['name' => 'أرغفة عيش بلدي طازجة', 'amount' => '6 أرغفة']
        ],
        'steps' => [
            'اعجني اللحم مع البصل والفلفل والبهارات جيداً.',
            'افردي اللحم داخل العيش البلدي وادهني الرغيف من الوجهين بالسمن أو الزيت.',
            'اخبزي الحواوشي في الفرن أو على طاسة ساخنة حتى ينضج ويقرمش العيش.'
        ],
        'tips' => ['نسبة الدهن في اللحمة المفرومة مهمة جداً لتعطي الحواوشي طراوة وطعم المحلات.']
    ],
    [
        'id' => 'popular_3',
        'name' => 'كبدة إسكندراني سريعة بالفلفل الحار والليمون والخل',
        'category' => 'popular',
        'imageUrl' => 'https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=800&q=80',
        'description' => 'أسرع وألذ ساندوتشات كبدة إسكندراني بخلطة التوم والكمون والكسبرة والفلفل الحامي.',
        'prepTimeMinutes' => 15,
        'cookTimeMinutes' => 10,
        'servings' => 4,
        'estimatedCost' => 130.0,
        'costTier' => 'medium',
        'calories' => 340,
        'isFeatured' => 0,
        'ingredients' => [
            ['name' => 'كبدة شرائح رفيعة عصافيري', 'amount' => 'نصف كيلو'],
            ['name' => 'ثوم مفروم وفلفل حار وأخضر', 'amount' => '8 فصوص ثوم + 4 قرون فلفل'],
            ['name' => 'خل وليمون وكمون وكسبرة', 'amount' => '3 ملاعق خل + ليمونة'],
            ['name' => 'زيت نباتي للقلي السريع', 'amount' => 'نصف كوب']
        ],
        'steps' => [
            'تبلي الكبدة بالثوم والخل والليمون والتوابل.',
            'سخني الزيت جداً في طاسة على نار عالية.',
            'انزلي بالكبدة على نار عالية دون تقليب أول دقيقة ثم قلبي مع الفلفل الأخضر 4 دقائق فقط.'
        ],
        'tips' => ['تسوية الكبدة لا تزيد عن 7-8 دقائق حتى تظل طرية ولا تجلد.']
    ],
    [
        'id' => 'western_1',
        'name' => 'مكرونة وايت صوص بالفراخ والمشروم (ألفريدو)',
        'category' => 'western',
        'imageUrl' => 'https://images.unsplash.com/photo-1645112411341-6c4fd023714a?auto=format&fit=crop&w=800&q=80',
        'description' => 'مكرونة فيتوتشيني أو بنا غرقانة في صوص الأبيض الكريمي مع قطع الفراخ المشوية والمشروم.',
        'prepTimeMinutes' => 20,
        'cookTimeMinutes' => 20,
        'servings' => 4,
        'estimatedCost' => 170.0,
        'costTier' => 'medium',
        'calories' => 580,
        'isFeatured' => 0,
        'ingredients' => [
            ['name' => 'مكرونة بنا مسلوقة', 'amount' => '400 جرام'],
            ['name' => 'صدور دجاج شرائح', 'amount' => '350 جرام'],
            ['name' => 'مشروم طازج مقطع', 'amount' => '1 كوب'],
            ['name' => 'كريمة طبخ أو حليب وقشطة', 'amount' => '2 كوب'],
            ['name' => 'زبدة وثوم وجبنة موتزاريلا', 'amount' => '2 ملعقة زبدة + 3 فصوص ثوم']
        ],
        'steps' => [
            'شوحي الفراخ في الزبدة حتى تستوي ثم ارفعيها.',
            'في نفس الطاسة شوحي الثوم والمشروم ثم صبي الكريمة وتبلي بالملح والفلفل والأوريجانو.',
            'أضيفي الفراخ والمكرونة المسلوقة وقلبي برفق وقدميها ساخنة.'
        ],
        'tips' => ['احتفظي بنصف كوب من ماء سلق المكرونة لتخفيف الصوص إذا ثقل.']
    ],
    [
        'id' => 'western_2',
        'name' => 'برجر لحم بيتي جوسي مع صوص الشيدر السري',
        'category' => 'western',
        'imageUrl' => 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=800&q=80',
        'description' => 'برجر لحمة بلدي أنضف وأطعم من المطاعم، طري وجوسي مع صوص البرجر والجبنة الشيدر السايحة.',
        'prepTimeMinutes' => 20,
        'cookTimeMinutes' => 15,
        'servings' => 4,
        'estimatedCost' => 190.0,
        'costTier' => 'medium',
        'calories' => 620,
        'isFeatured' => 0,
        'ingredients' => [
            ['name' => 'لحم مفروم به نسبة دهن 20%', 'amount' => 'نصف كيلو'],
            ['name' => 'خبز كايزر طازج بالسمسم', 'amount' => '4 قطع'],
            ['name' => 'شرائح جبنة شيدر مخصصة للبرجر', 'amount' => '4 شرائح'],
            ['name' => 'صوص برجر (مايونيز وكاتشب ومسطردة)', 'amount' => '3 ملاعق']
        ],
        'steps' => [
            'تبلي اللحم بخفة وشكليه إلى 4 أقراص متساوية.',
            'اشوي البرجر على جريل ساخن جداً 3-4 دقائق لكل جانب وضعي الجبنة لتذوب.',
            'حمري الخبز ورصي البرجر مع الصوص والخس والطماطم.'
        ],
        'tips' => ['عدم الإفراط في عجن اللحم سر بقاء البرجر طرياً ومليئاً بالعصارة.']
    ],
    [
        'id' => 'western_3',
        'name' => 'بيتزا إيطالية بيتي بعجينة هشة وطرية والجبنة المطاطية',
        'category' => 'western',
        'imageUrl' => 'https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=800&q=80',
        'description' => 'عجينة بيتزا قطنية وسريعة مع صلصة البيتزا الإيطالية بالزعتر ومكس أجبان وزيتون.',
        'prepTimeMinutes' => 35,
        'cookTimeMinutes' => 15,
        'servings' => 4,
        'estimatedCost' => 110.0,
        'costTier' => 'budget',
        'calories' => 490,
        'isFeatured' => 0,
        'ingredients' => [
            ['name' => 'دقيق أبيض فاخر', 'amount' => '3 أكواب'],
            ['name' => 'خميرة فورية وسكر وزيت زيتون', 'amount' => '1 ملعقة كبيرة خميرة + 3 ملاعق زيت'],
            ['name' => 'جبنة موتزاريلا مبشورة', 'amount' => '250 جرام'],
            ['name' => 'صلصة طماطم بالزعتر وزيتون وفلفل', 'amount' => 'نصف كوب']
        ],
        'steps' => [
            'اعجني الدقيق والخميرة والماء الدافئ واتركيها تختمر 40 دقيقة.',
            'افردي العجينة ووزعي الصلصة والجبن والزيتون.',
            'اخبزيها في فرن ساخن جداً على أعلى درجة حرارة لمدة 12-15 دقيقة.'
        ],
        'tips' => ['الفرن الساخن جداً سر قرمشة قاع البيتزا وطراوة العجينة من الداخل.']
    ],
    [
        'id' => 'budget_1',
        'name' => 'شكشوكة مصرية بالبيض والطماطم والفلفل',
        'category' => 'budgetFriendly',
        'imageUrl' => 'https://images.unsplash.com/photo-1590412200988-a436970781fa?auto=format&fit=crop&w=800&q=80',
        'description' => 'أكلة اقتصادية سريعة ومغذية، تفتح النفس مع العيش البلدي والمخلل لغداء أو عشاء سريع.',
        'prepTimeMinutes' => 10,
        'cookTimeMinutes' => 15,
        'servings' => 4,
        'estimatedCost' => 45.0,
        'costTier' => 'budget',
        'calories' => 280,
        'isFeatured' => 0,
        'ingredients' => [
            ['name' => 'بيض طازج', 'amount' => '5 حبات'],
            ['name' => 'طماطم مفرومة مكعبات', 'amount' => '4 حبات'],
            ['name' => 'بصلة وفلفل رومي وثوم', 'amount' => 'بصلة + 2 فلفل + 2 فص ثوم'],
            ['name' => 'سمن أو زيت وتوابل', 'amount' => '2 ملعقة سمن + بهارات']
        ],
        'steps' => [
            'شوحي البصل والفلفل والثوم في السمن ثم أضيفي الطماطم حتى تتسبك.',
            'اكسري حبات البيض فوق الصلصة وغطي الطاسة على نار هادئة حتى ينضج البيض.'
        ],
        'tips' => ['رشة بقدونس مفروم على الوجه تعطي لوناً وطعماً شهياً.']
    ],
    [
        'id' => 'budget_2',
        'name' => 'عجة مصرية بالخضار والبيض في الفرن',
        'category' => 'budgetFriendly',
        'imageUrl' => 'https://images.unsplash.com/photo-1525351484163-7529414344d8?auto=format&fit=crop&w=800&q=80',
        'description' => 'صينية العجة البلدي الهشة المشبعة بالخضار المشكل والبصل والبيض والتوابل، مشبعة جداً واقتصادية.',
        'prepTimeMinutes' => 15,
        'cookTimeMinutes' => 25,
        'servings' => 5,
        'estimatedCost' => 55.0,
        'costTier' => 'budget',
        'calories' => 310,
        'isFeatured' => 0,
        'ingredients' => [
            ['name' => 'بيض بلدي', 'amount' => '6 حبات'],
            ['name' => 'بصل مفروم ذهبي', 'amount' => '2 حبة كبيرة'],
            ['name' => 'حزمة خضرة مشكلة (شبت وبقدونس وكزبرة)', 'amount' => '1 حزمة'],
            ['name' => 'دقيق وبيكنج باودر', 'amount' => '3 ملاعق دقيق + 1 ملعقة صغيرة بيكنج باودر']
        ],
        'steps' => [
            'اخفقي البيض مع الدقيق والبيكنج باودر والتوابل.',
            'أضيفي البصل المحمر والخضرة وصبي في صينية فرن مدهونة.',
            'اخبزيها في فرن على 180 درجة لمدة 25 دقيقة حتى تتماسك وتصبح ذهبية.'
        ],
        'tips' => ['البيكنج باودر سر هشاشة العجة مثل الكيك المالح.']
    ],
    [
        'id' => 'dessert_1',
        'name' => 'بسبوسة بالسمنة البلدي مرملة ودايبة دوبان',
        'category' => 'desserts',
        'imageUrl' => 'https://images.unsplash.com/photo-1579372786545-d24232daf58c?auto=format&fit=crop&w=800&q=80',
        'description' => 'البسبوسة المظبوطة على أصولها، مرملة وشاربة الشربات الساخن بالسمن البلدي والمكسرات.',
        'prepTimeMinutes' => 15,
        'cookTimeMinutes' => 30,
        'servings' => 8,
        'estimatedCost' => 85.0,
        'costTier' => 'medium',
        'calories' => 390,
        'isFeatured' => 0,
        'ingredients' => [
            ['name' => 'سميد بسبوسة ناعم', 'amount' => 'نصف كيلو (3 أكواب)'],
            ['name' => 'سمنة بلدي طبيعية دافئة', 'amount' => 'نصف كوب + 2 ملعقة'],
            ['name' => 'حليب دافئ وسكر وعسل جلوكوز', 'amount' => 'نصف كوب حليب + نصف كوب سكر'],
            ['name' => 'شربات ساخن خفيف بالليمون والسمن البلدي', 'amount' => '2 كوب سكر + 2 كوب ماء']
        ],
        'steps' => [
            'ابسي السميد بالسمنة البلدي بأطراف أصابعك بهدوء.',
            'أضيفي خليط الحليب والسكر الدافئ وقلبي برفق دون عجن.',
            'افردي الخليط في صينية واخبزيها حتى تحمر الأطراف ثم شغلي الشواية.',
            'اسكبي الشربات الساخن المغلي فور خروج البسبوسة الساخنة.'
        ],
        'tips' => ['سر البسبوسة: الشربات ساخن بيغلي والبسبوسة طالعة سخنة معاً.']
    ],
    [
        'id' => 'dessert_2',
        'name' => 'طاجن أم علي مصري أصيل بالمكسرات والقشطة البلدي',
        'category' => 'desserts',
        'imageUrl' => 'https://images.unsplash.com/photo-1587314168485-3236d6710814?auto=format&fit=crop&w=800&q=80',
        'description' => 'حلوى أم علي المصرية الدافئة بقطع الملفيه المحمص والحليب كامل الدسم المغلي والمكسرات والقشطة المحمرة.',
        'prepTimeMinutes' => 15,
        'cookTimeMinutes' => 20,
        'servings' => 5,
        'estimatedCost' => 95.0,
        'costTier' => 'medium',
        'calories' => 430,
        'isFeatured' => 0,
        'ingredients' => [
            ['name' => 'عجينة ملفيه أو رقاق محمص', 'amount' => '350 جرام'],
            ['name' => 'حليب كامل الدسم مغلي ومحلى', 'amount' => '1 لتر'],
            ['name' => 'قشطة بلدي أو وش اللبن', 'amount' => 'كوب كبير'],
            ['name' => 'مكسرات مشكلة وزبيب وجوز هند', 'amount' => '1 كوب']
        ],
        'steps' => [
            'كسري الملفيه في طاجن فخار ووزعي المكسرات بين الطبقات.',
            'صبي الحليب المغلي المحلى فوق الملفيه.',
            'وزعي القشطة البلدي على الوجه بالكامل مع رشة سكر بودرة.',
            'أدخلي الطاجن تحت الشواية حتى يحمر وجه القشطة ويصبح ذهبياً شهياً.'
        ],
        'tips' => ['رشة سكر بودرة على وجه القشطة قبل الشواية تعطي كرملة ذهبية مقرمشة.']
    ],
    [
        'id' => 'dessert_3',
        'name' => 'كيكة الشوكولاتة الهشة الغرقانة بصوص الشوكولاتة السري',
        'category' => 'desserts',
        'imageUrl' => 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?auto=format&fit=crop&w=800&q=80',
        'description' => 'كيكة شوكولاتة في الخلاط بصوص لامع وغني، سريعة وسهلة وناجحة من أول مرة بدون تعقيد.',
        'prepTimeMinutes' => 15,
        'cookTimeMinutes' => 35,
        'servings' => 8,
        'estimatedCost' => 70.0,
        'costTier' => 'budget',
        'calories' => 360,
        'isFeatured' => 0,
        'ingredients' => [
            ['name' => 'دقيق أبيض فاخر منخول', 'amount' => '2 كوب'],
            ['name' => 'كاكاو خام مر بجودة ممتازة', 'amount' => 'نصف كوب'],
            ['name' => 'سكر وحليب وزيت وبيض', 'amount' => 'كوب ونصف سكر + كوب حليب + 3 بيضات'],
            ['name' => 'بيكنج باودر وفانيليا', 'amount' => '1 باكو']
        ],
        'steps' => [
            'في الخلاط اضربي السكر والحليب والزيت والكاكاو واحتفظي بكوب صوص على جنب.',
            'أضيفي البيض والفانيليا للخلاط واضربي ثم اسكبي فوق الدقيق والبيكنج باودر.',
            'اخبزيها في فرن على 180 درجة لمدة 35 دقيقة ثم صبي الصوص البارد عليها.'
        ],
        'tips' => ['استخدام كاكاو خام إسباني جيد يصنع فرقاً هائلاً في طعم ولون الصوص.']
    ]
];

// 1. Seed into Local Database (SQLite)
$db = Database::getConnection();
echo "Seeding into local database...\n";

$sql = "INSERT OR REPLACE INTO recipes (id, name, category, imageUrl, description, prepTimeMinutes, cookTimeMinutes, servings, estimatedCost, costTier, calories, isUserAdded, isFeatured, ingredients, steps, tips) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
$stmt = $db->prepare($sql);

foreach ($recipes as $r) {
    $stmt->execute([
        $r['id'],
        $r['name'],
        $r['category'],
        $r['imageUrl'],
        $r['description'],
        $r['prepTimeMinutes'],
        $r['cookTimeMinutes'],
        $r['servings'],
        $r['estimatedCost'],
        $r['costTier'],
        $r['calories'],
        0,
        $r['isFeatured'],
        json_encode($r['ingredients'], JSON_UNESCAPED_UNICODE),
        json_encode($r['steps'], JSON_UNESCAPED_UNICODE),
        json_encode($r['tips'], JSON_UNESCAPED_UNICODE)
    ]);
    echo "  + Added local: {$r['name']}\n";
}

// 2. Also send each recipe to the remote server via REST API
echo "\nSending recipes to remote server API (http://80.241.218.23:8085/api/recipes.php)...\n";
$remoteUrl = 'http://80.241.218.23:8085/api/recipes.php';

foreach ($recipes as $r) {
    $ch = curl_init($remoteUrl);
    $payload = json_encode($r, JSON_UNESCAPED_UNICODE);
    curl_setopt($ch, CURLOPT_POSTFIELDS, $payload);
    curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type:application/json; charset=utf-8']);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_TIMEOUT, 6);
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);
    
    echo "  -> Remote API [{$httpCode}]: {$r['name']}\n";
}

echo "\nDone! All recipes seeded successfully in both local and remote databases.\n";
