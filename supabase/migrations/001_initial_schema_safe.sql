-- WellPath Initial Schema Migration (SAFE - Only creates missing tables)
-- This creates only the tables that don't exist yet

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- PRACTICES TABLE (if not exists)
-- ============================================================================
CREATE TABLE IF NOT EXISTS practices (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  address TEXT,
  city TEXT,
  state TEXT,
  country TEXT,
  zip_code TEXT,
  time_zone TEXT DEFAULT 'America/New_York',
  primary_specialty TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================================
-- USERS TABLE (Extended profiles linked to Supabase Auth)
-- Note: id corresponds to auth.users.id but we can't create a formal FK
-- The relationship is enforced in application code and RLS policies
-- ============================================================================
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY,
  practice_id UUID REFERENCES practices(id) ON DELETE SET NULL,
  first_name TEXT,
  last_name TEXT,
  phone_number TEXT,
  role TEXT NOT NULL CHECK (role IN ('patient', 'clinician', 'admin')),
  speciality TEXT[], -- for clinicians
  is_owner BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,
  onboarding_step TEXT,
  patient_onboarding_step TEXT,
  dob DATE,
  gender TEXT,
  profile_image_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================================
-- PLANS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS plans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_id UUID REFERENCES users(id) ON DELETE CASCADE,
  clinician_id UUID REFERENCES users(id) ON DELETE SET NULL,
  name TEXT NOT NULL DEFAULT 'WellPath Plan',
  status INTEGER DEFAULT 0,
  general_info_status INTEGER DEFAULT 0,
  biomarkers_status INTEGER DEFAULT 0,
  biometrics_status INTEGER DEFAULT 0,
  questionnaire_status INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================================
-- PATIENT-CLINICIAN ASSIGNMENTS
-- ============================================================================
CREATE TABLE IF NOT EXISTS patient_clinician_assignments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_id UUID REFERENCES users(id) ON DELETE CASCADE,
  clinician_id UUID REFERENCES users(id) ON DELETE CASCADE,
  practice_id UUID REFERENCES practices(id) ON DELETE CASCADE,
  is_primary BOOLEAN DEFAULT FALSE,
  assigned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(patient_id, clinician_id)
);

-- ============================================================================
-- PILLARS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS pillars (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  short_name TEXT,
  description TEXT,
  color TEXT,
  icon_url TEXT,
  display_order INTEGER,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================================
-- PILLAR SCORES TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS pillar_scores (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_id UUID REFERENCES users(id) ON DELETE CASCADE,
  plan_id UUID REFERENCES plans(id) ON DELETE CASCADE,
  pillar_id UUID REFERENCES pillars(id) ON DELETE CASCADE,
  score NUMERIC(5,2) NOT NULL CHECK (score >= 0 AND score <= 100),
  recorded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================================
-- INDEXES (Create if not exists - PostgreSQL handles duplicates gracefully)
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_users_practice ON users(practice_id);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
CREATE INDEX IF NOT EXISTS idx_plans_patient ON plans(patient_id);
CREATE INDEX IF NOT EXISTS idx_plans_clinician ON plans(clinician_id);
CREATE INDEX IF NOT EXISTS idx_assignments_patient ON patient_clinician_assignments(patient_id);
CREATE INDEX IF NOT EXISTS idx_assignments_clinician ON patient_clinician_assignments(clinician_id);
CREATE INDEX IF NOT EXISTS idx_pillar_scores_patient_pillar ON pillar_scores(patient_id, pillar_id, recorded_at DESC);

-- ============================================================================
-- TRIGGERS FOR UPDATED_AT
-- ============================================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
   NEW.updated_at = NOW();
   RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_practices_updated_at ON practices;
CREATE TRIGGER update_practices_updated_at BEFORE UPDATE ON practices
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_users_updated_at ON users;
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_plans_updated_at ON plans;
CREATE TRIGGER update_plans_updated_at BEFORE UPDATE ON plans
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- INSERT DEFAULT PILLARS (Only if table is empty)
-- ============================================================================

INSERT INTO pillars (name, short_name, color, display_order)
SELECT * FROM (VALUES
  ('Healthful Nutrition', 'Nutrition', '#FF6B6B', 1),
  ('Movement & Exercise', 'Exercise', '#4ECDC4', 2),
  ('Restorative Sleep', 'Sleep', '#95E1D3', 3),
  ('Stress Management', 'Stress', '#F38181', 4),
  ('Connection & Purpose', 'Social', '#AA96DA', 5),
  ('Cognitive Health', 'Mental', '#FCBAD3', 6),
  ('Core Care', 'Preventive', '#FFFFD2', 7)
) AS v(name, short_name, color, display_order)
WHERE NOT EXISTS (SELECT 1 FROM pillars);
