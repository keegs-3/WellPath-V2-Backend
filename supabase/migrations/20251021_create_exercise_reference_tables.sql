-- =====================================================
-- Exercise Reference Tables
-- =====================================================
-- Creates 5 reference tables for exercise domain:
-- 1. cardio_types
-- 2. strength_types
-- 3. flexibility_types
-- 4. muscle_groups
-- 5. exercise_intensity_levels
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- 1. cardio_types
-- =====================================================
CREATE TABLE IF NOT EXISTS cardio_types (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  cardio_name TEXT UNIQUE NOT NULL,
  display_name TEXT NOT NULL,
  description TEXT,

  -- HealthKit integration
  healthkit_identifier TEXT,
  healthkit_mapping_id UUID REFERENCES healthkit_mapping(id) ON DELETE SET NULL,

  -- Metrics
  met_score NUMERIC,  -- Metabolic equivalent of task
  typical_intensity TEXT,  -- 'low', 'moderate', 'high', 'variable'

  -- Tracking preferences
  tracks_distance BOOLEAN DEFAULT false,
  tracks_elevation BOOLEAN DEFAULT false,
  typical_indoor BOOLEAN DEFAULT NULL,  -- NULL = can be either

  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

INSERT INTO cardio_types (cardio_name, display_name, description, healthkit_identifier, met_score, typical_intensity, tracks_distance, tracks_elevation, typical_indoor) VALUES
('running', 'Running', 'Outdoor or treadmill running', 'HKWorkoutActivityTypeRunning', 9.8, 'high', true, true, false),
('walking', 'Walking', 'Casual or brisk walking', 'HKWorkoutActivityTypeWalking', 3.5, 'moderate', true, true, false),
('cycling', 'Cycling', 'Road or stationary bike', 'HKWorkoutActivityTypeCycling', 7.5, 'moderate', true, true, NULL),
('swimming', 'Swimming', 'Lap swimming or water exercise', 'HKWorkoutActivityTypeSwimming', 8.0, 'high', true, false, true),
('rowing', 'Rowing', 'Rowing machine or water rowing', 'HKWorkoutActivityTypeRowing', 8.5, 'high', false, false, NULL),
('elliptical', 'Elliptical', 'Elliptical trainer', 'HKWorkoutActivityTypeElliptical', 7.0, 'moderate', false, false, true),
('stair_climbing', 'Stair Climbing', 'Stair climber or actual stairs', 'HKWorkoutActivityTypeStairClimbing', 8.5, 'high', false, true, NULL),
('hiking', 'Hiking', 'Trail hiking', 'HKWorkoutActivityTypeHiking', 6.0, 'moderate', true, true, false),
('dancing', 'Dancing', 'Dance cardio', 'HKWorkoutActivityTypeCardioDance', 5.5, 'moderate', false, false, NULL),
('jump_rope', 'Jump Rope', 'Skipping rope', 'HKWorkoutActivityTypeJumpRope', 12.0, 'high', false, false, true)
ON CONFLICT (cardio_name) DO NOTHING;

CREATE INDEX IF NOT EXISTS idx_cardio_types_hk_identifier ON cardio_types(healthkit_identifier);
CREATE INDEX IF NOT EXISTS idx_cardio_types_active ON cardio_types(is_active);


-- =====================================================
-- 2. strength_types
-- =====================================================
CREATE TABLE IF NOT EXISTS strength_types (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  strength_name TEXT UNIQUE NOT NULL,
  display_name TEXT NOT NULL,
  description TEXT,

  -- HealthKit integration
  healthkit_identifier TEXT,
  healthkit_mapping_id UUID REFERENCES healthkit_mapping(id) ON DELETE SET NULL,

  -- Metrics
  met_score NUMERIC,
  typical_equipment TEXT,  -- 'free_weights', 'machines', 'bodyweight', 'resistance_bands', 'mixed'

  -- Tracking preferences
  tracks_reps_sets BOOLEAN DEFAULT true,
  tracks_weight BOOLEAN DEFAULT true,

  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

INSERT INTO strength_types (strength_name, display_name, description, healthkit_identifier, met_score, typical_equipment, tracks_reps_sets, tracks_weight) VALUES
('weight_training', 'Weight Training', 'Free weights or machines', 'HKWorkoutActivityTypeTraditionalStrengthTraining', 6.0, 'free_weights', true, true),
('bodyweight', 'Bodyweight Training', 'Push-ups, pull-ups, etc.', 'HKWorkoutActivityTypeFunctionalStrengthTraining', 5.5, 'bodyweight', true, false),
('resistance_bands', 'Resistance Bands', 'Band-based exercises', 'HKWorkoutActivityTypeFunctionalStrengthTraining', 5.0, 'resistance_bands', true, false),
('machines', 'Machine Training', 'Gym machines', 'HKWorkoutActivityTypeTraditionalStrengthTraining', 5.5, 'machines', true, true),
('crossfit', 'CrossFit', 'High-intensity functional training', 'HKWorkoutActivityTypeCrossTraining', 8.0, 'mixed', true, true),
('kettlebell', 'Kettlebell', 'Kettlebell training', 'HKWorkoutActivityTypeFunctionalStrengthTraining', 7.0, 'free_weights', true, true),
('circuit', 'Circuit Training', 'Multiple exercises in sequence', 'HKWorkoutActivityTypeFunctionalStrengthTraining', 7.5, 'mixed', true, true)
ON CONFLICT (strength_name) DO NOTHING;

CREATE INDEX IF NOT EXISTS idx_strength_types_hk_identifier ON strength_types(healthkit_identifier);
CREATE INDEX IF NOT EXISTS idx_strength_types_active ON strength_types(is_active);


-- =====================================================
-- 3. flexibility_types
-- =====================================================
CREATE TABLE IF NOT EXISTS flexibility_types (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  flexibility_name TEXT UNIQUE NOT NULL,
  display_name TEXT NOT NULL,
  description TEXT,

  -- HealthKit integration
  healthkit_identifier TEXT,
  healthkit_mapping_id UUID REFERENCES healthkit_mapping(id) ON DELETE SET NULL,

  -- Metrics
  met_score NUMERIC,
  focus_area TEXT,  -- 'full_body', 'lower_body', 'upper_body', 'core', 'mind_body'

  -- Benefits
  improves_balance BOOLEAN DEFAULT false,
  improves_mobility BOOLEAN DEFAULT true,
  reduces_stress BOOLEAN DEFAULT false,

  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

INSERT INTO flexibility_types (flexibility_name, display_name, description, healthkit_identifier, met_score, focus_area, improves_balance, improves_mobility, reduces_stress) VALUES
('yoga', 'Yoga', 'Yoga practice', 'HKWorkoutActivityTypeYoga', 3.5, 'mind_body', true, true, true),
('stretching', 'Stretching', 'Static or dynamic stretching', 'HKWorkoutActivityTypeFlexibility', 2.5, 'full_body', false, true, false),
('pilates', 'Pilates', 'Pilates exercises', 'HKWorkoutActivityTypePilates', 3.5, 'core', true, true, false),
('foam_rolling', 'Foam Rolling', 'Myofascial release', 'HKWorkoutActivityTypeFlexibility', 2.0, 'full_body', false, true, false),
('tai_chi', 'Tai Chi', 'Tai chi practice', 'HKWorkoutActivityTypeTaiChi', 3.0, 'mind_body', true, true, true),
('mobility_work', 'Mobility Work', 'Joint mobility exercises', 'HKWorkoutActivityTypeFlexibility', 2.5, 'full_body', false, true, false)
ON CONFLICT (flexibility_name) DO NOTHING;

CREATE INDEX IF NOT EXISTS idx_flexibility_types_hk_identifier ON flexibility_types(healthkit_identifier);
CREATE INDEX IF NOT EXISTS idx_flexibility_types_active ON flexibility_types(is_active);


-- =====================================================
-- 4. muscle_groups
-- =====================================================
CREATE TABLE IF NOT EXISTS muscle_groups (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  group_name TEXT UNIQUE NOT NULL,
  display_name TEXT NOT NULL,
  description TEXT,
  body_region TEXT,  -- 'upper', 'lower', 'core'
  display_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

INSERT INTO muscle_groups (group_name, display_name, description, body_region, display_order) VALUES
('chest', 'Chest', 'Pectorals', 'upper', 1),
('back', 'Back', 'Lats, traps, rhomboids', 'upper', 2),
('shoulders', 'Shoulders', 'Deltoids', 'upper', 3),
('arms', 'Arms', 'Biceps, triceps, forearms', 'upper', 4),
('core', 'Core', 'Abs, obliques', 'core', 5),
('glutes', 'Glutes', 'Gluteus muscles', 'lower', 6),
('legs', 'Legs', 'Quads, hamstrings, calves', 'lower', 7),
('full_body', 'Full Body', 'Multiple muscle groups', 'upper', 8)
ON CONFLICT (group_name) DO NOTHING;

CREATE INDEX IF NOT EXISTS idx_muscle_groups_body_region ON muscle_groups(body_region);
CREATE INDEX IF NOT EXISTS idx_muscle_groups_active ON muscle_groups(is_active);


-- =====================================================
-- 5. exercise_intensity_levels
-- =====================================================
CREATE TABLE IF NOT EXISTS exercise_intensity_levels (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  intensity_level INTEGER UNIQUE NOT NULL CHECK (intensity_level BETWEEN 1 AND 10),
  display_name TEXT NOT NULL,
  description TEXT,

  -- RPE (Rate of Perceived Exertion)
  rpe_min INTEGER CHECK (rpe_min BETWEEN 6 AND 20),  -- Borg scale
  rpe_max INTEGER CHECK (rpe_max BETWEEN 6 AND 20),

  -- Heart rate zones
  hr_zone TEXT,  -- 'Z1', 'Z2', 'Z3', 'Z4', 'Z5'
  hr_percent_max_min INTEGER CHECK (hr_percent_max_min BETWEEN 0 AND 100),
  hr_percent_max_max INTEGER CHECK (hr_percent_max_max BETWEEN 0 AND 100),

  color_hex TEXT,  -- For UI visualization

  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

INSERT INTO exercise_intensity_levels (intensity_level, display_name, description, rpe_min, rpe_max, hr_zone, hr_percent_max_min, hr_percent_max_max, color_hex) VALUES
(1, 'Very Light', 'Minimal effort, easy conversation', 6, 8, 'Z1', 50, 60, '#4CAF50'),
(2, 'Light', 'Comfortable, can talk easily', 9, 10, 'Z1', 60, 65, '#8BC34A'),
(3, 'Light-Moderate', 'Slightly challenging', 11, 11, 'Z2', 65, 70, '#CDDC39'),
(4, 'Moderate', 'Somewhat hard, can still talk', 12, 13, 'Z2', 70, 75, '#FFC107'),
(5, 'Moderate-Hard', 'Challenging, conversation difficult', 14, 14, 'Z3', 75, 80, '#FF9800'),
(6, 'Hard', 'Hard effort, short phrases only', 15, 16, 'Z3', 80, 85, '#FF5722'),
(7, 'Very Hard', 'Very hard, minimal talking', 17, 17, 'Z4', 85, 90, '#F44336'),
(8, 'Extremely Hard', 'Extremely difficult', 18, 19, 'Z4', 90, 95, '#E91E63'),
(9, 'Near Maximum', 'Almost maximal effort', 19, 19, 'Z5', 95, 98, '#9C27B0'),
(10, 'Maximum', 'Absolute maximum effort', 20, 20, 'Z5', 98, 100, '#673AB7')
ON CONFLICT (intensity_level) DO NOTHING;

CREATE INDEX IF NOT EXISTS idx_exercise_intensity_levels_active ON exercise_intensity_levels(is_active);

COMMIT;
