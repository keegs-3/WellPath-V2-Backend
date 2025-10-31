-- =====================================================
-- Function-Based Question Mappings
-- =====================================================
-- Add mappings for questions within survey functions
-- These work the same as standalone questions - just
-- mapping response options to aggregation metrics
--
-- Created: 2025-10-22
-- =====================================================

BEGIN;

-- Add mappings for function-based questions
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
    '69eca8d1-a9fc-45aa-919d-70131034016b',
    'RO_3.04-1',
    3.04,
    'AGG_CARDIO_SESSION_COUNT',
    0,
    1,
    'AVG',
    'weekly',
    3,
    30,
    'Rarely or never'
),
(
    '6d85917f-05e6-48b5-a415-86553623c828',
    'RO_3.04-2',
    3.04,
    'AGG_CARDIO_SESSION_COUNT',
    1,
    2,
    'AVG',
    'weekly',
    3,
    30,
    '1-2 times per week'
),
(
    '6d4f9db2-a808-457a-a58f-f2c071cf893a',
    'RO_3.04-3',
    3.04,
    'AGG_CARDIO_SESSION_COUNT',
    3,
    4,
    'AVG',
    'weekly',
    3,
    30,
    '3-4 times per week'
),
(
    'bd5175ce-f1cf-49f9-a796-a2d62e9a6bf1',
    'RO_3.04-4',
    3.04,
    'AGG_CARDIO_SESSION_COUNT',
    5,
    999,
    'AVG',
    'weekly',
    3,
    30,
    '5 or more times per week'
),
(
    '94141db4-9ad1-4e11-a2e0-fe8c982d0931',
    'RO_3.08-1',
    3.08,
    'AGG_CARDIO_DURATION',
    0,
    60,
    'SUM',
    'weekly',
    3,
    30,
    '0-60 minutes per week'
),
(
    '92e085ae-b516-46a1-983b-6dbb0a99dbf1',
    'RO_3.08-2',
    3.08,
    'AGG_CARDIO_DURATION',
    61,
    120,
    'SUM',
    'weekly',
    3,
    30,
    '61-120 minutes per week'
),
(
    '8e88400f-b710-4f33-a598-ca3af61cdee7',
    'RO_3.08-3',
    3.08,
    'AGG_CARDIO_DURATION',
    121,
    150,
    'SUM',
    'weekly',
    3,
    30,
    '121-150 minutes per week'
),
(
    '85d2f4fe-ac24-4c3c-8fb1-ea8ad46c4f7d',
    'RO_3.08-4',
    3.08,
    'AGG_CARDIO_DURATION',
    151,
    9999,
    'SUM',
    'weekly',
    3,
    30,
    '151+ minutes per week'
),
(
    '6ab018aa-f597-41da-8b17-916b3b7441b9',
    'RO_3.05-1',
    3.05,
    'AGG_STRENGTH_SESSION_COUNT',
    0,
    0,
    'AVG',
    'weekly',
    3,
    30,
    'Rarely or never'
),
(
    '60424c84-0da3-4677-8cef-941a390070c8',
    'RO_3.05-2',
    3.05,
    'AGG_STRENGTH_SESSION_COUNT',
    1,
    1,
    'AVG',
    'weekly',
    3,
    30,
    '1 time per week'
),
(
    '7092c7ba-9476-4e22-9a9c-620e9491659e',
    'RO_3.05-3',
    3.05,
    'AGG_STRENGTH_SESSION_COUNT',
    2,
    2,
    'AVG',
    'weekly',
    3,
    30,
    '2 times per week'
),
(
    '117f81b8-c52c-493f-9a87-6023a7d3f39f',
    'RO_3.05-4',
    3.05,
    'AGG_STRENGTH_SESSION_COUNT',
    3,
    999,
    'AVG',
    'weekly',
    3,
    30,
    '3+ times per week'
),
(
    'c24d20ab-8b80-4fcb-b07d-f81bd33ebe62',
    'RO_3.09-1',
    3.09,
    'AGG_STRENGTH_DURATION',
    0,
    30,
    'SUM',
    'weekly',
    3,
    30,
    '0-30 minutes per week'
),
(
    'ddfd9de5-7c9c-4f85-9d38-182319b5ac42',
    'RO_3.09-2',
    3.09,
    'AGG_STRENGTH_DURATION',
    31,
    60,
    'SUM',
    'weekly',
    3,
    30,
    '31-60 minutes per week'
),
(
    '90baf3cc-acc4-4277-8ae6-81045cd77680',
    'RO_3.09-3',
    3.09,
    'AGG_STRENGTH_DURATION',
    61,
    90,
    'SUM',
    'weekly',
    3,
    30,
    '61-90 minutes per week'
),
(
    '71a4f6e7-5044-4099-96d3-632aee485ef8',
    'RO_3.09-4',
    3.09,
    'AGG_STRENGTH_DURATION',
    91,
    9999,
    'SUM',
    'weekly',
    3,
    30,
    '91+ minutes per week'
),
(
    '37412611-81d5-477f-a1bb-1899f073505a',
    'RO_3.07-1',
    3.07,
    'AGG_HIIT_SESSION_COUNT',
    0,
    0,
    'AVG',
    'weekly',
    2,
    30,
    'Rarely or never'
),
(
    '8c480133-bef9-43b2-8178-44776eab8312',
    'RO_3.07-2',
    3.07,
    'AGG_HIIT_SESSION_COUNT',
    1,
    1,
    'AVG',
    'weekly',
    2,
    30,
    '1 time per week'
),
(
    'a13a67db-de69-4877-ab60-2da6e9552342',
    'RO_3.07-3',
    3.07,
    'AGG_HIIT_SESSION_COUNT',
    2,
    2,
    'AVG',
    'weekly',
    2,
    30,
    '2 times per week'
),
(
    'c773e518-25bb-41c5-931d-cb0d6fd85e43',
    'RO_3.07-4',
    3.07,
    'AGG_HIIT_SESSION_COUNT',
    3,
    999,
    'AVG',
    'weekly',
    2,
    30,
    '3+ times per week'
),
(
    '454a16b0-92bd-4a61-ab5b-8061599a66a0',
    'RO_3.11-1',
    3.11,
    'AGG_HIIT_DURATION',
    0,
    20,
    'SUM',
    'weekly',
    2,
    30,
    '0-20 minutes per week'
),
(
    '6832cebe-ccc2-433a-b855-908b60a8e281',
    'RO_3.11-2',
    3.11,
    'AGG_HIIT_DURATION',
    21,
    40,
    'SUM',
    'weekly',
    2,
    30,
    '21-40 minutes per week'
),
(
    '589402a4-6452-4413-8ff7-2a7a298c4f89',
    'RO_3.11-3',
    3.11,
    'AGG_HIIT_DURATION',
    41,
    60,
    'SUM',
    'weekly',
    2,
    30,
    '41-60 minutes per week'
),
(
    '00d74617-160a-4749-8c36-0259e615371b',
    'RO_3.11-4',
    3.11,
    'AGG_HIIT_DURATION',
    61,
    9999,
    'SUM',
    'weekly',
    2,
    30,
    '61+ minutes per week'
),
(
    'bd664a8e-501a-4418-adcd-c662de00e3db',
    'RO_3.06-1',
    3.06,
    'AGG_MOBILITY_SESSION_COUNT',
    0,
    0,
    'AVG',
    'weekly',
    2,
    30,
    'Rarely or never'
),
(
    '5f2ea8e2-59db-4500-b84b-efd0b71e77f7',
    'RO_3.06-2',
    3.06,
    'AGG_MOBILITY_SESSION_COUNT',
    1,
    1,
    'AVG',
    'weekly',
    2,
    30,
    '1 time per week'
),
(
    '18a8eb0b-48c6-448c-aa7e-002cf9c2c220',
    'RO_3.06-3',
    3.06,
    'AGG_MOBILITY_SESSION_COUNT',
    2,
    3,
    'AVG',
    'weekly',
    2,
    30,
    '2-3 times per week'
),
(
    'dc9f51b9-65c0-4554-80df-5e6551b1e5f8',
    'RO_3.06-4',
    3.06,
    'AGG_MOBILITY_SESSION_COUNT',
    4,
    999,
    'AVG',
    'weekly',
    2,
    30,
    '4+ times per week'
),
(
    '64acff20-14d1-4c94-bcda-0f5e34bf2871',
    'RO_3.10-1',
    3.1,
    'AGG_MOBILITY_DURATION',
    0,
    20,
    'SUM',
    'weekly',
    2,
    30,
    '0-20 minutes per week'
),
(
    '96043ce7-cb6e-45a1-9426-aa0cf85c6cb9',
    'RO_3.10-2',
    3.1,
    'AGG_MOBILITY_DURATION',
    21,
    40,
    'SUM',
    'weekly',
    2,
    30,
    '21-40 minutes per week'
),
(
    '5e0e05ec-1b66-4dca-b3ff-fd120a1f1b69',
    'RO_3.10-3',
    3.1,
    'AGG_MOBILITY_DURATION',
    41,
    60,
    'SUM',
    'weekly',
    2,
    30,
    '41-60 minutes per week'
),
(
    '6ccb7077-bc88-45a4-ba49-51e88f3a975d',
    'RO_3.10-4',
    3.1,
    'AGG_MOBILITY_DURATION',
    61,
    9999,
    'SUM',
    'weekly',
    2,
    30,
    '61+ minutes per week'
),
(
    '30c95faa-ed1e-45f0-a199-33cf927d3989',
    'RO_8.05-1',
    8.05,
    'AGG_ALCOHOLIC_DRINKS',
    35,
    999,
    'SUM',
    'weekly',
    3,
    30,
    'Heavy: 5+ drinks per day (35+/week)'
),
(
    'db3a4fad-c84d-4fa9-9a1f-bf4097830f3d',
    'RO_8.05-2',
    8.05,
    'AGG_ALCOHOLIC_DRINKS',
    14,
    28,
    'SUM',
    'weekly',
    3,
    30,
    'Moderate: 2-4 drinks per day (14-28/week)'
),
(
    'f1a3de3e-dea0-46c7-bdf1-987ae5ea8b4c',
    'RO_8.05-3',
    8.05,
    'AGG_ALCOHOLIC_DRINKS',
    5,
    10,
    'SUM',
    'weekly',
    3,
    30,
    'Light: 1 drink per day (5-10/week)'
),
(
    'b3c5e8fa-248d-4740-8607-729c270b87d9',
    'RO_8.05-4',
    8.05,
    'AGG_ALCOHOLIC_DRINKS',
    1,
    4,
    'SUM',
    'weekly',
    3,
    30,
    'Minimal: A few per month (1-4/week)'
),
(
    '8a507c9c-d176-4eeb-91a9-c909e8a21abc',
    'RO_8.05-5',
    8.05,
    'AGG_ALCOHOLIC_DRINKS',
    0,
    1,
    'SUM',
    'weekly',
    3,
    30,
    'Occasional: Rarely (0-1/week)'
);


DO $$
BEGIN
    RAISE NOTICE '✅ Function-based question mappings added';
    RAISE NOTICE '   37 mappings created';
    RAISE NOTICE '';
    RAISE NOTICE 'These questions can now be dynamically updated via edge function:';
    RAISE NOTICE '  - Movement frequency + duration (cardio, strength, HIIT, mobility)';
    RAISE NOTICE '  - Alcohol use level';
    RAISE NOTICE '';
    RAISE NOTICE 'Edge function will update effective_response_option_id based on tracked data';
    RAISE NOTICE 'Existing scoring functions will recalculate automatically';
END $$;

COMMIT;
