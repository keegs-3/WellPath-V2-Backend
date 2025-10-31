-- =====================================================
-- Create Fruits Nutrition Component
-- =====================================================
-- Complete database structure for fruits tracking following protein pattern
-- Includes: data entry fields, reference data, aggregations, dependencies,
-- calculation types, periods, display metrics, and screens
-- =====================================================

BEGIN;

-- =====================================================
-- 1. Create Data Entry Fields
-- =====================================================

-- Main quantity field (servings)
INSERT INTO field_registry (
  field_id,
  field_name,
  display_name,
  description,
  field_type,
  data_type,
  unit,
  pillar,
  category,
  is_active,
  supports_apple_health_write
) VALUES (
  'DEF_FRUITS_SERVINGS',
  'fruits_servings',
  'Fruits Servings',
  'Number of fruit servings consumed',
  'quantity',
  'numeric',
  'serving',
  'Healthful Nutrition',
  'nutrition',
  true,
  false
) ON CONFLICT (field_id) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  updated_at = NOW();

-- Fruit type field (reference to data_entry_fields_reference)
INSERT INTO field_registry (
  field_id,
  field_name,
  display_name,
  description,
  field_type,
  data_type,
  reference_table,
  reference_category,
  pillar,
  category,
  is_active,
  supports_apple_health_write
) VALUES (
  'DEF_FRUITS_TYPE',
  'fruits_type',
  'Fruit Type',
  'Type of fruit consumed (berries, citrus, tropical, etc.)',
  'reference',
  'uuid',
  'data_entry_fields_reference',
  'fruits_types',
  'Healthful Nutrition',
  'nutrition',
  true,
  false
) ON CONFLICT (field_id) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  reference_category = EXCLUDED.reference_category,
  updated_at = NOW();

-- =====================================================
-- 2. Create Reference Data for Fruit Types
-- =====================================================

INSERT INTO data_entry_fields_reference (
  reference_category,
  reference_key,
  display_name,
  description,
  sort_order,
  is_active,
  icon_name,
  color_hex
) VALUES
  (
    'fruits_types',
    'berries',
    'Berries',
    'Strawberries, blueberries, raspberries, blackberries',
    1,
    true,
    'berry',
    '#DC143C'
  ),
  (
    'fruits_types',
    'citrus',
    'Citrus',
    'Oranges, grapefruits, lemons, limes, tangerines',
    2,
    true,
    'citrus',
    '#FFA500'
  ),
  (
    'fruits_types',
    'tropical',
    'Tropical',
    'Mango, pineapple, papaya, kiwi, passion fruit',
    3,
    true,
    'tropical',
    '#FFD700'
  ),
  (
    'fruits_types',
    'stone_fruits',
    'Stone Fruits',
    'Peaches, plums, nectarines, apricots, cherries',
    4,
    true,
    'stone_fruit',
    '#FF6347'
  ),
  (
    'fruits_types',
    'apples_pears',
    'Apples/Pears',
    'Apples, pears, and similar pome fruits',
    5,
    true,
    'apple',
    '#90EE90'
  ),
  (
    'fruits_types',
    'other',
    'Other',
    'Other fruits not in the above categories',
    6,
    true,
    'fruit',
    '#9370DB'
  )
ON CONFLICT (reference_category, reference_key) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  sort_order = EXCLUDED.sort_order,
  icon_name = EXCLUDED.icon_name,
  color_hex = EXCLUDED.color_hex,
  updated_at = NOW();

-- =====================================================
-- 3. Create Aggregation Metrics
-- =====================================================

-- Main total fruits aggregation
INSERT INTO aggregation_metrics (
  agg_id,
  metric_name,
  display_name,
  description,
  output_unit,
  is_active
) VALUES (
  'AGG_FRUITS_SERVINGS',
  'fruits_servings',
  'Total Fruits',
  'Total fruit servings consumed',
  'serving',
  true
) ON CONFLICT (agg_id) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  updated_at = NOW();

-- Timing breakdowns (6 metrics)
INSERT INTO aggregation_metrics (
  agg_id,
  metric_name,
  display_name,
  description,
  output_unit,
  is_active
) VALUES
  (
    'AGG_FRUITS_BREAKFAST_SERVINGS',
    'fruits_breakfast_servings',
    'Breakfast Fruits',
    'Fruit servings consumed at breakfast',
    'serving',
    true
  ),
  (
    'AGG_FRUITS_MORNING_SNACK_SERVINGS',
    'fruits_morning_snack_servings',
    'Morning Snack Fruits',
    'Fruit servings consumed during morning snack',
    'serving',
    true
  ),
  (
    'AGG_FRUITS_LUNCH_SERVINGS',
    'fruits_lunch_servings',
    'Lunch Fruits',
    'Fruit servings consumed at lunch',
    'serving',
    true
  ),
  (
    'AGG_FRUITS_AFTERNOON_SNACK_SERVINGS',
    'fruits_afternoon_snack_servings',
    'Afternoon Snack Fruits',
    'Fruit servings consumed during afternoon snack',
    'serving',
    true
  ),
  (
    'AGG_FRUITS_DINNER_SERVINGS',
    'fruits_dinner_servings',
    'Dinner Fruits',
    'Fruit servings consumed at dinner',
    'serving',
    true
  ),
  (
    'AGG_FRUITS_EVENING_SNACK_SERVINGS',
    'fruits_evening_snack_servings',
    'Evening Snack Fruits',
    'Fruit servings consumed during evening snack',
    'serving',
    true
  )
ON CONFLICT (agg_id) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  updated_at = NOW();

-- Type breakdowns (6 metrics)
INSERT INTO aggregation_metrics (
  agg_id,
  metric_name,
  display_name,
  description,
  output_unit,
  is_active
) VALUES
  (
    'AGG_FRUITS_TYPE_BERRIES',
    'fruits_type_berries',
    'Berries Servings',
    'Berry servings consumed',
    'serving',
    true
  ),
  (
    'AGG_FRUITS_TYPE_CITRUS',
    'fruits_type_citrus',
    'Citrus Servings',
    'Citrus fruit servings consumed',
    'serving',
    true
  ),
  (
    'AGG_FRUITS_TYPE_TROPICAL',
    'fruits_type_tropical',
    'Tropical Servings',
    'Tropical fruit servings consumed',
    'serving',
    true
  ),
  (
    'AGG_FRUITS_TYPE_STONE_FRUITS',
    'fruits_type_stone_fruits',
    'Stone Fruits Servings',
    'Stone fruit servings consumed',
    'serving',
    true
  ),
  (
    'AGG_FRUITS_TYPE_APPLES_PEARS',
    'fruits_type_apples_pears',
    'Apples/Pears Servings',
    'Apple and pear servings consumed',
    'serving',
    true
  ),
  (
    'AGG_FRUITS_TYPE_OTHER',
    'fruits_type_other',
    'Other Fruits Servings',
    'Other fruit servings consumed',
    'serving',
    true
  )
ON CONFLICT (agg_id) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  updated_at = NOW();

-- =====================================================
-- 4. Create Aggregation Dependencies
-- =====================================================

-- Main total dependency
INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id,
  data_entry_field_id,
  dependency_type,
  filter_conditions
) VALUES (
  'AGG_FRUITS_SERVINGS',
  'DEF_FRUITS_SERVINGS',
  'data_field',
  NULL
) ON CONFLICT (agg_metric_id, data_entry_field_id) DO NOTHING;

-- Timing dependencies (with filter conditions)
INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id,
  data_entry_field_id,
  dependency_type,
  filter_conditions
) VALUES
  (
    'AGG_FRUITS_BREAKFAST_SERVINGS',
    'DEF_FRUITS_SERVINGS',
    'data_field',
    '{"reference_field": "DEF_FOOD_TIMING", "reference_value": "breakfast"}'::jsonb
  ),
  (
    'AGG_FRUITS_MORNING_SNACK_SERVINGS',
    'DEF_FRUITS_SERVINGS',
    'data_field',
    '{"reference_field": "DEF_FOOD_TIMING", "reference_value": "morning_snack"}'::jsonb
  ),
  (
    'AGG_FRUITS_LUNCH_SERVINGS',
    'DEF_FRUITS_SERVINGS',
    'data_field',
    '{"reference_field": "DEF_FOOD_TIMING", "reference_value": "lunch"}'::jsonb
  ),
  (
    'AGG_FRUITS_AFTERNOON_SNACK_SERVINGS',
    'DEF_FRUITS_SERVINGS',
    'data_field',
    '{"reference_field": "DEF_FOOD_TIMING", "reference_value": "afternoon_snack"}'::jsonb
  ),
  (
    'AGG_FRUITS_DINNER_SERVINGS',
    'DEF_FRUITS_SERVINGS',
    'data_field',
    '{"reference_field": "DEF_FOOD_TIMING", "reference_value": "dinner"}'::jsonb
  ),
  (
    'AGG_FRUITS_EVENING_SNACK_SERVINGS',
    'DEF_FRUITS_SERVINGS',
    'data_field',
    '{"reference_field": "DEF_FOOD_TIMING", "reference_value": "evening_snack"}'::jsonb
  )
ON CONFLICT (agg_metric_id, data_entry_field_id) DO NOTHING;

-- Type dependencies (with filter conditions)
INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id,
  data_entry_field_id,
  dependency_type,
  filter_conditions
) VALUES
  (
    'AGG_FRUITS_TYPE_BERRIES',
    'DEF_FRUITS_SERVINGS',
    'data_field',
    '{"reference_field": "DEF_FRUITS_TYPE", "reference_value": "berries"}'::jsonb
  ),
  (
    'AGG_FRUITS_TYPE_CITRUS',
    'DEF_FRUITS_SERVINGS',
    'data_field',
    '{"reference_field": "DEF_FRUITS_TYPE", "reference_value": "citrus"}'::jsonb
  ),
  (
    'AGG_FRUITS_TYPE_TROPICAL',
    'DEF_FRUITS_SERVINGS',
    'data_field',
    '{"reference_field": "DEF_FRUITS_TYPE", "reference_value": "tropical"}'::jsonb
  ),
  (
    'AGG_FRUITS_TYPE_STONE_FRUITS',
    'DEF_FRUITS_SERVINGS',
    'data_field',
    '{"reference_field": "DEF_FRUITS_TYPE", "reference_value": "stone_fruits"}'::jsonb
  ),
  (
    'AGG_FRUITS_TYPE_APPLES_PEARS',
    'DEF_FRUITS_SERVINGS',
    'data_field',
    '{"reference_field": "DEF_FRUITS_TYPE", "reference_value": "apples_pears"}'::jsonb
  ),
  (
    'AGG_FRUITS_TYPE_OTHER',
    'DEF_FRUITS_SERVINGS',
    'data_field',
    '{"reference_field": "DEF_FRUITS_TYPE", "reference_value": "other"}'::jsonb
  )
ON CONFLICT (agg_metric_id, data_entry_field_id) DO NOTHING;

-- =====================================================
-- 5. Create Aggregation Calculation Types
-- =====================================================

-- Add SUM and AVG for all aggregations
INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
SELECT agg_id, calc_type
FROM (VALUES
  ('AGG_FRUITS_SERVINGS'),
  ('AGG_FRUITS_BREAKFAST_SERVINGS'),
  ('AGG_FRUITS_MORNING_SNACK_SERVINGS'),
  ('AGG_FRUITS_LUNCH_SERVINGS'),
  ('AGG_FRUITS_AFTERNOON_SNACK_SERVINGS'),
  ('AGG_FRUITS_DINNER_SERVINGS'),
  ('AGG_FRUITS_EVENING_SNACK_SERVINGS'),
  ('AGG_FRUITS_TYPE_BERRIES'),
  ('AGG_FRUITS_TYPE_CITRUS'),
  ('AGG_FRUITS_TYPE_TROPICAL'),
  ('AGG_FRUITS_TYPE_STONE_FRUITS'),
  ('AGG_FRUITS_TYPE_APPLES_PEARS'),
  ('AGG_FRUITS_TYPE_OTHER')
) AS aggs(agg_id)
CROSS JOIN (VALUES ('SUM'), ('AVG')) AS calc_types(calc_type)
ON CONFLICT DO NOTHING;

-- =====================================================
-- 6. Create Aggregation Periods
-- =====================================================

-- Add all standard periods for all aggregations
INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
SELECT agg_id, period
FROM (VALUES
  ('AGG_FRUITS_SERVINGS'),
  ('AGG_FRUITS_BREAKFAST_SERVINGS'),
  ('AGG_FRUITS_MORNING_SNACK_SERVINGS'),
  ('AGG_FRUITS_LUNCH_SERVINGS'),
  ('AGG_FRUITS_AFTERNOON_SNACK_SERVINGS'),
  ('AGG_FRUITS_DINNER_SERVINGS'),
  ('AGG_FRUITS_EVENING_SNACK_SERVINGS'),
  ('AGG_FRUITS_TYPE_BERRIES'),
  ('AGG_FRUITS_TYPE_CITRUS'),
  ('AGG_FRUITS_TYPE_TROPICAL'),
  ('AGG_FRUITS_TYPE_STONE_FRUITS'),
  ('AGG_FRUITS_TYPE_APPLES_PEARS'),
  ('AGG_FRUITS_TYPE_OTHER')
) AS aggs(agg_id)
CROSS JOIN (VALUES ('hourly'), ('daily'), ('weekly'), ('monthly'), ('6month'), ('yearly')) AS periods(period)
ON CONFLICT DO NOTHING;

-- =====================================================
-- 7. Create Display Metrics
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
  'DISP_FRUITS_SERVINGS',
  'Fruits',
  'Total fruit servings consumed',
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
  'DISP_FRUITS_MEAL_TIMING',
  'Fruits by Meal',
  'Fruit servings breakdown by meal timing (breakfast, lunch, dinner, snacks)',
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
  'DISP_FRUITS_TYPE',
  'Fruits by Type',
  'Breakdown of fruit servings by type (berries, citrus, tropical, stone fruits, apples/pears, other)',
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
-- 8. Map Aggregations to Display Metrics
-- =====================================================

-- Main total (daily SUM, weekly AVG)
INSERT INTO display_metrics_aggregations (
  metric_id,
  agg_metric_id,
  period_type,
  calculation_type_id,
  display_order
) VALUES
  ('DISP_FRUITS_SERVINGS', 'AGG_FRUITS_SERVINGS', 'daily', 'SUM', 1),
  ('DISP_FRUITS_SERVINGS', 'AGG_FRUITS_SERVINGS', 'weekly', 'AVG', 2),
  ('DISP_FRUITS_SERVINGS', 'AGG_FRUITS_SERVINGS', 'monthly', 'AVG', 3),
  ('DISP_FRUITS_SERVINGS', 'AGG_FRUITS_SERVINGS', 'yearly', 'AVG', 4)
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
  ('DISP_FRUITS_MEAL_TIMING', 'AGG_FRUITS_BREAKFAST_SERVINGS', 'daily', 'SUM', 1),
  ('DISP_FRUITS_MEAL_TIMING', 'AGG_FRUITS_MORNING_SNACK_SERVINGS', 'daily', 'SUM', 2),
  ('DISP_FRUITS_MEAL_TIMING', 'AGG_FRUITS_LUNCH_SERVINGS', 'daily', 'SUM', 3),
  ('DISP_FRUITS_MEAL_TIMING', 'AGG_FRUITS_AFTERNOON_SNACK_SERVINGS', 'daily', 'SUM', 4),
  ('DISP_FRUITS_MEAL_TIMING', 'AGG_FRUITS_DINNER_SERVINGS', 'daily', 'SUM', 5),
  ('DISP_FRUITS_MEAL_TIMING', 'AGG_FRUITS_EVENING_SNACK_SERVINGS', 'daily', 'SUM', 6),

  -- Weekly AVG
  ('DISP_FRUITS_MEAL_TIMING', 'AGG_FRUITS_BREAKFAST_SERVINGS', 'weekly', 'AVG', 7),
  ('DISP_FRUITS_MEAL_TIMING', 'AGG_FRUITS_MORNING_SNACK_SERVINGS', 'weekly', 'AVG', 8),
  ('DISP_FRUITS_MEAL_TIMING', 'AGG_FRUITS_LUNCH_SERVINGS', 'weekly', 'AVG', 9),
  ('DISP_FRUITS_MEAL_TIMING', 'AGG_FRUITS_AFTERNOON_SNACK_SERVINGS', 'weekly', 'AVG', 10),
  ('DISP_FRUITS_MEAL_TIMING', 'AGG_FRUITS_DINNER_SERVINGS', 'weekly', 'AVG', 11),
  ('DISP_FRUITS_MEAL_TIMING', 'AGG_FRUITS_EVENING_SNACK_SERVINGS', 'weekly', 'AVG', 12)
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
  ('DISP_FRUITS_TYPE', 'AGG_FRUITS_TYPE_BERRIES', 'daily', 'SUM', 1),
  ('DISP_FRUITS_TYPE', 'AGG_FRUITS_TYPE_CITRUS', 'daily', 'SUM', 2),
  ('DISP_FRUITS_TYPE', 'AGG_FRUITS_TYPE_TROPICAL', 'daily', 'SUM', 3),
  ('DISP_FRUITS_TYPE', 'AGG_FRUITS_TYPE_STONE_FRUITS', 'daily', 'SUM', 4),
  ('DISP_FRUITS_TYPE', 'AGG_FRUITS_TYPE_APPLES_PEARS', 'daily', 'SUM', 5),
  ('DISP_FRUITS_TYPE', 'AGG_FRUITS_TYPE_OTHER', 'daily', 'SUM', 6),

  -- Weekly AVG
  ('DISP_FRUITS_TYPE', 'AGG_FRUITS_TYPE_BERRIES', 'weekly', 'AVG', 7),
  ('DISP_FRUITS_TYPE', 'AGG_FRUITS_TYPE_CITRUS', 'weekly', 'AVG', 8),
  ('DISP_FRUITS_TYPE', 'AGG_FRUITS_TYPE_TROPICAL', 'weekly', 'AVG', 9),
  ('DISP_FRUITS_TYPE', 'AGG_FRUITS_TYPE_STONE_FRUITS', 'weekly', 'AVG', 10),
  ('DISP_FRUITS_TYPE', 'AGG_FRUITS_TYPE_APPLES_PEARS', 'weekly', 'AVG', 11),
  ('DISP_FRUITS_TYPE', 'AGG_FRUITS_TYPE_OTHER', 'weekly', 'AVG', 12)
ON CONFLICT DO NOTHING;

-- =====================================================
-- 9. Create Display Screens
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
  'SCREEN_FRUITS',
  'Fruits',
  'Track your fruit intake by servings, timing, and type',
  'Healthful Nutrition',
  'fruits',
  'D',
  'detailed',
  10,
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
  'SCREEN_FRUITS',
  'Fruits Tracking',
  'Optimize your fruit intake',
  'Monitor total fruit servings, meal timing distribution, and fruit type variety for optimal nutrition and health.',
  'sections',
  jsonb_build_array(
    jsonb_build_object(
      'section_id', 'fruits_overview',
      'section_title', 'Fruits Overview',
      'section_type', 'metrics_grid',
      'display_order', 1
    ),
    jsonb_build_object(
      'section_id', 'fruits_details',
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
-- 10. Link Display Metrics to Detail Screen
-- =====================================================

-- Overview Section: Total servings
INSERT INTO display_screens_detail_display_metrics (
  detail_screen_id,
  metric_id,
  section_id,
  display_order,
  context_label,
  context_description
) VALUES
  (
    'SCREEN_FRUITS_DETAIL',
    'DISP_FRUITS_SERVINGS',
    'fruits_overview',
    1,
    'Total Fruits',
    'Your total fruit servings per day'
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
    'SCREEN_FRUITS_DETAIL',
    'DISP_FRUITS_MEAL_TIMING',
    'fruits_details',
    1,
    'Fruits by Meal',
    'Distribution of fruit servings across breakfast, lunch, dinner, and snacks'
  ),
  (
    'SCREEN_FRUITS_DETAIL',
    'DISP_FRUITS_TYPE',
    'fruits_details',
    2,
    'Fruits by Type',
    'Breakdown by fruit type: berries, citrus, tropical, stone fruits, apples/pears, and other'
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
  v_ref_count INTEGER;
  v_agg_count INTEGER;
  v_dep_count INTEGER;
  v_calc_count INTEGER;
  v_period_count INTEGER;
  v_display_metrics_count INTEGER;
  v_display_agg_count INTEGER;
  v_screen_count INTEGER;
BEGIN
  -- Count created components
  SELECT COUNT(*) INTO v_fields_count
  FROM field_registry
  WHERE field_id IN ('DEF_FRUITS_SERVINGS', 'DEF_FRUITS_TYPE');

  SELECT COUNT(*) INTO v_ref_count
  FROM data_entry_fields_reference
  WHERE reference_category = 'fruits_types';

  SELECT COUNT(*) INTO v_agg_count
  FROM aggregation_metrics
  WHERE agg_id LIKE 'AGG_FRUITS%';

  SELECT COUNT(*) INTO v_dep_count
  FROM aggregation_metrics_dependencies
  WHERE agg_metric_id LIKE 'AGG_FRUITS%';

  SELECT COUNT(*) INTO v_calc_count
  FROM aggregation_metrics_calculation_types
  WHERE aggregation_metric_id LIKE 'AGG_FRUITS%';

  SELECT COUNT(*) INTO v_period_count
  FROM aggregation_metrics_periods
  WHERE agg_metric_id LIKE 'AGG_FRUITS%';

  SELECT COUNT(*) INTO v_display_metrics_count
  FROM display_metrics
  WHERE metric_id LIKE 'DISP_FRUITS%';

  SELECT COUNT(*) INTO v_display_agg_count
  FROM display_metrics_aggregations
  WHERE metric_id LIKE 'DISP_FRUITS%';

  SELECT COUNT(*) INTO v_screen_count
  FROM display_screens
  WHERE screen_id = 'SCREEN_FRUITS';

  RAISE NOTICE '';
  RAISE NOTICE '========================================';
  RAISE NOTICE 'Fruits Nutrition Component Created!';
  RAISE NOTICE '========================================';
  RAISE NOTICE '';
  RAISE NOTICE 'Component Summary:';
  RAISE NOTICE '  Data Entry Fields: % (DEF_FRUITS_SERVINGS, DEF_FRUITS_TYPE)', v_fields_count;
  RAISE NOTICE '  Reference Values: % fruit types', v_ref_count;
  RAISE NOTICE '  Aggregation Metrics: % (1 total + 6 timing + 6 type)', v_agg_count;
  RAISE NOTICE '  Dependencies: % (with filter conditions for timing and type)', v_dep_count;
  RAISE NOTICE '  Calculation Types: % (SUM + AVG for all metrics)', v_calc_count;
  RAISE NOTICE '  Periods: % (hourly, daily, weekly, monthly, 6month, yearly)', v_period_count;
  RAISE NOTICE '  Display Metrics: % (total, timing, type)', v_display_metrics_count;
  RAISE NOTICE '  Display Aggregations: % (mapped to display metrics)', v_display_agg_count;
  RAISE NOTICE '  Display Screens: %', v_screen_count;
  RAISE NOTICE '';
  RAISE NOTICE 'Data Entry Fields:';
  RAISE NOTICE '  DEF_FRUITS_SERVINGS - Main quantity field (servings)';
  RAISE NOTICE '  DEF_FRUITS_TYPE - Reference to fruit type category';
  RAISE NOTICE '  DEF_FOOD_TIMING - Shared timing field (breakfast, lunch, etc.)';
  RAISE NOTICE '';
  RAISE NOTICE 'Fruit Types (6):';
  RAISE NOTICE '  1. Berries (strawberries, blueberries, raspberries, blackberries)';
  RAISE NOTICE '  2. Citrus (oranges, grapefruits, lemons, limes, tangerines)';
  RAISE NOTICE '  3. Tropical (mango, pineapple, papaya, kiwi, passion fruit)';
  RAISE NOTICE '  4. Stone Fruits (peaches, plums, nectarines, apricots, cherries)';
  RAISE NOTICE '  5. Apples/Pears (apples, pears, and similar pome fruits)';
  RAISE NOTICE '  6. Other (other fruits not in the above categories)';
  RAISE NOTICE '';
  RAISE NOTICE 'Aggregation Metrics (13 total):';
  RAISE NOTICE '  Main Total:';
  RAISE NOTICE '    AGG_FRUITS_SERVINGS';
  RAISE NOTICE '';
  RAISE NOTICE '  Timing Breakdown (6):';
  RAISE NOTICE '    AGG_FRUITS_BREAKFAST_SERVINGS';
  RAISE NOTICE '    AGG_FRUITS_MORNING_SNACK_SERVINGS';
  RAISE NOTICE '    AGG_FRUITS_LUNCH_SERVINGS';
  RAISE NOTICE '    AGG_FRUITS_AFTERNOON_SNACK_SERVINGS';
  RAISE NOTICE '    AGG_FRUITS_DINNER_SERVINGS';
  RAISE NOTICE '    AGG_FRUITS_EVENING_SNACK_SERVINGS';
  RAISE NOTICE '';
  RAISE NOTICE '  Type Breakdown (6):';
  RAISE NOTICE '    AGG_FRUITS_TYPE_BERRIES';
  RAISE NOTICE '    AGG_FRUITS_TYPE_CITRUS';
  RAISE NOTICE '    AGG_FRUITS_TYPE_TROPICAL';
  RAISE NOTICE '    AGG_FRUITS_TYPE_STONE_FRUITS';
  RAISE NOTICE '    AGG_FRUITS_TYPE_APPLES_PEARS';
  RAISE NOTICE '    AGG_FRUITS_TYPE_OTHER';
  RAISE NOTICE '';
  RAISE NOTICE 'Display Metrics (3):';
  RAISE NOTICE '  DISP_FRUITS_SERVINGS - Total servings (primary)';
  RAISE NOTICE '  DISP_FRUITS_MEAL_TIMING - Stacked bar by meal timing';
  RAISE NOTICE '  DISP_FRUITS_TYPE - Stacked bar by fruit type';
  RAISE NOTICE '';
  RAISE NOTICE 'Display Screens:';
  RAISE NOTICE '  SCREEN_FRUITS - Primary fruits tracking screen';
  RAISE NOTICE '  SCREEN_FRUITS_DETAIL - Detail view with sections:';
  RAISE NOTICE '    - fruits_overview (total servings)';
  RAISE NOTICE '    - fruits_details (timing + type breakdown)';
  RAISE NOTICE '';
  RAISE NOTICE 'Next Steps:';
  RAISE NOTICE '  1. Generate test data for fruits';
  RAISE NOTICE '  2. Run aggregations to populate cache';
  RAISE NOTICE '  3. Verify display metrics show correct data';
  RAISE NOTICE '  4. Test mobile UI with fruits tracking';
  RAISE NOTICE '';
  RAISE NOTICE '========================================';
  RAISE NOTICE '';
END $$;

COMMIT;
