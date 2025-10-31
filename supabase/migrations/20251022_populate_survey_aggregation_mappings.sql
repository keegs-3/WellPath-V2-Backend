-- =====================================================
-- Survey Response Options → Aggregation Metrics Mappings
-- =====================================================
-- Auto-generated mappings for dynamic score updating
--
-- Created: 2025-10-22
-- =====================================================

BEGIN;

INSERT INTO survey_response_options_aggregations (
    id,
    response_option_id,
    question_number,
    agg_metric_id,
    threshold_low,
    threshold_high,
    calculation_type_id,
    period_type,
    min_data_points,
    lookback_days,
    notes
) VALUES
(
    '14780ff2-f877-421d-8c70-f5d50df4150f',
    'RO_2.19-1',
    2.19,
    'AGG_FRUIT_SERVINGS',
    0.0,
    0.9,
    'AVG',
    'monthly',
    20,
    30,
    'Auto-mapped from response option: 0 range 0.0 to 0.9'
),
(
    'eb9267c9-969a-4726-9731-39f885f76c4c',
    'RO_2.19-2',
    2.19,
    'AGG_FRUIT_SERVINGS',
    1.0,
    2.9,
    'AVG',
    'monthly',
    20,
    30,
    'Auto-mapped from response option: 1-2 range 1.0 to 2.9'
),
(
    'fd701cb9-2b3e-449d-8c35-d52e38239cd3',
    'RO_2.19-3',
    2.19,
    'AGG_FRUIT_SERVINGS',
    3.0,
    4.9,
    'AVG',
    'monthly',
    20,
    30,
    'Auto-mapped from response option: 3-4 range 3.0 to 4.9'
),
(
    '4f020386-a465-4fa4-b998-50e9bb77b29c',
    'RO_2.19-4',
    2.19,
    'AGG_FRUIT_SERVINGS',
    5.0,
    999.0,
    'AVG',
    'monthly',
    20,
    30,
    'Auto-mapped from response option: 5 or more range 5.0 to 999.0'
),
(
    '609c2775-be11-4811-9708-e9605f75eed9',
    'RO_2.21-1',
    2.21,
    'AGG_WHOLE_GRAIN_SERVINGS',
    0,
    0,
    'AVG',
    'monthly',
    20,
    30,
    'Auto-mapped from response option: Rarely or never range 0 to 0'
),
(
    '5905d08a-deac-4f88-bc8c-f0d7bdacb321',
    'RO_2.21-4',
    2.21,
    'AGG_WHOLE_GRAIN_SERVINGS',
    7,
    7,
    'AVG',
    'monthly',
    20,
    30,
    'Auto-mapped from response option: Daily range 7 to 7'
),
(
    'ecc128e3-9e48-4d42-b5a1-1abeb83ab5f7',
    'RO_2.23-1',
    2.23,
    'AGG_LEGUME_SERVINGS',
    0,
    0,
    'AVG',
    'monthly',
    20,
    30,
    'Auto-mapped from response option: Rarely or never range 0 to 0'
),
(
    '73443268-9e7a-416f-b73a-80d336878da8',
    'RO_2.23-4',
    2.23,
    'AGG_LEGUME_SERVINGS',
    7,
    7,
    'AVG',
    'monthly',
    20,
    30,
    'Auto-mapped from response option: Daily range 7 to 7'
),
(
    '6b2132ef-21e3-497a-b2bb-caa612971bbc',
    'RO_2.25-1',
    2.25,
    'AGG_SEED_SERVINGS',
    0,
    0,
    'AVG',
    'monthly',
    15,
    30,
    'Auto-mapped from response option: Rarely or never range 0 to 0'
),
(
    'dee51372-4a41-4710-b3de-5f87b3b50a1e',
    'RO_2.25-4',
    2.25,
    'AGG_SEED_SERVINGS',
    7,
    7,
    'AVG',
    'monthly',
    15,
    30,
    'Auto-mapped from response option: Daily range 7 to 7'
),
(
    '5b820325-bf51-4029-9a52-e26990a0b871',
    'RO_2.29-2',
    2.29,
    'AGG_WATER_CONSUMPTION',
    1.0,
    2.9,
    'AVG',
    'monthly',
    20,
    30,
    'Auto-mapped from response option: 1-2 liters (34-68 oz) range 1.0 to 2.9'
),
(
    'c4c12ac4-3815-4f41-b88f-70f0aa3a6664',
    'RO_3.01-1',
    3.01,
    'AGG_CARDIO_SESSION_COUNT',
    0,
    0,
    'SUM',
    'weekly',
    3,
    30,
    'Auto-mapped from response option: Rarely or Never range 0 to 0'
),
(
    'c28d33ac-ef43-498a-9fce-8bfadbbfcc87',
    'RO_3.01-4',
    3.01,
    'AGG_CARDIO_SESSION_COUNT',
    5.0,
    999.0,
    'SUM',
    'weekly',
    3,
    30,
    'Auto-mapped from response option: Frequently (5 or more times per week) range 5.0 to 999.0'
),
(
    'c0247ceb-a8bb-437f-9f2f-ac14726d8272',
    'RO_3.05-4',
    3.05,
    'AGG_STRENGTH_SESSION_COUNT',
    5.0,
    999.0,
    'SUM',
    'weekly',
    3,
    30,
    'Auto-mapped from response option: Frequently (5 or more times per week) range 5.0 to 999.0'
);


-- =====================================================
-- Summary
-- =====================================================

DO $$
DECLARE
    mapping_count INT;
    question_count INT;
    metric_count INT;
BEGIN
    SELECT COUNT(*) INTO mapping_count
    FROM survey_response_options_aggregations;

    SELECT COUNT(DISTINCT question_number) INTO question_count
    FROM survey_response_options_aggregations;

    SELECT COUNT(DISTINCT agg_metric_id) INTO metric_count
    FROM survey_response_options_aggregations;

    RAISE NOTICE '✅ Survey Response Mappings Created';
    RAISE NOTICE '';
    RAISE NOTICE 'Total mappings: %', mapping_count;
    RAISE NOTICE 'Questions mapped: %', question_count;
    RAISE NOTICE 'Aggregation metrics: %', metric_count;
    RAISE NOTICE '';
    RAISE NOTICE 'Dynamic scoring is now enabled!';
END $$;

COMMIT;
