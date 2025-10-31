-- =====================================================
-- Comprehensive Nutrition Educational Content
-- =====================================================
-- PhD-level longevity research content for all nutrition metrics
-- =====================================================

BEGIN;

-- =====================================================
-- VEGETABLES & PLANT FOODS
-- =====================================================

UPDATE display_metrics SET
  about_content = 'Vegetables are the cornerstone of longevity diets, providing concentrated phytonutrients, vitamins, minerals, and fiber with minimal calories. Dark leafy greens contain folate and vitamin K for cardiovascular and cognitive health. Cruciferous vegetables (broccoli, cauliflower) provide sulforaphane that activates cellular detoxification. Colorful vegetables offer diverse antioxidants: beta-carotene (orange), lycopene (red), anthocyanins (purple). Fiber feeds gut bacteria, producing anti-inflammatory short-chain fatty acids.',
  longevity_impact = 'The EPIC study of 450,000+ Europeans found each 200g daily serving reduced all-cause mortality by 6%. Nurses'' Health Study showed 8+ servings daily = 30% lower cardiovascular mortality. Blue Zone populations consume 5-10 servings daily. Cruciferous vegetable intake specifically correlates with 33% reduced ovarian cancer risk. High vegetable consumers show cognitive aging delayed by 11 years.',
  quick_tips = jsonb_build_array(
    'Aim for 7-9 servings daily with at least 3 different colors',
    'Include cruciferous vegetables (broccoli, cauliflower) 4-5 times weekly',
    'Eat dark leafy greens daily for brain health',
    'Lightly steam or sauté to preserve nutrients',
    'Add healthy fats when eating to enhance vitamin absorption',
    'Choose local, seasonal, organic when possible',
    'Include both raw and cooked for different nutrient benefits'
  )
WHERE metric_name = 'Vegetable Variety';

UPDATE display_metrics SET
  about_content = 'Whole grains contain all three parts of the grain kernel: bran (fiber, B vitamins), germ (healthy fats, vitamin E), and endosperm (carbohydrates). Beta-glucan fiber improves cholesterol metabolism and feeds beneficial gut bacteria. Unlike refined grains, whole grains maintain stable blood sugar and provide sustained energy. Examples: oats, quinoa, brown rice, barley, whole wheat.',
  longevity_impact = 'A meta-analysis of 45 studies (700,000+ participants) found 3 servings daily whole grains reduced all-cause mortality by 17%, cardiovascular disease by 21%, and cancer by 15%. Blue Zone populations consume whole grains at most meals. The Nurses'' Health Study found whole grain consumers had 9% lower mortality over 24 years.',
  quick_tips = jsonb_build_array(
    'Target 3-5 servings daily (1 serving = 1/2 cup cooked or 1 slice bread)',
    'Choose intact grains (steel-cut oats, brown rice) over flour products',
    'Look for "100% whole grain" or whole grain as first ingredient',
    'Cook and cool rice/oats to increase resistant starch',
    'Rotate varieties (quinoa, barley, farro) for nutrient diversity'
  )
WHERE metric_name = 'Whole Grain Variety';

UPDATE display_metrics SET
  about_content = 'Healthy fats include monounsaturated fats (olive oil, avocados, nuts), omega-3 fatty acids (fatty fish, walnuts, flaxseed), and nuts/seeds. These fats reduce inflammation, support brain health, improve cholesterol profiles, and enhance absorption of fat-soluble vitamins (A, D, E, K). Extra virgin olive oil provides phenolic compounds with powerful anti-inflammatory effects.',
  longevity_impact = 'The PREDIMED trial of 7,500 participants found Mediterranean diet with extra virgin olive oil or nuts reduced cardiovascular events by 30% and mortality by 25%. Omega-3 intake correlates with reduced inflammation, preserved telomere length, and lower dementia risk. Replacing saturated fats with unsaturated fats reduces mortality by 13-19% per 5% calorie substitution.',
  quick_tips = jsonb_build_array(
    'Use extra virgin olive oil as primary fat source (2-4 tablespoons daily)',
    'Eat fatty fish (salmon, mackerel, sardines) 2-3 times weekly for omega-3s',
    'Include 1 ounce nuts daily (almonds, walnuts, pistachios)',
    'Add avocado for monounsaturated fats and fiber',
    'Choose whole food fat sources over extracted oils when possible',
    'Avoid trans fats completely and limit saturated fat to <7% calories'
  )
WHERE metric_name = 'Healthy Fat Usage';

-- =====================================================
-- PROTEIN DETAILS
-- =====================================================

UPDATE display_metrics SET
  about_content = 'Plant-based proteins from legumes, nuts, seeds, and whole grains provide protein along with fiber, phytonutrients, and beneficial fats absent in animal proteins. While individually incomplete in amino acids, combining plant proteins throughout the day provides all essential amino acids. Plant proteins associate with lower inflammatory markers and reduced chronic disease risk compared to red/processed meat.',
  longevity_impact = 'A 32-year follow-up of 131,000+ participants found replacing 3% of calories from animal protein with plant protein reduced mortality by 10%. The Adventist Health Study-2 found vegans and vegetarians lived 3-6 years longer than meat-eaters. Each 3% increase in plant protein calories reduced cardiovascular mortality by 12%.',
  quick_tips = jsonb_build_array(
    'Aim for 50%+ of protein from plant sources',
    'Combine legumes with whole grains for complete amino acid profiles',
    'Include variety: beans, lentils, tofu, tempeh, nuts, seeds',
    'Don''t need to combine at same meal—daily variety sufficient',
    'Consider plant-based protein powder for convenience'
  )
WHERE metric_name = 'Plant Protein';

UPDATE display_metrics SET
  about_content = 'Protein per kilogram body weight is the most accurate way to assess adequate intake, accounting for individual body size. Requirements increase with age due to anabolic resistance—older adults need 1.2-1.6 g/kg vs 0.8 g/kg for younger adults. This metric helps ensure muscle preservation, especially during weight loss or aging.',
  longevity_impact = 'The Health ABC Study found older adults with protein intake >1.2 g/kg had 40% lower risk of significant muscle loss over 3 years. Adequate protein per kg associates with preserved strength, reduced frailty, lower fall risk, and maintained metabolic rate. Protein adequacy predicts functional independence in late life.',
  quick_tips = jsonb_build_array(
    'Target 1.2-1.6 g/kg if over 50 years old',
    'Calculate as: body weight (kg) × 1.2-1.6 = daily protein goal',
    'Increase to upper range (1.6 g/kg) if very active or in caloric deficit',
    'Track this metric rather than total grams to account for weight changes',
    'Reassess if weight changes significantly (>5 kg)'
  )
WHERE metric_name = 'Protein per Kg';

UPDATE display_metrics SET
  about_content = 'Processed meats (bacon, sausage, deli meat, hot dogs) undergo curing, smoking, or addition of preservatives like nitrites. These processes create compounds (N-nitroso, heterocyclic amines, polycyclic aromatic hydrocarbons) that damage DNA and promote cancer. High sodium content drives hypertension. Red meat (beef, pork, lamb) when consumed in excess increases cardiovascular disease risk.',
  longevity_impact = 'WHO classifies processed meat as Group 1 carcinogen. Each 50g daily serving increases colorectal cancer risk by 18%, all-cause mortality by 13-20%, and cardiovascular mortality by 24%. The NIH-AARP study of 500,000+ adults found those eating the most red/processed meat had 27% higher mortality. Blue Zones consume <1-2 servings monthly.',
  quick_tips = jsonb_build_array(
    'Limit processed meats to <1 serving weekly (or eliminate)',
    'Limit red meat to <1-2 servings weekly',
    'Choose grass-fed, organic when consuming red meat',
    'Replace with fish, poultry, or plant proteins',
    'Avoid charring/high-temperature cooking to reduce carcinogens'
  )
WHERE metric_name = 'Processed Meat Serving';

UPDATE display_metrics SET
  about_content = 'Red meat (beef, pork, lamb) contains heme iron, B vitamins, zinc, and complete protein but also saturated fat and compounds (TMAO, Neu5Gc) that may promote inflammation when consumed in excess. Grass-fed options provide better omega-3 to omega-6 ratios. Moderate consumption (1-2 servings weekly) can fit in longevity diets, but excessive intake correlates with increased disease risk.',
  longevity_impact = 'Large cohort studies find dose-response relationships: each daily serving increases all-cause mortality by 13%, cardiovascular mortality by 18%, and cancer mortality by 10%. Conversely, replacing red meat with plant proteins, fish, or poultry reduces mortality by 7-19%. Blue Zone populations consume red meat <5 times monthly, treating it as a condiment rather than main course.',
  quick_tips = jsonb_build_array(
    'Limit to 1-2 small servings (3-4 oz) weekly',
    'Choose grass-fed, organic options for better fatty acid profile',
    'Use as flavoring (small amounts in stews) rather than main course',
    'Replace with fatty fish for similar nutrients plus omega-3s',
    'Pair with plenty of vegetables to buffer negative effects'
  )
WHERE metric_name = 'Red Meat';

-- =====================================================
-- FATS
-- =====================================================

UPDATE display_metrics SET
  about_content = 'Monounsaturated fats (MUFA) from olive oil, avocados, and nuts improve cholesterol profiles by raising HDL and lowering LDL. Extra virgin olive oil provides polyphenols with anti-inflammatory effects. MUFAs are stable at cooking temperatures and support cardiovascular health, insulin sensitivity, and reduce oxidative stress. Mediterranean diet success largely attributes to high MUFA intake.',
  longevity_impact = 'The PREDIMED trial found Mediterranean diet with extra virgin olive oil reduced cardiovascular events by 30%. Replacing 5% of calories from saturated fat with MUFAs reduces all-cause mortality by 13% and cardiovascular mortality by 15%. Olive oil consumption (>1/2 tablespoon daily) associates with 34% lower all-cause mortality over 28-year follow-up.',
  quick_tips = jsonb_build_array(
    'Use extra virgin olive oil as primary cooking and dressing fat (2-4 tbsp daily)',
    'Include avocado regularly for MUFAs plus fiber and potassium',
    'Choose MUFA-rich nuts: almonds, cashews, pistachios, macadamias',
    'Use olive oil for low-medium heat; avocado oil for high-heat cooking',
    'Look for early harvest, high-polyphenol olive oils (may have peppery taste)'
  )
WHERE metric_name = 'Monounsaturated Fat';

UPDATE display_metrics SET
  about_content = 'Polyunsaturated fats (PUFA) include omega-3 (anti-inflammatory) and omega-6 (pro-inflammatory when excessive) fatty acids. Omega-3s (EPA, DHA from fish; ALA from walnuts, flaxseed) reduce inflammation, support brain health, and stabilize heart rhythm. The ratio of omega-6 to omega-3 matters—modern diets average 15:1 but optimal is 4:1 or lower.',
  longevity_impact = 'Higher omega-3 intake associates with 15-17% lower mortality, reduced dementia risk, and preserved telomere length. The VITAL trial of 25,000+ adults found omega-3 supplementation reduced heart attacks by 28% in low fish consumers. Each 1g daily EPA+DHA reduces cardiovascular mortality by 5-9%.',
  quick_tips = jsonb_build_array(
    'Eat fatty fish (salmon, sardines, mackerel) 2-3 times weekly for EPA/DHA',
    'Include plant omega-3s: walnuts, flaxseed, chia seeds daily',
    'Limit omega-6 oils (corn, soybean) to improve omega-6:omega-3 ratio',
    'Consider algae-based omega-3 supplements if not eating fish',
    'Target 250-500mg combined EPA+DHA daily minimum'
  )
WHERE metric_name = 'Polyunsaturated Fat';

UPDATE display_metrics SET
  about_content = 'Saturated fat primarily from animal products (meat, butter, cheese) raises LDL cholesterol and inflammatory markers when consumed in excess. While not as harmful as trans fats, excessive saturated fat (>10% of calories) increases cardiovascular disease risk. Sources matter: dairy saturated fats may have neutral or beneficial effects vs red meat saturated fats.',
  longevity_impact = 'Replacing 5% of calories from saturated fat with polyunsaturated fats reduces cardiovascular mortality by 19%, with MUFAs by 15%, and with whole grains by 9%. The Nurses'' Health Study found highest saturated fat consumers had 19% higher stroke risk. Optimal intake appears to be <7% of total calories for longevity.',
  quick_tips = jsonb_build_array(
    'Limit saturated fat to <7% of daily calories (~15g for 2000 cal diet)',
    'Replace butter with olive oil for cooking and spreading',
    'Choose lean proteins and trim visible fat from meat',
    'Limit full-fat dairy; choose low-fat options or plant-based alternatives',
    'Be aware: coconut and palm oils are very high in saturated fat',
    'Track saturated fat percentage, not just total fat intake'
  )
WHERE metric_name = 'Saturated Fat';

UPDATE display_metrics SET
  about_content = 'Fatty fish (salmon, mackerel, sardines, herring, anchovies) provide EPA and DHA omega-3 fatty acids that cannot be efficiently produced by the body. These long-chain omega-3s incorporate into cell membranes, reducing inflammation, stabilizing heart rhythm, supporting brain health, and preserving telomere length. Wild-caught options generally provide better omega-3 profiles than farmed.',
  longevity_impact = 'Meta-analyses show 2+ servings weekly reduces cardiovascular mortality by 17% and stroke risk by 18%. The Framingham Heart Study found omega-3 blood levels in the top quartile associated with 5 additional years of life expectancy. Japanese populations with highest fish intake show lowest cardiovascular mortality globally.',
  quick_tips = jsonb_build_array(
    'Target 2-3 servings weekly (4-6 oz per serving)',
    'Prioritize: wild salmon, sardines, mackerel, herring, anchovies',
    'Choose wild-caught when possible for better omega-3 content',
    'Include small fish (sardines, anchovies) for lower mercury',
    'Pair with vegetables and whole grains in Mediterranean pattern'
  )
WHERE metric_name = 'Fatty Fish';

-- =====================================================
-- MEAL TIMING & PATTERNS
-- =====================================================

UPDATE display_metrics SET
  about_content = 'Eating window (time between first and last caloric intake) affects circadian rhythm alignment, metabolic health, and cellular autophagy. Time-restricted eating (10-12 hour windows) allows extended fasting periods that trigger cellular cleanup processes, improve insulin sensitivity, and may extend lifespan. Longer eating windows (>14 hours) associate with metabolic dysfunction.',
  longevity_impact = 'Nurses'' Health Study II found eating over <10 hour window vs >15 hours associated with better glycemic control and reduced diabetes risk. The AHA study of 20,000+ adults found eating over 16+ hours increased cardiovascular mortality by 91%. Blue Zones naturally practice 10-12 hour eating windows with early dinners.',
  quick_tips = jsonb_build_array(
    'Target 10-12 hour eating window (e.g., 8am-6pm or 7am-7pm)',
    'Keep consistent timing day-to-day for circadian alignment',
    'Front-load calories: larger breakfast and lunch, lighter dinner',
    'Finish eating 2-3 hours before bed for better sleep and autophagy',
    'Weekend consistency matters—avoid "social jet lag"',
    'Start with current window and gradually shorten by 30 min increments'
  )
WHERE metric_name = 'Eating Window';

UPDATE display_metrics SET
  about_content = 'First meal timing affects circadian rhythm alignment, metabolism, and cognitive performance. Eating too early (before natural cortisol awakening) or too late (after 10-11am) can disrupt metabolic rhythms. Delaying first meal 1-2 hours after waking (allowing cortisol to peak naturally) may optimize metabolic health. Morning light exposure should precede first meal.',
  longevity_impact = 'Chrononutrition research shows breakfast skippers have 27% higher cardiovascular mortality. However, late breakfasts (after 10am) associate with weight gain and metabolic dysfunction. Optimal timing appears 1-2 hours post-waking, after morning light exposure and cortisol peak, aligning with Blue Zone patterns.',
  quick_tips = jsonb_build_array(
    'Eat first meal 1-2 hours after waking (after cortisol awakening response)',
    'Get morning sunlight before eating to set circadian rhythm',
    'Include protein (25-40g) in first meal to optimize satiety',
    'Keep timing consistent (±1 hour) day-to-day',
    'Consider waiting until true hunger rather than clock-watching'
  )
WHERE metric_name = 'First Meal Time';

UPDATE display_metrics SET
  about_content = 'Last meal timing relative to sleep affects digestion, sleep quality, circadian rhythm, and metabolic health. Eating close to bedtime elevates core body temperature and blood sugar, disrupting sleep onset and quality. A 2-3 hour buffer allows digestion, body temperature to drop, and melatonin to rise naturally. Late eating also reduces overnight autophagy and cellular repair.',
  longevity_impact = 'The AHA study found eating within 3 hours of bedtime increased cardiovascular mortality risk. Late eaters show poorer glycemic control, higher BMI, and disrupted circadian genes. Blue Zone populations eat dinner early (5-7pm) and avoid evening snacking. The CALERIE trial found earlier eating improved cardiometabolic risk markers.',
  quick_tips = jsonb_build_array(
    'Finish last meal 2-3 hours before bedtime',
    'Make dinner lightest meal or equal to lunch (not largest)',
    'Avoid late-night snacking after dinner',
    'If hungry before bed, choose small protein source (avoids blood sugar spike)',
    'Consider 7pm dinner "cutoff" as Blue Zone populations practice'
  )
WHERE metric_name = 'Last Meal Time';

-- =====================================================
-- MEAL QUALITY
-- =====================================================

UPDATE display_metrics SET
  about_content = 'Whole food meals contain minimally processed ingredients in their natural state: vegetables, fruits, whole grains, legumes, nuts, seeds, and unprocessed animal products. These foods provide nutrient density, fiber, and bioactive compounds while avoiding additives, preservatives, and excess sodium/sugar. Food synergy—nutrients working together—enhances health benefits beyond isolated nutrients.',
  longevity_impact = 'The PREDIMED and EPIC-Elderly studies show whole food, minimally processed diets reduce all-cause mortality by 20-25%. The NIH-AARP study of 492,000 adults found ultra-processed food consumption inversely correlated with longevity. Blue Zone populations consume 90-100% whole foods, with processed foods rare or absent.',
  quick_tips = jsonb_build_array(
    'Aim for 80%+ of diet from whole, unprocessed foods',
    'Shop the perimeter of grocery stores (produce, meat, dairy)',
    'If ingredients list is >5 items or contains unrecognizable chemicals, it''s ultra-processed',
    'Meal prep whole foods for convenience to avoid processed options',
    'Apply "80/20 rule"—perfection not required, consistency matters'
  )
WHERE metric_name = 'Whole Food Meals by Time';

UPDATE display_metrics SET
  about_content = 'Ultra-processed foods contain industrial ingredients not found in home kitchens: artificial colors, flavors, emulsifiers, preservatives. These foods are hyper-palatable (engineered for overconsumption), nutrient-poor, and displace whole foods from the diet. They disrupt satiety signaling, promote inflammation, and damage gut microbiome diversity.',
  longevity_impact = 'A BMJ study of 105,000 adults found each 10% increase in ultra-processed food consumption increased all-cause mortality by 14% and cardiovascular mortality by 12%. The SUN cohort found >4 servings daily increased all-cause mortality by 62%. Ultra-processed foods associate with obesity, diabetes, dementia, and depression.',
  quick_tips = jsonb_build_array(
    'Minimize to <10% of total food intake (ideally <5%)',
    'Read ingredient lists—avoid foods with >5 ingredients or chemicals',
    'Replace ultra-processed snacks with whole food options (nuts, fruit, vegetables)',
    'Recognize: most packaged snacks, frozen meals, cereals qualify',
    'Cook at home more often to avoid processed foods'
  )
WHERE metric_name = 'Ultraprocessed by Meal';

UPDATE display_metrics SET
  about_content = 'Plant-based meals center on vegetables, fruits, whole grains, legumes, nuts, and seeds with minimal or no animal products. These meals provide fiber (often 15-25g per meal), diverse phytonutrients, and prebiotic compounds that feed beneficial gut bacteria. Plant-based eating patterns associate with lower inflammatory markers, improved insulin sensitivity, and healthy body weight.',
  longevity_impact = 'The Adventist Health Study-2 following 96,000 adults found vegans lived 9.5 years longer than meat-eaters, vegetarians 6.1 years longer. Even flexitarian patterns (mostly plants with occasional animal products) show significant benefits. Plant-based diets reduce cardiovascular disease by 40%, diabetes by 50%, and certain cancers by 15-20%.',
  quick_tips = jsonb_build_array(
    'Aim for 1-2+ plant-based meals daily (breakfast and lunch often easiest)',
    'Build meals around legumes, whole grains, and abundant vegetables',
    'Include healthy fats (nuts, seeds, avocado, olive oil) for satiety',
    'Don''t need to be 100% vegan—"plant-forward" pattern offers major benefits',
    'Ensure B12, vitamin D, omega-3 adequacy if predominantly plant-based'
  )
WHERE metric_name = 'Plant Based Meal';

-- =====================================================
-- HYDRATION
-- =====================================================

UPDATE display_metrics SET
  about_content = 'Adequate hydration supports cellular function, temperature regulation, nutrient transport, waste removal, cognitive performance, and kidney health. The glymphatic system (brain waste clearance) requires proper hydration. As we age, thirst sensitivity decreases, making intentional hydration more important. Chronic mild dehydration accelerates aging at the cellular level.',
  longevity_impact = 'An NIH study of 11,000+ adults followed 25 years found optimal hydration (evidenced by serum sodium 135-142 mmol/L) associated with 39% lower risk of chronic disease and younger biological age. The Adventist Health Study found 5+ glasses water daily reduced cardiovascular mortality by 41-54% vs 2 glasses. Dehydration accelerates kidney aging and increases mortality risk.',
  quick_tips = jsonb_build_array(
    'Target half your body weight (lbs) in ounces daily (e.g., 150 lbs = 75 oz)',
    'Increase intake with exercise, heat, high altitude, or illness',
    'Drink water first thing upon waking to rehydrate after sleep',
    'Monitor urine color: pale yellow indicates good hydration',
    'Include water-rich foods (cucumber, watermelon, soup) toward daily goal',
    'Limit diuretics (alcohol, excessive caffeine) that promote fluid loss'
  )
WHERE metric_name IN ('Water Intake', 'Hydration');

-- =====================================================
-- CAFFEINE
-- =====================================================

UPDATE display_metrics SET
  about_content = 'Caffeine from coffee and tea provides antioxidants, polyphenols, and adenosine receptor antagonism that improves alertness and cognitive performance. Coffee contains chlorogenic acid and cafestol; tea provides catechins (especially EGCG in green tea). Moderate intake (200-400mg daily) shows health benefits, but excessive consumption (>600mg) increases anxiety, sleep disruption, and cortisol.',
  longevity_impact = 'Meta-analyses find U-shaped relationship: 2-4 cups coffee daily reduces all-cause mortality by 12-14% and cardiovascular mortality by 15-19% vs non-drinkers or heavy drinkers. The Health Professionals Follow-up Study found coffee drinkers had lower rates of Parkinson''s (32%), type 2 diabetes (25%), and liver disease (80%). Tea consumption shows similar benefits.',
  quick_tips = jsonb_build_array(
    'Optimal: 200-400mg daily (2-4 cups coffee or 3-5 cups tea)',
    'Consume before 2pm to avoid sleep disruption (caffeine half-life ~5 hours)',
    'Choose organic when possible to reduce pesticide exposure',
    'Skip if you metabolize caffeine slowly (genetic variant)',
    'Green tea provides L-theanine for calm alertness',
    'Avoid excessive sugar/cream—drink black or with minimal additions'
  )
WHERE metric_name = 'Caffeine';

-- =====================================================
-- ALCOHOL (if exists)
-- =====================================================

UPDATE display_metrics SET
  about_content = 'Alcohol is a cellular toxin that must be metabolized by the liver, producing acetaldehyde (a carcinogen) and oxidative stress. While low-moderate consumption (1 drink daily for women, 2 for men) was thought protective, recent research questions this due to confounding factors. Any amount increases cancer risk, disrupts sleep architecture (suppresses REM), and affects hormones. The "J-shaped curve" may be artifact of comparing to former drinkers (sick quitters).',
  longevity_impact = 'A Lancet study of 195 countries found zero alcohol is optimal for health—even light drinking increases overall risk. WHO classifies alcohol as Group 1 carcinogen. Each drink daily increases breast cancer risk by 7-10%, liver disease risk substantially, and disrupts restorative sleep. Some cardiovascular benefits may exist at very low intake (<1 weekly) but are offset by other harms.',
  quick_tips = jsonb_build_array(
    'Minimize alcohol consumption; zero is optimal for longevity',
    'If drinking, limit to 1-3 drinks weekly maximum',
    'Choose red wine over other alcohol for resveratrol content if consuming',
    'Avoid within 3-4 hours of bedtime to protect sleep quality',
    'Track "drinks vs baseline" to maintain awareness and prevent creep',
    'Consider alcohol-free periods (monthly or quarterly) to reset tolerance'
  )
WHERE metric_name LIKE '%Alcohol%' AND metric_name NOT LIKE '%vs%';

COMMIT;
