-- =====================================================
-- Create Authentication & Authorization Schema
-- =====================================================
-- Creates the core user hierarchy for WellPath:
-- - Medical Practices (customers)
-- - Practice Users (clinicians, admins, nurses)
-- - Patients (end users)
-- - Access Control (admin/nurse access to clinicians)
-- =====================================================

BEGIN;

-- =====================================================
-- 1. Medical Practices Table
-- =====================================================

CREATE TABLE IF NOT EXISTS medical_practices (
  practice_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  practice_name TEXT NOT NULL,
  specialty TEXT,
  location TEXT,
  billing_status TEXT CHECK (billing_status IN ('active', 'suspended', 'trial')) DEFAULT 'trial',
  seat_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE medical_practices IS
'Medical practices that subscribe to WellPath. Billing is per-seat (per patient).';

CREATE INDEX idx_medical_practices_billing ON medical_practices(billing_status);

-- =====================================================
-- 2. Practice Users Table (Clinicians, Admins, Nurses)
-- =====================================================

CREATE TABLE IF NOT EXISTS practice_users (
  user_id UUID PRIMARY KEY,  -- FK to auth.users
  medical_practice_id UUID NOT NULL REFERENCES medical_practices(practice_id) ON DELETE CASCADE,
  role TEXT NOT NULL CHECK (role IN ('clinician', 'admin', 'nurse')),
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  email TEXT NOT NULL,
  phone TEXT,
  specialty TEXT,  -- Only for clinicians
  is_primary_user BOOLEAN DEFAULT false,  -- The user who set up the practice
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT practice_users_email_unique UNIQUE (email)
);

COMMENT ON TABLE practice_users IS
'Staff members at medical practices: clinicians, admins, nurses. All reference auth.users.';

CREATE INDEX idx_practice_users_practice ON practice_users(medical_practice_id);
CREATE INDEX idx_practice_users_role ON practice_users(role);
CREATE INDEX idx_practice_users_clinicians ON practice_users(medical_practice_id, role) WHERE role = 'clinician';

-- =====================================================
-- 3. Patients Table
-- =====================================================

CREATE TABLE IF NOT EXISTS patients (
  patient_id UUID PRIMARY KEY,  -- FK to auth.users
  medical_practice_id UUID NOT NULL REFERENCES medical_practices(practice_id) ON DELETE CASCADE,
  assigned_clinician_id UUID NOT NULL REFERENCES practice_users(user_id) ON DELETE RESTRICT,
  external_patient_id TEXT,  -- Their EHR/EMR ID (optional)
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  email TEXT NOT NULL,
  phone TEXT,
  biological_sex TEXT CHECK (biological_sex IN ('male', 'female', 'other')),
  date_of_birth DATE,

  -- Onboarding status
  onboarding_complete BOOLEAN DEFAULT false,
  biometrics_entered BOOLEAN DEFAULT false,
  biomarkers_entered BOOLEAN DEFAULT false,
  questionnaire_complete BOOLEAN DEFAULT false,
  recommendations_generated BOOLEAN DEFAULT false,
  recommendations_confirmed BOOLEAN DEFAULT false,

  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT patients_email_unique UNIQUE (email)
);

COMMENT ON TABLE patients IS
'End users (patients) who track their health data. Each patient is assigned to one clinician.';

CREATE INDEX idx_patients_practice ON patients(medical_practice_id);
CREATE INDEX idx_patients_clinician ON patients(assigned_clinician_id);
CREATE INDEX idx_patients_onboarding ON patients(onboarding_complete, recommendations_generated);

-- =====================================================
-- 4. Practice User Access (Admin/Nurse → Clinician)
-- =====================================================

CREATE TABLE IF NOT EXISTS practice_user_access (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES practice_users(user_id) ON DELETE CASCADE,
  clinician_id UUID REFERENCES practice_users(user_id) ON DELETE CASCADE,
  has_all_access BOOLEAN DEFAULT false,  -- Access to all clinicians in practice
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  -- Either has_all_access OR specific clinician_id (not both)
  CONSTRAINT valid_access_pattern CHECK (
    (has_all_access = true AND clinician_id IS NULL) OR
    (has_all_access = false AND clinician_id IS NOT NULL)
  ),

  -- Unique: one row per user-clinician pair
  CONSTRAINT practice_user_access_unique UNIQUE (user_id, clinician_id)
);

COMMENT ON TABLE practice_user_access IS
'Defines which clinicians an admin/nurse can access. NULL clinician_id + has_all_access=true means access to all clinicians in practice.';

CREATE INDEX idx_practice_user_access_user ON practice_user_access(user_id);
CREATE INDEX idx_practice_user_access_clinician ON practice_user_access(clinician_id);
CREATE INDEX idx_practice_user_access_all ON practice_user_access(user_id) WHERE has_all_access = true;

-- =====================================================
-- 5. Helper Functions
-- =====================================================

-- Function to get all patients accessible by a practice user
CREATE OR REPLACE FUNCTION get_accessible_patients(p_user_id UUID)
RETURNS TABLE(patient_id UUID)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_role TEXT;
  v_practice_id UUID;
BEGIN
  -- Get user's role and practice
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
      INNER JOIN practice_user_access pua ON (
        pua.user_id = p_user_id AND
        (pua.has_all_access = true OR pua.clinician_id = p.assigned_clinician_id)
      )
      WHERE p.medical_practice_id = v_practice_id;
  END IF;
END;
$$;

COMMENT ON FUNCTION get_accessible_patients(UUID) IS
'Returns all patient IDs that a given user (patient/clinician/admin/nurse) can access.';

-- =====================================================
-- 6. Update Triggers
-- =====================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_medical_practices_updated_at
  BEFORE UPDATE ON medical_practices
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_practice_users_updated_at
  BEFORE UPDATE ON practice_users
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_patients_updated_at
  BEFORE UPDATE ON patients
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- VERIFICATION
-- =====================================================

DO $$
BEGIN
  RAISE NOTICE '✅ Authentication Schema Created';
  RAISE NOTICE '';
  RAISE NOTICE 'Tables created:';
  RAISE NOTICE '  - medical_practices';
  RAISE NOTICE '  - practice_users (clinicians, admins, nurses)';
  RAISE NOTICE '  - patients';
  RAISE NOTICE '  - practice_user_access';
  RAISE NOTICE '';
  RAISE NOTICE 'Helper function: get_accessible_patients(user_id)';
  RAISE NOTICE '';
  RAISE NOTICE 'Next step: Run RLS policies migration';
END $$;

COMMIT;
