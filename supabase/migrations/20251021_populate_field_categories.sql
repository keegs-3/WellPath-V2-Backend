-- =====================================================
-- Populate Category Assignments for All Data Entry Fields
-- =====================================================
-- Maps all 136 active DEF_* fields to their display categories
-- Also sets related_pillars for cross-pillar relationships
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- HEALTHFUL NUTRITION - Meals
-- =====================================================

UPDATE data_entry_fields SET category_id = 'nutrition_meals'
WHERE field_id IN (
  'DEF_MEAL_TYPE',
  'DEF_MEAL_TIME',
  'DEF_MEAL_SIZE',
  'DEF_MEAL_QUALIFIERS',
  'DEF_FOOD_TYPE',
  'DEF_FOOD_QUANTITY'
);


-- =====================================================
-- HEALTHFUL NUTRITION - Healthy Additions
-- =====================================================

UPDATE data_entry_fields SET category_id = 'nutrition_healthy_additions'
WHERE field_id IN (
  -- Fiber
  'DEF_FIBER_QUANTITY',
  'DEF_FIBER_SOURCE',
  'DEF_FIBER_TIME',

  -- Fruits
  'DEF_FRUIT_QUANTITY',
  'DEF_FRUIT_TYPE',
  'DEF_FRUIT_TIME',

  -- Legumes
  'DEF_LEGUME_QUANTITY',
  'DEF_LEGUME_TYPE',
  'DEF_LEGUME_TIME',

  -- Nuts/Seeds
  'DEF_NUT_SEED_QUANTITY',
  'DEF_NUT_SEED_TYPE',
  'DEF_NUT_SEED_TIME',

  -- Protein
  'DEF_PROTEIN_QUANTITY',
  'DEF_PROTEIN_TYPE',
  'DEF_PROTEIN_TIME',

  -- Vegetables
  'DEF_VEGETABLE_QUANTITY',
  'DEF_VEGETABLE_TYPE',
  'DEF_VEGETABLE_TIME',

  -- Whole Grains
  'DEF_WHOLE_GRAIN_QUANTITY',
  'DEF_WHOLE_GRAIN_TYPE',
  'DEF_WHOLE_GRAIN_TIME',

  -- Healthy Fats
  'DEF_FAT_QUANTITY',
  'DEF_FAT_TYPE',
  'DEF_FAT_TIME',

  -- Water
  'DEF_WATER_QUANTITY',
  'DEF_WATER_UNITS',
  'DEF_WATER_TIME'
);


-- =====================================================
-- HEALTHFUL NUTRITION - Mindful Reductions
-- =====================================================

UPDATE data_entry_fields SET category_id = 'nutrition_mindful_reductions'
WHERE field_id IN (
  -- Added Sugar
  'DEF_ADDED_SUGAR_QUANTITY',
  'DEF_ADDED_SUGAR_TYPE',
  'DEF_ADDED_SUGAR_TIME',

  -- Alcohol
  'DEF_ALCOHOL_QUANTITY',
  'DEF_ALCOHOL_TIME',

  -- Caffeine
  'DEF_CAFFEINE_QUANTITY',
  'DEF_CAFFEINE_TYPE',
  'DEF_CAFFEINE_TIME',

  -- Processed Meat
  'DEF_PROCESSED_MEAT_QUANTITY',
  'DEF_PROCESSED_MEAT_TYPE',
  'DEF_PROCESSED_MEAT_TIME',

  -- Ultra-Processed Foods
  'DEF_ULTRA_PROCESSED_QUANTITY',
  'DEF_ULTRA_PROCESSED_TYPE',
  'DEF_ULTRA_PROCESSED_TIME',

  -- Unhealthy Beverages
  'DEF_UNHEALTHY_BEV_QUANTITY',
  'DEF_UNHEALTHY_BEV_TYPE',
  'DEF_UNHEALTHY_BEV_TIME'
);

-- Set related pillars for caffeine (impacts multiple pillars)
UPDATE data_entry_fields
SET related_pillars = '["Movement + Exercise", "Restorative Sleep", "Stress Management"]'::jsonb
WHERE field_id IN ('DEF_CAFFEINE_QUANTITY', 'DEF_CAFFEINE_TYPE', 'DEF_CAFFEINE_TIME');

-- Set related pillars for alcohol (impacts sleep and stress)
UPDATE data_entry_fields
SET related_pillars = '["Restorative Sleep", "Stress Management", "Cognitive Health"]'::jsonb
WHERE field_id IN ('DEF_ALCOHOL_QUANTITY', 'DEF_ALCOHOL_TIME');


-- =====================================================
-- HEALTHFUL NUTRITION - Calories and Macronutrients
-- =====================================================

UPDATE data_entry_fields SET category_id = 'nutrition_calories_macros'
WHERE field_id IN (
  'DEF_CALORIES_CONSUMED'
);


-- =====================================================
-- MOVEMENT + EXERCISE - Cardio
-- =====================================================

UPDATE data_entry_fields SET category_id = 'exercise_cardio'
WHERE field_id IN (
  'DEF_CARDIO_TYPE',
  'DEF_CARDIO_START',
  'DEF_CARDIO_END',
  'DEF_CARDIO_DISTANCE',
  'DEF_CARDIO_DISTANCE_UNITS',
  'DEF_CARDIO_INTENSITY',
  'DEF_CARDIO_CALORIES'
);


-- =====================================================
-- MOVEMENT + EXERCISE - Strength
-- =====================================================

UPDATE data_entry_fields SET category_id = 'exercise_strength'
WHERE field_id IN (
  'DEF_STRENGTH_TYPE',
  'DEF_STRENGTH_START',
  'DEF_STRENGTH_END',
  'DEF_STRENGTH_INTENSITY',
  'DEF_STRENGTH_CALORIES',
  'DEF_STRENGTH_MUSCLE_GROUPS'
);


-- =====================================================
-- MOVEMENT + EXERCISE - HIIT
-- =====================================================

UPDATE data_entry_fields SET category_id = 'exercise_hiit'
WHERE field_id IN (
  'DEF_HIIT_TYPE',
  'DEF_HIIT_START',
  'DEF_HIIT_END',
  'DEF_HIIT_INTENSITY',
  'DEF_HIIT_CALORIES'
);


-- =====================================================
-- MOVEMENT + EXERCISE - Mobility
-- =====================================================

UPDATE data_entry_fields SET category_id = 'exercise_mobility'
WHERE field_id IN (
  'DEF_MOBILITY_TYPE',
  'DEF_MOBILITY_START',
  'DEF_MOBILITY_END',
  'DEF_MOBILITY_INTENSITY',
  'DEF_MOBILITY_CALORIES'
);

-- Set related pillars for mobility (impacts stress and cognitive health)
UPDATE data_entry_fields
SET related_pillars = '["Stress Management", "Cognitive Health"]'::jsonb
WHERE field_id IN ('DEF_MOBILITY_TYPE', 'DEF_MOBILITY_START', 'DEF_MOBILITY_END');


-- =====================================================
-- MOVEMENT + EXERCISE - Steps
-- =====================================================

UPDATE data_entry_fields SET category_id = 'exercise_steps'
WHERE field_id IN (
  'DEF_STEPS'
);


-- =====================================================
-- RESTORATIVE SLEEP - Sleep Tracking
-- =====================================================

UPDATE data_entry_fields SET category_id = 'sleep_tracking'
WHERE field_id IN (
  'DEF_SLEEP_BEDTIME',
  'DEF_SLEEP_WAKETIME',
  'DEF_SLEEP_QUALITY',
  'DEF_SLEEP_FACTORS',
  'DEF_SLEEP_PERIOD_START',
  'DEF_SLEEP_PERIOD_END',
  'DEF_SLEEP_PERIOD_TYPE'
);

-- Set related pillars for sleep (impacts cognitive health and stress)
UPDATE data_entry_fields
SET related_pillars = '["Cognitive Health", "Stress Management", "Movement + Exercise"]'::jsonb
WHERE field_id IN ('DEF_SLEEP_BEDTIME', 'DEF_SLEEP_WAKETIME', 'DEF_SLEEP_QUALITY');


-- =====================================================
-- STRESS MANAGEMENT - Stress Monitoring
-- =====================================================

UPDATE data_entry_fields SET category_id = 'stress_monitoring'
WHERE field_id IN (
  'DEF_STRESS_LEVEL',
  'DEF_STRESS_FACTORS'
);

-- Set related pillars for stress (impacts sleep and cognitive)
UPDATE data_entry_fields
SET related_pillars = '["Restorative Sleep", "Cognitive Health", "Movement + Exercise"]'::jsonb
WHERE field_id IN ('DEF_STRESS_LEVEL', 'DEF_STRESS_FACTORS');


-- =====================================================
-- STRESS MANAGEMENT - Mindfulness Practices
-- =====================================================

UPDATE data_entry_fields SET category_id = 'stress_mindfulness'
WHERE field_id IN (
  'DEF_MINDFULNESS_TYPE',
  'DEF_MINDFULNESS_START',
  'DEF_MINDFULNESS_END',
  'DEF_GRATITUDE_CONTENT',
  'DEF_GRATITUDE_TIME',
  'DEF_JOURNALING_START',
  'DEF_JOURNALING_END'
);

-- Set related pillars for mindfulness (impacts sleep, cognitive, connection)
UPDATE data_entry_fields
SET related_pillars = '["Restorative Sleep", "Cognitive Health", "Connection + Purpose"]'::jsonb
WHERE field_id IN ('DEF_MINDFULNESS_TYPE', 'DEF_MINDFULNESS_START', 'DEF_MINDFULNESS_END');


-- =====================================================
-- COGNITIVE HEALTH - Cognitive Performance
-- =====================================================

UPDATE data_entry_fields SET category_id = 'cognitive_performance'
WHERE field_id IN (
  'DEF_FOCUS_RATING',
  'DEF_MEMORY_CLARITY_RATING',
  'DEF_MOOD_RATING'
);


-- =====================================================
-- COGNITIVE HEALTH - Brain Training
-- =====================================================

UPDATE data_entry_fields SET category_id = 'cognitive_brain_training'
WHERE field_id IN (
  'DEF_BRAIN_TRAINING_START',
  'DEF_BRAIN_TRAINING_END'
);


-- =====================================================
-- COGNITIVE HEALTH - Screen Time
-- =====================================================

UPDATE data_entry_fields SET category_id = 'cognitive_screen_time'
WHERE field_id IN (
  'DEF_SCREEN_TIME_TYPE',
  'DEF_SCREEN_TIME_QUANTITY',
  'DEF_SCREEN_TIME_DATE'
);

-- Set related pillars for screen time (impacts sleep and stress)
UPDATE data_entry_fields
SET related_pillars = '["Restorative Sleep", "Stress Management"]'::jsonb
WHERE field_id IN ('DEF_SCREEN_TIME_TYPE', 'DEF_SCREEN_TIME_QUANTITY');


-- =====================================================
-- CONNECTION + PURPOSE - Social Connection
-- =====================================================

UPDATE data_entry_fields SET category_id = 'connection_social'
WHERE field_id IN (
  'DEF_SOCIAL_EVENT_TYPE',
  'DEF_SOCIAL_EVENT_TIME'
);

-- Set related pillars for social connection (impacts cognitive and stress)
UPDATE data_entry_fields
SET related_pillars = '["Cognitive Health", "Stress Management"]'::jsonb
WHERE field_id IN ('DEF_SOCIAL_EVENT_TYPE', 'DEF_SOCIAL_EVENT_TIME');


-- =====================================================
-- CONNECTION + PURPOSE - Nature Exposure
-- =====================================================

UPDATE data_entry_fields SET category_id = 'connection_nature'
WHERE field_id IN (
  'DEF_OUTDOOR_START',
  'DEF_OUTDOOR_END',
  'DEF_SUNLIGHT_TYPE',
  'DEF_SUNLIGHT_START',
  'DEF_SUNLIGHT_END'
);

-- Set related pillars for nature exposure (impacts stress, cognitive, movement)
UPDATE data_entry_fields
SET related_pillars = '["Stress Management", "Cognitive Health", "Movement + Exercise"]'::jsonb
WHERE field_id IN ('DEF_OUTDOOR_START', 'DEF_OUTDOOR_END');

UPDATE data_entry_fields
SET related_pillars = '["Restorative Sleep", "Core Care"]'::jsonb
WHERE field_id IN ('DEF_SUNLIGHT_TYPE', 'DEF_SUNLIGHT_START', 'DEF_SUNLIGHT_END');


-- =====================================================
-- CORE CARE - Body Measurements
-- =====================================================

UPDATE data_entry_fields SET category_id = 'core_body_measurements'
WHERE field_id IN (
  'DEF_WEIGHT',
  'DEF_WEIGHT_TIME',
  'DEF_HEIGHT',
  'DEF_BODY_FAT_PCT',
  'DEF_BODY_FAT_TIME',
  'DEF_WAIST_CIRCUMFERENCE',
  'DEF_WAIST_TIME',
  'DEF_HIP_CIRCUMFERENCE',
  'DEF_HIP_TIME'
);

-- Set related pillars for body measurements (reflects nutrition and exercise)
UPDATE data_entry_fields
SET related_pillars = '["Healthful Nutrition", "Movement + Exercise"]'::jsonb
WHERE field_id IN ('DEF_WEIGHT', 'DEF_BODY_FAT_PCT', 'DEF_WAIST_CIRCUMFERENCE', 'DEF_HIP_CIRCUMFERENCE');


-- =====================================================
-- CORE CARE - Vital Signs
-- =====================================================

UPDATE data_entry_fields SET category_id = 'core_vital_signs'
WHERE field_id IN (
  'DEF_BLOOD_PRESSURE_SYS',
  'DEF_BLOOD_PRESSURE_DIA',
  'DEF_BLOOD_PRESSURE_TIME'
);

-- Set related pillars for blood pressure (influenced by nutrition, exercise, stress)
UPDATE data_entry_fields
SET related_pillars = '["Healthful Nutrition", "Movement + Exercise", "Stress Management"]'::jsonb
WHERE field_id IN ('DEF_BLOOD_PRESSURE_SYS', 'DEF_BLOOD_PRESSURE_DIA');


-- =====================================================
-- CORE CARE - Health Screenings
-- =====================================================

UPDATE data_entry_fields SET category_id = 'core_screenings'
WHERE field_id IN (
  'DEF_SCREENING_TYPE',
  'DEF_SCREENING_NAME',
  'DEF_SCREENING_DATE',
  'DEF_SCREENING_RESULT'
);


-- =====================================================
-- CORE CARE - Therapeutic Tracking
-- =====================================================

UPDATE data_entry_fields SET category_id = 'core_therapeutics'
WHERE field_id IN (
  'DEF_THERAPEUTIC_TYPE',
  'DEF_THERAPEUTIC_DOSE',
  'DEF_THERAPEUTIC_UNITS',
  'DEF_THERAPEUTIC_TIME',
  'DEF_SUBSTANCE_TYPE',
  'DEF_SUBSTANCE_QUANTITY',
  'DEF_SUBSTANCE_SOURCE',
  'DEF_SUBSTANCE_TIME'
);


-- =====================================================
-- CORE CARE - Personal Care
-- =====================================================

UPDATE data_entry_fields SET category_id = 'core_personal_care'
WHERE field_id IN (
  'DEF_BRUSHING_TIME',
  'DEF_FLOSSING_TIME',
  'DEF_SKINCARE_STEP',
  'DEF_SKINCARE_TIME',
  'DEF_SUNSCREEN_TYPE',
  'DEF_SUNSCREEN_TIME'
);


-- =====================================================
-- VERIFICATION: Count Fields by Category
-- =====================================================

-- This shows the distribution of fields across categories
-- Uncomment to run verification after migration
/*
SELECT
  c.pillar_name,
  c.category_name,
  COUNT(f.field_id) as field_count
FROM data_entry_categories c
LEFT JOIN data_entry_fields f ON f.category_id = c.category_id AND f.is_active = true
GROUP BY c.pillar_name, c.category_name, c.display_order
ORDER BY c.pillar_name, c.display_order;
*/


COMMIT;
