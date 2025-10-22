# WellPath Score Pipeline Architecture

## Overview

The WellPath Score pipeline calculates a comprehensive health score (0-100%) based on:
- **72% Biomarkers & Biometrics** - Lab results and health measurements
- **18% Survey Responses** - Lifestyle and behavior questions
- **10% Education** - Health education completion (future)

## Data Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                      DATA SOURCES                                │
├─────────────────────────────────────────────────────────────────┤
│ • patient_biomarker_readings (2,972 readings, 50 patients)      │
│ • patient_biometric_readings (800 readings, 50 patients)        │
│ • patient_survey_responses (16,643 responses, 50 patients)      │
└────────────────────┬────────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────────┐
│                  SCORING CALCULATION                             │
│              (Edge Function / Batch Script)                      │
├─────────────────────────────────────────────────────────────────┤
│ 1. Calculate biomarker scores (72%)                             │
│    - Fetch latest readings per biomarker                        │
│    - Match to optimal ranges from biomarker_catalog             │
│    - Calculate percentile scores                                │
│                                                                  │
│ 2. Calculate survey scores (18%)                                │
│    - Fetch patient responses                                    │
│    - Match to response scoring rules                            │
│    - Aggregate by group → category → section                    │
│                                                                  │
│ 3. Calculate education scores (10%)                             │
│    - [Future implementation]                                    │
│                                                                  │
│ 4. Aggregate to pillar level                                    │
│    - Weighted average by component type                         │
└────────────────────┬────────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────────┐
│              SCORING FEATURES TABLE                              │
│         patient_scoring_features (per patient)                   │
├─────────────────────────────────────────────────────────────────┤
│ • user_id                                                        │
│ • overall_wellpath_score                                         │
│ • biomarker_biometric_score (72%)                               │
│ • survey_score (18%)                                            │
│ • education_score (10%)                                         │
│ • pillar_scores JSONB: {                                        │
│     "core_care": 85,                                            │
│     "nutrition": 78,                                            │
│     "movement": 92,                                             │
│     ...                                                         │
│   }                                                             │
│ • calculated_at                                                 │
└────────────────────┬────────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────────┐
│                  UI DISPLAY LAYER                                │
│         patient_wellpath_score_display (per patient)             │
├─────────────────────────────────────────────────────────────────┤
│ • user_id                                                        │
│ • section_key (e.g., 'pillar_nutrition')                        │
│ • section_score                                                 │
│ • item_scores JSONB: [                                          │
│     {                                                           │
│       "item_key": "survey_question_2.01",                       │
│       "score": 85,                                              │
│       "patient_value": "Balanced diet",                         │
│       "content": {...},  // tips, longevity_impact, etc.        │
│     },                                                          │
│     ...                                                         │
│   ]                                                             │
└─────────────────────────────────────────────────────────────────┘
```

## Survey Hierarchy Rollup Strategy

### 3-Level Survey Hierarchy
```
Section (e.g., "Healthful Nutrition")
  └─> Category (e.g., "Dietary Patterns & Structure")
       └─> Group (e.g., "general_diet")
            └─> Questions (e.g., 2.01, 2.02, 2.03)
```

### Scoring Aggregation

#### Level 1: Question Scores
```sql
-- Individual question scores from response matching
SELECT
    sqb.id as question_id,
    sqb.question_number,
    psr.response_value as patient_response,
    sqrc.score as question_score  -- From wellpath_score_question_content
FROM patient_survey_responses psr
JOIN survey_questions_base sqb ON psr.question_id = sqb.id
JOIN wellpath_score_question_content sqrc ON sqrc.question_number = sqb.question_number
WHERE psr.user_id = $1;
```

#### Level 2: Group Scores (Aggregate questions)
```sql
-- Average score for all questions in a group
SELECT
    sqb.group_id,
    AVG(question_score) as group_score,
    COUNT(*) as question_count
FROM question_scores
JOIN survey_questions_base sqb ON question_scores.question_id = sqb.id
GROUP BY sqb.group_id;
```

#### Level 3: Category Scores (Aggregate groups)
```sql
-- Average score for all groups in a category
SELECT
    sg.category_id,
    AVG(group_score) as category_score,
    COUNT(*) as group_count
FROM group_scores gs
JOIN survey_groups sg ON gs.group_id = sg.group_id
GROUP BY sg.category_id;
```

#### Level 4: Section Scores (Aggregate categories)
```sql
-- Average score for all categories in a section
SELECT
    sc.section_id,
    AVG(category_score) as section_score,
    COUNT(*) as category_count
FROM category_scores cs
JOIN survey_categories sc ON cs.category_id = sc.category_id
GROUP BY sc.section_id;
```

#### Level 5: Pillar Scores (Map sections to pillars)
```
Survey Section → WellPath Pillar Mapping:
- healthful_nutrition → pillar_nutrition
- movement_exercise → pillar_movement
- restorative_sleep → pillar_sleep
- cognitive_health → pillar_cognitive
- stress_management → pillar_stress
- connection_purpose → pillar_connection
- core_care → pillar_core_care
- introduction → [NOT SCORED]
```

## Pillar Component Breakdown

Each pillar has 4 components with different weightings:

```
Pillar Score = (Biomarkers * 0.72) + (Survey * 0.18) + (Biometrics * varies) + (Education * 0.10)
```

### Component Sections in UI
```
Overall WellPath Score (L0)
├─> Core Care Pillar (L1)
│   ├─> Biomarkers Component (L2)
│   │   └─> Individual biomarkers (L4)
│   ├─> Biometrics Component (L2)
│   │   └─> Individual biometrics (L4)
│   ├─> Behaviors Component (L2)
│   │   └─> Survey subsections (L3)
│   │       └─> Individual questions (L4)
│   └─> Education Component (L2)
│       └─> Completed modules (L4)
├─> Nutrition Pillar (L1)
│   └─> [Same 4 components]
└─> [Other pillars...]
```

## Implementation Steps

### 1. Create Scoring Calculation Function

Location: `supabase/functions/calculate-wellpath-score/index.ts`

**Key Responsibilities:**
- Fetch all patient data (biomarkers, biometrics, survey responses)
- Calculate scores at each level
- Apply weighting formulas
- Store in `patient_scoring_features`
- Populate `patient_wellpath_score_display` with UI data

### 2. Create Survey Rollup Views

Create materialized views or functions for efficient rollup queries:

```sql
-- Get patient's survey scores at all hierarchy levels
CREATE OR REPLACE FUNCTION get_patient_survey_scores(p_user_id UUID)
RETURNS TABLE (
    section_id TEXT,
    section_score NUMERIC,
    category_id TEXT,
    category_score NUMERIC,
    group_id TEXT,
    group_score NUMERIC,
    question_number TEXT,
    question_score NUMERIC
) AS $$
BEGIN
    -- Implementation
END;
$$ LANGUAGE plpgsql;
```

### 3. Map Survey Sections to WellPath Pillars

Create mapping table or function:

```sql
CREATE TABLE survey_section_to_pillar_mapping (
    section_id TEXT PRIMARY KEY REFERENCES survey_sections(section_id),
    pillar_key TEXT NOT NULL,
    is_scored BOOLEAN DEFAULT true
);

INSERT INTO survey_section_to_pillar_mapping VALUES
    ('healthful_nutrition', 'pillar_nutrition', true),
    ('movement_exercise', 'pillar_movement', true),
    ('restorative_sleep', 'pillar_sleep', true),
    ('cognitive_health', 'pillar_cognitive', true),
    ('stress_management', 'pillar_stress', true),
    ('connection_purpose', 'pillar_connection', true),
    ('core_care', 'pillar_core_care', true),
    ('introduction', NULL, false);
```

### 4. UI Display Population

For each patient:
1. Calculate section scores from survey hierarchy
2. Create `patient_wellpath_score_display` rows for each section
3. Populate `item_scores` JSONB array with:
   - Individual question scores
   - Patient's actual response
   - Content from `wellpath_score_question_content` (tips, longevity impact)
   - Alternative response options and their scores

### 5. Batch Processing

Script: `scripts/dev_only/batch_calculate_scores.py`

```python
# For each patient:
# 1. Call Edge Function to calculate scores
# 2. Verify scores written to database
# 3. Generate report of any errors
```

## Query Examples

### Get Complete Pillar Breakdown for Patient
```sql
SELECT
    wsds.section_key,
    wsds.display_name,
    pwsd.section_score,
    pwsd.item_scores
FROM patient_wellpath_score_display pwsd
JOIN wellpath_score_display_sections wsds ON pwsd.section_key = wsds.section_key
WHERE pwsd.user_id = $1
    AND wsds.section_type = 'pillar'
ORDER BY wsds.display_order;
```

### Get Survey Component Breakdown for Nutrition Pillar
```sql
SELECT
    wsds.section_key,
    wsds.display_name as subsection_name,
    pwsd.section_score as subsection_score,
    jsonb_array_length(pwsd.item_scores) as question_count
FROM patient_wellpath_score_display pwsd
JOIN wellpath_score_display_sections wsds ON pwsd.section_key = wsds.section_key
WHERE pwsd.user_id = $1
    AND wsds.parent_section_key = 'nutrition_behaviors'
ORDER BY wsds.display_order;
```

## Next Steps

1. ✅ Survey hierarchy organized (sections → categories → groups)
2. ✅ Questions mapped to groups
3. ⏳ Create survey-to-pillar mapping table
4. ⏳ Implement scoring calculation function
5. ⏳ Create rollup aggregation queries
6. ⏳ Populate UI display tables
7. ⏳ Test with 50 patient dataset
8. ⏳ Build frontend screens

---

**Status**: Ready to implement scoring calculation and rollup logic
**Last Updated**: 2025-10-17
