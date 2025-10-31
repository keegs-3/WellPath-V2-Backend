-- =====================================================
-- Fix Timezone-Aware Aggregations
-- =====================================================
-- Problem: Daily+ aggregations were using UTC timestamp boundaries
--          which caused entries to be grouped incorrectly across timezones
-- Solution: Use entry_date for daily/weekly/monthly/yearly/6month periods
--           Keep using entry_timestamp for hourly (correct behavior)
-- =====================================================

-- Step 1: Update calculate_field_aggregation to accept period_type
DROP FUNCTION IF EXISTS calculate_field_aggregation(uuid, text, timestamp with time zone, timestamp with time zone, text, jsonb);
DROP FUNCTION IF EXISTS calculate_field_aggregation(uuid, text, timestamp with time zone, timestamp with time zone, text);

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
BEGIN
  -- Extract filter conditions if present
  IF p_filter_conditions IS NOT NULL THEN
    v_ref_field := p_filter_conditions->>'reference_field';
    v_ref_value := p_filter_conditions->>'reference_value';
    v_no_match := COALESCE((p_filter_conditions->>'no_match')::boolean, false);
    v_ref_category := LOWER(REPLACE(REPLACE(v_ref_field, 'DEF_', ''), '_', '_'));
  END IF;

  -- For non-hourly periods, extract the date from period_start
  IF p_period_type != 'hourly' THEN
    v_entry_date := (p_period_start AT TIME ZONE 'UTC')::DATE;
  END IF;

  CASE p_calculation_type
    WHEN 'AVG' THEN
      IF p_filter_conditions IS NOT NULL THEN
        IF v_no_match THEN
          -- Find entries WITHOUT a matching reference entry
          IF p_period_type = 'hourly' THEN
            -- Hourly: use timestamp filtering
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
                AND pde.entry_timestamp >= $3
                AND pde.entry_timestamp < $4
                AND pde.source != ''deleted''
                AND pde_ref.id IS NULL
            ')
            INTO v_result
            USING p_patient_id, p_field_id, p_period_start, p_period_end, v_ref_field;
          ELSE
            -- Daily+: use entry_date filtering
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
                AND pde.entry_timestamp >= $3
                AND pde.entry_timestamp < $4
                AND pde.source != ''deleted''
                AND pde_ref.field_id = $5
                AND ref.reference_key = $6
            ')
            INTO v_result
            USING p_patient_id, p_field_id, p_period_start, p_period_end, v_ref_field, v_ref_value;
          ELSE
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
          SELECT COALESCE(AVG(value_quantity), 0)
          INTO v_result
          FROM patient_data_entries
          WHERE patient_id = p_patient_id
            AND field_id = p_field_id
            AND entry_timestamp >= p_period_start
            AND entry_timestamp < p_period_end
            AND source != 'deleted';
        ELSE
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
                AND pde.entry_timestamp >= $3
                AND pde.entry_timestamp < $4
                AND pde.source != ''deleted''
                AND pde_ref.id IS NULL
            ')
            INTO v_result
            USING p_patient_id, p_field_id, p_period_start, p_period_end, v_ref_field;
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
                AND pde.entry_timestamp >= $3
                AND pde.entry_timestamp < $4
                AND pde.source != ''deleted''
                AND pde_ref.field_id = $5
                AND ref.reference_key = $6
            ')
            INTO v_result
            USING p_patient_id, p_field_id, p_period_start, p_period_end, v_ref_field, v_ref_value;
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
            AND entry_timestamp >= p_period_start
            AND entry_timestamp < p_period_end
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
        SELECT COALESCE(MAX(value_quantity), 0)
        INTO v_result
        FROM patient_data_entries
        WHERE patient_id = p_patient_id
          AND field_id = p_field_id
          AND entry_timestamp >= p_period_start
          AND entry_timestamp < p_period_end
          AND source != 'deleted';
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
        SELECT COALESCE(MIN(value_quantity), 0)
        INTO v_result
        FROM patient_data_entries
        WHERE patient_id = p_patient_id
          AND field_id = p_field_id
          AND entry_timestamp >= p_period_start
          AND entry_timestamp < p_period_end
          AND source != 'deleted';
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
        FROM patient_data_entries
        WHERE patient_id = p_patient_id
          AND field_id = p_field_id
          AND entry_timestamp >= p_period_start
          AND entry_timestamp < p_period_end
          AND source != 'deleted';
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

-- Step 2: Update process_single_aggregation to pass period_type
CREATE OR REPLACE FUNCTION public.process_single_aggregation(
  p_patient_id uuid,
  p_agg_metric_id text,
  p_entry_date date
)
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
  FOR v_period IN
    SELECT period_id FROM aggregation_metrics_periods
    WHERE agg_metric_id = p_agg_metric_id
  LOOP
    IF v_period.period_id = 'hourly' THEN
      -- Process hourly
      FOR v_hour IN 0..23 LOOP
        v_period_start := get_period_start(p_entry_date, v_period.period_id, v_hour);
        v_period_end := get_period_end(p_entry_date, v_period.period_id, v_hour);

        -- Handle data_field dependencies
        FOR v_dep IN
          SELECT data_entry_field_id, filter_conditions
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
              v_calc_type.calculation_type_id,
              v_period.period_id,  -- ✨ PASS PERIOD TYPE
              v_dep.filter_conditions
            );

            IF v_value IS NOT NULL AND v_value > 0 THEN
              INSERT INTO aggregation_results_cache (
                patient_id, agg_metric_id, period_type,
                period_start, period_end, calculation_type_id,
                value, last_computed_at
              ) VALUES (
                p_patient_id, p_agg_metric_id, v_period.period_id,
                v_period_start, v_period_end, v_calc_type.calculation_type_id,
                v_value, NOW()
              )
              ON CONFLICT (patient_id, agg_metric_id, period_type, calculation_type_id, period_start)
              DO UPDATE SET value = EXCLUDED.value, last_computed_at = EXCLUDED.last_computed_at;

              v_count := v_count + 1;
            END IF;
          END LOOP;
        END LOOP;

        -- Handle instance_calc dependencies
        FOR v_dep IN
          SELECT instance_calculation_id
          FROM aggregation_metrics_dependencies
          WHERE agg_metric_id = p_agg_metric_id
            AND dependency_type = 'instance_calc'
        LOOP
          FOR v_calc_type IN
            SELECT calculation_type_id
            FROM aggregation_metrics_calculation_types
            WHERE aggregation_metric_id = p_agg_metric_id
          LOOP
            v_value := calculate_instance_calc_aggregation_v2(
              p_patient_id,
              v_dep.instance_calculation_id,
              v_period_start,
              v_period_end,
              v_calc_type.calculation_type_id
            );

            IF v_value IS NOT NULL AND v_value >= 0 THEN
              INSERT INTO aggregation_results_cache (
                patient_id, agg_metric_id, period_type,
                period_start, period_end, calculation_type_id,
                value, last_computed_at
              ) VALUES (
                p_patient_id, p_agg_metric_id, v_period.period_id,
                v_period_start, v_period_end, v_calc_type.calculation_type_id,
                v_value, NOW()
              )
              ON CONFLICT (patient_id, agg_metric_id, period_type, calculation_type_id, period_start)
              DO UPDATE SET value = EXCLUDED.value, last_computed_at = EXCLUDED.last_computed_at;

              v_count := v_count + 1;
            END IF;
          END LOOP;
        END LOOP;
      END LOOP;
    ELSE
      -- Non-hourly periods
      v_period_start := get_period_start(p_entry_date, v_period.period_id);
      v_period_end := get_period_end(p_entry_date, v_period.period_id);

      -- Handle data_field dependencies
      FOR v_dep IN
        SELECT data_entry_field_id, filter_conditions
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
            v_calc_type.calculation_type_id,
            v_period.period_id,  -- ✨ PASS PERIOD TYPE
            v_dep.filter_conditions
          );

          INSERT INTO aggregation_results_cache (
            patient_id, agg_metric_id, period_type,
            period_start, period_end, calculation_type_id,
            value, last_computed_at
          ) VALUES (
            p_patient_id, p_agg_metric_id, v_period.period_id,
            v_period_start, v_period_end, v_calc_type.calculation_type_id,
            v_value, NOW()
          )
          ON CONFLICT (patient_id, agg_metric_id, period_type, calculation_type_id, period_start)
          DO UPDATE SET value = EXCLUDED.value, last_computed_at = EXCLUDED.last_computed_at;

          v_count := v_count + 1;
        END LOOP;
      END LOOP;

      -- Handle instance_calc dependencies
      FOR v_dep IN
        SELECT instance_calculation_id
        FROM aggregation_metrics_dependencies
        WHERE agg_metric_id = p_agg_metric_id
          AND dependency_type = 'instance_calc'
      LOOP
        FOR v_calc_type IN
          SELECT calculation_type_id
          FROM aggregation_metrics_calculation_types
          WHERE aggregation_metric_id = p_agg_metric_id
        LOOP
          v_value := calculate_instance_calc_aggregation_v2(
            p_patient_id,
            v_dep.instance_calculation_id,
            v_period_start,
            v_period_end,
            v_calc_type.calculation_type_id
          );

          INSERT INTO aggregation_results_cache (
            patient_id, agg_metric_id, period_type,
            period_start, period_end, calculation_type_id,
            value, last_computed_at
          ) VALUES (
            p_patient_id, p_agg_metric_id, v_period.period_id,
            v_period_start, v_period_end, v_calc_type.calculation_type_id,
            v_value, NOW()
          )
          ON CONFLICT (patient_id, agg_metric_id, period_type, calculation_type_id, period_start)
          DO UPDATE SET value = EXCLUDED.value, last_computed_at = EXCLUDED.last_computed_at;

          v_count := v_count + 1;
        END LOOP;
      END LOOP;
    END IF;
  END LOOP;

  RETURN v_count;
END;
$function$;
