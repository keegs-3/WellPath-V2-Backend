-- Fix scoring double-count bug by adding batch_id tracking
--
-- PROBLEM:
-- The calculate-wellpath-score edge function was keeping historical score items
-- for trend tracking, but the calculatePillarSummary function was querying ALL
-- items without filtering by calculation batch. This caused it to sum max scores
-- from multiple scoring runs, resulting in doubled scores.
--
-- Example bug:
--   Patient 8b79... had 2 scoring runs (Oct 26 18:47 and 19:03)
--   Each biomarker appeared twice in patient_wellpath_score_items
--   Max scores were summed across both: 0.00837 × 2 = 0.01674
--   Result: Overall score 12.4/12.6 instead of 6.2/6.3
--
-- SOLUTION:
-- 1. Add batch_id UUID column to track each calculation run
-- 2. Add indexes for efficient batch filtering
-- 3. Update edge function to:
--    - Generate unique batch_id per calculation
--    - Include batch_id in all inserted items
--    - Filter calculatePillarSummary by batch_id to only sum current batch items
--
-- RESULT:
-- After fix, patient 8b79... correctly shows 6.2/6.3 (not 12.4/12.6)

-- Add batch_id column to track calculation runs
ALTER TABLE patient_wellpath_score_items
ADD COLUMN IF NOT EXISTS batch_id UUID;

-- Create index for efficient batch filtering
CREATE INDEX IF NOT EXISTS idx_score_items_batch
ON patient_wellpath_score_items(batch_id);

-- Create composite index for common query pattern (patient + batch)
CREATE INDEX IF NOT EXISTS idx_score_items_patient_batch
ON patient_wellpath_score_items(patient_id, batch_id);

-- Add helpful comment
COMMENT ON COLUMN patient_wellpath_score_items.batch_id IS
'UUID identifying a single scoring calculation run. Used to filter items from the current calculation and avoid double-counting historical items when summing max scores.';
