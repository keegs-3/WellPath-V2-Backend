-- Rename patient_wellpath_scores to patient_wellpath_scores_history for consistency
-- This table already functions as a history table (keeps all calculations with calculated_at timestamps)
-- But naming was inconsistent with other history tables

-- Rename the table
ALTER TABLE patient_wellpath_scores RENAME TO patient_wellpath_scores_history;

-- Rename the primary key constraint
ALTER TABLE patient_wellpath_scores_history
RENAME CONSTRAINT patient_wellpath_scores_pkey TO patient_wellpath_scores_history_pkey;

-- Rename the foreign key constraint
ALTER TABLE patient_wellpath_scores_history
RENAME CONSTRAINT patient_wellpath_scores_patient_id_fkey TO patient_wellpath_scores_history_patient_id_fkey;

-- Rename indexes
ALTER INDEX idx_patient_wellpath_scores_calculated_at
RENAME TO idx_patient_wellpath_scores_history_calculated_at;

ALTER INDEX idx_patient_wellpath_scores_patient_calculated
RENAME TO idx_patient_wellpath_scores_history_patient_calculated;

ALTER INDEX idx_patient_wellpath_scores_patient_id
RENAME TO idx_patient_wellpath_scores_history_patient_id;

-- Update the view definition to use the renamed table
DROP VIEW IF EXISTS patient_wellpath_scores_current;

CREATE OR REPLACE VIEW patient_wellpath_scores_current AS
SELECT DISTINCT ON (patient_id)
    id,
    patient_id,
    overall_score,
    overall_max_score,
    overall_percentage,
    pillar_scores,
    total_items_scored,
    biomarker_count,
    biometric_count,
    survey_question_count,
    survey_function_count,
    calculation_version,
    calculated_at,
    created_at
FROM patient_wellpath_scores_history
ORDER BY patient_id, calculated_at DESC;

-- Set security invoker for RLS
ALTER VIEW patient_wellpath_scores_current SET (security_invoker = on);

-- Update table comment
COMMENT ON TABLE patient_wellpath_scores_history IS
'Historical record of overall WellPath scores for each patient. Each calculation creates a new row with calculated_at timestamp for trend tracking.';

-- Update view comment
COMMENT ON VIEW patient_wellpath_scores_current IS
'Current (most recent) overall WellPath score for each patient. Shows only the latest calculation.';
