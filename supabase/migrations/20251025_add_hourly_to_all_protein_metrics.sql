-- =====================================================
-- Add Hourly Periods to All Protein Metrics
-- =====================================================
-- Adds hourly period support to all protein aggregations
-- for day view functionality in the mobile app
-- =====================================================

BEGIN;

-- =====================================================
-- 1. Add Hourly Periods to Aggregation Metrics
-- =====================================================
INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES
  -- Protein by meal timing
  ('AGG_PROTEIN_BREAKFAST_GRAMS', 'hourly'),
  ('AGG_PROTEIN_LUNCH_GRAMS', 'hourly'),
  ('AGG_PROTEIN_DINNER_GRAMS', 'hourly'),

  -- Protein ratio
  ('AGG_PROTEIN_PER_KILOGRAM_BODY_WEIGHT', 'hourly'),

  -- Protein types (all 6)
  ('AGG_PROTEIN_TYPE_FATTY_FISH', 'hourly'),
  ('AGG_PROTEIN_TYPE_LEAN_PROTEIN', 'hourly'),
  ('AGG_PROTEIN_TYPE_PLANT_BASED', 'hourly'),
  ('AGG_PROTEIN_TYPE_PROCESSED_MEAT', 'hourly'),
  ('AGG_PROTEIN_TYPE_RED_MEAT', 'hourly'),
  ('AGG_PROTEIN_TYPE_SUPPLEMENT', 'hourly'),

  -- Other protein metrics
  ('AGG_PROTEIN_VARIETY', 'hourly'),
  ('AGG_PROTEIN_GRAMS_TO_SERVINGS', 'hourly'),
  ('AGG_PROTEIN_SERVINGS_TO_GRAMS', 'hourly')
ON CONFLICT DO NOTHING;

-- =====================================================
-- 2. Add Calculation Types for Hourly Aggregations
-- =====================================================
-- Add SUM calculation type for hourly periods where needed
INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
SELECT DISTINCT agg_metric_id, 'SUM'
FROM aggregation_metrics_periods
WHERE agg_metric_id LIKE 'AGG_PROTEIN%'
  AND period_id = 'hourly'
  AND NOT EXISTS (
    SELECT 1 FROM aggregation_metrics_calculation_types
    WHERE aggregation_metric_id = agg_metric_id
      AND calculation_type_id = 'SUM'
  )
ON CONFLICT DO NOTHING;

-- =====================================================
-- 3. Add Hourly Mappings to Display Metrics
-- =====================================================
-- Add hourly SUM for protein type display metric
INSERT INTO display_metrics_aggregations (
  metric_id,
  agg_metric_id,
  period_type,
  calculation_type_id,
  display_order
) VALUES
  -- Hourly SUM for all 6 types (for day view)
  ('DISP_PROTEIN_TYPE', 'AGG_PROTEIN_TYPE_FATTY_FISH', 'hourly', 'SUM', 13),
  ('DISP_PROTEIN_TYPE', 'AGG_PROTEIN_TYPE_LEAN_PROTEIN', 'hourly', 'SUM', 14),
  ('DISP_PROTEIN_TYPE', 'AGG_PROTEIN_TYPE_PLANT_BASED', 'hourly', 'SUM', 15),
  ('DISP_PROTEIN_TYPE', 'AGG_PROTEIN_TYPE_PROCESSED_MEAT', 'hourly', 'SUM', 16),
  ('DISP_PROTEIN_TYPE', 'AGG_PROTEIN_TYPE_RED_MEAT', 'hourly', 'SUM', 17),
  ('DISP_PROTEIN_TYPE', 'AGG_PROTEIN_TYPE_SUPPLEMENT', 'hourly', 'SUM', 18)
ON CONFLICT DO NOTHING;

-- Add hourly SUM for protein meal timing
INSERT INTO display_metrics_aggregations (
  metric_id,
  agg_metric_id,
  period_type,
  calculation_type_id,
  display_order
) VALUES
  ('DISP_PROTEIN_MEAL_TIMING', 'AGG_PROTEIN_BREAKFAST_GRAMS', 'hourly', 'SUM', 7),
  ('DISP_PROTEIN_MEAL_TIMING', 'AGG_PROTEIN_LUNCH_GRAMS', 'hourly', 'SUM', 8),
  ('DISP_PROTEIN_MEAL_TIMING', 'AGG_PROTEIN_DINNER_GRAMS', 'hourly', 'SUM', 9)
ON CONFLICT DO NOTHING;

-- Add hourly for protein per kg
INSERT INTO display_metrics_aggregations (
  metric_id,
  agg_metric_id,
  period_type,
  calculation_type_id,
  display_order
) VALUES
  ('DISP_PROTEIN_PER_KG', 'AGG_PROTEIN_PER_KILOGRAM_BODY_WEIGHT', 'hourly', 'AVG', 4)
ON CONFLICT DO NOTHING;

-- =====================================================
-- Summary
-- =====================================================
DO $$
DECLARE
  v_hourly_periods INTEGER;
  v_hourly_display_mappings INTEGER;
BEGIN
  -- Count hourly periods
  SELECT COUNT(*) INTO v_hourly_periods
  FROM aggregation_metrics_periods
  WHERE agg_metric_id LIKE 'AGG_PROTEIN%'
    AND period_id = 'hourly';

  -- Count hourly display mappings
  SELECT COUNT(*) INTO v_hourly_display_mappings
  FROM display_metrics_aggregations
  WHERE metric_id LIKE 'DISP_PROTEIN%'
    AND period_type = 'hourly';

  RAISE NOTICE '';
  RAISE NOTICE '✅ Added Hourly Support to Protein Metrics!';
  RAISE NOTICE '';
  RAISE NOTICE 'Summary:';
  RAISE NOTICE '  Protein aggregations with hourly: %', v_hourly_periods;
  RAISE NOTICE '  Display metrics with hourly mappings: %', v_hourly_display_mappings;
  RAISE NOTICE '';
  RAISE NOTICE 'Day view ready metrics:';
  RAISE NOTICE '  • DISP_PROTEIN_GRAMS (already had hourly)';
  RAISE NOTICE '  • DISP_PROTEIN_TYPE (6 types × hourly SUM)';
  RAISE NOTICE '  • DISP_PROTEIN_MEAL_TIMING (3 meals × hourly SUM)';
  RAISE NOTICE '  • DISP_PROTEIN_PER_KG (hourly AVG)';
  RAISE NOTICE '';
END $$;

COMMIT;
