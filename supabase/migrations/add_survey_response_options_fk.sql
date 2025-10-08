-- Add foreign key from survey_response_options.linked_survey_question to survey_questions.record_id

-- First check if any orphaned records exist
DO $$
DECLARE
    orphaned_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO orphaned_count
    FROM survey_response_options sro
    WHERE sro.linked_survey_question IS NOT NULL
      AND sro.linked_survey_question NOT IN (SELECT record_id FROM survey_questions);

    IF orphaned_count > 0 THEN
        RAISE NOTICE 'Warning: % response options have invalid linked_survey_question', orphaned_count;
    END IF;
END $$;

-- Add the foreign key constraint
ALTER TABLE survey_response_options
ADD CONSTRAINT fk_survey_response_options_linked_survey_question
FOREIGN KEY (linked_survey_question) REFERENCES survey_questions(record_id)
ON UPDATE CASCADE ON DELETE CASCADE;

-- Create index for performance
CREATE INDEX IF NOT EXISTS idx_survey_response_options_linked_question
ON survey_response_options(linked_survey_question);
