-- =====================================================
-- Convert question_number to numeric(5,2)
-- =====================================================
-- Standardize question_number format to numeric with 2 decimal places
-- This ensures consistent formatting (e.g., 2.05 instead of 2.5 or 205)
--
-- Created: 2025-10-18
-- =====================================================

BEGIN;

-- Convert question_number in survey_questions_base
ALTER TABLE survey_questions_base
ALTER COLUMN question_number TYPE numeric(5,2) USING question_number::numeric(5,2);

-- Convert question_number in survey_response_options
ALTER TABLE survey_response_options
ALTER COLUMN question_number TYPE numeric(5,2) USING question_number::numeric(5,2);

-- Convert question_number in patient_survey_responses
ALTER TABLE patient_survey_responses
ALTER COLUMN question_number TYPE numeric(5,2) USING question_number::numeric(5,2);

-- Convert question_number in wellpath_scoring_question_pillar_weights_normalized (view)
-- Note: This is a view, so we need to recreate it with the new type
-- First check if there are any other tables with question_number

-- Verification
DO $$
DECLARE
  questions_base_type text;
  response_options_type text;
  patient_responses_type text;
BEGIN
  -- Check data types
  SELECT data_type INTO questions_base_type
  FROM information_schema.columns
  WHERE table_name = 'survey_questions_base'
  AND column_name = 'question_number';

  SELECT data_type INTO response_options_type
  FROM information_schema.columns
  WHERE table_name = 'survey_response_options'
  AND column_name = 'question_number';

  SELECT data_type INTO patient_responses_type
  FROM information_schema.columns
  WHERE table_name = 'patient_survey_responses'
  AND column_name = 'question_number';

  RAISE NOTICE '✅ Question number conversion complete:';
  RAISE NOTICE '  - survey_questions_base.question_number: %', questions_base_type;
  RAISE NOTICE '  - survey_response_options.question_number: %', response_options_type;
  RAISE NOTICE '  - patient_survey_responses.question_number: %', patient_responses_type;
  RAISE NOTICE '';
  RAISE NOTICE '⚠️  NOTE: Views using question_number will need to be refreshed';
END $$;

COMMIT;

-- =====================================================
-- Comments
-- =====================================================

COMMENT ON COLUMN survey_questions_base.question_number IS
'Question identifier in format X.YY (e.g., 1.01, 10.13). Numeric type ensures consistent formatting with 2 decimal places.';

COMMENT ON COLUMN survey_response_options.question_number IS
'Question identifier in format X.YY (e.g., 1.01, 10.13). Links to survey_questions_base.question_number.';

COMMENT ON COLUMN patient_survey_responses.question_number IS
'Question identifier in format X.YY (e.g., 1.01, 10.13). Links to survey_questions_base.question_number.';
