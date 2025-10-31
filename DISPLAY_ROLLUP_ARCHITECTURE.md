# Display Metrics Rollup Architecture

## The 3-Layer Separation

### Layer 1: Data Entry (What Users Input)
```sql
-- Individual fields for each protein type
DEF_PROTEIN_TYPE_LEAN       -- User logs "chicken breast, 25g"
DEF_PROTEIN_TYPE_PLANT      -- User logs "tofu, 15g"
DEF_PROTEIN_TYPE_FISH       -- User logs "salmon, 30g"
```

**Stay as individual data entry fields** - users can enter different types separately

### Layer 2: Aggregations (What Gets Calculated)
```sql
-- Individual aggregations for each type
AGG_PROTEIN_TYPE_LEAN_PROTEIN    -- Sum of all lean protein grams (daily/weekly/monthly)
AGG_PROTEIN_TYPE_PLANT_BASED     -- Sum of all plant protein grams
AGG_PROTEIN_TYPE_FATTY_FISH      -- Sum of all fish protein grams
```

**Individual aggregations stay** - process_field_aggregations creates them

### Layer 3: Display Rollup (What Mobile Queries)
```sql
-- The SECTION groups them for visualization
SECTION_PROTEIN_TYPE
  ├─ DISP_PROTEIN_TYPE_LEAN    ──┐
  ├─ DISP_PROTEIN_TYPE_PLANT   ──┼─> These are "child display metrics"
  └─ DISP_PROTEIN_TYPE_FISH    ──┘    They're a ROLLUP/LOOKUP layer
```

## The Junction Table (The Magic)

### `parent_child_display_metrics_aggregations`
This table MAPS display metrics → aggregations:

```sql
child_metric_id              | agg_metric_id                    | period_type | calculation_type_id
-----------------------------|----------------------------------|-------------|--------------------
DISP_PROTEIN_TYPE_LEAN       | AGG_PROTEIN_TYPE_LEAN_PROTEIN    | daily       | SUM
DISP_PROTEIN_TYPE_LEAN       | AGG_PROTEIN_TYPE_LEAN_PROTEIN    | weekly      | AVG
DISP_PROTEIN_TYPE_PLANT      | AGG_PROTEIN_TYPE_PLANT_BASED     | daily       | SUM
DISP_PROTEIN_TYPE_FISH       | AGG_PROTEIN_TYPE_FATTY_FISH      | daily       | SUM
```

## Mobile App Query Flow

### Step 1: User Taps "Protein" → Opens Modal → Swipes to "By Type" Tab

```swift
// Mobile queries for children in this section
let children: [DisplayMetric] = supabase
    .from("child_display_metrics")
    .select()
    .eq("section_id", value: "SECTION_PROTEIN_TYPE")
    .execute()
    .value

// Returns:
// - DISP_PROTEIN_TYPE_LEAN
// - DISP_PROTEIN_TYPE_PLANT
// - DISP_PROTEIN_TYPE_FISH
```

### Step 2: For Each Child, Get Its Aggregation

```swift
// For child: DISP_PROTEIN_TYPE_LEAN
let junctionResult = supabase
    .from("parent_child_display_metrics_aggregations")
    .select("agg_metric_id")
    .eq("child_metric_id", value: "DISP_PROTEIN_TYPE_LEAN")
    .eq("period_type", value: "daily")
    .execute()
    .value

// Returns: AGG_PROTEIN_TYPE_LEAN_PROTEIN
```

### Step 3: Query the Actual Data

```swift
let aggregationData = supabase
    .from("aggregation_results_cache")
    .select()
    .eq("user_id", value: userId)
    .eq("agg_metric_id", value: "AGG_PROTEIN_TYPE_LEAN_PROTEIN")
    .eq("period_type", value: "daily")
    .execute()
    .value

// Returns: [{ date: "2025-10-23", value: 45.2 }, ...]
```

### Step 4: Render ONE Chart with Multiple Series

```swift
Chart {
    ForEach(children) { child in
        // Get data for this child's aggregation
        let data = fetchDataForChild(child)

        // Each child becomes ONE layer in stacked bar
        BarMark(
            x: .value("Date", date),
            y: .value("Grams", data.value)
        )
        .foregroundStyle(getColorForChild(child))
    }
}
```

**Result:** ONE stacked bar chart showing Lean (blue) + Plant (green) + Fish (orange) per day

## The Rollup Rules

### Rule 1: One Section = One Chart
- Section `SECTION_PROTEIN_TYPE` → ONE chart
- All children in that section → data series on that ONE chart

### Rule 2: Children Are Display Wrappers
- `DISP_PROTEIN_TYPE_LEAN` is NOT a data entry field
- It's a **display wrapper** that points to `AGG_PROTEIN_TYPE_LEAN_PROTEIN`
- The junction table is the lookup

### Rule 3: Many-to-Many Mapping
A child can point to MULTIPLE aggregations:
```sql
-- DISP_PROTEIN_TYPE_LEAN points to different periods/calculations
DISP_PROTEIN_TYPE_LEAN → AGG_PROTEIN_TYPE_LEAN_PROTEIN (daily, SUM)
DISP_PROTEIN_TYPE_LEAN → AGG_PROTEIN_TYPE_LEAN_PROTEIN (daily, AVG)
DISP_PROTEIN_TYPE_LEAN → AGG_PROTEIN_TYPE_LEAN_PROTEIN (weekly, AVG)
```

## Example: Complete Protein "By Type" Section

### Database Setup

```sql
-- 1. Create Section
INSERT INTO parent_detail_sections (
    section_id, parent_metric_id, section_name, section_chart_type_id
) VALUES (
    'SECTION_PROTEIN_TYPE', 'DISP_PROTEIN_GRAMS', 'By Type', 'bar_stacked'
);

-- 2. Create Child Display Metrics (Rollup Layer)
INSERT INTO child_display_metrics (
    child_metric_id, parent_metric_id, section_id, child_name, data_series_order
) VALUES
    ('DISP_PROTEIN_TYPE_LEAN', 'DISP_PROTEIN_GRAMS', 'SECTION_PROTEIN_TYPE', 'Lean Protein', 1),
    ('DISP_PROTEIN_TYPE_PLANT', 'DISP_PROTEIN_GRAMS', 'SECTION_PROTEIN_TYPE', 'Plant-Based', 2),
    ('DISP_PROTEIN_TYPE_FISH', 'DISP_PROTEIN_GRAMS', 'SECTION_PROTEIN_TYPE', 'Fatty Fish', 3);

-- 3. Link Children to Aggregations (Junction Table)
INSERT INTO parent_child_display_metrics_aggregations (
    child_metric_id, agg_metric_id, period_type, calculation_type_id
) VALUES
    ('DISP_PROTEIN_TYPE_LEAN', 'AGG_PROTEIN_TYPE_LEAN_PROTEIN', 'daily', 'SUM'),
    ('DISP_PROTEIN_TYPE_PLANT', 'AGG_PROTEIN_TYPE_PLANT_BASED', 'daily', 'SUM'),
    ('DISP_PROTEIN_TYPE_FISH', 'AGG_PROTEIN_TYPE_FATTY_FISH', 'daily', 'SUM');
```

### Mobile Query (Simplified)

```swift
// 1. Get section children
let children = getChildren(sectionId: "SECTION_PROTEIN_TYPE")
// → [DISP_PROTEIN_TYPE_LEAN, DISP_PROTEIN_TYPE_PLANT, DISP_PROTEIN_TYPE_FISH]

// 2. For each child, lookup its aggregation via junction table
for child in children {
    let aggMetricId = getAggregationForChild(child, period: "daily")
    // → AGG_PROTEIN_TYPE_LEAN_PROTEIN, etc.

    let data = queryAggregationCache(aggMetricId, userId: currentUser)
    // → [{date: "2025-10-23", value: 45.2}, ...]

    chartData[child.childName] = data
}

// 3. Render ONE stacked bar chart
renderStackedBarChart(chartData)
```

## Current Problem: Missing Rollups

The issue is we have:
- ✅ Data entry fields exist
- ✅ Aggregations exist
- ❌ Child display metrics might not exist or aren't linked correctly
- ❌ Junction table might be incomplete

**Solution:** Create the rollup layer (child display metrics + junction mappings)

## Verification Query

```sql
-- Check if rollup exists for protein types
SELECT
    cdm.child_metric_id,
    cdm.child_name,
    cdm.section_id,
    pca.agg_metric_id,
    pca.period_type
FROM child_display_metrics cdm
LEFT JOIN parent_child_display_metrics_aggregations pca
    ON pca.child_metric_id = cdm.child_metric_id
WHERE cdm.section_id = 'SECTION_PROTEIN_TYPE'
ORDER BY cdm.data_series_order, pca.period_type;
```

If this returns 0 rows → **rollup doesn't exist, need to create it**
If it returns rows → **rollup exists, mobile just needs to query it correctly**
