-- =====================================================
-- Add Added Sugar Tracking Fields
-- =====================================================
-- Tracks servings of foods/drinks with added sugar
-- Supports REC0009 (Reduce Added Sugar Intake) - all levels
--
-- REC0009.1: Limit to 1 serving per day
-- REC0009.2: Limit to 2 servings per week
-- REC0009.3: Eliminate entirely
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Create Added Sugar Types Reference Table
-- =====================================================

CREATE TABLE IF NOT EXISTS def_ref_added_sugar_types (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sugar_type_key TEXT UNIQUE NOT NULL,
  display_name TEXT NOT NULL,
  category TEXT, -- 'beverage', 'snack', 'dessert', 'condiment', 'breakfast'
  typical_added_sugar_g NUMERIC, -- Typical grams of added sugar per serving
  example_items TEXT, -- Examples for UI (e.g., "soda, sweet tea, energy drinks")
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert common added sugar food/drink types
INSERT INTO def_ref_added_sugar_types (sugar_type_key, display_name, category, typical_added_sugar_g, example_items) VALUES
-- Beverages
('soda', 'Regular Soda', 'beverage', 39, 'Cola, lemon-lime soda, root beer'),
('sweet_tea', 'Sweetened Tea', 'beverage', 25, 'Sweet tea, Arizona tea, snapple'),
('energy_drink', 'Energy Drink', 'beverage', 27, 'Red Bull, Monster, Rockstar'),
('sports_drink', 'Sports Drink', 'beverage', 21, 'Gatorade, Powerade'),
('juice_cocktail', 'Juice Cocktail/Drink', 'beverage', 28, 'Fruit punch, cranberry cocktail, lemonade'),
('coffee_drink', 'Sweetened Coffee Drink', 'beverage', 25, 'Frappuccino, flavored latte, mocha'),
('flavored_milk', 'Flavored Milk', 'beverage', 24, 'Chocolate milk, strawberry milk'),

-- Snacks & Desserts
('candy', 'Candy', 'snack', 22, 'Chocolate bars, gummy candy, hard candy'),
('cookie', 'Cookies', 'dessert', 12, 'Chocolate chip, sugar cookies, Oreos'),
('pastry', 'Pastry/Donut', 'dessert', 15, 'Donuts, Danish, croissants with filling'),
('cake', 'Cake/Cupcake', 'dessert', 30, 'Birthday cake, cupcakes, pound cake'),
('ice_cream', 'Ice Cream/Frozen Dessert', 'dessert', 22, 'Ice cream, frozen yogurt, gelato'),
('granola_bar', 'Granola/Protein Bar', 'snack', 12, 'Nature Valley, Clif Bar, protein bars with added sugar'),

-- Breakfast Items
('sweetened_cereal', 'Sweetened Cereal', 'breakfast', 12, 'Frosted Flakes, Froot Loops, Honey Nut Cheerios'),
('sweetened_yogurt', 'Flavored/Sweetened Yogurt', 'breakfast', 17, 'Fruit-flavored yogurt, yogurt with added sugar'),
('pancake_syrup', 'Pancakes/Waffles with Syrup', 'breakfast', 32, 'Pancakes, waffles with maple/flavored syrup'),

-- Condiments & Other
('bbq_sauce', 'BBQ/Sweet Sauce', 'condiment', 9, 'BBQ sauce, ketchup, teriyaki sauce'),
('sweetened_condiment', 'Sweet Condiment', 'condiment', 8, 'Honey mustard, sweet and sour, cranberry sauce')

ON CONFLICT (sugar_type_key) DO NOTHING;


-- =====================================================
-- PART 2: Add Added Sugar Data Entry Fields
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
-- Added sugar quantity (servings)
(
  'DEF_ADDED_SUGAR_QUANTITY',
  'added_sugar_quantity',
  'Added Sugar Servings',
  'Number of servings of foods/drinks with added sugar consumed',
  'quantity',
  'numeric',
  'serving',
  true,
  false,
  '{"min": 0, "max": 20, "increment": 1}'::jsonb
),
-- Added sugar type
(
  'DEF_ADDED_SUGAR_TYPE',
  'added_sugar_type',
  'Added Sugar Type',
  'Type of food/drink with added sugar (references def_ref_added_sugar_types)',
  'reference',
  'text', -- Stores sugar_type_key
  NULL,
  true,
  false,
  NULL
),
-- Added sugar time
(
  'DEF_ADDED_SUGAR_TIME',
  'added_sugar_time',
  'Consumption Time',
  'When the added sugar food/drink was consumed',
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
SET reference_table = 'def_ref_added_sugar_types'
WHERE field_id = 'DEF_ADDED_SUGAR_TYPE';


-- =====================================================
-- PART 3: Add comments for clarity
-- =====================================================

COMMENT ON TABLE def_ref_added_sugar_types IS
'Reference table for foods and drinks with added sugar. Used for REC0009 (Reduce Added Sugar Intake) tracking.';

COMMENT ON COLUMN def_ref_added_sugar_types.typical_added_sugar_g IS
'Typical grams of added sugar per standard serving. Informational only - tracking is servings-based, not grams.';

COMMIT;
