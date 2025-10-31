-- =====================================================
-- Add All Protein Timing Aggregations
-- =====================================================
-- Creates aggregations for all 7 protein timing options
-- =====================================================

BEGIN;

-- =====================================================
-- 1. Create Missing Timing Aggregations
-- =====================================================

-- Morning Snack
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description, output_unit, is_active
) VALUES (
  'AGG_PROTEIN_MORNING_SNACK_GRAMS',
  'protein_morning_snack_grams',
  'Morning Snack Protein',
  'Protein consumed during morning snack',
  'gram',
  true
) ON CONFLICT (agg_id) DO NOTHING;

-- Afternoon Snack
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description, output_unit, is_active
) VALUES (
  'AGG_PROTEIN_AFTERNOON_SNACK_GRAMS',
  'protein_afternoon_snack_grams',
  'Afternoon Snack Protein',
  'Protein consumed during afternoon snack',
  'gram',
  true
) ON CONFLICT (agg_id) DO NOTHING;

-- Evening Snack
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description, output_unit, is_active
) VALUES (
  'AGG_PROTEIN_EVENING_SNACK_GRAMS',
  'protein_evening_snack_grams',
  'Evening Snack Protein',
  'Protein consumed during evening snack',
  'gram',
  true
) ON CONFLICT (agg_id) DO NOTHING;

-- Other
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description, output_unit, is_active
) VALUES (
  'AGG_PROTEIN_OTHER_GRAMS',
  'protein_other_grams',
  'Other Timing Protein',
  'Protein consumed at other times',
  'gram',
  true
) ON CONFLICT (agg_id) DO NOTHING;

-- =====================================================
-- 2. Add Periods for New Aggregations
-- =====================================================

INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
SELECT agg_id, period
FROM (VALUES
  ('AGG_PROTEIN_MORNING_SNACK_GRAMS'),
  ('AGG_PROTEIN_AFTERNOON_SNACK_GRAMS'),
  ('AGG_PROTEIN_EVENING_SNACK_GRAMS'),
  ('AGG_PROTEIN_OTHER_GRAMS')
) AS aggs(agg_id)
CROSS JOIN (VALUES ('hourly'), ('daily'), ('weekly'), ('monthly'), ('6month'), ('yearly')) AS periods(period)
ON CONFLICT DO NOTHING;

-- =====================================================
-- 3. Add Calculation Types
-- =====================================================

INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
SELECT agg_id, calc_type
FROM (VALUES
  ('AGG_PROTEIN_MORNING_SNACK_GRAMS'),
  ('AGG_PROTEIN_AFTERNOON_SNACK_GRAMS'),
  ('AGG_PROTEIN_EVENING_SNACK_GRAMS'),
  ('AGG_PROTEIN_OTHER_GRAMS')
) AS aggs(agg_id)
CROSS JOIN (VALUES ('SUM'), ('AVG')) AS calc_types(calc_type)
ON CONFLICT DO NOTHING;

-- =====================================================
-- 4. Add Dependencies (with filter conditions)
-- =====================================================

-- Morning Snack
INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_PROTEIN_MORNING_SNACK_GRAMS',
  'DEF_PROTEIN_GRAMS',
  'data_field',
  '{"reference_field": "DEF_PROTEIN_TIMING", "reference_value": "morning_snack"}'::jsonb
) ON CONFLICT DO NOTHING;

-- Afternoon Snack
INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_PROTEIN_AFTERNOON_SNACK_GRAMS',
  'DEF_PROTEIN_GRAMS',
  'data_field',
  '{"reference_field": "DEF_PROTEIN_TIMING", "reference_value": "afternoon_snack"}'::jsonb
) ON CONFLICT DO NOTHING;

-- Evening Snack
INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_PROTEIN_EVENING_SNACK_GRAMS',
  'DEF_PROTEIN_GRAMS',
  'data_field',
  '{"reference_field": "DEF_PROTEIN_TIMING", "reference_value": "evening_snack"}'::jsonb
) ON CONFLICT DO NOTHING;

-- Other
INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_PROTEIN_OTHER_GRAMS',
  'DEF_PROTEIN_GRAMS',
  'data_field',
  '{"reference_field": "DEF_PROTEIN_TIMING", "reference_value": "other"}'::jsonb
) ON CONFLICT DO NOTHING;

-- =====================================================
-- 5. Update Display Metric to Include All 7 Timings
-- =====================================================

-- Add display_metrics_aggregations for the 4 new timing aggregations
INSERT INTO display_metrics_aggregations (metric_id, agg_metric_id, period_type, calculation_type_id, display_order)
VALUES
  -- Morning Snack - Daily
  ('DISP_PROTEIN_MEAL_TIMING', 'AGG_PROTEIN_MORNING_SNACK_GRAMS', 'daily', 'SUM', 10),
  -- Afternoon Snack - Daily
  ('DISP_PROTEIN_MEAL_TIMING', 'AGG_PROTEIN_AFTERNOON_SNACK_GRAMS', 'daily', 'SUM', 11),
  -- Evening Snack - Daily
  ('DISP_PROTEIN_MEAL_TIMING', 'AGG_PROTEIN_EVENING_SNACK_GRAMS', 'daily', 'SUM', 12),
  -- Other - Daily
  ('DISP_PROTEIN_MEAL_TIMING', 'AGG_PROTEIN_OTHER_GRAMS', 'daily', 'SUM', 13),

  -- Morning Snack - Weekly
  ('DISP_PROTEIN_MEAL_TIMING', 'AGG_PROTEIN_MORNING_SNACK_GRAMS', 'weekly', 'AVG', 20),
  -- Afternoon Snack - Weekly
  ('DISP_PROTEIN_MEAL_TIMING', 'AGG_PROTEIN_AFTERNOON_SNACK_GRAMS', 'weekly', 'AVG', 21),
  -- Evening Snack - Weekly
  ('DISP_PROTEIN_MEAL_TIMING', 'AGG_PROTEIN_EVENING_SNACK_GRAMS', 'weekly', 'AVG', 22),
  -- Other - Weekly
  ('DISP_PROTEIN_MEAL_TIMING', 'AGG_PROTEIN_OTHER_GRAMS', 'weekly', 'AVG', 23),

  -- Hourly versions
  ('DISP_PROTEIN_MEAL_TIMING', 'AGG_PROTEIN_MORNING_SNACK_GRAMS', 'hourly', 'SUM', 30),
  ('DISP_PROTEIN_MEAL_TIMING', 'AGG_PROTEIN_AFTERNOON_SNACK_GRAMS', 'hourly', 'SUM', 31),
  ('DISP_PROTEIN_MEAL_TIMING', 'AGG_PROTEIN_EVENING_SNACK_GRAMS', 'hourly', 'SUM', 32),
  ('DISP_PROTEIN_MEAL_TIMING', 'AGG_PROTEIN_OTHER_GRAMS', 'hourly', 'SUM', 33)
ON CONFLICT DO NOTHING;

-- =====================================================
-- Summary
-- =====================================================

DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '✅ All Protein Timing Aggregations Added!';
  RAISE NOTICE '';
  RAISE NOTICE 'Created 4 new aggregations:';
  RAISE NOTICE '  • AGG_PROTEIN_MORNING_SNACK_GRAMS';
  RAISE NOTICE '  • AGG_PROTEIN_AFTERNOON_SNACK_GRAMS';
  RAISE NOTICE '  • AGG_PROTEIN_EVENING_SNACK_GRAMS';
  RAISE NOTICE '  • AGG_PROTEIN_OTHER_GRAMS';
  RAISE NOTICE '';
  RAISE NOTICE 'Total: 7 protein timing aggregations';
  RAISE NOTICE '  (breakfast, lunch, dinner, morning snack, afternoon snack, evening snack, other)';
  RAISE NOTICE '';
  RAISE NOTICE 'Updated DISP_PROTEIN_MEAL_TIMING to include all 7';
  RAISE NOTICE 'Now use stacked bars instead of grouped bars';
  RAISE NOTICE '';
END $$;

COMMIT;
