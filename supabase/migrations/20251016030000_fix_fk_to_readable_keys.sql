-- =====================================================
-- Fix Foreign Keys to Use Readable IDs Instead of UUIDs
-- =====================================================
--
-- Problem: aggregation_metrics_periods.period_id references
--          aggregation_periods.id (UUID) instead of
--          aggregation_periods.period_id (readable text like "7d", "30d")
--
-- Solution: Change FK to reference the readable period_id column
-- =====================================================

BEGIN;

-- Step 1: Add temporary column for readable period_id
ALTER TABLE aggregation_metrics_periods
ADD COLUMN period_id_readable TEXT;

-- Step 2: Populate with readable values
UPDATE aggregation_metrics_periods amp
SET period_id_readable = ap.period_id
FROM aggregation_periods ap
WHERE amp.period_id = ap.id;

-- Step 3: Verify all rows updated (should match total count)
DO $$
DECLARE
    total_count INTEGER;
    updated_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO total_count FROM aggregation_metrics_periods;
    SELECT COUNT(*) INTO updated_count FROM aggregation_metrics_periods WHERE period_id_readable IS NOT NULL;

    IF total_count != updated_count THEN
        RAISE EXCEPTION 'Migration failed: % rows total but only % updated', total_count, updated_count;
    END IF;

    RAISE NOTICE 'Successfully populated period_id_readable for % rows', updated_count;
END $$;

-- Step 4: Drop old FK constraint
ALTER TABLE aggregation_metrics_periods
DROP CONSTRAINT aggregation_metrics_periods_period_id_fkey;

-- Step 5: Drop old UUID column
ALTER TABLE aggregation_metrics_periods
DROP COLUMN period_id;

-- Step 6: Rename readable column to period_id
ALTER TABLE aggregation_metrics_periods
RENAME COLUMN period_id_readable TO period_id;

-- Step 7: Make it NOT NULL
ALTER TABLE aggregation_metrics_periods
ALTER COLUMN period_id SET NOT NULL;

-- Step 8: Create new FK constraint to readable period_id
ALTER TABLE aggregation_metrics_periods
ADD CONSTRAINT aggregation_metrics_periods_period_id_fkey
FOREIGN KEY (period_id) REFERENCES aggregation_periods(period_id)
ON DELETE CASCADE;

-- Step 9: Create index for performance
CREATE INDEX IF NOT EXISTS idx_aggregation_metrics_periods_period_id
ON aggregation_metrics_periods(period_id);

-- Verify the change
DO $$
BEGIN
    -- Check that FK now references period_id (text) not id (uuid)
    IF EXISTS (
        SELECT 1
        FROM information_schema.constraint_column_usage ccu
        JOIN information_schema.table_constraints tc
            ON ccu.constraint_name = tc.constraint_name
        WHERE tc.table_name = 'aggregation_metrics_periods'
            AND tc.constraint_type = 'FOREIGN KEY'
            AND ccu.column_name = 'period_id'
            AND ccu.table_name = 'aggregation_periods'
    ) THEN
        RAISE NOTICE '✅ FK now correctly references aggregation_periods.period_id (readable text)';
    ELSE
        RAISE EXCEPTION '❌ FK constraint not properly created';
    END IF;
END $$;

COMMIT;

-- =====================================================
-- Verification Query
-- =====================================================
-- Run this to verify the change worked:
--
-- SELECT
--     amp.agg_metric_id,
--     amp.period_id as readable_period,  -- Now shows "7d", "30d", etc.
--     ap.period_name
-- FROM aggregation_metrics_periods amp
-- JOIN aggregation_periods ap ON amp.period_id = ap.period_id
-- LIMIT 10;

-- =====================================================
-- COMMENT
-- =====================================================
COMMENT ON COLUMN aggregation_metrics_periods.period_id IS
'References aggregation_periods.period_id (text) for readability. Values like "7d", "30d", "90d" instead of UUIDs.';
