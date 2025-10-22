# WellPath Scoring Flow - Current Status

**Date**: October 16, 2024
**Status**: Data Ready, Scoring Not Yet Run

---

## Current State Overview

### ✅ What's Populated (Data Layer)

| Component | Count | Status | Description |
|-----------|-------|--------|-------------|
| **Test Patients** | 50 | ✅ Complete | Full demographics, age, gender |
| **Biomarker Readings** | 2,972 | ✅ Complete | ~60 biomarkers per patient |
| **Biometric Readings** | 800 | ✅ Complete | ~16 biometrics per patient |
| **Survey Responses** | 16,643 | ✅ Complete | ~337 responses per patient |
| **UI Sections** | 19 | ✅ Complete | Hierarchy config (pillars + behaviors) |
| **UI Items** | 7 | ⚠️ Partial | Examples only (3 alcohol questions, 4 biomarkers) |
| **Question Content** | 1 | ⚠️ Partial | Only alcohol question 8.05 populated |

### ❌ What's NOT Populated (Scoring Layer)

| Component | Count | Status | Description |
|-----------|-------|--------|-------------|
| **`patient_scoring_features`** | 0 | ❌ Empty | Where Edge Function saves calculated scores |
| **`patient_wellpath_score_display`** | 0 | ❌ Empty | Where UI display data should be saved |

---

## The Complete Flow

```
┌─────────────────────────────────────────────────────────────┐
│ LAYER 1: RAW DATA (✅ POPULATED - 50 patients)             │
├─────────────────────────────────────────────────────────────┤
│ • patient_details (50 patients)                             │
│ • patient_biomarker_readings (2,972 readings)               │
│ • patient_biometric_readings (800 readings)                 │
│ • patient_survey_responses (16,643 responses)               │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ LAYER 2: SCORING CONFIG (✅ POPULATED)                      │
├─────────────────────────────────────────────────────────────┤
│ • wellpath_scoring_marker_pillar_weights                    │
│ • wellpath_scoring_question_pillar_weights                  │
│ • wellpath_scoring_pillar_component_weights                 │
│ • wellpath_scoring_survey_functions                         │
│ • biomarkers_detail (ranges by age/gender)                  │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ LAYER 3: EDGE FUNCTION (❌ NOT RUN YET)                    │
├─────────────────────────────────────────────────────────────┤
│ Location: supabase/functions/calculate-wellpath-score/      │
│                                                              │
│ What it does:                                                │
│ 1. Fetches patient data (biomarkers, biometrics, survey)    │
│ 2. Scores each biomarker using age/gender ranges            │
│ 3. Scores survey questions and functions                    │
│ 4. Calculates 7 pillar scores                               │
│ 5. Calculates overall score (72% markers + 18% survey)      │
│ 6. SAVES to patient_scoring_features ← NOT HAPPENING YET    │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ LAYER 4: CALCULATED SCORES (❌ EMPTY)                       │
├─────────────────────────────────────────────────────────────┤
│ • patient_scoring_features (0 rows) ← NEEDS EDGE FUNCTION   │
│   - Overall wellpath_score                                   │
│   - 7 pillar scores                                          │
│   - Component breakdowns (markers, survey, education)        │
│   - calculation_details (JSONB with full breakdown)          │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ LAYER 5: UI DISPLAY CONFIG (✅ PARTIALLY POPULATED)         │
├─────────────────────────────────────────────────────────────┤
│ • wellpath_score_display_sections (19 sections)             │
│   - 7 pillars                                                │
│   - Behaviors cross-pillar view                              │
│   - Substances hierarchy (alcohol, tobacco, etc.)            │
│                                                               │
│ • wellpath_score_display_items (7 items)                    │
│   ⚠️ Only examples - needs ALL biomarkers/questions          │
│                                                               │
│ • wellpath_score_question_content (1 question)              │
│   ⚠️ Only alcohol question - needs ~100+ questions           │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ LAYER 6: PATIENT UI DATA (❌ EMPTY - FUTURE)                │
├─────────────────────────────────────────────────────────────┤
│ • patient_wellpath_score_display (0 rows)                   │
│   - Combines calculated scores + UI config                   │
│   - section_scores JSONB (scores for each section)          │
│   - item_scores JSONB (individual item details + content)   │
│   ← REQUIRES EDGE FUNCTION UPDATE                            │
└─────────────────────────────────────────────────────────────┘
```

---

## What You Can Do Right Now

### 1. Calculate Scores (Layer 3 → Layer 4)

**Run batch calculation**:
```bash
cd scripts/dev_only
python batch_calculate_scores.py
```

This will:
- ✅ Call the Edge Function for all 50 patients
- ✅ Calculate overall scores (expect ~54% average)
- ✅ Calculate 7 pillar scores for each patient
- ✅ Save to `patient_scoring_features` table
- ❌ NOT save to `patient_wellpath_score_display` (not implemented yet)

**Run single patient**:
```bash
python calculate_one_score.py <user_id>
```

### 2. View Scores (After Running Above)

After running batch calculation, you'll have data in `patient_scoring_features`:

```sql
-- Get all patient scores
SELECT
    patient_id,
    wellpath_score,
    pillar_nutrition_score,
    pillar_movement_score,
    pillar_sleep_score,
    last_calculated_at
FROM patient_scoring_features
ORDER BY wellpath_score DESC;

-- Get detailed breakdown for one patient
SELECT
    patient_id,
    wellpath_score,
    calculation_details
FROM patient_scoring_features
WHERE patient_id = 'xxx';
```

### 3. Test UI Hierarchy (Layer 5)

The UI hierarchy is already working:

```sql
-- Get top-level sections
SELECT * FROM get_section_hierarchy('user-id', NULL);

-- Drill into Behaviors
SELECT * FROM get_section_hierarchy('user-id', 'behaviors');

-- Drill into Substances
SELECT * FROM get_section_hierarchy('user-id', 'behaviors_substances');

-- Get alcohol question details
SELECT * FROM wellpath_score_question_content WHERE question_number = '8.05';
```

---

## What's Missing

### Phase 2: Edge Function Update (REQUIRED)

**File**: `supabase/functions/calculate-wellpath-score/index.ts`

**What needs to be added**:

After the Edge Function calculates scores, it needs to ALSO populate `patient_wellpath_score_display`:

```typescript
// After calculating pillarScores and overallScore...

// 1. Load UI sections config
const { data: sections } = await supabase
  .from('wellpath_score_display_sections')
  .select('*')

// 2. Calculate section scores based on aggregation rules
const sectionScores = {}
for (const section of sections) {
  if (section.aggregation_type === 'pillar_component') {
    // Use existing pillar score
    const pillarName = section.aggregation_source.pillar_name
    sectionScores[section.section_key] = {
      score: pillarScores[pillarName],
      max: 1.0,
      percentage: pillarScores[pillarName] * 100
    }
  } else if (section.aggregation_type === 'function_rollup') {
    // Sum the specified functions
    const functions = section.aggregation_source.function_names
    // Calculate rollup score...
  }
  // ... handle other aggregation types
}

// 3. Build item_scores array
const { data: displayItems } = await supabase
  .from('wellpath_score_display_items')
  .select('*, content:wellpath_score_question_content(*)')

const itemScores = scoredItems.map(item => ({
  section_key: item.section_key,
  item_type: item.item_type,
  item_id: item.item_id,
  patient_score: item.normalized_score,
  patient_data: {
    value: item.raw_value,
    answer: item.response_text
  },
  content: {
    tips: displayItems.find(d => d.item_id === item.item_id)?.quick_tips,
    longevity_impact: displayItems.find(d => d.item_id === item.item_id)?.longevity_impact
  }
}))

// 4. Save to patient_wellpath_score_display
await supabase
  .from('patient_wellpath_score_display')
  .upsert({
    user_id: patientId,
    overall_score: overallScore,
    section_scores: sectionScores,
    item_scores: itemScores,
    calculated_at: new Date()
  })
```

### Phase 3: Content Population (OPTIONAL BUT RECOMMENDED)

**Add all biomarkers to display_items**:
```sql
-- Need to add ~137 biomarkers to wellpath_score_display_items
INSERT INTO wellpath_score_display_items
(section_key, display_order, item_type, item_id, display_name, has_chart)
VALUES
('core_biomarkers', 5, 'biomarker', 'Total_Cholesterol', 'Total Cholesterol', TRUE),
('core_biomarkers', 6, 'biomarker', 'Glucose', 'Fasting Glucose', TRUE),
-- ... 130+ more
```

**Add all survey questions to question_content**:
```sql
-- Need to add ~100+ questions
INSERT INTO wellpath_score_question_content
(question_number, explanation, why_it_matters, response_content)
VALUES
('8.06', 'Duration of alcohol use...', 'Understanding patterns...', '{...}'::jsonb),
-- ... 100+ more
```

---

## Quick Summary

### ✅ Ready to Use Now:
1. **Calculate Scores**: Run `batch_calculate_scores.py` to populate `patient_scoring_features`
2. **Query UI Hierarchy**: Test navigation with helper functions
3. **View Example Content**: Check alcohol question alternatives

### 🚧 Requires Work:
1. **Edge Function Update**: Add code to populate `patient_wellpath_score_display`
2. **Content Population**: Add all biomarkers and questions to display tables

### 📊 Expected Results (After Running Batch):
- 50 patients with calculated scores
- Average score: ~54% (realistic)
- Perfect patient: 90%
- Range: 30-90%

---

## Next Steps

**IMMEDIATE** (5 minutes):
```bash
cd scripts/dev_only
python batch_calculate_scores.py
```
This will populate `patient_scoring_features` so you can see the scores!

**NEXT** (Development work):
- Update Edge Function to populate `patient_wellpath_score_display`
- Add content for all questions and biomarkers

**THEN** (Mobile app):
- Query `patient_wellpath_score_display` for UI
- Implement drill-down navigation
- Show alternatives and tips

---

**Current Status**: Data is ready, scoring engine is ready, UI config is ready. Just need to RUN the scoring and connect the pieces!
