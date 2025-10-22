-- =====================================================
-- Create Water Units Reference Table
-- =====================================================
-- Filtered subset of volume units from units_base
-- Only shows relevant water measurement options
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Create Water Units Table
-- =====================================================

CREATE TABLE IF NOT EXISTS def_ref_water_units (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  water_unit_key TEXT UNIQUE NOT NULL,
  unit_id TEXT NOT NULL, -- FK to units_base.unit_id
  display_name TEXT NOT NULL,
  description TEXT,
  display_order INTEGER DEFAULT 0,
  is_default BOOLEAN DEFAULT false,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  -- Foreign key to units_base
  CONSTRAINT fk_water_unit_base FOREIGN KEY (unit_id)
    REFERENCES units_base(unit_id)
    ON UPDATE CASCADE ON DELETE CASCADE
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_water_units_active ON def_ref_water_units(is_active);
CREATE INDEX IF NOT EXISTS idx_water_units_display_order ON def_ref_water_units(display_order);

-- Add update trigger
CREATE TRIGGER update_water_units_updated_at
  BEFORE UPDATE ON def_ref_water_units
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();


-- =====================================================
-- PART 2: Seed Water Unit Options
-- =====================================================

INSERT INTO def_ref_water_units (
  water_unit_key,
  unit_id,
  display_name,
  description,
  display_order,
  is_default
) VALUES
(
  'fluid_ounce',
  'fluid_ounce',
  'Fluid Ounces',
  'US fluid ounces (fl oz)',
  1,
  false
),
(
  'cup',
  'cup',
  'Cups',
  '8 fluid ounces per cup',
  2,
  true  -- Default unit
),
(
  'milliliter',
  'milliliter',
  'Milliliters',
  'Metric volume (mL)',
  3,
  false
),
(
  'liter',
  'liter',
  'Liters',
  'Metric volume (L)',
  4,
  false
),
(
  'tablespoon',
  'tablespoon',
  'Tablespoons',
  '0.5 fluid ounces per tablespoon',
  5,
  false
),
(
  'teaspoon',
  'teaspoon',
  'Teaspoons',
  '1/6 fluid ounce per teaspoon',
  6,
  false
)
ON CONFLICT (water_unit_key) DO NOTHING;


-- =====================================================
-- PART 3: Update DEF_WATER_UNITS Field
-- =====================================================

-- Link water units field to new table
UPDATE data_entry_fields
SET
  reference_table = 'def_ref_water_units',
  data_type = 'text',
  description = 'Unit of measurement for water consumption. References filtered subset of volume units.'
WHERE field_id = 'DEF_WATER_UNITS';


-- =====================================================
-- PART 4: Add Comments
-- =====================================================

COMMENT ON TABLE def_ref_water_units IS
'Filtered subset of volume units from units_base, showing only relevant water measurement options. Prevents UI from displaying nonsensical units like "feet" or "kilometers" for water volume.';

COMMENT ON COLUMN def_ref_water_units.is_default IS
'Default unit shown in UI. Currently set to "cups" as most common US measurement.';

COMMENT ON COLUMN def_ref_water_units.unit_id IS
'Foreign key to units_base.unit_id. Uses existing unit conversions from unit_conversions table for calculations.';


COMMIT;
