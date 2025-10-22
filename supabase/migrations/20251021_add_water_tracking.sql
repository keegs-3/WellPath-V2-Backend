-- =====================================================
-- Add Water Tracking Fields
-- =====================================================
-- Simple water tracking with quantity, units, and time
-- Uses existing units_base and unit_conversions infrastructure
-- Supports both manual entry and HealthKit sync
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Add Water Data Entry Fields
-- =====================================================

INSERT INTO data_entry_fields (
  field_id,
  field_name,
  display_name,
  description,
  field_type,
  data_type,
  unit,
  is_active,
  healthkit_identifier,
  healthkit_mapping_id,
  supports_healthkit_sync,
  validation_config
) VALUES
-- Water quantity
(
  'DEF_WATER_QUANTITY',
  'water_quantity',
  'Water Quantity',
  'Amount of water consumed',
  'quantity',
  'numeric',
  NULL, -- Unit is determined by DEF_WATER_UNITS field
  true,
  'HKQuantityTypeIdentifierDietaryWater',
  (SELECT id FROM healthkit_mapping WHERE healthkit_identifier = 'HKQuantityTypeIdentifierDietaryWater'),
  true,
  '{"min": 0, "max": 5000, "increment": 1}'::jsonb
),
-- Water units (reference to units_base via unit_id)
-- User can select: fl oz, cups, mL, L, pints, etc.
-- Conversions handled by existing unit_conversions table
(
  'DEF_WATER_UNITS',
  'water_units',
  'Water Units',
  'Unit of measurement for water (references units_base.unit_id)',
  'reference',
  'text', -- Stores unit_id from units_base (e.g., 'fluid_ounce', 'milliliter', 'liter')
  NULL,
  true,
  NULL,
  NULL,
  false,
  NULL
),
-- Water time
(
  'DEF_WATER_TIME',
  'water_time',
  'Water Consumption Time',
  'When water was consumed',
  'timestamp',
  'datetime',
  NULL,
  true,
  NULL,
  NULL,
  false,
  NULL
)
ON CONFLICT (field_id) DO NOTHING;


-- =====================================================
-- PART 2: Add comments for clarity
-- =====================================================

COMMENT ON COLUMN data_entry_fields.healthkit_identifier IS
'HKQuantityTypeIdentifierDietaryWater - HealthKit stores water in mL, use unit_conversions for sync';

-- Note: Volume units and conversions already exist in units_base and unit_conversions
-- Common water units available:
--   - fluid_ounce (fl oz) - 29.57 mL
--   - cup (cups) - 236.59 mL
--   - milliliter (mL) - 1 mL
--   - liter (L) - 1000 mL
--   - pint_us (pt_us) - 473.18 mL

COMMIT;
