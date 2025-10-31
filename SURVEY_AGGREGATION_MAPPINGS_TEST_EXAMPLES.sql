-- ============================================================================
-- Survey Response Options to Aggregation Metrics - Test Examples
-- ============================================================================
-- This file contains practical examples and test queries for using the
-- survey response options to aggregation metrics mappings.
--
-- Use these examples to understand how to:
-- 1. Check if tracked data matches survey responses
-- 2. Find which response option matches tracked data
-- 3. Detect discrepancies between surveys and actual behavior
-- 4. Update scores based on tracking data
-- ============================================================================

-- ============================================================================
-- EXAMPLE 1: Check if tracked fruit servings match survey response
-- ============================================================================
-- Scenario: Patient answered "1-2 servings" but we want to verify against
-- their actual tracked data over the last 30 days.

-- Simulated tracked data: 3.5 servings per day average
WITH tracked_data AS (
    SELECT 3.5 as avg_fruit_servings
)
SELECT
    sq.question_text,
    sro.option_text as survey_answer,
    sroa.threshold_low,
    sroa.threshold_high,
    td.avg_fruit_servings as tracked_average,
    CASE
        WHEN td.avg_fruit_servings BETWEEN sroa.threshold_low AND sroa.threshold_high
        THEN 'MATCH ✓'
        ELSE 'MISMATCH ✗'
    END as status,
    CASE
        WHEN td.avg_fruit_servings > sroa.threshold_high THEN 'Tracked data higher than survey'
        WHEN td.avg_fruit_servings < sroa.threshold_low THEN 'Tracked data lower than survey'
        ELSE 'Aligned'
    END as recommendation
FROM tracked_data td
CROSS JOIN survey_response_options_aggregations sroa
JOIN survey_response_options sro ON sro.option_id = sroa.response_option_id
JOIN survey_questions_base sq ON sq.question_number = sroa.question_number
WHERE sroa.question_number = 2.19
  AND sroa.agg_metric_id = 'AGG_FRUIT_SERVINGS'
  AND sroa.response_option_id = 'RO_2.19-2'  -- Patient's current survey answer
ORDER BY sroa.threshold_low;

-- Expected output:
-- The patient answered "1-2 servings" (threshold 1.0-2.9)
-- But their tracked average is 3.5 servings
-- Result: MISMATCH - suggest updating to "3-4 servings"


-- ============================================================================
-- EXAMPLE 2: Find the correct response option for tracked data
-- ============================================================================
-- Scenario: Patient has been tracking cardio sessions. We want to find which
-- survey response option matches their actual behavior.

-- Simulated tracked data: 2.1 cardio sessions per week average
WITH tracked_data AS (
    SELECT 2.1 as avg_weekly_sessions
)
SELECT
    sro.option_text,
    sroa.threshold_low || ' - ' || sroa.threshold_high as threshold_range,
    td.avg_weekly_sessions as tracked_sessions,
    CASE
        WHEN td.avg_weekly_sessions BETWEEN sroa.threshold_low AND sroa.threshold_high
        THEN 'THIS IS THE MATCH ✓'
        ELSE ''
    END as match_status
FROM tracked_data td
CROSS JOIN survey_response_options_aggregations sroa
JOIN survey_response_options sro ON sro.option_id = sroa.response_option_id
WHERE sroa.question_number = 3.04  -- Cardio frequency
  AND sroa.agg_metric_id = 'AGG_CARDIO_SESSION_COUNT'
ORDER BY sroa.threshold_low;

-- Expected output:
-- 2.1 sessions/week matches "Occasionally (1-2 times per week)"
-- Threshold: 1.0 - 2.9


-- ============================================================================
-- EXAMPLE 3: Check sleep duration alignment with data quality requirements
-- ============================================================================
-- Scenario: Verify patient has sufficient sleep tracking data to reliably
-- compare against their survey response.

-- This query would check actual patient_healthkit_events table
-- For testing, we simulate the check
WITH data_quality_check AS (
    SELECT
        25 as days_with_sleep_data,  -- Simulated: patient has 25 days of data
        7.2 as avg_sleep_hours        -- Simulated: averaging 7.2 hours
)
SELECT
    sroa.min_data_points as required_data_points,
    sroa.lookback_days,
    dq.days_with_sleep_data,
    CASE
        WHEN dq.days_with_sleep_data >= sroa.min_data_points
        THEN 'Sufficient data ✓'
        ELSE 'Need ' || (sroa.min_data_points - dq.days_with_sleep_data) || ' more days'
    END as data_quality,
    dq.avg_sleep_hours * 60 as avg_sleep_minutes,
    sroa.threshold_low || ' - ' || sroa.threshold_high as threshold_minutes,
    sro.option_text as matching_response
FROM data_quality_check dq
CROSS JOIN survey_response_options_aggregations sroa
JOIN survey_response_options sro ON sro.option_id = sroa.response_option_id
WHERE sroa.question_number = 4.02  -- Sleep duration
  AND sroa.agg_metric_id = 'AGG_SLEEP_DURATION'
  AND (dq.avg_sleep_hours * 60) BETWEEN sroa.threshold_low AND sroa.threshold_high
LIMIT 1;

-- Expected output:
-- 25 days of data meets requirement of 20 days ✓
-- 7.2 hours = 432 minutes
-- Matches "7 hours" response (threshold 390-450 minutes)


-- ============================================================================
-- EXAMPLE 4: Multi-metric check (Fruit servings + variety)
-- ============================================================================
-- Scenario: For Q2.19, check both servings AND variety to get complete picture

-- Simulated tracked data
WITH tracked_data AS (
    SELECT
        3.5 as avg_servings_per_day,
        4 as unique_fruit_types  -- COUNT DISTINCT of fruit types consumed
)
SELECT
    sroa.agg_metric_id as metric,
    sroa.calculation_type_id as calculation,
    sro.option_text,
    sroa.threshold_low || ' - ' || sroa.threshold_high as threshold,
    CASE sroa.agg_metric_id
        WHEN 'AGG_FRUIT_SERVINGS' THEN td.avg_servings_per_day::text
        WHEN 'AGG_FRUIT_VARIETY' THEN td.unique_fruit_types::text
    END as tracked_value,
    CASE
        WHEN sroa.agg_metric_id = 'AGG_FRUIT_SERVINGS'
             AND td.avg_servings_per_day BETWEEN sroa.threshold_low AND sroa.threshold_high
        THEN 'MATCH ✓'
        WHEN sroa.agg_metric_id = 'AGG_FRUIT_VARIETY'
             AND td.unique_fruit_types BETWEEN sroa.threshold_low AND sroa.threshold_high
        THEN 'MATCH ✓'
        ELSE 'No match'
    END as status
FROM tracked_data td
CROSS JOIN survey_response_options_aggregations sroa
JOIN survey_response_options sro ON sro.option_id = sroa.response_option_id
WHERE sroa.question_number = 2.19
  AND sroa.agg_metric_id IN ('AGG_FRUIT_SERVINGS', 'AGG_FRUIT_VARIETY')
ORDER BY sroa.agg_metric_id, sroa.threshold_low;

-- Expected output:
-- AGG_FRUIT_SERVINGS: 3.5 matches "3-4" option (threshold 3.0-4.9) ✓
-- AGG_FRUIT_VARIETY: 4 types matches "3-4" option (threshold 3-5) ✓
-- Both metrics align with same response option = high confidence


-- ============================================================================
-- EXAMPLE 5: Detect all mismatches for a patient
-- ============================================================================
-- Scenario: Generate a report of all survey questions where tracked data
-- doesn't match the patient's survey responses

-- This would use actual patient data in production
-- For testing, we simulate with sample data
WITH patient_tracking_data AS (
    SELECT 2.19 as question_number, 'AGG_FRUIT_SERVINGS' as metric_id, 3.5 as tracked_value
    UNION ALL
    SELECT 3.04, 'AGG_CARDIO_SESSION_COUNT', 2.1
    UNION ALL
    SELECT 4.02, 'AGG_SLEEP_DURATION', 380  -- 6.33 hours = 380 minutes
    UNION ALL
    SELECT 8.05, 'AGG_ALCOHOLIC_DRINKS', 3.2
),
patient_survey_responses AS (
    -- Simulated: Patient's actual survey responses
    SELECT 2.19 as question_number, 'RO_2.19-2' as response_option_id  -- Said "1-2" servings
    UNION ALL
    SELECT 3.04, 'RO_3.04-3'  -- Said "Regularly (3-4x/week)"
    UNION ALL
    SELECT 4.02, 'RO_4.02-4'  -- Said "7 hours"
    UNION ALL
    SELECT 8.05, 'RO_8.05-2'  -- Said "Moderate (2-4 drinks/day)"
)
SELECT
    sq.question_text,
    sro_current.option_text as current_survey_answer,
    ptd.tracked_value,
    sro_current.option_text as should_be,
    CASE
        WHEN ptd.tracked_value BETWEEN sroa.threshold_low AND sroa.threshold_high
        THEN 'ALIGNED ✓'
        ELSE 'MISMATCH ✗'
    END as status,
    CASE
        WHEN ptd.tracked_value > sroa.threshold_high
        THEN 'Upgrade response - performing better than indicated'
        WHEN ptd.tracked_value < sroa.threshold_low
        THEN 'Downgrade response - not meeting stated behavior'
        ELSE NULL
    END as recommendation
FROM patient_tracking_data ptd
JOIN patient_survey_responses psr ON psr.question_number = ptd.question_number
JOIN survey_response_options_aggregations sroa
    ON sroa.response_option_id = psr.response_option_id
    AND sroa.agg_metric_id = ptd.metric_id
JOIN survey_response_options sro_current
    ON sro_current.option_id = psr.response_option_id
JOIN survey_questions_base sq
    ON sq.question_number = ptd.question_number
ORDER BY ptd.question_number;

-- Expected mismatches:
-- Q2.19: Said "1-2" but tracking 3.5 → Upgrade to "3-4"
-- Q3.04: Said "3-4x/week" but only 2.1 sessions → Downgrade to "1-2x/week"
-- Q4.02: Said "7 hours" but only 380 min (6.3 hrs) → Downgrade to "6 hours"
-- Q8.05: Said "2-4 drinks" and tracking 3.2 → ALIGNED ✓


-- ============================================================================
-- EXAMPLE 6: Find recommended response option for tracked value
-- ============================================================================
-- This function-style query finds the correct response option
-- given a question and a tracked metric value

-- Function to find matching response option
CREATE OR REPLACE FUNCTION find_matching_response_option(
    p_question_number NUMERIC,
    p_metric_id TEXT,
    p_tracked_value NUMERIC
)
RETURNS TABLE (
    response_option_id TEXT,
    option_text TEXT,
    threshold_low NUMERIC,
    threshold_high NUMERIC,
    confidence TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        sroa.response_option_id,
        sro.option_text,
        sroa.threshold_low,
        sroa.threshold_high,
        CASE
            WHEN p_tracked_value BETWEEN sroa.threshold_low AND sroa.threshold_high
            THEN 'EXACT MATCH'
            WHEN p_tracked_value BETWEEN (sroa.threshold_low - 0.5) AND (sroa.threshold_high + 0.5)
            THEN 'CLOSE MATCH'
            ELSE 'NO MATCH'
        END as confidence
    FROM survey_response_options_aggregations sroa
    JOIN survey_response_options sro ON sro.option_id = sroa.response_option_id
    WHERE sroa.question_number = p_question_number
      AND sroa.agg_metric_id = p_metric_id
      AND p_tracked_value BETWEEN sroa.threshold_low AND sroa.threshold_high
    ORDER BY sroa.threshold_low
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- Test the function
SELECT * FROM find_matching_response_option(2.19, 'AGG_FRUIT_SERVINGS', 3.5);
-- Expected: RO_2.19-3, "3-4", 3.0, 4.9, EXACT MATCH

SELECT * FROM find_matching_response_option(3.21, 'AGG_STEPS', 8200);
-- Expected: RO_3.21-4, "7,500-10,000", 7500, 9999, EXACT MATCH


-- ============================================================================
-- EXAMPLE 7: Batch update recommendations
-- ============================================================================
-- Generate a report of ALL questions where a patient's tracking suggests
-- a different response than their survey answer

CREATE OR REPLACE FUNCTION generate_survey_update_recommendations(
    p_patient_id TEXT
)
RETURNS TABLE (
    question_number NUMERIC,
    question_text TEXT,
    current_response TEXT,
    recommended_response TEXT,
    tracked_value NUMERIC,
    confidence_level TEXT,
    data_quality TEXT
) AS $$
BEGIN
    RETURN QUERY
    WITH aggregated_tracking AS (
        -- This would aggregate actual patient tracking data
        -- Placeholder for the actual aggregation logic
        SELECT
            2.19 as question_num,
            'AGG_FRUIT_SERVINGS' as metric_id,
            3.5 as agg_value,
            25 as data_points
        -- Add more tracked metrics here
    )
    SELECT
        sroa.question_number,
        sq.question_text,
        sro_current.option_text as current_response,
        sro_recommended.option_text as recommended_response,
        at.agg_value as tracked_value,
        CASE
            WHEN at.agg_value BETWEEN sroa_rec.threshold_low AND sroa_rec.threshold_high
            THEN 'HIGH'
            ELSE 'MEDIUM'
        END as confidence_level,
        CASE
            WHEN at.data_points >= sroa.min_data_points
            THEN 'Sufficient (' || at.data_points || '/' || sroa.min_data_points || ')'
            ELSE 'Insufficient (' || at.data_points || '/' || sroa.min_data_points || ')'
        END as data_quality
    FROM aggregated_tracking at
    -- Join to find current response
    JOIN survey_response_options_aggregations sroa
        ON sroa.agg_metric_id = at.metric_id
    JOIN survey_response_options sro_current
        ON sro_current.option_id = sroa.response_option_id
    -- Join to find recommended response based on tracking
    JOIN survey_response_options_aggregations sroa_rec
        ON sroa_rec.question_number = at.question_num
        AND sroa_rec.agg_metric_id = at.metric_id
        AND at.agg_value BETWEEN sroa_rec.threshold_low AND sroa_rec.threshold_high
    JOIN survey_response_options sro_recommended
        ON sro_recommended.option_id = sroa_rec.response_option_id
    JOIN survey_questions_base sq
        ON sq.question_number = at.question_num
    -- Only show where recommendation differs from current
    WHERE sro_current.option_id != sro_recommended.option_id;
END;
$$ LANGUAGE plpgsql;


-- ============================================================================
-- EXAMPLE 8: Validation queries
-- ============================================================================

-- Check for gaps in threshold coverage (should be none)
WITH threshold_gaps AS (
    SELECT
        question_number,
        agg_metric_id,
        threshold_high,
        LEAD(threshold_low) OVER (
            PARTITION BY question_number, agg_metric_id
            ORDER BY threshold_low
        ) as next_threshold_low,
        LEAD(threshold_low) OVER (
            PARTITION BY question_number, agg_metric_id
            ORDER BY threshold_low
        ) - threshold_high as gap
    FROM survey_response_options_aggregations
)
SELECT
    question_number,
    agg_metric_id,
    threshold_high as current_high,
    next_threshold_low,
    gap
FROM threshold_gaps
WHERE gap > 0.1  -- Small tolerance for rounding
ORDER BY question_number, agg_metric_id;
-- Expected: No rows (no gaps in coverage)


-- Check for overlapping thresholds (should be intentional only)
WITH threshold_overlaps AS (
    SELECT
        a.question_number,
        a.agg_metric_id,
        a.response_option_id as option_a,
        b.response_option_id as option_b,
        a.threshold_low as a_low,
        a.threshold_high as a_high,
        b.threshold_low as b_low,
        b.threshold_high as b_high
    FROM survey_response_options_aggregations a
    JOIN survey_response_options_aggregations b
        ON a.question_number = b.question_number
        AND a.agg_metric_id = b.agg_metric_id
        AND a.response_option_id < b.response_option_id
    WHERE a.threshold_high > b.threshold_low
      AND a.threshold_low < b.threshold_high
)
SELECT * FROM threshold_overlaps;
-- Expected: Only intentional overlaps (like 4.02 sleep with ±30 min buffers)


-- Verify all response options for key questions are mapped
SELECT
    sq.question_number,
    sq.question_text,
    COUNT(DISTINCT sro.option_id) as total_options,
    COUNT(DISTINCT sroa.response_option_id) as mapped_options,
    COUNT(DISTINCT sro.option_id) - COUNT(DISTINCT sroa.response_option_id) as unmapped_count
FROM survey_questions_base sq
JOIN survey_response_options sro
    ON sro.question_number = sq.question_number
LEFT JOIN survey_response_options_aggregations sroa
    ON sroa.response_option_id = sro.option_id
WHERE sq.question_number IN (2.19, 3.04, 4.02, 8.05)  -- Key validation questions
GROUP BY sq.question_number, sq.question_text
ORDER BY sq.question_number;
-- Expected: All options mapped (unmapped_count = 0 or close)


-- ============================================================================
-- EXAMPLE 9: Score update trigger simulation
-- ============================================================================
-- This shows how to automatically update scores when tracking data
-- changes enough to warrant a different survey response

CREATE OR REPLACE FUNCTION check_and_update_survey_from_tracking()
RETURNS TRIGGER AS $$
DECLARE
    v_question_number NUMERIC;
    v_agg_metric_id TEXT;
    v_aggregated_value NUMERIC;
    v_new_response_option TEXT;
    v_current_response_option TEXT;
BEGIN
    -- This trigger would fire when aggregation_results are updated
    -- Find which survey question this metric relates to
    SELECT DISTINCT question_number, agg_metric_id
    INTO v_question_number, v_agg_metric_id
    FROM survey_response_options_aggregations
    WHERE agg_metric_id = NEW.agg_metric_id
    LIMIT 1;

    IF v_question_number IS NOT NULL THEN
        -- Get the aggregated value (would come from actual aggregation)
        v_aggregated_value := NEW.aggregated_value;

        -- Find which response option matches this aggregated value
        SELECT response_option_id
        INTO v_new_response_option
        FROM survey_response_options_aggregations
        WHERE question_number = v_question_number
          AND agg_metric_id = v_agg_metric_id
          AND v_aggregated_value BETWEEN threshold_low AND threshold_high
        LIMIT 1;

        -- Get patient's current response for this question
        -- (would query patient_survey_responses table)
        -- v_current_response_option := ...

        -- If different, log or update
        IF v_new_response_option IS NOT NULL
           AND v_new_response_option != v_current_response_option THEN
            -- Log the discrepancy or auto-update
            RAISE NOTICE 'Survey update needed: Q% current:% suggested:%',
                v_question_number, v_current_response_option, v_new_response_option;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- This trigger would be created on aggregation results table:
-- CREATE TRIGGER check_survey_alignment
--     AFTER INSERT OR UPDATE ON aggregation_results_cache
--     FOR EACH ROW
--     EXECUTE FUNCTION check_and_update_survey_from_tracking();


-- ============================================================================
-- EXAMPLE 10: Dashboard query - Patient alignment score
-- ============================================================================
-- Calculate what percentage of a patient's survey responses align
-- with their actual tracking data

WITH alignment_check AS (
    SELECT
        ptd.question_number,
        ptd.metric_id,
        ptd.tracked_value,
        sroa.response_option_id,
        CASE
            WHEN ptd.tracked_value BETWEEN sroa.threshold_low AND sroa.threshold_high
            THEN 1
            ELSE 0
        END as is_aligned
    FROM (
        -- Simulated patient tracking data
        SELECT 2.19 as question_number, 'AGG_FRUIT_SERVINGS' as metric_id, 3.5 as tracked_value
        UNION ALL SELECT 3.04, 'AGG_CARDIO_SESSION_COUNT', 2.1
        UNION ALL SELECT 4.02, 'AGG_SLEEP_DURATION', 380
        UNION ALL SELECT 8.05, 'AGG_ALCOHOLIC_DRINKS', 3.2
    ) ptd
    JOIN (
        -- Simulated patient survey responses
        SELECT 2.19 as question_number, 'RO_2.19-2' as response_option_id
        UNION ALL SELECT 3.04, 'RO_3.04-3'
        UNION ALL SELECT 4.02, 'RO_4.02-4'
        UNION ALL SELECT 8.05, 'RO_8.05-2'
    ) psr ON psr.question_number = ptd.question_number
    JOIN survey_response_options_aggregations sroa
        ON sroa.response_option_id = psr.response_option_id
        AND sroa.agg_metric_id = ptd.metric_id
)
SELECT
    COUNT(*) as total_questions_checked,
    SUM(is_aligned) as aligned_count,
    COUNT(*) - SUM(is_aligned) as misaligned_count,
    ROUND(100.0 * SUM(is_aligned) / COUNT(*), 1) || '%' as alignment_percentage,
    CASE
        WHEN ROUND(100.0 * SUM(is_aligned) / COUNT(*), 1) >= 80 THEN 'Excellent alignment ✓'
        WHEN ROUND(100.0 * SUM(is_aligned) / COUNT(*), 1) >= 60 THEN 'Good alignment'
        WHEN ROUND(100.0 * SUM(is_aligned) / COUNT(*), 1) >= 40 THEN 'Moderate alignment'
        ELSE 'Poor alignment - needs survey review'
    END as assessment
FROM alignment_check;

-- Expected for our test data:
-- 1 aligned (alcohol), 3 misaligned = 25% alignment
-- Assessment: "Poor alignment - needs survey review"

-- ============================================================================
-- END OF TEST EXAMPLES
-- ============================================================================
