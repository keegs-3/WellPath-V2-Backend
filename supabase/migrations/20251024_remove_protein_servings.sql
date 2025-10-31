-- =====================================================
-- Remove Protein Servings - GRAMS ONLY
-- =====================================================
-- Protein tracking uses grams only
-- Type and source are optional metadata for views
-- =====================================================

-- =====================================================
-- STEP 1: Delete Servings Data Entries
-- =====================================================

DELETE FROM patient_data_entries
WHERE field_id = 'DEF_PROTEIN_SERVINGS';

-- =====================================================
-- STEP 2: Delete Servings Aggregations
-- =====================================================

DELETE FROM aggregation_results_cache
WHERE agg_metric_id = 'AGG_PROTEIN_SERVINGS';

DELETE FROM display_metrics_aggregations
WHERE agg_metric_id = 'AGG_PROTEIN_SERVINGS';

DELETE FROM aggregation_metrics_periods
WHERE agg_metric_id = 'AGG_PROTEIN_SERVINGS';

DELETE FROM aggregation_metrics_calculation_types
WHERE aggregation_metric_id = 'AGG_PROTEIN_SERVINGS';

DELETE FROM aggregation_metrics_dependencies
WHERE agg_metric_id = 'AGG_PROTEIN_SERVINGS';

DELETE FROM aggregation_metrics
WHERE agg_id = 'AGG_PROTEIN_SERVINGS';

-- =====================================================
-- STEP 3: Delete Servings Instance Calculations
-- =====================================================

DELETE FROM instance_calculations_dependencies
WHERE calc_id IN ('CALC_PROTEIN_GRAMS_TO_SERVINGS', 'CALC_PROTEIN_SERVINGS_TO_GRAMS');

DELETE FROM instance_calculations
WHERE calc_id IN ('CALC_PROTEIN_GRAMS_TO_SERVINGS', 'CALC_PROTEIN_SERVINGS_TO_GRAMS');

-- =====================================================
-- STEP 4: Remove Servings from Field Registry
-- =====================================================

DELETE FROM field_registry
WHERE field_id = 'DEF_PROTEIN_SERVINGS';

DELETE FROM data_entry_fields
WHERE field_id = 'DEF_PROTEIN_SERVINGS';

-- =====================================================
-- STEP 5: Update Display Metrics (GRAMS ONLY)
-- =====================================================

-- Remove servings from supported units
UPDATE display_metrics
SET
  supported_units = '["grams"]'::jsonb,
  default_unit = 'grams',
  display_name = 'Protein',
  description = 'Total protein intake in grams'
WHERE display_metric_id = 'DISP_PROTEIN_SERVINGS';

-- Optionally rename the ID (or keep for backward compatibility)
-- For now, keep ID as DISP_PROTEIN_SERVINGS but it only shows grams

UPDATE parent_display_metrics
SET
  parent_name = 'Protein',
  parent_description = 'Track your daily protein intake in grams.',
  supported_units = '["grams"]'::jsonb
WHERE parent_metric_id = 'DISP_PROTEIN_SERVINGS';

-- Update meal breakdown metrics
UPDATE display_metrics
SET
  supported_units = '["grams"]'::jsonb,
  default_unit = 'grams',
  description = REPLACE(description, '(toggle between servings and grams)', '(grams)')
WHERE display_metric_id IN (
  'DISP_PROTEIN_SERVINGS_BREAKFAST',
  'DISP_PROTEIN_SERVINGS_LUNCH',
  'DISP_PROTEIN_SERVINGS_DINNER'
);

-- =====================================================
-- STEP 6: Update Data Entry Field (GRAMS ONLY)
-- =====================================================

UPDATE data_entry_fields
SET
  description = 'Protein intake in grams. Type and source are optional metadata.',
  validation_config = '{"min": 0, "max": 300, "increment": 1}'::jsonb
WHERE field_id = 'DEF_PROTEIN_GRAMS';

-- =====================================================
-- VERIFICATION
-- =====================================================

SELECT '✅ Protein Servings Removed - GRAMS ONLY' as status;

-- Show remaining protein fields
SELECT
  field_id,
  field_name,
  unit,
  is_active
FROM data_entry_fields
WHERE field_name LIKE '%protein%'
  AND is_active = true;

-- Show remaining aggregations
SELECT
  agg_id,
  agg_metric_name
FROM aggregation_metrics
WHERE agg_id LIKE '%PROTEIN%';

-- Show display metrics
SELECT
  display_metric_id,
  display_name,
  supported_units,
  default_unit
FROM display_metrics
WHERE display_metric_id LIKE '%PROTEIN%'
  AND is_active = true;
