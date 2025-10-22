-- =====================================================
-- Finalize Substance Tracking Architecture
-- =====================================================
-- Simplifies to two patterns:
-- 1. Precise tracking: Alcohol + Cigarettes (quantity + datetime)
-- 2. Usage bands: Other substances (5-level scale + date)
--
-- Removes: OTC medications (handled by therapeutics)
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Create Usage Level Enum
-- =====================================================

CREATE TYPE substance_usage_level AS ENUM (
  'heavy',
  'moderate',
  'light',
  'minimal',
  'occasional'
);


-- =====================================================
-- PART 2: Add Cigarette Tracking Fields (Precise)
-- =====================================================

INSERT INTO data_entry_fields (
  field_id,
  field_name,
  display_name,
  description,
  field_type,
  data_type,
  is_active,
  pillar_name,
  category_id,
  validation_type,
  validation_config,
  related_pillars
) VALUES
(
  'DEF_CIGARETTE_QUANTITY',
  'cigarette_quantity',
  'Cigarettes',
  'Number of cigarettes smoked. Can be logged per instance or daily total.',
  'quantity',
  'numeric',
  true,
  'Core Care',
  'core_substances',
  'numeric',
  '{"min": 0, "max": 100, "increment": 1}'::jsonb,
  '["Restorative Sleep", "Cognitive Health", "Movement + Exercise"]'::jsonb
),
(
  'DEF_CIGARETTE_TIME',
  'cigarette_time',
  'Time',
  'When cigarettes were smoked (datetime for instance tracking or end of day for daily totals)',
  'timestamp',
  'datetime',
  true,
  'Core Care',
  'core_substances',
  'timestamp',
  '{}'::jsonb,
  '[]'::jsonb
)
ON CONFLICT (field_id) DO NOTHING;


-- =====================================================
-- PART 3: Add Usage Level Field for Other Substances
-- =====================================================

INSERT INTO data_entry_fields (
  field_id,
  field_name,
  display_name,
  description,
  field_type,
  data_type,
  is_active,
  pillar_name,
  category_id,
  validation_type
) VALUES (
  'DEF_SUBSTANCE_USAGE_LEVEL',
  'substance_usage_level',
  'Usage Level',
  'Frequency/intensity of substance use. Options: heavy, moderate, light, minimal, occasional. Definitions vary by substance type.',
  'category',
  'text',
  true,
  'Core Care',
  'core_substances',
  'enum'
)
ON CONFLICT (field_id) DO NOTHING;


-- =====================================================
-- PART 4: Update Substance Date Field
-- =====================================================

-- Rename SUBSTANCE_TIME to SUBSTANCE_DATE (date only, not datetime)
UPDATE data_entry_fields
SET
  field_id = 'DEF_SUBSTANCE_DATE',
  field_name = 'substance_date',
  display_name = 'Date',
  description = 'Date of substance use assessment (usage level reflects pattern for that day)',
  data_type = 'date'
WHERE field_id = 'DEF_SUBSTANCE_TIME';


-- =====================================================
-- PART 5: Remove Quantity Field
-- =====================================================

-- Mark SUBSTANCE_QUANTITY as inactive (no longer needed)
UPDATE data_entry_fields
SET is_active = false
WHERE field_id = 'DEF_SUBSTANCE_QUANTITY';


-- =====================================================
-- PART 6: Remove OTC Medications from Substance Types
-- =====================================================

DELETE FROM def_ref_substance_types
WHERE category = 'otc_medication';

-- Note: OTC medications tracked via therapeutics (DEF_THERAPEUTIC_TYPE)


-- =====================================================
-- PART 7: Remove Cigarettes from Substance Types
-- =====================================================

-- Cigarettes now have dedicated fields, remove from substance types
DELETE FROM def_ref_substance_types
WHERE substance_type_key = 'cigarettes';


-- =====================================================
-- PART 8: Update Remaining Substance Types for Usage Bands
-- =====================================================

-- Add usage level definitions to remaining types
ALTER TABLE def_ref_substance_types
ADD COLUMN IF NOT EXISTS usage_level_definitions JSONB;

-- Tobacco (non-cigarette)
UPDATE def_ref_substance_types
SET usage_level_definitions = '{
  "heavy": "2+ packs per day (or equivalent heavy use)",
  "moderate": "1 pack per day (or moderate equivalent)",
  "light": "Less than 1 pack per day / occasional use",
  "minimal": "A few times a month or less",
  "occasional": "Only rarely or on special occasions"
}'::jsonb
WHERE category = 'tobacco';

-- Nicotine
UPDATE def_ref_substance_types
SET usage_level_definitions = '{
  "heavy": "All-day or equivalent to 2+ packs/day",
  "moderate": "Most of the day/equivalent to 1 pack/day",
  "light": "Less than daily or only in specific situations",
  "minimal": "A few times a month or less",
  "occasional": "Only rarely or on special occasions"
}'::jsonb
WHERE category = 'nicotine';

-- Cannabis
UPDATE def_ref_substance_types
SET usage_level_definitions = '{
  "heavy": "Daily or almost daily use",
  "moderate": "Weekly use (1–2x/week)",
  "light": "Monthly or less",
  "minimal": "A few times a year",
  "occasional": "Only a handful of times ever"
}'::jsonb
WHERE category = 'recreational';


-- =====================================================
-- PART 9: Remove Unit Fields (No Longer Needed)
-- =====================================================

ALTER TABLE def_ref_substance_types
DROP COLUMN IF EXISTS default_unit,
DROP COLUMN IF EXISTS unit_descriptor;


-- =====================================================
-- PART 10: Update Alcohol Description
-- =====================================================

UPDATE data_entry_fields
SET
  description = 'Number of standard drinks consumed. 1 drink = 12 oz beer, 5 oz wine, or 1.5 oz spirits. Tracked with datetime for sleep correlation analysis.',
  related_pillars = '["Restorative Sleep", "Stress Management", "Cognitive Health"]'::jsonb
WHERE field_id = 'DEF_ALCOHOL_QUANTITY';


-- =====================================================
-- PART 11: Add Comments
-- =====================================================

COMMENT ON TYPE substance_usage_level IS
'Usage frequency/intensity levels for substance tracking. Definitions vary by substance type:

Tobacco/Nicotine: Based on pack-per-day equivalents
Cannabis: Based on frequency (daily, weekly, monthly, etc.)
Other: General frequency descriptors

Levels: heavy, moderate, light, minimal, occasional';

COMMENT ON COLUMN def_ref_substance_types.usage_level_definitions IS
'JSONB object defining what each usage level means for this substance type. Used for UI display and patient education.

Example:
{
  "heavy": "Daily or almost daily use",
  "moderate": "Weekly use (1–2x/week)",
  "light": "Monthly or less",
  "minimal": "A few times a year",
  "occasional": "Only a handful of times ever"
}';


COMMIT;
