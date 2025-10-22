-- =====================================================
-- Add Duration Display Metrics
-- =====================================================
-- Create display metrics for duration tracking
-- (sleep, cardio, strength, etc.)
--
-- Created: 2025-10-22
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Create Duration Display Metrics
-- =====================================================

INSERT INTO display_metrics (
  display_metric_id,
  display_name,
  description,
  pillar,
  widget_type,
  chart_type_id,
  supported_periods,
  default_period,
  display_unit,
  is_active
)
VALUES
-- Restorative Sleep Duration
('DISP_SLEEP_DURATION', 'Sleep Duration', 'Track total sleep duration and patterns',
 'Restorative Sleep', 'chart', 'sleep_stages_vertical', ARRAY['daily', 'weekly', 'monthly'], 'weekly', 'minutes', true),

-- Movement + Exercise Durations
('DISP_CARDIO_DURATION', 'Cardio Duration', 'Track cardio workout duration',
 'Movement + Exercise', 'chart', 'bar_vertical', ARRAY['daily', 'weekly', 'monthly'], 'weekly', 'minutes', true)

ON CONFLICT (display_metric_id) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  pillar = EXCLUDED.pillar,
  widget_type = EXCLUDED.widget_type,
  chart_type_id = EXCLUDED.chart_type_id,
  supported_periods = EXCLUDED.supported_periods,
  default_period = EXCLUDED.default_period,
  display_unit = EXCLUDED.display_unit,
  is_active = EXCLUDED.is_active;


-- =====================================================
-- PART 2: Link Duration Metrics to Aggregations
-- =====================================================

-- Sleep Duration: AVG (primary), MIN, MAX
INSERT INTO display_metrics_aggregations (display_metric_id, agg_metric_id, period_type, calculation_type_id, is_primary, display_order)
VALUES
('DISP_SLEEP_DURATION', 'AGG_SLEEP_DURATION', 'weekly', 'AVG', true, 1),
('DISP_SLEEP_DURATION', 'AGG_SLEEP_DURATION', 'monthly', 'AVG', false, 2),
('DISP_SLEEP_DURATION', 'AGG_SLEEP_DURATION', 'daily', 'MIN', false, 3),
('DISP_SLEEP_DURATION', 'AGG_SLEEP_DURATION', 'daily', 'MAX', false, 4)

ON CONFLICT (display_metric_id, agg_metric_id, period_type, calculation_type_id) DO UPDATE SET
  is_primary = EXCLUDED.is_primary,
  display_order = EXCLUDED.display_order;

-- Cardio Duration: SUM (primary) for total minutes
INSERT INTO display_metrics_aggregations (display_metric_id, agg_metric_id, period_type, calculation_type_id, is_primary, display_order)
VALUES
('DISP_CARDIO_DURATION', 'AGG_CARDIO_DURATION', 'weekly', 'SUM', true, 1),
('DISP_CARDIO_DURATION', 'AGG_CARDIO_DURATION', 'monthly', 'SUM', false, 2),
('DISP_CARDIO_DURATION', 'AGG_CARDIO_DURATION', 'weekly', 'AVG', false, 3),
('DISP_CARDIO_DURATION', 'AGG_CARDIO_DURATION', 'monthly', 'AVG', false, 4)

ON CONFLICT (display_metric_id, agg_metric_id, period_type, calculation_type_id) DO UPDATE SET
  is_primary = EXCLUDED.is_primary,
  display_order = EXCLUDED.display_order;

-- =====================================================
-- Summary
-- =====================================================

DO $$
DECLARE
  metrics_count INT;
  links_count INT;
BEGIN
  SELECT COUNT(*) INTO metrics_count FROM display_metrics
  WHERE display_metric_id IN ('DISP_SLEEP_DURATION', 'DISP_CARDIO_DURATION');

  SELECT COUNT(*) INTO links_count FROM display_metrics_aggregations
  WHERE display_metric_id IN ('DISP_SLEEP_DURATION', 'DISP_CARDIO_DURATION');

  RAISE NOTICE '✅ Duration Display Metrics Added';
  RAISE NOTICE '';
  RAISE NOTICE 'Summary:';
  RAISE NOTICE '  Display Metrics Created: %', metrics_count;
  RAISE NOTICE '  Aggregation Links Created: %', links_count;
  RAISE NOTICE '';
  RAISE NOTICE 'Duration Metrics:';
  RAISE NOTICE '  • DISP_SLEEP_DURATION - AVG (primary), MIN, MAX';
  RAISE NOTICE '  • DISP_CARDIO_DURATION - SUM (primary), AVG';
END $$;

COMMIT;
