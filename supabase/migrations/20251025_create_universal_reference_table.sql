-- =====================================================
-- Create Universal Reference Table
-- =====================================================
-- Consolidates 27+ def_ref_* tables into one universal table
-- Pattern: reference_category + reference_key + display_name
-- =====================================================

BEGIN;

-- =====================================================
-- 1. Create Universal Reference Table
-- =====================================================
CREATE TABLE IF NOT EXISTS def_reference_values (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reference_category TEXT NOT NULL,  -- 'protein_type', 'meal_timing', 'vegetable_type', etc.
  reference_key TEXT NOT NULL,       -- 'fatty_fish', 'breakfast', 'broccoli', etc.
  display_name TEXT NOT NULL,
  description TEXT,
  metadata JSONB DEFAULT '{}'::jsonb,  -- Category-specific attributes (hour ranges, nutritional info, etc.)
  sort_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(reference_category, reference_key)
);

CREATE INDEX idx_reference_values_category ON def_reference_values(reference_category);
CREATE INDEX idx_reference_values_key ON def_reference_values(reference_category, reference_key);

COMMENT ON TABLE def_reference_values IS 'Universal reference table for all categorical data (protein types, meal timing, vegetables, etc.)';
COMMENT ON COLUMN def_reference_values.reference_category IS 'Category of reference (protein_type, meal_timing, vegetable_type, etc.)';
COMMENT ON COLUMN def_reference_values.reference_key IS 'Unique key within category (fatty_fish, breakfast, broccoli, etc.)';
COMMENT ON COLUMN def_reference_values.metadata IS 'Category-specific attributes stored as JSON';

-- =====================================================
-- 2. Migrate Protein Timing Data
-- =====================================================
INSERT INTO def_reference_values (
  reference_category,
  reference_key,
  display_name,
  description,
  metadata,
  sort_order,
  is_active
)
SELECT
  'meal_timing' AS reference_category,
  timing_key AS reference_key,
  display_name,
  description,
  jsonb_build_object(
    'typical_hour_start', typical_hour_start,
    'typical_hour_end', typical_hour_end
  ) AS metadata,
  sort_order,
  is_active
FROM def_ref_protein_timing
WHERE timing_key IS NOT NULL
ON CONFLICT (reference_category, reference_key) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  metadata = EXCLUDED.metadata,
  sort_order = EXCLUDED.sort_order,
  updated_at = NOW();

-- =====================================================
-- 3. Migrate Protein Type Data
-- =====================================================
INSERT INTO def_reference_values (
  reference_category,
  reference_key,
  display_name,
  description,
  metadata,
  sort_order,
  is_active
)
SELECT
  'protein_type' AS reference_category,
  protein_type_key AS reference_key,
  display_name,
  description,
  jsonb_build_object(
    'is_plant_based', is_plant_based,
    'typical_grams_per_serving', typical_grams_per_serving
  ) AS metadata,
  sort_order,
  is_active
FROM def_ref_protein_types
WHERE protein_type_key IS NOT NULL
ON CONFLICT (reference_category, reference_key) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  metadata = EXCLUDED.metadata,
  sort_order = EXCLUDED.sort_order,
  updated_at = NOW();

-- =====================================================
-- 4. Migrate Food Timing Data (if different from protein timing)
-- =====================================================
INSERT INTO def_reference_values (
  reference_category,
  reference_key,
  display_name,
  description,
  metadata,
  sort_order,
  is_active
)
SELECT
  'meal_timing' AS reference_category,
  timing_key AS reference_key,
  display_name,
  description,
  jsonb_build_object(
    'typical_hour_start', typical_hour_start,
    'typical_hour_end', typical_hour_end
  ) AS metadata,
  sort_order,
  is_active
FROM def_ref_food_timing
WHERE timing_key IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 FROM def_reference_values
    WHERE reference_category = 'meal_timing'
      AND reference_key = def_ref_food_timing.timing_key
  )
ON CONFLICT (reference_category, reference_key) DO NOTHING;

-- =====================================================
-- 5. Migrate Other Reference Tables (if they exist)
-- =====================================================

-- Fiber Sources
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'def_ref_fiber_sources') THEN
    INSERT INTO def_reference_values (reference_category, reference_key, display_name, description, sort_order, is_active)
    SELECT 'fiber_source', fiber_source_key, display_name, description, COALESCE(sort_order, 0), COALESCE(is_active, true)
    FROM def_ref_fiber_sources
    WHERE fiber_source_key IS NOT NULL
    ON CONFLICT (reference_category, reference_key) DO UPDATE SET
      display_name = EXCLUDED.display_name,
      updated_at = NOW();
  END IF;
END $$;

-- Vegetable Types
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'def_ref_vegetable_types') THEN
    INSERT INTO def_reference_values (reference_category, reference_key, display_name, description, sort_order, is_active)
    SELECT 'vegetable_type', vegetable_type_key, display_name, description, COALESCE(sort_order, 0), COALESCE(is_active, true)
    FROM def_ref_vegetable_types
    WHERE vegetable_type_key IS NOT NULL
    ON CONFLICT (reference_category, reference_key) DO UPDATE SET
      display_name = EXCLUDED.display_name,
      updated_at = NOW();
  END IF;
END $$;

-- Water Sources
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'def_ref_water_sources') THEN
    INSERT INTO def_reference_values (reference_category, reference_key, display_name, description, sort_order, is_active)
    SELECT 'water_source', water_source_key, display_name, description, COALESCE(sort_order, 0), COALESCE(is_active, true)
    FROM def_ref_water_sources
    WHERE water_source_key IS NOT NULL
    ON CONFLICT (reference_category, reference_key) DO UPDATE SET
      display_name = EXCLUDED.display_name,
      updated_at = NOW();
  END IF;
END $$;

-- Cardio Types
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'def_ref_cardio_types') THEN
    INSERT INTO def_reference_values (reference_category, reference_key, display_name, description, sort_order, is_active)
    SELECT 'cardio_type', cardio_type_key, display_name, description, COALESCE(sort_order, 0), COALESCE(is_active, true)
    FROM def_ref_cardio_types
    WHERE cardio_type_key IS NOT NULL
    ON CONFLICT (reference_category, reference_key) DO UPDATE SET
      display_name = EXCLUDED.display_name,
      updated_at = NOW();
  END IF;
END $$;

-- Strength Types
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'def_ref_strength_types') THEN
    INSERT INTO def_reference_values (reference_category, reference_key, display_name, description, sort_order, is_active)
    SELECT 'strength_type', strength_type_key, display_name, description, COALESCE(sort_order, 0), COALESCE(is_active, true)
    FROM def_ref_strength_types
    WHERE strength_type_key IS NOT NULL
    ON CONFLICT (reference_category, reference_key) DO UPDATE SET
      display_name = EXCLUDED.display_name,
      updated_at = NOW();
  END IF;
END $$;

-- =====================================================
-- 6. Update Data Entry Fields to Use Universal Table
-- =====================================================

-- Update DEF_PROTEIN_TIMING
UPDATE data_entry_fields
SET reference_table = 'def_reference_values',
    updated_at = NOW()
WHERE field_id = 'DEF_PROTEIN_TIMING';

-- Update DEF_PROTEIN_TYPE
UPDATE data_entry_fields
SET reference_table = 'def_reference_values',
    updated_at = NOW()
WHERE field_id = 'DEF_PROTEIN_TYPE';

-- Update DEF_FOOD_TIMING
UPDATE data_entry_fields
SET reference_table = 'def_reference_values',
    updated_at = NOW()
WHERE field_id = 'DEF_FOOD_TIMING';

-- Update all other reference fields
UPDATE data_entry_fields
SET reference_table = 'def_reference_values',
    updated_at = NOW()
WHERE field_type = 'reference'
  AND reference_table LIKE 'def_ref_%';

-- =====================================================
-- 7. Create Helper Function for Category Filtering
-- =====================================================
CREATE OR REPLACE FUNCTION get_reference_id(
  p_category TEXT,
  p_key TEXT
) RETURNS UUID
LANGUAGE sql STABLE
AS $$
  SELECT id
  FROM def_reference_values
  WHERE reference_category = p_category
    AND reference_key = p_key
    AND is_active = true
  LIMIT 1;
$$;

COMMENT ON FUNCTION get_reference_id IS 'Get UUID for a reference value by category and key';

-- =====================================================
-- 8. Create View for Backward Compatibility
-- =====================================================

-- Protein Timing View
CREATE OR REPLACE VIEW def_ref_protein_timing AS
SELECT
  id,
  reference_key AS timing_key,
  display_name,
  description,
  (metadata->>'typical_hour_start')::INTEGER AS typical_hour_start,
  (metadata->>'typical_hour_end')::INTEGER AS typical_hour_end,
  sort_order,
  is_active,
  created_at
FROM def_reference_values
WHERE reference_category = 'meal_timing';

-- Protein Types View
CREATE OR REPLACE VIEW def_ref_protein_types AS
SELECT
  id,
  reference_key AS protein_type_key,
  display_name,
  description,
  (metadata->>'is_plant_based')::BOOLEAN AS is_plant_based,
  (metadata->>'typical_grams_per_serving')::INTEGER AS typical_grams_per_serving,
  sort_order,
  is_active,
  created_at
FROM def_reference_values
WHERE reference_category = 'protein_type';

-- Food Timing View
CREATE OR REPLACE VIEW def_ref_food_timing AS
SELECT
  id,
  reference_key AS timing_key,
  display_name,
  description,
  (metadata->>'typical_hour_start')::INTEGER AS typical_hour_start,
  (metadata->>'typical_hour_end')::INTEGER AS typical_hour_end,
  sort_order,
  is_active,
  created_at
FROM def_reference_values
WHERE reference_category = 'meal_timing';

-- =====================================================
-- Summary
-- =====================================================
DO $$
DECLARE
  v_total_refs INTEGER;
  v_categories INTEGER;
  v_updated_fields INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_total_refs FROM def_reference_values;
  SELECT COUNT(DISTINCT reference_category) INTO v_categories FROM def_reference_values;
  SELECT COUNT(*) INTO v_updated_fields FROM data_entry_fields WHERE reference_table = 'def_reference_values';

  RAISE NOTICE '';
  RAISE NOTICE '✅ Created Universal Reference Table!';
  RAISE NOTICE '';
  RAISE NOTICE 'Summary:';
  RAISE NOTICE '  Total reference values: %', v_total_refs;
  RAISE NOTICE '  Reference categories: %', v_categories;
  RAISE NOTICE '  Data entry fields updated: %', v_updated_fields;
  RAISE NOTICE '';
  RAISE NOTICE 'Categories migrated:';
  RAISE NOTICE '  • meal_timing (breakfast, lunch, dinner, snacks)';
  RAISE NOTICE '  • protein_type (fatty_fish, lean_protein, etc.)';
  RAISE NOTICE '  • fiber_source (if exists)';
  RAISE NOTICE '  • vegetable_type (if exists)';
  RAISE NOTICE '  • water_source (if exists)';
  RAISE NOTICE '  • cardio_type (if exists)';
  RAISE NOTICE '  • strength_type (if exists)';
  RAISE NOTICE '';
  RAISE NOTICE 'New Architecture:';
  RAISE NOTICE '  One table: def_reference_values';
  RAISE NOTICE '  Pattern: reference_category + reference_key';
  RAISE NOTICE '  All data_entry_fields now reference this universal table';
  RAISE NOTICE '';
  RAISE NOTICE 'Backward Compatibility:';
  RAISE NOTICE '  Created views: def_ref_protein_timing, def_ref_protein_types, def_ref_food_timing';
  RAISE NOTICE '';
  RAISE NOTICE 'Helper Function:';
  RAISE NOTICE '  get_reference_id(''meal_timing'', ''breakfast'') → UUID';
  RAISE NOTICE '';
END $$;

COMMIT;
