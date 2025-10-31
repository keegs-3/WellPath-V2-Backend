-- =====================================================
-- Create Complete Fiber Nutrition Component
-- =====================================================
-- Following the protein pattern for fiber tracking
-- Created: 2025-10-25
-- =====================================================

BEGIN;

-- =====================================================
-- 1. Create Data Entry Fields
-- =====================================================

-- Main fiber quantity field (DEF_FIBER_GRAMS already exists from earlier migration)
-- Just ensure it's properly configured
UPDATE data_entry_fields
SET
  field_name = 'fiber_grams',
  display_name = 'Fiber (grams)',
  description = 'Fiber intake in grams',
  field_type = 'quantity',
  data_type = 'numeric',
  unit = 'gram',
  pillar_name = 'Healthful Nutrition',
  is_active = true,
  validation_config = '{"min": 0, "max": 100, "increment": 0.5}'::jsonb
WHERE field_id = 'DEF_FIBER_GRAMS';

-- Fiber Type field
INSERT INTO data_entry_fields (
  field_id,
  field_name,
  display_name,
  description,
  field_type,
  data_type,
  reference_table,
  pillar_name,
  is_active
) VALUES (
  'DEF_FIBER_TYPE',
  'fiber_type',
  'Fiber Type',
  'Type of fiber consumed (soluble, insoluble, uncategorized)',
  'reference',
  'uuid',
  'data_entry_fields_reference',
  'Healthful Nutrition',
  true
) ON CONFLICT (field_id) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  reference_table = EXCLUDED.reference_table,
  updated_at = NOW();

-- =====================================================
-- 2. Create Reference Data for Fiber Types
-- =====================================================

INSERT INTO data_entry_fields_reference (
  reference_category,
  reference_key,
  display_name,
  description,
  sort_order,
  is_active
) VALUES
  (
    'fiber_types',
    'soluble_fiber',
    'Soluble Fiber',
    'Dissolves in water to form a gel-like substance (oats, beans, apples, citrus)',
    1,
    true
  ),
  (
    'fiber_types',
    'insoluble_fiber',
    'Insoluble Fiber',
    'Does not dissolve in water, aids digestion (whole grains, vegetables, wheat bran)',
    2,
    true
  ),
  (
    'fiber_types',
    'uncategorized',
    'Uncategorized',
    'Fiber without a specified type',
    3,
    true
  )
ON CONFLICT (reference_category, reference_key) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  sort_order = EXCLUDED.sort_order,
  updated_at = NOW();

-- =====================================================
-- 3. Create Main Aggregation Metric
-- =====================================================

-- Main total fiber aggregation
INSERT INTO aggregation_metrics (
  agg_id,
  metric_name,
  display_name,
  description,
  output_unit,
  is_active
) VALUES (
  'AGG_FIBER_GRAMS',
  'fiber_grams',
  'Total Fiber',
  'Total fiber intake in grams',
  'gram',
  true
) ON CONFLICT (agg_id) DO UPDATE SET
  metric_name = EXCLUDED.metric_name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  output_unit = EXCLUDED.output_unit,
  updated_at = NOW();

-- =====================================================
-- 4. Create Timing Aggregations (6 meal timings)
-- =====================================================

INSERT INTO aggregation_metrics (
  agg_id,
  metric_name,
  display_name,
  description,
  output_unit,
  is_active
) VALUES
  (
    'AGG_FIBER_BREAKFAST_GRAMS',
    'fiber_breakfast_grams',
    'Breakfast Fiber',
    'Fiber consumed at breakfast',
    'gram',
    true
  ),
  (
    'AGG_FIBER_MORNING_SNACK_GRAMS',
    'fiber_morning_snack_grams',
    'Morning Snack Fiber',
    'Fiber consumed during morning snack',
    'gram',
    true
  ),
  (
    'AGG_FIBER_LUNCH_GRAMS',
    'fiber_lunch_grams',
    'Lunch Fiber',
    'Fiber consumed at lunch',
    'gram',
    true
  ),
  (
    'AGG_FIBER_AFTERNOON_SNACK_GRAMS',
    'fiber_afternoon_snack_grams',
    'Afternoon Snack Fiber',
    'Fiber consumed during afternoon snack',
    'gram',
    true
  ),
  (
    'AGG_FIBER_DINNER_GRAMS',
    'fiber_dinner_grams',
    'Dinner Fiber',
    'Fiber consumed at dinner',
    'gram',
    true
  ),
  (
    'AGG_FIBER_EVENING_SNACK_GRAMS',
    'fiber_evening_snack_grams',
    'Evening Snack Fiber',
    'Fiber consumed during evening snack',
    'gram',
    true
  )
ON CONFLICT (agg_id) DO UPDATE SET
  metric_name = EXCLUDED.metric_name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  output_unit = EXCLUDED.output_unit,
  updated_at = NOW();

-- =====================================================
-- 5. Create Type Aggregations (3 fiber types)
-- =====================================================

INSERT INTO aggregation_metrics (
  agg_id,
  metric_name,
  display_name,
  description,
  output_unit,
  is_active
) VALUES
  (
    'AGG_FIBER_TYPE_SOLUBLE',
    'fiber_type_soluble',
    'Soluble Fiber',
    'Soluble fiber intake',
    'gram',
    true
  ),
  (
    'AGG_FIBER_TYPE_INSOLUBLE',
    'fiber_type_insoluble',
    'Insoluble Fiber',
    'Insoluble fiber intake',
    'gram',
    true
  ),
  (
    'AGG_FIBER_TYPE_UNCATEGORIZED',
    'fiber_type_uncategorized',
    'Uncategorized Fiber',
    'Fiber without specified type',
    'gram',
    true
  )
ON CONFLICT (agg_id) DO UPDATE SET
  metric_name = EXCLUDED.metric_name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  output_unit = EXCLUDED.output_unit,
  updated_at = NOW();

-- =====================================================
-- 6. Create Dependencies
-- =====================================================

-- Main aggregation dependency
INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id,
  data_entry_field_id,
  dependency_type
) VALUES (
  'AGG_FIBER_GRAMS',
  'DEF_FIBER_GRAMS',
  'data_field'
) ON CONFLICT DO NOTHING;

-- Timing aggregation dependencies (with filter conditions)
INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id,
  data_entry_field_id,
  dependency_type,
  filter_conditions
) VALUES
  (
    'AGG_FIBER_BREAKFAST_GRAMS',
    'DEF_FIBER_GRAMS',
    'data_field',
    '{"reference_field": "DEF_FOOD_TIMING", "reference_value": "breakfast"}'::jsonb
  ),
  (
    'AGG_FIBER_MORNING_SNACK_GRAMS',
    'DEF_FIBER_GRAMS',
    'data_field',
    '{"reference_field": "DEF_FOOD_TIMING", "reference_value": "morning_snack"}'::jsonb
  ),
  (
    'AGG_FIBER_LUNCH_GRAMS',
    'DEF_FIBER_GRAMS',
    'data_field',
    '{"reference_field": "DEF_FOOD_TIMING", "reference_value": "lunch"}'::jsonb
  ),
  (
    'AGG_FIBER_AFTERNOON_SNACK_GRAMS',
    'DEF_FIBER_GRAMS',
    'data_field',
    '{"reference_field": "DEF_FOOD_TIMING", "reference_value": "afternoon_snack"}'::jsonb
  ),
  (
    'AGG_FIBER_DINNER_GRAMS',
    'DEF_FIBER_GRAMS',
    'data_field',
    '{"reference_field": "DEF_FOOD_TIMING", "reference_value": "dinner"}'::jsonb
  ),
  (
    'AGG_FIBER_EVENING_SNACK_GRAMS',
    'DEF_FIBER_GRAMS',
    'data_field',
    '{"reference_field": "DEF_FOOD_TIMING", "reference_value": "evening_snack"}'::jsonb
  )
ON CONFLICT DO NOTHING;

-- Type aggregation dependencies (with filter conditions)
INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id,
  data_entry_field_id,
  dependency_type,
  filter_conditions
) VALUES
  (
    'AGG_FIBER_TYPE_SOLUBLE',
    'DEF_FIBER_GRAMS',
    'data_field',
    '{"reference_field": "DEF_FIBER_TYPE", "reference_value": "soluble_fiber"}'::jsonb
  ),
  (
    'AGG_FIBER_TYPE_INSOLUBLE',
    'DEF_FIBER_GRAMS',
    'data_field',
    '{"reference_field": "DEF_FIBER_TYPE", "reference_value": "insoluble_fiber"}'::jsonb
  ),
  (
    'AGG_FIBER_TYPE_UNCATEGORIZED',
    'DEF_FIBER_GRAMS',
    'data_field',
    '{"reference_field": "DEF_FIBER_TYPE", "reference_value": "uncategorized"}'::jsonb
  )
ON CONFLICT DO NOTHING;

-- =====================================================
-- 7. Create Calculation Types (SUM and AVG for all)
-- =====================================================

INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
SELECT agg_id, calc_type
FROM (VALUES
  ('AGG_FIBER_GRAMS'),
  ('AGG_FIBER_BREAKFAST_GRAMS'),
  ('AGG_FIBER_MORNING_SNACK_GRAMS'),
  ('AGG_FIBER_LUNCH_GRAMS'),
  ('AGG_FIBER_AFTERNOON_SNACK_GRAMS'),
  ('AGG_FIBER_DINNER_GRAMS'),
  ('AGG_FIBER_EVENING_SNACK_GRAMS'),
  ('AGG_FIBER_TYPE_SOLUBLE'),
  ('AGG_FIBER_TYPE_INSOLUBLE'),
  ('AGG_FIBER_TYPE_UNCATEGORIZED')
) AS aggs(agg_id)
CROSS JOIN (VALUES ('SUM'), ('AVG')) AS calc_types(calc_type)
ON CONFLICT DO NOTHING;

-- =====================================================
-- 8. Create Periods (hourly, daily, weekly, monthly, 6month, yearly)
-- =====================================================

INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
SELECT agg_id, period
FROM (VALUES
  ('AGG_FIBER_GRAMS'),
  ('AGG_FIBER_BREAKFAST_GRAMS'),
  ('AGG_FIBER_MORNING_SNACK_GRAMS'),
  ('AGG_FIBER_LUNCH_GRAMS'),
  ('AGG_FIBER_AFTERNOON_SNACK_GRAMS'),
  ('AGG_FIBER_DINNER_GRAMS'),
  ('AGG_FIBER_EVENING_SNACK_GRAMS'),
  ('AGG_FIBER_TYPE_SOLUBLE'),
  ('AGG_FIBER_TYPE_INSOLUBLE'),
  ('AGG_FIBER_TYPE_UNCATEGORIZED')
) AS aggs(agg_id)
CROSS JOIN (VALUES ('hourly'), ('daily'), ('weekly'), ('monthly'), ('6month'), ('yearly')) AS periods(period)
ON CONFLICT DO NOTHING;

-- =====================================================
-- 9. Create Display Metrics
-- =====================================================

-- Main total display metric
INSERT INTO display_metrics (
  metric_id,
  metric_name,
  description,
  pillar,
  chart_type_id,
  is_active,
  is_primary
) VALUES (
  'DISP_FIBER_GRAMS',
  'Fiber',
  'Total fiber intake in grams',
  'Healthful Nutrition',
  'bar_vertical',
  true,
  true
) ON CONFLICT (metric_id) DO UPDATE SET
  metric_name = EXCLUDED.metric_name,
  description = EXCLUDED.description,
  chart_type_id = EXCLUDED.chart_type_id,
  updated_at = NOW();

-- Meal timing display metric (stacked bar)
INSERT INTO display_metrics (
  metric_id,
  metric_name,
  description,
  pillar,
  chart_type_id,
  is_active,
  is_primary
) VALUES (
  'DISP_FIBER_MEAL_TIMING',
  'Fiber by Meal',
  'Fiber intake breakdown by meal timing (breakfast, lunch, dinner, snacks)',
  'Healthful Nutrition',
  'bar_stacked',
  true,
  false
) ON CONFLICT (metric_id) DO UPDATE SET
  metric_name = EXCLUDED.metric_name,
  description = EXCLUDED.description,
  chart_type_id = EXCLUDED.chart_type_id,
  updated_at = NOW();

-- Type breakdown display metric (stacked bar)
INSERT INTO display_metrics (
  metric_id,
  metric_name,
  description,
  pillar,
  chart_type_id,
  is_active,
  is_primary
) VALUES (
  'DISP_FIBER_TYPE',
  'Fiber by Type',
  'Breakdown of fiber intake by type (soluble, insoluble, uncategorized)',
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
-- 10. Map Aggregations to Display Metrics
-- =====================================================

-- Main total (daily SUM, weekly AVG, monthly AVG, yearly AVG)
INSERT INTO display_metrics_aggregations (
  metric_id,
  agg_metric_id,
  period_type,
  calculation_type_id,
  display_order
) VALUES
  ('DISP_FIBER_GRAMS', 'AGG_FIBER_GRAMS', 'daily', 'SUM', 1),
  ('DISP_FIBER_GRAMS', 'AGG_FIBER_GRAMS', 'weekly', 'AVG', 2),
  ('DISP_FIBER_GRAMS', 'AGG_FIBER_GRAMS', 'monthly', 'AVG', 3),
  ('DISP_FIBER_GRAMS', 'AGG_FIBER_GRAMS', 'yearly', 'AVG', 4)
ON CONFLICT DO NOTHING;

-- Meal timing breakdown (daily SUM, weekly AVG for each timing)
INSERT INTO display_metrics_aggregations (
  metric_id,
  agg_metric_id,
  period_type,
  calculation_type_id,
  display_order
) VALUES
  -- Daily SUM
  ('DISP_FIBER_MEAL_TIMING', 'AGG_FIBER_BREAKFAST_GRAMS', 'daily', 'SUM', 1),
  ('DISP_FIBER_MEAL_TIMING', 'AGG_FIBER_MORNING_SNACK_GRAMS', 'daily', 'SUM', 2),
  ('DISP_FIBER_MEAL_TIMING', 'AGG_FIBER_LUNCH_GRAMS', 'daily', 'SUM', 3),
  ('DISP_FIBER_MEAL_TIMING', 'AGG_FIBER_AFTERNOON_SNACK_GRAMS', 'daily', 'SUM', 4),
  ('DISP_FIBER_MEAL_TIMING', 'AGG_FIBER_DINNER_GRAMS', 'daily', 'SUM', 5),
  ('DISP_FIBER_MEAL_TIMING', 'AGG_FIBER_EVENING_SNACK_GRAMS', 'daily', 'SUM', 6),

  -- Weekly AVG
  ('DISP_FIBER_MEAL_TIMING', 'AGG_FIBER_BREAKFAST_GRAMS', 'weekly', 'AVG', 7),
  ('DISP_FIBER_MEAL_TIMING', 'AGG_FIBER_MORNING_SNACK_GRAMS', 'weekly', 'AVG', 8),
  ('DISP_FIBER_MEAL_TIMING', 'AGG_FIBER_LUNCH_GRAMS', 'weekly', 'AVG', 9),
  ('DISP_FIBER_MEAL_TIMING', 'AGG_FIBER_AFTERNOON_SNACK_GRAMS', 'weekly', 'AVG', 10),
  ('DISP_FIBER_MEAL_TIMING', 'AGG_FIBER_DINNER_GRAMS', 'weekly', 'AVG', 11),
  ('DISP_FIBER_MEAL_TIMING', 'AGG_FIBER_EVENING_SNACK_GRAMS', 'weekly', 'AVG', 12)
ON CONFLICT DO NOTHING;

-- Type breakdown (daily SUM, weekly AVG for each type)
INSERT INTO display_metrics_aggregations (
  metric_id,
  agg_metric_id,
  period_type,
  calculation_type_id,
  display_order
) VALUES
  -- Daily SUM
  ('DISP_FIBER_TYPE', 'AGG_FIBER_TYPE_SOLUBLE', 'daily', 'SUM', 1),
  ('DISP_FIBER_TYPE', 'AGG_FIBER_TYPE_INSOLUBLE', 'daily', 'SUM', 2),
  ('DISP_FIBER_TYPE', 'AGG_FIBER_TYPE_UNCATEGORIZED', 'daily', 'SUM', 3),

  -- Weekly AVG
  ('DISP_FIBER_TYPE', 'AGG_FIBER_TYPE_SOLUBLE', 'weekly', 'AVG', 4),
  ('DISP_FIBER_TYPE', 'AGG_FIBER_TYPE_INSOLUBLE', 'weekly', 'AVG', 5),
  ('DISP_FIBER_TYPE', 'AGG_FIBER_TYPE_UNCATEGORIZED', 'weekly', 'AVG', 6)
ON CONFLICT DO NOTHING;

-- =====================================================
-- 11. Create Display Screens
-- =====================================================

-- Primary screen
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
  'SCREEN_FIBER',
  'Fiber',
  'Track your fiber intake by grams, timing, and type',
  'Healthful Nutrition',
  'fiber',
  'D',
  'detailed',
  11,
  'detailed',
  true
) ON CONFLICT (screen_id) DO UPDATE SET
  name = EXCLUDED.name,
  overview = EXCLUDED.overview,
  pillar = EXCLUDED.pillar,
  updated_at = NOW();

-- Detail screen configuration
INSERT INTO display_screens_detail (
  display_screen_id,
  title,
  subtitle,
  description,
  layout_type,
  section_config,
  show_insights,
  is_active
) VALUES (
  'SCREEN_FIBER',
  'Fiber Tracking',
  'Optimize your fiber intake',
  'Monitor total fiber intake, meal timing distribution, and fiber type (soluble vs insoluble) for optimal digestive health and wellness.',
  'sections',
  jsonb_build_array(
    jsonb_build_object(
      'section_id', 'fiber_overview',
      'section_title', 'Fiber Overview',
      'section_type', 'metrics_grid',
      'display_order', 1
    ),
    jsonb_build_object(
      'section_id', 'fiber_details',
      'section_title', 'Detailed Breakdown',
      'section_type', 'metrics_detailed',
      'display_order', 2
    )
  ),
  true,
  true
) ON CONFLICT (display_screen_id) DO UPDATE SET
  title = EXCLUDED.title,
  subtitle = EXCLUDED.subtitle,
  description = EXCLUDED.description,
  section_config = EXCLUDED.section_config,
  updated_at = NOW();

-- =====================================================
-- 12. Link Display Metrics to Detail Screen
-- =====================================================

-- Overview Section: Total fiber grams
INSERT INTO display_screens_detail_display_metrics (
  detail_screen_id,
  metric_id,
  section_id,
  display_order,
  context_label,
  context_description
) VALUES
  (
    'SCREEN_FIBER_DETAIL',
    'DISP_FIBER_GRAMS',
    'fiber_overview',
    1,
    'Total Fiber',
    'Your total fiber intake in grams per day'
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
    'SCREEN_FIBER_DETAIL',
    'DISP_FIBER_MEAL_TIMING',
    'fiber_details',
    1,
    'Fiber by Meal',
    'Distribution of fiber intake across breakfast, lunch, dinner, and snacks'
  ),
  (
    'SCREEN_FIBER_DETAIL',
    'DISP_FIBER_TYPE',
    'fiber_details',
    2,
    'Fiber by Type',
    'Breakdown by fiber type: soluble, insoluble, and uncategorized'
  )
ON CONFLICT (detail_screen_id, metric_id, section_id) DO UPDATE SET
  display_order = EXCLUDED.display_order,
  context_label = EXCLUDED.context_label,
  context_description = EXCLUDED.context_description,
  updated_at = NOW();

-- =====================================================
-- Summary and Verification
-- =====================================================

DO $$
DECLARE
  v_fields_count INTEGER;
  v_reference_count INTEGER;
  v_agg_metrics_count INTEGER;
  v_dependencies_count INTEGER;
  v_calc_types_count INTEGER;
  v_periods_count INTEGER;
  v_display_metrics_count INTEGER;
  v_display_agg_count INTEGER;
  v_screen_count INTEGER;
BEGIN
  -- Count data entry fields
  SELECT COUNT(*) INTO v_fields_count
  FROM data_entry_fields
  WHERE field_id IN ('DEF_FIBER_GRAMS', 'DEF_FIBER_TYPE');

  -- Count reference values
  SELECT COUNT(*) INTO v_reference_count
  FROM data_entry_fields_reference
  WHERE reference_category = 'fiber_types';

  -- Count aggregation metrics
  SELECT COUNT(*) INTO v_agg_metrics_count
  FROM aggregation_metrics
  WHERE agg_id LIKE 'AGG_FIBER%';

  -- Count dependencies
  SELECT COUNT(*) INTO v_dependencies_count
  FROM aggregation_metrics_dependencies
  WHERE agg_metric_id LIKE 'AGG_FIBER%';

  -- Count calculation types
  SELECT COUNT(*) INTO v_calc_types_count
  FROM aggregation_metrics_calculation_types
  WHERE aggregation_metric_id LIKE 'AGG_FIBER%';

  -- Count periods
  SELECT COUNT(*) INTO v_periods_count
  FROM aggregation_metrics_periods
  WHERE agg_metric_id LIKE 'AGG_FIBER%';

  -- Count display metrics
  SELECT COUNT(*) INTO v_display_metrics_count
  FROM display_metrics
  WHERE metric_id LIKE 'DISP_FIBER%';

  -- Count display aggregations
  SELECT COUNT(*) INTO v_display_agg_count
  FROM display_metrics_aggregations
  WHERE metric_id LIKE 'DISP_FIBER%';

  -- Count screens
  SELECT COUNT(*) INTO v_screen_count
  FROM display_screens
  WHERE screen_id = 'SCREEN_FIBER';

  RAISE NOTICE '';
  RAISE NOTICE '========================================';
  RAISE NOTICE 'Fiber Nutrition Component Created!';
  RAISE NOTICE '========================================';
  RAISE NOTICE '';
  RAISE NOTICE 'Component Summary:';
  RAISE NOTICE '  Data Entry Fields: % (DEF_FIBER_GRAMS, DEF_FIBER_TYPE)', v_fields_count;
  RAISE NOTICE '  Reference Values: % fiber types', v_reference_count;
  RAISE NOTICE '  Aggregation Metrics: % (1 total + 6 timing + 3 type)', v_agg_metrics_count;
  RAISE NOTICE '  Dependencies: % (with filter conditions for timing and type)', v_dependencies_count;
  RAISE NOTICE '  Calculation Types: % (SUM + AVG for all metrics)', v_calc_types_count;
  RAISE NOTICE '  Periods: % (hourly, daily, weekly, monthly, 6month, yearly)', v_periods_count;
  RAISE NOTICE '  Display Metrics: % (total, timing, type)', v_display_metrics_count;
  RAISE NOTICE '  Display Aggregations: % (mapped to display metrics)', v_display_agg_count;
  RAISE NOTICE '  Display Screens: %', v_screen_count;
  RAISE NOTICE '';
  RAISE NOTICE 'Data Entry Fields:';
  RAISE NOTICE '  DEF_FIBER_GRAMS - Main quantity field (grams)';
  RAISE NOTICE '  DEF_FIBER_TYPE - Reference to fiber type category';
  RAISE NOTICE '  DEF_FOOD_TIMING - Shared timing field (breakfast, lunch, etc.)';
  RAISE NOTICE '';
  RAISE NOTICE 'Fiber Types (3):';
  RAISE NOTICE '  1. Soluble Fiber (dissolves in water, forms gel)';
  RAISE NOTICE '  2. Insoluble Fiber (does not dissolve, aids digestion)';
  RAISE NOTICE '  3. Uncategorized (fiber without specified type)';
  RAISE NOTICE '';
  RAISE NOTICE 'Aggregation Metrics (10 total):';
  RAISE NOTICE '  Main Total:';
  RAISE NOTICE '    AGG_FIBER_GRAMS';
  RAISE NOTICE '';
  RAISE NOTICE '  Timing Breakdown (6):';
  RAISE NOTICE '    AGG_FIBER_BREAKFAST_GRAMS';
  RAISE NOTICE '    AGG_FIBER_MORNING_SNACK_GRAMS';
  RAISE NOTICE '    AGG_FIBER_LUNCH_GRAMS';
  RAISE NOTICE '    AGG_FIBER_AFTERNOON_SNACK_GRAMS';
  RAISE NOTICE '    AGG_FIBER_DINNER_GRAMS';
  RAISE NOTICE '    AGG_FIBER_EVENING_SNACK_GRAMS';
  RAISE NOTICE '';
  RAISE NOTICE '  Type Breakdown (3):';
  RAISE NOTICE '    AGG_FIBER_TYPE_SOLUBLE';
  RAISE NOTICE '    AGG_FIBER_TYPE_INSOLUBLE';
  RAISE NOTICE '    AGG_FIBER_TYPE_UNCATEGORIZED';
  RAISE NOTICE '';
  RAISE NOTICE 'Display Metrics (3):';
  RAISE NOTICE '  DISP_FIBER_GRAMS - Total fiber grams (primary)';
  RAISE NOTICE '  DISP_FIBER_MEAL_TIMING - Stacked bar by meal timing';
  RAISE NOTICE '  DISP_FIBER_TYPE - Stacked bar by fiber type';
  RAISE NOTICE '';
  RAISE NOTICE 'Display Screens:';
  RAISE NOTICE '  SCREEN_FIBER - Primary fiber tracking screen';
  RAISE NOTICE '  SCREEN_FIBER_DETAIL - Detail view with sections:';
  RAISE NOTICE '    - fiber_overview (total grams)';
  RAISE NOTICE '    - fiber_details (timing + type breakdown)';
  RAISE NOTICE '';
  RAISE NOTICE 'Pattern Match with Protein:';
  RAISE NOTICE '  ✓ Main quantity field (GRAMS)';
  RAISE NOTICE '  ✓ Type reference field';
  RAISE NOTICE '  ✓ 6 timing aggregations';
  RAISE NOTICE '  ✓ 3 type aggregations';
  RAISE NOTICE '  ✓ Conditional filtering via filter_conditions';
  RAISE NOTICE '  ✓ SUM and AVG calculation types';
  RAISE NOTICE '  ✓ All 6 period types';
  RAISE NOTICE '  ✓ Display metrics and aggregations';
  RAISE NOTICE '  ✓ Display screens and detail sections';
  RAISE NOTICE '';
  RAISE NOTICE 'Next Steps:';
  RAISE NOTICE '  1. Generate test data for fiber';
  RAISE NOTICE '  2. Run aggregations to populate cache';
  RAISE NOTICE '  3. Verify display metrics show correct data';
  RAISE NOTICE '  4. Test mobile UI with fiber tracking';
  RAISE NOTICE '';
  RAISE NOTICE '========================================';
  RAISE NOTICE '';
END $$;

COMMIT;
