-- Create patient_item_scores_current view showing latest scores for each item
-- This view shows only the most recent calculation for each patient's items

CREATE OR REPLACE VIEW patient_item_scores_current AS
SELECT DISTINCT ON (patient_id, pillar_name, component_type, item_type, COALESCE(biomarker_name, biometric_name, question_number::text, function_name, education_module_id))
    id,
    patient_id,
    batch_id,
    calculated_at,
    pillar_name,
    component_type,
    item_type,
    biomarker_name,
    biometric_name,
    question_number,
    function_name,
    education_module_id,
    item_name,
    item_display_name,
    patient_value,
    patient_value_numeric,
    patient_gender,
    patient_age,
    raw_score,
    normalized_score,
    score_band,
    raw_weight,
    item_weight_in_pillar,
    patient_score_contribution,
    max_score_contribution,
    item_percentage,
    data_collected_at,
    data_source,
    created_at
FROM patient_item_scores_history
ORDER BY
    patient_id,
    pillar_name,
    component_type,
    item_type,
    COALESCE(biomarker_name, biometric_name, question_number::text, function_name, education_module_id),
    calculated_at DESC;

-- RLS policies for the view
ALTER VIEW patient_item_scores_current SET (security_invoker = on);

-- Comment
COMMENT ON VIEW patient_item_scores_current IS
'Current (latest) scores for each item-pillar combination for each patient. Shows the most recent calculation only.';
