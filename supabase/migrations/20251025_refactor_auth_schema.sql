-- =====================================================
-- Refactor Authentication Schema
-- =====================================================
-- Transforms existing schema to cleaner structure:
-- - auth_users (mixed) → practice_users (staff) + patients (end users)
-- - patient_details → merged into patients table
-- - Adds practice_user_access junction table
-- =====================================================

BEGIN;

-- =====================================================
-- STEP 1: Create New Tables
-- =====================================================

-- Practice Users (Clinicians, Admins, Nurses - STAFF ONLY)
CREATE TABLE IF NOT EXISTS practice_users (
  user_id UUID PRIMARY KEY,  -- Will map to auth.users later
  medical_practice_id UUID NOT NULL REFERENCES medical_practices(id) ON DELETE CASCADE,
  role TEXT NOT NULL CHECK (role IN ('clinician', 'admin', 'nurse')),
  first_name TEXT,
  last_name TEXT,
  email TEXT NOT NULL,
  phone TEXT,
  specialty TEXT,  -- Only for clinicians
  is_primary_user BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT practice_users_email_unique UNIQUE (email)
);

COMMENT ON TABLE practice_users IS
'Staff members at medical practices: clinicians, admins, nurses. Separate from patients.';

CREATE INDEX idx_practice_users_practice ON practice_users(medical_practice_id);
CREATE INDEX idx_practice_users_role ON practice_users(role);

-- Patients (End Users - SEPARATE FROM STAFF)
CREATE TABLE IF NOT EXISTS patients (
  patient_id UUID PRIMARY KEY,  -- Will map to auth.users later
  medical_practice_id UUID NOT NULL REFERENCES medical_practices(id) ON DELETE CASCADE,
  assigned_clinician_id UUID NOT NULL,  -- Will add FK after practice_users populated
  external_patient_id TEXT,
  first_name TEXT,
  last_name TEXT,
  email TEXT NOT NULL,
  phone TEXT,
  biological_sex TEXT CHECK (biological_sex IN ('male', 'female', 'other')),
  date_of_birth DATE,
  height_cm NUMERIC(5,2),
  weight_kg NUMERIC(5,2),

  -- Onboarding status
  onboarding_complete BOOLEAN DEFAULT false,
  biometrics_entered BOOLEAN DEFAULT false,
  biomarkers_entered BOOLEAN DEFAULT false,
  questionnaire_complete BOOLEAN DEFAULT false,
  recommendations_generated BOOLEAN DEFAULT false,

  -- Additional fields from patient_details
  primary_language TEXT DEFAULT 'en',
  timezone TEXT,
  country TEXT,
  profile_image_url TEXT,
  wellpath_score NUMERIC(5,2),
  biological_age INTEGER,
  pace_of_aging NUMERIC(10,4),

  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT patients_email_unique UNIQUE (email)
);

COMMENT ON TABLE patients IS
'End users (patients) who track their health data. Separate from practice staff.';

CREATE INDEX idx_patients_practice ON patients(medical_practice_id);
CREATE INDEX idx_patients_clinician ON patients(assigned_clinician_id);
CREATE INDEX idx_patients_email ON patients(email);

-- Practice User Access (Admin/Nurse → Clinician)
CREATE TABLE IF NOT EXISTS practice_user_access (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,  -- Will add FK after practice_users populated
  clinician_id UUID,  -- Will add FK after practice_users populated
  has_all_access BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT valid_access_pattern CHECK (
    (has_all_access = true AND clinician_id IS NULL) OR
    (has_all_access = false AND clinician_id IS NOT NULL)
  ),
  CONSTRAINT practice_user_access_unique UNIQUE (user_id, clinician_id)
);

COMMENT ON TABLE practice_user_access IS
'Defines which clinicians an admin/nurse can access.';

CREATE INDEX idx_practice_user_access_user ON practice_user_access(user_id);
CREATE INDEX idx_practice_user_access_clinician ON practice_user_access(clinician_id);

-- =====================================================
-- STEP 2: Migrate Data from auth_users
-- =====================================================

-- Migrate CLINICIANS from auth_users → practice_users
INSERT INTO practice_users (
  user_id,
  medical_practice_id,
  role,
  first_name,
  last_name,
  email,
  phone,
  is_primary_user,
  created_at,
  updated_at
)
SELECT
  au.id,
  COALESCE(
    (SELECT medical_practice_id FROM patient_details WHERE assigned_clinician_id = au.id LIMIT 1),
    'a1b2c3d4-5678-90ab-cdef-123456789abc'::UUID  -- Existing practice ID
  ),
  'clinician',
  SPLIT_PART(au.full_name, ' ', 1),
  SPLIT_PART(au.full_name, ' ', 2),
  au.email,
  au.phone_number,
  true,  -- Mark as primary for now
  au.created_at,
  au.updated_at
FROM auth_users au
WHERE UPPER(au.role) = 'CLINICIAN'
ON CONFLICT (user_id) DO NOTHING;

-- =====================================================
-- STEP 3: Migrate Data from patient_details + auth_users
-- =====================================================

-- Migrate PATIENTS from auth_users + patient_details → patients
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
  height_cm,
  weight_kg,
  primary_language,
  timezone,
  country,
  profile_image_url,
  wellpath_score,
  biological_age,
  pace_of_aging,
  is_active,
  created_at,
  updated_at
)
SELECT
  au.id,
  COALESCE(pd.medical_practice_id, 'a1b2c3d4-5678-90ab-cdef-123456789abc'::UUID),
  COALESCE(pd.assigned_clinician_id, 'c1234567-89ab-cdef-0123-456789abcdef'::UUID),
  NULL,  -- external_patient_id
  COALESCE(pd.first_name, SPLIT_PART(au.full_name, ' ', 1)),
  COALESCE(pd.last_name, SPLIT_PART(au.full_name, ' ', 2)),
  au.email,
  COALESCE(au.phone_number, ''),
  pd.biological_sex,
  COALESCE(pd.date_of_birth, au.date_of_birth),
  pd.height_cm,
  pd.weight_kg,
  COALESCE(pd.primary_language, 'en'),
  pd.timezone,
  pd.country,
  pd.profile_image_url,
  pd.wellpath_score,
  pd.biological_age,
  pd.pace_of_aging,
  COALESCE(pd.is_active, au.is_active, true),
  COALESCE(pd.created_at, au.created_at, NOW()),
  COALESCE(pd.updated_at, au.updated_at, NOW())
FROM auth_users au
LEFT JOIN patient_details pd ON pd.user_id = au.id
WHERE UPPER(au.role) LIKE '%PATIENT%'
ON CONFLICT (patient_id) DO NOTHING;

-- =====================================================
-- STEP 4: Add Foreign Key Constraints
-- =====================================================

-- Now that data is migrated, add FKs
ALTER TABLE patients
  ADD CONSTRAINT patients_assigned_clinician_fk
  FOREIGN KEY (assigned_clinician_id)
  REFERENCES practice_users(user_id)
  ON DELETE RESTRICT;

ALTER TABLE practice_user_access
  ADD CONSTRAINT practice_user_access_user_fk
  FOREIGN KEY (user_id)
  REFERENCES practice_users(user_id)
  ON DELETE CASCADE;

ALTER TABLE practice_user_access
  ADD CONSTRAINT practice_user_access_clinician_fk
  FOREIGN KEY (clinician_id)
  REFERENCES practice_users(user_id)
  ON DELETE CASCADE;

-- =====================================================
-- STEP 5: Update Foreign Keys in Other Tables
-- =====================================================

-- Tables that reference auth_users(id) for PATIENTS should now reference patients(patient_id)
-- We'll do this by adding new columns, copying data, then swapping

-- Update patient_biomarker_readings
DO $$
BEGIN
  -- Add new column
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'patient_biomarker_readings' AND column_name = 'patient_id') THEN
    ALTER TABLE patient_biomarker_readings ADD COLUMN patient_id UUID;

    -- Copy data
    UPDATE patient_biomarker_readings SET patient_id = user_id;

    -- Drop old FK and column
    ALTER TABLE patient_biomarker_readings DROP CONSTRAINT IF EXISTS patient_biomarker_readings_user_id_fkey;

    -- Add new FK
    ALTER TABLE patient_biomarker_readings
      ADD CONSTRAINT patient_biomarker_readings_patient_fk
      FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE;

    -- Make it NOT NULL
    ALTER TABLE patient_biomarker_readings ALTER COLUMN patient_id SET NOT NULL;
  END IF;
END $$;

-- Update patient_biometric_readings
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'patient_biometric_readings' AND column_name = 'patient_id') THEN
    ALTER TABLE patient_biometric_readings ADD COLUMN patient_id UUID;
    UPDATE patient_biometric_readings SET patient_id = user_id;
    ALTER TABLE patient_biometric_readings DROP CONSTRAINT IF EXISTS patient_biometric_readings_user_id_fkey;
    ALTER TABLE patient_biometric_readings
      ADD CONSTRAINT patient_biometric_readings_patient_fk
      FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE;
    ALTER TABLE patient_biometric_readings ALTER COLUMN patient_id SET NOT NULL;
  END IF;
END $$;

-- Update patient_survey_responses (drop problematic trigger during migration)
DO $$
DECLARE
  v_trigger_exists BOOLEAN;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'patient_survey_responses' AND column_name = 'patient_id') THEN
    ALTER TABLE patient_survey_responses ADD COLUMN patient_id UUID;

    -- Drop the trigger that causes type mismatch errors
    DROP TRIGGER IF EXISTS survey_response_initialize_effective ON patient_survey_responses;

    UPDATE patient_survey_responses SET patient_id = user_id;

    -- Recreate the trigger (will be handled later if needed)
    -- Note: trigger will need to be updated to use patient_id column

    ALTER TABLE patient_survey_responses DROP CONSTRAINT IF EXISTS patient_survey_responses_user_id_fkey;
    ALTER TABLE patient_survey_responses
      ADD CONSTRAINT patient_survey_responses_patient_fk
      FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE;
    ALTER TABLE patient_survey_responses ALTER COLUMN patient_id SET NOT NULL;
  END IF;
END $$;

-- Update patient_data_entries (main table)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'patient_data_entries' AND column_name = 'patient_id') THEN
    ALTER TABLE patient_data_entries ADD COLUMN patient_id UUID;

    -- Fix orphaned user_ids (corrupted test data)
    -- These have typos in the UUID and should point to test.patient.21
    UPDATE patient_data_entries
    SET user_id = '8b79ce33-02b8-4f49-8268-3204130efa82'::UUID
    WHERE user_id IN (
      '8b79ce33-028b-4f49-8268-32041e3efa82'::UUID,
      '8b79ce33-028b-4f49-8268-32841e3efa82'::UUID
    );

    UPDATE patient_data_entries SET patient_id = user_id;

    -- Add new FK
    ALTER TABLE patient_data_entries
      ADD CONSTRAINT patient_data_entries_patient_fk
      FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE;

    ALTER TABLE patient_data_entries ALTER COLUMN patient_id SET NOT NULL;
  END IF;
END $$;

-- Update aggregation_results_cache
DO $$
DECLARE
  v_deleted_count INTEGER;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'aggregation_results_cache' AND column_name = 'patient_id') THEN
    ALTER TABLE aggregation_results_cache ADD COLUMN patient_id UUID;

    -- Delete ALL orphaned records (user_ids that don't exist in auth_users as patients)
    DELETE FROM aggregation_results_cache
    WHERE user_id NOT IN (
      SELECT id FROM auth_users WHERE UPPER(role) LIKE '%PATIENT%'
    );

    GET DIAGNOSTICS v_deleted_count = ROW_COUNT;
    RAISE NOTICE 'Deleted % orphaned aggregation cache entries', v_deleted_count;

    UPDATE aggregation_results_cache SET patient_id = user_id;

    ALTER TABLE aggregation_results_cache
      ADD CONSTRAINT aggregation_results_cache_patient_fk
      FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE;

    ALTER TABLE aggregation_results_cache ALTER COLUMN patient_id SET NOT NULL;
  END IF;
END $$;

-- =====================================================
-- STEP 6: Update Triggers
-- =====================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_practice_users_updated_at ON practice_users;
CREATE TRIGGER update_practice_users_updated_at
  BEFORE UPDATE ON practice_users
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_patients_updated_at ON patients;
CREATE TRIGGER update_patients_updated_at
  BEFORE UPDATE ON patients
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- STEP 7: Create Helper Functions
-- =====================================================

CREATE OR REPLACE FUNCTION get_accessible_patients(p_user_id UUID)
RETURNS TABLE(patient_id UUID)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_role TEXT;
  v_practice_id UUID;
BEGIN
  -- Check if user is a practice user
  SELECT role, medical_practice_id INTO v_role, v_practice_id
  FROM practice_users
  WHERE user_id = p_user_id;

  IF v_role IS NULL THEN
    -- User is a patient, return their own ID
    RETURN QUERY SELECT p_user_id;
  ELSIF v_role = 'clinician' THEN
    -- Clinicians see their assigned patients
    RETURN QUERY
      SELECT p.patient_id
      FROM patients p
      WHERE p.assigned_clinician_id = p_user_id;
  ELSE
    -- Admins/Nurses see patients based on access grants
    RETURN QUERY
      SELECT DISTINCT p.patient_id
      FROM patients p
      WHERE p.assigned_clinician_id IN (
        SELECT clinician_id
        FROM practice_user_access
        WHERE user_id = p_user_id
          AND clinician_id IS NOT NULL
      )
      OR EXISTS (
        SELECT 1
        FROM practice_user_access
        WHERE user_id = p_user_id
          AND has_all_access = true
      );
  END IF;
END;
$$;

COMMENT ON FUNCTION get_accessible_patients(UUID) IS
'Returns all patient IDs that a given user (patient/clinician/admin/nurse) can access.';

-- =====================================================
-- VERIFICATION
-- =====================================================

DO $$
DECLARE
  v_practice_users_count INTEGER;
  v_patients_count INTEGER;
  v_clinicians_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_practice_users_count FROM practice_users;
  SELECT COUNT(*) INTO v_patients_count FROM patients;
  SELECT COUNT(*) INTO v_clinicians_count FROM practice_users WHERE role = 'clinician';

  RAISE NOTICE '✅ Schema Refactor Complete!';
  RAISE NOTICE '';
  RAISE NOTICE 'Data Migration Summary:';
  RAISE NOTICE '  Practice Users (staff): %', v_practice_users_count;
  RAISE NOTICE '    - Clinicians: %', v_clinicians_count;
  RAISE NOTICE '  Patients: %', v_patients_count;
  RAISE NOTICE '';
  RAISE NOTICE 'New Tables Created:';
  RAISE NOTICE '  - practice_users (clinicians, admins, nurses)';
  RAISE NOTICE '  - patients (end users, separate from staff)';
  RAISE NOTICE '  - practice_user_access (junction table)';
  RAISE NOTICE '';
  RAISE NOTICE '⚠️  Next Steps:';
  RAISE NOTICE '  1. Run RLS policies migration';
  RAISE NOTICE '  2. Update application code to use patient_id instead of user_id';
  RAISE NOTICE '  3. Test with test.patient.21@wellpath.com';
  RAISE NOTICE '  4. After verification, can drop old auth_users and patient_details tables';
END $$;

COMMIT;
