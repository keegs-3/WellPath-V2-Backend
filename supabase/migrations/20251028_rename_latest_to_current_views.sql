-- Rename _latest views to _current for consistency
-- "current" is more semantically accurate than "latest" for showing the most recent scores

-- Rename patient_component_scores_latest -> patient_component_scores_current
ALTER VIEW patient_component_scores_latest RENAME TO patient_component_scores_current;

-- Rename patient_pillar_scores_latest -> patient_pillar_scores_current
ALTER VIEW patient_pillar_scores_latest RENAME TO patient_pillar_scores_current;

-- Rename patient_wellpath_scores_latest -> patient_wellpath_scores_current
ALTER VIEW patient_wellpath_scores_latest RENAME TO patient_wellpath_scores_current;

-- Update comments
COMMENT ON VIEW patient_component_scores_current IS
'Current (most recent) component scores for each patient-pillar-component combination. Shows only the latest calculation.';

COMMENT ON VIEW patient_pillar_scores_current IS
'Current (most recent) pillar scores for each patient-pillar combination. Shows only the latest calculation.';

COMMENT ON VIEW patient_wellpath_scores_current IS
'Current (most recent) overall WellPath score for each patient. Shows only the latest calculation.';
