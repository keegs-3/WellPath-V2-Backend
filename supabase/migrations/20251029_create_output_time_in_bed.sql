-- =====================================================
-- Create OUTPUT_TIME_IN_BED and AGG_TIME_IN_BED
-- =====================================================
-- Creates fields for tracking total time in bed per sleep event
-- (sum of ALL sleep stages including AWAKE and IN_BED)
--
-- Created: 2025-10-29
-- =====================================================

BEGIN;

-- =====================================================
-- 1. Create OUTPUT_TIME_IN_BED field
-- =====================================================

INSERT INTO data_entry_fields (
    field_id,
    field_name,
    display_name,
    description,
    field_type,
    data_type,
    unit,
    is_active
) VALUES (
    'OUTPUT_TIME_IN_BED',
    'total_time_in_bed',
    'Total Time in Bed',
    'Total time in bed per sleep event (sum of ALL stages: CORE + DEEP + REM + UNSPECIFIED + AWAKE + IN_BED)',
    'output',
    'numeric',
    'minutes',
    true
) ON CONFLICT (field_id) DO UPDATE SET
    display_name = EXCLUDED.display_name,
    description = EXCLUDED.description,
    updated_at = now();

INSERT INTO field_registry (
    field_id,
    field_name,
    display_name,
    description,
    field_source,
    data_entry_field_id,
    unit,
    is_active
) VALUES (
    'OUTPUT_TIME_IN_BED',
    'total_time_in_bed',
    'Total Time in Bed',
    'Total time in bed per sleep event (sum of ALL stages: CORE + DEEP + REM + UNSPECIFIED + AWAKE + IN_BED)',
    'calculated',
    'OUTPUT_TIME_IN_BED',
    'minutes',
    true
) ON CONFLICT (field_id) DO UPDATE SET
    display_name = EXCLUDED.display_name,
    description = EXCLUDED.description,
    updated_at = now();

-- =====================================================
-- 2. Populate OUTPUT_TIME_IN_BED values
-- =====================================================
-- Sum ALL sleep stage durations per event

-- OUTPUT_TIME_IN_BED = OUTPUT_SLEEP_DURATION + OUTPUT_AWAKE_PERIODS_DURATION
-- (Does NOT include IN_BED stage - that's time awake before falling asleep)
INSERT INTO patient_data_entries (
    patient_id,
    field_id,
    entry_date,
    value_quantity,
    event_instance_id,
    source
)
SELECT
    sleep_dur.patient_id,
    'OUTPUT_TIME_IN_BED' as field_id,
    sleep_dur.entry_date,
    sleep_dur.value_quantity + COALESCE(awake.value_quantity, 0) as value_quantity,
    sleep_dur.event_instance_id,
    'auto_calculated' as source
FROM patient_data_entries sleep_dur
LEFT JOIN patient_data_entries awake
    ON awake.event_instance_id = sleep_dur.event_instance_id
    AND awake.field_id = 'OUTPUT_AWAKE_PERIODS_DURATION'
WHERE sleep_dur.field_id = 'OUTPUT_SLEEP_DURATION'
  AND sleep_dur.event_instance_id IS NOT NULL
ON CONFLICT DO NOTHING;

-- =====================================================
-- 3. Create AGG_TIME_IN_BED aggregation metric
-- =====================================================

INSERT INTO aggregation_metrics (
    agg_id,
    metric_name,
    display_name,
    output_unit,
    description
) VALUES (
    'AGG_TIME_IN_BED',
    'time_in_bed_agg',
    'Time in Bed Aggregation',
    'hours_minutes',
    'Total time in bed (all sleep stages including awake and in bed periods)'
) ON CONFLICT (agg_id) DO UPDATE SET
    metric_name = EXCLUDED.metric_name,
    display_name = EXCLUDED.display_name,
    description = EXCLUDED.description,
    updated_at = now();

-- =====================================================
-- 4. Create dependency for AGG_TIME_IN_BED
-- =====================================================

INSERT INTO aggregation_metrics_dependencies (
    agg_metric_id,
    dependency_type,
    data_entry_field_id
) VALUES (
    'AGG_TIME_IN_BED',
    'data_field',
    'OUTPUT_TIME_IN_BED'
) ON CONFLICT ON CONSTRAINT unique_dependency DO NOTHING;

-- =====================================================
-- 5. Create display metric for TIME_IN_BED
-- =====================================================

INSERT INTO display_metrics (
    metric_id,
    metric_name,
    description,
    chart_type_id,
    pillar
) VALUES (
    'DISP_TIME_IN_BED',
    'Time in Bed',
    'Total time spent in bed per period',
    'line',
    'Restorative Sleep'
) ON CONFLICT (metric_id) DO UPDATE SET
    metric_name = EXCLUDED.metric_name,
    description = EXCLUDED.description,
    updated_at = now();

-- =====================================================
-- 6. Link display metric to aggregation
-- =====================================================

INSERT INTO display_metrics_aggregations (
    metric_id,
    agg_metric_id,
    period_type,
    calculation_type_id
) VALUES
    ('DISP_TIME_IN_BED', 'AGG_TIME_IN_BED', 'daily', 'SUM'),
    ('DISP_TIME_IN_BED', 'AGG_TIME_IN_BED', 'weekly', 'SUM'),
    ('DISP_TIME_IN_BED', 'AGG_TIME_IN_BED', 'monthly', 'SUM')
ON CONFLICT (metric_id, agg_metric_id, period_type, calculation_type_id) DO NOTHING;

COMMIT;

-- =====================================================
-- Verification
-- =====================================================

-- Check OUTPUT_TIME_IN_BED was created
SELECT field_id, field_name, unit, field_type
FROM data_entry_fields
WHERE field_id = 'OUTPUT_TIME_IN_BED';

-- Check AGG_TIME_IN_BED was created
SELECT agg_id, metric_name, display_name, output_unit
FROM aggregation_metrics
WHERE agg_id = 'AGG_TIME_IN_BED';

-- Check sample data
SELECT
    patient_id,
    event_instance_id,
    value_quantity as time_in_bed_minutes,
    entry_date
FROM patient_data_entries
WHERE field_id = 'OUTPUT_TIME_IN_BED'
ORDER BY entry_date DESC
LIMIT 5;

-- Compare sleep duration vs time in bed for validation
SELECT
    e1.patient_id,
    e1.event_instance_id,
    e1.entry_date,
    e1.value_quantity as sleep_duration_min,
    e2.value_quantity as time_in_bed_min,
    ROUND((e1.value_quantity::numeric / e2.value_quantity::numeric * 100), 1) as sleep_efficiency_pct
FROM patient_data_entries e1
INNER JOIN patient_data_entries e2
    ON e1.patient_id = e2.patient_id
    AND e1.event_instance_id = e2.event_instance_id
WHERE e1.field_id = 'OUTPUT_SLEEP_DURATION'
  AND e2.field_id = 'OUTPUT_TIME_IN_BED'
ORDER BY e1.entry_date DESC
LIMIT 5;
