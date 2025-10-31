# Dynamic Scoring Architecture - CORRECTED

**Date**: 2025-10-22
**Status**: Architecture Audit Complete

---

## Critical Discovery

The dynamic scoring edge functions should **UPDATE THE SOURCE TABLES** that the mobile app and existing scorer already use, NOT create parallel scoring logic!

---

## Current System Architecture

### Data Flow as Built

```
┌─────────────────────────────────────────────────────────────────┐
│                        USER DATA ENTRY                           │
└─────────────────────────────────────────────────────────────────┘
                               ↓
┌─────────────────────────────────────────────────────────────────┐
│              patient_data_entries (tracking data)                │
│  - 2005 entries for perfect patient (Sept 22 - Oct 21)          │
│  - Tracks: cardio, steps, water, sleep, nutrition, etc.         │
└─────────────────────────────────────────────────────────────────┘
                               ↓
┌─────────────────────────────────────────────────────────────────┐
│               Instance Calculations (if needed)                  │
│  - Trigger: auto_run_instance_calculations_http                 │
│  - Examples: BMI from height+weight, body fat % from Navy       │
└─────────────────────────────────────────────────────────────────┘
                               ↓
┌─────────────────────────────────────────────────────────────────┐
│            aggregation_results_cache                             │
│  - CURRENTLY EMPTY (0 records) ❌                               │
│  - SHOULD contain: AGG_BMI, AGG_STEPS, AGG_WATER, etc.         │
└─────────────────────────────────────────────────────────────────┘
                               ↓
                        ❌ GAP HERE ❌
                               ↓
┌─────────────────────────────────────────────────────────────────┐
│     patient_biometric_readings (what mobile app reads)           │
│  - 16 biometric records for perfect patient (Oct 16 only)       │
│  - Mobile app queries this table (BiometricsService.swift:103)  │
└─────────────────────────────────────────────────────────────────┘
                               ↓
┌─────────────────────────────────────────────────────────────────┐
│     patient_biomarker_readings (what mobile app reads)           │
│  - Mobile app queries this table (BiometricsService.swift:18)   │
└─────────────────────────────────────────────────────────────────┘
                               ↓
┌─────────────────────────────────────────────────────────────────┐
│     patient_survey_responses (what scorer reads)                 │
│  - 130 survey responses for perfect patient                     │
└─────────────────────────────────────────────────────────────────┘
                               ↓
┌─────────────────────────────────────────────────────────────────┐
│              WellPath Scorer (existing)                          │
│  - scoring_engine/utils/data_fetcher.py                         │
│  - Reads from: patient_survey_responses                         │
│  - Reads from: patient_biomarker_readings                       │
│  - Reads from: patient_biometric_readings                       │
└─────────────────────────────────────────────────────────────────┘
                               ↓
                          WellPath Score
```

---

## What the Dynamic Scoring Edge Functions Should Do

### CORRECT Architecture

The edge functions should **WRITE TO THE SAME TABLES** the mobile app and scorer already read from:

```
┌─────────────────────────────────────────────────────────────────┐
│                 aggregation_results_cache                        │
│  - Populated by aggregation pipeline                            │
│  - Contains: AGG_BMI, AGG_STEPS, AGG_WATER, AGG_CARDIO, etc.   │
└─────────────────────────────────────────────────────────────────┘
                               ↓
                               ↓
         ┌─────────────────────┴─────────────────────┐
         ↓                                           ↓
┌──────────────────────────┐        ┌──────────────────────────────┐
│  update-survey-scores    │        │  update-biometric-scores     │
│  (Edge Function)         │        │  (Edge Function)             │
│                          │        │                              │
│  IF tracked data shows   │        │  IF tracked data shows       │
│  consistent behavior:    │        │  biometric value:            │
│                          │        │                              │
│  UPDATE or INSERT        │        │  UPDATE or INSERT            │
│  patient_survey_         │        │  patient_biometric_          │
│  responses               │        │  readings                    │
│                          │        │                              │
│  Change response_        │        │  Add/update biometric        │
│  option_id to match      │        │  value                       │
│  tracked data            │        │                              │
└──────────────────────────┘        └──────────────────────────────┘
         │                                           │
         └─────────────────────┬─────────────────────┘
                               ↓
┌─────────────────────────────────────────────────────────────────┐
│              EXISTING WELLPATH SCORER                            │
│  - Reads patient_survey_responses (now updated by tracking!)    │
│  - Reads patient_biometric_readings (now updated by tracking!)  │
│  - Reads patient_biomarker_readings (lab results unchanged)     │
│  - Calculates WellPath Score using existing logic               │
└─────────────────────────────────────────────────────────────────┘
                               ↓
                    WellPath Score Updates!
```

---

## Key Insights

### 1. Mobile App Data Sources (from BiometricsService.swift)

**Confirmed Reading From:**
- Line 18: `patient_biomarker_readings` (for lab results)
- Line 103: `patient_biometric_readings` (for physical measurements)

### 2. WellPath Scorer Data Sources (from data_fetcher.py)

**Currently Trying to Read From (old V1 table names):**
- `survey_responses` → should be `patient_survey_responses`
- `biomarker_readings` → should be `patient_biomarker_readings`
- `biometric_readings` → should be `patient_biometric_readings`

### 3. Tables That Actually Exist (V2 Database)

**Patient Data Tables:**
- ✅ `patient_survey_responses` (130 records for perfect patient)
- ✅ `patient_biomarker_readings` (for lab results)
- ✅ `patient_biometric_readings` (16 records for perfect patient)
- ✅ `patient_data_entries` (2005 tracking entries for perfect patient)

**Configuration Tables:**
- ✅ `biometric_aggregations_scoring` (146 scoring ranges - just added!)
- ✅ `survey_response_options_aggregations` (159 response option mappings)
- ✅ `aggregation_metrics` (all aggregation metric definitions)

**Missing/Empty:**
- ❌ `aggregation_results_cache` (0 records - needs population!)

---

## What Needs to Happen

### Phase 1: Populate Aggregation Cache (CRITICAL)

The `aggregation_results_cache` is currently empty. Need to run aggregation pipeline to populate:
- AGG_BMI from height/weight instance calculations
- AGG_STEPS from daily step tracking
- AGG_WATER_CONSUMPTION from water entries
- AGG_CARDIO_SESSION_COUNT from cardio tracking
- AGG_DEEP_SLEEP_DURATION from sleep tracking
- etc.

### Phase 2: Revise Edge Functions

#### `update-biometric-scores/index.ts`

**Current (WRONG):**
```typescript
// Writes to patient_wellpath_score_items
await supabase
  .from('patient_wellpath_score_items')
  .upsert({...})
```

**Should Be (CORRECT):**
```typescript
// Writes to patient_biometric_readings (where mobile app reads from!)
await supabase
  .from('patient_biometric_readings')
  .upsert({
    user_id: userId,
    biometric_name: 'BMI',  // matches biometrics_base.biometric_name
    value: latestAgg.value,
    unit: 'kg/m²',
    recorded_at: latestAgg.period_end,
    source: 'auto_calculated'
  })
```

#### `update-survey-scores/index.ts`

**Current (conceptual):**
```typescript
// Updates patient_effective_responses
await supabase
  .from('patient_effective_responses')
  .upsert({...})
```

**Should Be (CORRECT):**
```typescript
// UPDATES patient_survey_responses (changes response option!)
await supabase
  .from('patient_survey_responses')
  .update({
    response_option_id: matchedResponseOption,
    updated_at: NOW(),
    data_source: 'auto_updated_from_tracking'
  })
  .eq('user_id', userId)
  .eq('question_number', questionNumber)
```

### Phase 3: Fix Scorer Table Names

Update `scoring_engine/utils/data_fetcher.py` to use V2 table names:
- `survey_responses` → `patient_survey_responses`
- `biomarker_readings` → `patient_biomarker_readings`
- `biometric_readings` → `patient_biometric_readings`

---

## Benefits of This Approach

### ✅ Single Source of Truth
- Mobile app reads from `patient_biometric_readings`
- Dynamic scoring WRITES to `patient_biometric_readings`
- Existing scorer READS from `patient_biometric_readings`
- **Everyone uses the same table!**

### ✅ Treats Tracked Data Like Manual Entry
- User manually enters BMI → goes to `patient_biometric_readings`
- System calculates BMI from tracking → goes to `patient_biometric_readings`
- **No difference in downstream processing!**

### ✅ Reuses Existing Scorer Logic
- Don't need to rebuild scoring algorithms
- Don't need to change mobile app queries
- Just populate the tables the system already expects

### ✅ Clean Audit Trail
- Can track `source` field: 'manual' vs 'auto_calculated'
- Can see when dynamic scoring overrode survey response
- Can revert if needed

---

## Example: BMI Dynamic Scoring

### Current State
```sql
-- Patient has tracking data
SELECT COUNT(*) FROM patient_data_entries
WHERE user_id = '...' AND field_id IN ('DEF_HEIGHT', 'DEF_WEIGHT');
-- Returns: ~30 entries

-- But biometric readings table is stale
SELECT * FROM patient_biometric_readings
WHERE user_id = '...' AND biometric_name = 'BMI';
-- Returns: 1 old record from Oct 16

-- And aggregation cache is empty
SELECT * FROM aggregation_results_cache
WHERE user_id = '...' AND agg_metric_id = 'AGG_BMI';
-- Returns: 0 records ❌
```

### What Should Happen
```sql
-- 1. Aggregation pipeline runs
INSERT INTO aggregation_results_cache
  (user_id, agg_metric_id, value, period_end, data_point_count)
VALUES
  ('...', 'AGG_BMI', 32.65, '2025-10-21', 30);

-- 2. Edge function update-biometric-scores runs
-- Reads AGG_BMI from cache (32.65)
-- Finds it matches "Obese" range (30-34.9) with score 0.3

-- 3. Edge function WRITES to patient_biometric_readings
INSERT INTO patient_biometric_readings
  (user_id, biometric_name, value, unit, recorded_at, source)
VALUES
  ('...', 'BMI', 32.65, 'kg/m²', NOW(), 'auto_calculated')
ON CONFLICT (user_id, biometric_name)
DO UPDATE SET
  value = 32.65,
  recorded_at = NOW(),
  source = 'auto_calculated';

-- 4. Mobile app SEES the update immediately
SELECT * FROM patient_biometric_readings
WHERE user_id = '...' AND biometric_name = 'BMI';
-- Returns: BMI = 32.65 (latest!)

-- 5. WellPath scorer SEES the update and recalculates
-- No code changes needed - it already reads from patient_biometric_readings!
```

---

## Tables to Deprecate/Remove

These tables were created for the WRONG architecture:

- ❌ `patient_effective_responses` - Should update `patient_survey_responses` instead
- ❌ `patient_wellpath_score_items` - Scorer already has its own scoring tables
- ❌ `function_aggregation_mappings` - Response options handle this

---

## Next Steps

1. **Run aggregation pipeline** to populate `aggregation_results_cache`
2. **Revise edge functions** to write to source tables
3. **Fix scorer** table names (V1 → V2)
4. **Test with perfect patient**:
   - Add weight/height tracking data
   - Run aggregation
   - Run edge function
   - Verify `patient_biometric_readings` updated
   - Verify mobile app shows new BMI
   - Verify scorer uses new BMI
5. **Deploy to production**

---

## Status

- ✅ Migration complete: 149 biometric scoring ranges
- ✅ Architecture audit complete
- ✅ Source tables identified
- ⏳ Edge functions need revision
- ⏳ Aggregation cache needs population
- ⏳ End-to-end testing needed
