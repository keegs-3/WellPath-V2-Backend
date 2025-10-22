-- =====================================================
-- Populate instance_calculations_dependencies
-- =====================================================
-- Links each instance calculation to its required data_entry_fields
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- Clear existing dependencies
TRUNCATE TABLE instance_calculations_dependencies;

-- =====================================================
-- Event Duration Dependencies
-- =====================================================

-- IC_001: Cardio Duration (cardio_start_time, cardio_end_time)
INSERT INTO instance_calculations_dependencies (
  id, instance_calculation_id, data_entry_field_id,
  parameter_name, parameter_order, parameter_role
) VALUES
  (gen_random_uuid(), 'IC_001', 'DEF_CARDIO_START', 'cardio_start_time', 1, 'start_time'),
  (gen_random_uuid(), 'IC_001', 'DEF_CARDIO_END', 'cardio_end_time', 2, 'end_time');

-- IC_002: Strength Duration
INSERT INTO instance_calculations_dependencies (
  id, instance_calculation_id, data_entry_field_id,
  parameter_name, parameter_order, parameter_role
) VALUES
  (gen_random_uuid(), 'IC_002', 'DEF_STRENGTH_START', 'strength_start_time', 1, 'start_time'),
  (gen_random_uuid(), 'IC_002', 'DEF_STRENGTH_END', 'strength_end_time', 2, 'end_time');

-- IC_003: Flexibility Duration
INSERT INTO instance_calculations_dependencies (
  id, instance_calculation_id, data_entry_field_id,
  parameter_name, parameter_order, parameter_role
) VALUES
  (gen_random_uuid(), 'IC_003', 'DEF_FLEXIBILITY_START', 'flexibility_start_time', 1, 'start_time'),
  (gen_random_uuid(), 'IC_003', 'DEF_FLEXIBILITY_END', 'flexibility_end_time', 2, 'end_time');

-- IC_004: Mindfulness Duration
INSERT INTO instance_calculations_dependencies (
  id, instance_calculation_id, data_entry_field_id,
  parameter_name, parameter_order, parameter_role
) VALUES
  (gen_random_uuid(), 'IC_004', 'DEF_MINDFULNESS_START', 'mindfulness_start_time', 1, 'start_time'),
  (gen_random_uuid(), 'IC_004', 'DEF_MINDFULNESS_END', 'mindfulness_end_time', 2, 'end_time');

-- IC_005: Sleep Period Duration
INSERT INTO instance_calculations_dependencies (
  id, instance_calculation_id, data_entry_field_id,
  parameter_name, parameter_order, parameter_role
) VALUES
  (gen_random_uuid(), 'IC_005', 'DEF_SLEEP_PERIOD_START', 'sleep_period_start', 1, 'start_time'),
  (gen_random_uuid(), 'IC_005', 'DEF_SLEEP_PERIOD_END', 'sleep_period_end', 2, 'end_time');

-- IC_006: Sleep Session Duration
INSERT INTO instance_calculations_dependencies (
  id, instance_calculation_id, data_entry_field_id,
  parameter_name, parameter_order, parameter_role
) VALUES
  (gen_random_uuid(), 'IC_006', 'DEF_SLEEP_BEDTIME', 'sleep_session_start', 1, 'start_time'),
  (gen_random_uuid(), 'IC_006', 'DEF_SLEEP_WAKETIME', 'sleep_session_end', 2, 'end_time');


-- =====================================================
-- Screening Time Dependencies
-- =====================================================

-- IC_010: Time Since Screening (screening_date)
INSERT INTO instance_calculations_dependencies (
  id, instance_calculation_id, data_entry_field_id,
  parameter_name, parameter_order, parameter_role
) VALUES
  (gen_random_uuid(), 'IC_010', 'DEF_SCREENING_DATE', 'screening_date', 1, 'event_date');


-- =====================================================
-- Body Composition Dependencies
-- =====================================================

-- IC_020: BMI (weight, height)
-- Note: These field_ids need to match actual measurement field_ids
INSERT INTO instance_calculations_dependencies (
  id, instance_calculation_id, data_entry_field_id,
  parameter_name, parameter_order, parameter_role
) VALUES
  (gen_random_uuid(), 'IC_020', 'DEF_MEASUREMENT_VALUE', 'weight', 1, 'numerator'),
  (gen_random_uuid(), 'IC_020', 'DEF_MEASUREMENT_VALUE', 'height', 2, 'denominator');

-- IC_021: Hip to Waist Ratio (hip, waist)
INSERT INTO instance_calculations_dependencies (
  id, instance_calculation_id, data_entry_field_id,
  parameter_name, parameter_order, parameter_role
) VALUES
  (gen_random_uuid(), 'IC_021', 'DEF_MEASUREMENT_VALUE', 'hip', 1, 'numerator'),
  (gen_random_uuid(), 'IC_021', 'DEF_MEASUREMENT_VALUE', 'waist', 2, 'denominator');

-- IC_022: Waist to Height Ratio (waist, height)
INSERT INTO instance_calculations_dependencies (
  id, instance_calculation_id, data_entry_field_id,
  parameter_name, parameter_order, parameter_role
) VALUES
  (gen_random_uuid(), 'IC_022', 'DEF_MEASUREMENT_VALUE', 'waist', 1, 'numerator'),
  (gen_random_uuid(), 'IC_022', 'DEF_MEASUREMENT_VALUE', 'height', 2, 'denominator');

-- IC_023: Skeletal Muscle Mass (lean_mass)
INSERT INTO instance_calculations_dependencies (
  id, instance_calculation_id, data_entry_field_id,
  parameter_name, parameter_order, parameter_role
) VALUES
  (gen_random_uuid(), 'IC_023', 'DEF_MEASUREMENT_VALUE', 'lean_mass', 1, 'input');

-- IC_024: Body Fat Mass (weight, body_fat_percent)
INSERT INTO instance_calculations_dependencies (
  id, instance_calculation_id, data_entry_field_id,
  parameter_name, parameter_order, parameter_role
) VALUES
  (gen_random_uuid(), 'IC_024', 'DEF_MEASUREMENT_VALUE', 'weight', 1, 'base_value'),
  (gen_random_uuid(), 'IC_024', 'DEF_MEASUREMENT_VALUE', 'body_fat', 2, 'percentage');

-- IC_025: Skeletal Muscle to FFM Ratio (skeletal_muscle_mass, lean_mass)
-- This depends on IC_023 output and lean_mass measurement
INSERT INTO instance_calculations_dependencies (
  id, instance_calculation_id, data_entry_field_id,
  parameter_name, parameter_order, parameter_role
) VALUES
  (gen_random_uuid(), 'IC_025', 'DEF_MEASUREMENT_VALUE', 'skeletal_muscle_mass', 1, 'numerator'),
  (gen_random_uuid(), 'IC_025', 'DEF_MEASUREMENT_VALUE', 'lean_mass', 2, 'denominator');


-- =====================================================
-- Other Dependencies
-- =====================================================

-- IC_030: User Age (date_of_birth)
-- Note: This needs patient_details field, not data_entry_field
-- Commenting out for now as it's a special case
-- INSERT INTO instance_calculations_dependencies (
--   id, instance_calculation_id, data_entry_field_id,
--   parameter_name, parameter_order, parameter_role
-- ) VALUES
--   (gen_random_uuid(), 'IC_030', 'DEF_BIRTH_DATE', 'date_of_birth', 1, 'reference_date');


-- =====================================================
-- Verification Summary
-- =====================================================

DO $$
DECLARE
  total_deps INT;
  calcs_with_deps INT;
  rec RECORD;
BEGIN
  SELECT COUNT(*) INTO total_deps
  FROM instance_calculations_dependencies;

  SELECT COUNT(DISTINCT instance_calculation_id) INTO calcs_with_deps
  FROM instance_calculations_dependencies;

  RAISE NOTICE '===========================================';
  RAISE NOTICE 'Instance Calculation Dependencies Created';
  RAISE NOTICE '===========================================';
  RAISE NOTICE 'Total dependencies: %', total_deps;
  RAISE NOTICE 'Calculations with dependencies: %', calcs_with_deps;
  RAISE NOTICE '';
  RAISE NOTICE 'Breakdown by calculation:';

  FOR rec IN
    SELECT
      ic.calc_id,
      ic.calc_name,
      COUNT(icd.id) as dep_count
    FROM instance_calculations ic
    LEFT JOIN instance_calculations_dependencies icd
      ON ic.calc_id = icd.instance_calculation_id
    GROUP BY ic.calc_id, ic.calc_name
    ORDER BY ic.calc_id
  LOOP
    RAISE NOTICE '  %: % dependencies', rec.calc_id, rec.dep_count;
  END LOOP;
END $$;

COMMIT;
