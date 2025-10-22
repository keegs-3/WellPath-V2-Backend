-- =====================================================
-- Rename Reference Tables to def_ref_ Pattern
-- =====================================================
-- Renames all reference tables to use def_ref_ prefix
-- for consistent architecture (matches def_ prefix pattern)
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- Nutrition Domain (6 tables)
-- =====================================================

ALTER TABLE IF EXISTS meal_qualifiers RENAME TO def_ref_meal_qualifiers;
ALTER TABLE IF EXISTS food_categories RENAME TO def_ref_food_categories;
ALTER TABLE IF EXISTS food_types RENAME TO def_ref_food_types;
ALTER TABLE IF EXISTS beverage_types RENAME TO def_ref_beverage_types;
ALTER TABLE IF EXISTS meal_types RENAME TO def_ref_meal_types;
ALTER TABLE IF EXISTS food_unit_options RENAME TO def_ref_food_unit_options;

-- =====================================================
-- Exercise Domain (5 tables)
-- =====================================================

ALTER TABLE IF EXISTS cardio_types RENAME TO def_ref_cardio_types;
ALTER TABLE IF EXISTS strength_types RENAME TO def_ref_strength_types;
ALTER TABLE IF EXISTS flexibility_types RENAME TO def_ref_flexibility_types;
ALTER TABLE IF EXISTS muscle_groups RENAME TO def_ref_muscle_groups;
ALTER TABLE IF EXISTS exercise_intensity_levels RENAME TO def_ref_exercise_intensity_levels;

-- =====================================================
-- Sleep Domain (2 tables)
-- =====================================================

ALTER TABLE IF EXISTS sleep_factors RENAME TO def_ref_sleep_factors;
ALTER TABLE IF EXISTS sleep_period_types RENAME TO def_ref_sleep_period_types;

-- =====================================================
-- Mindfulness Domain (2 tables)
-- =====================================================

ALTER TABLE IF EXISTS mindfulness_types RENAME TO def_ref_mindfulness_types;
ALTER TABLE IF EXISTS stress_factors RENAME TO def_ref_stress_factors;

-- =====================================================
-- Measurements Domain (2 tables)
-- =====================================================

ALTER TABLE IF EXISTS measurement_types RENAME TO def_ref_measurement_types;
ALTER TABLE IF EXISTS measurement_unit_options RENAME TO def_ref_measurement_unit_options;

-- =====================================================
-- Screening Domain (1 table)
-- =====================================================

ALTER TABLE IF EXISTS screening_types RENAME TO def_ref_screening_types;

-- =====================================================
-- Substances Domain (2 tables)
-- =====================================================

ALTER TABLE IF EXISTS substance_types RENAME TO def_ref_substance_types;
ALTER TABLE IF EXISTS substance_sources RENAME TO def_ref_substance_sources;

-- =====================================================
-- Self-care Domain (1 table)
-- =====================================================

ALTER TABLE IF EXISTS selfcare_types RENAME TO def_ref_selfcare_types;

-- =====================================================
-- Social Domain (1 table)
-- =====================================================

ALTER TABLE IF EXISTS social_activity_types RENAME TO def_ref_social_activity_types;

-- =====================================================
-- Update Comments on Renamed Tables
-- =====================================================

COMMENT ON TABLE def_ref_meal_qualifiers IS 'Reference: Meal characteristics (mindful, whole_foods, processed, etc.)';
COMMENT ON TABLE def_ref_food_categories IS 'Reference: Food category groupings (vegetables, fruits, proteins, etc.)';
COMMENT ON TABLE def_ref_food_types IS 'Reference: Specific food items with nutrition data and HealthKit identifiers';
COMMENT ON TABLE def_ref_beverage_types IS 'Reference: Beverages with caffeine/alcohol content';
COMMENT ON TABLE def_ref_meal_types IS 'Reference: Meal types (breakfast, lunch, dinner, snacks)';
COMMENT ON TABLE def_ref_food_unit_options IS 'Reference: Unit conversion options per food type';

COMMENT ON TABLE def_ref_cardio_types IS 'Reference: Cardio exercise types with HealthKit identifiers and MET scores';
COMMENT ON TABLE def_ref_strength_types IS 'Reference: Strength training types with HealthKit identifiers';
COMMENT ON TABLE def_ref_flexibility_types IS 'Reference: Flexibility/mobility types with HealthKit identifiers';
COMMENT ON TABLE def_ref_muscle_groups IS 'Reference: Muscle group targets for strength training';
COMMENT ON TABLE def_ref_exercise_intensity_levels IS 'Reference: Exercise intensity levels (1-10) with RPE and HR zones';

COMMENT ON TABLE def_ref_sleep_factors IS 'Reference: Factors affecting sleep quality';
COMMENT ON TABLE def_ref_sleep_period_types IS 'Reference: Sleep stages (REM, Deep, Core, Awake) with HealthKit identifiers';

COMMENT ON TABLE def_ref_mindfulness_types IS 'Reference: Mindfulness activity types';
COMMENT ON TABLE def_ref_stress_factors IS 'Reference: Stress factors/sources';

COMMENT ON TABLE def_ref_measurement_types IS 'Reference: Body measurement types with HealthKit identifiers and healthy ranges';
COMMENT ON TABLE def_ref_measurement_unit_options IS 'Reference: Unit conversion options per measurement type';

COMMENT ON TABLE def_ref_screening_types IS 'Reference: Preventive health screening types';

COMMENT ON TABLE def_ref_substance_types IS 'Reference: Substance categories (alcohol, caffeine, tobacco, cannabis)';
COMMENT ON TABLE def_ref_substance_sources IS 'Reference: Specific substance sources (beer, wine, coffee, tea, etc.)';

COMMENT ON TABLE def_ref_selfcare_types IS 'Reference: Self-care activity types';

COMMENT ON TABLE def_ref_social_activity_types IS 'Reference: Social interaction types';

COMMIT;
