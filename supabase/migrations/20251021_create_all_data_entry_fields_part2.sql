-- =====================================================
-- Create ALL Data Entry Fields - Part 2
-- =====================================================
-- Cognitive Health, Social/Outdoor, Core Care biometrics
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Cognitive Health - Mental Activities
-- =====================================================

INSERT INTO data_entry_fields (field_id, field_name, display_name, description, field_type, data_type, unit, is_active, healthkit_mapping_id, supports_healthkit_sync) VALUES
('DEF_BRAIN_TRAINING_START', 'brain_training_start', 'Brain Training Start', 'Start time of brain training activity', 'timestamp', 'datetime', NULL, true, NULL, false),
('DEF_BRAIN_TRAINING_END', 'brain_training_end', 'Brain Training End', 'End time of brain training activity', 'timestamp', 'datetime', NULL, true, NULL, false),
('DEF_JOURNALING_START', 'journaling_start', 'Journaling Start', 'Start time of journaling session', 'timestamp', 'datetime', NULL, true, NULL, false),
('DEF_JOURNALING_END', 'journaling_end', 'Journaling End', 'End time of journaling session', 'timestamp', 'datetime', NULL, true, NULL, false)
ON CONFLICT (field_id) DO NOTHING;


-- =====================================================
-- PART 2: Cognitive Health - Ratings
-- =====================================================

INSERT INTO data_entry_fields (field_id, field_name, display_name, description, field_type, data_type, unit, is_active, healthkit_mapping_id, supports_healthkit_sync, validation_config) VALUES
('DEF_MOOD_RATING', 'mood_rating', 'Mood Rating', 'Overall mood rating (1-5)', 'rating', 'integer', NULL, true, NULL, false, '{"min": 1, "max": 5, "type": "rating"}'::jsonb),
('DEF_FOCUS_RATING', 'focus_rating', 'Focus Rating', 'Focus and concentration rating (1-5)', 'rating', 'integer', NULL, true, NULL, false, '{"min": 1, "max": 5, "type": "rating"}'::jsonb),
('DEF_MEMORY_CLARITY_RATING', 'memory_clarity_rating', 'Memory Clarity Rating', 'Memory and mental clarity rating (1-5)', 'rating', 'integer', NULL, true, NULL, false, '{"min": 1, "max": 5, "type": "rating"}'::jsonb)
ON CONFLICT (field_id) DO NOTHING;


-- =====================================================
-- PART 3: Cognitive Health - Light Exposure
-- =====================================================

INSERT INTO data_entry_fields (field_id, field_name, display_name, description, field_type, data_type, unit, is_active, healthkit_mapping_id, supports_healthkit_sync) VALUES
('DEF_SUNLIGHT_START', 'sunlight_start', 'Sunlight Exposure Start', 'Start time of sunlight exposure', 'timestamp', 'datetime', NULL, true, NULL, false),
('DEF_SUNLIGHT_END', 'sunlight_end', 'Sunlight Exposure End', 'End time of sunlight exposure', 'timestamp', 'datetime', NULL, true, NULL, false),
('DEF_SUNLIGHT_TYPE', 'sunlight_type', 'Sunlight Exposure Type', 'Type of sunlight exposure (early morning vs general)', 'reference', 'uuid', NULL, true, NULL, false)
ON CONFLICT (field_id) DO NOTHING;

-- Create sunlight exposure types
CREATE TABLE IF NOT EXISTS def_ref_sunlight_types (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sunlight_type_key TEXT UNIQUE NOT NULL,
  display_name TEXT NOT NULL,
  description TEXT,
  is_early_morning BOOLEAN DEFAULT false, -- Within first 2 hours of waking
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO def_ref_sunlight_types (sunlight_type_key, display_name, description, is_early_morning) VALUES
('early_morning', 'Early Morning Light', 'Sunlight exposure within first 2 hours of waking', true),
('morning', 'Morning Sunlight', 'Sunlight exposure during morning hours', false),
('midday', 'Midday Sunlight', 'Sunlight exposure during midday', false),
('afternoon', 'Afternoon Sunlight', 'Sunlight exposure during afternoon', false),
('outdoor_activity', 'Outdoor Activity', 'Sunlight during outdoor activities', false)
ON CONFLICT (sunlight_type_key) DO NOTHING;

UPDATE data_entry_fields
SET reference_table = 'def_ref_sunlight_types'
WHERE field_id = 'DEF_SUNLIGHT_TYPE';


-- =====================================================
-- PART 4: Connection + Purpose - Social
-- =====================================================

INSERT INTO data_entry_fields (field_id, field_name, display_name, description, field_type, data_type, unit, is_active, healthkit_mapping_id, supports_healthkit_sync) VALUES
('DEF_SOCIAL_EVENT_TIME', 'social_event_time', 'Social Event Time', 'Time of social interaction', 'timestamp', 'datetime', NULL, true, NULL, false),
('DEF_SOCIAL_EVENT_TYPE', 'social_event_type', 'Social Event Type', 'Type of social interaction', 'reference', 'uuid', NULL, true, NULL, false)
ON CONFLICT (field_id) DO NOTHING;

-- Create social event types
CREATE TABLE IF NOT EXISTS def_ref_social_event_types (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  social_event_key TEXT UNIQUE NOT NULL,
  display_name TEXT NOT NULL,
  description TEXT,
  typical_duration_minutes NUMERIC,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO def_ref_social_event_types (social_event_key, display_name, description, typical_duration_minutes) VALUES
('family_gathering', 'Family Gathering', 'Time spent with family', 120),
('friend_meetup', 'Friend Meetup', 'Spending time with friends', 90),
('social_meal', 'Social Meal', 'Meal with others', 60),
('community_event', 'Community Event', 'Community or group activity', 90),
('phone_call', 'Phone/Video Call', 'Remote social interaction', 30),
('volunteer', 'Volunteer Work', 'Volunteering in community', 120)
ON CONFLICT (social_event_key) DO NOTHING;

UPDATE data_entry_fields
SET reference_table = 'def_ref_social_event_types'
WHERE field_id = 'DEF_SOCIAL_EVENT_TYPE';


-- =====================================================
-- PART 5: Connection + Purpose - Outdoor
-- =====================================================

INSERT INTO data_entry_fields (field_id, field_name, display_name, description, field_type, data_type, unit, is_active, healthkit_mapping_id, supports_healthkit_sync) VALUES
('DEF_OUTDOOR_START', 'outdoor_start', 'Outdoor Time Start', 'Start time of outdoor activity', 'timestamp', 'datetime', NULL, true, NULL, false),
('DEF_OUTDOOR_END', 'outdoor_end', 'Outdoor Time End', 'End time of outdoor activity', 'timestamp', 'datetime', NULL, true, NULL, false)
ON CONFLICT (field_id) DO NOTHING;


-- =====================================================
-- PART 6: Connection + Purpose - Screen Time (Daily Total)
-- =====================================================

INSERT INTO data_entry_fields (field_id, field_name, display_name, description, field_type, data_type, unit, is_active, healthkit_mapping_id, supports_healthkit_sync, validation_config) VALUES
('DEF_SCREEN_TIME_QUANTITY', 'screen_time_quantity', 'Screen Time Total', 'Total screen time for the day (minutes)', 'quantity', 'numeric', 'minute', true, NULL, true, '{"min": 0, "max": 1440, "increment": 1}'::jsonb),
('DEF_SCREEN_TIME_TYPE', 'screen_time_type', 'Screen Time Type', 'Type of screen time (optional breakdown)', 'reference', 'uuid', NULL, true, NULL, false, NULL),
('DEF_SCREEN_TIME_DATE', 'screen_time_date', 'Screen Time Date', 'Date for this screen time total', 'timestamp', 'datetime', NULL, true, NULL, true, NULL)
ON CONFLICT (field_id) DO NOTHING;

-- Create screen time types
CREATE TABLE IF NOT EXISTS def_ref_screen_time_types (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  screen_type_key TEXT UNIQUE NOT NULL,
  display_name TEXT NOT NULL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO def_ref_screen_time_types (screen_type_key, display_name) VALUES
('phone', 'Phone'),
('computer', 'Computer'),
('tablet', 'Tablet'),
('tv', 'TV'),
('gaming', 'Gaming'),
('total', 'Total (All Screens)')
ON CONFLICT (screen_type_key) DO NOTHING;

UPDATE data_entry_fields
SET reference_table = 'def_ref_screen_time_types'
WHERE field_id = 'DEF_SCREEN_TIME_TYPE';


-- =====================================================
-- PART 7: Connection + Purpose - Gratitude
-- =====================================================

INSERT INTO data_entry_fields (field_id, field_name, display_name, description, field_type, data_type, unit, is_active, healthkit_mapping_id, supports_healthkit_sync) VALUES
('DEF_GRATITUDE_TIME', 'gratitude_time', 'Gratitude Practice Time', 'Time of gratitude practice', 'timestamp', 'datetime', NULL, true, NULL, false),
('DEF_GRATITUDE_CONTENT', 'gratitude_content', 'Gratitude Content', 'What you are grateful for (optional text)', 'text', 'text', NULL, true, NULL, false)
ON CONFLICT (field_id) DO NOTHING;


-- =====================================================
-- PART 8: Core Care - Biometrics (Individual Fields)
-- =====================================================

-- Weight
INSERT INTO data_entry_fields (field_id, field_name, display_name, description, field_type, data_type, unit, is_active, healthkit_mapping_id, supports_healthkit_sync, validation_config) VALUES
('DEF_WEIGHT', 'weight', 'Weight', 'Body weight', 'quantity', 'numeric', 'kilogram', true, (SELECT id FROM healthkit_mapping WHERE healthkit_identifier = 'HKQuantityTypeIdentifierBodyMass' LIMIT 1), true, '{"min": 20, "max": 300, "increment": 0.1}'::jsonb),
('DEF_WEIGHT_TIME', 'weight_time', 'Weight Measurement Time', 'When weight was measured', 'timestamp', 'datetime', NULL, true, NULL, false, NULL)
ON CONFLICT (field_id) DO NOTHING;

-- Height
INSERT INTO data_entry_fields (field_id, field_name, display_name, description, field_type, data_type, unit, is_active, healthkit_mapping_id, supports_healthkit_sync, validation_config) VALUES
('DEF_HEIGHT', 'height', 'Height', 'Body height', 'quantity', 'numeric', 'centimeter', true, (SELECT id FROM healthkit_mapping WHERE healthkit_identifier = 'HKQuantityTypeIdentifierHeight' LIMIT 1), true, '{"min": 100, "max": 250, "increment": 0.1}'::jsonb)
ON CONFLICT (field_id) DO NOTHING;

-- Body Fat Percentage
INSERT INTO data_entry_fields (field_id, field_name, display_name, description, field_type, data_type, unit, is_active, healthkit_mapping_id, supports_healthkit_sync, validation_config) VALUES
('DEF_BODY_FAT_PCT', 'body_fat_percentage', 'Body Fat Percentage', 'Body fat percentage', 'quantity', 'numeric', 'percent', true, (SELECT id FROM healthkit_mapping WHERE healthkit_identifier = 'HKQuantityTypeIdentifierBodyFatPercentage' LIMIT 1), true, '{"min": 0, "max": 100, "increment": 0.1}'::jsonb),
('DEF_BODY_FAT_TIME', 'body_fat_time', 'Body Fat Measurement Time', 'When body fat was measured', 'timestamp', 'datetime', NULL, true, NULL, false, NULL)
ON CONFLICT (field_id) DO NOTHING;

-- Blood Pressure
INSERT INTO data_entry_fields (field_id, field_name, display_name, description, field_type, data_type, unit, is_active, healthkit_mapping_id, supports_healthkit_sync, validation_config) VALUES
('DEF_BLOOD_PRESSURE_SYS', 'blood_pressure_systolic', 'Systolic Blood Pressure', 'Systolic blood pressure', 'quantity', 'numeric', 'millimeters_mercury', true, (SELECT id FROM healthkit_mapping WHERE healthkit_identifier = 'HKQuantityTypeIdentifierBloodPressureSystolic' LIMIT 1), true, '{"min": 70, "max": 200, "increment": 1}'::jsonb),
('DEF_BLOOD_PRESSURE_DIA', 'blood_pressure_diastolic', 'Diastolic Blood Pressure', 'Diastolic blood pressure', 'quantity', 'numeric', 'millimeters_mercury', true, (SELECT id FROM healthkit_mapping WHERE healthkit_identifier = 'HKQuantityTypeIdentifierBloodPressureDiastolic' LIMIT 1), true, '{"min": 40, "max": 130, "increment": 1}'::jsonb),
('DEF_BLOOD_PRESSURE_TIME', 'blood_pressure_time', 'Blood Pressure Measurement Time', 'When blood pressure was measured', 'timestamp', 'datetime', NULL, true, NULL, false, NULL)
ON CONFLICT (field_id) DO NOTHING;

-- Waist Circumference
INSERT INTO data_entry_fields (field_id, field_name, display_name, description, field_type, data_type, unit, is_active, healthkit_mapping_id, supports_healthkit_sync, validation_config) VALUES
('DEF_WAIST_CIRCUMFERENCE', 'waist_circumference', 'Waist Circumference', 'Waist circumference measurement', 'quantity', 'numeric', 'centimeter', true, (SELECT id FROM healthkit_mapping WHERE healthkit_identifier = 'HKQuantityTypeIdentifierWaistCircumference' LIMIT 1), true, '{"min": 40, "max": 200, "increment": 0.5}'::jsonb),
('DEF_WAIST_TIME', 'waist_time', 'Waist Measurement Time', 'When waist was measured', 'timestamp', 'datetime', NULL, true, NULL, false, NULL)
ON CONFLICT (field_id) DO NOTHING;

-- Hip Circumference (no HealthKit equivalent)
INSERT INTO data_entry_fields (field_id, field_name, display_name, description, field_type, data_type, unit, is_active, healthkit_mapping_id, supports_healthkit_sync, validation_config) VALUES
('DEF_HIP_CIRCUMFERENCE', 'hip_circumference', 'Hip Circumference', 'Hip circumference measurement', 'quantity', 'numeric', 'centimeter', true, NULL, false, '{"min": 50, "max": 200, "increment": 0.5}'::jsonb),
('DEF_HIP_TIME', 'hip_time', 'Hip Measurement Time', 'When hip was measured', 'timestamp', 'datetime', NULL, true, NULL, false, NULL)
ON CONFLICT (field_id) DO NOTHING;


-- =====================================================
-- PART 9: Core Care - Daily Habits
-- =====================================================

INSERT INTO data_entry_fields (field_id, field_name, display_name, description, field_type, data_type, unit, is_active, healthkit_mapping_id, supports_healthkit_sync) VALUES
('DEF_BRUSHING_TIME', 'brushing_time', 'Teeth Brushing Time', 'Time teeth were brushed', 'timestamp', 'datetime', NULL, true, NULL, false),
('DEF_FLOSSING_TIME', 'flossing_time', 'Flossing Time', 'Time teeth were flossed', 'timestamp', 'datetime', NULL, true, NULL, false),
('DEF_SUNSCREEN_TIME', 'sunscreen_time', 'Sunscreen Application Time', 'Time sunscreen was applied', 'timestamp', 'datetime', NULL, true, NULL, false),
('DEF_SUNSCREEN_TYPE', 'sunscreen_type', 'Sunscreen Application Type', 'Type of sunscreen application', 'reference', 'uuid', NULL, true, NULL, false),
('DEF_SKINCARE_TIME', 'skincare_time', 'Skincare Time', 'Time of skincare routine', 'timestamp', 'datetime', NULL, true, NULL, false),
('DEF_SKINCARE_STEP', 'skincare_step', 'Skincare Step', 'Which step of skincare routine', 'reference', 'uuid', NULL, true, NULL, false)
ON CONFLICT (field_id) DO NOTHING;

-- Create sunscreen application types
CREATE TABLE IF NOT EXISTS def_ref_sunscreen_types (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sunscreen_type_key TEXT UNIQUE NOT NULL,
  display_name TEXT NOT NULL,
  is_morning BOOLEAN DEFAULT false,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO def_ref_sunscreen_types (sunscreen_type_key, display_name, is_morning) VALUES
('morning', 'Morning Application', true),
('reapplication', 'Reapplication', false),
('pre_outdoor', 'Pre-Outdoor Activity', false)
ON CONFLICT (sunscreen_type_key) DO NOTHING;

-- Create skincare step types
CREATE TABLE IF NOT EXISTS def_ref_skincare_steps (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  skincare_step_key TEXT UNIQUE NOT NULL,
  display_name TEXT NOT NULL,
  typical_order INTEGER,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO def_ref_skincare_steps (skincare_step_key, display_name, typical_order) VALUES
('cleanse', 'Cleanse', 1),
('tone', 'Tone', 2),
('serum', 'Serum', 3),
('eye_cream', 'Eye Cream', 4),
('moisturize', 'Moisturize', 5),
('sunscreen', 'Sunscreen (AM)', 6),
('retinol', 'Retinol (PM)', 7),
('mask', 'Face Mask', 8)
ON CONFLICT (skincare_step_key) DO NOTHING;

UPDATE data_entry_fields
SET reference_table = 'def_ref_sunscreen_types'
WHERE field_id = 'DEF_SUNSCREEN_TYPE';

UPDATE data_entry_fields
SET reference_table = 'def_ref_skincare_steps'
WHERE field_id = 'DEF_SKINCARE_STEP';


-- =====================================================
-- PART 10: Core Care - Add Therapeutic Time
-- =====================================================

INSERT INTO data_entry_fields (field_id, field_name, display_name, description, field_type, data_type, unit, is_active, healthkit_mapping_id, supports_healthkit_sync) VALUES
('DEF_THERAPEUTIC_TIME', 'therapeutic_time', 'Therapeutic Administration Time', 'Time medication/supplement was taken', 'timestamp', 'datetime', NULL, true, NULL, false)
ON CONFLICT (field_id) DO NOTHING;


-- =====================================================
-- Summary
-- =====================================================

DO $$
DECLARE
  active_count INT;
  new_count INT;
BEGIN
  SELECT COUNT(*) INTO active_count FROM data_entry_fields WHERE is_active = true;
  SELECT COUNT(*) INTO new_count FROM data_entry_fields WHERE is_active = true AND (
    field_id LIKE 'DEF_BRAIN%' OR
    field_id LIKE 'DEF_JOURNALING%' OR
    field_id LIKE 'DEF_MOOD%' OR
    field_id LIKE 'DEF_FOCUS%' OR
    field_id LIKE 'DEF_MEMORY%' OR
    field_id LIKE 'DEF_SUNLIGHT%' OR
    field_id LIKE 'DEF_SOCIAL%' OR
    field_id LIKE 'DEF_OUTDOOR%' OR
    field_id LIKE 'DEF_SCREEN_TIME%' OR
    field_id LIKE 'DEF_GRATITUDE%' OR
    field_id LIKE 'DEF_WEIGHT%' OR
    field_id LIKE 'DEF_HEIGHT%' OR
    field_id LIKE 'DEF_BODY_FAT%' OR
    field_id LIKE 'DEF_BLOOD_PRESSURE%' OR
    field_id LIKE 'DEF_WAIST%' OR
    field_id LIKE 'DEF_HIP%' OR
    field_id LIKE 'DEF_BRUSHING%' OR
    field_id LIKE 'DEF_FLOSSING%' OR
    field_id LIKE 'DEF_SUNSCREEN%' OR
    field_id LIKE 'DEF_SKINCARE%' OR
    field_id = 'DEF_THERAPEUTIC_TIME'
  );

  RAISE NOTICE '==========================================='  ;
  RAISE NOTICE 'Data Entry Fields - Part 2 Complete';
  RAISE NOTICE '===========================================';
  RAISE NOTICE 'Total active data_entry_fields: %', active_count;
  RAISE NOTICE 'Part 2 fields: %', new_count;
  RAISE NOTICE '';
  RAISE NOTICE 'Added:';
  RAISE NOTICE '  - Cognitive Health: 7 fields (brain training, journaling, ratings)';
  RAISE NOTICE '  - Light Exposure: 3 fields';
  RAISE NOTICE '  - Social: 2 fields';
  RAISE NOTICE '  - Outdoor: 2 fields';
  RAISE NOTICE '  - Screen Time: 3 fields (daily total)';
  RAISE NOTICE '  - Gratitude: 2 fields';
  RAISE NOTICE '  - Biometrics: 11 fields (weight, height, body fat, BP, waist, hip)';
  RAISE NOTICE '  - Daily Habits: 6 fields (brushing, flossing, sunscreen, skincare)';
  RAISE NOTICE '  - Therapeutic Time: 1 field';
  RAISE NOTICE '';
  RAISE NOTICE 'Reference tables created:';
  RAISE NOTICE '  - def_ref_sunlight_types';
  RAISE NOTICE '  - def_ref_social_event_types';
  RAISE NOTICE '  - def_ref_screen_time_types';
  RAISE NOTICE '  - def_ref_sunscreen_types';
  RAISE NOTICE '  - def_ref_skincare_steps';
  RAISE NOTICE '';
  RAISE NOTICE 'ALL DATA_ENTRY_FIELDS COMPLETE!';
END $$;

COMMIT;
