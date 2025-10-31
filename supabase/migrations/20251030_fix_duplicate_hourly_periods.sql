-- =====================================================
-- Fix Duplicate Hourly Period Entries
-- =====================================================
-- Removes duplicate hourly period entries for protein metrics
-- Prevents multiple hourly periods from being added in the future
--
-- Problem:
-- - Some protein metrics had 4 duplicate hourly period entries
-- - This didn't cause functional issues but was data bloat
--
-- Solution:
-- - Remove duplicates, keeping only one hourly entry per metric
-- - Add unique constraint to prevent future duplicates
--
-- Created: 2025-10-30
-- =====================================================

BEGIN;

-- =====================================================
-- 1. Remove Duplicate Hourly Period Entries
-- =====================================================
-- Keep only one hourly period entry per aggregation metric
DELETE FROM aggregation_metrics_periods
WHERE ctid NOT IN (
  SELECT MIN(ctid)
  FROM aggregation_metrics_periods
  WHERE period_id = 'hourly'
  GROUP BY agg_metric_id
)
AND period_id = 'hourly';

-- =====================================================
-- 2. Add Unique Constraint to Prevent Future Duplicates
-- =====================================================
-- Ensure each (agg_metric_id, period_id) combination is unique
DO $$
BEGIN
  -- Check if constraint already exists
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'aggregation_metrics_periods_agg_period_unique'
  ) THEN
    ALTER TABLE aggregation_metrics_periods
    ADD CONSTRAINT aggregation_metrics_periods_agg_period_unique
    UNIQUE (agg_metric_id, period_id);
    
    RAISE NOTICE 'Added unique constraint on (agg_metric_id, period_id)';
  ELSE
    RAISE NOTICE 'Unique constraint already exists';
  END IF;
END $$;

-- =====================================================
-- 3. Verify Clean State
-- =====================================================
DO $$
DECLARE
  v_duplicate_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_duplicate_count
  FROM (
    SELECT agg_metric_id, period_id, COUNT(*) as cnt
    FROM aggregation_metrics_periods
    GROUP BY agg_metric_id, period_id
    HAVING COUNT(*) > 1
  ) duplicates;
  
  IF v_duplicate_count > 0 THEN
    RAISE WARNING 'Found % duplicate (agg_metric_id, period_id) combinations', v_duplicate_count;
  ELSE
    RAISE NOTICE 'No duplicate periods found - cleanup successful';
  END IF;
END $$;

COMMENT ON TABLE aggregation_metrics_periods IS
'Each aggregation metric can have multiple period types, but (agg_metric_id, period_id) must be unique. Unique constraint prevents duplicate hourly/daily/weekly entries.';

COMMIT;

