-- =====================================================
-- Fix Primary/Detail Assignments
-- =====================================================
-- Rule: Primary = 1 main high-level metric
-- Detail = all breakdowns, comparisons, sub-metrics
-- =====================================================

BEGIN;

-- =====================================================
-- STEP 1: Rename DISP_PROTEIN_SERVINGS → DISP_PROTEIN_GRAMS
-- =====================================================

-- Rename DISP_PROTEIN_SERVINGS → DISP_PROTEIN_GRAMS
-- Delete all FK references first (no CASCADE on these FKs)
DELETE FROM display_metrics_aggregations WHERE metric_id = 'DISP_PROTEIN_SERVINGS';
DELETE FROM display_screens_primary_display_metrics WHERE metric_id = 'DISP_PROTEIN_SERVINGS';
DELETE FROM display_screens_detail_display_metrics WHERE metric_id = 'DISP_PROTEIN_SERVINGS';

-- Now update the metric itself
UPDATE display_metrics
SET metric_id = 'DISP_PROTEIN_GRAMS',
    metric_name = 'Protein',
    description = 'Total protein intake in grams'
WHERE metric_id = 'DISP_PROTEIN_SERVINGS';

-- Remove duplicate protein per kg metric
DELETE FROM display_metrics
WHERE metric_id = 'DISP_PROTEIN_PER_KILOGRAM_BODY_WEIGHT'
  AND EXISTS (SELECT 1 FROM display_metrics WHERE metric_id = 'DISP_PROTEIN_PER_KG');

-- =====================================================
-- STEP 2: Clear ALL Primary Assignments (Start Fresh)
-- =====================================================

DELETE FROM display_screens_primary_display_metrics;

-- =====================================================
-- STEP 3: Assign ONE Primary Metric Per Screen
-- =====================================================

-- PROTEIN: Main metric = Protein Grams
INSERT INTO display_screens_primary_display_metrics (primary_screen_id, metric_id, display_order, is_featured)
SELECT 'SCREEN_PROTEIN_PRIMARY', 'DISP_PROTEIN_GRAMS', 1, true
WHERE EXISTS (SELECT 1 FROM display_metrics WHERE metric_id = 'DISP_PROTEIN_GRAMS');

-- FIBER: Main metric = Fiber Grams
INSERT INTO display_screens_primary_display_metrics (primary_screen_id, metric_id, display_order, is_featured)
SELECT 'SCREEN_FIBER_PRIMARY', 'DISP_FIBER_GRAMS', 1, true
WHERE EXISTS (SELECT 1 FROM display_metrics WHERE metric_id = 'DISP_FIBER_GRAMS');

-- VEGETABLES: Main metric = Vegetable Servings (need to find the right one)
INSERT INTO display_screens_primary_display_metrics (primary_screen_id, metric_id, display_order, is_featured)
SELECT 'SCREEN_VEGETABLES_PRIMARY', metric_id, 1, true
FROM display_metrics
WHERE metric_name ILIKE 'Vegetable%' AND metric_id NOT LIKE '%MEAL%' AND metric_id NOT LIKE '%SOURCE%'
LIMIT 1;

-- FRUITS: Main metric = Fruit Servings
INSERT INTO display_screens_primary_display_metrics (primary_screen_id, metric_id, display_order, is_featured)
SELECT 'SCREEN_FRUITS_PRIMARY', metric_id, 1, true
FROM display_metrics
WHERE metric_name ILIKE 'Fruit%' AND metric_id NOT LIKE '%MEAL%' AND metric_id NOT LIKE '%SOURCE%'
LIMIT 1;

-- WATER: Main metric = Water Consumption
INSERT INTO display_screens_primary_display_metrics (primary_screen_id, metric_id, display_order, is_featured)
SELECT 'SCREEN_HYDRATION_PRIMARY', 'DISP_WATER_CONSUMPTION', 1, true
WHERE EXISTS (SELECT 1 FROM display_metrics WHERE metric_id = 'DISP_WATER_CONSUMPTION');

-- SLEEP: Main metric = Sleep Analysis
INSERT INTO display_screens_primary_display_metrics (primary_screen_id, metric_id, display_order, is_featured)
SELECT 'SCREEN_SLEEP_ANALYSIS_PRIMARY', 'DISP_SLEEP_ANALYSIS', 1, true
WHERE EXISTS (SELECT 1 FROM display_metrics WHERE metric_id = 'DISP_SLEEP_ANALYSIS');

-- SLEEP: Alternate = Sleep Duration
INSERT INTO display_screens_primary_display_metrics (primary_screen_id, metric_id, display_order, is_featured)
SELECT 'SCREEN_SLEEP_PRIMARY', 'DISP_SLEEP_DURATION', 1, true
WHERE EXISTS (SELECT 1 FROM display_metrics WHERE metric_id = 'DISP_SLEEP_DURATION');

-- STEPS: Main metric = Steps
INSERT INTO display_screens_primary_display_metrics (primary_screen_id, metric_id, display_order, is_featured)
SELECT 'SCREEN_STEPS_PRIMARY', 'DISP_STEPS', 1, true
WHERE EXISTS (SELECT 1 FROM display_metrics WHERE metric_id = 'DISP_STEPS');

-- CARDIO: Main metric = Zone 2 Duration or Sessions
INSERT INTO display_screens_primary_display_metrics (primary_screen_id, metric_id, display_order, is_featured)
SELECT 'SCREEN_CARDIO_PRIMARY', metric_id, 1, true
FROM display_metrics
WHERE (metric_id LIKE '%ZONE2%' OR metric_id LIKE '%CARDIO%') AND metric_id LIKE '%DURATION%'
LIMIT 1;

-- STRENGTH: Main metric = Strength Sessions
INSERT INTO display_screens_primary_display_metrics (primary_screen_id, metric_id, display_order, is_featured)
SELECT 'SCREEN_STRENGTH_PRIMARY', metric_id, 1, true
FROM display_metrics
WHERE metric_id LIKE '%STRENGTH%' AND metric_id LIKE '%SESSIONS%'
LIMIT 1;

-- BIOMETRICS: Main = Weight
INSERT INTO display_screens_primary_display_metrics (primary_screen_id, metric_id, display_order, is_featured)
SELECT 'SCREEN_BIOMETRICS_PRIMARY', 'DISP_WEIGHT', 1, true
WHERE EXISTS (SELECT 1 FROM display_metrics WHERE metric_id = 'DISP_WEIGHT');

-- For all other screens, pick the first metric alphabetically as primary
INSERT INTO display_screens_primary_display_metrics (primary_screen_id, metric_id, display_order, is_featured)
SELECT
  dsp.primary_screen_id,
  (
    SELECT dm.metric_id
    FROM display_metrics dm
    JOIN display_screens_detail_display_metrics ddm ON ddm.metric_id = dm.metric_id
    WHERE ddm.detail_screen_id = REPLACE(dsp.primary_screen_id, '_PRIMARY', '_DETAIL')
    ORDER BY dm.metric_name
    LIMIT 1
  ),
  1,
  true
FROM display_screens_primary dsp
WHERE NOT EXISTS (
  SELECT 1
  FROM display_screens_primary_display_metrics pdm
  WHERE pdm.primary_screen_id = dsp.primary_screen_id
)
AND EXISTS (
  SELECT 1
  FROM display_screens_detail_display_metrics ddm
  WHERE ddm.detail_screen_id = REPLACE(dsp.primary_screen_id, '_PRIMARY', '_DETAIL')
);

-- =====================================================
-- STEP 4: Keep Detail Assignments (Already Good)
-- =====================================================
-- Detail screens already have breakdowns, no changes needed

-- =====================================================
-- VERIFICATION
-- =====================================================

DO $$
DECLARE
  screens_with_one INT;
  screens_with_two_plus INT;
  screens_with_zero INT;
BEGIN
  SELECT COUNT(*) INTO screens_with_one
  FROM (
    SELECT primary_screen_id, COUNT(*) as cnt
    FROM display_screens_primary_display_metrics
    GROUP BY primary_screen_id
    HAVING COUNT(*) = 1
  ) sub;

  SELECT COUNT(*) INTO screens_with_two_plus
  FROM (
    SELECT primary_screen_id, COUNT(*) as cnt
    FROM display_screens_primary_display_metrics
    GROUP BY primary_screen_id
    HAVING COUNT(*) >= 2
  ) sub;

  SELECT COUNT(*) INTO screens_with_zero
  FROM display_screens_primary dsp
  WHERE NOT EXISTS (
    SELECT 1 FROM display_screens_primary_display_metrics pdm
    WHERE pdm.primary_screen_id = dsp.primary_screen_id
  );

  RAISE NOTICE '✅ Primary Screen Assignments Fixed';
  RAISE NOTICE '';
  RAISE NOTICE 'Primary Screens:';
  RAISE NOTICE '  With 1 metric: %', screens_with_one;
  RAISE NOTICE '  With 2+ metrics: %', screens_with_two_plus;
  RAISE NOTICE '  With 0 metrics: %', screens_with_zero;
  RAISE NOTICE '';
  RAISE NOTICE 'Rule: Primary = 1 main high-level metric';
END $$;

-- Show examples
SELECT
  dsp.title as screen,
  COUNT(pdm.metric_id) as metric_count,
  string_agg(dm.metric_name, ', ') as metrics
FROM display_screens_primary dsp
LEFT JOIN display_screens_primary_display_metrics pdm ON pdm.primary_screen_id = dsp.primary_screen_id
LEFT JOIN display_metrics dm ON dm.metric_id = pdm.metric_id
GROUP BY dsp.primary_screen_id, dsp.title
ORDER BY metric_count DESC, screen
LIMIT 20;

COMMIT;
