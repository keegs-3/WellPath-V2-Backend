-- =====================================================
-- Create Substance Use Category in Core Care Pillar
-- =====================================================
-- Separates substance tracking from nutrition into Core Care
-- Includes alcohol (moved from nutrition) + tobacco, nicotine, OTC, recreational
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Create Substance Use Category
-- =====================================================

INSERT INTO data_entry_categories (
  category_id,
  category_name,
  pillar_name,
  description,
  display_order
) VALUES (
  'core_substances',
  'Substance Use',
  'Core Care',
  'Tracking of substances that impact health: alcohol, tobacco, nicotine products, OTC medications, and recreational drugs. Important for longevity assessment and risk factor management.',
  6  -- After personal_care (5)
)
ON CONFLICT (category_id) DO NOTHING;


-- =====================================================
-- PART 2: Move Alcohol Fields to Substance Category
-- =====================================================

-- Move alcohol quantity
UPDATE data_entry_fields
SET
  pillar_name = 'Core Care',
  category_id = 'core_substances'
WHERE field_id = 'DEF_ALCOHOL_QUANTITY';

-- Move alcohol time
UPDATE data_entry_fields
SET
  pillar_name = 'Core Care',
  category_id = 'core_substances'
WHERE field_id = 'DEF_ALCOHOL_TIME';

-- Alcohol type field (currently inactive, but update for consistency)
UPDATE data_entry_fields
SET
  pillar_name = 'Core Care',
  category_id = 'core_substances'
WHERE field_id = 'DEF_ALCOHOL_TYPE';


-- =====================================================
-- PART 3: Move All Substance Fields to New Category
-- =====================================================

UPDATE data_entry_fields
SET
  pillar_name = 'Core Care',
  category_id = 'core_substances'
WHERE field_id IN (
  'DEF_SUBSTANCE_TYPE',
  'DEF_SUBSTANCE_QUANTITY',
  'DEF_SUBSTANCE_SOURCE',
  'DEF_SUBSTANCE_TIME'
);


-- =====================================================
-- PART 4: Update Related Pillars
-- =====================================================

-- Update alcohol fields to show cross-pillar impacts
UPDATE data_entry_fields
SET related_pillars = '["Restorative Sleep", "Stress Management", "Cognitive Health"]'::jsonb
WHERE field_id IN ('DEF_ALCOHOL_QUANTITY', 'DEF_ALCOHOL_TIME');

-- Substance fields also impact multiple pillars
UPDATE data_entry_fields
SET related_pillars = '["Restorative Sleep", "Cognitive Health", "Movement + Exercise"]'::jsonb
WHERE field_id IN ('DEF_SUBSTANCE_TYPE', 'DEF_SUBSTANCE_QUANTITY');


-- =====================================================
-- PART 5: Add Comments
-- =====================================================

COMMENT ON COLUMN data_entry_categories.category_id IS
'Unique identifier for the category. Format: {pillar_prefix}_{category_name}.
Examples: nutrition_meals, exercise_cardio, core_substances.';


COMMIT;
