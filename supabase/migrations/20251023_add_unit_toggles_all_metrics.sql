-- =====================================================================================
-- Add Unit Toggles to All Applicable Metrics
-- =====================================================================================
-- Extends unit toggle system beyond protein to other metrics
-- =====================================================================================

-- =====================================================================================
-- FIBER - Servings ↔ Grams Toggle
-- =====================================================================================

-- Update parent: Fiber Servings → Fiber Intake (with toggle support)
UPDATE display_metrics
SET
  display_name = 'Fiber Intake',
  description = 'Total fiber intake (toggle between servings and grams)',
  supported_units = '["servings", "grams"]'::jsonb,
  default_unit = 'servings'
WHERE display_metric_id = 'DISP_FIBER_SERVINGS';

-- Update meal breakdowns to support toggle
UPDATE display_metrics
SET
  display_name = 'Fiber: Breakfast',
  description = 'Fiber consumed at breakfast (toggle between servings and grams)',
  supported_units = '["servings", "grams"]'::jsonb,
  default_unit = 'servings'
WHERE display_metric_id = 'DISP_FIBER_SERVINGS_BREAKFAST';

UPDATE display_metrics
SET
  display_name = 'Fiber: Lunch',
  description = 'Fiber consumed at lunch (toggle between servings and grams)',
  supported_units = '["servings", "grams"]'::jsonb,
  default_unit = 'servings'
WHERE display_metric_id = 'DISP_FIBER_SERVINGS_LUNCH';

UPDATE display_metrics
SET
  display_name = 'Fiber: Dinner',
  description = 'Fiber consumed at dinner (toggle between servings and grams)',
  supported_units = '["servings", "grams"]'::jsonb,
  default_unit = 'servings'
WHERE display_metric_id = 'DISP_FIBER_SERVINGS_DINNER';

-- Update variety/source metrics (count only, no toggle)
UPDATE display_metrics
SET
  supported_units = '["count"]'::jsonb,
  default_unit = 'count'
WHERE display_metric_id IN (
  'DISP_FIBER_SOURCE_COUNT',
  'DISP_FIBER_SOURCE_VARIETY',
  'DISP_FIBER_SOURCES'
);

-- Deprecate standalone DISP_FIBER_GRAMS (now part of toggle)
UPDATE display_metrics
SET
  is_active = false,
  parent_metric_id = NULL,
  description = 'DEPRECATED: Use DISP_FIBER_SERVINGS (renamed to Fiber Intake) with grams toggle instead'
WHERE display_metric_id = 'DISP_FIBER_GRAMS';

-- Add fiber aggregation links for parent (both units)
INSERT INTO display_metrics_aggregations (display_metric_id, agg_metric_id, period_type, calculation_type_id, is_primary)
VALUES
  -- Servings (primary)
  ('DISP_FIBER_SERVINGS', 'AGG_FIBER_SERVINGS', 'daily', 'SUM', true),
  ('DISP_FIBER_SERVINGS', 'AGG_FIBER_SERVINGS', 'weekly', 'SUM', true),
  ('DISP_FIBER_SERVINGS', 'AGG_FIBER_SERVINGS', 'monthly', 'SUM', true),
  -- Grams (secondary for toggle)
  ('DISP_FIBER_SERVINGS', 'AGG_FIBER_GRAMS', 'daily', 'SUM', false),
  ('DISP_FIBER_SERVINGS', 'AGG_FIBER_GRAMS', 'weekly', 'SUM', false),
  ('DISP_FIBER_SERVINGS', 'AGG_FIBER_GRAMS', 'monthly', 'SUM', false)
ON CONFLICT (display_metric_id, agg_metric_id, period_type, calculation_type_id) DO NOTHING;

-- =====================================================================================
-- WATER - Fluid Ounces (single unit for now)
-- =====================================================================================

-- Water currently only has fl oz aggregation, set as single unit
UPDATE display_metrics
SET
  supported_units = '["fl_oz"]'::jsonb,
  default_unit = 'fl_oz',
  description = 'Daily water consumption in fluid ounces'
WHERE display_metric_id = 'DISP_WATER_CONSUMPTION';

-- TODO: Add ml and cups aggregations in future for toggle support

-- =====================================================================================
-- CARDIO DURATION - Minutes (single unit for now)
-- =====================================================================================

-- Duration currently only in minutes, could add hours toggle later
UPDATE display_metrics
SET
  supported_units = '["minutes"]'::jsonb,
  default_unit = 'minutes'
WHERE display_metric_id = 'DISP_CARDIO_DURATION';

-- =====================================================================================
-- OTHER NUTRITION METRICS - Set single units
-- =====================================================================================

-- Fruit Servings (only servings aggregation exists)
UPDATE display_metrics
SET
  supported_units = '["servings"]'::jsonb,
  default_unit = 'servings'
WHERE display_metric_id = 'DISP_FRUIT_SERVINGS';

-- Vegetable Servings (only servings aggregation exists)
UPDATE display_metrics
SET
  supported_units = '["servings"]'::jsonb,
  default_unit = 'servings'
WHERE display_metric_id IN (
  SELECT display_metric_id
  FROM display_metrics
  WHERE display_name ILIKE '%vegetable%servings%'
  LIMIT 1
);

-- Legume Servings
UPDATE display_metrics
SET
  supported_units = '["servings"]'::jsonb,
  default_unit = 'servings'
WHERE display_metric_id = 'DISP_LEGUME_SERVINGS';

-- =====================================================================================
-- VERIFICATION
-- =====================================================================================

-- Show all metrics with toggle support
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
  jsonb_array_length(supported_units) as unit_count,
  CASE WHEN jsonb_array_length(supported_units) > 1 THEN '✅ Toggle' ELSE '   Single' END as toggle_status
FROM display_metrics
WHERE display_metric_id IN (
  'DISP_PROTEIN_SERVINGS',
  'DISP_FIBER_SERVINGS',
  'DISP_WATER_CONSUMPTION',
  'DISP_CARDIO_DURATION',
  'DISP_FRUIT_SERVINGS',
  'DISP_LEGUME_SERVINGS'
)
OR parent_metric_id IN ('DISP_PROTEIN_SERVINGS', 'DISP_FIBER_SERVINGS')
ORDER BY
  CASE
    WHEN display_metric_id IN ('DISP_PROTEIN_SERVINGS', 'DISP_FIBER_SERVINGS') THEN 1
    ELSE 2
  END,
  parent_metric_id NULLS FIRST,
  display_name;
