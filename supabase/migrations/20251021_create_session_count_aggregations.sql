-- =====================================================
-- Create Session Count Aggregations
-- =====================================================
-- Configure aggregations for session counts:
-- - SUM: total sessions (e.g., 10 cardio workouts this week)
-- - COUNT_UNIQUE_DAYS: activity frequency (e.g., cardio on 4 days this week)
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Create Aggregation Metrics
-- =====================================================

INSERT INTO aggregation_metrics (agg_id, metric_name, display_name, description, output_unit, is_active)
VALUES
-- Cardio Sessions
('AGG_CARDIO_SESSION_COUNT', 'cardio_sessions_agg', 'Cardio Sessions Aggregation',
 'Aggregated cardio session counts over time', 'count', true),

-- Sleep Sessions
('AGG_SLEEP_SESSION_COUNT', 'sleep_sessions_agg', 'Sleep Sessions Aggregation',
 'Aggregated sleep session counts over time', 'count', true),

-- Strength Sessions
('AGG_STRENGTH_SESSION_COUNT', 'strength_sessions_agg', 'Strength Sessions Aggregation',
 'Aggregated strength session counts over time', 'count', true)

ON CONFLICT (agg_id) DO UPDATE SET
  metric_name = EXCLUDED.metric_name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  output_unit = EXCLUDED.output_unit,
  is_active = EXCLUDED.is_active;


-- =====================================================
-- PART 2: Link to Data Sources (instance calculations)
-- =====================================================

INSERT INTO aggregation_metrics_dependencies
(agg_metric_id, instance_calculation_id, dependency_type, display_order)
VALUES
('AGG_CARDIO_SESSION_COUNT', 'CALC_CARDIO_SESSION_COUNT', 'instance_calc', 1),
('AGG_SLEEP_SESSION_COUNT', 'CALC_SLEEP_SESSION_COUNT', 'instance_calc', 1),
('AGG_STRENGTH_SESSION_COUNT', 'CALC_STRENGTH_SESSION_COUNT', 'instance_calc', 1)

ON CONFLICT (agg_metric_id, instance_calculation_id, data_entry_field_id) DO NOTHING;


-- =====================================================
-- PART 3: Configure Calculation Types (SUM + COUNT_UNIQUE_DAYS)
-- =====================================================

-- Cardio Sessions: SUM (total sessions), COUNT_UNIQUE_DAYS (days with activity)
INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES
('AGG_CARDIO_SESSION_COUNT', 'SUM'),
('AGG_CARDIO_SESSION_COUNT', 'COUNT_UNIQUE_DAYS'),

('AGG_SLEEP_SESSION_COUNT', 'SUM'),
('AGG_SLEEP_SESSION_COUNT', 'COUNT_UNIQUE_DAYS'),

('AGG_STRENGTH_SESSION_COUNT', 'SUM'),
('AGG_STRENGTH_SESSION_COUNT', 'COUNT_UNIQUE_DAYS')

ON CONFLICT (aggregation_metric_id, calculation_type_id) DO NOTHING;


-- =====================================================
-- PART 4: Configure Periods (daily, weekly, monthly)
-- =====================================================

INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES
-- Cardio
('AGG_CARDIO_SESSION_COUNT', 'daily'),
('AGG_CARDIO_SESSION_COUNT', 'weekly'),
('AGG_CARDIO_SESSION_COUNT', 'monthly'),

-- Sleep
('AGG_SLEEP_SESSION_COUNT', 'daily'),
('AGG_SLEEP_SESSION_COUNT', 'weekly'),
('AGG_SLEEP_SESSION_COUNT', 'monthly'),

-- Strength
('AGG_STRENGTH_SESSION_COUNT', 'daily'),
('AGG_STRENGTH_SESSION_COUNT', 'weekly'),
('AGG_STRENGTH_SESSION_COUNT', 'monthly')

ON CONFLICT DO NOTHING;


-- =====================================================
-- Summary
-- =====================================================

DO $$
DECLARE
  agg_count INT;
  dep_count INT;
  calc_count INT;
  period_count INT;
BEGIN
  SELECT COUNT(*) INTO agg_count FROM aggregation_metrics WHERE agg_id LIKE 'AGG_%SESSION_COUNT';
  SELECT COUNT(*) INTO dep_count FROM aggregation_metrics_dependencies WHERE agg_metric_id LIKE 'AGG_%SESSION_COUNT';
  SELECT COUNT(*) INTO calc_count FROM aggregation_metrics_calculation_types WHERE aggregation_metric_id LIKE 'AGG_%SESSION_COUNT';
  SELECT COUNT(*) INTO period_count FROM aggregation_metrics_periods WHERE agg_metric_id LIKE 'AGG_%SESSION_COUNT';

  RAISE NOTICE '✅ Session Count Aggregations Created';
  RAISE NOTICE '';
  RAISE NOTICE 'Summary:';
  RAISE NOTICE '  Aggregation Metrics: %', agg_count;
  RAISE NOTICE '  Dependencies: %', dep_count;
  RAISE NOTICE '  Calculation Types: %', calc_count;
  RAISE NOTICE '  Periods: %', period_count;
  RAISE NOTICE '';
  RAISE NOTICE 'Configured Aggregations:';
  RAISE NOTICE '  1. Cardio Sessions (from CALC_CARDIO_SESSION_COUNT)';
  RAISE NOTICE '     - SUM (total sessions)';
  RAISE NOTICE '     - COUNT_UNIQUE_DAYS (days with activity)';
  RAISE NOTICE '     - Daily, Weekly, Monthly';
  RAISE NOTICE '  2. Sleep Sessions (from CALC_SLEEP_SESSION_COUNT)';
  RAISE NOTICE '     - SUM, COUNT_UNIQUE_DAYS';
  RAISE NOTICE '     - Daily, Weekly, Monthly';
  RAISE NOTICE '  3. Strength Sessions (from CALC_STRENGTH_SESSION_COUNT)';
  RAISE NOTICE '     - SUM, COUNT_UNIQUE_DAYS';
  RAISE NOTICE '     - Daily, Weekly, Monthly';
  RAISE NOTICE '';
  RAISE NOTICE 'Next: Run process_aggregations.py to populate the cache!';
END $$;

COMMIT;
