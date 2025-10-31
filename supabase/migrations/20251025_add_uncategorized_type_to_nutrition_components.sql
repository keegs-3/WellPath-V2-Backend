-- =====================================================
-- Add "Uncategorized" Type to All Nutrition Components
-- =====================================================
-- Ensures percentage calculations add up to 100%
-- by capturing entries without a type specified
-- =====================================================

BEGIN;

-- =====================================================
-- 1. Add Uncategorized Reference Data
-- =====================================================

-- Vegetables - Uncategorized
INSERT INTO data_entry_fields_reference (
  reference_category,
  reference_key,
  display_name,
  description,
  sort_order,
  is_active
) VALUES (
  'vegetables_types',
  'uncategorized',
  'Uncategorized',
  'Vegetables without a specific type assigned',
  99,  -- Sort last
  true
) ON CONFLICT (reference_category, reference_key) DO NOTHING;

-- Legumes - Uncategorized
INSERT INTO data_entry_fields_reference (
  reference_category,
  reference_key,
  display_name,
  description,
  sort_order,
  is_active
) VALUES (
  'legumes_types',
  'uncategorized',
  'Uncategorized',
  'Legumes without a specific type assigned',
  99,
  true
) ON CONFLICT (reference_category, reference_key) DO NOTHING;

-- Fruits - Uncategorized
INSERT INTO data_entry_fields_reference (
  reference_category,
  reference_key,
  display_name,
  description,
  sort_order,
  is_active
) VALUES (
  'fruits_types',
  'uncategorized',
  'Uncategorized',
  'Fruits without a specific type assigned',
  99,
  true
) ON CONFLICT (reference_category, reference_key) DO NOTHING;

-- Whole Grains - Uncategorized
INSERT INTO data_entry_fields_reference (
  reference_category,
  reference_key,
  display_name,
  description,
  sort_order,
  is_active
) VALUES (
  'whole_grains_types',
  'uncategorized',
  'Uncategorized',
  'Whole grains without a specific type assigned',
  99,
  true
) ON CONFLICT (reference_category, reference_key) DO NOTHING;

-- Healthy Fats - Uncategorized
INSERT INTO data_entry_fields_reference (
  reference_category,
  reference_key,
  display_name,
  description,
  sort_order,
  is_active
) VALUES (
  'healthy_fats_types',
  'uncategorized',
  'Uncategorized',
  'Healthy fats without a specific type assigned',
  99,
  true
) ON CONFLICT (reference_category, reference_key) DO NOTHING;

-- =====================================================
-- 2. Add Uncategorized Aggregation Metrics
-- =====================================================

-- Vegetables - Uncategorized Aggregation
INSERT INTO aggregation_metrics (
  agg_id,
  metric_name,
  display_name,
  description,
  output_unit,
  is_active
) VALUES (
  'AGG_VEGETABLES_TYPE_UNCATEGORIZED',
  'vegetables_type_uncategorized',
  'Uncategorized Vegetables',
  'Servings of vegetables without type specified',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;

-- Legumes - Uncategorized Aggregation
INSERT INTO aggregation_metrics (
  agg_id,
  metric_name,
  display_name,
  description,
  output_unit,
  is_active
) VALUES (
  'AGG_LEGUMES_TYPE_UNCATEGORIZED',
  'legumes_type_uncategorized',
  'Uncategorized Legumes',
  'Servings of legumes without type specified',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;

-- Fruits - Uncategorized Aggregation
INSERT INTO aggregation_metrics (
  agg_id,
  metric_name,
  display_name,
  description,
  output_unit,
  is_active
) VALUES (
  'AGG_FRUITS_TYPE_UNCATEGORIZED',
  'fruits_type_uncategorized',
  'Uncategorized Fruits',
  'Servings of fruits without type specified',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;

-- Whole Grains - Uncategorized Aggregation
INSERT INTO aggregation_metrics (
  agg_id,
  metric_name,
  display_name,
  description,
  output_unit,
  is_active
) VALUES (
  'AGG_WHOLE_GRAINS_TYPE_UNCATEGORIZED',
  'whole_grains_type_uncategorized',
  'Uncategorized Whole Grains',
  'Servings of whole grains without type specified',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;

-- Healthy Fats - Uncategorized Aggregation
INSERT INTO aggregation_metrics (
  agg_id,
  metric_name,
  display_name,
  description,
  output_unit,
  is_active
) VALUES (
  'AGG_HEALTHY_FATS_TYPE_UNCATEGORIZED',
  'healthy_fats_type_uncategorized',
  'Uncategorized Healthy Fats',
  'Servings of healthy fats without type specified',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;

-- =====================================================
-- 3. Add Aggregation Dependencies
-- =====================================================

-- Vegetables - Uncategorized Dependency
INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id,
  data_entry_field_id,
  dependency_type,
  display_order,
  filter_conditions
) VALUES (
  'AGG_VEGETABLES_TYPE_UNCATEGORIZED',
  'DEF_VEGETABLES_SERVINGS',
  'data_field',
  1,
  '{"reference_field": "DEF_VEGETABLES_TYPE", "reference_value": "uncategorized"}'::jsonb
) ON CONFLICT (agg_metric_id, instance_calculation_id, data_entry_field_id) DO NOTHING;

-- Legumes - Uncategorized Dependency
INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id,
  data_entry_field_id,
  dependency_type,
  display_order,
  filter_conditions
) VALUES (
  'AGG_LEGUMES_TYPE_UNCATEGORIZED',
  'DEF_LEGUMES_SERVINGS',
  'data_field',
  1,
  '{"reference_field": "DEF_LEGUMES_TYPE", "reference_value": "uncategorized"}'::jsonb
) ON CONFLICT (agg_metric_id, instance_calculation_id, data_entry_field_id) DO NOTHING;

-- Fruits - Uncategorized Dependency
INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id,
  data_entry_field_id,
  dependency_type,
  display_order,
  filter_conditions
) VALUES (
  'AGG_FRUITS_TYPE_UNCATEGORIZED',
  'DEF_FRUITS_SERVINGS',
  'data_field',
  1,
  '{"reference_field": "DEF_FRUITS_TYPE", "reference_value": "uncategorized"}'::jsonb
) ON CONFLICT (agg_metric_id, instance_calculation_id, data_entry_field_id) DO NOTHING;

-- Whole Grains - Uncategorized Dependency
INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id,
  data_entry_field_id,
  dependency_type,
  display_order,
  filter_conditions
) VALUES (
  'AGG_WHOLE_GRAINS_TYPE_UNCATEGORIZED',
  'DEF_WHOLE_GRAINS_SERVINGS',
  'data_field',
  1,
  '{"reference_field": "DEF_WHOLE_GRAINS_TYPE", "reference_value": "uncategorized"}'::jsonb
) ON CONFLICT (agg_metric_id, instance_calculation_id, data_entry_field_id) DO NOTHING;

-- Healthy Fats - Uncategorized Dependency
INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id,
  data_entry_field_id,
  dependency_type,
  display_order,
  filter_conditions
) VALUES (
  'AGG_HEALTHY_FATS_TYPE_UNCATEGORIZED',
  'DEF_HEALTHY_FATS_SERVINGS',
  'data_field',
  1,
  '{"reference_field": "DEF_HEALTHY_FATS_TYPE", "reference_value": "uncategorized"}'::jsonb
) ON CONFLICT (agg_metric_id, instance_calculation_id, data_entry_field_id) DO NOTHING;

-- =====================================================
-- 4. Add Calculation Types (SUM + AVG for each)
-- =====================================================

INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES
  -- Vegetables
  ('AGG_VEGETABLES_TYPE_UNCATEGORIZED', 'SUM'),
  ('AGG_VEGETABLES_TYPE_UNCATEGORIZED', 'AVG'),

  -- Legumes
  ('AGG_LEGUMES_TYPE_UNCATEGORIZED', 'SUM'),
  ('AGG_LEGUMES_TYPE_UNCATEGORIZED', 'AVG'),

  -- Fruits
  ('AGG_FRUITS_TYPE_UNCATEGORIZED', 'SUM'),
  ('AGG_FRUITS_TYPE_UNCATEGORIZED', 'AVG'),

  -- Whole Grains
  ('AGG_WHOLE_GRAINS_TYPE_UNCATEGORIZED', 'SUM'),
  ('AGG_WHOLE_GRAINS_TYPE_UNCATEGORIZED', 'AVG'),

  -- Healthy Fats
  ('AGG_HEALTHY_FATS_TYPE_UNCATEGORIZED', 'SUM'),
  ('AGG_HEALTHY_FATS_TYPE_UNCATEGORIZED', 'AVG')
ON CONFLICT (aggregation_metric_id, calculation_type_id) DO NOTHING;

-- =====================================================
-- 5. Add Periods (6 periods for each metric)
-- =====================================================

INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
SELECT agg_id, period_id
FROM (VALUES
  ('AGG_VEGETABLES_TYPE_UNCATEGORIZED'),
  ('AGG_LEGUMES_TYPE_UNCATEGORIZED'),
  ('AGG_FRUITS_TYPE_UNCATEGORIZED'),
  ('AGG_WHOLE_GRAINS_TYPE_UNCATEGORIZED'),
  ('AGG_HEALTHY_FATS_TYPE_UNCATEGORIZED')
) AS metrics(agg_id)
CROSS JOIN (VALUES
  ('hourly'),
  ('daily'),
  ('weekly'),
  ('monthly'),
  ('6month'),
  ('yearly')
) AS periods(period_id)
ON CONFLICT (agg_metric_id, period_id) DO NOTHING;

-- =====================================================
-- Summary Output
-- =====================================================

DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '✅ Added Uncategorized Type to Nutrition Components!';
  RAISE NOTICE '';
  RAISE NOTICE 'Components Updated:';
  RAISE NOTICE '  • Vegetables';
  RAISE NOTICE '  • Legumes';
  RAISE NOTICE '  • Fruits';
  RAISE NOTICE '  • Whole Grains';
  RAISE NOTICE '  • Healthy Fats';
  RAISE NOTICE '';
  RAISE NOTICE 'Added per Component:';
  RAISE NOTICE '  • 1 reference type (uncategorized)';
  RAISE NOTICE '  • 1 aggregation metric (AGG_*_TYPE_UNCATEGORIZED)';
  RAISE NOTICE '  • 1 dependency (filtered by uncategorized)';
  RAISE NOTICE '  • 2 calculation types (SUM + AVG)';
  RAISE NOTICE '  • 6 periods (hourly → yearly)';
  RAISE NOTICE '';
  RAISE NOTICE 'Total Records Added:';
  RAISE NOTICE '  • 5 reference types';
  RAISE NOTICE '  • 5 aggregation metrics';
  RAISE NOTICE '  • 5 dependencies';
  RAISE NOTICE '  • 10 calculation types';
  RAISE NOTICE '  • 30 periods';
  RAISE NOTICE '';
  RAISE NOTICE 'Purpose: Ensures percentage calculations add up to 100%';
  RAISE NOTICE '         by capturing entries without type specified';
  RAISE NOTICE '';
END $$;

COMMIT;
