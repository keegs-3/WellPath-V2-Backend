-- =====================================================
-- Enhance HealthKit Mapping Table
-- =====================================================
-- Adds metadata columns and populates with all HealthKit identifiers
-- Other tables reference this via healthkit_identifier (text match)
--
-- Created: 2025-10-19
-- =====================================================

BEGIN;

-- =====================================================
-- Add metadata columns to existing healthkit_mapping table
-- =====================================================
ALTER TABLE healthkit_mapping
ADD COLUMN IF NOT EXISTS display_name text,
ADD COLUMN IF NOT EXISTS category text,
ADD COLUMN IF NOT EXISTS subcategory text,
ADD COLUMN IF NOT EXISTS description text,
ADD COLUMN IF NOT EXISTS default_unit text,
ADD COLUMN IF NOT EXISTS available_ios_version text,
ADD COLUMN IF NOT EXISTS is_writable boolean DEFAULT true,
ADD COLUMN IF NOT EXISTS is_readable boolean DEFAULT true,
ADD COLUMN IF NOT EXISTS is_active boolean DEFAULT true;

-- Add indexes
CREATE INDEX IF NOT EXISTS idx_healthkit_mapping_identifier ON healthkit_mapping(healthkit_identifier);
CREATE INDEX IF NOT EXISTS idx_healthkit_mapping_type ON healthkit_mapping(healthkit_type_name);
CREATE INDEX IF NOT EXISTS idx_healthkit_mapping_category ON healthkit_mapping(category);

-- Update column comment
COMMENT ON TABLE healthkit_mapping IS
'Reference table for all HealthKit identifiers with metadata. Other tables reference this via healthkit_identifier text match.';


-- =====================================================
-- Seed Data: Workout Activity Types
-- =====================================================

-- Cardio Workouts
INSERT INTO healthkit_mapping (healthkit_identifier, healthkit_type_name, display_name, category, subcategory, description, available_ios_version, is_active) VALUES
('HKWorkoutActivityTypeRunning', 'HKWorkoutActivityType', 'Running', 'cardio', 'outdoor', 'Outdoor or treadmill running', 'iOS 8.0+', true),
('HKWorkoutActivityTypeWalking', 'HKWorkoutActivityType', 'Walking', 'cardio', 'outdoor', 'Walking for exercise', 'iOS 8.0+', true),
('HKWorkoutActivityTypeCycling', 'HKWorkoutActivityType', 'Cycling', 'cardio', 'outdoor', 'Outdoor or stationary cycling', 'iOS 8.0+', true),
('HKWorkoutActivityTypeSwimming', 'HKWorkoutActivityType', 'Swimming', 'cardio', 'water', 'Swimming laps or open water', 'iOS 10.0+', true),
('HKWorkoutActivityTypeRowing', 'HKWorkoutActivityType', 'Rowing', 'cardio', 'machine', 'Rowing machine or water rowing', 'iOS 10.0+', true),
('HKWorkoutActivityTypeElliptical', 'HKWorkoutActivityType', 'Elliptical', 'cardio', 'machine', 'Elliptical trainer', 'iOS 8.0+', true),
('HKWorkoutActivityTypeStairClimbing', 'HKWorkoutActivityType', 'Stair Climbing', 'cardio', 'machine', 'Stair climbing machine', 'iOS 8.0+', true),
('HKWorkoutActivityTypeMixedCardio', 'HKWorkoutActivityType', 'Mixed Cardio', 'cardio', 'general', 'Mixed cardio workout', 'iOS 10.0+', true),
('HKWorkoutActivityTypeHandCycling', 'HKWorkoutActivityType', 'Hand Cycling', 'cardio', 'adaptive', 'Hand cycling for adaptive athletes', 'iOS 10.0+', true),
('HKWorkoutActivityTypeJumpRope', 'HKWorkoutActivityType', 'Jump Rope', 'cardio', 'bodyweight', 'Jump rope exercise', 'iOS 13.0+', true),
('HKWorkoutActivityTypeStairs', 'HKWorkoutActivityType', 'Stairs', 'cardio', 'outdoor', 'Climbing stairs', 'iOS 11.0+', true),
('HKWorkoutActivityTypeStepTraining', 'HKWorkoutActivityType', 'Step Training', 'cardio', 'class', 'Step aerobics', 'iOS 10.0+', true),
('HKWorkoutActivityTypeCardioDance', 'HKWorkoutActivityType', 'Cardio Dance', 'cardio', 'dance', 'Dance-based cardio', 'iOS 14.0+', true),
('HKWorkoutActivityTypeSocialDance', 'HKWorkoutActivityType', 'Social Dance', 'cardio', 'dance', 'Social dancing', 'iOS 10.0+', true),
('HKWorkoutActivityTypeSwimBikeRun', 'HKWorkoutActivityType', 'Swim-Bike-Run', 'cardio', 'triathlon', 'Triathlon or multisport', 'iOS 10.0+', true),
('HKWorkoutActivityTypeWaterFitness', 'HKWorkoutActivityType', 'Water Fitness', 'cardio', 'water', 'Water aerobics', 'iOS 10.0+', true)
ON CONFLICT (healthkit_identifier) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  category = EXCLUDED.category,
  subcategory = EXCLUDED.subcategory,
  description = EXCLUDED.description,
  available_ios_version = EXCLUDED.available_ios_version,
  is_active = EXCLUDED.is_active;

-- Strength Training
INSERT INTO healthkit_mapping (healthkit_identifier, healthkit_type_name, display_name, category, subcategory, description, available_ios_version, is_active) VALUES
('HKWorkoutActivityTypeFunctionalStrengthTraining', 'HKWorkoutActivityType', 'Functional Strength Training', 'strength', 'functional', 'Functional strength training', 'iOS 8.0+', true),
('HKWorkoutActivityTypeTraditionalStrengthTraining', 'HKWorkoutActivityType', 'Traditional Strength Training', 'strength', 'weights', 'Weight training', 'iOS 8.0+', true),
('HKWorkoutActivityTypeCrossTraining', 'HKWorkoutActivityType', 'Cross Training', 'strength', 'mixed', 'Cross training or circuit training', 'iOS 8.0+', true)
ON CONFLICT (healthkit_identifier) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  category = EXCLUDED.category,
  subcategory = EXCLUDED.subcategory,
  description = EXCLUDED.description,
  available_ios_version = EXCLUDED.available_ios_version;

-- HIIT
INSERT INTO healthkit_mapping (healthkit_identifier, healthkit_type_name, display_name, category, subcategory, description, available_ios_version, is_active) VALUES
('HKWorkoutActivityTypeHighIntensityIntervalTraining', 'HKWorkoutActivityType', 'HIIT', 'hiit', NULL, 'High-intensity interval training', 'iOS 10.0+', true)
ON CONFLICT (healthkit_identifier) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  category = EXCLUDED.category,
  description = EXCLUDED.description,
  available_ios_version = EXCLUDED.available_ios_version;

-- Flexibility & Recovery
INSERT INTO healthkit_mapping (healthkit_identifier, healthkit_type_name, display_name, category, subcategory, description, available_ios_version, is_active) VALUES
('HKWorkoutActivityTypeYoga', 'HKWorkoutActivityType', 'Yoga', 'flexibility', 'yoga', 'Yoga practice', 'iOS 8.0+', true),
('HKWorkoutActivityTypeFlexibility', 'HKWorkoutActivityType', 'Flexibility', 'flexibility', 'stretching', 'Stretching exercises', 'iOS 10.0+', true),
('HKWorkoutActivityTypeCooldown', 'HKWorkoutActivityType', 'Cooldown', 'flexibility', 'recovery', 'Post-workout cooldown', 'iOS 14.0+', true),
('HKWorkoutActivityTypePreparationAndRecovery', 'HKWorkoutActivityType', 'Preparation and Recovery', 'flexibility', 'recovery', 'Warm-up or recovery session', 'iOS 14.0+', true)
ON CONFLICT (healthkit_identifier) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  category = EXCLUDED.category,
  subcategory = EXCLUDED.subcategory,
  description = EXCLUDED.description,
  available_ios_version = EXCLUDED.available_ios_version;

-- Other Workouts
INSERT INTO healthkit_mapping (healthkit_identifier, healthkit_type_name, display_name, category, subcategory, description, available_ios_version, is_active) VALUES
('HKWorkoutActivityTypeOther', 'HKWorkoutActivityType', 'Other', 'other', NULL, 'Workout not categorized elsewhere', 'iOS 8.0+', true)
ON CONFLICT (healthkit_identifier) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  category = EXCLUDED.category,
  description = EXCLUDED.description,
  available_ios_version = EXCLUDED.available_ios_version;


-- =====================================================
-- Seed Data: Sleep Analysis Categories
-- =====================================================
INSERT INTO healthkit_mapping (healthkit_identifier, healthkit_type_name, display_name, category, subcategory, description, available_ios_version, is_active) VALUES
('HKCategoryValueSleepAnalysisInBed', 'HKCategoryType', 'In Bed', 'sleep', 'time_in_bed', 'Time spent in bed', 'iOS 8.0+', true),
('HKCategoryValueSleepAnalysisAwake', 'HKCategoryType', 'Awake', 'sleep', 'sleep_stage', 'Awake during in-bed time', 'iOS 8.0+', true),
('HKCategoryValueSleepAnalysisAsleepCore', 'HKCategoryType', 'Core Sleep', 'sleep', 'sleep_stage', 'Light or intermediate sleep', 'iOS 16.0+', true),
('HKCategoryValueSleepAnalysisAsleepDeep', 'HKCategoryType', 'Deep Sleep', 'sleep', 'sleep_stage', 'Deep sleep stage', 'iOS 16.0+', true),
('HKCategoryValueSleepAnalysisAsleepREM', 'HKCategoryType', 'REM Sleep', 'sleep', 'sleep_stage', 'REM sleep stage', 'iOS 16.0+', true),
('HKCategoryValueSleepAnalysisAsleepUnspecified', 'HKCategoryType', 'Asleep (Unspecified)', 'sleep', 'sleep_stage', 'Asleep, stage unknown', 'iOS 16.0+', true)
ON CONFLICT (healthkit_identifier) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  category = EXCLUDED.category,
  subcategory = EXCLUDED.subcategory,
  description = EXCLUDED.description,
  available_ios_version = EXCLUDED.available_ios_version;


-- =====================================================
-- Seed Data: Mindfulness
-- =====================================================
INSERT INTO healthkit_mapping (healthkit_identifier, healthkit_type_name, display_name, category, subcategory, description, available_ios_version, is_active) VALUES
('HKCategoryTypeIdentifierMindfulSession', 'HKCategoryType', 'Mindful Session', 'mindfulness', NULL, 'Mindfulness or meditation session', 'iOS 10.0+', true)
ON CONFLICT (healthkit_identifier) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  category = EXCLUDED.category,
  description = EXCLUDED.description,
  available_ios_version = EXCLUDED.available_ios_version;


-- =====================================================
-- Seed Data: Nutrition - Macronutrients
-- =====================================================
INSERT INTO healthkit_mapping (healthkit_identifier, healthkit_type_name, display_name, category, subcategory, description, default_unit, available_ios_version, is_active) VALUES
('HKQuantityTypeIdentifierDietaryEnergyConsumed', 'HKQuantityType', 'Energy (Calories)', 'nutrition', 'macronutrient', 'Total energy consumed', 'kcal', 'iOS 8.0+', true),
('HKQuantityTypeIdentifierDietaryCarbohydrates', 'HKQuantityType', 'Carbohydrates', 'nutrition', 'macronutrient', 'Carbohydrates consumed', 'g', 'iOS 8.0+', true),
('HKQuantityTypeIdentifierDietaryFiber', 'HKQuantityType', 'Fiber', 'nutrition', 'macronutrient', 'Dietary fiber consumed', 'g', 'iOS 8.0+', true),
('HKQuantityTypeIdentifierDietarySugar', 'HKQuantityType', 'Sugar', 'nutrition', 'macronutrient', 'Sugar consumed', 'g', 'iOS 8.0+', true),
('HKQuantityTypeIdentifierDietaryFatTotal', 'HKQuantityType', 'Total Fat', 'nutrition', 'macronutrient', 'Total fat consumed', 'g', 'iOS 8.0+', true),
('HKQuantityTypeIdentifierDietaryFatMonounsaturated', 'HKQuantityType', 'Monounsaturated Fat', 'nutrition', 'fat', 'Monounsaturated fat consumed', 'g', 'iOS 8.0+', true),
('HKQuantityTypeIdentifierDietaryFatPolyunsaturated', 'HKQuantityType', 'Polyunsaturated Fat', 'nutrition', 'fat', 'Polyunsaturated fat consumed', 'g', 'iOS 8.0+', true),
('HKQuantityTypeIdentifierDietaryFatSaturated', 'HKQuantityType', 'Saturated Fat', 'nutrition', 'fat', 'Saturated fat consumed', 'g', 'iOS 8.0+', true),
('HKQuantityTypeIdentifierDietaryCholesterol', 'HKQuantityType', 'Cholesterol', 'nutrition', 'macronutrient', 'Cholesterol consumed', 'mg', 'iOS 8.0+', true),
('HKQuantityTypeIdentifierDietaryProtein', 'HKQuantityType', 'Protein', 'nutrition', 'macronutrient', 'Protein consumed', 'g', 'iOS 8.0+', true)
ON CONFLICT (healthkit_identifier) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  category = EXCLUDED.category,
  subcategory = EXCLUDED.subcategory,
  description = EXCLUDED.description,
  default_unit = EXCLUDED.default_unit,
  available_ios_version = EXCLUDED.available_ios_version;


-- =====================================================
-- Seed Data: Nutrition - Vitamins
-- =====================================================
INSERT INTO healthkit_mapping (healthkit_identifier, healthkit_type_name, display_name, category, subcategory, description, default_unit, available_ios_version, is_active) VALUES
('HKQuantityTypeIdentifierDietaryVitaminA', 'HKQuantityType', 'Vitamin A', 'nutrition', 'vitamin', 'Vitamin A consumed', 'mcg', 'iOS 8.0+', true),
('HKQuantityTypeIdentifierDietaryThiamin', 'HKQuantityType', 'Thiamin (B1)', 'nutrition', 'vitamin', 'Vitamin B1 consumed', 'mg', 'iOS 8.0+', true),
('HKQuantityTypeIdentifierDietaryRiboflavin', 'HKQuantityType', 'Riboflavin (B2)', 'nutrition', 'vitamin', 'Vitamin B2 consumed', 'mg', 'iOS 8.0+', true),
('HKQuantityTypeIdentifierDietaryNiacin', 'HKQuantityType', 'Niacin (B3)', 'nutrition', 'vitamin', 'Vitamin B3 consumed', 'mg', 'iOS 8.0+', true),
('HKQuantityTypeIdentifierDietaryPantothenicAcid', 'HKQuantityType', 'Pantothenic Acid (B5)', 'nutrition', 'vitamin', 'Vitamin B5 consumed', 'mg', 'iOS 8.0+', true),
('HKQuantityTypeIdentifierDietaryVitaminB6', 'HKQuantityType', 'Vitamin B6', 'nutrition', 'vitamin', 'Vitamin B6 consumed', 'mg', 'iOS 8.0+', true),
('HKQuantityTypeIdentifierDietaryBiotin', 'HKQuantityType', 'Biotin (B7)', 'nutrition', 'vitamin', 'Vitamin B7 consumed', 'mcg', 'iOS 8.0+', true),
('HKQuantityTypeIdentifierDietaryVitaminB12', 'HKQuantityType', 'Vitamin B12', 'nutrition', 'vitamin', 'Vitamin B12 consumed', 'mcg', 'iOS 8.0+', true),
('HKQuantityTypeIdentifierDietaryVitaminC', 'HKQuantityType', 'Vitamin C', 'nutrition', 'vitamin', 'Vitamin C consumed', 'mg', 'iOS 8.0+', true),
('HKQuantityTypeIdentifierDietaryVitaminD', 'HKQuantityType', 'Vitamin D', 'nutrition', 'vitamin', 'Vitamin D consumed', 'mcg', 'iOS 8.0+', true),
('HKQuantityTypeIdentifierDietaryVitaminE', 'HKQuantityType', 'Vitamin E', 'nutrition', 'vitamin', 'Vitamin E consumed', 'mg', 'iOS 8.0+', true),
('HKQuantityTypeIdentifierDietaryVitaminK', 'HKQuantityType', 'Vitamin K', 'nutrition', 'vitamin', 'Vitamin K consumed', 'mcg', 'iOS 8.0+', true),
('HKQuantityTypeIdentifierDietaryFolate', 'HKQuantityType', 'Folate', 'nutrition', 'vitamin', 'Folate (folic acid) consumed', 'mcg', 'iOS 8.0+', true)
ON CONFLICT (healthkit_identifier) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  category = EXCLUDED.category,
  subcategory = EXCLUDED.subcategory,
  description = EXCLUDED.description,
  default_unit = EXCLUDED.default_unit,
  available_ios_version = EXCLUDED.available_ios_version;


-- =====================================================
-- Seed Data: Nutrition - Minerals
-- =====================================================
INSERT INTO healthkit_mapping (healthkit_identifier, healthkit_type_name, display_name, category, subcategory, description, default_unit, available_ios_version, is_active) VALUES
('HKQuantityTypeIdentifierDietaryCalcium', 'HKQuantityType', 'Calcium', 'nutrition', 'mineral', 'Calcium consumed', 'mg', 'iOS 8.0+', true),
('HKQuantityTypeIdentifierDietaryChloride', 'HKQuantityType', 'Chloride', 'nutrition', 'mineral', 'Chloride consumed', 'mg', 'iOS 8.0+', true),
('HKQuantityTypeIdentifierDietaryIron', 'HKQuantityType', 'Iron', 'nutrition', 'mineral', 'Iron consumed', 'mg', 'iOS 8.0+', true),
('HKQuantityTypeIdentifierDietaryMagnesium', 'HKQuantityType', 'Magnesium', 'nutrition', 'mineral', 'Magnesium consumed', 'mg', 'iOS 8.0+', true),
('HKQuantityTypeIdentifierDietaryPhosphorus', 'HKQuantityType', 'Phosphorus', 'nutrition', 'mineral', 'Phosphorus consumed', 'mg', 'iOS 8.0+', true),
('HKQuantityTypeIdentifierDietaryPotassium', 'HKQuantityType', 'Potassium', 'nutrition', 'mineral', 'Potassium consumed', 'mg', 'iOS 8.0+', true),
('HKQuantityTypeIdentifierDietarySodium', 'HKQuantityType', 'Sodium', 'nutrition', 'mineral', 'Sodium consumed', 'mg', 'iOS 8.0+', true),
('HKQuantityTypeIdentifierDietaryZinc', 'HKQuantityType', 'Zinc', 'nutrition', 'mineral', 'Zinc consumed', 'mg', 'iOS 8.0+', true),
('HKQuantityTypeIdentifierDietaryChromium', 'HKQuantityType', 'Chromium', 'nutrition', 'ultratrace_mineral', 'Chromium consumed', 'mcg', 'iOS 8.0+', true),
('HKQuantityTypeIdentifierDietaryCopper', 'HKQuantityType', 'Copper', 'nutrition', 'ultratrace_mineral', 'Copper consumed', 'mg', 'iOS 8.0+', true),
('HKQuantityTypeIdentifierDietaryIodine', 'HKQuantityType', 'Iodine', 'nutrition', 'ultratrace_mineral', 'Iodine consumed', 'mcg', 'iOS 8.0+', true),
('HKQuantityTypeIdentifierDietaryManganese', 'HKQuantityType', 'Manganese', 'nutrition', 'ultratrace_mineral', 'Manganese consumed', 'mg', 'iOS 8.0+', true),
('HKQuantityTypeIdentifierDietaryMolybdenum', 'HKQuantityType', 'Molybdenum', 'nutrition', 'ultratrace_mineral', 'Molybdenum consumed', 'mcg', 'iOS 8.0+', true),
('HKQuantityTypeIdentifierDietarySelenium', 'HKQuantityType', 'Selenium', 'nutrition', 'ultratrace_mineral', 'Selenium consumed', 'mcg', 'iOS 8.0+', true)
ON CONFLICT (healthkit_identifier) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  category = EXCLUDED.category,
  subcategory = EXCLUDED.subcategory,
  description = EXCLUDED.description,
  default_unit = EXCLUDED.default_unit,
  available_ios_version = EXCLUDED.available_ios_version;


-- =====================================================
-- Seed Data: Nutrition - Other
-- =====================================================
INSERT INTO healthkit_mapping (healthkit_identifier, healthkit_type_name, display_name, category, subcategory, description, default_unit, available_ios_version, is_active) VALUES
('HKQuantityTypeIdentifierDietaryWater', 'HKQuantityType', 'Water', 'nutrition', 'hydration', 'Water consumed', 'mL', 'iOS 9.0+', true),
('HKQuantityTypeIdentifierDietaryCaffeine', 'HKQuantityType', 'Caffeine', 'nutrition', 'stimulant', 'Caffeine consumed', 'mg', 'iOS 8.0+', true)
ON CONFLICT (healthkit_identifier) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  category = EXCLUDED.category,
  subcategory = EXCLUDED.subcategory,
  description = EXCLUDED.description,
  default_unit = EXCLUDED.default_unit,
  available_ios_version = EXCLUDED.available_ios_version;


-- =====================================================
-- Seed Data: Body Measurements
-- =====================================================
INSERT INTO healthkit_mapping (healthkit_identifier, healthkit_type_name, display_name, category, subcategory, description, default_unit, available_ios_version, is_active) VALUES
('HKQuantityTypeIdentifierBodyMass', 'HKQuantityType', 'Weight', 'body_measurement', 'composition', 'Body weight', 'kg', 'iOS 8.0+', true),
('HKQuantityTypeIdentifierBodyFatPercentage', 'HKQuantityType', 'Body Fat Percentage', 'body_measurement', 'composition', 'Body fat percentage', '%', 'iOS 8.0+', true),
('HKQuantityTypeIdentifierLeanBodyMass', 'HKQuantityType', 'Lean Body Mass', 'body_measurement', 'composition', 'Lean body mass', 'kg', 'iOS 8.0+', true),
('HKQuantityTypeIdentifierBodyMassIndex', 'HKQuantityType', 'BMI', 'body_measurement', 'composition', 'Body mass index', 'count', 'iOS 8.0+', true),
('HKQuantityTypeIdentifierHeight', 'HKQuantityType', 'Height', 'body_measurement', 'anthropometric', 'Height', 'cm', 'iOS 8.0+', true),
('HKQuantityTypeIdentifierWaistCircumference', 'HKQuantityType', 'Waist Circumference', 'body_measurement', 'anthropometric', 'Waist circumference', 'cm', 'iOS 11.0+', true)
ON CONFLICT (healthkit_identifier) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  category = EXCLUDED.category,
  subcategory = EXCLUDED.subcategory,
  description = EXCLUDED.description,
  default_unit = EXCLUDED.default_unit,
  available_ios_version = EXCLUDED.available_ios_version;


-- =====================================================
-- Seed Data: Cardiovascular & Fitness
-- =====================================================
INSERT INTO healthkit_mapping (healthkit_identifier, healthkit_type_name, display_name, category, subcategory, description, default_unit, available_ios_version, is_active) VALUES
('HKQuantityTypeIdentifierHeartRate', 'HKQuantityType', 'Heart Rate', 'cardiovascular', 'heart', 'Heart rate', 'bpm', 'iOS 8.0+', true),
('HKQuantityTypeIdentifierHeartRateVariabilitySDNN', 'HKQuantityType', 'HRV (SDNN)', 'cardiovascular', 'heart', 'Heart rate variability', 'ms', 'iOS 11.0+', true),
('HKQuantityTypeIdentifierRestingHeartRate', 'HKQuantityType', 'Resting Heart Rate', 'cardiovascular', 'heart', 'Resting heart rate', 'bpm', 'iOS 11.0+', true),
('HKQuantityTypeIdentifierVO2Max', 'HKQuantityType', 'VO2 Max', 'fitness', 'cardio_fitness', 'VO2 max', 'mL/kg/min', 'iOS 11.0+', true),
('HKQuantityTypeIdentifierBloodPressureSystolic', 'HKQuantityType', 'Systolic Blood Pressure', 'cardiovascular', 'blood_pressure', 'Systolic blood pressure', 'mmHg', 'iOS 8.0+', true),
('HKQuantityTypeIdentifierBloodPressureDiastolic', 'HKQuantityType', 'Diastolic Blood Pressure', 'cardiovascular', 'blood_pressure', 'Diastolic blood pressure', 'mmHg', 'iOS 8.0+', true)
ON CONFLICT (healthkit_identifier) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  category = EXCLUDED.category,
  subcategory = EXCLUDED.subcategory,
  description = EXCLUDED.description,
  default_unit = EXCLUDED.default_unit,
  available_ios_version = EXCLUDED.available_ios_version;


-- =====================================================
-- Seed Data: Activity
-- =====================================================
INSERT INTO healthkit_mapping (healthkit_identifier, healthkit_type_name, display_name, category, subcategory, description, default_unit, available_ios_version, is_active) VALUES
('HKQuantityTypeIdentifierStepCount', 'HKQuantityType', 'Steps', 'activity', 'movement', 'Step count', 'count', 'iOS 8.0+', true),
('HKQuantityTypeIdentifierAppleExerciseTime', 'HKQuantityType', 'Exercise Time', 'activity', 'exercise', 'Active exercise time', 'min', 'iOS 9.3+', true),
('HKQuantityTypeIdentifierAppleStandHour', 'HKQuantityType', 'Stand Hours', 'activity', 'stand', 'Hours with stand time', 'count', 'iOS 9.0+', true),
('HKQuantityTypeIdentifierDistanceWalkingRunning', 'HKQuantityType', 'Walking/Running Distance', 'activity', 'distance', 'Distance walking or running', 'km', 'iOS 8.0+', true),
('HKQuantityTypeIdentifierDistanceCycling', 'HKQuantityType', 'Cycling Distance', 'activity', 'distance', 'Distance cycling', 'km', 'iOS 8.0+', true),
('HKQuantityTypeIdentifierDistanceSwimming', 'HKQuantityType', 'Swimming Distance', 'activity', 'distance', 'Distance swimming', 'm', 'iOS 10.0+', true)
ON CONFLICT (healthkit_identifier) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  category = EXCLUDED.category,
  subcategory = EXCLUDED.subcategory,
  description = EXCLUDED.description,
  default_unit = EXCLUDED.default_unit,
  available_ios_version = EXCLUDED.available_ios_version;


-- =====================================================
-- Seed Data: Other Health Metrics
-- =====================================================
INSERT INTO healthkit_mapping (healthkit_identifier, healthkit_type_name, display_name, category, subcategory, description, default_unit, available_ios_version, is_active) VALUES
('HKQuantityTypeIdentifierTimeInDaylight', 'HKQuantityType', 'Time in Daylight', 'environmental', 'light', 'Time spent in daylight', 'min', 'iOS 17.0+', true),
('HKQuantityTypeIdentifierNumberOfAlcoholicBeverages', 'HKQuantityType', 'Alcoholic Drinks', 'substance', 'alcohol', 'Number of alcoholic beverages', 'count', 'iOS 9.0+', true),
('HKCategoryTypeIdentifierToothbrushingEvent', 'HKCategoryType', 'Toothbrushing', 'self_care', 'oral_hygiene', 'Toothbrushing event', NULL, 'iOS 13.0+', true)
ON CONFLICT (healthkit_identifier) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  category = EXCLUDED.category,
  subcategory = EXCLUDED.subcategory,
  description = EXCLUDED.description,
  default_unit = EXCLUDED.default_unit,
  available_ios_version = EXCLUDED.available_ios_version;


COMMIT;
