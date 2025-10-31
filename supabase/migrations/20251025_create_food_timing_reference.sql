-- =====================================================
-- Create Food Timing Reference Table
-- =====================================================
-- Replaces meal-specific DEF fields with a single reusable timing reference
-- Can be used for protein, fiber, water, and all nutrition tracking
-- =====================================================

BEGIN;

-- =====================================================
-- 1. Remove the meal-specific DEF fields we just created
-- =====================================================
DELETE FROM aggregation_metrics_dependencies
WHERE data_entry_field_id IN ('DEF_PROTEIN_BREAKFAST', 'DEF_PROTEIN_LUNCH', 'DEF_PROTEIN_DINNER', 'DEF_PROTEIN_SNACK', 'DEF_PROTEIN_OTHER');

DELETE FROM data_entry_fields
WHERE field_id IN ('DEF_PROTEIN_BREAKFAST', 'DEF_PROTEIN_LUNCH', 'DEF_PROTEIN_DINNER', 'DEF_PROTEIN_SNACK', 'DEF_PROTEIN_OTHER');

-- =====================================================
-- 2. Create Food Timing Reference Table
-- =====================================================
CREATE TABLE IF NOT EXISTS def_ref_food_timing (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  timing_key TEXT UNIQUE NOT NULL,
  display_name TEXT NOT NULL,
  description TEXT,
  typical_hour_start INTEGER,  -- e.g., 6 for breakfast
  typical_hour_end INTEGER,    -- e.g., 11 for breakfast
  sort_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- 3. Populate Food Timing Options
-- =====================================================
INSERT INTO def_ref_food_timing (
  timing_key,
  display_name,
  description,
  typical_hour_start,
  typical_hour_end,
  sort_order
) VALUES
  ('breakfast', 'Breakfast', 'Morning meal', 5, 11, 1),
  ('morning_snack', 'Morning Snack', 'Snack between breakfast and lunch', 9, 12, 2),
  ('lunch', 'Lunch', 'Midday meal', 11, 15, 3),
  ('afternoon_snack', 'Afternoon Snack', 'Snack between lunch and dinner', 14, 17, 4),
  ('dinner', 'Dinner', 'Evening meal', 17, 21, 5),
  ('evening_snack', 'Evening Snack', 'Snack after dinner', 19, 23, 6),
  ('other', 'Other', 'Unspecified meal timing', NULL, NULL, 7)
ON CONFLICT (timing_key) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  typical_hour_start = EXCLUDED.typical_hour_start,
  typical_hour_end = EXCLUDED.typical_hour_end;

-- =====================================================
-- 4. Create DEF_FOOD_TIMING Data Entry Field
-- =====================================================
INSERT INTO data_entry_fields (
  field_id,
  field_name,
  display_name,
  description,
  field_type,
  data_type,
  reference_table,
  event_type_id,
  supports_healthkit_sync,
  pillar_name,
  is_active
) VALUES (
  'DEF_FOOD_TIMING',
  'food_timing',
  'Meal Timing',
  'When this food was consumed (breakfast, lunch, dinner, snack, etc.)',
  'reference',
  'uuid',
  'def_ref_food_timing',
  NULL,
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
-- 5. Update AGG Dependencies to Use DEF_PROTEIN_GRAMS
-- =====================================================
-- The breakfast/lunch/dinner aggregations will filter by food_timing reference
-- For now, they just aggregate all protein (filtering logic would need enhancement)

-- Ensure DEF_PROTEIN_GRAMS is mapped to meal aggregations
INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id,
  data_entry_field_id,
  dependency_type
) VALUES
  ('AGG_PROTEIN_BREAKFAST_GRAMS', 'DEF_PROTEIN_GRAMS', 'data_field'),
  ('AGG_PROTEIN_LUNCH_GRAMS', 'DEF_PROTEIN_GRAMS', 'data_field'),
  ('AGG_PROTEIN_DINNER_GRAMS', 'DEF_PROTEIN_GRAMS', 'data_field')
ON CONFLICT DO NOTHING;

-- =====================================================
-- Summary
-- =====================================================
DO $$
DECLARE
  v_timing_options INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_timing_options
  FROM def_ref_food_timing;

  RAISE NOTICE '';
  RAISE NOTICE '✅ Created Food Timing Reference System!';
  RAISE NOTICE '';
  RAISE NOTICE 'Summary:';
  RAISE NOTICE '  Timing options: %', v_timing_options;
  RAISE NOTICE '';
  RAISE NOTICE 'Reference Table: def_ref_food_timing';
  RAISE NOTICE '  • breakfast (5-11am)';
  RAISE NOTICE '  • morning_snack (9am-12pm)';
  RAISE NOTICE '  • lunch (11am-3pm)';
  RAISE NOTICE '  • afternoon_snack (2-5pm)';
  RAISE NOTICE '  • dinner (5-9pm)';
  RAISE NOTICE '  • evening_snack (7-11pm)';
  RAISE NOTICE '  • other (anytime)';
  RAISE NOTICE '';
  RAISE NOTICE 'New Field: DEF_FOOD_TIMING';
  RAISE NOTICE '  Can be used with any nutrition entry (protein, fiber, water, etc.)';
  RAISE NOTICE '';
  RAISE NOTICE 'Note: Breakfast/Lunch/Dinner aggregations currently aggregate all protein.';
  RAISE NOTICE '      Filtering by DEF_FOOD_TIMING would require enhanced aggregation logic.';
  RAISE NOTICE '';
END $$;

COMMIT;
