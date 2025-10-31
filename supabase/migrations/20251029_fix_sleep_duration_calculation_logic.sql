-- =====================================================
-- Fix Sleep Duration Calculation Logic
-- =====================================================
-- Implements correct sleep duration formula:
-- 1. Time in bed = in_bed period duration
-- 2. Time awake = SUM of awake period durations
-- 3. Sleep duration = time in bed - time awake
--
-- This replaces the old approach of summing all asleep stages
--
-- Created: 2025-10-29
-- =====================================================

BEGIN;

-- =====================================================
-- 1. Add aggregation metrics for sleep calculations
-- =====================================================

-- Time in bed (from in_bed periods only)
INSERT INTO aggregation_metrics (
    aggregation_metric_id,
    metric_name,
    display_name,
    description,
    aggregation_method,
    source_field_id,
    unit,
    is_active
) VALUES (
    'AGG_TIME_IN_BED_TOTAL',
    'time_in_bed_total',
    'Time in Bed',
    'Total duration of in_bed sleep periods',
    'sum',
    'DEF_SLEEP_PERIOD_DURATION',
    'minute',
    true
) ON CONFLICT (aggregation_metric_id) DO UPDATE SET
    display_name = EXCLUDED.display_name,
    description = EXCLUDED.description,
    updated_at = now();

-- Time awake (sum of awake periods)
INSERT INTO aggregation_metrics (
    aggregation_metric_id,
    metric_name,
    display_name,
    description,
    aggregation_method,
    source_field_id,
    unit,
    is_active
) VALUES (
    'AGG_TIME_AWAKE_TOTAL',
    'time_awake_total',
    'Time Awake',
    'Total duration of awake periods during sleep',
    'sum',
    'DEF_SLEEP_PERIOD_DURATION',
    'minute',
    true
) ON CONFLICT (aggregation_metric_id) DO UPDATE SET
    display_name = EXCLUDED.display_name,
    description = EXCLUDED.description,
    updated_at = now();

-- Sleep duration (calculated: time_in_bed - time_awake)
INSERT INTO aggregation_metrics (
    aggregation_metric_id,
    metric_name,
    display_name,
    description,
    aggregation_method,
    source_field_id,
    unit,
    calculation_formula,
    is_active
) VALUES (
    'AGG_SLEEP_DURATION_TOTAL',
    'sleep_duration_total',
    'Sleep Duration',
    'Total sleep duration (time in bed minus time awake)',
    'formula',
    NULL,  -- No single source field
    'minute',
    'AGG_TIME_IN_BED_TOTAL - AGG_TIME_AWAKE_TOTAL',
    true
) ON CONFLICT (aggregation_metric_id) DO UPDATE SET
    display_name = EXCLUDED.display_name,
    description = EXCLUDED.description,
    calculation_formula = EXCLUDED.calculation_formula,
    updated_at = now();

-- Core sleep total
INSERT INTO aggregation_metrics (
    aggregation_metric_id,
    metric_name,
    display_name,
    description,
    aggregation_method,
    source_field_id,
    unit,
    is_active
) VALUES (
    'AGG_CORE_SLEEP_TOTAL',
    'core_sleep_total',
    'Core Sleep',
    'Total duration of core sleep',
    'sum',
    'OUTPUT_CORE_SLEEP_DURATION',
    'minute',
    true
) ON CONFLICT (aggregation_metric_id) DO UPDATE SET
    display_name = EXCLUDED.display_name,
    description = EXCLUDED.description,
    updated_at = now();

-- Deep sleep total
INSERT INTO aggregation_metrics (
    aggregation_metric_id,
    metric_name,
    display_name,
    description,
    aggregation_method,
    source_field_id,
    unit,
    is_active
) VALUES (
    'AGG_DEEP_SLEEP_TOTAL',
    'deep_sleep_total',
    'Deep Sleep',
    'Total duration of deep sleep',
    'sum',
    'OUTPUT_DEEP_SLEEP_DURATION',
    'minute',
    true
) ON CONFLICT (aggregation_metric_id) DO UPDATE SET
    display_name = EXCLUDED.display_name,
    description = EXCLUDED.description,
    updated_at = now();

-- REM sleep total
INSERT INTO aggregation_metrics (
    aggregation_metric_id,
    metric_name,
    display_name,
    description,
    aggregation_method,
    source_field_id,
    unit,
    is_active
) VALUES (
    'AGG_REM_SLEEP_TOTAL',
    'rem_sleep_total',
    'REM Sleep',
    'Total duration of REM sleep',
    'sum',
    'OUTPUT_REM_SLEEP_DURATION',
    'minute',
    true
) ON CONFLICT (aggregation_metric_id) DO UPDATE SET
    display_name = EXCLUDED.display_name,
    description = EXCLUDED.description,
    updated_at = now();

-- =====================================================
-- 2. Add filtering conditions to distinguish period types
-- =====================================================

-- Time in bed: only sum periods where type = 'in_bed'
INSERT INTO aggregation_dependencies (
    aggregation_metric_id,
    depends_on_field_id,
    dependency_type,
    filter_config
) VALUES (
    'AGG_TIME_IN_BED_TOTAL',
    'DEF_SLEEP_PERIOD_TYPE',
    'filter',
    jsonb_build_object(
        'filter_type', 'reference_lookup',
        'reference_table', 'def_ref_sleep_period_types',
        'reference_field', 'period_name',
        'filter_value', 'in_bed'
    )
) ON CONFLICT (aggregation_metric_id, depends_on_field_id, dependency_type) DO UPDATE SET
    filter_config = EXCLUDED.filter_config,
    updated_at = now();

-- Time awake: only sum periods where type = 'awake'
INSERT INTO aggregation_dependencies (
    aggregation_metric_id,
    depends_on_field_id,
    dependency_type,
    filter_config
) VALUES (
    'AGG_TIME_AWAKE_TOTAL',
    'DEF_SLEEP_PERIOD_TYPE',
    'filter',
    jsonb_build_object(
        'filter_type', 'reference_lookup',
        'reference_table', 'def_ref_sleep_period_types',
        'reference_field', 'period_name',
        'filter_value', 'awake'
    )
) ON CONFLICT (aggregation_metric_id, depends_on_field_id, dependency_type) DO UPDATE SET
    filter_config = EXCLUDED.filter_config,
    updated_at = now();

-- Sleep duration depends on time in bed and time awake
INSERT INTO aggregation_dependencies (
    aggregation_metric_id,
    depends_on_metric_id,
    dependency_type
) VALUES
    ('AGG_SLEEP_DURATION_TOTAL', 'AGG_TIME_IN_BED_TOTAL', 'input'),
    ('AGG_SLEEP_DURATION_TOTAL', 'AGG_TIME_AWAKE_TOTAL', 'input')
ON CONFLICT (aggregation_metric_id, depends_on_metric_id, dependency_type) DO NOTHING;

-- =====================================================
-- 3. Create PostgreSQL function for formula aggregations
-- =====================================================

CREATE OR REPLACE FUNCTION calculate_formula_aggregation(
    p_patient_id UUID,
    p_aggregation_metric_id TEXT,
    p_period_type TEXT,
    p_start_date DATE,
    p_end_date DATE
) RETURNS NUMERIC AS $$
DECLARE
    v_formula TEXT;
    v_result NUMERIC;
    v_input_values JSONB := '{}'::JSONB;
    v_dependency RECORD;
BEGIN
    -- Get the formula
    SELECT calculation_formula INTO v_formula
    FROM aggregation_metrics
    WHERE aggregation_metric_id = p_aggregation_metric_id;

    IF v_formula IS NULL THEN
        RETURN NULL;
    END IF;

    -- Get all input metric values
    FOR v_dependency IN
        SELECT depends_on_metric_id
        FROM aggregation_dependencies
        WHERE aggregation_metric_id = p_aggregation_metric_id
          AND dependency_type = 'input'
    LOOP
        -- Get the aggregated value for this input metric
        SELECT value_quantity INTO v_result
        FROM patient_field_aggregations
        WHERE patient_id = p_patient_id
          AND aggregation_metric_id = v_dependency.depends_on_metric_id
          AND period_type = p_period_type
          AND period_start = p_start_date
          AND period_end = p_end_date;

        -- Store in JSONB for formula evaluation
        v_input_values := v_input_values || jsonb_build_object(
            v_dependency.depends_on_metric_id,
            COALESCE(v_result, 0)
        );
    END LOOP;

    -- Evaluate formula (for now, hardcode known formulas)
    -- In production, use a proper expression evaluator
    IF p_aggregation_metric_id = 'AGG_SLEEP_DURATION_TOTAL' THEN
        v_result :=
            COALESCE((v_input_values->>'AGG_TIME_IN_BED_TOTAL')::NUMERIC, 0) -
            COALESCE((v_input_values->>'AGG_TIME_AWAKE_TOTAL')::NUMERIC, 0);
    ELSE
        -- Unknown formula
        RETURN NULL;
    END IF;

    RETURN v_result;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 4. Update display metrics to use new aggregations
-- =====================================================

-- Update sleep duration display metric to use formula aggregation
UPDATE display_metrics
SET description = 'Total sleep duration calculated as time in bed minus time awake'
WHERE display_name = 'Sleep Duration'
  AND source_table = 'patient_field_aggregations';

COMMIT;

-- =====================================================
-- Verification Queries
-- =====================================================

-- Check new aggregation metrics
SELECT
    aggregation_metric_id,
    metric_name,
    display_name,
    aggregation_method,
    calculation_formula
FROM aggregation_metrics
WHERE aggregation_metric_id LIKE 'AGG_%SLEEP%'
   OR aggregation_metric_id LIKE 'AGG_%BED%'
   OR aggregation_metric_id LIKE 'AGG_%AWAKE%'
ORDER BY aggregation_metric_id;

-- Check dependencies
SELECT
    ad.aggregation_metric_id,
    ad.depends_on_field_id,
    ad.depends_on_metric_id,
    ad.dependency_type,
    ad.filter_config
FROM aggregation_dependencies ad
WHERE ad.aggregation_metric_id IN (
    'AGG_TIME_IN_BED_TOTAL',
    'AGG_TIME_AWAKE_TOTAL',
    'AGG_SLEEP_DURATION_TOTAL'
)
ORDER BY ad.aggregation_metric_id, ad.dependency_type;
