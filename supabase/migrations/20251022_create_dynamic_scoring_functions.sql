-- =====================================================
-- Dynamic Scoring Calculation Functions
-- =====================================================
-- Functions and triggers to automatically update patient scores
-- based on tracked behavior data
--
-- Created: 2025-10-22
-- =====================================================

BEGIN;

-- =====================================================
-- FUNCTION 1: Calculate Effective Response for Standalone Questions
-- =====================================================

CREATE OR REPLACE FUNCTION calculate_effective_response(
    p_user_id UUID,
    p_question_number NUMERIC
) RETURNS TABLE (
    effective_response_option_id TEXT,
    effective_score NUMERIC,
    response_source TEXT,
    tracking_value NUMERIC,
    data_points INT,
    agg_metric_used TEXT
) AS $$
DECLARE
    v_agg_metric_id TEXT;
    v_calc_type TEXT;
    v_period_type TEXT;
    v_lookback_days INT;
    v_min_data_points INT;
    v_tracking_avg NUMERIC;
    v_data_point_count INT;
BEGIN
    -- Get aggregation metric for this question (take first if multiple)
    SELECT DISTINCT
        sroa.agg_metric_id,
        sroa.calculation_type_id,
        sroa.period_type,
        sroa.lookback_days,
        sroa.min_data_points
    INTO v_agg_metric_id, v_calc_type, v_period_type, v_lookback_days, v_min_data_points
    FROM survey_response_options_aggregations sroa
    WHERE sroa.question_number = p_question_number
        AND sroa.is_active = true
    LIMIT 1;

    -- If no tracking mapping exists, use survey response
    IF v_agg_metric_id IS NULL THEN
        RETURN QUERY
        SELECT
            psr.response_option_id,
            sro.score,
            'survey'::TEXT,
            NULL::NUMERIC,
            NULL::INT,
            NULL::TEXT
        FROM patient_survey_responses psr
        JOIN survey_response_options sro ON psr.response_option_id = sro.option_id
        WHERE psr.user_id = p_user_id
            AND sro.question_number = p_question_number
        LIMIT 1;
        RETURN;
    END IF;

    -- Calculate tracking average from aggregation_results_cache
    SELECT
        CASE
            WHEN v_calc_type = 'AVG' THEN AVG(arc.value)
            WHEN v_calc_type = 'SUM' THEN SUM(arc.value)
            WHEN v_calc_type = 'MAX' THEN MAX(arc.value)
            WHEN v_calc_type = 'MIN' THEN MIN(arc.value)
            ELSE AVG(arc.value)
        END as calculated_value,
        COUNT(*) as data_points
    INTO v_tracking_avg, v_data_point_count
    FROM aggregation_results_cache arc
    WHERE arc.user_id = p_user_id
        AND arc.agg_metric_id = v_agg_metric_id
        AND arc.calculation_type_id = v_calc_type
        AND arc.period_type = v_period_type
        AND arc.period_start >= (CURRENT_DATE - v_lookback_days);

    -- Check if we have enough data
    IF v_data_point_count IS NULL OR v_data_point_count < v_min_data_points THEN
        -- Not enough tracking data, use survey response
        RETURN QUERY
        SELECT
            psr.response_option_id,
            sro.score,
            'survey'::TEXT,
            v_tracking_avg,
            v_data_point_count,
            v_agg_metric_id
        FROM patient_survey_responses psr
        JOIN survey_response_options sro ON psr.response_option_id = sro.option_id
        WHERE psr.user_id = p_user_id
            AND sro.question_number = p_question_number
        LIMIT 1;
        RETURN;
    END IF;

    -- Find matching response option based on tracking average
    RETURN QUERY
    SELECT
        sroa.response_option_id,
        sro.score,
        'tracking'::TEXT,
        v_tracking_avg,
        v_data_point_count,
        v_agg_metric_id
    FROM survey_response_options_aggregations sroa
    JOIN survey_response_options sro ON sroa.response_option_id = sro.option_id
    WHERE sroa.question_number = p_question_number
        AND v_tracking_avg >= sroa.threshold_low
        AND v_tracking_avg <= sroa.threshold_high
        AND sroa.is_active = true
    ORDER BY sroa.threshold_low DESC
    LIMIT 1;

    -- If no matching range found, use survey response as fallback
    IF NOT FOUND THEN
        RETURN QUERY
        SELECT
            psr.response_option_id,
            sro.score,
            'survey'::TEXT,
            v_tracking_avg,
            v_data_point_count,
            v_agg_metric_id
        FROM patient_survey_responses psr
        JOIN survey_response_options sro ON psr.response_option_id = sro.option_id
        WHERE psr.user_id = p_user_id
            AND sro.question_number = p_question_number
        LIMIT 1;
    END IF;

END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION calculate_effective_response IS
'Calculates the effective response for a patient-question pair. Returns tracking-based response if sufficient data exists, otherwise returns survey response.';


-- =====================================================
-- FUNCTION 2: Calculate Effective Function Score
-- =====================================================

CREATE OR REPLACE FUNCTION calculate_effective_function_score(
    p_user_id UUID,
    p_function_name TEXT
) RETURNS TABLE (
    effective_score NUMERIC,
    score_source TEXT,
    contributing_metrics JSONB,
    data_quality JSONB
) AS $$
DECLARE
    v_total_weight NUMERIC := 0;
    v_weighted_score NUMERIC := 0;
    v_metric_data JSONB := '[]'::JSONB;
    v_quality_data JSONB := '[]'::JSONB;
    v_has_tracking_data BOOLEAN := false;
    v_original_score NUMERIC;
    metric_record RECORD;
BEGIN
    -- Get original function score from patient score items
    SELECT normalized_score INTO v_original_score
    FROM patient_wellpath_score_items
    WHERE user_id = p_user_id
        AND function_name = p_function_name
        AND item_type = 'survey_function'
    ORDER BY scored_at DESC
    LIMIT 1;

    -- Loop through each aggregation metric mapped to this function
    FOR metric_record IN
        SELECT
            fam.agg_metric_id,
            fam.weight_in_function,
            fam.calculation_type_id,
            fam.period_type,
            fam.lookback_days,
            fam.min_data_points,
            fam.threshold_ranges
        FROM function_aggregation_mappings fam
        WHERE fam.function_name = p_function_name
            AND fam.is_active = true
    LOOP
        DECLARE
            v_metric_avg NUMERIC;
            v_data_points INT;
            v_metric_score NUMERIC := 0;
        BEGIN
            -- Calculate metric value from aggregation cache
            SELECT
                AVG(arc.value),
                COUNT(*)
            INTO v_metric_avg, v_data_points
            FROM aggregation_results_cache arc
            WHERE arc.user_id = p_user_id
                AND arc.agg_metric_id = metric_record.agg_metric_id
                AND arc.calculation_type_id = metric_record.calculation_type_id
                AND arc.period_type = metric_record.period_type
                AND arc.period_start >= (CURRENT_DATE - metric_record.lookback_days);

            -- If sufficient data, calculate score from threshold ranges
            IF v_data_points >= metric_record.min_data_points THEN
                v_has_tracking_data := true;

                -- Find matching threshold range and get score
                SELECT
                    (range_obj->>'score')::NUMERIC INTO v_metric_score
                FROM jsonb_array_elements(metric_record.threshold_ranges) range_obj
                WHERE v_metric_avg >= (range_obj->>'min')::NUMERIC
                    AND v_metric_avg <= (range_obj->>'max')::NUMERIC
                ORDER BY (range_obj->>'min')::NUMERIC DESC
                LIMIT 1;

                -- Apply weight and add to total
                IF v_metric_score IS NOT NULL THEN
                    v_weighted_score := v_weighted_score + (v_metric_score * metric_record.weight_in_function);
                    v_total_weight := v_total_weight + metric_record.weight_in_function;
                END IF;

                -- Store metric data
                v_metric_data := v_metric_data || jsonb_build_object(
                    'metric_id', metric_record.agg_metric_id,
                    'value', v_metric_avg,
                    'score', v_metric_score,
                    'weight', metric_record.weight_in_function,
                    'data_points', v_data_points
                );

                v_quality_data := v_quality_data || jsonb_build_object(
                    'metric_id', metric_record.agg_metric_id,
                    'data_points', v_data_points,
                    'sufficient', true
                );
            ELSE
                -- Not enough data for this metric
                v_quality_data := v_quality_data || jsonb_build_object(
                    'metric_id', metric_record.agg_metric_id,
                    'data_points', COALESCE(v_data_points, 0),
                    'sufficient', false
                );
            END IF;
        END;
    END LOOP;

    -- Return results
    IF v_has_tracking_data AND v_total_weight > 0 THEN
        -- Use tracking-based score
        RETURN QUERY SELECT
            (v_weighted_score / v_total_weight)::NUMERIC,
            'tracking'::TEXT,
            v_metric_data,
            v_quality_data;
    ELSE
        -- Use original survey-based score
        RETURN QUERY SELECT
            v_original_score,
            'survey'::TEXT,
            v_metric_data,
            v_quality_data;
    END IF;

END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION calculate_effective_function_score IS
'Calculates the effective score for a survey function based on tracked metrics. Returns weighted average of metric scores if sufficient data exists, otherwise returns original survey score.';


-- =====================================================
-- FUNCTION 3: Refresh Patient Effective Responses
-- =====================================================

CREATE OR REPLACE FUNCTION refresh_patient_effective_responses(
    p_user_id UUID,
    p_question_numbers NUMERIC[] DEFAULT NULL
) RETURNS INT AS $$
DECLARE
    v_updated_count INT := 0;
    question_num NUMERIC;
    eff_response RECORD;
BEGIN
    -- If no specific questions provided, update all mapped questions for this user
    IF p_question_numbers IS NULL THEN
        SELECT ARRAY_AGG(DISTINCT question_number) INTO p_question_numbers
        FROM survey_response_options_aggregations
        WHERE is_active = true;
    END IF;

    -- Loop through each question
    FOREACH question_num IN ARRAY p_question_numbers
    LOOP
        -- Calculate effective response
        SELECT * INTO eff_response
        FROM calculate_effective_response(p_user_id, question_num);

        IF eff_response IS NOT NULL THEN
            -- Upsert to patient_effective_responses
            INSERT INTO patient_effective_responses (
                user_id,
                question_number,
                effective_response_option_id,
                effective_score,
                response_source,
                tracking_agg_metric_id,
                tracking_avg_value,
                tracking_data_points,
                last_updated_at,
                created_at
            ) VALUES (
                p_user_id,
                question_num,
                eff_response.effective_response_option_id,
                eff_response.effective_score,
                eff_response.response_source,
                eff_response.agg_metric_used,
                eff_response.tracking_value,
                eff_response.data_points,
                NOW(),
                NOW()
            )
            ON CONFLICT (user_id, question_number)
            DO UPDATE SET
                effective_response_option_id = EXCLUDED.effective_response_option_id,
                effective_score = EXCLUDED.effective_score,
                response_source = EXCLUDED.response_source,
                tracking_agg_metric_id = EXCLUDED.tracking_agg_metric_id,
                tracking_avg_value = EXCLUDED.tracking_avg_value,
                tracking_data_points = EXCLUDED.tracking_data_points,
                last_updated_at = NOW();

            v_updated_count := v_updated_count + 1;
        END IF;
    END LOOP;

    RETURN v_updated_count;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION refresh_patient_effective_responses IS
'Refreshes effective responses for a patient. Can update all questions or specific questions provided in array.';


-- =====================================================
-- FUNCTION 4: Refresh Patient Effective Function Scores
-- =====================================================

CREATE OR REPLACE FUNCTION refresh_patient_effective_function_scores(
    p_user_id UUID,
    p_function_names TEXT[] DEFAULT NULL
) RETURNS INT AS $$
DECLARE
    v_updated_count INT := 0;
    func_name TEXT;
    func_score RECORD;
    v_original_score NUMERIC;
BEGIN
    -- If no specific functions provided, update all mapped functions for this user
    IF p_function_names IS NULL THEN
        SELECT ARRAY_AGG(DISTINCT function_name) INTO p_function_names
        FROM function_aggregation_mappings
        WHERE is_active = true;
    END IF;

    -- Loop through each function
    FOREACH func_name IN ARRAY p_function_names
    LOOP
        -- Get original score from patient's score items
        SELECT normalized_score INTO v_original_score
        FROM patient_wellpath_score_items
        WHERE user_id = p_user_id
            AND function_name = func_name
            AND item_type = 'survey_function'
        ORDER BY scored_at DESC
        LIMIT 1;

        -- Skip if user hasn't taken this function's survey
        CONTINUE WHEN v_original_score IS NULL;

        -- Calculate effective function score
        SELECT * INTO func_score
        FROM calculate_effective_function_score(p_user_id, func_name);

        IF func_score IS NOT NULL THEN
            -- Upsert to patient_effective_function_scores
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
                p_user_id,
                func_name,
                v_original_score,
                func_score.effective_score,
                func_score.score_source,
                func_score.contributing_metrics,
                func_score.data_quality,
                NOW(),
                NOW()
            )
            ON CONFLICT (user_id, function_name)
            DO UPDATE SET
                original_score = EXCLUDED.original_score,
                effective_score = EXCLUDED.effective_score,
                score_source = EXCLUDED.score_source,
                contributing_metrics = EXCLUDED.contributing_metrics,
                data_quality = EXCLUDED.data_quality,
                last_calculated_at = NOW();

            v_updated_count := v_updated_count + 1;
        END IF;
    END LOOP;

    RETURN v_updated_count;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION refresh_patient_effective_function_scores IS
'Refreshes effective function scores for a patient. Can update all functions or specific functions provided in array.';


-- =====================================================
-- Summary
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE '✅ Dynamic Scoring Functions Created';
    RAISE NOTICE '';
    RAISE NOTICE 'Functions:';
    RAISE NOTICE '  calculate_effective_response(user_id, question_number)';
    RAISE NOTICE '  calculate_effective_function_score(user_id, function_name)';
    RAISE NOTICE '  refresh_patient_effective_responses(user_id, [question_numbers])';
    RAISE NOTICE '  refresh_patient_effective_function_scores(user_id, [function_names])';
    RAISE NOTICE '';
    RAISE NOTICE 'Next Steps:';
    RAISE NOTICE '  1. Create triggers for automatic updates';
    RAISE NOTICE '  2. Create views for easy score access';
    RAISE NOTICE '  3. Test with patient data';
END $$;

COMMIT;
