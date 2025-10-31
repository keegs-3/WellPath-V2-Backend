-- =====================================================
-- Add Education Content to Detail Screens
-- =====================================================
-- Adds tab-specific education content for protein detail tabs
-- =====================================================

BEGIN;

-- =====================================================
-- 1. Add Education Content Columns to display_metrics
-- =====================================================
-- Each metric (shown in a tab) can have its own educational content

ALTER TABLE display_metrics
ADD COLUMN IF NOT EXISTS about_content TEXT,
ADD COLUMN IF NOT EXISTS longevity_impact TEXT,
ADD COLUMN IF NOT EXISTS quick_tips JSONB;

COMMENT ON COLUMN display_metrics.about_content IS 'Tab-specific information about this metric';
COMMENT ON COLUMN display_metrics.longevity_impact IS 'How this specific metric impacts longevity';
COMMENT ON COLUMN display_metrics.quick_tips IS 'Tab-specific actionable tips';

-- =====================================================
-- 2. Populate Tab 1: Protein by Meal (Timing)
-- =====================================================

UPDATE display_metrics
SET
  about_content = 'Protein timing and distribution throughout the day significantly impacts muscle protein synthesis (MPS). Research shows that spreading protein evenly across meals (rather than loading it in one meal) maximizes 24-hour muscle protein synthesis. Each meal should contain 20-40g of high-quality protein to reach the leucine threshold (~2.5-3g) needed to trigger MPS. The "muscle full" effect means eating more than ~40g per meal provides diminishing returns for muscle building.',

  longevity_impact = 'Even protein distribution across meals is associated with better muscle mass preservation, strength maintenance, and functional capacity in aging adults. Studies show that spreading protein intake evenly (vs skewed toward dinner) correlates with greater lean mass and grip strength in older adults. Breakfast protein specifically has been linked to improved satiety, better blood sugar control, and reduced risk of sarcopenic obesity. Morning protein may also support circadian rhythm alignment and metabolic health.',

  quick_tips = jsonb_build_array(
    'Eat 20-40g protein at breakfast to maximize daily muscle protein synthesis',
    'Space protein meals 3-5 hours apart for optimal absorption and utilization',
    'Don''t skip breakfast protein - morning intake is crucial for daily MPS',
    'Avoid loading all protein at dinner - your muscles can''t store excess amino acids',
    'Pre-sleep protein (20-40g) can enhance overnight muscle recovery and synthesis',
    'Post-workout timing matters: consume protein within 2 hours of resistance training',
    'Older adults (65+) may benefit from slightly higher protein per meal (~35-40g)'
  ),

  updated_at = NOW()
WHERE metric_id = 'DISP_PROTEIN_MEAL_TIMING';

-- =====================================================
-- 3. Populate Tab 2: Protein by Type (Sources)
-- =====================================================

UPDATE display_metrics
SET
  about_content = 'Protein quality varies by source based on amino acid profile, digestibility, and bioavailability. Animal proteins are "complete" (containing all 9 essential amino acids) with high digestibility (DIAAS >100). Plant proteins are often "incomplete" but can be combined for complete profiles. Fatty fish provides high-quality protein plus omega-3 EPA/DHA. Processed meats, while protein-rich, contain nitrates/nitrites linked to health risks. Diverse protein sources provide unique phytonutrients, minerals, and health benefits beyond just amino acids.',

  longevity_impact = 'Protein source significantly impacts longevity. Large cohort studies consistently show plant protein intake correlates with reduced all-cause mortality, while high red/processed meat intake associates with increased mortality risk. Fatty fish consumption (rich in omega-3s) is linked to reduced cardiovascular mortality and cognitive decline. The Adventist Health Study found that replacing 3% of calories from animal protein with plant protein reduced mortality by 10%. Leucine-rich sources (dairy, fish, poultry) are particularly important for older adults to prevent sarcopenia.',

  quick_tips = jsonb_build_array(
    'Aim for at least 50% plant-based protein sources for longevity benefits',
    'Fatty fish 2-3x/week provides protein + brain-protective omega-3s',
    'Limit red meat to 1-2x/week; choose grass-fed when possible',
    'Avoid processed meats (bacon, sausage, deli meat) - strong cancer links',
    'Combine plant proteins for complete profiles: beans + rice, hummus + pita',
    'Greek yogurt and cottage cheese offer high protein + gut-friendly probiotics',
    'Variety is key - rotate through 5+ different protein sources weekly'
  ),

  updated_at = NOW()
WHERE metric_id = 'DISP_PROTEIN_TYPE';

-- =====================================================
-- 4. Populate Tab 3: Protein Ratio (g/kg body weight)
-- =====================================================

UPDATE display_metrics
SET
  about_content = 'Protein requirements scale with body weight, activity level, and age. The RDA of 0.8 g/kg is a minimum to prevent deficiency, not optimal for health. Current evidence supports 1.2-1.6 g/kg for most adults, with athletes needing 1.6-2.2 g/kg. Older adults (65+) may need 1.2-1.6 g/kg to prevent sarcopenia. During caloric restriction/fat loss, higher protein (1.8-2.4 g/kg lean mass) helps preserve muscle. Very high intakes (>2.5 g/kg) offer no additional benefit and may strain kidneys in susceptible individuals.',

  longevity_impact = 'Higher protein intake (1.2-1.6 g/kg) is associated with increased longevity, reduced frailty, and better healthspan in adults over 65. The Framingham Heart Study Offspring Cohort found higher protein intake linked to 30% reduced risk of becoming frail. Adequate protein helps maintain muscle mass, bone density, immune function, and metabolic health - all key determinants of healthspan. However, source matters: plant protein shows stronger longevity benefits than animal protein at equivalent intakes.',

  quick_tips = jsonb_build_array(
    'Target 1.2-1.6 g/kg body weight for optimal health and longevity',
    'If overweight, calculate based on goal weight or lean mass, not total weight',
    'Increase to 1.6-2.0 g/kg during fat loss to preserve muscle mass',
    'Athletes and highly active individuals: aim for 1.6-2.2 g/kg',
    'Adults 65+: prioritize the higher end (1.4-1.6 g/kg) to prevent sarcopenia',
    'Space intake evenly: divide daily g/kg target across 3-4 meals',
    'More isn''t always better: >2.2 g/kg provides no additional muscle building'
  ),

  updated_at = NOW()
WHERE metric_id = 'DISP_PROTEIN_PER_KG';

-- =====================================================
-- Summary
-- =====================================================

DO $$
DECLARE
  v_metrics_updated INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_metrics_updated
  FROM display_metrics
  WHERE metric_id IN ('DISP_PROTEIN_MEAL_TIMING', 'DISP_PROTEIN_TYPE', 'DISP_PROTEIN_PER_KG')
    AND about_content IS NOT NULL;

  RAISE NOTICE '';
  RAISE NOTICE '✅ Detail Tab Education Content Added!';
  RAISE NOTICE '';
  RAISE NOTICE 'Updated % protein metrics with:', v_metrics_updated;
  RAISE NOTICE '  • about_content (evidence-based information)';
  RAISE NOTICE '  • longevity_impact (how it affects healthspan)';
  RAISE NOTICE '  • quick_tips (actionable advice)';
  RAISE NOTICE '';
  RAISE NOTICE 'Tab 1 (By Meal):';
  RAISE NOTICE '  ✓ Protein timing and distribution science';
  RAISE NOTICE '  ✓ Impact on muscle protein synthesis and aging';
  RAISE NOTICE '  ✓ 7 evidence-based timing tips';
  RAISE NOTICE '';
  RAISE NOTICE 'Tab 2 (By Type):';
  RAISE NOTICE '  ✓ Protein source quality and bioavailability';
  RAISE NOTICE '  ✓ Longevity research on plant vs animal protein';
  RAISE NOTICE '  ✓ 7 tips for optimizing protein sources';
  RAISE NOTICE '';
  RAISE NOTICE 'Tab 3 (Ratio):';
  RAISE NOTICE '  ✓ Protein requirements by body weight';
  RAISE NOTICE '  ✓ Research on optimal intake for longevity';
  RAISE NOTICE '  ✓ 7 tips for calculating and meeting your needs';
  RAISE NOTICE '';
  RAISE NOTICE 'Mobile can display these in tab-specific accordions';
  RAISE NOTICE '';
END $$;

COMMIT;
