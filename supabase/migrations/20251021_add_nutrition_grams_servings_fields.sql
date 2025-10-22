-- =====================================================
-- Add GRAMS and SERVINGS Fields for Nutrition Tracking
-- =====================================================
-- Enables bidirectional conversion: user enters one, system calculates other
-- Pattern: GRAMS + SERVINGS (no separate UNITS field needed for 2 options)
--
-- Fiber: DEF_FIBER_GRAMS + DEF_FIBER_SERVINGS
-- Protein: DEF_PROTEIN_GRAMS + DEF_PROTEIN_SERVINGS
-- Fat: DEF_FAT_GRAMS + DEF_FAT_SERVINGS
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Rename Existing QUANTITY Fields to GRAMS
-- =====================================================

-- Fiber: Rename QUANTITY to GRAMS (already in grams)
UPDATE data_entry_fields
SET
  field_id = 'DEF_FIBER_GRAMS',
  field_name = 'fiber_grams',
  display_name = 'Fiber (grams)',
  description = 'Fiber intake in grams. User enters OR auto-calculated from servings.'
WHERE field_id = 'DEF_FIBER_QUANTITY';

-- Protein: Rename QUANTITY to GRAMS (already in grams)
UPDATE data_entry_fields
SET
  field_id = 'DEF_PROTEIN_GRAMS',
  field_name = 'protein_grams',
  display_name = 'Protein (grams)',
  description = 'Protein intake in grams. User enters OR auto-calculated from servings.'
WHERE field_id = 'DEF_PROTEIN_QUANTITY';

-- Fat: Rename QUANTITY to GRAMS (already in grams)
UPDATE data_entry_fields
SET
  field_id = 'DEF_FAT_GRAMS',
  field_name = 'fat_grams',
  display_name = 'Fat (grams)',
  description = 'Fat intake in grams. User enters OR auto-calculated from servings.'
WHERE field_id = 'DEF_FAT_QUANTITY';


-- =====================================================
-- PART 2: Add SERVINGS Fields
-- =====================================================

-- Fiber Servings
INSERT INTO data_entry_fields (
  field_id,
  field_name,
  display_name,
  description,
  field_type,
  data_type,
  unit,
  is_active,
  pillar_name,
  category_id,
  validation_type,
  validation_config
) VALUES (
  'DEF_FIBER_SERVINGS',
  'fiber_servings',
  'Fiber (servings)',
  'Fiber intake in servings. User enters OR auto-calculated from grams using fiber source averages.',
  'quantity',
  'numeric',
  'serving',
  true,
  'Healthful Nutrition',
  'nutrition_healthy_additions',
  'numeric',
  '{"min": 0, "max": 50, "increment": 0.5}'::jsonb
)
ON CONFLICT (field_id) DO NOTHING;

-- Protein Servings
INSERT INTO data_entry_fields (
  field_id,
  field_name,
  display_name,
  description,
  field_type,
  data_type,
  unit,
  is_active,
  pillar_name,
  category_id,
  validation_type,
  validation_config
) VALUES (
  'DEF_PROTEIN_SERVINGS',
  'protein_servings',
  'Protein (servings)',
  'Protein intake in servings. User enters OR auto-calculated from grams using protein type averages.',
  'quantity',
  'numeric',
  'serving',
  true,
  'Healthful Nutrition',
  'nutrition_healthy_additions',
  'numeric',
  '{"min": 0, "max": 20, "increment": 0.5}'::jsonb
)
ON CONFLICT (field_id) DO NOTHING;

-- Fat Servings
INSERT INTO data_entry_fields (
  field_id,
  field_name,
  display_name,
  description,
  field_type,
  data_type,
  unit,
  is_active,
  pillar_name,
  category_id,
  validation_type,
  validation_config
) VALUES (
  'DEF_FAT_SERVINGS',
  'fat_servings',
  'Fat (servings)',
  'Fat intake in servings. User enters OR auto-calculated from grams using fat type averages.',
  'quantity',
  'numeric',
  'serving',
  true,
  'Healthful Nutrition',
  'nutrition_healthy_additions',
  'numeric',
  '{"min": 0, "max": 20, "increment": 0.5}'::jsonb
)
ON CONFLICT (field_id) DO NOTHING;


-- =====================================================
-- PART 3: Update Dependencies
-- =====================================================

-- Update any references to old field IDs in junction tables
UPDATE event_types_data_entry_fields
SET data_entry_field_id = 'DEF_FIBER_GRAMS'
WHERE data_entry_field_id = 'DEF_FIBER_QUANTITY';

UPDATE event_types_data_entry_fields
SET data_entry_field_id = 'DEF_PROTEIN_GRAMS'
WHERE data_entry_field_id = 'DEF_PROTEIN_QUANTITY';

UPDATE event_types_data_entry_fields
SET data_entry_field_id = 'DEF_FAT_GRAMS'
WHERE data_entry_field_id = 'DEF_FAT_QUANTITY';


-- =====================================================
-- PART 4: Add Comments
-- =====================================================

COMMENT ON COLUMN data_entry_fields.field_id IS
'Unique identifier for the field. For nutrition tracking with bidirectional conversion:
- *_GRAMS fields: User enters OR auto-calculated from servings
- *_SERVINGS fields: User enters OR auto-calculated from grams
- Exactly ONE must be user-entered, the other is calculated via instance_calculations';


COMMIT;
