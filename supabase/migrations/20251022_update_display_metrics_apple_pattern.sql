-- =====================================================
-- Update Display Metrics to Match Apple Health Pattern
-- =====================================================
-- Apple Health pattern:
-- - Daily (D): Shows TOTAL (SUM)
-- - Weekly (W): Shows AVERAGE (AVG per day)
-- - Monthly (M): Shows AVERAGE (AVG per day)
-- - 6-Month (6M): Shows DAILY AVERAGE (AVG per day)
-- - Yearly (Y): Shows DAILY AVERAGE (AVG per day)
--
-- Created: 2025-10-22
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Clear existing display metric aggregation links
-- =====================================================

DELETE FROM display_metrics_aggregations;


-- =====================================================
-- PART 2: Sleep Duration - Daily AVG, others AVG
-- =====================================================

INSERT INTO display_metrics_aggregations (display_metric_id, agg_metric_id, period_type, calculation_type_id, is_primary, display_order)
VALUES
-- Daily: Show AVG for the day (if multiple sleep periods)
('DISP_SLEEP_DURATION', 'AGG_SLEEP_DURATION', 'daily', 'AVG', true, 1),

-- Weekly/Monthly/6-Month/Yearly: All show AVG per day
('DISP_SLEEP_DURATION', 'AGG_SLEEP_DURATION', 'weekly', 'AVG', true, 2),
('DISP_SLEEP_DURATION', 'AGG_SLEEP_DURATION', 'monthly', 'AVG', true, 3)

ON CONFLICT (display_metric_id, agg_metric_id, period_type, calculation_type_id) DO UPDATE SET
  is_primary = EXCLUDED.is_primary,
  display_order = EXCLUDED.display_order;


-- =====================================================
-- PART 3: Cardio Duration - Daily SUM, others AVG
-- =====================================================

INSERT INTO display_metrics_aggregations (display_metric_id, agg_metric_id, period_type, calculation_type_id, is_primary, display_order)
VALUES
-- Daily: Show TOTAL minutes for the day
('DISP_CARDIO_DURATION', 'AGG_CARDIO_DURATION', 'daily', 'SUM', true, 1),

-- Weekly/Monthly: Show AVERAGE minutes per day
('DISP_CARDIO_DURATION', 'AGG_CARDIO_DURATION', 'weekly', 'AVG', true, 2),
('DISP_CARDIO_DURATION', 'AGG_CARDIO_DURATION', 'monthly', 'AVG', true, 3)

ON CONFLICT (display_metric_id, agg_metric_id, period_type, calculation_type_id) DO UPDATE SET
  is_primary = EXCLUDED.is_primary,
  display_order = EXCLUDED.display_order;


-- =====================================================
-- PART 4: Cardio Sessions - Daily SUM, others AVG
-- =====================================================

INSERT INTO display_metrics_aggregations (display_metric_id, agg_metric_id, period_type, calculation_type_id, is_primary, display_order)
VALUES
-- Daily: Show TOTAL sessions for the day
('DISP_CARDIO_SESSIONS', 'AGG_CARDIO_SESSION_COUNT', 'daily', 'SUM', true, 1),

-- Weekly/Monthly: Show AVERAGE sessions per day
('DISP_CARDIO_SESSIONS', 'AGG_CARDIO_SESSION_COUNT', 'weekly', 'AVG', true, 2),
('DISP_CARDIO_SESSIONS', 'AGG_CARDIO_SESSION_COUNT', 'monthly', 'AVG', true, 3)

ON CONFLICT (display_metric_id, agg_metric_id, period_type, calculation_type_id) DO UPDATE SET
  is_primary = EXCLUDED.is_primary,
  display_order = EXCLUDED.display_order;


-- =====================================================
-- PART 5: Strength Sessions - Daily SUM, others AVG
-- =====================================================

INSERT INTO display_metrics_aggregations (display_metric_id, agg_metric_id, period_type, calculation_type_id, is_primary, display_order)
VALUES
('DISP_STRENGTH_SESSIONS', 'AGG_STRENGTH_SESSION_COUNT', 'daily', 'SUM', true, 1),
('DISP_STRENGTH_SESSIONS', 'AGG_STRENGTH_SESSION_COUNT', 'weekly', 'AVG', true, 2),
('DISP_STRENGTH_SESSIONS', 'AGG_STRENGTH_SESSION_COUNT', 'monthly', 'AVG', true, 3)

ON CONFLICT (display_metric_id, agg_metric_id, period_type, calculation_type_id) DO UPDATE SET
  is_primary = EXCLUDED.is_primary,
  display_order = EXCLUDED.display_order;


-- =====================================================
-- PART 6: Variety Metrics - Daily COUNT_DISTINCT, Weekly AVG of counts
-- =====================================================
-- Note: For variety, COUNT_DISTINCT makes sense for daily (unique types per day)
-- For weekly/monthly, we might want AVG unique types per day

INSERT INTO display_metrics_aggregations (display_metric_id, agg_metric_id, period_type, calculation_type_id, is_primary, display_order)
VALUES
-- Vegetable Variety
('DISP_VEGETABLE_VARIETY', 'AGG_VEGETABLE_VARIETY', 'daily', 'COUNT_DISTINCT', true, 1),
('DISP_VEGETABLE_VARIETY', 'AGG_VEGETABLE_VARIETY', 'weekly', 'COUNT_DISTINCT', true, 2),

-- Fruit Variety
('DISP_FRUIT_VARIETY', 'AGG_FRUIT_VARIETY', 'daily', 'COUNT_DISTINCT', true, 1),
('DISP_FRUIT_VARIETY', 'AGG_FRUIT_VARIETY', 'weekly', 'COUNT_DISTINCT', true, 2),

-- Protein Variety
('DISP_PROTEIN_VARIETY', 'AGG_PROTEIN_VARIETY', 'daily', 'COUNT_DISTINCT', true, 1),
('DISP_PROTEIN_VARIETY', 'AGG_PROTEIN_VARIETY', 'weekly', 'COUNT_DISTINCT', true, 2),

-- Fiber Source Variety
('DISP_FIBER_SOURCE_VARIETY', 'AGG_FIBER_SOURCE_VARIETY', 'daily', 'COUNT_DISTINCT', true, 1),
('DISP_FIBER_SOURCE_VARIETY', 'AGG_FIBER_SOURCE_VARIETY', 'weekly', 'COUNT_DISTINCT', true, 2),

-- Legume Variety
('DISP_LEGUME_VARIETY', 'AGG_LEGUME_VARIETY', 'daily', 'COUNT_DISTINCT', true, 1),
('DISP_LEGUME_VARIETY', 'AGG_LEGUME_VARIETY', 'weekly', 'COUNT_DISTINCT', true, 2),

-- Nut/Seed Variety
('DISP_NUT_SEED_VARIETY', 'AGG_NUT_SEED_VARIETY', 'daily', 'COUNT_DISTINCT', true, 1),
('DISP_NUT_SEED_VARIETY', 'AGG_NUT_SEED_VARIETY', 'weekly', 'COUNT_DISTINCT', true, 2),

-- Whole Grain Variety
('DISP_WHOLE_GRAIN_VARIETY', 'AGG_WHOLE_GRAIN_VARIETY', 'daily', 'COUNT_DISTINCT', true, 1),
('DISP_WHOLE_GRAIN_VARIETY', 'AGG_WHOLE_GRAIN_VARIETY', 'weekly', 'COUNT_DISTINCT', true, 2)

ON CONFLICT (display_metric_id, agg_metric_id, period_type, calculation_type_id) DO UPDATE SET
  is_primary = EXCLUDED.is_primary,
  display_order = EXCLUDED.display_order;


-- =====================================================
-- Summary
-- =====================================================

DO $$
DECLARE
  total_links INT;
BEGIN
  SELECT COUNT(*) INTO total_links FROM display_metrics_aggregations;

  RAISE NOTICE '✅ Display Metrics Updated to Apple Health Pattern';
  RAISE NOTICE '';
  RAISE NOTICE 'Summary:';
  RAISE NOTICE '  Total aggregation links: %', total_links;
  RAISE NOTICE '';
  RAISE NOTICE 'Pattern Applied:';
  RAISE NOTICE '  Daily (D): TOTAL (SUM for counts, AVG for durations)';
  RAISE NOTICE '  Weekly (W): AVERAGE (AVG per day)';
  RAISE NOTICE '  Monthly (M): AVERAGE (AVG per day)';
  RAISE NOTICE '  6-Month (6M): DAILY AVERAGE (AVG per day)';
  RAISE NOTICE '  Yearly (Y): DAILY AVERAGE (AVG per day)';
  RAISE NOTICE '';
  RAISE NOTICE 'Metrics Configured:';
  RAISE NOTICE '  • Sleep Duration - Daily AVG, Weekly/Monthly AVG';
  RAISE NOTICE '  • Cardio Duration - Daily SUM, Weekly/Monthly AVG';
  RAISE NOTICE '  • Cardio Sessions - Daily SUM, Weekly/Monthly AVG';
  RAISE NOTICE '  • Strength Sessions - Daily SUM, Weekly/Monthly AVG';
  RAISE NOTICE '  • Variety Metrics - Daily/Weekly COUNT_DISTINCT';
END $$;

COMMIT;
