-- =====================================================
-- Nutrition Reference Tables
-- =====================================================
-- Creates 6 reference tables for nutrition domain:
-- 1. meal_qualifiers
-- 2. food_categories
-- 3. food_types
-- 4. beverage_types
-- 5. meal_types
-- 6. food_unit_options
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- 1. meal_qualifiers
-- =====================================================
CREATE TABLE IF NOT EXISTS meal_qualifiers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  qualifier_name TEXT UNIQUE NOT NULL,
  display_name TEXT NOT NULL,
  description TEXT,
  impact_score INTEGER CHECK (impact_score BETWEEN -10 AND 10),  -- Negative = bad, Positive = good
  is_positive BOOLEAN DEFAULT true,
  display_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

INSERT INTO meal_qualifiers (qualifier_name, display_name, description, impact_score, is_positive) VALUES
('mindful', 'Mindful Eating', 'Ate slowly and paid attention to food', 8, true),
('whole_foods', 'Whole Foods', 'Unprocessed, natural ingredients', 9, true),
('plant_based', 'Plant-Based', 'Primarily plants and vegetables', 7, true),
('processed', 'Processed', 'Highly processed or packaged foods', -6, false),
('takeout', 'Takeout/Restaurant', 'Ordered from restaurant', -3, false),
('rushed', 'Rushed/Distracted', 'Ate quickly or while distracted', -5, false),
('balanced', 'Balanced Meal', 'Good mix of protein, carbs, and fats', 8, true),
('hydrated', 'Well Hydrated', 'Drank water with meal', 5, true)
ON CONFLICT (qualifier_name) DO NOTHING;

CREATE INDEX IF NOT EXISTS idx_meal_qualifiers_active ON meal_qualifiers(is_active);


-- =====================================================
-- 2. food_categories
-- =====================================================
CREATE TABLE IF NOT EXISTS food_categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category_name TEXT UNIQUE NOT NULL,
  display_name TEXT NOT NULL,
  description TEXT,
  recommended_daily_servings NUMERIC,
  color_hex TEXT,  -- For UI visualization
  icon TEXT,
  display_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

INSERT INTO food_categories (category_name, display_name, description, recommended_daily_servings, color_hex, icon) VALUES
('vegetables', 'Vegetables', 'Non-starchy vegetables', 5, '#4CAF50', 'vegetables'),
('fruits', 'Fruits', 'Fresh and dried fruits', 3, '#FF9800', 'fruit'),
('protein', 'Protein', 'Meat, fish, eggs, legumes', 3, '#E91E63', 'protein'),
('grains', 'Whole Grains', 'Bread, rice, pasta, oats', 6, '#795548', 'grains'),
('dairy', 'Dairy', 'Milk, yogurt, cheese', 3, '#2196F3', 'dairy'),
('fats', 'Healthy Fats', 'Nuts, seeds, oils, avocado', 3, '#FFC107', 'fats'),
('sweets', 'Sweets & Treats', 'Sugar, desserts, candy', 0, '#9C27B0', 'sweets')
ON CONFLICT (category_name) DO NOTHING;

CREATE INDEX IF NOT EXISTS idx_food_categories_active ON food_categories(is_active);


-- =====================================================
-- 3. food_types
-- =====================================================
CREATE TABLE IF NOT EXISTS food_types (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  food_name TEXT UNIQUE NOT NULL,
  display_name TEXT NOT NULL,
  category_id UUID REFERENCES food_categories(id) ON DELETE CASCADE,

  -- HealthKit integration
  healthkit_identifier TEXT,
  healthkit_mapping_id UUID REFERENCES healthkit_mapping(id) ON DELETE SET NULL,

  -- Nutritional info (per 100g or standard serving)
  calories_per_100g NUMERIC,
  protein_g_per_100g NUMERIC,
  carbs_g_per_100g NUMERIC,
  fat_g_per_100g NUMERIC,
  fiber_g_per_100g NUMERIC,
  sugar_g_per_100g NUMERIC,

  -- Serving info
  default_serving_size NUMERIC,
  default_unit TEXT,

  -- Metadata
  description TEXT,
  is_whole_food BOOLEAN DEFAULT true,
  is_organic_available BOOLEAN DEFAULT false,

  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Seed some common foods
INSERT INTO food_types (food_name, display_name, category_id, calories_per_100g, protein_g_per_100g, carbs_g_per_100g, fat_g_per_100g, fiber_g_per_100g, default_serving_size, default_unit, is_whole_food) VALUES
-- Vegetables
('spinach', 'Spinach', (SELECT id FROM food_categories WHERE category_name = 'vegetables'), 23, 2.9, 3.6, 0.4, 2.2, 100, 'g', true),
('broccoli', 'Broccoli', (SELECT id FROM food_categories WHERE category_name = 'vegetables'), 34, 2.8, 7, 0.4, 2.6, 100, 'g', true),
('kale', 'Kale', (SELECT id FROM food_categories WHERE category_name = 'vegetables'), 35, 2.9, 4.4, 1.5, 4.1, 100, 'g', true),

-- Fruits
('apple', 'Apple', (SELECT id FROM food_categories WHERE category_name = 'fruits'), 52, 0.3, 14, 0.2, 2.4, 1, 'medium', true),
('banana', 'Banana', (SELECT id FROM food_categories WHERE category_name = 'fruits'), 89, 1.1, 23, 0.3, 2.6, 1, 'medium', true),
('blueberries', 'Blueberries', (SELECT id FROM food_categories WHERE category_name = 'fruits'), 57, 0.7, 14, 0.3, 2.4, 100, 'g', true),

-- Protein
('chicken_breast', 'Chicken Breast', (SELECT id FROM food_categories WHERE category_name = 'protein'), 165, 31, 0, 3.6, 0, 100, 'g', true),
('salmon', 'Salmon', (SELECT id FROM food_categories WHERE category_name = 'protein'), 206, 22, 0, 13, 0, 100, 'g', true),
('eggs', 'Eggs', (SELECT id FROM food_categories WHERE category_name = 'protein'), 155, 13, 1.1, 11, 0, 1, 'large', true),

-- Grains
('quinoa', 'Quinoa', (SELECT id FROM food_categories WHERE category_name = 'grains'), 120, 4.4, 21, 1.9, 2.8, 100, 'g', true),
('brown_rice', 'Brown Rice', (SELECT id FROM food_categories WHERE category_name = 'grains'), 112, 2.6, 24, 0.9, 1.8, 100, 'g', true),
('oats', 'Oats', (SELECT id FROM food_categories WHERE category_name = 'grains'), 389, 17, 66, 6.9, 10.6, 50, 'g', true)
ON CONFLICT (food_name) DO NOTHING;

CREATE INDEX IF NOT EXISTS idx_food_types_category ON food_types(category_id);
CREATE INDEX IF NOT EXISTS idx_food_types_hk_identifier ON food_types(healthkit_identifier);
CREATE INDEX IF NOT EXISTS idx_food_types_active ON food_types(is_active);


-- =====================================================
-- 4. beverage_types
-- =====================================================
CREATE TABLE IF NOT EXISTS beverage_types (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  beverage_name TEXT UNIQUE NOT NULL,
  display_name TEXT NOT NULL,

  -- HealthKit integration
  healthkit_identifier TEXT,
  healthkit_mapping_id UUID REFERENCES healthkit_mapping(id) ON DELETE SET NULL,

  -- Beverage properties
  caffeine_mg_per_serving NUMERIC DEFAULT 0,
  alcohol_g_per_serving NUMERIC DEFAULT 0,
  sugar_g_per_serving NUMERIC DEFAULT 0,
  calories_per_serving NUMERIC DEFAULT 0,

  -- Hydration
  hydration_factor NUMERIC DEFAULT 1.0 CHECK (hydration_factor BETWEEN 0 AND 1),  -- 1.0 = pure water

  -- Serving info
  default_serving_size NUMERIC,
  default_unit TEXT DEFAULT 'ml',

  category TEXT,  -- 'water', 'coffee', 'tea', 'alcohol', 'juice', 'soda'
  is_healthy BOOLEAN DEFAULT true,

  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

INSERT INTO beverage_types (beverage_name, display_name, category, caffeine_mg_per_serving, alcohol_g_per_serving, sugar_g_per_serving, calories_per_serving, hydration_factor, default_serving_size, is_healthy) VALUES
-- Hydration
('water', 'Water', 'water', 0, 0, 0, 0, 1.0, 250, true),
('sparkling_water', 'Sparkling Water', 'water', 0, 0, 0, 0, 1.0, 250, true),

-- Coffee
('coffee_black', 'Black Coffee', 'coffee', 95, 0, 0, 2, 0.9, 240, true),
('espresso', 'Espresso', 'coffee', 63, 0, 0, 3, 0.9, 30, true),
('latte', 'Latte', 'coffee', 63, 0, 12, 120, 0.85, 240, false),

-- Tea
('green_tea', 'Green Tea', 'tea', 28, 0, 0, 0, 0.95, 240, true),
('black_tea', 'Black Tea', 'tea', 47, 0, 0, 0, 0.95, 240, true),
('herbal_tea', 'Herbal Tea', 'tea', 0, 0, 0, 0, 0.95, 240, true),

-- Alcohol
('beer', 'Beer (12 oz)', 'alcohol', 0, 14, 13, 153, 0.6, 355, false),
('wine_red', 'Red Wine (5 oz)', 'alcohol', 0, 14, 1, 125, 0.6, 148, false),
('wine_white', 'White Wine (5 oz)', 'alcohol', 0, 14, 1, 121, 0.6, 148, false),
('spirits', 'Spirits (1.5 oz)', 'alcohol', 0, 14, 0, 97, 0.5, 44, false)
ON CONFLICT (beverage_name) DO NOTHING;

CREATE INDEX IF NOT EXISTS idx_beverage_types_category ON beverage_types(category);
CREATE INDEX IF NOT EXISTS idx_beverage_types_hk_identifier ON beverage_types(healthkit_identifier);
CREATE INDEX IF NOT EXISTS idx_beverage_types_active ON beverage_types(is_active);


-- =====================================================
-- 5. meal_types (if not exists)
-- =====================================================
CREATE TABLE IF NOT EXISTS meal_types (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  meal_name TEXT UNIQUE NOT NULL,
  display_name TEXT NOT NULL,
  typical_time_start TIME,
  typical_time_end TIME,
  display_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

INSERT INTO meal_types (meal_name, display_name, typical_time_start, typical_time_end, display_order) VALUES
('breakfast', 'Breakfast', '06:00', '10:00', 1),
('morning_snack', 'Morning Snack', '09:00', '11:00', 2),
('lunch', 'Lunch', '11:00', '14:00', 3),
('afternoon_snack', 'Afternoon Snack', '14:00', '17:00', 4),
('dinner', 'Dinner', '17:00', '21:00', 5),
('evening_snack', 'Evening Snack', '20:00', '23:00', 6),
('beverage', 'Beverage Only', NULL, NULL, 7)
ON CONFLICT (meal_name) DO NOTHING;

CREATE INDEX IF NOT EXISTS idx_meal_types_active ON meal_types(is_active);


-- =====================================================
-- 6. food_unit_options
-- =====================================================
CREATE TABLE IF NOT EXISTS food_unit_options (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  food_type_id UUID REFERENCES food_types(id) ON DELETE CASCADE,
  unit_name TEXT NOT NULL,
  display_name TEXT NOT NULL,
  conversion_to_grams NUMERIC,  -- How many grams this unit represents
  is_default BOOLEAN DEFAULT false,
  display_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),

  UNIQUE(food_type_id, unit_name)
);

-- Seed common units for foods we created
INSERT INTO food_unit_options (food_type_id, unit_name, display_name, conversion_to_grams, is_default) VALUES
-- Spinach
((SELECT id FROM food_types WHERE food_name = 'spinach'), 'g', 'grams', 1, true),
((SELECT id FROM food_types WHERE food_name = 'spinach'), 'cup', 'cup (raw)', 30, false),
((SELECT id FROM food_types WHERE food_name = 'spinach'), 'oz', 'ounces', 28.35, false)
ON CONFLICT (food_type_id, unit_name) DO NOTHING;

CREATE INDEX IF NOT EXISTS idx_food_unit_options_food_type ON food_unit_options(food_type_id);

-- Partial unique index for default unit per food type
CREATE UNIQUE INDEX IF NOT EXISTS idx_food_unit_options_default
  ON food_unit_options(food_type_id)
  WHERE is_default = true;

COMMIT;
