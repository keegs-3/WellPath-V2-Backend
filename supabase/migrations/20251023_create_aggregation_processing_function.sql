-- =====================================================
-- Direct Aggregation Processing (PostgreSQL Function)
-- =====================================================
-- Processes aggregations directly in PostgreSQL without edge functions
-- This is faster and doesn't require external HTTP calls
--
-- Created: 2025-10-23
-- =====================================================

-- =====================================================
-- Function: Process Single Aggregation
-- Calculates and updates cache for one aggregation
-- =====================================================
CREATE OR REPLACE FUNCTION process_single_aggregation(
  p_user_id UUID,
  p_agg_metric_id TEXT,
  p_entry_date DATE
)
RETURNS INTEGER AS $$
DECLARE
  v_dep RECORD;
  v_period RECORD;
  v_calc_type RECORD;
  v_period_start DATE;
  v_period_end DATE;
  v_value NUMERIC;
  v_count INTEGER := 0;
BEGIN
  -- Get dependency information
  SELECT * INTO v_dep
  FROM aggregation_metrics_dependencies
  WHERE agg_metric_id = p_agg_metric_id
  LIMIT 1;

  IF NOT FOUND THEN
    RETURN 0;
  END IF;

  -- Process each configured period
  FOR v_period IN
    SELECT period_id
    FROM aggregation_metrics_periods
    WHERE agg_metric_id = p_agg_metric_id
  LOOP
    -- Calculate period bounds
    SELECT * INTO v_period_start, v_period_end
    FROM get_period_bounds(v_period.period_id, p_entry_date);

    -- Process each calculation type
    FOR v_calc_type IN
      SELECT calculation_type_id
      FROM aggregation_metrics_calculation_types
      WHERE aggregation_metric_id = p_agg_metric_id
    LOOP
      -- Calculate aggregation value based on dependency type
      IF v_dep.dependency_type = 'data_field' AND v_dep.data_entry_field_id IS NOT NULL THEN
        -- Direct field aggregation
        SELECT calculate_field_aggregation(
          p_user_id,
          v_dep.data_entry_field_id,
          v_period_start,
          v_period_end,
          v_calc_type.calculation_type_id
        ) INTO v_value;

      ELSIF v_dep.dependency_type = 'instance_calc' AND v_dep.instance_calculation_id IS NOT NULL THEN
        -- Instance calculation aggregation
        SELECT calculate_instance_calc_aggregation(
          p_user_id,
          v_dep.instance_calculation_id,
          v_period_start,
          v_period_end,
          v_calc_type.calculation_type_id
        ) INTO v_value;
      END IF;

      -- Update cache if we have a value
      IF v_value IS NOT NULL THEN
        INSERT INTO aggregation_results_cache (
          user_id,
          agg_metric_id,
          period_type,
          calculation_type_id,
          period_start,
          period_end,
          value,
          last_computed_at,
          is_stale,
          data_points_count
        ) VALUES (
          p_user_id,
          p_agg_metric_id,
          v_period.period_id,
          v_calc_type.calculation_type_id,
          v_period_start,
          v_period_end,
          v_value,
          NOW(),
          false,
          1
        )
        ON CONFLICT (user_id, agg_metric_id, period_type, calculation_type_id, period_start)
        DO UPDATE SET
          value = EXCLUDED.value,
          last_computed_at = NOW(),
          is_stale = false;

        v_count := v_count + 1;
      END IF;
    END LOOP;
  END LOOP;

  RETURN v_count;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- Function: Get Period Bounds
-- Returns start and end dates for a period
-- =====================================================
CREATE OR REPLACE FUNCTION get_period_bounds(
  p_period_id TEXT,
  p_reference_date DATE
)
RETURNS TABLE (period_start DATE, period_end DATE) AS $$
BEGIN
  CASE p_period_id
    WHEN 'hourly' THEN
      -- For hourly, return the same day (aggregation logic handles hours)
      RETURN QUERY SELECT p_reference_date, p_reference_date;

    WHEN 'daily' THEN
      RETURN QUERY SELECT p_reference_date, p_reference_date;

    WHEN 'weekly' THEN
      -- Start of week (Monday)
      RETURN QUERY SELECT
        p_reference_date - (EXTRACT(DOW FROM p_reference_date)::int + 6) % 7,
        p_reference_date;

    WHEN 'monthly' THEN
      RETURN QUERY SELECT
        DATE_TRUNC('month', p_reference_date)::DATE,
        p_reference_date;

    WHEN '6month' THEN
      RETURN QUERY SELECT
        (p_reference_date - INTERVAL '5 months')::DATE,
        p_reference_date;

    WHEN 'yearly' THEN
      RETURN QUERY SELECT
        DATE_TRUNC('year', p_reference_date)::DATE,
        p_reference_date;

    ELSE
      RETURN QUERY SELECT p_reference_date, p_reference_date;
  END CASE;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- =====================================================
-- Function: Calculate Field Aggregation
-- Aggregates values from a data entry field
-- =====================================================
CREATE OR REPLACE FUNCTION calculate_field_aggregation(
  p_user_id UUID,
  p_field_id TEXT,
  p_period_start DATE,
  p_period_end DATE,
  p_calc_type TEXT
)
RETURNS NUMERIC AS $$
DECLARE
  v_result NUMERIC;
BEGIN
  CASE p_calc_type
    WHEN 'SUM' THEN
      SELECT COALESCE(SUM(value_quantity), 0) INTO v_result
      FROM patient_data_entries
      WHERE user_id = p_user_id
        AND field_id = p_field_id
        AND entry_date BETWEEN p_period_start AND p_period_end
        AND source != 'deleted';

    WHEN 'AVG' THEN
      SELECT COALESCE(AVG(value_quantity), 0) INTO v_result
      FROM patient_data_entries
      WHERE user_id = p_user_id
        AND field_id = p_field_id
        AND entry_date BETWEEN p_period_start AND p_period_end
        AND source != 'deleted';

    WHEN 'COUNT' THEN
      SELECT COUNT(*) INTO v_result
      FROM patient_data_entries
      WHERE user_id = p_user_id
        AND field_id = p_field_id
        AND entry_date BETWEEN p_period_start AND p_period_end
        AND source != 'deleted';

    WHEN 'COUNT_DISTINCT' THEN
      SELECT COUNT(DISTINCT value_reference) INTO v_result
      FROM patient_data_entries
      WHERE user_id = p_user_id
        AND field_id = p_field_id
        AND entry_date BETWEEN p_period_start AND p_period_end
        AND source != 'deleted'
        AND value_reference IS NOT NULL;

    ELSE
      v_result := NULL;
  END CASE;

  RETURN v_result;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- Function: Calculate Instance Calc Aggregation
-- Aggregates values from instance calculation outputs
-- =====================================================
CREATE OR REPLACE FUNCTION calculate_instance_calc_aggregation(
  p_user_id UUID,
  p_instance_calc_id TEXT,
  p_period_start DATE,
  p_period_end DATE,
  p_calc_type TEXT
)
RETURNS NUMERIC AS $$
DECLARE
  v_output_field TEXT;
  v_result NUMERIC;
BEGIN
  -- Get output field from instance calculation config
  SELECT calculation_config->>'output_field' INTO v_output_field
  FROM instance_calculations
  WHERE calc_id = p_instance_calc_id;

  IF v_output_field IS NULL THEN
    RETURN NULL;
  END IF;

  -- Aggregate the output field
  RETURN calculate_field_aggregation(
    p_user_id,
    v_output_field,
    p_period_start,
    p_period_end,
    p_calc_type
  );
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- Trigger Function: Auto Process Aggregations
-- Automatically processes aggregations when data is inserted
-- =====================================================
CREATE OR REPLACE FUNCTION trigger_auto_process_aggregations()
RETURNS TRIGGER AS $$
DECLARE
  v_agg RECORD;
  v_processed INTEGER := 0;
BEGIN
  -- Only process for actual data entries (not deleted)
  IF NEW.source IN ('manual', 'healthkit', 'import', 'api', 'auto_calculated') THEN

    -- Process each affected aggregation
    FOR v_agg IN
      SELECT DISTINCT agg_metric_id
      FROM get_affected_aggregations(NEW.field_id)
    LOOP
      v_processed := v_processed + process_single_aggregation(
        NEW.user_id,
        v_agg.agg_metric_id,
        NEW.entry_date
      );
    END LOOP;

    RAISE LOG 'Auto-processed % aggregation cache entries for field %',
      v_processed, NEW.field_id;

  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- Replace Trigger
-- =====================================================
DROP TRIGGER IF EXISTS auto_process_aggregations_http ON patient_data_entries;
DROP TRIGGER IF EXISTS auto_process_aggregations ON patient_data_entries;

CREATE TRIGGER auto_process_aggregations
  AFTER INSERT ON patient_data_entries
  FOR EACH ROW
  WHEN (NEW.source IN ('manual', 'healthkit', 'import', 'api', 'auto_calculated'))
  EXECUTE FUNCTION trigger_auto_process_aggregations();

COMMENT ON TRIGGER auto_process_aggregations ON patient_data_entries
IS 'Automatically processes aggregations when data is inserted (PostgreSQL native)';

-- =====================================================
-- Grant Permissions
-- =====================================================
GRANT EXECUTE ON FUNCTION process_single_aggregation(UUID, TEXT, DATE) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION get_period_bounds(TEXT, DATE) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION calculate_field_aggregation(UUID, TEXT, DATE, DATE, TEXT) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION calculate_instance_calc_aggregation(UUID, TEXT, DATE, DATE, TEXT) TO authenticated, service_role;

-- =====================================================
-- Summary
-- =====================================================
SELECT '✅ Created PostgreSQL-native aggregation processing' as status;

SELECT '
========================================
✅ Fully Automated Aggregation System
========================================

Pipeline:
1. Data inserted into patient_data_entries
2. Trigger: auto_run_instance_calculations_http
   → Instance calculations run (edge function)
3. Trigger: auto_process_aggregations
   → Aggregations calculated (PostgreSQL native)
4. aggregation_results_cache updated

✅ Fully automated - no manual intervention!
✅ Runs in PostgreSQL - no edge function needed
✅ Fast - processes synchronously
========================================
' as summary;
