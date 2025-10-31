-- =====================================================
-- Add Sleep Date Assignment Logic
-- =====================================================
-- Assigns the correct "sleep date" for each sleep event based on:
-- 1. Wake time - 1 day (for main sleep sessions)
-- 2. Same logic for naps (matching Apple Health behavior)
--
-- Nap Detection:
-- - Sleep duration < 4 hours, OR
-- - Wake time falls on same calendar day as another later wake time
--
-- Created: 2025-10-29
-- =====================================================

BEGIN;

-- =====================================================
-- 1. Create function to calculate sleep date for an event
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

    -- Sleep date = wake date - 1 day
    -- This applies to both main sleep and naps (matching Apple Health)
    sleep_date := (wake_time AT TIME ZONE 'UTC')::date - INTERVAL '1 day';

    RETURN sleep_date;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 2. Create function to detect if a sleep event is a nap
-- =====================================================

CREATE OR REPLACE FUNCTION is_nap_sleep_event(p_event_instance_id uuid)
RETURNS boolean AS $$
DECLARE
    total_duration_minutes numeric;
    wake_time timestamp;
    patient_id_val uuid;
    wake_date date;
    later_wake_exists boolean;
BEGIN
    -- Get total sleep duration for this event
    SELECT value_quantity INTO total_duration_minutes
    FROM patient_data_entries
    WHERE event_instance_id = p_event_instance_id
      AND field_id = 'OUTPUT_SLEEP_DURATION'
    LIMIT 1;

    -- Nap criterion 1: Duration < 4 hours (240 minutes)
    IF total_duration_minutes IS NOT NULL AND total_duration_minutes < 240 THEN
        RETURN true;
    END IF;

    -- Get wake time and patient_id for criterion 2
    SELECT value_timestamp, patient_id
    INTO wake_time, patient_id_val
    FROM patient_data_entries
    WHERE event_instance_id = p_event_instance_id
      AND field_id = 'DEF_SLEEP_PERIOD_END'
    LIMIT 1;

    IF wake_time IS NULL THEN
        RETURN false;
    END IF;

    wake_date := (wake_time AT TIME ZONE 'UTC')::date;

    -- Nap criterion 2: Another wake time exists on the same day that is later
    SELECT EXISTS(
        SELECT 1
        FROM patient_data_entries pde
        WHERE pde.field_id = 'DEF_SLEEP_PERIOD_END'
          AND pde.patient_id = patient_id_val
          AND pde.event_instance_id != p_event_instance_id
          AND (pde.value_timestamp AT TIME ZONE 'UTC')::date = wake_date
          AND pde.value_timestamp > wake_time
    ) INTO later_wake_exists;

    RETURN later_wake_exists;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 3. Update all OUTPUT field entry_dates with correct sleep date
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

-- Show sleep dates before and after
WITH sleep_events AS (
    SELECT DISTINCT
        pde.event_instance_id,
        pde.patient_id,
        pde.entry_date as output_sleep_date,
        start_entry.value_timestamp as sleep_start,
        end_entry.value_timestamp as wake_time,
        (end_entry.value_timestamp AT TIME ZONE 'UTC')::date as wake_date,
        (end_entry.value_timestamp AT TIME ZONE 'UTC')::date - INTERVAL '1 day' as calculated_sleep_date,
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
)
SELECT
    output_sleep_date,
    TO_CHAR(sleep_start, 'HH24:MI') as sleep_time,
    TO_CHAR(wake_time, 'HH24:MI') as wake_time,
    wake_date,
    duration_hours,
    is_nap,
    CASE WHEN is_nap THEN 'Nap' ELSE 'Main Sleep' END as sleep_type
FROM sleep_events
ORDER BY output_sleep_date DESC, sleep_start DESC
LIMIT 10;
