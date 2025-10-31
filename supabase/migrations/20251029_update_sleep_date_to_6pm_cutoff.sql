-- =====================================================
-- Update Sleep Date Assignment to 6 PM Cutoff Logic
-- =====================================================
-- Changes sleep date assignment from "wake date - 1" to
-- "6 PM cutoff on wake day":
--
-- Any sleep ending between 6 PM Monday and 6 PM Tuesday
-- is assigned to Tuesday (wake day).
--
-- Formula: sleep_date = DATE(wake_time + INTERVAL '6 hours')
--
-- Examples:
-- - Ends 7 AM Aug 29 + 6h = 1 PM Aug 29 → DATE = Aug 29
-- - Ends 3 PM Aug 29 + 6h = 9 PM Aug 29 → DATE = Aug 29
-- - Ends 8 PM Aug 29 + 6h = 2 AM Aug 30 → DATE = Aug 30
--
-- This matches Apple Health behavior and ensures data
-- appears at the start of the user's day.
--
-- Created: 2025-10-29
-- =====================================================

BEGIN;

-- =====================================================
-- 1. Update calculate_sleep_date function
-- =====================================================

CREATE OR REPLACE FUNCTION calculate_sleep_date(p_event_instance_id uuid)
RETURNS date AS $$
DECLARE
    wake_time timestamp;
    sleep_date date;
BEGIN
    -- Get the wake time (END of sleep period)
    SELECT value_timestamp INTO wake_time
    FROM patient_data_entries
    WHERE event_instance_id = p_event_instance_id
      AND field_id = 'DEF_SLEEP_PERIOD_END'
    ORDER BY value_timestamp DESC
    LIMIT 1;

    IF wake_time IS NULL THEN
        -- Fallback to entry_date if no wake time found
        SELECT MIN(entry_date) INTO sleep_date
        FROM patient_data_entries
        WHERE event_instance_id = p_event_instance_id;

        RETURN sleep_date;
    END IF;

    -- Sleep date = DATE(wake_time + 6 hours)
    -- This assigns sleep to the wake day with 6 PM cutoff
    -- Any sleep ending between 6 PM Monday and 6 PM Tuesday → Tuesday
    sleep_date := DATE(wake_time + INTERVAL '6 hours');

    RETURN sleep_date;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 2. Update group_adjacent_sleep_periods function
-- =====================================================
-- This function groups adjacent sleep periods and needs to use
-- the same 6 PM cutoff logic for consistency

-- Drop view first (depends on function)
DROP VIEW IF EXISTS v_daily_time_in_bed;

-- Now drop function
DROP FUNCTION IF EXISTS group_adjacent_sleep_periods(uuid, date);

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
    -- Use 6 PM cutoff logic for sleep date
    DATE(MAX(end_time) + INTERVAL '6 hours') as sleep_date,
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
GROUP BY session_number
ORDER BY session_start;
$$
LANGUAGE sql;

-- =====================================================
-- 3. Recreate the v_daily_time_in_bed view
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
-- 4. Update all OUTPUT field entry_dates with new logic
-- =====================================================

-- Update OUTPUT_SLEEP_DURATION
UPDATE patient_data_entries
SET entry_date = calculate_sleep_date(event_instance_id)
WHERE field_id = 'OUTPUT_SLEEP_DURATION'
  AND event_instance_id IS NOT NULL;

-- Update OUTPUT_TIME_IN_BED
UPDATE patient_data_entries
SET entry_date = calculate_sleep_date(event_instance_id)
WHERE field_id = 'OUTPUT_TIME_IN_BED'
  AND event_instance_id IS NOT NULL;

-- Update OUTPUT_CORE_SLEEP_DURATION
UPDATE patient_data_entries
SET entry_date = calculate_sleep_date(event_instance_id)
WHERE field_id = 'OUTPUT_CORE_SLEEP_DURATION'
  AND event_instance_id IS NOT NULL;

-- Update OUTPUT_DEEP_SLEEP_DURATION
UPDATE patient_data_entries
SET entry_date = calculate_sleep_date(event_instance_id)
WHERE field_id = 'OUTPUT_DEEP_SLEEP_DURATION'
  AND event_instance_id IS NOT NULL;

-- Update OUTPUT_REM_SLEEP_DURATION
UPDATE patient_data_entries
SET entry_date = calculate_sleep_date(event_instance_id)
WHERE field_id = 'OUTPUT_REM_SLEEP_DURATION'
  AND event_instance_id IS NOT NULL;

-- Update OUTPUT_AWAKE_PERIODS_DURATION
UPDATE patient_data_entries
SET entry_date = calculate_sleep_date(event_instance_id)
WHERE field_id = 'OUTPUT_AWAKE_PERIODS_DURATION'
  AND event_instance_id IS NOT NULL;

-- Update OUTPUT_IN_BED_DURATION
UPDATE patient_data_entries
SET entry_date = calculate_sleep_date(event_instance_id)
WHERE field_id = 'OUTPUT_IN_BED_DURATION'
  AND event_instance_id IS NOT NULL;

-- Update OUTPUT_UNSPECIFIED_SLEEP_DURATION
UPDATE patient_data_entries
SET entry_date = calculate_sleep_date(event_instance_id)
WHERE field_id = 'OUTPUT_UNSPECIFIED_SLEEP_DURATION'
  AND event_instance_id IS NOT NULL;

COMMIT;

-- =====================================================
-- Verification
-- =====================================================

-- Show sleep dates with 6 PM cutoff logic
WITH sleep_events AS (
    SELECT DISTINCT
        pde.event_instance_id,
        pde.patient_id,
        pde.entry_date as assigned_sleep_date,
        start_entry.value_timestamp as sleep_start,
        end_entry.value_timestamp as wake_time,
        DATE(end_entry.value_timestamp + INTERVAL '6 hours') as expected_sleep_date,
        ROUND((duration.value_quantity / 60.0)::numeric, 1) as duration_hours,
        is_nap_sleep_event(pde.event_instance_id) as is_nap
    FROM patient_data_entries pde
    LEFT JOIN patient_data_entries start_entry
        ON start_entry.event_instance_id = pde.event_instance_id
        AND start_entry.field_id = 'DEF_SLEEP_PERIOD_START'
    LEFT JOIN patient_data_entries end_entry
        ON end_entry.event_instance_id = pde.event_instance_id
        AND end_entry.field_id = 'DEF_SLEEP_PERIOD_END'
    LEFT JOIN patient_data_entries duration
        ON duration.event_instance_id = pde.event_instance_id
        AND duration.field_id = 'OUTPUT_SLEEP_DURATION'
    WHERE pde.field_id = 'OUTPUT_SLEEP_DURATION'
      AND pde.event_instance_id IS NOT NULL
      AND pde.patient_id = '8b79ce33-02b8-4f49-8268-3204130efa82'
)
SELECT
    assigned_sleep_date,
    expected_sleep_date,
    TO_CHAR(sleep_start, 'Mon DD HH24:MI') as sleep_time,
    TO_CHAR(wake_time, 'Mon DD HH24:MI') as wake_time,
    duration_hours,
    is_nap,
    CASE WHEN is_nap THEN 'Nap' ELSE 'Main Sleep' END as sleep_type,
    CASE WHEN assigned_sleep_date = expected_sleep_date
         THEN '✅ Correct'
         ELSE '❌ MISMATCH'
    END as status
FROM sleep_events
ORDER BY assigned_sleep_date DESC, sleep_start DESC
LIMIT 10;
