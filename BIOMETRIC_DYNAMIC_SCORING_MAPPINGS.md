# Biometric Dynamic Scoring Mappings

## Complete Flow

```
Patient Data Entry
  ↓
Data Entry Fields (DEF_*)
  ↓
Instance Calculations (CALC_*) [optional]
  ↓
Aggregation Metrics (AGG_*)
  ↓
Biometric Scoring Ranges
  ↓
Scores
```

---

## Biometric Mappings

### 1. BMI (Calculated)

**Flow:**
```
DEF_HEIGHT + DEF_WEIGHT
  ↓
CALC_BMI (formula: weight_kg / (height_m)²)
  ↓
AGG_BMI (latest value)
  ↓
biometric_aggregations_scoring ranges:
  - [18.5, 24.9] → 1.0 (Optimal)
  - [25.0, 29.9] → 0.6 (Overweight)
  - [30.0, 34.9] → 0.3 (Obese I)
  - etc.
```

**Dependencies:**
- `DEF_HEIGHT` → height
- `DEF_WEIGHT` → weight
- `CALC_BMI` → calculates from height + weight
- `AGG_BMI` → aggregates CALC_BMI

**Data Quality:**
- **No minimum required** - just need latest measurement
- Uses most recent BMI calculation

---

### 2. Body Fat Percentage (Calculated)

**Flow:**
```
DEF_GENDER + DEF_HEIGHT + DEF_WAIST + DEF_NECK + DEF_HIP
  ↓
CALC_BODY_FAT_PERCENTAGE (Navy formula)
  ↓
AGG_BODY_FAT_PERCENTAGE (latest value)
  ↓
biometric_aggregations_scoring ranges (gender + age specific):
  Men 18-39:
    - [8, 19] → 1.0 (Optimal)
    - [20, 24] → 0.7 (Good)
    - [25+] → 0.3 (High)
  Women 18-39:
    - [21, 32] → 1.0 (Optimal)
    - etc.
```

**Dependencies:**
- `DEF_GENDER` → gender
- `DEF_HEIGHT` → height
- `DEF_WAIST_CIRCUMFERENCE` → waist
- `DEF_NECK_CIRCUMFERENCE` → neck
- `DEF_HIP_CIRCUMFERENCE` → hip
- `CALC_BODY_FAT_PERCENTAGE` → Navy body fat formula
- `AGG_BODY_FAT_PERCENTAGE` → aggregates calculation

**Data Quality:**
- **No minimum required** - latest calculation
- All 5 input fields must be present for calculation

---

### 3. Blood Pressure (Direct Entry)

**Flow:**
```
DEF_BLOOD_PRESSURE_SYS → AGG_SYSTOLIC_BLOOD_PRESSURE
DEF_BLOOD_PRESSURE_DIA → AGG_DIASTOLIC_BLOOD_PRESSURE
  ↓
biometric_aggregations_scoring ranges:
  Systolic:
    - [<120] → 1.0 (Optimal)
    - [120-129] → 0.8 (Elevated)
    - [130-139] → 0.5 (Stage 1 Hypertension)
    - [140+] → 0.2 (Stage 2 Hypertension)
  Diastolic:
    - [<80] → 1.0 (Optimal)
    - [80-89] → 0.5 (Stage 1)
    - [90+] → 0.2 (Stage 2)
```

**Dependencies:**
- `DEF_BLOOD_PRESSURE_SYS` → AGG_SYSTOLIC_BLOOD_PRESSURE (direct)
- `DEF_BLOOD_PRESSURE_DIA` → AGG_DIASTOLIC_BLOOD_PRESSURE (direct)

**Data Quality:**
- **No minimum required** - latest reading
- No calculation needed - direct aggregation

---

### 4. Resting Heart Rate (Direct Entry)

**Flow:**
```
DEF_RESTING_HEART_RATE
  ↓
AGG_RESTING_HEART_RATE (latest value)
  ↓
biometric_aggregations_scoring ranges:
  - [40-60] → 1.0 (Athlete)
  - [61-70] → 0.9 (Excellent)
  - [71-80] → 0.7 (Good)
  - [81-90] → 0.5 (Average)
  - [91-100] → 0.3 (Below Average)
  - [100+] → 0.1 (Poor)
```

**Dependencies:**
- `DEF_RESTING_HEART_RATE` → AGG_RESTING_HEART_RATE (direct)

**Data Quality:**
- **No minimum required** - latest reading

---

### 5. Weight (Direct Entry)

**Flow:**
```
DEF_WEIGHT
  ↓
AGG_CURRENT_WEIGHT (latest value)
  ↓
Used for BMI calculation (not scored directly)
```

**Dependencies:**
- `DEF_WEIGHT` → AGG_CURRENT_WEIGHT (direct)

**Note:** Weight itself isn't scored - it's used to calculate BMI which is scored.

---

### 6. Hip-to-Waist Ratio (Calculated)

**Flow:**
```
DEF_WAIST_CIRCUMFERENCE + DEF_HIP_CIRCUMFERENCE
  ↓
CALC_HIP_WAIST_RATIO (formula: waist / hip)
  ↓
AGG_HIP_TO_WAIST_RATIO (latest value)
  ↓
biometric_aggregations_scoring ranges (gender specific):
  Men:
    - [<0.90] → 1.0 (Optimal)
    - [0.90-0.95] → 0.7 (Moderate Risk)
    - [0.96+] → 0.3 (High Risk)
  Women:
    - [<0.80] → 1.0 (Optimal)
    - [0.80-0.85] → 0.7 (Moderate Risk)
    - [0.86+] → 0.3 (High Risk)
```

**Dependencies:**
- `DEF_WAIST_CIRCUMFERENCE` → waist
- `DEF_HIP_CIRCUMFERENCE` → hip
- `CALC_HIP_WAIST_RATIO` → calculation
- `AGG_HIP_TO_WAIST_RATIO` → aggregation

**Data Quality:**
- **No minimum required** - latest calculation

---

### 7. Sleep Metrics (Behavioral/Trend)

**Flow:**
```
DEF_DEEP_SLEEP_DURATION → AGG_DEEP_SLEEP_DURATION (20+ nights)
DEF_REM_SLEEP_DURATION → AGG_REM_SLEEP_DURATION (20+ nights)
DEF_TOTAL_SLEEP_DURATION → AGG_TOTAL_SLEEP_DURATION (20+ nights)
  ↓
biometric_aggregations_scoring ranges:
  Deep Sleep:
    - [1.5-2.5 hrs] → 1.0 (Optimal - 15-25% of total)
    - [1.0-1.4 hrs] → 0.7 (Good)
    - [<1.0 hrs] → 0.3 (Insufficient)
  REM Sleep:
    - [1.5-2.5 hrs] → 1.0 (Optimal - 20-25% of total)
    - [1.0-1.4 hrs] → 0.7 (Good)
    - [<1.0 hrs] → 0.3 (Insufficient)
  Total Sleep:
    - [7-9 hrs] → 1.0 (Recommended for adults)
    - [6.5-6.9 hrs] → 0.7 (Adequate)
    - [<6.5 hrs] → 0.3 (Insufficient)
```

**Dependencies:**
- `DEF_DEEP_SLEEP_DURATION` → AGG_DEEP_SLEEP_DURATION (direct)
- `DEF_REM_SLEEP_DURATION` → AGG_REM_SLEEP_DURATION (direct)
- `DEF_TOTAL_SLEEP_DURATION` → AGG_TOTAL_SLEEP_DURATION (direct)

**Data Quality:**
- **Requires 20+ nights of data** - prove consistent sleep pattern

---

### 8. HRV - Heart Rate Variability (Behavioral/Trend)

**Flow:**
```
DEF_HRV
  ↓
AGG_HRV (average over 20+ days)
  ↓
biometric_aggregations_scoring ranges (gender/age specific):
  Men 18-39:
    - [60+ ms] → 1.0 (Excellent)
    - [40-59 ms] → 0.8 (Good)
    - [25-39 ms] → 0.6 (Average)
    - [<25 ms] → 0.3 (Below Average)
  (Different ranges for other age/gender groups)
```

**Dependencies:**
- `DEF_HRV` → AGG_HRV (direct)

**Data Quality:**
- **Requires 20+ readings over 30 days** - HRV varies daily with stress/recovery

---

### 9. Water Consumption (Behavioral/Trend)

**Flow:**
```
DEF_WATER_CONSUMPTION
  ↓
AGG_WATER_CONSUMPTION (average daily intake over 20+ days)
  ↓
biometric_aggregations_scoring ranges (gender specific):
  Men:
    - [100+ fl oz] → 1.0 (Optimal - meets 125 fl oz/day recommendation)
    - [80-99 fl oz] → 0.8 (Good)
    - [64-79 fl oz] → 0.6 (Adequate minimum)
    - [<64 fl oz] → 0.3 (Insufficient)
  Women:
    - [80+ fl oz] → 1.0 (Optimal - meets 91 fl oz/day recommendation)
    - [64-79 fl oz] → 0.8 (Good)
    - [48-63 fl oz] → 0.6 (Adequate minimum)
    - [<48 fl oz] → 0.3 (Insufficient)
```

**Dependencies:**
- `DEF_WATER_CONSUMPTION` → AGG_WATER_CONSUMPTION (direct)

**Data Quality:**
- **Requires 20+ days of tracking** - prove consistent hydration habit

---

### 10. Daily Steps (Behavioral/Trend)

**Flow:**
```
DEF_STEPS
  ↓
AGG_STEPS (average daily steps over 20+ days)
  ↓
biometric_aggregations_scoring ranges:
  - [10,000+ steps] → 1.0 (Highly Active)
  - [7,500-9,999 steps] → 0.8 (Active)
  - [5,000-7,499 steps] → 0.6 (Somewhat Active)
  - [2,500-4,999 steps] → 0.4 (Low Active)
  - [<2,500 steps] → 0.2 (Sedentary)
```

**Dependencies:**
- `DEF_STEPS` → AGG_STEPS (direct)

**Data Quality:**
- **Requires 20+ days of tracking** - prove consistent activity level

---

### 11. Grip Strength (Snapshot)

**Flow:**
```
DEF_GRIP_STRENGTH
  ↓
AGG_GRIP_STRENGTH (max value)
  ↓
biometric_aggregations_scoring ranges (gender/age specific):
  Men 18-39:
    - [46+ kg] → 1.0 (Excellent)
    - [41-45 kg] → 0.8 (Good)
    - [35-40 kg] → 0.6 (Average)
    - [<35 kg] → 0.3 (Below Average)
  (Different ranges for other age/gender groups)
```

**Dependencies:**
- `DEF_GRIP_STRENGTH` → AGG_GRIP_STRENGTH (direct)

**Data Quality:**
- **Latest max value only** - strength test, no trend needed

---

### 12. VO2 Max (Snapshot)

**Flow:**
```
DEF_VO2_MAX
  ↓
AGG_VO2_MAX (latest value)
  ↓
biometric_aggregations_scoring ranges (gender/age specific):
  Men 18-39:
    - [47+ mL/kg/min] → 1.0 (Excellent)
    - [42-46 mL/kg/min] → 0.8 (Good)
    - [37-41 mL/kg/min] → 0.6 (Average)
    - [<37 mL/kg/min] → 0.3 (Below Average)
  (Different ranges for other age/gender groups)
```

**Dependencies:**
- `DEF_VO2_MAX` → AGG_VO2_MAX (direct)

**Data Quality:**
- **Latest value only** - stable fitness metric, doesn't fluctuate daily

---

## Summary Table

### Snapshot Biometrics (Latest Value Only, No Min Data Points)

| Aggregation Metric | Source Type | Data Entry Fields | Instance Calc | Scoring Ranges | Min Data Points |
|-------------------|-------------|-------------------|---------------|----------------|-----------------|
| AGG_BMI | Calculated | DEF_HEIGHT, DEF_WEIGHT | CALC_BMI | 6 ranges | 1 |
| AGG_BODY_FAT_PERCENTAGE | Calculated | DEF_GENDER, DEF_HEIGHT, DEF_WAIST, DEF_NECK, DEF_HIP | CALC_BODY_FAT_PERCENTAGE | 22 ranges (gender/age) | 1 |
| AGG_HIP_TO_WAIST_RATIO | Calculated | DEF_WAIST_CIRCUMFERENCE, DEF_HIP_CIRCUMFERENCE | CALC_HIP_WAIST_RATIO | 6 ranges (gender) | 1 |
| AGG_CURRENT_WEIGHT | Direct | DEF_WEIGHT | None | Not scored (used for BMI) | 1 |
| AGG_GRIP_STRENGTH | Direct | DEF_GRIP_STRENGTH | None | 24 ranges (gender/age) | 1 |
| AGG_VO2_MAX | Direct | DEF_VO2_MAX | None | 24 ranges (gender/age) | 1 |

**Subtotal: 6 snapshot metrics, 82 scoring ranges**

### Behavioral/Trend Biometrics (Require 20+ Data Points Over 30 Days)

| Aggregation Metric | Source Type | Data Entry Fields | Instance Calc | Scoring Ranges | Min Data Points |
|-------------------|-------------|-------------------|---------------|----------------|-----------------|
| AGG_SYSTOLIC_BLOOD_PRESSURE | Direct | DEF_BLOOD_PRESSURE_SYS | None | 5 ranges | 20 |
| AGG_DIASTOLIC_BLOOD_PRESSURE | Direct | DEF_BLOOD_PRESSURE_DIA | None | 4 ranges | 20 |
| AGG_RESTING_HEART_RATE | Direct | DEF_RESTING_HEART_RATE | None | 6 ranges | 20 |
| AGG_DEEP_SLEEP_DURATION | Direct | DEF_DEEP_SLEEP_DURATION | None | 4 ranges | 20 |
| AGG_REM_SLEEP_DURATION | Direct | DEF_REM_SLEEP_DURATION | None | 4 ranges | 20 |
| AGG_TOTAL_SLEEP_DURATION | Direct | DEF_TOTAL_SLEEP_DURATION | None | 4 ranges | 20 |
| AGG_HRV | Direct | DEF_HRV | None | 24 ranges (gender/age) | 20 |
| AGG_WATER_CONSUMPTION | Direct | DEF_WATER_CONSUMPTION | None | 8 ranges (gender) | 20 |
| AGG_STEPS | Direct | DEF_STEPS | None | 5 ranges | 20 |

**Subtotal: 9 trend metrics, 64 scoring ranges**

**TOTAL: 15 aggregation metrics, 146 scoring ranges**

---

## Key Differences from Survey Questions

### Survey Questions
- Need 20+ data points over 30 days
- Require consistent behavior
- Map to response option thresholds

### Snapshot Biometrics
- **Just need latest value**
- No minimum data points (1 measurement)
- No consistency requirement
- Direct numeric range matching
- Examples: BMI, body fat %, grip strength, VO2 max

### Behavioral/Trend Biometrics
- **Need 20+ data points over 30 days**
- Require consistent pattern (like survey questions)
- Direct numeric range matching
- Prove sustained levels, not one-off readings
- Examples: Blood pressure, sleep quality, HRV, steps, water intake

---

## Edge Function Logic

```javascript
// For each biometric aggregation:
const latest = await getLatestAggregation(userId, 'AGG_BMI');
// Returns: { value: 23.5, period_end: '2025-10-22' }

// Find matching scoring range:
const scoring = await findBiometricScoringRange(
  'AGG_BMI',
  23.5,
  patient.gender,
  patient.age
);
// Returns: { range_score: 1.0, range_bucket: 'Optimal' }

// Store score immediately - no waiting!
```

---

## Implementation Notes

1. **Instance calculations run first**
   - BMI calculated when height or weight changes
   - Body fat % calculated when measurements taken
   - Stored in calculated_field_results table

2. **Aggregations pull latest**
   - For direct fields: latest DEF_* entry
   - For calculated fields: latest CALC_* result

3. **Scoring happens immediately**
   - No minimum data point requirement
   - Gender and age filters applied
   - Most recent = most accurate

4. **Updates trigger rescoring**
   - Patient logs new weight → BMI recalculates → AGG_BMI updates → Score updates
   - All automatic via existing instance calculation triggers
