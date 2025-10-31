-- =====================================================
-- Create Protein Meal Timing Data Entry Fields
-- =====================================================
-- Creates separate fields for breakfast, lunch, dinner, snack
-- Replaces time-based calculation with explicit user selection
-- =====================================================

BEGIN;

-- =====================================================
-- 1. Create Data Entry Fields for Each Meal
-- =====================================================
INSERT INTO data_entry_fields (
  field_id,
  field_name,
  display_name,
  description,
  field_type,
  data_type,
  unit,
  event_type_id,
  supports_healthkit_sync,
  pillar_name,
  is_active
) VALUES
  (
    'DEF_PROTEIN_BREAKFAST',
    'protein_breakfast',
    'Breakfast Protein',
    'Protein consumed at breakfast',
    'quantity',
    'numeric',
    'gram',
    'EVT_PROTEIN',
    false,
    'Healthful Nutrition',
    true
  ),
  (
    'DEF_PROTEIN_LUNCH',
    'protein_lunch',
    'Lunch Protein',
    'Protein consumed at lunch',
    'quantity',
    'numeric',
    'gram',
    'EVT_PROTEIN',
    false,
    'Healthful Nutrition',
    true
  ),
  (
    'DEF_PROTEIN_DINNER',
    'protein_dinner',
    'Dinner Protein',
    'Protein consumed at dinner',
    'quantity',
    'numeric',
    'gram',
    'EVT_PROTEIN',
    false,
    'Healthful Nutrition',
    true
  ),
  (
    'DEF_PROTEIN_SNACK',
    'protein_snack',
    'Snack Protein',
    'Protein consumed as a snack',
    'quantity',
    'numeric',
    'gram',
    'EVT_PROTEIN',
    false,
    'Healthful Nutrition',
    true
  ),
  (
    'DEF_PROTEIN_OTHER',
    'protein_other',
    'Other Protein',
    'Protein consumed at other times',
    'quantity',
    'numeric',
    'gram',
    'EVT_PROTEIN',
    false,
    'Healthful Nutrition',
    true
  )
ON CONFLICT (field_id) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  updated_at = NOW();

-- =====================================================
-- 2. Update Aggregation Dependencies
-- =====================================================
-- Map the meal-specific fields to their aggregations
INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id,
  data_entry_field_id,
  dependency_type
) VALUES
  ('AGG_PROTEIN_BREAKFAST_GRAMS', 'DEF_PROTEIN_BREAKFAST', 'data_field'),
  ('AGG_PROTEIN_LUNCH_GRAMS', 'DEF_PROTEIN_LUNCH', 'data_field'),
  ('AGG_PROTEIN_DINNER_GRAMS', 'DEF_PROTEIN_DINNER', 'data_field')
ON CONFLICT DO NOTHING;

-- =====================================================
-- 3. Add Periods and Calculation Types
-- =====================================================
-- Ensure all meal-specific aggregations have periods
INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
SELECT agg_id, period_id
FROM aggregation_metrics
CROSS JOIN (VALUES ('daily'), ('weekly'), ('monthly'), ('hourly')) AS periods(period_id)
WHERE agg_id IN ('AGG_PROTEIN_BREAKFAST_GRAMS', 'AGG_PROTEIN_LUNCH_GRAMS', 'AGG_PROTEIN_DINNER_GRAMS')
ON CONFLICT DO NOTHING;

-- Ensure calculation types
INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
SELECT agg_id, calc_type
FROM aggregation_metrics
CROSS JOIN (VALUES ('SUM'), ('AVG')) AS calc_types(calc_type)
WHERE agg_id IN ('AGG_PROTEIN_BREAKFAST_GRAMS', 'AGG_PROTEIN_LUNCH_GRAMS', 'AGG_PROTEIN_DINNER_GRAMS')
ON CONFLICT DO NOTHING;

-- =====================================================
-- Summary
-- =====================================================
DO $$
DECLARE
  v_fields_count INTEGER;
  v_deps_count INTEGER;
BEGIN
  -- Count new fields
  SELECT COUNT(*) INTO v_fields_count
  FROM data_entry_fields
  WHERE field_id IN ('DEF_PROTEIN_BREAKFAST', 'DEF_PROTEIN_LUNCH', 'DEF_PROTEIN_DINNER', 'DEF_PROTEIN_SNACK', 'DEF_PROTEIN_OTHER');

  -- Count dependencies
  SELECT COUNT(*) INTO v_deps_count
  FROM aggregation_metrics_dependencies
  WHERE data_entry_field_id IN ('DEF_PROTEIN_BREAKFAST', 'DEF_PROTEIN_LUNCH', 'DEF_PROTEIN_DINNER');

  RAISE NOTICE '';
  RAISE NOTICE '✅ Created Protein Meal Timing Fields!';
  RAISE NOTICE '';
  RAISE NOTICE 'Summary:';
  RAISE NOTICE '  Data entry fields created: %', v_fields_count;
  RAISE NOTICE '  Aggregation dependencies: %', v_deps_count;
  RAISE NOTICE '';
  RAISE NOTICE 'New fields:';
  RAISE NOTICE '  • DEF_PROTEIN_BREAKFAST → AGG_PROTEIN_BREAKFAST_GRAMS';
  RAISE NOTICE '  • DEF_PROTEIN_LUNCH → AGG_PROTEIN_LUNCH_GRAMS';
  RAISE NOTICE '  • DEF_PROTEIN_DINNER → AGG_PROTEIN_DINNER_GRAMS';
  RAISE NOTICE '  • DEF_PROTEIN_SNACK (no aggregation yet)';
  RAISE NOTICE '  • DEF_PROTEIN_OTHER (no aggregation yet)';
  RAISE NOTICE '';
  RAISE NOTICE 'User can now explicitly select meal timing when entering protein!';
  RAISE NOTICE '';
END $$;

COMMIT;
