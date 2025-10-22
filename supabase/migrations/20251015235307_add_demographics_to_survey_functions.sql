-- Add demographic filter columns to survey functions table
ALTER TABLE wellpath_scoring_survey_functions
ADD COLUMN gender_filter TEXT,
ADD COLUMN age_min INTEGER,
ADD COLUMN age_max INTEGER;

-- Update screening functions with gender/age filters
UPDATE wellpath_scoring_survey_functions
SET gender_filter = 'female', age_min = 0, age_max = 150
WHERE function_name IN ('screening_mammogram_score', 'screening_breast_mri_score');

UPDATE wellpath_scoring_survey_functions
SET gender_filter = 'female', age_min = 0, age_max = 65
WHERE function_name IN ('screening_pap_score', 'screening_hpv_score');

UPDATE wellpath_scoring_survey_functions
SET gender_filter = 'male', age_min = 45, age_max = 70
WHERE function_name = 'screening_psa_score';

UPDATE wellpath_scoring_survey_functions
SET gender_filter = 'male_female'
WHERE function_name IN ('screening_dental_score', 'screening_skin_check_score', 'screening_vision_score', 'screening_colonoscopy_score', 'screening_dexa_score');
