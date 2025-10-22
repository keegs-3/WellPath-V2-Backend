-- =====================================================
-- Add Dependencies for Cross-Event Instance Calculations
-- =====================================================
-- Links cross-event calculations (IC_040+) to their required fields
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- Sleep Efficiency Dependencies
-- =====================================================

-- IC_040: Sleep Efficiency (sleep_session_start, sleep_session_end)
INSERT INTO instance_calculations_dependencies (
  id, instance_calculation_id, data_entry_field_id,
  parameter_name, parameter_order, parameter_role
) VALUES
  (gen_random_uuid(), 'IC_040', 'DEF_SLEEP_BEDTIME', 'sleep_session_start', 1, 'start_time'),
  (gen_random_uuid(), 'IC_040', 'DEF_SLEEP_WAKETIME', 'sleep_session_end', 2, 'end_time');

-- IC_041: Total Sleep Duration (sleep_period_duration, sleep_period_type)
INSERT INTO instance_calculations_dependencies (
  id, instance_calculation_id, data_entry_field_id,
  parameter_name, parameter_order, parameter_role
) VALUES
  (gen_random_uuid(), 'IC_041', 'DEF_SLEEP_PERIOD_START', 'sleep_period_start', 1, 'period_start'),
  (gen_random_uuid(), 'IC_041', 'DEF_SLEEP_PERIOD_END', 'sleep_period_end', 2, 'period_end'),
  (gen_random_uuid(), 'IC_041', 'DEF_SLEEP_PERIOD_TYPE', 'sleep_period_type', 3, 'filter');

-- IC_042: Awake Time in Bed (sleep_period_duration, sleep_period_type)
INSERT INTO instance_calculations_dependencies (
  id, instance_calculation_id, data_entry_field_id,
  parameter_name, parameter_order, parameter_role
) VALUES
  (gen_random_uuid(), 'IC_042', 'DEF_SLEEP_PERIOD_START', 'sleep_period_start', 1, 'period_start'),
  (gen_random_uuid(), 'IC_042', 'DEF_SLEEP_PERIOD_END', 'sleep_period_end', 2, 'period_end'),
  (gen_random_uuid(), 'IC_042', 'DEF_SLEEP_PERIOD_TYPE', 'sleep_period_type', 3, 'filter');


-- =====================================================
-- Meal-Sleep Timing Dependencies
-- =====================================================

-- IC_050: Last Meal to Sleep Gap (meal_time, sleep_session_start)
INSERT INTO instance_calculations_dependencies (
  id, instance_calculation_id, data_entry_field_id,
  parameter_name, parameter_order, parameter_role
) VALUES
  (gen_random_uuid(), 'IC_050', 'DEF_MEAL_TIME', 'meal_time', 1, 'reference_time'),
  (gen_random_uuid(), 'IC_050', 'DEF_SLEEP_BEDTIME', 'sleep_session_start', 2, 'comparison_time');

-- IC_051: First Meal Delay (meal_time, sleep_session_end)
INSERT INTO instance_calculations_dependencies (
  id, instance_calculation_id, data_entry_field_id,
  parameter_name, parameter_order, parameter_role
) VALUES
  (gen_random_uuid(), 'IC_051', 'DEF_SLEEP_WAKETIME', 'sleep_session_end', 1, 'reference_time'),
  (gen_random_uuid(), 'IC_051', 'DEF_MEAL_TIME', 'meal_time', 2, 'comparison_time');

-- IC_052: Eating Window Duration (meal_time)
INSERT INTO instance_calculations_dependencies (
  id, instance_calculation_id, data_entry_field_id,
  parameter_name, parameter_order, parameter_role
) VALUES
  (gen_random_uuid(), 'IC_052', 'DEF_MEAL_TIME', 'meal_time', 1, 'time_value');


-- =====================================================
-- Post-Meal Activity Dependencies
-- =====================================================

-- IC_060: Post Meal Activity Window (meal_time, activity start times)
INSERT INTO instance_calculations_dependencies (
  id, instance_calculation_id, data_entry_field_id,
  parameter_name, parameter_order, parameter_role
) VALUES
  (gen_random_uuid(), 'IC_060', 'DEF_MEAL_TIME', 'meal_time', 1, 'reference_time'),
  (gen_random_uuid(), 'IC_060', 'DEF_CARDIO_START', 'cardio_start_time', 2, 'activity_time'),
  (gen_random_uuid(), 'IC_060', 'DEF_STRENGTH_START', 'strength_start_time', 3, 'activity_time'),
  (gen_random_uuid(), 'IC_060', 'DEF_FLEXIBILITY_START', 'flexibility_start_time', 4, 'activity_time');

-- IC_061: Post Meal Exercise Occurred (meal_time, activity start times)
INSERT INTO instance_calculations_dependencies (
  id, instance_calculation_id, data_entry_field_id,
  parameter_name, parameter_order, parameter_role
) VALUES
  (gen_random_uuid(), 'IC_061', 'DEF_MEAL_TIME', 'meal_time', 1, 'reference_time'),
  (gen_random_uuid(), 'IC_061', 'DEF_CARDIO_START', 'cardio_start_time', 2, 'activity_time'),
  (gen_random_uuid(), 'IC_061', 'DEF_STRENGTH_START', 'strength_start_time', 3, 'activity_time'),
  (gen_random_uuid(), 'IC_061', 'DEF_FLEXIBILITY_START', 'flexibility_start_time', 4, 'activity_time');


-- =====================================================
-- Exercise Recovery Dependencies
-- =====================================================

-- IC_070: Exercise to Sleep Window (exercise end times, sleep_session_start)
INSERT INTO instance_calculations_dependencies (
  id, instance_calculation_id, data_entry_field_id,
  parameter_name, parameter_order, parameter_role
) VALUES
  (gen_random_uuid(), 'IC_070', 'DEF_CARDIO_END', 'cardio_end_time', 1, 'exercise_end'),
  (gen_random_uuid(), 'IC_070', 'DEF_STRENGTH_END', 'strength_end_time', 2, 'exercise_end'),
  (gen_random_uuid(), 'IC_070', 'DEF_FLEXIBILITY_END', 'flexibility_end_time', 3, 'exercise_end'),
  (gen_random_uuid(), 'IC_070', 'DEF_SLEEP_BEDTIME', 'sleep_session_start', 4, 'sleep_time');

-- IC_071: Total Daily Exercise Duration (all exercise durations)
-- This depends on IC_001, IC_002, IC_003 outputs
INSERT INTO instance_calculations_dependencies (
  id, instance_calculation_id, data_entry_field_id,
  parameter_name, parameter_order, parameter_role
) VALUES
  (gen_random_uuid(), 'IC_071', 'DEF_CARDIO_START', 'cardio_start_time', 1, 'cardio_duration_input'),
  (gen_random_uuid(), 'IC_071', 'DEF_CARDIO_END', 'cardio_end_time', 2, 'cardio_duration_input'),
  (gen_random_uuid(), 'IC_071', 'DEF_STRENGTH_START', 'strength_start_time', 3, 'strength_duration_input'),
  (gen_random_uuid(), 'IC_071', 'DEF_STRENGTH_END', 'strength_end_time', 4, 'strength_duration_input'),
  (gen_random_uuid(), 'IC_071', 'DEF_FLEXIBILITY_START', 'flexibility_start_time', 5, 'flexibility_duration_input'),
  (gen_random_uuid(), 'IC_071', 'DEF_FLEXIBILITY_END', 'flexibility_end_time', 6, 'flexibility_duration_input');


-- =====================================================
-- Sleep Consistency Dependencies
-- =====================================================

-- IC_080: Sleep Time Consistency (sleep_session_start)
INSERT INTO instance_calculations_dependencies (
  id, instance_calculation_id, data_entry_field_id,
  parameter_name, parameter_order, parameter_role
) VALUES
  (gen_random_uuid(), 'IC_080', 'DEF_SLEEP_BEDTIME', 'sleep_session_start', 1, 'time_value');

-- IC_081: Wake Time Consistency (sleep_session_end)
INSERT INTO instance_calculations_dependencies (
  id, instance_calculation_id, data_entry_field_id,
  parameter_name, parameter_order, parameter_role
) VALUES
  (gen_random_uuid(), 'IC_081', 'DEF_SLEEP_WAKETIME', 'sleep_session_end', 1, 'time_value');


-- =====================================================
-- Verification Summary
-- =====================================================

DO $$
DECLARE
  total_deps INT;
  new_deps INT;
  rec RECORD;
BEGIN
  SELECT COUNT(*) INTO total_deps
  FROM instance_calculations_dependencies;

  SELECT COUNT(*) INTO new_deps
  FROM instance_calculations_dependencies icd
  WHERE icd.instance_calculation_id >= 'IC_040';

  RAISE NOTICE '===========================================';
  RAISE NOTICE 'Cross-Event Dependencies Added';
  RAISE NOTICE '===========================================';
  RAISE NOTICE 'New dependencies: %', new_deps;
  RAISE NOTICE 'Total dependencies: %', total_deps;
  RAISE NOTICE '';
  RAISE NOTICE 'Dependencies per calculation:';

  FOR rec IN
    SELECT
      ic.calc_id,
      ic.calc_name,
      COUNT(icd.id) as dep_count
    FROM instance_calculations ic
    LEFT JOIN instance_calculations_dependencies icd
      ON ic.calc_id = icd.instance_calculation_id
    WHERE ic.calc_id >= 'IC_040'
    GROUP BY ic.calc_id, ic.calc_name
    ORDER BY ic.calc_id
  LOOP
    RAISE NOTICE '  %: % dependencies', rec.calc_id, rec.dep_count;
  END LOOP;
END $$;

COMMIT;
