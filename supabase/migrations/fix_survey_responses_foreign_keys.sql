-- Fix survey_responses to properly link to survey_questions and survey_response_options

-- Step 1: Drop the unique constraint temporarily
ALTER TABLE survey_responses DROP CONSTRAINT IF EXISTS unique_patient_question;

-- Step 2: Add a temporary column for the new record_id
ALTER TABLE survey_responses ADD COLUMN IF NOT EXISTS question_record_id TEXT;

-- Step 3: Map numeric question_id to record_id using survey_questions.ID
UPDATE survey_responses sr
SET question_record_id = sq.record_id
FROM survey_questions sq
WHERE sr.question_id::TEXT = sq."ID"::TEXT;

-- Step 4: Check if any responses couldn't be mapped
DO $$
DECLARE
    unmapped_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO unmapped_count
    FROM survey_responses
    WHERE question_record_id IS NULL;

    IF unmapped_count > 0 THEN
        RAISE NOTICE 'Warning: % survey responses could not be mapped to questions', unmapped_count;
    END IF;
END $$;

-- Step 5: Drop old question_id column and rename new one
ALTER TABLE survey_responses DROP COLUMN question_id;
ALTER TABLE survey_responses RENAME COLUMN question_record_id TO question_id;

-- Step 6: Make question_id NOT NULL
ALTER TABLE survey_responses ALTER COLUMN question_id SET NOT NULL;

-- Step 7: Add foreign key constraint to survey_questions
ALTER TABLE survey_responses
ADD CONSTRAINT fk_survey_responses_question_id
FOREIGN KEY (question_id) REFERENCES survey_questions(record_id)
ON UPDATE CASCADE ON DELETE CASCADE;

-- Step 8: Add foreign key constraint to survey_response_options (if response_option_id is populated)
ALTER TABLE survey_responses
ADD CONSTRAINT fk_survey_responses_response_option_id
FOREIGN KEY (response_option_id) REFERENCES survey_response_options(record_id)
ON UPDATE CASCADE ON DELETE SET NULL;

-- Step 9: Recreate the unique constraint with TEXT type
ALTER TABLE survey_responses
ADD CONSTRAINT unique_patient_question UNIQUE (patient_id, question_id);

-- Step 10: Recreate index for better performance
DROP INDEX IF EXISTS idx_survey_responses_question;
CREATE INDEX idx_survey_responses_question ON survey_responses(question_id);
