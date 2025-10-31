-- Remove pillar_id entirely and use only pillar_name
-- pillar_id was a remnant from Airtable conversion

-- =====================================================
-- 1. UPDATE PATIENT_COMPONENT_SCORES_HISTORY
-- =====================================================

-- Drop the old view first
DROP VIEW IF EXISTS patient_component_scores_current;

-- Drop foreign key constraint on pillar_id
ALTER TABLE patient_component_scores_history
DROP CONSTRAINT IF EXISTS patient_component_scores_history_pillar_id_fkey;

-- Drop index on pillar_id
DROP INDEX IF EXISTS idx_component_scores_history_patient_pillar_component;

-- Drop pillar_id column
ALTER TABLE patient_component_scores_history
DROP COLUMN IF EXISTS pillar_id;

-- Recreate index using pillar_name
CREATE INDEX idx_component_scores_history_patient_pillar_component
ON patient_component_scores_history(patient_id, pillar_name, component_type, calculated_at DESC);

-- Recreate view using pillar_name
CREATE OR REPLACE VIEW patient_component_scores_current AS
SELECT DISTINCT ON (patient_id, pillar_name, component_type)
    id,
    patient_id,
    pillar_name,
    component_type,
    component_score,
    component_max_score,
    component_percentage,
    item_count,
    biomarker_count,
    biometric_count,
    survey_question_count,
    survey_function_count,
    education_count,
    calculated_at,
    calculation_version,
    created_at
FROM patient_component_scores_history
ORDER BY patient_id, pillar_name, component_type, calculated_at DESC;

ALTER VIEW patient_component_scores_current SET (security_invoker = on);

-- =====================================================
-- 2. UPDATE PATIENT_PILLAR_SCORES_HISTORY
-- =====================================================

-- Drop the old view first
DROP VIEW IF EXISTS patient_pillar_scores_current;

-- Drop foreign key constraint on pillar_id
ALTER TABLE patient_pillar_scores_history
DROP CONSTRAINT IF EXISTS patient_pillar_scores_history_pillar_id_fkey;

-- Drop index on pillar_id
DROP INDEX IF EXISTS idx_pillar_scores_history_patient_pillar;

-- Drop pillar_id column
ALTER TABLE patient_pillar_scores_history
DROP COLUMN IF EXISTS pillar_id;

-- Recreate index using pillar_name
CREATE INDEX idx_pillar_scores_history_patient_pillar
ON patient_pillar_scores_history(patient_id, pillar_name, calculated_at DESC);

-- Recreate view using pillar_name
CREATE OR REPLACE VIEW patient_pillar_scores_current AS
SELECT DISTINCT ON (patient_id, pillar_name)
    id,
    patient_id,
    pillar_name,
    pillar_score,
    pillar_max_score,
    pillar_percentage,
    item_count,
    biomarker_count,
    biometric_count,
    survey_question_count,
    survey_function_count,
    education_count,
    calculated_at,
    calculation_version,
    created_at
FROM patient_pillar_scores_history
ORDER BY patient_id, pillar_name, calculated_at DESC;

ALTER VIEW patient_pillar_scores_current SET (security_invoker = on);

-- =====================================================
-- 3. UPDATE PILLARS_BASE TABLE
-- =====================================================

-- Drop pillar_id column from pillars_base (keep pillar_name as primary key)
ALTER TABLE pillars_base
DROP COLUMN IF EXISTS pillar_id;

-- Ensure pillar_name is the primary key
ALTER TABLE pillars_base
DROP CONSTRAINT IF EXISTS pillars_base_pkey;

ALTER TABLE pillars_base
ADD PRIMARY KEY (pillar_name);

-- =====================================================
-- COMMENTS
-- =====================================================

COMMENT ON TABLE patient_component_scores_history IS
'Historical component scores (markers, behaviors, education) per patient-pillar combination. Uses pillar_name (not pillar_id).';

COMMENT ON TABLE patient_pillar_scores_history IS
'Historical pillar scores per patient. Uses pillar_name (not pillar_id).';

COMMENT ON VIEW patient_component_scores_current IS
'Current (most recent) component scores for each patient-pillar-component combination. Uses pillar_name for Swift compatibility.';

COMMENT ON VIEW patient_pillar_scores_current IS
'Current (most recent) pillar scores for each patient-pillar combination. Uses pillar_name for Swift compatibility.';
