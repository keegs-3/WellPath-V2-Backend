-- =====================================================
-- Create Display Screens Architecture
-- =====================================================
-- New hierarchy:
--   pillars_base → display_screens → display_metrics → aggregations
--
-- display_screens = entry point groupings (Protein, Fiber, Sleep, etc.)
-- display_metrics = individual metrics within a screen
-- Swift handles ALL presentation logic
-- =====================================================

BEGIN;

-- =====================================================
-- STEP 1: Create display_screens table
-- =====================================================

CREATE TABLE display_screens (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  screen_id text UNIQUE NOT NULL,
  screen_name text NOT NULL,
  description text,

  -- Categorization
  pillar text REFERENCES pillars_base(pillar_name) ON UPDATE CASCADE ON DELETE CASCADE,
  category text,  -- e.g., "nutrition", "sleep", "exercise", "health_tracking"

  -- Display
  icon text,
  color text,
  display_order integer,
  is_active boolean DEFAULT true,

  -- Metadata
  created_at timestamptz DEFAULT NOW(),
  updated_at timestamptz DEFAULT NOW()
);

CREATE INDEX idx_display_screens_pillar ON display_screens(pillar);
CREATE INDEX idx_display_screens_category ON display_screens(category);
CREATE INDEX idx_display_screens_active ON display_screens(is_active) WHERE is_active = true;

COMMENT ON TABLE display_screens IS
'Entry point groupings for related metrics. Each screen represents a Swift view that displays one or more metrics.';

-- =====================================================
-- STEP 2: Update display_metrics to reference screen
-- =====================================================

-- Add screen_id column
ALTER TABLE display_metrics
ADD COLUMN screen_id text REFERENCES display_screens(screen_id) ON DELETE CASCADE;

CREATE INDEX idx_display_metrics_screen ON display_metrics(screen_id);

COMMENT ON COLUMN display_metrics.screen_id IS
'The display screen this metric belongs to. Multiple metrics can share a screen.';

-- =====================================================
-- STEP 3: Remove presentation fields from display_metrics
-- =====================================================
-- Swift handles all presentation, so remove chart config

ALTER TABLE display_metrics
DROP COLUMN IF EXISTS chart_type_id,
DROP COLUMN IF EXISTS chart_config,
DROP COLUMN IF EXISTS supported_units,
DROP COLUMN IF EXISTS default_unit,
DROP COLUMN IF EXISTS display_order,
DROP COLUMN IF EXISTS is_featured,
DROP COLUMN IF EXISTS icon,
DROP COLUMN IF EXISTS color;

COMMENT ON TABLE display_metrics IS
'Individual metrics that display data. Multiple metrics can belong to one screen. All presentation logic is handled in Swift.';

-- =====================================================
-- STEP 4: Populate display_screens from existing metrics
-- =====================================================

-- Nutrition screens
INSERT INTO display_screens (screen_id, screen_name, description, pillar, category, display_order) VALUES
  ('SCREEN_PROTEIN', 'Protein', 'Protein intake and timing', 'Healthful Nutrition', 'nutrition', 1),
  ('SCREEN_FIBER', 'Fiber', 'Fiber intake and sources', 'Healthful Nutrition', 'nutrition', 2),
  ('SCREEN_VEGETABLES', 'Vegetables', 'Vegetable servings and variety', 'Healthful Nutrition', 'nutrition', 3),
  ('SCREEN_FRUITS', 'Fruits', 'Fruit servings and variety', 'Healthful Nutrition', 'nutrition', 4),
  ('SCREEN_WHOLE_GRAINS', 'Whole Grains', 'Whole grain servings and variety', 'Healthful Nutrition', 'nutrition', 5),
  ('SCREEN_LEGUMES', 'Legumes', 'Legume servings and timing', 'Healthful Nutrition', 'nutrition', 6),
  ('SCREEN_WATER', 'Water', 'Hydration tracking', 'Healthful Nutrition', 'nutrition', 7),
  ('SCREEN_HEALTHY_FATS', 'Healthy Fats', 'Fat sources and swaps', 'Healthful Nutrition', 'nutrition', 8),
  ('SCREEN_ADDED_SUGAR', 'Added Sugar', 'Sugar intake tracking', 'Healthful Nutrition', 'nutrition', 9),
  ('SCREEN_MEAL_TIMING', 'Meal Timing', 'When you eat throughout the day', 'Healthful Nutrition', 'nutrition', 10);

-- Exercise screens
INSERT INTO display_screens (screen_id, screen_name, description, pillar, category, display_order) VALUES
  ('SCREEN_STEPS', 'Steps', 'Daily step tracking', 'Movement + Exercise', 'activity', 1),
  ('SCREEN_CARDIO', 'Cardio', 'Cardiovascular exercise', 'Movement + Exercise', 'activity', 2),
  ('SCREEN_STRENGTH', 'Strength Training', 'Resistance and strength workouts', 'Movement + Exercise', 'activity', 3),
  ('SCREEN_HIIT', 'HIIT', 'High intensity interval training', 'Movement + Exercise', 'activity', 4),
  ('SCREEN_MOBILITY', 'Mobility', 'Flexibility and mobility work', 'Movement + Exercise', 'activity', 5),
  ('SCREEN_ACTIVE_TIME', 'Active Time', 'Total activity duration', 'Movement + Exercise', 'activity', 6);

-- Sleep screens
INSERT INTO display_screens (screen_id, screen_name, description, pillar, category, display_order) VALUES
  ('SCREEN_SLEEP_ANALYSIS', 'Sleep Analysis', 'Sleep stages and quality', 'Restorative Sleep', 'sleep', 1),
  ('SCREEN_SLEEP_CONSISTENCY', 'Sleep Consistency', 'Sleep schedule regularity', 'Restorative Sleep', 'sleep', 2),
  ('SCREEN_SLEEP_DURATION', 'Sleep Duration', 'Total sleep time', 'Restorative Sleep', 'sleep', 3);

-- Core Care screens
INSERT INTO display_screens (screen_id, screen_name, description, pillar, category, display_order) VALUES
  ('SCREEN_VITALS', 'Vitals', 'Blood pressure, heart rate, weight', 'Core Care', 'health_tracking', 1),
  ('SCREEN_BODY_METRICS', 'Body Metrics', 'BMI, body fat, measurements', 'Core Care', 'health_tracking', 2),
  ('SCREEN_PREVENTIVE_CARE', 'Preventive Care', 'Screening and checkup compliance', 'Core Care', 'health_tracking', 3),
  ('SCREEN_MEDICATIONS', 'Medications', 'Medication and supplement adherence', 'Core Care', 'health_tracking', 4),
  ('SCREEN_SKINCARE', 'Skincare', 'Sunscreen and skincare routine', 'Core Care', 'health_tracking', 5),
  ('SCREEN_ORAL_HEALTH', 'Oral Health', 'Dental care tracking', 'Core Care', 'health_tracking', 6),
  ('SCREEN_SUBSTANCE_USE', 'Substance Use', 'Alcohol and smoking tracking', 'Core Care', 'health_tracking', 7);

-- Cognitive Health screens
INSERT INTO display_screens (screen_id, screen_name, description, pillar, category, display_order) VALUES
  ('SCREEN_BRAIN_TRAINING', 'Brain Training', 'Cognitive exercises and training', 'Cognitive Health', 'mental_wellness', 1),
  ('SCREEN_COGNITIVE_METRICS', 'Cognitive Metrics', 'Focus, memory, and mood tracking', 'Cognitive Health', 'mental_wellness', 2),
  ('SCREEN_LIGHT_EXPOSURE', 'Light Exposure', 'Sunlight and morning light', 'Cognitive Health', 'mental_wellness', 3),
  ('SCREEN_JOURNALING', 'Journaling', 'Journaling sessions', 'Cognitive Health', 'mental_wellness', 4);

-- Connection + Purpose screens
INSERT INTO display_screens (screen_id, screen_name, description, pillar, category, display_order) VALUES
  ('SCREEN_SOCIAL', 'Social Connection', 'Social interactions and relationships', 'Connection + Purpose', 'mental_wellness', 1),
  ('SCREEN_MINDFULNESS', 'Mindfulness', 'Mindfulness and meditation', 'Connection + Purpose', 'mental_wellness', 2),
  ('SCREEN_OUTDOOR_TIME', 'Outdoor Time', 'Time spent outdoors', 'Connection + Purpose', 'mental_wellness', 3),
  ('SCREEN_GRATITUDE', 'Gratitude', 'Gratitude practice', 'Connection + Purpose', 'mental_wellness', 4),
  ('SCREEN_SCREEN_TIME', 'Screen Time', 'Digital device usage', 'Connection + Purpose', 'mental_wellness', 5);

-- Stress Management screens
INSERT INTO display_screens (screen_id, screen_name, description, pillar, category, display_order) VALUES
  ('SCREEN_MEDITATION', 'Meditation', 'Meditation practice', 'Stress Management', 'mental_wellness', 1),
  ('SCREEN_BREATHWORK', 'Breathwork', 'Breathing exercises', 'Stress Management', 'mental_wellness', 2),
  ('SCREEN_STRESS_TRACKING', 'Stress Tracking', 'Stress levels and management', 'Stress Management', 'mental_wellness', 3);

-- =====================================================
-- STEP 5: Link existing display_metrics to screens
-- =====================================================

-- Map existing metrics to their screens
UPDATE display_metrics SET screen_id = 'SCREEN_PROTEIN' WHERE metric_id LIKE '%PROTEIN%';
UPDATE display_metrics SET screen_id = 'SCREEN_FIBER' WHERE metric_id LIKE '%FIBER%';
UPDATE display_metrics SET screen_id = 'SCREEN_WATER' WHERE metric_id LIKE '%WATER%';
UPDATE display_metrics SET screen_id = 'SCREEN_STEPS' WHERE metric_id LIKE '%STEP%';
UPDATE display_metrics SET screen_id = 'SCREEN_CARDIO' WHERE metric_id LIKE '%CARDIO%' OR metric_id LIKE '%ZONE_2%';
UPDATE display_metrics SET screen_id = 'SCREEN_STRENGTH' WHERE metric_id LIKE '%STRENGTH%';
UPDATE display_metrics SET screen_id = 'SCREEN_SLEEP_ANALYSIS' WHERE metric_id = 'DISP_SLEEP_ANALYSIS';
UPDATE display_metrics SET screen_id = 'SCREEN_SLEEP_CONSISTENCY' WHERE metric_id LIKE '%SLEEP_CONSISTENCY%';
UPDATE display_metrics SET screen_id = 'SCREEN_SLEEP_DURATION' WHERE metric_id LIKE '%SLEEP_DURATION%';

-- =====================================================
-- VERIFICATION
-- =====================================================

DO $$
DECLARE
  screens_count INT;
  metrics_count INT;
  unlinked_count INT;
BEGIN
  SELECT COUNT(*) INTO screens_count FROM display_screens;
  SELECT COUNT(*) INTO metrics_count FROM display_metrics;
  SELECT COUNT(*) INTO unlinked_count FROM display_metrics WHERE screen_id IS NULL;

  RAISE NOTICE '✅ Display Screens Architecture Created';
  RAISE NOTICE '';
  RAISE NOTICE 'Structure:';
  RAISE NOTICE '  display_screens: % screens', screens_count;
  RAISE NOTICE '  display_metrics: % metrics', metrics_count;
  RAISE NOTICE '  Unlinked metrics: %', unlinked_count;
  RAISE NOTICE '';
  RAISE NOTICE 'Hierarchy:';
  RAISE NOTICE '  pillars_base → display_screens → display_metrics → aggregations';
END $$;

-- Show screens with metric counts
SELECT
  ds.screen_name,
  ds.pillar,
  ds.category,
  COUNT(dm.metric_id) as metric_count
FROM display_screens ds
LEFT JOIN display_metrics dm ON dm.screen_id = ds.screen_id
GROUP BY ds.screen_id, ds.screen_name, ds.pillar, ds.category
ORDER BY ds.pillar, ds.display_order
LIMIT 20;

COMMIT;
