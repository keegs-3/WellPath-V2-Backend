-- =====================================================================================
-- Create Aggregations for Protein Source Child Fields
-- =====================================================================================
-- Creates aggregation_metrics for each protein source field
-- Covers all periods (daily, weekly, monthly, 6_month, yearly)
-- Covers both SUM and AVG calculation types
-- Links aggregations to source fields via dependencies
-- =====================================================================================

-- =====================================================================================
-- STEP 1: Create Aggregation Metrics for Protein Sources (Servings)
-- =====================================================================================

-- For each protein source field (servings), create aggregation metrics for all periods
INSERT INTO aggregation_metrics (
  agg_id,
  metric_name,
  display_name,
  description,
  output_unit,
  is_active
)
SELECT
  'AGG_' || UPPER(REPLACE(REPLACE(def.field_name, 'protein_', ''), '_servings', '')) || '_SERVINGS',
  REPLACE(def.field_name, '_servings', '') || '_servings_agg',
  def.display_name,
  'Aggregated ' || LOWER(def.display_name) || ' consumption',
  'serving',
  true
FROM data_entry_fields def
WHERE def.parent_field_id = 'DEF_PROTEIN_SERVINGS'
  AND def.is_active = true
ON CONFLICT (agg_id) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description;

-- =====================================================================================
-- STEP 2: Create Aggregation Metrics for Protein Sources (Grams)
-- =====================================================================================

INSERT INTO aggregation_metrics (
  agg_id,
  metric_name,
  display_name,
  description,
  output_unit,
  is_active
)
SELECT
  'AGG_' || UPPER(REPLACE(REPLACE(def.field_name, 'protein_', ''), '_grams', '')) || '_GRAMS',
  REPLACE(def.field_name, '_grams', '') || '_grams_agg',
  def.display_name,
  'Aggregated ' || LOWER(def.display_name) || ' consumption',
  'gram',
  true
FROM data_entry_fields def
WHERE def.parent_field_id = 'DEF_PROTEIN_GRAMS'
  AND def.is_active = true
ON CONFLICT (agg_id) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description;

-- =====================================================================================
-- STEP 3: Link Aggregations to Source Fields (Dependencies)
-- =====================================================================================

-- Servings dependencies
INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id,
  data_entry_field_id,
  dependency_type,
  display_order
)
SELECT
  'AGG_' || UPPER(REPLACE(REPLACE(def.field_name, 'protein_', ''), '_servings', '')) || '_SERVINGS',
  def.field_id,
  'data_field',
  1
FROM data_entry_fields def
WHERE def.parent_field_id = 'DEF_PROTEIN_SERVINGS'
  AND def.is_active = true
ON CONFLICT (agg_metric_id, instance_calculation_id, data_entry_field_id) DO NOTHING;

-- Grams dependencies
INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id,
  data_entry_field_id,
  dependency_type,
  display_order
)
SELECT
  'AGG_' || UPPER(REPLACE(REPLACE(def.field_name, 'protein_', ''), '_grams', '')) || '_GRAMS',
  def.field_id,
  'data_field',
  1
FROM data_entry_fields def
WHERE def.parent_field_id = 'DEF_PROTEIN_GRAMS'
  AND def.is_active = true
ON CONFLICT (agg_metric_id, instance_calculation_id, data_entry_field_id) DO NOTHING;

-- =====================================================================================
-- STEP 4: Create Aggregation Calculation Types (SUM and AVG)
-- =====================================================================================

-- For each aggregation, create calculation types (SUM and AVG)
INSERT INTO aggregation_metrics_calculation_types (
  aggregation_metric_id,
  calculation_type_id
)
SELECT
  agg.agg_id,
  ct.type_id
FROM aggregation_metrics agg
CROSS JOIN calculation_types ct
WHERE (agg.agg_id LIKE 'AGG_%_SERVINGS' OR agg.agg_id LIKE 'AGG_%_GRAMS')
  AND agg.agg_id NOT LIKE '%TO%'  -- Exclude conversion aggregations
  AND (
    agg.agg_id LIKE '%CHICKEN%' OR
    agg.agg_id LIKE '%BEEF%' OR
    agg.agg_id LIKE '%FISH%' OR
    agg.agg_id LIKE '%TOFU%' OR
    agg.agg_id LIKE '%TEMPEH%' OR
    agg.agg_id LIKE '%SEITAN%' OR
    agg.agg_id LIKE '%EGGS%' OR
    agg.agg_id LIKE '%YOGURT%' OR
    agg.agg_id LIKE '%CHEESE%' OR
    agg.agg_id LIKE '%POULTRY%' OR
    agg.agg_id LIKE '%MEAT%' OR
    agg.agg_id LIKE '%POWDER%' OR
    agg.agg_id LIKE '%PLANTPROTEIN%'
  )
  AND ct.type_id IN ('SUM', 'AVG')
ON CONFLICT (aggregation_metric_id, calculation_type_id) DO NOTHING;

-- =====================================================================================
-- STEP 5: Create Aggregation Periods Configuration
-- =====================================================================================

-- For each aggregation, create period configurations (all periods with bar_stacked chart)
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
  agg.agg_id,
  ap.period_id,
  'bar_stacked',  -- All protein source charts are stacked bars
  'temporal',
  ap.x_axis_granularity,
  ap.bars,
  ap.days,
  CASE
    WHEN agg.output_unit = 'serving' THEN 'Servings'
    WHEN agg.output_unit = 'gram' THEN 'Grams'
    ELSE 'Value'
  END,
  true
FROM aggregation_metrics agg
CROSS JOIN aggregation_periods ap
WHERE (agg.agg_id LIKE 'AGG_%_SERVINGS' OR agg.agg_id LIKE 'AGG_%_GRAMS')
  AND agg.agg_id NOT LIKE '%TO%'
  AND (
    agg.agg_id LIKE '%CHICKEN%' OR
    agg.agg_id LIKE '%BEEF%' OR
    agg.agg_id LIKE '%FISH%' OR
    agg.agg_id LIKE '%TOFU%' OR
    agg.agg_id LIKE '%TEMPEH%' OR
    agg.agg_id LIKE '%SEITAN%' OR
    agg.agg_id LIKE '%EGGS%' OR
    agg.agg_id LIKE '%YOGURT%' OR
    agg.agg_id LIKE '%CHEESE%' OR
    agg.agg_id LIKE '%POULTRY%' OR
    agg.agg_id LIKE '%MEAT%' OR
    agg.agg_id LIKE '%POWDER%' OR
    agg.agg_id LIKE '%PLANTPROTEIN%'
  )
ON CONFLICT DO NOTHING;

-- =====================================================================================
-- VERIFICATION
-- =====================================================================================

-- Show created aggregations (sample: chicken, tofu, beef)
SELECT
  agg.agg_id,
  agg.metric_name,
  agg.output_unit,
  COUNT(DISTINCT amd.data_entry_field_id) as field_deps,
  COUNT(DISTINCT amp.period_id) as periods,
  COUNT(DISTINCT amct.calculation_type_id) as calc_types
FROM aggregation_metrics agg
LEFT JOIN aggregation_metrics_dependencies amd ON amd.agg_metric_id = agg.agg_id
LEFT JOIN aggregation_metrics_calculation_types amct ON amct.aggregation_metric_id = agg.agg_id
LEFT JOIN aggregation_metrics_periods amp ON amp.agg_metric_id = agg.agg_id
WHERE agg.agg_id LIKE 'AGG_%CHICKEN%'
   OR agg.agg_id LIKE 'AGG_%TOFU%'
   OR agg.agg_id LIKE 'AGG_%BEEF%'
GROUP BY agg.agg_id, agg.metric_name, agg.output_unit
ORDER BY agg.agg_id;

-- Count total protein source aggregations created
SELECT
  'Protein Source Aggregations Created' as summary,
  COUNT(*) as total
FROM aggregation_metrics
WHERE (agg_id LIKE '%CHICKEN%' OR
       agg_id LIKE '%BEEF%' OR
       agg_id LIKE '%FISH%' OR
       agg_id LIKE '%TOFU%' OR
       agg_id LIKE '%TEMPEH%' OR
       agg_id LIKE '%SEITAN%' OR
       agg_id LIKE '%EGGS%' OR
       agg_id LIKE '%YOGURT%' OR
       agg_id LIKE '%CHEESE%' OR
       agg_id LIKE '%POULTRY%' OR
       agg_id LIKE '%MEAT%' OR
       agg_id LIKE '%POWDER%' OR
       agg_id LIKE '%PLANTPROTEIN%')
  AND agg_id NOT LIKE '%TO%';
