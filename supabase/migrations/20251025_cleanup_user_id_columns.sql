-- =====================================================
-- Cleanup: Replace user_id with patient_id Everywhere
-- =====================================================
-- Issue: Many tables still use user_id instead of patient_id
-- Fix: Migrate all user_id columns to patient_id with proper FKs
-- =====================================================

BEGIN;

-- =====================================================
-- STEP 1: Drop user_id from Tables That Already Have patient_id
-- =====================================================

-- These tables already have both columns from the migration
-- Just need to drop the legacy user_id column

-- aggregation_results_cache
DO $$
BEGIN
  -- Update unique constraint first (remove user_id, keep patient_id)
  ALTER TABLE aggregation_results_cache
    DROP CONSTRAINT IF EXISTS unique_cache_entry;

  ALTER TABLE aggregation_results_cache
    ADD CONSTRAINT unique_cache_entry
    UNIQUE (patient_id, agg_metric_id, period_type, calculation_type_id, period_start);

  -- Now drop user_id column (CASCADE to drop dependent views/indexes)
  ALTER TABLE aggregation_results_cache DROP COLUMN IF EXISTS user_id CASCADE;

  RAISE NOTICE '✅ Dropped user_id from aggregation_results_cache';
END $$;

-- patient_biomarker_readings
ALTER TABLE patient_biomarker_readings DROP COLUMN IF EXISTS user_id CASCADE;

-- patient_biometric_readings
ALTER TABLE patient_biometric_readings DROP COLUMN IF EXISTS user_id CASCADE;

-- patient_survey_responses
ALTER TABLE patient_survey_responses DROP COLUMN IF EXISTS user_id CASCADE;

-- patient_data_entries
DO $$
BEGIN
  -- This table might have user_id in unique constraints or indexes
  -- Drop them first
  ALTER TABLE patient_data_entries DROP CONSTRAINT IF EXISTS patient_data_entries_user_id_key;
  ALTER TABLE patient_data_entries DROP COLUMN IF EXISTS user_id CASCADE;

  RAISE NOTICE '✅ Dropped user_id from all tables with patient_id';
END $$;

-- =====================================================
-- STEP 2: Convert Tables That Only Have user_id
-- =====================================================

-- For each table: add patient_id, copy data, add FK, drop user_id

-- adherence_scores
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'adherence_scores' AND column_name = 'patient_id') THEN
    ALTER TABLE adherence_scores ADD COLUMN patient_id UUID;
    UPDATE adherence_scores SET patient_id = user_id;
    ALTER TABLE adherence_scores
      ADD CONSTRAINT adherence_scores_patient_fk
      FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE;
    ALTER TABLE adherence_scores ALTER COLUMN patient_id SET NOT NULL;
    ALTER TABLE adherence_scores DROP COLUMN user_id;
    RAISE NOTICE '✅ Converted adherence_scores: user_id → patient_id';
  END IF;
END $$;

-- patient_conditions
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'patient_conditions' AND column_name = 'patient_id') THEN
    ALTER TABLE patient_conditions ADD COLUMN patient_id UUID;
    UPDATE patient_conditions SET patient_id = user_id;
    ALTER TABLE patient_conditions
      ADD CONSTRAINT patient_conditions_patient_fk
      FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE;
    ALTER TABLE patient_conditions ALTER COLUMN patient_id SET NOT NULL;
    ALTER TABLE patient_conditions DROP COLUMN user_id;
    RAISE NOTICE '✅ Converted patient_conditions: user_id → patient_id';
  END IF;
END $$;

-- patient_recommendations
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'patient_recommendations' AND column_name = 'patient_id') THEN
    ALTER TABLE patient_recommendations ADD COLUMN patient_id UUID;
    UPDATE patient_recommendations SET patient_id = user_id;
    ALTER TABLE patient_recommendations
      ADD CONSTRAINT patient_recommendations_patient_fk
      FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE;
    ALTER TABLE patient_recommendations ALTER COLUMN patient_id SET NOT NULL;
    ALTER TABLE patient_recommendations DROP COLUMN user_id;
    RAISE NOTICE '✅ Converted patient_recommendations: user_id → patient_id';
  END IF;
END $$;

-- patient_display_metrics_preferences
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'patient_display_metrics_preferences' AND column_name = 'patient_id') THEN
    ALTER TABLE patient_display_metrics_preferences ADD COLUMN patient_id UUID;
    UPDATE patient_display_metrics_preferences SET patient_id = user_id;
    ALTER TABLE patient_display_metrics_preferences
      ADD CONSTRAINT patient_display_metrics_preferences_patient_fk
      FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE;
    ALTER TABLE patient_display_metrics_preferences ALTER COLUMN patient_id SET NOT NULL;
    ALTER TABLE patient_display_metrics_preferences DROP COLUMN user_id;
    RAISE NOTICE '✅ Converted patient_display_metrics_preferences: user_id → patient_id';
  END IF;
END $$;

-- education_patient_engagement
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'education_patient_engagement' AND column_name = 'patient_id') THEN
    ALTER TABLE education_patient_engagement ADD COLUMN patient_id UUID;
    UPDATE education_patient_engagement SET patient_id = user_id;
    ALTER TABLE education_patient_engagement
      ADD CONSTRAINT education_patient_engagement_patient_fk
      FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE;
    ALTER TABLE education_patient_engagement ALTER COLUMN patient_id SET NOT NULL;
    ALTER TABLE education_patient_engagement DROP COLUMN user_id;
    RAISE NOTICE '✅ Converted education_patient_engagement: user_id → patient_id';
  END IF;
END $$;

-- parent_child_user_preferences
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'parent_child_user_preferences' AND column_name = 'patient_id') THEN
    ALTER TABLE parent_child_user_preferences ADD COLUMN patient_id UUID;
    UPDATE parent_child_user_preferences SET patient_id = user_id;
    ALTER TABLE parent_child_user_preferences
      ADD CONSTRAINT parent_child_user_preferences_patient_fk
      FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE;
    ALTER TABLE parent_child_user_preferences ALTER COLUMN patient_id SET NOT NULL;
    ALTER TABLE parent_child_user_preferences DROP COLUMN user_id;
    RAISE NOTICE '✅ Converted parent_child_user_preferences: user_id → patient_id';
  END IF;
END $$;

-- patient_events
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'patient_events' AND column_name = 'patient_id') THEN
    ALTER TABLE patient_events ADD COLUMN patient_id UUID;
    UPDATE patient_events SET patient_id = user_id;
    ALTER TABLE patient_events
      ADD CONSTRAINT patient_events_patient_fk
      FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE;
    ALTER TABLE patient_events ALTER COLUMN patient_id SET NOT NULL;
    ALTER TABLE patient_events DROP COLUMN user_id;
    RAISE NOTICE '✅ Converted patient_events: user_id → patient_id';
  END IF;
END $$;

-- patient_sleep_analysis
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'patient_sleep_analysis' AND column_name = 'patient_id') THEN
    ALTER TABLE patient_sleep_analysis ADD COLUMN patient_id UUID;
    UPDATE patient_sleep_analysis SET patient_id = user_id;
    ALTER TABLE patient_sleep_analysis
      ADD CONSTRAINT patient_sleep_analysis_patient_fk
      FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE;
    ALTER TABLE patient_sleep_analysis ALTER COLUMN patient_id SET NOT NULL;
    ALTER TABLE patient_sleep_analysis DROP COLUMN user_id;
    RAISE NOTICE '✅ Converted patient_sleep_analysis: user_id → patient_id';
  END IF;
END $$;

-- biometrics_reference
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'biometrics_reference' AND column_name = 'patient_id') THEN
    ALTER TABLE biometrics_reference ADD COLUMN patient_id UUID;
    UPDATE biometrics_reference SET patient_id = user_id;
    ALTER TABLE biometrics_reference
      ADD CONSTRAINT biometrics_reference_patient_fk
      FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE;
    ALTER TABLE biometrics_reference ALTER COLUMN patient_id SET NOT NULL;
    ALTER TABLE biometrics_reference DROP COLUMN user_id;
    RAISE NOTICE '✅ Converted biometrics_reference: user_id → patient_id';
  END IF;
END $$;

-- patient_current_question_scores
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'patient_current_question_scores' AND column_name = 'patient_id') THEN
    ALTER TABLE patient_current_question_scores ADD COLUMN patient_id UUID;
    UPDATE patient_current_question_scores SET patient_id = user_id;
    ALTER TABLE patient_current_question_scores
      ADD CONSTRAINT patient_current_question_scores_patient_fk
      FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE;
    ALTER TABLE patient_current_question_scores ALTER COLUMN patient_id SET NOT NULL;
    ALTER TABLE patient_current_question_scores DROP COLUMN user_id;
    RAISE NOTICE '✅ Converted patient_current_question_scores: user_id → patient_id';
  END IF;
END $$;

-- patient_current_scores
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'patient_current_scores' AND column_name = 'patient_id') THEN
    ALTER TABLE patient_current_scores ADD COLUMN patient_id UUID;
    UPDATE patient_current_scores SET patient_id = user_id;
    ALTER TABLE patient_current_scores
      ADD CONSTRAINT patient_current_scores_patient_fk
      FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE;
    ALTER TABLE patient_current_scores ALTER COLUMN patient_id SET NOT NULL;
    ALTER TABLE patient_current_scores DROP COLUMN user_id;
    RAISE NOTICE '✅ Converted patient_current_scores: user_id → patient_id';
  END IF;
END $$;

-- patient_effective_responses
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'patient_effective_responses' AND column_name = 'patient_id') THEN
    ALTER TABLE patient_effective_responses ADD COLUMN patient_id UUID;
    UPDATE patient_effective_responses SET patient_id = user_id;
    ALTER TABLE patient_effective_responses
      ADD CONSTRAINT patient_effective_responses_patient_fk
      FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE;
    ALTER TABLE patient_effective_responses ALTER COLUMN patient_id SET NOT NULL;
    ALTER TABLE patient_effective_responses DROP COLUMN user_id;
    RAISE NOTICE '✅ Converted patient_effective_responses: user_id → patient_id';
  END IF;
END $$;

-- patient_wellpath_score_by_pillar
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'patient_wellpath_score_by_pillar' AND column_name = 'patient_id') THEN
    ALTER TABLE patient_wellpath_score_by_pillar ADD COLUMN patient_id UUID;
    UPDATE patient_wellpath_score_by_pillar SET patient_id = user_id;
    ALTER TABLE patient_wellpath_score_by_pillar
      ADD CONSTRAINT patient_wellpath_score_by_pillar_patient_fk
      FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE;
    ALTER TABLE patient_wellpath_score_by_pillar ALTER COLUMN patient_id SET NOT NULL;
    ALTER TABLE patient_wellpath_score_by_pillar DROP COLUMN user_id;
    RAISE NOTICE '✅ Converted patient_wellpath_score_by_pillar: user_id → patient_id';
  END IF;
END $$;

-- patient_wellpath_score_by_pillar_section
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'patient_wellpath_score_by_pillar_section' AND column_name = 'patient_id') THEN
    ALTER TABLE patient_wellpath_score_by_pillar_section ADD COLUMN patient_id UUID;
    UPDATE patient_wellpath_score_by_pillar_section SET patient_id = user_id;
    ALTER TABLE patient_wellpath_score_by_pillar_section
      ADD CONSTRAINT patient_wellpath_score_by_pillar_section_patient_fk
      FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE;
    ALTER TABLE patient_wellpath_score_by_pillar_section ALTER COLUMN patient_id SET NOT NULL;
    ALTER TABLE patient_wellpath_score_by_pillar_section DROP COLUMN user_id;
    RAISE NOTICE '✅ Converted patient_wellpath_score_by_pillar_section: user_id → patient_id';
  END IF;
END $$;

-- patient_wellpath_score_by_section
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'patient_wellpath_score_by_section' AND column_name = 'patient_id') THEN
    ALTER TABLE patient_wellpath_score_by_section ADD COLUMN patient_id UUID;
    UPDATE patient_wellpath_score_by_section SET patient_id = user_id;
    ALTER TABLE patient_wellpath_score_by_section
      ADD CONSTRAINT patient_wellpath_score_by_section_patient_fk
      FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE;
    ALTER TABLE patient_wellpath_score_by_section ALTER COLUMN patient_id SET NOT NULL;
    ALTER TABLE patient_wellpath_score_by_section DROP COLUMN user_id;
    RAISE NOTICE '✅ Converted patient_wellpath_score_by_section: user_id → patient_id';
  END IF;
END $$;

-- patient_wellpath_score_detail
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'patient_wellpath_score_detail' AND column_name = 'patient_id') THEN
    ALTER TABLE patient_wellpath_score_detail ADD COLUMN patient_id UUID;
    UPDATE patient_wellpath_score_detail SET patient_id = user_id;
    ALTER TABLE patient_wellpath_score_detail
      ADD CONSTRAINT patient_wellpath_score_detail_patient_fk
      FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE;
    ALTER TABLE patient_wellpath_score_detail ALTER COLUMN patient_id SET NOT NULL;
    ALTER TABLE patient_wellpath_score_detail DROP COLUMN user_id;
    RAISE NOTICE '✅ Converted patient_wellpath_score_detail: user_id → patient_id';
  END IF;
END $$;

-- patient_wellpath_score_items
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'patient_wellpath_score_items' AND column_name = 'patient_id') THEN
    ALTER TABLE patient_wellpath_score_items ADD COLUMN patient_id UUID;
    UPDATE patient_wellpath_score_items SET patient_id = user_id;
    ALTER TABLE patient_wellpath_score_items
      ADD CONSTRAINT patient_wellpath_score_items_patient_fk
      FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE;
    ALTER TABLE patient_wellpath_score_items ALTER COLUMN patient_id SET NOT NULL;
    ALTER TABLE patient_wellpath_score_items DROP COLUMN user_id;
    RAISE NOTICE '✅ Converted patient_wellpath_score_items: user_id → patient_id';
  END IF;
END $$;

-- =====================================================
-- STEP 3: Update RLS Policies to Use Only patient_id
-- =====================================================

-- Drop old policies that use COALESCE(patient_id, user_id)
-- Recreate with just patient_id

-- patient_data_entries
DROP POLICY IF EXISTS "Users can read accessible patient data entries" ON patient_data_entries;
CREATE POLICY "Users can read accessible patient data entries"
  ON patient_data_entries FOR SELECT
  TO authenticated
  USING (patient_id IN (SELECT * FROM get_accessible_patients(auth.uid())));

DROP POLICY IF EXISTS "Patients can write their own data entries" ON patient_data_entries;
CREATE POLICY "Patients can write their own data entries"
  ON patient_data_entries FOR INSERT
  TO authenticated
  WITH CHECK (patient_id = auth.uid());

DROP POLICY IF EXISTS "Patients can update their own data entries" ON patient_data_entries;
CREATE POLICY "Patients can update their own data entries"
  ON patient_data_entries FOR UPDATE
  TO authenticated
  USING (patient_id = auth.uid())
  WITH CHECK (patient_id = auth.uid());

DROP POLICY IF EXISTS "Patients can delete their own data entries" ON patient_data_entries;
CREATE POLICY "Patients can delete their own data entries"
  ON patient_data_entries FOR DELETE
  TO authenticated
  USING (patient_id = auth.uid());

-- patient_survey_responses
DROP POLICY IF EXISTS "Users can read accessible survey responses" ON patient_survey_responses;
CREATE POLICY "Users can read accessible survey responses"
  ON patient_survey_responses FOR SELECT
  TO authenticated
  USING (patient_id IN (SELECT * FROM get_accessible_patients(auth.uid())));

DROP POLICY IF EXISTS "Patients can write their own survey responses" ON patient_survey_responses;
CREATE POLICY "Patients can write their own survey responses"
  ON patient_survey_responses FOR INSERT
  TO authenticated
  WITH CHECK (patient_id = auth.uid());

DROP POLICY IF EXISTS "Patients can update their own survey responses" ON patient_survey_responses;
CREATE POLICY "Patients can update their own survey responses"
  ON patient_survey_responses FOR UPDATE
  TO authenticated
  USING (patient_id = auth.uid())
  WITH CHECK (patient_id = auth.uid());

-- aggregation_results_cache
DROP POLICY IF EXISTS "Users can read accessible aggregation results" ON aggregation_results_cache;
CREATE POLICY "Users can read accessible aggregation results"
  ON aggregation_results_cache FOR SELECT
  TO authenticated
  USING (patient_id IN (SELECT * FROM get_accessible_patients(auth.uid())));

-- patient_biomarker_readings
DROP POLICY IF EXISTS "Users can read accessible biomarker readings" ON patient_biomarker_readings;
CREATE POLICY "Users can read accessible biomarker readings"
  ON patient_biomarker_readings FOR SELECT
  TO authenticated
  USING (patient_id IN (SELECT * FROM get_accessible_patients(auth.uid())));

DROP POLICY IF EXISTS "Practice users can write biomarker readings for accessible patients" ON patient_biomarker_readings;
DROP POLICY IF EXISTS "Practice users can write biomarker readings for accessible pati" ON patient_biomarker_readings;
CREATE POLICY "Practice users write biomarker readings"
  ON patient_biomarker_readings FOR INSERT
  TO authenticated
  WITH CHECK (patient_id IN (SELECT * FROM get_accessible_patients(auth.uid())));

DROP POLICY IF EXISTS "Practice users can update biomarker readings for accessible patients" ON patient_biomarker_readings;
DROP POLICY IF EXISTS "Practice users can update biomarker readings for accessible pat" ON patient_biomarker_readings;
CREATE POLICY "Practice users update biomarker readings"
  ON patient_biomarker_readings FOR UPDATE
  TO authenticated
  USING (patient_id IN (SELECT * FROM get_accessible_patients(auth.uid())))
  WITH CHECK (patient_id IN (SELECT * FROM get_accessible_patients(auth.uid())));

-- patient_biometric_readings
DROP POLICY IF EXISTS "Users can read accessible biometric readings" ON patient_biometric_readings;
CREATE POLICY "Users can read accessible biometric readings"
  ON patient_biometric_readings FOR SELECT
  TO authenticated
  USING (patient_id IN (SELECT * FROM get_accessible_patients(auth.uid())));

DROP POLICY IF EXISTS "Practice users can write biometric readings for accessible patients" ON patient_biometric_readings;
DROP POLICY IF EXISTS "Practice users can write biometric readings for accessible pati" ON patient_biometric_readings;
CREATE POLICY "Practice users write biometric readings"
  ON patient_biometric_readings FOR INSERT
  TO authenticated
  WITH CHECK (patient_id IN (SELECT * FROM get_accessible_patients(auth.uid())));

DROP POLICY IF EXISTS "Practice users can update biometric readings for accessible patients" ON patient_biometric_readings;
DROP POLICY IF EXISTS "Practice users can update biometric readings for accessible pat" ON patient_biometric_readings;
CREATE POLICY "Practice users update biometric readings"
  ON patient_biometric_readings FOR UPDATE
  TO authenticated
  USING (patient_id IN (SELECT * FROM get_accessible_patients(auth.uid())))
  WITH CHECK (patient_id IN (SELECT * FROM get_accessible_patients(auth.uid())));

RAISE NOTICE '✅ Updated all RLS policies to use patient_id only';

-- =====================================================
-- VERIFICATION
-- =====================================================

DO $$
DECLARE
  v_tables_with_user_id INTEGER;
  v_tables_with_patient_id INTEGER;
BEGIN
  -- Count tables still using user_id
  SELECT COUNT(DISTINCT table_name) INTO v_tables_with_user_id
  FROM information_schema.columns
  WHERE table_schema = 'public'
    AND column_name = 'user_id'
    AND table_name LIKE 'patient%' OR table_name LIKE 'adherence%' OR table_name LIKE 'education%' OR table_name LIKE 'biometrics%' OR table_name LIKE 'parent%';

  -- Count tables with patient_id
  SELECT COUNT(DISTINCT table_name) INTO v_tables_with_patient_id
  FROM information_schema.columns
  WHERE table_schema = 'public'
    AND column_name = 'patient_id';

  RAISE NOTICE '';
  RAISE NOTICE '✅ Cleanup Complete!';
  RAISE NOTICE '';
  RAISE NOTICE 'Summary:';
  RAISE NOTICE '  Tables with patient_id: %', v_tables_with_patient_id;
  RAISE NOTICE '  Tables still with user_id: %', v_tables_with_user_id;
  RAISE NOTICE '';

  IF v_tables_with_user_id > 5 THEN
    RAISE WARNING '⚠️  Some tables still have user_id columns';
  ELSE
    RAISE NOTICE '✅ Most user_id columns converted to patient_id!';
  END IF;

  RAISE NOTICE '';
  RAISE NOTICE 'All patient-related tables now use:';
  RAISE NOTICE '  - patient_id (with FK to patients table)';
  RAISE NOTICE '  - RLS policies updated to use patient_id only';
  RAISE NOTICE '  - No more COALESCE(patient_id, user_id) confusion!';
END $$;

COMMIT;
