-- =====================================================
-- Archive Unused def_ref Tables
-- =====================================================
-- Renames unused def_ref_* tables to z_old_def_ref_*
-- to mark them as deprecated
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- Tables that ARE in use (keep as is):
-- def_ref_alcohol_types
-- def_ref_caffeine_types
-- def_ref_cardio_types
-- def_ref_fat_types
-- def_ref_food_types
-- def_ref_meal_types
-- def_ref_nut_seed_types
-- def_ref_protein_types
-- def_ref_screen_time_types
-- def_ref_skincare_steps
-- def_ref_sleep_period_types
-- def_ref_social_event_types
-- def_ref_sunlight_types
-- def_ref_sunscreen_types
-- def_ref_unhealthy_beverage_types
-- def_ref_beverage_types (keep - may still have data we need)

-- Rename unused tables to z_old_def_ref_*
ALTER TABLE IF EXISTS def_ref_beverage_categories RENAME TO z_old_def_ref_beverage_categories;
ALTER TABLE IF EXISTS def_ref_beverage_unit_options RENAME TO z_old_def_ref_beverage_unit_options;
ALTER TABLE IF EXISTS def_ref_exercise_intensity_levels RENAME TO z_old_def_ref_exercise_intensity_levels;
ALTER TABLE IF EXISTS def_ref_flexibility_types RENAME TO z_old_def_ref_flexibility_types;
ALTER TABLE IF EXISTS def_ref_food_categories RENAME TO z_old_def_ref_food_categories;
ALTER TABLE IF EXISTS def_ref_food_unit_options RENAME TO z_old_def_ref_food_unit_options;
ALTER TABLE IF EXISTS def_ref_meal_qualifiers RENAME TO z_old_def_ref_meal_qualifiers;
ALTER TABLE IF EXISTS def_ref_measurement_types RENAME TO z_old_def_ref_measurement_types;
ALTER TABLE IF EXISTS def_ref_measurement_unit_options RENAME TO z_old_def_ref_measurement_unit_options;
ALTER TABLE IF EXISTS def_ref_mindfulness_types RENAME TO z_old_def_ref_mindfulness_types;
ALTER TABLE IF EXISTS def_ref_muscle_groups RENAME TO z_old_def_ref_muscle_groups;
ALTER TABLE IF EXISTS def_ref_screening_types RENAME TO z_old_def_ref_screening_types;
ALTER TABLE IF EXISTS def_ref_selfcare_types RENAME TO z_old_def_ref_selfcare_types;
ALTER TABLE IF EXISTS def_ref_sleep_factors RENAME TO z_old_def_ref_sleep_factors;
ALTER TABLE IF EXISTS def_ref_social_activity_types RENAME TO z_old_def_ref_social_activity_types;
ALTER TABLE IF EXISTS def_ref_strength_types RENAME TO z_old_def_ref_strength_types;
ALTER TABLE IF EXISTS def_ref_stress_factors RENAME TO z_old_def_ref_stress_factors;
ALTER TABLE IF EXISTS def_ref_substance_sources RENAME TO z_old_def_ref_substance_sources;
ALTER TABLE IF EXISTS def_ref_substance_types RENAME TO z_old_def_ref_substance_types;

-- Summary
DO $$
DECLARE
  archived_count INTEGER;
  active_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO archived_count
  FROM information_schema.tables
  WHERE table_schema = 'public'
  AND table_name LIKE 'z_old_def_ref_%';

  SELECT COUNT(*) INTO active_count
  FROM information_schema.tables
  WHERE table_schema = 'public'
  AND table_name LIKE 'def_ref_%';

  RAISE NOTICE '=========================================';
  RAISE NOTICE 'Archived Unused def_ref Tables';
  RAISE NOTICE '=========================================';
  RAISE NOTICE 'Archived tables: %', archived_count;
  RAISE NOTICE 'Active def_ref tables: %', active_count;
  RAISE NOTICE '';
  RAISE NOTICE 'Active tables:';
  RAISE NOTICE '  - def_ref_alcohol_types';
  RAISE NOTICE '  - def_ref_beverage_types (kept for data migration)';
  RAISE NOTICE '  - def_ref_caffeine_types';
  RAISE NOTICE '  - def_ref_cardio_types';
  RAISE NOTICE '  - def_ref_fat_types';
  RAISE NOTICE '  - def_ref_food_types';
  RAISE NOTICE '  - def_ref_meal_types';
  RAISE NOTICE '  - def_ref_nut_seed_types';
  RAISE NOTICE '  - def_ref_protein_types';
  RAISE NOTICE '  - def_ref_screen_time_types';
  RAISE NOTICE '  - def_ref_skincare_steps';
  RAISE NOTICE '  - def_ref_sleep_period_types';
  RAISE NOTICE '  - def_ref_social_event_types';
  RAISE NOTICE '  - def_ref_sunlight_types';
  RAISE NOTICE '  - def_ref_sunscreen_types';
  RAISE NOTICE '  - def_ref_unhealthy_beverage_types';
END $$;

COMMIT;
