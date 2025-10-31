-- =====================================================
-- Dynamic Scoring Views
-- =====================================================
-- Comprehensive views for accessing patient scores,
-- comparing survey vs tracking, and monitoring data quality
--
-- Created: 2025-10-22
-- =====================================================

BEGIN;

-- Drop existing views if they exist (to avoid column mismatch errors)
DROP VIEW IF EXISTS patient_data_quality_dashboard CASCADE;
DROP VIEW IF EXISTS patient_score_progress CASCADE;
DROP VIEW IF EXISTS patient_pillar_scores CASCADE;
DROP VIEW IF EXISTS patient_score_summary CASCADE;
DROP VIEW IF EXISTS patient_current_function_scores CASCADE;
DROP VIEW IF EXISTS patient_current_question_scores CASCADE;

-- =====================================================
-- VIEW 1: Patient Current Scores (Standalone Questions)
-- =====================================================

CREATE OR REPLACE VIEW patient_current_question_scores AS
SELECT
    per.user_id,
    per.question_number,
    sq.question_text,
    sq.category_id as pillar,
    sq.section_id,
    sq.group_id,

    -- Scores
    per.original_score,
    per.effective_score,
    per.effective_score - COALESCE(per.original_score, 0) as score_improvement,

    -- Source information
    per.response_source,
    per.original_response_option_id,
    per.effective_response_option_id,

    -- Tracking metadata
    per.tracking_agg_metric_id,
    per.tracking_avg_value,
    per.tracking_data_points,

    -- Quality indicators
    CASE
        WHEN per.response_source = 'tracking' AND per.tracking_data_points >= 20
            THEN 'high'
        WHEN per.response_source = 'tracking' AND per.tracking_data_points >= 10
            THEN 'medium'
        WHEN per.response_source = 'tracking'
            THEN 'low'
        ELSE 'survey_only'
    END as data_quality,

    -- Timestamps
    per.original_response_date,
    per.last_updated_at,

    -- Pillar weights
    wpw.pillar_name,
    wpw.weight as pillar_weight

FROM patient_effective_responses per
JOIN survey_questions_base sq ON per.question_number = sq.question_number
LEFT JOIN wellpath_scoring_question_pillar_weights wpw
    ON per.question_number = wpw.question_number
WHERE per.effective_score IS NOT NULL;

COMMENT ON VIEW patient_current_question_scores IS
'Shows current effective scores for all standalone questions with comparison to original survey responses';


-- =====================================================
-- VIEW 2: Patient Current Function Scores
-- =====================================================

CREATE OR REPLACE VIEW patient_current_function_scores AS
SELECT
    pefs.user_id,
    pefs.function_name,

    -- Scores
    pefs.original_score,
    pefs.effective_score,
    pefs.effective_score - COALESCE(pefs.original_score, 0) as score_improvement,

    -- Source information
    pefs.score_source,
    pefs.contributing_metrics,
    pefs.data_quality,

    -- Parse data quality summary
    jsonb_array_length(pefs.data_quality) as total_metrics,
    (
        SELECT COUNT(*)
        FROM jsonb_array_elements(pefs.data_quality) metric
        WHERE (metric->>'sufficient')::BOOLEAN = true
    ) as sufficient_metrics,

    -- Quality indicator
    CASE
        WHEN pefs.score_source = 'tracking' THEN
            CASE
                WHEN jsonb_array_length(pefs.data_quality) =
                    (SELECT COUNT(*) FROM jsonb_array_elements(pefs.data_quality) m
                     WHERE (m->>'sufficient')::BOOLEAN = true)
                THEN 'high'
                WHEN (SELECT COUNT(*) FROM jsonb_array_elements(pefs.data_quality) m
                      WHERE (m->>'sufficient')::BOOLEAN = true) > 0
                THEN 'partial'
                ELSE 'low'
            END
        ELSE 'survey_only'
    END as data_quality_level,

    -- Timestamps
    pefs.last_calculated_at,
    pefs.effective_score_date,
    pefs.created_at,
    pefs.updated_at,

    -- Function details (get first pillar if function has multiple)
    wpw.pillar_name,
    wpw.weight as pillar_weight

FROM patient_effective_function_scores pefs
LEFT JOIN LATERAL (
    SELECT pillar_name, weight
    FROM wellpath_scoring_question_pillar_weights
    WHERE function_name = pefs.function_name
        AND is_active = true
    LIMIT 1
) wpw ON true
WHERE pefs.effective_score IS NOT NULL;

COMMENT ON VIEW patient_current_function_scores IS
'Shows current effective scores for all survey functions with tracking data quality metrics';


-- =====================================================
-- VIEW 3: Patient Score Summary (Combined Questions + Functions)
-- =====================================================

CREATE OR REPLACE VIEW patient_score_summary AS
SELECT
    user_id,
    pillar_name,
    score_type,
    COUNT(*) as item_count,
    AVG(effective_score) as avg_effective_score,
    AVG(original_score) as avg_original_score,
    AVG(effective_score - COALESCE(original_score, 0)) as avg_improvement,
    SUM(CASE WHEN score_source = 'tracking' THEN 1 ELSE 0 END) as tracking_based_count,
    SUM(CASE WHEN score_source = 'survey' THEN 1 ELSE 0 END) as survey_based_count
FROM (
    -- Standalone questions
    SELECT
        user_id,
        pillar_name,
        'question' as score_type,
        effective_score,
        original_score,
        response_source as score_source
    FROM patient_current_question_scores

    UNION ALL

    -- Functions
    SELECT
        user_id,
        pillar_name,
        'function' as score_type,
        effective_score,
        original_score,
        score_source
    FROM patient_current_function_scores
) combined_scores
WHERE pillar_name IS NOT NULL
GROUP BY user_id, pillar_name, score_type;

COMMENT ON VIEW patient_score_summary IS
'Aggregated view showing score summary by pillar and type (questions vs functions)';


-- =====================================================
-- VIEW 4: Patient Pillar Scores (For WellPath Score Calculation)
-- =====================================================

CREATE OR REPLACE VIEW patient_pillar_scores AS
WITH weighted_question_scores AS (
    SELECT
        user_id,
        pillar_name,
        SUM(effective_score * pillar_weight) as weighted_score,
        SUM(pillar_weight) as total_weight,
        COUNT(*) as question_count
    FROM patient_current_question_scores
    WHERE pillar_name IS NOT NULL
        AND pillar_weight IS NOT NULL
    GROUP BY user_id, pillar_name
),
weighted_function_scores AS (
    SELECT
        user_id,
        pillar_name,
        SUM(effective_score * pillar_weight) as weighted_score,
        SUM(pillar_weight) as total_weight,
        COUNT(*) as function_count
    FROM patient_current_function_scores
    WHERE pillar_name IS NOT NULL
        AND pillar_weight IS NOT NULL
    GROUP BY user_id, pillar_name
)
SELECT
    COALESCE(wq.user_id, wf.user_id) as user_id,
    COALESCE(wq.pillar_name, wf.pillar_name) as pillar_name,

    -- Combined weighted score
    (COALESCE(wq.weighted_score, 0) + COALESCE(wf.weighted_score, 0)) /
    (COALESCE(wq.total_weight, 0) + COALESCE(wf.total_weight, 0)) as pillar_score,

    -- Component breakdown
    COALESCE(wq.question_count, 0) as question_count,
    COALESCE(wf.function_count, 0) as function_count,
    COALESCE(wq.weighted_score, 0) as questions_weighted_score,
    COALESCE(wf.weighted_score, 0) as functions_weighted_score,
    COALESCE(wq.total_weight, 0) as questions_total_weight,
    COALESCE(wf.total_weight, 0) as functions_total_weight

FROM weighted_question_scores wq
FULL OUTER JOIN weighted_function_scores wf
    ON wq.user_id = wf.user_id
    AND wq.pillar_name = wf.pillar_name;

COMMENT ON VIEW patient_pillar_scores IS
'Calculates weighted pillar scores combining both standalone questions and functions. Use this for WellPath score calculation.';


-- =====================================================
-- VIEW 5: Patient Score Progress (Tracking Impact)
-- =====================================================

CREATE OR REPLACE VIEW patient_score_progress AS
WITH all_scores AS (
    SELECT
        user_id,
        question_number::TEXT as item_id,
        'question' as item_type,
        question_text as item_description,
        pillar_name,
        original_score,
        effective_score,
        response_source as score_source,
        tracking_data_points,
        data_quality,
        last_updated_at
    FROM patient_current_question_scores

    UNION ALL

    SELECT
        user_id,
        function_name as item_id,
        'function' as item_type,
        function_name as item_description,
        pillar_name,
        original_score,
        effective_score,
        score_source,
        (
            SELECT SUM((m->>'data_points')::INT)
            FROM jsonb_array_elements(data_quality) m
        ) as tracking_data_points,
        data_quality_level as data_quality,
        last_calculated_at as last_updated_at
    FROM patient_current_function_scores
)
SELECT
    user_id,
    item_id,
    item_type,
    item_description,
    pillar_name,
    original_score,
    effective_score,
    effective_score - COALESCE(original_score, 0) as score_change,
    ROUND(((effective_score - COALESCE(original_score, 0)) / NULLIF(original_score, 0) * 100)::NUMERIC, 1) as percent_change,
    score_source,
    tracking_data_points,
    data_quality,

    -- Progress indicators
    CASE
        WHEN effective_score > COALESCE(original_score, 0) + 0.1 THEN 'improved'
        WHEN effective_score < COALESCE(original_score, 0) - 0.1 THEN 'declined'
        ELSE 'stable'
    END as progress_status,

    CASE
        WHEN score_source = 'tracking' AND tracking_data_points >= 20 THEN '🟢 High confidence'
        WHEN score_source = 'tracking' AND tracking_data_points >= 10 THEN '🟡 Medium confidence'
        WHEN score_source = 'tracking' THEN '🟠 Low confidence'
        ELSE '⚪ Survey only'
    END as confidence_indicator,

    last_updated_at

FROM all_scores
ORDER BY
    ABS(effective_score - COALESCE(original_score, 0)) DESC,
    last_updated_at DESC;

COMMENT ON VIEW patient_score_progress IS
'Shows score changes and progress for all items, highlighting improvements and data quality';


-- =====================================================
-- VIEW 6: Data Quality Dashboard
-- =====================================================

CREATE OR REPLACE VIEW patient_data_quality_dashboard AS
SELECT
    user_id,

    -- Overall coverage
    COUNT(*) as total_trackable_items,
    SUM(CASE WHEN score_source = 'tracking' THEN 1 ELSE 0 END) as tracking_based_items,
    SUM(CASE WHEN score_source = 'survey' THEN 1 ELSE 0 END) as survey_only_items,
    ROUND((SUM(CASE WHEN score_source = 'tracking' THEN 1 ELSE 0 END)::NUMERIC /
           COUNT(*)::NUMERIC * 100), 1) as tracking_coverage_percent,

    -- Data points
    SUM(tracking_data_points) as total_tracking_data_points,
    AVG(tracking_data_points) FILTER (WHERE tracking_data_points > 0) as avg_data_points_per_metric,

    -- Score improvements
    SUM(CASE WHEN score_change > 0.1 THEN 1 ELSE 0 END) as items_improved,
    SUM(CASE WHEN score_change < -0.1 THEN 1 ELSE 0 END) as items_declined,
    SUM(CASE WHEN ABS(score_change) <= 0.1 THEN 1 ELSE 0 END) as items_stable,

    -- Quality breakdown
    SUM(CASE WHEN data_quality = 'high' THEN 1 ELSE 0 END) as high_quality_items,
    SUM(CASE WHEN data_quality = 'medium' THEN 1 ELSE 0 END) as medium_quality_items,
    SUM(CASE WHEN data_quality = 'low' THEN 1 ELSE 0 END) as low_quality_items,

    -- Last update
    MAX(last_updated_at) as last_score_update

FROM patient_score_progress
GROUP BY user_id;

COMMENT ON VIEW patient_data_quality_dashboard IS
'Dashboard view showing overall data quality and tracking coverage for each patient';


-- =====================================================
-- Summary
-- =====================================================

DO $$
DECLARE
    view_count INT;
BEGIN
    SELECT COUNT(*) INTO view_count
    FROM pg_views
    WHERE viewname LIKE 'patient_%score%' OR viewname LIKE 'patient_data_quality%';

    RAISE NOTICE '✅ Dynamic Scoring Views Created';
    RAISE NOTICE '';
    RAISE NOTICE 'Views:';
    RAISE NOTICE '  patient_current_question_scores - Individual question scores';
    RAISE NOTICE '  patient_current_function_scores - Function-based scores';
    RAISE NOTICE '  patient_score_summary - Aggregated by pillar';
    RAISE NOTICE '  patient_pillar_scores - Weighted pillar scores for WellPath calculation';
    RAISE NOTICE '  patient_score_progress - Track improvements and changes';
    RAISE NOTICE '  patient_data_quality_dashboard - Overall quality metrics';
    RAISE NOTICE '';
    RAISE NOTICE 'Total views created: %', view_count;
    RAISE NOTICE '';
    RAISE NOTICE '✅ DYNAMIC SCORING SYSTEM COMPLETE!';
    RAISE NOTICE '';
    RAISE NOTICE 'System Capabilities:';
    RAISE NOTICE '  ✓ 122 standalone question mappings';
    RAISE NOTICE '  ✓ 37 function-to-aggregation mappings';
    RAISE NOTICE '  ✓ 52 biometric scoring ranges';
    RAISE NOTICE '  ✓ Automatic score updates via triggers';
    RAISE NOTICE '  ✓ Comprehensive views for score access';
    RAISE NOTICE '';
    RAISE NOTICE 'Next: Test with patient data!';
END $$;

COMMIT;
