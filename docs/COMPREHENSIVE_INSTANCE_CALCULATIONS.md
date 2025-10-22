# Comprehensive Instance Calculations Design

## Purpose
Instance calculations compute values for INDIVIDUAL instances/events, NOT aggregations over time.
They serve as the bridge between raw data_entry_fields and aggregation_metrics.

## Categories of Instance Calculations

### 1. DURATION CALCULATIONS (Single Session/Period)
Each start/end pair creates ONE duration calculation for ONE instance.

| Calc ID | Name | Description | Fields Required |
|---------|------|-------------|-----------------|
| IC_001 | cardio_session_duration | Duration of ONE cardio session | DEF_CARDIO_START, DEF_CARDIO_END |
| IC_002 | strength_session_duration | Duration of ONE strength session | DEF_STRENGTH_START, DEF_STRENGTH_END |
| IC_003 | mobility_session_duration | Duration of ONE mobility session | DEF_MOBILITY_START, DEF_MOBILITY_END |
| IC_004 | mindfulness_session_duration | Duration of ONE mindfulness session | DEF_MINDFULNESS_START, DEF_MINDFULNESS_END |
| IC_005 | hiit_session_duration | Duration of ONE HIIT session | DEF_HIIT_START, DEF_HIIT_END |
| IC_006 | outdoor_time_duration | Duration of ONE outdoor time block | DEF_OUTDOOR_START, DEF_OUTDOOR_END |
| IC_007 | sunlight_exposure_duration | Duration of ONE sunlight exposure | DEF_SUNLIGHT_START, DEF_SUNLIGHT_END |
| IC_008 | brain_training_duration | Duration of ONE brain training session | DEF_BRAIN_TRAINING_START, DEF_BRAIN_TRAINING_END |
| IC_009 | journaling_duration | Duration of ONE journaling session | DEF_JOURNALING_START, DEF_JOURNALING_END |
| IC_010 | sleep_session_duration | Duration of ONE complete sleep session (bed to wake) | DEF_SLEEP_SESSION_START, DEF_SLEEP_SESSION_END |

### 2. SLEEP PERIOD DURATIONS (Individual Periods Within Session)
Each sleep period (REM, deep, core, awake) within a session gets its own duration.

| Calc ID | Name | Description | Fields Required |
|---------|------|-------------|-----------------|
| IC_020 | rem_sleep_period_duration | Duration of ONE REM period | DEF_SLEEP_PERIOD_START, DEF_SLEEP_PERIOD_END (where type=REM) |
| IC_021 | deep_sleep_period_duration | Duration of ONE deep sleep period | DEF_SLEEP_PERIOD_START, DEF_SLEEP_PERIOD_END (where type=deep) |
| IC_022 | core_sleep_period_duration | Duration of ONE core sleep period | DEF_SLEEP_PERIOD_START, DEF_SLEEP_PERIOD_END (where type=core) |
| IC_023 | awake_period_duration | Duration of ONE awake period | DEF_SLEEP_PERIOD_START, DEF_SLEEP_PERIOD_END (where type=awake) |

### 3. CROSS-FIELD BIOMETRIC CALCULATIONS (Single Measurement Instance)
Calculated from multiple fields at ONE point in time.

| Calc ID | Name | Description | Fields Required |
|---------|------|-------------|-----------------|
| IC_030 | bmi_calculated | BMI from ONE weight/height measurement | DEF_WEIGHT, DEF_HEIGHT |
| IC_031 | waist_to_hip_ratio | WHR from ONE waist/hip measurement | DEF_WAIST, DEF_HIP |
| IC_032 | waist_to_height_ratio | WHtR from ONE waist/height measurement | DEF_WAIST, DEF_HEIGHT |
| IC_033 | body_fat_mass | Fat mass from ONE weight/bodyfat measurement | DEF_WEIGHT, DEF_BODY_FAT_PCT |
| IC_034 | lean_body_mass | Lean mass from ONE weight/bodyfat measurement | DEF_WEIGHT, DEF_BODY_FAT_PCT |

### 4. TEMPORAL RELATIONSHIP CALCULATIONS (Cross-Instance Timing)
Relationships between TWO different instances (meal → exercise, caffeine → sleep, etc.)

#### Meal-Related Timing
| Calc ID | Name | Description | Fields Required |
|---------|------|-------------|-----------------|
| IC_040 | post_meal_to_exercise_window | Time from THIS meal to NEXT exercise | DEF_MEAL_TIME, DEF_CARDIO_START/DEF_STRENGTH_START/DEF_HIIT_START |
| IC_041 | post_meal_to_snack_window | Time from THIS meal to NEXT small meal | DEF_MEAL_TIME (current), DEF_MEAL_TIME (next), DEF_MEAL_SIZE |
| IC_042 | pre_workout_meal_window | Time from LAST meal to THIS workout | DEF_MEAL_TIME, DEF_CARDIO_START/DEF_STRENGTH_START/DEF_HIIT_START |
| IC_043 | last_meal_to_sleep_gap | Time from LAST meal to THIS sleep session | DEF_MEAL_TIME, DEF_SLEEP_SESSION_START |
| IC_044 | first_meal_after_wake_delay | Time from wake to FIRST meal | DEF_SLEEP_SESSION_END, DEF_MEAL_TIME |
| IC_045 | eating_window_duration | Time from FIRST meal to LAST meal of day | DEF_MEAL_TIME (first), DEF_MEAL_TIME (last) |

#### Substance-Related Timing
| Calc ID | Name | Description | Fields Required |
|---------|------|-------------|-----------------|
| IC_050 | caffeine_to_sleep_window | Time from LAST caffeine to THIS sleep | DEF_CAFFEINE_TIME, DEF_SLEEP_SESSION_START |
| IC_051 | alcohol_to_sleep_window | Time from LAST alcohol to THIS sleep | DEF_ALCOHOL_TIME, DEF_SLEEP_SESSION_START |
| IC_052 | caffeine_before_workout | Time from LAST caffeine to THIS workout | DEF_CAFFEINE_TIME, workout start times |
| IC_053 | water_around_workout | Water intake timing relative to THIS workout | DEF_WATER_TIME, workout times |

#### Exercise-Related Timing
| IC_060 | exercise_to_sleep_window | Time from LAST exercise to THIS sleep | Last exercise end, DEF_SLEEP_SESSION_START |
| IC_061 | exercise_recovery_window | Time from THIS workout to NEXT workout | Current exercise end, next exercise start |
| IC_062 | post_exercise_meal_window | Time from THIS workout to NEXT meal | Exercise end time, DEF_MEAL_TIME |

#### Screen Time & Sleep
| IC_070 | screen_time_before_sleep | Time from LAST screen use to THIS sleep | DEF_SCREEN_TIME_DATE, DEF_SLEEP_SESSION_START |
| IC_071 | digital_shutoff_buffer | Whether screen stopped X hours before sleep | DEF_SCREEN_TIME_DATE, DEF_SLEEP_SESSION_START |

### 5. NUTRITIONAL INSTANCE CALCULATIONS
Macronutrient calculations for ONE meal or ONE consumption instance.

| Calc ID | Name | Description | Fields Required |
|---------|------|-------------|-----------------|
| IC_080 | meal_protein_grams | Total protein in THIS meal | Sum of DEF_PROTEIN_QUANTITY for meal instance |
| IC_081 | meal_fat_grams | Total fat in THIS meal | Sum of DEF_FAT_QUANTITY for meal instance |
| IC_082 | meal_fiber_grams | Total fiber in THIS meal | Sum of DEF_FIBER_QUANTITY for meal instance |
| IC_083 | meal_macro_ratio | Protein:Fat:Carb ratio for THIS meal | Protein, fat, carb quantities |
| IC_084 | meal_serving_count | Total servings in THIS meal | Sum of all food quantities |
| IC_085 | protein_timing_score | Protein distribution quality for THIS meal | DEF_PROTEIN_QUANTITY, DEF_PROTEIN_TIME |

### 6. COMPLIANCE & SCREENING CALCULATIONS
Age-based and time-based compliance for individual screening instances.

| Calc ID | Name | Description | Fields Required |
|---------|------|-------------|-----------------|
| IC_090 | time_since_screening | Days since THIS screening | DEF_SCREENING_DATE, current_date |
| IC_091 | screening_compliance_status | Whether THIS screening is current | DEF_SCREENING_DATE, screening_type, patient_age |
| IC_092 | user_age | Patient's current age | DEF_DATE_OF_BIRTH, current_date |

### 7. ACTIVITY INTENSITY CALCULATIONS
Intensity-adjusted calculations for THIS activity instance.

| Calc ID | Name | Description | Fields Required |
|---------|------|-------------|-----------------|
| IC_100 | cardio_intensity_minutes | Intensity-adjusted minutes for THIS cardio | IC_001, DEF_CARDIO_INTENSITY |
| IC_101 | strength_intensity_minutes | Intensity-adjusted minutes for THIS strength | IC_002, DEF_STRENGTH_INTENSITY |
| IC_102 | hiit_intensity_minutes | Intensity-adjusted minutes for THIS HIIT | IC_005, DEF_HIIT_INTENSITY |
| IC_103 | zone2_qualification | Whether THIS cardio qualifies as Zone 2 | IC_001, DEF_CARDIO_INTENSITY, DEF_CARDIO_TYPE |

### 8. SLEEP QUALITY CALCULATIONS (Per Session)
Quality metrics for ONE sleep session.

| Calc ID | Name | Description | Fields Required |
|---------|------|-------------|-----------------|
| IC_110 | sleep_efficiency | % of time in bed actually sleeping in THIS session | IC_010, sum of IC_020-023 |
| IC_111 | total_sleep_duration | Total sleep time in THIS session (no awake) | Sum of IC_020, IC_021, IC_022 |
| IC_112 | total_awake_duration | Total awake time in THIS session | Sum of all IC_023 for session |
| IC_113 | rem_percentage | % REM in THIS session | IC_020 / IC_111 |
| IC_114 | deep_percentage | % deep in THIS session | IC_021 / IC_111 |
| IC_115 | core_percentage | % core in THIS session | IC_022 / IC_111 |

### 9. BOOLEAN/STATUS CALCULATIONS (Per Instance)
Yes/no determinations for individual instances.

| Calc ID | Name | Description | Fields Required |
|---------|------|-------------|-----------------|
| IC_120 | post_meal_exercise_occurred | Did exercise happen within 2h after THIS meal? | IC_040 |
| IC_121 | caffeine_cutoff_met | Was last caffeine >6h before THIS sleep? | IC_050 |
| IC_122 | alcohol_cutoff_met | Was last alcohol >3h before THIS sleep? | IC_051 |
| IC_123 | breakfast_within_hour | Was first meal within 1h of wake? | IC_044 |
| IC_124 | eating_window_under_12h | Was eating window <12h THIS day? | IC_045 |

## What Are NOT Instance Calculations

These belong in aggregation_metrics:

- **Daily totals** (total daily exercise, total daily protein, total daily steps)
- **Weekly averages** (average sleep duration, average workout frequency)
- **Multi-day patterns** (sleep consistency over week, exercise adherence rate)
- **Trends over time** (weight change trend, fitness improvement)
- **Compliance over period** (screening up-to-date over past year)

## Next Steps

1. ✅ Drop current instance_calculations table
2. ✅ Recreate with ONLY the calculations listed above
3. ✅ Create calculation_config for each with proper parameters
4. ✅ Create dependencies linking to data_entry_fields
5. ✅ Create event_types that use these calculations
6. Move aggregation logic to aggregation_metrics
