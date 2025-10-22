-- =====================================================
-- Add Meal Qualifiers Reference and Link Field
-- =====================================================
-- Creates reference table for meal qualifiers
-- Supports multiple qualifiers per meal via JSONB array
--
-- Supports:
-- - REC0021: Daily Whole Food Meals
-- - REC0023: Reduce Takeout/Delivery Meals
-- - REC0024: Daily Plant-Based Meals
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Create Meal Qualifiers Reference Table
-- =====================================================

CREATE TABLE IF NOT EXISTS def_ref_meal_qualifiers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  qualifier_key TEXT UNIQUE NOT NULL,
  display_name TEXT NOT NULL,
  category TEXT, -- 'quality', 'dietary_pattern', 'preparation_method'
  description TEXT,
  is_positive BOOLEAN DEFAULT true, -- True for healthy qualifiers, false for elimination targets
  display_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert meal qualifiers
INSERT INTO def_ref_meal_qualifiers (qualifier_key, display_name, category, description, is_positive, display_order) VALUES
-- Quality/Processing Level
('whole_food', 'Whole Food', 'quality', 'Made from unprocessed or minimally processed ingredients (REC0021)', true, 1),
('ultra_processed', 'Ultra-Processed', 'quality', 'Contains mostly ultra-processed foods (REC0022)', false, 2),

-- Dietary Patterns
('plant_based', 'Plant-Based', 'dietary_pattern', 'No animal products in this meal (REC0024)', true, 3),
('vegetarian', 'Vegetarian', 'dietary_pattern', 'No meat, may include dairy/eggs', true, 4),
('contains_meat', 'Contains Meat', 'dietary_pattern', 'Includes meat protein', true, 5),

-- Preparation Method
('home_cooked', 'Home-Cooked', 'preparation_method', 'Prepared at home from scratch or simple ingredients', true, 6),
('meal_prep', 'Meal Prep', 'preparation_method', 'Pre-prepared meal from home cooking batch', true, 7),
('restaurant', 'Restaurant', 'preparation_method', 'Eaten at a restaurant', true, 8),
('takeout_delivery', 'Takeout/Delivery', 'preparation_method', 'Ordered for takeout or delivery (REC0023)', false, 9),
('fast_food', 'Fast Food', 'preparation_method', 'From a fast food restaurant', false, 10),

-- Special Preparation
('batch_cooked', 'Batch Cooked', 'preparation_method', 'Part of a larger batch cooking session', true, 11),
('leftovers', 'Leftovers', 'preparation_method', 'Previously cooked meal reheated', true, 12)

ON CONFLICT (qualifier_key) DO NOTHING;


-- =====================================================
-- PART 2: Update meal_qualifiers Field Configuration
-- =====================================================

-- Update the existing DEF_MEAL_QUALIFIERS field to properly link to reference table
-- Change data_type from 'uuid' to 'jsonb' to support multiple qualifiers
UPDATE data_entry_fields
SET
  data_type = 'jsonb',
  reference_table = 'def_ref_meal_qualifiers',
  description = 'Meal qualifiers (multiple allowed). Stores JSONB array of qualifier_keys from def_ref_meal_qualifiers.',
  validation_config = '{"type": "array", "items": {"type": "string"}, "maxItems": 5}'::jsonb
WHERE field_id = 'DEF_MEAL_QUALIFIERS';


-- =====================================================
-- PART 3: Add Helper Function for Meal Qualifier Queries
-- =====================================================

-- Function to check if a meal has a specific qualifier
CREATE OR REPLACE FUNCTION meal_has_qualifier(qualifiers JSONB, qualifier_key TEXT)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN qualifiers ? qualifier_key;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION meal_has_qualifier IS
'Helper function to check if a meal entry contains a specific qualifier. Usage: WHERE meal_has_qualifier(value_reference::jsonb, ''whole_food'')';


-- =====================================================
-- PART 4: Add comments for clarity
-- =====================================================

COMMENT ON TABLE def_ref_meal_qualifiers IS
'Reference table for meal qualifiers. Meals can have multiple qualifiers stored as JSONB array in patient_data_entries.value_reference.';

COMMENT ON COLUMN def_ref_meal_qualifiers.is_positive IS
'True for healthy/beneficial qualifiers (whole_food, plant_based). False for elimination targets (takeout_delivery, ultra_processed).';

-- Example usage comment
COMMENT ON COLUMN data_entry_fields.validation_config IS
E'JSONB validation configuration. For meal_qualifiers: stores array of qualifier_keys.\n\nExample stored value: ["whole_food", "plant_based", "home_cooked"]\n\nQuery example: SELECT * FROM patient_data_entries WHERE value_reference::jsonb ? ''whole_food''';

COMMIT;
