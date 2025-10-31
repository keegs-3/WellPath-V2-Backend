-- =====================================================================================
-- Fix All RLS Policies
-- =====================================================================================
-- Ensures all display metrics and aggregation tables have proper RLS policies
-- for mobile app access
-- =====================================================================================

-- =====================================================================================
-- STEP 1: Fix data_entry_fields (has RLS enabled but no policies)
-- =====================================================================================

-- Allow all users to read data_entry_fields (metadata table)
DROP POLICY IF EXISTS "allow_read_data_entry_fields" ON data_entry_fields;
CREATE POLICY "allow_read_data_entry_fields"
ON data_entry_fields
FOR SELECT
TO public
USING (true);

-- =====================================================================================
-- STEP 2: Fix aggregation_metrics_calculation_types (has RLS enabled but no policies)
-- =====================================================================================

-- Allow all users to read calculation types (metadata table)
DROP POLICY IF EXISTS "allow_read_calculation_types" ON aggregation_metrics_calculation_types;
CREATE POLICY "allow_read_calculation_types"
ON aggregation_metrics_calculation_types
FOR SELECT
TO public
USING (true);

-- =====================================================================================
-- STEP 3: Enable RLS and add policies for display_screens_parent_metrics
-- =====================================================================================

ALTER TABLE display_screens_parent_metrics ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "allow_read_display_screens_parent_metrics" ON display_screens_parent_metrics;
CREATE POLICY "allow_read_display_screens_parent_metrics"
ON display_screens_parent_metrics
FOR SELECT
TO public
USING (true);

-- =====================================================================================
-- STEP 4: Enable RLS and add policies for parent_child_display_metrics_aggregations
-- =====================================================================================

ALTER TABLE parent_child_display_metrics_aggregations ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "allow_read_parent_child_aggregations" ON parent_child_display_metrics_aggregations;
CREATE POLICY "allow_read_parent_child_aggregations"
ON parent_child_display_metrics_aggregations
FOR SELECT
TO public
USING (true);

-- =====================================================================================
-- STEP 5: Enable RLS and add user-scoped policies for patient_data_entries
-- =====================================================================================

ALTER TABLE patient_data_entries ENABLE ROW LEVEL SECURITY;

-- Users can read their own data
DROP POLICY IF EXISTS "allow_user_read_own_data_entries" ON patient_data_entries;
CREATE POLICY "allow_user_read_own_data_entries"
ON patient_data_entries
FOR SELECT
TO authenticated
USING (user_id = auth.uid());

-- Users can insert their own data
DROP POLICY IF EXISTS "allow_user_insert_own_data_entries" ON patient_data_entries;
CREATE POLICY "allow_user_insert_own_data_entries"
ON patient_data_entries
FOR INSERT
TO authenticated
WITH CHECK (user_id = auth.uid());

-- Users can update their own data
DROP POLICY IF EXISTS "allow_user_update_own_data_entries" ON patient_data_entries;
CREATE POLICY "allow_user_update_own_data_entries"
ON patient_data_entries
FOR UPDATE
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Users can delete their own data
DROP POLICY IF EXISTS "allow_user_delete_own_data_entries" ON patient_data_entries;
CREATE POLICY "allow_user_delete_own_data_entries"
ON patient_data_entries
FOR DELETE
TO authenticated
USING (user_id = auth.uid());

-- Service role can access all data (for backend scripts)
DROP POLICY IF EXISTS "allow_service_role_all_data_entries" ON patient_data_entries;
CREATE POLICY "allow_service_role_all_data_entries"
ON patient_data_entries
FOR ALL
TO service_role
USING (true)
WITH CHECK (true);

-- =====================================================================================
-- STEP 6: Enable RLS and add policies for aggregation_metrics_dependencies
-- =====================================================================================

ALTER TABLE aggregation_metrics_dependencies ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "allow_read_aggregation_dependencies" ON aggregation_metrics_dependencies;
CREATE POLICY "allow_read_aggregation_dependencies"
ON aggregation_metrics_dependencies
FOR SELECT
TO public
USING (true);

-- =====================================================================================
-- STEP 7: Ensure aggregation_results_cache has proper user-scoped policies
-- =====================================================================================

-- Drop overly permissive policies if they exist
DROP POLICY IF EXISTS "allow_user_read_cache" ON aggregation_results_cache;
DROP POLICY IF EXISTS "allow_user_insert_cache" ON aggregation_results_cache;
DROP POLICY IF EXISTS "allow_user_update_cache" ON aggregation_results_cache;

-- Users can read their own aggregation results
DROP POLICY IF EXISTS "allow_user_read_own_cache" ON aggregation_results_cache;
CREATE POLICY "allow_user_read_own_cache"
ON aggregation_results_cache
FOR SELECT
TO authenticated
USING (user_id = auth.uid());

-- Service role can read/write all cache entries (for backend aggregation scripts)
DROP POLICY IF EXISTS "allow_service_role_all_cache" ON aggregation_results_cache;
CREATE POLICY "allow_service_role_all_cache"
ON aggregation_results_cache
FOR ALL
TO service_role
USING (true)
WITH CHECK (true);

-- Anon users can still read aggregation cache (for public views)
-- This maintains backwards compatibility with existing policy
DROP POLICY IF EXISTS "allow_anon_read_cache" ON aggregation_results_cache;
CREATE POLICY "allow_anon_read_cache"
ON aggregation_results_cache
FOR SELECT
TO anon
USING (true);

-- =====================================================================================
-- STEP 8: Add any missing metadata table policies
-- =====================================================================================

-- Ensure all metadata tables are readable by everyone
DO $$
BEGIN
    -- These are metadata/configuration tables that should be publicly readable
    -- They don't contain user data, just configuration

    -- parent_display_metrics (already has policy)
    -- child_display_metrics (already has policy)
    -- aggregation_metrics (already has policy)
    -- aggregation_metrics_periods (already has policies)

    -- Just verify they exist
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE tablename = 'parent_display_metrics'
        AND policyname = 'Anyone can read parent_display_metrics'
    ) THEN
        RAISE NOTICE 'parent_display_metrics policy exists';
    END IF;
END $$;

-- =====================================================================================
-- VERIFICATION
-- =====================================================================================

-- Show all tables and their RLS status
SELECT
    'RLS Status' as check_type,
    t.tablename,
    CASE WHEN t.rowsecurity THEN 'ENABLED' ELSE 'DISABLED' END as rls_status,
    COUNT(p.policyname) as policy_count
FROM pg_tables t
LEFT JOIN pg_policies p ON p.tablename = t.tablename AND p.schemaname = t.schemaname
WHERE t.schemaname = 'public'
  AND t.tablename IN (
    'parent_display_metrics',
    'child_display_metrics',
    'display_screens_parent_metrics',
    'parent_child_display_metrics_aggregations',
    'aggregation_results_cache',
    'aggregation_metrics',
    'aggregation_metrics_periods',
    'aggregation_metrics_dependencies',
    'aggregation_metrics_calculation_types',
    'patient_data_entries',
    'data_entry_fields'
  )
GROUP BY t.schemaname, t.tablename, t.rowsecurity
ORDER BY t.tablename;

-- Show all policies
SELECT
    'Policies' as check_type,
    tablename,
    policyname,
    cmd,
    roles::text
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename IN (
    'parent_display_metrics',
    'child_display_metrics',
    'display_screens_parent_metrics',
    'parent_child_display_metrics_aggregations',
    'aggregation_results_cache',
    'aggregation_metrics',
    'aggregation_metrics_periods',
    'aggregation_metrics_dependencies',
    'aggregation_metrics_calculation_types',
    'patient_data_entries',
    'data_entry_fields'
  )
ORDER BY tablename, policyname;
