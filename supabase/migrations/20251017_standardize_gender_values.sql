-- =====================================================
-- Standardize Gender Values Across All Tables
-- =====================================================
-- Converts all gender values to lowercase 'male' and 'female'
-- Ensures consistency across all tables for filtering
--
-- Created: 2025-10-17
-- =====================================================

BEGIN;

-- =====================================================
-- 1. Patient Details - biological_sex column
-- =====================================================
-- Currently stores 'M' and 'F', update to 'male' and 'female'

UPDATE patient_details
SET biological_sex = CASE
    WHEN biological_sex IN ('M', 'Male', 'male', 'MALE') THEN 'male'
    WHEN biological_sex IN ('F', 'Female', 'female', 'FEMALE') THEN 'female'
    ELSE biological_sex
END
WHERE biological_sex IN ('M', 'F', 'Male', 'Female', 'MALE', 'FEMALE');

-- =====================================================
-- 2. Biomarkers Detail - gender column
-- =====================================================
-- Currently stores 'Male', 'Female', 'All'

UPDATE biomarkers_detail
SET gender = CASE
    WHEN gender IN ('M', 'Male', 'MALE') THEN 'male'
    WHEN gender IN ('F', 'Female', 'FEMALE') THEN 'female'
    WHEN gender IN ('All', 'ALL', 'all') THEN 'all'
    ELSE gender
END
WHERE gender IS NOT NULL;

-- =====================================================
-- 3. Biometrics Detail - gender column
-- =====================================================

UPDATE biometrics_detail
SET gender = CASE
    WHEN gender IN ('M', 'Male', 'MALE') THEN 'male'
    WHEN gender IN ('F', 'Female', 'FEMALE') THEN 'female'
    WHEN gender IN ('All', 'ALL', 'all') THEN 'all'
    ELSE gender
END
WHERE gender IS NOT NULL;

-- =====================================================
-- 4. Wellpath Scoring Marker Pillar Weights - gender column
-- =====================================================

UPDATE wellpath_scoring_marker_pillar_weights
SET gender = CASE
    WHEN gender IN ('M', 'Male', 'MALE') THEN 'male'
    WHEN gender IN ('F', 'Female', 'FEMALE') THEN 'female'
    WHEN gender IN ('male_female', 'Male_Female', 'MALE_FEMALE') THEN 'male_female'
    ELSE gender
END
WHERE gender IS NOT NULL;

-- =====================================================
-- 5. Wellpath Scoring Question Pillar Weights - gender column
-- =====================================================

UPDATE wellpath_scoring_question_pillar_weights
SET gender = CASE
    WHEN gender IN ('M', 'Male', 'MALE') THEN 'male'
    WHEN gender IN ('F', 'Female', 'FEMALE') THEN 'female'
    WHEN gender IN ('male_female', 'Male_Female', 'MALE_FEMALE') THEN 'male_female'
    ELSE gender
END
WHERE gender IS NOT NULL;

-- =====================================================
-- 6. Wellpath Scoring Survey Functions - gender_filter column
-- =====================================================

UPDATE wellpath_scoring_survey_functions
SET gender_filter = CASE
    WHEN gender_filter IN ('M', 'Male', 'MALE') THEN 'male'
    WHEN gender_filter IN ('F', 'Female', 'FEMALE') THEN 'female'
    WHEN gender_filter IN ('male_female', 'Male_Female', 'MALE_FEMALE') THEN 'male_female'
    ELSE gender_filter
END
WHERE gender_filter IS NOT NULL;

-- =====================================================
-- 7. Patient Wellpath Score Items - patient_gender column
-- =====================================================

UPDATE patient_wellpath_score_items
SET patient_gender = CASE
    WHEN patient_gender IN ('M', 'Male', 'MALE') THEN 'male'
    WHEN patient_gender IN ('F', 'Female', 'FEMALE') THEN 'female'
    ELSE patient_gender
END
WHERE patient_gender IS NOT NULL;

-- Update the constraint to use lowercase
ALTER TABLE patient_wellpath_score_items DROP CONSTRAINT IF EXISTS patient_wellpath_score_items_patient_gender_check;
ALTER TABLE patient_wellpath_score_items ADD CONSTRAINT patient_wellpath_score_items_patient_gender_check
    CHECK (patient_gender IN ('male', 'female'));

-- =====================================================
-- 8. Add constraints to enforce lowercase going forward
-- =====================================================

-- Patient Details
ALTER TABLE patient_details DROP CONSTRAINT IF EXISTS patient_details_biological_sex_check;
ALTER TABLE patient_details ADD CONSTRAINT patient_details_biological_sex_check
    CHECK (biological_sex IN ('male', 'female'));

-- Biomarkers Detail
ALTER TABLE biomarkers_detail DROP CONSTRAINT IF EXISTS biomarkers_detail_gender_check;
ALTER TABLE biomarkers_detail ADD CONSTRAINT biomarkers_detail_gender_check
    CHECK (gender IN ('male', 'female', 'all') OR gender IS NULL);

-- Biometrics Detail
ALTER TABLE biometrics_detail DROP CONSTRAINT IF EXISTS biometrics_detail_gender_check;
ALTER TABLE biometrics_detail ADD CONSTRAINT biometrics_detail_gender_check
    CHECK (gender IN ('male', 'female', 'all') OR gender IS NULL);

-- Wellpath Scoring Marker Pillar Weights
ALTER TABLE wellpath_scoring_marker_pillar_weights DROP CONSTRAINT IF EXISTS wellpath_scoring_marker_pillar_weights_gender_check;
ALTER TABLE wellpath_scoring_marker_pillar_weights ADD CONSTRAINT wellpath_scoring_marker_pillar_weights_gender_check
    CHECK (gender IN ('male', 'female', 'male_female') OR gender IS NULL);

-- Wellpath Scoring Question Pillar Weights
ALTER TABLE wellpath_scoring_question_pillar_weights DROP CONSTRAINT IF EXISTS wellpath_scoring_question_pillar_weights_gender_check;
ALTER TABLE wellpath_scoring_question_pillar_weights ADD CONSTRAINT wellpath_scoring_question_pillar_weights_gender_check
    CHECK (gender IN ('male', 'female', 'male_female') OR gender IS NULL);

-- Wellpath Scoring Survey Functions
ALTER TABLE wellpath_scoring_survey_functions DROP CONSTRAINT IF EXISTS wellpath_scoring_survey_functions_gender_filter_check;
ALTER TABLE wellpath_scoring_survey_functions ADD CONSTRAINT wellpath_scoring_survey_functions_gender_filter_check
    CHECK (gender_filter IN ('male', 'female', 'male_female') OR gender_filter IS NULL);

COMMIT;

-- =====================================================
-- Verification
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE '✅ Gender values standardized to lowercase';
    RAISE NOTICE '';
    RAISE NOTICE 'Standard values:';
    RAISE NOTICE '  - male (for males)';
    RAISE NOTICE '  - female (for females)';
    RAISE NOTICE '  - all (for ranges that apply to both)';
    RAISE NOTICE '  - male_female (for items applicable to both)';
    RAISE NOTICE '  - NULL (for items with no gender filter)';
END $$;

-- Show summary of gender values after standardization
SELECT 'patient_details' as table_name, biological_sex as gender_value, COUNT(*) as count
FROM patient_details
GROUP BY biological_sex

UNION ALL

SELECT 'biomarkers_detail', gender, COUNT(*)
FROM biomarkers_detail
GROUP BY gender

UNION ALL

SELECT 'biometrics_detail', gender, COUNT(*)
FROM biometrics_detail
GROUP BY gender

UNION ALL

SELECT 'scoring_marker_weights', gender, COUNT(*)
FROM wellpath_scoring_marker_pillar_weights
GROUP BY gender

UNION ALL

SELECT 'scoring_question_weights', gender, COUNT(*)
FROM wellpath_scoring_question_pillar_weights
GROUP BY gender

ORDER BY table_name, gender_value;
