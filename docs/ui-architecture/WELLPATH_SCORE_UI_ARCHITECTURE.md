# WellPath Score UI Architecture

## Analogy to Tracking System

| Tracking System | WellPath Score System |
|----------------|----------------------|
| **Results** (data entry fields) | **Survey Questions/Biomarker Readings** (raw input) |
| **Functions** (instance calculations/event types) | **Score Calculation** (Edge Function computes scores) |
| **Aggregation Metrics** (rollups) | **Score Aggregations** (pillar totals, category rollups) |
| **Display Metrics/Screens** (UI config) | **Score Display Config** (UI sections, content, tips) |

---

## Tables Design

### 1. **wellpath_score_display_sections** (like display_screens)
Defines the UI hierarchy and organization

```sql
CREATE TABLE wellpath_score_display_sections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Hierarchy
    section_key TEXT UNIQUE NOT NULL,  -- e.g., 'behaviors', 'behaviors_substances', 'behaviors_substances_alcohol'
    parent_section_key TEXT REFERENCES wellpath_score_display_sections(section_key),
    display_order INTEGER NOT NULL,
    depth_level INTEGER NOT NULL,  -- 0=top level, 1=sub-section, 2=sub-sub-section

    -- Display info
    display_name TEXT NOT NULL,  -- e.g., 'Behaviors', 'Substances', 'Alcohol'
    icon TEXT,  -- Icon name for UI
    description TEXT,

    -- What to show
    section_type TEXT NOT NULL,  -- 'pillar', 'category', 'function_group', 'individual_item'

    -- Aggregation logic (how to calculate this section's score)
    aggregation_type TEXT,  -- 'sum', 'average', 'function_rollup', 'pillar_component'
    aggregation_source JSONB,  -- Which items/functions to aggregate
    /* Example:
    {
      "source_type": "functions",
      "function_names": ["substance_alcohol_score", "substance_tobacco_score", ...],
      "rollup_method": "weighted_average"
    }
    OR
    {
      "source_type": "pillar_component",
      "pillar_name": "Core Care",
      "component": "markers"
    }
    */

    -- Content
    quick_tips JSONB,  -- Array of tips to show
    longevity_impact TEXT,  -- Description of longevity impact
    learn_more_url TEXT,

    -- Metadata
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### 2. **wellpath_score_display_items** (like display_metrics)
Defines individual items within sections (questions, biomarkers, functions)

```sql
CREATE TABLE wellpath_score_display_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Parent section
    section_key TEXT NOT NULL REFERENCES wellpath_score_display_sections(section_key),
    display_order INTEGER NOT NULL,

    -- What item is this?
    item_type TEXT NOT NULL,  -- 'biomarker', 'biometric', 'survey_question', 'survey_function'
    item_id TEXT NOT NULL,  -- biomarker name, question number, or function name

    -- Display info
    display_name TEXT NOT NULL,
    subtitle TEXT,
    icon TEXT,

    -- Content for this specific item
    description TEXT,
    longevity_impact TEXT,
    quick_tips JSONB,
    learn_more_url TEXT,

    -- Link to detailed chart (for biomarkers/biometrics)
    has_chart BOOLEAN DEFAULT FALSE,
    chart_screen_key TEXT,  -- References display_screens if applicable

    -- Show alternative scores? (for survey questions)
    show_alternative_responses BOOLEAN DEFAULT FALSE,

    -- Metadata
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    UNIQUE(section_key, item_id)
);
```

### 3. **wellpath_score_question_content** (Content for survey questions)
Additional content for survey questions (alternative responses, tips per answer)

```sql
CREATE TABLE wellpath_score_question_content (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    question_number TEXT NOT NULL UNIQUE,

    -- General question content
    explanation TEXT,
    why_it_matters TEXT,
    longevity_impact TEXT,

    -- Response-specific content
    response_content JSONB,
    /* Example:
    {
      "Never": {
        "score": 1.0,
        "normalized_score": 10,
        "longevity_impact": "Avoiding alcohol completely can add 2-3 years to your lifespan",
        "tips": ["Keep up the great work!", "..."]
      },
      "1-2 drinks per week": {
        "score": 0.8,
        "normalized_score": 8,
        "longevity_impact": "Light drinking has minimal impact on longevity",
        "tips": ["Consider tracking your drinks", "..."]
      },
      "Heavy (15+ drinks per week)": {
        "score": 0.0,
        "normalized_score": 0,
        "longevity_impact": "Heavy drinking can reduce lifespan by 5-10 years",
        "tips": ["Consider speaking with a healthcare provider", "..."],
        "severity": "high"
      }
    }
    */

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### 4. **patient_wellpath_score_display** (Patient-specific calculated data)
Combines scoring + config for each patient - THIS IS WHAT THE APP QUERIES

```sql
CREATE TABLE patient_wellpath_score_display (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id),

    -- Overall score (denormalized for quick access)
    overall_score DECIMAL(5,4) NOT NULL,
    calculated_at TIMESTAMPTZ NOT NULL,

    -- Section scores (calculated based on wellpath_score_display_sections config)
    section_scores JSONB NOT NULL,
    /* Example:
    {
      "behaviors": {
        "score": 0.58,
        "max": 1.0,
        "percentage": 58.0,
        "items_count": 25,
        "subsections": ["behaviors_substances", "behaviors_movement", ...]
      },
      "behaviors_substances": {
        "score": 0.45,
        "max": 1.0,
        "percentage": 45.0,
        "items_count": 6,
        "subsections": ["behaviors_substances_alcohol", "behaviors_substances_tobacco", ...]
      },
      "behaviors_substances_alcohol": {
        "score": 0.6,
        "max": 1.0,
        "percentage": 60.0,
        "items_count": 4,
        "items": [...detailed items...]
      }
    }
    */

    -- Individual item scores with patient's actual data
    item_scores JSONB NOT NULL,
    /* Example:
    [
      {
        "section_key": "behaviors_substances_alcohol",
        "item_type": "survey_function",
        "item_id": "substance_alcohol_score",
        "display_name": "Alcohol",
        "patient_score": 0.6,
        "max_score": 1.0,
        "weight": 8,
        "weighted_score": 4.8,
        "patient_data": {
          "current_use": "1-2 drinks per week",
          "frequency": "Occasionally",
          "trend": "Stable"
        },
        "content": {
          "tips": [...from wellpath_score_display_items...],
          "longevity_impact": "...",
          "learn_more_url": "..."
        }
      },
      {
        "section_key": "biomarkers_cardiovascular",
        "item_type": "biomarker",
        "item_id": "LDL",
        "display_name": "LDL Cholesterol",
        "patient_score": 1.0,
        "max_score": 1.0,
        "weight": 7,
        "weighted_score": 7.0,
        "patient_data": {
          "value": 85,
          "unit": "mg/dL",
          "range": "Optimal",
          "recorded_at": "2024-09-15"
        },
        "has_chart": true,
        "chart_screen_key": "biomarker_ldl",
        "content": {...}
      }
    ]
    */

    -- Index for fast lookups
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_patient_score_display_user ON patient_wellpath_score_display(user_id, calculated_at DESC);
```

---

## Example Hierarchy Configuration

### Top Level: Pillars
```sql
INSERT INTO wellpath_score_display_sections VALUES
('pillar_core_care', NULL, 1, 0, 'Core Care', 'shield', 'Your foundation of health', 'pillar', 'pillar_component',
 '{"source_type": "pillar", "pillar_name": "Core Care"}', ...),

('pillar_nutrition', NULL, 2, 0, 'Healthful Nutrition', 'apple', 'What you eat', 'pillar', 'pillar_component',
 '{"source_type": "pillar", "pillar_name": "Healthful Nutrition"}', ...);
```

### Sub-sections: Categories within Pillars
```sql
INSERT INTO wellpath_score_display_sections VALUES
-- Core Care sub-sections
('core_biomarkers', 'pillar_core_care', 1, 1, 'Biomarkers', 'test-tube', 'Lab test results', 'category', 'sum',
 '{"source_type": "pillar_component", "pillar_name": "Core Care", "component": "markers"}', ...),

('core_screenings', 'pillar_core_care', 2, 1, 'Preventive Screenings', 'calendar-check', 'Recommended health screenings', 'category', 'function_rollup',
 '{"source_type": "functions", "function_names": ["screening_dental_score", "screening_colonoscopy_score", ...]}', ...);
```

### Alternative Organization: Behaviors (cross-pillar)
```sql
INSERT INTO wellpath_score_display_sections VALUES
('behaviors', NULL, 8, 0, 'Behaviors', 'activity', 'Your daily habits and choices', 'category', 'custom', NULL, ...),

('behaviors_substances', 'behaviors', 1, 1, 'Substance Use', 'wine-glass', 'Alcohol, tobacco, and other substances', 'function_group', 'function_rollup',
 '{"source_type": "functions", "function_names": ["substance_alcohol_score", "substance_tobacco_score", "substance_nicotine_score", "substance_recreational_drugs_score", "substance_otc_meds_score"]}', ...),

('behaviors_substances_alcohol', 'behaviors_substances', 1, 2, 'Alcohol', 'beer', 'Your alcohol consumption', 'individual_item', 'function',
 '{"source_type": "function", "function_name": "substance_alcohol_score"}',
 '["Limit to 1-2 drinks per day", "Have alcohol-free days each week", "Avoid binge drinking"]',
 'Heavy alcohol use can reduce lifespan by 5-10 years', ...),

('behaviors_substances_tobacco', 'behaviors_substances', 2, 2, 'Tobacco', 'smoking', 'Cigarettes, cigars, smokeless tobacco', 'individual_item', 'function',
 '{"source_type": "function", "function_name": "substance_tobacco_score"}', ...);
```

---

## App Query Examples

### 1. Get top-level sections for home screen
```sql
SELECT
    s.section_key,
    s.display_name,
    s.icon,
    ps.section_scores->s.section_key as section_data
FROM wellpath_score_display_sections s
LEFT JOIN patient_wellpath_score_display ps ON ps.user_id = 'xxx'
WHERE s.parent_section_key IS NULL
  AND s.is_active = TRUE
ORDER BY s.display_order;
```

### 2. Get subsections when user taps "Behaviors"
```sql
SELECT
    s.section_key,
    s.display_name,
    s.icon,
    s.description,
    ps.section_scores->s.section_key as section_data
FROM wellpath_score_display_sections s
LEFT JOIN patient_wellpath_score_display ps ON ps.user_id = 'xxx'
WHERE s.parent_section_key = 'behaviors'
  AND s.is_active = TRUE
ORDER BY s.display_order;
```

### 3. Get individual items when user taps "Alcohol"
```sql
SELECT
    di.item_id,
    di.display_name,
    di.description,
    di.quick_tips,
    di.longevity_impact,
    jsonb_array_elements(ps.item_scores) as item_data
FROM wellpath_score_display_items di
LEFT JOIN patient_wellpath_score_display ps ON ps.user_id = 'xxx'
WHERE di.section_key = 'behaviors_substances_alcohol'
  AND di.is_active = TRUE
  AND jsonb_array_elements(ps.item_scores)->>'item_id' = di.item_id
ORDER BY di.display_order;
```

### 4. Get question details with alternative responses
```sql
SELECT
    q.question_number,
    q.explanation,
    q.why_it_matters,
    q.response_content,
    r.response_text as patient_current_answer
FROM wellpath_score_question_content q
LEFT JOIN patient_survey_responses r
    ON r.question_number = q.question_number
    AND r.user_id = 'xxx'
WHERE q.question_number = '8.05';  -- Alcohol frequency question
```

---

## Edge Function Updates Needed

The Edge Function needs to:

1. **Calculate section scores** based on `wellpath_score_display_sections` aggregation config
2. **Build item_scores array** with patient's actual data + content
3. **Save to `patient_wellpath_score_display`** table

This happens AFTER the core scoring calculation.

---

## Benefits of This Approach

✅ **Flexible UI** - Can reorganize sections without changing scoring logic
✅ **Content Management** - Tips, longevity impact, etc. all in database
✅ **Cross-pillar views** - Can show "Behaviors" that pulls from multiple pillars
✅ **Patient-specific** - Shows their actual answers, scores, and relevant content
✅ **Fast queries** - Pre-calculated and stored, not computed on-the-fly
✅ **Consistent with tracking** - Same pattern as display_screens/display_metrics

Does this architecture match what you're envisioning?
