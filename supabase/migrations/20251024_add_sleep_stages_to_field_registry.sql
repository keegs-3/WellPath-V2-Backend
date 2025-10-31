-- =====================================================
-- Add Sleep Stages to Field Registry
-- =====================================================
-- Registers sleep stage fields in the unified field registry
--
-- Created: 2025-10-24
-- =====================================================

-- =====================================================
-- USER INPUT FIELDS (Start/End times)
-- =====================================================

INSERT INTO field_registry (
  field_id,
  field_name,
  display_name,
  description,
  field_source,
  data_entry_field_id,
  is_active
) VALUES
  -- Deep Sleep
  (
    'DEF_DEEP_SLEEP_START',
    'deep_sleep_start',
    'Deep Sleep Start',
    'Start time of deep sleep period',
    'user_input',
    'DEF_DEEP_SLEEP_START',
    true
  ),
  (
    'DEF_DEEP_SLEEP_END',
    'deep_sleep_end',
    'Deep Sleep End',
    'End time of deep sleep period',
    'user_input',
    'DEF_DEEP_SLEEP_END',
    true
  ),

  -- Core Sleep
  (
    'DEF_CORE_SLEEP_START',
    'core_sleep_start',
    'Core Sleep Start',
    'Start time of core sleep period',
    'user_input',
    'DEF_CORE_SLEEP_START',
    true
  ),
  (
    'DEF_CORE_SLEEP_END',
    'core_sleep_end',
    'Core Sleep End',
    'End time of core sleep period',
    'user_input',
    'DEF_CORE_SLEEP_END',
    true
  ),

  -- REM Sleep
  (
    'DEF_REM_SLEEP_START',
    'rem_sleep_start',
    'REM Sleep Start',
    'Start time of REM sleep period',
    'user_input',
    'DEF_REM_SLEEP_START',
    true
  ),
  (
    'DEF_REM_SLEEP_END',
    'rem_sleep_end',
    'REM Sleep End',
    'End time of REM sleep period',
    'user_input',
    'DEF_REM_SLEEP_END',
    true
  ),

  -- Awake Periods
  (
    'DEF_AWAKE_PERIODS_START',
    'awake_periods_start',
    'Awake Period Start',
    'Start time of awake period during sleep session',
    'user_input',
    'DEF_AWAKE_PERIODS_START',
    true
  ),
  (
    'DEF_AWAKE_PERIODS_END',
    'awake_periods_end',
    'Awake Period End',
    'End time of awake period during sleep session',
    'user_input',
    'DEF_AWAKE_PERIODS_END',
    true
  )
ON CONFLICT (field_id) DO UPDATE SET
  field_name = EXCLUDED.field_name,
  display_name = EXCLUDED.display_name,
  data_entry_field_id = EXCLUDED.data_entry_field_id;

-- =====================================================
-- CALCULATED FIELDS (Duration outputs)
-- =====================================================

INSERT INTO field_registry (
  field_id,
  field_name,
  display_name,
  description,
  field_source,
  instance_calculation_id,
  unit,
  is_active
) VALUES
  -- Deep Sleep Duration
  (
    'OUTPUT_DEEP_SLEEP_DURATION',
    'deep_sleep_duration',
    'Deep Sleep Duration',
    'Calculated deep sleep duration',
    'calculated',
    'CALC_DEEP_SLEEP_DURATION',
    'minutes',
    true
  ),

  -- Core Sleep Duration
  (
    'OUTPUT_CORE_SLEEP_DURATION',
    'core_sleep_duration',
    'Core Sleep Duration',
    'Calculated core sleep duration',
    'calculated',
    'CALC_CORE_SLEEP_DURATION',
    'minutes',
    true
  ),

  -- REM Sleep Duration
  (
    'OUTPUT_REM_SLEEP_DURATION',
    'rem_sleep_duration',
    'REM Sleep Duration',
    'Calculated REM sleep duration',
    'calculated',
    'CALC_REM_SLEEP_DURATION',
    'minutes',
    true
  ),

  -- Awake Periods Duration
  (
    'OUTPUT_AWAKE_PERIODS_DURATION',
    'awake_periods_duration',
    'Awake Periods Duration',
    'Calculated awake periods duration',
    'calculated',
    'CALC_AWAKE_PERIODS_DURATION',
    'minutes',
    true
  )
ON CONFLICT (field_id) DO UPDATE SET
  field_name = EXCLUDED.field_name,
  display_name = EXCLUDED.display_name,
  instance_calculation_id = EXCLUDED.instance_calculation_id,
  unit = EXCLUDED.unit;

-- Summary
SELECT '
========================================
✅ Sleep Stages Added to Field Registry
========================================

User Input Fields (8):
  - DEF_DEEP_SLEEP_START
  - DEF_DEEP_SLEEP_END
  - DEF_CORE_SLEEP_START
  - DEF_CORE_SLEEP_END
  - DEF_REM_SLEEP_START
  - DEF_REM_SLEEP_END
  - DEF_AWAKE_PERIODS_START
  - DEF_AWAKE_PERIODS_END

Calculated Fields (4):
  - OUTPUT_DEEP_SLEEP_DURATION
  - OUTPUT_CORE_SLEEP_DURATION
  - OUTPUT_REM_SLEEP_DURATION
  - OUTPUT_AWAKE_PERIODS_DURATION

Ready for data entry! 🎉
========================================
' as summary;
