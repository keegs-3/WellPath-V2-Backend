-- =====================================================
-- Patient Section Scores View
-- =====================================================
-- Aggregates scores by section type across all pillars:
-- - Biomarker Score
-- - Biometric Score
-- - Behavior Score (combines survey_question + survey_function)
-- - Education Score (placeholder, currently 0)
--
-- Created: 2025-10-17
-- =====================================================

BEGIN;

-- Drop view if exists
DROP VIEW IF EXISTS patient_section_scores CASCADE;

-- Create the section scores view
CREATE VIEW patient_section_scores AS
WITH section_aggregates AS (
  SELECT
    patient_id,
    CASE
      WHEN item_type = 'biomarker' THEN 'Biomarker'
      WHEN item_type = 'biometric' THEN 'Biometric'
      WHEN item_type IN ('survey_question', 'survey_function') THEN 'Behavior'
      WHEN item_type = 'education' THEN 'Education'
      ELSE 'Other'
    END as section,
    SUM(patient_score_pct) as section_score,
    SUM(max_score_pct) as section_max_score,
    CASE
      WHEN SUM(max_score_pct) > 0
      THEN (SUM(patient_score_pct) / SUM(max_score_pct)) * 100
      ELSE 0
    END as section_percentage,
    COUNT(*) as item_count
  FROM patient_score_items_clean
  GROUP BY patient_id, section
),
pivoted_sections AS (
  SELECT
    patient_id,

    -- Biomarker
    MAX(CASE WHEN section = 'Biomarker' THEN section_score ELSE 0 END) as biomarker_score,
    MAX(CASE WHEN section = 'Biomarker' THEN section_max_score ELSE 0 END) as biomarker_max_score,
    MAX(CASE WHEN section = 'Biomarker' THEN section_percentage ELSE 0 END) as biomarker_pct,
    MAX(CASE WHEN section = 'Biomarker' THEN item_count ELSE 0 END) as biomarker_count,

    -- Biometric
    MAX(CASE WHEN section = 'Biometric' THEN section_score ELSE 0 END) as biometric_score,
    MAX(CASE WHEN section = 'Biometric' THEN section_max_score ELSE 0 END) as biometric_max_score,
    MAX(CASE WHEN section = 'Biometric' THEN section_percentage ELSE 0 END) as biometric_pct,
    MAX(CASE WHEN section = 'Biometric' THEN item_count ELSE 0 END) as biometric_count,

    -- Behavior (survey_question + survey_function combined)
    MAX(CASE WHEN section = 'Behavior' THEN section_score ELSE 0 END) as behavior_score,
    MAX(CASE WHEN section = 'Behavior' THEN section_max_score ELSE 0 END) as behavior_max_score,
    MAX(CASE WHEN section = 'Behavior' THEN section_percentage ELSE 0 END) as behavior_pct,
    MAX(CASE WHEN section = 'Behavior' THEN item_count ELSE 0 END) as behavior_count,

    -- Education (placeholder - currently 0)
    MAX(CASE WHEN section = 'Education' THEN section_score ELSE 0 END) as education_score,
    MAX(CASE WHEN section = 'Education' THEN section_max_score ELSE 0 END) as education_max_score,
    MAX(CASE WHEN section = 'Education' THEN section_percentage ELSE 0 END) as education_pct,
    MAX(CASE WHEN section = 'Education' THEN item_count ELSE 0 END) as education_count

  FROM section_aggregates
  GROUP BY patient_id
)
SELECT
  patient_id,

  -- Biomarker Score
  ROUND(biomarker_score::numeric, 2) as biomarker_score,
  ROUND(biomarker_max_score::numeric, 2) as biomarker_max_score,
  ROUND(biomarker_pct::numeric, 2) as biomarker_pct,
  biomarker_count,

  -- Biometric Score
  ROUND(biometric_score::numeric, 2) as biometric_score,
  ROUND(biometric_max_score::numeric, 2) as biometric_max_score,
  ROUND(biometric_pct::numeric, 2) as biometric_pct,
  biometric_count,

  -- Behavior Score (questions + functions)
  ROUND(behavior_score::numeric, 2) as behavior_score,
  ROUND(behavior_max_score::numeric, 2) as behavior_max_score,
  ROUND(behavior_pct::numeric, 2) as behavior_pct,
  behavior_count,

  -- Education Score (placeholder)
  ROUND(education_score::numeric, 2) as education_score,
  ROUND(education_max_score::numeric, 2) as education_max_score,
  ROUND(education_pct::numeric, 2) as education_pct,
  education_count

FROM pivoted_sections;

-- Grant permissions
GRANT SELECT ON patient_section_scores TO service_role;
GRANT SELECT ON patient_section_scores TO authenticated;
GRANT SELECT ON patient_section_scores TO anon;

COMMIT;

-- =====================================================
-- Comments
-- =====================================================

COMMENT ON VIEW patient_section_scores IS
'Aggregates patient scores by section type (Biomarker, Biometric, Behavior, Education) across all pillars. Behavior combines survey questions and functions.';

COMMENT ON COLUMN patient_section_scores.biomarker_score IS
'Total patient score from all biomarkers across all pillars (0-100 scale)';

COMMENT ON COLUMN patient_section_scores.biomarker_pct IS
'Percentage of max biomarker score achieved: (biomarker_score / biomarker_max_score) * 100';

COMMENT ON COLUMN patient_section_scores.behavior_score IS
'Total patient score from survey questions and functions combined (0-100 scale)';

COMMENT ON COLUMN patient_section_scores.behavior_pct IS
'Percentage of max behavior score achieved: (behavior_score / behavior_max_score) * 100';

-- =====================================================
-- Verification
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE '✅ View patient_section_scores created successfully';
    RAISE NOTICE '';
    RAISE NOTICE 'Sections:';
    RAISE NOTICE '  - Biomarker: All biomarker items across all pillars';
    RAISE NOTICE '  - Biometric: All biometric items across all pillars';
    RAISE NOTICE '  - Behavior: Survey questions + functions combined';
    RAISE NOTICE '  - Education: Placeholder (currently 0)';
    RAISE NOTICE '';
    RAISE NOTICE 'Usage:';
    RAISE NOTICE '  SELECT * FROM patient_section_scores';
    RAISE NOTICE '  WHERE patient_id = ''1758fa60-a306-440e-8ae6-9e68fd502bc2'';';
END $$;
