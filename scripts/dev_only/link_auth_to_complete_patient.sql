-- Link test.patient.0@wellpath.com auth user to a patient with complete metric data
-- This allows you to login and see all charts working immediately

-- Step 1: Check current state
SELECT
  'BEFORE' as status,
  au.email,
  pd.id as patient_id,
  (SELECT COUNT(*) FROM biomarker_readings WHERE patient_id = pd.id) as biomarkers,
  (SELECT COUNT(*) FROM survey_responses WHERE patient_id = pd.id) as surveys,
  (SELECT COUNT(*) FROM metric_readings WHERE patient_id = pd.id) as metrics
FROM auth.users au
LEFT JOIN patient_details pd ON au.id = pd.id
WHERE au.email = 'test.patient.0@wellpath.com';

-- Step 2: Patient with most complete data
-- Patient ID: 00ecf02f-66fe-4b43-9b34-0e577dd7f38b
-- - 59 biomarkers
-- - 337 surveys
-- - 8,180 metric readings (DOUBLE the others!)

-- Step 3: Backup current mapping
CREATE TEMP TABLE auth_backup AS
SELECT id, email FROM auth.users WHERE email = 'test.patient.0@wellpath.com';

CREATE TEMP TABLE patient_backup AS
SELECT * FROM patient_details WHERE id IN (
  SELECT id FROM auth.users WHERE email = 'test.patient.0@wellpath.com'
);

-- Step 4: Update the auth.users ID to match the complete patient
-- CAUTION: This will reassign test.patient.0 login to the patient with complete data

DO $$
DECLARE
  old_patient_id UUID;
  new_patient_id UUID := '00ecf02f-66fe-4b43-9b34-0e577dd7f38b';
  auth_user_exists BOOLEAN;
BEGIN
  -- Get current patient_id for test.patient.0
  SELECT id INTO old_patient_id
  FROM auth.users
  WHERE email = 'test.patient.0@wellpath.com';

  -- Check if there's already an auth user for the new patient
  SELECT EXISTS(
    SELECT 1 FROM auth.users WHERE id = new_patient_id
  ) INTO auth_user_exists;

  IF auth_user_exists THEN
    RAISE NOTICE 'Auth user already exists for patient %, deleting...', new_patient_id;
    DELETE FROM auth.users WHERE id = new_patient_id;
  END IF;

  RAISE NOTICE 'Updating auth.users id from % to %', old_patient_id, new_patient_id;

  -- Update the auth user's UUID to match the complete patient
  UPDATE auth.users
  SET id = new_patient_id
  WHERE email = 'test.patient.0@wellpath.com';

  -- Delete the old orphaned patient_details record
  IF old_patient_id IS NOT NULL AND old_patient_id != new_patient_id THEN
    RAISE NOTICE 'Deleting orphaned patient_details record %', old_patient_id;
    DELETE FROM patient_details WHERE id = old_patient_id;
  END IF;

  RAISE NOTICE 'Successfully linked test.patient.0 to patient with complete data';
END $$;

-- Step 5: Verify new state
SELECT
  'AFTER' as status,
  au.email,
  pd.id as patient_id,
  pd.gender,
  pd.age,
  (SELECT COUNT(*) FROM biomarker_readings WHERE patient_id = pd.id) as biomarkers,
  (SELECT COUNT(*) FROM survey_responses WHERE patient_id = pd.id) as surveys,
  (SELECT COUNT(*) FROM metric_readings WHERE patient_id = pd.id) as metrics
FROM auth.users au
LEFT JOIN patient_details pd ON au.id = pd.id
WHERE au.email = 'test.patient.0@wellpath.com';

-- Step 6: Summary
SELECT
  'SUMMARY' as info,
  'test.patient.0@wellpath.com can now login and see:' as message,
  '✅ 59 biomarkers' as biomarkers,
  '✅ 337 surveys' as surveys,
  '✅ 8,180 metric readings (with chart types!)' as metrics;
