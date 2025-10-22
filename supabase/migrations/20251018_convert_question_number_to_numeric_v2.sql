-- =====================================================
-- Convert question_number to numeric(5,2) - WITH FK handling
-- =====================================================
-- Comprehensive migration to convert question_number across all tables
-- Handles all foreign key constraints properly
--
-- Created: 2025-10-18
-- =====================================================

BEGIN;

-- =====================================================
-- Step 0: Drop dependent views (in reverse dependency order)
-- =====================================================

DROP VIEW IF EXISTS patient_pillar_scores CASCADE;
DROP VIEW IF EXISTS patient_section_scores CASCADE;
DROP VIEW IF EXISTS patient_score_items_clean CASCADE;
DROP VIEW IF EXISTS wellpath_scoring_question_pillar_weights_normalized CASCADE;
DROP VIEW IF EXISTS wellpath_scoring_pillar_component_weights_with_sum CASCADE;

-- =====================================================
-- Step 1: Drop all foreign key constraints
-- =====================================================

ALTER TABLE display_metrics_survey_questions
DROP CONSTRAINT IF EXISTS display_metrics_survey_questions_survey_question_id_fkey;

ALTER TABLE patient_survey_responses
DROP CONSTRAINT IF EXISTS patient_survey_responses_question_number_fkey;

ALTER TABLE patient_wellpath_score_items
DROP CONSTRAINT IF EXISTS patient_wellpath_score_items_question_number_fkey;

ALTER TABLE survey_response_options
DROP CONSTRAINT IF EXISTS survey_response_options_question_number_fkey;

ALTER TABLE wellpath_risk_assessment_rules
DROP CONSTRAINT IF EXISTS wellpath_risk_assessment_rule_family_age_at_diagnosis_ques_fkey,
DROP CONSTRAINT IF EXISTS wellpath_risk_assessment_rule_personal_age_at_diagnosis_qu_fkey,
DROP CONSTRAINT IF EXISTS wellpath_risk_assessment_rules_family_history_question_fkey,
DROP CONSTRAINT IF EXISTS wellpath_risk_assessment_rules_family_member_question_fkey,
DROP CONSTRAINT IF EXISTS wellpath_risk_assessment_rules_personal_diagnosis_question_fkey;

ALTER TABLE wellpath_scoring_behavioral
DROP CONSTRAINT IF EXISTS wellpath_scoring_behavioral_question_number_fkey;

ALTER TABLE wellpath_scoring_question_pillar_weights
DROP CONSTRAINT IF EXISTS scoring_question_pillar_weights_question_number_fkey;

ALTER TABLE wellpath_scoring_survey_function_questions
DROP CONSTRAINT IF EXISTS scoring_survey_function_questions_question_number_fkey;

-- =====================================================
-- Step 2: Convert column types
-- =====================================================

-- Base table first
ALTER TABLE survey_questions_base
ALTER COLUMN question_number TYPE numeric(5,2) USING question_number::numeric(5,2);

-- Then all referencing tables
ALTER TABLE display_metrics_survey_questions
ALTER COLUMN survey_question_id TYPE numeric(5,2) USING survey_question_id::numeric(5,2);

ALTER TABLE patient_survey_responses
ALTER COLUMN question_number TYPE numeric(5,2) USING question_number::numeric(5,2);

ALTER TABLE patient_wellpath_score_items
ALTER COLUMN question_number TYPE numeric(5,2) USING question_number::numeric(5,2);

ALTER TABLE survey_response_options
ALTER COLUMN question_number TYPE numeric(5,2) USING question_number::numeric(5,2);

ALTER TABLE wellpath_risk_assessment_rules
ALTER COLUMN family_age_at_diagnosis_question TYPE numeric(5,2) USING family_age_at_diagnosis_question::numeric(5,2),
ALTER COLUMN personal_age_at_diagnosis_question TYPE numeric(5,2) USING personal_age_at_diagnosis_question::numeric(5,2),
ALTER COLUMN family_history_question TYPE numeric(5,2) USING family_history_question::numeric(5,2),
ALTER COLUMN family_member_question TYPE numeric(5,2) USING family_member_question::numeric(5,2),
ALTER COLUMN personal_diagnosis_question TYPE numeric(5,2) USING personal_diagnosis_question::numeric(5,2);

ALTER TABLE wellpath_scoring_behavioral
ALTER COLUMN question_number TYPE numeric(5,2) USING question_number::numeric(5,2);

ALTER TABLE wellpath_scoring_question_pillar_weights
ALTER COLUMN question_number TYPE numeric(5,2) USING question_number::numeric(5,2);

ALTER TABLE wellpath_scoring_survey_function_questions
ALTER COLUMN question_number TYPE numeric(5,2) USING question_number::numeric(5,2);

-- =====================================================
-- Step 3: Recreate foreign key constraints
-- =====================================================

ALTER TABLE display_metrics_survey_questions
ADD CONSTRAINT display_metrics_survey_questions_survey_question_id_fkey
FOREIGN KEY (survey_question_id) REFERENCES survey_questions_base(question_number);

ALTER TABLE patient_survey_responses
ADD CONSTRAINT patient_survey_responses_question_number_fkey
FOREIGN KEY (question_number) REFERENCES survey_questions_base(question_number);

ALTER TABLE patient_wellpath_score_items
ADD CONSTRAINT patient_wellpath_score_items_question_number_fkey
FOREIGN KEY (question_number) REFERENCES survey_questions_base(question_number);

ALTER TABLE survey_response_options
ADD CONSTRAINT survey_response_options_question_number_fkey
FOREIGN KEY (question_number) REFERENCES survey_questions_base(question_number);

ALTER TABLE wellpath_risk_assessment_rules
ADD CONSTRAINT wellpath_risk_assessment_rule_family_age_at_diagnosis_ques_fkey
FOREIGN KEY (family_age_at_diagnosis_question) REFERENCES survey_questions_base(question_number);

ALTER TABLE wellpath_risk_assessment_rules
ADD CONSTRAINT wellpath_risk_assessment_rule_personal_age_at_diagnosis_qu_fkey
FOREIGN KEY (personal_age_at_diagnosis_question) REFERENCES survey_questions_base(question_number);

ALTER TABLE wellpath_risk_assessment_rules
ADD CONSTRAINT wellpath_risk_assessment_rules_family_history_question_fkey
FOREIGN KEY (family_history_question) REFERENCES survey_questions_base(question_number);

ALTER TABLE wellpath_risk_assessment_rules
ADD CONSTRAINT wellpath_risk_assessment_rules_family_member_question_fkey
FOREIGN KEY (family_member_question) REFERENCES survey_questions_base(question_number);

ALTER TABLE wellpath_risk_assessment_rules
ADD CONSTRAINT wellpath_risk_assessment_rules_personal_diagnosis_question_fkey
FOREIGN KEY (personal_diagnosis_question) REFERENCES survey_questions_base(question_number);

ALTER TABLE wellpath_scoring_behavioral
ADD CONSTRAINT wellpath_scoring_behavioral_question_number_fkey
FOREIGN KEY (question_number) REFERENCES survey_questions_base(question_number);

ALTER TABLE wellpath_scoring_question_pillar_weights
ADD CONSTRAINT scoring_question_pillar_weights_question_number_fkey
FOREIGN KEY (question_number) REFERENCES survey_questions_base(question_number);

ALTER TABLE wellpath_scoring_survey_function_questions
ADD CONSTRAINT scoring_survey_function_questions_question_number_fkey
FOREIGN KEY (question_number) REFERENCES survey_questions_base(question_number);

-- =====================================================
-- Step 4: Recreate views
-- =====================================================

-- Recreate views (run the migration files in dependency order)
\i /Users/keegs/Documents/GitHub/WellPath-V2-Backend/supabase/migrations/20251017_wellpath_scoring_normalization.sql
\i /Users/keegs/Documents/GitHub/WellPath-V2-Backend/supabase/migrations/20251017_patient_score_items_clean.sql
\i /Users/keegs/Documents/GitHub/WellPath-V2-Backend/supabase/migrations/20251017_patient_section_scores.sql
\i /Users/keegs/Documents/GitHub/WellPath-V2-Backend/supabase/migrations/20251017_patient_pillar_scores.sql

-- =====================================================
-- Verification
-- =====================================================

DO $$
DECLARE
  base_type text;
  fk_count int;
BEGIN
  SELECT data_type INTO base_type
  FROM information_schema.columns
  WHERE table_name = 'survey_questions_base'
  AND column_name = 'question_number';

  SELECT COUNT(*) INTO fk_count
  FROM information_schema.table_constraints
  WHERE constraint_type = 'FOREIGN KEY'
  AND constraint_name LIKE '%question_number%';

  RAISE NOTICE '✅ Question number conversion complete:';
  RAISE NOTICE '  - survey_questions_base.question_number type: %', base_type;
  RAISE NOTICE '  - Foreign keys recreated: %', fk_count;
END $$;

COMMIT;
