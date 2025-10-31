-- =====================================================
-- Populate Critical Aggregation Dependencies
-- =====================================================
-- Maps data_entry_fields → aggregation_metrics
-- This is REQUIRED for aggregations to work!
-- =====================================================

BEGIN;

-- Protein Dependencies
INSERT INTO aggregation_metrics_dependencies (agg_metric_id, data_entry_field_id, dependency_type)
VALUES
  ('AGG_PROTEIN_GRAMS', 'DEF_PROTEIN_GRAMS', 'data_field'),
  ('AGG_PROTEIN_BREAKFAST_GRAMS', 'DEF_PROTEIN_GRAMS', 'data_field'),
  ('AGG_PROTEIN_LUNCH_GRAMS', 'DEF_PROTEIN_GRAMS', 'data_field'),
  ('AGG_PROTEIN_DINNER_GRAMS', 'DEF_PROTEIN_GRAMS', 'data_field'),
  ('AGG_PROTEIN_PER_KILOGRAM_BODY_WEIGHT', 'DEF_PROTEIN_GRAMS', 'data_field'),
  ('AGG_PROTEIN_PER_KILOGRAM_BODY_WEIGHT', 'DEF_WEIGHT', 'data_field'),
  ('AGG_PLANTBASED_PROTEIN', 'DEF_PROTEIN_GRAMS', 'data_field'),
  ('AGG_PLANTBASED_PROTEIN_PERCENTAGE', 'DEF_PROTEIN_GRAMS', 'data_field')
ON CONFLICT DO NOTHING;

-- Steps
INSERT INTO aggregation_metrics_dependencies (agg_metric_id, data_entry_field_id, dependency_type)
VALUES
  ('AGG_STEPS', 'DEF_STEPS', 'data_field')
ON CONFLICT DO NOTHING;

-- Fiber
INSERT INTO aggregation_metrics_dependencies (agg_metric_id, data_entry_field_id, dependency_type)
VALUES
  ('AGG_FIBER_GRAMS', 'DEF_FIBER_GRAMS', 'data_field'),
  ('AGG_FIBER_SERVINGS', 'DEF_FIBER_GRAMS', 'data_field'),
  ('AGG_FIBER_SOURCE_COUNT', 'DEF_FIBER_SOURCE', 'data_field')
ON CONFLICT DO NOTHING;

-- Water
INSERT INTO aggregation_metrics_dependencies (agg_metric_id, data_entry_field_id, dependency_type)
VALUES
  ('AGG_WATER_QUANTITY', 'DEF_WATER_QUANTITY', 'data_field')
ON CONFLICT DO NOTHING;

-- Weight & Body Composition
INSERT INTO aggregation_metrics_dependencies (agg_metric_id, data_entry_field_id, dependency_type)
VALUES
  ('AGG_WEIGHT', 'DEF_WEIGHT', 'data_field'),
  ('AGG_BMI', 'DEF_WEIGHT', 'data_field'),
  ('AGG_BMI', 'DEF_HEIGHT', 'data_field')
ON CONFLICT DO NOTHING;

-- Cardio/Exercise
INSERT INTO aggregation_metrics_dependencies (agg_metric_id, data_entry_field_id, dependency_type)
VALUES
  ('AGG_CARDIO_DURATION', 'DEF_CARDIO_START', 'data_field'),
  ('AGG_CARDIO_DURATION', 'DEF_CARDIO_END', 'data_field'),
  ('AGG_CARDIO_SESSIONS', 'DEF_CARDIO_TYPE', 'data_field'),
  ('AGG_CARDIO_CALORIES', 'DEF_CARDIO_CALORIES', 'data_field')
ON CONFLICT DO NOTHING;

-- Sleep
INSERT INTO aggregation_metrics_dependencies (agg_metric_id, data_entry_field_id, dependency_type)
VALUES
  ('AGG_TOTAL_SLEEP_DURATION', 'DEF_CORE_SLEEP_START', 'data_field'),
  ('AGG_TOTAL_SLEEP_DURATION', 'DEF_CORE_SLEEP_END', 'data_field'),
  ('AGG_REM_SLEEP_DURATION', 'DEF_REM_SLEEP_START', 'data_field'),
  ('AGG_REM_SLEEP_DURATION', 'DEF_REM_SLEEP_END', 'data_field'),
  ('AGG_DEEP_SLEEP_DURATION', 'DEF_DEEP_SLEEP_START', 'data_field'),
  ('AGG_DEEP_SLEEP_DURATION', 'DEF_DEEP_SLEEP_END', 'data_field'),
  ('AGG_AWAKE_DURATION', 'DEF_AWAKE_PERIODS_START', 'data_field'),
  ('AGG_AWAKE_DURATION', 'DEF_AWAKE_PERIODS_END', 'data_field')
ON CONFLICT DO NOTHING;

DO $$
DECLARE
  v_total_deps INTEGER;
  v_unique_aggs INTEGER;
  v_unique_fields INTEGER;
BEGIN
  SELECT COUNT(*), COUNT(DISTINCT agg_metric_id), COUNT(DISTINCT data_entry_field_id)
  INTO v_total_deps, v_unique_aggs, v_unique_fields
  FROM aggregation_metrics_dependencies
  WHERE dependency_type = 'field';

  RAISE NOTICE '';
  RAISE NOTICE '✅ Populated Critical Aggregation Dependencies!';
  RAISE NOTICE '';
  RAISE NOTICE 'Summary:';
  RAISE NOTICE '  Total dependencies: %', v_total_deps;
  RAISE NOTICE '  Unique aggregation metrics: %', v_unique_aggs;
  RAISE NOTICE '  Unique data entry fields: %', v_unique_fields;
  RAISE NOTICE '';
  RAISE NOTICE 'Aggregations will now calculate automatically!';
  RAISE NOTICE '';
END $$;

COMMIT;
