-- Create view for item cards with navigation metadata and clean display names
-- This enables the component drill-down flow: WellPath Score → Pillar → Component → Items
-- Each item card shows: ring chart, display name, subtitle, and navigation target

CREATE OR REPLACE VIEW patient_item_cards_with_navigation AS
SELECT
    -- All columns from base view (scoring data, weights, etc.)
    h.id,
    h.patient_id,
    h.pillar_name,
    h.component_type,
    h.item_type,
    h.item_name,
    h.biomarker_name,
    h.biometric_name,
    h.question_number,
    h.function_name,
    h.education_module_id,
    h.item_weight_in_pillar,
    h.item_weight_in_component,
    h.component_percentage,
    h.patient_value,
    h.patient_score_contribution,
    h.max_score_contribution,
    h.calculated_at,
    h.component_weight_in_pillar,
    h.max_contribution_to_component,
    h.patient_contribution_to_component,

    -- Card Display Name (user-friendly name for the card)
    CASE
        -- Biomarkers and biometrics: use their existing names (already clean)
        WHEN h.item_type IN ('biomarker', 'biometric') THEN
            COALESCE(h.biomarker_name, h.biometric_name, h.item_name)

        -- Survey questions: use group display name (e.g., "Fish Consumption")
        WHEN h.item_type = 'survey_question' THEN
            COALESCE(sg.display_name, sq.question_text, h.item_name)

        -- Survey functions: use display name from survey functions table
        WHEN h.item_type = 'survey_function' THEN
            COALESCE(sf.display_name, h.function_name, h.item_name)

        -- Education: use module title
        WHEN h.item_type = 'education' THEN
            COALESCE(eb.title, h.item_name)

        ELSE h.item_name
    END as card_display_name,

    -- Card Subtitle (provides context, e.g., section name)
    CASE
        WHEN h.item_type IN ('survey_question', 'survey_function') THEN
            ss.display_name
        WHEN h.item_type = 'education' THEN
            'Education'
        ELSE NULL
    END as card_subtitle,

    -- Navigation Type (tells Swift which view to navigate to)
    CASE
        WHEN h.item_type = 'biomarker' THEN 'biomarker_detail'
        WHEN h.item_type = 'biometric' THEN 'biometric_detail'
        WHEN h.item_type IN ('survey_question', 'survey_function') THEN 'display_screen'
        WHEN h.item_type = 'education' THEN 'education_content'
        ELSE 'unknown'
    END as navigation_type,

    -- Navigation ID (the identifier Swift needs for navigation)
    CASE
        -- Biomarkers/biometrics: use the item name
        WHEN h.item_type IN ('biomarker', 'biometric') THEN
            COALESCE(h.biomarker_name, h.biometric_name, h.item_name)

        -- Survey questions: use question_number for now (can be mapped to display_screen later)
        WHEN h.item_type = 'survey_question' THEN
            h.question_number::text

        -- Survey functions: use function name
        WHEN h.item_type = 'survey_function' THEN
            h.function_name

        -- Education: use module_id
        WHEN h.item_type = 'education' THEN
            eb.module_id

        ELSE NULL
    END as navigation_id,

    -- Additional context for display
    sg.display_name as survey_group_name,
    ss.display_name as survey_section_name

FROM patient_item_scores_current_with_component_weights h

-- Join survey questions for display names
LEFT JOIN survey_questions_base sq ON h.question_number = sq.question_number
LEFT JOIN survey_groups sg ON sq.group_id = sg.group_id
LEFT JOIN survey_sections ss ON sq.section_id = ss.section_id

-- Join survey functions for display names
LEFT JOIN wellpath_scoring_survey_functions sf ON h.function_name = sf.function_name

-- Join education for content
LEFT JOIN education_base eb ON h.education_module_id = eb.module_id;

-- Enable RLS (inherits from base table)
ALTER VIEW patient_item_cards_with_navigation SET (security_invoker = on);

-- Create index on base table to speed up queries (if not exists)
CREATE INDEX IF NOT EXISTS idx_patient_item_scores_history_patient_pillar_component
ON patient_item_scores_history(patient_id, pillar_name, component_type, calculated_at DESC);

-- Comments
COMMENT ON VIEW patient_item_cards_with_navigation IS
'Item cards with navigation metadata and clean display names. Used for component drill-down UI showing cards that navigate to biomarker detail, display screens, or education content.';

-- Example Swift usage:
--
-- Get all item cards for Healthful Nutrition markers:
-- SELECT
--     card_display_name,
--     card_subtitle,
--     component_percentage,
--     item_weight_in_component,
--     navigation_type,
--     navigation_id
-- FROM patient_item_cards_with_navigation
-- WHERE patient_id = '<uuid>'
--   AND pillar_name = 'Healthful Nutrition'
--   AND component_type = 'markers'
-- ORDER BY item_weight_in_component DESC;
--
-- Swift Navigation Pattern:
-- switch card.navigation_type {
-- case "biomarker_detail":
--     BiomarkerDetailView(name: card.navigation_id, ...)
-- case "biometric_detail":
--     BiometricDetailView(name: card.navigation_id, ...)
-- case "display_screen":
--     DisplayScreenView(screenId: card.navigation_id, ...)
-- case "education_content":
--     EducationContentView(moduleId: card.navigation_id, ...)
-- }
