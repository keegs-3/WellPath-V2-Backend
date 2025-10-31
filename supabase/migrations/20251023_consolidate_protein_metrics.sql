-- =====================================================================================
-- Consolidate Protein Metrics for Unit Toggle
-- =====================================================================================
-- Renames protein metrics to be unit-agnostic (remove "SERVINGS" from names)
-- Sets up supported_units for toggle functionality
-- Links display metrics to both servings and grams aggregations
-- =====================================================================================

-- =====================================================================================
-- STEP 1: Rename metrics to be unit-agnostic
-- =====================================================================================

-- Rename parent: Protein Servings → Protein Intake
UPDATE display_metrics
SET
  display_metric_id = 'DISP_PROTEIN_INTAKE',
  display_name = 'Protein Intake',
  description = 'Total protein intake (toggle between servings and grams)'
WHERE display_metric_id = 'DISP_PROTEIN_SERVINGS';

-- Rename meal breakdowns (remove "Servings:")
UPDATE display_metrics
SET
  display_metric_id = 'DISP_PROTEIN_BREAKFAST',
  display_name = 'Protein: Breakfast',
  description = 'Protein consumed at breakfast (toggle between servings and grams)'
WHERE display_metric_id = 'DISP_PROTEIN_SERVINGS_BREAKFAST';

UPDATE display_metrics
SET
  display_metric_id = 'DISP_PROTEIN_LUNCH',
  display_name = 'Protein: Lunch',
  description = 'Protein consumed at lunch (toggle between servings and grams)'
WHERE display_metric_id = 'DISP_PROTEIN_SERVINGS_LUNCH';

UPDATE display_metrics
SET
  display_metric_id = 'DISP_PROTEIN_DINNER',
  display_name = 'Protein: Dinner',
  description = 'Protein consumed at dinner (toggle between servings and grams)'
WHERE display_metric_id = 'DISP_PROTEIN_SERVINGS_DINNER';

-- =====================================================================================
-- STEP 2: Update parent_metric_id references to new parent name
-- =====================================================================================

UPDATE display_metrics
SET parent_metric_id = 'DISP_PROTEIN_INTAKE'
WHERE parent_metric_id = 'DISP_PROTEIN_SERVINGS';

-- =====================================================================================
-- STEP 3: Set supported_units and default_unit
-- =====================================================================================

-- Parent and meal breakdowns support servings/grams toggle
UPDATE display_metrics
SET
  supported_units = '["servings", "grams"]'::jsonb,
  default_unit = 'servings'
WHERE display_metric_id IN (
  'DISP_PROTEIN_INTAKE',
  'DISP_PROTEIN_BREAKFAST',
  'DISP_PROTEIN_LUNCH',
  'DISP_PROTEIN_DINNER'
);

-- Protein Variety (count only)
UPDATE display_metrics
SET
  supported_units = '["count"]'::jsonb,
  default_unit = 'count'
WHERE display_metric_id = 'DISP_PROTEIN_VARIETY';

-- Protein per kg (g/kg only)
UPDATE display_metrics
SET
  supported_units = '["g/kg"]'::jsonb,
  default_unit = 'g/kg'
WHERE display_metric_id = 'DISP_PROTEIN_PER_KILOGRAM_BODY_WEIGHT';

-- Plant-based supports grams and percentage
UPDATE display_metrics
SET
  supported_units = '["grams", "percentage"]'::jsonb,
  default_unit = 'percentage'
WHERE display_metric_id = 'DISP_PLANTBASED_PROTEIN_PERCENTAGE';

UPDATE display_metrics
SET
  supported_units = '["grams"]'::jsonb,
  default_unit = 'grams'
WHERE display_metric_id = 'DISP_PLANTBASED_PROTEIN_GRAMS';

-- =====================================================================================
-- STEP 4: Update display_metrics_aggregations references
-- =====================================================================================

-- Update aggregation links to use new display_metric_ids
UPDATE display_metrics_aggregations
SET display_metric_id = 'DISP_PROTEIN_INTAKE'
WHERE display_metric_id = 'DISP_PROTEIN_SERVINGS';

UPDATE display_metrics_aggregations
SET display_metric_id = 'DISP_PROTEIN_BREAKFAST'
WHERE display_metric_id = 'DISP_PROTEIN_SERVINGS_BREAKFAST';

UPDATE display_metrics_aggregations
SET display_metric_id = 'DISP_PROTEIN_LUNCH'
WHERE display_metric_id = 'DISP_PROTEIN_SERVINGS_LUNCH';

UPDATE display_metrics_aggregations
SET display_metric_id = 'DISP_PROTEIN_DINNER'
WHERE display_metric_id = 'DISP_PROTEIN_SERVINGS_DINNER';

-- =====================================================================================
-- STEP 5: Add grams aggregation links for toggle support
-- =====================================================================================

-- Add AGG_PROTEIN_GRAMS link to DISP_PROTEIN_INTAKE (for toggle)
INSERT INTO display_metrics_aggregations (display_metric_id, agg_metric_id, period_type, calculation_type_id, is_primary)
SELECT
  'DISP_PROTEIN_INTAKE',
  'AGG_PROTEIN_GRAMS',
  period_type,
  calculation_type_id,
  false  -- Not primary (servings is primary)
FROM display_metrics_aggregations
WHERE display_metric_id = 'DISP_PROTEIN_INTAKE'
  AND agg_metric_id = 'AGG_PROTEIN_SERVINGS'
ON CONFLICT (display_metric_id, agg_metric_id, period_type, calculation_type_id) DO NOTHING;

-- Note: Meal breakdowns (breakfast/lunch/dinner) will need filtered aggregations
-- For now they only link to AGG_PROTEIN_SERVINGS with group_by filtering

-- =====================================================================================
-- STEP 6: Deprecate standalone DISP_PROTEIN_GRAMS (now part of toggle)
-- =====================================================================================

UPDATE display_metrics
SET
  is_active = false,
  description = 'DEPRECATED: Use DISP_PROTEIN_INTAKE with grams toggle instead'
WHERE display_metric_id = 'DISP_PROTEIN_GRAMS';

-- =====================================================================================
-- VERIFICATION
-- =====================================================================================

-- Show consolidated protein metrics
SELECT
  CASE
    WHEN parent_metric_id IS NULL AND is_parent THEN '🏆 PARENT'
    WHEN parent_metric_id IS NOT NULL THEN '   ↳ child'
    ELSE '   standalone'
  END as type,
  display_metric_id,
  display_name,
  supported_units,
  default_unit,
  is_active
FROM display_metrics
WHERE display_metric_id ILIKE '%protein%'
  AND is_active = true
ORDER BY parent_metric_id NULLS FIRST, display_name;
