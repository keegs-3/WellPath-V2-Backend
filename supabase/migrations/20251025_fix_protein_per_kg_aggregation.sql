-- =====================================================
-- Fix Protein Per Kg Body Weight Aggregation
-- =====================================================
-- Creates function to compute ratio-based aggregations
-- =====================================================

BEGIN;

-- =====================================================
-- Function to calculate instance calculation aggregation
-- (for ratios like protein/weight)
-- =====================================================
CREATE OR REPLACE FUNCTION public.calculate_instance_calc_aggregation_v2(
  p_patient_id uuid,
  p_instance_calc_id text,
  p_period_start timestamp with time zone,
  p_period_end timestamp with time zone,
  p_calculation_type text
)
 RETURNS numeric
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_result NUMERIC;
  v_numerator_field TEXT;
  v_denominator_field TEXT;
  v_calculation_method TEXT;
BEGIN
  -- Get calculation configuration
  SELECT
    calculation_method,
    calculation_config->>'numerator_field',
    calculation_config->>'denominator_field'
  INTO
    v_calculation_method,
    v_numerator_field,
    v_denominator_field
  FROM instance_calculations
  WHERE calc_id = p_instance_calc_id;

  -- Currently only support division
  IF v_calculation_method != 'division' THEN
    RETURN NULL;
  END IF;

  IF v_numerator_field IS NULL OR v_denominator_field IS NULL THEN
    RETURN NULL;
  END IF;

  -- For protein per kg: compute daily ratios using most recent weight for each day
  -- Then aggregate those ratios
  CASE p_calculation_type
    WHEN 'AVG' THEN
      -- Average of daily ratios: compute protein/weight for each day, then average
      WITH daily_protein AS (
        SELECT
          DATE(entry_timestamp) as entry_date,
          SUM(value_quantity) as daily_protein
        FROM patient_data_entries
        WHERE patient_id = p_patient_id
          AND field_id = v_numerator_field
          AND entry_timestamp >= p_period_start
          AND entry_timestamp < p_period_end
          AND source != 'deleted'
        GROUP BY DATE(entry_timestamp)
      ),
      daily_ratios AS (
        SELECT
          dp.entry_date,
          dp.daily_protein,
          (
            SELECT value_quantity
            FROM patient_data_entries
            WHERE patient_id = p_patient_id
              AND field_id = 'DEF_WEIGHT'
              AND entry_timestamp < dp.entry_date + INTERVAL '1 day'
            ORDER BY entry_timestamp DESC
            LIMIT 1
          ) as weight
        FROM daily_protein dp
      )
      SELECT COALESCE(AVG(daily_protein / NULLIF(weight, 0)), 0)
      INTO v_result
      FROM daily_ratios
      WHERE weight > 0;

    WHEN 'MAX' THEN
      -- Max ratio in period (compute per-day ratios, return max)
      WITH daily_protein AS (
        SELECT
          DATE(entry_timestamp) as entry_date,
          SUM(value_quantity) as daily_protein
        FROM patient_data_entries
        WHERE patient_id = p_patient_id
          AND field_id = v_numerator_field
          AND entry_timestamp >= p_period_start
          AND entry_timestamp < p_period_end
          AND source != 'deleted'
        GROUP BY DATE(entry_timestamp)
      ),
      daily_ratios AS (
        SELECT
          dp.entry_date,
          dp.daily_protein,
          (
            SELECT value_quantity
            FROM patient_data_entries
            WHERE patient_id = p_patient_id
              AND field_id = 'DEF_WEIGHT'
              AND entry_timestamp < dp.entry_date + INTERVAL '1 day'
            ORDER BY entry_timestamp DESC
            LIMIT 1
          ) as weight
        FROM daily_protein dp
      )
      SELECT COALESCE(MAX(daily_protein / NULLIF(weight, 0)), 0)
      INTO v_result
      FROM daily_ratios
      WHERE weight > 0;

    WHEN 'MIN' THEN
      -- Min ratio in period (compute per-day ratios, return min)
      WITH daily_protein AS (
        SELECT
          DATE(entry_timestamp) as entry_date,
          SUM(value_quantity) as daily_protein
        FROM patient_data_entries
        WHERE patient_id = p_patient_id
          AND field_id = v_numerator_field
          AND entry_timestamp >= p_period_start
          AND entry_timestamp < p_period_end
          AND source != 'deleted'
        GROUP BY DATE(entry_timestamp)
      ),
      daily_ratios AS (
        SELECT
          dp.entry_date,
          dp.daily_protein,
          (
            SELECT value_quantity
            FROM patient_data_entries
            WHERE patient_id = p_patient_id
              AND field_id = 'DEF_WEIGHT'
              AND entry_timestamp < dp.entry_date + INTERVAL '1 day'
            ORDER BY entry_timestamp DESC
            LIMIT 1
          ) as weight
        FROM daily_protein dp
      )
      SELECT COALESCE(MIN(daily_protein / NULLIF(weight, 0)), 0)
      INTO v_result
      FROM daily_ratios
      WHERE weight > 0 AND daily_protein > 0;

    ELSE
      v_result := 0;
  END CASE;

  RETURN COALESCE(v_result, 0);
END;
$function$;

-- =====================================================
-- Update process_single_aggregation to handle instance_calc
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

        -- Handle instance_calc dependencies (NEW)
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

      -- Handle instance_calc dependencies (NEW)
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

DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '✅ Fixed Protein Per Kg Body Weight Aggregation!';
  RAISE NOTICE '';
  RAISE NOTICE 'Changes:';
  RAISE NOTICE '  • Created calculate_instance_calc_aggregation_v2() for ratio calculations';
  RAISE NOTICE '  • Updated process_single_aggregation() to handle instance_calc dependencies';
  RAISE NOTICE '  • Computes protein/weight ratio on-the-fly during aggregation';
  RAISE NOTICE '';
END $$;

COMMIT;
