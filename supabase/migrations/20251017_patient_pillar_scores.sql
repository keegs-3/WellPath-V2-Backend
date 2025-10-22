-- =====================================================
-- Patient Pillar Scores View
-- =====================================================
-- Aggregates patient_score_items_clean to show total WellPath score
-- and individual pillar scores for each patient
--
-- Created: 2025-10-17
-- =====================================================

BEGIN;

-- Drop view if exists
DROP VIEW IF EXISTS patient_pillar_scores CASCADE;

-- Create the pillar scores view
CREATE VIEW patient_pillar_scores AS
WITH pillar_aggregates AS (
  SELECT
    patient_id,
    pillar_name,
    SUM(patient_score_pct) as pillar_score,
    SUM(max_score_pct) as pillar_max_score,
    CASE
      WHEN SUM(max_score_pct) > 0
      THEN (SUM(patient_score_pct) / SUM(max_score_pct)) * 100
      ELSE 0
    END as pillar_percentage,
    COUNT(*) as item_count
  FROM patient_score_items_clean
  GROUP BY patient_id, pillar_name
),
pivoted_pillars AS (
  SELECT
    patient_id,
    MAX(CASE WHEN pillar_name = 'Healthful Nutrition' THEN pillar_score END) as healthful_nutrition_score,
    MAX(CASE WHEN pillar_name = 'Healthful Nutrition' THEN pillar_max_score END) as healthful_nutrition_max,
    MAX(CASE WHEN pillar_name = 'Healthful Nutrition' THEN pillar_percentage END) as healthful_nutrition_pct,

    MAX(CASE WHEN pillar_name = 'Movement + Exercise' THEN pillar_score END) as movement_exercise_score,
    MAX(CASE WHEN pillar_name = 'Movement + Exercise' THEN pillar_max_score END) as movement_exercise_max,
    MAX(CASE WHEN pillar_name = 'Movement + Exercise' THEN pillar_percentage END) as movement_exercise_pct,

    MAX(CASE WHEN pillar_name = 'Restorative Sleep' THEN pillar_score END) as restorative_sleep_score,
    MAX(CASE WHEN pillar_name = 'Restorative Sleep' THEN pillar_max_score END) as restorative_sleep_max,
    MAX(CASE WHEN pillar_name = 'Restorative Sleep' THEN pillar_percentage END) as restorative_sleep_pct,

    MAX(CASE WHEN pillar_name = 'Stress Management' THEN pillar_score END) as stress_management_score,
    MAX(CASE WHEN pillar_name = 'Stress Management' THEN pillar_max_score END) as stress_management_max,
    MAX(CASE WHEN pillar_name = 'Stress Management' THEN pillar_percentage END) as stress_management_pct,

    MAX(CASE WHEN pillar_name = 'Cognitive Health' THEN pillar_score END) as cognitive_health_score,
    MAX(CASE WHEN pillar_name = 'Cognitive Health' THEN pillar_max_score END) as cognitive_health_max,
    MAX(CASE WHEN pillar_name = 'Cognitive Health' THEN pillar_percentage END) as cognitive_health_pct,

    MAX(CASE WHEN pillar_name = 'Connection + Purpose' THEN pillar_score END) as connection_purpose_score,
    MAX(CASE WHEN pillar_name = 'Connection + Purpose' THEN pillar_max_score END) as connection_purpose_max,
    MAX(CASE WHEN pillar_name = 'Connection + Purpose' THEN pillar_percentage END) as connection_purpose_pct,

    MAX(CASE WHEN pillar_name = 'Core Care' THEN pillar_score END) as core_care_score,
    MAX(CASE WHEN pillar_name = 'Core Care' THEN pillar_max_score END) as core_care_max,
    MAX(CASE WHEN pillar_name = 'Core Care' THEN pillar_percentage END) as core_care_pct
  FROM pillar_aggregates
  GROUP BY patient_id
),
pillar_scores AS (
  SELECT
    patient_id,
    pillar_name,
    SUM(patient_score_pct) as pillar_patient_score,
    SUM(max_score_pct) as pillar_max_score
  FROM patient_score_items_clean
  GROUP BY patient_id, pillar_name
),
total_score AS (
  SELECT
    patient_id,
    -- WellPath Score = Average of all 7 pillar scores
    -- Each pillar is already normalized to max 100
    AVG(
      CASE
        WHEN pillar_max_score > 0
        THEN (pillar_patient_score / pillar_max_score) * 100
        ELSE 0
      END
    ) as wellpath_score,
    SUM(pillar_patient_score) as total_score,
    SUM(pillar_max_score) as total_max_score
  FROM pillar_scores
  GROUP BY patient_id
)
SELECT
  t.patient_id,

  -- Total WellPath Score
  ROUND(t.wellpath_score::numeric, 2) as wellpath_score,
  ROUND(t.total_score::numeric, 2) as total_score,
  ROUND(t.total_max_score::numeric, 2) as total_max_score,

  -- Healthful Nutrition
  ROUND(COALESCE(p.healthful_nutrition_score, 0)::numeric, 2) as healthful_nutrition_score,
  ROUND(COALESCE(p.healthful_nutrition_max, 0)::numeric, 2) as healthful_nutrition_max,
  ROUND(COALESCE(p.healthful_nutrition_pct, 0)::numeric, 2) as healthful_nutrition_pct,

  -- Movement + Exercise
  ROUND(COALESCE(p.movement_exercise_score, 0)::numeric, 2) as movement_exercise_score,
  ROUND(COALESCE(p.movement_exercise_max, 0)::numeric, 2) as movement_exercise_max,
  ROUND(COALESCE(p.movement_exercise_pct, 0)::numeric, 2) as movement_exercise_pct,

  -- Restorative Sleep
  ROUND(COALESCE(p.restorative_sleep_score, 0)::numeric, 2) as restorative_sleep_score,
  ROUND(COALESCE(p.restorative_sleep_max, 0)::numeric, 2) as restorative_sleep_max,
  ROUND(COALESCE(p.restorative_sleep_pct, 0)::numeric, 2) as restorative_sleep_pct,

  -- Stress Management
  ROUND(COALESCE(p.stress_management_score, 0)::numeric, 2) as stress_management_score,
  ROUND(COALESCE(p.stress_management_max, 0)::numeric, 2) as stress_management_max,
  ROUND(COALESCE(p.stress_management_pct, 0)::numeric, 2) as stress_management_pct,

  -- Cognitive Health
  ROUND(COALESCE(p.cognitive_health_score, 0)::numeric, 2) as cognitive_health_score,
  ROUND(COALESCE(p.cognitive_health_max, 0)::numeric, 2) as cognitive_health_max,
  ROUND(COALESCE(p.cognitive_health_pct, 0)::numeric, 2) as cognitive_health_pct,

  -- Connection + Purpose
  ROUND(COALESCE(p.connection_purpose_score, 0)::numeric, 2) as connection_purpose_score,
  ROUND(COALESCE(p.connection_purpose_max, 0)::numeric, 2) as connection_purpose_max,
  ROUND(COALESCE(p.connection_purpose_pct, 0)::numeric, 2) as connection_purpose_pct,

  -- Core Care
  ROUND(COALESCE(p.core_care_score, 0)::numeric, 2) as core_care_score,
  ROUND(COALESCE(p.core_care_max, 0)::numeric, 2) as core_care_max,
  ROUND(COALESCE(p.core_care_pct, 0)::numeric, 2) as core_care_pct

FROM total_score t
LEFT JOIN pivoted_pillars p ON t.patient_id = p.patient_id;

-- Grant permissions
GRANT SELECT ON patient_pillar_scores TO service_role;
GRANT SELECT ON patient_pillar_scores TO authenticated;
GRANT SELECT ON patient_pillar_scores TO anon;

COMMIT;

-- =====================================================
-- Comments
-- =====================================================

COMMENT ON VIEW patient_pillar_scores IS
'Aggregated view showing total WellPath score and individual pillar scores for each patient. All scores are on 0-100 scale.';

COMMENT ON COLUMN patient_pillar_scores.wellpath_score IS
'Overall WellPath score (0-100). Calculated as (total_score / total_max_score) * 100.';

COMMENT ON COLUMN patient_pillar_scores.healthful_nutrition_pct IS
'Percentage score for Healthful Nutrition pillar (0-100)';

COMMENT ON COLUMN patient_pillar_scores.movement_exercise_pct IS
'Percentage score for Movement + Exercise pillar (0-100)';

COMMENT ON COLUMN patient_pillar_scores.restorative_sleep_pct IS
'Percentage score for Restorative Sleep pillar (0-100)';

COMMENT ON COLUMN patient_pillar_scores.stress_management_pct IS
'Percentage score for Stress Management pillar (0-100)';

COMMENT ON COLUMN patient_pillar_scores.cognitive_health_pct IS
'Percentage score for Cognitive Health pillar (0-100)';

COMMENT ON COLUMN patient_pillar_scores.connection_purpose_pct IS
'Percentage score for Connection + Purpose pillar (0-100)';

COMMENT ON COLUMN patient_pillar_scores.core_care_pct IS
'Percentage score for Core Care pillar (0-100)';

-- =====================================================
-- Verification
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE '✅ View patient_pillar_scores created successfully';
    RAISE NOTICE '';
    RAISE NOTICE 'Columns:';
    RAISE NOTICE '  - wellpath_score (total score 0-100)';
    RAISE NOTICE '  - total_score, total_max_score (raw sums)';
    RAISE NOTICE '  - {pillar}_score, {pillar}_max, {pillar}_pct for each pillar';
    RAISE NOTICE '';
    RAISE NOTICE 'Usage:';
    RAISE NOTICE '  SELECT * FROM patient_pillar_scores';
    RAISE NOTICE '  WHERE patient_id = ''1758fa60-a306-440e-8ae6-9e68fd502bc2'';';
END $$;
