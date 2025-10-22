-- =====================================================
-- Create Variety/Diversity Aggregations
-- =====================================================
-- Track variety of food sources for recommendations like:
-- - "Eat 5 different types of vegetables per day"
-- - "Try 7 different fruits this week"
-- - "Consume 3 different protein sources weekly"
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Create Aggregation Metrics
-- =====================================================

INSERT INTO aggregation_metrics (agg_id, metric_name, display_name, description, output_unit, is_active)
VALUES
-- Nutritional variety metrics
('AGG_VEGETABLE_VARIETY', 'vegetable_variety_agg', 'Vegetable Variety', 'Count of unique vegetable types consumed', 'count', true),
('AGG_FRUIT_VARIETY', 'fruit_variety_agg', 'Fruit Variety', 'Count of unique fruit types consumed', 'count', true),
('AGG_PROTEIN_VARIETY', 'protein_variety_agg', 'Protein Variety', 'Count of unique protein types consumed', 'count', true),
('AGG_FIBER_SOURCE_VARIETY', 'fiber_source_variety_agg', 'Fiber Source Variety', 'Count of unique fiber sources consumed', 'count', true),
('AGG_LEGUME_VARIETY', 'legume_variety_agg', 'Legume Variety', 'Count of unique legume types consumed', 'count', true),
('AGG_NUT_SEED_VARIETY', 'nut_seed_variety_agg', 'Nut/Seed Variety', 'Count of unique nut/seed types consumed', 'count', true),
('AGG_WHOLE_GRAIN_VARIETY', 'whole_grain_variety_agg', 'Whole Grain Variety', 'Count of unique whole grain types consumed', 'count', true)

ON CONFLICT (agg_id) DO UPDATE SET
  metric_name = EXCLUDED.metric_name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  output_unit = EXCLUDED.output_unit,
  is_active = EXCLUDED.is_active;


-- =====================================================
-- PART 2: Link to Data Entry Fields (not calculations)
-- =====================================================

INSERT INTO aggregation_metrics_dependencies
(agg_metric_id, data_entry_field_id, dependency_type, display_order)
VALUES
('AGG_VEGETABLE_VARIETY', 'DEF_VEGETABLE_TYPE', 'data_field', 1),
('AGG_FRUIT_VARIETY', 'DEF_FRUIT_TYPE', 'data_field', 1),
('AGG_PROTEIN_VARIETY', 'DEF_PROTEIN_TYPE', 'data_field', 1),
('AGG_FIBER_SOURCE_VARIETY', 'DEF_FIBER_SOURCE', 'data_field', 1),
('AGG_LEGUME_VARIETY', 'DEF_LEGUME_TYPE', 'data_field', 1),
('AGG_NUT_SEED_VARIETY', 'DEF_NUT_SEED_TYPE', 'data_field', 1),
('AGG_WHOLE_GRAIN_VARIETY', 'DEF_WHOLE_GRAIN_TYPE', 'data_field', 1)

ON CONFLICT (agg_metric_id, instance_calculation_id, data_entry_field_id) DO NOTHING;


-- =====================================================
-- PART 3: Configure Calculation Type (COUNT_DISTINCT)
-- =====================================================

INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES
('AGG_VEGETABLE_VARIETY', 'COUNT_DISTINCT'),
('AGG_FRUIT_VARIETY', 'COUNT_DISTINCT'),
('AGG_PROTEIN_VARIETY', 'COUNT_DISTINCT'),
('AGG_FIBER_SOURCE_VARIETY', 'COUNT_DISTINCT'),
('AGG_LEGUME_VARIETY', 'COUNT_DISTINCT'),
('AGG_NUT_SEED_VARIETY', 'COUNT_DISTINCT'),
('AGG_WHOLE_GRAIN_VARIETY', 'COUNT_DISTINCT')

ON CONFLICT (aggregation_metric_id, calculation_type_id) DO NOTHING;


-- =====================================================
-- PART 4: Configure Periods (daily, weekly)
-- =====================================================

INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES
-- Vegetables
('AGG_VEGETABLE_VARIETY', 'daily'),
('AGG_VEGETABLE_VARIETY', 'weekly'),

-- Fruits
('AGG_FRUIT_VARIETY', 'daily'),
('AGG_FRUIT_VARIETY', 'weekly'),

-- Protein
('AGG_PROTEIN_VARIETY', 'daily'),
('AGG_PROTEIN_VARIETY', 'weekly'),

-- Fiber sources
('AGG_FIBER_SOURCE_VARIETY', 'daily'),
('AGG_FIBER_SOURCE_VARIETY', 'weekly'),

-- Legumes
('AGG_LEGUME_VARIETY', 'daily'),
('AGG_LEGUME_VARIETY', 'weekly'),

-- Nuts/Seeds
('AGG_NUT_SEED_VARIETY', 'daily'),
('AGG_NUT_SEED_VARIETY', 'weekly'),

-- Whole Grains
('AGG_WHOLE_GRAIN_VARIETY', 'daily'),
('AGG_WHOLE_GRAIN_VARIETY', 'weekly')

ON CONFLICT DO NOTHING;


-- =====================================================
-- Summary
-- =====================================================

DO $$
DECLARE
  agg_count INT;
  dep_count INT;
  calc_count INT;
  period_count INT;
BEGIN
  SELECT COUNT(*) INTO agg_count FROM aggregation_metrics WHERE agg_id LIKE 'AGG_%_VARIETY';
  SELECT COUNT(*) INTO dep_count FROM aggregation_metrics_dependencies WHERE agg_metric_id LIKE 'AGG_%_VARIETY';
  SELECT COUNT(*) INTO calc_count FROM aggregation_metrics_calculation_types WHERE aggregation_metric_id LIKE 'AGG_%_VARIETY';
  SELECT COUNT(*) INTO period_count FROM aggregation_metrics_periods WHERE agg_metric_id LIKE 'AGG_%_VARIETY';

  RAISE NOTICE '✅ Variety/Diversity Aggregations Created';
  RAISE NOTICE '';
  RAISE NOTICE 'Summary:';
  RAISE NOTICE '  Aggregation Metrics: %', agg_count;
  RAISE NOTICE '  Dependencies: %', dep_count;
  RAISE NOTICE '  Calculation Types: %', calc_count;
  RAISE NOTICE '  Periods: %', period_count;
  RAISE NOTICE '';
  RAISE NOTICE 'Configured Aggregations:';
  RAISE NOTICE '  1. Vegetable Variety - COUNT_DISTINCT (daily, weekly)';
  RAISE NOTICE '  2. Fruit Variety - COUNT_DISTINCT (daily, weekly)';
  RAISE NOTICE '  3. Protein Variety - COUNT_DISTINCT (daily, weekly)';
  RAISE NOTICE '  4. Fiber Source Variety - COUNT_DISTINCT (daily, weekly)';
  RAISE NOTICE '  5. Legume Variety - COUNT_DISTINCT (daily, weekly)';
  RAISE NOTICE '  6. Nut/Seed Variety - COUNT_DISTINCT (daily, weekly)';
  RAISE NOTICE '  7. Whole Grain Variety - COUNT_DISTINCT (daily, weekly)';
  RAISE NOTICE '';
  RAISE NOTICE 'Perfect for recommendations like:';
  RAISE NOTICE '  "Eat 5 different types of vegetables per day"';
  RAISE NOTICE '  "Try 7 different fruits this week"';
END $$;

COMMIT;
