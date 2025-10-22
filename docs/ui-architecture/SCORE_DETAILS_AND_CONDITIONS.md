# WellPath Score Details & Patient Conditions

## 1. Patient Conditions & Biomarker Range Matching

### Current Implementation Status

The biomarker/biometric range matching currently supports:
- ✅ **Age ranges** (`age_low`, `age_high`)
- ✅ **Gender** (`gender`: Male, Female, All)
- ⚠️ **Unique conditions** (`unique_condition`: CKD, athlete, etc.) - **NOT YET IMPLEMENTED**
- ⚠️ **Menopausal status** (`menopausal_status`) - **NOT YET IMPLEMENTED**
- ⚠️ **Cycle stage** (`cycle_stage`: Follicular, Luteal, Ovulatory) - **NOT YET IMPLEMENTED**

### What Needs to Be Done

#### A. Store Patient Conditions

Add these columns to `patient_details` table (or create a separate `patient_conditions` table):

```sql
ALTER TABLE patient_details
ADD COLUMN has_ckd BOOLEAN DEFAULT FALSE,
ADD COLUMN is_athlete BOOLEAN DEFAULT FALSE,
ADD COLUMN menopausal_status TEXT,  -- 'premenopausal', 'perimenopausal', 'postmenopausal'
ADD COLUMN current_cycle_stage TEXT;  -- 'Follicular', 'Luteal', 'Ovulatory', NULL for males
```

#### B. Update Edge Function Logic

Modify `calculateMarkerScore` in the Edge Function to match conditions:

```typescript
const applicableRanges = allRangesForMarker.filter(r => {
  // Existing: Check gender match
  if (r.gender && r.gender !== 'All') {
    if (r.gender !== patientGenderFull) return false
  }

  // Existing: Check age range
  if (r.age_low && patient.age < r.age_low) return false
  if (r.age_high && patient.age > r.age_high) return false

  // NEW: Check unique condition
  if (r.unique_condition) {
    // If range requires a condition, patient must have it
    // If patient doesn't have the condition, check if there's a NULL condition range instead
    if (r.unique_condition === 'CKD' && !patient.has_ckd) {
      // Check if there's an equivalent range without CKD condition
      const hasNonCKDRange = allRangesForMarker.some(alt =>
        alt.unique_condition === null &&
        alt.gender === r.gender &&
        alt.age_low === r.age_low &&
        alt.age_high === r.age_high
      )
      if (hasNonCKDRange) return false // Skip CKD range, use normal range instead
    }
    // Add similar logic for athlete, etc.
  }

  // NEW: Check menopausal status
  if (r.menopausal_status && r.menopausal_status !== patient.menopausal_status) {
    return false
  }

  // NEW: Check cycle stage
  if (r.cycle_stage && r.cycle_stage !== patient.current_cycle_stage) {
    return false
  }

  return true
})
```

#### C. Prioritization Logic

When multiple ranges match (e.g., both CKD and non-CKD ranges), prioritize:

1. **Most specific condition match** (CKD range if patient has CKD)
2. **Highest score** (prefer optimal ranges)
3. **Narrowest range** (more specific is better)

```typescript
// After filtering to applicable ranges, sort by specificity:
const bestRange = applicableRanges.sort((a, b) => {
  // Priority 1: Prefer ranges with matching conditions over NULL
  const aSpecificity = (a.unique_condition ? 1 : 0) + (a.menopausal_status ? 1 : 0) + (a.cycle_stage ? 1 : 0)
  const bSpecificity = (b.unique_condition ? 1 : 0) + (b.menopausal_status ? 1 : 0) + (b.cycle_stage ? 1 : 0)
  if (aSpecificity !== bSpecificity) return bSpecificity - aSpecificity

  // Priority 2: Highest score
  const aScore = Math.max(a.score_at_low ?? 0, a.score_at_high ?? 0)
  const bScore = Math.max(b.score_at_low ?? 0, b.score_at_high ?? 0)
  if (aScore !== bScore) return bScore - aScore

  // Priority 3: Narrowest range
  const aWidth = (a.range_high ?? Infinity) - (a.range_low ?? -Infinity)
  const bWidth = (b.range_high ?? Infinity) - (b.range_low ?? -Infinity)
  return aWidth - bWidth
})[0]
```

---

## 2. Score Detail Storage Architecture

### Option A: Single Table with JSONB (RECOMMENDED)

**Table:** `wellpath_score_details`

**Structure:**
```sql
CREATE TABLE wellpath_score_details (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id),
    overall_score DECIMAL(5,4),  -- e.g., 0.9000 = 90%

    -- Pillar breakdown stored as JSONB
    pillar_scores JSONB,
    /* Example structure:
    {
      "Core Care": {
        "final_score": 0.896,
        "markers_score": 137.0,
        "markers_max": 137.0,
        "survey_score": 367.0,
        "survey_max": 371.0,
        "education_score": 0.0,
        "education_max": 100.0,
        "component_weights": {
          "markers": 0.72,
          "survey": 0.18,
          "education": 0.10
        }
      },
      "Healthful Nutrition": { ... },
      ...
    }
    */

    -- All scored items stored as JSONB array
    scored_items JSONB,
    /* Example structure:
    [
      {
        "item_name": "LDL",
        "item_type": "biomarker",
        "raw_value": 85.0,
        "normalized_score": 1.0,
        "pillar_contributions": [
          {
            "pillar_name": "Core Care",
            "weight": 7,
            "weighted_score": 7.0
          }
        ]
      },
      {
        "item_name": "screening_psa_score",
        "item_type": "survey_function",
        "normalized_score": 1.0,
        "pillar_contributions": [
          {
            "pillar_name": "Core Care",
            "weight": 4,
            "weighted_score": 4.0
          }
        ]
      },
      ...
    ]
    */

    calculated_at TIMESTAMPTZ,
    calculation_version TEXT
)
```

**Advantages:**
- ✅ **Simple** - One table, one row per calculation
- ✅ **Flexible** - Easy to add new pillars/items without schema changes
- ✅ **Fast queries** - GIN indexes on JSONB for efficient filtering
- ✅ **Historical** - Keep multiple calculations per user over time
- ✅ **Complete** - All data in one place

**Query Examples:**

```sql
-- Get latest full breakdown
SELECT * FROM wellpath_score_details
WHERE user_id = 'xxx'
ORDER BY calculated_at DESC
LIMIT 1;

-- Get just Core Care pillar
SELECT pillar_scores->'Core Care' as core_care
FROM wellpath_score_details
WHERE user_id = 'xxx'
ORDER BY calculated_at DESC
LIMIT 1;

-- Get all biomarkers with their scores
SELECT jsonb_array_elements(scored_items) as item
FROM wellpath_score_details
WHERE user_id = 'xxx'
  AND jsonb_array_elements(scored_items)->>'item_type' = 'biomarker'
ORDER BY calculated_at DESC
LIMIT 1;

-- Get all items for a specific pillar
SELECT item
FROM (
    SELECT jsonb_array_elements(scored_items) as item
    FROM wellpath_score_details
    WHERE user_id = 'xxx'
    ORDER BY calculated_at DESC
    LIMIT 1
) items
WHERE item->'pillar_contributions'->0->>'pillar_name' = 'Core Care';
```

### Option B: Normalized Tables (More Complex)

Create separate tables:
- `wellpath_score_calculations` - Overall score + metadata
- `wellpath_pillar_scores` - One row per pillar per calculation
- `wellpath_scored_items` - One row per item per calculation

**Advantages:**
- ✅ More traditional relational structure
- ✅ Easier to query individual items

**Disadvantages:**
- ❌ More complex schema (3+ tables)
- ❌ Requires JOINs for full breakdown
- ❌ More rows to insert/update (could be 100+ items per patient)

---

## 3. Application UI Flow

### Top Level: Overall Score
```
Your WellPath Score: 89.6%
[Progress circle showing 89.6%]

Last Updated: Oct 16, 2024
```

### Pillar Breakdown
```
Tap to expand each pillar:

Core Care: 89.6%
├─ Biomarkers: 137.0/137.0 (100%)  [Tap to see details]
├─ Surveys: 367.0/371.0 (98.9%)    [Tap to see details]
└─ Education: 0.0/100.0 (0%)       [Tap to see details]

Healthful Nutrition: 90.0%
├─ Biomarkers: 258.0/258.0 (100%)
├─ Surveys: 91.0/91.0 (100%)
└─ Education: 0.0/100.0 (0%)

... (other pillars)
```

### Item Detail: Biomarkers
```
Core Care - Biomarkers (137.0/137.0)

✓ LDL: 7.0/7.0          [Tap → Chart view]
✓ HDL: 6.0/6.0          [Tap → Chart view]
✓ Triglycerides: 6.0/6.0 [Tap → Chart view]
✓ HbA1c: 7.0/7.0        [Tap → Chart view]
...
```

### Query Functions for App

```sql
-- Function 1: Get overall score
CREATE FUNCTION get_user_overall_score(p_user_id UUID)
RETURNS DECIMAL AS $$
    SELECT overall_score
    FROM wellpath_score_details
    WHERE user_id = p_user_id
    ORDER BY calculated_at DESC
    LIMIT 1;
$$ LANGUAGE sql;

-- Function 2: Get pillar breakdown
CREATE FUNCTION get_pillar_breakdown(p_user_id UUID)
RETURNS JSONB AS $$
    SELECT pillar_scores
    FROM wellpath_score_details
    WHERE user_id = p_user_id
    ORDER BY calculated_at DESC
    LIMIT 1;
$$ LANGUAGE sql;

-- Function 3: Get biomarkers for a pillar
CREATE FUNCTION get_pillar_biomarkers(
    p_user_id UUID,
    p_pillar_name TEXT
)
RETURNS TABLE (
    biomarker_name TEXT,
    raw_value DECIMAL,
    normalized_score DECIMAL,
    weight DECIMAL,
    weighted_score DECIMAL
) AS $$
    SELECT
        item->>'item_name' as biomarker_name,
        (item->>'raw_value')::decimal as raw_value,
        (item->>'normalized_score')::decimal as normalized_score,
        (item->'pillar_contributions'->0->>'weight')::decimal as weight,
        (item->'pillar_contributions'->0->>'weighted_score')::decimal as weighted_score
    FROM (
        SELECT jsonb_array_elements(scored_items) as item
        FROM wellpath_score_details
        WHERE user_id = p_user_id
        ORDER BY calculated_at DESC
        LIMIT 1
    ) items
    WHERE item->>'item_type' = 'biomarker'
      AND item->'pillar_contributions'->0->>'pillar_name' = p_pillar_name
    ORDER BY biomarker_name;
$$ LANGUAGE sql;
```

---

## 4. Implementation Steps

### Phase 1: Add Patient Conditions (Priority)
1. Add condition columns to patient_details
2. Update Edge Function to pass conditions in patient object
3. Modify range filtering logic to check conditions
4. Test with CKD patient data

### Phase 2: Score Detail Storage
1. Run migration to create wellpath_score_details table
2. Modify Edge Function to save full breakdown to this table
3. Create helper functions for querying
4. Update batch_calculate_scores.py to save details

### Phase 3: App Integration
1. Create API endpoints that use the query functions
2. Build UI screens for pillar breakdown
3. Build UI screens for item lists (biomarkers, surveys, etc.)
4. Add tap-through to existing chart screens

---

## 5. Recommended Approach

**I recommend Option A (Single Table with JSONB)** because:

1. **Simplicity** - One table, one row per calculation
2. **Performance** - JSONB is highly optimized in Postgres, GIN indexes make queries fast
3. **Flexibility** - Can easily add new data without migrations
4. **Complete** - All the data the Edge Function already returns, just stored as-is
5. **Historical** - Can keep multiple calculations to show trends

The Edge Function already returns the exact structure we need - we just need to save it!
