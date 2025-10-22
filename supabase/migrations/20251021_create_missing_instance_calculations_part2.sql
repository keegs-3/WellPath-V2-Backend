-- =====================================================
-- Create Missing Instance Calculations - Part 2
-- =====================================================
-- Creates dependencies for new instance calculations
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- HIIT Duration dependencies
INSERT INTO instance_calculations_dependencies (
  instance_calculation_id,
  data_entry_field_id,
  parameter_name
)
SELECT
  ic.calc_id,
  def.field_id,
  CASE
    WHEN def.field_id = 'DEF_HIIT_START' THEN 'start_time'
    WHEN def.field_id = 'DEF_HIIT_END' THEN 'end_time'
  END as parameter_name
FROM instance_calculations ic
CROSS JOIN data_entry_fields def
WHERE ic.calc_id = 'IC_007'
AND def.field_id IN ('DEF_HIIT_START', 'DEF_HIIT_END')
ON CONFLICT (instance_calculation_id, data_entry_field_id, parameter_name) DO NOTHING;

-- Mobility Duration dependencies
INSERT INTO instance_calculations_dependencies (
  instance_calculation_id,
  data_entry_field_id,
  parameter_name
)
SELECT
  ic.calc_id,
  def.field_id,
  CASE
    WHEN def.field_id = 'DEF_MOBILITY_START' THEN 'start_time'
    WHEN def.field_id = 'DEF_MOBILITY_END' THEN 'end_time'
  END as parameter_name
FROM instance_calculations ic
CROSS JOIN data_entry_fields def
WHERE ic.calc_id = 'IC_003B'
AND def.field_id IN ('DEF_MOBILITY_START', 'DEF_MOBILITY_END')
ON CONFLICT (instance_calculation_id, data_entry_field_id, parameter_name) DO NOTHING;

-- Outdoor Duration dependencies
INSERT INTO instance_calculations_dependencies (
  instance_calculation_id,
  data_entry_field_id,
  parameter_name
)
SELECT
  ic.calc_id,
  def.field_id,
  CASE
    WHEN def.field_id = 'DEF_OUTDOOR_START' THEN 'start_time'
    WHEN def.field_id = 'DEF_OUTDOOR_END' THEN 'end_time'
  END as parameter_name
FROM instance_calculations ic
CROSS JOIN data_entry_fields def
WHERE ic.calc_id = 'IC_008'
AND def.field_id IN ('DEF_OUTDOOR_START', 'DEF_OUTDOOR_END')
ON CONFLICT (instance_calculation_id, data_entry_field_id, parameter_name) DO NOTHING;

-- Sunlight Duration dependencies
INSERT INTO instance_calculations_dependencies (
  instance_calculation_id,
  data_entry_field_id,
  parameter_name
)
SELECT
  ic.calc_id,
  def.field_id,
  CASE
    WHEN def.field_id = 'DEF_SUNLIGHT_START' THEN 'start_time'
    WHEN def.field_id = 'DEF_SUNLIGHT_END' THEN 'end_time'
  END as parameter_name
FROM instance_calculations ic
CROSS JOIN data_entry_fields def
WHERE ic.calc_id = 'IC_009'
AND def.field_id IN ('DEF_SUNLIGHT_START', 'DEF_SUNLIGHT_END')
ON CONFLICT (instance_calculation_id, data_entry_field_id, parameter_name) DO NOTHING;

-- Caffeine to Sleep Window dependencies
INSERT INTO instance_calculations_dependencies (
  instance_calculation_id,
  data_entry_field_id,
  parameter_name
)
SELECT
  ic.calc_id,
  def.field_id,
  CASE
    WHEN def.field_id = 'DEF_CAFFEINE_TIME' THEN 'caffeine_time'
    WHEN def.field_id = 'DEF_SLEEP_SESSION_START' THEN 'sleep_start_time'
  END as parameter_name
FROM instance_calculations ic
CROSS JOIN data_entry_fields def
WHERE ic.calc_id = 'IC_073'
AND def.field_id IN ('DEF_CAFFEINE_TIME', 'DEF_SLEEP_SESSION_START')
ON CONFLICT (instance_calculation_id, data_entry_field_id, parameter_name) DO NOTHING;

-- Alcohol to Sleep Window dependencies
INSERT INTO instance_calculations_dependencies (
  instance_calculation_id,
  data_entry_field_id,
  parameter_name
)
SELECT
  ic.calc_id,
  def.field_id,
  CASE
    WHEN def.field_id = 'DEF_ALCOHOL_TIME' THEN 'alcohol_time'
    WHEN def.field_id = 'DEF_SLEEP_SESSION_START' THEN 'sleep_start_time'
  END as parameter_name
FROM instance_calculations ic
CROSS JOIN data_entry_fields def
WHERE ic.calc_id = 'IC_072'
AND def.field_id IN ('DEF_ALCOHOL_TIME', 'DEF_SLEEP_SESSION_START')
ON CONFLICT (instance_calculation_id, data_entry_field_id, parameter_name) DO NOTHING;

DO $$
DECLARE
  new_calcs INTEGER;
BEGIN
  SELECT COUNT(*) INTO new_calcs
  FROM instance_calculations
  WHERE calc_id IN ('IC_007', 'IC_003B', 'IC_008', 'IC_009', 'IC_073', 'IC_072');

  RAISE NOTICE '=========================================';
  RAISE NOTICE 'Missing Instance Calculations Created';
  RAISE NOTICE '=========================================';
  RAISE NOTICE 'New instance calculations: %', new_calcs;
  RAISE NOTICE '';
  RAISE NOTICE 'Duration-Based:';
  RAISE NOTICE '  - IC_007: HIIT Duration';
  RAISE NOTICE '  - IC_003B: Mobility Duration (replaces IC_003)';
  RAISE NOTICE '  - IC_008: Outdoor Time Duration';
  RAISE NOTICE '  - IC_009: Sunlight Exposure Duration';
  RAISE NOTICE '';
  RAISE NOTICE 'Contextual/Temporal:';
  RAISE NOTICE '  - IC_073: Caffeine to Sleep Window (CRITICAL)';
  RAISE NOTICE '  - IC_072: Alcohol to Sleep Window';
  RAISE NOTICE '';
  RAISE NOTICE 'Next step: Create event_types architecture';
END $$;

COMMIT;
