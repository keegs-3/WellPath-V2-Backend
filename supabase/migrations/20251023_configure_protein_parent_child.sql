-- =====================================================================================
-- Configure Protein Parent/Child Metrics
-- =====================================================================================
-- Parent: Protein Servings (main chart)
-- Children organized as:
--   - Meals: Breakfast, Lunch, Dinner
--   - Variety: Protein Variety
--   - Plant-Based: Percentage and Grams
--   - Alternative Units: Grams, g/kg body weight
-- =====================================================================================

-- Set parent for Meal breakdowns
UPDATE display_metrics
SET parent_metric_id = 'DISP_PROTEIN_SERVINGS'
WHERE display_metric_id IN (
  'DISP_PROTEIN_SERVINGS_BREAKFAST',
  'DISP_PROTEIN_SERVINGS_LUNCH',
  'DISP_PROTEIN_SERVINGS_DINNER'
);

-- Set parent for Variety
UPDATE display_metrics
SET parent_metric_id = 'DISP_PROTEIN_SERVINGS'
WHERE display_metric_id = 'DISP_PROTEIN_VARIETY';

-- Set parent for Plant-Based views
UPDATE display_metrics
SET parent_metric_id = 'DISP_PROTEIN_SERVINGS'
WHERE display_metric_id IN (
  'DISP_PLANTBASED_PROTEIN_PERCENTAGE',
  'DISP_PLANTBASED_PROTEIN_GRAMS'
);

-- Set parent for Alternative Units
UPDATE display_metrics
SET parent_metric_id = 'DISP_PROTEIN_SERVINGS'
WHERE display_metric_id IN (
  'DISP_PROTEIN_GRAMS',
  'DISP_PROTEIN_PER_KILOGRAM_BODY_WEIGHT'
);

-- Verify the configuration
SELECT
  CASE WHEN parent_metric_id IS NULL THEN '🏆 PARENT' ELSE '  ↳ child' END as type,
  display_metric_id,
  display_name
FROM display_metrics
WHERE display_metric_id = 'DISP_PROTEIN_SERVINGS'
   OR parent_metric_id = 'DISP_PROTEIN_SERVINGS'
ORDER BY
  parent_metric_id NULLS FIRST,
  display_name;
