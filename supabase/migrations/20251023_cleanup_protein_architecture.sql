-- =====================================================================================
-- Cleanup Protein Architecture
-- =====================================================================================
-- Simplifies protein tracking to grams-only with high-level types
-- Removes granular food source tracking (eggs, chicken, etc.)
-- Standardizes conversion: 1 serving = 25g protein
-- =====================================================================================

-- =====================================================================================
-- STEP 1: Delete Sources Section (too granular)
-- =====================================================================================

DELETE FROM parent_child_display_metrics_aggregations
WHERE child_metric_id IN (
  SELECT child_metric_id
  FROM child_display_metrics
  WHERE section_id = 'SECTION_PROTEIN_SOURCES_SERVINGS'
);

DELETE FROM child_display_metrics
WHERE section_id = 'SECTION_PROTEIN_SOURCES_SERVINGS';

DELETE FROM parent_detail_sections
WHERE section_id = 'SECTION_PROTEIN_SOURCES_SERVINGS';

-- =====================================================================================
-- STEP 2: Delete Protein Source Child Fields (chicken, eggs, tofu, etc.)
-- =====================================================================================

-- Delete patient data entries for child fields
DELETE FROM patient_data_entries
WHERE field_id IN (
  SELECT field_id FROM data_entry_fields
  WHERE parent_field_id IN ('DEF_PROTEIN_GRAMS', 'DEF_PROTEIN_SERVINGS')
);

-- Delete aggregation results for child fields
DELETE FROM aggregation_results_cache
WHERE agg_metric_id IN (
  SELECT agg_id FROM aggregation_metrics
  WHERE agg_id LIKE 'AGG_%_GRAMS'
    AND agg_id NOT IN ('AGG_PROTEIN_GRAMS', 'AGG_FIBER_GRAMS')
);

-- Delete aggregation configs
DELETE FROM aggregation_metrics_periods
WHERE agg_metric_id IN (
  SELECT agg_id FROM aggregation_metrics
  WHERE agg_id LIKE 'AGG_COTTAGE%'
     OR agg_id LIKE 'AGG_EGGS%'
     OR agg_id LIKE 'AGG_FISH%'
     OR agg_id LIKE 'AGG_TOFU%'
     OR agg_id LIKE 'AGG_BEEF%'
     OR agg_id LIKE 'AGG_POULTRY%'
     OR agg_id LIKE 'AGG_YOGURT%'
     OR agg_id LIKE 'AGG_TEMPEH%'
     OR agg_id LIKE 'AGG_SEITAN%'
     OR agg_id LIKE 'AGG_POWDER%'
     OR agg_id LIKE 'AGG_MEAT%'
     OR agg_id LIKE 'AGG_PLANT_PROTEIN%'
);

DELETE FROM aggregation_metrics_calculation_types
WHERE aggregation_metric_id IN (
  SELECT agg_id FROM aggregation_metrics
  WHERE agg_id LIKE 'AGG_COTTAGE%'
     OR agg_id LIKE 'AGG_EGGS%'
     OR agg_id LIKE 'AGG_FISH%'
     OR agg_id LIKE 'AGG_TOFU%'
     OR agg_id LIKE 'AGG_BEEF%'
     OR agg_id LIKE 'AGG_POULTRY%'
     OR agg_id LIKE 'AGG_YOGURT%'
     OR agg_id LIKE 'AGG_TEMPEH%'
     OR agg_id LIKE 'AGG_SEITAN%'
     OR agg_id LIKE 'AGG_POWDER%'
     OR agg_id LIKE 'AGG_MEAT%'
     OR agg_id LIKE 'AGG_PLANT_PROTEIN%'
);

DELETE FROM aggregation_metrics_dependencies
WHERE agg_metric_id IN (
  SELECT agg_id FROM aggregation_metrics
  WHERE agg_id LIKE 'AGG_COTTAGE%'
     OR agg_id LIKE 'AGG_EGGS%'
     OR agg_id LIKE 'AGG_FISH%'
     OR agg_id LIKE 'AGG_TOFU%'
     OR agg_id LIKE 'AGG_BEEF%'
     OR agg_id LIKE 'AGG_POULTRY%'
     OR agg_id LIKE 'AGG_YOGURT%'
     OR agg_id LIKE 'AGG_TEMPEH%'
     OR agg_id LIKE 'AGG_SEITAN%'
     OR agg_id LIKE 'AGG_POWDER%'
     OR agg_id LIKE 'AGG_MEAT%'
     OR agg_id LIKE 'AGG_PLANT_PROTEIN%'
);

DELETE FROM aggregation_metrics
WHERE agg_id LIKE 'AGG_COTTAGE%'
   OR agg_id LIKE 'AGG_EGGS%'
   OR agg_id LIKE 'AGG_FISH%'
   OR agg_id LIKE 'AGG_TOFU%'
   OR agg_id LIKE 'AGG_BEEF%'
   OR agg_id LIKE 'AGG_POULTRY%'
   OR agg_id LIKE 'AGG_YOGURT%'
   OR agg_id LIKE 'AGG_TEMPEH%'
   OR agg_id LIKE 'AGG_SEITAN%'
   OR agg_id LIKE 'AGG_POWDER%'
   OR agg_id LIKE 'AGG_MEAT%'
   OR agg_id LIKE 'AGG_PLANT_PROTEIN%';

-- Remove from field_registry
DELETE FROM field_registry
WHERE field_id IN (
  SELECT field_id FROM data_entry_fields
  WHERE parent_field_id IN ('DEF_PROTEIN_GRAMS', 'DEF_PROTEIN_SERVINGS')
);

-- Mark child fields as deprecated
UPDATE data_entry_fields
SET is_deprecated = true, is_active = false
WHERE parent_field_id IN ('DEF_PROTEIN_GRAMS', 'DEF_PROTEIN_SERVINGS');

-- =====================================================================================
-- STEP 3: Update Protein Type Options (6 high-level categories)
-- =====================================================================================

-- Clear old protein types
UPDATE def_ref_protein_types SET is_active = false;

-- Insert new simplified types
INSERT INTO def_ref_protein_types (
  protein_type_key,
  display_name,
  category,
  typical_protein_grams,
  is_active
) VALUES
  ('processed_meat', 'Processed Meat', 'animal', 20, true),
  ('red_meat', 'Red Meat', 'animal', 25, true),
  ('fatty_fish', 'Fatty Fish', 'animal', 25, true),
  ('lean_protein', 'Lean Protein', 'animal', 25, true),
  ('plant_based', 'Plant-based', 'plant', 20, true),
  ('supplement', 'Supplement', 'supplement', 25, true)
ON CONFLICT (protein_type_key) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  category = EXCLUDED.category,
  typical_protein_grams = EXCLUDED.typical_protein_grams,
  is_active = EXCLUDED.is_active;

-- =====================================================================================
-- STEP 4: Update Conversion Calculation (25g per serving)
-- =====================================================================================

-- Update grams to servings conversion
UPDATE instance_calculations
SET calculation_config = jsonb_set(
  calculation_config,
  '{conversion_rate}',
  '25'::jsonb
)
WHERE calc_id = 'CALC_PROTEIN_GRAMS_TO_SERVINGS';

-- Update servings to grams conversion
UPDATE instance_calculations
SET calculation_config = jsonb_set(
  calculation_config,
  '{conversion_rate}',
  '25'::jsonb
)
WHERE calc_id = 'CALC_PROTEIN_SERVINGS_TO_GRAMS';

-- =====================================================================================
-- STEP 5: Update Parent Descriptions
-- =====================================================================================

UPDATE parent_display_metrics
SET
  parent_description = 'Track your daily protein intake in grams. 1 serving = 25g.',
  about_what = 'Protein is essential for building and repairing tissues, making enzymes and hormones, and supporting immune function.',
  about_why = 'Adequate protein intake helps maintain muscle mass, supports metabolism, and promotes satiety.',
  about_optimal_target = 'Most adults need 50-150g daily (0.8-1.2g per kg body weight). Athletes may need more.',
  about_quick_tips = E'Quick reference:\n• 1 egg ≈ 6g\n• 1 chicken breast ≈ 30g\n• 1 cup tofu ≈ 20g\n• 1 scoop protein powder ≈ 25g\n\n1 serving = 25g protein'
WHERE parent_metric_id IN ('DISP_PROTEIN_SERVINGS', 'DISP_PROTEIN_GRAMS');

-- =====================================================================================
-- VERIFICATION
-- =====================================================================================

-- Show remaining protein sections
SELECT
  pds.section_id,
  pds.section_name,
  COUNT(cdm.child_metric_id) as child_count
FROM parent_detail_sections pds
LEFT JOIN child_display_metrics cdm ON cdm.section_id = pds.section_id
WHERE pds.parent_metric_id IN ('DISP_PROTEIN_SERVINGS', 'DISP_PROTEIN_GRAMS')
  AND pds.is_active = true
GROUP BY pds.section_id, pds.section_name, pds.display_order
ORDER BY pds.display_order;

-- Show active protein types
SELECT protein_type_key, display_name, category, typical_protein_grams
FROM def_ref_protein_types
WHERE is_active = true
ORDER BY protein_type_key;

-- Show data entry fields status
SELECT
  field_id,
  field_name,
  is_parent,
  is_active,
  is_deprecated
FROM data_entry_fields
WHERE field_name LIKE '%protein%'
  AND (is_parent = true OR parent_field_id IS NULL)
ORDER BY field_name;
