-- =====================================================
-- Create Complete Protein Screen
-- =====================================================
-- Creates:
-- 1. DISP_PROTEIN_TYPE display metric
-- 2. Maps all 6 protein type aggregations
-- 3. Creates SCREEN_PROTEIN display screen
-- 4. Creates detail screen
-- 5. Links all 4 protein metrics to the detail screen
-- =====================================================

BEGIN;

-- =====================================================
-- 1. Create DISP_PROTEIN_TYPE Display Metric
-- =====================================================
INSERT INTO display_metrics (
  metric_id,
  metric_name,
  description,
  pillar,
  chart_type_id,
  is_active,
  is_primary
) VALUES (
  'DISP_PROTEIN_TYPE',
  'Protein by Type',
  'Breakdown of protein consumption by source type (fatty fish, lean protein, plant-based, etc.)',
  'Healthful Nutrition',
  'bar_stacked',
  true,
  false
) ON CONFLICT (metric_id) DO UPDATE SET
  metric_name = EXCLUDED.metric_name,
  description = EXCLUDED.description,
  chart_type_id = EXCLUDED.chart_type_id,
  updated_at = NOW();

-- =====================================================
-- 2. Map Protein Type Aggregations
-- =====================================================
-- Map all 6 protein type aggregations to the display metric
-- Using daily SUM and weekly AVG for each type

INSERT INTO display_metrics_aggregations (
  metric_id,
  agg_metric_id,
  period_type,
  calculation_type_id,
  display_order
) VALUES
  -- Daily SUM for all 6 types
  ('DISP_PROTEIN_TYPE', 'AGG_PROTEIN_TYPE_FATTY_FISH', 'daily', 'SUM', 1),
  ('DISP_PROTEIN_TYPE', 'AGG_PROTEIN_TYPE_LEAN_PROTEIN', 'daily', 'SUM', 2),
  ('DISP_PROTEIN_TYPE', 'AGG_PROTEIN_TYPE_PLANT_BASED', 'daily', 'SUM', 3),
  ('DISP_PROTEIN_TYPE', 'AGG_PROTEIN_TYPE_PROCESSED_MEAT', 'daily', 'SUM', 4),
  ('DISP_PROTEIN_TYPE', 'AGG_PROTEIN_TYPE_RED_MEAT', 'daily', 'SUM', 5),
  ('DISP_PROTEIN_TYPE', 'AGG_PROTEIN_TYPE_SUPPLEMENT', 'daily', 'SUM', 6),

  -- Weekly AVG for all 6 types
  ('DISP_PROTEIN_TYPE', 'AGG_PROTEIN_TYPE_FATTY_FISH', 'weekly', 'AVG', 7),
  ('DISP_PROTEIN_TYPE', 'AGG_PROTEIN_TYPE_LEAN_PROTEIN', 'weekly', 'AVG', 8),
  ('DISP_PROTEIN_TYPE', 'AGG_PROTEIN_TYPE_PLANT_BASED', 'weekly', 'AVG', 9),
  ('DISP_PROTEIN_TYPE', 'AGG_PROTEIN_TYPE_PROCESSED_MEAT', 'weekly', 'AVG', 10),
  ('DISP_PROTEIN_TYPE', 'AGG_PROTEIN_TYPE_RED_MEAT', 'weekly', 'AVG', 11),
  ('DISP_PROTEIN_TYPE', 'AGG_PROTEIN_TYPE_SUPPLEMENT', 'weekly', 'AVG', 12)
ON CONFLICT DO NOTHING;

-- =====================================================
-- 3. Create Protein Display Screen
-- =====================================================
INSERT INTO display_screens (
  screen_id,
  name,
  overview,
  pillar,
  icon,
  default_time_period,
  layout_type,
  display_order,
  screen_type,
  is_active
) VALUES (
  'SCREEN_PROTEIN',
  'Protein',
  'Track your protein intake by amount, timing, type, and ratio to body weight',
  'Healthful Nutrition',
  'nutrition',
  'D',
  'detailed',
  1,
  'detailed',
  true
) ON CONFLICT (screen_id) DO UPDATE SET
  name = EXCLUDED.name,
  overview = EXCLUDED.overview,
  pillar = EXCLUDED.pillar,
  updated_at = NOW();

-- =====================================================
-- 4. Update Detail Screen Configuration
-- =====================================================
UPDATE display_screens_detail SET
  title = 'Protein Tracking',
  subtitle = 'Optimize your protein intake',
  description = 'Monitor total protein consumption, meal timing distribution, protein sources, and protein-to-bodyweight ratio for optimal health and performance.',
  layout_type = 'sections',
  section_config = jsonb_build_array(
    jsonb_build_object(
      'section_id', 'protein_overview',
      'section_title', 'Protein Overview',
      'section_type', 'metrics_grid',
      'display_order', 1
    ),
    jsonb_build_object(
      'section_id', 'protein_details',
      'section_title', 'Detailed Breakdown',
      'section_type', 'metrics_detailed',
      'display_order', 2
    )
  ),
  show_insights = true,
  updated_at = NOW()
WHERE display_screen_id = 'SCREEN_PROTEIN';

-- =====================================================
-- 5. Link Display Metrics to Detail Screen
-- =====================================================
-- Overview Section: Protein Grams and Per Kg
INSERT INTO display_screens_detail_display_metrics (
  detail_screen_id,
  metric_id,
  section_id,
  display_order,
  context_label,
  context_description
) VALUES
  (
    'SCREEN_PROTEIN_DETAIL',
    'DISP_PROTEIN_GRAMS',
    'protein_overview',
    1,
    'Total Protein',
    'Your total protein intake in grams'
  ),
  (
    'SCREEN_PROTEIN_DETAIL',
    'DISP_PROTEIN_PER_KG',
    'protein_overview',
    2,
    'Protein Ratio',
    'Protein per kilogram of body weight'
  )
ON CONFLICT (detail_screen_id, metric_id, section_id) DO UPDATE SET
  display_order = EXCLUDED.display_order,
  context_label = EXCLUDED.context_label,
  context_description = EXCLUDED.context_description,
  updated_at = NOW();

-- Details Section: Timing and Type
INSERT INTO display_screens_detail_display_metrics (
  detail_screen_id,
  metric_id,
  section_id,
  display_order,
  context_label,
  context_description
) VALUES
  (
    'SCREEN_PROTEIN_DETAIL',
    'DISP_PROTEIN_MEAL_TIMING',
    'protein_details',
    1,
    'Protein by Meal',
    'Distribution of protein across breakfast, lunch, and dinner'
  ),
  (
    'SCREEN_PROTEIN_DETAIL',
    'DISP_PROTEIN_TYPE',
    'protein_details',
    2,
    'Protein by Source',
    'Breakdown by protein source type: fatty fish, lean protein, plant-based, processed meat, red meat, and supplements'
  )
ON CONFLICT (detail_screen_id, metric_id, section_id) DO UPDATE SET
  display_order = EXCLUDED.display_order,
  context_label = EXCLUDED.context_label,
  context_description = EXCLUDED.context_description,
  updated_at = NOW();

-- =====================================================
-- Summary
-- =====================================================
DO $$
DECLARE
  v_metric_count INTEGER;
  v_agg_count INTEGER;
  v_detail_metric_count INTEGER;
BEGIN
  -- Count display metrics
  SELECT COUNT(*) INTO v_metric_count
  FROM display_metrics
  WHERE metric_id LIKE 'DISP_PROTEIN%';

  -- Count aggregation mappings for protein type
  SELECT COUNT(*) INTO v_agg_count
  FROM display_metrics_aggregations
  WHERE metric_id = 'DISP_PROTEIN_TYPE';

  -- Count detail screen metrics
  SELECT COUNT(*) INTO v_detail_metric_count
  FROM display_screens_detail_display_metrics
  WHERE detail_screen_id = 'SCREEN_PROTEIN_DETAIL';

  RAISE NOTICE '';
  RAISE NOTICE '✅ Protein Screen Setup Complete!';
  RAISE NOTICE '';
  RAISE NOTICE 'Summary:';
  RAISE NOTICE '  Display Metrics: % total protein metrics', v_metric_count;
  RAISE NOTICE '  Protein Type Aggregations: % mappings (6 types × 2 periods)', v_agg_count;
  RAISE NOTICE '  Detail Screen Metrics: % metrics linked', v_detail_metric_count;
  RAISE NOTICE '';
  RAISE NOTICE 'Screen Structure:';
  RAISE NOTICE '  📱 SCREEN_PROTEIN → Protein tracking screen';
  RAISE NOTICE '  📄 SCREEN_PROTEIN_DETAIL → Detail view';
  RAISE NOTICE '';
  RAISE NOTICE 'Sections:';
  RAISE NOTICE '  📊 protein_overview:';
  RAISE NOTICE '     • DISP_PROTEIN_GRAMS - Total protein intake';
  RAISE NOTICE '     • DISP_PROTEIN_PER_KG - Protein per kg body weight';
  RAISE NOTICE '  📈 protein_details:';
  RAISE NOTICE '     • DISP_PROTEIN_MEAL_TIMING - Breakfast/Lunch/Dinner distribution';
  RAISE NOTICE '     • DISP_PROTEIN_TYPE - 6 protein source types';
  RAISE NOTICE '';
END $$;

COMMIT;
