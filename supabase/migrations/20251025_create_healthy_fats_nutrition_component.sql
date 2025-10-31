-- =====================================================
-- Create Healthy Fats Nutrition Component
-- =====================================================
-- Following the protein pattern established in the codebase
-- Creates:
-- 1. Data entry fields (DEF_HEALTHY_FATS_SERVINGS, DEF_HEALTHY_FATS_TYPE)
-- 2. Reference data for types (Avocado, Nuts, Seeds, Olive Oil, Fatty Fish, Other)
-- 3. Aggregation metrics (main + timing + type breakdowns)
-- 4. Dependencies, calculation types, periods
-- 5. Display metrics and screen configuration
-- =====================================================

BEGIN;

-- =====================================================
-- 1. Create Data Entry Fields
-- =====================================================

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
) VALUES
  (
    'DEF_HEALTHY_FATS_SERVINGS',
    'healthy_fats_servings',
    'Healthy Fats',
    'Servings of healthy fats consumed',
    'quantity',
    'numeric',
    'serving',
    NULL,
    false,
    'Healthful Nutrition',
    true,
    '{"min": 0, "max": 20, "increment": 0.25}'::jsonb
  ),
  (
    'DEF_HEALTHY_FATS_TYPE',
    'healthy_fats_type',
    'Healthy Fats Type',
    'Type of healthy fat consumed',
    'reference',
    'text',
    NULL,
    NULL,
    false,
    'Healthful Nutrition',
    true,
    NULL
  ),
  (
    'DEF_HEALTHY_FATS_TIMING',
    'healthy_fats_timing',
    'Healthy Fats Timing',
    'Meal timing for healthy fats consumption',
    'reference',
    'text',
    NULL,
    NULL,
    false,
    'Healthful Nutrition',
    true,
    NULL
  )
ON CONFLICT (field_id) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  updated_at = NOW();

-- Set reference tables
UPDATE data_entry_fields
SET reference_table = 'data_entry_fields_reference'
WHERE field_id IN ('DEF_HEALTHY_FATS_TYPE', 'DEF_HEALTHY_FATS_TIMING');

-- =====================================================
-- 2. Create Reference Data for Healthy Fats Types
-- =====================================================

INSERT INTO data_entry_fields_reference (
  reference_category,
  reference_key,
  display_name,
  description,
  display_order,
  is_active
) VALUES
  -- Healthy Fats Types
  ('healthy_fats_types', 'avocado', 'Avocado', 'Avocado and avocado oil', 1, true),
  ('healthy_fats_types', 'nuts', 'Nuts', 'Almonds, walnuts, cashews, pecans, etc.', 2, true),
  ('healthy_fats_types', 'seeds', 'Seeds', 'Chia, flax, hemp, pumpkin, sunflower seeds', 3, true),
  ('healthy_fats_types', 'olive_oil', 'Olive Oil', 'Extra virgin olive oil and olives', 4, true),
  ('healthy_fats_types', 'fatty_fish', 'Fatty Fish', 'Salmon, mackerel, sardines, anchovies', 5, true),
  ('healthy_fats_types', 'other', 'Other', 'Other healthy fat sources', 6, true),

  -- Food Timing (shared reference)
  ('food_timing', 'breakfast', 'Breakfast', 'Morning meal', 1, true),
  ('food_timing', 'morning_snack', 'Morning Snack', 'Mid-morning snack', 2, true),
  ('food_timing', 'lunch', 'Lunch', 'Midday meal', 3, true),
  ('food_timing', 'afternoon_snack', 'Afternoon Snack', 'Mid-afternoon snack', 4, true),
  ('food_timing', 'dinner', 'Dinner', 'Evening meal', 5, true),
  ('food_timing', 'evening_snack', 'Evening Snack', 'Late evening snack', 6, true),
  ('food_timing', 'other', 'Other', 'Other times', 7, true)
ON CONFLICT (reference_category, reference_key) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  display_order = EXCLUDED.display_order,
  updated_at = NOW();

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
) VALUES
  (
    'AGG_HEALTHY_FATS_SERVINGS',
    'healthy_fats_servings',
    'Healthy Fats',
    'Total servings of healthy fats consumed',
    'serving',
    true
  )
ON CONFLICT (agg_id) DO UPDATE SET
  metric_name = EXCLUDED.metric_name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  updated_at = NOW();

-- Timing breakdown aggregations
INSERT INTO aggregation_metrics (
  agg_id,
  metric_name,
  display_name,
  description,
  output_unit,
  is_active
) VALUES
  ('AGG_HEALTHY_FATS_BREAKFAST_SERVINGS', 'healthy_fats_breakfast_servings', 'Breakfast Healthy Fats', 'Healthy fats consumed at breakfast', 'serving', true),
  ('AGG_HEALTHY_FATS_MORNING_SNACK_SERVINGS', 'healthy_fats_morning_snack_servings', 'Morning Snack Healthy Fats', 'Healthy fats consumed during morning snack', 'serving', true),
  ('AGG_HEALTHY_FATS_LUNCH_SERVINGS', 'healthy_fats_lunch_servings', 'Lunch Healthy Fats', 'Healthy fats consumed at lunch', 'serving', true),
  ('AGG_HEALTHY_FATS_AFTERNOON_SNACK_SERVINGS', 'healthy_fats_afternoon_snack_servings', 'Afternoon Snack Healthy Fats', 'Healthy fats consumed during afternoon snack', 'serving', true),
  ('AGG_HEALTHY_FATS_DINNER_SERVINGS', 'healthy_fats_dinner_servings', 'Dinner Healthy Fats', 'Healthy fats consumed at dinner', 'serving', true),
  ('AGG_HEALTHY_FATS_EVENING_SNACK_SERVINGS', 'healthy_fats_evening_snack_servings', 'Evening Snack Healthy Fats', 'Healthy fats consumed during evening snack', 'serving', true),
  ('AGG_HEALTHY_FATS_OTHER_SERVINGS', 'healthy_fats_other_servings', 'Other Time Healthy Fats', 'Healthy fats consumed at other times', 'serving', true)
ON CONFLICT (agg_id) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  updated_at = NOW();

-- Type breakdown aggregations
INSERT INTO aggregation_metrics (
  agg_id,
  metric_name,
  display_name,
  description,
  output_unit,
  is_active
) VALUES
  ('AGG_HEALTHY_FATS_TYPE_AVOCADO', 'healthy_fats_type_avocado', 'Avocado Servings', 'Servings of avocado and avocado oil', 'serving', true),
  ('AGG_HEALTHY_FATS_TYPE_NUTS', 'healthy_fats_type_nuts', 'Nuts Servings', 'Servings of nuts', 'serving', true),
  ('AGG_HEALTHY_FATS_TYPE_SEEDS', 'healthy_fats_type_seeds', 'Seeds Servings', 'Servings of seeds', 'serving', true),
  ('AGG_HEALTHY_FATS_TYPE_OLIVE_OIL', 'healthy_fats_type_olive_oil', 'Olive Oil Servings', 'Servings of olive oil and olives', 'serving', true),
  ('AGG_HEALTHY_FATS_TYPE_FATTY_FISH', 'healthy_fats_type_fatty_fish', 'Fatty Fish Servings', 'Servings of fatty fish', 'serving', true),
  ('AGG_HEALTHY_FATS_TYPE_OTHER', 'healthy_fats_type_other', 'Other Healthy Fats Servings', 'Servings of other healthy fats', 'serving', true)
ON CONFLICT (agg_id) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  updated_at = NOW();

-- =====================================================
-- 4. Create Aggregation Dependencies
-- =====================================================

-- Main aggregation depends on servings field
INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id,
  data_entry_field_id,
  dependency_type
) VALUES
  ('AGG_HEALTHY_FATS_SERVINGS', 'DEF_HEALTHY_FATS_SERVINGS', 'data_field')
ON CONFLICT DO NOTHING;

-- Timing aggregations with filter conditions
INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id,
  data_entry_field_id,
  dependency_type,
  filter_conditions
) VALUES
  ('AGG_HEALTHY_FATS_BREAKFAST_SERVINGS', 'DEF_HEALTHY_FATS_SERVINGS', 'data_field', '{"reference_field": "DEF_HEALTHY_FATS_TIMING", "reference_value": "breakfast"}'::jsonb),
  ('AGG_HEALTHY_FATS_MORNING_SNACK_SERVINGS', 'DEF_HEALTHY_FATS_SERVINGS', 'data_field', '{"reference_field": "DEF_HEALTHY_FATS_TIMING", "reference_value": "morning_snack"}'::jsonb),
  ('AGG_HEALTHY_FATS_LUNCH_SERVINGS', 'DEF_HEALTHY_FATS_SERVINGS', 'data_field', '{"reference_field": "DEF_HEALTHY_FATS_TIMING", "reference_value": "lunch"}'::jsonb),
  ('AGG_HEALTHY_FATS_AFTERNOON_SNACK_SERVINGS', 'DEF_HEALTHY_FATS_SERVINGS', 'data_field', '{"reference_field": "DEF_HEALTHY_FATS_TIMING", "reference_value": "afternoon_snack"}'::jsonb),
  ('AGG_HEALTHY_FATS_DINNER_SERVINGS', 'DEF_HEALTHY_FATS_SERVINGS', 'data_field', '{"reference_field": "DEF_HEALTHY_FATS_TIMING", "reference_value": "dinner"}'::jsonb),
  ('AGG_HEALTHY_FATS_EVENING_SNACK_SERVINGS', 'DEF_HEALTHY_FATS_SERVINGS', 'data_field', '{"reference_field": "DEF_HEALTHY_FATS_TIMING", "reference_value": "evening_snack"}'::jsonb),
  ('AGG_HEALTHY_FATS_OTHER_SERVINGS', 'DEF_HEALTHY_FATS_SERVINGS', 'data_field', '{"reference_field": "DEF_HEALTHY_FATS_TIMING", "reference_value": "other"}'::jsonb)
ON CONFLICT DO NOTHING;

-- Type aggregations with filter conditions
INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id,
  data_entry_field_id,
  dependency_type,
  filter_conditions
) VALUES
  ('AGG_HEALTHY_FATS_TYPE_AVOCADO', 'DEF_HEALTHY_FATS_SERVINGS', 'data_field', '{"reference_field": "DEF_HEALTHY_FATS_TYPE", "reference_value": "avocado"}'::jsonb),
  ('AGG_HEALTHY_FATS_TYPE_NUTS', 'DEF_HEALTHY_FATS_SERVINGS', 'data_field', '{"reference_field": "DEF_HEALTHY_FATS_TYPE", "reference_value": "nuts"}'::jsonb),
  ('AGG_HEALTHY_FATS_TYPE_SEEDS', 'DEF_HEALTHY_FATS_SERVINGS', 'data_field', '{"reference_field": "DEF_HEALTHY_FATS_TYPE", "reference_value": "seeds"}'::jsonb),
  ('AGG_HEALTHY_FATS_TYPE_OLIVE_OIL', 'DEF_HEALTHY_FATS_SERVINGS', 'data_field', '{"reference_field": "DEF_HEALTHY_FATS_TYPE", "reference_value": "olive_oil"}'::jsonb),
  ('AGG_HEALTHY_FATS_TYPE_FATTY_FISH', 'DEF_HEALTHY_FATS_SERVINGS', 'data_field', '{"reference_field": "DEF_HEALTHY_FATS_TYPE", "reference_value": "fatty_fish"}'::jsonb),
  ('AGG_HEALTHY_FATS_TYPE_OTHER', 'DEF_HEALTHY_FATS_SERVINGS', 'data_field', '{"reference_field": "DEF_HEALTHY_FATS_TYPE", "reference_value": "other"}'::jsonb)
ON CONFLICT DO NOTHING;

-- =====================================================
-- 5. Create Calculation Types
-- =====================================================

-- All aggregations support SUM and AVG
INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
SELECT agg_id, calc_type
FROM (VALUES
  ('AGG_HEALTHY_FATS_SERVINGS'),
  ('AGG_HEALTHY_FATS_BREAKFAST_SERVINGS'),
  ('AGG_HEALTHY_FATS_MORNING_SNACK_SERVINGS'),
  ('AGG_HEALTHY_FATS_LUNCH_SERVINGS'),
  ('AGG_HEALTHY_FATS_AFTERNOON_SNACK_SERVINGS'),
  ('AGG_HEALTHY_FATS_DINNER_SERVINGS'),
  ('AGG_HEALTHY_FATS_EVENING_SNACK_SERVINGS'),
  ('AGG_HEALTHY_FATS_OTHER_SERVINGS'),
  ('AGG_HEALTHY_FATS_TYPE_AVOCADO'),
  ('AGG_HEALTHY_FATS_TYPE_NUTS'),
  ('AGG_HEALTHY_FATS_TYPE_SEEDS'),
  ('AGG_HEALTHY_FATS_TYPE_OLIVE_OIL'),
  ('AGG_HEALTHY_FATS_TYPE_FATTY_FISH'),
  ('AGG_HEALTHY_FATS_TYPE_OTHER')
) AS aggs(agg_id)
CROSS JOIN (VALUES ('SUM'), ('AVG')) AS calc_types(calc_type)
ON CONFLICT DO NOTHING;

-- =====================================================
-- 6. Create Aggregation Periods
-- =====================================================

-- All aggregations support hourly, daily, weekly, monthly, 6month, yearly
INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
SELECT agg_id, period
FROM (VALUES
  ('AGG_HEALTHY_FATS_SERVINGS'),
  ('AGG_HEALTHY_FATS_BREAKFAST_SERVINGS'),
  ('AGG_HEALTHY_FATS_MORNING_SNACK_SERVINGS'),
  ('AGG_HEALTHY_FATS_LUNCH_SERVINGS'),
  ('AGG_HEALTHY_FATS_AFTERNOON_SNACK_SERVINGS'),
  ('AGG_HEALTHY_FATS_DINNER_SERVINGS'),
  ('AGG_HEALTHY_FATS_EVENING_SNACK_SERVINGS'),
  ('AGG_HEALTHY_FATS_OTHER_SERVINGS'),
  ('AGG_HEALTHY_FATS_TYPE_AVOCADO'),
  ('AGG_HEALTHY_FATS_TYPE_NUTS'),
  ('AGG_HEALTHY_FATS_TYPE_SEEDS'),
  ('AGG_HEALTHY_FATS_TYPE_OLIVE_OIL'),
  ('AGG_HEALTHY_FATS_TYPE_FATTY_FISH'),
  ('AGG_HEALTHY_FATS_TYPE_OTHER')
) AS aggs(agg_id)
CROSS JOIN (VALUES ('hourly'), ('daily'), ('weekly'), ('monthly'), ('6month'), ('yearly')) AS periods(period)
ON CONFLICT DO NOTHING;

-- =====================================================
-- 7. Create Display Metrics
-- =====================================================

-- Main display metric for total servings
INSERT INTO display_metrics (
  metric_id,
  metric_name,
  description,
  pillar,
  chart_type_id,
  is_active,
  is_primary
) VALUES
  (
    'DISP_HEALTHY_FATS_SERVINGS',
    'Healthy Fats',
    'Total servings of healthy fats consumed',
    'Healthful Nutrition',
    'bar_grouped',
    true,
    true
  )
ON CONFLICT (metric_id) DO UPDATE SET
  metric_name = EXCLUDED.metric_name,
  description = EXCLUDED.description,
  chart_type_id = EXCLUDED.chart_type_id,
  updated_at = NOW();

-- Display metric for meal timing breakdown
INSERT INTO display_metrics (
  metric_id,
  metric_name,
  description,
  pillar,
  chart_type_id,
  is_active,
  is_primary
) VALUES
  (
    'DISP_HEALTHY_FATS_MEAL_TIMING',
    'Healthy Fats by Meal',
    'Healthy fats consumption by meal timing (breakfast, lunch, dinner, snacks)',
    'Healthful Nutrition',
    'bar_stacked',
    true,
    false
  )
ON CONFLICT (metric_id) DO UPDATE SET
  metric_name = EXCLUDED.metric_name,
  description = EXCLUDED.description,
  chart_type_id = EXCLUDED.chart_type_id,
  updated_at = NOW();

-- Display metric for type breakdown
INSERT INTO display_metrics (
  metric_id,
  metric_name,
  description,
  pillar,
  chart_type_id,
  is_active,
  is_primary
) VALUES
  (
    'DISP_HEALTHY_FATS_TYPE',
    'Healthy Fats by Type',
    'Breakdown of healthy fats consumption by source type (avocado, nuts, seeds, olive oil, fatty fish)',
    'Healthful Nutrition',
    'bar_stacked',
    true,
    false
  )
ON CONFLICT (metric_id) DO UPDATE SET
  metric_name = EXCLUDED.metric_name,
  description = EXCLUDED.description,
  chart_type_id = EXCLUDED.chart_type_id,
  updated_at = NOW();

-- =====================================================
-- 8. Map Aggregations to Display Metrics
-- =====================================================

-- Main servings display metric (daily SUM, weekly AVG)
INSERT INTO display_metrics_aggregations (
  metric_id,
  agg_metric_id,
  period_type,
  calculation_type_id,
  display_order
) VALUES
  ('DISP_HEALTHY_FATS_SERVINGS', 'AGG_HEALTHY_FATS_SERVINGS', 'daily', 'SUM', 1),
  ('DISP_HEALTHY_FATS_SERVINGS', 'AGG_HEALTHY_FATS_SERVINGS', 'weekly', 'AVG', 2)
ON CONFLICT DO NOTHING;

-- Meal timing display metric (7 timing options × 2 periods)
INSERT INTO display_metrics_aggregations (
  metric_id,
  agg_metric_id,
  period_type,
  calculation_type_id,
  display_order
) VALUES
  -- Daily SUM for all 7 timings
  ('DISP_HEALTHY_FATS_MEAL_TIMING', 'AGG_HEALTHY_FATS_BREAKFAST_SERVINGS', 'daily', 'SUM', 1),
  ('DISP_HEALTHY_FATS_MEAL_TIMING', 'AGG_HEALTHY_FATS_MORNING_SNACK_SERVINGS', 'daily', 'SUM', 2),
  ('DISP_HEALTHY_FATS_MEAL_TIMING', 'AGG_HEALTHY_FATS_LUNCH_SERVINGS', 'daily', 'SUM', 3),
  ('DISP_HEALTHY_FATS_MEAL_TIMING', 'AGG_HEALTHY_FATS_AFTERNOON_SNACK_SERVINGS', 'daily', 'SUM', 4),
  ('DISP_HEALTHY_FATS_MEAL_TIMING', 'AGG_HEALTHY_FATS_DINNER_SERVINGS', 'daily', 'SUM', 5),
  ('DISP_HEALTHY_FATS_MEAL_TIMING', 'AGG_HEALTHY_FATS_EVENING_SNACK_SERVINGS', 'daily', 'SUM', 6),
  ('DISP_HEALTHY_FATS_MEAL_TIMING', 'AGG_HEALTHY_FATS_OTHER_SERVINGS', 'daily', 'SUM', 7),

  -- Weekly AVG for all 7 timings
  ('DISP_HEALTHY_FATS_MEAL_TIMING', 'AGG_HEALTHY_FATS_BREAKFAST_SERVINGS', 'weekly', 'AVG', 8),
  ('DISP_HEALTHY_FATS_MEAL_TIMING', 'AGG_HEALTHY_FATS_MORNING_SNACK_SERVINGS', 'weekly', 'AVG', 9),
  ('DISP_HEALTHY_FATS_MEAL_TIMING', 'AGG_HEALTHY_FATS_LUNCH_SERVINGS', 'weekly', 'AVG', 10),
  ('DISP_HEALTHY_FATS_MEAL_TIMING', 'AGG_HEALTHY_FATS_AFTERNOON_SNACK_SERVINGS', 'weekly', 'AVG', 11),
  ('DISP_HEALTHY_FATS_MEAL_TIMING', 'AGG_HEALTHY_FATS_DINNER_SERVINGS', 'weekly', 'AVG', 12),
  ('DISP_HEALTHY_FATS_MEAL_TIMING', 'AGG_HEALTHY_FATS_EVENING_SNACK_SERVINGS', 'weekly', 'AVG', 13),
  ('DISP_HEALTHY_FATS_MEAL_TIMING', 'AGG_HEALTHY_FATS_OTHER_SERVINGS', 'weekly', 'AVG', 14)
ON CONFLICT DO NOTHING;

-- Type display metric (6 types × 2 periods)
INSERT INTO display_metrics_aggregations (
  metric_id,
  agg_metric_id,
  period_type,
  calculation_type_id,
  display_order
) VALUES
  -- Daily SUM for all 6 types
  ('DISP_HEALTHY_FATS_TYPE', 'AGG_HEALTHY_FATS_TYPE_AVOCADO', 'daily', 'SUM', 1),
  ('DISP_HEALTHY_FATS_TYPE', 'AGG_HEALTHY_FATS_TYPE_NUTS', 'daily', 'SUM', 2),
  ('DISP_HEALTHY_FATS_TYPE', 'AGG_HEALTHY_FATS_TYPE_SEEDS', 'daily', 'SUM', 3),
  ('DISP_HEALTHY_FATS_TYPE', 'AGG_HEALTHY_FATS_TYPE_OLIVE_OIL', 'daily', 'SUM', 4),
  ('DISP_HEALTHY_FATS_TYPE', 'AGG_HEALTHY_FATS_TYPE_FATTY_FISH', 'daily', 'SUM', 5),
  ('DISP_HEALTHY_FATS_TYPE', 'AGG_HEALTHY_FATS_TYPE_OTHER', 'daily', 'SUM', 6),

  -- Weekly AVG for all 6 types
  ('DISP_HEALTHY_FATS_TYPE', 'AGG_HEALTHY_FATS_TYPE_AVOCADO', 'weekly', 'AVG', 7),
  ('DISP_HEALTHY_FATS_TYPE', 'AGG_HEALTHY_FATS_TYPE_NUTS', 'weekly', 'AVG', 8),
  ('DISP_HEALTHY_FATS_TYPE', 'AGG_HEALTHY_FATS_TYPE_SEEDS', 'weekly', 'AVG', 9),
  ('DISP_HEALTHY_FATS_TYPE', 'AGG_HEALTHY_FATS_TYPE_OLIVE_OIL', 'weekly', 'AVG', 10),
  ('DISP_HEALTHY_FATS_TYPE', 'AGG_HEALTHY_FATS_TYPE_FATTY_FISH', 'weekly', 'AVG', 11),
  ('DISP_HEALTHY_FATS_TYPE', 'AGG_HEALTHY_FATS_TYPE_OTHER', 'weekly', 'AVG', 12)
ON CONFLICT DO NOTHING;

-- =====================================================
-- 9. Create Display Screen
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
) VALUES
  (
    'SCREEN_HEALTHY_FATS',
    'Healthy Fats',
    'Track your healthy fats intake by servings, timing, and source type',
    'Healthful Nutrition',
    'nutrition',
    'D',
    'detailed',
    10,
    'detailed',
    true
  )
ON CONFLICT (screen_id) DO UPDATE SET
  name = EXCLUDED.name,
  overview = EXCLUDED.overview,
  pillar = EXCLUDED.pillar,
  updated_at = NOW();

-- =====================================================
-- 10. Configure Detail Screen
-- =====================================================

INSERT INTO display_screens_detail (
  display_screen_id,
  title,
  subtitle,
  description,
  layout_type,
  section_config,
  show_insights,
  is_active
) VALUES
  (
    'SCREEN_HEALTHY_FATS_DETAIL',
    'Healthy Fats Tracking',
    'Optimize your healthy fats intake',
    'Monitor total healthy fats consumption, meal timing distribution, and fat source types (avocado, nuts, seeds, olive oil, fatty fish) for optimal health and inflammation control.',
    'sections',
    jsonb_build_array(
      jsonb_build_object(
        'section_id', 'healthy_fats_overview',
        'section_title', 'Healthy Fats Overview',
        'section_type', 'metrics_grid',
        'display_order', 1
      ),
      jsonb_build_object(
        'section_id', 'healthy_fats_details',
        'section_title', 'Detailed Breakdown',
        'section_type', 'metrics_detailed',
        'display_order', 2
      )
    ),
    true,
    true
  )
ON CONFLICT (display_screen_id) DO UPDATE SET
  title = EXCLUDED.title,
  subtitle = EXCLUDED.subtitle,
  description = EXCLUDED.description,
  section_config = EXCLUDED.section_config,
  updated_at = NOW();

-- =====================================================
-- 11. Link Display Metrics to Detail Screen
-- =====================================================

-- Overview Section: Total Servings
INSERT INTO display_screens_detail_display_metrics (
  detail_screen_id,
  metric_id,
  section_id,
  display_order,
  context_label,
  context_description
) VALUES
  (
    'SCREEN_HEALTHY_FATS_DETAIL',
    'DISP_HEALTHY_FATS_SERVINGS',
    'healthy_fats_overview',
    1,
    'Total Servings',
    'Your total healthy fats intake in servings'
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
    'SCREEN_HEALTHY_FATS_DETAIL',
    'DISP_HEALTHY_FATS_MEAL_TIMING',
    'healthy_fats_details',
    1,
    'Healthy Fats by Meal',
    'Distribution of healthy fats across meals and snacks'
  ),
  (
    'SCREEN_HEALTHY_FATS_DETAIL',
    'DISP_HEALTHY_FATS_TYPE',
    'healthy_fats_details',
    2,
    'Healthy Fats by Source',
    'Breakdown by source: avocado, nuts, seeds, olive oil, fatty fish, and other'
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
  v_field_count INTEGER;
  v_ref_count INTEGER;
  v_agg_count INTEGER;
  v_timing_agg_count INTEGER;
  v_type_agg_count INTEGER;
  v_dep_count INTEGER;
  v_calc_types_count INTEGER;
  v_periods_count INTEGER;
  v_display_metrics_count INTEGER;
  v_display_agg_count INTEGER;
BEGIN
  -- Count data entry fields
  SELECT COUNT(*) INTO v_field_count
  FROM data_entry_fields
  WHERE field_id LIKE 'DEF_HEALTHY_FATS%';

  -- Count reference data
  SELECT COUNT(*) INTO v_ref_count
  FROM data_entry_fields_reference
  WHERE reference_category = 'healthy_fats_types';

  -- Count aggregation metrics
  SELECT COUNT(*) INTO v_agg_count
  FROM aggregation_metrics
  WHERE agg_id LIKE 'AGG_HEALTHY_FATS%';

  SELECT COUNT(*) INTO v_timing_agg_count
  FROM aggregation_metrics
  WHERE agg_id LIKE 'AGG_HEALTHY_FATS_%_SERVINGS' AND agg_id != 'AGG_HEALTHY_FATS_SERVINGS';

  SELECT COUNT(*) INTO v_type_agg_count
  FROM aggregation_metrics
  WHERE agg_id LIKE 'AGG_HEALTHY_FATS_TYPE_%';

  -- Count dependencies
  SELECT COUNT(*) INTO v_dep_count
  FROM aggregation_metrics_dependencies
  WHERE agg_metric_id LIKE 'AGG_HEALTHY_FATS%';

  -- Count calculation types
  SELECT COUNT(*) INTO v_calc_types_count
  FROM aggregation_metrics_calculation_types
  WHERE aggregation_metric_id LIKE 'AGG_HEALTHY_FATS%';

  -- Count periods
  SELECT COUNT(*) INTO v_periods_count
  FROM aggregation_metrics_periods
  WHERE agg_metric_id LIKE 'AGG_HEALTHY_FATS%';

  -- Count display metrics
  SELECT COUNT(*) INTO v_display_metrics_count
  FROM display_metrics
  WHERE metric_id LIKE 'DISP_HEALTHY_FATS%';

  -- Count display metric aggregations
  SELECT COUNT(*) INTO v_display_agg_count
  FROM display_metrics_aggregations
  WHERE metric_id LIKE 'DISP_HEALTHY_FATS%';

  RAISE NOTICE '';
  RAISE NOTICE '========================================';
  RAISE NOTICE '  Healthy Fats Component Created!';
  RAISE NOTICE '========================================';
  RAISE NOTICE '';
  RAISE NOTICE 'Data Entry Fields: %', v_field_count;
  RAISE NOTICE '  • DEF_HEALTHY_FATS_SERVINGS';
  RAISE NOTICE '  • DEF_HEALTHY_FATS_TYPE';
  RAISE NOTICE '  • DEF_HEALTHY_FATS_TIMING';
  RAISE NOTICE '';
  RAISE NOTICE 'Reference Data: % types', v_ref_count;
  RAISE NOTICE '  • Avocado';
  RAISE NOTICE '  • Nuts';
  RAISE NOTICE '  • Seeds';
  RAISE NOTICE '  • Olive Oil';
  RAISE NOTICE '  • Fatty Fish';
  RAISE NOTICE '  • Other';
  RAISE NOTICE '';
  RAISE NOTICE 'Aggregation Metrics: % total', v_agg_count;
  RAISE NOTICE '  • 1 main total (AGG_HEALTHY_FATS_SERVINGS)';
  RAISE NOTICE '  • % timing breakdowns', v_timing_agg_count;
  RAISE NOTICE '  • % type breakdowns', v_type_agg_count;
  RAISE NOTICE '';
  RAISE NOTICE 'Dependencies: %', v_dep_count;
  RAISE NOTICE 'Calculation Types: % (SUM + AVG for each metric)', v_calc_types_count;
  RAISE NOTICE 'Periods: % (6 periods × % metrics)', v_periods_count, v_agg_count;
  RAISE NOTICE '';
  RAISE NOTICE 'Display Metrics: %', v_display_metrics_count;
  RAISE NOTICE '  • DISP_HEALTHY_FATS_SERVINGS (primary)';
  RAISE NOTICE '  • DISP_HEALTHY_FATS_MEAL_TIMING';
  RAISE NOTICE '  • DISP_HEALTHY_FATS_TYPE';
  RAISE NOTICE '';
  RAISE NOTICE 'Display Aggregation Mappings: %', v_display_agg_count;
  RAISE NOTICE '';
  RAISE NOTICE 'Screen Structure:';
  RAISE NOTICE '  📱 SCREEN_HEALTHY_FATS → Healthy Fats tracking screen';
  RAISE NOTICE '  📄 SCREEN_HEALTHY_FATS_DETAIL → Detail view';
  RAISE NOTICE '';
  RAISE NOTICE 'Sections:';
  RAISE NOTICE '  📊 healthy_fats_overview:';
  RAISE NOTICE '     • DISP_HEALTHY_FATS_SERVINGS - Total servings';
  RAISE NOTICE '  📈 healthy_fats_details:';
  RAISE NOTICE '     • DISP_HEALTHY_FATS_MEAL_TIMING - 7 meal timings';
  RAISE NOTICE '     • DISP_HEALTHY_FATS_TYPE - 6 source types';
  RAISE NOTICE '';
  RAISE NOTICE 'Ready for:';
  RAISE NOTICE '  ✓ Data entry via mobile app';
  RAISE NOTICE '  ✓ Aggregation processing';
  RAISE NOTICE '  ✓ Display in nutrition screens';
  RAISE NOTICE '';
END $$;

COMMIT;
