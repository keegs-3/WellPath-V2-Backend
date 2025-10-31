-- =====================================================
-- Populate Test Data for Authentication Schema
-- =====================================================
-- Creates test practice, clinician, and links existing
-- 3 patient users to the new schema
-- =====================================================

BEGIN;

-- =====================================================
-- 1. Create Test Medical Practice
-- =====================================================

INSERT INTO medical_practices (
  practice_id,
  practice_name,
  specialty,
  location,
  billing_status,
  seat_count
)
VALUES (
  'a1b2c3d4-e5f6-7890-abcd-ef1234567890'::UUID,
  'WellPath Test Practice',
  'General Medicine',
  'San Francisco, CA',
  'trial',
  3
)
ON CONFLICT (practice_id) DO NOTHING;

-- =====================================================
-- 2. Create Test Clinician
-- =====================================================

-- First, check if clinician exists in auth.users
-- If not, you'll need to create it via Supabase Auth UI
-- For now, we'll use a placeholder UUID and update it later

DO $$
DECLARE
  v_clinician_id UUID := 'c1111111-1111-1111-1111-111111111111'::UUID;
BEGIN
  -- Insert test clinician
  INSERT INTO practice_users (
    user_id,
    medical_practice_id,
    role,
    first_name,
    last_name,
    email,
    phone,
    specialty,
    is_primary_user
  )
  VALUES (
    v_clinician_id,
    'a1b2c3d4-e5f6-7890-abcd-ef1234567890'::UUID,
    'clinician',
    'Dr. John',
    'Smith',
    'test.clinician@wellpath.com',
    '+1-555-0100',
    'General Medicine',
    true
  )
  ON CONFLICT (user_id) DO NOTHING;

  RAISE NOTICE 'Created test clinician: %', v_clinician_id;
  RAISE NOTICE 'Email: test.clinician@wellpath.com';
  RAISE NOTICE 'NOTE: You need to create this user in Supabase Auth with this UUID';
END $$;

-- =====================================================
-- 3. Link Existing Patients to Schema
-- =====================================================

-- Patient 1: test.patient.21@wellpath.com
INSERT INTO patients (
  patient_id,
  medical_practice_id,
  assigned_clinician_id,
  external_patient_id,
  first_name,
  last_name,
  email,
  phone,
  biological_sex,
  date_of_birth,
  onboarding_complete,
  biometrics_entered,
  biomarkers_entered,
  questionnaire_complete,
  recommendations_generated
)
VALUES (
  '8b79ce33-02b8-4f49-8268-3204130efa82'::UUID,
  'a1b2c3d4-e5f6-7890-abcd-ef1234567890'::UUID,
  'c1111111-1111-1111-1111-111111111111'::UUID,
  'PT-001',
  'Test',
  'Patient',
  'test.patient.21@wellpath.com',
  '+1-555-0101',
  'male',
  '1990-01-15',
  true,
  true,
  true,
  true,
  true
)
ON CONFLICT (patient_id) DO UPDATE SET
  medical_practice_id = EXCLUDED.medical_practice_id,
  assigned_clinician_id = EXCLUDED.assigned_clinician_id,
  updated_at = NOW();

-- Patient 2: Test patient with biomarker data
INSERT INTO patients (
  patient_id,
  medical_practice_id,
  assigned_clinician_id,
  external_patient_id,
  first_name,
  last_name,
  email,
  biological_sex,
  date_of_birth,
  onboarding_complete,
  biometrics_entered,
  biomarkers_entered,
  questionnaire_complete,
  recommendations_generated
)
VALUES (
  '1758fa60-a306-440e-8ae6-9e68fd502bc2'::UUID,
  'a1b2c3d4-e5f6-7890-abcd-ef1234567890'::UUID,
  'c1111111-1111-1111-1111-111111111111'::UUID,
  'PT-002',
  'Test',
  'Patient 2',
  'test.patient.2@wellpath.com',
  'female',
  '1985-03-22',
  true,
  true,
  true,
  true,
  true
)
ON CONFLICT (patient_id) DO UPDATE SET
  medical_practice_id = EXCLUDED.medical_practice_id,
  assigned_clinician_id = EXCLUDED.assigned_clinician_id,
  updated_at = NOW();

-- Patient 3: Test patient with biomarker data
INSERT INTO patients (
  patient_id,
  medical_practice_id,
  assigned_clinician_id,
  external_patient_id,
  first_name,
  last_name,
  email,
  biological_sex,
  date_of_birth,
  onboarding_complete,
  biometrics_entered,
  biomarkers_entered,
  questionnaire_complete,
  recommendations_generated
)
VALUES (
  'd9581a86-0f30-4be4-ba9e-6ae269700d4d'::UUID,
  'a1b2c3d4-e5f6-7890-abcd-ef1234567890'::UUID,
  'c1111111-1111-1111-1111-111111111111'::UUID,
  'PT-003',
  'Test',
  'Patient 3',
  'test.patient.3@wellpath.com',
  'male',
  '1992-07-08',
  true,
  true,
  true,
  true,
  true
)
ON CONFLICT (patient_id) DO UPDATE SET
  medical_practice_id = EXCLUDED.medical_practice_id,
  assigned_clinician_id = EXCLUDED.assigned_clinician_id,
  updated_at = NOW();

-- =====================================================
-- 4. Create Test Admin/Nurse (Optional)
-- =====================================================

-- Create test admin with access to all clinicians
DO $$
DECLARE
  v_admin_id UUID := 'a2222222-2222-2222-2222-222222222222'::UUID;
BEGIN
  INSERT INTO practice_users (
    user_id,
    medical_practice_id,
    role,
    first_name,
    last_name,
    email,
    is_primary_user
  )
  VALUES (
    v_admin_id,
    'a1b2c3d4-e5f6-7890-abcd-ef1234567890'::UUID,
    'admin',
    'Test',
    'Admin',
    'test.admin@wellpath.com',
    false
  )
  ON CONFLICT (user_id) DO NOTHING;

  -- Grant admin access to all clinicians
  INSERT INTO practice_user_access (
    user_id,
    clinician_id,
    has_all_access
  )
  VALUES (
    v_admin_id,
    NULL,
    true
  )
  ON CONFLICT (user_id, clinician_id) DO NOTHING;

  RAISE NOTICE 'Created test admin: %', v_admin_id;
  RAISE NOTICE 'Email: test.admin@wellpath.com';
END $$;

-- =====================================================
-- VERIFICATION
-- =====================================================

DO $$
DECLARE
  v_practice_count INTEGER;
  v_clinician_count INTEGER;
  v_patient_count INTEGER;
  v_admin_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_practice_count FROM medical_practices;
  SELECT COUNT(*) INTO v_clinician_count FROM practice_users WHERE role = 'clinician';
  SELECT COUNT(*) INTO v_patient_count FROM patients;
  SELECT COUNT(*) INTO v_admin_count FROM practice_users WHERE role IN ('admin', 'nurse');

  RAISE NOTICE '✅ Test Data Populated';
  RAISE NOTICE '';
  RAISE NOTICE 'Summary:';
  RAISE NOTICE '  Medical Practices: %', v_practice_count;
  RAISE NOTICE '  Clinicians: %', v_clinician_count;
  RAISE NOTICE '  Patients: %', v_patient_count;
  RAISE NOTICE '  Admins/Nurses: %', v_admin_count;
  RAISE NOTICE '';
  RAISE NOTICE 'Test Users:';
  RAISE NOTICE '  Patient: test.patient.21@wellpath.com (password: wellpath123)';
  RAISE NOTICE '  Patient: 1758fa60-a306-440e-8ae6-9e68fd502bc2';
  RAISE NOTICE '  Patient: d9581a86-0f30-4be4-ba9e-6ae269700d4d';
  RAISE NOTICE '';
  RAISE NOTICE '⚠️  IMPORTANT: Create these auth.users via Supabase Auth:';
  RAISE NOTICE '  - test.clinician@wellpath.com (UUID: c1111111-1111-1111-1111-111111111111)';
  RAISE NOTICE '  - test.admin@wellpath.com (UUID: a2222222-2222-2222-2222-222222222222)';
END $$;

-- =====================================================
-- Show Accessible Patients (Testing)
-- =====================================================

-- Test get_accessible_patients function for each user
SELECT
  'Patient 1 Access' as test_case,
  patient_id
FROM get_accessible_patients('8b79ce33-02b8-4f49-8268-3204130efa82'::UUID)
UNION ALL
SELECT
  'Clinician Access',
  patient_id
FROM get_accessible_patients('c1111111-1111-1111-1111-111111111111'::UUID)
UNION ALL
SELECT
  'Admin Access',
  patient_id
FROM get_accessible_patients('a2222222-2222-2222-2222-222222222222'::UUID);

COMMIT;
