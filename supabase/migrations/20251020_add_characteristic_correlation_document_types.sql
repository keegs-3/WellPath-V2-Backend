-- =====================================================
-- Add HKCharacteristicType, HKCorrelationType, and HKDocumentType
-- =====================================================
-- Adds the remaining HealthKit object type categories:
-- - HKCharacteristicType (user characteristics that don't change)
-- - HKCorrelationType (compound measurements like blood pressure)
-- - HKDocumentType (CDA documents)
--
-- Created: 2025-10-20
-- =====================================================

BEGIN;

-- =====================================================
-- HKCharacteristicType (6 types)
-- =====================================================
-- These are read-only from the app perspective
-- Users must edit via Health app
INSERT INTO healthkit_mapping (healthkit_identifier, healthkit_type_name, display_name, category, description, available_ios_version, is_writable, is_readable, is_active) VALUES
('HKCharacteristicTypeIdentifierBiologicalSex', 'HKCharacteristicType', 'Biological Sex', 'characteristic', 'User biological sex (male/female/other)', 'iOS 8.0+', false, true, true),
('HKCharacteristicTypeIdentifierBloodType', 'HKCharacteristicType', 'Blood Type', 'characteristic', 'User blood type (A+, O-, etc.)', 'iOS 8.0+', false, true, true),
('HKCharacteristicTypeIdentifierDateOfBirth', 'HKCharacteristicType', 'Date of Birth', 'characteristic', 'User date of birth', 'iOS 8.0+', false, true, true),
('HKCharacteristicTypeIdentifierFitzpatrickSkinType', 'HKCharacteristicType', 'Fitzpatrick Skin Type', 'characteristic', 'User skin type (I-VI scale)', 'iOS 9.0+', false, true, true),
('HKCharacteristicTypeIdentifierWheelchairUse', 'HKCharacteristicType', 'Wheelchair Use', 'characteristic', 'Whether user uses wheelchair', 'iOS 10.0+', false, true, true),
('HKCharacteristicTypeIdentifierActivityMoveMode', 'HKCharacteristicType', 'Activity Move Mode', 'characteristic', 'Activity move mode (active energy vs move time)', 'iOS 14.0+', false, true, true)
ON CONFLICT (healthkit_identifier) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  category = EXCLUDED.category,
  description = EXCLUDED.description,
  is_writable = EXCLUDED.is_writable,
  is_readable = EXCLUDED.is_readable;

-- =====================================================
-- HKCorrelationType (2 types)
-- =====================================================
-- These combine multiple samples into single objects
INSERT INTO healthkit_mapping (healthkit_identifier, healthkit_type_name, display_name, category, subcategory, description, available_ios_version, is_active) VALUES
('HKCorrelationTypeIdentifierBloodPressure', 'HKCorrelationType', 'Blood Pressure', 'cardiovascular', 'correlation', 'Combines systolic and diastolic into single reading', 'iOS 8.0+', true),
('HKCorrelationTypeIdentifierFood', 'HKCorrelationType', 'Food', 'nutrition', 'correlation', 'Combines nutritional samples into single food object', 'iOS 8.0+', true)
ON CONFLICT (healthkit_identifier) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  category = EXCLUDED.category,
  subcategory = EXCLUDED.subcategory,
  description = EXCLUDED.description;

-- =====================================================
-- HKDocumentType (1 type)
-- =====================================================
-- Clinical documents in CDA format
INSERT INTO healthkit_mapping (healthkit_identifier, healthkit_type_name, display_name, category, description, available_ios_version, is_active) VALUES
('HKDocumentTypeIdentifierCDA', 'HKDocumentType', 'Clinical Document', 'clinical', 'CDA (Clinical Document Architecture) formatted documents', 'iOS 10.0+', true)
ON CONFLICT (healthkit_identifier) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  category = EXCLUDED.category,
  description = EXCLUDED.description;

-- =====================================================
-- Add aggregation_style metadata for HKQuantityType
-- =====================================================
-- This helps determine valid aggregation operations
ALTER TABLE healthkit_mapping
ADD COLUMN IF NOT EXISTS aggregation_style TEXT,
ADD COLUMN IF NOT EXISTS supports_sum BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS supports_average BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS supports_min_max BOOLEAN DEFAULT false;

-- Add check constraint for aggregation_style
ALTER TABLE healthkit_mapping
DROP CONSTRAINT IF EXISTS healthkit_mapping_aggregation_style_check;

ALTER TABLE healthkit_mapping
ADD CONSTRAINT healthkit_mapping_aggregation_style_check
CHECK (aggregation_style IS NULL OR aggregation_style IN ('cumulative', 'discrete_arithmetic', 'discrete_temporally_weighted', 'discrete_equivalent_continuous'));

COMMENT ON COLUMN healthkit_mapping.aggregation_style IS
'HKQuantityAggregationStyle: cumulative (sum), discrete_arithmetic (avg), discrete_temporally_weighted (time-weighted avg), discrete_equivalent_continuous (sound level)';

COMMENT ON COLUMN healthkit_mapping.supports_sum IS
'Whether this quantity type supports SUM aggregation (cumulative types only)';

COMMENT ON COLUMN healthkit_mapping.supports_average IS
'Whether this quantity type supports AVERAGE aggregation (discrete types)';

COMMENT ON COLUMN healthkit_mapping.supports_min_max IS
'Whether this quantity type supports MIN/MAX aggregation (discrete types)';

-- =====================================================
-- Update existing HKQuantityType with aggregation styles
-- =====================================================

-- Cumulative types (support SUM)
UPDATE healthkit_mapping
SET
  aggregation_style = 'cumulative',
  supports_sum = true,
  supports_average = false,
  supports_min_max = false
WHERE healthkit_identifier IN (
  -- Activity metrics
  'HKQuantityTypeIdentifierStepCount',
  'HKQuantityTypeIdentifierDistanceWalkingRunning',
  'HKQuantityTypeIdentifierDistanceCycling',
  'HKQuantityTypeIdentifierDistanceSwimming',
  'HKQuantityTypeIdentifierDistanceWheelchair',
  'HKQuantityTypeIdentifierPushCount',
  'HKQuantityTypeIdentifierFlightsClimbed',
  'HKQuantityTypeIdentifierSwimmingStrokeCount',
  -- Energy
  'HKQuantityTypeIdentifierActiveEnergyBurned',
  'HKQuantityTypeIdentifierBasalEnergyBurned',
  -- Nutrition (all cumulative)
  'HKQuantityTypeIdentifierDietaryEnergyConsumed',
  'HKQuantityTypeIdentifierDietaryProtein',
  'HKQuantityTypeIdentifierDietaryCarbohydrates',
  'HKQuantityTypeIdentifierDietaryFatTotal',
  'HKQuantityTypeIdentifierDietaryFatSaturated',
  'HKQuantityTypeIdentifierDietaryFatMonounsaturated',
  'HKQuantityTypeIdentifierDietaryFatPolyunsaturated',
  'HKQuantityTypeIdentifierDietaryCholesterol',
  'HKQuantityTypeIdentifierDietarySodium',
  'HKQuantityTypeIdentifierDietaryFiber',
  'HKQuantityTypeIdentifierDietarySugar',
  'HKQuantityTypeIdentifierDietaryVitaminA',
  'HKQuantityTypeIdentifierDietaryVitaminB6',
  'HKQuantityTypeIdentifierDietaryVitaminB12',
  'HKQuantityTypeIdentifierDietaryVitaminC',
  'HKQuantityTypeIdentifierDietaryVitaminD',
  'HKQuantityTypeIdentifierDietaryVitaminE',
  'HKQuantityTypeIdentifierDietaryVitaminK',
  'HKQuantityTypeIdentifierDietaryCalcium',
  'HKQuantityTypeIdentifierDietaryIron',
  'HKQuantityTypeIdentifierDietaryMagnesium',
  'HKQuantityTypeIdentifierDietaryPotassium',
  'HKQuantityTypeIdentifierDietaryZinc',
  'HKQuantityTypeIdentifierDietaryWater',
  'HKQuantityTypeIdentifierDietaryCaffeine',
  -- Time
  'HKQuantityTypeIdentifierAppleExerciseTime',
  'HKQuantityTypeIdentifierAppleStandTime'
);

-- Discrete Arithmetic types (support AVG, MIN, MAX)
UPDATE healthkit_mapping
SET
  aggregation_style = 'discrete_arithmetic',
  supports_sum = false,
  supports_average = true,
  supports_min_max = true
WHERE healthkit_identifier IN (
  -- Body measurements
  'HKQuantityTypeIdentifierBodyMass',
  'HKQuantityTypeIdentifierBodyFatPercentage',
  'HKQuantityTypeIdentifierLeanBodyMass',
  'HKQuantityTypeIdentifierBodyMassIndex',
  'HKQuantityTypeIdentifierHeight',
  'HKQuantityTypeIdentifierWaistCircumference',
  -- Cardiovascular
  'HKQuantityTypeIdentifierHeartRate',
  'HKQuantityTypeIdentifierRestingHeartRate',
  'HKQuantityTypeIdentifierWalkingHeartRateAverage',
  'HKQuantityTypeIdentifierHeartRateVariabilitySDNN',
  'HKQuantityTypeIdentifierOxygenSaturation',
  'HKQuantityTypeIdentifierBloodPressureSystolic',
  'HKQuantityTypeIdentifierBloodPressureDiastolic',
  'HKQuantityTypeIdentifierRespiratoryRate',
  'HKQuantityTypeIdentifierVO2Max',
  -- Temperature
  'HKQuantityTypeIdentifierBodyTemperature',
  -- Metabolic
  'HKQuantityTypeIdentifierBloodGlucose',
  'HKQuantityTypeIdentifierInsulinDelivery'
);

-- Discrete Temporally Weighted types (support time-weighted AVG)
UPDATE healthkit_mapping
SET
  aggregation_style = 'discrete_temporally_weighted',
  supports_sum = false,
  supports_average = true,
  supports_min_max = true
WHERE healthkit_identifier IN (
  'HKQuantityTypeIdentifierHeartRateVariabilitySDNN'
);

-- Discrete Equivalent Continuous Level (sound exposure)
UPDATE healthkit_mapping
SET
  aggregation_style = 'discrete_equivalent_continuous',
  supports_sum = false,
  supports_average = true,
  supports_min_max = true
WHERE healthkit_identifier IN (
  'HKQuantityTypeIdentifierEnvironmentalAudioExposure',
  'HKQuantityTypeIdentifierHeadphoneAudioExposure'
);

COMMIT;
