-- =====================================================
-- Create ALL Aggregation Metrics
-- =====================================================
-- Creates aggregation_metrics for:
-- 1. All data_entry_fields that don't have instance calculations (34)
-- 2. All instance calculations (26)
-- Total: 60 aggregation_metrics
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- Clear existing
TRUNCATE TABLE aggregation_metrics CASCADE;

-- =====================================================
-- PART 1: Data Entry Field Aggregations (34)
-- =====================================================
-- These are fields that don't have instance calculations
-- We aggregate them directly

-- Automatically create aggregations for all data_entry_fields without instance calculations
INSERT INTO aggregation_metrics (
  id, agg_id, metric_name, display_name, description, output_unit, is_active
)
SELECT
  gen_random_uuid(),
  'AGG_' || UPPER(REPLACE(def.field_name, '_id', '')),
  REPLACE(def.field_name, '_id', ''),
  def.display_name,
  'Aggregates ' || def.display_name || ' values',
  CASE
    WHEN def.field_type = 'quantity' THEN COALESCE(def.unit, 'count')
    WHEN def.field_type IN ('reference', 'category') THEN 'count'
    WHEN def.field_type = 'rating' THEN 'rating'
    WHEN def.field_type = 'timestamp' THEN 'datetime_combined'
    WHEN def.field_type = 'text' THEN 'text'
    ELSE 'count'
  END,
  true
FROM data_entry_fields def
WHERE def.is_active = true
AND def.field_id NOT IN (
  SELECT DISTINCT data_entry_field_id
  FROM instance_calculations_dependencies
);


-- =====================================================
-- PART 2: Instance Calculation Aggregations (26)
-- =====================================================

-- Automatically create aggregations for all instance calculations
INSERT INTO aggregation_metrics (
  id, agg_id, metric_name, display_name, description, output_unit, is_active
)
SELECT
  gen_random_uuid(),
  'AGG_' || UPPER(ic.calc_name),
  ic.calc_name,
  ic.display_name,
  'Aggregates ' || ic.display_name || ' calculated values',
  ic.unit_id,
  true
FROM instance_calculations ic
WHERE ic.is_active = true;


-- =====================================================
-- Summary
-- =====================================================

DO $$
DECLARE
  total_metrics INT;
  field_aggs INT;
  calc_aggs INT;
BEGIN
  SELECT COUNT(*) INTO total_metrics
  FROM aggregation_metrics
  WHERE is_active = true;

  SELECT COUNT(*) INTO field_aggs
  FROM aggregation_metrics am
  WHERE am.agg_id IN (
    SELECT 'AGG_' || UPPER(REPLACE(def.field_name, '_id', ''))
    FROM data_entry_fields def
    WHERE def.is_active = true
    AND def.field_id NOT IN (
      SELECT DISTINCT data_entry_field_id
      FROM instance_calculations_dependencies
    )
  );

  SELECT COUNT(*) INTO calc_aggs
  FROM aggregation_metrics am
  WHERE am.agg_id IN (
    SELECT 'AGG_' || UPPER(ic.calc_name)
    FROM instance_calculations ic
    WHERE ic.is_active = true
  );

  RAISE NOTICE '===========================================';
  RAISE NOTICE 'All Aggregation Metrics Created';
  RAISE NOTICE '===========================================';
  RAISE NOTICE 'Total metrics: %', total_metrics;
  RAISE NOTICE '';
  RAISE NOTICE 'Breakdown:';
  RAISE NOTICE '  Data entry field aggregations: %', field_aggs;
  RAISE NOTICE '  Instance calculation aggregations: %', calc_aggs;
  RAISE NOTICE '';
  RAISE NOTICE 'Next step: Populate aggregation_metrics_calculation_types';
  RAISE NOTICE '(specify which calculation types can be used for each metric)';
END $$;

COMMIT;