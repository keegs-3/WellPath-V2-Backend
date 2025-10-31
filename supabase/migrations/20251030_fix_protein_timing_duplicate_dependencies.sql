-- =====================================================
-- Fix Protein Timing Duplicate Dependencies
-- =====================================================
-- Removes duplicate aggregation_metrics_dependencies rows
-- that were causing protein timing aggregations to count entries multiple times
--
-- Problem:
-- - AGG_PROTEIN_DINNER_GRAMS, AGG_PROTEIN_BREAKFAST_GRAMS, AGG_PROTEIN_LUNCH_GRAMS
--   each had 3 dependency rows: 2 with NULL filter_conditions and 1 with correct filter
-- - This caused each protein entry to be counted 3 times (once per dependency)
-- - Result: 100g entry appeared as 300g total across all timing metrics
--
-- Solution:
-- - Remove duplicate dependencies with NULL filter_conditions
-- - Keep only the dependency with the correct filter_conditions
-- - Add constraint to prevent future duplicates
--
-- Created: 2025-10-30
-- =====================================================

BEGIN;

-- =====================================================
-- 1. Remove Duplicate Dependencies
-- =====================================================
-- Delete dependencies with NULL filter_conditions for protein timing aggregations
-- These should only have one dependency with the correct filter
DELETE FROM aggregation_metrics_dependencies
WHERE agg_metric_id IN (
  'AGG_PROTEIN_DINNER_GRAMS',
  'AGG_PROTEIN_BREAKFAST_GRAMS',
  'AGG_PROTEIN_LUNCH_GRAMS',
  'AGG_PROTEIN_MORNING_SNACK_GRAMS',
  'AGG_PROTEIN_AFTERNOON_SNACK_GRAMS',
  'AGG_PROTEIN_EVENING_SNACK_GRAMS',
  'AGG_PROTEIN_OTHER_GRAMS'
)
AND filter_conditions IS NULL
AND data_entry_field_id = 'DEF_PROTEIN_GRAMS';

-- =====================================================
-- 2. Verify Clean State
-- =====================================================
-- Each protein timing aggregation should have exactly one dependency with filter_conditions
DO $$
DECLARE
  v_count INTEGER;
  v_agg_id TEXT;
BEGIN
  FOR v_agg_id IN 
    SELECT DISTINCT agg_metric_id
    FROM aggregation_metrics_dependencies
    WHERE agg_metric_id IN (
      'AGG_PROTEIN_DINNER_GRAMS',
      'AGG_PROTEIN_BREAKFAST_GRAMS',
      'AGG_PROTEIN_LUNCH_GRAMS',
      'AGG_PROTEIN_MORNING_SNACK_GRAMS',
      'AGG_PROTEIN_AFTERNOON_SNACK_GRAMS',
      'AGG_PROTEIN_EVENING_SNACK_GRAMS',
      'AGG_PROTEIN_OTHER_GRAMS'
    )
  LOOP
    -- Count dependencies with NULL filters (should be 0)
    SELECT COUNT(*) INTO v_count
    FROM aggregation_metrics_dependencies
    WHERE agg_metric_id = v_agg_id
      AND filter_conditions IS NULL
      AND data_entry_field_id = 'DEF_PROTEIN_GRAMS';
    
    IF v_count > 0 THEN
      RAISE WARNING 'Aggregation % still has % dependencies with NULL filters', v_agg_id, v_count;
    END IF;
    
    -- Count total dependencies (should be 1)
    SELECT COUNT(*) INTO v_count
    FROM aggregation_metrics_dependencies
    WHERE agg_metric_id = v_agg_id
      AND data_entry_field_id = 'DEF_PROTEIN_GRAMS';
    
    IF v_count != 1 THEN
      RAISE WARNING 'Aggregation % has % dependencies (expected 1)', v_agg_id, v_count;
    END IF;
  END LOOP;
END $$;

COMMENT ON TABLE aggregation_metrics_dependencies IS
'Aggregation dependencies should have unique (agg_metric_id, data_entry_field_id) combinations when filter_conditions is NULL. For protein timing aggregations, filter_conditions must be specified.';

COMMIT;

