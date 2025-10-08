-- WellPath Initial Schema Migration
-- This creates all base tables for the WellPath application

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- PRACTICES TABLE
-- ============================================================================
CREATE TABLE practices (
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
-- ============================================================================
CREATE TABLE users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
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
CREATE TABLE plans (
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
CREATE TABLE patient_clinician_assignments (
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
CREATE TABLE pillars (
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
CREATE TABLE pillar_scores (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_id UUID REFERENCES users(id) ON DELETE CASCADE,
  plan_id UUID REFERENCES plans(id) ON DELETE CASCADE,
  pillar_id UUID REFERENCES pillars(id) ON DELETE CASCADE,
  score NUMERIC(5,2) NOT NULL CHECK (score >= 0 AND score <= 100),
  recorded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================================
-- INDEXES
-- ============================================================================

-- User indexes
CREATE INDEX idx_users_practice ON users(practice_id);
CREATE INDEX idx_users_role ON users(role);

-- Plan indexes
CREATE INDEX idx_plans_patient ON plans(patient_id);
CREATE INDEX idx_plans_clinician ON plans(clinician_id);

-- Assignment indexes
CREATE INDEX idx_assignments_patient ON patient_clinician_assignments(patient_id);
CREATE INDEX idx_assignments_clinician ON patient_clinician_assignments(clinician_id);

-- Pillar score indexes
CREATE INDEX idx_pillar_scores_patient_pillar ON pillar_scores(patient_id, pillar_id, recorded_at DESC);

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

CREATE TRIGGER update_practices_updated_at BEFORE UPDATE ON practices
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_plans_updated_at BEFORE UPDATE ON plans
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- INSERT DEFAULT PILLARS
-- ============================================================================

INSERT INTO pillars (name, short_name, color, display_order) VALUES
  ('Nutrition', 'Nutrition', '#FF6B6B', 1),
  ('Exercise', 'Exercise', '#4ECDC4', 2),
  ('Sleep', 'Sleep', '#95E1D3', 3),
  ('Stress Management', 'Stress', '#F38181', 4),
  ('Social Connection', 'Social', '#AA96DA', 5),
  ('Mental Health', 'Mental', '#FCBAD3', 6),
  ('Preventive Care', 'Preventive', '#FFFFD2', 7);
