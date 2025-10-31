# WellPath Scoring History & Drill-Down System

## Complete Architecture Overview

The WellPath scoring system provides a complete hierarchy for navigation and scoring:

**Navigation Flow**: WellPath Score → Pillars → Components (Markers/Behaviors/Education) → Individual Items

## Table of Contents
1. [Core Scoring Tables](#core-scoring-tables)
2. [History Tracking System](#history-tracking-system)
3. [Drill-Down Views for Mobile](#drill-down-views-for-mobile)
4. [Automatic Recalculation](#automatic-recalculation-system)
5. [Swift Integration Guide](#swift-integration-guide)
6. [Example Queries](#example-queries)

---

## Core Scoring Tables

### `patient_wellpath_scores_history`
Stores **aggregated** pillar scores and overall WellPath scores with **full history**.

**Columns**:
- `score_id` (PK)
- `patient_id`
- `overall_score` - Total weighted score
- `overall_percentage` - Score as percentage (0-100)
- `pillar_scores` - JSONB with breakdown by pillar
- `total_items_scored` - Count of all scored items
- `biomarker_count`, `biometric_count`, `survey_count`, `function_count`
- `calculated_at` - Timestamp of calculation

**Use Cases**:
- Track overall WellPath score over time
- Compare pillar performance across dates
- Display score history charts

### `patient_wellpath_scores_current` (VIEW)
Convenience view showing only the **current** (most recent) score for each patient.

```sql
SELECT * FROM patient_wellpath_scores_current WHERE patient_id = 'uuid';
```

### `patient_item_scores_history`
Stores **detailed** item-level scores with **full history**.

**Columns**:
- `id` (PK)
- `patient_id`
- `pillar_name` - Name of pillar (e.g., "Healthful Nutrition", "Core Care")
- `component_type` - 'markers', 'behaviors', or 'education'
- `item_type` - 'biomarker', 'biometric', 'survey_question', 'survey_function', 'education'
- `item_name` - Generic item identifier
- `biomarker_name`, `biometric_name`, `question_number`, `function_name`, `education_module_id` - Specific identifiers
- `item_weight_in_pillar` - Weight of this item within its pillar
- `patient_value` - Patient's actual value (if applicable)
- `patient_score_contribution` - Actual points earned
- `max_score_contribution` - Maximum possible points
- `calculated_at` - Timestamp

**Use Cases**:
- Track individual biomarker/biometric scores over time
- See which items contributed to a pillar score
- Analyze trends in specific measurements
- Component drill-down navigation

### `patient_pillar_scores_history`
Stores pillar-level scores with full history.

### `patient_component_scores_history`
Stores component-level scores (markers, behaviors, education) with full history.

---

## History Tracking System

### How It Works

1. **Initial Calculation**: Edge function `calculate-wellpath-score` runs
2. **Item Scores Stored**: Each scored item creates a row in `patient_item_scores_history`
3. **Component Scores Stored**: Component aggregates saved to `patient_component_scores_history`
4. **Pillar Scores Stored**: Pillar aggregates saved to `patient_pillar_scores_history`
5. **Overall Scores Stored**: Overall and pillar scores saved to `patient_wellpath_scores_history`
6. **History Preserved**: Old scores are NEVER deleted, new calculations add new rows

### Data Retention
- **All historical scores retained indefinitely**
- No automatic cleanup
- Use `calculated_at` to filter by date range
- Views provide "current" snapshots (most recent calculation)

---

## Drill-Down Views for Mobile

These views power the component drill-down navigation in the Swift app.

### 1. `patient_pillar_scores_current`

**Purpose**: Current pillar scores (latest calculation only)

**Key Columns**:
- `patient_id`
- `pillar_name` - "Healthful Nutrition", "Core Care", etc.
- `pillar_score` - Total score for pillar
- `pillar_max_score` - Maximum possible score
- `pillar_percentage` - Score as percentage (0-100)
- `item_count` - Total items in pillar
- `calculated_at`

**Swift Usage**:
```swift
// Get pillar cards for WellPath Score screen
SELECT pillar_name, pillar_percentage, pillar_score, pillar_max_score
FROM patient_pillar_scores_current
WHERE patient_id = 'uuid'
ORDER BY pillar_name;
```

### 2. `patient_component_scores_current`

**Purpose**: Current component scores for each pillar (latest calculation only)

**Key Columns**:
- `patient_id`
- `pillar_name`
- `component_type` - 'markers', 'behaviors', 'education'
- `component_score` - Total score for component
- `component_max_score` - Maximum possible score
- `component_percentage` - Score as percentage (0-100)
- `item_count` - Number of items in component
- `calculated_at`

**Swift Usage**:
```swift
// Get component cards for a pillar drill-down
SELECT component_type, component_percentage, component_score, item_count
FROM patient_component_scores_current
WHERE patient_id = 'uuid' AND pillar_name = 'Healthful Nutrition'
ORDER BY component_type;
```

### 3. `patient_item_scores_current`

**Purpose**: Current item scores (latest calculation only) - basic version

**Key Columns**:
- `patient_id`, `pillar_name`, `component_type`, `item_type`
- `item_name`, `biomarker_name`, `biometric_name`, `question_number`, `function_name`
- `item_weight_in_pillar`
- `patient_value`, `patient_score_contribution`, `max_score_contribution`
- `calculated_at`

### 4. `patient_item_scores_current_with_component_weights` ⭐

**Purpose**: Individual item scores with component-level weights for drill-down

**Key Columns**:
- All columns from `patient_item_scores_current`
- `component_weight_in_pillar` - Component's weight in pillar (e.g., 0.72 = 72%)
- `item_weight_in_component` - Item's weight within its component (normalized to sum to 1.0)
- `component_percentage` - Patient's score for this item (0-100)

**Calculation**:
```
item_weight_in_component = item_weight_in_pillar / component_weight_in_pillar

Example:
- HbA1c weight in pillar: 0.0223
- Markers weight in pillar: 0.72
- HbA1c weight in markers: 0.0223 / 0.72 = 0.0310 (3.10%)
```

**Swift Usage**:
```swift
// Get items for a component with normalized weights
SELECT
    item_type,
    COALESCE(biomarker_name, biometric_name, item_name) as item_name,
    component_percentage,
    item_weight_in_component,
    component_weight_in_pillar
FROM patient_item_scores_current_with_component_weights
WHERE patient_id = 'uuid'
  AND pillar_name = 'Healthful Nutrition'
  AND component_type = 'markers'
ORDER BY item_weight_in_component DESC;
```

### 5. `patient_item_cards_with_navigation` ⭐ NEW

**Purpose**: Item cards with user-friendly display names and navigation metadata

**Key Columns**:
- All columns from `patient_item_scores_current_with_component_weights`
- `card_display_name` - User-friendly name for the card
- `card_subtitle` - Context label (section name for surveys)
- `navigation_type` - Where to navigate: 'biomarker_detail', 'biometric_detail', 'display_screen', 'education_content'
- `navigation_id` - Identifier for navigation (biomarker name, screen_id, module_id, etc.)
- `survey_group_name` - Group display name for surveys
- `survey_section_name` - Section display name for surveys

**Display Name Logic**:
- **Biomarkers/Biometrics**: Uses existing name (e.g., "HbA1c", "BMI", "Bodyfat")
- **Survey Questions**: Uses `survey_groups.display_name` (e.g., "Fish Consumption" instead of raw question text)
- **Survey Functions**: Uses `wellpath_scoring_survey_functions.display_name` (e.g., "Cognitive Activities Engagement" instead of "cognitive_activities_score")
- **Education**: Uses `education_base.title`

**Swift Usage**:
```swift
// Data Model
struct ItemCard: Codable {
    let cardDisplayName: String
    let cardSubtitle: String?
    let componentPercentage: Double
    let itemWeightInComponent: Double
    let navigationType: String
    let navigationId: String?
}

// Fetch item cards
let cards: [ItemCard] = try await supabase
    .from("patient_item_cards_with_navigation")
    .select("""
        card_display_name,
        card_subtitle,
        component_percentage,
        item_weight_in_component,
        navigation_type,
        navigation_id
    """)
    .eq("patient_id", value: userId)
    .eq("pillar_name", value: "Healthful Nutrition")
    .eq("component_type", value: "markers")
    .order("item_weight_in_component", ascending: false)
    .execute()
    .value

// Navigation routing
switch card.navigationType {
case "biomarker_detail":
    BiomarkerDetailView(name: card.navigationId!)
case "biometric_detail":
    BiometricDetailView(name: card.navigationId!)
case "display_screen":
    DisplayScreenView(screenId: card.navigationId!)
case "education_content":
    EducationContentView(moduleId: card.navigationId!)
}
```

**Example Results**:
```
card_display_name          | component_percentage | navigation_type  | navigation_id
---------------------------|----------------------|------------------|---------------
HbA1c                      | 100                  | biomarker_detail | HbA1c
Fish Consumption           | 100                  | display_screen   | 2.15
Cognitive Activities       | 100                  | display_screen   | cognitive_activities_score
```

### 6. History Views (with Full History)

- `patient_item_scores_with_component_weights` - Same as current version but includes all history
- `patient_pillar_scores_history` - All pillar scores over time
- `patient_component_scores_history` - All component scores over time
- `patient_wellpath_scores_history` - All overall scores over time

---

## Automatic Recalculation System

### Queue Table: `wellpath_score_recalculation_queue`

Tracks which patients need score recalculation.

**Columns**:
- `patient_id`
- `triggered_by` - What caused the recalculation
- `status` - 'pending', 'processing', 'completed', 'failed'
- `triggered_at`, `processed_at`

### Triggers

Automatic triggers on data changes:
- `patient_biomarker_readings` (INSERT, UPDATE, DELETE)
- `patient_biometric_readings` (INSERT, UPDATE, DELETE)
- `patient_survey_responses` (INSERT, UPDATE, DELETE)

**Behavior**:
1. Trigger fires on data change
2. Patient queued for recalculation (if not already queued)
3. Duplicate requests within 5 minutes prevented
4. Process queue manually or via cron job

### Edge Function: `calculate-wellpath-score`

**Endpoint**: `https://csotzmardnvrpdhlogjm.supabase.co/functions/v1/calculate-wellpath-score`

**Request**:
```json
{
  "patient_id": "uuid"
}
```

**What It Does**:
1. Retrieves patient demographics (age, gender, weight)
2. Scores biomarkers (with age/gender ranges)
3. Scores biometrics (with age/gender ranges)
4. Scores survey questions
5. Scores survey functions
6. Scores education completion
7. Inserts detailed scores into `patient_item_scores_history`
8. Inserts component scores into `patient_component_scores_history`
9. Inserts pillar scores into `patient_pillar_scores_history`
10. Inserts overall score into `patient_wellpath_scores_history`

**Response**:
```json
{
  "success": true,
  "patient_id": "uuid",
  "items_scored": 303,
  "overall_score": 85.5,
  "pillars": [
    {
      "pillar_name": "Core Care",
      "score": 1.8,
      "max": 1.8,
      "percentage": "100.00",
      "item_count": 144
    }
  ]
}
```

---

## Swift Integration Guide

### Complete Navigation Flow

```
WellPath Score Screen
    ↓ (tap pillar card)
Pillar Detail Screen (e.g., "Healthful Nutrition")
    ↓ (tap component: "Markers", "Behaviors", or "Education")
Component Items Screen (e.g., "Healthful Nutrition - Markers")
    ↓ (tap item card)
Detail Screen (based on navigation_type)
    - BiomarkerDetailView (for biomarkers)
    - BiometricDetailView (for biometrics)
    - DisplayScreenView (for surveys)
    - EducationContentView (for education)
```

### 1. WellPath Score Screen

**Query**: Get all pillars with their scores
```swift
struct PillarCard: Codable {
    let pillarName: String
    let pillarPercentage: Double
    let pillarScore: Double
    let pillarMaxScore: Double
    let itemCount: Int
}

let pillars: [PillarCard] = try await supabase
    .from("patient_pillar_scores_current")
    .select("pillar_name, pillar_percentage, pillar_score, pillar_max_score, item_count")
    .eq("patient_id", value: userId)
    .order("pillar_name")
    .execute()
    .value
```

### 2. Pillar Detail Screen

**Query**: Get components for a pillar
```swift
struct ComponentCard: Codable {
    let componentType: String
    let componentPercentage: Double
    let componentScore: Double
    let componentMaxScore: Double
    let itemCount: Int
}

let components: [ComponentCard] = try await supabase
    .from("patient_component_scores_current")
    .select("component_type, component_percentage, component_score, component_max_score, item_count")
    .eq("patient_id", value: userId)
    .eq("pillar_name", value: pillarName)
    .order("component_type")
    .execute()
    .value
```

### 3. Component Items Screen

**Query**: Get item cards with navigation
```swift
struct ItemCard: Codable {
    let cardDisplayName: String
    let cardSubtitle: String?
    let componentPercentage: Double
    let itemWeightInComponent: Double
    let navigationType: String
    let navigationId: String?
}

let items: [ItemCard] = try await supabase
    .from("patient_item_cards_with_navigation")
    .select("""
        card_display_name,
        card_subtitle,
        component_percentage,
        item_weight_in_component,
        navigation_type,
        navigation_id
    """)
    .eq("patient_id", value: userId)
    .eq("pillar_name", value: pillarName)
    .eq("component_type", value: componentType)
    .order("item_weight_in_component", ascending: false)
    .execute()
    .value
```

### 4. Navigation Routing

```swift
@ViewBuilder
func destinationView(for card: ItemCard) -> some View {
    switch card.navigationType {
    case "biomarker_detail":
        BiomarkerDetailView(name: card.navigationId!)
    case "biometric_detail":
        BiometricDetailView(name: card.navigationId!)
    case "display_screen":
        DisplayScreenView(screenId: card.navigationId!)
    case "education_content":
        EducationContentView(moduleId: card.navigationId!)
    default:
        Text("Unknown type: \(card.navigationType)")
    }
}
```

---

## Example Queries

### Get Latest Overall Score
```sql
SELECT overall_percentage, pillar_scores, calculated_at
FROM patient_wellpath_scores_current
WHERE patient_id = 'uuid';
```

### Get Score History (Last 30 Days)
```sql
SELECT calculated_at, overall_percentage, total_items_scored
FROM patient_wellpath_scores_history
WHERE patient_id = 'uuid'
  AND calculated_at >= NOW() - INTERVAL '30 days'
ORDER BY calculated_at DESC;
```

### Get All Pillars with Current Scores
```sql
SELECT
    pillar_name,
    pillar_percentage,
    pillar_score,
    pillar_max_score,
    item_count
FROM patient_pillar_scores_current
WHERE patient_id = 'uuid'
ORDER BY pillar_name;
```

### Get Components for a Pillar
```sql
SELECT
    component_type,
    component_percentage,
    component_score,
    component_max_score,
    item_count
FROM patient_component_scores_current
WHERE patient_id = 'uuid'
  AND pillar_name = 'Healthful Nutrition'
ORDER BY component_type;
```

### Get Item Cards for Healthful Nutrition Markers
```sql
SELECT
    card_display_name,
    card_subtitle,
    component_percentage,
    item_weight_in_component,
    navigation_type,
    navigation_id
FROM patient_item_cards_with_navigation
WHERE patient_id = 'uuid'
  AND pillar_name = 'Healthful Nutrition'
  AND component_type = 'markers'
ORDER BY item_weight_in_component DESC;
```

### Get Survey Question Cards with Display Names
```sql
SELECT
    card_display_name,
    survey_group_name,
    card_subtitle,
    component_percentage,
    navigation_type,
    navigation_id
FROM patient_item_cards_with_navigation
WHERE patient_id = 'uuid'
  AND item_type = 'survey_question'
ORDER BY pillar_name, item_weight_in_component DESC;
```

### Track Biomarker Score Over Time
```sql
SELECT
    calculated_at,
    patient_value,
    patient_score_contribution,
    max_score_contribution
FROM patient_item_scores_history
WHERE patient_id = 'uuid'
  AND biomarker_name = 'HbA1c'
ORDER BY calculated_at DESC;
```

### Verify Component Weights Sum to 1.0
```sql
SELECT
    pillar_name,
    component_type,
    COUNT(*) as item_count,
    ROUND(SUM(item_weight_in_component)::numeric, 4) as sum_weights
FROM patient_item_scores_current_with_component_weights
WHERE patient_id = 'uuid'
GROUP BY pillar_name, component_type
ORDER BY pillar_name, component_type;

-- All sum_weights should be 1.0000
```

---

## Key Tables & Views Reference

### History Tables (Full History)
- `patient_wellpath_scores_history` - Overall and pillar scores with history
- `patient_pillar_scores_history` - Pillar scores with history
- `patient_component_scores_history` - Component scores with history
- `patient_item_scores_history` - Detailed item scores with history

### Current Views (Latest Calculation Only)
- `patient_wellpath_scores_current` - Latest overall scores
- `patient_pillar_scores_current` - Latest pillar scores
- `patient_component_scores_current` - Latest component scores
- `patient_item_scores_current` - Latest item scores (basic)

### Drill-Down Views
- `patient_item_scores_current_with_component_weights` - Item scores with component-level weights
- `patient_item_scores_with_component_weights` - Same but with full history
- `patient_item_cards_with_navigation` - Item cards with display names and navigation

### Reference Tables
- `survey_groups` - Provides `display_name` for survey questions
- `wellpath_scoring_survey_functions` - Provides `display_name` for survey functions
- `education_base` - Provides `title` for education modules
- `survey_sections` - Provides section context for surveys

### Queue & Automation
- `wellpath_score_recalculation_queue` - Tracks pending recalculations
- Triggers on: `patient_biomarker_readings`, `patient_biometric_readings`, `patient_survey_responses`

---

## Implementation Notes

### Performance
- Edge function takes ~5-6 seconds to calculate score
- Triggers queue requests but don't block transactions
- Use batch processing for bulk operations
- All views use indexes for efficient queries

### History Retention
- All historical scores retained indefinitely
- No automatic cleanup
- Filter by `calculated_at` for date ranges
- Consider retention policy if needed (e.g., keep 2 years)

### RLS & Permissions
- All views use `security_invoker = on` (inherit RLS from base tables)
- Authenticated users can only see their own data
- Service role has full access for Edge Functions

### Display Names
- Biomarkers/Biometrics: Use existing clean names
- Survey Questions: Use `survey_groups.display_name`
- Survey Functions: Use `wellpath_scoring_survey_functions.display_name`
- Education: Use `education_base.title`

### Weight Normalization
- `item_weight_in_pillar`: Item's weight as fraction of entire pillar
- `component_weight_in_pillar`: Component's weight in pillar (e.g., 0.72 = markers are 72% of Healthful Nutrition)
- `item_weight_in_component`: Item's weight within its component (normalized so items in each component sum to 1.0)

---

## Migrations Applied

1. `20251026_create_wellpath_scores_history.sql` - Created scores history table
2. `20251026_create_score_recalculation_queue.sql` - Created queue table and triggers
3. `20251027_create_item_scores_history.sql` - Created item scores history table
4. `20251028_rename_latest_to_current_views.sql` - Renamed views from _latest to _current
5. `20251028_create_item_component_weights_view.sql` - Created component weight views
6. `20251028_create_item_cards_navigation_view.sql` - Created item cards with navigation
7. `20251028_grant_item_cards_navigation_permissions.sql` - Granted permissions

---

## Current Status

✅ Complete history tracking (overall, pillar, component, item scores)
✅ Automatic queueing triggers configured and active
✅ Edge function preserves history across all tables
✅ Component drill-down views for mobile navigation
✅ Item cards with user-friendly display names
✅ Navigation metadata for all item types
✅ RLS policies and permissions configured

⚠️ Queue processing is manual - implement cron job as needed

---

## Related Documentation

- **Item Cards Navigation**: See `ITEM_CARDS_NAVIGATION_GUIDE.md` for detailed Swift implementation
- **Component Drill-Down**: See `COMPONENT_DRILL_DOWN_QUERIES.md` for weight calculations
- **Scoring Logic**: See `DYNAMIC_SCORING_SYSTEM_COMPLETE.md`
