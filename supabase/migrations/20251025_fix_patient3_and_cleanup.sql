-- =====================================================
-- Fix Patient 3 UUID Mismatch & Cleanup Old Tables
-- =====================================================
-- Issue: Patient 3 has mismatched UUIDs between patients table and auth.users
-- Fix: Update to use the correct auth.users UUID
-- Also: Drop old public.auth_users and patient_details tables
-- =====================================================

BEGIN;

-- =====================================================
-- STEP 1: Fix Patient 3 UUID Mismatch
-- =====================================================

-- Current situation:
-- - patients.patient_id = 'd9581a86-0f30-4be4-ba9e-6ae269700d4d' (WRONG)
-- - auth.users.id = 'e21d19f7-4f80-4b76-b047-a74a4e87956e' (CORRECT)

DO $$
DECLARE
  v_old_uuid UUID := 'd9581a86-0f30-4be4-ba9e-6ae269700d4d'::UUID;
  v_new_uuid UUID := 'e21d19f7-4f80-4b76-b047-a74a4e87956e'::UUID;
  v_biomarkers_updated INTEGER;
  v_biometrics_updated INTEGER;
BEGIN
  -- STEP 1: Create patient record with correct UUID FIRST
  DELETE FROM patients WHERE patient_id = v_old_uuid;

  INSERT INTO patients (
    patient_id,
    medical_practice_id,
    assigned_clinician_id,
    first_name,
    last_name,
    email,
    biological_sex,
    date_of_birth,
    is_active
  )
  VALUES (
    v_new_uuid,
    'a1b2c3d4-5678-90ab-cdef-123456789abc'::UUID,
    'c1234567-89ab-cdef-0123-456789abcdef'::UUID,
    'Test',
    'Patient 3',
    'test.patient.3@wellpath.com',
    'male',
    '1992-07-08',
    true
  )
  ON CONFLICT (patient_id) DO UPDATE SET
    email = EXCLUDED.email,
    first_name = EXCLUDED.first_name,
    last_name = EXCLUDED.last_name;

  -- STEP 2: Now update biomarker/biometric readings to point to correct patient
  UPDATE patient_biomarker_readings
  SET user_id = v_new_uuid, patient_id = v_new_uuid
  WHERE user_id = v_old_uuid OR patient_id = v_old_uuid;

  GET DIAGNOSTICS v_biomarkers_updated = ROW_COUNT;

  UPDATE patient_biometric_readings
  SET user_id = v_new_uuid, patient_id = v_new_uuid
  WHERE user_id = v_old_uuid OR patient_id = v_old_uuid;

  GET DIAGNOSTICS v_biometrics_updated = ROW_COUNT;

  RAISE NOTICE '✅ Fixed Patient 3 UUID mismatch';
  RAISE NOTICE '  Updated % biomarker readings', v_biomarkers_updated;
  RAISE NOTICE '  Updated % biometric readings', v_biometrics_updated;
  RAISE NOTICE '  Old UUID: %', v_old_uuid;
  RAISE NOTICE '  New UUID: %', v_new_uuid;
END $$;

-- =====================================================
-- STEP 2: Update Email in auth.users for Patient 2
-- =====================================================

-- Patient 2 has auth email "test@wellpath.dev" but should be "old.test.patient.21@wellpath.com"
-- This is just cosmetic - auth email doesn't need to match patient email
-- Skipping for now to avoid breaking existing auth sessions

-- =====================================================
-- STEP 3: Drop Old public.auth_users Table
-- =====================================================

-- This table is no longer needed - we migrated everything to:
-- - practice_users (for staff)
-- - patients (for end users)
-- - auth.users (Supabase's real auth table)

DO $$
BEGIN
  -- Check if there are any foreign keys pointing to auth_users
  RAISE NOTICE 'Checking for foreign keys to public.auth_users...';

  -- List all FKs (for information only)
  PERFORM 1;
END $$;

-- Show foreign keys before dropping
SELECT
  tc.table_name,
  kcu.column_name,
  ccu.table_name AS foreign_table_name,
  ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
  AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
  AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND ccu.table_name = 'auth_users'
ORDER BY tc.table_name;

-- Drop all foreign keys to auth_users first
DO $$
DECLARE
  r RECORD;
BEGIN
  FOR r IN (
    SELECT
      tc.table_name,
      tc.constraint_name
    FROM information_schema.table_constraints AS tc
    JOIN information_schema.constraint_column_usage AS ccu
      ON ccu.constraint_name = tc.constraint_name
      AND ccu.table_schema = tc.table_schema
    WHERE tc.constraint_type = 'FOREIGN KEY'
      AND ccu.table_name = 'auth_users'
      AND tc.table_schema = 'public'
  )
  LOOP
    EXECUTE format('ALTER TABLE %I DROP CONSTRAINT IF EXISTS %I CASCADE',
                   r.table_name, r.constraint_name);
    RAISE NOTICE 'Dropped FK: %.%', r.table_name, r.constraint_name;
  END LOOP;
END $$;

-- Now drop the table
DROP TABLE IF EXISTS public.auth_users CASCADE;

-- Drop patient_details table
DROP TABLE IF EXISTS public.patient_details CASCADE;

-- =====================================================
-- VERIFICATION
-- =====================================================

DO $$
DECLARE
  v_patient3_auth_match BOOLEAN;
  v_all_patients_have_auth INTEGER;
  v_total_patients INTEGER;
BEGIN
  -- Check patient 3 now has matching auth
  SELECT EXISTS (
    SELECT 1 FROM patients p
    INNER JOIN auth.users au ON au.id = p.patient_id
    WHERE p.email = 'test.patient.3@wellpath.com'
  ) INTO v_patient3_auth_match;

  -- Check all patients have auth accounts
  SELECT COUNT(*) INTO v_total_patients FROM patients;

  SELECT COUNT(*) INTO v_all_patients_have_auth
  FROM patients p
  INNER JOIN auth.users au ON au.id = p.patient_id;

  RAISE NOTICE '';
  RAISE NOTICE '✅ Cleanup Complete!';
  RAISE NOTICE '';
  RAISE NOTICE 'Verification:';
  RAISE NOTICE '  Patient 3 has auth account: %',
    CASE WHEN v_patient3_auth_match THEN '✅ YES' ELSE '❌ NO' END;
  RAISE NOTICE '  Total patients: %', v_total_patients;
  RAISE NOTICE '  Patients with auth: %', v_all_patients_have_auth;
  RAISE NOTICE '';

  IF v_all_patients_have_auth < v_total_patients THEN
    RAISE WARNING '⚠️  % patients missing auth accounts!',
      v_total_patients - v_all_patients_have_auth;
  ELSE
    RAISE NOTICE '✅ All patients have auth accounts';
  END IF;

  RAISE NOTICE '';
  RAISE NOTICE 'Dropped tables:';
  RAISE NOTICE '  - public.auth_users';
  RAISE NOTICE '  - public.patient_details';
  RAISE NOTICE '';
  RAISE NOTICE 'Active auth tables:';
  RAISE NOTICE '  - auth.users (Supabase Auth - THE source of truth)';
  RAISE NOTICE '  - public.practice_users (staff metadata)';
  RAISE NOTICE '  - public.patients (patient metadata)';
END $$;

COMMIT;
