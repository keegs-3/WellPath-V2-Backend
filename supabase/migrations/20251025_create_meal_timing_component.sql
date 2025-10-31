-- =====================================================
-- Create Meal Timing Component
-- =====================================================
-- Special nutrition component that tracks:
-- - First meal time (timestamp)
-- - Last meal time (timestamp)
-- - Eating window duration (calculated in hours)
--
-- Supports floating bar visualization (first → last meal)
-- with user-adjustable targets and backup bar chart
--
-- Created: 2025-10-25
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Create Data Entry Fields
-- =====================================================

-- First meal time (timestamp field)
INSERT INTO data_entry_fields (
  field_id,
  field_name,
  display_name,
  description,
  field_type,
  data_type,
  event_type_id,
  supports_healthkit_sync,
  pillar_name,
  is_active
) VALUES (
  'DEF_FIRST_MEAL_TIME',
  'first_meal_time',
  'First Meal Time',
  'Time of first meal/caloric intake of the day',
  'simple',
  'timestamptz',
  NULL,
  false,
  'Healthful Nutrition',
  true
)
ON CONFLICT (field_id) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  data_type = EXCLUDED.data_type,
  updated_at = NOW();

-- Last meal time (timestamp field)
INSERT INTO data_entry_fields (
  field_id,
  field_name,
  display_name,
  description,
  field_type,
  data_type,
  event_type_id,
  supports_healthkit_sync,
  pillar_name,
  is_active
) VALUES (
  'DEF_LAST_MEAL_TIME',
  'last_meal_time',
  'Last Meal Time',
  'Time of last meal/caloric intake of the day',
  'simple',
  'timestamptz',
  NULL,
  false,
  'Healthful Nutrition',
  true
)
ON CONFLICT (field_id) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  data_type = EXCLUDED.data_type,
  updated_at = NOW();


-- =====================================================
-- PART 2: Create Instance Calculation (Eating Window)
-- =====================================================

-- Calculate eating window in hours (last_meal_time - first_meal_time)
INSERT INTO instance_calculations (
  calc_id,
  calc_name,
  display_name,
  description,
  calculation_method,
  unit_id,
  calculation_config
) VALUES (
  'CALC_EATING_WINDOW_HOURS',
  'eating_window_hours',
  'Eating Window Duration',
  'Calculate eating window in hours (time between first and last meal)',
  'time_difference',
  'hour',
  '{
    "operation": "time_difference",
    "output_unit": "hour",
    "output_field": "DEF_EATING_WINDOW_HOURS",
    "output_source": "auto_calculated"
  }'::jsonb
)
ON CONFLICT (calc_id) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  calculation_config = EXCLUDED.calculation_config,
  updated_at = NOW();

-- Add dependencies for eating window calculation
INSERT INTO instance_calculations_dependencies (
  instance_calculation_id,
  data_entry_field_id,
  parameter_name,
  parameter_role,
  parameter_order
) VALUES
  ('CALC_EATING_WINDOW_HOURS', 'DEF_FIRST_MEAL_TIME', 'start_time', 'start_time', 1),
  ('CALC_EATING_WINDOW_HOURS', 'DEF_LAST_MEAL_TIME', 'end_time', 'end_time', 2)
ON CONFLICT DO NOTHING;


-- =====================================================
-- PART 3: Register Fields in Field Registry
-- =====================================================

-- Register first meal time (user input)
INSERT INTO field_registry (
  field_id,
  field_name,
  display_name,
  description,
  field_source,
  data_entry_field_id,
  unit,
  is_active
) VALUES (
  'DEF_FIRST_MEAL_TIME',
  'first_meal_time',
  'First Meal Time',
  'Time of first meal/caloric intake of the day',
  'user_input',
  'DEF_FIRST_MEAL_TIME',
  NULL,
  true
)
ON CONFLICT (field_id) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  updated_at = NOW();

-- Register last meal time (user input)
INSERT INTO field_registry (
  field_id,
  field_name,
  display_name,
  description,
  field_source,
  data_entry_field_id,
  unit,
  is_active
) VALUES (
  'DEF_LAST_MEAL_TIME',
  'last_meal_time',
  'Last Meal Time',
  'Time of last meal/caloric intake of the day',
  'user_input',
  'DEF_LAST_MEAL_TIME',
  NULL,
  true
)
ON CONFLICT (field_id) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  updated_at = NOW();

-- Register eating window (calculated)
INSERT INTO field_registry (
  field_id,
  field_name,
  display_name,
  description,
  field_source,
  instance_calculation_id,
  unit,
  is_active
) VALUES (
  'DEF_EATING_WINDOW_HOURS',
  'eating_window_hours',
  'Eating Window Duration',
  'Calculated eating window in hours (last meal - first meal)',
  'calculated',
  'CALC_EATING_WINDOW_HOURS',
  'hour',
  true
)
ON CONFLICT (field_id) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  instance_calculation_id = EXCLUDED.instance_calculation_id,
  updated_at = NOW();


-- =====================================================
-- PART 4: Create Aggregation Metrics
-- =====================================================

-- AGG_FIRST_MEAL_TIME_AVG - Average first meal time
INSERT INTO aggregation_metrics (
  agg_id,
  metric_name,
  display_name,
  description,
  output_unit,
  is_active
) VALUES (
  'AGG_FIRST_MEAL_TIME_AVG',
  'first_meal_time_avg',
  'Average First Meal Time',
  'Average time of first meal across the period',
  'time',
  true
)
ON CONFLICT (agg_id) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  updated_at = NOW();

-- AGG_LAST_MEAL_TIME_AVG - Average last meal time
INSERT INTO aggregation_metrics (
  agg_id,
  metric_name,
  display_name,
  description,
  output_unit,
  is_active
) VALUES (
  'AGG_LAST_MEAL_TIME_AVG',
  'last_meal_time_avg',
  'Average Last Meal Time',
  'Average time of last meal across the period',
  'time',
  true
)
ON CONFLICT (agg_id) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  updated_at = NOW();

-- AGG_EATING_WINDOW_HOURS - Average eating window duration
INSERT INTO aggregation_metrics (
  agg_id,
  metric_name,
  display_name,
  description,
  output_unit,
  is_active
) VALUES (
  'AGG_EATING_WINDOW_HOURS',
  'eating_window_hours',
  'Average Eating Window',
  'Average eating window duration in hours',
  'hour',
  true
)
ON CONFLICT (agg_id) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  updated_at = NOW();


-- =====================================================
-- PART 5: Create Aggregation Dependencies
-- =====================================================

-- First meal time depends on DEF_FIRST_MEAL_TIME
INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id,
  data_entry_field_id,
  dependency_type
) VALUES (
  'AGG_FIRST_MEAL_TIME_AVG',
  'DEF_FIRST_MEAL_TIME',
  'data_field'
)
ON CONFLICT DO NOTHING;

-- Last meal time depends on DEF_LAST_MEAL_TIME
INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id,
  data_entry_field_id,
  dependency_type
) VALUES (
  'AGG_LAST_MEAL_TIME_AVG',
  'DEF_LAST_MEAL_TIME',
  'data_field'
)
ON CONFLICT DO NOTHING;

-- Eating window depends on the calculated field
INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id,
  data_entry_field_id,
  dependency_type
) VALUES (
  'AGG_EATING_WINDOW_HOURS',
  'DEF_EATING_WINDOW_HOURS',
  'data_field'
)
ON CONFLICT DO NOTHING;


-- =====================================================
-- PART 6: Create Aggregation Calculation Types
-- =====================================================

-- First meal time: MIN, MAX, AVG
INSERT INTO aggregation_metrics_calculation_types (
  aggregation_metric_id,
  calculation_type_id
)
SELECT agg_id, calc_type
FROM (VALUES ('AGG_FIRST_MEAL_TIME_AVG')) AS aggs(agg_id)
CROSS JOIN (VALUES ('MIN'), ('MAX'), ('AVG')) AS calc_types(calc_type)
ON CONFLICT DO NOTHING;

-- Last meal time: MIN, MAX, AVG
INSERT INTO aggregation_metrics_calculation_types (
  aggregation_metric_id,
  calculation_type_id
)
SELECT agg_id, calc_type
FROM (VALUES ('AGG_LAST_MEAL_TIME_AVG')) AS aggs(agg_id)
CROSS JOIN (VALUES ('MIN'), ('MAX'), ('AVG')) AS calc_types(calc_type)
ON CONFLICT DO NOTHING;

-- Eating window: MIN, MAX, AVG
INSERT INTO aggregation_metrics_calculation_types (
  aggregation_metric_id,
  calculation_type_id
)
SELECT agg_id, calc_type
FROM (VALUES ('AGG_EATING_WINDOW_HOURS')) AS aggs(agg_id)
CROSS JOIN (VALUES ('MIN'), ('MAX'), ('AVG')) AS calc_types(calc_type)
ON CONFLICT DO NOTHING;


-- =====================================================
-- PART 7: Create Aggregation Periods
-- =====================================================

-- All metrics support all standard periods
INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
SELECT agg_id, period
FROM (VALUES
  ('AGG_FIRST_MEAL_TIME_AVG'),
  ('AGG_LAST_MEAL_TIME_AVG'),
  ('AGG_EATING_WINDOW_HOURS')
) AS aggs(agg_id)
CROSS JOIN (VALUES
  ('daily'),
  ('weekly'),
  ('monthly'),
  ('6month'),
  ('yearly')
) AS periods(period)
ON CONFLICT DO NOTHING;


-- =====================================================
-- PART 8: Create Display Metrics
-- =====================================================

-- Primary display metric for meal timing (floating bar visualization)
INSERT INTO display_metrics (
  metric_id,
  metric_name,
  display_name,
  description,
  category,
  subcategory,
  chart_type,
  is_active
) VALUES (
  'DISP_MEAL_TIMING',
  'meal_timing',
  'Meal Timing',
  'First and last meal times with eating window duration',
  'Nutrition',
  'Meal Timing',
  'floating_bar',
  true
)
ON CONFLICT (metric_id) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  chart_type = EXCLUDED.chart_type,
  updated_at = NOW();

-- Backup/alternative display metric (eating window bar chart)
INSERT INTO display_metrics (
  metric_id,
  metric_name,
  display_name,
  description,
  category,
  subcategory,
  chart_type,
  is_active
) VALUES (
  'DISP_EATING_WINDOW',
  'eating_window',
  'Eating Window Duration',
  'Duration of daily eating window in hours',
  'Nutrition',
  'Meal Timing',
  'bar',
  true
)
ON CONFLICT (metric_id) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  updated_at = NOW();


-- =====================================================
-- PART 9: Link Aggregations to Display Metrics
-- =====================================================

-- DISP_MEAL_TIMING - Primary view (floating bar: first → last)
INSERT INTO display_metrics_aggregations (
  metric_id,
  agg_metric_id,
  period_type,
  calculation_type_id,
  display_order
) VALUES
  -- Daily - AVG first/last times
  ('DISP_MEAL_TIMING', 'AGG_FIRST_MEAL_TIME_AVG', 'daily', 'AVG', 1),
  ('DISP_MEAL_TIMING', 'AGG_LAST_MEAL_TIME_AVG', 'daily', 'AVG', 2),

  -- Weekly - AVG first/last times
  ('DISP_MEAL_TIMING', 'AGG_FIRST_MEAL_TIME_AVG', 'weekly', 'AVG', 3),
  ('DISP_MEAL_TIMING', 'AGG_LAST_MEAL_TIME_AVG', 'weekly', 'AVG', 4),

  -- Monthly - AVG first/last times
  ('DISP_MEAL_TIMING', 'AGG_FIRST_MEAL_TIME_AVG', 'monthly', 'AVG', 5),
  ('DISP_MEAL_TIMING', 'AGG_LAST_MEAL_TIME_AVG', 'monthly', 'AVG', 6)
ON CONFLICT DO NOTHING;

-- DISP_EATING_WINDOW - Backup view (bar chart of window duration)
INSERT INTO display_metrics_aggregations (
  metric_id,
  agg_metric_id,
  period_type,
  calculation_type_id,
  display_order
) VALUES
  -- Daily - AVG eating window
  ('DISP_EATING_WINDOW', 'AGG_EATING_WINDOW_HOURS', 'daily', 'AVG', 1),
  ('DISP_EATING_WINDOW', 'AGG_EATING_WINDOW_HOURS', 'daily', 'MIN', 2),
  ('DISP_EATING_WINDOW', 'AGG_EATING_WINDOW_HOURS', 'daily', 'MAX', 3),

  -- Weekly - AVG eating window
  ('DISP_EATING_WINDOW', 'AGG_EATING_WINDOW_HOURS', 'weekly', 'AVG', 4),
  ('DISP_EATING_WINDOW', 'AGG_EATING_WINDOW_HOURS', 'weekly', 'MIN', 5),
  ('DISP_EATING_WINDOW', 'AGG_EATING_WINDOW_HOURS', 'weekly', 'MAX', 6),

  -- Monthly - AVG eating window
  ('DISP_EATING_WINDOW', 'AGG_EATING_WINDOW_HOURS', 'monthly', 'AVG', 7),
  ('DISP_EATING_WINDOW', 'AGG_EATING_WINDOW_HOURS', 'monthly', 'MIN', 8),
  ('DISP_EATING_WINDOW', 'AGG_EATING_WINDOW_HOURS', 'monthly', 'MAX', 9)
ON CONFLICT DO NOTHING;


-- =====================================================
-- PART 10: Create Display Screens
-- =====================================================

-- Primary screen - Meal Timing (floating bar view)
INSERT INTO display_screens (
  screen_id,
  screen_name,
  display_name,
  description,
  screen_type,
  category,
  is_active
) VALUES (
  'SCREEN_MEAL_TIMING',
  'meal_timing',
  'Meal Timing',
  'View first/last meal times and eating window with adjustable targets',
  'primary',
  'Nutrition',
  true
)
ON CONFLICT (screen_id) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  updated_at = NOW();

-- Link primary display metric to screen
INSERT INTO display_screens_metrics (
  screen_id,
  metric_id,
  display_order
) VALUES (
  'SCREEN_MEAL_TIMING',
  'DISP_MEAL_TIMING',
  1
)
ON CONFLICT DO NOTHING;

-- Optionally link eating window backup view
INSERT INTO display_screens_metrics (
  screen_id,
  metric_id,
  display_order
) VALUES (
  'SCREEN_MEAL_TIMING',
  'DISP_EATING_WINDOW',
  2
)
ON CONFLICT DO NOTHING;


-- =====================================================
-- Summary
-- =====================================================

DO $$
DECLARE
  v_data_fields INTEGER;
  v_instance_calcs INTEGER;
  v_agg_metrics INTEGER;
  v_display_metrics INTEGER;
  v_screens INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_data_fields
  FROM data_entry_fields
  WHERE field_id IN ('DEF_FIRST_MEAL_TIME', 'DEF_LAST_MEAL_TIME');

  SELECT COUNT(*) INTO v_instance_calcs
  FROM instance_calculations
  WHERE calc_id = 'CALC_EATING_WINDOW_HOURS';

  SELECT COUNT(*) INTO v_agg_metrics
  FROM aggregation_metrics
  WHERE agg_id IN ('AGG_FIRST_MEAL_TIME_AVG', 'AGG_LAST_MEAL_TIME_AVG', 'AGG_EATING_WINDOW_HOURS');

  SELECT COUNT(*) INTO v_display_metrics
  FROM display_metrics
  WHERE metric_id IN ('DISP_MEAL_TIMING', 'DISP_EATING_WINDOW');

  SELECT COUNT(*) INTO v_screens
  FROM display_screens
  WHERE screen_id = 'SCREEN_MEAL_TIMING';

  RAISE NOTICE '';
  RAISE NOTICE '=======================================================';
  RAISE NOTICE '✅ Meal Timing Component Created Successfully!';
  RAISE NOTICE '=======================================================';
  RAISE NOTICE '';
  RAISE NOTICE 'Component Summary:';
  RAISE NOTICE '  Data Entry Fields: %', v_data_fields;
  RAISE NOTICE '    • DEF_FIRST_MEAL_TIME (timestamp)';
  RAISE NOTICE '    • DEF_LAST_MEAL_TIME (timestamp)';
  RAISE NOTICE '';
  RAISE NOTICE '  Instance Calculations: %', v_instance_calcs;
  RAISE NOTICE '    • CALC_EATING_WINDOW_HOURS (last - first in hours)';
  RAISE NOTICE '';
  RAISE NOTICE '  Aggregation Metrics: %', v_agg_metrics;
  RAISE NOTICE '    • AGG_FIRST_MEAL_TIME_AVG (MIN/MAX/AVG)';
  RAISE NOTICE '    • AGG_LAST_MEAL_TIME_AVG (MIN/MAX/AVG)';
  RAISE NOTICE '    • AGG_EATING_WINDOW_HOURS (MIN/MAX/AVG)';
  RAISE NOTICE '';
  RAISE NOTICE '  Display Metrics: %', v_display_metrics;
  RAISE NOTICE '    • DISP_MEAL_TIMING (floating bar: first → last)';
  RAISE NOTICE '    • DISP_EATING_WINDOW (bar chart: window duration)';
  RAISE NOTICE '';
  RAISE NOTICE '  Display Screens: %', v_screens;
  RAISE NOTICE '    • SCREEN_MEAL_TIMING (primary view)';
  RAISE NOTICE '';
  RAISE NOTICE 'Periods Supported: daily, weekly, monthly, 6month, yearly';
  RAISE NOTICE 'Calculation Types: MIN, MAX, AVG';
  RAISE NOTICE '';
  RAISE NOTICE 'Visualization:';
  RAISE NOTICE '  Primary: Floating bar showing first meal → last meal';
  RAISE NOTICE '  Backup: Bar chart showing eating window duration';
  RAISE NOTICE '  Features: User-adjustable targets for optimal timing';
  RAISE NOTICE '';
  RAISE NOTICE 'Next Steps:';
  RAISE NOTICE '  1. Generate test data for meal timing';
  RAISE NOTICE '  2. Run aggregations to populate cache';
  RAISE NOTICE '  3. Verify calculations are correct';
  RAISE NOTICE '  4. Test floating bar visualization';
  RAISE NOTICE '';
  RAISE NOTICE '=======================================================';
END $$;

COMMIT;
