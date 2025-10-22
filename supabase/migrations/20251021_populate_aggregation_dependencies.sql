-- =====================================================
-- Populate Aggregation Metrics Dependencies
-- =====================================================
-- Links each aggregation_metric to its source:
-- - Data entry fields (for direct field aggregations)
-- - Instance calculations (for calculated value aggregations)
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- Clear existing
TRUNCATE TABLE aggregation_metrics_dependencies CASCADE;

-- =====================================================
-- PART 1: Link Instance Calculation Aggregations
-- =====================================================
-- Each AGG_* that matches an instance calculation gets linked to that calc

INSERT INTO aggregation_metrics_dependencies (
  id, agg_metric_id, instance_calculation_id, dependency_type
)
SELECT
  gen_random_uuid(),
  am.agg_id,
  ic.calc_id,
  'instance_calc'
FROM aggregation_metrics am
JOIN instance_calculations ic
  ON UPPER(ic.calc_name) = REPLACE(am.agg_id, 'AGG_', '')
WHERE ic.is_active = true;


-- =====================================================
-- PART 2: Link Data Entry Field Aggregations
-- =====================================================
-- Each AGG_* that matches a data entry field gets linked to that field

INSERT INTO aggregation_metrics_dependencies (
  id, agg_metric_id, data_entry_field_id, dependency_type
)
SELECT
  gen_random_uuid(),
  am.agg_id,
  def.field_id,
  'data_field'
FROM aggregation_metrics am
JOIN data_entry_fields def
  ON UPPER(REPLACE(def.field_name, '_id', '')) = REPLACE(am.agg_id, 'AGG_', '')
WHERE def.is_active = true
AND def.field_id NOT IN (
  -- Exclude fields that are dependencies for instance calculations
  -- (we aggregate the calculation output, not the field directly)
  SELECT DISTINCT data_entry_field_id
  FROM instance_calculations_dependencies
);


-- =====================================================
-- Summary
-- =====================================================

DO $$
DECLARE
  total_deps INT;
  field_deps INT;
  calc_deps INT;
  unlinked_aggs INT;
BEGIN
  SELECT COUNT(*) INTO total_deps
  FROM aggregation_metrics_dependencies;

  SELECT COUNT(*) INTO field_deps
  FROM aggregation_metrics_dependencies
  WHERE data_entry_field_id IS NOT NULL;

  SELECT COUNT(*) INTO calc_deps
  FROM aggregation_metrics_dependencies
  WHERE instance_calculation_id IS NOT NULL;

  SELECT COUNT(*) INTO unlinked_aggs
  FROM aggregation_metrics am
  WHERE NOT EXISTS (
    SELECT 1 FROM aggregation_metrics_dependencies amd
    WHERE amd.agg_metric_id = am.agg_id
  );

  RAISE NOTICE '===========================================';
  RAISE NOTICE 'Aggregation Metrics Dependencies Created';
  RAISE NOTICE '===========================================';
  RAISE NOTICE 'Total dependencies: %', total_deps;
  RAISE NOTICE '';
  RAISE NOTICE 'Breakdown:';
  RAISE NOTICE '  Linked to data_entry_fields: %', field_deps;
  RAISE NOTICE '  Linked to instance_calculations: %', calc_deps;
  RAISE NOTICE '  Unlinked aggregations: %', unlinked_aggs;

  IF unlinked_aggs > 0 THEN
    RAISE NOTICE '';
    RAISE NOTICE 'WARNING: % aggregations have no dependencies!', unlinked_aggs;
    RAISE NOTICE 'Run this query to see them:';
    RAISE NOTICE 'SELECT am.agg_id, am.metric_name FROM aggregation_metrics am';
    RAISE NOTICE 'WHERE NOT EXISTS (SELECT 1 FROM aggregation_metrics_dependencies amd WHERE amd.agg_metric_id = am.agg_id);';
  END IF;
END $$;

COMMIT;
