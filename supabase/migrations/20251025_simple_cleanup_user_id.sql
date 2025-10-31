-- =====================================================
-- Simple Cleanup: user_id → patient_id
-- =====================================================
-- Strategy:
-- 1. Tables with BOTH: Drop user_id (redundant, values match patient_id)
-- 2. Tables with ONLY user_id: Rename to patient_id + add FK
-- =====================================================

BEGIN;

-- =====================================================
-- STEP 1: Drop user_id from Dual-Column Tables
-- =====================================================

-- These already have patient_id with FK to patients
-- user_id is redundant (values are identical)
-- Use CASCADE to drop any dependent indexes/constraints

DO $$
BEGIN
  ALTER TABLE patient_biomarker_readings DROP COLUMN IF EXISTS user_id CASCADE;
  ALTER TABLE patient_biometric_readings DROP COLUMN IF EXISTS user_id CASCADE;
  ALTER TABLE patient_survey_responses DROP COLUMN IF EXISTS user_id CASCADE;
  ALTER TABLE patient_data_entries DROP COLUMN IF EXISTS user_id CASCADE;

  -- aggregation_results_cache: update unique constraint first
  ALTER TABLE aggregation_results_cache
    DROP CONSTRAINT IF EXISTS unique_cache_entry;

  ALTER TABLE aggregation_results_cache DROP COLUMN IF EXISTS user_id CASCADE;

  ALTER TABLE aggregation_results_cache
    ADD CONSTRAINT unique_cache_entry
    UNIQUE (patient_id, agg_metric_id, period_type, calculation_type_id, period_start);

  RAISE NOTICE '✅ Dropped user_id from 5 tables (already had patient_id)';
END $$;

-- =====================================================
-- STEP 2: Rename user_id → patient_id (Single Column Tables)
-- =====================================================

-- These ONLY have user_id, need to rename and add FK

-- patient_effective_responses
ALTER TABLE patient_effective_responses
  RENAME COLUMN user_id TO patient_id;
ALTER TABLE patient_effective_responses
  ADD CONSTRAINT patient_effective_responses_patient_fk
  FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE;

-- adherence_scores
ALTER TABLE adherence_scores
  RENAME COLUMN user_id TO patient_id;
ALTER TABLE adherence_scores
  ADD CONSTRAINT adherence_scores_patient_fk
  FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE;

-- patient_conditions
ALTER TABLE patient_conditions
  RENAME COLUMN user_id TO patient_id;
ALTER TABLE patient_conditions
  ADD CONSTRAINT patient_conditions_patient_fk
  FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE;

-- patient_recommendations
ALTER TABLE patient_recommendations
  RENAME COLUMN user_id TO patient_id;
ALTER TABLE patient_recommendations
  ADD CONSTRAINT patient_recommendations_patient_fk
  FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE;

-- patient_display_metrics_preferences
ALTER TABLE patient_display_metrics_preferences
  RENAME COLUMN user_id TO patient_id;
ALTER TABLE patient_display_metrics_preferences
  ADD CONSTRAINT patient_display_metrics_preferences_patient_fk
  FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE;

-- education_patient_engagement
ALTER TABLE education_patient_engagement
  RENAME COLUMN user_id TO patient_id;
ALTER TABLE education_patient_engagement
  ADD CONSTRAINT education_patient_engagement_patient_fk
  FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE;

-- parent_child_user_preferences
ALTER TABLE parent_child_user_preferences
  RENAME COLUMN user_id TO patient_id;
ALTER TABLE parent_child_user_preferences
  ADD CONSTRAINT parent_child_user_preferences_patient_fk
  FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE;

-- patient_events
ALTER TABLE patient_events
  RENAME COLUMN user_id TO patient_id;
ALTER TABLE patient_events
  ADD CONSTRAINT patient_events_patient_fk
  FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE;

-- biometrics_reference
ALTER TABLE biometrics_reference
  RENAME COLUMN user_id TO patient_id;
ALTER TABLE biometrics_reference
  ADD CONSTRAINT biometrics_reference_patient_fk
  FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE;

DO $$
BEGIN
  RAISE NOTICE '✅ Renamed user_id → patient_id on 9 tables';
END $$;

-- =====================================================
-- STEP 3: Update Views to Use patient_id
-- =====================================================

-- Recreate views that use user_id → patient_id

-- patient_current_question_scores
DROP VIEW IF EXISTS patient_current_question_scores CASCADE;
CREATE VIEW patient_current_question_scores AS
SELECT
  per.patient_id,  -- ← Changed from user_id
  per.question_number,
  sq.question_text,
  sq.category_id AS pillar,
  sq.section_id,
  sq.group_id,
  per.original_score,
  per.effective_score,
  (per.effective_score - COALESCE(per.original_score, 0)) AS score_improvement,
  per.response_source,
  per.original_response_option_id,
  per.effective_response_option_id,
  per.tracking_agg_metric_id,
  per.tracking_avg_value,
  per.tracking_data_points,
  CASE
    WHEN per.response_source = 'tracking' AND per.tracking_data_points >= 20 THEN 'high'
    WHEN per.response_source = 'tracking' AND per.tracking_data_points >= 10 THEN 'medium'
    WHEN per.response_source = 'tracking' THEN 'low'
    ELSE 'survey_only'
  END AS data_quality,
  per.original_response_date,
  per.last_updated_at,
  wpw.pillar_name,
  wpw.weight AS pillar_weight
FROM patient_effective_responses per
JOIN survey_questions_base sq ON per.question_number = sq.question_number
LEFT JOIN wellpath_scoring_question_pillar_weights wpw ON per.question_number = wpw.question_number
WHERE per.effective_score IS NOT NULL;

-- patient_current_scores
DROP VIEW IF EXISTS patient_current_scores CASCADE;
CREATE VIEW patient_current_scores AS
SELECT
  per.patient_id,  -- ← Changed from user_id
  sq.category_id AS pillar,
  sq.section_id,
  sq.group_id,
  per.question_number,
  per.effective_score AS score,
  per.response_source,
  per.tracking_avg_value,
  sq.question_text,
  CASE
    WHEN per.response_source = 'tracking' THEN 'Score updated from tracked behavior'
    ELSE 'Score from survey response'
  END AS score_note
FROM patient_effective_responses per
JOIN survey_questions_base sq ON per.question_number = sq.question_number
WHERE per.effective_score IS NOT NULL;

DO $$
BEGIN
  RAISE NOTICE '✅ Updated 2 views to use patient_id';
END $$;

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
    AND (
      table_name LIKE 'patient%' OR
      table_name LIKE 'adherence%' OR
      table_name LIKE 'education%' OR
      table_name LIKE 'biometrics%' OR
      table_name LIKE 'parent%'
    );

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

  IF v_tables_with_user_id = 0 THEN
    RAISE NOTICE '🎉 ALL user_id columns converted to patient_id!';
  ELSIF v_tables_with_user_id < 10 THEN
    RAISE NOTICE '⚠️  % tables still have user_id (likely views/scoring tables)', v_tables_with_user_id;
  ELSE
    RAISE WARNING '❌ Still have many user_id columns to convert';
  END IF;
END $$;

COMMIT;
