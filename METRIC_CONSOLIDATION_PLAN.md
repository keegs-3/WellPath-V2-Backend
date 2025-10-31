# Metric Consolidation Plan

## Problem

z_old_display_metrics has 270 metrics with lots of duplication:
- 57 metrics split by meal timing (Breakfast/Lunch/Dinner)
- Missing entire pillars in new table (Cognitive Health, Connection + Purpose, Core Care, Stress Management)

## Solution Strategy

### 1. Meal Timing Consolidation

Instead of separate metrics per meal, create ONE parent metric with meal timing as data series.

**Pattern:**
```
OLD:
- Protein Servings: Breakfast (DM_047)
- Protein Servings: Lunch (DM_048)
- Protein Servings: Dinner (DM_049)

NEW:
- Protein Meal Timing (DISP_PROTEIN_MEAL_TIMING)
  → Links to AGG_PROTEIN_BREAKFAST_GRAMS
  → Links to AGG_PROTEIN_LUNCH_GRAMS
  → Links to AGG_PROTEIN_DINNER_GRAMS
```

### 2. Metrics to Consolidate

#### Protein
- `Protein Servings: Breakfast/Lunch/Dinner` → **DISP_PROTEIN_MEAL_TIMING**

#### Fiber
- `Fiber Servings: Breakfast/Lunch/Dinner` → **DISP_FIBER_MEAL_TIMING**

#### Legumes
- `Legume Servings: Breakfast/Lunch/Dinner` → **DISP_LEGUME_MEAL_TIMING**

#### Vegetables
- `Vegetable Servings: Breakfast/Lunch/Dinner` → **DISP_VEGETABLE_MEAL_TIMING**

#### Fruits
- `Fruit Servings: Breakfast/Lunch/Dinner` → **DISP_FRUIT_MEAL_TIMING**

#### Whole Grains
- `Whole Grain Servings: Breakfast/Lunch/Dinner` → **DISP_WHOLE_GRAIN_MEAL_TIMING**

#### Added Sugar
- `Added Sugar Servings: Breakfast/Lunch/Dinner` → **DISP_ADDED_SUGAR_MEAL_TIMING**

#### Saturated Fat
- `Saturated Fat: Breakfast/Lunch/Dinner` → **DISP_SATURATED_FAT_MEAL_TIMING**

#### Healthy Fat Swaps
- `Healthy Fat Swaps: Breakfast/Lunch/Dinner` → **DISP_HEALTHY_FAT_SWAPS_TIMING**

#### Processed Foods
- `Ultraprocessed Food Servings: Breakfast/Lunch/Dinner` → **DISP_ULTRAPROCESSED_MEAL_TIMING**
- `Process Meat: Breakfast/Lunch/Dinner` → **DISP_PROCESSED_MEAT_TIMING**

#### Meal Quality
- `Whole Food Meals: Breakfast/Lunch/Dinner` → **DISP_WHOLE_FOOD_MEALS_TIMING**
- `Plant Based Meals: Breakfast/Lunch/Dinner` → **DISP_PLANT_BASED_MEALS_TIMING**
- `Mindful Eating: Breakfast/Lunch/Dinner` → **DISP_MINDFUL_EATING_TIMING**
- `Takeout/Delivery Meals: Breakfast/Lunch/Dinner` → **DISP_TAKEOUT_MEALS_TIMING**
- `Large Meals: Breakfast/Lunch/Dinner` → **DISP_LARGE_MEALS_TIMING**

#### Post-Meal Activity
- `Post Meal Activity Sessions: Breakfast/Lunch/Dinner` → **DISP_POST_MEAL_ACTIVITY_TIMING**
- `Post Meal Exercise Snacks: Breakfast/Lunch/Dinner` → **DISP_POST_MEAL_EXERCISE_TIMING**

### 3. Standalone Metrics to Migrate (No Consolidation)

These don't have meal-timing variants, migrate as-is:

#### Core Care (72 metrics)
- BMI, Body Fat %, Blood Pressure, Weight, Height
- Compliance metrics (Mammogram, Colonoscopy, Dental, etc.)
- Medication/Supplement adherence
- Smoking, Alcohol tracking
- Sunscreen compliance
- Morning routine metrics

#### Cognitive Health (8 metrics)
- Brain Training
- Focus/Memory ratings
- Journaling
- Mood tracking
- Sunlight exposure

#### Connection + Purpose (11 metrics)
- Social interaction
- Gratitude sessions
- Mindfulness
- Outdoor time
- Stress level
- Screen time

#### Stress Management (7 metrics)
- Meditation
- Breathwork
- Stress management sessions

### 4. Already Migrated

These are already in display_metrics:
- Sleep metrics (Sleep Analysis, Duration, Consistency)
- Basic nutrition totals (Protein Grams, Fiber, Water)
- Exercise metrics (Steps, Cardio, Strength)

## Implementation Steps

1. ✅ Document consolidation patterns
2. Create migration to add consolidated metrics to display_metrics
3. Link consolidated metrics to their aggregations via display_metrics_aggregations
4. Migrate standalone metrics (Core Care, Cognitive, Connection, Stress)
5. Verify all 270 metrics accounted for
6. Update mobile app to query consolidated metrics

## Database Structure

Each consolidated metric follows this pattern:

```sql
-- Add metric
INSERT INTO display_metrics (
  metric_id,
  metric_name,
  category,
  pillar,
  chart_type_id
) VALUES (
  'DISP_PROTEIN_MEAL_TIMING',
  'Protein by Meal',
  'nutrition',
  'Healthful Nutrition',
  'bar_stacked_vertical'
);

-- Link to aggregations (3 data series)
INSERT INTO display_metrics_aggregations (
  metric_id,
  agg_metric_id,
  period_type,
  calculation_type_id,
  display_order,
  series_label
) VALUES
  ('DISP_PROTEIN_MEAL_TIMING', 'AGG_PROTEIN_BREAKFAST_GRAMS', 'daily', 'SUM', 1, 'Breakfast'),
  ('DISP_PROTEIN_MEAL_TIMING', 'AGG_PROTEIN_LUNCH_GRAMS', 'daily', 'SUM', 2, 'Lunch'),
  ('DISP_PROTEIN_MEAL_TIMING', 'AGG_PROTEIN_DINNER_GRAMS', 'daily', 'SUM', 3, 'Dinner');
```

## Expected Result

**Before:** 270 metrics in z_old_display_metrics (redundant)
**After:** ~150 metrics in display_metrics (consolidated + standalone)

Reduction: 120 redundant metrics eliminated
