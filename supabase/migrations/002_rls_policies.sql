-- WellPath Row Level Security Policies
-- This sets up RLS to control data access based on user roles

-- ============================================================================
-- ENABLE RLS ON ALL TABLES
-- ============================================================================

ALTER TABLE practices ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE patient_clinician_assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE pillars ENABLE ROW LEVEL SECURITY;
ALTER TABLE pillar_scores ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- PRACTICES POLICIES
-- ============================================================================

-- Users can read their own practice
CREATE POLICY "Users can read own practice" ON practices
  FOR SELECT
  USING (
    id IN (SELECT practice_id FROM users WHERE id = auth.uid())
  );

-- Admins can manage their practice
CREATE POLICY "Admins can manage own practice" ON practices
  FOR ALL
  USING (
    id IN (
      SELECT practice_id FROM users
      WHERE id = auth.uid() AND (role = 'admin' OR is_owner = TRUE)
    )
  );

-- ============================================================================
-- USERS POLICIES
-- ============================================================================

-- Users can read their own profile
CREATE POLICY "Users can read own profile" ON users
  FOR SELECT
  USING (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY "Users can update own profile" ON users
  FOR UPDATE
  USING (auth.uid() = id);

-- Clinicians and admins can read users in their practice
CREATE POLICY "Staff can read practice users" ON users
  FOR SELECT
  USING (
    practice_id IN (
      SELECT practice_id FROM users
      WHERE id = auth.uid() AND role IN ('clinician', 'admin')
    )
  );

-- Admins can create users in their practice
CREATE POLICY "Admins can create practice users" ON users
  FOR INSERT
  WITH CHECK (
    practice_id IN (
      SELECT practice_id FROM users
      WHERE id = auth.uid() AND (role = 'admin' OR is_owner = TRUE)
    )
  );

-- ============================================================================
-- PLANS POLICIES
-- ============================================================================

-- Patients can read their own plans
CREATE POLICY "Patients can read own plans" ON plans
  FOR SELECT
  USING (patient_id = auth.uid());

-- Clinicians can read plans of their assigned patients
CREATE POLICY "Clinicians can read assigned patient plans" ON plans
  FOR SELECT
  USING (
    clinician_id = auth.uid() OR
    patient_id IN (
      SELECT patient_id FROM patient_clinician_assignments
      WHERE clinician_id = auth.uid()
    )
  );

-- Clinicians can create plans for their patients
CREATE POLICY "Clinicians can create patient plans" ON plans
  FOR INSERT
  WITH CHECK (
    clinician_id = auth.uid() OR
    patient_id IN (
      SELECT patient_id FROM patient_clinician_assignments
      WHERE clinician_id = auth.uid()
    )
  );

-- Clinicians can update plans for their patients
CREATE POLICY "Clinicians can update patient plans" ON plans
  FOR UPDATE
  USING (
    clinician_id = auth.uid() OR
    patient_id IN (
      SELECT patient_id FROM patient_clinician_assignments
      WHERE clinician_id = auth.uid()
    )
  );

-- ============================================================================
-- PATIENT-CLINICIAN ASSIGNMENTS POLICIES
-- ============================================================================

-- Patients can read their assignments
CREATE POLICY "Patients can read own assignments" ON patient_clinician_assignments
  FOR SELECT
  USING (patient_id = auth.uid());

-- Clinicians can read their assignments
CREATE POLICY "Clinicians can read own assignments" ON patient_clinician_assignments
  FOR SELECT
  USING (clinician_id = auth.uid());

-- Admins can manage assignments in their practice
CREATE POLICY "Admins can manage practice assignments" ON patient_clinician_assignments
  FOR ALL
  USING (
    practice_id IN (
      SELECT practice_id FROM users
      WHERE id = auth.uid() AND (role = 'admin' OR is_owner = TRUE)
    )
  );

-- ============================================================================
-- PILLARS POLICIES (Read-only for all authenticated users)
-- ============================================================================

CREATE POLICY "Authenticated users can read pillars" ON pillars
  FOR SELECT
  TO authenticated
  USING (TRUE);

-- ============================================================================
-- PILLAR SCORES POLICIES
-- ============================================================================

-- Patients can read their own scores
CREATE POLICY "Patients can read own scores" ON pillar_scores
  FOR SELECT
  USING (patient_id = auth.uid());

-- Clinicians can read their patients' scores
CREATE POLICY "Clinicians can read patient scores" ON pillar_scores
  FOR SELECT
  USING (
    patient_id IN (
      SELECT patient_id FROM patient_clinician_assignments
      WHERE clinician_id = auth.uid()
    )
  );

-- System can insert scores (for now, via service role)
-- Later we can add more specific policies for score creation

-- ============================================================================
-- HELPER FUNCTION TO GET USER ROLE
-- ============================================================================

CREATE OR REPLACE FUNCTION get_user_role()
RETURNS TEXT AS $$
  SELECT role FROM users WHERE id = auth.uid();
$$ LANGUAGE SQL SECURITY DEFINER;
