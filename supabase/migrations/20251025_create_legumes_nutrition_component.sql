-- =====================================================
-- Create Complete Legumes Nutrition Component
-- =====================================================
-- Following the protein/fruits/healthy_fats pattern for legumes tracking
--
-- Components:
-- 1. Data Entry Fields (DEF_LEGUMES_SERVINGS, DEF_LEGUMES_TYPE)
-- 2. Reference Data (6 legume types)
-- 3. Aggregation Metrics (1 main + 6 timing + 6 type breakdowns)
-- 4. Aggregation Dependencies
-- 5. Calculation Types (SUM, AVG)
-- 6. Periods (hourly, daily, weekly, monthly, 6month, yearly)
-- 7. Display Metrics (3 metrics: servings, meal timing, type)
-- 8. Display Aggregations Mappings
-- 9. Display Screens (SCREEN_LEGUMES with detail view)
-- 10. Screen Sections (overview and details)
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Create Data Entry Fields
-- =====================================================

-- Main servings field
INSERT INTO data_entry_fields (
  field_id,
  field_name,
  display_name,
  description,
  field_type,
  data_type,
  unit,
  is_active,
  pillar_name,
  supports_healthkit_sync,
  validation_type,
  validation_config
) VALUES (
  'DEF_LEGUMES_SERVINGS',
  'legumes_servings',
  'Legumes (servings)',
  'Legumes consumption in servings. Track beans, lentils, chickpeas, peas, soy products, and other legumes.',
  'quantity',
  'numeric',
  'serving',
  true,
  'Healthful Nutrition',
  false,
  'numeric',
  '{"min": 0, "max": 20, "increment": 0.5}'::jsonb
) ON CONFLICT (field_id) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  unit = EXCLUDED.unit,
  validation_config = EXCLUDED.validation_config,
  updated_at = NOW();

-- Legume type field (reference to data_entry_fields_reference)
INSERT INTO data_entry_fields (
  field_id,
  field_name,
  display_name,
  description,
  field_type,
  data_type,
  reference_table,
  is_active,
  pillar_name,
  supports_healthkit_sync
) VALUES (
  'DEF_LEGUMES_TYPE',
  'legumes_type',
  'Legume Type',
  'Type of legume consumed (beans, lentils, chickpeas, peas, soy products, other)',
  'reference',
  'uuid',
  'data_entry_fields_reference',
  true,
  'Healthful Nutrition',
  false
) ON CONFLICT (field_id) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  reference_table = EXCLUDED.reference_table,
  updated_at = NOW();

-- =====================================================
-- PART 2: Create Reference Data for Legume Types
-- =====================================================

INSERT INTO data_entry_fields_reference (
  id,
  reference_category,
  reference_key,
  display_name,
  description,
  sort_order,
  is_active
) VALUES
  (
    gen_random_uuid(),
    'legumes_types',
    'beans',
    'Beans',
    'Black beans, kidney beans, pinto beans, navy beans, etc.',
    1,
    true
  ),
  (
    gen_random_uuid(),
    'legumes_types',
    'lentils',
    'Lentils',
    'Red lentils, green lentils, brown lentils, etc.',
    2,
    true
  ),
  (
    gen_random_uuid(),
    'legumes_types',
    'chickpeas',
    'Chickpeas',
    'Chickpeas (garbanzo beans), hummus',
    3,
    true
  ),
  (
    gen_random_uuid(),
    'legumes_types',
    'peas',
    'Peas',
    'Split peas, green peas, black-eyed peas',
    4,
    true
  ),
  (
    gen_random_uuid(),
    'legumes_types',
    'soy_products',
    'Soy Products',
    'Tofu, tempeh, edamame, soy milk',
    5,
    true
  ),
  (
    gen_random_uuid(),
    'legumes_types',
    'other',
    'Other',
    'Other legume varieties not listed above',
    6,
    true
  )
ON CONFLICT (reference_category, reference_key) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  sort_order = EXCLUDED.sort_order,
  updated_at = NOW();

-- =====================================================
-- PART 3: Create Aggregation Metrics
-- =====================================================

-- Main total servings aggregation
INSERT INTO aggregation_metrics (
  agg_id,
  metric_name,
  display_name,
  description,
  output_unit,
  is_active
) VALUES (
  'AGG_LEGUMES_SERVINGS',
  'legumes_servings',
  'Total Legumes',
  'Total legumes consumed in servings',
  'serving',
  true
) ON CONFLICT (agg_id) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  updated_at = NOW();

-- =====================================================
-- Timing Breakdown Aggregations (6 meal times)
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
  'AGG_LEGUMES_BREAKFAST_SERVINGS',
  'legumes_breakfast_servings',
  'Breakfast Legumes',
  'Legumes consumed at breakfast',
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
  'AGG_LEGUMES_MORNING_SNACK_SERVINGS',
  'legumes_morning_snack_servings',
  'Morning Snack Legumes',
  'Legumes consumed during morning snack',
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
  'AGG_LEGUMES_LUNCH_SERVINGS',
  'legumes_lunch_servings',
  'Lunch Legumes',
  'Legumes consumed at lunch',
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
  'AGG_LEGUMES_AFTERNOON_SNACK_SERVINGS',
  'legumes_afternoon_snack_servings',
  'Afternoon Snack Legumes',
  'Legumes consumed during afternoon snack',
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
  'AGG_LEGUMES_DINNER_SERVINGS',
  'legumes_dinner_servings',
  'Dinner Legumes',
  'Legumes consumed at dinner',
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
  'AGG_LEGUMES_EVENING_SNACK_SERVINGS',
  'legumes_evening_snack_servings',
  'Evening Snack Legumes',
  'Legumes consumed during evening snack',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;

-- =====================================================
-- Type Breakdown Aggregations (6 legume types)
-- =====================================================

-- Beans
INSERT INTO aggregation_metrics (
  agg_id,
  metric_name,
  display_name,
  description,
  output_unit,
  is_active
) VALUES (
  'AGG_LEGUMES_TYPE_BEANS',
  'legumes_type_beans',
  'Beans',
  'Beans consumption (black beans, kidney beans, pinto beans, etc.)',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;

-- Lentils
INSERT INTO aggregation_metrics (
  agg_id,
  metric_name,
  display_name,
  description,
  output_unit,
  is_active
) VALUES (
  'AGG_LEGUMES_TYPE_LENTILS',
  'legumes_type_lentils',
  'Lentils',
  'Lentils consumption (red, green, brown lentils)',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;

-- Chickpeas
INSERT INTO aggregation_metrics (
  agg_id,
  metric_name,
  display_name,
  description,
  output_unit,
  is_active
) VALUES (
  'AGG_LEGUMES_TYPE_CHICKPEAS',
  'legumes_type_chickpeas',
  'Chickpeas',
  'Chickpeas consumption (garbanzo beans, hummus)',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;

-- Peas
INSERT INTO aggregation_metrics (
  agg_id,
  metric_name,
  display_name,
  description,
  output_unit,
  is_active
) VALUES (
  'AGG_LEGUMES_TYPE_PEAS',
  'legumes_type_peas',
  'Peas',
  'Peas consumption (split peas, green peas, black-eyed peas)',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;

-- Soy Products
INSERT INTO aggregation_metrics (
  agg_id,
  metric_name,
  display_name,
  description,
  output_unit,
  is_active
) VALUES (
  'AGG_LEGUMES_TYPE_SOY_PRODUCTS',
  'legumes_type_soy_products',
  'Soy Products',
  'Soy products consumption (tofu, tempeh, edamame, soy milk)',
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
  'AGG_LEGUMES_TYPE_OTHER',
  'legumes_type_other',
  'Other Legumes',
  'Other legume varieties not listed above',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;

-- =====================================================
-- PART 4: Create Aggregation Dependencies
-- =====================================================

-- Main total (no filter)
INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id,
  data_entry_field_id,
  dependency_type
) VALUES (
  'AGG_LEGUMES_SERVINGS',
  'DEF_LEGUMES_SERVINGS',
  'data_field'
) ON CONFLICT DO NOTHING;

-- =====================================================
-- Timing Dependencies (filtered by DEF_FOOD_TIMING)
-- =====================================================

INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id,
  data_entry_field_id,
  dependency_type,
  filter_conditions
) VALUES
  (
    'AGG_LEGUMES_BREAKFAST_SERVINGS',
    'DEF_LEGUMES_SERVINGS',
    'data_field',
    '{"reference_field": "DEF_FOOD_TIMING", "reference_value": "breakfast"}'::jsonb
  ),
  (
    'AGG_LEGUMES_MORNING_SNACK_SERVINGS',
    'DEF_LEGUMES_SERVINGS',
    'data_field',
    '{"reference_field": "DEF_FOOD_TIMING", "reference_value": "morning_snack"}'::jsonb
  ),
  (
    'AGG_LEGUMES_LUNCH_SERVINGS',
    'DEF_LEGUMES_SERVINGS',
    'data_field',
    '{"reference_field": "DEF_FOOD_TIMING", "reference_value": "lunch"}'::jsonb
  ),
  (
    'AGG_LEGUMES_AFTERNOON_SNACK_SERVINGS',
    'DEF_LEGUMES_SERVINGS',
    'data_field',
    '{"reference_field": "DEF_FOOD_TIMING", "reference_value": "afternoon_snack"}'::jsonb
  ),
  (
    'AGG_LEGUMES_DINNER_SERVINGS',
    'DEF_LEGUMES_SERVINGS',
    'data_field',
    '{"reference_field": "DEF_FOOD_TIMING", "reference_value": "dinner"}'::jsonb
  ),
  (
    'AGG_LEGUMES_EVENING_SNACK_SERVINGS',
    'DEF_LEGUMES_SERVINGS',
    'data_field',
    '{"reference_field": "DEF_FOOD_TIMING", "reference_value": "evening_snack"}'::jsonb
  )
ON CONFLICT DO NOTHING;

-- =====================================================
-- Type Dependencies (filtered by DEF_LEGUMES_TYPE)
-- =====================================================

INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id,
  data_entry_field_id,
  dependency_type,
  filter_conditions
) VALUES
  (
    'AGG_LEGUMES_TYPE_BEANS',
    'DEF_LEGUMES_SERVINGS',
    'data_field',
    '{"reference_field": "DEF_LEGUMES_TYPE", "reference_value": "beans"}'::jsonb
  ),
  (
    'AGG_LEGUMES_TYPE_LENTILS',
    'DEF_LEGUMES_SERVINGS',
    'data_field',
    '{"reference_field": "DEF_LEGUMES_TYPE", "reference_value": "lentils"}'::jsonb
  ),
  (
    'AGG_LEGUMES_TYPE_CHICKPEAS',
    'DEF_LEGUMES_SERVINGS',
    'data_field',
    '{"reference_field": "DEF_LEGUMES_TYPE", "reference_value": "chickpeas"}'::jsonb
  ),
  (
    'AGG_LEGUMES_TYPE_PEAS',
    'DEF_LEGUMES_SERVINGS',
    'data_field',
    '{"reference_field": "DEF_LEGUMES_TYPE", "reference_value": "peas"}'::jsonb
  ),
  (
    'AGG_LEGUMES_TYPE_SOY_PRODUCTS',
    'DEF_LEGUMES_SERVINGS',
    'data_field',
    '{"reference_field": "DEF_LEGUMES_TYPE", "reference_value": "soy_products"}'::jsonb
  ),
  (
    'AGG_LEGUMES_TYPE_OTHER',
    'DEF_LEGUMES_SERVINGS',
    'data_field',
    '{"reference_field": "DEF_LEGUMES_TYPE", "reference_value": "other"}'::jsonb
  )
ON CONFLICT DO NOTHING;

-- =====================================================
-- PART 5: Create Calculation Types (SUM and AVG)
-- =====================================================

INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
SELECT agg_id, calc_type
FROM (VALUES
  ('AGG_LEGUMES_SERVINGS'),
  ('AGG_LEGUMES_BREAKFAST_SERVINGS'),
  ('AGG_LEGUMES_MORNING_SNACK_SERVINGS'),
  ('AGG_LEGUMES_LUNCH_SERVINGS'),
  ('AGG_LEGUMES_AFTERNOON_SNACK_SERVINGS'),
  ('AGG_LEGUMES_DINNER_SERVINGS'),
  ('AGG_LEGUMES_EVENING_SNACK_SERVINGS'),
  ('AGG_LEGUMES_TYPE_BEANS'),
  ('AGG_LEGUMES_TYPE_LENTILS'),
  ('AGG_LEGUMES_TYPE_CHICKPEAS'),
  ('AGG_LEGUMES_TYPE_PEAS'),
  ('AGG_LEGUMES_TYPE_SOY_PRODUCTS'),
  ('AGG_LEGUMES_TYPE_OTHER')
) AS aggs(agg_id)
CROSS JOIN (VALUES ('SUM'), ('AVG')) AS calc_types(calc_type)
ON CONFLICT DO NOTHING;

-- =====================================================
-- PART 6: Create Aggregation Periods
-- =====================================================

INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
SELECT agg_id, period
FROM (VALUES
  ('AGG_LEGUMES_SERVINGS'),
  ('AGG_LEGUMES_BREAKFAST_SERVINGS'),
  ('AGG_LEGUMES_MORNING_SNACK_SERVINGS'),
  ('AGG_LEGUMES_LUNCH_SERVINGS'),
  ('AGG_LEGUMES_AFTERNOON_SNACK_SERVINGS'),
  ('AGG_LEGUMES_DINNER_SERVINGS'),
  ('AGG_LEGUMES_EVENING_SNACK_SERVINGS'),
  ('AGG_LEGUMES_TYPE_BEANS'),
  ('AGG_LEGUMES_TYPE_LENTILS'),
  ('AGG_LEGUMES_TYPE_CHICKPEAS'),
  ('AGG_LEGUMES_TYPE_PEAS'),
  ('AGG_LEGUMES_TYPE_SOY_PRODUCTS'),
  ('AGG_LEGUMES_TYPE_OTHER')
) AS aggs(agg_id)
CROSS JOIN (VALUES ('hourly'), ('daily'), ('weekly'), ('monthly'), ('6month'), ('yearly')) AS periods(period)
ON CONFLICT DO NOTHING;

-- =====================================================
-- PART 7: Create Display Metrics
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
  'DISP_LEGUMES_SERVINGS',
  'Legumes',
  'Total legumes servings consumed',
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
  'DISP_LEGUMES_MEAL_TIMING',
  'Legumes by Meal',
  'Legumes servings breakdown by meal timing (breakfast, lunch, dinner, snacks)',
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
  'DISP_LEGUMES_TYPE',
  'Legumes by Type',
  'Breakdown of legumes servings by type (beans, lentils, chickpeas, peas, soy products, other)',
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
-- PART 8: Map Aggregations to Display Metrics
-- =====================================================

-- Main total (daily SUM, weekly AVG)
INSERT INTO display_metrics_aggregations (
  metric_id,
  agg_metric_id,
  period_type,
  calculation_type_id,
  display_order
) VALUES
  ('DISP_LEGUMES_SERVINGS', 'AGG_LEGUMES_SERVINGS', 'daily', 'SUM', 1),
  ('DISP_LEGUMES_SERVINGS', 'AGG_LEGUMES_SERVINGS', 'weekly', 'AVG', 2),
  ('DISP_LEGUMES_SERVINGS', 'AGG_LEGUMES_SERVINGS', 'monthly', 'AVG', 3),
  ('DISP_LEGUMES_SERVINGS', 'AGG_LEGUMES_SERVINGS', 'yearly', 'AVG', 4)
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
  ('DISP_LEGUMES_MEAL_TIMING', 'AGG_LEGUMES_BREAKFAST_SERVINGS', 'daily', 'SUM', 1),
  ('DISP_LEGUMES_MEAL_TIMING', 'AGG_LEGUMES_MORNING_SNACK_SERVINGS', 'daily', 'SUM', 2),
  ('DISP_LEGUMES_MEAL_TIMING', 'AGG_LEGUMES_LUNCH_SERVINGS', 'daily', 'SUM', 3),
  ('DISP_LEGUMES_MEAL_TIMING', 'AGG_LEGUMES_AFTERNOON_SNACK_SERVINGS', 'daily', 'SUM', 4),
  ('DISP_LEGUMES_MEAL_TIMING', 'AGG_LEGUMES_DINNER_SERVINGS', 'daily', 'SUM', 5),
  ('DISP_LEGUMES_MEAL_TIMING', 'AGG_LEGUMES_EVENING_SNACK_SERVINGS', 'daily', 'SUM', 6),

  -- Weekly AVG
  ('DISP_LEGUMES_MEAL_TIMING', 'AGG_LEGUMES_BREAKFAST_SERVINGS', 'weekly', 'AVG', 7),
  ('DISP_LEGUMES_MEAL_TIMING', 'AGG_LEGUMES_MORNING_SNACK_SERVINGS', 'weekly', 'AVG', 8),
  ('DISP_LEGUMES_MEAL_TIMING', 'AGG_LEGUMES_LUNCH_SERVINGS', 'weekly', 'AVG', 9),
  ('DISP_LEGUMES_MEAL_TIMING', 'AGG_LEGUMES_AFTERNOON_SNACK_SERVINGS', 'weekly', 'AVG', 10),
  ('DISP_LEGUMES_MEAL_TIMING', 'AGG_LEGUMES_DINNER_SERVINGS', 'weekly', 'AVG', 11),
  ('DISP_LEGUMES_MEAL_TIMING', 'AGG_LEGUMES_EVENING_SNACK_SERVINGS', 'weekly', 'AVG', 12)
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
  ('DISP_LEGUMES_TYPE', 'AGG_LEGUMES_TYPE_BEANS', 'daily', 'SUM', 1),
  ('DISP_LEGUMES_TYPE', 'AGG_LEGUMES_TYPE_LENTILS', 'daily', 'SUM', 2),
  ('DISP_LEGUMES_TYPE', 'AGG_LEGUMES_TYPE_CHICKPEAS', 'daily', 'SUM', 3),
  ('DISP_LEGUMES_TYPE', 'AGG_LEGUMES_TYPE_PEAS', 'daily', 'SUM', 4),
  ('DISP_LEGUMES_TYPE', 'AGG_LEGUMES_TYPE_SOY_PRODUCTS', 'daily', 'SUM', 5),
  ('DISP_LEGUMES_TYPE', 'AGG_LEGUMES_TYPE_OTHER', 'daily', 'SUM', 6),

  -- Weekly AVG
  ('DISP_LEGUMES_TYPE', 'AGG_LEGUMES_TYPE_BEANS', 'weekly', 'AVG', 7),
  ('DISP_LEGUMES_TYPE', 'AGG_LEGUMES_TYPE_LENTILS', 'weekly', 'AVG', 8),
  ('DISP_LEGUMES_TYPE', 'AGG_LEGUMES_TYPE_CHICKPEAS', 'weekly', 'AVG', 9),
  ('DISP_LEGUMES_TYPE', 'AGG_LEGUMES_TYPE_PEAS', 'weekly', 'AVG', 10),
  ('DISP_LEGUMES_TYPE', 'AGG_LEGUMES_TYPE_SOY_PRODUCTS', 'weekly', 'AVG', 11),
  ('DISP_LEGUMES_TYPE', 'AGG_LEGUMES_TYPE_OTHER', 'weekly', 'AVG', 12)
ON CONFLICT DO NOTHING;

-- =====================================================
-- PART 9: Create Display Screens
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
  'SCREEN_LEGUMES',
  'Legumes',
  'Track your legumes intake by servings, timing, and type',
  'Healthful Nutrition',
  'legumes',
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
  'SCREEN_LEGUMES',
  'Legumes Tracking',
  'Optimize your legumes intake',
  'Monitor total legumes servings, meal timing distribution, and legume type variety for optimal plant-based protein and fiber intake.',
  'sections',
  jsonb_build_array(
    jsonb_build_object(
      'section_id', 'legumes_overview',
      'section_title', 'Legumes Overview',
      'section_type', 'metrics_grid',
      'display_order', 1
    ),
    jsonb_build_object(
      'section_id', 'legumes_details',
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
-- PART 10: Link Display Metrics to Detail Screen
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
    'SCREEN_LEGUMES_DETAIL',
    'DISP_LEGUMES_SERVINGS',
    'legumes_overview',
    1,
    'Total Legumes',
    'Your total legumes servings per day'
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
    'SCREEN_LEGUMES_DETAIL',
    'DISP_LEGUMES_MEAL_TIMING',
    'legumes_details',
    1,
    'Legumes by Meal',
    'Distribution of legumes servings across breakfast, lunch, dinner, and snacks'
  ),
  (
    'SCREEN_LEGUMES_DETAIL',
    'DISP_LEGUMES_TYPE',
    'legumes_details',
    2,
    'Legumes by Type',
    'Breakdown by legume type: beans, lentils, chickpeas, peas, soy products, and other'
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
  v_data_fields INTEGER;
  v_reference_types INTEGER;
  v_agg_metrics INTEGER;
  v_dependencies INTEGER;
  v_calc_types INTEGER;
  v_periods INTEGER;
  v_display_metrics INTEGER;
  v_display_agg_count INTEGER;
  v_screen_count INTEGER;
BEGIN
  -- Count data entry fields
  SELECT COUNT(*) INTO v_data_fields
  FROM data_entry_fields
  WHERE field_id IN ('DEF_LEGUMES_SERVINGS', 'DEF_LEGUMES_TYPE');

  -- Count reference types
  SELECT COUNT(*) INTO v_reference_types
  FROM data_entry_fields_reference
  WHERE reference_category = 'legumes_types';

  -- Count aggregation metrics
  SELECT COUNT(*) INTO v_agg_metrics
  FROM aggregation_metrics
  WHERE agg_id LIKE 'AGG_LEGUMES%';

  -- Count dependencies
  SELECT COUNT(*) INTO v_dependencies
  FROM aggregation_metrics_dependencies
  WHERE agg_metric_id LIKE 'AGG_LEGUMES%';

  -- Count calculation types
  SELECT COUNT(*) INTO v_calc_types
  FROM aggregation_metrics_calculation_types
  WHERE aggregation_metric_id LIKE 'AGG_LEGUMES%';

  -- Count periods
  SELECT COUNT(*) INTO v_periods
  FROM aggregation_metrics_periods
  WHERE agg_metric_id LIKE 'AGG_LEGUMES%';

  -- Count display metrics
  SELECT COUNT(*) INTO v_display_metrics
  FROM display_metrics
  WHERE metric_id LIKE 'DISP_LEGUMES%';

  -- Count display aggregation mappings
  SELECT COUNT(*) INTO v_display_agg_count
  FROM display_metrics_aggregations
  WHERE metric_id LIKE 'DISP_LEGUMES%';

  -- Count screens
  SELECT COUNT(*) INTO v_screen_count
  FROM display_screens
  WHERE screen_id = 'SCREEN_LEGUMES';

  RAISE NOTICE '';
  RAISE NOTICE '========================================';
  RAISE NOTICE '  Legumes Nutrition Component Created!';
  RAISE NOTICE '========================================';
  RAISE NOTICE '';
  RAISE NOTICE 'Component Summary:';
  RAISE NOTICE '  Data Entry Fields: % (DEF_LEGUMES_SERVINGS, DEF_LEGUMES_TYPE)', v_data_fields;
  RAISE NOTICE '  Reference Types: % legume types', v_reference_types;
  RAISE NOTICE '  Aggregation Metrics: % total', v_agg_metrics;
  RAISE NOTICE '    - 1 main total (AGG_LEGUMES_SERVINGS)';
  RAISE NOTICE '    - 6 timing breakdowns (breakfast, morning snack, lunch, afternoon snack, dinner, evening snack)';
  RAISE NOTICE '    - 6 type breakdowns (beans, lentils, chickpeas, peas, soy products, other)';
  RAISE NOTICE '  Dependencies: % mappings', v_dependencies;
  RAISE NOTICE '  Calculation Types: % (SUM and AVG for each metric)', v_calc_types;
  RAISE NOTICE '  Periods: % (6 periods × 13 metrics)', v_periods;
  RAISE NOTICE '  Display Metrics: % (total, timing, type)', v_display_metrics;
  RAISE NOTICE '  Display Aggregations: % (mapped to display metrics)', v_display_agg_count;
  RAISE NOTICE '  Display Screens: %', v_screen_count;
  RAISE NOTICE '';
  RAISE NOTICE 'Data Entry Fields:';
  RAISE NOTICE '  DEF_LEGUMES_SERVINGS - Main quantity field (servings)';
  RAISE NOTICE '  DEF_LEGUMES_TYPE - Reference to legume type category';
  RAISE NOTICE '  DEF_FOOD_TIMING - Shared timing field (breakfast, lunch, etc.)';
  RAISE NOTICE '';
  RAISE NOTICE 'Legume Types (6):';
  RAISE NOTICE '  1. Beans (black beans, kidney beans, pinto beans, navy beans)';
  RAISE NOTICE '  2. Lentils (red, green, brown lentils)';
  RAISE NOTICE '  3. Chickpeas (garbanzo beans, hummus)';
  RAISE NOTICE '  4. Peas (split peas, green peas, black-eyed peas)';
  RAISE NOTICE '  5. Soy Products (tofu, tempeh, edamame, soy milk)';
  RAISE NOTICE '  6. Other (other legume varieties)';
  RAISE NOTICE '';
  RAISE NOTICE 'Aggregation Metrics (13 total):';
  RAISE NOTICE '  Main Total:';
  RAISE NOTICE '    AGG_LEGUMES_SERVINGS';
  RAISE NOTICE '';
  RAISE NOTICE '  Timing Breakdown (6):';
  RAISE NOTICE '    AGG_LEGUMES_BREAKFAST_SERVINGS';
  RAISE NOTICE '    AGG_LEGUMES_MORNING_SNACK_SERVINGS';
  RAISE NOTICE '    AGG_LEGUMES_LUNCH_SERVINGS';
  RAISE NOTICE '    AGG_LEGUMES_AFTERNOON_SNACK_SERVINGS';
  RAISE NOTICE '    AGG_LEGUMES_DINNER_SERVINGS';
  RAISE NOTICE '    AGG_LEGUMES_EVENING_SNACK_SERVINGS';
  RAISE NOTICE '';
  RAISE NOTICE '  Type Breakdown (6):';
  RAISE NOTICE '    AGG_LEGUMES_TYPE_BEANS';
  RAISE NOTICE '    AGG_LEGUMES_TYPE_LENTILS';
  RAISE NOTICE '    AGG_LEGUMES_TYPE_CHICKPEAS';
  RAISE NOTICE '    AGG_LEGUMES_TYPE_PEAS';
  RAISE NOTICE '    AGG_LEGUMES_TYPE_SOY_PRODUCTS';
  RAISE NOTICE '    AGG_LEGUMES_TYPE_OTHER';
  RAISE NOTICE '';
  RAISE NOTICE 'Display Metrics (3):';
  RAISE NOTICE '  DISP_LEGUMES_SERVINGS - Total servings (primary)';
  RAISE NOTICE '  DISP_LEGUMES_MEAL_TIMING - Stacked bar by meal timing';
  RAISE NOTICE '  DISP_LEGUMES_TYPE - Stacked bar by legume type';
  RAISE NOTICE '';
  RAISE NOTICE 'Display Screens:';
  RAISE NOTICE '  SCREEN_LEGUMES - Primary legumes tracking screen';
  RAISE NOTICE '  SCREEN_LEGUMES_DETAIL - Detail view with sections:';
  RAISE NOTICE '    - legumes_overview (total servings)';
  RAISE NOTICE '    - legumes_details (timing + type breakdown)';
  RAISE NOTICE '';
  RAISE NOTICE 'Next Steps:';
  RAISE NOTICE '  1. Generate test data for legumes';
  RAISE NOTICE '  2. Run aggregations to populate cache';
  RAISE NOTICE '  3. Verify display metrics show correct data';
  RAISE NOTICE '  4. Test mobile UI with legumes tracking';
  RAISE NOTICE '';
  RAISE NOTICE '========================================';
  RAISE NOTICE '';
END $$;

COMMIT;
