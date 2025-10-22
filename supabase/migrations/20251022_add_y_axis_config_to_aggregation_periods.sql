-- =====================================================
-- Add Y-Axis Configuration to Aggregation Metrics Periods
-- =====================================================
-- Add y-axis display configuration for charts
-- Includes min/max values, labels, and auto-scaling
--
-- Created: 2025-10-22
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Add Y-Axis Columns
-- =====================================================

ALTER TABLE aggregation_metrics_periods
ADD COLUMN IF NOT EXISTS y_axis_min NUMERIC,
ADD COLUMN IF NOT EXISTS y_axis_max NUMERIC,
ADD COLUMN IF NOT EXISTS y_axis_label TEXT,
ADD COLUMN IF NOT EXISTS y_axis_auto_scale BOOLEAN DEFAULT true;


-- =====================================================
-- PART 2: Set Default Y-Axis Configuration by Metric Type
-- =====================================================

-- Duration Metrics (minutes)
-- Daily (hourly): 0-60 mins per hour
-- Weekly/Monthly (daily): 0-120 mins per day

UPDATE aggregation_metrics_periods
SET
  y_axis_min = 0,
  y_axis_max = 60,
  y_axis_label = 'minutes',
  y_axis_auto_scale = true
WHERE agg_metric_id IN (
  'AGG_CARDIO_DURATION',
  'AGG_STRENGTH_DURATION',
  'AGG_SLEEP_DURATION',
  'AGG_HIIT_DURATION',
  'AGG_MOBILITY_DURATION',
  'AGG_WALKING_DURATION',
  'AGG_YOGA_DURATION'
)
AND period_id = 'daily';

UPDATE aggregation_metrics_periods
SET
  y_axis_min = 0,
  y_axis_max = 120,
  y_axis_label = 'minutes',
  y_axis_auto_scale = true
WHERE agg_metric_id IN (
  'AGG_CARDIO_DURATION',
  'AGG_STRENGTH_DURATION',
  'AGG_SLEEP_DURATION',
  'AGG_HIIT_DURATION',
  'AGG_MOBILITY_DURATION',
  'AGG_WALKING_DURATION',
  'AGG_YOGA_DURATION'
)
AND period_id IN ('weekly', 'monthly');


-- Session Count Metrics
-- Daily (hourly): 0-2 sessions per hour
-- Weekly/Monthly (daily): 0-5 sessions per day

UPDATE aggregation_metrics_periods
SET
  y_axis_min = 0,
  y_axis_max = 2,
  y_axis_label = 'sessions',
  y_axis_auto_scale = true
WHERE agg_metric_id IN (
  'AGG_CARDIO_SESSION_COUNT',
  'AGG_STRENGTH_SESSION_COUNT',
  'AGG_SLEEP_SESSION_COUNT',
  'AGG_HIIT_SESSION_COUNT',
  'AGG_MOBILITY_SESSION_COUNT',
  'AGG_WALKING_SESSION_COUNT',
  'AGG_YOGA_SESSION_COUNT'
)
AND period_id = 'daily';

UPDATE aggregation_metrics_periods
SET
  y_axis_min = 0,
  y_axis_max = 5,
  y_axis_label = 'sessions',
  y_axis_auto_scale = true
WHERE agg_metric_id IN (
  'AGG_CARDIO_SESSION_COUNT',
  'AGG_STRENGTH_SESSION_COUNT',
  'AGG_SLEEP_SESSION_COUNT',
  'AGG_HIIT_SESSION_COUNT',
  'AGG_MOBILITY_SESSION_COUNT',
  'AGG_WALKING_SESSION_COUNT',
  'AGG_YOGA_SESSION_COUNT'
)
AND period_id IN ('weekly', 'monthly');


-- Variety Metrics (unique types per time period)
-- Daily: 0-10 unique types per day
-- Weekly: 0-15 unique types per day (might eat more variety throughout week)

UPDATE aggregation_metrics_periods
SET
  y_axis_min = 0,
  y_axis_max = 10,
  y_axis_label = 'unique types',
  y_axis_auto_scale = true
WHERE agg_metric_id IN (
  'AGG_VEGETABLE_VARIETY',
  'AGG_FRUIT_VARIETY',
  'AGG_PROTEIN_VARIETY',
  'AGG_FIBER_SOURCE_VARIETY',
  'AGG_LEGUME_VARIETY',
  'AGG_NUT_SEED_VARIETY',
  'AGG_WHOLE_GRAIN_VARIETY'
)
AND period_id = 'daily';

UPDATE aggregation_metrics_periods
SET
  y_axis_min = 0,
  y_axis_max = 15,
  y_axis_label = 'unique types',
  y_axis_auto_scale = true
WHERE agg_metric_id IN (
  'AGG_VEGETABLE_VARIETY',
  'AGG_FRUIT_VARIETY',
  'AGG_PROTEIN_VARIETY',
  'AGG_FIBER_SOURCE_VARIETY',
  'AGG_LEGUME_VARIETY',
  'AGG_NUT_SEED_VARIETY',
  'AGG_WHOLE_GRAIN_VARIETY'
)
AND period_id = 'weekly';


-- =====================================================
-- Summary
-- =====================================================

DO $$
DECLARE
  configured_count INT;
  duration_count INT;
  session_count INT;
  variety_count INT;
BEGIN
  SELECT COUNT(*) INTO configured_count
  FROM aggregation_metrics_periods
  WHERE y_axis_min IS NOT NULL;

  SELECT COUNT(*) INTO duration_count
  FROM aggregation_metrics_periods
  WHERE agg_metric_id LIKE '%_DURATION'
  AND y_axis_min IS NOT NULL;

  SELECT COUNT(*) INTO session_count
  FROM aggregation_metrics_periods
  WHERE agg_metric_id LIKE '%_SESSION_COUNT'
  AND y_axis_min IS NOT NULL;

  SELECT COUNT(*) INTO variety_count
  FROM aggregation_metrics_periods
  WHERE agg_metric_id LIKE '%_VARIETY'
  AND y_axis_min IS NOT NULL;

  RAISE NOTICE '✅ Y-Axis Configuration Added to Aggregation Metrics Periods';
  RAISE NOTICE '';
  RAISE NOTICE 'Summary:';
  RAISE NOTICE '  Total periods configured: %', configured_count;
  RAISE NOTICE '  Duration metrics: %', duration_count;
  RAISE NOTICE '  Session count metrics: %', session_count;
  RAISE NOTICE '  Variety metrics: %', variety_count;
  RAISE NOTICE '';
  RAISE NOTICE 'Y-Axis Ranges by Metric Type:';
  RAISE NOTICE '  Duration (daily/hourly): 0-60 minutes';
  RAISE NOTICE '  Duration (weekly/monthly): 0-120 minutes';
  RAISE NOTICE '  Sessions (daily/hourly): 0-2 sessions';
  RAISE NOTICE '  Sessions (weekly/monthly): 0-5 sessions';
  RAISE NOTICE '  Variety (daily): 0-10 unique types';
  RAISE NOTICE '  Variety (weekly): 0-15 unique types';
  RAISE NOTICE '';
  RAISE NOTICE 'All metrics have y_axis_auto_scale = true';
  RAISE NOTICE '  (Charts will auto-adjust when data exists)';
END $$;

COMMIT;
