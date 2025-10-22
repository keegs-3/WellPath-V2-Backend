-- =====================================================
-- Populate Aggregation Period Chart Configurations
-- =====================================================
-- Add chart display configuration to all aggregation_metrics_periods
-- Defines how each period type should be visualized
--
-- Created: 2025-10-22
-- =====================================================

BEGIN;

-- =====================================================
-- Copy Configuration from aggregation_periods table
-- =====================================================
-- Each period type defines how to display that specific period:
-- - daily: 24 bars (hourly granularity) for 1 day
-- - weekly: 7 bars (daily granularity) for 7 days
-- - monthly: 33 bars (daily granularity) for max month length
-- - 6month: 26 bars (weekly granularity) for 182 days
-- - yearly: 12 bars (monthly granularity) for 365 days

UPDATE aggregation_metrics_periods amp
SET
  chart_type = 'bar_vertical',
  x_axis_type = 'date',
  x_axis_granularity = ap.x_axis_granularity,
  x_axis_label_format = CASE
    WHEN ap.x_axis_granularity = 'hour' THEN 'HH:mm'
    WHEN ap.x_axis_granularity = 'day' THEN 'MMM DD'
    WHEN ap.x_axis_granularity = 'week' THEN 'MMM DD'
    WHEN ap.x_axis_granularity = 'month' THEN 'MMM'
  END,
  bars = ap.bars,
  days = ap.days
FROM aggregation_periods ap
WHERE amp.period_id = ap.period_id;


-- =====================================================
-- PART 6: Sleep-Specific Overrides
-- =====================================================
-- Sleep metrics get special chart types for better visualization

UPDATE aggregation_metrics_periods
SET
  chart_type = 'sleep_stages_vertical'
WHERE agg_metric_id IN (
  'AGG_SLEEP_DURATION',
  'AGG_SLEEP_SESSION_COUNT'
)
AND period_id IN ('weekly', 'monthly');


-- =====================================================
-- Summary
-- =====================================================

DO $$
DECLARE
  daily_count INT;
  weekly_count INT;
  monthly_count INT;
  total_count INT;
BEGIN
  SELECT COUNT(*) INTO daily_count FROM aggregation_metrics_periods WHERE period_id = 'daily' AND chart_type IS NOT NULL;
  SELECT COUNT(*) INTO weekly_count FROM aggregation_metrics_periods WHERE period_id = 'weekly' AND chart_type IS NOT NULL;
  SELECT COUNT(*) INTO monthly_count FROM aggregation_metrics_periods WHERE period_id = 'monthly' AND chart_type IS NOT NULL;
  SELECT COUNT(*) INTO total_count FROM aggregation_metrics_periods WHERE chart_type IS NOT NULL;

  RAISE NOTICE '✅ Aggregation Period Chart Configurations Populated';
  RAISE NOTICE '';
  RAISE NOTICE 'Summary:';
  RAISE NOTICE '  Daily periods configured: % (24 bars, hourly)', daily_count;
  RAISE NOTICE '  Weekly periods configured: % (7 bars, daily)', weekly_count;
  RAISE NOTICE '  Monthly periods configured: % (33 bars, daily)', monthly_count;
  RAISE NOTICE '  Total configurations: %', total_count;
  RAISE NOTICE '';
  RAISE NOTICE 'Period Configurations (from aggregation_periods):';
  RAISE NOTICE '  • daily: 24 bars (hourly) for 1 day';
  RAISE NOTICE '  • weekly: 7 bars (daily) for 7 days';
  RAISE NOTICE '  • monthly: 33 bars (daily) for 33 days';
  RAISE NOTICE '  • 6month: 26 bars (weekly) for 182 days';
  RAISE NOTICE '  • yearly: 12 bars (monthly) for 365 days';
  RAISE NOTICE '';
  RAISE NOTICE 'Chart Types Used:';
  RAISE NOTICE '  • bar_vertical - Most aggregations';
  RAISE NOTICE '  • sleep_stages_vertical - Sleep metrics (weekly/monthly)';
END $$;

COMMIT;
