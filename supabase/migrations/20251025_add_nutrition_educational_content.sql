-- =====================================================================================
-- COMPREHENSIVE NUTRITION EDUCATIONAL CONTENT
-- PhD-Level Longevity & Healthspan Optimization
-- =====================================================================================
-- This migration adds evidence-based educational content for all 11 nutrition components
-- Content focuses on longevity research, Blue Zone populations, and disease prevention
-- =====================================================================================

-- =====================================================================================
-- 1. VEGETABLES
-- =====================================================================================
UPDATE display_metrics
SET
    about_content = 'Vegetables represent the cornerstone of longevity-promoting dietary patterns, providing concentrated sources of phytonutrients, vitamins, minerals, and fiber with minimal caloric density. The bioactive compounds in vegetables—including carotenoids, flavonoids, glucosinolates, and polyphenols—exert powerful anti-inflammatory and antioxidant effects that protect against cellular damage and chronic disease. Dark leafy greens like spinach and kale are rich in folate, vitamin K, and lutein, supporting cardiovascular health and cognitive function. Cruciferous vegetables (broccoli, cauliflower, Brussels sprouts) contain sulforaphane, which activates cellular detoxification pathways and has demonstrated anti-cancer properties. Colorful vegetables provide diverse antioxidants: beta-carotene in orange vegetables supports immune function, lycopene in tomatoes protects cardiovascular health, and anthocyanins in purple vegetables enhance brain health. The fiber content supports gut microbiome diversity, which is increasingly recognized as central to systemic health and longevity. Optimal intake appears to be 5-9 servings daily, with emphasis on variety to capture the full spectrum of protective compounds.',
    longevity_impact = 'Vegetable consumption shows one of the strongest dose-response relationships with longevity in epidemiological research. The EPIC study of over 450,000 Europeans found each additional 200g daily serving of vegetables reduced all-cause mortality by 6%. The Nurses'' Health Study demonstrated that women consuming 8+ servings daily had 30% lower cardiovascular mortality compared to those eating fewer than 3 servings. Blue Zone populations in Okinawa, Sardinia, and Ikaria consume 5-10 servings daily, emphasizing leafy greens and local varieties. Cruciferous vegetable intake specifically correlates with reduced cancer incidence across multiple studies, with the Iowa Women''s Health Study showing 33% reduction in ovarian cancer risk. The antioxidant and anti-inflammatory properties of vegetable phytonutrients protect against age-related diseases including dementia, with the Rush Memory and Aging Project finding that high vegetable consumers had cognitive aging delayed by 11 years.',
    quick_tips = jsonb_build_array(
        'Aim for 7-9 servings daily with at least 3 different colors to maximize phytonutrient diversity',
        'Include cruciferous vegetables (broccoli, cauliflower, cabbage) 4-5 times weekly for cancer-protective compounds',
        'Eat dark leafy greens daily—one large salad provides multiple servings and supports brain health',
        'Lightly steam or sauté rather than boiling to preserve heat-sensitive nutrients like vitamin C and folate',
        'Add healthy fats (olive oil, nuts) when eating vegetables to enhance absorption of fat-soluble vitamins A, E, K',
        'Choose local, seasonal, and organic when possible to maximize nutrient density and minimize pesticide exposure',
        'Include both raw and cooked vegetables—cooking enhances bioavailability of some nutrients (lycopene, beta-carotene) while preserving others raw (vitamin C, enzymes)'
    )
WHERE metric_name = 'vegetable_servings';

-- =====================================================================================
-- 2. FRUITS
-- =====================================================================================
UPDATE display_metrics
SET
    about_content = 'Fruits provide a unique combination of simple sugars, fiber, vitamins, minerals, and thousands of bioactive phytonutrients that support longevity and metabolic health. Unlike refined sugars, the fructose in whole fruits is packaged with fiber that moderates absorption and prevents blood sugar spikes, while polyphenols and antioxidants provide protective benefits that far outweigh concerns about sugar content. Berries stand out for exceptional antioxidant density, with compounds like anthocyanins and ellagic acid that cross the blood-brain barrier to protect cognitive function. Citrus fruits provide vitamin C and hesperidin for cardiovascular protection, while apples contain quercetin and pectin that support gut health and cholesterol metabolism. Stone fruits offer vitamin A and potassium, tropical fruits provide unique enzymes and anti-inflammatory compounds, and pomegranates contain punicalagins with remarkable cellular protection properties. The fiber in fruits feeds beneficial gut bacteria, producing short-chain fatty acids that reduce inflammation and support immune function. Optimal intake appears to be 3-5 servings daily, emphasizing whole fruits over juices to maintain the protective fiber matrix.',
    longevity_impact = 'Large-scale prospective studies consistently demonstrate fruit consumption''s protective effects against age-related mortality and disease. The Harvard cohort studies following over 100,000 participants for decades found each daily fruit serving reduced cardiovascular mortality by 4% and stroke risk by 5%. Blue Zone populations consume 2-4 servings daily, with Adventist Health Study participants eating the most fruit showing 10% lower all-cause mortality. The specific benefits of berries are striking: the Nurses'' Health Study found women consuming 3+ servings of blueberries and strawberries weekly had 32% reduced heart attack risk. For cognitive aging, the Rush Memory and Aging Project showed higher berry consumption slowed cognitive decline by up to 2.5 years. Fruit''s anti-inflammatory effects appear crucial—the Framingham Heart Study linked higher fruit intake with lower inflammatory markers (CRP, IL-6) that predict longevity. The key is whole fruit: fruit juice consumption lacks these benefits and may increase diabetes risk.',
    quick_tips = jsonb_build_array(
        'Consume 3-5 servings daily, prioritizing berries (blueberries, strawberries, raspberries) for brain health 3-4 times weekly',
        'Eat whole fruits rather than drinking juice to maintain fiber content and prevent blood sugar spikes',
        'Include citrus fruits regularly for vitamin C and flavonoids that protect cardiovascular health',
        'Choose deeply colored fruits (berries, cherries, pomegranates) for highest antioxidant and polyphenol content',
        'Time fruit consumption with meals or as pre-exercise fuel to optimize blood sugar response',
        'Freeze berries when in season for year-round availability—freezing preserves most antioxidant content',
        'Pair fruits with protein or healthy fats (apple with almond butter, berries with yogurt) to further stabilize blood sugar'
    )
WHERE metric_name = 'fruit_servings';

-- =====================================================================================
-- 3. LEGUMES
-- =====================================================================================
UPDATE display_metrics
SET
    about_content = 'Legumes—including beans, lentils, chickpeas, and peas—represent one of the most nutrient-dense and longevity-promoting food categories, combining high-quality plant protein, complex carbohydrates, fiber, resistant starch, and diverse micronutrients. This unique nutritional profile provides sustained energy without blood sugar spikes while feeding beneficial gut bacteria. Legumes are exceptional sources of folate, magnesium, potassium, iron, and zinc, minerals frequently deficient in modern diets. Their high soluble fiber content (15-19g per cup cooked) binds cholesterol and bile acids, reducing cardiovascular disease risk. Resistant starch in legumes survives digestion to reach the colon, where it ferments to produce butyrate and other short-chain fatty acids that reduce inflammation, support immune function, and may protect against colon cancer. The protein quality of legumes, while incomplete individually, provides all essential amino acids when combined with whole grains. Phytonutrients including saponins, phytosterols, and phenolic compounds exert antioxidant and anti-cancer effects. Regular consumption (1 cup daily) consistently associates with reduced body weight, improved glycemic control, and lower chronic disease risk.',
    longevity_impact = 'Legume consumption represents a defining dietary characteristic of the world''s longest-lived populations and shows powerful longevity benefits in research. Dan Buettner''s Blue Zones research identified legumes as the cornerstone food across all five longevity hotspots, with centenarians consuming approximately 1 cup daily. The Adventist Health Study-2 following 96,000 participants found those eating legumes 3+ times weekly had 9-13% lower all-cause mortality. For cardiovascular health specifically, a meta-analysis of 26 randomized trials showed legume consumption reduced LDL cholesterol by 5-6%, translating to approximately 5-6% reduced heart disease risk. The PREDIMED trial demonstrated participants eating legumes 3+ servings weekly had 49% reduced diabetes risk. Legumes'' resistant starch and fiber promote gut microbiome diversity, which correlates strongly with healthy aging. The Nurses'' Health Study found women with highest legume intake had 22% lower coronary heart disease risk. Replacing animal protein with plant protein from legumes associates with reduced mortality and lower biological aging markers.',
    quick_tips = jsonb_build_array(
        'Consume at least 3-4 servings (½ cup cooked = 1 serving) weekly, with Blue Zone populations eating up to 1 cup daily',
        'Soak dried beans 8-24 hours and discard soaking water to reduce phytates and improve mineral absorption',
        'Add beans to soups, salads, and grain bowls for an easy protein and fiber boost',
        'Include variety: black beans, lentils, chickpeas, kidney beans each provide unique phytonutrient profiles',
        'Combine with whole grains (beans and rice, lentils and bulgur) to create complete protein with all essential amino acids',
        'Use canned beans for convenience—rinse thoroughly to reduce sodium by 40%',
        'If experiencing gas, start with smaller portions and increase gradually as gut bacteria adapt, or choose more digestible options like lentils and split peas'
    )
WHERE metric_name = 'legume_servings';

-- =====================================================================================
-- 4. WHOLE GRAINS
-- =====================================================================================
UPDATE display_metrics
SET
    about_content = 'Whole grains retain all three components of the grain kernel—bran, germ, and endosperm—providing a complete package of complex carbohydrates, fiber, B vitamins, minerals, and phytonutrients that are stripped away in refined grain processing. This structural integrity delivers sustained energy release, blood sugar stability, and numerous health-promoting compounds. The bran layer provides insoluble fiber that promotes digestive health and soluble fiber (beta-glucan in oats and barley) that lowers cholesterol. The germ contains vitamin E, healthy fats, and minerals including magnesium, selenium, and zinc. Whole grains provide significant B vitamins (thiamin, riboflavin, niacin, folate) essential for energy metabolism and nervous system function. Phytonutrients including lignans, phenolic acids, and phytic acid (when properly prepared) exert antioxidant and anti-inflammatory effects. Different whole grains offer distinct benefits: oats for cholesterol reduction, quinoa for complete protein, barley for blood sugar control, and fermented grains for enhanced nutrient bioavailability. The recommended intake is 3+ servings daily (1 serving = ½ cup cooked or 1 slice bread), with emphasis on variety and minimally processed forms.',
    longevity_impact = 'Whole grain consumption demonstrates robust associations with reduced mortality and extended healthspan across multiple large-scale studies. A meta-analysis of 45 prospective cohort studies including over 700,000 participants found each daily serving of whole grains reduced all-cause mortality by 5%, cardiovascular mortality by 9%, and cancer mortality by 3%. The Nurses'' Health Study and Health Professionals Follow-up Study tracking over 100,000 participants for decades showed those consuming 3+ daily servings had 20% lower mortality compared to minimal consumers. The Iowa Women''s Health Study found whole grain intake inversely associated with death from all causes, particularly cardiovascular disease and diabetes. Blue Zone populations consume whole grains daily: Okinawans eat purple sweet potatoes and brown rice, Sardinians eat whole grain sourdough bread, and Adventists favor oatmeal and whole wheat. The fiber and magnesium in whole grains support healthy blood pressure, while their anti-inflammatory properties reduce chronic disease risk. Substituting whole grains for refined grains shows significant benefits—just 50g daily whole grain intake associates with 7% reduced type 2 diabetes risk.',
    quick_tips = jsonb_build_array(
        'Aim for 3-5 servings daily, replacing refined grains entirely for maximum benefit',
        'Choose intact whole grains (steel-cut oats, brown rice, quinoa, barley) over whole grain flour products when possible',
        'Start your day with whole grain breakfast—oatmeal with berries and nuts provides sustained energy and supports heart health',
        'Look for "100% whole grain" or "100% whole wheat" as first ingredient, not just "multigrain" or "wheat"',
        'Experiment with ancient grains (farro, spelt, kamut, freekeh) for greater nutrient diversity',
        'Cook grains in batches and refrigerate—cooling creates resistant starch that improves blood sugar response when reheated',
        'Soak or ferment grains before cooking to reduce phytates and improve mineral bioavailability, especially for those with digestive sensitivity'
    )
WHERE metric_name = 'whole_grain_servings';

-- =====================================================================================
-- 5. HEALTHY FATS
-- =====================================================================================
UPDATE display_metrics
SET
    about_content = 'Healthy fats—predominantly monounsaturated and omega-3 polyunsaturated fats—are essential for cellular membrane integrity, hormone production, nutrient absorption, and brain function, while also providing powerful anti-inflammatory and cardioprotective effects. Monounsaturated fats from olive oil, avocados, and nuts improve cholesterol profiles by raising HDL while lowering LDL and reducing oxidation. Omega-3 fatty acids (EPA and DHA from fish, ALA from plants) are anti-inflammatory powerhouses that reduce triglycerides, stabilize heart rhythm, improve endothelial function, and support brain health throughout the lifespan. Extra virgin olive oil contains not just oleic acid but over 30 phenolic compounds including oleocanthal (similar anti-inflammatory effects to ibuprofen) and hydroxytyrosol (potent antioxidant). Nuts and seeds provide vitamin E, magnesium, fiber, and plant sterols alongside healthy fats. Fatty fish delivers EPA/DHA plus vitamin D and selenium. The key is replacing saturated and trans fats rather than adding fat calories—Mediterranean populations derive 35-40% of calories from fat, primarily olive oil, yet have exceptional longevity. Quality matters tremendously: oxidized, heated, or processed fats become inflammatory rather than protective.',
    longevity_impact = 'The health effects of fat type, rather than total fat intake, represent one of nutrition science''s most well-established findings for longevity. The PREDIMED trial, a landmark study of nearly 7,500 Spanish adults, found those assigned to Mediterranean diet supplemented with extra virgin olive oil or nuts had 31% reduced cardiovascular events and 30% lower mortality over 5 years compared to low-fat diet. The Nurses'' Health Study and Health Professionals Follow-up Study following over 126,000 participants for 32 years showed replacing 5% of calories from saturated fat with polyunsaturated fat reduced mortality by 27%. For omega-3s specifically, the Framingham Heart Study found higher blood EPA and DHA levels associated with 2.2 years increased lifespan. Blue Zone populations share high intake of omega-3s: Okinawans eat fish regularly, Adventists eat nuts daily, Ikarians use olive oil liberally. Brain health benefits are substantial—the Rush Memory and Aging Project found higher MUFA intake associated with 36% reduced cognitive decline. The Women''s Health Study showed women with highest blood omega-3 levels aged more slowly at the cellular level with longer telomeres.',
    quick_tips = jsonb_build_array(
        'Use extra virgin olive oil as primary cooking and dressing fat—aim for 2-4 tablespoons daily as in Mediterranean diet',
        'Eat fatty fish (salmon, sardines, mackerel, anchovies) 2-3 times weekly for EPA and DHA omega-3s',
        'Include 1-2 ounces of nuts or seeds daily—almonds, walnuts, and flaxseeds provide complementary nutrient profiles',
        'Add half an avocado 4-5 times weekly for monounsaturated fats, fiber, and potassium',
        'Choose "extra virgin" olive oil in dark bottles, store away from heat and light, and use within 6 months of opening',
        'If vegetarian, consume ALA-rich foods (flaxseeds, chia seeds, walnuts) plus consider algae-based EPA/DHA supplement',
        'Avoid or strictly limit trans fats (partially hydrogenated oils) and minimize saturated fats from processed meats and fried foods'
    )
WHERE metric_name = 'healthy_fat_servings';

-- =====================================================================================
-- 6. FIBER
-- =====================================================================================
UPDATE display_metrics
SET
    about_content = 'Dietary fiber encompasses diverse plant carbohydrates and lignin that resist digestion in the small intestine, instead traveling to the colon where they profoundly influence gut microbiome composition, immune function, metabolic health, and disease risk. Soluble fiber (in oats, beans, apples, citrus) dissolves in water to form gel-like substances that slow digestion, stabilize blood sugar, bind cholesterol, and feed beneficial bacteria. Insoluble fiber (in wheat bran, vegetables, whole grains) adds bulk to stool and promotes regular bowel movements, reducing constipation and diverticular disease risk. The gut microbiome ferments fiber into short-chain fatty acids—particularly butyrate, propionate, and acetate—that reduce inflammation, strengthen the intestinal barrier, regulate appetite hormones, and may protect against colon cancer. Different fiber types support distinct bacterial populations, making dietary diversity crucial. Fiber slows gastric emptying and nutrient absorption, improving satiety and glycemic control. Most Americans consume only 15g daily versus the recommended 25-38g, contributing to epidemic rates of chronic disease. Whole food sources provide fiber with vitamins, minerals, and phytonutrients in optimal combinations for absorption and utilization.',
    longevity_impact = 'Fiber intake shows one of the strongest protective associations with mortality and age-related disease across multiple studies and populations. A meta-analysis of 185 prospective studies and 58 clinical trials found each 8g daily increase in dietary fiber reduced all-cause mortality by 5-27% depending on fiber type, with greatest benefits for cereal fiber and whole grains. The Nurses'' Health Study following over 74,000 women for 26 years found those in the highest fiber intake quintile (median 26g daily) had 22% lower mortality than lowest quintile (median 12g daily). The NIH-AARP Diet and Health Study of over 388,000 participants showed strong inverse associations between fiber intake and death from cardiovascular, infectious, and respiratory diseases. For specific conditions, each 10g daily fiber increase reduces coronary heart disease risk by 14%, stroke by 9%, and type 2 diabetes by 6%. Blue Zone populations consume 50-100g fiber daily from vegetables, fruits, beans, and whole grains. The gut microbiome benefits appear central—individuals with higher fiber intake show greater bacterial diversity, which predicts healthy aging and longevity across populations.',
    quick_tips = jsonb_build_array(
        'Target 35-50g daily from whole food sources—emphasize variety for diverse gut bacteria support',
        'Start each day with high-fiber breakfast: oatmeal (4g) with berries (4g) and ground flaxseed (3g) = 11g',
        'Include beans or lentils in one meal daily for easy 15g fiber boost plus protein and minerals',
        'Eat vegetables at every meal, including breakfast—add spinach to eggs or smoothies',
        'Choose whole fruits over juice and eat the skin when appropriate (apples, pears, potatoes)',
        'Snack on nuts, seeds, and fresh vegetables—carrots, celery, and hummus provide fiber plus healthy fats',
        'Increase intake gradually over 2-3 weeks while drinking plenty of water to avoid digestive discomfort as gut bacteria adapt'
    )
WHERE metric_name = 'fiber_grams';

-- =====================================================================================
-- 7. HYDRATION
-- =====================================================================================
UPDATE display_metrics
SET
    about_content = 'Optimal hydration is fundamental to virtually every physiological process, yet its importance for healthspan and longevity is often underappreciated. Water comprises 55-60% of adult body weight and serves as the medium for all biochemical reactions, nutrient transport, waste removal, temperature regulation, joint lubrication, and cellular signaling. Even mild dehydration (1-2% body weight loss) impairs cognitive performance, physical endurance, mood, and cardiovascular function. Chronic suboptimal hydration accelerates cellular aging through multiple mechanisms: concentrating toxins and metabolic waste products, reducing kidney function, increasing oxidative stress, impairing nutrient delivery, and triggering vasopressin release that may promote inflammation and metabolic dysfunction. Adequate hydration supports the glymphatic system that clears metabolic waste from the brain during sleep, potentially reducing neurodegenerative disease risk. Kidney function, crucial for longevity, depends critically on sufficient fluid intake to filter blood and excrete waste. Individual needs vary based on body size, activity level, climate, and diet composition (higher sodium and protein increase requirements), but general targets are 2.7-3.7 liters daily for adults. Water sources include beverages and water-rich foods (fruits, vegetables, soups).',
    longevity_impact = 'Emerging research suggests chronic inadequate hydration may accelerate biological aging and reduce lifespan. A National Institutes of Health study of over 11,000 adults followed for 25 years found those with serum sodium in the upper-normal range (indicating lower hydration) had 39% increased risk of developing chronic diseases and 21% increased risk of premature death compared to optimally hydrated individuals. The same cohort showed higher sodium levels associated with biological aging markers including increased left ventricular mass and arterial stiffness. For kidney health specifically, the Adventist Health Study found individuals drinking 5+ glasses of water daily had 38% reduced fatal coronary heart disease risk compared to those drinking 2 or fewer glasses, with proposed mechanisms including blood viscosity and thrombosis reduction. Hydration status affects healthspan through multiple pathways: the Framingham Heart Study linked better hydration with lower cardiovascular disease risk, while cognitive studies show even mild dehydration impairs executive function and increases perceived task difficulty. Blue Zone populations universally emphasize water and herbal teas, avoiding sugary beverages that provide hydration but contribute to metabolic disease.',
    quick_tips = jsonb_build_array(
        'Target at least 8-10 cups (64-80oz) daily for women, 10-12 cups (80-96oz) for men, adjusting for activity and climate',
        'Start each morning with 16oz water to rehydrate after overnight fluid loss and support the glymphatic system',
        'Drink water before meals to support satiety and optimize digestion—30 minutes before is ideal',
        'Monitor urine color—pale yellow indicates good hydration, dark yellow suggests need for more fluid',
        'Increase intake during exercise (add 12-16oz per hour of moderate activity) and hot weather',
        'Eat water-rich foods (cucumber, watermelon, tomatoes, lettuce, soup) which contribute to hydration plus nutrients',
        'Limit diuretics like caffeine and alcohol, or increase water intake to compensate—add one extra glass of water per caffeinated or alcoholic beverage'
    )
WHERE metric_name = 'water_intake_ounces';

-- =====================================================================================
-- 8. PROTEIN
-- =====================================================================================
UPDATE display_metrics
SET
    about_content = 'Protein serves as the fundamental building block for all body tissues, enzymes, hormones, immune factors, and cellular machinery, making adequate intake essential for maintaining muscle mass, bone density, immune function, and metabolic health throughout the lifespan. Composed of 20 amino acids (9 essential from diet), protein requirements increase with age due to "anabolic resistance"—reduced muscle protein synthesis in response to dietary protein. Current evidence suggests older adults (50+) benefit from 1.2-1.6 g/kg body weight daily, significantly higher than the minimal RDA of 0.8 g/kg, distributed across meals to optimize muscle protein synthesis (25-40g per meal). Protein quality varies significantly: animal sources provide complete essential amino acid profiles and high bioavailability, while plant proteins often require combination for completeness but offer fiber and phytonutrients absent in animal foods. Leucine, found abundantly in animal proteins and legumes, particularly triggers muscle protein synthesis. Beyond muscle, adequate protein supports bone matrix, wound healing, neurotransmitter production, and satiety. Source matters for longevity: plant and fish proteins associate with reduced mortality, while high red meat intake (especially processed) increases disease risk.',
    longevity_impact = 'The protein-longevity relationship is complex and source-dependent, with profound implications for healthspan. The Nurses'' Health Study and Health Professionals Follow-up Study following over 131,000 participants for 32 years found replacing 3% of calories from animal protein with plant protein reduced mortality by 10%. However, protein adequacy becomes increasingly critical with age—the Health ABC Study found older adults (70-79) with highest protein intake (1.2+ g/kg) had 30% reduced frailty risk compared to lowest intake. Sarcopenia (muscle loss) affects 30% of adults over 60 and 50% over 80, strongly predicting mortality, disability, and loss of independence. The Rotterdam Study showed each 25g daily increase in plant protein reduced frailty by 9%. For protein sources, fish intake consistently associates with longevity: the Nurses'' Health Study found women eating fish 5+ times weekly had 36% reduced Alzheimer''s risk. Conversely, high red meat consumption (especially processed) increases mortality—the NIH-AARP study of 500,000 participants found those in highest quintile had 26% increased mortality. Blue Zone populations consume moderate protein (10-20% of calories) primarily from plants, beans, nuts, and fish, with minimal meat.',
    quick_tips = jsonb_build_array(
        'Aim for 1.2-1.6 g/kg body weight daily if over 50, distributed across meals (25-40g per meal for optimal muscle synthesis)',
        'Prioritize plant and fish proteins—beans, lentils, nuts, tofu, tempeh, salmon, sardines—over red meat',
        'Include 20-30g protein at breakfast to activate muscle protein synthesis and improve satiety throughout the day',
        'Combine plant proteins for complete amino acid profiles: beans + rice, hummus + pita, peanut butter + whole grain bread',
        'Time protein intake around resistance exercise—consume 20-40g within 2 hours post-workout for maximum muscle building',
        'Choose high-quality animal proteins when consumed: wild-caught fish, pasture-raised poultry, eggs, and Greek yogurt',
        'If plant-based, emphasize leucine-rich sources (soy, lentils, chickpeas, pumpkin seeds) and consider supplementing with essential amino acids'
    )
WHERE metric_name = 'protein_grams';

-- =====================================================================================
-- 9. ADDED SUGAR
-- =====================================================================================
UPDATE display_metrics
SET
    about_content = 'Added sugars—including table sugar, high-fructose corn syrup, honey, and other caloric sweeteners added during processing or preparation—represent one of the most detrimental dietary components for metabolic health and longevity. Unlike naturally occurring sugars in whole fruits and dairy that come packaged with fiber, protein, vitamins, and minerals, added sugars provide empty calories that trigger rapid blood glucose and insulin spikes without nutritional benefit. Excessive added sugar consumption drives multiple pathological processes: promoting fat storage (particularly visceral fat), inducing insulin resistance, increasing inflammation, generating advanced glycation end products (AGEs) that accelerate cellular aging, promoting non-alcoholic fatty liver disease, dysregulating appetite hormones, and feeding pathogenic gut bacteria. The average American consumes 17 teaspoons (68g) of added sugar daily—nearly triple the American Heart Association''s recommended maximum of 25g for women and 36g for men. Major sources include sugar-sweetened beverages (47% of total), desserts and sweet snacks (31%), and processed foods where sugar is added for palatability and preservation. Fructose metabolism specifically in the liver drives triglyceride synthesis and uric acid production, contributing to metabolic syndrome.',
    longevity_impact = 'Added sugar consumption shows dose-dependent associations with increased mortality and accelerated biological aging across multiple large-scale studies. The JAMA Internal Medicine study of over 31,000 American adults found those consuming 17-21% of calories from added sugar had 38% higher cardiovascular mortality compared to those under 8%, with risk increasing dramatically above 21%. The Nurses'' Health Study showed women consuming 2+ sugar-sweetened beverages daily had 63% increased mortality compared to those consuming less than one monthly. Added sugar appears to accelerate cellular aging—a study in the American Journal of Public Health found each daily 20oz soda associated with 4.6 years of additional telomere aging. For disease-specific risks, a meta-analysis found highest versus lowest sugar intake associated with 26% increased type 2 diabetes risk independent of adiposity. The Framingham Heart Study demonstrated sugar-sweetened beverage consumption associated with visceral fat accumulation, insulin resistance, and elevated cardiovascular risk markers. Notably, Blue Zone populations consume minimal added sugar (typically under 5 teaspoons daily) and avoid sugar-sweetened beverages entirely, emphasizing whole foods and water.',
    quick_tips = jsonb_build_array(
        'Limit added sugar to 25g (6 teaspoons) daily for women, 36g (9 teaspoons) for men—less is better for longevity',
        'Eliminate sugar-sweetened beverages (soda, sweet tea, fruit juice, energy drinks)—these provide no nutrition and spike blood sugar',
        'Read nutrition labels carefully—sugar hides under 60+ names including high-fructose corn syrup, cane juice, dextrose, and maltose',
        'Choose whole fruits over dried fruits and fruit juice to get natural sweetness with fiber that moderates sugar absorption',
        'Reduce sugar gradually to retrain taste preferences—most people find foods taste sweeter after 2-3 weeks with less sugar',
        'Satisfy sweet cravings with naturally sweet vegetables (sweet potatoes, beets, carrots) and fruits, especially berries',
        'When using sweeteners, prefer small amounts of minimally processed options (maple syrup, honey, dates) and always pair with protein or fiber'
    )
WHERE metric_name = 'added_sugar_grams';

-- =====================================================================================
-- 10. MEAL TIMING
-- =====================================================================================
UPDATE display_metrics
SET
    about_content = 'Meal timing—the distribution and schedule of food intake across the day—profoundly influences metabolic health, circadian rhythm alignment, and longevity through complex interactions between nutrition and the body''s internal biological clocks. Emerging research in chrononutrition demonstrates that when we eat may be as important as what we eat. Time-restricted eating (TRE), confining food intake to consistent 8-12 hour windows, synchronizes peripheral circadian clocks in the liver, pancreas, and adipose tissue with the central clock in the brain, optimizing metabolic efficiency. The human body demonstrates predictable diurnal variation in insulin sensitivity, with greatest sensitivity in morning hours and progressive decline toward evening—consuming larger meals and carbohydrates earlier capitalizes on this pattern. Conversely, late-night eating disrupts circadian rhythms, impairs glucose tolerance, promotes fat storage, interferes with sleep quality, and may accelerate aging. The overnight fasting period (ideally 12-14+ hours) triggers cellular cleanup processes including autophagy and allows digestive system repair. Front-loading calories supports energy availability during active hours, while lighter evening meals promote better sleep and overnight fat oxidation. Consistency in meal timing helps entrain circadian rhythms for optimal metabolic function.',
    longevity_impact = 'Accumulating evidence suggests meal timing patterns significantly influence healthspan and longevity independent of diet quality. The Nurses'' Health Study II found women who consumed most calories at breakfast versus dinner had significantly lower obesity risk and better metabolic profiles. For time-restricted eating specifically, the American Heart Association study of over 20,000 adults found eating within an 8-10 hour window associated with reduced obesity and improved metabolic markers. Animal studies show robust lifespan extension from TRE—mice fed high-fat diets within restricted windows lived 35% longer than ad libitum fed controls despite identical caloric intake, with reduced inflammation, improved mitochondrial function, and enhanced autophagy. The CALERIE trial demonstrated that even without caloric restriction, later mealtimes associated with reduced weight loss and metabolic improvements. For cardiovascular health, the Adventist Health Study found those eating 2 larger meals with breakfast as largest had lower BMI and better health outcomes than those eating frequent small meals. Late-night eating associates with increased mortality—the Study of Women''s Health Across the Nation found eating within 3 hours of bedtime increased cardiovascular disease risk by 76%.',
    quick_tips = jsonb_build_array(
        'Establish a consistent eating window of 10-12 hours (e.g., 8am-6pm) and avoid food for 12-14 hours overnight',
        'Front-load calories by making breakfast or lunch your largest meal to align with peak insulin sensitivity',
        'Stop eating at least 3 hours before bedtime to optimize sleep quality, fat oxidation, and cellular repair processes',
        'Eat breakfast within 1-2 hours of waking to properly set your circadian rhythm and support metabolic health',
        'Maintain consistent meal times day-to-day—irregular eating patterns disrupt circadian clocks and metabolic function',
        'If practicing time-restricted eating, start with 12-hour window and gradually narrow to 10 hours as tolerated',
        'Consider intermittent fasting (16:8 or 5:2 patterns) after consulting healthcare provider—may enhance autophagy and longevity pathways'
    )
WHERE metric_name = 'meal_timing_score';

-- =====================================================================================
-- 11. MEAL QUALITY
-- =====================================================================================
UPDATE display_metrics
SET
    about_content = 'Meal quality encompasses the overall nutritional density, balance, and composition of eating occasions, integrating multiple dietary components into coherent patterns that support optimal metabolic function and long-term health. High-quality meals combine whole, minimally processed foods that provide complementary nutrients in forms that enhance bioavailability and promote satiety while minimizing blood glucose excursions and inflammatory responses. Key principles include: (1) building meals around non-starchy vegetables and plant foods that provide fiber, phytonutrients, and volume with minimal calories; (2) including adequate protein (20-40g) from diverse sources to support muscle synthesis and satiety; (3) incorporating healthy fats that slow digestion and enhance nutrient absorption; (4) choosing complex carbohydrates that provide sustained energy; (5) minimizing ultra-processed foods, added sugars, and refined grains that spike blood sugar and provide empty calories. The concept of "food synergy" recognizes that nutrients interact: iron absorption increases with vitamin C, fat-soluble vitamins require dietary fats, and fiber moderates sugar absorption. Meal quality also involves preparation methods—steaming, sautéing, and fermenting versus deep-frying or charring—that preserve nutrients and minimize harmful compound formation.',
    longevity_impact = 'Overall dietary patterns characterized by high meal quality consistently demonstrate the strongest associations with longevity across diverse populations and study designs. The Healthy Eating Index, which scores diet quality based on adherence to dietary guidelines, shows robust dose-response relationships with mortality—the NIH-AARP study of 492,000 participants found those in the highest versus lowest quintile had 22% lower all-cause mortality. The Alternative Mediterranean Diet Score similarly predicts longevity: the EPIC-Elderly study found each 2-point increase reduced mortality by 8%. Notably, these patterns emphasize meal quality over individual nutrients. The PREDIMED trial demonstrated that dietary pattern intervention (Mediterranean diet with olive oil or nuts) reduced cardiovascular events by 30% without calorie restriction. Blue Zone populations share high meal quality characteristics: predominantly plant-based whole foods, minimal processing, social eating contexts, and absence of ultra-processed foods. The prospective Urban Rural Epidemiology (PURE) study across 18 countries found diet quality scores based on protective foods (fruits, vegetables, legumes, nuts, fish) more strongly predicted mortality than limiting individual nutrients. Food processing level matters tremendously—the NutriNet-Santé cohort found each 10% increase in ultra-processed food consumption increased mortality by 14%.',
    quick_tips = jsonb_build_array(
        'Build every meal around non-starchy vegetables (half your plate) for maximum nutrient density and satiety',
        'Include protein (palm-sized portion), healthy fats (thumb-sized), and complex carbs (fist-sized) at each meal for balance',
        'Follow the 80/20 rule: 80% whole, minimally processed foods with flexible 20% for social and enjoyment contexts',
        'Prepare meals at home when possible—home cooking associates with better diet quality and lower chronic disease risk',
        'Practice the "food first" principle: obtain nutrients from whole foods rather than supplements whenever possible for optimal absorption and food synergy',
        'Use gentle cooking methods (steaming, sautéing, baking under 350°F) to preserve nutrients and avoid harmful compounds from high-heat cooking',
        'Eat mindfully without screens, chewing thoroughly and pausing between bites—supports digestion, satiety signals, and relationship with food'
    )
WHERE metric_name = 'meal_quality_score';

-- =====================================================================================
-- VERIFICATION
-- =====================================================================================
-- Verify all updates were applied
SELECT
    metric_name,
    CASE
        WHEN about_content IS NOT NULL THEN '✓'
        ELSE '✗'
    END as has_about,
    CASE
        WHEN longevity_impact IS NOT NULL THEN '✓'
        ELSE '✗'
    END as has_longevity,
    CASE
        WHEN quick_tips IS NOT NULL THEN '✓'
        ELSE '✗'
    END as has_tips,
    jsonb_array_length(quick_tips) as tip_count,
    LENGTH(about_content) as about_length,
    LENGTH(longevity_impact) as longevity_length
FROM display_metrics
WHERE metric_name IN (
    'vegetable_servings',
    'fruit_servings',
    'legume_servings',
    'whole_grain_servings',
    'healthy_fat_servings',
    'fiber_grams',
    'water_intake_ounces',
    'protein_grams',
    'added_sugar_grams',
    'meal_timing_score',
    'meal_quality_score'
)
ORDER BY metric_name;
