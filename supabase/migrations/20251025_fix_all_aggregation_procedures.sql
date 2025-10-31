-- =====================================================
-- Fix All Aggregation Stored Procedures
-- =====================================================
-- Update all aggregation procedures to use patient_id instead of user_id
-- =====================================================

BEGIN;

-- Drop and recreate process_field_aggregations
DROP FUNCTION IF EXISTS process_field_aggregations(uuid, text, date);

CREATE OR REPLACE FUNCTION public.process_field_aggregations(p_patient_id uuid, p_field_id text, p_entry_date date)
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_agg RECORD;
  v_total INTEGER := 0;
  v_count INTEGER;
BEGIN
  -- Process each affected aggregation
  FOR v_agg IN
    SELECT DISTINCT agg_metric_id
    FROM get_affected_aggregations(p_field_id)
  LOOP
    -- Process this aggregation
    v_count := process_single_aggregation(
      p_patient_id,
      v_agg.agg_metric_id,
      p_entry_date
    );

    v_total := v_total + v_count;
  END LOOP;

  RETURN v_total;
END;
$function$;

-- Drop and recreate process_single_aggregation
DROP FUNCTION IF EXISTS process_single_aggregation(uuid, text, date);

CREATE OR REPLACE FUNCTION public.process_single_aggregation(p_patient_id uuid, p_agg_metric_id text, p_entry_date date)
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_period RECORD;
  v_dep RECORD;
  v_calc_type RECORD;
  v_period_start DATE;
  v_period_end DATE;
  v_value NUMERIC;
  v_count INTEGER := 0;
BEGIN
  -- Get all periods for this aggregation metric
  FOR v_period IN
    SELECT period_id
    FROM aggregation_metrics_periods
    WHERE agg_metric_id = p_agg_metric_id
  LOOP
    -- Calculate period boundaries
    v_period_start := get_period_start(p_entry_date, v_period.period_id);
    v_period_end := get_period_end(p_entry_date, v_period.period_id);

    -- Get all data entry fields that feed this aggregation
    FOR v_dep IN
      SELECT data_entry_field_id
      FROM aggregation_metrics_dependencies
      WHERE agg_metric_id = p_agg_metric_id
        AND dependency_type = 'data_field'
    LOOP
      -- Get all calculation types for this aggregation + period combination
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

        -- Upsert into cache
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
  END LOOP;

  RETURN v_count;
END;
$function$;

-- Drop and recreate calculate_field_aggregation
DROP FUNCTION IF EXISTS calculate_field_aggregation(uuid, text, date, date, text);

CREATE OR REPLACE FUNCTION public.calculate_field_aggregation(
  p_patient_id uuid,
  p_field_id text,
  p_period_start date,
  p_period_end date,
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
        AND entry_date >= p_period_start
        AND entry_date < p_period_end  -- ✅ Exclusive upper bound
        AND source != 'deleted';

    WHEN 'SUM' THEN
      SELECT COALESCE(SUM(value_quantity), 0)
      INTO v_result
      FROM patient_data_entries
      WHERE patient_id = p_patient_id
        AND field_id = p_field_id
        AND entry_date >= p_period_start
        AND entry_date < p_period_end
        AND source != 'deleted';

    WHEN 'MAX' THEN
      SELECT COALESCE(MAX(value_quantity), 0)
      INTO v_result
      FROM patient_data_entries
      WHERE patient_id = p_patient_id
        AND field_id = p_field_id
        AND entry_date >= p_period_start
        AND entry_date < p_period_end
        AND source != 'deleted';

    WHEN 'MIN' THEN
      SELECT COALESCE(MIN(value_quantity), 0)
      INTO v_result
      FROM patient_data_entries
      WHERE patient_id = p_patient_id
        AND field_id = p_field_id
        AND entry_date >= p_period_start
        AND entry_date < p_period_end
        AND source != 'deleted';

    WHEN 'COUNT' THEN
      SELECT COUNT(*)
      INTO v_result
      FROM patient_data_entries
      WHERE patient_id = p_patient_id
        AND field_id = p_field_id
        AND entry_date >= p_period_start
        AND entry_date < p_period_end
        AND source != 'deleted';

    WHEN 'COUNT_DISTINCT' THEN
      SELECT COUNT(DISTINCT value_reference)
      INTO v_result
      FROM patient_data_entries
      WHERE patient_id = p_patient_id
        AND field_id = p_field_id
        AND entry_date >= p_period_start
        AND entry_date < p_period_end
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
  RAISE NOTICE '✅ Fixed All Aggregation Stored Procedures!';
  RAISE NOTICE '';
  RAISE NOTICE 'Updated procedures:';
  RAISE NOTICE '  - process_field_aggregations(patient_id, field_id, entry_date)';
  RAISE NOTICE '  - process_single_aggregation(patient_id, agg_metric_id, entry_date)';
  RAISE NOTICE '  - calculate_field_aggregation(patient_id, field_id, period_start, period_end, calc_type)';
  RAISE NOTICE '';
  RAISE NOTICE 'All procedures now use patient_id instead of user_id';
  RAISE NOTICE '';
END $$;

COMMIT;
