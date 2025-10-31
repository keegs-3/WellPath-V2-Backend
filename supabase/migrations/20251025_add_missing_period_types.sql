-- =====================================================
-- Add Missing Period Types (6month and yearly)
-- =====================================================
-- Issue: Only 21 of 334 aggregations have 6month and yearly periods
-- Fix: Add 6month and yearly to all 313 missing aggregations
-- =====================================================

BEGIN;

-- =====================================================
-- STEP 1: Add 6month Period to Missing Aggregations
-- =====================================================

INSERT INTO aggregation_metrics_periods (
  agg_metric_id,
  period_id,
  chart_type,
  x_axis_type,
  x_axis_granularity,
  x_axis_label_format,
  bars,
  days,
  y_axis_min,
  y_axis_max,
  y_axis_label,
  y_axis_auto_scale
)
SELECT
  amp.agg_metric_id,
  '6month' as period_id,
  amp.chart_type,
  amp.x_axis_type,
  'week' as x_axis_granularity,  -- 6month uses weekly granularity
  'MMM DD' as x_axis_label_format,
  26 as bars,  -- ~26 weeks in 6 months
  182 as days,
  amp.y_axis_min,
  amp.y_axis_max,
  amp.y_axis_label,
  amp.y_axis_auto_scale
FROM aggregation_metrics_periods amp
WHERE amp.period_id = 'daily'
  AND NOT EXISTS (
    SELECT 1
    FROM aggregation_metrics_periods
    WHERE agg_metric_id = amp.agg_metric_id
      AND period_id = '6month'
  );

-- =====================================================
-- STEP 2: Add yearly Period to Missing Aggregations
-- =====================================================

INSERT INTO aggregation_metrics_periods (
  agg_metric_id,
  period_id,
  chart_type,
  x_axis_type,
  x_axis_granularity,
  x_axis_label_format,
  bars,
  days,
  y_axis_min,
  y_axis_max,
  y_axis_label,
  y_axis_auto_scale
)
SELECT
  amp.agg_metric_id,
  'yearly' as period_id,
  amp.chart_type,
  amp.x_axis_type,
  'month' as x_axis_granularity,  -- yearly uses monthly granularity
  'MMM' as x_axis_label_format,
  12 as bars,  -- 12 months
  365 as days,
  amp.y_axis_min,
  amp.y_axis_max,
  amp.y_axis_label,
  amp.y_axis_auto_scale
FROM aggregation_metrics_periods amp
WHERE amp.period_id = 'daily'
  AND NOT EXISTS (
    SELECT 1
    FROM aggregation_metrics_periods
    WHERE agg_metric_id = amp.agg_metric_id
      AND period_id = 'yearly'
  );

-- =====================================================
-- VERIFICATION
-- =====================================================

DO $$
DECLARE
  v_total_aggs INTEGER;
  v_with_all_periods INTEGER;
  v_missing_periods INTEGER;
BEGIN
  -- Count total unique aggregations
  SELECT COUNT(DISTINCT agg_metric_id) INTO v_total_aggs
  FROM aggregation_metrics_periods;

  -- Count aggregations with all 5 periods
  SELECT COUNT(*) INTO v_with_all_periods
  FROM (
    SELECT agg_metric_id
    FROM aggregation_metrics_periods
    GROUP BY agg_metric_id
    HAVING
      BOOL_OR(period_id = 'daily') AND
      BOOL_OR(period_id = 'weekly') AND
      BOOL_OR(period_id = 'monthly') AND
      BOOL_OR(period_id = '6month') AND
      BOOL_OR(period_id = 'yearly')
  ) complete;

  v_missing_periods := v_total_aggs - v_with_all_periods;

  RAISE NOTICE '✅ Period Types Added';
  RAISE NOTICE '';
  RAISE NOTICE 'Aggregation Coverage:';
  RAISE NOTICE '  Total aggregations: %', v_total_aggs;
  RAISE NOTICE '  With all 5 periods: %', v_with_all_periods;
  RAISE NOTICE '  Missing periods: %', v_missing_periods;
  RAISE NOTICE '';

  IF v_missing_periods > 0 THEN
    RAISE WARNING '⚠️  % aggregations still missing period types!', v_missing_periods;
  ELSE
    RAISE NOTICE '✅ All aggregations now have: daily, weekly, monthly, 6month, yearly';
  END IF;
END $$;

-- Show sample of added periods
SELECT
  agg_metric_id,
  period_id,
  bars,
  days,
  x_axis_granularity
FROM aggregation_metrics_periods
WHERE period_id IN ('6month', 'yearly')
  AND agg_metric_id LIKE 'AGG_FIBER%'
ORDER BY agg_metric_id, period_id
LIMIT 10;

COMMIT;
