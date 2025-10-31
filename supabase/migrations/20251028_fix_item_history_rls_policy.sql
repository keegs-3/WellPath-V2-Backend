-- Fix RLS policy for patient_item_scores_history
-- The service role policy was missing the FOR clause, preventing inserts

-- Drop the incomplete policy
DROP POLICY IF EXISTS "Service role can manage item score history" ON patient_item_scores_history;

-- Recreate with correct FOR ALL clause
CREATE POLICY "Service role can manage item score history"
    ON patient_item_scores_history
    FOR ALL
    TO service_role
    USING (true)
    WITH CHECK (true);

-- Also ensure anon role can't access this table
DROP POLICY IF EXISTS "Anon cannot access item score history" ON patient_item_scores_history;
CREATE POLICY "Anon cannot access item score history"
    ON patient_item_scores_history
    FOR ALL
    TO anon
    USING (false);

COMMENT ON TABLE patient_item_scores_history IS
'Historical tracking of individual item scores (biomarkers, biometrics, survey questions, functions, education) for each patient. Items that apply to multiple pillars have one row per pillar. Used for charts and trend analysis. Service role has full access for edge function inserts.';
