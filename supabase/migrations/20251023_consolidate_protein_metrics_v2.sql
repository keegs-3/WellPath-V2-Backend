-- =====================================================================================
-- Consolidate Protein Metrics for Unit Toggle (V2 - Fixed FK issues)
-- =====================================================================================
-- Instead of renaming IDs, we'll just update the display names and properties
-- The ID can stay as DISP_PROTEIN_SERVINGS for backward compatibility
-- =====================================================================================

-- =====================================================================================
-- STEP 1: Update parent metric properties (keep ID, change display)
-- =====================================================================================

UPDATE display_metrics
SET
  display_name = 'Protein Intake',
  description = 'Total protein intake (toggle between servings and grams)',
  supported_units = '["servings", "grams"]'::jsonb,
  default_unit = 'servings'
WHERE display_metric_id = 'DISP_PROTEIN_SERVINGS';

-- =====================================================================================
-- STEP 2: Update meal breakdown metrics (keep IDs, change display, add toggle support)
-- =====================================================================================

UPDATE display_metrics
SET
  display_name = 'Protein: Breakfast',
  description = 'Protein consumed at breakfast (toggle between servings and grams)',
  supported_units = '["servings", "grams"]'::jsonb,
  default_unit = 'servings'
WHERE display_metric_id = 'DISP_PROTEIN_SERVINGS_BREAKFAST';

UPDATE display_metrics
SET
  display_name = 'Protein: Lunch',
  description = 'Protein consumed at lunch (toggle between servings and grams)',
  supported_units = '["servings", "grams"]'::jsonb,
  default_unit = 'servings'
WHERE display_metric_id = 'DISP_PROTEIN_SERVINGS_LUNCH';

UPDATE display_metrics
SET
  display_name = 'Protein: Dinner',
  description = 'Protein consumed at dinner (toggle between servings and grams)',
  supported_units = '["servings", "grams"]'::jsonb,
  default_unit = 'servings'
WHERE display_metric_id = 'DISP_PROTEIN_SERVINGS_DINNER';

-- =====================================================================================
-- STEP 3: Set supported_units for other protein children
-- =====================================================================================

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
-- STEP 4: Add grams aggregation links for toggle support
-- =====================================================================================

-- Add AGG_PROTEIN_GRAMS link to DISP_PROTEIN_SERVINGS (for toggle)
INSERT INTO display_metrics_aggregations (display_metric_id, agg_metric_id, period_type, calculation_type_id, is_primary)
SELECT
  'DISP_PROTEIN_SERVINGS',
  'AGG_PROTEIN_GRAMS',
  period_type,
  calculation_type_id,
  false  -- Not primary (servings is primary)
FROM display_metrics_aggregations
WHERE display_metric_id = 'DISP_PROTEIN_SERVINGS'
  AND agg_metric_id = 'AGG_PROTEIN_SERVINGS'
  AND NOT EXISTS (
    SELECT 1 FROM display_metrics_aggregations dma2
    WHERE dma2.display_metric_id = 'DISP_PROTEIN_SERVINGS'
      AND dma2.agg_metric_id = 'AGG_PROTEIN_GRAMS'
      AND dma2.period_type = display_metrics_aggregations.period_type
      AND dma2.calculation_type_id = display_metrics_aggregations.calculation_type_id
  );

-- =====================================================================================
-- STEP 5: Deprecate standalone DISP_PROTEIN_GRAMS (now part of toggle)
-- =====================================================================================

UPDATE display_metrics
SET
  is_active = false,
  description = 'DEPRECATED: Use DISP_PROTEIN_SERVINGS (renamed to Protein Intake) with grams toggle instead'
WHERE display_metric_id = 'DISP_PROTEIN_GRAMS';

-- Remove from parent relationship
UPDATE display_metrics
SET parent_metric_id = NULL
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
WHERE (display_metric_id ILIKE '%protein%' OR parent_metric_id = 'DISP_PROTEIN_SERVINGS')
ORDER BY
  CASE WHEN parent_metric_id IS NULL THEN 0 ELSE 1 END,
  is_active DESC,
  display_name;
