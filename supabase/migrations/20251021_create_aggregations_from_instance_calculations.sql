-- =====================================================
-- Create Aggregations from Instance Calculations
-- =====================================================
-- Generates aggregations (SUM, AVG, MIN, MAX, COUNT, LATEST) for all instance calculations
-- Each instance calculation gets its relevant aggregation types
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- Clear existing aggregations
TRUNCATE TABLE aggregation_metrics CASCADE;

-- =====================================================
-- Helper Function: Create Aggregations for Instance Calc
-- =====================================================
-- This will be used to generate standard aggregations

CREATE OR REPLACE FUNCTION create_aggregations_for_instance_calc(
  p_calc_id TEXT,
  p_calc_name TEXT,
  p_display_name TEXT,
  p_output_unit TEXT,
  p_agg_types TEXT[]
) RETURNS VOID AS $$
DECLARE
  agg_type TEXT;
  agg_counter INT := 0;
BEGIN
  FOREACH agg_type IN ARRAY p_agg_types
  LOOP
    agg_counter := agg_counter + 1;

    INSERT INTO aggregation_metrics (
      id, agg_id, metric_name, display_name, description,
      output_unit, is_active
    ) VALUES (
      gen_random_uuid(),
      'AGG_' || UPPER(p_calc_name) || '_' || UPPER(agg_type),
      p_calc_name || '_' || agg_type,
      p_display_name || ' (' || UPPER(agg_type) || ')',
      CASE agg_type
        WHEN 'sum' THEN 'Total ' || p_display_name || ' over period'
        WHEN 'avg' THEN 'Average ' || p_display_name || ' over period'
        WHEN 'min' THEN 'Minimum ' || p_display_name || ' over period'
        WHEN 'max' THEN 'Maximum ' || p_display_name || ' over period'
        WHEN 'count' THEN 'Count of ' || p_display_name || ' instances'
        WHEN 'latest' THEN 'Most recent ' || p_display_name
        ELSE agg_type || ' of ' || p_display_name
      END,
      p_output_unit,
      true
    );
  END LOOP;
END;
$$ LANGUAGE plpgsql;


-- =====================================================
-- Event Duration Aggregations
-- =====================================================

-- IC_001: Cardio Duration
SELECT create_aggregations_for_instance_calc(
  'IC_001', 'cardio_duration', 'Cardio Duration',
  'minute', ARRAY['sum', 'avg', 'min', 'max', 'count']
);

-- IC_002: Strength Duration
SELECT create_aggregations_for_instance_calc(
  'IC_002', 'strength_duration', 'Strength Duration',
  'minute', ARRAY['sum', 'avg', 'min', 'max', 'count']
);

-- IC_003: Flexibility Duration
SELECT create_aggregations_for_instance_calc(
  'IC_003', 'flexibility_duration', 'Flexibility Duration',
  'minute', ARRAY['sum', 'avg', 'min', 'max', 'count']
);

-- IC_004: Mindfulness Duration
SELECT create_aggregations_for_instance_calc(
  'IC_004', 'mindfulness_duration', 'Mindfulness Duration',
  'minute', ARRAY['sum', 'avg', 'min', 'max', 'count']
);

-- IC_005: Sleep Period Duration
SELECT create_aggregations_for_instance_calc(
  'IC_005', 'sleep_period_duration', 'Sleep Period Duration',
  'minute', ARRAY['sum', 'avg', 'min', 'max', 'count']
);

-- IC_006: Sleep Session Duration
SELECT create_aggregations_for_instance_calc(
  'IC_006', 'sleep_session_duration', 'Sleep Session Duration',
  'minute', ARRAY['sum', 'avg', 'min', 'max', 'latest']
);


-- =====================================================
-- Screening Time Aggregations
-- =====================================================

-- IC_010: Time Since Screening
SELECT create_aggregations_for_instance_calc(
  'IC_010', 'time_since_screening', 'Time Since Screening',
  'day', ARRAY['latest']
);


-- =====================================================
-- Body Composition Aggregations
-- =====================================================

-- IC_020: BMI
SELECT create_aggregations_for_instance_calc(
  'IC_020', 'bmi_calculated', 'BMI',
  'count', ARRAY['avg', 'min', 'max', 'latest']
);

-- IC_021: Hip to Waist Ratio
SELECT create_aggregations_for_instance_calc(
  'IC_021', 'hip_to_waist_ratio', 'Hip-to-Waist Ratio',
  'ratio', ARRAY['avg', 'min', 'max', 'latest']
);

-- IC_022: Waist to Height Ratio
SELECT create_aggregations_for_instance_calc(
  'IC_022', 'waist_to_height_ratio', 'Waist-to-Height Ratio',
  'ratio', ARRAY['avg', 'min', 'max', 'latest']
);

-- IC_023: Skeletal Muscle Mass
SELECT create_aggregations_for_instance_calc(
  'IC_023', 'skeletal_muscle_mass', 'Skeletal Muscle Mass',
  'kilogram', ARRAY['avg', 'min', 'max', 'latest']
);

-- IC_024: Body Fat Mass
SELECT create_aggregations_for_instance_calc(
  'IC_024', 'body_fat_mass', 'Body Fat Mass',
  'kilogram', ARRAY['avg', 'min', 'max', 'latest']
);

-- IC_025: Skeletal Muscle to FFM Ratio
SELECT create_aggregations_for_instance_calc(
  'IC_025', 'skeletal_muscle_to_ffm_ratio', 'Skeletal Muscle / FFM Ratio',
  'percentage', ARRAY['avg', 'min', 'max', 'latest']
);


-- =====================================================
-- User Age Aggregations
-- =====================================================

-- IC_030: User Age
SELECT create_aggregations_for_instance_calc(
  'IC_030', 'user_age', 'User Age',
  'years', ARRAY['latest']
);


-- =====================================================
-- Sleep Efficiency Aggregations
-- =====================================================

-- IC_040: Sleep Efficiency
SELECT create_aggregations_for_instance_calc(
  'IC_040', 'sleep_efficiency', 'Sleep Efficiency',
  'percentage', ARRAY['avg', 'min', 'max', 'latest']
);

-- IC_041: Total Sleep Duration
SELECT create_aggregations_for_instance_calc(
  'IC_041', 'total_sleep_duration', 'Total Sleep Duration',
  'minute', ARRAY['sum', 'avg', 'min', 'max', 'latest']
);

-- IC_042: Awake Time in Bed
SELECT create_aggregations_for_instance_calc(
  'IC_042', 'awake_time_in_bed', 'Awake Time in Bed',
  'minute', ARRAY['sum', 'avg', 'min', 'max', 'latest']
);


-- =====================================================
-- Meal-Sleep Timing Aggregations
-- =====================================================

-- IC_050: Last Meal to Sleep Gap
SELECT create_aggregations_for_instance_calc(
  'IC_050', 'last_meal_to_sleep_gap', 'Last Meal to Sleep Gap',
  'hours', ARRAY['avg', 'min', 'max', 'latest']
);

-- IC_051: First Meal Delay
SELECT create_aggregations_for_instance_calc(
  'IC_051', 'first_meal_delay', 'First Meal Delay',
  'hours', ARRAY['avg', 'min', 'max', 'latest']
);

-- IC_052: Eating Window Duration
SELECT create_aggregations_for_instance_calc(
  'IC_052', 'eating_window_duration', 'Eating Window Duration',
  'hours', ARRAY['avg', 'min', 'max', 'latest']
);


-- =====================================================
-- Post-Meal Activity Aggregations
-- =====================================================

-- IC_060: Post Meal Activity Window
SELECT create_aggregations_for_instance_calc(
  'IC_060', 'post_meal_activity_window', 'Post-Meal Activity Window',
  'minute', ARRAY['avg', 'min', 'max', 'latest']
);

-- IC_061: Post Meal Exercise Occurred
SELECT create_aggregations_for_instance_calc(
  'IC_061', 'post_meal_exercise_occurred', 'Post-Meal Exercise',
  'count', ARRAY['sum', 'count']
);


-- =====================================================
-- Exercise Recovery Aggregations
-- =====================================================

-- IC_070: Exercise to Sleep Window
SELECT create_aggregations_for_instance_calc(
  'IC_070', 'exercise_to_sleep_window', 'Exercise to Sleep Window',
  'hours', ARRAY['avg', 'min', 'max', 'latest']
);

-- IC_071: Total Daily Exercise Duration
SELECT create_aggregations_for_instance_calc(
  'IC_071', 'total_daily_exercise_duration', 'Total Daily Exercise',
  'minute', ARRAY['sum', 'avg', 'min', 'max', 'latest']
);


-- =====================================================
-- Sleep Consistency Aggregations
-- =====================================================

-- IC_080: Sleep Time Consistency
SELECT create_aggregations_for_instance_calc(
  'IC_080', 'sleep_time_consistency', 'Sleep Time Consistency',
  'minute', ARRAY['avg', 'latest']
);

-- IC_081: Wake Time Consistency
SELECT create_aggregations_for_instance_calc(
  'IC_081', 'wake_time_consistency', 'Wake Time Consistency',
  'minute', ARRAY['avg', 'latest']
);


-- =====================================================
-- Clean up helper function
-- =====================================================

DROP FUNCTION create_aggregations_for_instance_calc;


-- =====================================================
-- Summary
-- =====================================================

DO $$
DECLARE
  total_aggs INT;
  agg_by_type RECORD;
BEGIN
  SELECT COUNT(*) INTO total_aggs
  FROM aggregation_metrics
  WHERE is_active = true;

  RAISE NOTICE '===========================================';
  RAISE NOTICE 'Aggregation Metrics Created';
  RAISE NOTICE '===========================================';
  RAISE NOTICE 'Total aggregations: %', total_aggs;
  RAISE NOTICE '';
  RAISE NOTICE 'Aggregations by type:';

  FOR agg_by_type IN
    SELECT
      UPPER(SUBSTRING(metric_name FROM '.*_(.*)$')) as agg_type,
      COUNT(*) as count
    FROM aggregation_metrics
    WHERE is_active = true
    GROUP BY agg_type
    ORDER BY count DESC
  LOOP
    RAISE NOTICE '  %: %', agg_by_type.agg_type, agg_by_type.count;
  END LOOP;

  RAISE NOTICE '';
  RAISE NOTICE 'Sample aggregations:';

  FOR agg_by_type IN
    SELECT agg_id, metric_name, display_name
    FROM aggregation_metrics
    WHERE is_active = true
    ORDER BY agg_id
    LIMIT 10
  LOOP
    RAISE NOTICE '  % - %', agg_by_type.agg_id, agg_by_type.display_name;
  END LOOP;
END $$;

COMMIT;
