-- =====================================================
-- Smart TIME_IN_BED Calculation
-- =====================================================
-- Handles both:
-- 1. HealthKit: periods with same event_instance_id
-- 2. Manual entry: temporally adjacent periods
--
-- Groups periods that are immediately adjacent (end time = start time)
-- into sleep sessions and calculates TIME_IN_BED per session
--
-- Created: 2025-10-29
-- =====================================================

BEGIN;

-- Drop existing objects in correct order (view before function)
DROP VIEW IF EXISTS v_daily_time_in_bed;
DROP FUNCTION IF EXISTS group_adjacent_sleep_periods(uuid, date);

-- =====================================================
-- 1. Create function to group adjacent sleep periods into sessions
-- =====================================================

CREATE OR REPLACE FUNCTION group_adjacent_sleep_periods(p_patient_id uuid, p_date date)
RETURNS TABLE (
    session_id uuid,
    sleep_date date,
    session_start timestamp,
    session_end timestamp,
    total_duration_minutes numeric,
    sleep_duration_minutes numeric,
    core_sleep_minutes numeric,
    deep_sleep_minutes numeric,
    rem_sleep_minutes numeric,
    unspecified_sleep_minutes numeric,
    awake_duration_minutes numeric,
    in_bed_duration_minutes numeric
) AS $$
WITH sleep_periods AS (
    -- Get all sleep-related periods for the date
    SELECT
        pde_start.event_instance_id,
        pde_start.value_timestamp as start_time,
        pde_end.value_timestamp as end_time,
        pde_type.value_reference as period_type_id,
        ref_type.period_name,
        EXTRACT(EPOCH FROM (pde_end.value_timestamp - pde_start.value_timestamp)) / 60 as duration_minutes,
        pde_start.entry_date
    FROM patient_data_entries pde_start
    INNER JOIN patient_data_entries pde_end
        ON pde_end.event_instance_id = pde_start.event_instance_id
        AND pde_end.field_id = 'DEF_SLEEP_PERIOD_END'
    INNER JOIN patient_data_entries pde_type
        ON pde_type.event_instance_id = pde_start.event_instance_id
        AND pde_type.field_id = 'DEF_SLEEP_PERIOD_TYPE'
    LEFT JOIN def_ref_sleep_period_types ref_type
        ON ref_type.id = pde_type.value_reference::uuid
    WHERE pde_start.field_id = 'DEF_SLEEP_PERIOD_START'
      AND pde_start.patient_id = p_patient_id
      AND pde_start.entry_date = p_date
    ORDER BY pde_start.value_timestamp
),
grouped_periods AS (
    -- Group adjacent periods using window functions
    SELECT
        *,
        -- Mark start of new session when gap > 1 minute between periods
        CASE
            WHEN LAG(end_time) OVER (ORDER BY start_time) IS NULL THEN true
            WHEN start_time - LAG(end_time) OVER (ORDER BY start_time) > INTERVAL '1 minute' THEN true
            ELSE false
        END as is_session_start
    FROM sleep_periods
),
session_markers AS (
    -- Assign session IDs
    SELECT
        *,
        SUM(CASE WHEN is_session_start THEN 1 ELSE 0 END) OVER (ORDER BY start_time) as session_number
    FROM grouped_periods
)
-- Aggregate by session
SELECT
    gen_random_uuid() as session_id,
    entry_date as sleep_date,
    MIN(start_time) as session_start,
    MAX(end_time) as session_end,
    -- TIME_IN_BED = sleep stages + awake periods (NOT including IN_BED stage)
    SUM(CASE WHEN period_name IN ('core', 'deep', 'rem', 'unspecified', 'awake')
             THEN duration_minutes ELSE 0 END) as total_duration_minutes,
    SUM(CASE WHEN period_name IN ('core', 'deep', 'rem', 'unspecified')
             THEN duration_minutes ELSE 0 END) as sleep_duration_minutes,
    SUM(CASE WHEN period_name = 'core'
             THEN duration_minutes ELSE 0 END) as core_sleep_minutes,
    SUM(CASE WHEN period_name = 'deep'
             THEN duration_minutes ELSE 0 END) as deep_sleep_minutes,
    SUM(CASE WHEN period_name = 'rem'
             THEN duration_minutes ELSE 0 END) as rem_sleep_minutes,
    SUM(CASE WHEN period_name = 'unspecified'
             THEN duration_minutes ELSE 0 END) as unspecified_sleep_minutes,
    SUM(CASE WHEN period_name = 'awake'
             THEN duration_minutes ELSE 0 END) as awake_duration_minutes,
    SUM(CASE WHEN period_name = 'in_bed'
             THEN duration_minutes ELSE 0 END) as in_bed_duration_minutes
FROM session_markers
GROUP BY session_number, entry_date
ORDER BY session_start;
$$
 LANGUAGE sql;

-- =====================================================
-- 2. Create aggregate TIME_IN_BED view
-- =====================================================

CREATE OR REPLACE VIEW v_daily_time_in_bed AS
WITH patient_dates AS (
    SELECT DISTINCT
        patient_id,
        entry_date
    FROM patient_data_entries
    WHERE field_id = 'DEF_SLEEP_PERIOD_START'
),
sessions AS (
    SELECT
        pd.patient_id,
        sessions.*
    FROM patient_dates pd
    CROSS JOIN LATERAL group_adjacent_sleep_periods(pd.patient_id, pd.entry_date) sessions
)
SELECT
    patient_id,
    sleep_date,
    COUNT(*) as num_sessions,
    SUM(total_duration_minutes) as total_time_in_bed_minutes,
    SUM(sleep_duration_minutes) as total_sleep_minutes,
    SUM(core_sleep_minutes) as total_core_minutes,
    SUM(deep_sleep_minutes) as total_deep_minutes,
    SUM(rem_sleep_minutes) as total_rem_minutes,
    SUM(unspecified_sleep_minutes) as total_unspecified_minutes,
    SUM(awake_duration_minutes) as total_awake_minutes,
    SUM(in_bed_duration_minutes) as total_in_bed_minutes
FROM sessions
GROUP BY patient_id, sleep_date;

-- =====================================================
-- 3. Consolidate ALL OUTPUT fields using smart grouping
-- =====================================================

-- Delete all existing OUTPUT sleep fields
DELETE FROM patient_data_entries
WHERE field_id IN (
    'OUTPUT_TIME_IN_BED',
    'OUTPUT_SLEEP_DURATION',
    'OUTPUT_CORE_SLEEP_DURATION',
    'OUTPUT_DEEP_SLEEP_DURATION',
    'OUTPUT_REM_SLEEP_DURATION',
    'OUTPUT_UNSPECIFIED_SLEEP_DURATION',
    'OUTPUT_AWAKE_PERIODS_DURATION',
    'OUTPUT_IN_BED_DURATION'
);

-- Insert consolidated session-level OUTPUT fields
WITH all_sessions AS (
    SELECT DISTINCT
        pd.patient_id,
        pd.entry_date,
        sessions.*
    FROM patient_data_entries pd
    CROSS JOIN LATERAL group_adjacent_sleep_periods(pd.patient_id, pd.entry_date) sessions
    WHERE pd.field_id = 'DEF_SLEEP_PERIOD_START'
)
INSERT INTO patient_data_entries (
    patient_id,
    field_id,
    entry_date,
    value_quantity,
    event_instance_id,
    source
)
SELECT patient_id, 'OUTPUT_TIME_IN_BED', sleep_date, total_duration_minutes, session_id, 'auto_calculated'
FROM all_sessions
UNION ALL
SELECT patient_id, 'OUTPUT_SLEEP_DURATION', sleep_date, sleep_duration_minutes, session_id, 'auto_calculated'
FROM all_sessions
UNION ALL
SELECT patient_id, 'OUTPUT_CORE_SLEEP_DURATION', sleep_date, core_sleep_minutes, session_id, 'auto_calculated'
FROM all_sessions
WHERE core_sleep_minutes > 0
UNION ALL
SELECT patient_id, 'OUTPUT_DEEP_SLEEP_DURATION', sleep_date, deep_sleep_minutes, session_id, 'auto_calculated'
FROM all_sessions
WHERE deep_sleep_minutes > 0
UNION ALL
SELECT patient_id, 'OUTPUT_REM_SLEEP_DURATION', sleep_date, rem_sleep_minutes, session_id, 'auto_calculated'
FROM all_sessions
WHERE rem_sleep_minutes > 0
UNION ALL
SELECT patient_id, 'OUTPUT_UNSPECIFIED_SLEEP_DURATION', sleep_date, unspecified_sleep_minutes, session_id, 'auto_calculated'
FROM all_sessions
WHERE unspecified_sleep_minutes > 0
UNION ALL
SELECT patient_id, 'OUTPUT_AWAKE_PERIODS_DURATION', sleep_date, awake_duration_minutes, session_id, 'auto_calculated'
FROM all_sessions
WHERE awake_duration_minutes > 0
UNION ALL
SELECT patient_id, 'OUTPUT_IN_BED_DURATION', sleep_date, in_bed_duration_minutes, session_id, 'auto_calculated'
FROM all_sessions
WHERE in_bed_duration_minutes > 0;

COMMIT;

-- =====================================================
-- Verification
-- =====================================================

-- Show consolidated sleep metrics by date
SELECT
    sleep_date,
    num_sessions,
    ROUND(total_time_in_bed_minutes::numeric, 1) as time_in_bed_min,
    ROUND(total_sleep_minutes::numeric, 1) as sleep_min,
    ROUND(total_core_minutes::numeric, 1) as core_min,
    ROUND(total_deep_minutes::numeric, 1) as deep_min,
    ROUND(total_rem_minutes::numeric, 1) as rem_min,
    ROUND(total_awake_minutes::numeric, 1) as awake_min,
    ROUND(total_in_bed_minutes::numeric, 1) as in_bed_min
FROM v_daily_time_in_bed
WHERE patient_id = '8b79ce33-02b8-4f49-8268-3204130efa82'
ORDER BY sleep_date DESC
LIMIT 10;
