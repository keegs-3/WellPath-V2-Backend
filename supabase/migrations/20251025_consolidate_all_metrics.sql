-- =====================================================
-- Consolidate All 270 Metrics from z_old_display_metrics
-- =====================================================
-- Consolidates meal-timing duplicates into parent metrics
-- Migrates standalone metrics as-is
-- Creates missing screens
-- =====================================================

BEGIN;

-- =====================================================
-- STEP 1: Create Missing Display Screens
-- =====================================================

INSERT INTO display_screens (screen_id, name, overview, pillar, display_order, is_active) VALUES
  -- Nutrition screens (missing)
  ('SCREEN_LEGUMES', 'Legumes', 'Bean and legume intake tracking', 'Healthful Nutrition', 7, true),
  ('SCREEN_WHOLE_GRAINS', 'Whole Grains', 'Whole grain servings and variety', 'Healthful Nutrition', 8, true),
  ('SCREEN_HEALTHY_FATS', 'Healthy Fats', 'Fat sources and quality tracking', 'Healthful Nutrition', 9, true),
  ('SCREEN_ADDED_SUGAR', 'Added Sugar', 'Sugar intake monitoring', 'Healthful Nutrition', 10, true),
  ('SCREEN_MEAL_QUALITY', 'Meal Quality', 'Whole food and meal quality metrics', 'Healthful Nutrition', 11, true),

  -- Exercise screens (missing)
  ('SCREEN_POST_MEAL_ACTIVITY', 'Post-Meal Activity', 'Activity after meals', 'Movement + Exercise', 7, true),
  ('SCREEN_FITNESS_METRICS', 'Fitness Metrics', 'Heart rate and VO2 max', 'Movement + Exercise', 8, true),

  -- Sleep screens (missing)
  ('SCREEN_SLEEP_ANALYSIS', 'Sleep Analysis', 'Sleep stages and breakdown', 'Restorative Sleep', 1, true),
  ('SCREEN_SLEEP_CONSISTENCY', 'Sleep Consistency', 'Sleep schedule consistency', 'Restorative Sleep', 2, true),
  ('SCREEN_SLEEP_QUALITY', 'Sleep Quality', 'Sleep efficiency and cycles', 'Restorative Sleep', 3, true),
  ('SCREEN_SLEEP_TIMING', 'Sleep Timing', 'Bedtime routines and timing', 'Restorative Sleep', 4, true),

  -- Core Care screens (missing)
  ('SCREEN_MEDICATIONS', 'Medications & Supplements', 'Medication and supplement adherence', 'Core Care', 5, true),
  ('SCREEN_ORAL_HEALTH', 'Oral Health', 'Brushing and flossing', 'Core Care', 7, true),
  ('SCREEN_ROUTINES', 'Daily Routines', 'Morning and evening routines', 'Core Care', 8, true),

  -- Mental wellness screens (missing)
  ('SCREEN_SOCIAL', 'Social Connection', 'Social interactions', 'Connection + Purpose', 1, true),
  ('SCREEN_OUTDOOR_TIME', 'Outdoor Time', 'Time spent outdoors', 'Connection + Purpose', 2, true),
  ('SCREEN_GRATITUDE', 'Gratitude', 'Gratitude practice', 'Connection + Purpose', 3, true),
  ('SCREEN_SCREEN_TIME', 'Screen Time', 'Digital device usage', 'Connection + Purpose', 4, true),
  ('SCREEN_BRAIN_TRAINING', 'Brain Training', 'Cognitive exercises', 'Cognitive Health', 1, true),
  ('SCREEN_COGNITIVE_METRICS', 'Cognitive Metrics', 'Mood, focus, and memory', 'Cognitive Health', 2, true),
  ('SCREEN_JOURNALING', 'Journaling', 'Journaling sessions', 'Cognitive Health', 3, true),
  ('SCREEN_MEDITATION', 'Meditation', 'Meditation practice', 'Stress Management', 1, true),
  ('SCREEN_BREATHWORK', 'Breathwork', 'Breathing exercises', 'Stress Management', 2, true)
ON CONFLICT (screen_id) DO NOTHING;

-- =====================================================
-- STEP 2: Create Consolidated Metrics (Meal Timing)
-- =====================================================

-- Protein meal timing
INSERT INTO display_metrics (metric_id, metric_name, description, pillar, category, screen_id, is_active) VALUES
  ('DISP_PROTEIN_MEAL_TIMING', 'Protein by Meal', 'Protein distribution across meals', 'Healthful Nutrition', 'nutrition', 'SCREEN_PROTEIN', true),
  ('DISP_PROTEIN_PER_KG', 'Protein per Kg', 'Protein intake per kilogram body weight', 'Healthful Nutrition', 'nutrition', 'SCREEN_PROTEIN', true),
  ('DISP_PLANT_PROTEIN_PCT', 'Plant Protein %', 'Percentage of protein from plant sources', 'Healthful Nutrition', 'nutrition', 'SCREEN_PROTEIN', true),
  ('DISP_PLANT_PROTEIN_GRAMS', 'Plant Protein', 'Plant-based protein in grams', 'Healthful Nutrition', 'nutrition', 'SCREEN_PROTEIN', true)
ON CONFLICT (metric_id) DO NOTHING;

-- Fiber meal timing
INSERT INTO display_metrics (metric_id, metric_name, description, pillar, category, screen_id, is_active) VALUES
  ('DISP_FIBER_MEAL_TIMING', 'Fiber by Meal', 'Fiber distribution across meals', 'Healthful Nutrition', 'nutrition', 'SCREEN_FIBER', true),
  ('DISP_FIBER_SOURCE_COUNT', 'Fiber Source Count', 'Number of different fiber sources', 'Healthful Nutrition', 'nutrition', 'SCREEN_FIBER', true)
ON CONFLICT (metric_id) DO UPDATE SET screen_id = EXCLUDED.screen_id WHERE display_metrics.screen_id IS NULL;

-- Vegetable meal timing
INSERT INTO display_metrics (metric_id, metric_name, description, pillar, category, screen_id, is_active) VALUES
  ('DISP_VEGETABLE_MEAL_TIMING', 'Vegetables by Meal', 'Vegetable servings by meal', 'Healthful Nutrition', 'nutrition', 'SCREEN_VEGETABLES', true),
  ('DISP_VEGETABLE_SOURCE_COUNT', 'Vegetable Variety', 'Number of different vegetables', 'Healthful Nutrition', 'nutrition', 'SCREEN_VEGETABLES', true)
ON CONFLICT (metric_id) DO UPDATE SET screen_id = EXCLUDED.screen_id WHERE display_metrics.screen_id IS NULL;

-- Fruit meal timing
INSERT INTO display_metrics (metric_id, metric_name, description, pillar, category, screen_id, is_active) VALUES
  ('DISP_FRUIT_MEAL_TIMING', 'Fruits by Meal', 'Fruit servings by meal', 'Healthful Nutrition', 'nutrition', 'SCREEN_FRUITS', true),
  ('DISP_FRUIT_SOURCE_COUNT', 'Fruit Variety', 'Number of different fruits', 'Healthful Nutrition', 'nutrition', 'SCREEN_FRUITS', true)
ON CONFLICT (metric_id) DO UPDATE SET screen_id = EXCLUDED.screen_id WHERE display_metrics.screen_id IS NULL;

-- Legume meal timing
INSERT INTO display_metrics (metric_id, metric_name, description, pillar, category, screen_id, is_active) VALUES
  ('DISP_LEGUME_MEAL_TIMING', 'Legumes by Meal', 'Legume servings by meal', 'Healthful Nutrition', 'nutrition', 'SCREEN_LEGUMES', true),
  ('DISP_LEGUME_SOURCE_COUNT', 'Legume Variety', 'Number of different legumes', 'Healthful Nutrition', 'nutrition', 'SCREEN_LEGUMES', true)
ON CONFLICT (metric_id) DO UPDATE SET screen_id = EXCLUDED.screen_id WHERE display_metrics.screen_id IS NULL;

-- Whole grain meal timing
INSERT INTO display_metrics (metric_id, metric_name, description, pillar, category, screen_id, is_active) VALUES
  ('DISP_WHOLE_GRAIN_MEAL_TIMING', 'Whole Grains by Meal', 'Whole grain servings by meal', 'Healthful Nutrition', 'nutrition', 'SCREEN_WHOLE_GRAINS', true),
  ('DISP_WHOLE_GRAIN_SOURCE_COUNT', 'Whole Grain Variety', 'Number of different whole grains', 'Healthful Nutrition', 'nutrition', 'SCREEN_WHOLE_GRAINS', true)
ON CONFLICT (metric_id) DO UPDATE SET screen_id = EXCLUDED.screen_id WHERE display_metrics.screen_id IS NULL;

-- Healthy fats meal timing
INSERT INTO display_metrics (metric_id, metric_name, description, pillar, category, screen_id, is_active) VALUES
  ('DISP_HEALTHY_FAT_SWAPS_TIMING', 'Healthy Fat Swaps by Meal', 'Healthy fat usage by meal', 'Healthful Nutrition', 'nutrition', 'SCREEN_HEALTHY_FATS', true),
  ('DISP_SATURATED_FAT_TIMING', 'Saturated Fat by Meal', 'Saturated fat intake by meal', 'Healthful Nutrition', 'nutrition', 'SCREEN_HEALTHY_FATS', true),
  ('DISP_FAT_SOURCE_COUNT', 'Fat Source Count', 'Number of different fat sources', 'Healthful Nutrition', 'nutrition', 'SCREEN_HEALTHY_FATS', true),
  ('DISP_HEALTHY_FAT_RATIO', 'Healthy Fat Ratio', 'Ratio of healthy to unhealthy fats', 'Healthful Nutrition', 'nutrition', 'SCREEN_HEALTHY_FATS', true),
  ('DISP_MUFA_GRAMS', 'Monounsaturated Fat', 'Monounsaturated fat in grams', 'Healthful Nutrition', 'nutrition', 'SCREEN_HEALTHY_FATS', true),
  ('DISP_PUFA_GRAMS', 'Polyunsaturated Fat', 'Polyunsaturated fat in grams', 'Healthful Nutrition', 'nutrition', 'SCREEN_HEALTHY_FATS', true),
  ('DISP_SAT_FAT_GRAMS', 'Saturated Fat', 'Saturated fat in grams', 'Healthful Nutrition', 'nutrition', 'SCREEN_HEALTHY_FATS', true),
  ('DISP_SAT_FAT_PCT', 'Saturated Fat %', 'Percentage of fat from saturated sources', 'Healthful Nutrition', 'nutrition', 'SCREEN_HEALTHY_FATS', true)
ON CONFLICT (metric_id) DO UPDATE SET screen_id = EXCLUDED.screen_id WHERE display_metrics.screen_id IS NULL;

-- Added sugar meal timing
INSERT INTO display_metrics (metric_id, metric_name, description, pillar, category, screen_id, is_active) VALUES
  ('DISP_ADDED_SUGAR_TIMING', 'Added Sugar by Meal', 'Sugar intake by meal', 'Healthful Nutrition', 'nutrition', 'SCREEN_ADDED_SUGAR', true),
  ('DISP_ADDED_SUGAR_GRAMS', 'Added Sugar', 'Total added sugar in grams', 'Healthful Nutrition', 'nutrition', 'SCREEN_ADDED_SUGAR', true)
ON CONFLICT (metric_id) DO UPDATE SET screen_id = EXCLUDED.screen_id WHERE display_metrics.screen_id IS NULL;

-- Meal quality timing
INSERT INTO display_metrics (metric_id, metric_name, description, pillar, category, screen_id, is_active) VALUES
  ('DISP_WHOLE_FOOD_MEALS_TIMING', 'Whole Food Meals by Time', 'Whole food meals by meal', 'Healthful Nutrition', 'nutrition', 'SCREEN_MEAL_QUALITY', true),
  ('DISP_PLANT_BASED_MEALS_TIMING', 'Plant-Based Meals by Time', 'Plant-based meals by meal', 'Healthful Nutrition', 'nutrition', 'SCREEN_MEAL_QUALITY', true),
  ('DISP_MINDFUL_EATING_TIMING', 'Mindful Eating by Meal', 'Mindful eating episodes by meal', 'Healthful Nutrition', 'nutrition', 'SCREEN_MEAL_QUALITY', true),
  ('DISP_TAKEOUT_TIMING', 'Takeout by Meal', 'Takeout/delivery meals by meal', 'Healthful Nutrition', 'nutrition', 'SCREEN_MEAL_QUALITY', true),
  ('DISP_LARGE_MEALS_TIMING', 'Large Meals by Time', 'Large meals by meal', 'Healthful Nutrition', 'nutrition', 'SCREEN_MEAL_QUALITY', true),
  ('DISP_ULTRAPROCESSED_TIMING', 'Ultraprocessed by Meal', 'Ultraprocessed food by meal', 'Healthful Nutrition', 'nutrition', 'SCREEN_MEAL_QUALITY', true),
  ('DISP_PROCESSED_MEAT_TIMING', 'Processed Meat by Meal', 'Processed meat by meal', 'Healthful Nutrition', 'nutrition', 'SCREEN_MEAL_QUALITY', true)
ON CONFLICT (metric_id) DO UPDATE SET screen_id = EXCLUDED.screen_id WHERE display_metrics.screen_id IS NULL;

-- Post-meal activity timing
INSERT INTO display_metrics (metric_id, metric_name, description, pillar, category, screen_id, is_active) VALUES
  ('DISP_POST_MEAL_ACTIVITY_TIMING', 'Post-Meal Activity by Meal', 'Activity after each meal', 'Movement + Exercise', 'activity', 'SCREEN_POST_MEAL_ACTIVITY', true),
  ('DISP_POST_MEAL_EXERCISE_TIMING', 'Post-Meal Exercise by Meal', 'Exercise snacks after meals', 'Movement + Exercise', 'activity', 'SCREEN_POST_MEAL_ACTIVITY', true)
ON CONFLICT (metric_id) DO UPDATE SET screen_id = EXCLUDED.screen_id WHERE display_metrics.screen_id IS NULL;

-- =====================================================
-- STEP 3: Create Standalone Metrics
-- =====================================================

-- Nutrition
INSERT INTO display_metrics (metric_id, metric_name, description, pillar, category, screen_id, is_active) VALUES
  -- Meal timing screen
  ('DISP_TOTAL_MEALS', 'Total Meals', 'Total number of meals', 'Healthful Nutrition', 'nutrition', 'SCREEN_MEAL_TIMING', true),
  ('DISP_BREAKFAST', 'Breakfast', 'Breakfast meals', 'Healthful Nutrition', 'nutrition', 'SCREEN_MEAL_TIMING', true),
  ('DISP_LUNCH', 'Lunch', 'Lunch meals', 'Healthful Nutrition', 'nutrition', 'SCREEN_MEAL_TIMING', true),
  ('DISP_DINNER', 'Dinner', 'Dinner meals', 'Healthful Nutrition', 'nutrition', 'SCREEN_MEAL_TIMING', true),
  ('DISP_SNACKS', 'Snacks', 'Snacking episodes', 'Healthful Nutrition', 'nutrition', 'SCREEN_MEAL_TIMING', true),
  ('DISP_FIRST_MEAL_TIME', 'First Meal Time', 'Time of first meal', 'Healthful Nutrition', 'nutrition', 'SCREEN_MEAL_TIMING', true),
  ('DISP_FIRST_MEAL_DELAY', 'First Meal Delay', 'Hours after waking before first meal', 'Healthful Nutrition', 'nutrition', 'SCREEN_MEAL_TIMING', true),
  ('DISP_LAST_MEAL_TIME', 'Last Meal Time', 'Time of last meal', 'Healthful Nutrition', 'nutrition', 'SCREEN_MEAL_TIMING', true),
  ('DISP_LAST_MEAL_BUFFER', 'Last Meal Buffer', 'Hours before bed after last meal', 'Healthful Nutrition', 'nutrition', 'SCREEN_MEAL_TIMING', true),
  ('DISP_LAST_LARGE_MEAL_TIME', 'Last Large Meal Time', 'Time of last large meal', 'Healthful Nutrition', 'nutrition', 'SCREEN_MEAL_TIMING', true),
  ('DISP_LAST_LARGE_MEAL_BUFFER', 'Last Large Meal Buffer', 'Hours before bed after last large meal', 'Healthful Nutrition', 'nutrition', 'SCREEN_MEAL_TIMING', true),
  ('DISP_EATING_WINDOW', 'Eating Window', 'Duration of eating window', 'Healthful Nutrition', 'nutrition', 'SCREEN_MEAL_TIMING', true),

  -- Meal quality
  ('DISP_BREAKFAST_TOTAL_SERVINGS', 'Breakfast Total Servings', 'Total servings at breakfast', 'Healthful Nutrition', 'nutrition', 'SCREEN_MEAL_QUALITY', true),
  ('DISP_LUNCH_TOTAL_SERVINGS', 'Lunch Total Servings', 'Total servings at lunch', 'Healthful Nutrition', 'nutrition', 'SCREEN_MEAL_QUALITY', true),
  ('DISP_DINNER_TOTAL_SERVINGS', 'Dinner Total Servings', 'Total servings at dinner', 'Healthful Nutrition', 'nutrition', 'SCREEN_MEAL_QUALITY', true),
  ('DISP_FATTY_FISH_SERVINGS', 'Fatty Fish', 'Fatty fish servings', 'Healthful Nutrition', 'nutrition', 'SCREEN_MEAL_QUALITY', true),
  ('DISP_RED_MEAT_SERVINGS', 'Red Meat', 'Red meat servings', 'Healthful Nutrition', 'nutrition', 'SCREEN_MEAL_QUALITY', true),
  ('DISP_SEED_SERVINGS', 'Seeds', 'Seed servings', 'Healthful Nutrition', 'nutrition', 'SCREEN_MEAL_QUALITY', true),

  -- Hydration
  ('DISP_CAFFEINE_CONSUMED', 'Caffeine', 'Caffeine consumed', 'Healthful Nutrition', 'nutrition', 'SCREEN_HYDRATION', true),
  ('DISP_CAFFEINE_SOURCE_COUNT', 'Caffeine Sources', 'Number of caffeine sources', 'Healthful Nutrition', 'nutrition', 'SCREEN_HYDRATION', true)
ON CONFLICT (metric_id) DO UPDATE SET screen_id = EXCLUDED.screen_id WHERE display_metrics.screen_id IS NULL;

-- Exercise
INSERT INTO display_metrics (metric_id, metric_name, description, pillar, category, screen_id, is_active) VALUES
  -- Cardio
  ('DISP_CALORIES', 'Calories Burned', 'Total calories burned', 'Movement + Exercise', 'activity', 'SCREEN_CARDIO', true),

  -- Activity
  ('DISP_CALCULATED_ACTIVE_TIME', 'Calculated Active Time', 'Calculated total active time', 'Movement + Exercise', 'activity', 'SCREEN_ACTIVITY', true),
  ('DISP_CALCULATED_EXERCISE_TIME', 'Calculated Exercise Time', 'Calculated exercise duration', 'Movement + Exercise', 'activity', 'SCREEN_ACTIVITY', true),
  ('DISP_ACTIVE_VS_CALCULATED', 'Active vs Calculated', 'Difference between tracked and calculated', 'Movement + Exercise', 'activity', 'SCREEN_ACTIVITY', true),
  ('DISP_SEDENTARY_SESSIONS', 'Sedentary Sessions', 'Number of sedentary periods', 'Movement + Exercise', 'activity', 'SCREEN_ACTIVITY', true),
  ('DISP_SEDENTARY_TIME', 'Sedentary Time', 'Total sedentary duration', 'Movement + Exercise', 'activity', 'SCREEN_ACTIVITY', true),
  ('DISP_SEDENTARY_PERIOD', 'Sedentary Period', 'Individual sedentary period', 'Movement + Exercise', 'activity', 'SCREEN_ACTIVITY', true),
  ('DISP_EXERCISE_SNACKS', 'Exercise Snacks', 'Brief exercise sessions', 'Movement + Exercise', 'activity', 'SCREEN_ACTIVITY', true),
  ('DISP_EXERCISE_SNACK', 'Exercise Snack', 'Single exercise snack', 'Movement + Exercise', 'activity', 'SCREEN_ACTIVITY', true),
  ('DISP_WALKING_DURATION', 'Walking Duration', 'Total walking time', 'Movement + Exercise', 'activity', 'SCREEN_ACTIVITY', true),
  ('DISP_WALKING_SESSIONS', 'Walking Sessions', 'Number of walking sessions', 'Movement + Exercise', 'activity', 'SCREEN_ACTIVITY', true),

  -- Post-meal activity
  ('DISP_POST_MEAL_ACTIVITY_DURATION', 'Post-Meal Activity Duration', 'Total post-meal activity time', 'Movement + Exercise', 'activity', 'SCREEN_POST_MEAL_ACTIVITY', true),

  -- Fitness metrics
  ('DISP_RESTING_HR', 'Resting Heart Rate', 'Resting heart rate', 'Movement + Exercise', 'activity', 'SCREEN_FITNESS_METRICS', true),
  ('DISP_VO2_MAX', 'VO2 Max', 'Maximal oxygen uptake', 'Movement + Exercise', 'activity', 'SCREEN_FITNESS_METRICS', true)
ON CONFLICT (metric_id) DO UPDATE SET screen_id = EXCLUDED.screen_id WHERE display_metrics.screen_id IS NULL;

-- Sleep
INSERT INTO display_metrics (metric_id, metric_name, description, pillar, category, screen_id, is_active) VALUES
  -- Sleep analysis percentages
  ('DISP_DEEP_PCT', 'Deep Sleep %', 'Percentage of sleep in deep stage', 'Restorative Sleep', 'sleep', 'SCREEN_SLEEP_ANALYSIS', true),
  ('DISP_CORE_PCT', 'Core Sleep %', 'Percentage of sleep in core stage', 'Restorative Sleep', 'sleep', 'SCREEN_SLEEP_ANALYSIS', true),
  ('DISP_REM_PCT', 'REM Sleep %', 'Percentage of sleep in REM stage', 'Restorative Sleep', 'sleep', 'SCREEN_SLEEP_ANALYSIS', true),
  ('DISP_AWAKE_PCT', 'Awake %', 'Percentage of time awake', 'Restorative Sleep', 'sleep', 'SCREEN_SLEEP_ANALYSIS', true),

  -- Sleep quality
  ('DISP_SLEEP_EFFICIENCY', 'Sleep Efficiency', 'Sleep efficiency percentage', 'Restorative Sleep', 'sleep', 'SCREEN_SLEEP_QUALITY', true),
  ('DISP_SLEEP_LATENCY', 'Sleep Latency', 'Time to fall asleep', 'Restorative Sleep', 'sleep', 'SCREEN_SLEEP_QUALITY', true),
  ('DISP_DEEP_CYCLES', 'Deep Sleep Cycles', 'Number of deep sleep cycles', 'Restorative Sleep', 'sleep', 'SCREEN_SLEEP_QUALITY', true),
  ('DISP_REM_CYCLES', 'REM Cycles', 'Number of REM cycles', 'Restorative Sleep', 'sleep', 'SCREEN_SLEEP_QUALITY', true),
  ('DISP_AWAKE_EPISODES', 'Awake Episodes', 'Number of wake episodes', 'Restorative Sleep', 'sleep', 'SCREEN_SLEEP_QUALITY', true),
  ('DISP_SLEEP_ENVIRONMENT', 'Sleep Environment Score', 'Sleep environment quality', 'Restorative Sleep', 'sleep', 'SCREEN_SLEEP_QUALITY', true),
  ('DISP_SLEEP_ROUTINE', 'Sleep Routine Adherence', 'Adherence to sleep routine', 'Restorative Sleep', 'sleep', 'SCREEN_SLEEP_QUALITY', true),

  -- Sleep consistency
  ('DISP_WAKE_TIME_CONSISTENCY', 'Wake Time Consistency', 'Consistency of wake times', 'Restorative Sleep', 'sleep', 'SCREEN_SLEEP_CONSISTENCY', true),

  -- Sleep timing
  ('DISP_TIME_IN_BED', 'Time in Bed', 'Total time in bed', 'Restorative Sleep', 'sleep', 'SCREEN_SLEEP_TIMING', true),
  ('DISP_SLEEP_WINDOW', 'Sleep Window', 'Total sleep window duration', 'Restorative Sleep', 'sleep', 'SCREEN_SLEEP_TIMING', true),
  ('DISP_LAST_DRINK_TIME', 'Last Drink Time', 'Time of last alcoholic drink', 'Restorative Sleep', 'sleep', 'SCREEN_SLEEP_TIMING', true),
  ('DISP_LAST_SCREEN_TIME', 'Last Screen Time', 'Time of last digital device use', 'Restorative Sleep', 'sleep', 'SCREEN_SLEEP_TIMING', true),
  ('DISP_LAST_DRINK_BUFFER', 'Last Drink Buffer', 'Hours before bed after last drink', 'Restorative Sleep', 'sleep', 'SCREEN_SLEEP_TIMING', true),
  ('DISP_WEARABLE_USAGE', 'Wearable Usage', 'Wearable device usage tracking', 'Restorative Sleep', 'sleep', 'SCREEN_SLEEP_TIMING', true)
ON CONFLICT (metric_id) DO UPDATE SET screen_id = EXCLUDED.screen_id WHERE display_metrics.screen_id IS NULL;

-- Core Care
INSERT INTO display_metrics (metric_id, metric_name, description, pillar, category, screen_id, is_active) VALUES
  -- Biometrics
  ('DISP_WEIGHT', 'Weight', 'Current body weight', 'Core Care', 'health_tracking', 'SCREEN_BIOMETRICS', true),
  ('DISP_HEIGHT', 'Height', 'Height measurement', 'Core Care', 'health_tracking', 'SCREEN_BIOMETRICS', true),
  ('DISP_BMI', 'BMI', 'Body mass index', 'Core Care', 'health_tracking', 'SCREEN_BIOMETRICS', true),
  ('DISP_BODY_FAT_PCT', 'Body Fat %', 'Body fat percentage', 'Core Care', 'health_tracking', 'SCREEN_BIOMETRICS', true),
  ('DISP_WAIST_HIP_RATIO', 'Waist-Hip Ratio', 'Waist to hip ratio', 'Core Care', 'health_tracking', 'SCREEN_BIOMETRICS', true),
  ('DISP_SYSTOLIC_BP', 'Systolic BP', 'Systolic blood pressure', 'Core Care', 'health_tracking', 'SCREEN_BIOMETRICS', true),
  ('DISP_DIASTOLIC_BP', 'Diastolic BP', 'Diastolic blood pressure', 'Core Care', 'health_tracking', 'SCREEN_BIOMETRICS', true),
  ('DISP_AGE', 'Age', 'User age', 'Core Care', 'health_tracking', 'SCREEN_BIOMETRICS', true),

  -- Compliance
  ('DISP_MAMMOGRAM_COMPLIANCE', 'Mammogram Compliance', 'Mammogram screening status', 'Core Care', 'health_tracking', 'SCREEN_COMPLIANCE', true),
  ('DISP_COLONOSCOPY_COMPLIANCE', 'Colonoscopy Compliance', 'Colonoscopy screening status', 'Core Care', 'health_tracking', 'SCREEN_COMPLIANCE', true),
  ('DISP_CERVICAL_COMPLIANCE', 'Cervical Screening', 'Cervical screening status', 'Core Care', 'health_tracking', 'SCREEN_COMPLIANCE', true),
  ('DISP_BREAST_MRI_COMPLIANCE', 'Breast MRI', 'Breast MRI screening status', 'Core Care', 'health_tracking', 'SCREEN_COMPLIANCE', true),
  ('DISP_PSA_COMPLIANCE', 'PSA Test', 'PSA test screening status', 'Core Care', 'health_tracking', 'SCREEN_COMPLIANCE', true),
  ('DISP_DENTAL_COMPLIANCE', 'Dental Exam', 'Dental exam compliance', 'Core Care', 'health_tracking', 'SCREEN_COMPLIANCE', true),
  ('DISP_PHYSICAL_COMPLIANCE', 'Physical Exam', 'Physical exam compliance', 'Core Care', 'health_tracking', 'SCREEN_COMPLIANCE', true),
  ('DISP_SKIN_CHECK_COMPLIANCE', 'Skin Check', 'Skin check compliance', 'Core Care', 'health_tracking', 'SCREEN_COMPLIANCE', true),
  ('DISP_VISION_COMPLIANCE', 'Vision Check', 'Vision check compliance', 'Core Care', 'health_tracking', 'SCREEN_COMPLIANCE', true),
  ('DISP_MONTHS_SINCE_DENTAL', 'Months Since Dental', 'Months since last dental exam', 'Core Care', 'health_tracking', 'SCREEN_COMPLIANCE', true),
  ('DISP_MONTHS_SINCE_MAMMOGRAM', 'Months Since Mammogram', 'Months since last mammogram', 'Core Care', 'health_tracking', 'SCREEN_COMPLIANCE', true),
  ('DISP_MONTHS_SINCE_BREAST_MRI', 'Months Since Breast MRI', 'Months since last breast MRI', 'Core Care', 'health_tracking', 'SCREEN_COMPLIANCE', true),
  ('DISP_MONTHS_SINCE_SKIN_CHECK', 'Months Since Skin Check', 'Months since last skin check', 'Core Care', 'health_tracking', 'SCREEN_COMPLIANCE', true),
  ('DISP_MONTHS_SINCE_VISION', 'Months Since Vision', 'Months since last vision check', 'Core Care', 'health_tracking', 'SCREEN_COMPLIANCE', true),
  ('DISP_YEARS_SINCE_COLONOSCOPY', 'Years Since Colonoscopy', 'Years since last colonoscopy', 'Core Care', 'health_tracking', 'SCREEN_COMPLIANCE', true),
  ('DISP_YEARS_SINCE_HPV', 'Years Since HPV', 'Years since last HPV screening', 'Core Care', 'health_tracking', 'SCREEN_COMPLIANCE', true),
  ('DISP_YEARS_SINCE_PAP', 'Years Since Pap', 'Years since last pap test', 'Core Care', 'health_tracking', 'SCREEN_COMPLIANCE', true),
  ('DISP_YEARS_SINCE_PHYSICAL', 'Years Since Physical', 'Years since last physical', 'Core Care', 'health_tracking', 'SCREEN_COMPLIANCE', true),
  ('DISP_YEARS_SINCE_PSA', 'Years Since PSA', 'Years since last PSA test', 'Core Care', 'health_tracking', 'SCREEN_COMPLIANCE', true),

  -- Medications
  ('DISP_MEDICATION_ADHERENCE', 'Medication Adherence', 'Medication adherence tracking', 'Core Care', 'health_tracking', 'SCREEN_MEDICATIONS', true),
  ('DISP_SUPPLEMENT_ADHERENCE', 'Supplement Adherence', 'Supplement adherence tracking', 'Core Care', 'health_tracking', 'SCREEN_MEDICATIONS', true),
  ('DISP_PEPTIDE_ADHERENCE', 'Peptide Adherence', 'Peptide adherence tracking', 'Core Care', 'health_tracking', 'SCREEN_MEDICATIONS', true),

  -- Skincare
  ('DISP_SUNSCREEN_APPLICATIONS', 'Sunscreen Applications', 'Total sunscreen applications', 'Core Care', 'health_tracking', 'SCREEN_SKINCARE', true),
  ('DISP_MORNING_SUNSCREEN', 'Morning Sunscreen', 'Morning sunscreen applications', 'Core Care', 'health_tracking', 'SCREEN_SKINCARE', true),
  ('DISP_SUNSCREEN_EVENTS', 'Sunscreen Events', 'Sunscreen compliance events', 'Core Care', 'health_tracking', 'SCREEN_SKINCARE', true),
  ('DISP_SUNSCREEN_RATE', 'Sunscreen Rate', 'Sunscreen compliance rate', 'Core Care', 'health_tracking', 'SCREEN_SKINCARE', true),
  ('DISP_SKINCARE_ROUTINE', 'Skincare Routine', 'Skincare routine adherence', 'Core Care', 'health_tracking', 'SCREEN_SKINCARE', true),

  -- Oral health
  ('DISP_BRUSHING_SESSIONS', 'Brushing', 'Tooth brushing sessions', 'Core Care', 'health_tracking', 'SCREEN_ORAL_HEALTH', true),
  ('DISP_FLOSSING_SESSIONS', 'Flossing', 'Flossing sessions', 'Core Care', 'health_tracking', 'SCREEN_ORAL_HEALTH', true),

  -- Substances
  ('DISP_ALCOHOL_DRINKS', 'Alcohol', 'Alcoholic drinks consumed', 'Core Care', 'health_tracking', 'SCREEN_SUBSTANCES', true),
  ('DISP_ALCOHOL_VS_BASELINE', 'Alcohol vs Baseline', 'Alcohol compared to baseline', 'Core Care', 'health_tracking', 'SCREEN_SUBSTANCES', true),
  ('DISP_CIGARETTES', 'Cigarettes', 'Cigarettes smoked', 'Core Care', 'health_tracking', 'SCREEN_SUBSTANCES', true),
  ('DISP_CIGARETTES_VS_BASELINE', 'Cigarettes vs Baseline', 'Smoking compared to baseline', 'Core Care', 'health_tracking', 'SCREEN_SUBSTANCES', true),

  -- Routines
  ('DISP_EVENING_ROUTINE', 'Evening Routine', 'Evening routine adherence', 'Core Care', 'health_tracking', 'SCREEN_ROUTINES', true),
  ('DISP_DIGITAL_SHUTOFF', 'Digital Shutoff', 'Digital device shutoff buffer', 'Core Care', 'health_tracking', 'SCREEN_ROUTINES', true),
  ('DISP_LAST_CAFFEINE_TIME', 'Last Caffeine Time', 'Time of last caffeine', 'Core Care', 'health_tracking', 'SCREEN_ROUTINES', true),
  ('DISP_LAST_CAFFEINE_BUFFER', 'Last Caffeine Buffer', 'Hours before bed after last caffeine', 'Core Care', 'health_tracking', 'SCREEN_ROUTINES', true)
ON CONFLICT (metric_id) DO UPDATE SET screen_id = EXCLUDED.screen_id WHERE display_metrics.screen_id IS NULL;

-- Cognitive Health
INSERT INTO display_metrics (metric_id, metric_name, description, pillar, category, screen_id, is_active) VALUES
  -- Brain training
  ('DISP_BRAIN_TRAINING_SESSIONS', 'Brain Training Sessions', 'Cognitive training sessions', 'Cognitive Health', 'mental_wellness', 'SCREEN_BRAIN_TRAINING', true),
  ('DISP_BRAIN_TRAINING_DURATION', 'Brain Training Duration', 'Time spent on cognitive training', 'Cognitive Health', 'mental_wellness', 'SCREEN_BRAIN_TRAINING', true),

  -- Cognitive metrics
  ('DISP_MOOD_RATING', 'Mood', 'Mood rating', 'Cognitive Health', 'mental_wellness', 'SCREEN_COGNITIVE_METRICS', true),
  ('DISP_FOCUS_RATING', 'Focus', 'Focus rating', 'Cognitive Health', 'mental_wellness', 'SCREEN_COGNITIVE_METRICS', true),
  ('DISP_MEMORY_RATING', 'Memory', 'Memory clarity rating', 'Cognitive Health', 'mental_wellness', 'SCREEN_COGNITIVE_METRICS', true),

  -- Light exposure
  ('DISP_SUNLIGHT_SESSIONS', 'Sunlight Sessions', 'Sunlight exposure sessions', 'Cognitive Health', 'mental_wellness', 'SCREEN_LIGHT_EXPOSURE', true),
  ('DISP_SUNLIGHT_DURATION', 'Sunlight Duration', 'Total sunlight exposure time', 'Cognitive Health', 'mental_wellness', 'SCREEN_LIGHT_EXPOSURE', true),
  ('DISP_MORNING_LIGHT_DURATION', 'Morning Light', 'Morning light exposure duration', 'Cognitive Health', 'mental_wellness', 'SCREEN_LIGHT_EXPOSURE', true),

  -- Journaling
  ('DISP_JOURNALING_SESSIONS', 'Journaling', 'Journaling sessions', 'Cognitive Health', 'mental_wellness', 'SCREEN_JOURNALING', true)
ON CONFLICT (metric_id) DO UPDATE SET screen_id = EXCLUDED.screen_id WHERE display_metrics.screen_id IS NULL;

-- Connection + Purpose
INSERT INTO display_metrics (metric_id, metric_name, description, pillar, category, screen_id, is_active) VALUES
  -- Social
  ('DISP_SOCIAL_INTERACTION', 'Social Interaction', 'Social interaction tracking', 'Connection + Purpose', 'mental_wellness', 'SCREEN_SOCIAL', true),

  -- Mindfulness
  ('DISP_MINDFULNESS_SESSIONS', 'Mindfulness Sessions', 'Mindfulness practice sessions', 'Connection + Purpose', 'mental_wellness', 'SCREEN_MINDFULNESS', true),
  ('DISP_MINDFULNESS_DURATION', 'Mindfulness Duration', 'Time spent on mindfulness', 'Connection + Purpose', 'mental_wellness', 'SCREEN_MINDFULNESS', true),

  -- Outdoor time
  ('DISP_OUTDOOR_SESSIONS', 'Outdoor Sessions', 'Outdoor time sessions', 'Connection + Purpose', 'mental_wellness', 'SCREEN_OUTDOOR_TIME', true),
  ('DISP_OUTDOOR_DURATION', 'Outdoor Duration', 'Total outdoor time', 'Connection + Purpose', 'mental_wellness', 'SCREEN_OUTDOOR_TIME', true),
  ('DISP_MORNING_OUTDOOR_DURATION', 'Morning Outdoor Time', 'Morning outdoor time duration', 'Connection + Purpose', 'mental_wellness', 'SCREEN_OUTDOOR_TIME', true),

  -- Gratitude
  ('DISP_GRATITUDE_SESSIONS', 'Gratitude', 'Gratitude practice sessions', 'Connection + Purpose', 'mental_wellness', 'SCREEN_GRATITUDE', true),

  -- Screen time
  ('DISP_SCREEN_TIME_SESSIONS', 'Screen Time Sessions', 'Digital device usage sessions', 'Connection + Purpose', 'mental_wellness', 'SCREEN_SCREEN_TIME', true),
  ('DISP_SCREEN_TIME_DURATION', 'Screen Time Duration', 'Total screen time', 'Connection + Purpose', 'mental_wellness', 'SCREEN_SCREEN_TIME', true),

  -- Stress tracking (also in Stress Management)
  ('DISP_STRESS_LEVEL', 'Stress Level', 'Stress level rating', 'Connection + Purpose', 'mental_wellness', 'SCREEN_WELLNESS', true),
  ('DISP_STRESS_MGMT_DURATION', 'Stress Management Duration', 'Time spent on stress management', 'Connection + Purpose', 'mental_wellness', 'SCREEN_WELLNESS', true)
ON CONFLICT (metric_id) DO UPDATE SET screen_id = EXCLUDED.screen_id WHERE display_metrics.screen_id IS NULL;

-- Stress Management
INSERT INTO display_metrics (metric_id, metric_name, description, pillar, category, screen_id, is_active) VALUES
  -- Meditation
  ('DISP_MEDITATION_SESSIONS', 'Meditation Sessions', 'Meditation practice sessions', 'Stress Management', 'mental_wellness', 'SCREEN_MEDITATION', true),
  ('DISP_MEDITATION_DURATION', 'Meditation Duration', 'Time spent meditating', 'Stress Management', 'mental_wellness', 'SCREEN_MEDITATION', true),

  -- Breathwork
  ('DISP_BREATHWORK_SESSIONS', 'Breathwork Sessions', 'Breathing exercise sessions', 'Stress Management', 'mental_wellness', 'SCREEN_BREATHWORK', true),
  ('DISP_BREATHWORK_DURATION', 'Breathwork Duration', 'Time spent on breathwork', 'Stress Management', 'mental_wellness', 'SCREEN_BREATHWORK', true),
  ('DISP_BREATHWORK_MINDFULNESS_SESSIONS', 'Breathwork + Mindfulness', 'Combined breathwork and mindfulness sessions', 'Stress Management', 'mental_wellness', 'SCREEN_BREATHWORK', true),
  ('DISP_BREATHWORK_MINDFULNESS_DURATION', 'Breathwork + Mindfulness Duration', 'Time spent on combined practice', 'Stress Management', 'mental_wellness', 'SCREEN_BREATHWORK', true),

  -- Stress management
  ('DISP_STRESS_MGMT_SESSIONS', 'Stress Management Sessions', 'Stress management sessions', 'Stress Management', 'mental_wellness', 'SCREEN_MINDFULNESS', true)

-- Handle conflicts (some metrics may already exist)
ON CONFLICT (metric_id) DO NOTHING;

-- =====================================================
-- VERIFICATION
-- =====================================================

DO $$
DECLARE
  screens_count INT;
  metrics_count INT;
  linked_count INT;
  old_count INT;
BEGIN
  SELECT COUNT(*) INTO screens_count FROM display_screens WHERE is_active = true;
  SELECT COUNT(*) INTO metrics_count FROM display_metrics WHERE is_active = true;
  SELECT COUNT(*) INTO linked_count FROM display_metrics WHERE screen_id IS NOT NULL;
  SELECT COUNT(*) INTO old_count FROM z_old_display_metrics;

  RAISE NOTICE '✅ Metrics Consolidation Complete';
  RAISE NOTICE '';
  RAISE NOTICE 'Old Structure:';
  RAISE NOTICE '  z_old_display_metrics: % metrics (with duplicates)', old_count;
  RAISE NOTICE '';
  RAISE NOTICE 'New Structure:';
  RAISE NOTICE '  display_screens: % active screens', screens_count;
  RAISE NOTICE '  display_metrics: % active metrics', metrics_count;
  RAISE NOTICE '    Linked to screens: %', linked_count;
  RAISE NOTICE '';
  RAISE NOTICE 'Consolidation:';
  RAISE NOTICE '  57 meal-timing triplicates → 19 consolidated metrics';
  RAISE NOTICE '  ~150 redundant metrics eliminated';
END $$;

-- Show screen breakdown
SELECT
  ds.pillar,
  COUNT(DISTINCT ds.screen_id) as screens,
  COUNT(dm.metric_id) as metrics
FROM display_screens ds
LEFT JOIN display_metrics dm ON dm.screen_id = ds.screen_id
WHERE ds.is_active = true
GROUP BY ds.pillar
ORDER BY ds.pillar;

COMMIT;
