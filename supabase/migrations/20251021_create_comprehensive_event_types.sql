-- =====================================================
-- Create Comprehensive Event Types
-- =====================================================
-- One event type per measurement/activity with EVT_ prefix
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Delete existing event types to start fresh
-- =====================================================

DELETE FROM event_types_dependencies;
DELETE FROM event_types WHERE event_type_id NOT IN ('protein_intake', 'vegetable_intake', 'fruit_intake', 'whole_grain_intake', 'fat_intake', 'legume_intake', 'nut_seed_intake', 'fiber_intake');

-- =====================================================
-- PART 2: Create Event Types
-- =====================================================

-- NUTRITION EVENTS
INSERT INTO event_types (event_type_id, name, description, category, is_active) VALUES
('EVT_ADDED_SUGAR', 'Added Sugar Intake', 'Consumption of added sugars', 'nutrition', true),
('EVT_ALCOHOL', 'Alcohol Intake', 'Alcoholic beverage consumption', 'nutrition', true),
('EVT_BEVERAGE', 'Beverage Intake', 'General beverage consumption', 'nutrition', true),
('EVT_CAFFEINE', 'Caffeine Intake', 'Caffeine consumption', 'nutrition', true),
('EVT_CALORIES', 'Calorie Tracking', 'Total calorie consumption', 'nutrition', true),
('EVT_FAT', 'Fat Intake', 'Healthy fat consumption', 'nutrition', true),
('EVT_FIBER', 'Fiber Intake', 'Dietary fiber consumption', 'nutrition', true),
('EVT_FOOD', 'Food Intake', 'General food consumption', 'nutrition', true),
('EVT_FRUIT', 'Fruit Intake', 'Fruit consumption', 'nutrition', true),
('EVT_LEGUME', 'Legume Intake', 'Legume/bean consumption', 'nutrition', true),
('EVT_MEAL', 'Meal', 'Full meal tracking', 'nutrition', true),
('EVT_NUT_SEED', 'Nut & Seed Intake', 'Nut and seed consumption', 'nutrition', true),
('EVT_PROCESSED_MEAT', 'Processed Meat Intake', 'Processed meat consumption', 'nutrition', true),
('EVT_PROTEIN', 'Protein Intake', 'Protein consumption', 'nutrition', true),
('EVT_ULTRA_PROCESSED', 'Ultra-Processed Food', 'Ultra-processed food consumption', 'nutrition', true),
('EVT_UNHEALTHY_BEVERAGE', 'Unhealthy Beverage', 'Unhealthy beverage consumption', 'nutrition', true),
('EVT_VEGETABLE', 'Vegetable Intake', 'Vegetable consumption', 'nutrition', true),
('EVT_WATER', 'Water Intake', 'Water/fluid consumption', 'nutrition', true),
('EVT_WHOLE_GRAIN', 'Whole Grain Intake', 'Whole grain consumption', 'nutrition', true);

-- EXERCISE EVENTS
INSERT INTO event_types (event_type_id, name, description, category, is_active) VALUES
('EVT_CARDIO', 'Cardio Exercise', 'Cardiovascular exercise session', 'exercise', true),
('EVT_HIIT', 'HIIT Session', 'High-intensity interval training', 'exercise', true),
('EVT_STRENGTH', 'Strength Training', 'Strength/resistance training', 'exercise', true),
('EVT_FLEXIBILITY', 'Flexibility Training', 'Flexibility/stretching session', 'exercise', true),
('EVT_MOBILITY', 'Mobility Work', 'Mobility and movement training', 'exercise', true),
('EVT_STEPS', 'Daily Steps', 'Step count tracking', 'exercise', true);

-- BIOMETRIC EVENTS
INSERT INTO event_types (event_type_id, name, description, category, is_active) VALUES
('EVT_AGE', 'Age', 'Patient age', 'biometric', true),
('EVT_GENDER', 'Gender', 'Patient gender', 'biometric', true),
('EVT_WEIGHT', 'Weight Measurement', 'Body weight measurement', 'biometric', true),
('EVT_HEIGHT', 'Height Measurement', 'Height measurement', 'biometric', true),
('EVT_WAIST', 'Waist Measurement', 'Waist circumference measurement', 'biometric', true),
('EVT_HIP', 'Hip Measurement', 'Hip circumference measurement', 'biometric', true),
('EVT_NECK', 'Neck Measurement', 'Neck circumference measurement', 'biometric', true),
('EVT_BMI', 'BMI Measurement', 'Body Mass Index', 'biometric', true),
('EVT_BMR', 'BMR Measurement', 'Basal Metabolic Rate', 'biometric', true),
('EVT_BODY_FAT', 'Body Fat Measurement', 'Body fat percentage', 'biometric', true),
('EVT_LEAN_MASS', 'Lean Body Mass', 'Lean body mass measurement', 'biometric', true),
('EVT_HIP_WAIST_RATIO', 'Hip-Waist Ratio', 'Hip to waist ratio', 'biometric', true),
('EVT_BLOOD_PRESSURE', 'Blood Pressure', 'Blood pressure reading', 'biometric', true);

-- SLEEP EVENTS
INSERT INTO event_types (event_type_id, name, description, category, is_active) VALUES
('EVT_SLEEP', 'Sleep Period', 'Full sleep period tracking', 'sleep', true);

-- BEHAVIORAL/MINDFULNESS EVENTS
INSERT INTO event_types (event_type_id, name, description, category, is_active) VALUES
('EVT_MINDFULNESS', 'Mindfulness Practice', 'Meditation/mindfulness session', 'behavioral', true),
('EVT_BRAIN_TRAINING', 'Brain Training', 'Cognitive training activity', 'behavioral', true),
('EVT_JOURNALING', 'Journaling', 'Reflective journaling session', 'behavioral', true),
('EVT_OUTDOOR', 'Outdoor Time', 'Time spent outdoors', 'behavioral', true),
('EVT_SUNLIGHT', 'Sunlight Exposure', 'Direct sunlight exposure', 'behavioral', true),
('EVT_GRATITUDE', 'Gratitude Practice', 'Gratitude journaling/practice', 'behavioral', true),
('EVT_SOCIAL', 'Social Event', 'Social interaction/event', 'behavioral', true);

-- HEALTH FACTORS
INSERT INTO event_types (event_type_id, name, description, category, is_active) VALUES
('EVT_STRESS', 'Stress Level', 'Stress level tracking', 'health_factor', true),
('EVT_MOOD', 'Mood Rating', 'Mood/emotional state', 'health_factor', true),
('EVT_FOCUS', 'Focus Rating', 'Focus/concentration level', 'health_factor', true),
('EVT_MEMORY', 'Memory Clarity', 'Memory clarity rating', 'health_factor', true);

-- HYGIENE EVENTS
INSERT INTO event_types (event_type_id, name, description, category, is_active) VALUES
('EVT_BRUSHING', 'Teeth Brushing', 'Tooth brushing', 'hygiene', true),
('EVT_FLOSSING', 'Flossing', 'Dental flossing', 'hygiene', true),
('EVT_SKINCARE', 'Skincare Routine', 'Skincare routine step', 'hygiene', true),
('EVT_SUNSCREEN', 'Sunscreen Application', 'Sunscreen application', 'hygiene', true);

-- SUBSTANCE USE
INSERT INTO event_types (event_type_id, name, description, category, is_active) VALUES
('EVT_CIGARETTE', 'Cigarette Use', 'Cigarette smoking', 'substance', true),
('EVT_SUBSTANCE', 'Substance Use', 'General substance use tracking', 'substance', true);

-- SCREENING
INSERT INTO event_types (event_type_id, name, description, category, is_active) VALUES
('EVT_SCREENING', 'Health Screening', 'Medical screening/test', 'screening', true);

-- THERAPEUTIC
INSERT INTO event_types (event_type_id, name, description, category, is_active) VALUES
('EVT_THERAPEUTIC', 'Therapeutic Intake', 'Medication/supplement intake', 'therapeutic', true);

-- OTHER
INSERT INTO event_types (event_type_id, name, description, category, is_active) VALUES
('EVT_SCREEN_TIME', 'Screen Time', 'Screen time tracking', 'behavioral', true),
('EVT_MEASUREMENT', 'Generic Measurement', 'General measurement tracking', 'other', true);

COMMIT;
