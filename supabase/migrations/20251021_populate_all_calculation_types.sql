-- =====================================================
-- Populate Aggregation Metrics Calculation Types
-- =====================================================
-- Junction table linking aggregation_metrics to calculation_types
-- Assigns appropriate calculation types based on metric characteristics
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- Clear existing
TRUNCATE TABLE aggregation_metrics_calculation_types CASCADE;

-- =====================================================
-- PART 1: Instance Calculation Aggregations
-- =====================================================
-- These get calculation types based on their output unit

-- Duration metrics (minute, hours) -> SUM, AVG, MIN, MAX, COUNT
INSERT INTO aggregation_metrics_calculation_types (
  id, aggregation_metric_id, calculation_type_id
)
SELECT
  gen_random_uuid(),
  am.agg_id,
  ct.type_id
FROM aggregation_metrics am
CROSS JOIN calculation_types ct
WHERE am.output_unit IN ('minute', 'hours')
AND ct.type_id IN ('SUM', 'AVG', 'MIN', 'MAX', 'COUNT');

-- Percentage/Ratio metrics -> AVG, MIN, MAX, LATEST
INSERT INTO aggregation_metrics_calculation_types (
  id, aggregation_metric_id, calculation_type_id
)
SELECT
  gen_random_uuid(),
  am.agg_id,
  ct.type_id
FROM aggregation_metrics am
CROSS JOIN calculation_types ct
WHERE am.output_unit IN ('percentage', 'ratio')
AND ct.type_id IN ('AVG', 'MIN', 'MAX', 'LATEST');

-- Body composition metrics (kilogram - excluding quantity fields, count for BMI) -> AVG, MIN, MAX, LATEST
INSERT INTO aggregation_metrics_calculation_types (
  id, aggregation_metric_id, calculation_type_id
)
SELECT
  gen_random_uuid(),
  am.agg_id,
  ct.type_id
FROM aggregation_metrics am
CROSS JOIN calculation_types ct
WHERE (
  (am.output_unit = 'kilogram' AND am.agg_id LIKE 'AGG_%MASS')
  OR (am.output_unit = 'kilogram' AND am.agg_id LIKE 'AGG_%MUSCLE%')
  OR am.agg_id = 'AGG_BMI_CALCULATED'
)
AND ct.type_id IN ('AVG', 'MIN', 'MAX', 'LATEST');

-- Age/Time metrics (years, day) -> LATEST only
INSERT INTO aggregation_metrics_calculation_types (
  id, aggregation_metric_id, calculation_type_id
)
SELECT
  gen_random_uuid(),
  am.agg_id,
  ct.type_id
FROM aggregation_metrics am
CROSS JOIN calculation_types ct
WHERE am.output_unit IN ('years', 'day')
AND ct.type_id = 'LATEST';


-- =====================================================
-- PART 2: Data Entry Field Aggregations
-- =====================================================

-- Reference/Category fields (count by type) -> COUNT only
INSERT INTO aggregation_metrics_calculation_types (
  id, aggregation_metric_id, calculation_type_id
)
SELECT
  gen_random_uuid(),
  am.agg_id,
  ct.type_id
FROM aggregation_metrics am
CROSS JOIN calculation_types ct
WHERE am.output_unit = 'count'
AND ct.type_id = 'COUNT';

-- Rating fields -> AVG, MIN, MAX, MODE
INSERT INTO aggregation_metrics_calculation_types (
  id, aggregation_metric_id, calculation_type_id
)
SELECT
  gen_random_uuid(),
  am.agg_id,
  ct.type_id
FROM aggregation_metrics am
CROSS JOIN calculation_types ct
WHERE am.output_unit = 'rating'
AND ct.type_id IN ('AVG', 'MIN', 'MAX', 'MODE');

-- Timestamp fields -> MIN (first), MAX (last), COUNT
INSERT INTO aggregation_metrics_calculation_types (
  id, aggregation_metric_id, calculation_type_id
)
SELECT
  gen_random_uuid(),
  am.agg_id,
  ct.type_id
FROM aggregation_metrics am
CROSS JOIN calculation_types ct
WHERE am.output_unit = 'datetime_combined'
AND ct.type_id IN ('MIN', 'MAX', 'COUNT');

-- Quantity fields (gram, milligram, centimeter, meter, steps) -> SUM, AVG, MIN, MAX, COUNT
-- NOTE: kilogram excluded here because body composition metrics are handled separately above
INSERT INTO aggregation_metrics_calculation_types (
  id, aggregation_metric_id, calculation_type_id
)
SELECT
  gen_random_uuid(),
  am.agg_id,
  ct.type_id
FROM aggregation_metrics am
CROSS JOIN calculation_types ct
WHERE am.output_unit IN ('gram', 'milligram', 'centimeter', 'meter', 'steps')
AND ct.type_id IN ('SUM', 'AVG', 'MIN', 'MAX', 'COUNT');

-- Text fields -> COUNT, MODE
INSERT INTO aggregation_metrics_calculation_types (
  id, aggregation_metric_id, calculation_type_id
)
SELECT
  gen_random_uuid(),
  am.agg_id,
  ct.type_id
FROM aggregation_metrics am
CROSS JOIN calculation_types ct
WHERE am.output_unit = 'text'
AND ct.type_id IN ('COUNT', 'MODE');


-- =====================================================
-- Summary
-- =====================================================

DO $$
DECLARE
  total_junction_entries INT;
  metrics_with_calcs INT;
  avg_calcs_per_metric NUMERIC;
  calc_breakdown RECORD;
BEGIN
  SELECT COUNT(*) INTO total_junction_entries
  FROM aggregation_metrics_calculation_types;

  SELECT COUNT(DISTINCT aggregation_metric_id) INTO metrics_with_calcs
  FROM aggregation_metrics_calculation_types;

  SELECT ROUND(AVG(calc_count), 1) INTO avg_calcs_per_metric
  FROM (
    SELECT COUNT(*) as calc_count
    FROM aggregation_metrics_calculation_types
    GROUP BY aggregation_metric_id
  ) counts;

  RAISE NOTICE '===========================================';
  RAISE NOTICE 'Aggregation Calculation Types Populated';
  RAISE NOTICE '===========================================';
  RAISE NOTICE 'Total junction entries: %', total_junction_entries;
  RAISE NOTICE 'Metrics with calculation types: %', metrics_with_calcs;
  RAISE NOTICE 'Average calculation types per metric: %', avg_calcs_per_metric;
  RAISE NOTICE '';
  RAISE NOTICE 'Calculation types by frequency:';

  FOR calc_breakdown IN
    SELECT
      ct.type_id,
      ct.type_name,
      COUNT(amct.id) as usage_count
    FROM calculation_types ct
    LEFT JOIN aggregation_metrics_calculation_types amct
      ON ct.type_id = amct.calculation_type_id
    GROUP BY ct.type_id, ct.type_name
    ORDER BY usage_count DESC
  LOOP
    RAISE NOTICE '  %: % (%)',
      calc_breakdown.type_id,
      calc_breakdown.usage_count,
      calc_breakdown.type_name;
  END LOOP;

  RAISE NOTICE '';
  RAISE NOTICE 'Next step: Populate aggregation_metrics_dependencies';
  RAISE NOTICE '(link each aggregation to its source data_entry_field or instance_calculation)';
END $$;

COMMIT;
