-- =====================================================
-- Create Added Sugar Nutrition Component
-- =====================================================
-- Complete database structure for added sugar tracking following protein pattern
-- Includes: data entry fields, reference data, aggregations, dependencies,
-- calculation types, periods, display metrics, and screens
-- =====================================================

BEGIN;

-- =====================================================
-- 1. Create Data Entry Fields
-- =====================================================

-- Main quantity field (grams)
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
  'DEF_ADDED_SUGAR_GRAMS',
  'added_sugar_grams',
  'Added Sugar',
  'Grams of added sugar consumed',
  'quantity',
  'numeric',
  'gram',
  'Healthful Nutrition',
  'nutrition',
  true,
  false
) ON CONFLICT (field_id) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  updated_at = NOW();

-- Added sugar source/type field (reference to data_entry_fields_reference)
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
  'DEF_ADDED_SUGAR_TYPE',
  'added_sugar_type',
  'Added Sugar Source',
  'Source of added sugar (beverages, desserts, sauces, etc.)',
  'reference',
  'uuid',
  'data_entry_fields_reference',
  'added_sugar_types',
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
-- 2. Create Reference Data for Added Sugar Sources
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
    'added_sugar_types',
    'beverages',
    'Beverages',
    'Soda, juice, sweetened coffee/tea, energy drinks',
    1,
    true,
    'beverage',
    '#FF6B6B'
  ),
  (
    'added_sugar_types',
    'desserts',
    'Desserts',
    'Candy, cookies, cake, ice cream, pastries',
    2,
    true,
    'dessert',
    '#FFB84D'
  ),
  (
    'added_sugar_types',
    'sauces_condiments',
    'Sauces/Condiments',
    'Ketchup, BBQ sauce, salad dressing, marinades',
    3,
    true,
    'sauce',
    '#F9CA24'
  ),
  (
    'added_sugar_types',
    'snacks',
    'Snacks',
    'Granola bars, protein bars, sweetened yogurt, flavored nuts',
    4,
    true,
    'snack',
    '#A29BFE'
  ),
  (
    'added_sugar_types',
    'other',
    'Other',
    'Other sources of added sugar',
    5,
    true,
    'sugar',
    '#95A5A6'
  ),
  (
    'added_sugar_types',
    'uncategorized',
    'Uncategorized',
    'Added sugar entries without a specified source',
    6,
    true,
    'question',
    '#BDC3C7'
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

-- Main total added sugar aggregation
INSERT INTO aggregation_metrics (
  agg_id,
  metric_name,
  display_name,
  description,
  output_unit,
  is_active
) VALUES (
  'AGG_ADDED_SUGAR_GRAMS',
  'added_sugar_grams',
  'Total Added Sugar',
  'Total grams of added sugar consumed',
  'gram',
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
    'AGG_ADDED_SUGAR_BREAKFAST_GRAMS',
    'added_sugar_breakfast_grams',
    'Breakfast Added Sugar',
    'Grams of added sugar consumed at breakfast',
    'gram',
    true
  ),
  (
    'AGG_ADDED_SUGAR_MORNING_SNACK_GRAMS',
    'added_sugar_morning_snack_grams',
    'Morning Snack Added Sugar',
    'Grams of added sugar consumed during morning snack',
    'gram',
    true
  ),
  (
    'AGG_ADDED_SUGAR_LUNCH_GRAMS',
    'added_sugar_lunch_grams',
    'Lunch Added Sugar',
    'Grams of added sugar consumed at lunch',
    'gram',
    true
  ),
  (
    'AGG_ADDED_SUGAR_AFTERNOON_SNACK_GRAMS',
    'added_sugar_afternoon_snack_grams',
    'Afternoon Snack Added Sugar',
    'Grams of added sugar consumed during afternoon snack',
    'gram',
    true
  ),
  (
    'AGG_ADDED_SUGAR_DINNER_GRAMS',
    'added_sugar_dinner_grams',
    'Dinner Added Sugar',
    'Grams of added sugar consumed at dinner',
    'gram',
    true
  ),
  (
    'AGG_ADDED_SUGAR_EVENING_SNACK_GRAMS',
    'added_sugar_evening_snack_grams',
    'Evening Snack Added Sugar',
    'Grams of added sugar consumed during evening snack',
    'gram',
    true
  )
ON CONFLICT (agg_id) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  updated_at = NOW();

-- Type/Source breakdowns (6 metrics)
INSERT INTO aggregation_metrics (
  agg_id,
  metric_name,
  display_name,
  description,
  output_unit,
  is_active
) VALUES
  (
    'AGG_ADDED_SUGAR_TYPE_BEVERAGES',
    'added_sugar_type_beverages',
    'Sugar from Beverages',
    'Grams of added sugar from beverages',
    'gram',
    true
  ),
  (
    'AGG_ADDED_SUGAR_TYPE_DESSERTS',
    'added_sugar_type_desserts',
    'Sugar from Desserts',
    'Grams of added sugar from desserts',
    'gram',
    true
  ),
  (
    'AGG_ADDED_SUGAR_TYPE_SAUCES_CONDIMENTS',
    'added_sugar_type_sauces_condiments',
    'Sugar from Sauces/Condiments',
    'Grams of added sugar from sauces and condiments',
    'gram',
    true
  ),
  (
    'AGG_ADDED_SUGAR_TYPE_SNACKS',
    'added_sugar_type_snacks',
    'Sugar from Snacks',
    'Grams of added sugar from snacks',
    'gram',
    true
  ),
  (
    'AGG_ADDED_SUGAR_TYPE_OTHER',
    'added_sugar_type_other',
    'Sugar from Other Sources',
    'Grams of added sugar from other sources',
    'gram',
    true
  ),
  (
    'AGG_ADDED_SUGAR_TYPE_UNCATEGORIZED',
    'added_sugar_type_uncategorized',
    'Uncategorized Sugar',
    'Grams of added sugar from uncategorized sources',
    'gram',
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
  'AGG_ADDED_SUGAR_GRAMS',
  'DEF_ADDED_SUGAR_GRAMS',
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
    'AGG_ADDED_SUGAR_BREAKFAST_GRAMS',
    'DEF_ADDED_SUGAR_GRAMS',
    'data_field',
    '{"reference_field": "DEF_FOOD_TIMING", "reference_value": "breakfast"}'::jsonb
  ),
  (
    'AGG_ADDED_SUGAR_MORNING_SNACK_GRAMS',
    'DEF_ADDED_SUGAR_GRAMS',
    'data_field',
    '{"reference_field": "DEF_FOOD_TIMING", "reference_value": "morning_snack"}'::jsonb
  ),
  (
    'AGG_ADDED_SUGAR_LUNCH_GRAMS',
    'DEF_ADDED_SUGAR_GRAMS',
    'data_field',
    '{"reference_field": "DEF_FOOD_TIMING", "reference_value": "lunch"}'::jsonb
  ),
  (
    'AGG_ADDED_SUGAR_AFTERNOON_SNACK_GRAMS',
    'DEF_ADDED_SUGAR_GRAMS',
    'data_field',
    '{"reference_field": "DEF_FOOD_TIMING", "reference_value": "afternoon_snack"}'::jsonb
  ),
  (
    'AGG_ADDED_SUGAR_DINNER_GRAMS',
    'DEF_ADDED_SUGAR_GRAMS',
    'data_field',
    '{"reference_field": "DEF_FOOD_TIMING", "reference_value": "dinner"}'::jsonb
  ),
  (
    'AGG_ADDED_SUGAR_EVENING_SNACK_GRAMS',
    'DEF_ADDED_SUGAR_GRAMS',
    'data_field',
    '{"reference_field": "DEF_FOOD_TIMING", "reference_value": "evening_snack"}'::jsonb
  )
ON CONFLICT (agg_metric_id, data_entry_field_id) DO NOTHING;

-- Type/Source dependencies (with filter conditions)
INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id,
  data_entry_field_id,
  dependency_type,
  filter_conditions
) VALUES
  (
    'AGG_ADDED_SUGAR_TYPE_BEVERAGES',
    'DEF_ADDED_SUGAR_GRAMS',
    'data_field',
    '{"reference_field": "DEF_ADDED_SUGAR_TYPE", "reference_value": "beverages"}'::jsonb
  ),
  (
    'AGG_ADDED_SUGAR_TYPE_DESSERTS',
    'DEF_ADDED_SUGAR_GRAMS',
    'data_field',
    '{"reference_field": "DEF_ADDED_SUGAR_TYPE", "reference_value": "desserts"}'::jsonb
  ),
  (
    'AGG_ADDED_SUGAR_TYPE_SAUCES_CONDIMENTS',
    'DEF_ADDED_SUGAR_GRAMS',
    'data_field',
    '{"reference_field": "DEF_ADDED_SUGAR_TYPE", "reference_value": "sauces_condiments"}'::jsonb
  ),
  (
    'AGG_ADDED_SUGAR_TYPE_SNACKS',
    'DEF_ADDED_SUGAR_GRAMS',
    'data_field',
    '{"reference_field": "DEF_ADDED_SUGAR_TYPE", "reference_value": "snacks"}'::jsonb
  ),
  (
    'AGG_ADDED_SUGAR_TYPE_OTHER',
    'DEF_ADDED_SUGAR_GRAMS',
    'data_field',
    '{"reference_field": "DEF_ADDED_SUGAR_TYPE", "reference_value": "other"}'::jsonb
  ),
  (
    'AGG_ADDED_SUGAR_TYPE_UNCATEGORIZED',
    'DEF_ADDED_SUGAR_GRAMS',
    'data_field',
    '{"reference_field": "DEF_ADDED_SUGAR_TYPE", "reference_value": "uncategorized"}'::jsonb
  )
ON CONFLICT (agg_metric_id, data_entry_field_id) DO NOTHING;

-- =====================================================
-- 5. Create Aggregation Calculation Types
-- =====================================================

-- Add SUM and AVG for all aggregations
INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
SELECT agg_id, calc_type
FROM (VALUES
  ('AGG_ADDED_SUGAR_GRAMS'),
  ('AGG_ADDED_SUGAR_BREAKFAST_GRAMS'),
  ('AGG_ADDED_SUGAR_MORNING_SNACK_GRAMS'),
  ('AGG_ADDED_SUGAR_LUNCH_GRAMS'),
  ('AGG_ADDED_SUGAR_AFTERNOON_SNACK_GRAMS'),
  ('AGG_ADDED_SUGAR_DINNER_GRAMS'),
  ('AGG_ADDED_SUGAR_EVENING_SNACK_GRAMS'),
  ('AGG_ADDED_SUGAR_TYPE_BEVERAGES'),
  ('AGG_ADDED_SUGAR_TYPE_DESSERTS'),
  ('AGG_ADDED_SUGAR_TYPE_SAUCES_CONDIMENTS'),
  ('AGG_ADDED_SUGAR_TYPE_SNACKS'),
  ('AGG_ADDED_SUGAR_TYPE_OTHER'),
  ('AGG_ADDED_SUGAR_TYPE_UNCATEGORIZED')
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
  ('AGG_ADDED_SUGAR_GRAMS'),
  ('AGG_ADDED_SUGAR_BREAKFAST_GRAMS'),
  ('AGG_ADDED_SUGAR_MORNING_SNACK_GRAMS'),
  ('AGG_ADDED_SUGAR_LUNCH_GRAMS'),
  ('AGG_ADDED_SUGAR_AFTERNOON_SNACK_GRAMS'),
  ('AGG_ADDED_SUGAR_DINNER_GRAMS'),
  ('AGG_ADDED_SUGAR_EVENING_SNACK_GRAMS'),
  ('AGG_ADDED_SUGAR_TYPE_BEVERAGES'),
  ('AGG_ADDED_SUGAR_TYPE_DESSERTS'),
  ('AGG_ADDED_SUGAR_TYPE_SAUCES_CONDIMENTS'),
  ('AGG_ADDED_SUGAR_TYPE_SNACKS'),
  ('AGG_ADDED_SUGAR_TYPE_OTHER'),
  ('AGG_ADDED_SUGAR_TYPE_UNCATEGORIZED')
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
  'DISP_ADDED_SUGAR_GRAMS',
  'Added Sugar',
  'Total grams of added sugar consumed',
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
  'DISP_ADDED_SUGAR_MEAL_TIMING',
  'Added Sugar by Meal',
  'Added sugar breakdown by meal timing (breakfast, lunch, dinner, snacks)',
  'Healthful Nutrition',
  'bar_stacked',
  true,
  false
) ON CONFLICT (metric_id) DO UPDATE SET
  metric_name = EXCLUDED.metric_name,
  description = EXCLUDED.description,
  chart_type_id = EXCLUDED.chart_type_id,
  updated_at = NOW();

-- Source breakdown display metric (stacked bar)
INSERT INTO display_metrics (
  metric_id,
  metric_name,
  description,
  pillar,
  chart_type_id,
  is_active,
  is_primary
) VALUES (
  'DISP_ADDED_SUGAR_SOURCE',
  'Added Sugar by Source',
  'Breakdown of added sugar by source (beverages, desserts, sauces/condiments, snacks, other)',
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
  ('DISP_ADDED_SUGAR_GRAMS', 'AGG_ADDED_SUGAR_GRAMS', 'daily', 'SUM', 1),
  ('DISP_ADDED_SUGAR_GRAMS', 'AGG_ADDED_SUGAR_GRAMS', 'weekly', 'AVG', 2),
  ('DISP_ADDED_SUGAR_GRAMS', 'AGG_ADDED_SUGAR_GRAMS', 'monthly', 'AVG', 3),
  ('DISP_ADDED_SUGAR_GRAMS', 'AGG_ADDED_SUGAR_GRAMS', 'yearly', 'AVG', 4)
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
  ('DISP_ADDED_SUGAR_MEAL_TIMING', 'AGG_ADDED_SUGAR_BREAKFAST_GRAMS', 'daily', 'SUM', 1),
  ('DISP_ADDED_SUGAR_MEAL_TIMING', 'AGG_ADDED_SUGAR_MORNING_SNACK_GRAMS', 'daily', 'SUM', 2),
  ('DISP_ADDED_SUGAR_MEAL_TIMING', 'AGG_ADDED_SUGAR_LUNCH_GRAMS', 'daily', 'SUM', 3),
  ('DISP_ADDED_SUGAR_MEAL_TIMING', 'AGG_ADDED_SUGAR_AFTERNOON_SNACK_GRAMS', 'daily', 'SUM', 4),
  ('DISP_ADDED_SUGAR_MEAL_TIMING', 'AGG_ADDED_SUGAR_DINNER_GRAMS', 'daily', 'SUM', 5),
  ('DISP_ADDED_SUGAR_MEAL_TIMING', 'AGG_ADDED_SUGAR_EVENING_SNACK_GRAMS', 'daily', 'SUM', 6),

  -- Weekly AVG
  ('DISP_ADDED_SUGAR_MEAL_TIMING', 'AGG_ADDED_SUGAR_BREAKFAST_GRAMS', 'weekly', 'AVG', 7),
  ('DISP_ADDED_SUGAR_MEAL_TIMING', 'AGG_ADDED_SUGAR_MORNING_SNACK_GRAMS', 'weekly', 'AVG', 8),
  ('DISP_ADDED_SUGAR_MEAL_TIMING', 'AGG_ADDED_SUGAR_LUNCH_GRAMS', 'weekly', 'AVG', 9),
  ('DISP_ADDED_SUGAR_MEAL_TIMING', 'AGG_ADDED_SUGAR_AFTERNOON_SNACK_GRAMS', 'weekly', 'AVG', 10),
  ('DISP_ADDED_SUGAR_MEAL_TIMING', 'AGG_ADDED_SUGAR_DINNER_GRAMS', 'weekly', 'AVG', 11),
  ('DISP_ADDED_SUGAR_MEAL_TIMING', 'AGG_ADDED_SUGAR_EVENING_SNACK_GRAMS', 'weekly', 'AVG', 12)
ON CONFLICT DO NOTHING;

-- Source breakdown (daily SUM, weekly AVG for each source)
INSERT INTO display_metrics_aggregations (
  metric_id,
  agg_metric_id,
  period_type,
  calculation_type_id,
  display_order
) VALUES
  -- Daily SUM
  ('DISP_ADDED_SUGAR_SOURCE', 'AGG_ADDED_SUGAR_TYPE_BEVERAGES', 'daily', 'SUM', 1),
  ('DISP_ADDED_SUGAR_SOURCE', 'AGG_ADDED_SUGAR_TYPE_DESSERTS', 'daily', 'SUM', 2),
  ('DISP_ADDED_SUGAR_SOURCE', 'AGG_ADDED_SUGAR_TYPE_SAUCES_CONDIMENTS', 'daily', 'SUM', 3),
  ('DISP_ADDED_SUGAR_SOURCE', 'AGG_ADDED_SUGAR_TYPE_SNACKS', 'daily', 'SUM', 4),
  ('DISP_ADDED_SUGAR_SOURCE', 'AGG_ADDED_SUGAR_TYPE_OTHER', 'daily', 'SUM', 5),
  ('DISP_ADDED_SUGAR_SOURCE', 'AGG_ADDED_SUGAR_TYPE_UNCATEGORIZED', 'daily', 'SUM', 6),

  -- Weekly AVG
  ('DISP_ADDED_SUGAR_SOURCE', 'AGG_ADDED_SUGAR_TYPE_BEVERAGES', 'weekly', 'AVG', 7),
  ('DISP_ADDED_SUGAR_SOURCE', 'AGG_ADDED_SUGAR_TYPE_DESSERTS', 'weekly', 'AVG', 8),
  ('DISP_ADDED_SUGAR_SOURCE', 'AGG_ADDED_SUGAR_TYPE_SAUCES_CONDIMENTS', 'weekly', 'AVG', 9),
  ('DISP_ADDED_SUGAR_SOURCE', 'AGG_ADDED_SUGAR_TYPE_SNACKS', 'weekly', 'AVG', 10),
  ('DISP_ADDED_SUGAR_SOURCE', 'AGG_ADDED_SUGAR_TYPE_OTHER', 'weekly', 'AVG', 11),
  ('DISP_ADDED_SUGAR_SOURCE', 'AGG_ADDED_SUGAR_TYPE_UNCATEGORIZED', 'weekly', 'AVG', 12)
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
  'SCREEN_ADDED_SUGAR',
  'Added Sugar',
  'Track your added sugar intake by grams, timing, and source',
  'Healthful Nutrition',
  'sugar',
  'D',
  'detailed',
  20,
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
  'SCREEN_ADDED_SUGAR',
  'Added Sugar Tracking',
  'Monitor and reduce added sugar consumption',
  'Track total added sugar intake, meal timing distribution, and sugar sources to make healthier choices and support better health outcomes.',
  'sections',
  jsonb_build_array(
    jsonb_build_object(
      'section_id', 'added_sugar_overview',
      'section_title', 'Added Sugar Overview',
      'section_type', 'metrics_grid',
      'display_order', 1
    ),
    jsonb_build_object(
      'section_id', 'added_sugar_details',
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

-- Overview Section: Total grams
INSERT INTO display_screens_detail_display_metrics (
  detail_screen_id,
  metric_id,
  section_id,
  display_order,
  context_label,
  context_description
) VALUES
  (
    'SCREEN_ADDED_SUGAR_DETAIL',
    'DISP_ADDED_SUGAR_GRAMS',
    'added_sugar_overview',
    1,
    'Total Added Sugar',
    'Your total added sugar consumption in grams per day'
  )
ON CONFLICT (detail_screen_id, metric_id, section_id) DO UPDATE SET
  display_order = EXCLUDED.display_order,
  context_label = EXCLUDED.context_label,
  context_description = EXCLUDED.context_description,
  updated_at = NOW();

-- Details Section: Timing and Source
INSERT INTO display_screens_detail_display_metrics (
  detail_screen_id,
  metric_id,
  section_id,
  display_order,
  context_label,
  context_description
) VALUES
  (
    'SCREEN_ADDED_SUGAR_DETAIL',
    'DISP_ADDED_SUGAR_MEAL_TIMING',
    'added_sugar_details',
    1,
    'Added Sugar by Meal',
    'Distribution of added sugar across breakfast, lunch, dinner, and snacks'
  ),
  (
    'SCREEN_ADDED_SUGAR_DETAIL',
    'DISP_ADDED_SUGAR_SOURCE',
    'added_sugar_details',
    2,
    'Added Sugar by Source',
    'Breakdown by source: beverages, desserts, sauces/condiments, snacks, and other'
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
  WHERE field_id IN ('DEF_ADDED_SUGAR_GRAMS', 'DEF_ADDED_SUGAR_TYPE');

  SELECT COUNT(*) INTO v_ref_count
  FROM data_entry_fields_reference
  WHERE reference_category = 'added_sugar_types';

  SELECT COUNT(*) INTO v_agg_count
  FROM aggregation_metrics
  WHERE agg_id LIKE 'AGG_ADDED_SUGAR%';

  SELECT COUNT(*) INTO v_dep_count
  FROM aggregation_metrics_dependencies
  WHERE agg_metric_id LIKE 'AGG_ADDED_SUGAR%';

  SELECT COUNT(*) INTO v_calc_count
  FROM aggregation_metrics_calculation_types
  WHERE aggregation_metric_id LIKE 'AGG_ADDED_SUGAR%';

  SELECT COUNT(*) INTO v_period_count
  FROM aggregation_metrics_periods
  WHERE agg_metric_id LIKE 'AGG_ADDED_SUGAR%';

  SELECT COUNT(*) INTO v_display_metrics_count
  FROM display_metrics
  WHERE metric_id LIKE 'DISP_ADDED_SUGAR%';

  SELECT COUNT(*) INTO v_display_agg_count
  FROM display_metrics_aggregations
  WHERE metric_id LIKE 'DISP_ADDED_SUGAR%';

  SELECT COUNT(*) INTO v_screen_count
  FROM display_screens
  WHERE screen_id = 'SCREEN_ADDED_SUGAR';

  RAISE NOTICE '';
  RAISE NOTICE '========================================';
  RAISE NOTICE 'Added Sugar Nutrition Component Created!';
  RAISE NOTICE '========================================';
  RAISE NOTICE '';
  RAISE NOTICE 'Component Summary:';
  RAISE NOTICE '  Data Entry Fields: % (DEF_ADDED_SUGAR_GRAMS, DEF_ADDED_SUGAR_TYPE)', v_fields_count;
  RAISE NOTICE '  Reference Values: % sugar sources', v_ref_count;
  RAISE NOTICE '  Aggregation Metrics: % (1 total + 6 timing + 6 source)', v_agg_count;
  RAISE NOTICE '  Dependencies: % (with filter conditions for timing and source)', v_dep_count;
  RAISE NOTICE '  Calculation Types: % (SUM + AVG for all metrics)', v_calc_count;
  RAISE NOTICE '  Periods: % (hourly, daily, weekly, monthly, 6month, yearly)', v_period_count;
  RAISE NOTICE '  Display Metrics: % (total, timing, source)', v_display_metrics_count;
  RAISE NOTICE '  Display Aggregations: % (mapped to display metrics)', v_display_agg_count;
  RAISE NOTICE '  Display Screens: %', v_screen_count;
  RAISE NOTICE '';
  RAISE NOTICE 'Data Entry Fields:';
  RAISE NOTICE '  DEF_ADDED_SUGAR_GRAMS - Main quantity field (grams)';
  RAISE NOTICE '  DEF_ADDED_SUGAR_TYPE - Reference to sugar source category';
  RAISE NOTICE '  DEF_FOOD_TIMING - Shared timing field (breakfast, lunch, etc.)';
  RAISE NOTICE '';
  RAISE NOTICE 'Sugar Sources (6):';
  RAISE NOTICE '  1. Beverages (soda, juice, sweetened coffee/tea, energy drinks)';
  RAISE NOTICE '  2. Desserts (candy, cookies, cake, ice cream, pastries)';
  RAISE NOTICE '  3. Sauces/Condiments (ketchup, BBQ sauce, salad dressing, marinades)';
  RAISE NOTICE '  4. Snacks (granola bars, protein bars, sweetened yogurt, flavored nuts)';
  RAISE NOTICE '  5. Other (other sources of added sugar)';
  RAISE NOTICE '  6. Uncategorized (entries without a specified source)';
  RAISE NOTICE '';
  RAISE NOTICE 'Aggregation Metrics (13 total):';
  RAISE NOTICE '  Main Total:';
  RAISE NOTICE '    AGG_ADDED_SUGAR_GRAMS';
  RAISE NOTICE '';
  RAISE NOTICE '  Timing Breakdown (6):';
  RAISE NOTICE '    AGG_ADDED_SUGAR_BREAKFAST_GRAMS';
  RAISE NOTICE '    AGG_ADDED_SUGAR_MORNING_SNACK_GRAMS';
  RAISE NOTICE '    AGG_ADDED_SUGAR_LUNCH_GRAMS';
  RAISE NOTICE '    AGG_ADDED_SUGAR_AFTERNOON_SNACK_GRAMS';
  RAISE NOTICE '    AGG_ADDED_SUGAR_DINNER_GRAMS';
  RAISE NOTICE '    AGG_ADDED_SUGAR_EVENING_SNACK_GRAMS';
  RAISE NOTICE '';
  RAISE NOTICE '  Source Breakdown (6):';
  RAISE NOTICE '    AGG_ADDED_SUGAR_TYPE_BEVERAGES';
  RAISE NOTICE '    AGG_ADDED_SUGAR_TYPE_DESSERTS';
  RAISE NOTICE '    AGG_ADDED_SUGAR_TYPE_SAUCES_CONDIMENTS';
  RAISE NOTICE '    AGG_ADDED_SUGAR_TYPE_SNACKS';
  RAISE NOTICE '    AGG_ADDED_SUGAR_TYPE_OTHER';
  RAISE NOTICE '    AGG_ADDED_SUGAR_TYPE_UNCATEGORIZED';
  RAISE NOTICE '';
  RAISE NOTICE 'Display Metrics (3):';
  RAISE NOTICE '  DISP_ADDED_SUGAR_GRAMS - Total grams (primary)';
  RAISE NOTICE '  DISP_ADDED_SUGAR_MEAL_TIMING - Stacked bar by meal timing';
  RAISE NOTICE '  DISP_ADDED_SUGAR_SOURCE - Stacked bar by sugar source';
  RAISE NOTICE '';
  RAISE NOTICE 'Display Screens:';
  RAISE NOTICE '  SCREEN_ADDED_SUGAR - Primary added sugar tracking screen';
  RAISE NOTICE '  SCREEN_ADDED_SUGAR_DETAIL - Detail view with sections:';
  RAISE NOTICE '    - added_sugar_overview (total grams)';
  RAISE NOTICE '    - added_sugar_details (timing + source breakdown)';
  RAISE NOTICE '';
  RAISE NOTICE 'Next Steps:';
  RAISE NOTICE '  1. Generate test data for added sugar';
  RAISE NOTICE '  2. Run aggregations to populate cache';
  RAISE NOTICE '  3. Verify display metrics show correct data';
  RAISE NOTICE '  4. Test mobile UI with added sugar tracking';
  RAISE NOTICE '';
  RAISE NOTICE '========================================';
  RAISE NOTICE '';
END $$;

COMMIT;
