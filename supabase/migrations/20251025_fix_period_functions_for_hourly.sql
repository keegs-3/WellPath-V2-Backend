-- =====================================================
-- Fix Period Helper Functions for Hourly Support
-- =====================================================
-- Changes return type from DATE to TIMESTAMPTZ
-- Properly handles hourly periods (24 hours per day)
-- =====================================================

BEGIN;

-- Drop old functions
DROP FUNCTION IF EXISTS get_period_start(DATE, TEXT);
DROP FUNCTION IF EXISTS get_period_end(DATE, TEXT);

-- =====================================================
-- Create New Period Functions with TIMESTAMPTZ
-- =====================================================
CREATE OR REPLACE FUNCTION get_period_start(p_date DATE, p_period_type TEXT, p_hour INTEGER DEFAULT 0)
RETURNS TIMESTAMP WITH TIME ZONE
LANGUAGE plpgsql
IMMUTABLE
AS $$
BEGIN
  CASE p_period_type
    WHEN 'hourly' THEN
      -- Return start of specific hour on the date
      RETURN (p_date::TIMESTAMP + (p_hour || ' hours')::INTERVAL) AT TIME ZONE 'UTC';
    WHEN 'daily' THEN
      RETURN p_date::TIMESTAMP AT TIME ZONE 'UTC';
    WHEN 'weekly' THEN
      RETURN DATE_TRUNC('week', p_date::TIMESTAMP) AT TIME ZONE 'UTC';
    WHEN 'monthly' THEN
      RETURN DATE_TRUNC('month', p_date::TIMESTAMP) AT TIME ZONE 'UTC';
    WHEN 'quarterly' THEN
      RETURN DATE_TRUNC('quarter', p_date::TIMESTAMP) AT TIME ZONE 'UTC';
    WHEN 'yearly' THEN
      RETURN DATE_TRUNC('year', p_date::TIMESTAMP) AT TIME ZONE 'UTC';
    WHEN '6month' THEN
      -- 6-month periods starting from the date
      RETURN p_date::TIMESTAMP AT TIME ZONE 'UTC';
    ELSE
      RETURN p_date::TIMESTAMP AT TIME ZONE 'UTC';
  END CASE;
END;
$$;

CREATE OR REPLACE FUNCTION get_period_end(p_date DATE, p_period_type TEXT, p_hour INTEGER DEFAULT 0)
RETURNS TIMESTAMP WITH TIME ZONE
LANGUAGE plpgsql
IMMUTABLE
AS $$
BEGIN
  CASE p_period_type
    WHEN 'hourly' THEN
      -- Return end of specific hour (start of next hour)
      RETURN (p_date::TIMESTAMP + ((p_hour + 1) || ' hours')::INTERVAL) AT TIME ZONE 'UTC';
    WHEN 'daily' THEN
      RETURN (p_date::TIMESTAMP + INTERVAL '1 day') AT TIME ZONE 'UTC';
    WHEN 'weekly' THEN
      RETURN (DATE_TRUNC('week', p_date::TIMESTAMP) + INTERVAL '1 week') AT TIME ZONE 'UTC';
    WHEN 'monthly' THEN
      RETURN (DATE_TRUNC('month', p_date::TIMESTAMP) + INTERVAL '1 month') AT TIME ZONE 'UTC';
    WHEN 'quarterly' THEN
      RETURN (DATE_TRUNC('quarter', p_date::TIMESTAMP) + INTERVAL '3 months') AT TIME ZONE 'UTC';
    WHEN 'yearly' THEN
      RETURN (DATE_TRUNC('year', p_date::TIMESTAMP) + INTERVAL '1 year') AT TIME ZONE 'UTC';
    WHEN '6month' THEN
      RETURN (p_date::TIMESTAMP + INTERVAL '6 months') AT TIME ZONE 'UTC';
    ELSE
      RETURN (p_date::TIMESTAMP + INTERVAL '1 day') AT TIME ZONE 'UTC';
  END CASE;
END;
$$;

-- =====================================================
-- Update process_single_aggregation to Handle Hourly
-- =====================================================
CREATE OR REPLACE FUNCTION public.process_single_aggregation(p_patient_id uuid, p_agg_metric_id text, p_entry_date date)
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_period RECORD;
  v_dep RECORD;
  v_calc_type RECORD;
  v_period_start TIMESTAMP WITH TIME ZONE;
  v_period_end TIMESTAMP WITH TIME ZONE;
  v_value NUMERIC;
  v_count INTEGER := 0;
  v_hour INTEGER;
BEGIN
  -- Get all periods for this aggregation metric
  FOR v_period IN
    SELECT period_id
    FROM aggregation_metrics_periods
    WHERE agg_metric_id = p_agg_metric_id
  LOOP
    -- Special handling for hourly periods
    IF v_period.period_id = 'hourly' THEN
      -- Process each hour (0-23)
      FOR v_hour IN 0..23 LOOP
        v_period_start := get_period_start(p_entry_date, v_period.period_id, v_hour);
        v_period_end := get_period_end(p_entry_date, v_period.period_id, v_hour);

        -- Get all data entry fields that feed this aggregation
        FOR v_dep IN
          SELECT data_entry_field_id
          FROM aggregation_metrics_dependencies
          WHERE agg_metric_id = p_agg_metric_id
            AND dependency_type = 'data_field'
        LOOP
          -- Get all calculation types for this aggregation
          FOR v_calc_type IN
            SELECT calculation_type_id
            FROM aggregation_metrics_calculation_types
            WHERE aggregation_metric_id = p_agg_metric_id
          LOOP
            -- Calculate the aggregated value
            v_value := calculate_field_aggregation(
              p_patient_id,
              v_dep.data_entry_field_id,
              v_period_start,
              v_period_end,
              v_calc_type.calculation_type_id
            );

            -- Only insert if there's data for this hour
            IF v_value IS NOT NULL AND v_value > 0 THEN
              INSERT INTO aggregation_results_cache (
                patient_id,
                agg_metric_id,
                period_type,
                period_start,
                period_end,
                calculation_type_id,
                value,
                last_computed_at
              ) VALUES (
                p_patient_id,
                p_agg_metric_id,
                v_period.period_id,
                v_period_start,
                v_period_end,
                v_calc_type.calculation_type_id,
                v_value,
                NOW()
              )
              ON CONFLICT (patient_id, agg_metric_id, period_type, calculation_type_id, period_start)
              DO UPDATE SET
                value = EXCLUDED.value,
                last_computed_at = EXCLUDED.last_computed_at;

              v_count := v_count + 1;
            END IF;
          END LOOP;
        END LOOP;
      END LOOP;
    ELSE
      -- Non-hourly periods: original logic
      v_period_start := get_period_start(p_entry_date, v_period.period_id);
      v_period_end := get_period_end(p_entry_date, v_period.period_id);

      FOR v_dep IN
        SELECT data_entry_field_id
        FROM aggregation_metrics_dependencies
        WHERE agg_metric_id = p_agg_metric_id
          AND dependency_type = 'data_field'
      LOOP
        FOR v_calc_type IN
          SELECT calculation_type_id
          FROM aggregation_metrics_calculation_types
          WHERE aggregation_metric_id = p_agg_metric_id
        LOOP
          v_value := calculate_field_aggregation(
            p_patient_id,
            v_dep.data_entry_field_id,
            v_period_start,
            v_period_end,
            v_calc_type.calculation_type_id
          );

          INSERT INTO aggregation_results_cache (
            patient_id,
            agg_metric_id,
            period_type,
            period_start,
            period_end,
            calculation_type_id,
            value,
            last_computed_at
          ) VALUES (
            p_patient_id,
            p_agg_metric_id,
            v_period.period_id,
            v_period_start,
            v_period_end,
            v_calc_type.calculation_type_id,
            v_value,
            NOW()
          )
          ON CONFLICT (patient_id, agg_metric_id, period_type, calculation_type_id, period_start)
          DO UPDATE SET
            value = EXCLUDED.value,
            last_computed_at = EXCLUDED.last_computed_at;

          v_count := v_count + 1;
        END LOOP;
      END LOOP;
    END IF;
  END LOOP;

  RETURN v_count;
END;
$function$;

-- =====================================================
-- Update calculate_field_aggregation Signature
-- =====================================================
DROP FUNCTION IF EXISTS calculate_field_aggregation(uuid, text, date, date, text);

CREATE OR REPLACE FUNCTION public.calculate_field_aggregation(
  p_patient_id uuid,
  p_field_id text,
  p_period_start timestamp with time zone,
  p_period_end timestamp with time zone,
  p_calculation_type text
)
 RETURNS numeric
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_result NUMERIC;
BEGIN
  CASE p_calculation_type
    WHEN 'AVG' THEN
      SELECT COALESCE(AVG(value_quantity), 0)
      INTO v_result
      FROM patient_data_entries
      WHERE patient_id = p_patient_id
        AND field_id = p_field_id
        AND entry_timestamp >= p_period_start
        AND entry_timestamp < p_period_end
        AND source != 'deleted';

    WHEN 'SUM' THEN
      SELECT COALESCE(SUM(value_quantity), 0)
      INTO v_result
      FROM patient_data_entries
      WHERE patient_id = p_patient_id
        AND field_id = p_field_id
        AND entry_timestamp >= p_period_start
        AND entry_timestamp < p_period_end
        AND source != 'deleted';

    WHEN 'MAX' THEN
      SELECT COALESCE(MAX(value_quantity), 0)
      INTO v_result
      FROM patient_data_entries
      WHERE patient_id = p_patient_id
        AND field_id = p_field_id
        AND entry_timestamp >= p_period_start
        AND entry_timestamp < p_period_end
        AND source != 'deleted';

    WHEN 'MIN' THEN
      SELECT COALESCE(MIN(value_quantity), 0)
      INTO v_result
      FROM patient_data_entries
      WHERE patient_id = p_patient_id
        AND field_id = p_field_id
        AND entry_timestamp >= p_period_start
        AND entry_timestamp < p_period_end
        AND source != 'deleted';

    WHEN 'COUNT' THEN
      SELECT COUNT(*)
      INTO v_result
      FROM patient_data_entries
      WHERE patient_id = p_patient_id
        AND field_id = p_field_id
        AND entry_timestamp >= p_period_start
        AND entry_timestamp < p_period_end
        AND source != 'deleted';

    WHEN 'COUNT_DISTINCT' THEN
      SELECT COUNT(DISTINCT value_reference)
      INTO v_result
      FROM patient_data_entries
      WHERE patient_id = p_patient_id
        AND field_id = p_field_id
        AND entry_timestamp >= p_period_start
        AND entry_timestamp < p_period_end
        AND source != 'deleted';

    ELSE
      v_result := 0;
  END CASE;

  RETURN COALESCE(v_result, 0);
END;
$function$;

DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '✅ Fixed Period Functions for Hourly Support!';
  RAISE NOTICE '';
  RAISE NOTICE 'Changes:';
  RAISE NOTICE '  • get_period_start() now returns TIMESTAMPTZ';
  RAISE NOTICE '  • get_period_end() now returns TIMESTAMPTZ';
  RAISE NOTICE '  • Added p_hour parameter for hourly granularity';
  RAISE NOTICE '  • process_single_aggregation() handles 24 hours/day';
  RAISE NOTICE '  • calculate_field_aggregation() uses entry_timestamp';
  RAISE NOTICE '';
  RAISE NOTICE 'Hourly periods now properly create 24 entries per day!';
  RAISE NOTICE '';
END $$;

COMMIT;
