-- =====================================================
-- Create OUTPUT_SLEEP_DURATION Field
-- =====================================================
-- Creates a field that aggregates all sleep stage durations
-- for a complete sleep event (sum of CORE + DEEP + REM + AWAKE + IN_BED)
--
-- Created: 2025-10-29
-- =====================================================

BEGIN;

-- =====================================================
-- 1. Create OUTPUT_SLEEP_DURATION field in field_registry
-- =====================================================
-- This is a calculated field that sums CORE + DEEP + REM + UNSPECIFIED per event
-- Note: Does NOT include AWAKE or IN_BED (those contribute to "time in bed", not "sleep duration")

-- Create OUTPUT_SLEEP_DURATION in data_entry_fields
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
    'OUTPUT_SLEEP_DURATION',
    'total_sleep_duration',
    'Total Sleep Duration',
    'Total actual sleep duration per event (sum of CORE + DEEP + REM + UNSPECIFIED stages). Excludes AWAKE and IN_BED periods.',
    'output',
    'numeric',
    'minutes',
    true
) ON CONFLICT (field_id) DO UPDATE SET
    display_name = EXCLUDED.display_name,
    description = EXCLUDED.description,
    updated_at = now();

-- Also create in field_registry for completeness
INSERT INTO field_registry (
    field_id,
    field_name,
    display_name,
    description,
    field_source,
    data_entry_field_id,
    unit,
    is_active
) VALUES (
    'OUTPUT_SLEEP_DURATION',
    'total_sleep_duration',
    'Total Sleep Duration',
    'Total actual sleep duration per event (sum of CORE + DEEP + REM + UNSPECIFIED stages). Excludes AWAKE and IN_BED periods.',
    'calculated',
    'OUTPUT_SLEEP_DURATION',  -- Points to itself in data_entry_fields
    'minutes',
    true
) ON CONFLICT (field_id) DO UPDATE SET
    display_name = EXCLUDED.display_name,
    description = EXCLUDED.description,
    updated_at = now();

-- =====================================================
-- 2. Populate OUTPUT_SLEEP_DURATION values
-- =====================================================
-- Sum only actual sleep stages (CORE + DEEP + REM + UNSPECIFIED)
-- Group by event_instance_id to avoid double counting across days
-- Note: AWAKE and IN_BED are NOT included in sleep duration

INSERT INTO patient_data_entries (
    patient_id,
    field_id,
    entry_date,
    value_quantity,
    event_instance_id,
    source
)
SELECT
    patient_id,
    'OUTPUT_SLEEP_DURATION' as field_id,
    MIN(entry_date) as entry_date,  -- Use the first date of the sleep event
    SUM(value_quantity) as value_quantity,
    event_instance_id,
    'auto_calculated' as source
FROM patient_data_entries
WHERE field_id IN (
    'OUTPUT_CORE_SLEEP_DURATION',
    'OUTPUT_DEEP_SLEEP_DURATION',
    'OUTPUT_REM_SLEEP_DURATION',
    'OUTPUT_UNSPECIFIED_SLEEP_DURATION'
    -- Explicitly NOT including OUTPUT_AWAKE_PERIODS_DURATION or OUTPUT_IN_BED_DURATION
)
  AND event_instance_id IS NOT NULL
GROUP BY patient_id, event_instance_id
ON CONFLICT DO NOTHING;

-- =====================================================
-- 3. Update AGG_SLEEP_DURATION to use OUTPUT_SLEEP_DURATION
-- =====================================================

UPDATE aggregation_metrics_dependencies
SET data_entry_field_id = 'OUTPUT_SLEEP_DURATION'
WHERE agg_metric_id = 'AGG_SLEEP_DURATION'
  AND data_entry_field_id = 'DEF_SLEEP_PERIOD_DURATION';

COMMIT;

-- =====================================================
-- Verification
-- =====================================================

-- Check the field was created
SELECT field_id, field_name, field_type, unit
FROM data_entry_fields
WHERE field_id = 'OUTPUT_SLEEP_DURATION';

-- Check the dependency was updated
SELECT
    amd.dependency_type,
    amd.data_entry_field_id
FROM aggregation_metrics_dependencies amd
WHERE amd.agg_metric_id = 'AGG_SLEEP_DURATION'
  AND amd.dependency_type = 'data_field';
