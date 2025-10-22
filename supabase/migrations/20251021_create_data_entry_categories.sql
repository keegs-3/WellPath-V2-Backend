-- =====================================================
-- Create Data Entry Categories Table
-- =====================================================
-- Formalizes the display group hierarchy: Pillars → Categories → Fields
-- Replaces text-based grouping with FK constraints for type safety
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Create Categories Table
-- =====================================================

CREATE TABLE IF NOT EXISTS data_entry_categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category_id TEXT UNIQUE NOT NULL,
  category_name TEXT NOT NULL,
  pillar_name TEXT NOT NULL,
  description TEXT,
  display_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  -- Foreign key to pillars_base
  CONSTRAINT fk_category_pillar FOREIGN KEY (pillar_name)
    REFERENCES pillars_base(pillar_name)
    ON UPDATE CASCADE ON DELETE CASCADE
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_categories_pillar ON data_entry_categories(pillar_name);
CREATE INDEX IF NOT EXISTS idx_categories_active ON data_entry_categories(is_active);
CREATE INDEX IF NOT EXISTS idx_categories_display_order ON data_entry_categories(pillar_name, display_order);

-- Add update trigger
CREATE TRIGGER update_data_entry_categories_updated_at
  BEFORE UPDATE ON data_entry_categories
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();


-- =====================================================
-- PART 2: Seed Categories - Healthful Nutrition
-- =====================================================

INSERT INTO data_entry_categories (
  category_id,
  category_name,
  pillar_name,
  description,
  display_order
) VALUES
(
  'nutrition_meals',
  'Meals',
  'Healthful Nutrition',
  'Meal logging, timing, portion sizes, and meal quality characteristics',
  1
),
(
  'nutrition_healthy_additions',
  'Healthy Additions',
  'Healthful Nutrition',
  'Longevity-supporting foods to increase: fiber, fruits, vegetables, legumes, nuts/seeds, quality proteins, whole grains, and water',
  2
),
(
  'nutrition_mindful_reductions',
  'Mindful Reductions',
  'Healthful Nutrition',
  'Longevity-limiting substances to reduce: added sugars, alcohol, caffeine, processed meats, ultra-processed foods, and unhealthy beverages',
  3
),
(
  'nutrition_calories_macros',
  'Calories and Macronutrients',
  'Healthful Nutrition',
  'Calorie intake and macronutrient balance tracking',
  4
)
ON CONFLICT (category_id) DO NOTHING;


-- =====================================================
-- PART 3: Seed Categories - Movement + Exercise
-- =====================================================

INSERT INTO data_entry_categories (
  category_id,
  category_name,
  pillar_name,
  description,
  display_order
) VALUES
(
  'exercise_cardio',
  'Cardio',
  'Movement + Exercise',
  'Cardiovascular exercise including Zone 2 training, distance, intensity, and duration tracking',
  1
),
(
  'exercise_strength',
  'Strength',
  'Movement + Exercise',
  'Resistance training, muscle group targeting, and strength progression',
  2
),
(
  'exercise_hiit',
  'HIIT',
  'Movement + Exercise',
  'High-intensity interval training protocols and interval-based workouts',
  3
),
(
  'exercise_mobility',
  'Mobility',
  'Movement + Exercise',
  'Flexibility, mobility work, stretching, and movement quality',
  4
),
(
  'exercise_steps',
  'Steps',
  'Movement + Exercise',
  'Daily step count and non-exercise activity thermogenesis (NEAT)',
  5
)
ON CONFLICT (category_id) DO NOTHING;


-- =====================================================
-- PART 4: Seed Categories - Restorative Sleep
-- =====================================================

INSERT INTO data_entry_categories (
  category_id,
  category_name,
  pillar_name,
  description,
  display_order
) VALUES
(
  'sleep_tracking',
  'Sleep Tracking',
  'Restorative Sleep',
  'Sleep duration, quality, timing, and factors affecting sleep',
  1
)
ON CONFLICT (category_id) DO NOTHING;


-- =====================================================
-- PART 5: Seed Categories - Stress Management
-- =====================================================

INSERT INTO data_entry_categories (
  category_id,
  category_name,
  pillar_name,
  description,
  display_order
) VALUES
(
  'stress_monitoring',
  'Stress Monitoring',
  'Stress Management',
  'Stress levels, stress factors, and stress response tracking',
  1
),
(
  'stress_mindfulness',
  'Mindfulness Practices',
  'Stress Management',
  'Mindfulness, meditation, gratitude, journaling, and stress reduction techniques',
  2
)
ON CONFLICT (category_id) DO NOTHING;


-- =====================================================
-- PART 6: Seed Categories - Cognitive Health
-- =====================================================

INSERT INTO data_entry_categories (
  category_id,
  category_name,
  pillar_name,
  description,
  display_order
) VALUES
(
  'cognitive_performance',
  'Cognitive Performance',
  'Cognitive Health',
  'Focus, memory, mood, and mental clarity monitoring',
  1
),
(
  'cognitive_brain_training',
  'Brain Training',
  'Cognitive Health',
  'Cognitive exercises and brain training activities',
  2
),
(
  'cognitive_screen_time',
  'Screen Time',
  'Cognitive Health',
  'Digital device usage and screen time management',
  3
)
ON CONFLICT (category_id) DO NOTHING;


-- =====================================================
-- PART 7: Seed Categories - Connection + Purpose
-- =====================================================

INSERT INTO data_entry_categories (
  category_id,
  category_name,
  pillar_name,
  description,
  display_order
) VALUES
(
  'connection_social',
  'Social Connection',
  'Connection + Purpose',
  'Social interactions, events, and relationship quality',
  1
),
(
  'connection_nature',
  'Nature Exposure',
  'Connection + Purpose',
  'Outdoor time, sunlight exposure, and connection with nature',
  2
)
ON CONFLICT (category_id) DO NOTHING;


-- =====================================================
-- PART 8: Seed Categories - Core Care
-- =====================================================

INSERT INTO data_entry_categories (
  category_id,
  category_name,
  pillar_name,
  description,
  display_order
) VALUES
(
  'core_body_measurements',
  'Body Measurements',
  'Core Care',
  'Weight, height, body composition, and circumference measurements',
  1
),
(
  'core_vital_signs',
  'Vital Signs',
  'Core Care',
  'Blood pressure and other vital sign monitoring',
  2
),
(
  'core_screenings',
  'Health Screenings',
  'Core Care',
  'Preventive health screenings, tests, and results',
  3
),
(
  'core_therapeutics',
  'Therapeutic Tracking',
  'Core Care',
  'Medications, supplements, and therapeutic substances',
  4
),
(
  'core_personal_care',
  'Personal Care',
  'Core Care',
  'Dental hygiene, skincare, and personal health maintenance',
  5
)
ON CONFLICT (category_id) DO NOTHING;


-- =====================================================
-- PART 9: Add Comments
-- =====================================================

COMMENT ON TABLE data_entry_categories IS
'Display categories for organizing data entry fields. Provides the middle tier of the navigation hierarchy: Pillars → Categories → Fields. Each category belongs to exactly one pillar.';

COMMENT ON COLUMN data_entry_categories.category_id IS
'Unique identifier for the category (e.g., "nutrition_meals", "exercise_cardio"). Used as FK in data_entry_fields.';

COMMENT ON COLUMN data_entry_categories.pillar_name IS
'Foreign key to pillars_base.pillar_name. Each category belongs to exactly one pillar.';

COMMENT ON COLUMN data_entry_categories.display_order IS
'Display order within the pillar. Lower numbers appear first in UI.';


COMMIT;
