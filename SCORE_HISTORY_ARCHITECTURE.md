# WellPath Score History Tracking Architecture

## Overview
Complete history tracking system for WellPath scores at all levels, enabling charts and trend analysis in the mobile app.

## Architecture Pattern
All score tracking follows a consistent pattern:
- **History Table**: Stores all calculations with `calculated_at` timestamp
- **Current View**: Shows only the most recent calculation per patient

---

## 1. Overall WellPath Scores

### Table: `patient_wellpath_scores_history`
**Purpose**: Historical record of overall WellPath scores

**Key Columns**:
- `patient_id` - Patient identifier
- `overall_score` - Total score across all pillars
- `overall_max_score` - Maximum possible score
- `overall_percentage` - Score as percentage
- `pillar_scores` - JSONB array of pillar breakdowns
- `total_items_scored` - Count of all scored items
- `biomarker_count`, `biometric_count`, `survey_question_count`, `survey_function_count`
- `calculation_version` - Edge function version
- **`calculated_at`** - Timestamp of calculation (KEY for history tracking)
- `created_at` - Row creation timestamp

### View: `patient_wellpath_scores_current`
**Query**: Latest score per patient
```sql
SELECT DISTINCT ON (patient_id) *
FROM patient_wellpath_scores_history
ORDER BY patient_id, calculated_at DESC
```

**Mobile Usage**: Not directly used (mobile uses `patient_wellpath_score_overall` view instead)

---

## 2. Pillar Scores

### Table: `patient_pillar_scores_history`
**Purpose**: Historical scores for each pillar (7 pillars per patient)

**Key Columns**:
- `patient_id` - Patient identifier
- `pillar_id` - Pillar UUID
- **`pillar_name`** - Pillar name (e.g., "Healthful Nutrition") - Used by Swift
- `pillar_score` - Total score for this pillar
- `pillar_max_score` - Maximum possible for this pillar
- `pillar_percentage` - Score as percentage
- `item_count`, `biomarker_count`, `biometric_count`, `survey_question_count`, `survey_function_count`
- `calculation_version`
- **`calculated_at`** - Timestamp of calculation (KEY for history tracking)
- `created_at` - Row creation timestamp

### View: `patient_pillar_scores_current`
**Query**: Latest scores for each patient-pillar combination
```sql
SELECT DISTINCT ON (patient_id, pillar_id) *
FROM patient_pillar_scores_history
ORDER BY patient_id, pillar_id, calculated_at DESC
```

**Mobile Usage**: Used by Swift to fetch pillar-level scores
```swift
.from("patient_pillar_scores_current")
.eq("patient_id", value: userId)
.eq("pillar_name", value: "Healthful Nutrition")
```

---

## 3. Component Scores (Markers, Behaviors, Education)

### Table: `patient_component_scores_history`
**Purpose**: Historical scores for each pillar-component combination (3 components × 7 pillars = 21 rows per patient)

**Key Columns**:
- `patient_id` - Patient identifier
- `pillar_id` - Pillar UUID
- **`pillar_name`** - Pillar name - Used by Swift
- `component_type` - 'markers', 'behaviors', or 'education'
- `component_score` - Total score for this component
- `component_max_score` - Maximum possible for this component
- `component_percentage` - Score as percentage
- `item_count`, `biomarker_count`, `biometric_count`, `survey_question_count`, `survey_function_count`, `education_count`
- `calculation_version`
- **`calculated_at`** - Timestamp of calculation (KEY for history tracking)
- `created_at` - Row creation timestamp

### View: `patient_component_scores_current`
**Query**: Latest scores for each patient-pillar-component combination
```sql
SELECT DISTINCT ON (patient_id, pillar_id, component_type) *
FROM patient_component_scores_history
ORDER BY patient_id, pillar_id, component_type, calculated_at DESC
```

**Mobile Usage**: Used by Swift to show component breakdowns
```swift
.from("patient_component_scores_current")
.eq("patient_id", value: userId)
.eq("pillar_name", value: "Healthful Nutrition")
.eq("component_type", value: "markers")
```

---

## 4. Item-Level Scores (Individual Biomarkers, Biometrics, Behaviors, Education)

### Table: `patient_item_scores_history`
**Purpose**: Historical scores for individual items (biomarkers, biometrics, survey questions, functions, education)

**Important**: Items that apply to multiple pillars (e.g., BMI applies to 6 pillars) have **separate rows for each pillar**

**Key Columns**:
- `patient_id` - Patient identifier
- `batch_id` - UUID linking to calculation run
- **`pillar_name`** - Pillar name - Used by Swift
- `component_type` - 'markers', 'behaviors', or 'education'
- `item_type` - 'biomarker', 'biometric', 'survey_question', 'survey_function', 'education'
- **Item Identifiers** (exactly one non-null):
  - `biomarker_name` - e.g., "Albumin"
  - `biometric_name` - e.g., "BMI"
  - `question_number` - e.g., 9.01
  - `function_name` - e.g., "protein_intake_score"
  - `education_module_id`
- `item_name` - Display name
- `item_display_name` - Friendly display name
- **Patient Data**:
  - `patient_value` - Raw value (text)
  - `patient_value_numeric` - Numeric value
  - `patient_gender`, `patient_age`
- **Scores**:
  - `raw_score` - Original score (0-10 or 0-1 scale)
  - `normalized_score` - Normalized to 0-1
  - `score_band` - e.g., "Optimal", "Elevated"
- **Weights and Contributions**:
  - `raw_weight` - Original weight
  - `item_weight_in_pillar` - Normalized weight for this pillar
  - `patient_score_contribution` - Actual contribution to pillar score
  - `max_score_contribution` - Max possible contribution
  - `item_percentage` - (patient_score / max_score) × 100
- **Source Tracking**:
  - `data_collected_at` - When data was collected
  - `data_source` - Source system
- **`calculated_at`** - Timestamp of calculation (KEY for history tracking)
- `created_at` - Row creation timestamp

### View: `patient_item_scores_current`
**Query**: Latest scores for each patient-pillar-component-item combination
```sql
SELECT DISTINCT ON (
    patient_id,
    pillar_name,
    component_type,
    item_type,
    COALESCE(biomarker_name, biometric_name, question_number::text, function_name, education_module_id)
) *
FROM patient_item_scores_history
ORDER BY ..., calculated_at DESC
```

**Mobile Usage**: Used by Swift to show individual item scores and charts
```swift
// Get all biomarkers for a pillar
.from("patient_item_scores_current")
.eq("patient_id", value: userId)
.eq("pillar_name", value: "Healthful Nutrition")
.eq("item_type", value: "biomarker")

// Get history for charting
.from("patient_item_scores_history")
.eq("patient_id", value: userId)
.eq("biomarker_name", value: "Albumin")
.order("calculated_at", ascending: false)
```

---

## 5. Score Items (Raw Calculation Data)

### Table: `patient_wellpath_score_items`
**Purpose**: Raw scored items from each calculation run (not primarily for mobile consumption)

**Key Columns**:
- `patient_id` - Patient identifier
- **`batch_id`** - UUID identifying calculation run (prevents double-counting)
- `pillar_name` - Pillar this item contributes to
- `item_type` - Type of item
- Item identifiers (one non-null)
- Scores and weights
- **`scored_at`** - Timestamp when scored
- `created_at`, `updated_at`

**Purpose of batch_id**:
When `calculatePillarSummary()` queries this table, it filters by `batch_id` to only sum items from the current calculation run. Without this filter, it would sum ALL historical items and produce doubled scores (bug that was fixed).

---

## Key Design Decisions

### 1. Why pillar_name instead of pillar_id?
Swift mobile code uses pillar names (e.g., "Healthful Nutrition") throughout the UI. Using pillar_name in history tables eliminates the need for join lookups and makes queries simpler.

### 2. Why separate rows for multi-pillar items?
Items like BMI that contribute to multiple pillars need separate tracking per pillar because:
- The weight differs per pillar
- The contribution to each pillar is independent
- Charts need to show the item's impact on each pillar separately

### 3. Why calculated_at instead of data_collected_at?
- `calculated_at` - When the score was calculated (history tracking)
- `data_collected_at` - When the underlying data was measured/collected
- We track both because scores can be recalculated from the same data

### 4. Why _history and _current naming?
Consistent naming pattern:
- `*_history` tables store ALL calculations
- `*_current` views show ONLY the latest calculation
- Makes it immediately clear which to query for current state vs. trends

---

## Query Patterns for Mobile

### Current Overall Score
```swift
supabase.from("patient_wellpath_score_overall")
    .eq("patient_id", value: userId)
```

### Current Pillar Scores
```swift
supabase.from("patient_pillar_scores_current")
    .eq("patient_id", value: userId)
    .order("pillar_name")
```

### Current Component Scores for a Pillar
```swift
supabase.from("patient_component_scores_current")
    .eq("patient_id", value: userId)
    .eq("pillar_name", value: "Healthful Nutrition")
```

### Current Items for a Pillar and Component
```swift
supabase.from("patient_item_scores_current")
    .eq("patient_id", value: userId)
    .eq("pillar_name", value: "Healthful Nutrition")
    .eq("component_type", value: "markers")
    .eq("item_type", value: "biomarker")
```

### Historical Trend for an Item
```swift
supabase.from("patient_item_scores_history")
    .eq("patient_id", value: userId)
    .eq("biomarker_name", value: "Albumin")
    .eq("pillar_name", value: "Healthful Nutrition")
    .order("calculated_at", ascending: false)
    .limit(30)  // Last 30 calculations for chart
```

---

## Migration Files Applied

1. `20251028_fix_scoring_double_count_add_batch_id.sql` - Added batch_id to prevent double counting
2. `20251028_create_patient_item_scores_history.sql` - Created item-level history table
3. `20251028_create_patient_item_scores_current_view.sql` - Created item-level current view
4. `20251028_add_pillar_name_to_component_scores_history.sql` - Added pillar_name for Swift
5. `20251028_add_pillar_name_to_pillar_scores_history.sql` - Added pillar_name for Swift
6. `20251028_rename_latest_to_current_views.sql` - Renamed for consistency
7. `20251028_rename_wellpath_scores_to_history.sql` - Renamed overall scores table

---

## Edge Function Integration

The `calculate-wellpath-score` edge function:
1. Generates unique `batch_id` per calculation run
2. Inserts scored items with `batch_id` and `scored_at`
3. Calculates pillar summaries filtering by `batch_id` (prevents double counting)
4. Inserts into `patient_wellpath_scores_history` with `calculated_at`
5. Populates `patient_item_scores_history` for charts (in progress - debugging needed)

**Edge Function Location**: `/supabase/functions/calculate-wellpath-score/index.ts`
