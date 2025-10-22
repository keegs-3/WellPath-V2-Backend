-- =====================================================
-- Remaining Reference Tables
-- =====================================================
-- Creates remaining reference tables for:
-- - Sleep (2 tables)
-- - Mindfulness (2 tables)
-- - Measurements (2 tables)
-- - Screenings (1 table)
-- - Substances (2 tables)
-- - Self-care (1 table)
-- - Social (1 table)
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- SLEEP DOMAIN (2 tables)
-- =====================================================

-- sleep_factors
CREATE TABLE IF NOT EXISTS sleep_factors (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  factor_name TEXT UNIQUE NOT NULL,
  display_name TEXT NOT NULL,
  description TEXT,
  impact_type TEXT CHECK (impact_type IN ('positive', 'negative')),
  impact_severity INTEGER CHECK (impact_severity BETWEEN 1 AND 10),  -- 1=mild, 10=severe
  category TEXT,  -- 'environmental', 'behavioral', 'physical', 'mental'
  display_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

INSERT INTO sleep_factors (factor_name, display_name, description, impact_type, impact_severity, category) VALUES
-- Negative factors
('caffeine_late', 'Late Caffeine', 'Caffeine within 6 hours of bed', 'negative', 7, 'behavioral'),
('alcohol', 'Alcohol Consumption', 'Alcohol before bed', 'negative', 6, 'behavioral'),
('heavy_meal', 'Heavy Meal', 'Large meal close to bedtime', 'negative', 5, 'behavioral'),
('stress', 'Stress/Anxiety', 'Mental stress or worry', 'negative', 8, 'mental'),
('screen_time', 'Screen Time', 'Blue light exposure before bed', 'negative', 6, 'behavioral'),
('exercise_late', 'Late Exercise', 'Intense exercise close to bedtime', 'negative', 5, 'physical'),
('temperature_hot', 'Room Too Hot', 'Bedroom temperature too warm', 'negative', 5, 'environmental'),
('noise', 'Noise Disturbance', 'Environmental noise', 'negative', 7, 'environmental'),
('light', 'Light Exposure', 'Room not dark enough', 'negative', 6, 'environmental'),

-- Positive factors
('good_routine', 'Good Sleep Routine', 'Consistent bedtime routine', 'positive', 8, 'behavioral'),
('exercise_earlier', 'Earlier Exercise', 'Exercise earlier in day', 'positive', 6, 'physical'),
('meditation', 'Meditation/Relaxation', 'Relaxation before bed', 'positive', 7, 'behavioral'),
('cool_room', 'Cool Room Temperature', 'Optimal bedroom temperature', 'positive', 6, 'environmental'),
('dark_room', 'Dark Room', 'Blackout curtains or eye mask', 'positive', 7, 'environmental'),
('comfortable_bed', 'Comfortable Bed', 'Good mattress and pillows', 'positive', 8, 'physical')
ON CONFLICT (factor_name) DO NOTHING;

CREATE INDEX IF NOT EXISTS idx_sleep_factors_impact_type ON sleep_factors(impact_type);
CREATE INDEX IF NOT EXISTS idx_sleep_factors_active ON sleep_factors(is_active);


-- sleep_period_types (links to HKCategoryType)
CREATE TABLE IF NOT EXISTS sleep_period_types (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  period_name TEXT UNIQUE NOT NULL,
  display_name TEXT NOT NULL,
  description TEXT,

  -- HealthKit integration
  healthkit_identifier TEXT,
  healthkit_mapping_id UUID REFERENCES healthkit_mapping(id) ON DELETE SET NULL,
  hk_category_value INTEGER,  -- HKCategoryValueSleepAnalysis enum value

  -- Properties
  is_restorative BOOLEAN DEFAULT false,
  is_light_sleep BOOLEAN DEFAULT false,
  color_hex TEXT,

  display_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

INSERT INTO sleep_period_types (period_name, display_name, description, healthkit_identifier, hk_category_value, is_restorative, is_light_sleep, color_hex, display_order) VALUES
('in_bed', 'In Bed', 'Time in bed (not necessarily asleep)', 'HKCategoryValueSleepAnalysisInBed', 0, false, false, '#E0E0E0', 1),
('awake', 'Awake', 'Awake during sleep period', 'HKCategoryValueSleepAnalysisAwake', 1, false, false, '#FFC107', 2),
('core', 'Core Sleep', 'Light sleep (N1/N2)', 'HKCategoryValueSleepAnalysisAsleepCore', 3, true, true, '#81C784', 3),
('deep', 'Deep Sleep', 'Deep sleep (N3)', 'HKCategoryValueSleepAnalysisAsleepDeep', 4, true, false, '#1976D2', 4),
('rem', 'REM Sleep', 'Rapid eye movement sleep', 'HKCategoryValueSleepAnalysisAsleepREM', 5, true, false, '#9C27B0', 5),
('unspecified', 'Asleep (Unspecified)', 'General sleep (stage unknown)', 'HKCategoryValueSleepAnalysisAsleepUnspecified', 6, true, false, '#66BB6A', 6)
ON CONFLICT (period_name) DO NOTHING;

CREATE INDEX IF NOT EXISTS idx_sleep_period_types_hk_identifier ON sleep_period_types(healthkit_identifier);
CREATE INDEX IF NOT EXISTS idx_sleep_period_types_active ON sleep_period_types(is_active);


-- =====================================================
-- MINDFULNESS DOMAIN (2 tables)
-- =====================================================

-- mindfulness_types
CREATE TABLE IF NOT EXISTS mindfulness_types (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mindfulness_name TEXT UNIQUE NOT NULL,
  display_name TEXT NOT NULL,
  description TEXT,

  -- HealthKit integration
  healthkit_identifier TEXT,
  healthkit_mapping_id UUID REFERENCES healthkit_mapping(id) ON DELETE SET NULL,

  -- Properties
  typical_duration_minutes INTEGER,
  difficulty_level TEXT CHECK (difficulty_level IN ('beginner', 'intermediate', 'advanced')),
  benefits TEXT[],  -- Array of benefits

  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

INSERT INTO mindfulness_types (mindfulness_name, display_name, description, healthkit_identifier, typical_duration_minutes, difficulty_level, benefits) VALUES
('meditation', 'Meditation', 'Seated meditation practice', 'HKCategoryTypeIdentifierMindfulSession', 15, 'beginner', ARRAY['reduces stress', 'improves focus', 'emotional regulation']),
('breathing', 'Breathwork', 'Focused breathing exercises', 'HKCategoryTypeIdentifierMindfulSession', 5, 'beginner', ARRAY['reduces anxiety', 'calms nervous system', 'improves energy']),
('journaling', 'Journaling', 'Reflective writing', NULL, 10, 'beginner', ARRAY['self-awareness', 'emotional processing', 'goal clarity']),
('gratitude', 'Gratitude Practice', 'Gratitude reflection', NULL, 5, 'beginner', ARRAY['positive mood', 'life satisfaction', 'reduces depression']),
('body_scan', 'Body Scan', 'Progressive body awareness', 'HKCategoryTypeIdentifierMindfulSession', 20, 'intermediate', ARRAY['body awareness', 'tension release', 'relaxation']),
('visualization', 'Visualization', 'Guided imagery', NULL, 10, 'intermediate', ARRAY['goal achievement', 'stress reduction', 'performance enhancement'])
ON CONFLICT (mindfulness_name) DO NOTHING;

CREATE INDEX IF NOT EXISTS idx_mindfulness_types_hk_identifier ON mindfulness_types(healthkit_identifier);
CREATE INDEX IF NOT EXISTS idx_mindfulness_types_active ON mindfulness_types(is_active);


-- stress_factors
CREATE TABLE IF NOT EXISTS stress_factors (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  factor_name TEXT UNIQUE NOT NULL,
  display_name TEXT NOT NULL,
  description TEXT,
  category TEXT,  -- 'work', 'relationships', 'financial', 'health', 'family', 'other'
  is_chronic BOOLEAN DEFAULT false,  -- Ongoing vs acute stressor
  display_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

INSERT INTO stress_factors (factor_name, display_name, description, category, is_chronic) VALUES
('work_deadlines', 'Work Deadlines', 'Work pressure and deadlines', 'work', false),
('work_conflict', 'Work Conflict', 'Workplace conflicts or politics', 'work', true),
('relationship_conflict', 'Relationship Conflict', 'Partner or family conflict', 'relationships', false),
('financial_worry', 'Financial Worry', 'Money concerns', 'financial', true),
('health_concern', 'Health Concern', 'Personal or family health issues', 'health', true),
('family_responsibility', 'Family Responsibility', 'Caregiving or family duties', 'family', true),
('life_change', 'Major Life Change', 'Moving, job change, etc.', 'other', false),
('social_isolation', 'Social Isolation', 'Loneliness or lack of support', 'relationships', true)
ON CONFLICT (factor_name) DO NOTHING;

CREATE INDEX IF NOT EXISTS idx_stress_factors_category ON stress_factors(category);
CREATE INDEX IF NOT EXISTS idx_stress_factors_active ON stress_factors(is_active);


-- =====================================================
-- MEASUREMENTS DOMAIN (2 tables)
-- =====================================================

-- measurement_types
CREATE TABLE IF NOT EXISTS measurement_types (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  measurement_name TEXT UNIQUE NOT NULL,
  display_name TEXT NOT NULL,
  description TEXT,

  -- HealthKit integration
  healthkit_identifier TEXT,
  healthkit_mapping_id UUID REFERENCES healthkit_mapping(id) ON DELETE SET NULL,

  -- Properties
  category TEXT,  -- 'body_composition', 'cardiovascular', 'metabolic', 'fitness'
  default_unit TEXT,

  -- Healthy ranges (general guidelines)
  healthy_range_min NUMERIC,
  healthy_range_max NUMERIC,
  optimal_range_min NUMERIC,
  optimal_range_max NUMERIC,

  -- Tracking recommendations
  recommended_frequency_days INTEGER,  -- How often to measure

  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

INSERT INTO measurement_types (measurement_name, display_name, description, healthkit_identifier, category, default_unit, healthy_range_min, healthy_range_max, optimal_range_min, optimal_range_max, recommended_frequency_days) VALUES
-- Body Composition
('weight', 'Weight', 'Body weight', 'HKQuantityTypeIdentifierBodyMass', 'body_composition', 'kg', NULL, NULL, NULL, NULL, 7),
('body_fat', 'Body Fat %', 'Body fat percentage', 'HKQuantityTypeIdentifierBodyFatPercentage', 'body_composition', '%', 10, 25, 12, 20, 30),
('lean_mass', 'Lean Body Mass', 'Lean body mass', 'HKQuantityTypeIdentifierLeanBodyMass', 'body_composition', 'kg', NULL, NULL, NULL, NULL, 30),
('bmi', 'BMI', 'Body mass index', 'HKQuantityTypeIdentifierBodyMassIndex', 'body_composition', 'count', 18.5, 24.9, 20, 23, 30),
('waist', 'Waist Circumference', 'Waist measurement', 'HKQuantityTypeIdentifierWaistCircumference', 'body_composition', 'cm', NULL, 102, NULL, 94, 90),

-- Cardiovascular
('resting_hr', 'Resting Heart Rate', 'Heart rate at rest', 'HKQuantityTypeIdentifierRestingHeartRate', 'cardiovascular', 'bpm', 60, 100, 55, 75, 7),
('hrv', 'HRV (SDNN)', 'Heart rate variability', 'HKQuantityTypeIdentifierHeartRateVariabilitySDNN', 'cardiovascular', 'ms', 20, 200, 50, 100, 1),
('bp_systolic', 'Systolic BP', 'Systolic blood pressure', 'HKQuantityTypeIdentifierBloodPressureSystolic', 'cardiovascular', 'mmHg', 90, 120, 100, 115, 7),
('bp_diastolic', 'Diastolic BP', 'Diastolic blood pressure', 'HKQuantityTypeIdentifierBloodPressureDiastolic', 'cardiovascular', 'mmHg', 60, 80, 65, 75, 7),
('vo2_max', 'VO2 Max', 'Maximal oxygen uptake', 'HKQuantityTypeIdentifierVO2Max', 'fitness', 'mL/kg/min', 30, 60, 40, 55, 90)
ON CONFLICT (measurement_name) DO NOTHING;

CREATE INDEX IF NOT EXISTS idx_measurement_types_category ON measurement_types(category);
CREATE INDEX IF NOT EXISTS idx_measurement_types_hk_identifier ON measurement_types(healthkit_identifier);
CREATE INDEX IF NOT EXISTS idx_measurement_types_active ON measurement_types(is_active);


-- measurement_unit_options
CREATE TABLE IF NOT EXISTS measurement_unit_options (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  measurement_type_id UUID REFERENCES measurement_types(id) ON DELETE CASCADE,
  unit_name TEXT NOT NULL,
  display_name TEXT NOT NULL,
  conversion_factor NUMERIC,  -- Multiply by this to convert to default unit
  is_default BOOLEAN DEFAULT false,
  display_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),

  UNIQUE(measurement_type_id, unit_name)
);

-- Seed unit options
INSERT INTO measurement_unit_options (measurement_type_id, unit_name, display_name, conversion_factor, is_default) VALUES
-- Weight
((SELECT id FROM measurement_types WHERE measurement_name = 'weight'), 'kg', 'kilograms', 1, true),
((SELECT id FROM measurement_types WHERE measurement_name = 'weight'), 'lbs', 'pounds', 0.453592, false),

-- Body Fat %
((SELECT id FROM measurement_types WHERE measurement_name = 'body_fat'), '%', 'percent', 1, true),

-- HRV
((SELECT id FROM measurement_types WHERE measurement_name = 'hrv'), 'ms', 'milliseconds', 1, true)
ON CONFLICT (measurement_type_id, unit_name) DO NOTHING;

CREATE INDEX IF NOT EXISTS idx_measurement_unit_options_measurement_type ON measurement_unit_options(measurement_type_id);

CREATE UNIQUE INDEX IF NOT EXISTS idx_measurement_unit_options_default
  ON measurement_unit_options(measurement_type_id)
  WHERE is_default = true;


-- =====================================================
-- SCREENINGS DOMAIN (1 table - types already exist)
-- =====================================================
-- screening_types table already created in previous migrations
-- Just ensure it exists

CREATE TABLE IF NOT EXISTS screening_types (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  screening_name TEXT UNIQUE NOT NULL,
  display_name TEXT NOT NULL,
  description TEXT,

  -- Recommendations
  recommended_frequency_months INTEGER,
  age_start INTEGER,
  age_end INTEGER,
  gender_specific TEXT CHECK (gender_specific IN ('male', 'female', 'all')),

  -- Medical codes
  cpt_codes TEXT[],  -- CPT billing codes

  -- Risk factors
  risk_factors TEXT[],

  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

INSERT INTO screening_types (screening_name, display_name, description, recommended_frequency_months, age_start, gender_specific, cpt_codes) VALUES
('colonoscopy', 'Colonoscopy', 'Colon cancer screening', 120, 45, 'all', ARRAY['45378']),
('mammogram', 'Mammogram', 'Breast cancer screening', 24, 40, 'female', ARRAY['77067']),
('psa', 'PSA Test', 'Prostate cancer screening', 12, 50, 'male', ARRAY['84153']),
('physical', 'Annual Physical', 'Comprehensive health exam', 12, 18, 'all', ARRAY['99395']),
('dental', 'Dental Exam', 'Dental checkup and cleaning', 6, 0, 'all', ARRAY['D0120']),
('vision', 'Vision Exam', 'Eye examination', 24, 0, 'all', ARRAY['92004']),
('skin_check', 'Skin Cancer Screening', 'Dermatological exam', 12, 30, 'all', ARRAY['96160'])
ON CONFLICT (screening_name) DO NOTHING;

CREATE INDEX IF NOT EXISTS idx_screening_types_gender ON screening_types(gender_specific);
CREATE INDEX IF NOT EXISTS idx_screening_types_active ON screening_types(is_active);


-- =====================================================
-- SUBSTANCES DOMAIN (2 tables)
-- =====================================================

-- substance_types
CREATE TABLE IF NOT EXISTS substance_types (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  substance_name TEXT UNIQUE NOT NULL,
  display_name TEXT NOT NULL,
  description TEXT,

  category TEXT,  -- 'alcohol', 'tobacco', 'cannabis', 'caffeine'
  unit_name TEXT,  -- 'drinks', 'cigarettes', 'mg', 'grams'

  -- Health guidelines
  daily_limit NUMERIC,
  weekly_limit NUMERIC,
  is_recommended_zero BOOLEAN DEFAULT false,

  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

INSERT INTO substance_types (substance_name, display_name, description, category, unit_name, daily_limit, weekly_limit, is_recommended_zero) VALUES
('cigarettes', 'Cigarettes', 'Tobacco cigarettes', 'tobacco', 'cigarettes', 0, 0, true),
('alcohol', 'Alcohol', 'Alcoholic beverages', 'alcohol', 'drinks', 2, 14, false),
('cannabis', 'Cannabis', 'Marijuana/THC products', 'cannabis', 'grams', NULL, NULL, false),
('caffeine', 'Caffeine', 'Caffeine consumption', 'caffeine', 'mg', 400, NULL, false)
ON CONFLICT (substance_name) DO NOTHING;

CREATE INDEX IF NOT EXISTS idx_substance_types_category ON substance_types(category);
CREATE INDEX IF NOT EXISTS idx_substance_types_active ON substance_types(is_active);


-- substance_sources
CREATE TABLE IF NOT EXISTS substance_sources (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  substance_type_id UUID REFERENCES substance_types(id) ON DELETE CASCADE,
  source_name TEXT NOT NULL,
  display_name TEXT NOT NULL,
  description TEXT,

  -- Content per serving
  content_per_serving NUMERIC,  -- mg caffeine, g alcohol, etc.
  serving_size NUMERIC,
  serving_unit TEXT,

  UNIQUE(substance_type_id, source_name),

  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

INSERT INTO substance_sources (substance_type_id, source_name, display_name, description, content_per_serving, serving_size, serving_unit) VALUES
-- Alcohol
((SELECT id FROM substance_types WHERE substance_name = 'alcohol'), 'beer', 'Beer', '12 oz beer', 14, 355, 'ml'),
((SELECT id FROM substance_types WHERE substance_name = 'alcohol'), 'wine', 'Wine', '5 oz wine', 14, 148, 'ml'),
((SELECT id FROM substance_types WHERE substance_name = 'alcohol'), 'spirits', 'Spirits/Liquor', '1.5 oz spirits', 14, 44, 'ml'),

-- Caffeine
((SELECT id FROM substance_types WHERE substance_name = 'caffeine'), 'coffee', 'Coffee', '8 oz brewed coffee', 95, 240, 'ml'),
((SELECT id FROM substance_types WHERE substance_name = 'caffeine'), 'espresso', 'Espresso', 'Single shot', 63, 30, 'ml'),
((SELECT id FROM substance_types WHERE substance_name = 'caffeine'), 'green_tea', 'Green Tea', '8 oz green tea', 28, 240, 'ml'),
((SELECT id FROM substance_types WHERE substance_name = 'caffeine'), 'black_tea', 'Black Tea', '8 oz black tea', 47, 240, 'ml'),
((SELECT id FROM substance_types WHERE substance_name = 'caffeine'), 'energy_drink', 'Energy Drink', '8 oz energy drink', 80, 240, 'ml')
ON CONFLICT (substance_type_id, source_name) DO NOTHING;

CREATE INDEX IF NOT EXISTS idx_substance_sources_substance_type ON substance_sources(substance_type_id);
CREATE INDEX IF NOT EXISTS idx_substance_sources_active ON substance_sources(is_active);


-- =====================================================
-- SELF-CARE DOMAIN (1 table)
-- =====================================================

CREATE TABLE IF NOT EXISTS selfcare_types (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  selfcare_name TEXT UNIQUE NOT NULL,
  display_name TEXT NOT NULL,
  description TEXT,

  -- HealthKit integration (e.g., toothbrushing)
  healthkit_identifier TEXT,
  healthkit_mapping_id UUID REFERENCES healthkit_mapping(id) ON DELETE SET NULL,

  -- Recommendations
  recommended_frequency_per_day NUMERIC,
  recommended_duration_minutes INTEGER,

  category TEXT,  -- 'dental', 'skin', 'hygiene'

  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

INSERT INTO selfcare_types (selfcare_name, display_name, description, healthkit_identifier, recommended_frequency_per_day, recommended_duration_minutes, category) VALUES
('brushing', 'Tooth Brushing', 'Brush teeth', 'HKCategoryTypeIdentifierToothbrushingEvent', 2, 2, 'dental'),
('flossing', 'Flossing', 'Floss teeth', NULL, 1, 2, 'dental'),
('skincare_morning', 'Morning Skincare', 'Morning skincare routine', NULL, 1, 5, 'skin'),
('skincare_evening', 'Evening Skincare', 'Evening skincare routine', NULL, 1, 5, 'skin'),
('sunscreen', 'Sunscreen Application', 'Apply sunscreen', NULL, 1, 2, 'skin'),
('handwashing', 'Handwashing', 'Wash hands', 'HKCategoryTypeIdentifierHandwashingEvent', 6, 1, 'hygiene')
ON CONFLICT (selfcare_name) DO NOTHING;

CREATE INDEX IF NOT EXISTS idx_selfcare_types_category ON selfcare_types(category);
CREATE INDEX IF NOT EXISTS idx_selfcare_types_hk_identifier ON selfcare_types(healthkit_identifier);
CREATE INDEX IF NOT EXISTS idx_selfcare_types_active ON selfcare_types(is_active);


-- =====================================================
-- SOCIAL DOMAIN (1 table)
-- =====================================================

CREATE TABLE IF NOT EXISTS social_activity_types (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  activity_name TEXT UNIQUE NOT NULL,
  display_name TEXT NOT NULL,
  description TEXT,

  -- Connection quality (1-10 scale, 10=best)
  connection_quality_score INTEGER CHECK (connection_quality_score BETWEEN 1 AND 10),

  category TEXT,  -- 'in_person', 'digital', 'group', 'one_on_one'
  is_face_to_face BOOLEAN DEFAULT false,

  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

INSERT INTO social_activity_types (activity_name, display_name, description, connection_quality_score, category, is_face_to_face) VALUES
('in_person_oneonone', 'In-Person (1-on-1)', 'Face-to-face conversation', 10, 'in_person', true),
('in_person_group', 'In-Person (Group)', 'Group gathering', 9, 'in_person', true),
('video_call', 'Video Call', 'Video chat', 7, 'digital', false),
('phone_call', 'Phone Call', 'Voice call', 6, 'digital', false),
('text_message', 'Text/Message', 'Text messaging', 4, 'digital', false),
('social_media', 'Social Media', 'Social media interaction', 3, 'digital', false)
ON CONFLICT (activity_name) DO NOTHING;

CREATE INDEX IF NOT EXISTS idx_social_activity_types_category ON social_activity_types(category);
CREATE INDEX IF NOT EXISTS idx_social_activity_types_active ON social_activity_types(is_active);

COMMIT;
