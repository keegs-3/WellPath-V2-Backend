-- =====================================================
-- Fix Function Score Initialization Trigger
-- =====================================================
-- The trigger should be on patient_wellpath_score_items
-- not on the reference table wellpath_scoring_survey_functions
--
-- Created: 2025-10-22
-- =====================================================

BEGIN;

-- Drop the incorrect trigger if it exists
DROP TRIGGER IF EXISTS survey_function_initialize_effective ON wellpath_scoring_survey_functions;

-- Create correct trigger on patient_wellpath_score_items
CREATE OR REPLACE FUNCTION trigger_initialize_effective_function_scores()
RETURNS TRIGGER AS $$
BEGIN
    -- Only process if this is a survey function item
    IF NEW.item_type = 'survey_function' AND NEW.function_name IS NOT NULL THEN
        -- Insert initial effective function score
        INSERT INTO patient_effective_function_scores (
            user_id,
            function_name,
            original_score,
            effective_score,
            score_source,
            contributing_metrics,
            data_quality,
            last_calculated_at,
            created_at
        ) VALUES (
            NEW.user_id,
            NEW.function_name,
            NEW.normalized_score,
            NEW.normalized_score,
            'survey',
            '[]'::JSONB,
            '[]'::JSONB,
            NOW(),
            NOW()
        )
        ON CONFLICT (user_id, function_name)
        DO UPDATE SET
            original_score = EXCLUDED.original_score,
            effective_score = CASE
                WHEN patient_effective_function_scores.score_source = 'survey'
                THEN EXCLUDED.effective_score
                ELSE patient_effective_function_scores.effective_score
            END,
            last_calculated_at = NOW();
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER score_items_initialize_effective_function
AFTER INSERT OR UPDATE ON patient_wellpath_score_items
FOR EACH ROW
EXECUTE FUNCTION trigger_initialize_effective_function_scores();

COMMENT ON TRIGGER score_items_initialize_effective_function ON patient_wellpath_score_items IS
'Initializes effective function scores when patient function scores are calculated and inserted into score items';

DO $$
BEGIN
    RAISE NOTICE '✅ Function score trigger fixed';
    RAISE NOTICE '   Trigger now correctly watches patient_wellpath_score_items table';
END $$;

COMMIT;
