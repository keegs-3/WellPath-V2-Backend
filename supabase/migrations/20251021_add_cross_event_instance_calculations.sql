-- =====================================================
-- Add Cross-Event Instance Calculations
-- =====================================================
-- Adds instance calculations that span multiple events:
-- - Sleep efficiency metrics
-- - Meal-to-sleep timing
-- - Post-meal activity windows
-- - Exercise recovery metrics
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- Sleep Efficiency Calculations
-- =====================================================

-- IC_040: Sleep Efficiency
INSERT INTO instance_calculations (
  id, calc_id, calc_name, display_name, description,
  calculation_method, formula_definition, depends_on_fields,
  unit_id, is_displayed_to_user, is_active, calculation_config
) VALUES (
  gen_random_uuid(), 'IC_040', 'sleep_efficiency', 'Sleep Efficiency',
  'Ratio of actual sleep duration to time in bed',
  'divide', 'sleep_session_duration / time_in_bed',
  ARRAY['sleep_session_start', 'sleep_session_end'],
  'percentage', true, true,
  jsonb_build_object(
    'formula', 'sleep_duration / time_in_bed',
    'required_metrics', jsonb_build_array('sleep_session_duration', 'time_in_bed'),
    'formula_reference', 'time_efficiency'
  )
);

-- IC_041: Total Sleep Duration (sum of all restorative sleep periods)
INSERT INTO instance_calculations (
  id, calc_id, calc_name, display_name, description,
  calculation_method, formula_definition, depends_on_fields,
  unit_id, is_displayed_to_user, is_active, calculation_config
) VALUES (
  gen_random_uuid(), 'IC_041', 'total_sleep_duration', 'Total Sleep Duration',
  'Sum of REM + Deep + Core sleep periods',
  'custom_calc', 'SUM(sleep_period_duration WHERE period_type IN (rem, deep, core))',
  ARRAY['sleep_period_duration', 'sleep_period_type'],
  'minute', true, true,
  jsonb_build_object(
    'formula', 'SUM(sleep_period_duration) WHERE is_restorative = true',
    'required_metrics', jsonb_build_array('sleep_period_duration', 'sleep_period_type'),
    'formula_reference', 'conditional_sum'
  )
);

-- IC_042: Awake Time in Bed
INSERT INTO instance_calculations (
  id, calc_id, calc_name, display_name, description,
  calculation_method, formula_definition, depends_on_fields,
  unit_id, is_displayed_to_user, is_active, calculation_config
) VALUES (
  gen_random_uuid(), 'IC_042', 'awake_time_in_bed', 'Awake Time in Bed',
  'Total time awake during sleep session',
  'custom_calc', 'SUM(sleep_period_duration WHERE period_type = awake)',
  ARRAY['sleep_period_duration', 'sleep_period_type'],
  'minute', true, true,
  jsonb_build_object(
    'formula', 'SUM(sleep_period_duration) WHERE period_type = awake',
    'required_metrics', jsonb_build_array('sleep_period_duration', 'sleep_period_type'),
    'formula_reference', 'conditional_sum'
  )
);


-- =====================================================
-- Meal-to-Sleep Timing Calculations
-- =====================================================

-- IC_050: Last Meal to Sleep Gap
INSERT INTO instance_calculations (
  id, calc_id, calc_name, display_name, description,
  calculation_method, formula_definition, depends_on_fields,
  unit_id, is_displayed_to_user, is_active, calculation_config
) VALUES (
  gen_random_uuid(), 'IC_050', 'last_meal_to_sleep_gap', 'Last Meal to Sleep Gap',
  'Hours between last meal and sleep session start',
  'time_difference', 'sleep_session_start - MAX(meal_time WHERE DATE(meal_time) = DATE(sleep_session_start))',
  ARRAY['meal_time', 'sleep_session_start'],
  'hours', true, true,
  jsonb_build_object(
    'formula', 'sleep_time - last_meal_time',
    'required_metrics', jsonb_build_array('last_meal_time', 'sleep_session_start'),
    'formula_reference', 'time_difference'
  )
);

-- IC_051: First Meal Delay (time from wake to first meal)
INSERT INTO instance_calculations (
  id, calc_id, calc_name, display_name, description,
  calculation_method, formula_definition, depends_on_fields,
  unit_id, is_displayed_to_user, is_active, calculation_config
) VALUES (
  gen_random_uuid(), 'IC_051', 'first_meal_delay', 'First Meal Delay',
  'Hours between wake time and first meal',
  'time_difference', 'MIN(meal_time WHERE DATE(meal_time) = DATE(sleep_session_end)) - sleep_session_end',
  ARRAY['meal_time', 'sleep_session_end'],
  'hours', true, true,
  jsonb_build_object(
    'formula', 'first_meal_time - wake_time',
    'required_metrics', jsonb_build_array('first_meal_time', 'sleep_session_end'),
    'formula_reference', 'time_difference'
  )
);

-- IC_052: Eating Window Duration
INSERT INTO instance_calculations (
  id, calc_id, calc_name, display_name, description,
  calculation_method, formula_definition, depends_on_fields,
  unit_id, is_displayed_to_user, is_active, calculation_config
) VALUES (
  gen_random_uuid(), 'IC_052', 'eating_window_duration', 'Eating Window Duration',
  'Hours between first and last meal of the day',
  'time_difference', 'MAX(meal_time) - MIN(meal_time) per day',
  ARRAY['meal_time'],
  'hours', true, true,
  jsonb_build_object(
    'formula', 'last_meal_time - first_meal_time',
    'required_metrics', jsonb_build_array('first_meal_time', 'last_meal_time'),
    'formula_reference', 'time_difference'
  )
);


-- =====================================================
-- Post-Meal Activity Calculations
-- =====================================================

-- IC_060: Post Meal Activity Window
INSERT INTO instance_calculations (
  id, calc_id, calc_name, display_name, description,
  calculation_method, formula_definition, depends_on_fields,
  unit_id, is_displayed_to_user, is_active, calculation_config
) VALUES (
  gen_random_uuid(), 'IC_060', 'post_meal_activity_window', 'Post-Meal Activity Window',
  'Minutes between meal and next activity (cardio/strength/flexibility)',
  'time_difference', 'MIN(activity_start_time WHERE activity_start_time > meal_time) - meal_time',
  ARRAY['meal_time', 'cardio_start_time', 'strength_start_time', 'flexibility_start_time'],
  'minute', true, true,
  jsonb_build_object(
    'formula', 'next_activity_time - meal_time',
    'required_metrics', jsonb_build_array('meal_time', 'activity_start_time'),
    'formula_reference', 'time_difference'
  )
);

-- IC_061: Post Meal Exercise Occurred (boolean)
INSERT INTO instance_calculations (
  id, calc_id, calc_name, display_name, description,
  calculation_method, formula_definition, depends_on_fields,
  unit_id, is_displayed_to_user, is_active, calculation_config
) VALUES (
  gen_random_uuid(), 'IC_061', 'post_meal_exercise_occurred', 'Post-Meal Exercise',
  'Whether exercise occurred within 2 hours after meal',
  'custom_calc', 'EXISTS(activity WHERE activity_start_time BETWEEN meal_time AND meal_time + 2 hours)',
  ARRAY['meal_time', 'cardio_start_time', 'strength_start_time', 'flexibility_start_time'],
  'count', true, true,
  jsonb_build_object(
    'formula', 'activity_exists_within_window',
    'required_metrics', jsonb_build_array('meal_time', 'activity_start_time'),
    'formula_reference', 'boolean_check',
    'window_hours', 2
  )
);


-- =====================================================
-- Exercise Recovery Calculations
-- =====================================================

-- IC_070: Exercise to Sleep Recovery Window
INSERT INTO instance_calculations (
  id, calc_id, calc_name, display_name, description,
  calculation_method, formula_definition, depends_on_fields,
  unit_id, is_displayed_to_user, is_active, calculation_config
) VALUES (
  gen_random_uuid(), 'IC_070', 'exercise_to_sleep_window', 'Exercise to Sleep Window',
  'Hours between last exercise and sleep',
  'time_difference', 'sleep_session_start - MAX(exercise_end_time WHERE DATE(exercise_end_time) = DATE(sleep_session_start))',
  ARRAY['cardio_end_time', 'strength_end_time', 'flexibility_end_time', 'sleep_session_start'],
  'hours', true, true,
  jsonb_build_object(
    'formula', 'sleep_time - last_exercise_time',
    'required_metrics', jsonb_build_array('last_exercise_time', 'sleep_session_start'),
    'formula_reference', 'time_difference'
  )
);

-- IC_071: Total Exercise Duration (daily sum)
INSERT INTO instance_calculations (
  id, calc_id, calc_name, display_name, description,
  calculation_method, formula_definition, depends_on_fields,
  unit_id, is_displayed_to_user, is_active, calculation_config
) VALUES (
  gen_random_uuid(), 'IC_071', 'total_daily_exercise_duration', 'Total Daily Exercise',
  'Sum of all exercise durations for the day',
  'custom_calc', 'SUM(cardio_duration + strength_duration + flexibility_duration) per day',
  ARRAY['cardio_duration', 'strength_duration', 'flexibility_duration'],
  'minute', true, true,
  jsonb_build_object(
    'formula', 'SUM(exercise_durations)',
    'required_metrics', jsonb_build_array('cardio_duration', 'strength_duration', 'flexibility_duration'),
    'formula_reference', 'sum'
  )
);


-- =====================================================
-- Sleep Consistency Calculations
-- =====================================================

-- IC_080: Sleep Time Consistency (std dev of sleep_session_start over period)
INSERT INTO instance_calculations (
  id, calc_id, calc_name, display_name, description,
  calculation_method, formula_definition, depends_on_fields,
  unit_id, is_displayed_to_user, is_active, calculation_config
) VALUES (
  gen_random_uuid(), 'IC_080', 'sleep_time_consistency', 'Sleep Time Consistency',
  'Standard deviation of sleep start times (lower = more consistent)',
  'std_dev', 'STDDEV(time_of_day(sleep_session_start)) over 7 days',
  ARRAY['sleep_session_start'],
  'minute', true, true,
  jsonb_build_object(
    'formula', 'STDDEV(sleep_session_start)',
    'required_metrics', jsonb_build_array('sleep_session_start'),
    'formula_reference', 'std_dev',
    'period_days', 7
  )
);

-- IC_081: Wake Time Consistency
INSERT INTO instance_calculations (
  id, calc_id, calc_name, display_name, description,
  calculation_method, formula_definition, depends_on_fields,
  unit_id, is_displayed_to_user, is_active, calculation_config
) VALUES (
  gen_random_uuid(), 'IC_081', 'wake_time_consistency', 'Wake Time Consistency',
  'Standard deviation of wake times (lower = more consistent)',
  'std_dev', 'STDDEV(time_of_day(sleep_session_end)) over 7 days',
  ARRAY['sleep_session_end'],
  'minute', true, true,
  jsonb_build_object(
    'formula', 'STDDEV(sleep_session_end)',
    'required_metrics', jsonb_build_array('sleep_session_end'),
    'formula_reference', 'std_dev',
    'period_days', 7
  )
);


-- =====================================================
-- Summary
-- =====================================================

DO $$
DECLARE
  total_calcs INT;
  new_calcs INT;
BEGIN
  SELECT COUNT(*) INTO total_calcs
  FROM instance_calculations
  WHERE is_active = true;

  SELECT COUNT(*) INTO new_calcs
  FROM instance_calculations
  WHERE calc_id >= 'IC_040'
  AND is_active = true;

  RAISE NOTICE '===========================================';
  RAISE NOTICE 'Cross-Event Instance Calculations Added';
  RAISE NOTICE '===========================================';
  RAISE NOTICE 'New calculations added: %', new_calcs;
  RAISE NOTICE 'Total active calculations: %', total_calcs;
  RAISE NOTICE '';
  RAISE NOTICE 'Categories:';
  RAISE NOTICE '  Sleep Efficiency: 3';
  RAISE NOTICE '  Meal-Sleep Timing: 3';
  RAISE NOTICE '  Post-Meal Activity: 2';
  RAISE NOTICE '  Exercise Recovery: 2';
  RAISE NOTICE '  Sleep Consistency: 2';
END $$;

COMMIT;
