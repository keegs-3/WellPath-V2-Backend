-- =====================================================
-- Row Level Security (RLS) Policies
-- =====================================================
-- Implements multi-tenant access control:
-- - Patients: Own data only
-- - Clinicians: Assigned patients only
-- - Admins/Nurses: Based on access grants
-- - Service Role: Full access (bypasses RLS)
-- =====================================================

BEGIN;

-- =====================================================
-- 1. AUTH TABLES - Practice Users and Patients
-- =====================================================

-- Medical Practices
ALTER TABLE medical_practices ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Practice users can read their own practice"
  ON medical_practices FOR SELECT
  TO authenticated
  USING (
    id IN (
      SELECT medical_practice_id FROM practice_users WHERE user_id = auth.uid()
      UNION
      SELECT medical_practice_id FROM patients WHERE patient_id = auth.uid()
    )
  );

-- Practice Users
ALTER TABLE practice_users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read their own profile"
  ON practice_users FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Practice users can read colleagues in same practice"
  ON practice_users FOR SELECT
  TO authenticated
  USING (
    medical_practice_id IN (
      SELECT medical_practice_id FROM practice_users WHERE user_id = auth.uid()
    )
  );

-- Patients
ALTER TABLE patients ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Patients can read their own profile"
  ON patients FOR SELECT
  TO authenticated
  USING (patient_id = auth.uid());

CREATE POLICY "Practice users can read accessible patients"
  ON patients FOR SELECT
  TO authenticated
  USING (patient_id IN (SELECT * FROM get_accessible_patients(auth.uid())));

CREATE POLICY "Practice users can update accessible patients"
  ON patients FOR UPDATE
  TO authenticated
  USING (patient_id IN (SELECT * FROM get_accessible_patients(auth.uid())))
  WITH CHECK (patient_id IN (SELECT * FROM get_accessible_patients(auth.uid())));

-- Practice User Access
ALTER TABLE practice_user_access ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read their own access grants"
  ON practice_user_access FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

-- =====================================================
-- 2. CONFIGURATION TABLES (Read-only for all authenticated)
-- =====================================================

-- Display Screens
ALTER TABLE display_screens ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authenticated users can read display screens"
  ON display_screens FOR SELECT TO authenticated USING (true);

-- Display Screens Primary
ALTER TABLE display_screens_primary ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authenticated users can read primary screens"
  ON display_screens_primary FOR SELECT TO authenticated USING (true);

-- Display Screens Detail
ALTER TABLE display_screens_detail ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authenticated users can read detail screens"
  ON display_screens_detail FOR SELECT TO authenticated USING (true);

-- Display Metrics
ALTER TABLE display_metrics ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authenticated users can read display metrics"
  ON display_metrics FOR SELECT TO authenticated USING (true);

-- Junction Tables
ALTER TABLE display_screens_primary_display_metrics ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authenticated users can read primary metrics junction"
  ON display_screens_primary_display_metrics FOR SELECT TO authenticated USING (true);

ALTER TABLE display_screens_detail_display_metrics ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authenticated users can read detail metrics junction"
  ON display_screens_detail_display_metrics FOR SELECT TO authenticated USING (true);

-- Data Entry Fields
ALTER TABLE data_entry_fields ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authenticated users can read data entry fields"
  ON data_entry_fields FOR SELECT TO authenticated USING (true);

-- Aggregation Metrics
ALTER TABLE aggregation_metrics ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authenticated users can read aggregation metrics"
  ON aggregation_metrics FOR SELECT TO authenticated USING (true);

ALTER TABLE aggregation_metrics_periods ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authenticated users can read aggregation periods"
  ON aggregation_metrics_periods FOR SELECT TO authenticated USING (true);

-- Biometrics Base (if exists)
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'biometrics_base') THEN
    ALTER TABLE biometrics_base ENABLE ROW LEVEL SECURITY;
    DROP POLICY IF EXISTS "Authenticated users can read biometrics base" ON biometrics_base;
    CREATE POLICY "Authenticated users can read biometrics base"
      ON biometrics_base FOR SELECT TO authenticated USING (true);
  END IF;
END $$;

-- Surveys Base (if exists)
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'surveys_base') THEN
    ALTER TABLE surveys_base ENABLE ROW LEVEL SECURITY;
    DROP POLICY IF EXISTS "Authenticated users can read surveys base" ON surveys_base;
    CREATE POLICY "Authenticated users can read surveys base"
      ON surveys_base FOR SELECT TO authenticated USING (true);
  END IF;
END $$;

-- Pillars Base (if exists)
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'pillars_base') THEN
    ALTER TABLE pillars_base ENABLE ROW LEVEL SECURITY;
    DROP POLICY IF EXISTS "Authenticated users can read pillars base" ON pillars_base;
    CREATE POLICY "Authenticated users can read pillars base"
      ON pillars_base FOR SELECT TO authenticated USING (true);
  END IF;
END $$;

-- Chart Types (if exists)
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'chart_types') THEN
    ALTER TABLE chart_types ENABLE ROW LEVEL SECURITY;
    DROP POLICY IF EXISTS "Authenticated users can read chart types" ON chart_types;
    CREATE POLICY "Authenticated users can read chart types"
      ON chart_types FOR SELECT TO authenticated USING (true);
  END IF;
END $$;

-- =====================================================
-- 3. PATIENT DATA TABLES (Patient Read/Write, Staff Read)
-- =====================================================

-- Patient Data Entries
ALTER TABLE patient_data_entries ENABLE ROW LEVEL SECURITY;

-- Read access: user_id column (legacy) OR patient_id column (new)
CREATE POLICY "Users can read accessible patient data entries"
  ON patient_data_entries FOR SELECT
  TO authenticated
  USING (
    COALESCE(patient_id, user_id) IN (SELECT * FROM get_accessible_patients(auth.uid()))
  );

-- Write access: patients only, using either column
CREATE POLICY "Patients can write their own data entries"
  ON patient_data_entries FOR INSERT
  TO authenticated
  WITH CHECK (COALESCE(patient_id, user_id) = auth.uid());

CREATE POLICY "Patients can update their own data entries"
  ON patient_data_entries FOR UPDATE
  TO authenticated
  USING (COALESCE(patient_id, user_id) = auth.uid())
  WITH CHECK (COALESCE(patient_id, user_id) = auth.uid());

CREATE POLICY "Patients can delete their own data entries"
  ON patient_data_entries FOR DELETE
  TO authenticated
  USING (COALESCE(patient_id, user_id) = auth.uid());

-- Patient Survey Responses
ALTER TABLE patient_survey_responses ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read accessible survey responses"
  ON patient_survey_responses FOR SELECT
  TO authenticated
  USING (COALESCE(patient_id, user_id) IN (SELECT * FROM get_accessible_patients(auth.uid())));

CREATE POLICY "Patients can write their own survey responses"
  ON patient_survey_responses FOR INSERT
  TO authenticated
  WITH CHECK (COALESCE(patient_id, user_id) = auth.uid());

CREATE POLICY "Patients can update their own survey responses"
  ON patient_survey_responses FOR UPDATE
  TO authenticated
  USING (COALESCE(patient_id, user_id) = auth.uid())
  WITH CHECK (COALESCE(patient_id, user_id) = auth.uid());

-- Aggregation Results Cache
ALTER TABLE aggregation_results_cache ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read accessible aggregation results"
  ON aggregation_results_cache FOR SELECT
  TO authenticated
  USING (COALESCE(patient_id, user_id) IN (SELECT * FROM get_accessible_patients(auth.uid())));

-- Note: Aggregation writes are done by service role (bypasses RLS)

-- =====================================================
-- 4. STAFF-WRITE TABLES (Clinician/Admin/Nurse Write)
-- =====================================================

-- Patient Biomarker Readings (Lab Results)
ALTER TABLE patient_biomarker_readings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read accessible biomarker readings"
  ON patient_biomarker_readings FOR SELECT
  TO authenticated
  USING (COALESCE(patient_id, user_id) IN (SELECT * FROM get_accessible_patients(auth.uid())));

CREATE POLICY "Practice users can write biomarker readings for accessible patients"
  ON patient_biomarker_readings FOR INSERT
  TO authenticated
  WITH CHECK (COALESCE(patient_id, user_id) IN (SELECT * FROM get_accessible_patients(auth.uid())));

CREATE POLICY "Practice users can update biomarker readings for accessible patients"
  ON patient_biomarker_readings FOR UPDATE
  TO authenticated
  USING (COALESCE(patient_id, user_id) IN (SELECT * FROM get_accessible_patients(auth.uid())))
  WITH CHECK (COALESCE(patient_id, user_id) IN (SELECT * FROM get_accessible_patients(auth.uid())));

-- Patient Biometric Readings (Vitals)
ALTER TABLE patient_biometric_readings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read accessible biometric readings"
  ON patient_biometric_readings FOR SELECT
  TO authenticated
  USING (COALESCE(patient_id, user_id) IN (SELECT * FROM get_accessible_patients(auth.uid())));

CREATE POLICY "Practice users can write biometric readings for accessible patients"
  ON patient_biometric_readings FOR INSERT
  TO authenticated
  WITH CHECK (COALESCE(patient_id, user_id) IN (SELECT * FROM get_accessible_patients(auth.uid())));

CREATE POLICY "Practice users can update biometric readings for accessible patients"
  ON patient_biometric_readings FOR UPDATE
  TO authenticated
  USING (COALESCE(patient_id, user_id) IN (SELECT * FROM get_accessible_patients(auth.uid())))
  WITH CHECK (COALESCE(patient_id, user_id) IN (SELECT * FROM get_accessible_patients(auth.uid())));

-- =====================================================
-- VERIFICATION
-- =====================================================

DO $$
DECLARE
  v_table_count INTEGER;
  v_policy_count INTEGER;
BEGIN
  -- Count tables with RLS enabled
  SELECT COUNT(*)
  INTO v_table_count
  FROM pg_tables
  WHERE schemaname = 'public'
    AND rowsecurity = true;

  -- Count policies created
  SELECT COUNT(*)
  INTO v_policy_count
  FROM pg_policies
  WHERE schemaname = 'public';

  RAISE NOTICE '✅ RLS Policies Created';
  RAISE NOTICE '';
  RAISE NOTICE 'Tables with RLS enabled: %', v_table_count;
  RAISE NOTICE 'Total policies created: %', v_policy_count;
  RAISE NOTICE '';
  RAISE NOTICE 'Access Control Summary:';
  RAISE NOTICE '  Patients: Read/write own data only';
  RAISE NOTICE '  Clinicians: Read assigned patients + write biomarkers/biometrics';
  RAISE NOTICE '  Admins/Nurses: Based on practice_user_access grants';
  RAISE NOTICE '  Service Role: Full access (bypasses RLS)';
  RAISE NOTICE '';
  RAISE NOTICE 'Next step: Run test data migration';
END $$;

COMMIT;
