-- Create view showing item scores as percentage of their COMPONENT (not just pillar)
-- This supports the drill-down flow: WellPath Score → Pillar → Component → Items
--
-- For example, a Healthful Nutrition marker with item_weight_in_pillar of 0.01116
-- and markers component weight of 0.72 becomes:
-- item_weight_in_component = 0.01116 / 0.72 = 0.0155 (1.55% of the markers component)

CREATE OR REPLACE VIEW patient_item_scores_with_component_weights AS
SELECT
    h.*,

    -- Get component weight from wellpath_scoring_pillar_component_weights
    CASE
        WHEN h.component_type = 'markers' THEN pcw.marker_weight
        WHEN h.component_type = 'behaviors' THEN pcw.survey_weight
        WHEN h.component_type = 'education' THEN pcw.education_weight
    END as component_weight_in_pillar,

    -- Calculate item's weight as fraction of its component (not pillar)
    -- This shows what percentage of the component this item represents
    CASE
        WHEN h.component_type = 'markers' THEN
            CASE WHEN pcw.marker_weight > 0
                THEN h.item_weight_in_pillar / pcw.marker_weight
                ELSE 0
            END
        WHEN h.component_type = 'behaviors' THEN
            CASE WHEN pcw.survey_weight > 0
                THEN h.item_weight_in_pillar / pcw.survey_weight
                ELSE 0
            END
        WHEN h.component_type = 'education' THEN
            CASE WHEN pcw.education_weight > 0
                THEN h.item_weight_in_pillar / pcw.education_weight
                ELSE 0
            END
    END as item_weight_in_component,

    -- Calculate max contribution to component (same value, just clear naming)
    CASE
        WHEN h.component_type = 'markers' THEN
            CASE WHEN pcw.marker_weight > 0
                THEN h.max_score_contribution / pcw.marker_weight
                ELSE 0
            END
        WHEN h.component_type = 'behaviors' THEN
            CASE WHEN pcw.survey_weight > 0
                THEN h.max_score_contribution / pcw.survey_weight
                ELSE 0
            END
        WHEN h.component_type = 'education' THEN
            CASE WHEN pcw.education_weight > 0
                THEN h.max_score_contribution / pcw.education_weight
                ELSE 0
            END
    END as max_contribution_to_component,

    -- Calculate patient contribution to component
    CASE
        WHEN h.component_type = 'markers' THEN
            CASE WHEN pcw.marker_weight > 0
                THEN h.patient_score_contribution / pcw.marker_weight
                ELSE 0
            END
        WHEN h.component_type = 'behaviors' THEN
            CASE WHEN pcw.survey_weight > 0
                THEN h.patient_score_contribution / pcw.survey_weight
                ELSE 0
            END
        WHEN h.component_type = 'education' THEN
            CASE WHEN pcw.education_weight > 0
                THEN h.patient_score_contribution / pcw.education_weight
                ELSE 0
            END
    END as patient_contribution_to_component,

    -- Component percentage (same as item_percentage, but explicit naming)
    -- This is (patient_contribution / max_contribution) * 100 at component level
    h.item_percentage as component_percentage

FROM patient_item_scores_history h
INNER JOIN wellpath_scoring_pillar_component_weights pcw
    ON h.pillar_name = pcw.pillar_name;

-- Create corresponding current view
CREATE OR REPLACE VIEW patient_item_scores_current_with_component_weights AS
SELECT DISTINCT ON (
    patient_id,
    pillar_name,
    component_type,
    item_type,
    COALESCE(biomarker_name, biometric_name, question_number::text, function_name, education_module_id)
)
    *
FROM patient_item_scores_with_component_weights
ORDER BY
    patient_id,
    pillar_name,
    component_type,
    item_type,
    COALESCE(biomarker_name, biometric_name, question_number::text, function_name, education_module_id),
    calculated_at DESC;

-- Enable RLS (inherits from base table)
ALTER VIEW patient_item_scores_with_component_weights SET (security_invoker = on);
ALTER VIEW patient_item_scores_current_with_component_weights SET (security_invoker = on);

-- Comments
COMMENT ON VIEW patient_item_scores_with_component_weights IS
'Item scores with weights normalized to component level. Shows what percentage of a COMPONENT (markers/behaviors/education) each item represents, not just the pillar. Used for drill-down UI: WellPath Score → Pillar → Component → Items.';

COMMENT ON VIEW patient_item_scores_current_with_component_weights IS
'Latest item scores with component-level weights. Shows current state for mobile app drill-down from component to items.';

-- Example usage for Swift:
--
-- Get items in Healthful Nutrition markers component, showing % of markers:
-- SELECT
--     item_name,
--     item_weight_in_component,  -- What fraction of markers component this item is
--     component_percentage,       -- Patient's score as % of this item's max
--     patient_contribution_to_component,  -- Patient's points towards markers
--     max_contribution_to_component       -- Max possible points towards markers
-- FROM patient_item_scores_current_with_component_weights
-- WHERE patient_id = '<uuid>'
--   AND pillar_name = 'Healthful Nutrition'
--   AND component_type = 'markers'
-- ORDER BY item_weight_in_component DESC;
