-- =====================================================
-- Create Field Registry Architecture
-- =====================================================
-- Central registry for ALL field identifiers (user-input, calculated, or hybrid)
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Create Field Registry Table
-- =====================================================

CREATE TABLE IF NOT EXISTS field_registry (
  field_id TEXT PRIMARY KEY,
  field_name TEXT NOT NULL,
  display_name TEXT NOT NULL,
  description TEXT,
  field_source TEXT NOT NULL CHECK (field_source IN ('user_input', 'calculated', 'hybrid')),
  data_entry_field_id TEXT REFERENCES data_entry_fields(field_id) ON UPDATE CASCADE ON DELETE SET NULL,
  instance_calculation_id TEXT REFERENCES instance_calculations(calc_id) ON UPDATE CASCADE ON DELETE SET NULL,
  unit TEXT REFERENCES units_base(unit_id) ON UPDATE CASCADE ON DELETE SET NULL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  -- Ensure at least one source is specified
  CONSTRAINT field_registry_has_source CHECK (
    data_entry_field_id IS NOT NULL OR instance_calculation_id IS NOT NULL
  )
);

-- Add indexes
CREATE INDEX idx_field_registry_source ON field_registry(field_source);
CREATE INDEX idx_field_registry_data_entry ON field_registry(data_entry_field_id);
CREATE INDEX idx_field_registry_calculation ON field_registry(instance_calculation_id);
CREATE INDEX idx_field_registry_active ON field_registry(is_active);

-- Add trigger for updated_at
CREATE TRIGGER update_field_registry_updated_at
  BEFORE UPDATE ON field_registry
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();


-- =====================================================
-- PART 2: Populate from data_entry_fields
-- =====================================================

-- First, populate all user-input fields from data_entry_fields
INSERT INTO field_registry (field_id, field_name, display_name, description, field_source, data_entry_field_id, unit)
SELECT
  field_id,
  field_name,
  display_name,
  description,
  'user_input' as field_source,
  field_id as data_entry_field_id,
  unit
FROM data_entry_fields
WHERE field_id NOT IN (
  -- Exclude duration fields - these are calculated only
  'DEF_SLEEP_DURATION', 'DEF_SLEEP_PERIOD_DURATION', 'DEF_CARDIO_DURATION',
  'DEF_HIIT_DURATION', 'DEF_STRENGTH_DURATION', 'DEF_MOBILITY_DURATION',
  'DEF_MINDFULNESS_DURATION', 'DEF_BRAIN_TRAINING_DURATION', 'DEF_JOURNALING_DURATION',
  'DEF_OUTDOOR_DURATION', 'DEF_SUNLIGHT_DURATION'
)
ON CONFLICT (field_id) DO NOTHING;


-- =====================================================
-- PART 3: Mark Hybrid Fields (can be input OR calculated)
-- =====================================================

-- Update biometric fields that can be both user-input AND calculated
UPDATE field_registry
SET
  field_source = 'hybrid',
  instance_calculation_id = ic.calc_id
FROM instance_calculations ic
WHERE field_registry.field_id IN (
  'DEF_BMI',                -- Can be entered or calculated
  'DEF_BMR',                -- Can be entered or calculated
  'DEF_BODY_FAT_PCT',       -- Can be entered or calculated
  'DEF_LEAN_BODY_MASS',     -- Can be entered or calculated
  'DEF_HIP_WAIST_RATIO'     -- Can be entered or calculated
)
AND ic.calc_id IN (
  'CALC_BMI',
  'CALC_BMR',
  'CALC_BODY_FAT_PERCENTAGE',
  'CALC_LEAN_BODY_MASS',
  'CALC_HIP_WAIST_RATIO'
)
AND (
  (field_registry.field_id = 'DEF_BMI' AND ic.calc_id = 'CALC_BMI') OR
  (field_registry.field_id = 'DEF_BMR' AND ic.calc_id = 'CALC_BMR') OR
  (field_registry.field_id = 'DEF_BODY_FAT_PCT' AND ic.calc_id = 'CALC_BODY_FAT_PERCENTAGE') OR
  (field_registry.field_id = 'DEF_LEAN_BODY_MASS' AND ic.calc_id = 'CALC_LEAN_BODY_MASS') OR
  (field_registry.field_id = 'DEF_HIP_WAIST_RATIO' AND ic.calc_id = 'CALC_HIP_WAIST_RATIO')
);


-- =====================================================
-- PART 4: Add Calculated-Only Fields from instance_calculations
-- =====================================================

-- Add duration calculations (calculated only, not in data_entry_fields)
INSERT INTO field_registry (field_id, field_name, display_name, description, field_source, instance_calculation_id, unit)
VALUES
('DEF_SLEEP_DURATION', 'sleep_duration', 'Sleep Duration', 'Total sleep duration (calculated)', 'calculated', 'CALC_SLEEP_DURATION', 'minute'),
('DEF_SLEEP_PERIOD_DURATION', 'sleep_period_duration', 'Sleep Period Duration', 'Individual sleep period duration (calculated)', 'calculated', 'CALC_SLEEP_PERIOD_DURATION', 'minute'),
('DEF_CARDIO_DURATION', 'cardio_duration', 'Cardio Duration', 'Cardio workout duration (calculated)', 'calculated', 'CALC_CARDIO_DURATION', 'minute'),
('DEF_HIIT_DURATION', 'hiit_duration', 'HIIT Duration', 'HIIT workout duration (calculated)', 'calculated', 'CALC_HIIT_DURATION', 'minute'),
('DEF_STRENGTH_DURATION', 'strength_duration', 'Strength Duration', 'Strength training duration (calculated)', 'calculated', 'CALC_STRENGTH_DURATION', 'minute'),
('DEF_MOBILITY_DURATION', 'mobility_duration', 'Mobility Duration', 'Mobility workout duration (calculated)', 'calculated', 'CALC_MOBILITY_DURATION', 'minute'),
('DEF_MINDFULNESS_DURATION', 'mindfulness_duration', 'Mindfulness Duration', 'Mindfulness session duration (calculated)', 'calculated', 'CALC_MINDFULNESS_DURATION', 'minute'),
('DEF_BRAIN_TRAINING_DURATION', 'brain_training_duration', 'Brain Training Duration', 'Brain training session duration (calculated)', 'calculated', 'CALC_BRAIN_TRAINING_DURATION', 'minute'),
('DEF_JOURNALING_DURATION', 'journaling_duration', 'Journaling Duration', 'Journaling session duration (calculated)', 'calculated', 'CALC_JOURNALING_DURATION', 'minute'),
('DEF_OUTDOOR_DURATION', 'outdoor_duration', 'Outdoor Duration', 'Outdoor time duration (calculated)', 'calculated', 'CALC_OUTDOOR_DURATION', 'minute'),
('DEF_SUNLIGHT_DURATION', 'sunlight_duration', 'Sunlight Duration', 'Sunlight exposure duration (calculated)', 'calculated', 'CALC_SUNLIGHT_DURATION', 'minute')
ON CONFLICT (field_id) DO NOTHING;


-- =====================================================
-- PART 5: Update patient_data_entries FK Constraint
-- =====================================================

-- Drop old FK constraint
ALTER TABLE patient_data_entries
DROP CONSTRAINT IF EXISTS patient_data_entries_field_id_fkey;

-- Add new FK constraint to field_registry
ALTER TABLE patient_data_entries
ADD CONSTRAINT patient_data_entries_field_id_fkey
  FOREIGN KEY (field_id) REFERENCES field_registry(field_id) ON UPDATE CASCADE ON DELETE RESTRICT;


-- =====================================================
-- Summary
-- =====================================================

DO $$
DECLARE
  total_fields INT;
  user_input_count INT;
  calculated_count INT;
  hybrid_count INT;
BEGIN
  SELECT COUNT(*) INTO total_fields FROM field_registry;
  SELECT COUNT(*) INTO user_input_count FROM field_registry WHERE field_source = 'user_input';
  SELECT COUNT(*) INTO calculated_count FROM field_registry WHERE field_source = 'calculated';
  SELECT COUNT(*) INTO hybrid_count FROM field_registry WHERE field_source = 'hybrid';

  RAISE NOTICE '✅ Field Registry Created';
  RAISE NOTICE 'Total fields: %', total_fields;
  RAISE NOTICE 'User input fields: %', user_input_count;
  RAISE NOTICE 'Calculated fields: %', calculated_count;
  RAISE NOTICE 'Hybrid fields: %', hybrid_count;
END $$;

COMMIT;
