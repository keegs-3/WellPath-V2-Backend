-- =====================================================================================
-- Fix Protein Timing and Type Sections
-- =====================================================================================
-- Creates proper aggregations for:
-- 1. Timing: Breakfast, Lunch, Dinner (filtered by entry_timestamp hour)
-- 2. Type: All 6 protein types (processed_meat, red_meat, fatty_fish, lean_protein, plant_based, supplement)
-- =====================================================================================

-- =====================================================================================
-- STEP 1: Create Instance Calculations for Meal Times
-- =====================================================================================

-- These calculations will filter protein entries by time of day and create virtual fields

INSERT INTO instance_calculations (
  calc_id,
  calc_name,
  display_name,
  description,
  calculation_config,
  is_active
) VALUES
(
  'CALC_PROTEIN_BREAKFAST',
  'protein_breakfast',
  'Breakfast Protein',
  'Protein consumed at breakfast (5am-11am)',
  jsonb_build_object(
    'operation', 'time_filter',
    'source_field', 'DEF_PROTEIN_GRAMS',
    'time_range_start', 5,
    'time_range_end', 11,
    'output_field', 'protein_breakfast_grams',
    'output_unit', 'gram'
  ),
  true
),
(
  'CALC_PROTEIN_LUNCH',
  'protein_lunch',
  'Lunch Protein',
  'Protein consumed at lunch (11am-4pm)',
  jsonb_build_object(
    'operation', 'time_filter',
    'source_field', 'DEF_PROTEIN_GRAMS',
    'time_range_start', 11,
    'time_range_end', 16,
    'output_field', 'protein_lunch_grams',
    'output_unit', 'gram'
  ),
  true
),
(
  'CALC_PROTEIN_DINNER',
  'protein_dinner',
  'Dinner Protein',
  'Protein consumed at dinner (4pm-10pm)',
  jsonb_build_object(
    'operation', 'time_filter',
    'source_field', 'DEF_PROTEIN_GRAMS',
    'time_range_start', 16,
    'time_range_end', 22,
    'output_field', 'protein_dinner_grams',
    'output_unit', 'gram'
  ),
  true
)
ON CONFLICT (calc_id) DO UPDATE SET
  calculation_config = EXCLUDED.calculation_config,
  is_active = EXCLUDED.is_active;

-- =====================================================================================
-- STEP 2: Create Aggregations for Meal Times
-- =====================================================================================

-- Create aggregation metrics
INSERT INTO aggregation_metrics (
  agg_id,
  metric_name,
  display_name,
  description,
  output_unit,
  is_active
) VALUES
  ('AGG_PROTEIN_BREAKFAST_GRAMS', 'protein_breakfast_grams', 'Breakfast Protein', 'Protein consumed at breakfast', 'gram', true),
  ('AGG_PROTEIN_LUNCH_GRAMS', 'protein_lunch_grams', 'Lunch Protein', 'Protein consumed at lunch', 'gram', true),
  ('AGG_PROTEIN_DINNER_GRAMS', 'protein_dinner_grams', 'Dinner Protein', 'Protein consumed at dinner', 'gram', true)
ON CONFLICT (agg_id) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  is_active = EXCLUDED.is_active;

-- Link to source field (DEF_PROTEIN_GRAMS)
INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id,
  data_entry_field_id,
  dependency_type,
  display_order
) VALUES
  ('AGG_PROTEIN_BREAKFAST_GRAMS', 'DEF_PROTEIN_GRAMS', 'data_field', 1),
  ('AGG_PROTEIN_LUNCH_GRAMS', 'DEF_PROTEIN_GRAMS', 'data_field', 1),
  ('AGG_PROTEIN_DINNER_GRAMS', 'DEF_PROTEIN_GRAMS', 'data_field', 1)
ON CONFLICT DO NOTHING;

-- Add calculation types (SUM and AVG)
INSERT INTO aggregation_metrics_calculation_types (
  aggregation_metric_id,
  calculation_type_id
)
SELECT agg_id, calc_type
FROM (VALUES
  ('AGG_PROTEIN_BREAKFAST_GRAMS'),
  ('AGG_PROTEIN_LUNCH_GRAMS'),
  ('AGG_PROTEIN_DINNER_GRAMS')
) AS aggs(agg_id)
CROSS JOIN (VALUES ('SUM'), ('AVG')) AS calcs(calc_type)
ON CONFLICT DO NOTHING;

-- Add periods
INSERT INTO aggregation_metrics_periods (
  agg_metric_id,
  period_id,
  chart_type,
  x_axis_type,
  x_axis_granularity,
  bars,
  days,
  y_axis_label,
  y_axis_auto_scale
)
SELECT
  agg_id,
  ap.period_id,
  'bar_stacked',
  'temporal',
  ap.x_axis_granularity,
  ap.bars,
  ap.days,
  'Grams',
  true
FROM (VALUES
  ('AGG_PROTEIN_BREAKFAST_GRAMS'),
  ('AGG_PROTEIN_LUNCH_GRAMS'),
  ('AGG_PROTEIN_DINNER_GRAMS')
) AS aggs(agg_id)
CROSS JOIN aggregation_periods ap
ON CONFLICT DO NOTHING;

-- =====================================================================================
-- STEP 3: Update Timing Section Child Display Metrics
-- =====================================================================================

-- Remove old incorrect links
DELETE FROM parent_child_display_metrics_aggregations
WHERE child_metric_id IN ('DISP_PROTEIN_BREAKFAST', 'DISP_PROTEIN_LUNCH', 'DISP_PROTEIN_DINNER');

-- Add correct links
INSERT INTO parent_child_display_metrics_aggregations (
  parent_metric_id,
  child_metric_id,
  agg_metric_id,
  period_type,
  calculation_type_id
)
SELECT
  NULL,
  child_id,
  agg_id,
  ap.period_id,
  'AVG'
FROM (VALUES
  ('DISP_PROTEIN_BREAKFAST', 'AGG_PROTEIN_BREAKFAST_GRAMS'),
  ('DISP_PROTEIN_LUNCH', 'AGG_PROTEIN_LUNCH_GRAMS'),
  ('DISP_PROTEIN_DINNER', 'AGG_PROTEIN_DINNER_GRAMS')
) AS mappings(child_id, agg_id)
CROSS JOIN aggregation_periods ap
ON CONFLICT DO NOTHING;

-- Also add SUM for daily
INSERT INTO parent_child_display_metrics_aggregations (
  parent_metric_id,
  child_metric_id,
  agg_metric_id,
  period_type,
  calculation_type_id
)
SELECT
  NULL,
  child_id,
  agg_id,
  'daily',
  'SUM'
FROM (VALUES
  ('DISP_PROTEIN_BREAKFAST', 'AGG_PROTEIN_BREAKFAST_GRAMS'),
  ('DISP_PROTEIN_LUNCH', 'AGG_PROTEIN_LUNCH_GRAMS'),
  ('DISP_PROTEIN_DINNER', 'AGG_PROTEIN_DINNER_GRAMS')
) AS mappings(child_id, agg_id)
ON CONFLICT DO NOTHING;

-- =====================================================================================
-- STEP 4: Create Aggregations for Protein Types (6 types)
-- =====================================================================================

-- Create aggregation metrics for each type
INSERT INTO aggregation_metrics (
  agg_id,
  metric_name,
  display_name,
  description,
  output_unit,
  is_active
) VALUES
  ('AGG_PROTEIN_TYPE_PROCESSED_MEAT', 'protein_type_processed_meat', 'Processed Meat', 'Protein from processed meat', 'gram', true),
  ('AGG_PROTEIN_TYPE_RED_MEAT', 'protein_type_red_meat', 'Red Meat', 'Protein from red meat', 'gram', true),
  ('AGG_PROTEIN_TYPE_FATTY_FISH', 'protein_type_fatty_fish', 'Fatty Fish', 'Protein from fatty fish', 'gram', true),
  ('AGG_PROTEIN_TYPE_LEAN_PROTEIN', 'protein_type_lean_protein', 'Lean Protein', 'Protein from lean sources', 'gram', true),
  ('AGG_PROTEIN_TYPE_PLANT_BASED', 'protein_type_plant_based', 'Plant-based', 'Protein from plant sources', 'gram', true),
  ('AGG_PROTEIN_TYPE_SUPPLEMENT', 'protein_type_supplement', 'Supplement', 'Protein from supplements', 'gram', true)
ON CONFLICT (agg_id) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  is_active = EXCLUDED.is_active;

-- Link to source field
INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id,
  data_entry_field_id,
  dependency_type,
  display_order
)
SELECT agg_id, 'DEF_PROTEIN_GRAMS', 'data_field', 1
FROM (VALUES
  ('AGG_PROTEIN_TYPE_PROCESSED_MEAT'),
  ('AGG_PROTEIN_TYPE_RED_MEAT'),
  ('AGG_PROTEIN_TYPE_FATTY_FISH'),
  ('AGG_PROTEIN_TYPE_LEAN_PROTEIN'),
  ('AGG_PROTEIN_TYPE_PLANT_BASED'),
  ('AGG_PROTEIN_TYPE_SUPPLEMENT')
) AS aggs(agg_id)
ON CONFLICT DO NOTHING;

-- Add calculation types
INSERT INTO aggregation_metrics_calculation_types (
  aggregation_metric_id,
  calculation_type_id
)
SELECT agg_id, calc_type
FROM (VALUES
  ('AGG_PROTEIN_TYPE_PROCESSED_MEAT'),
  ('AGG_PROTEIN_TYPE_RED_MEAT'),
  ('AGG_PROTEIN_TYPE_FATTY_FISH'),
  ('AGG_PROTEIN_TYPE_LEAN_PROTEIN'),
  ('AGG_PROTEIN_TYPE_PLANT_BASED'),
  ('AGG_PROTEIN_TYPE_SUPPLEMENT')
) AS aggs(agg_id)
CROSS JOIN (VALUES ('SUM'), ('AVG')) AS calcs(calc_type)
ON CONFLICT DO NOTHING;

-- Add periods
INSERT INTO aggregation_metrics_periods (
  agg_metric_id,
  period_id,
  chart_type,
  x_axis_type,
  x_axis_granularity,
  bars,
  days,
  y_axis_label,
  y_axis_auto_scale
)
SELECT
  agg_id,
  ap.period_id,
  'bar_stacked',
  'temporal',
  ap.x_axis_granularity,
  ap.bars,
  ap.days,
  'Grams',
  true
FROM (VALUES
  ('AGG_PROTEIN_TYPE_PROCESSED_MEAT'),
  ('AGG_PROTEIN_TYPE_RED_MEAT'),
  ('AGG_PROTEIN_TYPE_FATTY_FISH'),
  ('AGG_PROTEIN_TYPE_LEAN_PROTEIN'),
  ('AGG_PROTEIN_TYPE_PLANT_BASED'),
  ('AGG_PROTEIN_TYPE_SUPPLEMENT')
) AS aggs(agg_id)
CROSS JOIN aggregation_periods ap
ON CONFLICT DO NOTHING;

-- =====================================================================================
-- STEP 5: Create Child Display Metrics for Type Section
-- =====================================================================================

-- Delete old Type section children (plant-based only)
DELETE FROM parent_child_display_metrics_aggregations
WHERE child_metric_id IN ('DISP_PLANTBASED_PROTEIN_GRAMS', 'DISP_PLANTBASED_PROTEIN_PERCENTAGE');

DELETE FROM child_display_metrics
WHERE section_id = 'SECTION_PROTEIN_TYPE';

-- Create new children for all 6 types
INSERT INTO child_display_metrics (
  child_metric_id,
  parent_metric_id,
  section_id,
  child_name,
  child_description,
  data_series_order,
  supported_units,
  default_unit,
  inherit_parent_unit,
  is_active
) VALUES
  ('DISP_PROTEIN_TYPE_PROCESSED_MEAT', 'DISP_PROTEIN_SERVINGS', 'SECTION_PROTEIN_TYPE', 'Processed Meat', 'Protein from processed meat', 1, '["grams"]', 'gram', true, true),
  ('DISP_PROTEIN_TYPE_RED_MEAT', 'DISP_PROTEIN_SERVINGS', 'SECTION_PROTEIN_TYPE', 'Red Meat', 'Protein from red meat', 2, '["grams"]', 'gram', true, true),
  ('DISP_PROTEIN_TYPE_FATTY_FISH', 'DISP_PROTEIN_SERVINGS', 'SECTION_PROTEIN_TYPE', 'Fatty Fish', 'Protein from fatty fish', 3, '["grams"]', 'gram', true, true),
  ('DISP_PROTEIN_TYPE_LEAN_PROTEIN', 'DISP_PROTEIN_SERVINGS', 'SECTION_PROTEIN_TYPE', 'Lean Protein', 'Protein from lean sources', 4, '["grams"]', 'gram', true, true),
  ('DISP_PROTEIN_TYPE_PLANT_BASED', 'DISP_PROTEIN_SERVINGS', 'SECTION_PROTEIN_TYPE', 'Plant-based', 'Protein from plant sources', 5, '["grams"]', 'gram', true, true),
  ('DISP_PROTEIN_TYPE_SUPPLEMENT', 'DISP_PROTEIN_SERVINGS', 'SECTION_PROTEIN_TYPE', 'Supplement', 'Protein from supplements', 6, '["grams"]', 'gram', true, true)
ON CONFLICT (child_metric_id) DO UPDATE SET
  child_name = EXCLUDED.child_name,
  data_series_order = EXCLUDED.data_series_order,
  is_active = EXCLUDED.is_active;

-- Link type children to aggregations
INSERT INTO parent_child_display_metrics_aggregations (
  parent_metric_id,
  child_metric_id,
  agg_metric_id,
  period_type,
  calculation_type_id
)
SELECT
  NULL,
  child_id,
  agg_id,
  ap.period_id,
  'AVG'
FROM (VALUES
  ('DISP_PROTEIN_TYPE_PROCESSED_MEAT', 'AGG_PROTEIN_TYPE_PROCESSED_MEAT'),
  ('DISP_PROTEIN_TYPE_RED_MEAT', 'AGG_PROTEIN_TYPE_RED_MEAT'),
  ('DISP_PROTEIN_TYPE_FATTY_FISH', 'AGG_PROTEIN_TYPE_FATTY_FISH'),
  ('DISP_PROTEIN_TYPE_LEAN_PROTEIN', 'AGG_PROTEIN_TYPE_LEAN_PROTEIN'),
  ('DISP_PROTEIN_TYPE_PLANT_BASED', 'AGG_PROTEIN_TYPE_PLANT_BASED'),
  ('DISP_PROTEIN_TYPE_SUPPLEMENT', 'AGG_PROTEIN_TYPE_SUPPLEMENT')
) AS mappings(child_id, agg_id)
CROSS JOIN aggregation_periods ap
ON CONFLICT DO NOTHING;

-- Also add SUM for daily
INSERT INTO parent_child_display_metrics_aggregations (
  parent_metric_id,
  child_metric_id,
  agg_metric_id,
  period_type,
  calculation_type_id
)
SELECT
  NULL,
  child_id,
  agg_id,
  'daily',
  'SUM'
FROM (VALUES
  ('DISP_PROTEIN_TYPE_PROCESSED_MEAT', 'AGG_PROTEIN_TYPE_PROCESSED_MEAT'),
  ('DISP_PROTEIN_TYPE_RED_MEAT', 'AGG_PROTEIN_TYPE_RED_MEAT'),
  ('DISP_PROTEIN_TYPE_FATTY_FISH', 'AGG_PROTEIN_TYPE_FATTY_FISH'),
  ('DISP_PROTEIN_TYPE_LEAN_PROTEIN', 'AGG_PROTEIN_TYPE_LEAN_PROTEIN'),
  ('DISP_PROTEIN_TYPE_PLANT_BASED', 'AGG_PROTEIN_TYPE_PLANT_BASED'),
  ('DISP_PROTEIN_TYPE_SUPPLEMENT', 'AGG_PROTEIN_TYPE_SUPPLEMENT')
) AS mappings(child_id, agg_id)
ON CONFLICT DO NOTHING;

-- =====================================================================================
-- VERIFICATION
-- =====================================================================================

-- Show Timing section structure
SELECT
  'TIMING SECTION' as section,
  cdm.child_name,
  pca.agg_metric_id,
  COUNT(DISTINCT pca.period_type) as periods
FROM child_display_metrics cdm
LEFT JOIN parent_child_display_metrics_aggregations pca ON pca.child_metric_id = cdm.child_metric_id
WHERE cdm.section_id = 'SECTION_PROTEIN_TIMING'
GROUP BY cdm.child_name, pca.agg_metric_id
ORDER BY cdm.data_series_order;

-- Show Type section structure
SELECT
  'TYPE SECTION' as section,
  cdm.child_name,
  pca.agg_metric_id,
  COUNT(DISTINCT pca.period_type) as periods
FROM child_display_metrics cdm
LEFT JOIN parent_child_display_metrics_aggregations pca ON pca.child_metric_id = cdm.child_metric_id
WHERE cdm.section_id = 'SECTION_PROTEIN_TYPE'
GROUP BY cdm.child_name, pca.agg_metric_id, cdm.data_series_order
ORDER BY cdm.data_series_order;
