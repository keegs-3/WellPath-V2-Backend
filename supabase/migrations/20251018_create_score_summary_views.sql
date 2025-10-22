-- =====================================================
-- WellPath Score Summary Views
-- =====================================================
-- Creates views for different levels of score aggregation:
-- 1. Overall WellPath Score
-- 2. Section Scores (across all pillars)
-- 3. Pillar Scores (overall per pillar)
-- 4. Pillar Section Scores (sections within each pillar)
-- 5. Pillar Detail (individual item scores)
--
-- Created: 2025-10-18
-- =====================================================

BEGIN;

-- Drop existing views first
DROP VIEW IF EXISTS patient_wellpath_score_detail CASCADE;
DROP VIEW IF EXISTS patient_wellpath_score_by_pillar_section CASCADE;
DROP VIEW IF EXISTS patient_wellpath_score_by_pillar CASCADE;
DROP VIEW IF EXISTS patient_wellpath_score_by_section CASCADE;
DROP VIEW IF EXISTS patient_wellpath_score_overall CASCADE;

-- =====================================================
-- View 1: Overall WellPath Score
-- =====================================================
-- Single overall WellPath score calculated by summing pillar scores
-- weighted by their wellpath_allocation

CREATE VIEW patient_wellpath_score_overall AS
WITH pillar_scores AS (
    -- Calculate score for each pillar
    SELECT
        user_id,
        patient_gender,
        patient_age,
        pillar_name,
        SUM(CASE WHEN patient_gender = 'male'
            THEN patient_normalized_score_male
            ELSE patient_normalized_score_female
        END) as pillar_patient_score,
        SUM(CASE WHEN patient_gender = 'male'
            THEN max_normalized_score_male
            ELSE max_normalized_score_female
        END) as pillar_max_score
    FROM patient_wellpath_score_items
    GROUP BY user_id, patient_gender, patient_age, pillar_name
),
weighted_pillars AS (
    -- Apply wellpath_allocation to each pillar
    SELECT
        ps.user_id,
        ps.patient_gender,
        ps.patient_age,
        ps.pillar_patient_score * pcw.wellpath_allocation as weighted_patient_score,
        ps.pillar_max_score * pcw.wellpath_allocation as weighted_max_score
    FROM pillar_scores ps
    JOIN wellpath_scoring_pillar_component_weights pcw
        ON ps.pillar_name = pcw.pillar_name
)
SELECT
    user_id,
    patient_gender,
    patient_age,

    -- Overall WellPath Score (sum of weighted pillar scores)
    SUM(weighted_patient_score) as wellpath_score_overall

FROM weighted_pillars
GROUP BY user_id, patient_gender, patient_age;

COMMENT ON VIEW patient_wellpath_score_overall IS
'Overall WellPath Score per patient. Calculated by summing each pillar score weighted by wellpath_allocation from wellpath_scoring_pillar_component_weights.';


-- =====================================================
-- View 2: Section Scores (Across All Pillars)
-- =====================================================
-- 4 rows per patient: Biomarkers, Biometrics, Behaviors, Education
-- Each section shows patient_score / max_score across all pillars

CREATE VIEW patient_wellpath_score_by_section AS
SELECT
    user_id,
    patient_gender,
    patient_age,

    -- Section categorization
    CASE
        WHEN item_type = 'biomarker' THEN 'Biomarkers'
        WHEN item_type = 'biometric' THEN 'Biometrics'
        WHEN item_type IN ('survey_question', 'survey_function') THEN 'Behaviors'
        WHEN item_type = 'education' THEN 'Education'
        ELSE 'Other'
    END as section_name,

    -- Patient's actual score for this section (sum across all pillars)
    SUM(CASE WHEN patient_gender = 'male'
        THEN patient_normalized_score_male
        ELSE patient_normalized_score_female
    END) as patient_score,

    -- Max possible score for this section (sum across all pillars)
    SUM(CASE WHEN patient_gender = 'male'
        THEN max_normalized_score_male
        ELSE max_normalized_score_female
    END) as max_score,

    -- Percentage: patient_score / max_score
    CASE
        WHEN SUM(CASE WHEN patient_gender = 'male'
            THEN max_normalized_score_male
            ELSE max_normalized_score_female
        END) > 0
        THEN (SUM(CASE WHEN patient_gender = 'male'
                THEN patient_normalized_score_male
                ELSE patient_normalized_score_female
            END) /
            SUM(CASE WHEN patient_gender = 'male'
                THEN max_normalized_score_male
                ELSE max_normalized_score_female
            END)) * 100
        ELSE 0
    END as score_percentage,

    COUNT(*) as item_count

FROM patient_wellpath_score_items
GROUP BY user_id, patient_gender, patient_age, section_name;

COMMENT ON VIEW patient_wellpath_score_by_section IS
'Section scores (Biomarkers, Biometrics, Behaviors, Education) aggregated across all pillars. Shows 4 rows per patient with patient_score, max_score, and percentage for each section.';


-- =====================================================
-- View 3: Pillar Scores
-- =====================================================
-- Overall score per pillar

CREATE OR REPLACE VIEW patient_wellpath_score_by_pillar AS
SELECT
    user_id,
    patient_gender,
    patient_age,
    pillar_name,

    -- Scores
    SUM(CASE WHEN patient_gender = 'male'
        THEN patient_normalized_score_male
        ELSE patient_normalized_score_female
    END) as patient_score,

    SUM(CASE WHEN patient_gender = 'male'
        THEN max_normalized_score_male
        ELSE max_normalized_score_female
    END) as max_score,

    CASE
        WHEN SUM(CASE WHEN patient_gender = 'male'
            THEN max_normalized_score_male
            ELSE max_normalized_score_female
        END) > 0
        THEN (SUM(CASE WHEN patient_gender = 'male'
                THEN patient_normalized_score_male
                ELSE patient_normalized_score_female
            END) /
            SUM(CASE WHEN patient_gender = 'male'
                THEN max_normalized_score_male
                ELSE max_normalized_score_female
            END)) * 100
        ELSE 0
    END as score_percentage,

    COUNT(*) as item_count,
    MAX(updated_at) as last_updated

FROM patient_wellpath_score_items
GROUP BY user_id, patient_gender, patient_age, pillar_name;

COMMENT ON VIEW patient_wellpath_score_by_pillar IS
'Overall score per pillar. This is the 7 pillar scores shown in the main dashboard.';


-- =====================================================
-- View 4: Pillar Section Scores
-- =====================================================
-- Section scores within each pillar
-- (e.g., Biomarkers within Healthful Nutrition, Behaviors within Core Care)

CREATE OR REPLACE VIEW patient_wellpath_score_by_pillar_section AS
SELECT
    user_id,
    patient_gender,
    patient_age,
    pillar_name,

    -- Section categorization
    CASE
        WHEN item_type = 'biomarker' THEN 'Biomarkers'
        WHEN item_type = 'biometric' THEN 'Biometrics'
        WHEN item_type IN ('survey_question', 'survey_function') THEN 'Behaviors'
        WHEN item_type = 'education' THEN 'Education'
        ELSE 'Other'
    END as section_name,

    -- Scores
    SUM(CASE WHEN patient_gender = 'male'
        THEN patient_normalized_score_male
        ELSE patient_normalized_score_female
    END) as patient_score,

    SUM(CASE WHEN patient_gender = 'male'
        THEN max_normalized_score_male
        ELSE max_normalized_score_female
    END) as max_score,

    CASE
        WHEN SUM(CASE WHEN patient_gender = 'male'
            THEN max_normalized_score_male
            ELSE max_normalized_score_female
        END) > 0
        THEN (SUM(CASE WHEN patient_gender = 'male'
                THEN patient_normalized_score_male
                ELSE patient_normalized_score_female
            END) /
            SUM(CASE WHEN patient_gender = 'male'
                THEN max_normalized_score_male
                ELSE max_normalized_score_female
            END)) * 100
        ELSE 0
    END as score_percentage,

    COUNT(*) as item_count,
    MAX(updated_at) as last_updated

FROM patient_wellpath_score_items
GROUP BY user_id, patient_gender, patient_age, pillar_name, section_name;

COMMENT ON VIEW patient_wellpath_score_by_pillar_section IS
'Section scores within each pillar. Shows Biomarkers, Biometrics, Behaviors, and Education breakdown for each of the 7 pillars.';


-- =====================================================
-- View 5: Pillar Detail (Individual Item Scores)
-- =====================================================
-- Individual item scores with all details
-- This is the most granular view showing every scored item

CREATE OR REPLACE VIEW patient_wellpath_score_detail AS
SELECT
    user_id,
    patient_gender,
    patient_age,
    pillar_name,

    -- Section categorization
    CASE
        WHEN item_type = 'biomarker' THEN 'Biomarkers'
        WHEN item_type = 'biometric' THEN 'Biometrics'
        WHEN item_type IN ('survey_question', 'survey_function') THEN 'Behaviors'
        WHEN item_type = 'education' THEN 'Education'
        ELSE 'Other'
    END as section_name,

    item_type,

    -- Item identifier (what was scored)
    COALESCE(
        biomarker_name,
        biometric_name,
        question_number::text,
        function_name
    ) as item_name,

    -- Patient's value/response
    patient_value,
    patient_value_numeric,

    -- Scoring details
    score_band,
    raw_score,
    normalized_score,
    raw_weight,

    -- Gender-specific scores
    patient_normalized_score_male as patient_score_male,
    patient_normalized_score_female as patient_score_female,
    max_normalized_score_male as max_score_male,
    max_normalized_score_female as max_score_female,

    -- Calculated percentage for this item
    CASE WHEN patient_gender = 'male'
        THEN CASE
            WHEN max_normalized_score_male > 0
            THEN (patient_normalized_score_male / max_normalized_score_male) * 100
            ELSE 0
        END
        ELSE CASE
            WHEN max_normalized_score_female > 0
            THEN (patient_normalized_score_female / max_normalized_score_female) * 100
            ELSE 0
        END
    END as item_score_percentage,

    max_grouping,
    data_collected_at,
    created_at,
    updated_at

FROM patient_wellpath_score_items
ORDER BY user_id, pillar_name, item_type, item_name;

COMMENT ON VIEW patient_wellpath_score_detail IS
'Detailed individual item scores. Shows every biomarker, biometric, question, and function score with full details. Use this for drill-down views and detailed analysis.';

COMMIT;
