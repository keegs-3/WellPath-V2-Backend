-- =====================================================
-- Create Display Metrics for New Aggregations
-- =====================================================
-- Create display metrics for:
-- - Session counts (cardio, sleep, strength)
-- - Variety tracking (vegetables, fruits, proteins, etc.)
--
-- Created: 2025-10-22
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Create Display Metrics
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
-- Movement + Exercise Session Counts
('DISP_CARDIO_SESSIONS', 'Cardio Sessions', 'Track cardio workout frequency and total sessions',
 'Movement + Exercise', 'chart', 'bar_vertical', ARRAY['daily', 'weekly', 'monthly'], 'weekly', 'sessions', true),

('DISP_STRENGTH_SESSIONS', 'Strength Sessions', 'Track strength training frequency and total sessions',
 'Movement + Exercise', 'chart', 'bar_vertical', ARRAY['daily', 'weekly', 'monthly'], 'weekly', 'sessions', true),

-- Restorative Sleep Session Count
('DISP_SLEEP_SESSIONS', 'Sleep Sessions', 'Track sleep frequency and consistency',
 'Restorative Sleep', 'chart', 'bar_vertical', ARRAY['daily', 'weekly', 'monthly'], 'weekly', 'sessions', true),

-- Healthful Nutrition Variety Tracking
('DISP_VEGETABLE_VARIETY', 'Vegetable Variety', 'Track variety of vegetables consumed',
 'Healthful Nutrition', 'chart', 'bar_vertical', ARRAY['daily', 'weekly'], 'daily', 'types', true),

('DISP_FRUIT_VARIETY', 'Fruit Variety', 'Track variety of fruits consumed',
 'Healthful Nutrition', 'chart', 'bar_vertical', ARRAY['daily', 'weekly'], 'daily', 'types', true),

('DISP_PROTEIN_VARIETY', 'Protein Variety', 'Track variety of protein sources consumed',
 'Healthful Nutrition', 'chart', 'bar_vertical', ARRAY['daily', 'weekly'], 'daily', 'types', true),

('DISP_FIBER_SOURCE_VARIETY', 'Fiber Source Variety', 'Track variety of fiber sources consumed',
 'Healthful Nutrition', 'chart', 'bar_vertical', ARRAY['daily', 'weekly'], 'daily', 'types', true),

('DISP_LEGUME_VARIETY', 'Legume Variety', 'Track variety of legumes consumed',
 'Healthful Nutrition', 'chart', 'bar_vertical', ARRAY['daily', 'weekly'], 'daily', 'types', true),

('DISP_NUT_SEED_VARIETY', 'Nut/Seed Variety', 'Track variety of nuts and seeds consumed',
 'Healthful Nutrition', 'chart', 'bar_vertical', ARRAY['daily', 'weekly'], 'daily', 'types', true),

('DISP_WHOLE_GRAIN_VARIETY', 'Whole Grain Variety', 'Track variety of whole grains consumed',
 'Healthful Nutrition', 'chart', 'bar_vertical', ARRAY['daily', 'weekly'], 'daily', 'types', true)

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
-- PART 2: Link Display Metrics to Aggregations
-- =====================================================

-- Cardio Sessions: SUM (total) as primary, COUNT_UNIQUE_DAYS (frequency)
INSERT INTO display_metrics_aggregations (display_metric_id, agg_metric_id, period_type, calculation_type_id, is_primary, display_order)
VALUES
('DISP_CARDIO_SESSIONS', 'AGG_CARDIO_SESSION_COUNT', 'weekly', 'SUM', true, 1),
('DISP_CARDIO_SESSIONS', 'AGG_CARDIO_SESSION_COUNT', 'weekly', 'COUNT_UNIQUE_DAYS', false, 2),
('DISP_CARDIO_SESSIONS', 'AGG_CARDIO_SESSION_COUNT', 'monthly', 'SUM', false, 3),
('DISP_CARDIO_SESSIONS', 'AGG_CARDIO_SESSION_COUNT', 'monthly', 'COUNT_UNIQUE_DAYS', false, 4)

ON CONFLICT (display_metric_id, agg_metric_id, period_type, calculation_type_id) DO UPDATE SET
  is_primary = EXCLUDED.is_primary,
  display_order = EXCLUDED.display_order;

-- Strength Sessions: SUM (total) as primary, COUNT_UNIQUE_DAYS (frequency)
INSERT INTO display_metrics_aggregations (display_metric_id, agg_metric_id, period_type, calculation_type_id, is_primary, display_order)
VALUES
('DISP_STRENGTH_SESSIONS', 'AGG_STRENGTH_SESSION_COUNT', 'weekly', 'SUM', true, 1),
('DISP_STRENGTH_SESSIONS', 'AGG_STRENGTH_SESSION_COUNT', 'weekly', 'COUNT_UNIQUE_DAYS', false, 2),
('DISP_STRENGTH_SESSIONS', 'AGG_STRENGTH_SESSION_COUNT', 'monthly', 'SUM', false, 3),
('DISP_STRENGTH_SESSIONS', 'AGG_STRENGTH_SESSION_COUNT', 'monthly', 'COUNT_UNIQUE_DAYS', false, 4)

ON CONFLICT (display_metric_id, agg_metric_id, period_type, calculation_type_id) DO UPDATE SET
  is_primary = EXCLUDED.is_primary,
  display_order = EXCLUDED.display_order;

-- Sleep Sessions: SUM (total) as primary, COUNT_UNIQUE_DAYS (frequency)
INSERT INTO display_metrics_aggregations (display_metric_id, agg_metric_id, period_type, calculation_type_id, is_primary, display_order)
VALUES
('DISP_SLEEP_SESSIONS', 'AGG_SLEEP_SESSION_COUNT', 'weekly', 'SUM', true, 1),
('DISP_SLEEP_SESSIONS', 'AGG_SLEEP_SESSION_COUNT', 'weekly', 'COUNT_UNIQUE_DAYS', false, 2),
('DISP_SLEEP_SESSIONS', 'AGG_SLEEP_SESSION_COUNT', 'monthly', 'SUM', false, 3),
('DISP_SLEEP_SESSIONS', 'AGG_SLEEP_SESSION_COUNT', 'monthly', 'COUNT_UNIQUE_DAYS', false, 4)

ON CONFLICT (display_metric_id, agg_metric_id, period_type, calculation_type_id) DO UPDATE SET
  is_primary = EXCLUDED.is_primary,
  display_order = EXCLUDED.display_order;

-- Vegetable Variety: COUNT_DISTINCT for daily and weekly
INSERT INTO display_metrics_aggregations (display_metric_id, agg_metric_id, period_type, calculation_type_id, is_primary, display_order)
VALUES
('DISP_VEGETABLE_VARIETY', 'AGG_VEGETABLE_VARIETY', 'daily', 'COUNT_DISTINCT', true, 1),
('DISP_VEGETABLE_VARIETY', 'AGG_VEGETABLE_VARIETY', 'weekly', 'COUNT_DISTINCT', false, 2)

ON CONFLICT (display_metric_id, agg_metric_id, period_type, calculation_type_id) DO UPDATE SET
  is_primary = EXCLUDED.is_primary,
  display_order = EXCLUDED.display_order;

-- Fruit Variety: COUNT_DISTINCT for daily and weekly
INSERT INTO display_metrics_aggregations (display_metric_id, agg_metric_id, period_type, calculation_type_id, is_primary, display_order)
VALUES
('DISP_FRUIT_VARIETY', 'AGG_FRUIT_VARIETY', 'daily', 'COUNT_DISTINCT', true, 1),
('DISP_FRUIT_VARIETY', 'AGG_FRUIT_VARIETY', 'weekly', 'COUNT_DISTINCT', false, 2)

ON CONFLICT (display_metric_id, agg_metric_id, period_type, calculation_type_id) DO UPDATE SET
  is_primary = EXCLUDED.is_primary,
  display_order = EXCLUDED.display_order;

-- Protein Variety: COUNT_DISTINCT for daily and weekly
INSERT INTO display_metrics_aggregations (display_metric_id, agg_metric_id, period_type, calculation_type_id, is_primary, display_order)
VALUES
('DISP_PROTEIN_VARIETY', 'AGG_PROTEIN_VARIETY', 'daily', 'COUNT_DISTINCT', true, 1),
('DISP_PROTEIN_VARIETY', 'AGG_PROTEIN_VARIETY', 'weekly', 'COUNT_DISTINCT', false, 2)

ON CONFLICT (display_metric_id, agg_metric_id, period_type, calculation_type_id) DO UPDATE SET
  is_primary = EXCLUDED.is_primary,
  display_order = EXCLUDED.display_order;

-- Fiber Source Variety: COUNT_DISTINCT for daily and weekly
INSERT INTO display_metrics_aggregations (display_metric_id, agg_metric_id, period_type, calculation_type_id, is_primary, display_order)
VALUES
('DISP_FIBER_SOURCE_VARIETY', 'AGG_FIBER_SOURCE_VARIETY', 'daily', 'COUNT_DISTINCT', true, 1),
('DISP_FIBER_SOURCE_VARIETY', 'AGG_FIBER_SOURCE_VARIETY', 'weekly', 'COUNT_DISTINCT', false, 2)

ON CONFLICT (display_metric_id, agg_metric_id, period_type, calculation_type_id) DO UPDATE SET
  is_primary = EXCLUDED.is_primary,
  display_order = EXCLUDED.display_order;

-- Legume Variety: COUNT_DISTINCT for daily and weekly
INSERT INTO display_metrics_aggregations (display_metric_id, agg_metric_id, period_type, calculation_type_id, is_primary, display_order)
VALUES
('DISP_LEGUME_VARIETY', 'AGG_LEGUME_VARIETY', 'daily', 'COUNT_DISTINCT', true, 1),
('DISP_LEGUME_VARIETY', 'AGG_LEGUME_VARIETY', 'weekly', 'COUNT_DISTINCT', false, 2)

ON CONFLICT (display_metric_id, agg_metric_id, period_type, calculation_type_id) DO UPDATE SET
  is_primary = EXCLUDED.is_primary,
  display_order = EXCLUDED.display_order;

-- Nut/Seed Variety: COUNT_DISTINCT for daily and weekly
INSERT INTO display_metrics_aggregations (display_metric_id, agg_metric_id, period_type, calculation_type_id, is_primary, display_order)
VALUES
('DISP_NUT_SEED_VARIETY', 'AGG_NUT_SEED_VARIETY', 'daily', 'COUNT_DISTINCT', true, 1),
('DISP_NUT_SEED_VARIETY', 'AGG_NUT_SEED_VARIETY', 'weekly', 'COUNT_DISTINCT', false, 2)

ON CONFLICT (display_metric_id, agg_metric_id, period_type, calculation_type_id) DO UPDATE SET
  is_primary = EXCLUDED.is_primary,
  display_order = EXCLUDED.display_order;

-- Whole Grain Variety: COUNT_DISTINCT for daily and weekly
INSERT INTO display_metrics_aggregations (display_metric_id, agg_metric_id, period_type, calculation_type_id, is_primary, display_order)
VALUES
('DISP_WHOLE_GRAIN_VARIETY', 'AGG_WHOLE_GRAIN_VARIETY', 'daily', 'COUNT_DISTINCT', true, 1),
('DISP_WHOLE_GRAIN_VARIETY', 'AGG_WHOLE_GRAIN_VARIETY', 'weekly', 'COUNT_DISTINCT', false, 2)

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
  WHERE display_metric_id IN (
    'DISP_CARDIO_SESSIONS', 'DISP_STRENGTH_SESSIONS', 'DISP_SLEEP_SESSIONS',
    'DISP_VEGETABLE_VARIETY', 'DISP_FRUIT_VARIETY', 'DISP_PROTEIN_VARIETY',
    'DISP_FIBER_SOURCE_VARIETY', 'DISP_LEGUME_VARIETY', 'DISP_NUT_SEED_VARIETY',
    'DISP_WHOLE_GRAIN_VARIETY'
  );

  SELECT COUNT(*) INTO links_count FROM display_metrics_aggregations
  WHERE display_metric_id IN (
    'DISP_CARDIO_SESSIONS', 'DISP_STRENGTH_SESSIONS', 'DISP_SLEEP_SESSIONS',
    'DISP_VEGETABLE_VARIETY', 'DISP_FRUIT_VARIETY', 'DISP_PROTEIN_VARIETY',
    'DISP_FIBER_SOURCE_VARIETY', 'DISP_LEGUME_VARIETY', 'DISP_NUT_SEED_VARIETY',
    'DISP_WHOLE_GRAIN_VARIETY'
  );

  RAISE NOTICE '✅ Display Metrics Created for New Aggregations';
  RAISE NOTICE '';
  RAISE NOTICE 'Summary:';
  RAISE NOTICE '  Display Metrics Created: %', metrics_count;
  RAISE NOTICE '  Aggregation Links Created: %', links_count;
  RAISE NOTICE '';
  RAISE NOTICE 'Session Count Display Metrics (Movement + Exercise, Restorative Sleep):';
  RAISE NOTICE '  • DISP_CARDIO_SESSIONS - SUM (primary) + COUNT_UNIQUE_DAYS';
  RAISE NOTICE '  • DISP_STRENGTH_SESSIONS - SUM (primary) + COUNT_UNIQUE_DAYS';
  RAISE NOTICE '  • DISP_SLEEP_SESSIONS - SUM (primary) + COUNT_UNIQUE_DAYS';
  RAISE NOTICE '';
  RAISE NOTICE 'Variety Display Metrics (Healthful Nutrition):';
  RAISE NOTICE '  • DISP_VEGETABLE_VARIETY - COUNT_DISTINCT (daily primary, weekly)';
  RAISE NOTICE '  • DISP_FRUIT_VARIETY - COUNT_DISTINCT (daily primary, weekly)';
  RAISE NOTICE '  • DISP_PROTEIN_VARIETY - COUNT_DISTINCT (daily primary, weekly)';
  RAISE NOTICE '  • DISP_FIBER_SOURCE_VARIETY - COUNT_DISTINCT (daily primary, weekly)';
  RAISE NOTICE '  • DISP_LEGUME_VARIETY - COUNT_DISTINCT (daily primary, weekly)';
  RAISE NOTICE '  • DISP_NUT_SEED_VARIETY - COUNT_DISTINCT (daily primary, weekly)';
  RAISE NOTICE '  • DISP_WHOLE_GRAIN_VARIETY - COUNT_DISTINCT (daily primary, weekly)';
  RAISE NOTICE '';
  RAISE NOTICE 'Ready for UI testing!';
END $$;

COMMIT;
