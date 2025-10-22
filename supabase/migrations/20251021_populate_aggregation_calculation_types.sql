-- =====================================================
-- Populate Aggregation Metrics Calculation Types
-- =====================================================
-- Junction table linking aggregation_metrics to calculation_types
-- Specifies WHICH calculation types can be used for each metric
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- Clear existing
TRUNCATE TABLE aggregation_metrics_calculation_types CASCADE;

-- =====================================================
-- PART 1: Data Entry Field Aggregations
-- =====================================================

-- Meal Time (min=first, max=last, count)
INSERT INTO aggregation_metrics_calculation_types (
  id, aggregation_metric_id, calculation_type_id
)
SELECT
  gen_random_uuid(),
  am.agg_id,
  ct.type_id
FROM aggregation_metrics am
CROSS JOIN calculation_types ct
WHERE am.agg_id = 'AGG_MEAL_TIME'
AND ct.type_id IN ('MIN', 'MAX', 'COUNT');

-- Meal Type (count by type)
INSERT INTO aggregation_metrics_calculation_types (
  id, agg_id, calculation_type, display_name, description, is_default
)
SELECT
  gen_random_uuid(),
  am.agg_id,
  'count',
  'Meal Count by Type',
  'Count of meals grouped by type (breakfast/lunch/dinner)',
  true
FROM aggregation_metrics am
WHERE am.agg_id = 'AGG_MEAL_TYPE';

-- Meal Qualifiers (count by qualifier)
INSERT INTO aggregation_metrics_calculation_types (
  id, agg_id, calculation_type, display_name, description, is_default
)
SELECT
  gen_random_uuid(),
  am.agg_id,
  'count',
  'Meal Count by Qualifier',
  'Count of meals grouped by qualifier (mindful, whole foods, etc.)',
  true
FROM aggregation_metrics am
WHERE am.agg_id = 'AGG_MEAL_QUALIFIERS';

-- Cardio Type (count by type)
INSERT INTO aggregation_metrics_calculation_types (
  id, agg_id, calculation_type, display_name, description, is_default
)
SELECT
  gen_random_uuid(),
  am.agg_id,
  'count',
  'Cardio Sessions by Type',
  'Count of cardio sessions by type (running/cycling/swimming)',
  true
FROM aggregation_metrics am
WHERE am.agg_id = 'AGG_CARDIO_TYPE';

-- Strength Type (count by type)
INSERT INTO aggregation_metrics_calculation_types (
  id, agg_id, calculation_type, display_name, description, is_default
)
SELECT
  gen_random_uuid(),
  am.agg_id,
  'count',
  'Strength Sessions by Type',
  'Count of strength sessions by type',
  true
FROM aggregation_metrics am
WHERE am.agg_id = 'AGG_STRENGTH_TYPE';

-- Flexibility Type (count by type)
INSERT INTO aggregation_metrics_calculation_types (
  id, agg_id, calculation_type, display_name, description, is_default
)
SELECT
  gen_random_uuid(),
  am.agg_id,
  'count',
  'Flexibility Sessions by Type',
  'Count of flexibility sessions by type',
  true
FROM aggregation_metrics am
WHERE am.agg_id = 'AGG_FLEXIBILITY_TYPE';

-- Sleep Period Type (count by type, sum of durations by type)
INSERT INTO aggregation_metrics_calculation_types (
  id, agg_id, calculation_type, display_name, description, is_default
)
SELECT
  gen_random_uuid(),
  am.agg_id,
  calc_type,
  CASE calc_type
    WHEN 'count' THEN 'Sleep Period Count by Type'
    WHEN 'sum' THEN 'Total Duration by Sleep Period Type'
  END as display_name,
  CASE calc_type
    WHEN 'count' THEN 'Count of sleep periods by type (REM/Deep/Core/Awake)'
    WHEN 'sum' THEN 'Total minutes by sleep period type'
  END as description,
  calc_type = 'sum' as is_default
FROM aggregation_metrics am,
LATERAL (VALUES ('count'), ('sum')) AS t(calc_type)
WHERE am.agg_id = 'AGG_SLEEP_PERIOD_TYPE';

-- Sleep Quality (count by rating, avg rating)
INSERT INTO aggregation_metrics_calculation_types (
  id, agg_id, calculation_type, display_name, description, is_default
)
SELECT
  gen_random_uuid(),
  am.agg_id,
  calc_type,
  CASE calc_type
    WHEN 'count' THEN 'Sleep Quality Count'
    WHEN 'avg' THEN 'Average Sleep Quality'
  END as display_name,
  CASE calc_type
    WHEN 'count' THEN 'Count of sleep sessions by quality rating'
    WHEN 'avg' THEN 'Average sleep quality rating'
  END as description,
  calc_type = 'avg' as is_default
FROM aggregation_metrics am,
LATERAL (VALUES ('count'), ('avg')) AS t(calc_type)
WHERE am.agg_id = 'AGG_SLEEP_QUALITY';

-- Mindfulness Type (count by type)
INSERT INTO aggregation_metrics_calculation_types (
  id, agg_id, calculation_type, display_name, description, is_default
)
SELECT
  gen_random_uuid(),
  am.agg_id,
  'count',
  'Mindfulness Sessions by Type',
  'Count of mindfulness sessions by type',
  true
FROM aggregation_metrics am
WHERE am.agg_id = 'AGG_MINDFULNESS_TYPE';

-- Screening Type (count by type)
INSERT INTO aggregation_metrics_calculation_types (
  id, agg_id, calculation_type, display_name, description, is_default
)
SELECT
  gen_random_uuid(),
  am.agg_id,
  'count',
  'Screenings by Type',
  'Count of screenings by type',
  true
FROM aggregation_metrics am
WHERE am.agg_id = 'AGG_SCREENING_TYPE';


-- =====================================================
-- PART 2: Instance Calculation Aggregations
-- =====================================================

-- Cardio Duration (sum, avg, min, max, count)
INSERT INTO aggregation_metrics_calculation_types (
  id, agg_id, calculation_type, display_name, description, is_default
)
SELECT
  gen_random_uuid(),
  am.agg_id,
  calc_type,
  CASE calc_type
    WHEN 'sum' THEN 'Total Cardio Duration'
    WHEN 'avg' THEN 'Average Cardio Duration'
    WHEN 'min' THEN 'Shortest Cardio Session'
    WHEN 'max' THEN 'Longest Cardio Session'
    WHEN 'count' THEN 'Number of Cardio Sessions'
  END as display_name,
  CASE calc_type
    WHEN 'sum' THEN 'Total minutes of cardio in period'
    WHEN 'avg' THEN 'Average cardio session duration'
    WHEN 'min' THEN 'Duration of shortest cardio session'
    WHEN 'max' THEN 'Duration of longest cardio session'
    WHEN 'count' THEN 'Count of cardio sessions'
  END as description,
  calc_type = 'sum' as is_default
FROM aggregation_metrics am,
LATERAL (VALUES ('sum'), ('avg'), ('min'), ('max'), ('count')) AS t(calc_type)
WHERE am.agg_id = 'AGG_CARDIO_DURATION';

-- Strength Duration (sum, avg, min, max, count)
INSERT INTO aggregation_metrics_calculation_types (
  id, agg_id, calculation_type, display_name, description, is_default
)
SELECT
  gen_random_uuid(),
  am.agg_id,
  calc_type,
  CASE calc_type
    WHEN 'sum' THEN 'Total Strength Duration'
    WHEN 'avg' THEN 'Average Strength Duration'
    WHEN 'min' THEN 'Shortest Strength Session'
    WHEN 'max' THEN 'Longest Strength Session'
    WHEN 'count' THEN 'Number of Strength Sessions'
  END as display_name,
  CASE calc_type
    WHEN 'sum' THEN 'Total minutes of strength training in period'
    WHEN 'avg' THEN 'Average strength session duration'
    WHEN 'min' THEN 'Duration of shortest strength session'
    WHEN 'max' THEN 'Duration of longest strength session'
    WHEN 'count' THEN 'Count of strength sessions'
  END as description,
  calc_type = 'sum' as is_default
FROM aggregation_metrics am,
LATERAL (VALUES ('sum'), ('avg'), ('min'), ('max'), ('count')) AS t(calc_type)
WHERE am.agg_id = 'AGG_STRENGTH_DURATION';

-- Flexibility Duration (sum, avg, min, max, count)
INSERT INTO aggregation_metrics_calculation_types (
  id, agg_id, calculation_type, display_name, description, is_default
)
SELECT
  gen_random_uuid(),
  am.agg_id,
  calc_type,
  CASE calc_type
    WHEN 'sum' THEN 'Total Flexibility Duration'
    WHEN 'avg' THEN 'Average Flexibility Duration'
    WHEN 'min' THEN 'Shortest Flexibility Session'
    WHEN 'max' THEN 'Longest Flexibility Session'
    WHEN 'count' THEN 'Number of Flexibility Sessions'
  END as display_name,
  CASE calc_type
    WHEN 'sum' THEN 'Total minutes of flexibility in period'
    WHEN 'avg' THEN 'Average flexibility session duration'
    WHEN 'min' THEN 'Duration of shortest flexibility session'
    WHEN 'max' THEN 'Duration of longest flexibility session'
    WHEN 'count' THEN 'Count of flexibility sessions'
  END as description,
  calc_type = 'sum' as is_default
FROM aggregation_metrics am,
LATERAL (VALUES ('sum'), ('avg'), ('min'), ('max'), ('count')) AS t(calc_type)
WHERE am.agg_id = 'AGG_FLEXIBILITY_DURATION';

-- Mindfulness Duration (sum, avg, min, max, count)
INSERT INTO aggregation_metrics_calculation_types (
  id, agg_id, calculation_type, display_name, description, is_default
)
SELECT
  gen_random_uuid(),
  am.agg_id,
  calc_type,
  CASE calc_type
    WHEN 'sum' THEN 'Total Mindfulness Duration'
    WHEN 'avg' THEN 'Average Mindfulness Duration'
    WHEN 'min' THEN 'Shortest Mindfulness Session'
    WHEN 'max' THEN 'Longest Mindfulness Session'
    WHEN 'count' THEN 'Number of Mindfulness Sessions'
  END as display_name,
  CASE calc_type
    WHEN 'sum' THEN 'Total minutes of mindfulness in period'
    WHEN 'avg' THEN 'Average mindfulness session duration'
    WHEN 'min' THEN 'Duration of shortest mindfulness session'
    WHEN 'max' THEN 'Duration of longest mindfulness session'
    WHEN 'count' THEN 'Count of mindfulness sessions'
  END as description,
  calc_type = 'sum' as is_default
FROM aggregation_metrics am,
LATERAL (VALUES ('sum'), ('avg'), ('min'), ('max'), ('count')) AS t(calc_type)
WHERE am.agg_id = 'AGG_MINDFULNESS_DURATION';

-- Sleep Period Duration (sum, avg, min, max, count)
INSERT INTO aggregation_metrics_calculation_types (
  id, agg_id, calculation_type, display_name, description, is_default
)
SELECT
  gen_random_uuid(),
  am.agg_id,
  calc_type,
  CASE calc_type
    WHEN 'sum' THEN 'Total Sleep Period Duration'
    WHEN 'avg' THEN 'Average Sleep Period Duration'
    WHEN 'min' THEN 'Shortest Sleep Period'
    WHEN 'max' THEN 'Longest Sleep Period'
    WHEN 'count' THEN 'Number of Sleep Periods'
  END as display_name,
  CASE calc_type
    WHEN 'sum' THEN 'Total minutes of all sleep periods'
    WHEN 'avg' THEN 'Average sleep period duration'
    WHEN 'min' THEN 'Duration of shortest sleep period'
    WHEN 'max' THEN 'Duration of longest sleep period'
    WHEN 'count' THEN 'Count of sleep periods'
  END as description,
  calc_type = 'sum' as is_default
FROM aggregation_metrics am,
LATERAL (VALUES ('sum'), ('avg'), ('min'), ('max'), ('count')) AS t(calc_type)
WHERE am.agg_id = 'AGG_SLEEP_PERIOD_DURATION';

-- Sleep Session Duration (avg, min, max, latest)
INSERT INTO aggregation_metrics_calculation_types (
  id, agg_id, calculation_type, display_name, description, is_default
)
SELECT
  gen_random_uuid(),
  am.agg_id,
  calc_type,
  CASE calc_type
    WHEN 'avg' THEN 'Average Sleep Session Duration'
    WHEN 'min' THEN 'Shortest Sleep Session'
    WHEN 'max' THEN 'Longest Sleep Session'
    WHEN 'latest' THEN 'Most Recent Sleep Duration'
  END as display_name,
  CASE calc_type
    WHEN 'avg' THEN 'Average total sleep session duration'
    WHEN 'min' THEN 'Duration of shortest sleep session'
    WHEN 'max' THEN 'Duration of longest sleep session'
    WHEN 'latest' THEN 'Duration of most recent sleep session'
  END as description,
  calc_type = 'avg' as is_default
FROM aggregation_metrics am,
LATERAL (VALUES ('avg'), ('min'), ('max'), ('latest')) AS t(calc_type)
WHERE am.agg_id = 'AGG_SLEEP_SESSION_DURATION';

-- Sleep Efficiency (avg, min, max, latest)
INSERT INTO aggregation_metrics_calculation_types (
  id, agg_id, calculation_type, display_name, description, is_default
)
SELECT
  gen_random_uuid(),
  am.agg_id,
  calc_type,
  CASE calc_type
    WHEN 'avg' THEN 'Average Sleep Efficiency'
    WHEN 'min' THEN 'Lowest Sleep Efficiency'
    WHEN 'max' THEN 'Highest Sleep Efficiency'
    WHEN 'latest' THEN 'Most Recent Sleep Efficiency'
  END as display_name,
  CASE calc_type
    WHEN 'avg' THEN 'Average sleep efficiency percentage'
    WHEN 'min' THEN 'Lowest sleep efficiency in period'
    WHEN 'max' THEN 'Highest sleep efficiency in period'
    WHEN 'latest' THEN 'Most recent sleep efficiency'
  END as description,
  calc_type = 'avg' as is_default
FROM aggregation_metrics am,
LATERAL (VALUES ('avg'), ('min'), ('max'), ('latest')) AS t(calc_type)
WHERE am.agg_id = 'AGG_SLEEP_EFFICIENCY';

-- Last Meal to Sleep Gap (avg, min, max, latest)
INSERT INTO aggregation_metrics_calculation_types (
  id, agg_id, calculation_type, display_name, description, is_default
)
SELECT
  gen_random_uuid(),
  am.agg_id,
  calc_type,
  CASE calc_type
    WHEN 'avg' THEN 'Average Last Meal to Sleep Gap'
    WHEN 'min' THEN 'Shortest Last Meal to Sleep Gap'
    WHEN 'max' THEN 'Longest Last Meal to Sleep Gap'
    WHEN 'latest' THEN 'Most Recent Last Meal to Sleep Gap'
  END as display_name,
  CASE calc_type
    WHEN 'avg' THEN 'Average hours between last meal and sleep'
    WHEN 'min' THEN 'Shortest gap between last meal and sleep'
    WHEN 'max' THEN 'Longest gap between last meal and sleep'
    WHEN 'latest' THEN 'Most recent last meal to sleep gap'
  END as description,
  calc_type = 'avg' as is_default
FROM aggregation_metrics am,
LATERAL (VALUES ('avg'), ('min'), ('max'), ('latest')) AS t(calc_type)
WHERE am.agg_id = 'AGG_LAST_MEAL_TO_SLEEP_GAP';

-- BMI (avg, min, max, latest)
INSERT INTO aggregation_metrics_calculation_types (
  id, agg_id, calculation_type, display_name, description, is_default
)
SELECT
  gen_random_uuid(),
  am.agg_id,
  calc_type,
  CASE calc_type
    WHEN 'avg' THEN 'Average BMI'
    WHEN 'min' THEN 'Minimum BMI'
    WHEN 'max' THEN 'Maximum BMI'
    WHEN 'latest' THEN 'Most Recent BMI'
  END as display_name,
  CASE calc_type
    WHEN 'avg' THEN 'Average BMI in period'
    WHEN 'min' THEN 'Minimum BMI in period'
    WHEN 'max' THEN 'Maximum BMI in period'
    WHEN 'latest' THEN 'Most recent BMI measurement'
  END as description,
  calc_type = 'latest' as is_default
FROM aggregation_metrics am,
LATERAL (VALUES ('avg'), ('min'), ('max'), ('latest')) AS t(calc_type)
WHERE am.agg_id = 'AGG_BMI';

-- Body Fat Mass (avg, min, max, latest)
INSERT INTO aggregation_metrics_calculation_types (
  id, agg_id, calculation_type, display_name, description, is_default
)
SELECT
  gen_random_uuid(),
  am.agg_id,
  calc_type,
  CASE calc_type
    WHEN 'avg' THEN 'Average Body Fat Mass'
    WHEN 'min' THEN 'Minimum Body Fat Mass'
    WHEN 'max' THEN 'Maximum Body Fat Mass'
    WHEN 'latest' THEN 'Most Recent Body Fat Mass'
  END as display_name,
  CASE calc_type
    WHEN 'avg' THEN 'Average body fat mass in period'
    WHEN 'min' THEN 'Minimum body fat mass in period'
    WHEN 'max' THEN 'Maximum body fat mass in period'
    WHEN 'latest' THEN 'Most recent body fat mass'
  END as description,
  calc_type = 'latest' as is_default
FROM aggregation_metrics am,
LATERAL (VALUES ('avg'), ('min'), ('max'), ('latest')) AS t(calc_type)
WHERE am.agg_id = 'AGG_BODY_FAT_MASS';


-- =====================================================
-- Summary
-- =====================================================

DO $$
DECLARE
  total_calc_types INT;
  calc_types_by_agg RECORD;
BEGIN
  SELECT COUNT(*) INTO total_calc_types
  FROM aggregation_metrics_calculation_types;

  RAISE NOTICE '===========================================';
  RAISE NOTICE 'Aggregation Calculation Types Created';
  RAISE NOTICE '===========================================';
  RAISE NOTICE 'Total calculation types: %', total_calc_types;
  RAISE NOTICE '';
  RAISE NOTICE 'Breakdown by aggregation metric:';

  FOR calc_types_by_agg IN
    SELECT
      am.agg_id,
      am.display_name,
      COUNT(amct.id) as calc_type_count,
      string_agg(amct.calculation_type, ', ' ORDER BY amct.calculation_type) as calc_types
    FROM aggregation_metrics am
    LEFT JOIN aggregation_metrics_calculation_types amct
      ON am.agg_id = amct.agg_id
    GROUP BY am.agg_id, am.display_name
    ORDER BY am.agg_id
  LOOP
    RAISE NOTICE '  % (%): %',
      calc_types_by_agg.agg_id,
      calc_types_by_agg.calc_type_count,
      calc_types_by_agg.calc_types;
  END LOOP;

  RAISE NOTICE '';
  RAISE NOTICE 'Next step: Create aggregation_metrics_dependencies';
  RAISE NOTICE '(link each aggregation back to its source data_entry_field or instance_calculation)';
END $$;

COMMIT;
