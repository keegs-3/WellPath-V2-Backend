-- =====================================================
-- Consolidate Sleep Duration Metrics
-- =====================================================
-- Removes duplicate AGG_TOTAL_SLEEP_DURATION metric
-- Updates all references to use AGG_SLEEP_DURATION (minutes)
--
-- Created: 2025-10-29
-- =====================================================

BEGIN;

-- =====================================================
-- 1. Update display_metrics_aggregations to use AGG_SLEEP_DURATION
-- =====================================================

-- First, let's see what we're changing
DO $$
BEGIN
    RAISE NOTICE 'Updating display_metrics_aggregations references from AGG_TOTAL_SLEEP_DURATION to AGG_SLEEP_DURATION...';
END $$;

-- Update any display_metrics_aggregations pointing to the duplicate
UPDATE display_metrics_aggregations
SET agg_metric_id = 'AGG_SLEEP_DURATION'
WHERE agg_metric_id = 'AGG_TOTAL_SLEEP_DURATION';

-- =====================================================
-- 3. Delete cache entries for duplicate metric
-- =====================================================

DELETE FROM aggregation_results_cache
WHERE agg_metric_id = 'AGG_TOTAL_SLEEP_DURATION';

-- =====================================================
-- 4. Delete dependencies for duplicate metric
-- =====================================================

DELETE FROM aggregation_metrics_dependencies
WHERE agg_metric_id = 'AGG_TOTAL_SLEEP_DURATION';

-- =====================================================
-- 5. Delete the duplicate aggregation metric
-- =====================================================

DELETE FROM aggregation_metrics
WHERE agg_id = 'AGG_TOTAL_SLEEP_DURATION';

COMMIT;

-- =====================================================
-- Verification Queries
-- =====================================================

-- Check that AGG_SLEEP_DURATION exists and is being used
SELECT
    dm.metric_id,
    dma.agg_metric_id,
    am.metric_name,
    am.output_unit
FROM display_metrics dm
INNER JOIN display_metrics_aggregations dma ON dm.metric_id = dma.metric_id
LEFT JOIN aggregation_metrics am ON dma.agg_metric_id = am.agg_id
WHERE dma.agg_metric_id LIKE '%SLEEP_DURATION%'
ORDER BY dm.metric_id;

-- Verify AGG_TOTAL_SLEEP_DURATION is gone
SELECT COUNT(*) as should_be_zero
FROM aggregation_metrics
WHERE agg_id = 'AGG_TOTAL_SLEEP_DURATION';
