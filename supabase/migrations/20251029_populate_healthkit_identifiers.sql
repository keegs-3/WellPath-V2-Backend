-- Populate healthkit_identifier for all HealthKit-syncable fields
-- This enables backend-driven mapping instead of hardcoded field_ids in iOS

-- Sleep
UPDATE data_entry_fields SET healthkit_identifier = 'HKCategoryTypeIdentifierSleepAnalysis'
WHERE field_id = 'DEF_SLEEP_PERIOD_START';

UPDATE data_entry_fields SET healthkit_identifier = 'HKCategoryTypeIdentifierSleepAnalysis'
WHERE field_id = 'DEF_SLEEP_PERIOD_END';

UPDATE data_entry_fields SET healthkit_identifier = 'HKCategoryTypeIdentifierSleepAnalysis'
WHERE field_id = 'DEF_SLEEP_PERIOD_TYPE';

-- Nutrition
UPDATE data_entry_fields SET healthkit_identifier = 'HKQuantityTypeIdentifierDietaryProtein'
WHERE field_id = 'DEF_PROTEIN_GRAMS';

UPDATE data_entry_fields SET healthkit_identifier = 'HKQuantityTypeIdentifierDietaryFiber'
WHERE field_id = 'DEF_FIBER_GRAMS';

UPDATE data_entry_fields SET healthkit_identifier = 'HKQuantityTypeIdentifierDietaryWater'
WHERE field_id = 'DEF_WATER_QUANTITY';

UPDATE data_entry_fields SET healthkit_identifier = 'HKQuantityTypeIdentifierDietaryEnergyConsumed'
WHERE field_id = 'DEF_CALORIES_CONSUMED';

UPDATE data_entry_fields SET healthkit_identifier = 'HKQuantityTypeIdentifierDietaryCaffeine'
WHERE field_id = 'DEF_CAFFEINE_QUANTITY';

UPDATE data_entry_fields SET healthkit_identifier = 'HKQuantityTypeIdentifierDietarySugar'
WHERE field_id = 'DEF_ADDED_SUGAR_QUANTITY';

UPDATE data_entry_fields SET healthkit_identifier = 'HKQuantityTypeIdentifierDietaryFatSaturated'
WHERE field_id = 'DEF_SATURATED_FAT';

-- Activity & Exercise
UPDATE data_entry_fields SET healthkit_identifier = 'HKQuantityTypeIdentifierStepCount'
WHERE field_id = 'DEF_STEPS';

UPDATE data_entry_fields SET healthkit_identifier = 'HKQuantityTypeIdentifierActiveEnergyBurned'
WHERE field_id = 'DEF_CARDIO_CALORIES';

UPDATE data_entry_fields SET healthkit_identifier = 'HKQuantityTypeIdentifierDistanceWalkingRunning'
WHERE field_id = 'DEF_CARDIO_DISTANCE';

UPDATE data_entry_fields SET healthkit_identifier = 'HKWorkoutTypeIdentifier'
WHERE field_id = 'DEF_CARDIO_START';

UPDATE data_entry_fields SET healthkit_identifier = 'HKWorkoutTypeIdentifier'
WHERE field_id = 'DEF_CARDIO_END';

UPDATE data_entry_fields SET healthkit_identifier = 'HKWorkoutTypeIdentifier'
WHERE field_id = 'DEF_CARDIO_TYPE';

-- Body Measurements
UPDATE data_entry_fields SET healthkit_identifier = 'HKQuantityTypeIdentifierBodyMass'
WHERE field_id = 'DEF_WEIGHT';

UPDATE data_entry_fields SET healthkit_identifier = 'HKQuantityTypeIdentifierHeight'
WHERE field_id = 'DEF_HEIGHT';

UPDATE data_entry_fields SET healthkit_identifier = 'HKQuantityTypeIdentifierBodyFatPercentage'
WHERE field_id = 'DEF_BODY_FAT_PCT';

UPDATE data_entry_fields SET healthkit_identifier = 'HKQuantityTypeIdentifierBodyMassIndex'
WHERE field_id = 'DEF_BMI';

UPDATE data_entry_fields SET healthkit_identifier = 'HKQuantityTypeIdentifierWaistCircumference'
WHERE field_id = 'DEF_WAIST_CIRCUMFERENCE';

-- Heart Health
UPDATE data_entry_fields SET healthkit_identifier = 'HKQuantityTypeIdentifierHeartRate'
WHERE field_id IN (SELECT field_id FROM data_entry_fields WHERE field_name = 'heart_rate');

UPDATE data_entry_fields SET healthkit_identifier = 'HKQuantityTypeIdentifierRestingHeartRate'
WHERE field_id IN (SELECT field_id FROM data_entry_fields WHERE field_name = 'resting_heart_rate');

UPDATE data_entry_fields SET healthkit_identifier = 'HKQuantityTypeIdentifierVO2Max'
WHERE field_id IN (SELECT field_id FROM data_entry_fields WHERE field_name = 'vo2_max');

-- Vitals
UPDATE data_entry_fields SET healthkit_identifier = 'HKQuantityTypeIdentifierBloodPressureSystolic'
WHERE field_id = 'DEF_BLOOD_PRESSURE_SYS';

UPDATE data_entry_fields SET healthkit_identifier = 'HKQuantityTypeIdentifierBloodPressureDiastolic'
WHERE field_id = 'DEF_BLOOD_PRESSURE_DIA';

UPDATE data_entry_fields SET healthkit_identifier = 'HKQuantityTypeIdentifierRespiratoryRate'
WHERE field_id IN (SELECT field_id FROM data_entry_fields WHERE field_name = 'respiratory_rate');

UPDATE data_entry_fields SET healthkit_identifier = 'HKQuantityTypeIdentifierBodyTemperature'
WHERE field_id IN (SELECT field_id FROM data_entry_fields WHERE field_name = 'body_temperature');

UPDATE data_entry_fields SET healthkit_identifier = 'HKQuantityTypeIdentifierOxygenSaturation'
WHERE field_id IN (SELECT field_id FROM data_entry_fields WHERE field_name = 'oxygen_saturation');

UPDATE data_entry_fields SET healthkit_identifier = 'HKQuantityTypeIdentifierBloodGlucose'
WHERE field_id IN (SELECT field_id FROM data_entry_fields WHERE field_name = 'blood_glucose');

-- Mindfulness
UPDATE data_entry_fields SET healthkit_identifier = 'HKCategoryTypeIdentifierMindfulSession'
WHERE field_id IN (SELECT field_id FROM data_entry_fields WHERE field_name LIKE '%mindful%' OR field_name LIKE '%meditation%');

-- Mark all populated fields as supporting HealthKit sync
UPDATE data_entry_fields
SET supports_healthkit_sync = true
WHERE healthkit_identifier IS NOT NULL;

-- Verify the mappings
SELECT
    field_id,
    field_name,
    healthkit_identifier,
    supports_healthkit_sync
FROM data_entry_fields
WHERE healthkit_identifier IS NOT NULL
ORDER BY field_id;
