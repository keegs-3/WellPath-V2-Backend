-- =====================================================
-- Cleanup Remaining user_id → patient_id Conversions
-- =====================================================
-- Strategy:
-- 1. Rename user_id → patient_id for patient-related TABLES
-- 2. Recreate VIEWS to use patient_id instead of user_id
-- 3. Keep user_id in staff tables (practice_users, practice_user_access)
-- =====================================================

BEGIN;

-- =====================================================
-- STEP 1: Rename user_id → patient_id (Patient Tables Only)
-- =====================================================

-- calculation_queue
ALTER TABLE calculation_queue
  RENAME COLUMN user_id TO patient_id;
ALTER TABLE calculation_queue
  ADD CONSTRAINT calculation_queue_patient_fk
  FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE;

-- patient_category_events
ALTER TABLE patient_category_events
  RENAME COLUMN user_id TO patient_id;
ALTER TABLE patient_category_events
  ADD CONSTRAINT patient_category_events_patient_fk
  FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE;

-- patient_correlation_events
ALTER TABLE patient_correlation_events
  RENAME COLUMN user_id TO patient_id;
ALTER TABLE patient_correlation_events
  ADD CONSTRAINT patient_correlation_events_patient_fk
  FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE;

-- patient_quantity_events
ALTER TABLE patient_quantity_events
  RENAME COLUMN user_id TO patient_id;
ALTER TABLE patient_quantity_events
  ADD CONSTRAINT patient_quantity_events_patient_fk
  FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE;

-- patient_sleep_periods (base table for patient_sleep_analysis view)
ALTER TABLE patient_sleep_periods
  RENAME COLUMN user_id TO patient_id;
ALTER TABLE patient_sleep_periods
  ADD CONSTRAINT patient_sleep_periods_patient_fk
  FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE;

-- patient_wellpath_score_display
ALTER TABLE patient_wellpath_score_display
  RENAME COLUMN user_id TO patient_id;
ALTER TABLE patient_wellpath_score_display
  ADD CONSTRAINT patient_wellpath_score_display_patient_fk
  FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE;

-- patient_wellpath_score_items (base table for score views)
ALTER TABLE patient_wellpath_score_items
  RENAME COLUMN user_id TO patient_id;
ALTER TABLE patient_wellpath_score_items
  ADD CONSTRAINT patient_wellpath_score_items_patient_fk
  FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE;

-- patient_workout_events
ALTER TABLE patient_workout_events
  RENAME COLUMN user_id TO patient_id;
ALTER TABLE patient_workout_events
  ADD CONSTRAINT patient_workout_events_patient_fk
  FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE;

DO $$
BEGIN
  RAISE NOTICE '✅ Renamed user_id → patient_id on 8 patient tables';
END $$;

-- =====================================================
-- STEP 2: Recreate Views to Use patient_id
-- =====================================================

-- patient_sleep_analysis view
DROP VIEW IF EXISTS patient_sleep_analysis CASCADE;
CREATE VIEW patient_sleep_analysis AS
SELECT
  psp.patient_id,
  date(psp.period_start) AS sleep_date,
  min(psp.period_start) AS session_start,
  max(psp.period_end) AS session_end,
  (EXTRACT(epoch FROM (max(psp.period_end) - min(psp.period_start))) / 60::numeric) AS time_in_bed_minutes,
  sum(psp.duration_minutes) FILTER (WHERE spt.period_name = 'rem') AS rem_minutes,
  sum(psp.duration_minutes) FILTER (WHERE spt.period_name = 'deep') AS deep_minutes,
  sum(psp.duration_minutes) FILTER (WHERE spt.period_name = 'core') AS core_minutes,
  sum(psp.duration_minutes) FILTER (WHERE spt.period_name = 'awake') AS awake_minutes,
  sum(psp.duration_minutes) FILTER (WHERE spt.is_restorative = true) AS total_sleep_minutes,
  round(((sum(psp.duration_minutes) FILTER (WHERE spt.is_restorative = true) /
    NULLIF((EXTRACT(epoch FROM (max(psp.period_end) - min(psp.period_start))) / 60::numeric), 0::numeric)) * 100::numeric), 1) AS sleep_efficiency_percent
FROM patient_sleep_periods psp
LEFT JOIN def_ref_sleep_period_types spt ON psp.sleep_period_type_id = spt.id
GROUP BY psp.patient_id, date(psp.period_start);

-- patient_wellpath_score_by_pillar view
DROP VIEW IF EXISTS patient_wellpath_score_by_pillar CASCADE;
CREATE VIEW patient_wellpath_score_by_pillar AS
SELECT
  patient_id,
  patient_gender,
  patient_age,
  pillar_name,
  sum(CASE
    WHEN patient_gender = 'male' THEN patient_normalized_score_male
    ELSE patient_normalized_score_female
  END) AS patient_score,
  sum(CASE
    WHEN patient_gender = 'male' THEN max_normalized_score_male
    ELSE max_normalized_score_female
  END) AS max_score,
  CASE
    WHEN sum(CASE
      WHEN patient_gender = 'male' THEN max_normalized_score_male
      ELSE max_normalized_score_female
    END) > 0 THEN (
      sum(CASE
        WHEN patient_gender = 'male' THEN patient_normalized_score_male
        ELSE patient_normalized_score_female
      END) / sum(CASE
        WHEN patient_gender = 'male' THEN max_normalized_score_male
        ELSE max_normalized_score_female
      END) * 100
    )
    ELSE 0
  END AS score_percentage,
  count(*) AS item_count,
  max(updated_at) AS last_updated
FROM patient_wellpath_score_items
GROUP BY patient_id, patient_gender, patient_age, pillar_name;

-- patient_wellpath_score_by_pillar_section view
DROP VIEW IF EXISTS patient_wellpath_score_by_pillar_section CASCADE;
CREATE VIEW patient_wellpath_score_by_pillar_section AS
SELECT
  patient_id,
  patient_gender,
  patient_age,
  pillar_name,
  CASE
    WHEN item_type = 'biomarker' THEN 'Biomarkers'
    WHEN item_type = 'biometric' THEN 'Biometrics'
    WHEN item_type IN ('survey_question', 'survey_function') THEN 'Behaviors'
    WHEN item_type = 'education' THEN 'Education'
    ELSE 'Other'
  END AS section_name,
  sum(CASE
    WHEN patient_gender = 'male' THEN patient_normalized_score_male
    ELSE patient_normalized_score_female
  END) AS patient_score,
  sum(CASE
    WHEN patient_gender = 'male' THEN max_normalized_score_male
    ELSE max_normalized_score_female
  END) AS max_score,
  CASE
    WHEN sum(CASE
      WHEN patient_gender = 'male' THEN max_normalized_score_male
      ELSE max_normalized_score_female
    END) > 0 THEN (
      sum(CASE
        WHEN patient_gender = 'male' THEN patient_normalized_score_male
        ELSE patient_normalized_score_female
      END) / sum(CASE
        WHEN patient_gender = 'male' THEN max_normalized_score_male
        ELSE max_normalized_score_female
      END) * 100
    )
    ELSE 0
  END AS score_percentage,
  count(*) AS item_count,
  max(updated_at) AS last_updated
FROM patient_wellpath_score_items
GROUP BY patient_id, patient_gender, patient_age, pillar_name,
  CASE
    WHEN item_type = 'biomarker' THEN 'Biomarkers'
    WHEN item_type = 'biometric' THEN 'Biometrics'
    WHEN item_type IN ('survey_question', 'survey_function') THEN 'Behaviors'
    WHEN item_type = 'education' THEN 'Education'
    ELSE 'Other'
  END;

-- patient_wellpath_score_by_section view
DROP VIEW IF EXISTS patient_wellpath_score_by_section CASCADE;
CREATE VIEW patient_wellpath_score_by_section AS
SELECT
  patient_id,
  patient_gender,
  patient_age,
  CASE
    WHEN item_type = 'biomarker' THEN 'Biomarkers'
    WHEN item_type = 'biometric' THEN 'Biometrics'
    WHEN item_type IN ('survey_question', 'survey_function') THEN 'Behaviors'
    WHEN item_type = 'education' THEN 'Education'
    ELSE 'Other'
  END AS section_name,
  sum(CASE
    WHEN patient_gender = 'male' THEN patient_normalized_score_male
    ELSE patient_normalized_score_female
  END) AS patient_score,
  sum(CASE
    WHEN patient_gender = 'male' THEN max_normalized_score_male
    ELSE max_normalized_score_female
  END) AS max_score,
  CASE
    WHEN sum(CASE
      WHEN patient_gender = 'male' THEN max_normalized_score_male
      ELSE max_normalized_score_female
    END) > 0 THEN (
      sum(CASE
        WHEN patient_gender = 'male' THEN patient_normalized_score_male
        ELSE patient_normalized_score_female
      END) / sum(CASE
        WHEN patient_gender = 'male' THEN max_normalized_score_male
        ELSE max_normalized_score_female
      END) * 100
    )
    ELSE 0
  END AS score_percentage,
  count(*) AS item_count,
  max(updated_at) AS last_updated
FROM patient_wellpath_score_items
GROUP BY patient_id, patient_gender, patient_age,
  CASE
    WHEN item_type = 'biomarker' THEN 'Biomarkers'
    WHEN item_type = 'biometric' THEN 'Biometrics'
    WHEN item_type IN ('survey_question', 'survey_function') THEN 'Behaviors'
    WHEN item_type = 'education' THEN 'Education'
    ELSE 'Other'
  END;

-- patient_wellpath_score_detail view
DROP VIEW IF EXISTS patient_wellpath_score_detail CASCADE;
CREATE VIEW patient_wellpath_score_detail AS
SELECT
  patient_id,
  patient_gender,
  patient_age,
  pillar_name,
  CASE
    WHEN item_type = 'biomarker' THEN 'Biomarkers'
    WHEN item_type = 'biometric' THEN 'Biometrics'
    WHEN item_type IN ('survey_question', 'survey_function') THEN 'Behaviors'
    WHEN item_type = 'education' THEN 'Education'
    ELSE 'Other'
  END AS section_name,
  item_type,
  COALESCE(biomarker_name, biometric_name, question_number::text, function_name) AS item_name,
  patient_value,
  patient_value_numeric,
  score_band,
  raw_score,
  normalized_score,
  raw_weight,
  patient_normalized_score_male AS patient_score_male,
  patient_normalized_score_female AS patient_score_female,
  max_normalized_score_male AS max_score_male,
  max_normalized_score_female AS max_score_female,
  CASE
    WHEN patient_gender = 'male' THEN
      CASE
        WHEN max_normalized_score_male > 0 THEN patient_normalized_score_male / max_normalized_score_male * 100
        ELSE 0
      END
    ELSE
      CASE
        WHEN max_normalized_score_female > 0 THEN patient_normalized_score_female / max_normalized_score_female * 100
        ELSE 0
      END
  END AS item_score_percentage,
  max_grouping,
  data_collected_at,
  created_at,
  updated_at
FROM patient_wellpath_score_items
ORDER BY patient_id, pillar_name, item_type, COALESCE(biomarker_name, biometric_name, question_number::text, function_name);

-- patient_wellpath_score_overall view
DROP VIEW IF EXISTS patient_wellpath_score_overall CASCADE;
CREATE VIEW patient_wellpath_score_overall AS
SELECT
  patient_id,
  patient_gender,
  patient_age,
  sum(CASE
    WHEN patient_gender = 'male' THEN patient_normalized_score_male
    ELSE patient_normalized_score_female
  END) AS patient_score,
  sum(CASE
    WHEN patient_gender = 'male' THEN max_normalized_score_male
    ELSE max_normalized_score_female
  END) AS max_score,
  CASE
    WHEN sum(CASE
      WHEN patient_gender = 'male' THEN max_normalized_score_male
      ELSE max_normalized_score_female
    END) > 0 THEN (
      sum(CASE
        WHEN patient_gender = 'male' THEN patient_normalized_score_male
        ELSE patient_normalized_score_female
      END) / sum(CASE
        WHEN patient_gender = 'male' THEN max_normalized_score_male
        ELSE max_normalized_score_female
      END) * 100
    )
    ELSE 0
  END AS score_percentage,
  count(*) AS item_count,
  max(updated_at) AS last_updated
FROM patient_wellpath_score_items
GROUP BY patient_id, patient_gender, patient_age;

DO $$
BEGIN
  RAISE NOTICE '✅ Recreated 6 views to use patient_id';
END $$;

-- =====================================================
-- STEP 3: Verify Staff Tables Keep user_id
-- =====================================================

DO $$
BEGIN
  RAISE NOTICE '✅ Verified staff tables (practice_users, practice_user_access) keep user_id';
END $$;

-- =====================================================
-- VERIFICATION
-- =====================================================

DO $$
DECLARE
  v_patient_tables_with_user_id INTEGER;
  v_staff_tables_with_user_id INTEGER;
  v_tables_with_patient_id INTEGER;
BEGIN
  -- Count patient-related tables still using user_id
  SELECT COUNT(DISTINCT c.table_name) INTO v_patient_tables_with_user_id
  FROM information_schema.columns c
  JOIN information_schema.tables t ON c.table_name = t.table_name AND c.table_schema = t.table_schema
  WHERE c.table_schema = 'public'
    AND c.column_name = 'user_id'
    AND t.table_type = 'BASE TABLE'
    AND (
      c.table_name LIKE 'patient%' OR
      c.table_name LIKE 'adherence%' OR
      c.table_name LIKE 'education%' OR
      c.table_name LIKE 'calculation%' OR
      c.table_name LIKE 'biometrics%' OR
      c.table_name LIKE 'parent%'
    );

  -- Count staff tables with user_id (should be 2)
  SELECT COUNT(DISTINCT table_name) INTO v_staff_tables_with_user_id
  FROM information_schema.columns
  WHERE table_schema = 'public'
    AND column_name = 'user_id'
    AND table_name LIKE 'practice%';

  -- Count tables with patient_id
  SELECT COUNT(DISTINCT table_name) INTO v_tables_with_patient_id
  FROM information_schema.columns
  WHERE table_schema = 'public'
    AND column_name = 'patient_id';

  RAISE NOTICE '';
  RAISE NOTICE '🎉 Final Cleanup Complete!';
  RAISE NOTICE '';
  RAISE NOTICE 'Summary:';
  RAISE NOTICE '  Tables with patient_id: %', v_tables_with_patient_id;
  RAISE NOTICE '  Patient tables still with user_id: %', v_patient_tables_with_user_id;
  RAISE NOTICE '  Staff tables with user_id (expected=2): %', v_staff_tables_with_user_id;
  RAISE NOTICE '';

  IF v_patient_tables_with_user_id = 0 AND v_staff_tables_with_user_id >= 2 THEN
    RAISE NOTICE '✅ Perfect! All patient tables use patient_id, staff tables use user_id';
  ELSIF v_patient_tables_with_user_id = 0 THEN
    RAISE NOTICE '✅ All patient tables converted to patient_id!';
  ELSE
    RAISE WARNING '⚠️  % patient tables still have user_id', v_patient_tables_with_user_id;
  END IF;
END $$;

-- =====================================================
-- List Final Column Usage
-- =====================================================

DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE 'Final Column Usage:';
  RAISE NOTICE '  patient_id → Patient data (references patients.patient_id)';
  RAISE NOTICE '  user_id → Staff data (practice_users, practice_user_access)';
  RAISE NOTICE '';
  RAISE NOTICE 'Schema is now clean and consistent! 🎉';
END $$;

COMMIT;
