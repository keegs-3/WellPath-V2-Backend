# WellPath V2 Backend - Complete Data Architecture

## Overview

The WellPath scoring system uses **4 separate data pipelines** for patient assessment:

1. **Biomarkers + Biometrics** (baseline health snapshot from intake)
2. **Survey Responses** (327 questions capturing lifestyle, habits, health history)
3. **Daily Tracked Metrics** (ongoing behavior tracking - steps, sleep, meals, etc.)
4. **Calculated Metrics** (derived values computed from tracked metrics - NOT based on direct inputs)

---

## 1. BIOMARKERS + BIOMETRICS (Baseline Health Snapshot)

These are **one-time intake measurements** that establish the patient's baseline health status.

### Data Flow:
```
preliminary_data CSV (dummy_lab_results_full.csv)
  ├─> 62 Biomarkers → biomarker_readings table
  └─> 15 Biometrics → biometric_readings table
```

### A. BIOMARKERS (Lab Work)
**Source Table:** `intake_markers_raw` (62 markers total)
**Patient Data:** `biomarker_readings`

**Join:** `biomarker_readings.marker_id` → `intake_markers_raw.record_id`

**Examples:**
- Lipids: HDL, LDL, Triglycerides, Total Cholesterol, Lp(a), ApoB
- Glucose: HbA1c, Fasting Glucose, Fasting Insulin, HOMA-IR
- Vitamins: Vitamin D, B12, Folate
- Hormones: Testosterone, Cortisol, TSH, Estradiol, DHEA-S
- Inflammation: hsCRP
- Liver: ALT, AST, GGT, Alkaline Phosphatase
- Kidney: Creatinine, BUN, eGFR, Cystatin C
- CBC: WBC, RBC, Hemoglobin, Hematocrit, Platelets, MCV, MCH, MCHC, RDW
- Minerals: Magnesium, Iron, Ferritin, Calcium, Sodium, Potassium

**Total:** 62 biomarkers scored together

### B. BIOMETRICS (Physical Measurements)
**Source Table:** `intake_metrics_raw` (18 metrics total, but only 15 are baseline biometrics)
**Patient Data:** `biometric_readings`

**Join:** `biometric_readings.metric_id` → `intake_metrics_raw.record_id`

**Note:** intake_metrics_raw contains 18 metrics, but 3 are daily tracked metrics (Steps/Day, Total Sleep, Water Intake) that go into `metric_readings` for ongoing tracking, NOT baseline scoring.

**Biometric Mappings (CSV → Supabase) - 15 Baseline Measurements:**
```
CSV Column              | metric_id (intake_metrics_raw) | Metric Name
------------------------|--------------------------------|---------------------------
bmi                     | reccxH7AESy9vvBPo             | BMI
vo2_max                 | rec0v0JrVS6xu5Dcj             | VO2 Max
grip_strength           | recHOTAk6Lpmb9uUz             | Grip Strength
percent_body_fat        | recVHWlB26jWt9Ij9             | % Bodyfat
visceral_fat            | recoiAahhmbWcaNoa             | Visceral Fat
hrv                     | recqea20SA5Y5BaIw             | HRV
resting_heart_rate      | recLuAlDIETnvUUtO             | Resting Heart Rate
smm_to_ffm              | recyKRTIlX4Jux2W0             | Skeletal Muscle Mass to FFM
hip_to_waist            | recbIfUESzC18eAIL             | Hip-to-Waist Ratio
rem_sleep               | rec8o1wlo0olBMl8A             | REM Sleep
deep_sleep              | recXiq3Os05QJJki4             | Deep Sleep
blood_pressure_systolic | recELBnyZAf0mIQH6             | Blood Pressure - Systolic
blood_pressure_diastolic| recSy02sgRnjfOkHE             | Blood Pressure - Diastolic
weight_lb               | recWsK4nX930OGci1             | Weight
height_in               | recKjpXsXuiQfYGpu             | Height
```

**Total:** 15 biometrics scored together with biomarkers

### Combined Scoring
The preliminary_data script (`Wellpath_score_runner_markers.py`) loads `dummy_lab_results_full.csv` which contains **77 total columns** (62 biomarkers + 15 biometrics) and scores them together as a single baseline health assessment.

**V2-Backend Implementation:**
- `data_fetcher.get_patient_biomarkers()` pulls BOTH biomarker_readings AND biometric_readings
- Merges them into single DataFrame with common schema
- `biomarker_scorer.py` scores all 77 values using `marker_config.json`

---

## 2. SURVEY RESPONSES (Lifestyle & Health History)

**Source Table:** `survey_questions` (327 questions)
**Patient Data:** `survey_responses`

**Join:** `survey_responses.question_id` → survey question IDs like "1.04", "2.11", etc.

### Data Flow:
```
preliminary_data CSV (synthetic_patient_survey.csv)
  └─> 327 Survey Responses → survey_responses table
```

### Survey Question Structure:
- Questions have IDs like "1.04", "2.11", "3.05", etc.
- Each question has pillar weights (which pillars it affects)
- Each question has response scores (how answers are scored)
- Some questions have custom scoring functions (protein_intake_score, calorie_intake_score, etc.)

**Total:** 327 survey questions covering all 7 pillars

**V2-Backend Implementation:**
- `data_fetcher.get_patient_survey_responses()` pulls survey_responses
- `survey_scorer.py` (NOT YET IMPLEMENTED) should score using pillar weights and response scores

---

## 3. DAILY TRACKED METRICS (Ongoing Behavior)

**Source Table:** `metric_types_vfinal` (~500+ tracked metrics)
**Patient Data:** `metric_readings`

**Join:** `metric_readings.metric_id` → `metric_types_vfinal.record_id`

### Purpose:
These are **NOT intake metrics**. These are ongoing daily tracked behaviors:
- Steps per day
- Meals logged
- Sleep duration
- Water intake
- Exercise sessions
- Meditation minutes
- Screen time
- etc.

**Examples:**
- Meal Logged
- Large Meal
- Wake Time
- Mindful Eating Episode
- Fruit Serving
- Protein Grams
- Steps/Day
- Water Intake
- Exercise Duration

**Used For:**
- Adherence tracking (did patient follow recommendations?)
- Input for calculated metrics
- Recommendation impact scoring

**NOT Used For:**
- Initial baseline scoring (that's biomarkers + biometrics)

---

## 4. CALCULATED METRICS (Derived Values)

**Source Table:** `calculated_metrics_vfinal` (240 metrics)
**Patient Data:** `calculated_metrics_readings` (cached computed values)

**Join:** `calculated_metrics_readings.calculated_metric_id` → `calculated_metrics_vfinal.record_id`

### Purpose:
These are **derived/aggregated values** computed from raw tracked metrics:
- Daily totals (e.g., "Daily Meals" = count of all meal entries)
- Time windows (e.g., "Last Meal Time" = max timestamp of meals)
- Differences (e.g., "Last Meal Buffer" = time between last meal and sleep)
- Sums (e.g., "Daily Saturated Fat" = sum of saturated fat from all meals)

**Calculation Types:**
- `count` - Count occurrences
- `sum` - Add up values
- `max_time` - Latest timestamp
- `min_time` - Earliest timestamp
- `time_difference` - Duration between events
- `divide` - Ratio calculations
- `custom_calc` - Complex logic (BMI, compliance checks, etc.)

**Examples:**
- Daily Mindful Eating Episodes (count)
- Daily Saturated Fat (g) (sum)
- Last Meal Time (max_time)
- Last Large Meal Buffer (time_difference)
- Daily Breakfast (count)
- Current BMI (custom_calc from height/weight)
- Current User Age (time_difference from DOB)

**Total:** 240 calculated metrics

**Used For:**
- Adherence scoring (comparing actual vs target behaviors)
- Recommendation triggers (e.g., "if daily_saturated_fat > 20g")
- Complex health metrics that require multiple inputs

**NOT Used For:**
- Direct patient input (no patient enters "Daily Meals Count" - it's computed)

---

## Data Architecture Summary

| Data Type | Reference Table | Patient Data Table | Purpose | Count |
|-----------|----------------|-------------------|---------|-------|
| **Biomarkers** | intake_markers_raw | biomarker_readings | Lab work for baseline scoring | 62 |
| **Biometrics** | intake_metrics_raw | biometric_readings | Physical measurements for baseline scoring | 15 |
| **Survey** | survey_questions | survey_responses | Lifestyle/health history for baseline scoring | 327 |
| **Tracking** | metric_types_vfinal | metric_readings | Daily behavior tracking for adherence | 500+ |
| **Calculated** | calculated_metrics_vfinal | calculated_metrics_readings | Derived metrics from tracked data (CACHED) | 240 |

---

## Useful Queries

### Show Patient Biomarkers with Names
```sql
SELECT
    br.patient_id,
    im.name as marker_name,
    br.value,
    br.unit,
    br.test_date
FROM biomarker_readings br
JOIN intake_markers_raw im ON br.marker_id = im.record_id
WHERE br.patient_id = '<patient_id>'
ORDER BY im.name;
```

### Show Patient Biometrics with Names
```sql
SELECT
    bir.patient_id,
    imr.name as metric_name,
    bir.value,
    bir.unit,
    bir.test_date
FROM biometric_readings bir
JOIN intake_metrics_raw imr ON bir.metric_id = imr.record_id
WHERE bir.patient_id = '<patient_id>'
ORDER BY imr.name;
```

### Show Patient Tracked Metrics with Names
```sql
SELECT
    mr.patient_id,
    mt.name as metric_name,
    mr.value,
    mr.value_text,
    mr.recorded_date,
    mr.recorded_time
FROM metric_readings mr
JOIN metric_types_vfinal mt ON mr.metric_id = mt.record_id
WHERE mr.patient_id = '<patient_id>'
    AND mr.recorded_date >= CURRENT_DATE - INTERVAL '7 days'
ORDER BY mr.recorded_date DESC, mr.recorded_time DESC;
```

### Check Which Calculated Metrics Use Which Tracked Metrics
```sql
SELECT
    cm.name as calculated_metric,
    cm.calculation_type,
    mt.name as input_metric
FROM calculated_metrics_vfinal cm
JOIN calculated_metrics_metric_types cmmt ON cm.record_id = cmmt.calculated_metric_id
JOIN metric_types_vfinal mt ON cmmt.metric_type_id = mt.record_id
WHERE cm.name LIKE '%Daily Meals%'
ORDER BY cm.name, mt.name;
```

---

## Scoring Breakdown Per Pillar

Each pillar's score comes from 3 components:

```
Pillar Score = (Biomarker/Biometric Score × marker_weight) +
               (Survey Score × survey_weight) +
               (Education Score × education_weight)
```

### Example: Healthful Nutrition
- **Markers** (70%): Lipids, HbA1c, Vitamin D, etc.
- **Survey** (20%): Diet quality questions, meal frequency, eating window, etc.
- **Education** (10%): Articles read/engaged with

---

## Current V2-Backend Status

✅ **Biomarkers:** Working - pulls from biomarker_readings
✅ **Biometrics:** Working - NOW pulls from biometric_readings (as of this update)
❌ **Survey:** NOT IMPLEMENTED - returns zeros
❌ **Education:** PLACEHOLDER - hardcoded to 70

---

## Known Issues

### 1. ~~Missing Foreign Key Constraints~~ ✅ FIXED
**Status:** RESOLVED - All foreign keys have been added

**What Was Fixed:**
- ✅ `biomarker_readings.marker_id` → FK to `intake_markers_raw.record_id`
- ✅ `biometric_readings.metric_id` → FK to `intake_metrics_raw.record_id`
- ✅ `metric_readings.metric_id` → FK to `metric_types_vfinal.record_id`
- ✅ `calculated_metrics_readings.calculated_metric_id` → FK to `calculated_metrics_vfinal.record_id`
- ✅ Fixed bad data: `metric_id='weight'` and `metric_id='height'` converted to proper rec IDs
- ✅ Created new `calculated_metrics_readings` table for caching calculated values

### 2. Duplicate Biometric Data
**Symptom:** Patient 83a28af3 has weight 6 times, height 3 times
**Cause:** `inject_synthetic_patients_supabase.py` was run multiple times without proper cleanup
**Root Issue:** The script only clears data for TEST_PATIENT_ID (b48ca674...), not for all patients

**To Fix:**
```sql
-- Clean up duplicate biometric data
DELETE FROM biometric_readings
WHERE id NOT IN (
    SELECT DISTINCT ON (patient_id, metric_id) id
    FROM biometric_readings
    ORDER BY patient_id, metric_id, test_date DESC
);

-- Verify no duplicates
SELECT patient_id, metric_id, COUNT(*)
FROM biometric_readings
GROUP BY patient_id, metric_id
HAVING COUNT(*) > 1;
```

**Permanent Fix:** Update inject script to clear ALL patient data, not just TEST_PATIENT_ID

### 2. biometric_readings Table Confusion
**Issue:** Table name suggests it's for tracking, but it's actually for INTAKE biometrics
**Clarification:**
- `biometric_readings` = intake baseline measurements (BMI, VO2 Max, etc.)
- `metric_readings` = ongoing daily tracking (steps, meals, etc.)

### 3. Missing Biometric Scoring
**Issue:** Score went DOWN when biometric fetching was added (47.49 → 47.12)
**Possible Cause:** Either biometric data is incomplete OR there's an error in scoring/mapping

---

## Next Steps

1. ✅ Document complete data architecture (THIS FILE)
2. ⬜ Fix duplicate biometric data issue
3. ⬜ Verify biometric scoring is working correctly
4. ⬜ Implement survey scoring using question pillar weights and response scores
5. ⬜ Implement education scoring (pull from education_engagement table)

---

## For Future Claude Sessions

If you get disconnected and need to understand the data architecture:
1. Read this file first
2. Check `inject_synthetic_patients_supabase.py` to see how test data is loaded
3. Check `Wellpath_score_runner_markers.py` in preliminary_data to see ground truth scoring
4. The scoring MUST match preliminary_data output for validation
