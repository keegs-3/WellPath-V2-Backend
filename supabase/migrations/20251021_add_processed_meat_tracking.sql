-- =====================================================
-- Add Processed Meat Tracking Fields
-- =====================================================
-- Tracks servings of processed meat
-- Supports REC0010 (Reduce Processed Meat Intake) - all levels
--
-- REC0010.1: Limit to ≤3 servings per week
-- REC0010.2: Limit to ≤1 serving per week
-- REC0010.3: Eliminate entirely
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Create Processed Meat Types Reference Table
-- =====================================================

CREATE TABLE IF NOT EXISTS def_ref_processed_meat_types (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  meat_type_key TEXT UNIQUE NOT NULL,
  display_name TEXT NOT NULL,
  category TEXT, -- 'cured', 'smoked', 'deli', 'sausage', 'canned'
  nitrate_level TEXT, -- 'high', 'medium', 'low', 'nitrate_free'
  typical_serving_size TEXT, -- e.g., "2 slices", "1 hot dog", "3 oz"
  example_items TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert common processed meat types
INSERT INTO def_ref_processed_meat_types (meat_type_key, display_name, category, nitrate_level, typical_serving_size, example_items) VALUES
-- Deli/Lunch Meats
('deli_meat', 'Deli/Lunch Meat', 'deli', 'high', '2-3 slices', 'Deli turkey, ham, roast beef, salami'),
('bacon', 'Bacon', 'cured', 'high', '2-3 slices', 'Regular bacon, turkey bacon'),

-- Sausages & Hot Dogs
('hot_dog', 'Hot Dog', 'sausage', 'high', '1 hot dog', 'Beef, pork, or turkey hot dogs'),
('sausage', 'Sausage', 'sausage', 'medium', '1-2 links', 'Breakfast sausage, Italian sausage, bratwurst'),
('chorizo', 'Chorizo', 'sausage', 'medium', '2 oz', 'Spanish or Mexican chorizo'),
('pepperoni', 'Pepperoni', 'cured', 'high', '15-20 slices', 'Pizza pepperoni, snack sticks'),

-- Specialty/Regional
('salami', 'Salami', 'cured', 'high', '3-4 slices', 'Hard salami, Genoa salami'),
('prosciutto', 'Prosciutto/Cured Ham', 'cured', 'medium', '2-3 slices', 'Prosciutto, serrano ham'),
('spam', 'Canned Meat Product', 'canned', 'high', '2 oz', 'SPAM, canned ham, Vienna sausages'),
('jerky', 'Jerky/Dried Meat', 'cured', 'medium', '1 oz', 'Beef jerky, turkey jerky'),

-- Lower Processing
('smoked_meat', 'Smoked Meat', 'smoked', 'low', '3 oz', 'Smoked turkey, smoked salmon'),
('nitrate_free_deli', 'Nitrate-Free Deli Meat', 'deli', 'nitrate_free', '2-3 slices', 'Organic/natural deli meats without nitrates')

ON CONFLICT (meat_type_key) DO NOTHING;


-- =====================================================
-- PART 2: Add Processed Meat Data Entry Fields
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
  supports_healthkit_sync,
  validation_config
) VALUES
-- Processed meat quantity (servings)
(
  'DEF_PROCESSED_MEAT_QUANTITY',
  'processed_meat_quantity',
  'Processed Meat Servings',
  'Number of servings of processed meat consumed',
  'quantity',
  'numeric',
  'serving',
  true,
  false,
  '{"min": 0, "max": 20, "increment": 1}'::jsonb
),
-- Processed meat type
(
  'DEF_PROCESSED_MEAT_TYPE',
  'processed_meat_type',
  'Processed Meat Type',
  'Type of processed meat (references def_ref_processed_meat_types)',
  'reference',
  'text', -- Stores meat_type_key
  NULL,
  true,
  false,
  NULL
),
-- Processed meat time
(
  'DEF_PROCESSED_MEAT_TIME',
  'processed_meat_time',
  'Consumption Time',
  'When the processed meat was consumed',
  'timestamp',
  'datetime',
  NULL,
  true,
  false,
  NULL
)
ON CONFLICT (field_id) DO NOTHING;

-- Link type field to reference table
UPDATE data_entry_fields
SET reference_table = 'def_ref_processed_meat_types'
WHERE field_id = 'DEF_PROCESSED_MEAT_TYPE';


-- =====================================================
-- PART 3: Add comments for clarity
-- =====================================================

COMMENT ON TABLE def_ref_processed_meat_types IS
'Reference table for processed meat types. Used for REC0010 (Reduce Processed Meat Intake) tracking.';

COMMENT ON COLUMN def_ref_processed_meat_types.nitrate_level IS
'Indicates typical nitrate/nitrite content. Helpful for users choosing healthier processed options.';

COMMIT;
