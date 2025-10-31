-- =====================================================
-- Add Educational Content to Existing Display Metrics
-- =====================================================
-- Updates about_content, longevity_impact, quick_tips
-- for all existing display metrics
-- =====================================================

BEGIN;

-- =====================================================
-- NUTRITION - Main Components
-- =====================================================

-- Protein
UPDATE display_metrics SET
  about_content = 'Protein is essential for maintaining muscle mass, bone density, and metabolic health throughout the lifespan. As we age, anabolic resistance increases—requiring higher protein intake (1.2-1.6 g/kg body weight for adults 65+) to maintain muscle protein synthesis. Quality matters: animal proteins provide complete amino acid profiles with high leucine content that triggers muscle building, while plant proteins offer additional fiber and phytonutrients. The timing and distribution of protein across meals optimizes muscle protein synthesis, with 25-40g per meal being ideal.',
  longevity_impact = 'Higher protein intake in older adults associates with preserved muscle mass, reduced frailty risk, and lower mortality. The Health ABC Study found that adults 70+ in the highest protein quintile had 40% lower risk of losing significant muscle mass over 3 years. A 32-year follow-up of 131,342 participants found that replacing 3% of calories from animal protein with plant protein reduced mortality by 10%. Blue Zone populations average 1.0-1.2 g/kg daily, emphasizing plant sources with occasional fish.',
  quick_tips = jsonb_build_array(
    'Target 1.2-1.6 g/kg body weight daily, especially if over 50 years old',
    'Distribute protein across meals (25-40g each) rather than loading one meal',
    'Prioritize plant proteins (legumes, nuts, seeds) with occasional fish',
    'Include 2.5-3g leucine per meal to trigger muscle protein synthesis',
    'Consume protein within 2 hours post-exercise for optimal recovery',
    'Consider collagen/gelatin for joint health and skin elasticity',
    'Track protein per kg body weight to ensure adequate intake as weight changes'
  )
WHERE metric_name = 'Protein';

-- Fruits
UPDATE display_metrics SET
  about_content = 'Whole fruits provide concentrated antioxidants, polyphenols, vitamins, and fiber that support longevity. Unlike fruit juice, whole fruits include fiber that moderates sugar absorption and feeds gut bacteria. Berries are exceptionally rich in anthocyanins that cross the blood-brain barrier to protect cognitive function. The diverse phytonutrients in fruits—including vitamin C, quercetin, and ellagic acid—reduce oxidative stress and inflammation.',
  longevity_impact = 'Each daily serving of fruit reduces cardiovascular mortality by 4% and stroke risk by 5% according to Harvard cohort studies of 100,000+ participants. Higher berry consumption slowed cognitive decline by 2.5 years in the Rush Memory and Aging Project. Blue Zone populations consume 2-4 servings daily, with Adventist Health Study participants eating the most fruit showing 10% lower all-cause mortality.',
  quick_tips = jsonb_build_array(
    'Aim for 3-5 servings daily, emphasizing berries 3-4 times weekly for brain health',
    'Choose whole fruits over juice to maintain protective fiber content',
    'Include deeply colored fruits (berries, cherries, pomegranates) for highest antioxidants',
    'Time fruit with meals or pre-exercise to optimize blood sugar response',
    'Pair fruits with protein or healthy fats to stabilize blood sugar'
  )
WHERE metric_name = 'Fruit Servings';

-- Legumes
UPDATE display_metrics SET
  about_content = 'Legumes (beans, lentils, chickpeas, peas) combine plant protein, fiber, resistant starch, and micronutrients in a uniquely longevity-promoting package. One cup provides 15-19g fiber and produces short-chain fatty acids that reduce inflammation and support immune function. Their soluble fiber binds cholesterol, reducing cardiovascular risk.',
  longevity_impact = 'Blue Zone populations consume legumes daily, with the Adventist Health Study-2 finding legume consumers had 9-13% lower all-cause mortality over 96,000 participants. Regular consumption (1 cup daily) consistently associates with reduced body weight, improved glycemic control, and 22% lower cardiovascular disease risk.',
  quick_tips = jsonb_build_array(
    'Aim for 1-2 cups daily (cooked) for optimal longevity benefits',
    'Soak dried beans 8-12 hours and rinse to reduce gas-causing oligosaccharides',
    'Combine with whole grains to create complete protein profiles',
    'Include variety: rotate between beans, lentils, chickpeas for diverse nutrients',
    'Add to soups, salads, and grain bowls for easy incorporation'
  )
WHERE metric_name = 'Legume Servings';

-- Fiber
UPDATE display_metrics SET
  about_content = 'Dietary fiber includes soluble fiber (dissolves in water, forms gel) and insoluble fiber (aids digestion). Fiber feeds gut bacteria that produce short-chain fatty acids (butyrate, propionate, acetate) which reduce inflammation, support immune function, and may protect against colon cancer. Adequate fiber intake (35-50g daily) improves glycemic control, lowers cholesterol, and promotes satiety.',
  longevity_impact = 'A meta-analysis of 185 studies found each 8g daily fiber increase reduced all-cause mortality by 5-27%. The NIH-AARP study of 388,000 adults over 9 years found those in the highest fiber quintile had 22% lower mortality. Fiber intake inversely correlates with cardiovascular disease, diabetes, and certain cancers.',
  quick_tips = jsonb_build_array(
    'Target 35-50g daily from whole food sources (not supplements)',
    'Include both soluble (oats, beans, fruits) and insoluble (whole grains, vegetables)',
    'Increase gradually to avoid digestive discomfort',
    'Drink adequate water (8-12 cups daily) to support fiber function',
    'Prioritize diversity of fiber sources for gut microbiome health'
  )
WHERE metric_name = 'Fiber Intake';

-- Added Sugar
UPDATE display_metrics SET
  about_content = 'Added sugars (not naturally occurring sugars in fruits/dairy) drive metabolic dysfunction through multiple pathways: formation of advanced glycation end products (AGEs) that damage proteins, metabolic syndrome, insulin resistance, and systemic inflammation. Fructose specifically stresses the liver, promoting fat accumulation and uric acid production. The average American consumes 77g daily—triple the recommended maximum.',
  longevity_impact = 'A JAMA study of 31,147 adults found those consuming 17-21% of calories from added sugar had 38% higher cardiovascular mortality compared to those consuming <8%. Each daily sugar-sweetened beverage increases diabetes risk by 13% and telomere shortening equivalent to 4.6 years of aging. Reducing to <25-36g daily improves metabolic health markers within weeks.',
  quick_tips = jsonb_build_array(
    'Limit added sugars to 25g (women) or 36g (men) daily maximum',
    'Eliminate sugar-sweetened beverages—largest source of added sugar',
    'Read labels: 4g sugar = 1 teaspoon; many "healthy" foods contain 12+ teaspoons',
    'Choose whole fruits instead of dried fruits, which concentrate sugars',
    'Beware hidden sugars in sauces, dressings, and "health foods"'
  )
WHERE metric_name = 'Added Sugar';

COMMIT;
