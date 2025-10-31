# Unit Toggle System

**Date**: 2025-10-23
**Status**: Implemented for Protein, Ready for Other Metrics

---

## Overview

The unit toggle system allows users to switch between different units for the same metric (e.g., protein in servings vs grams). Like Apple Health's unit preferences, users can toggle once and all related metrics respect that preference.

---

## Database Schema

### New Columns

**`display_metrics` table**:
```sql
-- Array of units this metric supports
supported_units JSONB DEFAULT '["default"]'::jsonb NOT NULL

-- Default unit if user has no preference
default_unit TEXT

-- Indicates if this is a parent metric with children
is_parent BOOLEAN DEFAULT false NOT NULL
```

**`patient_display_metrics_preferences` table**:
```sql
-- User's preferred unit for this metric
preferred_unit TEXT
```

### Examples

```sql
-- Protein Intake (parent)
supported_units: ["servings", "grams"]
default_unit: "servings"
is_parent: true

-- Protein: Breakfast (child)
supported_units: ["servings", "grams"]
default_unit: "servings"
parent_metric_id: "DISP_PROTEIN_SERVINGS"

-- Protein Variety (child - no toggle)
supported_units: ["count"]
default_unit: "count"
parent_metric_id: "DISP_PROTEIN_SERVINGS"
```

---

## How It Works

### 1. Parent Metric with Toggle

**Database**: `DISP_PROTEIN_SERVINGS` (ID stays for compatibility, display name = "Protein Intake")

**UI Flow**:
```
┌────────────────────────────────────────┐
│  Protein Intake                        │
│  ════════════════                      │
│  [Servings ⚪ | 🟢 Grams]   ← Toggle   │
│                                        │
│  Current: 120 grams                    │
│  Last entry: Today, 2:30 PM            │
│                                        │
│  [Log New Entry]                       │
└────────────────────────────────────────┘
```

### 2. Children Respect Parent's Unit

When user selects "Grams" toggle on parent:

```
┌────────────────────────────────────────┐
│  [▲ View Details]                      │
│  ────────────────────────────────      │
│  Meals                                 │
│  • Breakfast: 40g                   [>]│  ← Shows in grams
│  • Lunch: 35g                       [>]│
│  • Dinner: 45g                      [>]│
│                                        │
│  Variety                               │
│  • Protein Variety: 4 sources       [>]│  ← Always count
│                                        │
│  Plant-Based                           │
│  • Plant-Based %: 40%               [>]│  ← Different toggle
│  • Plant-Based: 48g                 [>]│
│                                        │
│  Alternative Units                     │
│  • g/kg body weight: 1.5 g/kg       [>]│  ← No toggle
└────────────────────────────────────────┘
```

---

## Implementation for Mobile

### Querying Display Unit

```swift
// 1. Check user preference
let userPref = await fetchUserPreference(
  userId: userId,
  displayMetricId: "DISP_PROTEIN_SERVINGS"
)

// 2. Get metric's supported units
let metric = await fetchDisplayMetric("DISP_PROTEIN_SERVINGS")

// 3. Determine display unit
let displayUnit = userPref?.preferredUnit ?? metric.defaultUnit

// 4. Query appropriate aggregation
let aggMetricId = (displayUnit == "servings")
  ? "AGG_PROTEIN_SERVINGS"
  : "AGG_PROTEIN_GRAMS"

// 5. Fetch data
let data = await fetchAggregation(
  userId: userId,
  aggMetricId: aggMetricId,
  periodType: "weekly",
  calculationType: "SUM"
)
```

### Saving User Preference

```swift
// When user toggles unit
func onUnitToggle(newUnit: String) {
  // Save preference
  await upsertUserPreference(
    userId: userId,
    displayMetricId: "DISP_PROTEIN_SERVINGS",
    preferredUnit: newUnit
  )

  // Refresh all protein views (parent + children)
  await refreshMetricViews()
}
```

### SQL Queries

**Check if metric supports toggle**:
```sql
SELECT
  display_metric_id,
  supported_units,
  default_unit
FROM display_metrics
WHERE display_metric_id = 'DISP_PROTEIN_SERVINGS';

-- Result:
-- supported_units: ["servings", "grams"]
-- Shows toggle UI if array length > 1
```

**Get user's preference**:
```sql
SELECT preferred_unit
FROM patient_display_metrics_preferences
WHERE user_id = :user_id
  AND display_metric_id = (
    SELECT id FROM display_metrics
    WHERE display_metric_id = 'DISP_PROTEIN_SERVINGS'
  );
```

**Set user's preference**:
```sql
INSERT INTO patient_display_metrics_preferences (
  user_id,
  display_metric_id,
  preferred_unit
)
SELECT
  :user_id,
  id,
  :preferred_unit
FROM display_metrics
WHERE display_metric_id = 'DISP_PROTEIN_SERVINGS'
ON CONFLICT (user_id, display_metric_id)
DO UPDATE SET
  preferred_unit = EXCLUDED.preferred_unit,
  updated_at = NOW();
```

---

## Current Protein Implementation

### Parent: Protein Intake (DISP_PROTEIN_SERVINGS)
- **Supported Units**: servings, grams
- **Default**: servings
- **Aggregations**:
  - `AGG_PROTEIN_SERVINGS` (primary)
  - `AGG_PROTEIN_GRAMS` (secondary for toggle)

### Children (inherit parent's toggle):

**Toggle-capable** (servings ↔ grams):
- Protein: Breakfast
- Protein: Lunch
- Protein: Dinner

**No toggle** (single unit):
- Protein Variety → count
- Protein per Kilogram Body Weight → g/kg

**Different toggle** (grams ↔ percentage):
- Plant-Based Protein Percentage → percentage (default)
- Plant-Based Protein (g) → grams

---

## Extending to Other Metrics

### Good Candidates for Toggle

**Nutrition**:
- Fiber: servings ↔ grams
- Fruits: servings ↔ grams
- Vegetables: servings ↔ grams
- Water: fl oz ↔ ml ↔ cups
- Fats: servings ↔ grams

**Exercise**:
- Cardio Duration: minutes ↔ hours
- Distance: miles ↔ kilometers ↔ meters
- Weight (strength training): lbs ↔ kg

**Sleep**:
- Duration: hours ↔ minutes
- Time of day: 12hr ↔ 24hr format

### Implementation Steps

1. **Check aggregations exist** for both units
2. **Update display_metrics**:
   ```sql
   UPDATE display_metrics
   SET
     supported_units = '["unit1", "unit2"]'::jsonb,
     default_unit = 'unit1'
   WHERE display_metric_id = 'DISP_METRIC_ID';
   ```
3. **Link both aggregations**:
   ```sql
   INSERT INTO display_metrics_aggregations
   (display_metric_id, agg_metric_id, period_type, calculation_type_id, is_primary)
   VALUES
   ('DISP_METRIC_ID', 'AGG_METRIC_UNIT1', 'weekly', 'SUM', true),
   ('DISP_METRIC_ID', 'AGG_METRIC_UNIT2', 'weekly', 'SUM', false);
   ```
4. **Update mobile UI** to show toggle when `supported_units.length > 1`

---

## UI/UX Guidelines

### Toggle Placement

**Parent Metric**:
- Toggle appears directly below metric name
- Segmented control style (like iOS Settings)
- State persists across app sessions

**Children**:
- No separate toggle (inherit from parent)
- Display in parent's selected unit
- Exception: Children with their own `supported_units` can have separate toggle

### Visual Design

```
┌────────────────────────────────────────┐
│  Protein Intake                        │
│  ════════════════                      │
│                                        │
│  [● Servings  |  Grams ]   ← Toggle   │
│     ^selected    ^not                  │
│                                        │
│  Current: 3.5 servings                 │
│                                        │
```

### Accessibility

- Toggle should be keyboard/voice navigable
- Announce unit changes to screen readers
- Remember preference per user, per metric

---

## Testing Checklist

- [ ] Toggle changes parent metric chart
- [ ] Toggle changes all child metric values
- [ ] Preference persists after app restart
- [ ] Multiple users have independent preferences
- [ ] Metrics without toggle don't show toggle UI
- [ ] Child metrics with different toggle work independently
- [ ] Data entry respects current toggle unit
- [ ] Historical data converts correctly between units

---

---

## Current Implementation Status

### ✅ Fully Implemented (Toggle Available)

**Protein** - servings ↔ grams
- Parent: Protein Intake (DISP_PROTEIN_SERVINGS)
- Children: Breakfast, Lunch, Dinner (all toggle)
- Children (single-unit): Variety (count), g/kg, Plant-Based % & grams

**Fiber** - servings ↔ grams
- Parent: Fiber Intake (DISP_FIBER_SERVINGS)
- Children: Breakfast, Lunch, Dinner (all toggle)
- Children (single-unit): Source Count, Source Variety, Sources (all count)

**Plant-Based Protein** - grams ↔ percentage
- Parent: Plant-Based Protein Percentage
- Alternate view: Plant-Based Protein (g)

### ⚙️ Single Unit (No Toggle Yet)

**Nutrition**:
- Fruit Servings (only servings) - *needs grams aggregation*
- Vegetable Servings (only servings) - *needs grams aggregation*
- Legume Servings (only servings) - *needs grams aggregation*
- Water Consumption (only fl oz) - *needs ml and cups aggregations*

**Exercise**:
- Cardio Duration (only minutes) - *needs hours aggregation*
- Distance metrics not yet created - *needs miles ↔ km aggregations*

### 🔮 Future Toggle Candidates

**When aggregations are added**:
- All vegetables/fruits: servings ↔ grams
- Water: fl oz ↔ ml ↔ cups
- Sleep duration: hours ↔ minutes
- Exercise duration: minutes ↔ hours
- Distance: miles ↔ km
- Weight (strength): lbs ↔ kg
- Temperature: F ↔ C
- Time format: 12hr ↔ 24hr

---

## Next Steps

1. ✅ Protein toggle implemented
2. ✅ Fiber toggle implemented
3. ⬜ Create missing aggregations (grams for fruits/vegetables, ml/cups for water)
4. ⬜ Add unit conversion utilities (mobile helper functions)
5. ⬜ Add unit toggle to data entry modals
6. ⬜ Add unit display to chart axis labels
