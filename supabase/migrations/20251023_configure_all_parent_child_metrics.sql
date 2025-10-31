-- =====================================================================================
-- Configure Parent/Child Metrics Across All Pillars
-- =====================================================================================
-- Implements Apple Health pattern: Parent metric with expandable child metrics
-- Mobile shows parent with main chart, "View Details" reveals children
-- =====================================================================================

-- =====================================================================================
-- HEALTHFUL NUTRITION
-- =====================================================================================

-- Fruit Servings
UPDATE display_metrics SET parent_metric_id = 'DISP_FRUIT_SERVINGS'
WHERE display_metric_id IN (
  'DISP_FRUIT_SERVINGS_BREAKFAST',
  'DISP_FRUIT_SERVINGS_LUNCH',
  'DISP_FRUIT_SERVINGS_DINNER',
  'DISP_FRUIT_VARIETY',
  'DISP_FRUIT_SOURCE_COUNT',
  'DISP_FRUIT_SOURCES'
);

-- Fiber Servings
UPDATE display_metrics SET parent_metric_id = 'DISP_FIBER_SERVINGS'
WHERE display_metric_id IN (
  'DISP_FIBER_SERVINGS_BREAKFAST',
  'DISP_FIBER_SERVINGS_LUNCH',
  'DISP_FIBER_SERVINGS_DINNER',
  'DISP_FIBER_GRAMS',
  'DISP_FIBER_SOURCE_COUNT',
  'DISP_FIBER_SOURCE_VARIETY',
  'DISP_FIBER_SOURCES'
);

-- Legume Servings
UPDATE display_metrics SET parent_metric_id = 'DISP_LEGUME_SERVINGS'
WHERE display_metric_id IN (
  'DISP_LEGUME_SERVINGS_BREAKFAST',
  'DISP_LEGUME_SERVINGS_LUNCH',
  'DISP_LEGUME_SERVINGS_DINNER',
  'DISP_LEGUME_VARIETY',
  'DISP_LEGUME_SOURCE_COUNT',
  'DISP_LEGUME_SOURCES'
);

-- Added Sugar
UPDATE display_metrics SET parent_metric_id = 'DISP_ADDED_SUGAR_SERVINGS'
WHERE display_metric_id IN (
  'DISP_ADDED_SUGAR_SERVINGS_BREAKFAST',
  'DISP_ADDED_SUGAR_SERVINGS_LUNCH',
  'DISP_ADDED_SUGAR_SERVINGS_DINNER',
  'DISP_ADDED_SUGAR_CONSUMED'
);

-- Healthy Fats
UPDATE display_metrics SET parent_metric_id = 'DISP_HEALTHY_FAT_USAGE'
WHERE display_metric_id IN (
  'DISP_HEALTHY_FAT_SWAPS',
  'DISP_HEALTHY_FAT_SWAPS_BREAKFAST',
  'DISP_HEALTHY_FAT_SWAPS_LUNCH',
  'DISP_HEALTHY_FAT_SWAPS_DINNER',
  'DISP_HEALTHY_FAT_RATIO',
  'DISP_FAT_SOURCES',
  'DISP_FAT_SOURCE_COUNT',
  'DISP_MONOUNATURATED_FAT_G',
  'DISP_POLYUNSATURATED_FAT_G'
);

-- Processed Meat
UPDATE display_metrics SET parent_metric_id = 'DISP_PROCESSED_MEAT_SERVING'
WHERE display_metric_id IN (
  'DISP_PROCESS_MEAT_BREAKFAST',
  'DISP_PROCESS_MEAT_LUNCH',
  'DISP_PROCESS_MEAT_DINNER'
);

-- Plant-Based Meals
UPDATE display_metrics SET parent_metric_id = 'DISP_PLANT_BASED_MEAL'
WHERE display_metric_id IN (
  'DISP_PLANT_BASED_MEALS_BREAKFAST',
  'DISP_PLANT_BASED_MEALS_LUNCH',
  'DISP_PLANT_BASED_MEALS_DINNER'
);

-- Mindful Eating
UPDATE display_metrics SET parent_metric_id = 'DISP_MINDFUL_EATING_EPISODES'
WHERE display_metric_id IN (
  'DISP_MINDFUL_EATING_BREAKFAST',
  'DISP_MINDFUL_EATING_LUNCH',
  'DISP_MINDFUL_EATING_DINNER'
);

-- Large Meals
UPDATE display_metrics SET parent_metric_id = 'DISP_LARGE_MEALS'
WHERE display_metric_id IN (
  'DISP_LARGE_MEALS_BREAKFAST',
  'DISP_LARGE_MEALS_LUNCH',
  'DISP_LARGE_MEALS_DINNER'
);

-- =====================================================================================
-- MOVEMENT + EXERCISE
-- =====================================================================================

-- Cardio
UPDATE display_metrics SET parent_metric_id = 'DISP_CARDIO_DURATION'
WHERE display_metric_id IN (
  'DISP_CARDIO_SESSIONS',
  'DISP_CALORIES'
);

-- HIIT
UPDATE display_metrics SET parent_metric_id = 'DISP_HIIT_DURATION'
WHERE display_metric_id IN (
  'DISP_HIIT_SESSION',
  'DISP_HIIT_SESSIONS'
);

-- Mobility
UPDATE display_metrics SET parent_metric_id = 'DISP_MOBILITY_DURATION'
WHERE display_metric_id IN (
  'DISP_MOBILITY_SESSION',
  'DISP_MOBILITY_SESSIONS'
);

-- Strength Training
UPDATE display_metrics SET parent_metric_id = 'DISP_STRENGTH_TRAINING_DURATION'
WHERE display_metric_id IN (
  'DISP_STRENGTH_TRAINING_SESSION',
  'DISP_STRENGTH_TRAINING_SESSIONS',
  'DISP_STRENGTH_SESSIONS'
);

-- Zone 2 Cardio
UPDATE display_metrics SET parent_metric_id = 'DISP_ZONE_2_CARDIO_DURATION'
WHERE display_metric_id IN (
  'DISP_ZONE_2_CARDIO_SESSION',
  'DISP_ZONE_2_CARDIO_SESSIONS'
);

-- Post Meal Activity
UPDATE display_metrics SET parent_metric_id = 'DISP_POST_MEAL_ACTIVITY_DURATION'
WHERE display_metric_id IN (
  'DISP_POST_MEAL_ACTIVITY_SESSIONS',
  'DISP_POST_MEAL_ACTIVITY_SESSIONS_BREAKFAST',
  'DISP_POST_MEAL_ACTIVITY_SESSIONS_LUNCH',
  'DISP_POST_MEAL_ACTIVITY_SESSIONS_DINNER',
  'DISP_POST_MEAL_EXERCISE_SNACKS',
  'DISP_POST_MEAL_EXERCISE_SNACKS_BREAKFAST',
  'DISP_POST_MEAL_EXERCISE_SNACKS_LUNCH',
  'DISP_POST_MEAL_EXERCISE_SNACKS_DINNER'
);

-- Exercise Snacks
UPDATE display_metrics SET parent_metric_id = 'DISP_EXERCISE_SNACKS'
WHERE display_metric_id IN (
  'DISP_EXERCISE_SNACK'
);

-- Sedentary Time
UPDATE display_metrics SET parent_metric_id = 'DISP_SEDENTARY_TIME'
WHERE display_metric_id IN (
  'DISP_SEDENTARY_SESSIONS',
  'DISP_SEDENTARY_PERIOD'
);

-- =====================================================================================
-- RESTORATIVE SLEEP
-- =====================================================================================

-- Total Sleep Duration (main parent)
UPDATE display_metrics SET parent_metric_id = 'DISP_TOTAL_SLEEP_DURATION'
WHERE display_metric_id IN (
  -- Sleep Stages (duration)
  'DISP_DEEP_SLEEP_DURATION',
  'DISP_CORE_SLEEP_DURATION',
  'DISP_REM_SLEEP_DURATION',
  'DISP_AWAKE_DURATION',
  -- Sleep Stages (percentage)
  'DISP_DEEP_PERCENTAGE',
  'DISP_CORE_PERCENTAGE',
  'DISP_REM_PERCENTAGE',
  'DISP_AWAKE_PERCENTAGE',
  -- Sleep Quality
  'DISP_SLEEP_EFFICIENCY',
  'DISP_SLEEP_LATENCY',
  'DISP_AWAKE_EPISODE_COUNT',
  -- Consistency
  'DISP_SLEEP_TIME_CONSISTENCY',
  'DISP_WAKE_TIME_CONSISTENCY',
  -- Other metrics
  'DISP_TIME_IN_BED_DURATION',
  'DISP_SLEEP_SESSIONS'
);

-- =====================================================================================
-- VERIFICATION
-- =====================================================================================

-- Show parent metrics and their children counts
SELECT
  parent.display_metric_id as parent_id,
  parent.display_name as parent_name,
  parent.pillar,
  COUNT(child.id) as child_count
FROM display_metrics parent
LEFT JOIN display_metrics child ON child.parent_metric_id = parent.display_metric_id
WHERE parent.parent_metric_id IS NULL
  AND EXISTS (
    SELECT 1 FROM display_metrics c2
    WHERE c2.parent_metric_id = parent.display_metric_id
  )
GROUP BY parent.display_metric_id, parent.display_name, parent.pillar
ORDER BY parent.pillar, parent.display_name;
