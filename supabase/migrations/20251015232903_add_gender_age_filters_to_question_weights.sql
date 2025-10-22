-- Add gender and age filters to question pillar weights table
ALTER TABLE wellpath_scoring_question_pillar_weights
ADD COLUMN gender_filter TEXT,
ADD COLUMN age_min INTEGER,
ADD COLUMN age_max INTEGER;

-- Add gender filters for personal history questions
UPDATE wellpath_scoring_question_pillar_weights
SET gender_filter = 'female'
WHERE question_number = '9.48'; -- Breast cancer personal history

UPDATE wellpath_scoring_question_pillar_weights
SET gender_filter = 'male'
WHERE question_number = '9.52'; -- Prostate cancer personal history

-- Note: Screening functions already filtered via screening_compliance_rules table
-- This handles simple questions that are gender/age specific
