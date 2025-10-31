-- =====================================================
-- Cleanup Incorrect Function Scoring Tables
-- =====================================================
-- Remove tables created with incorrect approach
-- The correct approach: ALL questions (standalone or in functions)
-- map their response options to aggregation metrics
-- Functions automatically recalculate from updated effective responses
--
-- Created: 2025-10-22
-- =====================================================

BEGIN;

-- Drop incorrect tables
DROP TABLE IF EXISTS patient_effective_function_scores CASCADE;
DROP TABLE IF EXISTS function_aggregation_mappings CASCADE;

-- Remove triggers that referenced these tables
DROP TRIGGER IF EXISTS aggregation_cache_update_function_scores ON aggregation_results_cache;
DROP TRIGGER IF EXISTS score_items_initialize_effective_function ON patient_wellpath_score_items;

-- Remove functions that referenced these tables
DROP FUNCTION IF EXISTS calculate_effective_function_score(UUID, TEXT);
DROP FUNCTION IF EXISTS refresh_patient_effective_function_scores(UUID, TEXT[]);
DROP FUNCTION IF EXISTS trigger_update_effective_function_scores();
DROP FUNCTION IF EXISTS trigger_initialize_effective_function_scores();

-- Drop views that referenced the incorrect tables
DROP VIEW IF EXISTS patient_data_quality_dashboard CASCADE;
DROP VIEW IF EXISTS patient_score_progress CASCADE;
DROP VIEW IF EXISTS patient_pillar_scores CASCADE;
DROP VIEW IF EXISTS patient_score_summary CASCADE;
DROP VIEW IF EXISTS patient_current_function_scores CASCADE;

DO $$
BEGIN
    RAISE NOTICE '✅ Cleanup Complete';
    RAISE NOTICE '';
    RAISE NOTICE 'Removed incorrect tables:';
    RAISE NOTICE '  ❌ function_aggregation_mappings';
    RAISE NOTICE '  ❌ patient_effective_function_scores';
    RAISE NOTICE '';
    RAISE NOTICE 'Correct approach:';
    RAISE NOTICE '  ✅ All questions (standalone AND in functions) map response options → agg metrics';
    RAISE NOTICE '  ✅ Edge function updates effective_response_option_id for ANY question';
    RAISE NOTICE '  ✅ Existing scoring functions recalculate automatically';
    RAISE NOTICE '';
    RAISE NOTICE 'Current state:';
    RAISE NOTICE '  - 159 response option → aggregation metric mappings';
    RAISE NOTICE '  - 36 questions covered (standalone + function-based)';
    RAISE NOTICE '  - patient_effective_responses table handles ALL question updates';
END $$;

COMMIT;
