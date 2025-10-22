-- =====================================================
-- Create Aggregation Metrics - Correct Architecture
-- =====================================================
-- Creates aggregation_metrics for:
-- 1. Data entry fields (raw values to aggregate)
-- 2. Instance calculations (calculated values to aggregate)
--
-- Then uses aggregation_metrics_calculation_types to specify HOW to aggregate
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- Clear existing
TRUNCATE TABLE aggregation_metrics CASCADE;

-- =====================================================
-- PART 1: Aggregation Metrics for Data Entry Fields
-- =====================================================
-- These aggregate raw field values (timestamps, types, qualifiers, etc.)

-- Meal Time
INSERT INTO aggregation_metrics (
  id, agg_id, metric_name, display_name, description, output_unit, is_active
) VALUES (
  gen_random_uuid(), 'AGG_MEAL_TIME', 'meal_time', 'Meal Time',
  'Aggregates meal timestamps (first, last, count)', 'datetime_combined', true
);

-- Meal Type
INSERT INTO aggregation_metrics (
  id, agg_id, metric_name, display_name, description, output_unit, is_active
) VALUES (
  gen_random_uuid(), 'AGG_MEAL_TYPE', 'meal_type', 'Meal Type',
  'Aggregates meal types (count by breakfast/lunch/dinner)', 'count', true
);

-- Meal Qualifiers
INSERT INTO aggregation_metrics (
  id, agg_id, metric_name, display_name, description, output_unit, is_active
) VALUES (
  gen_random_uuid(), 'AGG_MEAL_QUALIFIERS', 'meal_qualifiers', 'Meal Qualifiers',
  'Aggregates meal qualifiers (mindful, whole foods, etc.)', 'count', true
);

-- Cardio Type
INSERT INTO aggregation_metrics (
  id, agg_id, metric_name, display_name, description, output_unit, is_active
) VALUES (
  gen_random_uuid(), 'AGG_CARDIO_TYPE', 'cardio_type', 'Cardio Type',
  'Aggregates cardio types (count by running/cycling/swimming)', 'count', true
);

-- Strength Type
INSERT INTO aggregation_metrics (
  id, agg_id, metric_name, display_name, description, output_unit, is_active
) VALUES (
  gen_random_uuid(), 'AGG_STRENGTH_TYPE', 'strength_type', 'Strength Type',
  'Aggregates strength types (count by type)', 'count', true
);

-- Flexibility Type
INSERT INTO aggregation_metrics (
  id, agg_id, metric_name, display_name, description, output_unit, is_active
) VALUES (
  gen_random_uuid(), 'AGG_FLEXIBILITY_TYPE', 'flexibility_type', 'Flexibility Type',
  'Aggregates flexibility types (count by type)', 'count', true
);

-- Sleep Period Type
INSERT INTO aggregation_metrics (
  id, agg_id, metric_name, display_name, description, output_unit, is_active
) VALUES (
  gen_random_uuid(), 'AGG_SLEEP_PERIOD_TYPE', 'sleep_period_type', 'Sleep Period Type',
  'Aggregates sleep period types (count by REM/Deep/Core/Awake)', 'count', true
);

-- Sleep Quality
INSERT INTO aggregation_metrics (
  id, agg_id, metric_name, display_name, description, output_unit, is_active
) VALUES (
  gen_random_uuid(), 'AGG_SLEEP_QUALITY', 'sleep_quality', 'Sleep Quality',
  'Aggregates sleep quality ratings', 'count', true
);

-- Mindfulness Type
INSERT INTO aggregation_metrics (
  id, agg_id, metric_name, display_name, description, output_unit, is_active
) VALUES (
  gen_random_uuid(), 'AGG_MINDFULNESS_TYPE', 'mindfulness_type', 'Mindfulness Type',
  'Aggregates mindfulness types', 'count', true
);

-- Screening Type
INSERT INTO aggregation_metrics (
  id, agg_id, metric_name, display_name, description, output_unit, is_active
) VALUES (
  gen_random_uuid(), 'AGG_SCREENING_TYPE', 'screening_type', 'Screening Type',
  'Aggregates screening types', 'count', true
);


-- =====================================================
-- PART 2: Aggregation Metrics for Instance Calculations
-- =====================================================
-- These aggregate calculated values (durations, ratios, cross-event metrics)

-- Cardio Duration
INSERT INTO aggregation_metrics (
  id, agg_id, metric_name, display_name, description, output_unit, is_active
) VALUES (
  gen_random_uuid(), 'AGG_CARDIO_DURATION', 'cardio_duration', 'Cardio Duration',
  'Aggregates cardio session durations', 'minute', true
);

-- Strength Duration
INSERT INTO aggregation_metrics (
  id, agg_id, metric_name, display_name, description, output_unit, is_active
) VALUES (
  gen_random_uuid(), 'AGG_STRENGTH_DURATION', 'strength_duration', 'Strength Duration',
  'Aggregates strength session durations', 'minute', true
);

-- Flexibility Duration
INSERT INTO aggregation_metrics (
  id, agg_id, metric_name, display_name, description, output_unit, is_active
) VALUES (
  gen_random_uuid(), 'AGG_FLEXIBILITY_DURATION', 'flexibility_duration', 'Flexibility Duration',
  'Aggregates flexibility session durations', 'minute', true
);

-- Mindfulness Duration
INSERT INTO aggregation_metrics (
  id, agg_id, metric_name, display_name, description, output_unit, is_active
) VALUES (
  gen_random_uuid(), 'AGG_MINDFULNESS_DURATION', 'mindfulness_duration', 'Mindfulness Duration',
  'Aggregates mindfulness session durations', 'minute', true
);

-- Sleep Period Duration
INSERT INTO aggregation_metrics (
  id, agg_id, metric_name, display_name, description, output_unit, is_active
) VALUES (
  gen_random_uuid(), 'AGG_SLEEP_PERIOD_DURATION', 'sleep_period_duration', 'Sleep Period Duration',
  'Aggregates individual sleep period durations', 'minute', true
);

-- Sleep Session Duration
INSERT INTO aggregation_metrics (
  id, agg_id, metric_name, display_name, description, output_unit, is_active
) VALUES (
  gen_random_uuid(), 'AGG_SLEEP_SESSION_DURATION', 'sleep_session_duration', 'Sleep Session Duration',
  'Aggregates total sleep session durations', 'minute', true
);

-- Sleep Efficiency
INSERT INTO aggregation_metrics (
  id, agg_id, metric_name, display_name, description, output_unit, is_active
) VALUES (
  gen_random_uuid(), 'AGG_SLEEP_EFFICIENCY', 'sleep_efficiency', 'Sleep Efficiency',
  'Aggregates sleep efficiency percentages', 'percentage', true
);

-- Last Meal to Sleep Gap
INSERT INTO aggregation_metrics (
  id, agg_id, metric_name, display_name, description, output_unit, is_active
) VALUES (
  gen_random_uuid(), 'AGG_LAST_MEAL_TO_SLEEP_GAP', 'last_meal_to_sleep_gap', 'Last Meal to Sleep Gap',
  'Aggregates time between last meal and sleep', 'hours', true
);

-- BMI
INSERT INTO aggregation_metrics (
  id, agg_id, metric_name, display_name, description, output_unit, is_active
) VALUES (
  gen_random_uuid(), 'AGG_BMI', 'bmi_calculated', 'BMI',
  'Aggregates BMI values', 'count', true
);

-- Body Fat Mass
INSERT INTO aggregation_metrics (
  id, agg_id, metric_name, display_name, description, output_unit, is_active
) VALUES (
  gen_random_uuid(), 'AGG_BODY_FAT_MASS', 'body_fat_mass', 'Body Fat Mass',
  'Aggregates body fat mass', 'kilogram', true
);


-- =====================================================
-- Summary
-- =====================================================

DO $$
DECLARE
  total_metrics INT;
BEGIN
  SELECT COUNT(*) INTO total_metrics
  FROM aggregation_metrics
  WHERE is_active = true;

  RAISE NOTICE '===========================================';
  RAISE NOTICE 'Aggregation Metrics Created';
  RAISE NOTICE '===========================================';
  RAISE NOTICE 'Total metrics: %', total_metrics;
  RAISE NOTICE '';
  RAISE NOTICE 'Breakdown:';
  RAISE NOTICE '  Data entry field aggregations: 10';
  RAISE NOTICE '  Instance calculation aggregations: 10';
  RAISE NOTICE '';
  RAISE NOTICE 'Next step: Create calculation_types for each metric';
  RAISE NOTICE '(e.g., cardio_duration can be SUM, AVG, MIN, MAX, COUNT)';
END $$;

COMMIT;
