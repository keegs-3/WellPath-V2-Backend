-- =====================================================
-- Create Missing Instance Calculations
-- =====================================================
-- Adds instance calculations for:
-- - HIIT duration
-- - Mobility duration (replaces flexibility)
-- - Outdoor time duration
-- - Sunlight exposure duration
-- - Caffeine to sleep window
-- - Alcohol to sleep window
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Duration-Based Calculations
-- =====================================================

-- HIIT Duration
INSERT INTO instance_calculations (
  calc_id,
  calc_name,
  display_name,
  description,
  calculation_method,
  formula_definition,
  unit_id,
  is_displayed_to_user,
  is_active,
  calculation_config
) VALUES (
  'IC_007',
  'hiit_duration',
  'HIIT Duration',
  'Duration of high-intensity interval training session',
  'time_difference',
  'end_time - start_time',
  'minute',
  true,
  true,
  '{
    "parameters": {
      "end_time": "DEF_HIIT_END",
      "start_time": "DEF_HIIT_START"
    },
    "output_unit": "minute"
  }'::jsonb
)
ON CONFLICT (calc_id) DO NOTHING;

-- Mobility Duration (new, to replace flexibility)
INSERT INTO instance_calculations (
  calc_id,
  calc_name,
  display_name,
  description,
  calculation_method,
  formula_definition,
  unit_id,
  is_displayed_to_user,
  is_active,
  calculation_config
) VALUES (
  'IC_003B',
  'mobility_duration',
  'Mobility Duration',
  'Duration of mobility/flexibility session',
  'time_difference',
  'end_time - start_time',
  'minute',
  true,
  true,
  '{
    "parameters": {
      "end_time": "DEF_MOBILITY_END",
      "start_time": "DEF_MOBILITY_START"
    },
    "output_unit": "minute"
  }'::jsonb
)
ON CONFLICT (calc_id) DO NOTHING;

-- Outdoor Time Duration
INSERT INTO instance_calculations (
  calc_id,
  calc_name,
  display_name,
  description,
  calculation_method,
  formula_definition,
  unit_id,
  is_displayed_to_user,
  is_active,
  calculation_config
) VALUES (
  'IC_008',
  'outdoor_duration',
  'Outdoor Time Duration',
  'Duration spent outdoors',
  'time_difference',
  'end_time - start_time',
  'minute',
  true,
  true,
  '{
    "parameters": {
      "end_time": "DEF_OUTDOOR_END",
      "start_time": "DEF_OUTDOOR_START"
    },
    "output_unit": "minute"
  }'::jsonb
)
ON CONFLICT (calc_id) DO NOTHING;

-- Sunlight Exposure Duration
INSERT INTO instance_calculations (
  calc_id,
  calc_name,
  display_name,
  description,
  calculation_method,
  formula_definition,
  unit_id,
  is_displayed_to_user,
  is_active,
  calculation_config
) VALUES (
  'IC_009',
  'sunlight_duration',
  'Sunlight Exposure Duration',
  'Duration of sunlight exposure',
  'time_difference',
  'end_time - start_time',
  'minute',
  true,
  true,
  '{
    "parameters": {
      "end_time": "DEF_SUNLIGHT_END",
      "start_time": "DEF_SUNLIGHT_START"
    },
    "output_unit": "minute"
  }'::jsonb
)
ON CONFLICT (calc_id) DO NOTHING;


-- =====================================================
-- PART 2: Contextual/Temporal Pattern Calculations
-- =====================================================

-- Caffeine to Sleep Window
INSERT INTO instance_calculations (
  calc_id,
  calc_name,
  display_name,
  description,
  calculation_method,
  formula_definition,
  unit_id,
  is_displayed_to_user,
  is_active,
  calculation_config
) VALUES (
  'IC_073',
  'caffeine_to_sleep_window',
  'Caffeine to Sleep Window',
  'Hours between last caffeine intake and sleep session start (CRITICAL for sleep quality)',
  'time_difference',
  'sleep_start_time - caffeine_time',
  'hours',
  true,
  true,
  '{
    "parameters": {
      "sleep_start_time": "DEF_SLEEP_SESSION_START",
      "caffeine_time": "DEF_CAFFEINE_TIME"
    },
    "output_unit": "hours",
    "aggregation": "min",
    "window": "same_day",
    "alert_threshold": 6,
    "alert_message": "Caffeine within 6 hours of sleep may impact sleep quality"
  }'::jsonb
)
ON CONFLICT (calc_id) DO NOTHING;

-- Alcohol to Sleep Window
INSERT INTO instance_calculations (
  calc_id,
  calc_name,
  display_name,
  description,
  calculation_method,
  formula_definition,
  unit_id,
  is_displayed_to_user,
  is_active,
  calculation_config
) VALUES (
  'IC_072',
  'alcohol_to_sleep_window',
  'Alcohol to Sleep Window',
  'Hours between last alcohol consumption and sleep session start',
  'time_difference',
  'sleep_start_time - alcohol_time',
  'hours',
  true,
  true,
  '{
    "parameters": {
      "sleep_start_time": "DEF_SLEEP_SESSION_START",
      "alcohol_time": "DEF_ALCOHOL_TIME"
    },
    "output_unit": "hours",
    "aggregation": "min",
    "window": "same_day",
    "alert_threshold": 3,
    "alert_message": "Alcohol within 3 hours of sleep may disrupt sleep architecture"
  }'::jsonb
)
ON CONFLICT (calc_id) DO NOTHING;


-- =====================================================
-- PART 3: Update old flexibility calculation to inactive
-- =====================================================

UPDATE instance_calculations
SET is_active = false
WHERE calc_id = 'IC_003'
AND calc_name = 'flexibility_duration';


-- =====================================================
-- PART 4: Create dependencies for new calculations
-- =====================================================

-- HIIT Duration dependencies
INSERT INTO instance_calculations_dependencies (
  instance_calculation_id,
  data_entry_field_id,
  parameter_name
)
SELECT
  ic.id,
  def.field_id,
  CASE
    WHEN def.field_id = 'DEF_HIIT_START' THEN 'start_time'
    WHEN def.field_id = 'DEF_HIIT_END' THEN 'end_time'
  END as parameter_name
FROM instance_calculations ic
CROSS JOIN data_entry_fields def
WHERE ic.calc_id = 'IC_007'
AND def.field_id IN ('DEF_HIIT_START', 'DEF_HIIT_END')
AND ic.id IS NOT NULL
ON CONFLICT (instance_calculation_id, data_entry_field_id, parameter_name) DO NOTHING;

-- Mobility Duration dependencies
INSERT INTO instance_calculations_dependencies (
  instance_calculation_id,
  data_entry_field_id,
  parameter_name
)
SELECT
  ic.id,
  def.field_id,
  CASE
    WHEN def.field_id = 'DEF_MOBILITY_START' THEN 'start_time'
    WHEN def.field_id = 'DEF_MOBILITY_END' THEN 'end_time'
  END as parameter_name
FROM instance_calculations ic
CROSS JOIN data_entry_fields def
WHERE ic.calc_id = 'IC_003B'
AND def.field_id IN ('DEF_MOBILITY_START', 'DEF_MOBILITY_END')
AND ic.id IS NOT NULL
ON CONFLICT (instance_calculation_id, data_entry_field_id, parameter_name) DO NOTHING;

-- Outdoor Duration dependencies
INSERT INTO instance_calculations_dependencies (
  instance_calculation_id,
  data_entry_field_id,
  parameter_name
)
SELECT
  ic.id,
  def.field_id,
  CASE
    WHEN def.field_id = 'DEF_OUTDOOR_START' THEN 'start_time'
    WHEN def.field_id = 'DEF_OUTDOOR_END' THEN 'end_time'
  END as parameter_name
FROM instance_calculations ic
CROSS JOIN data_entry_fields def
WHERE ic.calc_id = 'IC_008'
AND def.field_id IN ('DEF_OUTDOOR_START', 'DEF_OUTDOOR_END')
AND ic.id IS NOT NULL
ON CONFLICT (instance_calculation_id, data_entry_field_id, parameter_name) DO NOTHING;

-- Sunlight Duration dependencies
INSERT INTO instance_calculations_dependencies (
  instance_calculation_id,
  data_entry_field_id,
  parameter_name
)
SELECT
  ic.id,
  def.field_id,
  CASE
    WHEN def.field_id = 'DEF_SUNLIGHT_START' THEN 'start_time'
    WHEN def.field_id = 'DEF_SUNLIGHT_END' THEN 'end_time'
  END as parameter_name
FROM instance_calculations ic
CROSS JOIN data_entry_fields def
WHERE ic.calc_id = 'IC_009'
AND def.field_id IN ('DEF_SUNLIGHT_START', 'DEF_SUNLIGHT_END')
AND ic.id IS NOT NULL
ON CONFLICT (instance_calculation_id, data_entry_field_id, parameter_name) DO NOTHING;

-- Caffeine to Sleep Window dependencies
INSERT INTO instance_calculations_dependencies (
  instance_calculation_id,
  data_entry_field_id,
  parameter_name
)
SELECT
  ic.id,
  def.field_id,
  CASE
    WHEN def.field_id = 'DEF_CAFFEINE_TIME' THEN 'caffeine_time'
    WHEN def.field_id = 'DEF_SLEEP_SESSION_START' THEN 'sleep_start_time'
  END as parameter_name
FROM instance_calculations ic
CROSS JOIN data_entry_fields def
WHERE ic.calc_id = 'IC_073'
AND def.field_id IN ('DEF_CAFFEINE_TIME', 'DEF_SLEEP_SESSION_START')
AND ic.id IS NOT NULL
ON CONFLICT (instance_calculation_id, data_entry_field_id, parameter_name) DO NOTHING;

-- Alcohol to Sleep Window dependencies
INSERT INTO instance_calculations_dependencies (
  instance_calculation_id,
  data_entry_field_id,
  parameter_name
)
SELECT
  ic.id,
  def.field_id,
  CASE
    WHEN def.field_id = 'DEF_ALCOHOL_TIME' THEN 'alcohol_time'
    WHEN def.field_id = 'DEF_SLEEP_SESSION_START' THEN 'sleep_start_time'
  END as parameter_name
FROM instance_calculations ic
CROSS JOIN data_entry_fields def
WHERE ic.calc_id = 'IC_072'
AND def.field_id IN ('DEF_ALCOHOL_TIME', 'DEF_SLEEP_SESSION_START')
AND ic.id IS NOT NULL
ON CONFLICT (instance_calculation_id, data_entry_field_id, parameter_name) DO NOTHING;


-- =====================================================
-- Summary
-- =====================================================

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
