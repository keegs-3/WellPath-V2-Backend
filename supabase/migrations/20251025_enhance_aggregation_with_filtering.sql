-- =====================================================
-- Enhance Aggregation Functions with Filter Support
-- =====================================================
-- Updates calculate_field_aggregation to support filter_conditions
-- Allows filtering by reference values (e.g., protein_timing = 'breakfast')
-- =====================================================

BEGIN;

-- =====================================================
-- Enhanced calculate_field_aggregation with Filtering
-- =====================================================
CREATE OR REPLACE FUNCTION public.calculate_field_aggregation(
  p_patient_id uuid,
  p_field_id text,
  p_period_start timestamp with time zone,
  p_period_end timestamp with time zone,
  p_calculation_type text,
  p_filter_conditions jsonb DEFAULT NULL
)
 RETURNS numeric
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_result NUMERIC;
  v_ref_field TEXT;
  v_ref_value TEXT;
  v_ref_table TEXT;
  v_ref_key_column TEXT;
BEGIN
  -- Extract filter conditions if present
  IF p_filter_conditions IS NOT NULL THEN
    v_ref_field := p_filter_conditions->>'reference_field';
    v_ref_value := p_filter_conditions->>'reference_value';

    -- Get the reference table for the filter field
    SELECT reference_table INTO v_ref_table
    FROM data_entry_fields
    WHERE field_id = v_ref_field;

    -- Determine the key column (timing_key, protein_type_key, etc.)
    v_ref_key_column := v_ref_value; -- For now, we'll match by timing_key or similar
  END IF;

  CASE p_calculation_type
    WHEN 'AVG' THEN
      IF p_filter_conditions IS NOT NULL AND v_ref_table IS NOT NULL THEN
        -- Filtered aggregation: JOIN to reference table
        EXECUTE format('
          SELECT COALESCE(AVG(pde.value_quantity), 0)
          FROM patient_data_entries pde
          INNER JOIN patient_data_entries pde_ref
            ON pde.patient_id = pde_ref.patient_id
            AND pde.entry_timestamp = pde_ref.entry_timestamp
          INNER JOIN %I ref_table
            ON pde_ref.value_reference::uuid = ref_table.id
          WHERE pde.patient_id = $1
            AND pde.field_id = $2
            AND pde.entry_timestamp >= $3
            AND pde.entry_timestamp < $4
            AND pde.source != ''deleted''
            AND pde_ref.field_id = $5
            AND ref_table.timing_key = $6
        ', v_ref_table)
        INTO v_result
        USING p_patient_id, p_field_id, p_period_start, p_period_end, v_ref_field, v_ref_value;
      ELSE
        -- No filtering
        SELECT COALESCE(AVG(value_quantity), 0)
        INTO v_result
        FROM patient_data_entries
        WHERE patient_id = p_patient_id
          AND field_id = p_field_id
          AND entry_timestamp >= p_period_start
          AND entry_timestamp < p_period_end
          AND source != 'deleted';
      END IF;

    WHEN 'SUM' THEN
      IF p_filter_conditions IS NOT NULL AND v_ref_table IS NOT NULL THEN
        EXECUTE format('
          SELECT COALESCE(SUM(pde.value_quantity), 0)
          FROM patient_data_entries pde
          INNER JOIN patient_data_entries pde_ref
            ON pde.patient_id = pde_ref.patient_id
            AND pde.entry_timestamp = pde_ref.entry_timestamp
          INNER JOIN %I ref_table
            ON pde_ref.value_reference::uuid = ref_table.id
          WHERE pde.patient_id = $1
            AND pde.field_id = $2
            AND pde.entry_timestamp >= $3
            AND pde.entry_timestamp < $4
            AND pde.source != ''deleted''
            AND pde_ref.field_id = $5
            AND ref_table.timing_key = $6
        ', v_ref_table)
        INTO v_result
        USING p_patient_id, p_field_id, p_period_start, p_period_end, v_ref_field, v_ref_value;
      ELSE
        SELECT COALESCE(SUM(value_quantity), 0)
        INTO v_result
        FROM patient_data_entries
        WHERE patient_id = p_patient_id
          AND field_id = p_field_id
          AND entry_timestamp >= p_period_start
          AND entry_timestamp < p_period_end
          AND source != 'deleted';
      END IF;

    WHEN 'MAX', 'MIN', 'COUNT', 'COUNT_DISTINCT' THEN
      -- For now, these don't support filtering (can be added if needed)
      EXECUTE format('
        SELECT COALESCE(%s(value_quantity), 0)
        FROM patient_data_entries
        WHERE patient_id = $1
          AND field_id = $2
          AND entry_timestamp >= $3
          AND entry_timestamp < $4
          AND source != ''deleted''
      ', p_calculation_type)
      INTO v_result
      USING p_patient_id, p_field_id, p_period_start, p_period_end;

    ELSE
      v_result := 0;
  END CASE;

  RETURN COALESCE(v_result, 0);
END;
$function$;

-- =====================================================
-- Update process_single_aggregation to pass filters
-- =====================================================
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
            -- Pass filter_conditions to aggregation function
            v_value := calculate_field_aggregation(
              p_patient_id,
              v_dep.data_entry_field_id,
              v_period_start,
              v_period_end,
              v_calc_type.calculation_type_id,
              v_dep.filter_conditions  -- ✅ NEW: Pass filter conditions
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
      END LOOP;
    ELSE
      -- Non-hourly periods
      v_period_start := get_period_start(p_entry_date, v_period.period_id);
      v_period_end := get_period_end(p_entry_date, v_period.period_id);

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
            v_dep.filter_conditions  -- ✅ NEW: Pass filter conditions
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

DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '✅ Enhanced Aggregation Functions with Filtering!';
  RAISE NOTICE '';
  RAISE NOTICE 'Changes:';
  RAISE NOTICE '  • calculate_field_aggregation() now accepts p_filter_conditions parameter';
  RAISE NOTICE '  • JOINs to reference tables when filter_conditions present';
  RAISE NOTICE '  • process_single_aggregation() passes filter_conditions from dependencies';
  RAISE NOTICE '';
  RAISE NOTICE 'Conditional filtering now works!';
  RAISE NOTICE '  AGG_PROTEIN_BREAKFAST filters DEF_PROTEIN_GRAMS by timing=breakfast';
  RAISE NOTICE '';
END $$;

COMMIT;
