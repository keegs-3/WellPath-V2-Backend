# Metrics Consolidation Mapping

## Source: z_old_display_metrics (270 metrics)
## Target: display_metrics (current: 45, goal: ~120)

---

## Strategy

### 1. Meal-Timing Metrics → Consolidated Parents
**Pattern:** "X: Breakfast/Lunch/Dinner" → "X Meal Timing"

Example:
- DM_047: Protein Servings: Breakfast
- DM_048: Protein Servings: Lunch
- DM_049: Protein Servings: Dinner

→ Creates: **DISP_PROTEIN_MEAL_TIMING** (one metric, 3 data series)

### 2. Standalone Metrics → Direct Migration
Metrics without meal-timing variants migrate as-is.

---

## Consolidation Groups

### Healthful Nutrition (115 → ~35 metrics)

#### SCREEN_PROTEIN
| Old Metrics | New Consolidated Metric |
|------------|------------------------|
| Protein Servings: Breakfast/Lunch/Dinner | DISP_PROTEIN_MEAL_TIMING |
| Protein Grams (DM_045) | DISP_PROTEIN_GRAMS ✅ (exists) |
| Protein per Kilogram Body Weight (DM_046) | DISP_PROTEIN_PER_KG |
| Plant-Based Protein Percentage (DM_217) | DISP_PLANT_PROTEIN_PCT |
| plant-based protein (grams) (DM_218) | DISP_PLANT_PROTEIN_GRAMS |

#### SCREEN_FIBER
| Old Metrics | New Consolidated Metric |
|------------|------------------------|
| Fiber Servings: Breakfast/Lunch/Dinner | DISP_FIBER_MEAL_TIMING |
| Fiber Grams (DM_051) | DISP_FIBER_GRAMS ✅ (exists) |
| Fiber Source Count (DM_056) | DISP_FIBER_SOURCE_COUNT |
| DISP_FIBER_SOURCE_VARIETY | ✅ (exists) |

#### SCREEN_VEGETABLES
| Old Metrics | New Consolidated Metric |
|------------|------------------------|
| Vegetable Servings: Breakfast/Lunch/Dinner | DISP_VEGETABLE_MEAL_TIMING |
| Vegetable Source Count (DM_043) | DISP_VEGETABLE_SOURCE_COUNT |
| DISP_VEGETABLE_VARIETY | ✅ (exists) |

#### SCREEN_FRUITS
| Old Metrics | New Consolidated Metric |
|------------|------------------------|
| Fruit Servings: Breakfast/Lunch/Dinner | DISP_FRUIT_MEAL_TIMING |
| Fruit Source Count (DM_037) | DISP_FRUIT_SOURCE_COUNT |
| DISP_FRUIT_VARIETY | ✅ (exists) |

#### SCREEN_LEGUMES (NEW)
| Old Metrics | New Consolidated Metric |
|------------|------------------------|
| Legume Servings: Breakfast/Lunch/Dinner | DISP_LEGUME_MEAL_TIMING |
| Legume Source Count (DM_068) | DISP_LEGUME_SOURCE_COUNT |
| DISP_LEGUME_VARIETY | ✅ (exists) |

#### SCREEN_WHOLE_GRAINS (NEW)
| Old Metrics | New Consolidated Metric |
|------------|------------------------|
| Whole Grain Servings: Breakfast/Lunch/Dinner | DISP_WHOLE_GRAIN_MEAL_TIMING |
| Whole Grain Source Count (DM_062) | DISP_WHOLE_GRAIN_SOURCE_COUNT |
| DISP_WHOLE_GRAIN_VARIETY | ✅ (exists) |

#### SCREEN_HYDRATION
| Old Metrics | New Consolidated Metric |
|------------|------------------------|
| Water Consumption (DM_105) | DISP_WATER_CONSUMPTION ✅ (exists) |
| Caffeine Consumed (DM_102) | DISP_CAFFEINE_CONSUMED |
| Caffeine Source Count (DM_103) | DISP_CAFFEINE_SOURCE_COUNT |

#### SCREEN_HEALTHY_FATS (NEW)
| Old Metrics | New Consolidated Metric |
|------------|------------------------|
| Healthy Fat Swaps: Breakfast/Lunch/Dinner | DISP_HEALTHY_FAT_SWAPS_TIMING |
| Saturated Fat: Breakfast/Lunch/Dinner | DISP_SATURATED_FAT_TIMING |
| Fat Source Count (DM_087) | DISP_FAT_SOURCE_COUNT |
| Healthy Fat Ratio (DM_073) | DISP_HEALTHY_FAT_RATIO |
| Monounaturated Fat (g) (DM_075) | DISP_MUFA_GRAMS |
| Polyunsaturated Fat (g) (DM_074) | DISP_PUFA_GRAMS |
| Saturated Fat (g) (DM_076) | DISP_SAT_FAT_GRAMS |
| Saturated Fat Percentage (DM_077) | DISP_SAT_FAT_PCT |

#### SCREEN_ADDED_SUGAR (NEW)
| Old Metrics | New Consolidated Metric |
|------------|------------------------|
| Added Sugar Servings: Breakfast/Lunch/Dinner | DISP_ADDED_SUGAR_TIMING |
| Added Sugar Consumed (DM_098) | DISP_ADDED_SUGAR_GRAMS |

#### SCREEN_MEAL_TIMING
| Old Metrics | New Consolidated Metric |
|------------|------------------------|
| Meals (DM_001) | DISP_TOTAL_MEALS |
| Breakfast (DM_002) | DISP_BREAKFAST |
| Lunch (DM_003) | DISP_LUNCH |
| Dinner (DM_004) | DISP_DINNER |
| Snacks (DM_032) | DISP_SNACKS |
| First Meal Time (DM_012) | DISP_FIRST_MEAL_TIME |
| First Meal Delay (DM_011) | DISP_FIRST_MEAL_DELAY |
| Last Meal Time (DM_013) | DISP_LAST_MEAL_TIME |
| Last Meal Buffer (DM_014) | DISP_LAST_MEAL_BUFFER |
| Last Large Meal Time (DM_009) | DISP_LAST_LARGE_MEAL_TIME |
| Last Large Meal Buffer (DM_010) | DISP_LAST_LARGE_MEAL_BUFFER |
| Eating Window Duration (DM_031) | DISP_EATING_WINDOW |

#### SCREEN_NUTRITION_QUALITY
| Old Metrics | New Consolidated Metric |
|------------|------------------------|
| Whole Food Meals: Breakfast/Lunch/Dinner | DISP_WHOLE_FOOD_MEALS_TIMING |
| Plant Based Meals: Breakfast/Lunch/Dinner | DISP_PLANT_BASED_MEALS_TIMING |
| Mindful Eating: Breakfast/Lunch/Dinner | DISP_MINDFUL_EATING_TIMING |
| Takeout/Delivery Meals: Breakfast/Lunch/Dinner | DISP_TAKEOUT_TIMING |
| Large Meals: Breakfast/Lunch/Dinner | DISP_LARGE_MEALS_TIMING |
| Ultraprocessed Food Servings: Breakfast/Lunch/Dinner | DISP_ULTRAPROCESSED_TIMING |
| Process Meat: Breakfast/Lunch/Dinner | DISP_PROCESSED_MEAT_TIMING |
| Fatty Fish Servings (DM_215) | DISP_FATTY_FISH_SERVINGS |
| Red Meat Servings (DM_214) | DISP_RED_MEAT_SERVINGS |
| Seed Servings (DM_216) | DISP_SEED_SERVINGS |

#### SCREEN_MEAL_QUALITY_TOTALS (NEW)
| Old Metrics | New Consolidated Metric |
|------------|------------------------|
| Breakfast Total Servings (DM_070) | DISP_BREAKFAST_TOTAL_SERVINGS |
| Lunch Total Servings (DM_071) | DISP_LUNCH_TOTAL_SERVINGS |
| Dinner Total Servings (DM_072) | DISP_DINNER_TOTAL_SERVINGS |

---

### Movement + Exercise (41 → ~30 metrics)

#### SCREEN_STEPS
| Old Metrics | New Consolidated Metric |
|------------|------------------------|
| Steps (DM_106) | DISP_STEPS ✅ (exists) |

#### SCREEN_CARDIO
| Old Metrics | New Consolidated Metric |
|------------|------------------------|
| Zone 2 Cardio Sessions (DM_118) | DISP_ZONE2_SESSIONS ✅ (exists) |
| Zone 2 Cardio Session (DM_119) | DISP_ZONE2_SESSION ✅ (exists) |
| Zone 2 Cardio Duration (DM_120) | DISP_ZONE2_DURATION ✅ (exists) |
| Calories (DM_121) | DISP_CALORIES |

#### SCREEN_STRENGTH
| Old Metrics | New Consolidated Metric |
|------------|------------------------|
| Strength Training Sessions (DM_107) | DISP_STRENGTH_SESSIONS ✅ (exists) |
| Strength Training Session (DM_254) | DISP_STRENGTH_SESSION ✅ (exists) |
| Strength Training Duration (DM_108) | DISP_STRENGTH_DURATION ✅ (exists) |

#### SCREEN_HIIT
| Old Metrics | New Consolidated Metric |
|------------|------------------------|
| HIIT Sessions (DM_109) | DISP_HIIT_SESSIONS ✅ (exists) |
| HIIT Session (DM_255) | DISP_HIIT_SESSION ✅ (exists) |
| HIIT Duration (DM_110) | DISP_HIIT_DURATION ✅ (exists) |

#### SCREEN_MOBILITY
| Old Metrics | New Consolidated Metric |
|------------|------------------------|
| Mobility Sessions (DM_111) | DISP_MOBILITY_SESSIONS ✅ (exists) |
| Mobility Session (DM_256) | DISP_MOBILITY_SESSION ✅ (exists) |
| Mobility Duration (DM_112) | DISP_MOBILITY_DURATION ✅ (exists) |

#### SCREEN_ACTIVITY
| Old Metrics | New Consolidated Metric |
|------------|------------------------|
| Activity Sessions (DM_122) | DISP_ACTIVITY_SESSIONS ✅ (exists) |
| Active Time (DM_123) | DISP_ACTIVE_TIME ✅ (exists) |
| Active Time Session (DM_258) | DISP_ACTIVE_TIME_SESSION ✅ (exists) |
| Calculated Active Time (DM_124) | DISP_CALCULATED_ACTIVE_TIME |
| Calculated Exercise Time (DM_125) | DISP_CALCULATED_EXERCISE_TIME |
| Active vs Calculated Time Difference (DM_126) | DISP_ACTIVE_VS_CALCULATED |
| Sedentary Sessions (DM_127) | DISP_SEDENTARY_SESSIONS |
| Sedentary Time (DM_128) | DISP_SEDENTARY_TIME |
| Sedentary Period (DM_259) | DISP_SEDENTARY_PERIOD |
| Exercise Snacks (DM_113) | DISP_EXERCISE_SNACKS |
| Exercise Snack (DM_257) | DISP_EXERCISE_SNACK |
| Walking Duration (DM_210) | DISP_WALKING_DURATION |
| Walking Sessions (DM_208) | DISP_WALKING_SESSIONS |

#### SCREEN_POST_MEAL_ACTIVITY (NEW)
| Old Metrics | New Consolidated Metric |
|------------|------------------------|
| Post Meal Activity Sessions: Breakfast/Lunch/Dinner | DISP_POST_MEAL_ACTIVITY_TIMING |
| Post Meal Exercise Snacks: Breakfast/Lunch/Dinner | DISP_POST_MEAL_EXERCISE_TIMING |
| Post Meal Activity Duration (DM_133) | DISP_POST_MEAL_ACTIVITY_DURATION |

#### SCREEN_FITNESS_METRICS (NEW)
| Old Metrics | New Consolidated Metric |
|------------|------------------------|
| Resting Heart Rate (DM_245) | DISP_RESTING_HR |
| VO2 Max (DM_246) | DISP_VO2_MAX |

---

### Restorative Sleep (34 → ~15 metrics)

#### SCREEN_SLEEP_ANALYSIS
| Old Metrics | New Consolidated Metric |
|------------|------------------------|
| Deep Sleep Duration (DM_228) | DISP_DEEP_SLEEP ✅ (exists via agg) |
| Core Sleep Duration (DM_229) | DISP_CORE_SLEEP ✅ (exists via agg) |
| REM Sleep Duration (DM_227) | DISP_REM_SLEEP ✅ (exists via agg) |
| Awake Duration (DM_230) | DISP_AWAKE_DURATION ✅ (exists via agg) |
| Total Sleep Duration (DM_231) | DISP_SLEEP_DURATION ✅ (exists) |
| Deep Percentage (DM_235) | DISP_DEEP_PCT |
| Core Percentage (DM_236) | DISP_CORE_PCT |
| REM Percentage (DM_234) | DISP_REM_PCT |
| Awake Percentage (DM_260) | DISP_AWAKE_PCT |

#### SCREEN_SLEEP_QUALITY (NEW)
| Old Metrics | New Consolidated Metric |
|------------|------------------------|
| Sleep Efficiency (DM_232) | DISP_SLEEP_EFFICIENCY |
| Sleep Latency (DM_233) | DISP_SLEEP_LATENCY |
| Deep Sleep Cycle Count (DM_240) | DISP_DEEP_CYCLES |
| REM Sleep Cycle Count (DM_241, DM_239) | DISP_REM_CYCLES |
| Awake Episode Count (DM_242) | DISP_AWAKE_EPISODES |
| Sleep Environment Score (DM_220) | DISP_SLEEP_ENVIRONMENT |
| Sleep Routine Adherence (DM_219) | DISP_SLEEP_ROUTINE |

#### SCREEN_SLEEP_CONSISTENCY
| Old Metrics | New Consolidated Metric |
|------------|------------------------|
| Sleep Time Consistency (DM_237) | DISP_SLEEP_TIME_CONSISTENCY ✅ (exists) |
| Wake Time Consistency (DM_238) | DISP_WAKE_TIME_CONSISTENCY |

#### SCREEN_SLEEP_TIMING (NEW)
| Old Metrics | New Consolidated Metric |
|------------|------------------------|
| Time In Bed Duration (DM_225) | DISP_TIME_IN_BED |
| Total Sleep Window (DM_226) | DISP_SLEEP_WINDOW |
| Last Alcoholic Drink Time (DM_137) | DISP_LAST_DRINK_TIME |
| Last Digital Device Time Usage (DM_138) | DISP_LAST_SCREEN_TIME |
| Last Drink Buffer (DM_136) | DISP_LAST_DRINK_BUFFER |
| DISP_SLEEP_SESSIONS | ✅ (exists) |
| Wearable Usage (DM_135) | DISP_WEARABLE_USAGE |

---

### Core Care (52 → ~35 metrics)

#### SCREEN_BIOMETRICS
| Old Metrics | New Consolidated Metric |
|------------|------------------------|
| Current Weight (DM_243) | DISP_WEIGHT |
| Height (DM_244) | DISP_HEIGHT |
| BMI (Calculated) (DM_212) | DISP_BMI |
| Body Fat Percentage (DM_247) | DISP_BODY_FAT_PCT |
| Hip to Waist Ratio (DM_213) | DISP_WAIST_HIP_RATIO |
| Systolic Blood Pressure (DM_249) | DISP_SYSTOLIC_BP |
| Diastolic Blood Pressure (DM_248) | DISP_DIASTOLIC_BP |
| User Age (DM_211) | DISP_AGE |

#### SCREEN_COMPLIANCE
| Old Metrics | New Consolidated Metric |
|------------|------------------------|
| Mammogram Compliance Status (DM_159, DM_160, DM_161) | DISP_MAMMOGRAM_COMPLIANCE |
| Colonoscopy Compliance Status (DM_157, DM_158) | DISP_COLONOSCOPY_COMPLIANCE |
| Cervical Screening Compliance Status (DM_163, DM_164) | DISP_CERVICAL_COMPLIANCE |
| Breast MRI Compliance Status (DM_162) | DISP_BREAST_MRI_COMPLIANCE |
| PSA Test Compliance Status (DM_165, DM_166) | DISP_PSA_COMPLIANCE |
| Dental Compliance Status (DM_152) | DISP_DENTAL_COMPLIANCE |
| Physical Exam Compliance Status (DM_153) | DISP_PHYSICAL_COMPLIANCE |
| Skin Check Compliance Status (DM_154, DM_155) | DISP_SKIN_CHECK_COMPLIANCE |
| Vision Check Compliance Status (DM_156) | DISP_VISION_COMPLIANCE |
| Months Since Last Dental Exam (DM_142) | DISP_MONTHS_SINCE_DENTAL |
| Months Since Last Mammogram (DM_147) | DISP_MONTHS_SINCE_MAMMOGRAM |
| Months Since Last Breast MRI (DM_148) | DISP_MONTHS_SINCE_BREAST_MRI |
| Months Since Last Skin Check (DM_144) | DISP_MONTHS_SINCE_SKIN_CHECK |
| Months Since Last Vision Check (DM_145) | DISP_MONTHS_SINCE_VISION |
| Years Since Last Colonoscopy (DM_146) | DISP_YEARS_SINCE_COLONOSCOPY |
| Years Since Last HPV Screening (DM_149) | DISP_YEARS_SINCE_HPV |
| Years Since Last Pap Test (DM_150) | DISP_YEARS_SINCE_PAP |
| Years Since Last Physical (DM_143) | DISP_YEARS_SINCE_PHYSICAL |
| Years Since Last PSA Test (DM_151) | DISP_YEARS_SINCE_PSA |

#### SCREEN_MEDICATIONS
| Old Metrics | New Consolidated Metric |
|------------|------------------------|
| Medication Adherence (DM_168) | DISP_MEDICATION_ADHERENCE |
| Supplement Adherence (DM_167) | DISP_SUPPLEMENT_ADHERENCE |
| Peptide Adherence (DM_169) | DISP_PEPTIDE_ADHERENCE |

#### SCREEN_SKINCARE
| Old Metrics | New Consolidated Metric |
|------------|------------------------|
| Sunscreen Applications (DM_173) | DISP_SUNSCREEN_APPLICATIONS |
| Morning Sunscreen Applications (DM_174) | DISP_MORNING_SUNSCREEN |
| Sunscreen Compliance Events (DM_175) | DISP_SUNSCREEN_EVENTS |
| Sunscreen Compliance Rate (DM_176) | DISP_SUNSCREEN_RATE |
| Skincare Routine Adherence (DM_172) | DISP_SKINCARE_ROUTINE |

#### SCREEN_ORAL_HEALTH (NEW)
| Old Metrics | New Consolidated Metric |
|------------|------------------------|
| Brushing Sessions (DM_171) | DISP_BRUSHING_SESSIONS |
| Flossing Sessions (DM_170) | DISP_FLOSSING_SESSIONS |

#### SCREEN_SUBSTANCES
| Old Metrics | New Consolidated Metric |
|------------|------------------------|
| Alcoholic Drinks (DM_179) | DISP_ALCOHOL_DRINKS |
| Alcoholic Drinks vs. Baseline (DM_180) | DISP_ALCOHOL_VS_BASELINE |
| Cigarettes (DM_177) | DISP_CIGARETTES |
| Cigarettes vs. Baseline (DM_178) | DISP_CIGARETTES_VS_BASELINE |

#### SCREEN_ROUTINES (NEW)
| Old Metrics | New Consolidated Metric |
|------------|------------------------|
| Evening Routine Adherence (DM_209) | DISP_EVENING_ROUTINE |
| Digital Shutoff Buffer (DM_139) | DISP_DIGITAL_SHUTOFF |
| Last Caffeine Consumption Time (DM_140) | DISP_LAST_CAFFEINE_TIME |
| Last Caffeine Consumption Buffer (DM_141) | DISP_LAST_CAFFEINE_BUFFER |

---

### Cognitive Health (9 → ~8 metrics)

#### SCREEN_BRAIN_TRAINING
| Old Metrics | New Consolidated Metric |
|------------|------------------------|
| Brain Training Sessions (DM_194) | DISP_BRAIN_TRAINING_SESSIONS |
| Brain Training Duration (DM_195) | DISP_BRAIN_TRAINING_DURATION |

#### SCREEN_COGNITIVE_METRICS
| Old Metrics | New Consolidated Metric |
|------------|------------------------|
| Mood Rating (DM_186) | DISP_MOOD_RATING |
| Focus Rating (DM_197) | DISP_FOCUS_RATING |
| Memory Clarity Rating (DM_198) | DISP_MEMORY_RATING |

#### SCREEN_LIGHT_EXPOSURE
| Old Metrics | New Consolidated Metric |
|------------|------------------------|
| Sunlight Exposure Sessions (DM_205) | DISP_SUNLIGHT_SESSIONS |
| Sunlight Exposure Duration (DM_206) | DISP_SUNLIGHT_DURATION |
| Early Morning Light Exposure Duration (DM_207) | DISP_MORNING_LIGHT_DURATION |

#### SCREEN_JOURNALING
| Old Metrics | New Consolidated Metric |
|------------|------------------------|
| Journaling Sessions (DM_196) | DISP_JOURNALING_SESSIONS |

---

### Connection + Purpose (11 → ~11 metrics)

#### SCREEN_SOCIAL (NEW)
| Old Metrics | New Consolidated Metric |
|------------|------------------------|
| Social Interaction (DM_187) | DISP_SOCIAL_INTERACTION |

#### SCREEN_MINDFULNESS
| Old Metrics | New Consolidated Metric |
|------------|------------------------|
| Mindfulness Sessions (DM_199) | DISP_MINDFULNESS_SESSIONS |
| Mindfulness Duration (DM_200) | DISP_MINDFULNESS_DURATION |

#### SCREEN_OUTDOOR_TIME
| Old Metrics | New Consolidated Metric |
|------------|------------------------|
| Outdoor Time Sessions (DM_189) | DISP_OUTDOOR_SESSIONS |
| Outdoor Time Duration (DM_190) | DISP_OUTDOOR_DURATION |
| Morning Outdoor Time Duration (DM_191) | DISP_MORNING_OUTDOOR_DURATION |

#### SCREEN_GRATITUDE
| Old Metrics | New Consolidated Metric |
|------------|------------------------|
| Gratitude Sessions (DM_188) | DISP_GRATITUDE_SESSIONS |

#### SCREEN_SCREEN_TIME
| Old Metrics | New Consolidated Metric |
|------------|------------------------|
| Screen Time Sessions (DM_192) | DISP_SCREEN_TIME_SESSIONS |
| Screen Time Duration (DM_193) | DISP_SCREEN_TIME_DURATION |

#### SCREEN_STRESS_TRACKING
| Old Metrics | New Consolidated Metric |
|------------|------------------------|
| Stress Level Rating (DM_185) | DISP_STRESS_LEVEL |
| Stress Management Duration (DM_184) | DISP_STRESS_MGMT_DURATION |

---

### Stress Management (7 → ~7 metrics)

#### SCREEN_MEDITATION
| Old Metrics | New Consolidated Metric |
|------------|------------------------|
| Meditation Sessions (DM_181) | DISP_MEDITATION_SESSIONS |
| Meditation Duration (DM_182) | DISP_MEDITATION_DURATION |

#### SCREEN_BREATHWORK
| Old Metrics | New Consolidated Metric |
|------------|------------------------|
| Breathwork Sessions (DM_201) | DISP_BREATHWORK_SESSIONS |
| Breathwork Duration (DM_202) | DISP_BREATHWORK_DURATION |
| Breathwork AND Mindfulness Sessions (DM_204) | DISP_BREATHWORK_MINDFULNESS_SESSIONS |
| Breathwork AND Mindfulness Duration (DM_203) | DISP_BREATHWORK_MINDFULNESS_DURATION |

#### SCREEN_STRESS_TRACKING
| Old Metrics | New Consolidated Metric |
|------------|------------------------|
| Stress Management Sessions (DM_183) | DISP_STRESS_MGMT_SESSIONS |

---

## Summary

**Consolidation Results:**
- Old: 270 metrics (with duplicates)
- New: ~120 metrics (consolidated)
- Reduction: 150 redundant metrics eliminated

**New Screens Needed:**
- SCREEN_LEGUMES
- SCREEN_WHOLE_GRAINS
- SCREEN_HEALTHY_FATS
- SCREEN_ADDED_SUGAR
- SCREEN_MEAL_QUALITY_TOTALS
- SCREEN_POST_MEAL_ACTIVITY
- SCREEN_FITNESS_METRICS
- SCREEN_SLEEP_QUALITY
- SCREEN_SLEEP_TIMING
- SCREEN_ORAL_HEALTH
- SCREEN_ROUTINES
- SCREEN_SOCIAL

**Metrics Marked ✅:** Already exist in display_metrics, just need screen linkage.
