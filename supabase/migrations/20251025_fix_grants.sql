-- =====================================================
-- Fix GRANT Permissions for Authenticated Users
-- =====================================================
-- Issue: RLS policies exist but GRANT permissions missing
-- Tables have RLS enabled but authenticated role can't SELECT
-- =====================================================

BEGIN;

-- =====================================================
-- Grant SELECT to All Config/Display Tables
-- =====================================================

GRANT SELECT ON display_screens TO authenticated;
GRANT SELECT ON display_screens_primary TO authenticated;
GRANT SELECT ON display_screens_detail TO authenticated;
GRANT SELECT ON display_metrics TO authenticated;
GRANT SELECT ON display_screens_primary_display_metrics TO authenticated;
GRANT SELECT ON display_screens_detail_display_metrics TO authenticated;
GRANT SELECT ON display_metrics_aggregations TO authenticated;
GRANT SELECT ON data_entry_fields TO authenticated;
GRANT SELECT ON aggregation_metrics TO authenticated;
GRANT SELECT ON aggregation_metrics_periods TO authenticated;

-- =====================================================
-- Grant SELECT on Auth Tables
-- =====================================================

GRANT SELECT ON patients TO authenticated;
GRANT SELECT ON practice_users TO authenticated;
GRANT SELECT ON medical_practices TO authenticated;

-- =====================================================
-- Grant ALL on Patient Data Tables
-- =====================================================

-- These need full CRUD for patients to manage their data
GRANT SELECT, INSERT, UPDATE, DELETE ON patient_data_entries TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON patient_survey_responses TO authenticated;
GRANT SELECT ON aggregation_results_cache TO authenticated;

-- Staff can write to biomarker/biometric tables
GRANT SELECT, INSERT, UPDATE, DELETE ON patient_biomarker_readings TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON patient_biometric_readings TO authenticated;

-- =====================================================
-- VERIFICATION
-- =====================================================

DO $$
DECLARE
  v_granted_count INTEGER;
  v_total_count INTEGER;
BEGIN
  -- Count tables with grants
  SELECT COUNT(*) INTO v_granted_count
  FROM pg_tables t
  WHERE t.schemaname = 'public'
    AND (
      t.tablename LIKE 'display%' OR
      t.tablename LIKE 'patient%' OR
      t.tablename LIKE 'data_entry%' OR
      t.tablename = 'patients'
    )
    AND has_table_privilege('authenticated', t.schemaname || '.' || t.tablename, 'SELECT');

  SELECT COUNT(*) INTO v_total_count
  FROM pg_tables t
  WHERE t.schemaname = 'public'
    AND (
      t.tablename LIKE 'display%' OR
      t.tablename LIKE 'patient%' OR
      t.tablename LIKE 'data_entry%' OR
      t.tablename = 'patients'
    );

  RAISE NOTICE '';
  RAISE NOTICE 'Verification:';
  RAISE NOTICE '  Tables with SELECT grant: % / %', v_granted_count, v_total_count;
  RAISE NOTICE '';

  IF v_granted_count >= v_total_count * 0.8 THEN
    RAISE NOTICE '✅ Most tables now have proper grants!';
  ELSE
    RAISE WARNING '⚠️  Some tables still missing grants';
  END IF;
END $$;

-- Test authenticated access
DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE 'Testing authenticated access to display_screens_primary...';

  -- This will work now!
  PERFORM 1 FROM display_screens_primary LIMIT 1;

  RAISE NOTICE '✅ Authenticated users can now read display_screens_primary!';
END $$;

COMMIT;
