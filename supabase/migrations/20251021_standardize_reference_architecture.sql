-- =====================================================
-- Standardize Reference Data Architecture
-- =====================================================
-- Implements unified reference system for data_entry_fields
-- All def_ref_* tables follow consistent pattern
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Enhance data_entry_fields
-- =====================================================

-- Add columns to link to reference tables and validation
ALTER TABLE data_entry_fields
ADD COLUMN IF NOT EXISTS reference_table TEXT,
ADD COLUMN IF NOT EXISTS allows_custom_units BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS allows_custom_values BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS validation_config JSONB DEFAULT '{}'::jsonb;

-- Add comments
COMMENT ON COLUMN data_entry_fields.reference_table IS
'For field_type = reference: which def_ref_* table to use (e.g., def_ref_beverage_types)';

COMMENT ON COLUMN data_entry_fields.allows_custom_units IS
'Whether user can enter custom units beyond defaults';

COMMENT ON COLUMN data_entry_fields.allows_custom_values IS
'Whether user can enter custom values beyond reference options';

COMMENT ON COLUMN data_entry_fields.validation_config IS
'Complex validation rules as JSON. Examples:
- {"min": 0, "max": 1000, "increment": 0.1}
- {"pattern": "^[0-9]{3}-[0-9]{2}-[0-9]{4}$"}
- {"prompt_at": 100, "max_recommended": 500}';


-- =====================================================
-- PART 2: Define Standard Reference Table Pattern
-- =====================================================

-- All def_ref_* tables should have these base columns:
--
-- REQUIRED BASE COLUMNS:
-- - id UUID PRIMARY KEY
-- - key TEXT UNIQUE (the identifier - beverage_type_key, cardio_type_key, etc.)
-- - display_name TEXT
-- - is_active BOOLEAN DEFAULT true
-- - display_order INTEGER
-- - created_at TIMESTAMPTZ
-- - updated_at TIMESTAMPTZ
--
-- OPTIONAL HIERARCHY COLUMNS (for multi-level references):
-- - category_id UUID REFERENCES def_ref_*_categories(id)
-- - parent_id UUID REFERENCES same_table(id) (for nested hierarchies)
--
-- OPTIONAL QUANTITY COLUMNS (for measurable items):
-- - default_unit TEXT
-- - min_value NUMERIC
-- - max_value NUMERIC
-- - recommended_max NUMERIC (softer limit - shows warning)
-- - increment NUMERIC (step size for UI)
-- - unit_options TEXT[] (allowed units for this type)
--
-- OPTIONAL METADATA:
-- - description TEXT
-- - icon TEXT
-- - color_hex TEXT
-- - metadata JSONB


-- =====================================================
-- PART 3: Add missing columns to existing ref tables
-- =====================================================

-- Beverage Types - add quantity validation
ALTER TABLE def_ref_beverage_types
ADD COLUMN IF NOT EXISTS default_unit TEXT DEFAULT 'ounces',
ADD COLUMN IF NOT EXISTS unit_options TEXT[] DEFAULT ARRAY['ounces', 'ml', 'cups', 'bottles', 'cans'],
ADD COLUMN IF NOT EXISTS min_value NUMERIC DEFAULT 0,
ADD COLUMN IF NOT EXISTS max_value NUMERIC DEFAULT 128, -- 1 gallon in oz
ADD COLUMN IF NOT EXISTS recommended_max NUMERIC DEFAULT 64, -- warning threshold
ADD COLUMN IF NOT EXISTS increment NUMERIC DEFAULT 1;

COMMENT ON COLUMN def_ref_beverage_types.unit_options IS
'Allowed units for this beverage type. User can select from these when logging.';

COMMENT ON COLUMN def_ref_beverage_types.recommended_max IS
'Soft limit - shows warning if exceeded but allows entry';

-- Cardio Types - add intensity and duration validation
ALTER TABLE def_ref_cardio_types
ADD COLUMN IF NOT EXISTS default_duration_unit TEXT DEFAULT 'minute',
ADD COLUMN IF NOT EXISTS min_duration NUMERIC DEFAULT 1,
ADD COLUMN IF NOT EXISTS max_duration NUMERIC DEFAULT 480, -- 8 hours
ADD COLUMN IF NOT EXISTS recommended_max_duration NUMERIC DEFAULT 180, -- 3 hours
ADD COLUMN IF NOT EXISTS default_distance_unit TEXT DEFAULT 'kilometer',
ADD COLUMN IF NOT EXISTS supports_distance BOOLEAN DEFAULT true,
ADD COLUMN IF NOT EXISTS supports_intensity BOOLEAN DEFAULT true;

-- Food Types - add serving size validation
ALTER TABLE def_ref_food_types
ADD COLUMN IF NOT EXISTS default_unit TEXT DEFAULT 'serving',
ADD COLUMN IF NOT EXISTS unit_options TEXT[] DEFAULT ARRAY['serving', 'cup', 'ounce', 'gram'],
ADD COLUMN IF NOT EXISTS min_value NUMERIC DEFAULT 0,
ADD COLUMN IF NOT EXISTS max_value NUMERIC DEFAULT 20, -- servings
ADD COLUMN IF NOT EXISTS recommended_max NUMERIC DEFAULT 10,
ADD COLUMN IF NOT EXISTS increment NUMERIC DEFAULT 0.5;

-- Meal Types - no quantity (meal is a container)
-- Already has what it needs

-- Sleep Period Types - add duration expectations
ALTER TABLE def_ref_sleep_period_types
ADD COLUMN IF NOT EXISTS typical_min_minutes NUMERIC,
ADD COLUMN IF NOT EXISTS typical_max_minutes NUMERIC;

-- Update with typical ranges
UPDATE def_ref_sleep_period_types SET
  typical_min_minutes = 0,
  typical_max_minutes = 60
WHERE period_name = 'awake';

UPDATE def_ref_sleep_period_types SET
  typical_min_minutes = 60,
  typical_max_minutes = 240
WHERE period_name = 'core';

UPDATE def_ref_sleep_period_types SET
  typical_min_minutes = 20,
  typical_max_minutes = 120
WHERE period_name = 'deep';

UPDATE def_ref_sleep_period_types SET
  typical_min_minutes = 30,
  typical_max_minutes = 150
WHERE period_name = 'rem';


-- =====================================================
-- PART 4: Link data_entry_fields to reference tables
-- =====================================================

-- Beverages
UPDATE data_entry_fields SET
  reference_table = 'def_ref_beverage_types',
  allows_custom_units = true
WHERE field_id = 'DEF_BEVERAGE_TYPE';

UPDATE data_entry_fields SET
  validation_config = '{"min": 0, "max": 128, "prompt_at": 64}'::jsonb
WHERE field_id = 'DEF_BEVERAGE_QUANTITY';

-- Cardio
UPDATE data_entry_fields SET
  reference_table = 'def_ref_cardio_types'
WHERE field_id = 'DEF_CARDIO_TYPE';

-- Foods
UPDATE data_entry_fields SET
  reference_table = 'def_ref_food_types',
  allows_custom_units = true
WHERE field_id = 'DEF_FOOD_TYPE';

-- Meals
UPDATE data_entry_fields SET
  reference_table = 'def_ref_meal_types'
WHERE field_id = 'DEF_MEAL_TYPE';

-- Sleep
UPDATE data_entry_fields SET
  reference_table = 'def_ref_sleep_period_types'
WHERE field_id = 'DEF_SLEEP_PERIOD_TYPE';

-- Sleep Quality (rating)
UPDATE data_entry_fields SET
  validation_config = '{"min": 1, "max": 5, "type": "rating"}'::jsonb
WHERE field_id = 'DEF_SLEEP_QUALITY';


-- =====================================================
-- PART 5: Create helper view for reference lookup
-- =====================================================

CREATE OR REPLACE VIEW data_entry_fields_with_references AS
SELECT
  def.field_id,
  def.field_name,
  def.display_name,
  def.field_type,
  def.unit,
  def.reference_table,
  def.allows_custom_units,
  def.allows_custom_values,
  def.validation_config,
  def.is_active
FROM data_entry_fields def
WHERE def.is_active = true;

COMMENT ON VIEW data_entry_fields_with_references IS
'Active data entry fields with their reference table links and validation config';


-- =====================================================
-- Summary
-- =====================================================

DO $$
DECLARE
  ref_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO ref_count
  FROM data_entry_fields
  WHERE reference_table IS NOT NULL;

  RAISE NOTICE '===========================================';
  RAISE NOTICE 'Reference Architecture Standardized';
  RAISE NOTICE '===========================================';
  RAISE NOTICE 'Enhanced data_entry_fields with:';
  RAISE NOTICE '  - reference_table (links to def_ref_*)';
  RAISE NOTICE '  - allows_custom_units';
  RAISE NOTICE '  - allows_custom_values';
  RAISE NOTICE '  - validation_config (JSONB)';
  RAISE NOTICE '';
  RAISE NOTICE 'Fields linked to reference tables: %', ref_count;
  RAISE NOTICE '';
  RAISE NOTICE 'Standardized def_ref_* tables with:';
  RAISE NOTICE '  - Quantity validation (min, max, recommended_max)';
  RAISE NOTICE '  - Unit options (allowed units array)';
  RAISE NOTICE '  - Default units';
  RAISE NOTICE '  - Increments for UI';
  RAISE NOTICE '';
  RAISE NOTICE 'Reference Table Pattern:';
  RAISE NOTICE '  Base: id, key, display_name, is_active, display_order';
  RAISE NOTICE '  Hierarchy: category_id, parent_id (optional)';
  RAISE NOTICE '  Quantities: default_unit, min/max/recommended_max, increment';
  RAISE NOTICE '  Metadata: description, icon, color_hex, metadata (JSONB)';
END $$;

COMMIT;
