-- =====================================================
-- Therapeutic Tracking Architecture Implementation
-- =====================================================
-- Consolidates 75+ individual therapeutic fields into
-- event-based pattern with 3 reusable fields
--
-- Created: 2025-10-19
-- =====================================================

BEGIN;

-- =====================================================
-- Table 1: therapeutic_unit_options
-- =====================================================
-- Links therapeutics to available units with conversion factors
-- Handles substance-specific conversions (e.g., IU for Vitamin D)

CREATE TABLE IF NOT EXISTS therapeutic_unit_options (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  therapeutic_id uuid NOT NULL REFERENCES therapeutics_base(id) ON DELETE CASCADE,
  unit_id uuid NOT NULL REFERENCES units_base(id) ON DELETE CASCADE,

  -- Conversion factor to therapeutic's base unit
  -- For IU: this is substance-specific (e.g., Vitamin D: 1 IU = 0.025 mcg)
  conversion_to_base_factor numeric,

  -- Default unit for this therapeutic (displayed first in UI)
  is_default boolean DEFAULT false,

  -- Available for selection in UI
  is_available boolean DEFAULT true,

  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),

  -- Prevent duplicate unit assignments
  CONSTRAINT unique_therapeutic_unit
    UNIQUE (therapeutic_id, unit_id)
);

-- Partial unique index: only one default per therapeutic
CREATE UNIQUE INDEX idx_therapeutic_unit_one_default
  ON therapeutic_unit_options(therapeutic_id)
  WHERE is_default = true;

CREATE INDEX idx_therapeutic_unit_options_therapeutic
  ON therapeutic_unit_options(therapeutic_id);

CREATE INDEX idx_therapeutic_unit_options_unit
  ON therapeutic_unit_options(unit_id);

COMMENT ON TABLE therapeutic_unit_options IS
'Defines which units are available for each therapeutic and their conversion factors. Handles substance-specific IU conversions.';

COMMENT ON COLUMN therapeutic_unit_options.conversion_to_base_factor IS
'Factor to convert this unit to the therapeutic base unit. For IU: substance-specific (e.g., Vitamin D: 1 IU = 0.025 mcg, so factor = 0.025)';


-- =====================================================
-- Table 2: unit_conversions
-- =====================================================
-- Generic unit conversions (not substance-specific)
-- e.g., mg to g, ml to l

CREATE TABLE IF NOT EXISTS unit_conversions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  from_unit_id uuid NOT NULL REFERENCES units_base(id) ON DELETE CASCADE,
  to_unit_id uuid NOT NULL REFERENCES units_base(id) ON DELETE CASCADE,

  -- Conversion factor (from_value * conversion_factor = to_value)
  conversion_factor numeric NOT NULL,

  -- Type of conversion (mostly 'multiply', but 'divide' for inverse)
  conversion_type text DEFAULT 'multiply' CHECK (conversion_type IN ('multiply', 'divide')),

  created_at timestamptz DEFAULT now(),

  -- Prevent duplicate conversions
  CONSTRAINT unique_unit_conversion
    UNIQUE (from_unit_id, to_unit_id),

  -- Prevent self-conversion
  CONSTRAINT no_self_conversion
    CHECK (from_unit_id != to_unit_id)
);

CREATE INDEX idx_unit_conversions_from
  ON unit_conversions(from_unit_id);

CREATE INDEX idx_unit_conversions_to
  ON unit_conversions(to_unit_id);

COMMENT ON TABLE unit_conversions IS
'Generic unit conversions not specific to any substance. For substance-specific conversions (like IU), use therapeutic_unit_options.';

COMMENT ON COLUMN unit_conversions.conversion_factor IS
'Multiply from_value by this factor to get to_value. Example: mg to g = 0.001 (1 mg = 0.001 g)';


-- =====================================================
-- Populate unit_conversions with common conversions
-- =====================================================

-- First, get or create common unit IDs
DO $$
DECLARE
  mg_unit_id uuid;
  g_unit_id uuid;
  mcg_unit_id uuid;
  ml_unit_id uuid;
  l_unit_id uuid;
  iu_unit_id uuid;
BEGIN
  -- Get existing units by symbol
  SELECT id INTO mg_unit_id FROM units_base WHERE symbol = 'mg' LIMIT 1;
  SELECT id INTO g_unit_id FROM units_base WHERE symbol = 'g' LIMIT 1;
  SELECT id INTO mcg_unit_id FROM units_base WHERE symbol = 'mcg' OR symbol = 'μg' LIMIT 1;
  SELECT id INTO ml_unit_id FROM units_base WHERE symbol = 'ml' OR symbol = 'mL' LIMIT 1;
  SELECT id INTO l_unit_id FROM units_base WHERE symbol = 'l' OR symbol = 'L' LIMIT 1;
  SELECT id INTO iu_unit_id FROM units_base WHERE symbol = 'IU' LIMIT 1;

  -- Insert common conversions if units exist

  -- Mass conversions
  IF mg_unit_id IS NOT NULL AND g_unit_id IS NOT NULL THEN
    INSERT INTO unit_conversions (from_unit_id, to_unit_id, conversion_factor, conversion_type)
    VALUES (mg_unit_id, g_unit_id, 0.001, 'multiply')
    ON CONFLICT (from_unit_id, to_unit_id) DO NOTHING;

    INSERT INTO unit_conversions (from_unit_id, to_unit_id, conversion_factor, conversion_type)
    VALUES (g_unit_id, mg_unit_id, 1000, 'multiply')
    ON CONFLICT (from_unit_id, to_unit_id) DO NOTHING;
  END IF;

  IF mcg_unit_id IS NOT NULL AND mg_unit_id IS NOT NULL THEN
    INSERT INTO unit_conversions (from_unit_id, to_unit_id, conversion_factor, conversion_type)
    VALUES (mcg_unit_id, mg_unit_id, 0.001, 'multiply')
    ON CONFLICT (from_unit_id, to_unit_id) DO NOTHING;

    INSERT INTO unit_conversions (from_unit_id, to_unit_id, conversion_factor, conversion_type)
    VALUES (mg_unit_id, mcg_unit_id, 1000, 'multiply')
    ON CONFLICT (from_unit_id, to_unit_id) DO NOTHING;
  END IF;

  IF mcg_unit_id IS NOT NULL AND g_unit_id IS NOT NULL THEN
    INSERT INTO unit_conversions (from_unit_id, to_unit_id, conversion_factor, conversion_type)
    VALUES (mcg_unit_id, g_unit_id, 0.000001, 'multiply')
    ON CONFLICT (from_unit_id, to_unit_id) DO NOTHING;

    INSERT INTO unit_conversions (from_unit_id, to_unit_id, conversion_factor, conversion_type)
    VALUES (g_unit_id, mcg_unit_id, 1000000, 'multiply')
    ON CONFLICT (from_unit_id, to_unit_id) DO NOTHING;
  END IF;

  -- Volume conversions
  IF ml_unit_id IS NOT NULL AND l_unit_id IS NOT NULL THEN
    INSERT INTO unit_conversions (from_unit_id, to_unit_id, conversion_factor, conversion_type)
    VALUES (ml_unit_id, l_unit_id, 0.001, 'multiply')
    ON CONFLICT (from_unit_id, to_unit_id) DO NOTHING;

    INSERT INTO unit_conversions (from_unit_id, to_unit_id, conversion_factor, conversion_type)
    VALUES (l_unit_id, ml_unit_id, 1000, 'multiply')
    ON CONFLICT (from_unit_id, to_unit_id) DO NOTHING;
  END IF;

END $$;


-- =====================================================
-- Create Event Type: therapeutic_intake
-- =====================================================

INSERT INTO event_types (
  event_type_id,
  name,
  category,
  description,
  is_active
) VALUES (
  'therapeutic_intake',
  'Therapeutic Intake',
  'health_tracking',
  'Event for tracking medications, supplements, and peptides',
  true
)
ON CONFLICT (event_type_id) DO UPDATE
SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  updated_at = now();


-- =====================================================
-- Create Data Entry Fields (3 fields to replace 75+)
-- =====================================================

-- Field 1: therapeutic_taken (FK to therapeutics_base)
INSERT INTO data_entry_fields (
  field_id,
  field_name,
  display_name,
  description,
  field_type,
  data_type,
  is_active
) VALUES (
  'DEF_THERAPEUTIC_TAKEN',
  'therapeutic_taken',
  'Which therapeutic did you take?',
  'Select the medication, supplement, or peptide you took',
  'reference',
  'uuid',
  true
)
ON CONFLICT (field_id) DO UPDATE
SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  updated_at = now();

-- Field 2: therapeutic_dosage (numeric input)
INSERT INTO data_entry_fields (
  field_id,
  field_name,
  display_name,
  description,
  field_type,
  data_type,
  is_active
) VALUES (
  'DEF_THERAPEUTIC_DOSAGE',
  'therapeutic_dosage',
  'How much did you take?',
  'Enter the dosage amount',
  'quantity',
  'numeric',
  true
)
ON CONFLICT (field_id) DO UPDATE
SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  updated_at = now();

-- Field 3: therapeutic_unit (FK to units_base)
INSERT INTO data_entry_fields (
  field_id,
  field_name,
  display_name,
  description,
  field_type,
  data_type,
  is_active
) VALUES (
  'DEF_THERAPEUTIC_UNIT',
  'therapeutic_unit',
  'What unit?',
  'Select the dosage unit (mg, mcg, IU, etc.)',
  'reference',
  'uuid',
  true
)
ON CONFLICT (field_id) DO UPDATE
SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  updated_at = now();


-- =====================================================
-- Link Fields to Event Type
-- =====================================================

INSERT INTO event_types_data_entry_fields (
  event_type_id,
  data_entry_field_id,
  display_order,
  is_required
) VALUES
  ('therapeutic_intake', 'DEF_THERAPEUTIC_TAKEN', 1, true),
  ('therapeutic_intake', 'DEF_THERAPEUTIC_DOSAGE', 2, true),
  ('therapeutic_intake', 'DEF_THERAPEUTIC_UNIT', 3, true)
ON CONFLICT (event_type_id, data_entry_field_id) DO UPDATE
SET
  display_order = EXCLUDED.display_order,
  is_required = EXCLUDED.is_required,
  updated_at = now();


COMMIT;
