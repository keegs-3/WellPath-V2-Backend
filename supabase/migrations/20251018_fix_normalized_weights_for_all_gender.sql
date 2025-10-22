-- =====================================================
-- Fix Normalized Weight Views to Handle 'all' Gender
-- =====================================================
-- Updates the normalized weight views to use gender = 'all'
-- instead of gender IS NULL
--
-- Created: 2025-10-18
-- =====================================================

BEGIN;

-- Drop dependent views first
DROP VIEW IF EXISTS wellpath_scoring_marker_pillar_weights_normalized CASCADE;
DROP VIEW IF EXISTS wellpath_scoring_question_pillar_weights_normalized CASCADE;
DROP VIEW IF EXISTS wellpath_scoring_pillar_component_weights_with_sum CASCADE;

-- =====================================================
-- View 1: Pillar Component Weights with Sum Totals
-- =====================================================

CREATE VIEW wellpath_scoring_pillar_component_weights_with_sum AS
SELECT
    w1.*,

    -- ===== FEMALE TOTALS =====
    -- (where gender = 'female' OR gender = 'all')

    -- Biomarkers total for females
    COALESCE((
        SELECT SUM(max_weight)
        FROM (
            SELECT MAX(weight) as max_weight
            FROM wellpath_scoring_marker_pillar_weights
            WHERE pillar_name = w1.pillar_name
            AND biomarker_name IS NOT NULL
            AND (gender = 'female' OR gender = 'all')
            GROUP BY COALESCE(max_grouping, id::text)
        ) sub
    ), 0) as biomarkers_max_female,

    -- Biometrics total for females
    COALESCE((
        SELECT SUM(max_weight)
        FROM (
            SELECT MAX(weight) as max_weight
            FROM wellpath_scoring_marker_pillar_weights
            WHERE pillar_name = w1.pillar_name
            AND biometric_name IS NOT NULL
            AND (gender = 'female' OR gender = 'all')
            GROUP BY COALESCE(max_grouping, id::text)
        ) sub
    ), 0) as biometrics_max_female,

    -- Total markers (biomarkers + biometrics) for females
    COALESCE((
        SELECT SUM(max_weight)
        FROM (
            SELECT MAX(weight) as max_weight
            FROM wellpath_scoring_marker_pillar_weights
            WHERE pillar_name = w1.pillar_name
            AND (gender = 'female' OR gender = 'all')
            GROUP BY COALESCE(max_grouping, id::text)
        ) sub
    ), 0) as markers_total_female,

    -- Survey questions total for females
    COALESCE((
        SELECT SUM(max_weight)
        FROM (
            SELECT MAX(weight) as max_weight
            FROM wellpath_scoring_question_pillar_weights
            WHERE pillar_name = w1.pillar_name
            AND question_number IS NOT NULL
            AND (gender = 'female' OR gender = 'all')
            GROUP BY COALESCE(max_grouping, id::text)
        ) sub
    ), 0) as survey_questions_max_female,

    -- Survey functions total for females
    COALESCE((
        SELECT SUM(max_weight)
        FROM (
            SELECT MAX(weight) as max_weight
            FROM wellpath_scoring_question_pillar_weights
            WHERE pillar_name = w1.pillar_name
            AND function_name IS NOT NULL
            AND (gender = 'female' OR gender = 'all')
            GROUP BY COALESCE(max_grouping, id::text)
        ) sub
    ), 0) as survey_functions_max_female,

    -- Total survey (questions + functions) for females
    COALESCE((
        SELECT SUM(max_weight)
        FROM (
            SELECT MAX(weight) as max_weight
            FROM wellpath_scoring_question_pillar_weights
            WHERE pillar_name = w1.pillar_name
            AND (gender = 'female' OR gender = 'all')
            GROUP BY COALESCE(max_grouping, id::text)
        ) sub
    ), 0) as survey_total_female,

    -- ===== MALE TOTALS =====
    -- (where gender = 'male' OR gender = 'all')

    -- Biomarkers total for males
    COALESCE((
        SELECT SUM(max_weight)
        FROM (
            SELECT MAX(weight) as max_weight
            FROM wellpath_scoring_marker_pillar_weights
            WHERE pillar_name = w1.pillar_name
            AND biomarker_name IS NOT NULL
            AND (gender = 'male' OR gender = 'all')
            GROUP BY COALESCE(max_grouping, id::text)
        ) sub
    ), 0) as biomarkers_max_male,

    -- Biometrics total for males
    COALESCE((
        SELECT SUM(max_weight)
        FROM (
            SELECT MAX(weight) as max_weight
            FROM wellpath_scoring_marker_pillar_weights
            WHERE pillar_name = w1.pillar_name
            AND biometric_name IS NOT NULL
            AND (gender = 'male' OR gender = 'all')
            GROUP BY COALESCE(max_grouping, id::text)
        ) sub
    ), 0) as biometrics_max_male,

    -- Total markers (biomarkers + biometrics) for males
    COALESCE((
        SELECT SUM(max_weight)
        FROM (
            SELECT MAX(weight) as max_weight
            FROM wellpath_scoring_marker_pillar_weights
            WHERE pillar_name = w1.pillar_name
            AND (gender = 'male' OR gender = 'all')
            GROUP BY COALESCE(max_grouping, id::text)
        ) sub
    ), 0) as markers_total_male,

    -- Survey questions total for males
    COALESCE((
        SELECT SUM(max_weight)
        FROM (
            SELECT MAX(weight) as max_weight
            FROM wellpath_scoring_question_pillar_weights
            WHERE pillar_name = w1.pillar_name
            AND question_number IS NOT NULL
            AND (gender = 'male' OR gender = 'all')
            GROUP BY COALESCE(max_grouping, id::text)
        ) sub
    ), 0) as survey_questions_max_male,

    -- Survey functions total for males
    COALESCE((
        SELECT SUM(max_weight)
        FROM (
            SELECT MAX(weight) as max_weight
            FROM wellpath_scoring_question_pillar_weights
            WHERE pillar_name = w1.pillar_name
            AND function_name IS NOT NULL
            AND (gender = 'male' OR gender = 'all')
            GROUP BY COALESCE(max_grouping, id::text)
        ) sub
    ), 0) as survey_functions_max_male,

    -- Total survey (questions + functions) for males
    COALESCE((
        SELECT SUM(max_weight)
        FROM (
            SELECT MAX(weight) as max_weight
            FROM wellpath_scoring_question_pillar_weights
            WHERE pillar_name = w1.pillar_name
            AND (gender = 'male' OR gender = 'all')
            GROUP BY COALESCE(max_grouping, id::text)
        ) sub
    ), 0) as survey_total_male

FROM wellpath_scoring_pillar_component_weights w1;

COMMENT ON VIEW wellpath_scoring_pillar_component_weights_with_sum IS
'Calculates total raw weights per pillar per gender. Handles max_grouping where items in the same group contribute MAX(weight) instead of SUM(weights). Uses gender = ''all'' to indicate items that apply to both genders.';


-- =====================================================
-- View 2: Marker Pillar Weights Normalized
-- =====================================================

CREATE VIEW wellpath_scoring_marker_pillar_weights_normalized AS
SELECT
    m.*,

    -- Female normalized weight
    CASE
        WHEN m.biomarker_name IS NOT NULL THEN
            CASE WHEN v.markers_total_female > 0
                THEN (m.weight / v.markers_total_female) * v.marker_weight
                ELSE 0
            END
        WHEN m.biometric_name IS NOT NULL THEN
            CASE WHEN v.markers_total_female > 0
                THEN (m.weight / v.markers_total_female) * v.marker_weight
                ELSE 0
            END
        ELSE 0
    END as max_normalized_score_female,

    -- Male normalized weight
    CASE
        WHEN m.biomarker_name IS NOT NULL THEN
            CASE WHEN v.markers_total_male > 0
                THEN (m.weight / v.markers_total_male) * v.marker_weight
                ELSE 0
            END
        WHEN m.biometric_name IS NOT NULL THEN
            CASE WHEN v.markers_total_male > 0
                THEN (m.weight / v.markers_total_male) * v.marker_weight
                ELSE 0
            END
        ELSE 0
    END as max_normalized_score_male

FROM wellpath_scoring_marker_pillar_weights m
LEFT JOIN wellpath_scoring_pillar_component_weights_with_sum v
    ON m.pillar_name = v.pillar_name;

COMMENT ON VIEW wellpath_scoring_marker_pillar_weights_normalized IS
'Adds gender-specific normalized weight columns to marker weights. Formula: (raw_weight / total_markers) * marker_component_percentage.';


-- =====================================================
-- View 3: Question Pillar Weights Normalized
-- =====================================================

CREATE VIEW wellpath_scoring_question_pillar_weights_normalized AS
SELECT
    q.*,

    -- Female normalized weight
    CASE
        WHEN q.question_number IS NOT NULL THEN
            CASE WHEN v.survey_total_female > 0
                THEN (q.weight / v.survey_total_female) * v.survey_weight
                ELSE 0
            END
        WHEN q.function_name IS NOT NULL THEN
            CASE WHEN v.survey_total_female > 0
                THEN (q.weight / v.survey_total_female) * v.survey_weight
                ELSE 0
            END
        ELSE 0
    END as max_normalized_score_female,

    -- Male normalized weight
    CASE
        WHEN q.question_number IS NOT NULL THEN
            CASE WHEN v.survey_total_male > 0
                THEN (q.weight / v.survey_total_male) * v.survey_weight
                ELSE 0
            END
        WHEN q.function_name IS NOT NULL THEN
            CASE WHEN v.survey_total_male > 0
                THEN (q.weight / v.survey_total_male) * v.survey_weight
                ELSE 0
            END
        ELSE 0
    END as max_normalized_score_male

FROM wellpath_scoring_question_pillar_weights q
LEFT JOIN wellpath_scoring_pillar_component_weights_with_sum v
    ON q.pillar_name = v.pillar_name;

COMMENT ON VIEW wellpath_scoring_question_pillar_weights_normalized IS
'Adds gender-specific normalized weight columns to question/function weights. Formula: (raw_weight / total_survey) * survey_component_percentage.';

COMMIT;
