-- =====================================================
-- Create Proof-of-Concept Aggregations
-- =====================================================
-- Set up 3 test aggregations to validate the pipeline:
-- 1. Sleep Duration (from instance calculation)
-- 2. Cardio Duration (from instance calculation)
-- 3. Vegetable Servings (from data entry field)
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Create Aggregation Metrics
-- =====================================================

INSERT INTO aggregation_metrics (agg_id, metric_name, display_name, description, output_unit, is_active)
VALUES
-- Sleep Duration: from instance calc DEF_SLEEP_DURATION
('AGG_SLEEP_DURATION', 'sleep_duration_agg', 'Sleep Duration Aggregation',
 'Aggregated sleep duration metrics over time', 'minute', true),

-- Cardio Duration: from instance calc DEF_CARDIO_DURATION
('AGG_CARDIO_DURATION', 'cardio_duration_agg', 'Cardio Duration Aggregation',
 'Aggregated cardio exercise duration over time', 'minute', true),

-- Vegetable Servings: from data entry field DEF_VEGETABLE_QUANTITY
('AGG_VEGETABLE_SERVINGS', 'vegetable_servings_agg', 'Vegetable Servings Aggregation',
 'Aggregated vegetable consumption over time', 'serving', true)

ON CONFLICT (agg_id) DO UPDATE SET
  metric_name = EXCLUDED.metric_name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  output_unit = EXCLUDED.output_unit,
  is_active = EXCLUDED.is_active;


-- =====================================================
-- PART 2: Link Aggregations to Data Sources
-- =====================================================

-- Sleep Duration: instance_calc dependency
INSERT INTO aggregation_metrics_dependencies
(agg_metric_id, instance_calculation_id, dependency_type, display_order)
VALUES
('AGG_SLEEP_DURATION', 'CALC_SLEEP_DURATION', 'instance_calc', 1)
ON CONFLICT (agg_metric_id, instance_calculation_id, data_entry_field_id) DO NOTHING;

-- Cardio Duration: instance_calc dependency
INSERT INTO aggregation_metrics_dependencies
(agg_metric_id, instance_calculation_id, dependency_type, display_order)
VALUES
('AGG_CARDIO_DURATION', 'CALC_CARDIO_DURATION', 'instance_calc', 1)
ON CONFLICT (agg_metric_id, instance_calculation_id, data_entry_field_id) DO NOTHING;

-- Vegetable Servings: data_field dependency
INSERT INTO aggregation_metrics_dependencies
(agg_metric_id, data_entry_field_id, dependency_type, display_order)
VALUES
('AGG_VEGETABLE_SERVINGS', 'DEF_VEGETABLE_QUANTITY', 'data_field', 1)
ON CONFLICT (agg_metric_id, instance_calculation_id, data_entry_field_id) DO NOTHING;


-- =====================================================
-- PART 3: Configure Calculation Types
-- =====================================================

-- Sleep Duration: AVG, MIN, MAX
INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES
('AGG_SLEEP_DURATION', 'AVG'),
('AGG_SLEEP_DURATION', 'MIN'),
('AGG_SLEEP_DURATION', 'MAX')
ON CONFLICT (aggregation_metric_id, calculation_type_id) DO NOTHING;

-- Cardio Duration: SUM (total time), AVG (avg session length)
INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES
('AGG_CARDIO_DURATION', 'SUM'),
('AGG_CARDIO_DURATION', 'AVG')
ON CONFLICT (aggregation_metric_id, calculation_type_id) DO NOTHING;

-- Vegetable Servings: SUM (total servings), AVG (avg per day)
INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES
('AGG_VEGETABLE_SERVINGS', 'SUM'),
('AGG_VEGETABLE_SERVINGS', 'AVG')
ON CONFLICT (aggregation_metric_id, calculation_type_id) DO NOTHING;


-- =====================================================
-- PART 4: Configure Periods
-- =====================================================

-- Sleep Duration: daily, weekly, monthly
INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES
('AGG_SLEEP_DURATION', 'daily'),
('AGG_SLEEP_DURATION', 'weekly'),
('AGG_SLEEP_DURATION', 'monthly')
ON CONFLICT DO NOTHING;

-- Cardio Duration: daily, weekly, monthly
INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES
('AGG_CARDIO_DURATION', 'daily'),
('AGG_CARDIO_DURATION', 'weekly'),
('AGG_CARDIO_DURATION', 'monthly')
ON CONFLICT DO NOTHING;

-- Vegetable Servings: daily, weekly, monthly
INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES
('AGG_VEGETABLE_SERVINGS', 'daily'),
('AGG_VEGETABLE_SERVINGS', 'weekly'),
('AGG_VEGETABLE_SERVINGS', 'monthly')
ON CONFLICT DO NOTHING;


-- =====================================================
-- PART 5: Link to Display Metrics
-- =====================================================

-- Sleep Duration → DISP_SLEEP_DURATION
-- Link to weekly AVG (primary), monthly AVG, daily MIN, daily MAX
INSERT INTO display_metrics_aggregations
(display_metric_id, agg_metric_id, period_type, calculation_type_id, is_primary, display_order)
VALUES
('DISP_SLEEP_DURATION', 'AGG_SLEEP_DURATION', 'weekly', 'AVG', true, 1),
('DISP_SLEEP_DURATION', 'AGG_SLEEP_DURATION', 'monthly', 'AVG', false, 2),
('DISP_SLEEP_DURATION', 'AGG_SLEEP_DURATION', 'daily', 'MIN', false, 3),
('DISP_SLEEP_DURATION', 'AGG_SLEEP_DURATION', 'daily', 'MAX', false, 4)
ON CONFLICT (display_metric_id, agg_metric_id, period_type, calculation_type_id) DO UPDATE SET
  is_primary = EXCLUDED.is_primary,
  display_order = EXCLUDED.display_order;


-- =====================================================
-- Summary
-- =====================================================

DO $$
DECLARE
  agg_count INT;
  dep_count INT;
  calc_count INT;
  period_count INT;
  display_count INT;
BEGIN
  SELECT COUNT(*) INTO agg_count FROM aggregation_metrics WHERE agg_id LIKE 'AGG_%';
  SELECT COUNT(*) INTO dep_count FROM aggregation_metrics_dependencies WHERE agg_metric_id LIKE 'AGG_%';
  SELECT COUNT(*) INTO calc_count FROM aggregation_metrics_calculation_types WHERE aggregation_metric_id LIKE 'AGG_%';
  SELECT COUNT(*) INTO period_count FROM aggregation_metrics_periods WHERE agg_metric_id LIKE 'AGG_%';
  SELECT COUNT(*) INTO display_count FROM display_metrics_aggregations WHERE agg_metric_id LIKE 'AGG_%';

  RAISE NOTICE '✅ Proof-of-Concept Aggregations Created';
  RAISE NOTICE '';
  RAISE NOTICE 'Summary:';
  RAISE NOTICE '  Aggregation Metrics: %', agg_count;
  RAISE NOTICE '  Dependencies: %', dep_count;
  RAISE NOTICE '  Calculation Types: %', calc_count;
  RAISE NOTICE '  Periods: %', period_count;
  RAISE NOTICE '  Display Links: %', display_count;
  RAISE NOTICE '';
  RAISE NOTICE 'Configured Aggregations:';
  RAISE NOTICE '  1. Sleep Duration (from CALC_SLEEP_DURATION)';
  RAISE NOTICE '     - AVG, MIN, MAX';
  RAISE NOTICE '     - Daily, Weekly, Monthly';
  RAISE NOTICE '  2. Cardio Duration (from CALC_CARDIO_DURATION)';
  RAISE NOTICE '     - SUM, AVG';
  RAISE NOTICE '     - Daily, Weekly, Monthly';
  RAISE NOTICE '  3. Vegetable Servings (from DEF_VEGETABLE_QUANTITY)';
  RAISE NOTICE '     - SUM, AVG';
  RAISE NOTICE '     - Daily, Weekly, Monthly';
  RAISE NOTICE '';
  RAISE NOTICE 'Next: Build aggregation worker to populate aggregation_results_cache';
END $$;

COMMIT;
