-- =====================================================
-- Create Vegetables Nutrition Component
-- =====================================================
-- Complete database structure for vegetables tracking
-- Following the protein pattern with servings-based tracking
-- =====================================================

BEGIN;

-- =====================================================
-- 1. Create Data Entry Fields
-- =====================================================

-- Main quantity field (servings)
INSERT INTO data_entry_fields (
  field_id,
  field_name,
  display_name,
  description,
  field_type,
  data_type,
  unit,
  event_type_id,
  supports_healthkit_sync,
  pillar_name,
  is_active
) VALUES (
  'DEF_VEGETABLES_SERVINGS',
  'vegetables_servings',
  'Vegetables Servings',
  'Number of vegetable servings consumed',
  'quantity',
  'numeric',
  'serving',
  NULL,
  false,
  'Healthful Nutrition',
  true
) ON CONFLICT (field_id) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  updated_at = NOW();

-- Type field (reference to vegetable types)
INSERT INTO data_entry_fields (
  field_id,
  field_name,
  display_name,
  description,
  field_type,
  data_type,
  reference_table,
  event_type_id,
  supports_healthkit_sync,
  pillar_name,
  is_active
) VALUES (
  'DEF_VEGETABLES_TYPE',
  'vegetables_type',
  'Vegetable Type',
  'Type of vegetable consumed',
  'reference',
  'uuid',
  'data_entry_fields_reference',
  NULL,
  false,
  'Healthful Nutrition',
  true
) ON CONFLICT (field_id) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  reference_table = EXCLUDED.reference_table,
  updated_at = NOW();

-- =====================================================
-- 2. Create Reference Data for Vegetable Types
-- =====================================================

INSERT INTO data_entry_fields_reference (
  reference_category,
  reference_key,
  display_name,
  description,
  sort_order,
  is_active
) VALUES
  ('vegetables_types', 'leafy_greens', 'Leafy Greens', 'Spinach, kale, lettuce, arugula, collard greens', 1, true),
  ('vegetables_types', 'cruciferous', 'Cruciferous', 'Broccoli, cauliflower, Brussels sprouts, cabbage', 2, true),
  ('vegetables_types', 'root_vegetables', 'Root Vegetables', 'Carrots, beets, turnips, radishes, sweet potatoes', 3, true),
  ('vegetables_types', 'nightshades', 'Nightshades', 'Tomatoes, peppers, eggplant', 4, true),
  ('vegetables_types', 'alliums', 'Alliums', 'Onions, garlic, leeks, shallots', 5, true),
  ('vegetables_types', 'other', 'Other', 'Other vegetable types', 6, true)
ON CONFLICT (reference_category, reference_key) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  sort_order = EXCLUDED.sort_order,
  is_active = EXCLUDED.is_active;

-- =====================================================
-- 3. Create Aggregation Metrics
-- =====================================================

-- Main total aggregation
INSERT INTO aggregation_metrics (
  agg_id,
  metric_name,
  display_name,
  description,
  output_unit,
  is_active
) VALUES (
  'AGG_VEGETABLES_SERVINGS',
  'vegetables_servings',
  'Total Vegetables',
  'Total vegetable servings consumed',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;

-- =====================================================
-- 3a. Timing Breakdown Aggregations (6 metrics)
-- =====================================================

-- Breakfast
INSERT INTO aggregation_metrics (
  agg_id,
  metric_name,
  display_name,
  description,
  output_unit,
  is_active
) VALUES (
  'AGG_VEGETABLES_BREAKFAST_SERVINGS',
  'vegetables_breakfast_servings',
  'Breakfast Vegetables',
  'Vegetable servings consumed at breakfast',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;

-- Morning Snack
INSERT INTO aggregation_metrics (
  agg_id,
  metric_name,
  display_name,
  description,
  output_unit,
  is_active
) VALUES (
  'AGG_VEGETABLES_MORNING_SNACK_SERVINGS',
  'vegetables_morning_snack_servings',
  'Morning Snack Vegetables',
  'Vegetable servings consumed during morning snack',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;

-- Lunch
INSERT INTO aggregation_metrics (
  agg_id,
  metric_name,
  display_name,
  description,
  output_unit,
  is_active
) VALUES (
  'AGG_VEGETABLES_LUNCH_SERVINGS',
  'vegetables_lunch_servings',
  'Lunch Vegetables',
  'Vegetable servings consumed at lunch',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;

-- Afternoon Snack
INSERT INTO aggregation_metrics (
  agg_id,
  metric_name,
  display_name,
  description,
  output_unit,
  is_active
) VALUES (
  'AGG_VEGETABLES_AFTERNOON_SNACK_SERVINGS',
  'vegetables_afternoon_snack_servings',
  'Afternoon Snack Vegetables',
  'Vegetable servings consumed during afternoon snack',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;

-- Dinner
INSERT INTO aggregation_metrics (
  agg_id,
  metric_name,
  display_name,
  description,
  output_unit,
  is_active
) VALUES (
  'AGG_VEGETABLES_DINNER_SERVINGS',
  'vegetables_dinner_servings',
  'Dinner Vegetables',
  'Vegetable servings consumed at dinner',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;

-- Evening Snack
INSERT INTO aggregation_metrics (
  agg_id,
  metric_name,
  display_name,
  description,
  output_unit,
  is_active
) VALUES (
  'AGG_VEGETABLES_EVENING_SNACK_SERVINGS',
  'vegetables_evening_snack_servings',
  'Evening Snack Vegetables',
  'Vegetable servings consumed during evening snack',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;

-- =====================================================
-- 3b. Type Breakdown Aggregations (6 metrics)
-- =====================================================

-- Leafy Greens
INSERT INTO aggregation_metrics (
  agg_id,
  metric_name,
  display_name,
  description,
  output_unit,
  is_active
) VALUES (
  'AGG_VEGETABLES_TYPE_LEAFY_GREENS',
  'vegetables_type_leafy_greens',
  'Leafy Greens',
  'Servings of leafy greens consumed',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;

-- Cruciferous
INSERT INTO aggregation_metrics (
  agg_id,
  metric_name,
  display_name,
  description,
  output_unit,
  is_active
) VALUES (
  'AGG_VEGETABLES_TYPE_CRUCIFEROUS',
  'vegetables_type_cruciferous',
  'Cruciferous',
  'Servings of cruciferous vegetables consumed',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;

-- Root Vegetables
INSERT INTO aggregation_metrics (
  agg_id,
  metric_name,
  display_name,
  description,
  output_unit,
  is_active
) VALUES (
  'AGG_VEGETABLES_TYPE_ROOT_VEGETABLES',
  'vegetables_type_root_vegetables',
  'Root Vegetables',
  'Servings of root vegetables consumed',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;

-- Nightshades
INSERT INTO aggregation_metrics (
  agg_id,
  metric_name,
  display_name,
  description,
  output_unit,
  is_active
) VALUES (
  'AGG_VEGETABLES_TYPE_NIGHTSHADES',
  'vegetables_type_nightshades',
  'Nightshades',
  'Servings of nightshade vegetables consumed',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;

-- Alliums
INSERT INTO aggregation_metrics (
  agg_id,
  metric_name,
  display_name,
  description,
  output_unit,
  is_active
) VALUES (
  'AGG_VEGETABLES_TYPE_ALLIUMS',
  'vegetables_type_alliums',
  'Alliums',
  'Servings of allium vegetables consumed',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;

-- Other
INSERT INTO aggregation_metrics (
  agg_id,
  metric_name,
  display_name,
  description,
  output_unit,
  is_active
) VALUES (
  'AGG_VEGETABLES_TYPE_OTHER',
  'vegetables_type_other',
  'Other Vegetables',
  'Servings of other vegetables consumed',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;

-- =====================================================
-- 4. Create Aggregation Dependencies
-- =====================================================

-- Main total depends on DEF_VEGETABLES_SERVINGS
INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id,
  data_entry_field_id,
  dependency_type
) VALUES (
  'AGG_VEGETABLES_SERVINGS',
  'DEF_VEGETABLES_SERVINGS',
  'data_field'
) ON CONFLICT DO NOTHING;

-- =====================================================
-- 4a. Timing Dependencies (with filter conditions)
-- =====================================================

-- Breakfast (filter by DEF_FOOD_TIMING = breakfast)
INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id,
  data_entry_field_id,
  dependency_type,
  filter_conditions
) VALUES (
  'AGG_VEGETABLES_BREAKFAST_SERVINGS',
  'DEF_VEGETABLES_SERVINGS',
  'data_field',
  '{"reference_field": "DEF_FOOD_TIMING", "reference_value": "breakfast"}'::jsonb
) ON CONFLICT DO NOTHING;

-- Morning Snack
INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id,
  data_entry_field_id,
  dependency_type,
  filter_conditions
) VALUES (
  'AGG_VEGETABLES_MORNING_SNACK_SERVINGS',
  'DEF_VEGETABLES_SERVINGS',
  'data_field',
  '{"reference_field": "DEF_FOOD_TIMING", "reference_value": "morning_snack"}'::jsonb
) ON CONFLICT DO NOTHING;

-- Lunch
INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id,
  data_entry_field_id,
  dependency_type,
  filter_conditions
) VALUES (
  'AGG_VEGETABLES_LUNCH_SERVINGS',
  'DEF_VEGETABLES_SERVINGS',
  'data_field',
  '{"reference_field": "DEF_FOOD_TIMING", "reference_value": "lunch"}'::jsonb
) ON CONFLICT DO NOTHING;

-- Afternoon Snack
INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id,
  data_entry_field_id,
  dependency_type,
  filter_conditions
) VALUES (
  'AGG_VEGETABLES_AFTERNOON_SNACK_SERVINGS',
  'DEF_VEGETABLES_SERVINGS',
  'data_field',
  '{"reference_field": "DEF_FOOD_TIMING", "reference_value": "afternoon_snack"}'::jsonb
) ON CONFLICT DO NOTHING;

-- Dinner
INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id,
  data_entry_field_id,
  dependency_type,
  filter_conditions
) VALUES (
  'AGG_VEGETABLES_DINNER_SERVINGS',
  'DEF_VEGETABLES_SERVINGS',
  'data_field',
  '{"reference_field": "DEF_FOOD_TIMING", "reference_value": "dinner"}'::jsonb
) ON CONFLICT DO NOTHING;

-- Evening Snack
INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id,
  data_entry_field_id,
  dependency_type,
  filter_conditions
) VALUES (
  'AGG_VEGETABLES_EVENING_SNACK_SERVINGS',
  'DEF_VEGETABLES_SERVINGS',
  'data_field',
  '{"reference_field": "DEF_FOOD_TIMING", "reference_value": "evening_snack"}'::jsonb
) ON CONFLICT DO NOTHING;

-- =====================================================
-- 4b. Type Dependencies (with filter conditions)
-- =====================================================

-- Leafy Greens
INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id,
  data_entry_field_id,
  dependency_type,
  filter_conditions
) VALUES (
  'AGG_VEGETABLES_TYPE_LEAFY_GREENS',
  'DEF_VEGETABLES_SERVINGS',
  'data_field',
  '{"reference_field": "DEF_VEGETABLES_TYPE", "reference_value": "leafy_greens"}'::jsonb
) ON CONFLICT DO NOTHING;

-- Cruciferous
INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id,
  data_entry_field_id,
  dependency_type,
  filter_conditions
) VALUES (
  'AGG_VEGETABLES_TYPE_CRUCIFEROUS',
  'DEF_VEGETABLES_SERVINGS',
  'data_field',
  '{"reference_field": "DEF_VEGETABLES_TYPE", "reference_value": "cruciferous"}'::jsonb
) ON CONFLICT DO NOTHING;

-- Root Vegetables
INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id,
  data_entry_field_id,
  dependency_type,
  filter_conditions
) VALUES (
  'AGG_VEGETABLES_TYPE_ROOT_VEGETABLES',
  'DEF_VEGETABLES_SERVINGS',
  'data_field',
  '{"reference_field": "DEF_VEGETABLES_TYPE", "reference_value": "root_vegetables"}'::jsonb
) ON CONFLICT DO NOTHING;

-- Nightshades
INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id,
  data_entry_field_id,
  dependency_type,
  filter_conditions
) VALUES (
  'AGG_VEGETABLES_TYPE_NIGHTSHADES',
  'DEF_VEGETABLES_SERVINGS',
  'data_field',
  '{"reference_field": "DEF_VEGETABLES_TYPE", "reference_value": "nightshades"}'::jsonb
) ON CONFLICT DO NOTHING;

-- Alliums
INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id,
  data_entry_field_id,
  dependency_type,
  filter_conditions
) VALUES (
  'AGG_VEGETABLES_TYPE_ALLIUMS',
  'DEF_VEGETABLES_SERVINGS',
  'data_field',
  '{"reference_field": "DEF_VEGETABLES_TYPE", "reference_value": "alliums"}'::jsonb
) ON CONFLICT DO NOTHING;

-- Other
INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id,
  data_entry_field_id,
  dependency_type,
  filter_conditions
) VALUES (
  'AGG_VEGETABLES_TYPE_OTHER',
  'DEF_VEGETABLES_SERVINGS',
  'data_field',
  '{"reference_field": "DEF_VEGETABLES_TYPE", "reference_value": "other"}'::jsonb
) ON CONFLICT DO NOTHING;

-- =====================================================
-- 5. Create Calculation Types (SUM and AVG)
-- =====================================================

INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
SELECT agg_id, calc_type
FROM (VALUES
  ('AGG_VEGETABLES_SERVINGS'),
  ('AGG_VEGETABLES_BREAKFAST_SERVINGS'),
  ('AGG_VEGETABLES_MORNING_SNACK_SERVINGS'),
  ('AGG_VEGETABLES_LUNCH_SERVINGS'),
  ('AGG_VEGETABLES_AFTERNOON_SNACK_SERVINGS'),
  ('AGG_VEGETABLES_DINNER_SERVINGS'),
  ('AGG_VEGETABLES_EVENING_SNACK_SERVINGS'),
  ('AGG_VEGETABLES_TYPE_LEAFY_GREENS'),
  ('AGG_VEGETABLES_TYPE_CRUCIFEROUS'),
  ('AGG_VEGETABLES_TYPE_ROOT_VEGETABLES'),
  ('AGG_VEGETABLES_TYPE_NIGHTSHADES'),
  ('AGG_VEGETABLES_TYPE_ALLIUMS'),
  ('AGG_VEGETABLES_TYPE_OTHER')
) AS aggs(agg_id)
CROSS JOIN (VALUES ('SUM'), ('AVG')) AS calc_types(calc_type)
ON CONFLICT DO NOTHING;

-- =====================================================
-- 6. Create Aggregation Periods
-- =====================================================

INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
SELECT agg_id, period
FROM (VALUES
  ('AGG_VEGETABLES_SERVINGS'),
  ('AGG_VEGETABLES_BREAKFAST_SERVINGS'),
  ('AGG_VEGETABLES_MORNING_SNACK_SERVINGS'),
  ('AGG_VEGETABLES_LUNCH_SERVINGS'),
  ('AGG_VEGETABLES_AFTERNOON_SNACK_SERVINGS'),
  ('AGG_VEGETABLES_DINNER_SERVINGS'),
  ('AGG_VEGETABLES_EVENING_SNACK_SERVINGS'),
  ('AGG_VEGETABLES_TYPE_LEAFY_GREENS'),
  ('AGG_VEGETABLES_TYPE_CRUCIFEROUS'),
  ('AGG_VEGETABLES_TYPE_ROOT_VEGETABLES'),
  ('AGG_VEGETABLES_TYPE_NIGHTSHADES'),
  ('AGG_VEGETABLES_TYPE_ALLIUMS'),
  ('AGG_VEGETABLES_TYPE_OTHER')
) AS aggs(agg_id)
CROSS JOIN (VALUES ('hourly'), ('daily'), ('weekly'), ('monthly'), ('6month'), ('yearly')) AS periods(period)
ON CONFLICT DO NOTHING;

-- =====================================================
-- 7. Create Display Metrics
-- =====================================================

-- Main total display metric (primary, bar chart)
INSERT INTO display_metrics (
  metric_id,
  metric_name,
  description,
  pillar,
  chart_type_id,
  is_active,
  is_primary
) VALUES (
  'DISP_VEGETABLES_SERVINGS',
  'Vegetables',
  'Total vegetable servings consumed',
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
  'DISP_VEGETABLES_MEAL_TIMING',
  'Vegetables by Meal',
  'Vegetable servings breakdown by meal timing (breakfast, lunch, dinner, snacks)',
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
  'DISP_VEGETABLES_TYPE',
  'Vegetables by Type',
  'Breakdown of vegetable servings by type (leafy greens, cruciferous, root vegetables, nightshades, alliums, other)',
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

-- Main total (daily SUM, weekly AVG, monthly AVG, yearly AVG)
INSERT INTO display_metrics_aggregations (
  metric_id,
  agg_metric_id,
  period_type,
  calculation_type_id,
  display_order
) VALUES
  ('DISP_VEGETABLES_SERVINGS', 'AGG_VEGETABLES_SERVINGS', 'daily', 'SUM', 1),
  ('DISP_VEGETABLES_SERVINGS', 'AGG_VEGETABLES_SERVINGS', 'weekly', 'AVG', 2),
  ('DISP_VEGETABLES_SERVINGS', 'AGG_VEGETABLES_SERVINGS', 'monthly', 'AVG', 3),
  ('DISP_VEGETABLES_SERVINGS', 'AGG_VEGETABLES_SERVINGS', 'yearly', 'AVG', 4)
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
  ('DISP_VEGETABLES_MEAL_TIMING', 'AGG_VEGETABLES_BREAKFAST_SERVINGS', 'daily', 'SUM', 1),
  ('DISP_VEGETABLES_MEAL_TIMING', 'AGG_VEGETABLES_MORNING_SNACK_SERVINGS', 'daily', 'SUM', 2),
  ('DISP_VEGETABLES_MEAL_TIMING', 'AGG_VEGETABLES_LUNCH_SERVINGS', 'daily', 'SUM', 3),
  ('DISP_VEGETABLES_MEAL_TIMING', 'AGG_VEGETABLES_AFTERNOON_SNACK_SERVINGS', 'daily', 'SUM', 4),
  ('DISP_VEGETABLES_MEAL_TIMING', 'AGG_VEGETABLES_DINNER_SERVINGS', 'daily', 'SUM', 5),
  ('DISP_VEGETABLES_MEAL_TIMING', 'AGG_VEGETABLES_EVENING_SNACK_SERVINGS', 'daily', 'SUM', 6),

  -- Weekly AVG
  ('DISP_VEGETABLES_MEAL_TIMING', 'AGG_VEGETABLES_BREAKFAST_SERVINGS', 'weekly', 'AVG', 7),
  ('DISP_VEGETABLES_MEAL_TIMING', 'AGG_VEGETABLES_MORNING_SNACK_SERVINGS', 'weekly', 'AVG', 8),
  ('DISP_VEGETABLES_MEAL_TIMING', 'AGG_VEGETABLES_LUNCH_SERVINGS', 'weekly', 'AVG', 9),
  ('DISP_VEGETABLES_MEAL_TIMING', 'AGG_VEGETABLES_AFTERNOON_SNACK_SERVINGS', 'weekly', 'AVG', 10),
  ('DISP_VEGETABLES_MEAL_TIMING', 'AGG_VEGETABLES_DINNER_SERVINGS', 'weekly', 'AVG', 11),
  ('DISP_VEGETABLES_MEAL_TIMING', 'AGG_VEGETABLES_EVENING_SNACK_SERVINGS', 'weekly', 'AVG', 12)
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
  ('DISP_VEGETABLES_TYPE', 'AGG_VEGETABLES_TYPE_LEAFY_GREENS', 'daily', 'SUM', 1),
  ('DISP_VEGETABLES_TYPE', 'AGG_VEGETABLES_TYPE_CRUCIFEROUS', 'daily', 'SUM', 2),
  ('DISP_VEGETABLES_TYPE', 'AGG_VEGETABLES_TYPE_ROOT_VEGETABLES', 'daily', 'SUM', 3),
  ('DISP_VEGETABLES_TYPE', 'AGG_VEGETABLES_TYPE_NIGHTSHADES', 'daily', 'SUM', 4),
  ('DISP_VEGETABLES_TYPE', 'AGG_VEGETABLES_TYPE_ALLIUMS', 'daily', 'SUM', 5),
  ('DISP_VEGETABLES_TYPE', 'AGG_VEGETABLES_TYPE_OTHER', 'daily', 'SUM', 6),

  -- Weekly AVG
  ('DISP_VEGETABLES_TYPE', 'AGG_VEGETABLES_TYPE_LEAFY_GREENS', 'weekly', 'AVG', 7),
  ('DISP_VEGETABLES_TYPE', 'AGG_VEGETABLES_TYPE_CRUCIFEROUS', 'weekly', 'AVG', 8),
  ('DISP_VEGETABLES_TYPE', 'AGG_VEGETABLES_TYPE_ROOT_VEGETABLES', 'weekly', 'AVG', 9),
  ('DISP_VEGETABLES_TYPE', 'AGG_VEGETABLES_TYPE_NIGHTSHADES', 'weekly', 'AVG', 10),
  ('DISP_VEGETABLES_TYPE', 'AGG_VEGETABLES_TYPE_ALLIUMS', 'weekly', 'AVG', 11),
  ('DISP_VEGETABLES_TYPE', 'AGG_VEGETABLES_TYPE_OTHER', 'weekly', 'AVG', 12)
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
  'SCREEN_VEGETABLES',
  'Vegetables',
  'Track your vegetable intake by servings, timing, and type',
  'Healthful Nutrition',
  'vegetables',
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
  'SCREEN_VEGETABLES',
  'Vegetables Tracking',
  'Optimize your vegetable intake',
  'Monitor total vegetable servings, meal timing distribution, and vegetable type variety for optimal nutrition and health.',
  'sections',
  jsonb_build_array(
    jsonb_build_object(
      'section_id', 'vegetables_overview',
      'section_title', 'Vegetables Overview',
      'section_type', 'metrics_grid',
      'display_order', 1
    ),
    jsonb_build_object(
      'section_id', 'vegetables_details',
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
    'SCREEN_VEGETABLES_DETAIL',
    'DISP_VEGETABLES_SERVINGS',
    'vegetables_overview',
    1,
    'Total Vegetables',
    'Your total vegetable servings per day'
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
    'SCREEN_VEGETABLES_DETAIL',
    'DISP_VEGETABLES_MEAL_TIMING',
    'vegetables_details',
    1,
    'Vegetables by Meal',
    'Distribution of vegetable servings across breakfast, lunch, dinner, and snacks'
  ),
  (
    'SCREEN_VEGETABLES_DETAIL',
    'DISP_VEGETABLES_TYPE',
    'vegetables_details',
    2,
    'Vegetables by Type',
    'Breakdown by vegetable type: leafy greens, cruciferous, root vegetables, nightshades, alliums, and other'
  )
ON CONFLICT (detail_screen_id, metric_id, section_id) DO UPDATE SET
  display_order = EXCLUDED.display_order,
  context_label = EXCLUDED.context_label,
  context_description = EXCLUDED.context_description,
  updated_at = NOW();

-- =====================================================
-- Summary Report
-- =====================================================

DO $$
DECLARE
  v_data_entry_fields INTEGER;
  v_reference_types INTEGER;
  v_aggregation_metrics INTEGER;
  v_dependencies INTEGER;
  v_calculation_types INTEGER;
  v_periods INTEGER;
  v_display_metrics_count INTEGER;
  v_display_agg_count INTEGER;
  v_screen_count INTEGER;
BEGIN
  -- Count data entry fields
  SELECT COUNT(*) INTO v_data_entry_fields
  FROM data_entry_fields
  WHERE field_id IN ('DEF_VEGETABLES_SERVINGS', 'DEF_VEGETABLES_TYPE');

  -- Count reference types
  SELECT COUNT(*) INTO v_reference_types
  FROM data_entry_fields_reference
  WHERE reference_category = 'vegetables_types';

  -- Count aggregation metrics
  SELECT COUNT(*) INTO v_aggregation_metrics
  FROM aggregation_metrics
  WHERE agg_id LIKE 'AGG_VEGETABLES%';

  -- Count dependencies
  SELECT COUNT(*) INTO v_dependencies
  FROM aggregation_metrics_dependencies
  WHERE agg_metric_id LIKE 'AGG_VEGETABLES%';

  -- Count calculation types
  SELECT COUNT(*) INTO v_calculation_types
  FROM aggregation_metrics_calculation_types
  WHERE aggregation_metric_id LIKE 'AGG_VEGETABLES%';

  -- Count periods
  SELECT COUNT(*) INTO v_periods
  FROM aggregation_metrics_periods
  WHERE agg_metric_id LIKE 'AGG_VEGETABLES%';

  -- Count display metrics
  SELECT COUNT(*) INTO v_display_metrics_count
  FROM display_metrics
  WHERE metric_id LIKE 'DISP_VEGETABLES%';

  -- Count display metric aggregations
  SELECT COUNT(*) INTO v_display_agg_count
  FROM display_metrics_aggregations
  WHERE metric_id LIKE 'DISP_VEGETABLES%';

  -- Count display screens
  SELECT COUNT(*) INTO v_screen_count
  FROM display_screens
  WHERE screen_id = 'SCREEN_VEGETABLES';

  RAISE NOTICE '';
  RAISE NOTICE '====================================================';
  RAISE NOTICE 'Vegetables Nutrition Component Created!';
  RAISE NOTICE '====================================================';
  RAISE NOTICE '';
  RAISE NOTICE 'Component Summary:';
  RAISE NOTICE '  Data Entry Fields: % (DEF_VEGETABLES_SERVINGS, DEF_VEGETABLES_TYPE)', v_data_entry_fields;
  RAISE NOTICE '  Reference Values: % vegetable types', v_reference_types;
  RAISE NOTICE '  Aggregation Metrics: % (1 total + 6 timing + 6 type)', v_aggregation_metrics;
  RAISE NOTICE '  Dependencies: % (with filter conditions for timing and type)', v_dependencies;
  RAISE NOTICE '  Calculation Types: % (SUM + AVG for all metrics)', v_calculation_types;
  RAISE NOTICE '  Periods: % (hourly, daily, weekly, monthly, 6month, yearly)', v_periods;
  RAISE NOTICE '  Display Metrics: % (total, timing, type)', v_display_metrics_count;
  RAISE NOTICE '  Display Aggregations: % (mapped to display metrics)', v_display_agg_count;
  RAISE NOTICE '  Display Screens: %', v_screen_count;
  RAISE NOTICE '';
  RAISE NOTICE 'Data Entry Fields:';
  RAISE NOTICE '  DEF_VEGETABLES_SERVINGS - Main quantity field (servings)';
  RAISE NOTICE '  DEF_VEGETABLES_TYPE - Reference to vegetable type category';
  RAISE NOTICE '  DEF_FOOD_TIMING - Shared timing field (breakfast, lunch, etc.)';
  RAISE NOTICE '';
  RAISE NOTICE 'Vegetable Types (6):';
  RAISE NOTICE '  1. Leafy Greens (spinach, kale, lettuce, arugula, collard greens)';
  RAISE NOTICE '  2. Cruciferous (broccoli, cauliflower, Brussels sprouts, cabbage)';
  RAISE NOTICE '  3. Root Vegetables (carrots, beets, turnips, radishes, sweet potatoes)';
  RAISE NOTICE '  4. Nightshades (tomatoes, peppers, eggplant)';
  RAISE NOTICE '  5. Alliums (onions, garlic, leeks, shallots)';
  RAISE NOTICE '  6. Other (other vegetable types)';
  RAISE NOTICE '';
  RAISE NOTICE 'Aggregation Metrics (13 total):';
  RAISE NOTICE '  Main Total:';
  RAISE NOTICE '    AGG_VEGETABLES_SERVINGS';
  RAISE NOTICE '';
  RAISE NOTICE '  Timing Breakdown (6):';
  RAISE NOTICE '    AGG_VEGETABLES_BREAKFAST_SERVINGS';
  RAISE NOTICE '    AGG_VEGETABLES_MORNING_SNACK_SERVINGS';
  RAISE NOTICE '    AGG_VEGETABLES_LUNCH_SERVINGS';
  RAISE NOTICE '    AGG_VEGETABLES_AFTERNOON_SNACK_SERVINGS';
  RAISE NOTICE '    AGG_VEGETABLES_DINNER_SERVINGS';
  RAISE NOTICE '    AGG_VEGETABLES_EVENING_SNACK_SERVINGS';
  RAISE NOTICE '';
  RAISE NOTICE '  Type Breakdown (6):';
  RAISE NOTICE '    AGG_VEGETABLES_TYPE_LEAFY_GREENS';
  RAISE NOTICE '    AGG_VEGETABLES_TYPE_CRUCIFEROUS';
  RAISE NOTICE '    AGG_VEGETABLES_TYPE_ROOT_VEGETABLES';
  RAISE NOTICE '    AGG_VEGETABLES_TYPE_NIGHTSHADES';
  RAISE NOTICE '    AGG_VEGETABLES_TYPE_ALLIUMS';
  RAISE NOTICE '    AGG_VEGETABLES_TYPE_OTHER';
  RAISE NOTICE '';
  RAISE NOTICE 'Display Metrics (3):';
  RAISE NOTICE '  DISP_VEGETABLES_SERVINGS - Total servings (primary, bar chart)';
  RAISE NOTICE '  DISP_VEGETABLES_MEAL_TIMING - Stacked bar by meal timing';
  RAISE NOTICE '  DISP_VEGETABLES_TYPE - Stacked bar by vegetable type';
  RAISE NOTICE '';
  RAISE NOTICE 'Display Screens:';
  RAISE NOTICE '  SCREEN_VEGETABLES - Primary vegetables tracking screen';
  RAISE NOTICE '  SCREEN_VEGETABLES_DETAIL - Detail view with sections:';
  RAISE NOTICE '    - vegetables_overview (total servings)';
  RAISE NOTICE '    - vegetables_details (timing + type breakdown)';
  RAISE NOTICE '';
  RAISE NOTICE 'Next Steps:';
  RAISE NOTICE '  1. Generate test data for vegetables';
  RAISE NOTICE '  2. Run aggregations to populate cache';
  RAISE NOTICE '  3. Verify display metrics show correct data';
  RAISE NOTICE '  4. Test mobile UI with vegetables tracking';
  RAISE NOTICE '';
  RAISE NOTICE '====================================================';
  RAISE NOTICE '';
END $$;

COMMIT;
