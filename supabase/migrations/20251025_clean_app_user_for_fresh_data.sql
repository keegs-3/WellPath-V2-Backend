-- =====================================================
-- Clean App User Data for Fresh Test Data Generation
-- =====================================================
-- User: test.patient.21@wellpath.com
-- UUID: 8b79ce33-02b8-4f49-8268-3204130efa82
-- =====================================================

BEGIN;

DO $$
DECLARE
  v_app_user_id UUID := '8b79ce33-02b8-4f49-8268-3204130efa82'::UUID;
  v_entries_deleted INTEGER;
  v_biomarkers_deleted INTEGER;
  v_biometrics_deleted INTEGER;
  v_cache_deleted INTEGER;
  v_surveys_deleted INTEGER;
BEGIN
  RAISE NOTICE '🧹 Cleaning data for test.patient.21@wellpath.com...';
  RAISE NOTICE '';

  -- Count before deletion
  SELECT COUNT(*) INTO v_entries_deleted FROM patient_data_entries WHERE patient_id = v_app_user_id;
  SELECT COUNT(*) INTO v_biomarkers_deleted FROM patient_biomarker_readings WHERE patient_id = v_app_user_id;
  SELECT COUNT(*) INTO v_biometrics_deleted FROM patient_biometric_readings WHERE patient_id = v_app_user_id;
  SELECT COUNT(*) INTO v_cache_deleted FROM aggregation_results_cache WHERE patient_id = v_app_user_id;
  SELECT COUNT(*) INTO v_surveys_deleted FROM patient_survey_responses WHERE patient_id = v_app_user_id;

  RAISE NOTICE 'Data to be deleted:';
  RAISE NOTICE '  - % data entries', v_entries_deleted;
  RAISE NOTICE '  - % biomarker readings', v_biomarkers_deleted;
  RAISE NOTICE '  - % biometric readings', v_biometrics_deleted;
  RAISE NOTICE '  - % cached aggregations', v_cache_deleted;
  RAISE NOTICE '  - % survey responses', v_surveys_deleted;
  RAISE NOTICE '';

  -- Delete data
  DELETE FROM patient_data_entries WHERE patient_id = v_app_user_id;
  DELETE FROM patient_biomarker_readings WHERE patient_id = v_app_user_id;
  DELETE FROM patient_biometric_readings WHERE patient_id = v_app_user_id;
  DELETE FROM aggregation_results_cache WHERE patient_id = v_app_user_id;
  DELETE FROM patient_survey_responses WHERE patient_id = v_app_user_id;

  RAISE NOTICE '✅ Deleted all data for test.patient.21@wellpath.com';
  RAISE NOTICE '';
  RAISE NOTICE 'Next steps:';
  RAISE NOTICE '  1. Run: python3 scripts/generate_comprehensive_test_data.py';
  RAISE NOTICE '  2. Run: python3 scripts/process_all_aggregations_for_user.py 8b79ce33-02b8-4f49-8268-3204130efa82';
  RAISE NOTICE '';
END $$;

COMMIT;
