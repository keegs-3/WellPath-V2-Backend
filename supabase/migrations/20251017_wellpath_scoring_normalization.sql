-- =====================================================
-- WellPath Scoring Normalization Views
-- =====================================================
-- Creates views that calculate normalized weights for scoring items
-- with gender-specific calculations and max_grouping support
--
-- Key Features:
-- 1. Gender-specific normalization (male/female split)
-- 2. max_grouping logic (e.g., PAP/HPV take MAX not SUM)
-- 3. Normalized weights = (raw_weight / total_weight) * component_percentage
--
-- Created: 2025-10-17
-- =====================================================

BEGIN;

-- Drop dependent views first (cascade to ensure clean rebuild)
DROP VIEW IF EXISTS wellpath_scoring_marker_pillar_weights_normalized CASCADE;
DROP VIEW IF EXISTS wellpath_scoring_question_pillar_weights_normalized CASCADE;
DROP VIEW IF EXISTS wellpath_scoring_pillar_component_weights_with_sum CASCADE;

-- =====================================================
-- View 1: Pillar Component Weights with Sum Totals
-- =====================================================
-- Calculates total raw weights per pillar per gender
-- Handles max_grouping: items in same group use MAX(weight) not SUM
--
-- Example:
-- - screening_pap_score and screening_hpv_score both have weight=4
-- - They share max_grouping='cervical_cancer_screening'
-- - Total contribution = MAX(4, 4) = 4, not SUM(4+4) = 8
-- =====================================================

CREATE VIEW wellpath_scoring_pillar_component_weights_with_sum AS
SELECT
    w1.*,

    -- ===== FEMALE TOTALS =====
    -- (where gender = 'female' OR gender IS NULL)

    -- Biomarkers total for females
    COALESCE((
        SELECT SUM(max_weight)
        FROM (
            SELECT MAX(weight) as max_weight
            FROM wellpath_scoring_marker_pillar_weights
            WHERE pillar_name = w1.pillar_name
            AND biomarker_name IS NOT NULL
            AND (gender = 'female' OR gender IS NULL)
            GROUP BY COALESCE(max_grouping, id::text)  -- Group by max_grouping or unique id
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
            AND (gender = 'female' OR gender IS NULL)
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
            AND (gender = 'female' OR gender IS NULL)
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
            AND (gender = 'female' OR gender IS NULL)
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
            AND (gender = 'female' OR gender IS NULL)
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
            AND (gender = 'female' OR gender IS NULL)
            GROUP BY COALESCE(max_grouping, id::text)
        ) sub
    ), 0) as survey_total_female,

    -- ===== MALE TOTALS =====
    -- (where gender = 'male' OR gender IS NULL)

    -- Biomarkers total for males
    COALESCE((
        SELECT SUM(max_weight)
        FROM (
            SELECT MAX(weight) as max_weight
            FROM wellpath_scoring_marker_pillar_weights
            WHERE pillar_name = w1.pillar_name
            AND biomarker_name IS NOT NULL
            AND (gender = 'male' OR gender IS NULL)
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
            AND (gender = 'male' OR gender IS NULL)
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
            AND (gender = 'male' OR gender IS NULL)
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
            AND (gender = 'male' OR gender IS NULL)
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
            AND (gender = 'male' OR gender IS NULL)
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
            AND (gender = 'male' OR gender IS NULL)
            GROUP BY COALESCE(max_grouping, id::text)
        ) sub
    ), 0) as survey_total_male

FROM wellpath_scoring_pillar_component_weights w1;

COMMENT ON VIEW wellpath_scoring_pillar_component_weights_with_sum IS
'Calculates total raw weights per pillar per gender. Handles max_grouping where items in the same group contribute MAX(weight) instead of SUM(weights). Example: PAP and HPV screening both weight 4 but share max_grouping, so total = 4 not 8.';


-- =====================================================
-- View 2: Marker Pillar Weights Normalized
-- =====================================================
-- Adds normalized weight columns (male/female) to marker weights
-- Formula: (raw_weight / total_markers) * marker_component_percentage
--
-- Example for ALT (weight=3) in Nutrition pillar:
-- - Female: (3 / 260) * 0.72 = 0.0083 (0.83%)
-- - Male: (3 / 255) * 0.72 = 0.0085 (0.85%)
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
'Adds gender-specific normalized weight columns to marker weights. Formula: (raw_weight / total_markers) * marker_component_percentage. Edge Function multiplies marker score by the appropriate gender-specific normalized weight.';


-- =====================================================
-- View 3: Question Pillar Weights Normalized
-- =====================================================
-- Adds normalized weight columns (male/female) to question/function weights
-- Formula: (raw_weight / total_survey) * survey_component_percentage
--
-- Example for Question 2.01 (weight=5) in Nutrition pillar:
-- - Female: (5 / 120) * 0.18 = 0.0075 (0.75%)
-- - Male: (5 / 115) * 0.18 = 0.0078 (0.78%)
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
'Adds gender-specific normalized weight columns to question/function weights. Formula: (raw_weight / total_survey) * survey_component_percentage. Edge Function multiplies question/function score by the appropriate gender-specific normalized weight.';

COMMIT;

-- =====================================================
-- Verification Queries
-- =====================================================

DO $$
BEGIN
    -- Check if views were created
    IF EXISTS (
        SELECT 1 FROM pg_views
        WHERE viewname = 'wellpath_scoring_pillar_component_weights_with_sum'
    ) THEN
        RAISE NOTICE '✅ View wellpath_scoring_pillar_component_weights_with_sum created successfully';
    ELSE
        RAISE EXCEPTION '❌ View wellpath_scoring_pillar_component_weights_with_sum failed to create';
    END IF;

    IF EXISTS (
        SELECT 1 FROM pg_views
        WHERE viewname = 'wellpath_scoring_marker_pillar_weights_normalized'
    ) THEN
        RAISE NOTICE '✅ View wellpath_scoring_marker_pillar_weights_normalized created successfully';
    ELSE
        RAISE EXCEPTION '❌ View wellpath_scoring_marker_pillar_weights_normalized failed to create';
    END IF;

    IF EXISTS (
        SELECT 1 FROM pg_views
        WHERE viewname = 'wellpath_scoring_question_pillar_weights_normalized'
    ) THEN
        RAISE NOTICE '✅ View wellpath_scoring_question_pillar_weights_normalized created successfully';
    ELSE
        RAISE EXCEPTION '❌ View wellpath_scoring_question_pillar_weights_normalized failed to create';
    END IF;
END $$;

-- =====================================================
-- Sample Usage Examples (Commented Out)
-- =====================================================

-- Example 1: Get normalized weights for all markers in Nutrition pillar (females)
-- SELECT
--     biomarker_name,
--     biometric_name,
--     weight as raw_weight,
--     max_normalized_score_female,
--     ROUND((max_normalized_score_female * 100)::numeric, 2) as contribution_percent
-- FROM wellpath_scoring_marker_pillar_weights_normalized
-- WHERE pillar_name = 'Nutrition'
-- AND (gender = 'female' OR gender IS NULL)
-- ORDER BY max_normalized_score_female DESC;

-- Example 2: Get normalized weights for all survey items in Nutrition pillar (males)
-- SELECT
--     question_number,
--     function_name,
--     weight as raw_weight,
--     max_normalized_score_male,
--     ROUND((max_normalized_score_male * 100)::numeric, 2) as contribution_percent
-- FROM wellpath_scoring_question_pillar_weights_normalized
-- WHERE pillar_name = 'Nutrition'
-- AND (gender = 'male' OR gender IS NULL)
-- ORDER BY max_normalized_score_male DESC;

-- Example 3: Verify max_grouping logic for cervical cancer screening
-- SELECT
--     function_name,
--     weight,
--     max_grouping,
--     max_normalized_score_female
-- FROM wellpath_scoring_question_pillar_weights_normalized
-- WHERE max_grouping = 'cervical_cancer_screening';
-- Expected: Both PAP and HPV should have SAME normalized weight, not double

-- Example 4: Check totals per pillar per gender
-- SELECT
--     pillar_name,
--     markers_total_female,
--     markers_total_male,
--     survey_total_female,
--     survey_total_male,
--     marker_weight,
--     survey_weight
-- FROM wellpath_scoring_pillar_component_weights_with_sum
-- ORDER BY pillar_name;
