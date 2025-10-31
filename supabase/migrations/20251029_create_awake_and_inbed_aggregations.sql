-- =====================================================
-- Create AGG_AWAKE_PERIODS_DURATION and AGG_IN_BED_DURATION
-- =====================================================
-- Creates aggregation metrics for AWAKE and IN_BED stages
-- to support sleep analysis chart with percentages and averages
--
-- Created: 2025-10-29
-- =====================================================

BEGIN;

-- =====================================================
-- 1. Create AGG_AWAKE_PERIODS_DURATION
-- =====================================================

INSERT INTO aggregation_metrics (
    agg_id,
    metric_name,
    display_name,
    output_unit,
    description
) VALUES (
    'AGG_AWAKE_PERIODS_DURATION',
    'awake_periods_duration_agg',
    'Awake Periods Duration Aggregation',
    'hours_minutes',
    'Total time spent awake during sleep periods'
) ON CONFLICT (agg_id) DO UPDATE SET
    metric_name = EXCLUDED.metric_name,
    display_name = EXCLUDED.display_name,
    description = EXCLUDED.description,
    updated_at = now();

-- Create dependency
INSERT INTO aggregation_metrics_dependencies (
    agg_metric_id,
    dependency_type,
    data_entry_field_id
) VALUES (
    'AGG_AWAKE_PERIODS_DURATION',
    'data_field',
    'OUTPUT_AWAKE_PERIODS_DURATION'
) ON CONFLICT ON CONSTRAINT unique_dependency DO NOTHING;

-- =====================================================
-- 2. Create AGG_IN_BED_DURATION
-- =====================================================

INSERT INTO aggregation_metrics (
    agg_id,
    metric_name,
    display_name,
    output_unit,
    description
) VALUES (
    'AGG_IN_BED_DURATION',
    'in_bed_duration_agg',
    'In Bed Duration Aggregation',
    'hours_minutes',
    'Total time spent in bed but not yet asleep'
) ON CONFLICT (agg_id) DO UPDATE SET
    metric_name = EXCLUDED.metric_name,
    display_name = EXCLUDED.display_name,
    description = EXCLUDED.description,
    updated_at = now();

-- Create dependency
INSERT INTO aggregation_metrics_dependencies (
    agg_metric_id,
    dependency_type,
    data_entry_field_id
) VALUES (
    'AGG_IN_BED_DURATION',
    'data_field',
    'OUTPUT_IN_BED_DURATION'
) ON CONFLICT ON CONSTRAINT unique_dependency DO NOTHING;

COMMIT;

-- =====================================================
-- Verification
-- =====================================================

SELECT agg_id, metric_name, display_name
FROM aggregation_metrics
WHERE agg_id IN ('AGG_AWAKE_PERIODS_DURATION', 'AGG_IN_BED_DURATION');

-- Check dependencies
SELECT
    amd.agg_metric_id,
    amd.data_entry_field_id
FROM aggregation_metrics_dependencies amd
WHERE amd.agg_metric_id IN ('AGG_AWAKE_PERIODS_DURATION', 'AGG_IN_BED_DURATION')
  AND amd.dependency_type = 'data_field';
