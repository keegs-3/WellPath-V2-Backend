-- =====================================================================================
-- Add Unit Toggle Support to Display Metrics
-- =====================================================================================
-- Allows metrics to support multiple units (e.g., protein: servings OR grams)
-- User preference stored per metric in patient_display_metrics_preferences
-- =====================================================================================

-- Step 1: Add supported_units to display_metrics
ALTER TABLE display_metrics
ADD COLUMN supported_units JSONB DEFAULT '["default"]'::jsonb NOT NULL;

-- Add comment
COMMENT ON COLUMN display_metrics.supported_units IS
'Array of units this metric can display in. Examples:
- ["servings", "grams"] = supports toggle between servings and grams
- ["count"] = only supports count (no toggle)
- ["g/kg"] = only supports g/kg (no toggle)
- ["minutes", "hours"] = supports toggle between time units
User preference stored in patient_display_metrics_preferences.preferred_unit';

-- Step 2: Add preferred_unit to patient_display_metrics_preferences
ALTER TABLE patient_display_metrics_preferences
ADD COLUMN preferred_unit TEXT;

-- Add comment
COMMENT ON COLUMN patient_display_metrics_preferences.preferred_unit IS
'User''s preferred unit for this metric when multiple units are supported.
Must be one of the values in display_metrics.supported_units.
If null, uses display_metrics.default_unit';

-- Step 3: Add default_unit to display_metrics (if not exists)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'display_metrics' AND column_name = 'default_unit'
  ) THEN
    ALTER TABLE display_metrics ADD COLUMN default_unit TEXT;
  END IF;
END $$;

-- Add comment for default_unit
COMMENT ON COLUMN display_metrics.default_unit IS
'Default unit to display if user has no preference set.
Should always be one of the values in supported_units array.';

-- Verify
SELECT
  column_name,
  data_type,
  column_default
FROM information_schema.columns
WHERE table_name = 'display_metrics'
  AND column_name IN ('supported_units', 'default_unit', 'display_unit')
ORDER BY column_name;
