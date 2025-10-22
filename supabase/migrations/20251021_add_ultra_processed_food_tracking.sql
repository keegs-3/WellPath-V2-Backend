-- =====================================================
-- Add Ultra-Processed Food Tracking Fields
-- =====================================================
-- Tracks servings of ultra-processed foods (NOVA Group 4)
-- Supports REC0022 (Reduce Ultra-Processed Foods) - all levels
--
-- REC0022.1: Limit to ≤1 serving per day, 2+ days/week
-- REC0022.2: Limit to ≤1 serving per day, 5+ days/week
-- REC0022.3: Eliminate entirely
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Create Ultra-Processed Food Types Reference Table
-- =====================================================

CREATE TABLE IF NOT EXISTS def_ref_ultra_processed_types (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  upf_type_key TEXT UNIQUE NOT NULL,
  display_name TEXT NOT NULL,
  category TEXT, -- 'snack', 'frozen_meal', 'instant', 'packaged_baked', 'sweetened_beverage', 'breakfast'
  nova_group INTEGER DEFAULT 4, -- NOVA classification (always 4 for ultra-processed)
  example_items TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert common ultra-processed food types
INSERT INTO def_ref_ultra_processed_types (upf_type_key, display_name, category, example_items) VALUES
-- Snacks & Chips
('chips_crisps', 'Chips/Crisps', 'snack', 'Potato chips, tortilla chips, cheese puffs, Pringles'),
('packaged_crackers', 'Packaged Crackers', 'snack', 'Cheese crackers, flavored crackers, club crackers'),
('candy_chocolate', 'Candy/Chocolate Bars', 'snack', 'Candy bars, M&Ms, Skittles, gummy candy'),
('cookies_packaged', 'Packaged Cookies', 'packaged_baked', 'Oreos, Chips Ahoy, store-bought cookies'),

-- Frozen & Instant Meals
('frozen_dinner', 'Frozen Dinner/Entree', 'frozen_meal', 'TV dinners, frozen pizza, Hot Pockets'),
('frozen_appetizer', 'Frozen Appetizer/Snack', 'frozen_meal', 'Frozen chicken nuggets, mozzarella sticks, pizza rolls'),
('instant_noodles', 'Instant Noodles/Ramen', 'instant', 'Cup noodles, instant ramen, instant mac & cheese'),
('instant_meal', 'Instant Meal Mix', 'instant', 'Hamburger Helper, boxed pasta meals, instant mashed potatoes'),

-- Breakfast Items
('breakfast_cereal_sugary', 'Sugary Breakfast Cereal', 'breakfast', 'Frosted Flakes, Froot Loops, Lucky Charms'),
('toaster_pastry', 'Toaster Pastries', 'breakfast', 'Pop-Tarts, toaster strudel'),
('breakfast_bar', 'Breakfast/Cereal Bar', 'breakfast', 'Nutri-Grain bars, Special K bars, cereal bars'),

-- Baked Goods
('packaged_cake', 'Packaged Cake/Pastry', 'packaged_baked', 'Hostess, Little Debbie, packaged donuts'),
('packaged_bread', 'Ultra-Processed Bread', 'packaged_baked', 'Wonder Bread, white sandwich bread with many additives'),

-- Beverages
('soda', 'Soda/Soft Drink', 'sweetened_beverage', 'Cola, lemon-lime soda, fruit-flavored sodas'),
('energy_drink', 'Energy Drink', 'sweetened_beverage', 'Red Bull, Monster, energy shots'),
('fruit_drink', 'Fruit Drink/Punch', 'sweetened_beverage', 'Fruit punch, Sunny D, Capri Sun'),

-- Convenience Foods
('deli_salad', 'Pre-Made Deli Salad', 'instant', 'Potato salad, coleslaw, pasta salad from deli'),
('protein_bar_upf', 'Ultra-Processed Protein Bar', 'snack', 'Protein bars with long ingredient lists'),
('meal_replacement', 'Meal Replacement Shake/Bar', 'instant', 'Slim-Fast, Ensure, meal bars')

ON CONFLICT (upf_type_key) DO NOTHING;


-- =====================================================
-- PART 2: Add Ultra-Processed Food Data Entry Fields
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
-- Ultra-processed food quantity (servings)
(
  'DEF_ULTRA_PROCESSED_QUANTITY',
  'ultra_processed_quantity',
  'Ultra-Processed Food Servings',
  'Number of servings of ultra-processed foods consumed',
  'quantity',
  'numeric',
  'serving',
  true,
  false,
  '{"min": 0, "max": 20, "increment": 1}'::jsonb
),
-- Ultra-processed food type
(
  'DEF_ULTRA_PROCESSED_TYPE',
  'ultra_processed_type',
  'Ultra-Processed Food Type',
  'Type of ultra-processed food (references def_ref_ultra_processed_types)',
  'reference',
  'text', -- Stores upf_type_key
  NULL,
  true,
  false,
  NULL
),
-- Ultra-processed food time
(
  'DEF_ULTRA_PROCESSED_TIME',
  'ultra_processed_time',
  'Consumption Time',
  'When the ultra-processed food was consumed',
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
SET reference_table = 'def_ref_ultra_processed_types'
WHERE field_id = 'DEF_ULTRA_PROCESSED_TYPE';


-- =====================================================
-- PART 3: Add comments for clarity
-- =====================================================

COMMENT ON TABLE def_ref_ultra_processed_types IS
'Reference table for ultra-processed foods (NOVA Group 4). Used for REC0022 tracking. These are industrial formulations with multiple ingredients and additives.';

COMMENT ON COLUMN def_ref_ultra_processed_types.nova_group IS
'NOVA classification system. All entries are Group 4 (ultra-processed). Groups: 1=Unprocessed, 2=Processed ingredients, 3=Processed, 4=Ultra-processed.';

COMMIT;
