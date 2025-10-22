-- =====================================================
-- Create Consolidated Event Types and Data Entry Fields
-- =====================================================
-- Phase 2: Creates 9 event types
-- Phase 3: Creates ~40 consolidated data_entry_fields
-- Links fields to event types via event_types_data_entry_fields
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- Phase 2: Create 9 Consolidated Event Types
-- =====================================================

INSERT INTO event_types (event_type_id, name, category, description, is_active) VALUES
('meal_event', 'Meal/Food Intake', 'nutrition', 'Complete meal or food intake event', true),
('cardio_event', 'Cardio Exercise', 'exercise', 'Cardiovascular exercise session', true),
('strength_event', 'Strength Training', 'exercise', 'Strength/resistance training session', true),
('flexibility_event', 'Flexibility/Mobility', 'exercise', 'Stretching, yoga, or mobility work', true),
('sleep_event', 'Sleep Period', 'sleep', 'Sleep session with quality factors', true),
('mindfulness_event', 'Mindfulness Activity', 'mindfulness', 'Meditation, breathing, or mindfulness practice', true),
('measurement_event', 'Body Measurement', 'health_tracking', 'Body measurements and vitals', true),
('screening_event', 'Health Screening', 'health_tracking', 'Preventive health screening', true),
('substance_event', 'Substance Use', 'substances', 'Alcohol, caffeine, or other substance intake', true)
ON CONFLICT (event_type_id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  updated_at = now();


-- =====================================================
-- Phase 3: Create Consolidated Data Entry Fields
-- =====================================================

-- =====================================================
-- MEAL EVENT FIELDS (8 fields)
-- =====================================================

INSERT INTO data_entry_fields (field_id, field_name, display_name, description, field_type, data_type, event_type_id, is_active) VALUES
('DEF_MEAL_TIME', 'meal_time', 'Meal Time', 'When the meal was consumed', 'timestamp', 'datetime', 'meal_event', true),
('DEF_MEAL_TYPE', 'meal_type_id', 'Meal Type', 'Type of meal (breakfast, lunch, etc.)', 'reference', 'uuid', 'meal_event', true),
('DEF_MEAL_SIZE', 'meal_size', 'Meal Size', 'Size of meal (small/regular/large)', 'category', 'text', 'meal_event', true),
('DEF_MEAL_QUALIFIERS', 'meal_qualifiers', 'Meal Qualifiers', 'Meal characteristics (mindful, whole_foods, etc.)', 'reference', 'uuid[]', 'meal_event', true),
('DEF_FOOD_TYPE', 'food_type_id', 'Food Item', 'Specific food consumed', 'reference', 'uuid', 'meal_event', true),
('DEF_FOOD_QUANTITY', 'food_quantity', 'Food Quantity', 'Amount of food', 'quantity', 'numeric', 'meal_event', true),
('DEF_BEVERAGE_TYPE', 'beverage_type_id', 'Beverage', 'Beverage consumed', 'reference', 'uuid', 'meal_event', true),
('DEF_BEVERAGE_QUANTITY', 'beverage_quantity', 'Beverage Quantity', 'Amount of beverage', 'quantity', 'numeric', 'meal_event', true)
ON CONFLICT (field_id) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  event_type_id = EXCLUDED.event_type_id,
  is_active = EXCLUDED.is_active,
  updated_at = now();


-- =====================================================
-- CARDIO EVENT FIELDS (5 fields)
-- =====================================================

INSERT INTO data_entry_fields (field_id, field_name, display_name, description, field_type, data_type, event_type_id, is_active) VALUES
('DEF_CARDIO_START', 'cardio_start_time', 'Start Time', 'When cardio started', 'timestamp', 'datetime', 'cardio_event', true),
('DEF_CARDIO_END', 'cardio_end_time', 'End Time', 'When cardio ended', 'timestamp', 'datetime', 'cardio_event', true),
('DEF_CARDIO_TYPE', 'cardio_type_id', 'Cardio Type', 'Type of cardio exercise', 'reference', 'uuid', 'cardio_event', true),
('DEF_CARDIO_INTENSITY', 'cardio_intensity', 'Intensity Level', 'Intensity level (1-10)', 'rating', 'integer', 'cardio_event', true),
('DEF_CARDIO_DISTANCE', 'cardio_distance', 'Distance', 'Distance covered', 'quantity', 'numeric', 'cardio_event', true)
ON CONFLICT (field_id) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  event_type_id = EXCLUDED.event_type_id,
  is_active = EXCLUDED.is_active,
  updated_at = now();


-- =====================================================
-- STRENGTH EVENT FIELDS (5 fields)
-- =====================================================

INSERT INTO data_entry_fields (field_id, field_name, display_name, description, field_type, data_type, event_type_id, is_active) VALUES
('DEF_STRENGTH_START', 'strength_start_time', 'Start Time', 'When strength training started', 'timestamp', 'datetime', 'strength_event', true),
('DEF_STRENGTH_END', 'strength_end_time', 'End Time', 'When strength training ended', 'timestamp', 'datetime', 'strength_event', true),
('DEF_STRENGTH_TYPE', 'strength_type_id', 'Strength Type', 'Type of strength training', 'reference', 'uuid', 'strength_event', true),
('DEF_STRENGTH_MUSCLE_GROUPS', 'muscle_groups', 'Muscle Groups', 'Muscle groups targeted', 'reference', 'uuid[]', 'strength_event', true),
('DEF_STRENGTH_INTENSITY', 'strength_intensity', 'Intensity Level', 'Intensity level (1-10)', 'rating', 'integer', 'strength_event', true)
ON CONFLICT (field_id) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  event_type_id = EXCLUDED.event_type_id,
  is_active = EXCLUDED.is_active,
  updated_at = now();


-- =====================================================
-- FLEXIBILITY EVENT FIELDS (4 fields)
-- =====================================================

INSERT INTO data_entry_fields (field_id, field_name, display_name, description, field_type, data_type, event_type_id, is_active) VALUES
('DEF_FLEXIBILITY_START', 'flexibility_start_time', 'Start Time', 'When flexibility work started', 'timestamp', 'datetime', 'flexibility_event', true),
('DEF_FLEXIBILITY_END', 'flexibility_end_time', 'End Time', 'When flexibility work ended', 'timestamp', 'datetime', 'flexibility_event', true),
('DEF_FLEXIBILITY_TYPE', 'flexibility_type_id', 'Flexibility Type', 'Type of flexibility work', 'reference', 'uuid', 'flexibility_event', true),
('DEF_FLEXIBILITY_INTENSITY', 'flexibility_intensity', 'Intensity Level', 'Intensity level (1-10)', 'rating', 'integer', 'flexibility_event', true)
ON CONFLICT (field_id) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  event_type_id = EXCLUDED.event_type_id,
  is_active = EXCLUDED.is_active,
  updated_at = now();


-- =====================================================
-- SLEEP EVENT FIELDS (4 fields)
-- =====================================================

INSERT INTO data_entry_fields (field_id, field_name, display_name, description, field_type, data_type, event_type_id, is_active) VALUES
('DEF_SLEEP_BEDTIME', 'bedtime', 'Bedtime', 'When went to bed', 'timestamp', 'datetime', 'sleep_event', true),
('DEF_SLEEP_WAKETIME', 'wake_time', 'Wake Time', 'When woke up', 'timestamp', 'datetime', 'sleep_event', true),
('DEF_SLEEP_QUALITY', 'sleep_quality', 'Sleep Quality', 'Sleep quality rating (1-10)', 'rating', 'integer', 'sleep_event', true),
('DEF_SLEEP_FACTORS', 'sleep_factors', 'Sleep Factors', 'Factors affecting sleep', 'reference', 'uuid[]', 'sleep_event', true)
ON CONFLICT (field_id) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  event_type_id = EXCLUDED.event_type_id,
  is_active = EXCLUDED.is_active,
  updated_at = now();


-- =====================================================
-- MINDFULNESS EVENT FIELDS (5 fields)
-- =====================================================

INSERT INTO data_entry_fields (field_id, field_name, display_name, description, field_type, data_type, event_type_id, is_active) VALUES
('DEF_MINDFULNESS_START', 'mindfulness_start_time', 'Start Time', 'When mindfulness started', 'timestamp', 'datetime', 'mindfulness_event', true),
('DEF_MINDFULNESS_END', 'mindfulness_end_time', 'End Time', 'When mindfulness ended', 'timestamp', 'datetime', 'mindfulness_event', true),
('DEF_MINDFULNESS_TYPE', 'mindfulness_type_id', 'Mindfulness Type', 'Type of mindfulness practice', 'reference', 'uuid', 'mindfulness_event', true),
('DEF_STRESS_LEVEL', 'stress_level', 'Stress Level', 'Current stress level (1-10)', 'rating', 'integer', 'mindfulness_event', true),
('DEF_STRESS_FACTORS', 'stress_factors', 'Stress Factors', 'Sources of stress', 'reference', 'uuid[]', 'mindfulness_event', true)
ON CONFLICT (field_id) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  event_type_id = EXCLUDED.event_type_id,
  is_active = EXCLUDED.is_active,
  updated_at = now();


-- =====================================================
-- MEASUREMENT EVENT FIELDS (4 fields)
-- =====================================================

INSERT INTO data_entry_fields (field_id, field_name, display_name, description, field_type, data_type, event_type_id, is_active) VALUES
('DEF_MEASUREMENT_TYPE', 'measurement_type_id', 'Measurement Type', 'Type of measurement', 'reference', 'uuid', 'measurement_event', true),
('DEF_MEASUREMENT_VALUE', 'measurement_value', 'Value', 'Measurement value', 'quantity', 'numeric', 'measurement_event', true),
('DEF_MEASUREMENT_UNIT', 'measurement_unit_id', 'Unit', 'Unit of measurement', 'reference', 'uuid', 'measurement_event', true),
('DEF_MEASUREMENT_TIME', 'measurement_time', 'Time', 'When measured', 'timestamp', 'datetime', 'measurement_event', true)
ON CONFLICT (field_id) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  event_type_id = EXCLUDED.event_type_id,
  is_active = EXCLUDED.is_active,
  updated_at = now();


-- =====================================================
-- SCREENING EVENT FIELDS (4 fields) - already exist
-- =====================================================
-- DEF_SCREENING_NAME and DEF_SCREENING_DATE already created
-- Just update their event_type_id

UPDATE data_entry_fields
SET event_type_id = 'screening_event'
WHERE field_id IN ('DEF_SCREENING_NAME', 'DEF_SCREENING_DATE');

-- Add new screening fields
INSERT INTO data_entry_fields (field_id, field_name, display_name, description, field_type, data_type, event_type_id, is_active) VALUES
('DEF_SCREENING_TYPE', 'screening_type_id', 'Screening Type', 'Type of screening', 'reference', 'uuid', 'screening_event', true),
('DEF_SCREENING_RESULT', 'screening_result', 'Result', 'Screening result (normal/abnormal/pending)', 'category', 'text', 'screening_event', true)
ON CONFLICT (field_id) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  event_type_id = EXCLUDED.event_type_id,
  is_active = EXCLUDED.is_active,
  updated_at = now();


-- =====================================================
-- SUBSTANCE EVENT FIELDS (4 fields)
-- =====================================================

INSERT INTO data_entry_fields (field_id, field_name, display_name, description, field_type, data_type, event_type_id, is_active) VALUES
('DEF_SUBSTANCE_TYPE', 'substance_type_id', 'Substance Type', 'Type of substance', 'reference', 'uuid', 'substance_event', true),
('DEF_SUBSTANCE_SOURCE', 'substance_source_id', 'Substance Source', 'Specific source (e.g., beer, coffee)', 'reference', 'uuid', 'substance_event', true),
('DEF_SUBSTANCE_QUANTITY', 'substance_quantity', 'Quantity', 'Amount consumed', 'quantity', 'numeric', 'substance_event', true),
('DEF_SUBSTANCE_TIME', 'substance_time', 'Time', 'When consumed', 'timestamp', 'datetime', 'substance_event', true)
ON CONFLICT (field_id) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  event_type_id = EXCLUDED.event_type_id,
  is_active = EXCLUDED.is_active,
  updated_at = now();


-- =====================================================
-- Link Fields to Event Types (if needed)
-- =====================================================
-- The event_types_data_entry_fields junction table will be auto-populated
-- by triggers or can be manually populated here

COMMIT;
