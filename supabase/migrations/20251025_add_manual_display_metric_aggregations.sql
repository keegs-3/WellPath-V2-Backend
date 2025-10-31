-- =====================================================
-- Add Manually Curated Display Metric Aggregations
-- =====================================================
-- For metrics that couldn't be auto-matched
-- =====================================================

BEGIN;

-- Plant Protein Metrics (use AGG_PLANTBASED_PROTEIN instead of AGG_PLANT_GRAMS)
INSERT INTO display_metrics_aggregations (metric_id, agg_metric_id, period_type, calculation_type_id, display_order)
VALUES
  ('DISP_PLANT_PROTEIN_GRAMS', 'AGG_PLANTBASED_PROTEIN', 'daily', 'SUM', 1),
  ('DISP_PLANT_PROTEIN_GRAMS', 'AGG_PLANTBASED_PROTEIN', 'weekly', 'AVG', 2),
  ('DISP_PLANT_PROTEIN_GRAMS', 'AGG_PLANTBASED_PROTEIN', 'monthly', 'AVG', 3)
ON CONFLICT (metric_id, agg_metric_id, period_type, calculation_type_id) DO NOTHING;

INSERT INTO display_metrics_aggregations (metric_id, agg_metric_id, period_type, calculation_type_id, display_order)
VALUES
  ('DISP_PLANT_PROTEIN_PCT', 'AGG_PLANTBASED_PROTEIN_PERCENTAGE', 'daily', 'AVG', 1),
  ('DISP_PLANT_PROTEIN_PCT', 'AGG_PLANTBASED_PROTEIN_PERCENTAGE', 'weekly', 'AVG', 2),
  ('DISP_PLANT_PROTEIN_PCT', 'AGG_PLANTBASED_PROTEIN_PERCENTAGE', 'monthly', 'AVG', 3)
ON CONFLICT (metric_id, agg_metric_id, period_type, calculation_type_id) DO NOTHING;

-- Protein Meal Timing (use protein breakfast/lunch/dinner aggregations)
INSERT INTO display_metrics_aggregations (metric_id, agg_metric_id, period_type, calculation_type_id, display_order)
VALUES
  ('DISP_PROTEIN_MEAL_TIMING', 'AGG_PROTEIN_BREAKFAST_GRAMS', 'daily', 'SUM', 1),
  ('DISP_PROTEIN_MEAL_TIMING', 'AGG_PROTEIN_LUNCH_GRAMS', 'daily', 'SUM', 2),
  ('DISP_PROTEIN_MEAL_TIMING', 'AGG_PROTEIN_DINNER_GRAMS', 'daily', 'SUM', 3),
  ('DISP_PROTEIN_MEAL_TIMING', 'AGG_PROTEIN_BREAKFAST_GRAMS', 'weekly', 'AVG', 4),
  ('DISP_PROTEIN_MEAL_TIMING', 'AGG_PROTEIN_LUNCH_GRAMS', 'weekly', 'AVG', 5),
  ('DISP_PROTEIN_MEAL_TIMING', 'AGG_PROTEIN_DINNER_GRAMS', 'weekly', 'AVG', 6)
ON CONFLICT (metric_id, agg_metric_id, period_type, calculation_type_id) DO NOTHING;

-- Protein per Kg (body weight normalized)
INSERT INTO display_metrics_aggregations (metric_id, agg_metric_id, period_type, calculation_type_id, display_order)
VALUES
  ('DISP_PROTEIN_PER_KG', 'AGG_PROTEIN_PER_KILOGRAM_BODY_WEIGHT', 'daily', 'AVG', 1),
  ('DISP_PROTEIN_PER_KG', 'AGG_PROTEIN_PER_KILOGRAM_BODY_WEIGHT', 'weekly', 'AVG', 2),
  ('DISP_PROTEIN_PER_KG', 'AGG_PROTEIN_PER_KILOGRAM_BODY_WEIGHT', 'monthly', 'AVG', 3)
ON CONFLICT (metric_id, agg_metric_id, period_type, calculation_type_id) DO NOTHING;

-- NOTE: Blood pressure, waist-hip ratio, caffeine timing, and sunscreen events
-- aggregation metrics don't exist yet. Skipping these for now.
-- They need to be created in aggregation_metrics first.

INSERT INTO display_metrics_aggregations (metric_id, agg_metric_id, period_type, calculation_type_id, display_order)
VALUES
  ('DISP_SUNLIGHT_SESSIONS', 'AGG_SUNLIGHT_EXPOSURE_SESSIONS', 'daily', 'SUM', 1),
  ('DISP_SUNLIGHT_SESSIONS', 'AGG_SUNLIGHT_EXPOSURE_SESSIONS', 'weekly', 'AVG', 2),
  ('DISP_SUNLIGHT_SESSIONS', 'AGG_SUNLIGHT_EXPOSURE_SESSIONS', 'monthly', 'AVG', 3)
ON CONFLICT (metric_id, agg_metric_id, period_type, calculation_type_id) DO NOTHING;

INSERT INTO display_metrics_aggregations (metric_id, agg_metric_id, period_type, calculation_type_id, display_order)
VALUES
  ('DISP_OUTDOOR_SESSIONS', 'AGG_OUTDOOR_TIME_SESSIONS', 'daily', 'SUM', 1),
  ('DISP_OUTDOOR_SESSIONS', 'AGG_OUTDOOR_TIME_SESSIONS', 'weekly', 'AVG', 2),
  ('DISP_OUTDOOR_SESSIONS', 'AGG_OUTDOOR_TIME_SESSIONS', 'monthly', 'AVG', 3)
ON CONFLICT (metric_id, agg_metric_id, period_type, calculation_type_id) DO NOTHING;

-- NOTE: Alcohol vs baseline aggregation metric doesn't exist yet.

-- Verification
DO $$
DECLARE
  v_total_metrics INTEGER;
  v_metrics_with_aggs INTEGER;
  v_total_mappings INTEGER;
  v_coverage_pct NUMERIC;
BEGIN
  SELECT COUNT(*) INTO v_total_metrics FROM display_metrics;
  SELECT COUNT(DISTINCT metric_id) INTO v_metrics_with_aggs FROM display_metrics_aggregations;
  SELECT COUNT(*) INTO v_total_mappings FROM display_metrics_aggregations;
  v_coverage_pct := ROUND((v_metrics_with_aggs::NUMERIC / v_total_metrics) * 100, 1);

  RAISE NOTICE '';
  RAISE NOTICE '✅ Manual Display Metric Aggregations Added!';
  RAISE NOTICE '';
  RAISE NOTICE 'Final Summary:';
  RAISE NOTICE '  Total display metrics: %', v_total_metrics;
  RAISE NOTICE '  Metrics with aggregations: %', v_metrics_with_aggs;
  RAISE NOTICE '  Total aggregation mappings: %', v_total_mappings;
  RAISE NOTICE '  Coverage: % percent', v_coverage_pct;
  RAISE NOTICE '';

  IF v_coverage_pct >= 80 THEN
    RAISE NOTICE '🎉 Excellent coverage! Most display metrics now have aggregations.';
  ELSIF v_coverage_pct >= 70 THEN
    RAISE NOTICE '✅ Good coverage. Review remaining unmapped metrics.';
  ELSE
    RAISE WARNING '⚠️  Coverage below 70 percent. More work needed.';
  END IF;
END $$;

COMMIT;
