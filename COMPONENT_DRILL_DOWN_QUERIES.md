# Component Drill-Down Queries for Swift

## UI Flow: WellPath Score → Pillar → Component → Items

### Overview

When drilling down from a component to its items, you want to show each item as a **percentage of that component**, not the entire pillar.

For example:
- Healthful Nutrition has 3 components: Markers (72%), Behaviors (18%), Education (10%)
- When viewing the Markers component, each biomarker should show its % of the **72% markers allocation**, not the full pillar

## New Views

### `patient_item_scores_current_with_component_weights`
Shows item scores with component-level calculations (latest scores only)

### `patient_item_scores_with_component_weights`
Shows item scores with component-level calculations (full history for charts)

## Key Columns

| Column | Description | Example |
|--------|-------------|---------|
| `item_weight_in_pillar` | Item's weight as fraction of entire pillar | 0.0223 (2.23% of pillar) |
| `component_weight_in_pillar` | Component's weight in pillar | 0.72 (markers = 72% of Healthful Nutrition) |
| `item_weight_in_component` | Item's weight as fraction of component | 0.0310 (3.10% of markers) |
| `component_percentage` | Patient's score on item (% of item max) | 100 (patient scored 100% on this item) |

## Calculation

```
item_weight_in_component = item_weight_in_pillar / component_weight_in_pillar

Example:
- HbA1c weight in pillar: 0.0223
- Markers weight in pillar: 0.72
- HbA1c weight in markers: 0.0223 / 0.72 = 0.0310 (3.10%)
```

## Swift Usage Examples

### 1. Show Items in a Component (Drill-Down)

```swift
// User tapped on "Markers" in Healthful Nutrition
// Show all markers with their % of the markers component

struct ItemScore: Codable {
    let itemName: String
    let biomarkerName: String?
    let biometricName: String?
    let itemWeightInComponent: Double
    let componentPercentage: Double
    let patientValue: String?

    var displayName: String {
        biomarkerName ?? biometricName ?? itemName
    }

    var percentOfComponent: String {
        String(format: "%.1f%%", itemWeightInComponent * 100)
    }

    var patientScore: String {
        String(format: "%.0f%%", componentPercentage)
    }
}

let query = supabase
    .from("patient_item_scores_current_with_component_weights")
    .select("""
        item_name,
        biomarker_name,
        biometric_name,
        item_weight_in_component,
        component_percentage,
        patient_value
    """)
    .eq("patient_id", value: userId)
    .eq("pillar_name", value: "Healthful Nutrition")
    .eq("component_type", value: "markers")
    .order("item_weight_in_component", ascending: false)

let items: [ItemScore] = try await query.execute().value

// Display in list:
// HbA1c           3.1% of markers    Score: 100%
// Total Chol      2.8% of markers    Score: 100%
// ...
```

### 2. Show Component Summary with Item Count

```swift
struct ComponentSummary: Codable {
    let pillarName: String
    let componentType: String
    let itemCount: Int
    let avgScore: Double
    let componentWeight: Double

    var displayTitle: String {
        componentType.capitalized
    }

    var itemCountText: String {
        "\(itemCount) items"
    }

    var avgScoreText: String {
        String(format: "%.0f%%", avgScore)
    }
}

let query = supabase.rpc("get_component_summary", params: [
    "p_patient_id": userId,
    "p_pillar_name": "Healthful Nutrition"
])

// Or query directly:
let query = supabase
    .from("patient_item_scores_current_with_component_weights")
    .select("component_type, item_weight_in_component, component_percentage")
    .eq("patient_id", value: userId)
    .eq("pillar_name", value: "Healthful Nutrition")

// Aggregate in Swift:
let grouped = Dictionary(grouping: items) { $0.componentType }
let summaries = grouped.map { type, items in
    ComponentSummary(
        componentType: type,
        itemCount: items.count,
        avgScore: items.map { $0.componentPercentage }.average,
        componentWeight: items.first?.componentWeightInPillar ?? 0
    )
}
```

### 3. Item Detail with Context

```swift
struct ItemDetail: Codable {
    let itemName: String
    let pillarName: String
    let componentType: String

    // Context
    let componentWeightInPillar: Double
    let itemWeightInPillar: Double
    let itemWeightInComponent: Double

    // Patient data
    let patientValue: String?
    let componentPercentage: Double

    var componentWeightText: String {
        String(format: "%.0f%% of %@", componentWeightInPillar * 100, pillarName)
    }

    var itemContributionText: String {
        String(format: "%.1f%% of %@", itemWeightInComponent * 100, componentType)
    }
}

let query = supabase
    .from("patient_item_scores_current_with_component_weights")
    .select("*")
    .eq("patient_id", value: userId)
    .eq("biomarker_name", value: "HbA1c")
    .eq("pillar_name", value: "Healthful Nutrition")
    .single()

let item: ItemDetail = try await query.execute().value

// Display:
// HbA1c
// 3.1% of Markers (which is 72% of Healthful Nutrition)
// Your score: 100%
// Your value: 4.89
```

### 4. Historical Chart Data

```swift
struct ItemHistoryPoint: Codable {
    let calculatedAt: Date
    let componentPercentage: Double
    let patientValue: String?
}

let query = supabase
    .from("patient_item_scores_with_component_weights")
    .select("calculated_at, component_percentage, patient_value")
    .eq("patient_id", value: userId)
    .eq("biomarker_name", value: "HbA1c")
    .eq("pillar_name", value: "Healthful Nutrition")
    .order("calculated_at", ascending: false)
    .limit(30)

let history: [ItemHistoryPoint] = try await query.execute().value

// Chart: X-axis = calculatedAt, Y-axis = componentPercentage
```

## SQL Verification Queries

### Verify Component Weights Sum to 1.0

```sql
SELECT
    pillar_name,
    component_type,
    COUNT(*) as item_count,
    ROUND(SUM(item_weight_in_component)::numeric, 4) as sum_weights
FROM patient_item_scores_current_with_component_weights
WHERE patient_id = '<uuid>'
GROUP BY pillar_name, component_type
ORDER BY pillar_name, component_type;

-- All sum_weights should be 1.0000
```

### Get Top Items in a Component

```sql
SELECT
    COALESCE(biomarker_name, biometric_name, question_number::text) as item,
    ROUND((item_weight_in_component * 100)::numeric, 2) as pct_of_component,
    component_percentage as patient_score_pct
FROM patient_item_scores_current_with_component_weights
WHERE patient_id = '<uuid>'
  AND pillar_name = 'Healthful Nutrition'
  AND component_type = 'markers'
ORDER BY item_weight_in_component DESC
LIMIT 10;
```

## UI Layout Example

```
┌─────────────────────────────────────┐
│ Healthful Nutrition                 │
│ 88% (0.88/1.0)                      │
├─────────────────────────────────────┤
│ Components:                         │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ Markers (72%)         → 92%     │ │  ← Tappable
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ Behaviors (18%)       → 85%     │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ Education (10%)       → 0%      │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘

After tapping "Markers":

┌─────────────────────────────────────┐
│ ← Healthful Nutrition Markers       │
│ 65 items • 92% average              │
├─────────────────────────────────────┤
│ Items:                              │
│                                     │
│ Lp(a)          3.9%   [████████] 100% │
│ ApoB           3.9%   [████████] 100% │
│ HbA1c          3.1%   [████████] 100% │
│ LDL            3.1%   [████████] 100% │
│ Triglycerides  2.8%   [█████░░░]  75% │
│                       ^^^^^^^^^       │
│                     % of markers      │
└─────────────────────────────────────┘
```

## Notes

- The `component_percentage` column is the same as the original `item_percentage` - it shows the patient's score on that item as a % of the item's maximum
- The new `item_weight_in_component` shows what fraction of the COMPONENT that item represents
- All weights are already normalized and sum to 1.0 per component
- Use `*_current_with_component_weights` for current state, `*_with_component_weights` for history/charts
