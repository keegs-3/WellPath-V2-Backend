-- =====================================================
-- Fix Hourly Aggregation to Match Local Time Hours
-- =====================================================
-- Problem: Hourly aggregations use UTC hour boundaries (e.g., hour 18 = 6PM UTC),
--          but entries have entry_timestamp in UTC and entry_date in local calendar date.
--          Entry logged at 6PM local (PST) has UTC timestamp of 1AM next day,
--          so it doesn't match the UTC hour 18 boundary.
--
-- Solution: For hourly aggregations, filter by entry_date (local calendar date)
--           and infer local hour from each entry by calculating timezone offset.
--           Local hour = UTC hour + timezone_offset_hours
--           where timezone_offset = (entry_date - DATE(entry_timestamp AT TIME ZONE 'UTC')) * 24
-- =====================================================

BEGIN;

-- Update calculate_field_aggregation to handle hourly with local time matching
-- This replaces ONLY the hourly logic in the existing function
CREATE OR REPLACE FUNCTION public.calculate_field_aggregation(
  p_patient_id uuid,
  p_field_id text,
  p_period_start timestamp with time zone,
  p_period_end timestamp with time zone,
  p_calculation_type text,
  p_period_type text DEFAULT 'hourly',
  p_filter_conditions jsonb DEFAULT NULL::jsonb
)
RETURNS numeric
LANGUAGE plpgsql
AS $function$
DECLARE
  v_result NUMERIC;
  v_ref_field TEXT;
  v_ref_value TEXT;
  v_no_match BOOLEAN;
  v_ref_category TEXT;
  v_sql TEXT;
  v_entry_date DATE;
  v_target_hour INTEGER;
BEGIN
  -- Extract filter conditions if present
  IF p_filter_conditions IS NOT NULL THEN
    v_ref_field := p_filter_conditions->>'reference_field';
    v_ref_value := p_filter_conditions->>'reference_value';
    v_no_match := COALESCE((p_filter_conditions->>'no_match')::boolean, false);
    v_ref_category := LOWER(REPLACE(REPLACE(v_ref_field, 'DEF_', ''), '_', '_'));
  END IF;

  -- Extract target hour and entry date
  IF p_period_type = 'hourly' THEN
    v_entry_date := (p_period_start AT TIME ZONE 'UTC')::DATE;
    -- Extract UTC hour from period_start (this represents the LOCAL hour we want, not UTC)
    -- The edge function passes hour 18 meaning 6PM local, but get_period_start creates 6PM UTC
    -- So we extract the hour from period_start as the target local hour
    v_target_hour := EXTRACT(HOUR FROM p_period_start AT TIME ZONE 'UTC')::INTEGER;
  ELSE
    -- For non-hourly periods, extract the date from period_start
    v_entry_date := (p_period_start AT TIME ZONE 'UTC')::DATE;
  END IF;

  CASE p_calculation_type
    WHEN 'AVG' THEN
      IF p_filter_conditions IS NOT NULL THEN
        IF v_no_match THEN
          -- Find entries WITHOUT a matching reference entry
          IF p_period_type = 'hourly' THEN
            -- Hourly: Filter by entry_date and match local hour
            EXECUTE format('
              SELECT COALESCE(AVG(pde.value_quantity), 0)
              FROM patient_data_entries pde
              LEFT JOIN patient_data_entries pde_ref
                ON pde.patient_id = pde_ref.patient_id
                AND (
                  (pde.event_instance_id IS NOT NULL AND pde.event_instance_id = pde_ref.event_instance_id)
                  OR (pde.event_instance_id IS NULL AND pde.entry_timestamp = pde_ref.entry_timestamp)
                )
                AND pde_ref.field_id = $5
              WHERE pde.patient_id = $1
                AND pde.field_id = $2
                AND pde.entry_date = $3
                AND (
                  CASE
                  WHEN p.timezone IS NOT NULL THEN
                    EXTRACT(HOUR FROM pde.entry_timestamp AT TIME ZONE p.timezone)::INTEGER
                  ELSE
                    MOD(
                      EXTRACT(HOUR FROM pde.entry_timestamp)::INTEGER + 
                      CASE 
                        WHEN pde.entry_date = DATE(pde.entry_timestamp AT TIME ZONE ''UTC'') THEN 0
                        WHEN pde.entry_date < DATE(pde.entry_timestamp AT TIME ZONE ''UTC'') THEN -7
                        ELSE +7
                      END + 24,
                      24
                    )
                END = $4
                AND pde.source != ''deleted''
                AND pde_ref.id IS NULL
            ')
            INTO v_result
            USING p_patient_id, p_field_id, v_entry_date, v_target_hour, v_ref_field;
          ELSE
            -- Daily+: use entry_date filtering (unchanged)
            EXECUTE format('
              SELECT COALESCE(AVG(pde.value_quantity), 0)
              FROM patient_data_entries pde
              LEFT JOIN patient_data_entries pde_ref
                ON pde.patient_id = pde_ref.patient_id
                AND (
                  (pde.event_instance_id IS NOT NULL AND pde.event_instance_id = pde_ref.event_instance_id)
                  OR (pde.event_instance_id IS NULL AND pde.entry_timestamp = pde_ref.entry_timestamp)
                )
                AND pde_ref.field_id = $5
              WHERE pde.patient_id = $1
                AND pde.field_id = $2
                AND pde.entry_date >= $3
                AND pde.entry_date < $4
                AND pde.source != ''deleted''
                AND pde_ref.id IS NULL
            ')
            INTO v_result
            USING p_patient_id, p_field_id, v_entry_date, (p_period_end AT TIME ZONE 'UTC')::DATE, v_ref_field;
          END IF;
        ELSE
          -- Original logic: find entries WITH matching reference
          IF p_period_type = 'hourly' THEN
            -- Hourly: Filter by entry_date and match local hour
            EXECUTE format('
              SELECT COALESCE(AVG(pde.value_quantity), 0)
              FROM patient_data_entries pde
              INNER JOIN patient_data_entries pde_ref
                ON pde.patient_id = pde_ref.patient_id
                AND (
                  (pde.event_instance_id IS NOT NULL AND pde.event_instance_id = pde_ref.event_instance_id)
                  OR (pde.event_instance_id IS NULL AND pde.entry_timestamp = pde_ref.entry_timestamp)
                )
              INNER JOIN data_entry_fields_reference ref
                ON pde_ref.value_reference::uuid = ref.id
              WHERE pde.patient_id = $1
                AND pde.field_id = $2
                AND pde.entry_date = $3
                AND (
                  CASE
                  WHEN p.timezone IS NOT NULL THEN
                    EXTRACT(HOUR FROM pde.entry_timestamp AT TIME ZONE p.timezone)::INTEGER
                  ELSE
                    MOD(
                      EXTRACT(HOUR FROM pde.entry_timestamp)::INTEGER + 
                      CASE 
                        WHEN pde.entry_date = DATE(pde.entry_timestamp AT TIME ZONE ''UTC'') THEN 0
                        WHEN pde.entry_date < DATE(pde.entry_timestamp AT TIME ZONE ''UTC'') THEN -7
                        ELSE +7
                      END + 24,
                      24
                    )
                END = $4
                AND pde.source != ''deleted''
                AND pde_ref.field_id = $5
                AND ref.reference_key = $6
            ')
            INTO v_result
            USING p_patient_id, p_field_id, v_entry_date, v_target_hour, v_ref_field, v_ref_value;
          ELSE
            -- Daily+: use entry_date filtering (unchanged)
            EXECUTE format('
              SELECT COALESCE(AVG(pde.value_quantity), 0)
              FROM patient_data_entries pde
              INNER JOIN patient_data_entries pde_ref
                ON pde.patient_id = pde_ref.patient_id
                AND (
                  (pde.event_instance_id IS NOT NULL AND pde.event_instance_id = pde_ref.event_instance_id)
                  OR (pde.event_instance_id IS NULL AND pde.entry_timestamp = pde_ref.entry_timestamp)
                )
              INNER JOIN data_entry_fields_reference ref
                ON pde_ref.value_reference::uuid = ref.id
              WHERE pde.patient_id = $1
                AND pde.field_id = $2
                AND pde.entry_date >= $3
                AND pde.entry_date < $4
                AND pde.source != ''deleted''
                AND pde_ref.field_id = $5
                AND ref.reference_key = $6
            ')
            INTO v_result
            USING p_patient_id, p_field_id, v_entry_date, (p_period_end AT TIME ZONE 'UTC')::DATE, v_ref_field, v_ref_value;
          END IF;
        END IF;
      ELSE
        -- No filter conditions
        IF p_period_type = 'hourly' THEN
          -- Hourly: Filter by entry_date and match local hour
          -- Use patient timezone if available, otherwise infer from entry_date vs UTC date
          SELECT COALESCE(AVG(pde.value_quantity), 0)
          INTO v_result
          FROM patient_data_entries pde
          LEFT JOIN patients p ON p.patient_id = pde.patient_id
          WHERE pde.patient_id = p_patient_id
            AND pde.field_id = p_field_id
            AND pde.entry_date = v_entry_date
            AND (
              -- If patient has timezone stored, use it directly (most accurate)
              -- Otherwise, calculate timezone offset from entry_date vs UTC date
              CASE
                WHEN p.timezone IS NOT NULL THEN
                  EXTRACT(HOUR FROM pde.entry_timestamp AT TIME ZONE p.timezone)::INTEGER = v_target_hour
                ELSE
                  -- Fallback: Calculate timezone offset from entry_date vs UTC date relationship
                  -- Since we don't have stored timezone, infer it from the data
                  -- Calculate approximate offset: if entry_date is 1 day before UTC date,
                  -- the timezone is likely west of UTC (US timezones typically -5 to -10)
                  -- For US timezones: EST=-5, CST=-6, MST=-7, PST=-8, plus DST adjustments
                  -- Since entry_date represents local calendar date, and entry_timestamp is UTC,
                  -- we can calculate the hour that would match local midnight of entry_date
                  -- 
                  -- Simplest approach: Calculate local hour by assuming common US timezone offsets
                  -- and testing which one makes entry_date align correctly
                  -- Actually, better: Use a subquery to calculate actual offset from sample entries
                  -- But for performance, use a heuristic based on day difference
                  -- 
                  -- For day_diff = -1: likely offset between -5 and -10 (US timezones)
                  -- For day_diff = 0: likely offset between -12 and +12 (most common)
                  -- For day_diff = +1: likely offset between +10 and +15 (rare, east of UTC)
                  (
                    EXTRACT(HOUR FROM pde.entry_timestamp)::INTEGER + 
                    CASE 
                      WHEN pde.entry_date = DATE(pde.entry_timestamp AT TIME ZONE 'UTC') THEN 0
                      WHEN pde.entry_date < DATE(pde.entry_timestamp AT TIME ZONE 'UTC') THEN
                        -- West of UTC: offset is negative
                        -- For US: EST=-5, CST=-6, MST=-7, PST=-8 (or -4/-5/-6/-7 with DST)
                        -- Use -7 as approximation (middle of US timezone range, accounts for DST)
                        -- This will work for most US users; ideally patients.timezone should be populated
                        -7
                      ELSE
                        -- East of UTC: offset is positive (rare for US users)
                        +7
                    END + 24
                  ) % 24 = v_target_hour
              END
            )
            AND pde.source != 'deleted';
        ELSE
          -- Daily+ logic (existing, unchanged)
          SELECT COALESCE(AVG(value_quantity), 0)
          INTO v_result
          FROM patient_data_entries
          WHERE patient_id = p_patient_id
            AND field_id = p_field_id
            AND entry_date >= v_entry_date
            AND entry_date < (p_period_end AT TIME ZONE 'UTC')::DATE
            AND source != 'deleted';
        END IF;
      END IF;

    WHEN 'SUM' THEN
      IF p_filter_conditions IS NOT NULL THEN
        IF v_no_match THEN
          -- Find entries WITHOUT a matching reference entry
          IF p_period_type = 'hourly' THEN
            EXECUTE format('
              SELECT COALESCE(SUM(pde.value_quantity), 0)
              FROM patient_data_entries pde
              LEFT JOIN patient_data_entries pde_ref
                ON pde.patient_id = pde_ref.patient_id
                AND (
                  (pde.event_instance_id IS NOT NULL AND pde.event_instance_id = pde_ref.event_instance_id)
                  OR (pde.event_instance_id IS NULL AND pde.entry_timestamp = pde_ref.entry_timestamp)
                )
                AND pde_ref.field_id = $5
              WHERE pde.patient_id = $1
                AND pde.field_id = $2
                AND pde.entry_date = $3
                AND (
                  CASE
                  WHEN p.timezone IS NOT NULL THEN
                    EXTRACT(HOUR FROM pde.entry_timestamp AT TIME ZONE p.timezone)::INTEGER
                  ELSE
                    MOD(
                      EXTRACT(HOUR FROM pde.entry_timestamp)::INTEGER + 
                      CASE 
                        WHEN pde.entry_date = DATE(pde.entry_timestamp AT TIME ZONE ''UTC'') THEN 0
                        WHEN pde.entry_date < DATE(pde.entry_timestamp AT TIME ZONE ''UTC'') THEN -7
                        ELSE +7
                      END + 24,
                      24
                    )
                END = $4
                AND pde.source != ''deleted''
                AND pde_ref.id IS NULL
            ')
            INTO v_result
            USING p_patient_id, p_field_id, v_entry_date, v_target_hour, v_ref_field;
          ELSE
            EXECUTE format('
              SELECT COALESCE(SUM(pde.value_quantity), 0)
              FROM patient_data_entries pde
              LEFT JOIN patient_data_entries pde_ref
                ON pde.patient_id = pde_ref.patient_id
                AND (
                  (pde.event_instance_id IS NOT NULL AND pde.event_instance_id = pde_ref.event_instance_id)
                  OR (pde.event_instance_id IS NULL AND pde.entry_timestamp = pde_ref.entry_timestamp)
                )
                AND pde_ref.field_id = $5
              WHERE pde.patient_id = $1
                AND pde.field_id = $2
                AND pde.entry_date >= $3
                AND pde.entry_date < $4
                AND pde.source != ''deleted''
                AND pde_ref.id IS NULL
            ')
            INTO v_result
            USING p_patient_id, p_field_id, v_entry_date, (p_period_end AT TIME ZONE 'UTC')::DATE, v_ref_field;
          END IF;
        ELSE
          -- Original logic: find entries WITH matching reference
          IF p_period_type = 'hourly' THEN
            EXECUTE format('
              SELECT COALESCE(SUM(pde.value_quantity), 0)
              FROM patient_data_entries pde
              INNER JOIN patient_data_entries pde_ref
                ON pde.patient_id = pde_ref.patient_id
                AND (
                  (pde.event_instance_id IS NOT NULL AND pde.event_instance_id = pde_ref.event_instance_id)
                  OR (pde.event_instance_id IS NULL AND pde.entry_timestamp = pde_ref.entry_timestamp)
                )
              INNER JOIN data_entry_fields_reference ref
                ON pde_ref.value_reference::uuid = ref.id
              WHERE pde.patient_id = $1
                AND pde.field_id = $2
                AND pde.entry_date = $3
                AND (
                  CASE
                  WHEN p.timezone IS NOT NULL THEN
                    EXTRACT(HOUR FROM pde.entry_timestamp AT TIME ZONE p.timezone)::INTEGER
                  ELSE
                    MOD(
                      EXTRACT(HOUR FROM pde.entry_timestamp)::INTEGER + 
                      CASE 
                        WHEN pde.entry_date = DATE(pde.entry_timestamp AT TIME ZONE ''UTC'') THEN 0
                        WHEN pde.entry_date < DATE(pde.entry_timestamp AT TIME ZONE ''UTC'') THEN -7
                        ELSE +7
                      END + 24,
                      24
                    )
                END = $4
                AND pde.source != ''deleted''
                AND pde_ref.field_id = $5
                AND ref.reference_key = $6
            ')
            INTO v_result
            USING p_patient_id, p_field_id, v_entry_date, v_target_hour, v_ref_field, v_ref_value;
          ELSE
            EXECUTE format('
              SELECT COALESCE(SUM(pde.value_quantity), 0)
              FROM patient_data_entries pde
              INNER JOIN patient_data_entries pde_ref
                ON pde.patient_id = pde_ref.patient_id
                AND (
                  (pde.event_instance_id IS NOT NULL AND pde.event_instance_id = pde_ref.event_instance_id)
                  OR (pde.event_instance_id IS NULL AND pde.entry_timestamp = pde_ref.entry_timestamp)
                )
              INNER JOIN data_entry_fields_reference ref
                ON pde_ref.value_reference::uuid = ref.id
              WHERE pde.patient_id = $1
                AND pde.field_id = $2
                AND pde.entry_date >= $3
                AND pde.entry_date < $4
                AND pde.source != ''deleted''
                AND pde_ref.field_id = $5
                AND ref.reference_key = $6
            ')
            INTO v_result
            USING p_patient_id, p_field_id, v_entry_date, (p_period_end AT TIME ZONE 'UTC')::DATE, v_ref_field, v_ref_value;
          END IF;
        END IF;
      ELSE
        -- No filter conditions
        IF p_period_type = 'hourly' THEN
          SELECT COALESCE(SUM(value_quantity), 0)
          INTO v_result
          FROM patient_data_entries
          WHERE patient_id = p_patient_id
            AND field_id = p_field_id
            AND entry_date = v_entry_date
            AND (
              EXTRACT(HOUR FROM entry_timestamp)::INTEGER + 
              (entry_date::date - DATE(entry_timestamp AT TIME ZONE 'UTC')::date)::INTEGER * 24
            + 24) % 24 = v_target_hour
            AND source != 'deleted';
        ELSE
          SELECT COALESCE(SUM(value_quantity), 0)
          INTO v_result
          FROM patient_data_entries
          WHERE patient_id = p_patient_id
            AND field_id = p_field_id
            AND entry_date >= v_entry_date
            AND entry_date < (p_period_end AT TIME ZONE 'UTC')::DATE
            AND source != 'deleted';
        END IF;
      END IF;

    WHEN 'MAX' THEN
      IF p_period_type = 'hourly' THEN
        SELECT COALESCE(MAX(pde.value_quantity), 0)
        INTO v_result
        FROM patient_data_entries pde
        LEFT JOIN patients p ON p.patient_id = pde.patient_id
        WHERE pde.patient_id = p_patient_id
          AND pde.field_id = p_field_id
          AND pde.entry_date = v_entry_date
          AND (
            CASE
              WHEN p.timezone IS NOT NULL THEN
                EXTRACT(HOUR FROM pde.entry_timestamp AT TIME ZONE p.timezone)::INTEGER
              ELSE
                MOD(
                  EXTRACT(HOUR FROM pde.entry_timestamp)::INTEGER + 
                  CASE 
                    WHEN pde.entry_date = DATE(pde.entry_timestamp AT TIME ZONE 'UTC') THEN 0
                    WHEN pde.entry_date < DATE(pde.entry_timestamp AT TIME ZONE 'UTC') THEN -7
                    ELSE +7
                  END + 24,
                  24
                )
            END = v_target_hour
          )
          AND pde.source != 'deleted';
      ELSE
        SELECT COALESCE(MAX(value_quantity), 0)
        INTO v_result
        FROM patient_data_entries
        WHERE patient_id = p_patient_id
          AND field_id = p_field_id
          AND entry_date >= v_entry_date
          AND entry_date < (p_period_end AT TIME ZONE 'UTC')::DATE
          AND source != 'deleted';
      END IF;

    WHEN 'MIN' THEN
      IF p_period_type = 'hourly' THEN
        SELECT COALESCE(MIN(pde.value_quantity), 0)
        INTO v_result
        FROM patient_data_entries pde
        LEFT JOIN patients p ON p.patient_id = pde.patient_id
        WHERE pde.patient_id = p_patient_id
          AND pde.field_id = p_field_id
          AND pde.entry_date = v_entry_date
          AND (
            CASE
              WHEN p.timezone IS NOT NULL THEN
                EXTRACT(HOUR FROM pde.entry_timestamp AT TIME ZONE p.timezone)::INTEGER
              ELSE
                MOD(
                  EXTRACT(HOUR FROM pde.entry_timestamp)::INTEGER + 
                  CASE 
                    WHEN pde.entry_date = DATE(pde.entry_timestamp AT TIME ZONE 'UTC') THEN 0
                    WHEN pde.entry_date < DATE(pde.entry_timestamp AT TIME ZONE 'UTC') THEN -7
                    ELSE +7
                  END + 24,
                  24
                )
            END = v_target_hour
          )
          AND pde.source != 'deleted';
      ELSE
        SELECT COALESCE(MIN(value_quantity), 0)
        INTO v_result
        FROM patient_data_entries
        WHERE patient_id = p_patient_id
          AND field_id = p_field_id
          AND entry_date >= v_entry_date
          AND entry_date < (p_period_end AT TIME ZONE 'UTC')::DATE
          AND source != 'deleted';
      END IF;

    WHEN 'COUNT' THEN
      IF p_period_type = 'hourly' THEN
        SELECT COALESCE(COUNT(*), 0)
        INTO v_result
        FROM patient_data_entries pde
        LEFT JOIN patients p ON p.patient_id = pde.patient_id
        WHERE pde.patient_id = p_patient_id
          AND pde.field_id = p_field_id
          AND pde.entry_date = v_entry_date
          AND (
            CASE
              WHEN p.timezone IS NOT NULL THEN
                EXTRACT(HOUR FROM pde.entry_timestamp AT TIME ZONE p.timezone)::INTEGER
              ELSE
                MOD(
                  EXTRACT(HOUR FROM pde.entry_timestamp)::INTEGER + 
                  CASE 
                    WHEN pde.entry_date = DATE(pde.entry_timestamp AT TIME ZONE 'UTC') THEN 0
                    WHEN pde.entry_date < DATE(pde.entry_timestamp AT TIME ZONE 'UTC') THEN -7
                    ELSE +7
                  END + 24,
                  24
                )
            END = v_target_hour
          )
          AND pde.source != 'deleted';
      ELSE
        SELECT COALESCE(COUNT(*), 0)
        INTO v_result
        FROM patient_data_entries
        WHERE patient_id = p_patient_id
          AND field_id = p_field_id
          AND entry_date >= v_entry_date
          AND entry_date < (p_period_end AT TIME ZONE 'UTC')::DATE
          AND source != 'deleted';
      END IF;

    ELSE
      v_result := 0;
  END CASE;

  RETURN v_result;
END;
$function$;

COMMIT;

