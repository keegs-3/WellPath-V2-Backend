-- =====================================================
-- Fix Sleep Stage Instance Calculation Config
-- =====================================================
-- Update calculation_method and calculation_config
-- to match the working pattern used by other sleep calculations
--
-- Created: 2025-10-24
-- =====================================================

UPDATE instance_calculations
SET
  calculation_method = 'calculate_duration',
  calculation_config = jsonb_build_object(
    'output_unit', 'minute',
    'output_field', 'OUTPUT_DEEP_SLEEP_DURATION',
    'output_source', 'auto_calculated'
  )
WHERE calc_id = 'CALC_DEEP_SLEEP_DURATION';

UPDATE instance_calculations
SET
  calculation_method = 'calculate_duration',
  calculation_config = jsonb_build_object(
    'output_unit', 'minute',
    'output_field', 'OUTPUT_CORE_SLEEP_DURATION',
    'output_source', 'auto_calculated'
  )
WHERE calc_id = 'CALC_CORE_SLEEP_DURATION';

UPDATE instance_calculations
SET
  calculation_method = 'calculate_duration',
  calculation_config = jsonb_build_object(
    'output_unit', 'minute',
    'output_field', 'OUTPUT_REM_SLEEP_DURATION',
    'output_source', 'auto_calculated'
  )
WHERE calc_id = 'CALC_REM_SLEEP_DURATION';

UPDATE instance_calculations
SET
  calculation_method = 'calculate_duration',
  calculation_config = jsonb_build_object(
    'output_unit', 'minute',
    'output_field', 'OUTPUT_AWAKE_PERIODS_DURATION',
    'output_source', 'auto_calculated'
  )
WHERE calc_id = 'CALC_AWAKE_PERIODS_DURATION';

-- Summary
SELECT '
========================================
✅ Sleep Stage Calculations Fixed
========================================

Updated:
  - CALC_DEEP_SLEEP_DURATION
  - CALC_CORE_SLEEP_DURATION
  - CALC_REM_SLEEP_DURATION
  - CALC_AWAKE_PERIODS_DURATION

Changes:
  calculation_method: "duration" → "calculate_duration"
  calculation_config: Added output_unit, output_field, output_source

Ready for edge function processing! 🚀
========================================
' as summary;
