-- WellPath Database Functions
-- Helper functions for complex queries

-- ============================================================================
-- GET PATIENT PROFILE (Complete profile with practice and clinician)
-- ============================================================================

CREATE OR REPLACE FUNCTION get_patient_profile(patient_user_id UUID)
RETURNS JSON AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_build_object(
    'user', json_build_object(
      'details', (
        SELECT row_to_json(u.*)
        FROM users u
        WHERE u.id = patient_user_id
      ),
      'practice', (
        SELECT row_to_json(p.*)
        FROM practices p
        JOIN users u ON u.practice_id = p.id
        WHERE u.id = patient_user_id
      ),
      'assigned_clinician', (
        SELECT row_to_json(c.*)
        FROM users c
        JOIN patient_clinician_assignments pca ON pca.clinician_id = c.id
        WHERE pca.patient_id = patient_user_id AND pca.is_primary = TRUE
        LIMIT 1
      )
    )
  ) INTO result;

  RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- GET PATIENT PILLAR SCORES (Latest scores for all pillars)
-- ============================================================================

CREATE OR REPLACE FUNCTION get_patient_pillar_scores(patient_user_id UUID, plan_uuid UUID DEFAULT NULL)
RETURNS TABLE (
  id UUID,
  pillar_id UUID,
  pillar_name TEXT,
  pillar_short_name TEXT,
  latest_wellpath_score NUMERIC,
  score NUMERIC,
  color TEXT,
  icon_url TEXT,
  display_order INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    gen_random_uuid() as id,
    p.id as pillar_id,
    p.name as pillar_name,
    p.short_name as pillar_short_name,
    ps.score as latest_wellpath_score,
    COALESCE(ps.score, 0::NUMERIC) as score,
    p.color,
    p.icon_url,
    p.display_order
  FROM pillars p
  LEFT JOIN LATERAL (
    SELECT score
    FROM pillar_scores
    WHERE pillar_id = p.id
      AND patient_id = patient_user_id
      AND (plan_uuid IS NULL OR plan_id = plan_uuid)
    ORDER BY recorded_at DESC
    LIMIT 1
  ) ps ON TRUE
  ORDER BY p.display_order;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- CREATE OR UPDATE PILLAR SCORE
-- ============================================================================

CREATE OR REPLACE FUNCTION upsert_pillar_score(
  p_patient_id UUID,
  p_plan_id UUID,
  p_pillar_id UUID,
  p_score NUMERIC
)
RETURNS UUID AS $$
DECLARE
  score_id UUID;
BEGIN
  INSERT INTO pillar_scores (patient_id, plan_id, pillar_id, score, recorded_at)
  VALUES (p_patient_id, p_plan_id, p_pillar_id, p_score, NOW())
  RETURNING id INTO score_id;

  RETURN score_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- GET OR CREATE PATIENT PLAN
-- ============================================================================

CREATE OR REPLACE FUNCTION get_or_create_patient_plan(
  p_patient_id UUID,
  p_clinician_id UUID DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
  plan_uuid UUID;
BEGIN
  -- Try to get existing active plan
  SELECT id INTO plan_uuid
  FROM plans
  WHERE patient_id = p_patient_id
    AND status = 1  -- Active
  ORDER BY created_at DESC
  LIMIT 1;

  -- If no plan exists, create one
  IF plan_uuid IS NULL THEN
    INSERT INTO plans (patient_id, clinician_id, name, status)
    VALUES (p_patient_id, p_clinician_id, 'WellPath Plan', 1)
    RETURNING id INTO plan_uuid;
  END IF;

  RETURN plan_uuid;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- CREATE PATIENT WITH PRACTICE
-- ============================================================================

CREATE OR REPLACE FUNCTION create_patient_with_practice(
  p_auth_user_id UUID,
  p_practice_name TEXT DEFAULT 'Default Practice',
  p_first_name TEXT DEFAULT NULL,
  p_last_name TEXT DEFAULT NULL,
  p_phone_number TEXT DEFAULT NULL
)
RETURNS JSON AS $$
DECLARE
  practice_uuid UUID;
  result JSON;
BEGIN
  -- Create practice
  INSERT INTO practices (name)
  VALUES (p_practice_name)
  RETURNING id INTO practice_uuid;

  -- Create user profile
  INSERT INTO users (
    id,
    practice_id,
    first_name,
    last_name,
    phone_number,
    role,
    is_active,
    onboarding_step,
    patient_onboarding_step
  )
  VALUES (
    p_auth_user_id,
    practice_uuid,
    p_first_name,
    p_last_name,
    p_phone_number,
    'patient',
    TRUE,
    'completed',
    'completed'
  );

  -- Create initial plan
  PERFORM get_or_create_patient_plan(p_auth_user_id, NULL);

  -- Return the created profile
  SELECT json_build_object(
    'user_id', p_auth_user_id,
    'practice_id', practice_uuid,
    'success', TRUE
  ) INTO result;

  RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- GET PATIENT CARE TEAM
-- ============================================================================

CREATE OR REPLACE FUNCTION get_patient_care_team(patient_user_id UUID)
RETURNS JSON AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_agg(
    json_build_object(
      'id', c.id,
      'first_name', c.first_name,
      'last_name', c.last_name,
      'email', (SELECT email FROM auth.users WHERE id = c.id),
      'phone_number', c.phone_number,
      'role', c.role,
      'speciality', c.speciality,
      'is_primary', pca.is_primary,
      'assigned_at', pca.assigned_at
    )
  ) INTO result
  FROM users c
  JOIN patient_clinician_assignments pca ON pca.clinician_id = c.id
  WHERE pca.patient_id = patient_user_id;

  RETURN COALESCE(result, '[]'::JSON);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- CALCULATE OVERALL WELLPATH SCORE
-- ============================================================================

CREATE OR REPLACE FUNCTION get_overall_wellpath_score(patient_user_id UUID, plan_uuid UUID DEFAULT NULL)
RETURNS NUMERIC AS $$
DECLARE
  avg_score NUMERIC;
BEGIN
  SELECT AVG(latest_score) INTO avg_score
  FROM (
    SELECT DISTINCT ON (ps.pillar_id) ps.score as latest_score
    FROM pillar_scores ps
    WHERE ps.patient_id = patient_user_id
      AND (plan_uuid IS NULL OR ps.plan_id = plan_uuid)
    ORDER BY ps.pillar_id, ps.recorded_at DESC
  ) latest_scores;

  RETURN COALESCE(ROUND(avg_score, 2), 0);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
