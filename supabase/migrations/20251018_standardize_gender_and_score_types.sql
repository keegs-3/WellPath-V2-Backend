-- =====================================================
-- Standardize Gender and Score Data Types
-- =====================================================
-- 1. Convert NULL gender to 'all' in survey_questions_base
-- 2. Convert biomarkers_detail score columns from float4 to numeric
--
-- Created: 2025-10-18
-- =====================================================

BEGIN;

-- =====================================================
-- Part 1: Standardize Gender in survey_questions_base
-- =====================================================

-- Update NULL and empty string to 'all'
UPDATE survey_questions_base
SET gender = 'all'
WHERE gender IS NULL OR TRIM(gender) = '';

-- Also handle 'female+' -> 'female'
UPDATE survey_questions_base
SET gender = 'female'
WHERE gender = 'female+';

-- =====================================================
-- Part 2: Convert biomarkers_detail scores to numeric
-- =====================================================

-- Convert score_at_low from float4 to numeric
ALTER TABLE biomarkers_detail
ALTER COLUMN score_at_low TYPE numeric USING score_at_low::numeric;

-- Convert score_at_high from float4 to numeric
ALTER TABLE biomarkers_detail
ALTER COLUMN score_at_high TYPE numeric USING score_at_high::numeric;

-- =====================================================
-- Verification
-- =====================================================

DO $$
DECLARE
  null_gender_count int;
  all_gender_count int;
  biomarker_score_type text;
  biometric_score_type text;
BEGIN
  -- Check gender values
  SELECT COUNT(*) INTO null_gender_count
  FROM survey_questions_base
  WHERE gender IS NULL OR TRIM(gender) = '';

  SELECT COUNT(*) INTO all_gender_count
  FROM survey_questions_base
  WHERE gender = 'all';

  -- Check biomarkers_detail score types
  SELECT data_type INTO biomarker_score_type
  FROM information_schema.columns
  WHERE table_name = 'biomarkers_detail'
  AND column_name = 'score_at_low';

  -- Check biometrics_detail score types
  SELECT data_type INTO biometric_score_type
  FROM information_schema.columns
  WHERE table_name = 'biometrics_detail'
  AND column_name = 'score_at_low';

  RAISE NOTICE '✅ Standardization complete:';
  RAISE NOTICE '';
  RAISE NOTICE 'Gender standardization:';
  RAISE NOTICE '  - NULL/empty gender values: %', null_gender_count;
  RAISE NOTICE '  - ''all'' gender values: %', all_gender_count;
  RAISE NOTICE '';
  RAISE NOTICE 'Score type standardization:';
  RAISE NOTICE '  - biomarkers_detail score type: %', biomarker_score_type;
  RAISE NOTICE '  - biometrics_detail score type: %', biometric_score_type;
END $$;

COMMIT;

-- =====================================================
-- Comments
-- =====================================================

COMMENT ON COLUMN survey_questions_base.gender IS
'Gender applicability: ''male'', ''female'', or ''all'' for questions that apply to all genders';

COMMENT ON COLUMN biomarkers_detail.score_at_low IS
'Score value at the low end of the range (0-10 scale, numeric for precision)';

COMMENT ON COLUMN biomarkers_detail.score_at_high IS
'Score value at the high end of the range (0-10 scale, numeric for precision)';
