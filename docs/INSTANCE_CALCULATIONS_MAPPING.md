# Instance Calculations Mapping

## Overview
This document maps all data_entry_fields to their required instance_calculations and eventual event_types.

## Architecture Flow
```
data_entry_fields → instance_calculations → event_types → aggregation_metrics
```

## Instance Calculation Categories

### 1. Duration-Based (Start/End Time Pairs)

| Activity | Start Field | End Field | Calculation | Status |
|----------|-------------|-----------|-------------|--------|
| Cardio | DEF_CARDIO_START | DEF_CARDIO_END | IC_001 cardio_duration | ✅ Exists |
| Strength | DEF_STRENGTH_START | DEF_STRENGTH_END | IC_002 strength_duration | ✅ Exists |
| Flexibility | DEF_FLEXIBILITY_START | DEF_FLEXIBILITY_END | IC_003 flexibility_duration | ✅ Exists (needs rename to mobility) |
| **Mobility** | DEF_MOBILITY_START | DEF_MOBILITY_END | **IC_003b mobility_duration** | ⚠️ Need new |
| Mindfulness | DEF_MINDFULNESS_START | DEF_MINDFULNESS_END | IC_004 mindfulness_duration | ✅ Exists |
| **HIIT** | DEF_HIIT_START | DEF_HIIT_END | **IC_007 hiit_duration** | ❌ Missing |
| Sleep Session | DEF_SLEEP_SESSION_START | DEF_SLEEP_SESSION_END | IC_006 sleep_session_duration | ✅ Exists |
| Sleep Period | DEF_SLEEP_PERIOD_START | DEF_SLEEP_PERIOD_END | IC_005 sleep_period_duration | ✅ Exists |
| **Outdoor Time** | DEF_OUTDOOR_START | DEF_OUTDOOR_END | **IC_008 outdoor_duration** | ❌ Missing |
| **Sunlight Exposure** | DEF_SUNLIGHT_START | DEF_SUNLIGHT_END | **IC_009 sunlight_duration** | ❌ Missing |

### 2. Cross-Field Measurements

| Calculation | Fields Required | Calculation | Status |
|-------------|-----------------|-------------|--------|
| BMI | DEF_WEIGHT, DEF_HEIGHT | IC_020 bmi_calculated | ✅ Exists |
| Waist-to-Hip Ratio | DEF_WAIST, DEF_HIP | IC_021 hip_to_waist_ratio | ✅ Exists |
| Body Fat Mass | DEF_WEIGHT, DEF_BODY_FAT_PCT | IC_024 body_fat_mass | ✅ Exists |
| Skeletal Muscle Mass | DEF_LEAN_MASS | IC_023 skeletal_muscle_mass | ✅ Exists |
| Blood Pressure (Combined) | DEF_BLOOD_PRESSURE_SYS, DEF_BLOOD_PRESSURE_DIA | **IC_026 blood_pressure_combined** | ❌ Missing |

### 3. Contextual/Temporal Patterns

| Pattern | Fields Required | Calculation | Status |
|---------|-----------------|-------------|--------|
| Post-Meal Exercise | DEF_MEAL_TIME, DEF_CARDIO_START, DEF_STRENGTH_START, DEF_HIIT_START | IC_061 post_meal_exercise_occurred | ✅ Exists |
| Post-Meal Activity Window | DEF_MEAL_TIME, activity starts | IC_060 post_meal_activity_window | ✅ Exists |
| Last Meal to Sleep Gap | DEF_MEAL_TIME, DEF_SLEEP_SESSION_START | IC_050 last_meal_to_sleep_gap | ✅ Exists |
| First Meal Delay | DEF_SLEEP_SESSION_END, DEF_MEAL_TIME | IC_051 first_meal_delay | ✅ Exists |
| Eating Window Duration | First DEF_MEAL_TIME, Last DEF_MEAL_TIME | IC_052 eating_window_duration | ✅ Exists |
| Exercise to Sleep Window | Last exercise end, DEF_SLEEP_SESSION_START | IC_070 exercise_to_sleep_window | ✅ Exists |
| **Caffeine to Sleep Window** | DEF_CAFFEINE_TIME, DEF_SLEEP_SESSION_START | **IC_071 caffeine_to_sleep_window** | ❌ Missing |
| **Alcohol to Sleep Window** | DEF_ALCOHOL_TIME, DEF_SLEEP_SESSION_START | **IC_072 alcohol_to_sleep_window** | ❌ Missing |
| Sleep Efficiency | IC_006, IC_042 | IC_040 sleep_efficiency | ✅ Exists |
| Sleep Time Consistency | Multiple DEF_SLEEP_SESSION_START | IC_080 sleep_time_consistency | ✅ Exists |

### 4. Single-Event Logged Items (No calculation, just event creation)

These don't need instance_calculations but do need event_types:

**Nutrition:**
- Protein logged (DEF_PROTEIN_QUANTITY, DEF_PROTEIN_TYPE, DEF_PROTEIN_TIME)
- Fat logged (DEF_FAT_QUANTITY, DEF_FAT_TYPE, DEF_FAT_TIME)
- Fiber logged (DEF_FIBER_QUANTITY, DEF_FIBER_SOURCE, DEF_FIBER_TIME)
- Legume logged (DEF_LEGUME_QUANTITY, DEF_LEGUME_TYPE, DEF_LEGUME_TIME)
- Nut/Seed logged (DEF_NUT_SEED_QUANTITY, DEF_NUT_SEED_TYPE, DEF_NUT_SEED_TIME)
- Whole Grain logged (DEF_WHOLE_GRAIN_QUANTITY, DEF_WHOLE_GRAIN_TYPE, DEF_WHOLE_GRAIN_TIME)
- Fruit logged (DEF_FRUIT_QUANTITY, DEF_FRUIT_TYPE, DEF_FRUIT_TIME)
- Vegetable logged (DEF_VEGETABLE_QUANTITY, DEF_VEGETABLE_TYPE, DEF_VEGETABLE_TIME)
- Meal logged (DEF_MEAL_TYPE, DEF_MEAL_SIZE, DEF_MEAL_TIME)
- Caffeine logged (DEF_CAFFEINE_QUANTITY, DEF_CAFFEINE_TYPE, DEF_CAFFEINE_TIME)
- Alcohol logged (DEF_ALCOHOL_QUANTITY, DEF_ALCOHOL_TYPE, DEF_ALCOHOL_TIME)
- Unhealthy Beverage logged (DEF_UNHEALTHY_BEV_QUANTITY, DEF_UNHEALTHY_BEV_TYPE, DEF_UNHEALTHY_BEV_TIME)

**Biometrics:**
- Weight logged (DEF_WEIGHT, DEF_WEIGHT_TIME)
- Blood Pressure logged (DEF_BLOOD_PRESSURE_SYS, DEF_BLOOD_PRESSURE_DIA, DEF_BLOOD_PRESSURE_TIME)
- Body Fat logged (DEF_BODY_FAT_PCT, DEF_BODY_FAT_TIME)
- Waist logged (DEF_WAIST, DEF_WAIST_TIME)
- Hip logged (DEF_HIP, DEF_HIP_TIME)

**Cognitive:**
- Mood logged (DEF_MOOD_RATING, DEF_MOOD_TIME)
- Focus logged (DEF_FOCUS_RATING, DEF_FOCUS_TIME)
- Memory Clarity logged (DEF_MEMORY_CLARITY_RATING, DEF_MEMORY_CLARITY_TIME)

**Core Care:**
- Brushing logged (DEF_BRUSHING_TIME)
- Flossing logged (DEF_FLOSSING_TIME)
- Skincare logged (DEF_SKINCARE_STEP, DEF_SKINCARE_TIME)
- Sunscreen logged (DEF_SUNSCREEN_TYPE, DEF_SUNSCREEN_TIME)

**Social:**
- Social Event logged (DEF_SOCIAL_EVENT_TYPE, DEF_SOCIAL_EVENT_TIME)
- Gratitude logged (DEF_GRATITUDE_ENTRY, DEF_GRATITUDE_TIME)

**Screen Time:**
- Screen Time logged (DEF_SCREEN_TIME_QUANTITY, DEF_SCREEN_TIME_TYPE, DEF_SCREEN_TIME_DATE)

**Daily Habits:**
- Journal Entry logged (DEF_JOURNAL_ENTRY, DEF_JOURNAL_TIME)
- Brain Training logged (DEF_BRAIN_TRAINING_TYPE, DEF_BRAIN_TRAINING_TIME)

## Missing Instance Calculations Summary

### High Priority (Duration-Based)
1. **IC_007 hiit_duration** - HIIT workout duration
2. **IC_003b mobility_duration** - Mobility/flexibility duration (rename from flexibility)
3. **IC_008 outdoor_duration** - Outdoor time duration
4. **IC_009 sunlight_duration** - Sunlight exposure duration

### Medium Priority (Contextual)
5. **IC_071 caffeine_to_sleep_window** - Hours between last caffeine and sleep
6. **IC_072 alcohol_to_sleep_window** - Hours between last alcohol and sleep

### Low Priority (Cross-Field)
7. **IC_026 blood_pressure_combined** - Combined BP reading (may not be needed if we just log sys/dia separately)

## Event Types Design

Every event should have:
- `event_type_id` (unique identifier)
- `event_type_name` (e.g., 'cardio_session', 'weight_logged', 'meal_logged')
- `display_name` (user-facing name)
- `category` (nutrition, movement, biometric, cognitive, social, core_care)
- `has_duration` (boolean - whether this is a duration-based event)
- `instance_calculation_id` (if has_duration or cross-field calc)
- `required_fields` (array of data_entry_field_ids needed)
- `optional_fields` (array of optional data_entry_field_ids)

### Event Type Categories

**Duration Events (has_duration = true):**
- cardio_session (IC_001 + DEF_CARDIO_START, DEF_CARDIO_END, DEF_CARDIO_TYPE, DEF_CARDIO_DISTANCE, DEF_CARDIO_INTENSITY)
- strength_session (IC_002 + DEF_STRENGTH_START, DEF_STRENGTH_END, DEF_STRENGTH_TYPE, DEF_STRENGTH_INTENSITY)
- hiit_session (IC_007 + DEF_HIIT_START, DEF_HIIT_END, DEF_HIIT_TYPE, DEF_HIIT_INTENSITY)
- mobility_session (IC_003b + DEF_MOBILITY_START, DEF_MOBILITY_END, DEF_MOBILITY_TYPE, DEF_MOBILITY_INTENSITY)
- mindfulness_session (IC_004 + DEF_MINDFULNESS_START, DEF_MINDFULNESS_END, DEF_MINDFULNESS_TYPE)
- sleep_session (IC_006 + DEF_SLEEP_SESSION_START, DEF_SLEEP_SESSION_END, DEF_SLEEP_QUALITY)
- outdoor_time (IC_008 + DEF_OUTDOOR_START, DEF_OUTDOOR_END)
- sunlight_exposure (IC_009 + DEF_SUNLIGHT_START, DEF_SUNLIGHT_END, DEF_SUNLIGHT_TYPE)

**Logged Events (has_duration = false, no instance_calc):**
- All the single-event items listed above

**Calculated Events (has instance_calc but not duration-based):**
- bmi_measurement (IC_020 + DEF_WEIGHT, DEF_HEIGHT, DEF_WEIGHT_TIME)
- body_composition_assessment (IC_024 + DEF_WEIGHT, DEF_BODY_FAT_PCT, DEF_BODY_FAT_TIME)
- waist_hip_ratio_measurement (IC_021 + DEF_WAIST, DEF_HIP, DEF_WAIST_TIME, DEF_HIP_TIME)

## Next Steps

1. ✅ Create missing instance_calculations (IC_007, IC_008, IC_009, IC_071, IC_072)
2. Create event_types table schema
3. Populate event_types for all activities
4. Create linking tables (event_types_fields, event_types_calculations)
5. Test event creation flow
