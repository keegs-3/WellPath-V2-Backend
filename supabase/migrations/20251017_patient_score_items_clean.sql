-- =====================================================
-- Patient Score Items Clean View
-- =====================================================
-- Data cleaning view that simplifies patient_wellpath_score_items
-- by selecting only the gender-appropriate normalized scores
-- and converting to percentage scale (0-100)
--
-- Created: 2025-10-17
-- =====================================================

BEGIN;

-- Drop view if exists
DROP VIEW IF EXISTS patient_score_items_clean CASCADE;

-- Create the clean view
CREATE VIEW patient_score_items_clean AS
SELECT
    user_id AS patient_id,
    patient_gender,
    patient_age,
    item_type,

    -- Item identifiers (one will be non-null based on item_type)
    biomarker_name,
    biometric_name,
    question_number,
    function_name,
    education_module_id,
    behavior_metric_id,

    pillar_name,

    -- Patient's actual value/response
    patient_value,
    patient_value_numeric,

    -- Raw and normalized scores (0-1 scale)
    raw_score,
    normalized_score,

    -- Gender-appropriate patient score (converted to 0-100 scale)
    CASE
        WHEN patient_gender = 'male' THEN patient_normalized_score_male * 100
        WHEN patient_gender = 'female' THEN patient_normalized_score_female * 100
    END AS patient_score_pct,

    -- Gender-appropriate max score (converted to 0-100 scale)
    CASE
        WHEN patient_gender = 'male' THEN max_normalized_score_male * 100
        WHEN patient_gender = 'female' THEN max_normalized_score_female * 100
    END AS max_score_pct,

    -- Percentage: (patient_score / max_score) * 100
    CASE
        WHEN patient_gender = 'male' AND max_normalized_score_male > 0 THEN
            (patient_normalized_score_male / max_normalized_score_male) * 100
        WHEN patient_gender = 'female' AND max_normalized_score_female > 0 THEN
            (patient_normalized_score_female / max_normalized_score_female) * 100
        ELSE 0
    END AS score_percentage,

    -- Additional fields
    score_band,
    max_grouping,
    data_collected_at,
    scored_at,
    created_at,
    updated_at,

    -- Metadata
    calculation_version,
    function_question_responses

FROM patient_wellpath_score_items;

-- Grant permissions
GRANT SELECT ON patient_score_items_clean TO service_role;
GRANT SELECT ON patient_score_items_clean TO authenticated;
GRANT SELECT ON patient_score_items_clean TO anon;

COMMIT;

-- =====================================================
-- Comments
-- =====================================================

COMMENT ON VIEW patient_score_items_clean IS
'Cleaned view of patient_wellpath_score_items with gender-specific scores converted to 0-100 percentage scale. Simplifies queries by automatically selecting male vs female scores based on patient_gender.';

COMMENT ON COLUMN patient_score_items_clean.patient_score_pct IS
'Patient''s weighted score contribution to pillar (0-100 scale). Automatically uses male or female score based on patient_gender.';

COMMENT ON COLUMN patient_score_items_clean.max_score_pct IS
'Maximum possible score contribution for this item (0-100 scale). Automatically uses male or female max based on patient_gender.';

COMMENT ON COLUMN patient_score_items_clean.score_percentage IS
'Percentage of max score achieved: (patient_score / max_score) * 100. Shows how well patient performed on this individual item.';

-- =====================================================
-- Verification
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE '✅ View patient_score_items_clean created successfully';
    RAISE NOTICE '';
    RAISE NOTICE 'Usage examples:';
    RAISE NOTICE '  -- Get all items for a patient with percentages';
    RAISE NOTICE '  SELECT patient_id, item_type, biomarker_name, biometric_name, question_number,';
    RAISE NOTICE '         pillar_name, patient_score_pct, max_score_pct, score_percentage';
    RAISE NOTICE '  FROM patient_score_items_clean';
    RAISE NOTICE '  WHERE patient_id = ''1758fa60-a306-440e-8ae6-9e68fd502bc2''';
    RAISE NOTICE '  ORDER BY pillar_name, item_type;';
END $$;

-- =====================================================
-- Sample Usage (Commented Out)
-- =====================================================

-- Example 1: Get all biomarker scores for a patient
-- SELECT
--     biomarker_name,
--     patient_value_numeric,
--     score_band,
--     normalized_score,
--     patient_score_pct,
--     max_score_pct,
--     score_percentage,
--     pillar_name
-- FROM patient_score_items_clean
-- WHERE patient_id = '1758fa60-a306-440e-8ae6-9e68fd502bc2'
-- AND item_type = 'biomarker'
-- ORDER BY pillar_name, biomarker_name;

-- Example 2: Get average performance by pillar
-- SELECT
--     pillar_name,
--     COUNT(*) as item_count,
--     ROUND(AVG(score_percentage), 2) as avg_performance_pct,
--     ROUND(SUM(patient_score_pct), 2) as total_patient_score,
--     ROUND(SUM(max_score_pct), 2) as total_max_score
-- FROM patient_score_items_clean
-- WHERE patient_id = '1758fa60-a306-440e-8ae6-9e68fd502bc2'
-- GROUP BY pillar_name
-- ORDER BY pillar_name;

-- Example 3: Find items with low performance
-- SELECT
--     pillar_name,
--     item_type,
--     COALESCE(biomarker_name, biometric_name, question_number, function_name) as item_name,
--     patient_value,
--     score_percentage
-- FROM patient_score_items_clean
-- WHERE patient_id = '1758fa60-a306-440e-8ae6-9e68fd502bc2'
-- AND score_percentage < 70
-- ORDER BY score_percentage ASC;
