-- =====================================================
-- Implement Conditional Aggregation Filtering
-- =====================================================
-- Adds filter_conditions to aggregation_metrics_dependencies
-- Enables AGG_PROTEIN_BREAKFAST to filter DEF_PROTEIN_GRAMS by timing
-- =====================================================

BEGIN;

-- =====================================================
-- 1. Remove the explicit meal timing fields
-- =====================================================
DELETE FROM aggregation_metrics_dependencies
WHERE data_entry_field_id IN ('DEF_PROTEIN_BREAKFAST', 'DEF_PROTEIN_LUNCH', 'DEF_PROTEIN_DINNER', 'DEF_PROTEIN_SNACK');

DELETE FROM data_entry_fields
WHERE field_id IN ('DEF_PROTEIN_BREAKFAST', 'DEF_PROTEIN_LUNCH', 'DEF_PROTEIN_DINNER', 'DEF_PROTEIN_SNACK');

-- =====================================================
-- 2. Add filter_conditions column to dependencies
-- =====================================================
ALTER TABLE aggregation_metrics_dependencies
ADD COLUMN IF NOT EXISTS filter_conditions JSONB DEFAULT NULL;

COMMENT ON COLUMN aggregation_metrics_dependencies.filter_conditions IS
'JSON conditions to filter data entries. E.g., {"reference_field": "DEF_PROTEIN_TIMING", "reference_value": "breakfast"}';

-- =====================================================
-- 3. Create def_ref_protein_timing reference table
-- =====================================================
CREATE TABLE IF NOT EXISTS def_ref_protein_timing (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  timing_key TEXT UNIQUE NOT NULL,
  display_name TEXT NOT NULL,
  description TEXT,
  typical_hour_start INTEGER,
  typical_hour_end INTEGER,
  sort_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Populate timing options
INSERT INTO def_ref_protein_timing (timing_key, display_name, description, typical_hour_start, typical_hour_end, sort_order)
VALUES
  ('breakfast', 'Breakfast', 'Morning meal', 5, 11, 1),
  ('morning_snack', 'Morning Snack', 'Between breakfast and lunch', 9, 12, 2),
  ('lunch', 'Lunch', 'Midday meal', 11, 15, 3),
  ('afternoon_snack', 'Afternoon Snack', 'Between lunch and dinner', 14, 17, 4),
  ('dinner', 'Dinner', 'Evening meal', 17, 21, 5),
  ('evening_snack', 'Evening Snack', 'After dinner', 19, 23, 6),
  ('other', 'Other', 'Unspecified', NULL, NULL, 7)
ON CONFLICT (timing_key) DO NOTHING;

-- =====================================================
-- 4. Create DEF_PROTEIN_TIMING reference field
-- =====================================================
INSERT INTO data_entry_fields (
  field_id, field_name, display_name, description,
  field_type, data_type, reference_table,
  event_type_id, supports_healthkit_sync, pillar_name, is_active
) VALUES (
  'DEF_PROTEIN_TIMING',
  'protein_timing',
  'Protein Meal Timing',
  'When this protein was consumed (breakfast, lunch, dinner, etc.)',
  'reference',
  'uuid',
  'def_ref_protein_timing',
  'EVT_PROTEIN',
  false,
  'Healthful Nutrition',
  true
)
ON CONFLICT (field_id) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  reference_table = EXCLUDED.reference_table,
  updated_at = NOW();

-- =====================================================
-- 5. Update dependencies with filter conditions
-- =====================================================
-- Remove old dependencies
DELETE FROM aggregation_metrics_dependencies
WHERE agg_metric_id IN ('AGG_PROTEIN_BREAKFAST_GRAMS', 'AGG_PROTEIN_LUNCH_GRAMS', 'AGG_PROTEIN_DINNER_GRAMS')
  AND data_entry_field_id = 'DEF_PROTEIN_GRAMS';

-- Add new dependencies with filter conditions
INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id,
  data_entry_field_id,
  dependency_type,
  filter_conditions
) VALUES
  (
    'AGG_PROTEIN_BREAKFAST_GRAMS',
    'DEF_PROTEIN_GRAMS',
    'data_field',
    '{"reference_field": "DEF_PROTEIN_TIMING", "reference_value": "breakfast"}'::jsonb
  ),
  (
    'AGG_PROTEIN_LUNCH_GRAMS',
    'DEF_PROTEIN_GRAMS',
    'data_field',
    '{"reference_field": "DEF_PROTEIN_TIMING", "reference_value": "lunch"}'::jsonb
  ),
  (
    'AGG_PROTEIN_DINNER_GRAMS',
    'DEF_PROTEIN_GRAMS',
    'data_field',
    '{"reference_field": "DEF_PROTEIN_TIMING", "reference_value": "dinner"}'::jsonb
  )
ON CONFLICT DO NOTHING;

-- =====================================================
-- Summary
-- =====================================================
DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '✅ Implemented Conditional Aggregation Filtering!';
  RAISE NOTICE '';
  RAISE NOTICE 'Changes:';
  RAISE NOTICE '  • Added filter_conditions column to aggregation_metrics_dependencies';
  RAISE NOTICE '  • Created def_ref_protein_timing reference table';
  RAISE NOTICE '  • Created DEF_PROTEIN_TIMING reference field';
  RAISE NOTICE '  • Removed explicit DEF_PROTEIN_BREAKFAST/LUNCH/DINNER fields';
  RAISE NOTICE '';
  RAISE NOTICE 'New Architecture:';
  RAISE NOTICE '  DEF_PROTEIN_GRAMS (25g) + DEF_PROTEIN_TIMING (breakfast)';
  RAISE NOTICE '    → AGG_PROTEIN_BREAKFAST_GRAMS filters by timing=breakfast';
  RAISE NOTICE '';
  RAISE NOTICE '⚠️  NOTE: calculate_field_aggregation() needs enhancement to use filter_conditions!';
  RAISE NOTICE '';
END $$;

COMMIT;
