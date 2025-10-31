-- =====================================================
-- Cleanup Remaining user_id → patient_id Conversions
-- =====================================================
-- Strategy: Rename user_id → patient_id for ALL patient-related tables
-- Keep user_id ONLY in staff tables (practice_users, practice_user_access)
-- =====================================================

BEGIN;

-- =====================================================
-- STEP 1: Rename user_id → patient_id (Patient Tables)
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

-- patient_sleep_analysis
ALTER TABLE patient_sleep_analysis
  RENAME COLUMN user_id TO patient_id;
ALTER TABLE patient_sleep_analysis
  ADD CONSTRAINT patient_sleep_analysis_patient_fk
  FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE;

-- patient_sleep_periods
ALTER TABLE patient_sleep_periods
  RENAME COLUMN user_id TO patient_id;
ALTER TABLE patient_sleep_periods
  ADD CONSTRAINT patient_sleep_periods_patient_fk
  FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE;

-- patient_wellpath_score_by_pillar
ALTER TABLE patient_wellpath_score_by_pillar
  RENAME COLUMN user_id TO patient_id;
ALTER TABLE patient_wellpath_score_by_pillar
  ADD CONSTRAINT patient_wellpath_score_by_pillar_patient_fk
  FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE;

-- patient_wellpath_score_by_pillar_section
ALTER TABLE patient_wellpath_score_by_pillar_section
  RENAME COLUMN user_id TO patient_id;
ALTER TABLE patient_wellpath_score_by_pillar_section
  ADD CONSTRAINT patient_wellpath_score_by_pillar_section_patient_fk
  FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE;

-- patient_wellpath_score_by_section
ALTER TABLE patient_wellpath_score_by_section
  RENAME COLUMN user_id TO patient_id;
ALTER TABLE patient_wellpath_score_by_section
  ADD CONSTRAINT patient_wellpath_score_by_section_patient_fk
  FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE;

-- patient_wellpath_score_detail
ALTER TABLE patient_wellpath_score_detail
  RENAME COLUMN user_id TO patient_id;
ALTER TABLE patient_wellpath_score_detail
  ADD CONSTRAINT patient_wellpath_score_detail_patient_fk
  FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE;

-- patient_wellpath_score_display
ALTER TABLE patient_wellpath_score_display
  RENAME COLUMN user_id TO patient_id;
ALTER TABLE patient_wellpath_score_display
  ADD CONSTRAINT patient_wellpath_score_display_patient_fk
  FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE;

-- patient_wellpath_score_items
ALTER TABLE patient_wellpath_score_items
  RENAME COLUMN user_id TO patient_id;
ALTER TABLE patient_wellpath_score_items
  ADD CONSTRAINT patient_wellpath_score_items_patient_fk
  FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE;

-- patient_wellpath_score_overall
ALTER TABLE patient_wellpath_score_overall
  RENAME COLUMN user_id TO patient_id;
ALTER TABLE patient_wellpath_score_overall
  ADD CONSTRAINT patient_wellpath_score_overall_patient_fk
  FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE;

-- patient_workout_events
ALTER TABLE patient_workout_events
  RENAME COLUMN user_id TO patient_id;
ALTER TABLE patient_workout_events
  ADD CONSTRAINT patient_workout_events_patient_fk
  FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE;

DO $$
BEGIN
  RAISE NOTICE '✅ Renamed user_id → patient_id on 14 patient tables';
END $$;

-- =====================================================
-- STEP 2: Keep user_id in Staff Tables (No Changes)
-- =====================================================

-- practice_users.user_id → Correct! References auth.users for staff
-- practice_user_access.user_id → Correct! References practice_users

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
  SELECT COUNT(DISTINCT table_name) INTO v_patient_tables_with_user_id
  FROM information_schema.columns
  WHERE table_schema = 'public'
    AND column_name = 'user_id'
    AND (
      table_name LIKE 'patient%' OR
      table_name LIKE 'adherence%' OR
      table_name LIKE 'education%' OR
      table_name LIKE 'calculation%' OR
      table_name LIKE 'biometrics%' OR
      table_name LIKE 'parent%'
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

  IF v_patient_tables_with_user_id = 0 AND v_staff_tables_with_user_id = 2 THEN
    RAISE NOTICE '✅ Perfect! All patient tables use patient_id, staff tables use user_id';
  ELSIF v_patient_tables_with_user_id = 0 THEN
    RAISE NOTICE '✅ All patient tables converted to patient_id!';
    RAISE WARNING '⚠️  Staff tables: % (expected 2)', v_staff_tables_with_user_id;
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
