-- =====================================================
-- Cleanup Redundant Sleep Fields
-- =====================================================
-- Removes redundant type-specific START/END fields
-- Keeps generic fields (DEF_SLEEP_PERIOD_START/END/TYPE)
-- Ensures all OUTPUT fields exist for aggregations
--
-- Created: 2025-10-29
-- =====================================================

BEGIN;

-- =====================================================
-- 1. Add missing OUTPUT fields for all 6 sleep types
-- =====================================================

-- Awake periods duration (for aggregation)
INSERT INTO data_entry_fields (
    field_id,
    field_name,
    display_name,
    description,
    field_type,
    data_type,
    unit,
    is_active
) VALUES (
    'OUTPUT_AWAKE_PERIODS_DURATION',
    'awake_periods_duration',
    'Awake Periods Duration',
    'Total duration of awake periods during sleep (calculated)',
    'output',
    'numeric',
    'minute',
    true
) ON CONFLICT (field_id) DO UPDATE SET
    display_name = EXCLUDED.display_name,
    description = EXCLUDED.description,
    updated_at = now();

-- In bed duration (for aggregation)
INSERT INTO data_entry_fields (
    field_id,
    field_name,
    display_name,
    description,
    field_type,
    data_type,
    unit,
    is_active
) VALUES (
    'OUTPUT_IN_BED_DURATION',
    'in_bed_duration',
    'Time in Bed',
    'Total duration of in bed period (calculated)',
    'output',
    'numeric',
    'minute',
    true
) ON CONFLICT (field_id) DO UPDATE SET
    display_name = EXCLUDED.display_name,
    description = EXCLUDED.description,
    updated_at = now();

-- Unspecified sleep duration (for aggregation)
INSERT INTO data_entry_fields (
    field_id,
    field_name,
    display_name,
    description,
    field_type,
    data_type,
    unit,
    is_active
) VALUES (
    'OUTPUT_UNSPECIFIED_SLEEP_DURATION',
    'unspecified_sleep_duration',
    'Unspecified Sleep Duration',
    'Total duration of unspecified sleep periods (calculated)',
    'output',
    'numeric',
    'minute',
    true
) ON CONFLICT (field_id) DO UPDATE SET
    display_name = EXCLUDED.display_name,
    description = EXCLUDED.description,
    updated_at = now();

-- =====================================================
-- 2. Create instance calculations for missing types
-- =====================================================

-- Awake periods duration calculation
INSERT INTO instance_calculations (
    calc_id,
    calc_name,
    display_name,
    description,
    calculation_method,
    unit_id,
    calculation_config
) VALUES (
    'CALC_AWAKE_PERIODS_DURATION',
    'awake_periods_duration',
    'Awake Periods Duration',
    'Calculate duration of awake periods during sleep',
    'calculate_duration',
    'minute',
    jsonb_build_object(
        'output_field', 'OUTPUT_AWAKE_PERIODS_DURATION',
        'output_source', 'auto_calculated',
        'output_unit', 'minute'
    )
) ON CONFLICT (calc_id) DO UPDATE SET
    display_name = EXCLUDED.display_name,
    description = EXCLUDED.description,
    updated_at = now();

-- In bed duration calculation
INSERT INTO instance_calculations (
    calc_id,
    calc_name,
    display_name,
    description,
    calculation_method,
    unit_id,
    calculation_config
) VALUES (
    'CALC_IN_BED_DURATION',
    'in_bed_duration',
    'Time in Bed',
    'Calculate duration of in bed period',
    'calculate_duration',
    'minute',
    jsonb_build_object(
        'output_field', 'OUTPUT_IN_BED_DURATION',
        'output_source', 'auto_calculated',
        'output_unit', 'minute'
    )
) ON CONFLICT (calc_id) DO UPDATE SET
    display_name = EXCLUDED.display_name,
    description = EXCLUDED.description,
    updated_at = now();

-- Unspecified sleep duration calculation
INSERT INTO instance_calculations (
    calc_id,
    calc_name,
    display_name,
    description,
    calculation_method,
    unit_id,
    calculation_config
) VALUES (
    'CALC_UNSPECIFIED_SLEEP_DURATION',
    'unspecified_sleep_duration',
    'Unspecified Sleep Duration',
    'Calculate duration of unspecified sleep periods',
    'calculate_duration',
    'minute',
    jsonb_build_object(
        'output_field', 'OUTPUT_UNSPECIFIED_SLEEP_DURATION',
        'output_source', 'auto_calculated',
        'output_unit', 'minute'
    )
) ON CONFLICT (calc_id) DO UPDATE SET
    display_name = EXCLUDED.display_name,
    description = EXCLUDED.description,
    updated_at = now();

-- =====================================================
-- 3. Add OUTPUT fields to field_registry
-- =====================================================

-- Link to existing calculations
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
    ('OUTPUT_CORE_SLEEP_DURATION', 'core_sleep_duration', 'Core Sleep Duration', 'Total duration of core sleep (calculated)', 'calculated', 'CALC_CORE_SLEEP_DURATION', 'minute', true),
    ('OUTPUT_DEEP_SLEEP_DURATION', 'deep_sleep_duration', 'Deep Sleep Duration', 'Total duration of deep sleep (calculated)', 'calculated', 'CALC_DEEP_SLEEP_DURATION', 'minute', true),
    ('OUTPUT_REM_SLEEP_DURATION', 'rem_sleep_duration', 'REM Sleep Duration', 'Total duration of REM sleep (calculated)', 'calculated', 'CALC_REM_SLEEP_DURATION', 'minute', true),
    ('OUTPUT_AWAKE_PERIODS_DURATION', 'awake_periods_duration', 'Awake Periods Duration', 'Total duration of awake periods (calculated)', 'calculated', 'CALC_AWAKE_PERIODS_DURATION', 'minute', true),
    ('OUTPUT_IN_BED_DURATION', 'in_bed_duration', 'Time in Bed', 'Total duration in bed (calculated)', 'calculated', 'CALC_IN_BED_DURATION', 'minute', true),
    ('OUTPUT_UNSPECIFIED_SLEEP_DURATION', 'unspecified_sleep_duration', 'Unspecified Sleep Duration', 'Total duration of unspecified sleep (calculated)', 'calculated', 'CALC_UNSPECIFIED_SLEEP_DURATION', 'minute', true)
ON CONFLICT (field_id) DO UPDATE SET
    instance_calculation_id = EXCLUDED.instance_calculation_id,
    updated_at = now();

-- =====================================================
-- 4. Delete redundant type-specific START/END fields
-- =====================================================

-- These are redundant because we use generic fields:
-- DEF_SLEEP_PERIOD_START, DEF_SLEEP_PERIOD_END, DEF_SLEEP_PERIOD_TYPE

-- First, delete any instance calculation dependencies referencing these fields
DELETE FROM instance_calculations_dependencies
WHERE data_entry_field_id IN (
    'DEF_CORE_SLEEP_START',
    'DEF_CORE_SLEEP_END',
    'DEF_DEEP_SLEEP_START',
    'DEF_DEEP_SLEEP_END',
    'DEF_REM_SLEEP_START',
    'DEF_REM_SLEEP_END',
    'DEF_AWAKE_SLEEP_START',
    'DEF_AWAKE_SLEEP_END',
    'DEF_INBED_SLEEP_START',
    'DEF_INBED_SLEEP_END',
    'DEF_ASLEEP_UNSPECIFIED_SLEEP_START',
    'DEF_ASLEEP_UNSPECIFIED_SLEEP_END'
);

-- Delete any aggregation metric dependencies referencing these fields
DELETE FROM aggregation_metrics_dependencies
WHERE data_entry_field_id IN (
    'DEF_CORE_SLEEP_START',
    'DEF_CORE_SLEEP_END',
    'DEF_DEEP_SLEEP_START',
    'DEF_DEEP_SLEEP_END',
    'DEF_REM_SLEEP_START',
    'DEF_REM_SLEEP_END',
    'DEF_AWAKE_SLEEP_START',
    'DEF_AWAKE_SLEEP_END',
    'DEF_INBED_SLEEP_START',
    'DEF_INBED_SLEEP_END',
    'DEF_ASLEEP_UNSPECIFIED_SLEEP_START',
    'DEF_ASLEEP_UNSPECIFIED_SLEEP_END'
);

-- Delete from field_registry (must come before data_entry_fields due to FK)
DELETE FROM field_registry
WHERE field_id IN (
    'DEF_CORE_SLEEP_START',
    'DEF_CORE_SLEEP_END',
    'DEF_DEEP_SLEEP_START',
    'DEF_DEEP_SLEEP_END',
    'DEF_REM_SLEEP_START',
    'DEF_REM_SLEEP_END',
    'DEF_AWAKE_SLEEP_START',
    'DEF_AWAKE_SLEEP_END',
    'DEF_INBED_SLEEP_START',
    'DEF_INBED_SLEEP_END',
    'DEF_ASLEEP_UNSPECIFIED_SLEEP_START',
    'DEF_ASLEEP_UNSPECIFIED_SLEEP_END'
);

-- Finally, delete the fields themselves from data_entry_fields
DELETE FROM data_entry_fields
WHERE field_id IN (
    'DEF_CORE_SLEEP_START',
    'DEF_CORE_SLEEP_END',
    'DEF_DEEP_SLEEP_START',
    'DEF_DEEP_SLEEP_END',
    'DEF_REM_SLEEP_START',
    'DEF_REM_SLEEP_END',
    'DEF_AWAKE_SLEEP_START',
    'DEF_AWAKE_SLEEP_END',
    'DEF_INBED_SLEEP_START',
    'DEF_INBED_SLEEP_END',
    'DEF_ASLEEP_UNSPECIFIED_SLEEP_START',
    'DEF_ASLEEP_UNSPECIFIED_SLEEP_END'
);

COMMIT;

-- =====================================================
-- Verification Queries
-- =====================================================

-- Check OUTPUT fields exist
SELECT
    field_id,
    field_name,
    field_type,
    is_active
FROM data_entry_fields
WHERE field_id LIKE 'OUTPUT_%SLEEP%'
   OR field_id LIKE 'OUTPUT_%BED%'
   OR field_id LIKE 'OUTPUT_%AWAKE%'
ORDER BY field_id;

-- Verify redundant fields are deleted
SELECT
    field_id,
    field_name
FROM data_entry_fields
WHERE field_id IN (
    'DEF_CORE_SLEEP_START', 'DEF_CORE_SLEEP_END',
    'DEF_DEEP_SLEEP_START', 'DEF_DEEP_SLEEP_END',
    'DEF_REM_SLEEP_START', 'DEF_REM_SLEEP_END'
);
-- Should return 0 rows

-- Check generic fields still exist
SELECT
    field_id,
    field_name,
    display_name,
    is_active
FROM data_entry_fields
WHERE field_id IN (
    'DEF_SLEEP_PERIOD_START',
    'DEF_SLEEP_PERIOD_END',
    'DEF_SLEEP_PERIOD_TYPE',
    'DEF_SLEEP_PERIOD_DURATION'
)
ORDER BY field_id;
-- Should return 4 rows
