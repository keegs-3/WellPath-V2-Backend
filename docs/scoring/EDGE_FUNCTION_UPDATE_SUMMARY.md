# Edge Function Update Summary - Category Grouping & Normalized Weights

## Date: 2025-10-17

## Overview

Updated the `calculate-wellpath-score` Edge Function to use pre-calculated normalized weights and add category/hierarchy grouping to all scored items. This enables proper UI display with items grouped by functional categories.

---

## Changes Made

### 1. Updated Marker Scoring (`calculateMarkerScores`)

**File**: `/Users/keegs/Documents/GitHub/WellPath-V2-Backend/supabase/functions/calculate-wellpath-score/index.ts`

#### Changed Query Source
```typescript
// OLD: Query from base table
const { data: markerWeights } = await supabase
  .from('wellpath_scoring_marker_pillar_weights')
  .select('...')

// NEW: Query from normalized weights view
const { data: markerWeights } = await supabase
  .from('wellpath_scoring_marker_pillar_weights_normalized')
  .select('biomarker_name, biometric_name, pillar_name, weight, normalized_weight, ...')
```

#### Added Category Mapping
```typescript
// Fetch category mappings
const { data: biomarkerCategories } = await supabase
  .from('biomarkers_category')
  .select('biomarker, category')

const { data: biometricCategories } = await supabase
  .from('biometrics_category')
  .select('biometric, category')

// Create lookup maps
const biomarkerCategoryMap = new Map(biomarkerCategories?.map(bc => [bc.biomarker, bc.category]) || [])
const biometricCategoryMap = new Map(biometricCategories?.map(bc => [bc.biometric, bc.category]) || [])
```

#### Updated Weight Usage
```typescript
// OLD: Used raw weight
scores[pillar].max += weight.weight
const weightedScore = markerScore * weight.weight

// NEW: Use normalized weight
scores[pillar].max += weight.normalized_weight
const weightedScore = markerScore * weight.normalized_weight
```

#### Added Category to Scored Items
```typescript
// Lookup category for this marker
const category = weight.biomarker_name
  ? biomarkerCategoryMap.get(markerName)
  : biometricCategoryMap.get(markerName)

const scoredItem: ScoredItem = {
  item_name: markerName,
  item_type: weight.biomarker_name ? 'biomarker' : 'biometric',
  category: category,  // ← NEW: Category added
  raw_value: markerData?.value,
  normalized_score: markerScore,
  pillar_contributions: [{
    pillar_name: pillar,
    weight: weight.normalized_weight,  // ← Uses normalized weight
    weighted_score: weightedScore
  }]
}
```

---

### 2. Updated Survey Question Scoring (`calculateSurveyScores`)

#### Changed Query Source
```typescript
// OLD: Query from base table
const { data: questionWeights } = await supabase
  .from('wellpath_scoring_question_pillar_weights')
  .select('...')

// NEW: Query from normalized weights view
const { data: questionWeights } = await supabase
  .from('wellpath_scoring_question_pillar_weights_normalized')
  .select('question_number, pillar_name, weight, normalized_weight, ...')
```

#### Added Survey Hierarchy Mapping
```typescript
// Fetch question hierarchy (question → group → category → section)
const { data: questionHierarchy } = await supabase
  .from('survey_questions_base')
  .select(`
    question_number,
    group_id,
    survey_groups!inner(
      group_id,
      display_name,
      category_id,
      survey_categories!inner(
        category_id,
        display_name,
        section_id,
        survey_sections!inner(
          section_id,
          display_name
        )
      )
    )
  `)

// Create a map from question_number to hierarchy info
const questionHierarchyMap = new Map()
if (questionHierarchy) {
  for (const q of questionHierarchy) {
    const group = q.survey_groups
    const category = group?.survey_categories
    const section = category?.survey_sections

    questionHierarchyMap.set(q.question_number, {
      group_id: group?.group_id,
      group_name: group?.display_name,
      category_id: category?.category_id,
      category_name: category?.display_name,
      section_id: section?.section_id,
      section_name: section?.display_name
    })
  }
}
```

#### Updated Weight Usage
```typescript
// OLD: Used raw weight
scores[pillar].max += qw.weight
const weightedScore = normalizedScore * qw.weight

// NEW: Use normalized weight
scores[pillar].max += qw.normalized_weight
const weightedScore = normalizedScore * qw.normalized_weight
```

#### Added Hierarchy to Scored Items
```typescript
// Get hierarchy info for this question
const hierarchy = questionHierarchyMap.get(qw.question_number)

const scoredItem: ScoredItem = {
  item_name: `Q${qw.question_number}`,
  item_type: 'survey_question',
  category: hierarchy?.category_name || hierarchy?.group_name || hierarchy?.section_name,  // ← NEW
  raw_value: answer,
  normalized_score: normalizedScore,
  pillar_contributions: [{
    pillar_name: pillar,
    weight: qw.normalized_weight,  // ← Uses normalized weight
    weighted_score: weightedScore
  }]
}
```

---

### 3. Updated Survey Function Scoring

#### Changed Query Source
```typescript
// OLD: Query from base table
const { data: functionWeights } = await supabase
  .from('wellpath_scoring_question_pillar_weights')
  .select('...')

// NEW: Query from normalized weights view
const { data: functionWeights } = await supabase
  .from('wellpath_scoring_question_pillar_weights_normalized')
  .select('function_name, pillar_name, weight, normalized_weight')
```

#### Updated Weight Usage
```typescript
// OLD: Used raw weight
scores[pillar].max += fw.weight
const weightedScore = functionScore * fw.weight

// NEW: Use normalized weight
scores[pillar].max += fw.normalized_weight
const weightedScore = functionScore * fw.normalized_weight
```

---

### 4. Updated ScoredItem Interface

```typescript
// OLD
interface ScoredItem {
  item_name: string
  item_type: 'biomarker' | 'biometric' | 'survey_question' | 'survey_function'
  raw_value?: any
  normalized_score: number
  pillar_contributions: {
    pillar_name: string
    weight: number
    weighted_score: number
  }[]
}

// NEW
interface ScoredItem {
  item_name: string
  item_type: 'biomarker' | 'biometric' | 'survey_question' | 'survey_function'
  category?: string  // ← NEW: Category or hierarchy level name
  raw_value?: any
  normalized_score: number
  pillar_contributions: {
    pillar_name: string
    weight: number  // This is now normalized_weight
    weighted_score: number
  }[]
}
```

---

### 5. Simplified Final Score Calculation

```typescript
// OLD: Complex calculation with component percentages
const finalScore = (
  (markers.score / markers.max) * weights.markers +
  (survey.score / survey.max) * weights.survey +
  (education.score / education.max) * weights.education
) * 100

// NEW: Simple sum (scores already normalized to component percentage)
// e.g., markers.max for Nutrition = 72 (72% of 100), survey.max = 18, education.max = 10
// So final score is just sum of all components
const finalScore = markers.score + survey.score + education.score
```

---

## Benefits

### 1. **Correct Individual Item Contributions**
- Each scored item now shows its actual percentage contribution to the pillar score
- Example: ALT with weight 3 in Nutrition shows 0.83% contribution (calculated as `(3 / 260) * 0.72`)

### 2. **Category Grouping for UI**
- Biomarkers grouped by functional categories: "Metabolism", "Cardiovascular Health", "Kidney Function", etc.
- Biometrics grouped by categories: "Body Composition", "Vital Signs", etc.
- Survey questions grouped by hierarchy: Section → Category → Group

### 3. **Pre-calculated Normalization**
- Normalization factors calculated once in database views
- Edge Function just reads and uses normalized weights
- No runtime calculations needed

### 4. **Simplified Scoring Logic**
- Removed complex normalization formulas from Edge Function
- Scores already in correct scale (0-100 with component percentages)
- Final score is simple addition

---

## Database Views Used

### 1. `wellpath_scoring_marker_pillar_weights_normalized`
Adds `normalized_weight` column to biomarker/biometric weights:
```sql
normalized_weight = (weight / markers_total) * marker_weight
```
Example: ALT with weight 3 in Nutrition = `(3 / 260) * 0.72 = 0.0083` or 0.83%

### 2. `wellpath_scoring_question_pillar_weights_normalized`
Adds `normalized_weight` column to question/function weights:
```sql
normalized_weight = (weight / survey_total) * survey_weight
```

### 3. `wellpath_scoring_pillar_component_weights_with_sum`
Calculates total weights per component:
- `markers_total` = sum of all biomarker/biometric weights for a pillar
- `survey_total` = sum of all question/function weights for a pillar

---

## Category Mappings Used

### 1. `biomarkers_category`
Maps each biomarker to a functional category:
```sql
biomarker | category
----------|------------------
ALT       | Liver Function
Glucose   | Metabolism
```

### 2. `biometrics_category`
Maps each biometric to a category:
```sql
biometric     | category
--------------|------------------
Weight        | Body Composition
Blood Pressure| Vital Signs
```

### 3. Survey Hierarchy
Maps questions through hierarchy:
```
Question → Group → Category → Section
```

---

## Deployment

### Deployed to Supabase
```bash
supabase functions deploy calculate-wellpath-score
```

**Status**: ✅ Deployed successfully

**URL**: `https://csotzmardnvrpdhlogjm.supabase.co/functions/v1/calculate-wellpath-score`

---

## Testing

### Test Status
- ✅ Edge Function deployed
- ⏳ Function testing pending (JWT configuration issue)
- ⏳ Category grouping verification pending

### Test Patient
- **Patient ID**: `1758fa60-a306-440e-8ae6-9e68fd502bc2`
- **Data**: 60 biomarkers, 16 biometrics, 337 survey responses

### Next Steps for Testing
1. Fix JWT authentication configuration
2. Call Edge Function with test patient
3. Verify:
   - Normalized weights are used correctly
   - Categories are populated for all items
   - Biomarkers/biometrics group by category
   - Survey questions group by hierarchy
   - Final scores match expected values

---

## Expected Response Structure

```json
{
  "patient_id": "1758fa60-a306-440e-8ae6-9e68fd502bc2",
  "overall_score": 87.5,
  "pillar_scores": [
    {
      "pillar_name": "pillar_nutrition",
      "markers_score": 65.2,
      "markers_max": 72.0,
      "survey_score": 16.5,
      "survey_max": 18.0,
      "education_score": 8.0,
      "education_max": 10.0,
      "final_score": 89.7,
      "component_weights": {
        "markers": 0.72,
        "survey": 0.18,
        "education": 0.10
      },
      "scored_items": [
        {
          "item_name": "ALT",
          "item_type": "biomarker",
          "category": "Liver Function",
          "raw_value": 18,
          "normalized_score": 1.0,
          "pillar_contributions": [{
            "pillar_name": "pillar_nutrition",
            "weight": 0.0083,
            "weighted_score": 0.0083
          }]
        },
        {
          "item_name": "Q2.01",
          "item_type": "survey_question",
          "category": "Dietary Patterns & Structure",
          "raw_value": "Balanced diet",
          "normalized_score": 0.9,
          "pillar_contributions": [{
            "pillar_name": "pillar_nutrition",
            "weight": 0.0125,
            "weighted_score": 0.01125
          }]
        }
      ]
    }
  ]
}
```

---

## UI Display Integration (Next Steps)

### 1. Group Items by Category
```typescript
// Group biomarkers/biometrics by category
const markersByCategory = new Map<string, ScoredItem[]>()
for (const item of scoredItems) {
  if (item.item_type === 'biomarker' || item.item_type === 'biometric') {
    const category = item.category || 'Uncategorized'
    if (!markersByCategory.has(category)) {
      markersByCategory.set(category, [])
    }
    markersByCategory.get(category)!.push(item)
  }
}
```

### 2. Group Survey Questions by Hierarchy
```typescript
// Group survey questions by category/section
const questionsByCategory = new Map<string, ScoredItem[]>()
for (const item of scoredItems) {
  if (item.item_type === 'survey_question') {
    const category = item.category || 'Uncategorized'
    if (!questionsByCategory.has(category)) {
      questionsByCategory.set(category, [])
    }
    questionsByCategory.get(category)!.push(item)
  }
}
```

### 3. Display with Drill-Down
```
Pillar: Nutrition (89.7%)
├─ Biomarkers (65.2 / 72)
│  ├─ Liver Function
│  │  ├─ ALT: 100% (0.83% contribution)
│  │  └─ AST: 95% (0.83% contribution)
│  ├─ Metabolism
│  │  ├─ Glucose: 90% (1.2% contribution)
│  │  └─ HbA1c: 85% (1.5% contribution)
│  └─ [Other categories...]
├─ Survey (16.5 / 18)
│  ├─ Dietary Patterns & Structure
│  │  ├─ Q2.01: 90% (1.25% contribution)
│  │  └─ Q2.02: 85% (1.25% contribution)
│  └─ [Other categories...]
└─ Education (8.0 / 10)
```

---

## Files Modified

1. `/Users/keegs/Documents/GitHub/WellPath-V2-Backend/supabase/functions/calculate-wellpath-score/index.ts`
   - Updated marker scoring queries
   - Updated survey scoring queries
   - Added category mapping fetches
   - Updated ScoredItem interface
   - Simplified final score calculation

---

## Documentation Created

1. This summary: `EDGE_FUNCTION_UPDATE_SUMMARY.md`
2. Test script: `/Users/keegs/Documents/GitHub/WellPath-V2-Backend/scripts/dev_only/test_edge_function.js`

---

## Status: ✅ Complete (Pending Testing)

All code changes complete and deployed. Testing blocked by JWT configuration issue - will need to resolve authentication before verifying functionality.

**Version**: 2.1
**Last Updated**: 2025-10-17
