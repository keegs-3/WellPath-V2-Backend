-- =====================================================
-- Create Whole Grains Nutrition Component
-- =====================================================
-- Complete database structure for whole grains tracking
-- Following the protein pattern with servings-based tracking
-- =====================================================

BEGIN;

-- =====================================================
-- STEP 1: Create Data Entry Fields
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
  is_active,
  validation_config
) VALUES (
  'DEF_WHOLE_GRAINS_SERVINGS',
  'whole_grains_servings',
  'Whole Grains',
  'Number of whole grain servings consumed',
  'quantity',
  'numeric',
  'serving',
  NULL,
  false,
  'Healthful Nutrition',
  true,
  '{"min": 0, "max": 20, "increment": 0.5}'::jsonb
) ON CONFLICT (field_id) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  unit = EXCLUDED.unit,
  validation_config = EXCLUDED.validation_config,
  updated_at = NOW();

-- Type field (reference to whole grain types)
INSERT INTO data_entry_fields (
  field_id,
  field_name,
  display_name,
  description,
  field_type,
  data_type,
  reference_table,
  reference_category,
  event_type_id,
  supports_healthkit_sync,
  pillar_name,
  is_active
) VALUES (
  'DEF_WHOLE_GRAINS_TYPE',
  'whole_grains_type',
  'Whole Grain Type',
  'Type of whole grain (Oats, Brown Rice, Quinoa, etc.)',
  'reference',
  'uuid',
  'data_entry_fields_reference',
  'whole_grains_types',
  NULL,
  false,
  'Healthful Nutrition',
  true
) ON CONFLICT (field_id) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  reference_table = EXCLUDED.reference_table,
  reference_category = EXCLUDED.reference_category,
  updated_at = NOW();

-- =====================================================
-- STEP 2: Create Reference Data for Whole Grain Types
-- =====================================================

INSERT INTO data_entry_fields_reference (
  reference_category,
  reference_key,
  display_name,
  description,
  sort_order,
  is_active,
  metadata
) VALUES
  (
    'whole_grains_types',
    'oats',
    'Oats',
    'Oatmeal, oat groats, steel-cut oats',
    1,
    true,
    '{"typical_serving_size": "1/2 cup cooked", "fiber_per_serving": 4}'::jsonb
  ),
  (
    'whole_grains_types',
    'brown_rice',
    'Brown Rice',
    'Brown rice, wild rice',
    2,
    true,
    '{"typical_serving_size": "1/2 cup cooked", "fiber_per_serving": 2}'::jsonb
  ),
  (
    'whole_grains_types',
    'quinoa',
    'Quinoa',
    'Quinoa grain (complete protein)',
    3,
    true,
    '{"typical_serving_size": "1/2 cup cooked", "fiber_per_serving": 3, "is_complete_protein": true}'::jsonb
  ),
  (
    'whole_grains_types',
    'whole_wheat',
    'Whole Wheat',
    'Whole wheat bread, pasta, flour',
    4,
    true,
    '{"typical_serving_size": "1 slice or 1/2 cup cooked", "fiber_per_serving": 3}'::jsonb
  ),
  (
    'whole_grains_types',
    'barley',
    'Barley',
    'Barley grain, pearled barley',
    5,
    true,
    '{"typical_serving_size": "1/2 cup cooked", "fiber_per_serving": 3}'::jsonb
  ),
  (
    'whole_grains_types',
    'ancient_grains',
    'Other Ancient Grains',
    'Farro, spelt, kamut, millet, bulgur, freekeh',
    6,
    true,
    '{"typical_serving_size": "1/2 cup cooked", "fiber_per_serving": 3}'::jsonb
  )
ON CONFLICT (reference_category, reference_key) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  sort_order = EXCLUDED.sort_order,
  metadata = EXCLUDED.metadata,
  updated_at = NOW();

-- =====================================================
-- STEP 3: Create Aggregation Metrics
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
  'AGG_WHOLE_GRAINS_SERVINGS',
  'whole_grains_servings',
  'Whole Grains',
  'Total whole grain servings consumed',
  'serving',
  true
) ON CONFLICT (agg_id) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  is_active = EXCLUDED.is_active;

-- Timing breakdown aggregations (6 meal times)
INSERT INTO aggregation_metrics (
  agg_id,
  metric_name,
  display_name,
  description,
  output_unit,
  is_active
) VALUES
  (
    'AGG_WHOLE_GRAINS_BREAKFAST_SERVINGS',
    'whole_grains_breakfast_servings',
    'Breakfast Whole Grains',
    'Whole grains consumed at breakfast',
    'serving',
    true
  ),
  (
    'AGG_WHOLE_GRAINS_MORNING_SNACK_SERVINGS',
    'whole_grains_morning_snack_servings',
    'Morning Snack Whole Grains',
    'Whole grains consumed during morning snack',
    'serving',
    true
  ),
  (
    'AGG_WHOLE_GRAINS_LUNCH_SERVINGS',
    'whole_grains_lunch_servings',
    'Lunch Whole Grains',
    'Whole grains consumed at lunch',
    'serving',
    true
  ),
  (
    'AGG_WHOLE_GRAINS_AFTERNOON_SNACK_SERVINGS',
    'whole_grains_afternoon_snack_servings',
    'Afternoon Snack Whole Grains',
    'Whole grains consumed during afternoon snack',
    'serving',
    true
  ),
  (
    'AGG_WHOLE_GRAINS_DINNER_SERVINGS',
    'whole_grains_dinner_servings',
    'Dinner Whole Grains',
    'Whole grains consumed at dinner',
    'serving',
    true
  ),
  (
    'AGG_WHOLE_GRAINS_EVENING_SNACK_SERVINGS',
    'whole_grains_evening_snack_servings',
    'Evening Snack Whole Grains',
    'Whole grains consumed during evening snack',
    'serving',
    true
  )
ON CONFLICT (agg_id) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  is_active = EXCLUDED.is_active;

-- Type breakdown aggregations (6 types)
INSERT INTO aggregation_metrics (
  agg_id,
  metric_name,
  display_name,
  description,
  output_unit,
  is_active
) VALUES
  (
    'AGG_WHOLE_GRAINS_TYPE_OATS',
    'whole_grains_type_oats',
    'Oats',
    'Servings of oats consumed',
    'serving',
    true
  ),
  (
    'AGG_WHOLE_GRAINS_TYPE_BROWN_RICE',
    'whole_grains_type_brown_rice',
    'Brown Rice',
    'Servings of brown rice consumed',
    'serving',
    true
  ),
  (
    'AGG_WHOLE_GRAINS_TYPE_QUINOA',
    'whole_grains_type_quinoa',
    'Quinoa',
    'Servings of quinoa consumed',
    'serving',
    true
  ),
  (
    'AGG_WHOLE_GRAINS_TYPE_WHOLE_WHEAT',
    'whole_grains_type_whole_wheat',
    'Whole Wheat',
    'Servings of whole wheat products consumed',
    'serving',
    true
  ),
  (
    'AGG_WHOLE_GRAINS_TYPE_BARLEY',
    'whole_grains_type_barley',
    'Barley',
    'Servings of barley consumed',
    'serving',
    true
  ),
  (
    'AGG_WHOLE_GRAINS_TYPE_ANCIENT_GRAINS',
    'whole_grains_type_ancient_grains',
    'Other Ancient Grains',
    'Servings of other ancient grains consumed',
    'serving',
    true
  )
ON CONFLICT (agg_id) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  is_active = EXCLUDED.is_active;

-- =====================================================
-- STEP 4: Create Aggregation Dependencies
-- =====================================================

-- Main total depends on DEF_WHOLE_GRAINS_SERVINGS
INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id,
  data_entry_field_id,
  dependency_type
) VALUES (
  'AGG_WHOLE_GRAINS_SERVINGS',
  'DEF_WHOLE_GRAINS_SERVINGS',
  'data_field'
) ON CONFLICT DO NOTHING;

-- Timing breakdowns depend on DEF_WHOLE_GRAINS_SERVINGS with filter on DEF_FOOD_TIMING
INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id,
  data_entry_field_id,
  dependency_type,
  filter_conditions
) VALUES
  (
    'AGG_WHOLE_GRAINS_BREAKFAST_SERVINGS',
    'DEF_WHOLE_GRAINS_SERVINGS',
    'data_field',
    '{"reference_field": "DEF_FOOD_TIMING", "reference_value": "breakfast"}'::jsonb
  ),
  (
    'AGG_WHOLE_GRAINS_MORNING_SNACK_SERVINGS',
    'DEF_WHOLE_GRAINS_SERVINGS',
    'data_field',
    '{"reference_field": "DEF_FOOD_TIMING", "reference_value": "morning_snack"}'::jsonb
  ),
  (
    'AGG_WHOLE_GRAINS_LUNCH_SERVINGS',
    'DEF_WHOLE_GRAINS_SERVINGS',
    'data_field',
    '{"reference_field": "DEF_FOOD_TIMING", "reference_value": "lunch"}'::jsonb
  ),
  (
    'AGG_WHOLE_GRAINS_AFTERNOON_SNACK_SERVINGS',
    'DEF_WHOLE_GRAINS_SERVINGS',
    'data_field',
    '{"reference_field": "DEF_FOOD_TIMING", "reference_value": "afternoon_snack"}'::jsonb
  ),
  (
    'AGG_WHOLE_GRAINS_DINNER_SERVINGS',
    'DEF_WHOLE_GRAINS_SERVINGS',
    'data_field',
    '{"reference_field": "DEF_FOOD_TIMING", "reference_value": "dinner"}'::jsonb
  ),
  (
    'AGG_WHOLE_GRAINS_EVENING_SNACK_SERVINGS',
    'DEF_WHOLE_GRAINS_SERVINGS',
    'data_field',
    '{"reference_field": "DEF_FOOD_TIMING", "reference_value": "evening_snack"}'::jsonb
  )
ON CONFLICT DO NOTHING;

-- Type breakdowns depend on DEF_WHOLE_GRAINS_SERVINGS with filter on DEF_WHOLE_GRAINS_TYPE
INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id,
  data_entry_field_id,
  dependency_type,
  filter_conditions
) VALUES
  (
    'AGG_WHOLE_GRAINS_TYPE_OATS',
    'DEF_WHOLE_GRAINS_SERVINGS',
    'data_field',
    '{"reference_field": "DEF_WHOLE_GRAINS_TYPE", "reference_value": "oats"}'::jsonb
  ),
  (
    'AGG_WHOLE_GRAINS_TYPE_BROWN_RICE',
    'DEF_WHOLE_GRAINS_SERVINGS',
    'data_field',
    '{"reference_field": "DEF_WHOLE_GRAINS_TYPE", "reference_value": "brown_rice"}'::jsonb
  ),
  (
    'AGG_WHOLE_GRAINS_TYPE_QUINOA',
    'DEF_WHOLE_GRAINS_SERVINGS',
    'data_field',
    '{"reference_field": "DEF_WHOLE_GRAINS_TYPE", "reference_value": "quinoa"}'::jsonb
  ),
  (
    'AGG_WHOLE_GRAINS_TYPE_WHOLE_WHEAT',
    'DEF_WHOLE_GRAINS_SERVINGS',
    'data_field',
    '{"reference_field": "DEF_WHOLE_GRAINS_TYPE", "reference_value": "whole_wheat"}'::jsonb
  ),
  (
    'AGG_WHOLE_GRAINS_TYPE_BARLEY',
    'DEF_WHOLE_GRAINS_SERVINGS',
    'data_field',
    '{"reference_field": "DEF_WHOLE_GRAINS_TYPE", "reference_value": "barley"}'::jsonb
  ),
  (
    'AGG_WHOLE_GRAINS_TYPE_ANCIENT_GRAINS',
    'DEF_WHOLE_GRAINS_SERVINGS',
    'data_field',
    '{"reference_field": "DEF_WHOLE_GRAINS_TYPE", "reference_value": "ancient_grains"}'::jsonb
  )
ON CONFLICT DO NOTHING;

-- =====================================================
-- STEP 5: Create Aggregation Calculation Types
-- =====================================================

-- Add SUM and AVG calculation types for all aggregations
INSERT INTO aggregation_metrics_calculation_types (
  aggregation_metric_id,
  calculation_type_id
)
SELECT agg_id, calc_type
FROM (VALUES
  ('AGG_WHOLE_GRAINS_SERVINGS'),
  ('AGG_WHOLE_GRAINS_BREAKFAST_SERVINGS'),
  ('AGG_WHOLE_GRAINS_MORNING_SNACK_SERVINGS'),
  ('AGG_WHOLE_GRAINS_LUNCH_SERVINGS'),
  ('AGG_WHOLE_GRAINS_AFTERNOON_SNACK_SERVINGS'),
  ('AGG_WHOLE_GRAINS_DINNER_SERVINGS'),
  ('AGG_WHOLE_GRAINS_EVENING_SNACK_SERVINGS'),
  ('AGG_WHOLE_GRAINS_TYPE_OATS'),
  ('AGG_WHOLE_GRAINS_TYPE_BROWN_RICE'),
  ('AGG_WHOLE_GRAINS_TYPE_QUINOA'),
  ('AGG_WHOLE_GRAINS_TYPE_WHOLE_WHEAT'),
  ('AGG_WHOLE_GRAINS_TYPE_BARLEY'),
  ('AGG_WHOLE_GRAINS_TYPE_ANCIENT_GRAINS')
) AS aggs(agg_id)
CROSS JOIN (VALUES ('SUM'), ('AVG')) AS calc_types(calc_type)
ON CONFLICT DO NOTHING;

-- =====================================================
-- STEP 6: Create Aggregation Periods
-- =====================================================

-- Add all standard periods (hourly, daily, weekly, monthly, 6month, yearly)
INSERT INTO aggregation_metrics_periods (
  agg_metric_id,
  period_id
)
SELECT agg_id, period
FROM (VALUES
  ('AGG_WHOLE_GRAINS_SERVINGS'),
  ('AGG_WHOLE_GRAINS_BREAKFAST_SERVINGS'),
  ('AGG_WHOLE_GRAINS_MORNING_SNACK_SERVINGS'),
  ('AGG_WHOLE_GRAINS_LUNCH_SERVINGS'),
  ('AGG_WHOLE_GRAINS_AFTERNOON_SNACK_SERVINGS'),
  ('AGG_WHOLE_GRAINS_DINNER_SERVINGS'),
  ('AGG_WHOLE_GRAINS_EVENING_SNACK_SERVINGS'),
  ('AGG_WHOLE_GRAINS_TYPE_OATS'),
  ('AGG_WHOLE_GRAINS_TYPE_BROWN_RICE'),
  ('AGG_WHOLE_GRAINS_TYPE_QUINOA'),
  ('AGG_WHOLE_GRAINS_TYPE_WHOLE_WHEAT'),
  ('AGG_WHOLE_GRAINS_TYPE_BARLEY'),
  ('AGG_WHOLE_GRAINS_TYPE_ANCIENT_GRAINS')
) AS aggs(agg_id)
CROSS JOIN (VALUES
  ('hourly'),
  ('daily'),
  ('weekly'),
  ('monthly'),
  ('6month'),
  ('yearly')
) AS periods(period)
ON CONFLICT DO NOTHING;

-- =====================================================
-- STEP 7: Create Display Metrics
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
  'DISP_WHOLE_GRAINS_SERVINGS',
  'Whole Grains',
  'Total whole grain servings consumed',
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
  'DISP_WHOLE_GRAINS_MEAL_TIMING',
  'Whole Grains by Meal',
  'Whole grain servings breakdown by meal timing (breakfast, lunch, dinner, snacks)',
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
  'DISP_WHOLE_GRAINS_TYPE',
  'Whole Grains by Type',
  'Breakdown of whole grain servings by type (oats, brown rice, quinoa, whole wheat, barley, ancient grains)',
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
-- STEP 8: Map Aggregations to Display Metrics
-- =====================================================

-- Main total (daily SUM, weekly AVG, monthly AVG, yearly AVG)
INSERT INTO display_metrics_aggregations (
  metric_id,
  agg_metric_id,
  period_type,
  calculation_type_id,
  display_order
) VALUES
  ('DISP_WHOLE_GRAINS_SERVINGS', 'AGG_WHOLE_GRAINS_SERVINGS', 'daily', 'SUM', 1),
  ('DISP_WHOLE_GRAINS_SERVINGS', 'AGG_WHOLE_GRAINS_SERVINGS', 'weekly', 'AVG', 2),
  ('DISP_WHOLE_GRAINS_SERVINGS', 'AGG_WHOLE_GRAINS_SERVINGS', 'monthly', 'AVG', 3),
  ('DISP_WHOLE_GRAINS_SERVINGS', 'AGG_WHOLE_GRAINS_SERVINGS', 'yearly', 'AVG', 4)
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
  ('DISP_WHOLE_GRAINS_MEAL_TIMING', 'AGG_WHOLE_GRAINS_BREAKFAST_SERVINGS', 'daily', 'SUM', 1),
  ('DISP_WHOLE_GRAINS_MEAL_TIMING', 'AGG_WHOLE_GRAINS_MORNING_SNACK_SERVINGS', 'daily', 'SUM', 2),
  ('DISP_WHOLE_GRAINS_MEAL_TIMING', 'AGG_WHOLE_GRAINS_LUNCH_SERVINGS', 'daily', 'SUM', 3),
  ('DISP_WHOLE_GRAINS_MEAL_TIMING', 'AGG_WHOLE_GRAINS_AFTERNOON_SNACK_SERVINGS', 'daily', 'SUM', 4),
  ('DISP_WHOLE_GRAINS_MEAL_TIMING', 'AGG_WHOLE_GRAINS_DINNER_SERVINGS', 'daily', 'SUM', 5),
  ('DISP_WHOLE_GRAINS_MEAL_TIMING', 'AGG_WHOLE_GRAINS_EVENING_SNACK_SERVINGS', 'daily', 'SUM', 6),

  -- Weekly AVG
  ('DISP_WHOLE_GRAINS_MEAL_TIMING', 'AGG_WHOLE_GRAINS_BREAKFAST_SERVINGS', 'weekly', 'AVG', 7),
  ('DISP_WHOLE_GRAINS_MEAL_TIMING', 'AGG_WHOLE_GRAINS_MORNING_SNACK_SERVINGS', 'weekly', 'AVG', 8),
  ('DISP_WHOLE_GRAINS_MEAL_TIMING', 'AGG_WHOLE_GRAINS_LUNCH_SERVINGS', 'weekly', 'AVG', 9),
  ('DISP_WHOLE_GRAINS_MEAL_TIMING', 'AGG_WHOLE_GRAINS_AFTERNOON_SNACK_SERVINGS', 'weekly', 'AVG', 10),
  ('DISP_WHOLE_GRAINS_MEAL_TIMING', 'AGG_WHOLE_GRAINS_DINNER_SERVINGS', 'weekly', 'AVG', 11),
  ('DISP_WHOLE_GRAINS_MEAL_TIMING', 'AGG_WHOLE_GRAINS_EVENING_SNACK_SERVINGS', 'weekly', 'AVG', 12)
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
  ('DISP_WHOLE_GRAINS_TYPE', 'AGG_WHOLE_GRAINS_TYPE_OATS', 'daily', 'SUM', 1),
  ('DISP_WHOLE_GRAINS_TYPE', 'AGG_WHOLE_GRAINS_TYPE_BROWN_RICE', 'daily', 'SUM', 2),
  ('DISP_WHOLE_GRAINS_TYPE', 'AGG_WHOLE_GRAINS_TYPE_QUINOA', 'daily', 'SUM', 3),
  ('DISP_WHOLE_GRAINS_TYPE', 'AGG_WHOLE_GRAINS_TYPE_WHOLE_WHEAT', 'daily', 'SUM', 4),
  ('DISP_WHOLE_GRAINS_TYPE', 'AGG_WHOLE_GRAINS_TYPE_BARLEY', 'daily', 'SUM', 5),
  ('DISP_WHOLE_GRAINS_TYPE', 'AGG_WHOLE_GRAINS_TYPE_ANCIENT_GRAINS', 'daily', 'SUM', 6),

  -- Weekly AVG
  ('DISP_WHOLE_GRAINS_TYPE', 'AGG_WHOLE_GRAINS_TYPE_OATS', 'weekly', 'AVG', 7),
  ('DISP_WHOLE_GRAINS_TYPE', 'AGG_WHOLE_GRAINS_TYPE_BROWN_RICE', 'weekly', 'AVG', 8),
  ('DISP_WHOLE_GRAINS_TYPE', 'AGG_WHOLE_GRAINS_TYPE_QUINOA', 'weekly', 'AVG', 9),
  ('DISP_WHOLE_GRAINS_TYPE', 'AGG_WHOLE_GRAINS_TYPE_WHOLE_WHEAT', 'weekly', 'AVG', 10),
  ('DISP_WHOLE_GRAINS_TYPE', 'AGG_WHOLE_GRAINS_TYPE_BARLEY', 'weekly', 'AVG', 11),
  ('DISP_WHOLE_GRAINS_TYPE', 'AGG_WHOLE_GRAINS_TYPE_ANCIENT_GRAINS', 'weekly', 'AVG', 12)
ON CONFLICT DO NOTHING;

-- =====================================================
-- STEP 9: Create Display Screens
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
  'SCREEN_WHOLE_GRAINS',
  'Whole Grains',
  'Track your whole grain intake by servings, timing, and type',
  'Healthful Nutrition',
  'grains',
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
  'SCREEN_WHOLE_GRAINS',
  'Whole Grains Tracking',
  'Optimize your whole grain intake',
  'Monitor total whole grain servings, meal timing distribution, and grain type variety for optimal nutrition, sustained energy, and digestive health.',
  'sections',
  jsonb_build_array(
    jsonb_build_object(
      'section_id', 'whole_grains_overview',
      'section_title', 'Whole Grains Overview',
      'section_type', 'metrics_grid',
      'display_order', 1
    ),
    jsonb_build_object(
      'section_id', 'whole_grains_details',
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
-- STEP 10: Link Display Metrics to Detail Screen
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
    'SCREEN_WHOLE_GRAINS_DETAIL',
    'DISP_WHOLE_GRAINS_SERVINGS',
    'whole_grains_overview',
    1,
    'Total Whole Grains',
    'Your total whole grain servings per day'
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
    'SCREEN_WHOLE_GRAINS_DETAIL',
    'DISP_WHOLE_GRAINS_MEAL_TIMING',
    'whole_grains_details',
    1,
    'Whole Grains by Meal',
    'Distribution of whole grain servings across breakfast, lunch, dinner, and snacks'
  ),
  (
    'SCREEN_WHOLE_GRAINS_DETAIL',
    'DISP_WHOLE_GRAINS_TYPE',
    'whole_grains_details',
    2,
    'Whole Grains by Type',
    'Breakdown by grain type: oats, brown rice, quinoa, whole wheat, barley, and ancient grains'
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
  v_agg_metrics_count INTEGER;
  v_deps_count INTEGER;
  v_calc_types_count INTEGER;
  v_periods_count INTEGER;
  v_display_metrics_count INTEGER;
  v_display_agg_count INTEGER;
  v_screen_count INTEGER;
BEGIN
  -- Count created records
  SELECT COUNT(*) INTO v_fields_count
  FROM data_entry_fields
  WHERE field_id IN ('DEF_WHOLE_GRAINS_SERVINGS', 'DEF_WHOLE_GRAINS_TYPE');

  SELECT COUNT(*) INTO v_ref_count
  FROM data_entry_fields_reference
  WHERE reference_category = 'whole_grains_types';

  SELECT COUNT(*) INTO v_agg_metrics_count
  FROM aggregation_metrics
  WHERE agg_id LIKE 'AGG_WHOLE_GRAINS%';

  SELECT COUNT(*) INTO v_deps_count
  FROM aggregation_metrics_dependencies
  WHERE agg_metric_id LIKE 'AGG_WHOLE_GRAINS%';

  SELECT COUNT(*) INTO v_calc_types_count
  FROM aggregation_metrics_calculation_types
  WHERE aggregation_metric_id LIKE 'AGG_WHOLE_GRAINS%';

  SELECT COUNT(*) INTO v_periods_count
  FROM aggregation_metrics_periods
  WHERE agg_metric_id LIKE 'AGG_WHOLE_GRAINS%';

  SELECT COUNT(*) INTO v_display_metrics_count
  FROM display_metrics
  WHERE metric_id LIKE 'DISP_WHOLE_GRAINS%';

  SELECT COUNT(*) INTO v_display_agg_count
  FROM display_metrics_aggregations
  WHERE metric_id LIKE 'DISP_WHOLE_GRAINS%';

  SELECT COUNT(*) INTO v_screen_count
  FROM display_screens
  WHERE screen_id = 'SCREEN_WHOLE_GRAINS';

  RAISE NOTICE '';
  RAISE NOTICE '========================================';
  RAISE NOTICE 'Whole Grains Nutrition Component Created!';
  RAISE NOTICE '========================================';
  RAISE NOTICE '';
  RAISE NOTICE 'Component Summary:';
  RAISE NOTICE '  Data Entry Fields: % (DEF_WHOLE_GRAINS_SERVINGS, DEF_WHOLE_GRAINS_TYPE)', v_fields_count;
  RAISE NOTICE '  Reference Values: % grain types', v_ref_count;
  RAISE NOTICE '  Aggregation Metrics: % (1 total + 6 timing + 6 type)', v_agg_metrics_count;
  RAISE NOTICE '  Dependencies: % (with filter conditions for timing and type)', v_deps_count;
  RAISE NOTICE '  Calculation Types: % (SUM + AVG for all metrics)', v_calc_types_count;
  RAISE NOTICE '  Periods: % (hourly, daily, weekly, monthly, 6month, yearly)', v_periods_count;
  RAISE NOTICE '  Display Metrics: % (total, timing, type)', v_display_metrics_count;
  RAISE NOTICE '  Display Aggregations: % (mapped to display metrics)', v_display_agg_count;
  RAISE NOTICE '  Display Screens: %', v_screen_count;
  RAISE NOTICE '';
  RAISE NOTICE 'Data Entry Fields:';
  RAISE NOTICE '  DEF_WHOLE_GRAINS_SERVINGS - Main quantity field (servings)';
  RAISE NOTICE '  DEF_WHOLE_GRAINS_TYPE - Reference to grain type category';
  RAISE NOTICE '  DEF_FOOD_TIMING - Shared timing field (breakfast, lunch, etc.)';
  RAISE NOTICE '';
  RAISE NOTICE 'Whole Grain Types (6):';
  RAISE NOTICE '  1. Oats (oatmeal, oat groats, steel-cut oats)';
  RAISE NOTICE '  2. Brown Rice (brown rice, wild rice)';
  RAISE NOTICE '  3. Quinoa (quinoa grain, complete protein)';
  RAISE NOTICE '  4. Whole Wheat (whole wheat bread, pasta, flour)';
  RAISE NOTICE '  5. Barley (barley grain, pearled barley)';
  RAISE NOTICE '  6. Other Ancient Grains (farro, spelt, kamut, millet, bulgur, freekeh)';
  RAISE NOTICE '';
  RAISE NOTICE 'Aggregation Metrics (13 total):';
  RAISE NOTICE '  Main Total:';
  RAISE NOTICE '    AGG_WHOLE_GRAINS_SERVINGS';
  RAISE NOTICE '';
  RAISE NOTICE '  Timing Breakdown (6):';
  RAISE NOTICE '    AGG_WHOLE_GRAINS_BREAKFAST_SERVINGS';
  RAISE NOTICE '    AGG_WHOLE_GRAINS_MORNING_SNACK_SERVINGS';
  RAISE NOTICE '    AGG_WHOLE_GRAINS_LUNCH_SERVINGS';
  RAISE NOTICE '    AGG_WHOLE_GRAINS_AFTERNOON_SNACK_SERVINGS';
  RAISE NOTICE '    AGG_WHOLE_GRAINS_DINNER_SERVINGS';
  RAISE NOTICE '    AGG_WHOLE_GRAINS_EVENING_SNACK_SERVINGS';
  RAISE NOTICE '';
  RAISE NOTICE '  Type Breakdown (6):';
  RAISE NOTICE '    AGG_WHOLE_GRAINS_TYPE_OATS';
  RAISE NOTICE '    AGG_WHOLE_GRAINS_TYPE_BROWN_RICE';
  RAISE NOTICE '    AGG_WHOLE_GRAINS_TYPE_QUINOA';
  RAISE NOTICE '    AGG_WHOLE_GRAINS_TYPE_WHOLE_WHEAT';
  RAISE NOTICE '    AGG_WHOLE_GRAINS_TYPE_BARLEY';
  RAISE NOTICE '    AGG_WHOLE_GRAINS_TYPE_ANCIENT_GRAINS';
  RAISE NOTICE '';
  RAISE NOTICE 'Display Metrics (3):';
  RAISE NOTICE '  DISP_WHOLE_GRAINS_SERVINGS - Total servings (primary)';
  RAISE NOTICE '  DISP_WHOLE_GRAINS_MEAL_TIMING - Stacked bar by meal timing';
  RAISE NOTICE '  DISP_WHOLE_GRAINS_TYPE - Stacked bar by grain type';
  RAISE NOTICE '';
  RAISE NOTICE 'Display Screens:';
  RAISE NOTICE '  SCREEN_WHOLE_GRAINS - Primary whole grains tracking screen';
  RAISE NOTICE '  SCREEN_WHOLE_GRAINS_DETAIL - Detail view with sections:';
  RAISE NOTICE '    - whole_grains_overview (total servings)';
  RAISE NOTICE '    - whole_grains_details (timing + type breakdown)';
  RAISE NOTICE '';
  RAISE NOTICE 'Next Steps:';
  RAISE NOTICE '  1. Generate test data for whole grains';
  RAISE NOTICE '  2. Run aggregations to populate cache';
  RAISE NOTICE '  3. Verify display metrics show correct data';
  RAISE NOTICE '  4. Test mobile UI with whole grains tracking';
  RAISE NOTICE '';
  RAISE NOTICE '========================================';
  RAISE NOTICE '';
END $$;

COMMIT;
