# Data Entry Fields → Aggregation Metrics Coverage Plan

## Current Status

- **Total fields**: 226
- **Covered**: 85 (38%)
- **Missing**: 141 (62%)

---

## Missing Fields Breakdown

### By Field Type:
| Field Type | Count | Pattern Type |
|------------|-------|--------------|
| timestamp  | 124   | Mixed (Events + Counters) |
| measurement| 13    | Pattern 1: Measurements |
| category   | 4     | Reference data |
| reference  | 2     | FK lookups |
| quantity   | 1     | Pattern 1: Measurement |

---

## Implementation Plan

### Phase 1: Measurements (14 fields) ✅ READY TO IMPLEMENT

**Pattern**: Direct aggregation (most_recent, 7d_avg, 30d_avg, 30d_max, 30d_min)

**Fields**:
1. body_fat_measured
2. diastolic_blood_pressure_measured
3. grip_strength
4. height_measured
5. hip_measurement
6. hrv_measured
7. lean_body_mass_measured
8. resting_heart_rate_measured
9. skeletal_muscle_mass_measured
10. systolic_blood_pressure
11. visceral_fat_measured
12. vo2_max_measured
13. waist_measurement
14. step_taken (quantity)

**Action**: Create 14 aggregation_metrics, each with dependencies pointing directly to the data_entry_field.

---

### Phase 2: Therapeutics (75+ fields) ✅ DONE

**Pattern**: Event-based with 3 reusable fields

**Status**: Already implemented via therapeutic_intake event type

**Replaced**: All DEF_114+ therapeutic timestamp fields (supplements, medications, peptides)

---

### Phase 3: Activity Sessions (~20 fields)

**Pattern**: Event-based with start/end times → duration calculation

**Field Pairs** (start/end):
- strength_session (DEF_037, DEF_038)
- hiit_session (DEF_039, DEF_040)
- mobility_session (DEF_041, DEF_042)
- exercise_snack (DEF_043, DEF_044)
- zone2_cardio_session (DEF_045, DEF_046)
- active_time (DEF_048, DEF_049)
- sedentary_time (DEF_050, DEF_051)
- meditation_session (DEF_076, DEF_077)
- stress_management_session (DEF_078, DEF_079)
- gratitude_practice_session (DEF_083, DEF_084)
- outdoor_time_session (DEF_085, DEF_086)
- screen_time_session (DEF_087, DEF_088)
- brain_training_session (DEF_089, DEF_090)
- journaling_session (DEF_091, DEF_092)
- mindfulness_session (DEF_095, DEF_096)
- breathwork_session (DEF_097, DEF_098)
- sunlight_exposure (DEF_101, DEF_102)
- walking_session (DEF_103, DEF_104)

**Action**:
1. Create event_types for each activity category
2. Create instance_calculation for duration (end_time - start_time)
3. Create aggregation_metrics for total_duration, frequency, average_duration

---

### Phase 4: Preventive Care Screenings (~10 fields)

**Pattern**: Counter (frequency) + Days since last

**Fields**:
- dental_screening_date (DEF_055)
- physical_exam_date (DEF_056)
- skin_check_date (DEF_057)
- vision_check_date (DEF_058)
- colonoscopy_date (DEF_059)
- mammogram_date (DEF_060)
- breast_mri_date (DEF_061)
- hpv_date (DEF_062)
- pap_date (DEF_063)
- psa_date (DEF_064)

**Action**:
1. Create event_type: "preventive_screening"
2. Create instance_calculation: days_since_last_screening
3. Create aggregation_metrics: screening_adherence_score

---

### Phase 5: Sleep Periods (~10 fields - Apple Health)

**Pattern**: Event-based with duration + stage percentages

**Fields**:
- awake_period (DEF_222, DEF_223)
- core_sleep (DEF_218, DEF_219)
- deep_sleep (DEF_220, DEF_221)
- rem_sleep (DEF_224, DEF_225)
- sleep_time (DEF_054)
- wake_time (DEF_003)

**Action**:
1. Create event_type: "sleep_session"
2. Create instance_calculations: total_sleep_duration, rem_percentage, deep_percentage
3. Create aggregation_metrics: avg_sleep_duration_7d, avg_rem_pct_30d

---

### Phase 6: Meal/Nutrition Timestamps (~10 fields)

**Pattern**: Counter (frequency)

**Fields**:
- meal_logged (DEF_001)
- large_meal (DEF_002)
- mindful_eating_episode (DEF_004)
- whole_food_meal (DEF_005)
- takeout_delivery_meal (DEF_006)
- plant_based_meal (DEF_007)
- snack_logged (DEF_008)

**Action**:
1. Link to existing event_type: "meal"
2. Create aggregation_metrics: meal_frequency, meal_type_distribution

---

### Phase 7: Health Behaviors (~10 fields)

**Pattern**: Counter (frequency)

**Fields**:
- healthy_fat_swap (DEF_027)
- healthy_fat_usage (DEF_028)
- sleep_routine_adherence (DEF_052)
- supplement_taken (DEF_065) [general]
- medication_taken (DEF_066) [general]
- peptide_taken (DEF_067) [general]
- brushing_session (DEF_068)
- flossing_session (DEF_069)
- skincare_routine (DEF_070)
- sunscreen_application (DEF_071)
- social_interaction (DEF_082)
- evening_routine (DEF_105)

**Action**:
1. Create event_type: "health_behavior"
2. Create aggregation_metrics: behavior_frequency, adherence_score

---

### Phase 8: Ratings (~4 fields)

**Pattern**: Measurement (daily avg, weekly avg)

**Fields**:
- sleep_environment_score (DEF_053)
- stress_level_rating (DEF_080)
- mood_rating (DEF_081)
- focus_rating (DEF_093)
- memory_clarity_rating (DEF_094)

**Action**:
1. Create aggregation_metrics for each (7d_avg, 30d_avg, trend)

---

### Phase 9: Reference/Category Fields (6 fields)

**Pattern**: No aggregation needed (descriptive data)

**Fields**:
- fruit_source_type (DEF_010)
- vegetable_source_type (DEF_012)
- fiber_source_type (DEF_018)
- whole_grain_source_type (DEF_020)
- caffeine_source (DEF_034)
- birth_date (DEF_109)
- gender (DEF_110)

**Action**: Document as non-aggregating fields (used for filtering/segmentation only)

---

## Recommended Implementation Order

1. **Phase 1: Measurements** (quick win, 14 fields, simple pattern)
2. **Phase 8: Ratings** (quick win, 5 fields, simple pattern)
3. **Phase 3: Activity Sessions** (medium effort, 18 pairs = 36 fields)
4. **Phase 5: Sleep Periods** (medium effort, Apple Health integration)
5. **Phase 4: Preventive Care** (low effort, 10 fields)
6. **Phase 6: Meal Timestamps** (low effort, 7 fields)
7. **Phase 7: Health Behaviors** (low effort, 12 fields)
8. **Phase 9: Reference fields** (document only, no implementation)

---

## Success Metrics

- **Target**: 220/226 fields covered (97%) - excluding 6 reference fields
- **Current**: 85/226 (38%)
- **Gap**: 135 fields to implement

**After Phase 1+8**: 104/226 (46%)
**After Phase 1+3+5+8**: 158/226 (70%)
**After all phases**: 220/226 (97%) ✅

---

*Created: 2025-10-19*
