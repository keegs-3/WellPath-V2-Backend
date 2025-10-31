# Mobile Implementation: Actual Database Queries

**Date**: 2025-10-23
**Status**: ✅ Production Ready

This guide uses **actual table and column names** from the database.

---

## Overview: Query Flow

```
1. Screen Query → Get all parent cards for a screen (e.g., Nutrition)
2. Parent Query → Get parent card data + chart config
3. Sections Query → Get all modal tabs/sections for a parent
4. Child Query → Get child data for a specific section (stacked bars)
```

---

## 1. Screen-Level Query

**Purpose**: Get all parent cards to display on a screen

### Query

```sql
SELECT
  pdm.parent_metric_id,
  pdm.parent_name,
  pdm.parent_description,
  pdm.pillar,
  pdm.default_unit,
  pdm.default_period,
  pdm.chart_type_id,
  pdm.display_order,
  pdm.is_featured,
  pdm.widget_type
FROM display_screens_parent_metrics dspm
JOIN parent_display_metrics pdm
  ON pdm.parent_metric_id = dspm.parent_metric_id
WHERE dspm.screen_id = :screen_id
  AND pdm.is_active = true
ORDER BY dspm.display_order, pdm.display_order;
```

### Parameters
- `:screen_id` - Example: `'SCREEN_NUTRITION'`, `'SCREEN_EXERCISE'`

### Example Result
```
parent_metric_id      | parent_name       | default_period | widget_type
----------------------+-------------------+----------------+-------------
DISP_PROTEIN_SERVINGS | Protein Intake    | weekly         | card
DISP_FIBER_GRAMS      | Fiber Intake      | weekly         | card
```

---

## 2. Parent Card Query

**Purpose**: Get parent card data and chart configuration

### Query

```sql
-- Get parent configuration + aggregation data
SELECT
  pdm.parent_metric_id,
  pdm.parent_name,
  pdm.parent_description,
  pdm.default_unit,
  pdm.chart_type_id,

  -- Chart config from aggregation_metrics_periods
  amp.chart_type,
  amp.bars,
  amp.days,
  amp.x_axis_granularity,
  amp.y_axis_label,
  amp.y_axis_auto_scale,

  -- Aggregation data
  arc.value,
  arc.period_start,
  arc.period_end,
  arc.data_points_count,
  arc.calculation_type_id

FROM parent_display_metrics pdm

-- Link to parent-child-agg mapping to get agg_metric_id
JOIN parent_child_display_metrics_aggregations pcdma
  ON pcdma.parent_metric_id = pdm.parent_metric_id
  AND pcdma.period_type = :selected_period  -- IMPORTANT: Filter by period here!

-- Get chart config for this period
JOIN aggregation_metrics_periods amp
  ON amp.agg_metric_id = pcdma.agg_metric_id
  AND amp.period_id = pcdma.period_type

-- Get actual data values
JOIN aggregation_results_cache arc
  ON arc.agg_metric_id = pcdma.agg_metric_id
  AND arc.period_type = pcdma.period_type
  AND arc.calculation_type_id = pcdma.calculation_type_id
  AND arc.user_id = :user_id

WHERE pdm.parent_metric_id = :parent_metric_id
  AND pcdma.child_metric_id IS NULL  -- Only parent aggregations

ORDER BY arc.period_start;
```

### Parameters
- `:parent_metric_id` - Example: `'DISP_PROTEIN_SERVINGS'`
- `:user_id` - User UUID
- `:selected_period` - One of: `'hourly'`, `'daily'`, `'weekly'`, `'monthly'`, `'6month'`, `'yearly'`

### Example Result (Hourly Period)
```
parent_name    | chart_type     | bars | value | period_start        | calculation_type_id
---------------+----------------+------+-------+---------------------+--------------------
Protein Intake | bar_vertical   | 24   | 20.1  | 2025-10-22 08:00:00 | SUM
Protein Intake | bar_vertical   | 24   | 23.4  | 2025-10-22 12:00:00 | SUM
Protein Intake | bar_vertical   | 24   | 34.9  | 2025-10-22 18:00:00 | SUM
```

### Example Result (Weekly Period)
```
parent_name    | chart_type   | bars | value | period_start        | calculation_type_id
---------------+--------------+------+-------+---------------------+--------------------
Protein Intake | bar_vertical | 7    | 85.3  | 2025-10-17 00:00:00 | AVG
Protein Intake | bar_vertical | 7    | 92.1  | 2025-10-18 00:00:00 | AVG
... (7 days total)
```

---

## 3. Sections Query

**Purpose**: Get all modal tabs/sections for a parent card

### Query

```sql
SELECT DISTINCT
  cdm.section_id,

  -- Derive section name from first child
  CASE
    WHEN cdm.section_id = 'SECTION_PROTEIN_TIMING' THEN 'Timing'
    WHEN cdm.section_id = 'SECTION_PROTEIN_TYPE' THEN 'Type'
    WHEN cdm.section_id = 'SECTION_PROTEIN_VARIETY' THEN 'Variety'
    ELSE cdm.section_id
  END as section_name,

  -- Chart type (should be consistent per section)
  MIN(cdm.chart_type_id) as chart_type_id,

  -- Count of children in this section
  COUNT(cdm.child_metric_id) as child_count

FROM child_display_metrics cdm

WHERE cdm.parent_metric_id = :parent_metric_id
  AND cdm.section_id IS NOT NULL
  AND cdm.is_active = true

GROUP BY cdm.section_id
ORDER BY cdm.section_id;
```

### Parameters
- `:parent_metric_id` - Example: `'DISP_PROTEIN_SERVINGS'`

### Example Result
```
section_id              | section_name | chart_type_id | child_count
------------------------+--------------+---------------+-------------
SECTION_PROTEIN_TIMING  | Timing       | bar_stacked   | 3
SECTION_PROTEIN_TYPE    | Type         | bar_stacked   | 6
SECTION_PROTEIN_VARIETY | Variety      | value_card    | 1
```

### Mobile Usage
- Create horizontal tabs from `section_name`
- First section is default tab
- Use `chart_type_id` to determine rendering (bar_stacked vs value_card)

---

## 4. Child Data Query (Stacked Bar Charts)

**Purpose**: Get child data for a specific section to render stacked bars

### Query

```sql
SELECT
  cdm.child_metric_id,
  cdm.child_name,
  cdm.child_description,
  cdm.data_series_order,
  cdm.default_unit,

  -- Chart config
  amp.chart_type,
  amp.bars,
  amp.days,
  amp.x_axis_granularity,
  amp.y_axis_label,

  -- Aggregation data
  arc.value,
  arc.period_start,
  arc.period_end,
  arc.calculation_type_id,
  arc.data_points_count

FROM child_display_metrics cdm

-- Link to aggregation via parent_child_display_metrics_aggregations
JOIN parent_child_display_metrics_aggregations pcdma
  ON pcdma.child_metric_id = cdm.child_metric_id
  AND pcdma.period_type = :selected_period  -- IMPORTANT: Filter by period here!

-- Get chart config for this period
JOIN aggregation_metrics_periods amp
  ON amp.agg_metric_id = pcdma.agg_metric_id
  AND amp.period_id = pcdma.period_type

-- Get actual data values
JOIN aggregation_results_cache arc
  ON arc.agg_metric_id = pcdma.agg_metric_id
  AND arc.period_type = pcdma.period_type
  AND arc.calculation_type_id = pcdma.calculation_type_id
  AND arc.user_id = :user_id

WHERE cdm.section_id = :section_id
  AND cdm.is_active = true

ORDER BY cdm.data_series_order NULLS LAST, arc.period_start;
```

### Parameters
- `:section_id` - Example: `'SECTION_PROTEIN_TIMING'`, `'SECTION_PROTEIN_TYPE'`
- `:user_id` - User UUID
- `:selected_period` - One of: `'daily'`, `'weekly'`, `'monthly'`, `'6month'`, `'yearly'`

### Example Result (SECTION_PROTEIN_TIMING, Weekly)
```
child_name         | data_series_order | value | period_start        | calculation_type_id
-------------------+-------------------+-------+---------------------+--------------------
Protein: Breakfast | 1                 | 20.2  | 2025-10-17 00:00:00 | AVG
Protein: Lunch     | 2                 | 29.9  | 2025-10-17 00:00:00 | AVG
Protein: Dinner    | 3                 | 35.2  | 2025-10-17 00:00:00 | AVG
```

### Example Result (SECTION_PROTEIN_TYPE, Weekly)
```
child_name     | data_series_order | value | period_start        | calculation_type_id
---------------+-------------------+-------+---------------------+--------------------
Processed Meat | 1                 | 33.9  | 2025-10-17 00:00:00 | AVG
Red Meat       | 2                 | 31.6  | 2025-10-17 00:00:00 | AVG
Fatty Fish     | 3                 | 23.4  | 2025-10-17 00:00:00 | AVG
Lean Protein   | 4                 | 22.7  | 2025-10-17 00:00:00 | AVG
Plant-based    | 5                 | 27.5  | 2025-10-17 00:00:00 | AVG
```

### Mobile Rendering

For **Stacked Bar Charts**:
1. Group by `period_start` (each bar represents one time period)
2. Stack segments using `data_series_order` (preserves consistent ordering)
3. Assign colors based on `child_metric_id` (consistent across periods)
4. Show legend with `child_name` values

For **Value Cards** (like Variety):
- Display single `value` with `child_name` as label
- No chart needed, just numeric display

---

## 5. Simplified Parent Query (No Child Data)

If you only need parent totals without child breakdown:

```sql
SELECT
  arc.value,
  arc.period_start,
  arc.period_end,
  arc.calculation_type_id,
  arc.data_points_count,

  amp.chart_type,
  amp.bars,
  amp.y_axis_label

FROM parent_child_display_metrics_aggregations pcdma

JOIN aggregation_metrics_periods amp
  ON amp.agg_metric_id = pcdma.agg_metric_id
  AND amp.period_id = :selected_period

JOIN aggregation_results_cache arc
  ON arc.agg_metric_id = pcdma.agg_metric_id
  AND arc.period_type = :selected_period
  AND arc.calculation_type_id = pcdma.calculation_type_id
  AND arc.user_id = :user_id

WHERE pcdma.parent_metric_id = :parent_metric_id
  AND pcdma.child_metric_id IS NULL  -- Only parent aggregations
  AND pcdma.period_type = :selected_period  -- Filter by period

ORDER BY arc.period_start;
```

---

## 6. Period Behavior Reference

| Period   | Bars | Days | Granularity | Calc Type | Meaning                          |
|----------|------|------|-------------|-----------|----------------------------------|
| hourly   | 24   | 1    | hour        | SUM       | Total grams per hour (sparse)    |
| daily    | 7    | 7    | day         | SUM       | Total grams per day              |
| weekly   | 7    | 7    | day         | AVG       | Daily average over 7 days        |
| monthly  | 30   | 30   | day         | AVG       | Daily average over 30 days       |
| 6month   | 26   | 180  | week        | AVG       | Weekly average over 6 months     |
| yearly   | 52   | 365  | week        | AVG       | Weekly average over 12 months    |

---

## 7. Swift/Kotlin Examples

### Swift Example (Parent Card)

```swift
struct ParentCardData {
    let parentName: String
    let chartType: String
    let bars: Int
    let yAxisLabel: String
    let dataPoints: [DataPoint]
}

struct DataPoint {
    let value: Double
    let periodStart: Date
    let periodEnd: Date
}

func fetchParentCard(
    parentMetricId: String,
    userId: UUID,
    period: String
) async throws -> ParentCardData {
    let response = await supabase
        .from("parent_display_metrics")
        .select("""
            parent_name,
            parent_child_display_metrics_aggregations!inner(
                agg_metric_id,
                calculation_type_id,
                aggregation_metrics_periods!inner(
                    chart_type,
                    bars,
                    y_axis_label
                ),
                aggregation_results_cache!inner(
                    value,
                    period_start,
                    period_end
                )
            )
        """)
        .eq("parent_metric_id", parentMetricId)
        .eq("parent_child_display_metrics_aggregations.child_metric_id", nil)
        .eq("aggregation_metrics_periods.period_id", period)
        .eq("aggregation_results_cache.period_type", period)
        .eq("aggregation_results_cache.user_id", userId)
        .order("aggregation_results_cache.period_start")
        .execute()

    // Parse and return
}
```

### Swift Example (Child Section)

```swift
struct ChildSectionData {
    let sectionName: String
    let chartType: String
    let series: [DataSeries]
}

struct DataSeries {
    let name: String
    let order: Int
    let dataPoints: [DataPoint]
}

func fetchChildSection(
    sectionId: String,
    userId: UUID,
    period: String
) async throws -> ChildSectionData {
    let response = await supabase
        .from("child_display_metrics")
        .select("""
            child_name,
            data_series_order,
            parent_child_display_metrics_aggregations!inner(
                aggregation_results_cache!inner(
                    value,
                    period_start,
                    period_end
                )
            )
        """)
        .eq("section_id", sectionId)
        .eq("is_active", true)
        .eq("parent_child_display_metrics_aggregations.period_type", period)
        .eq("aggregation_results_cache.user_id", userId)
        .order("data_series_order")
        .order("aggregation_results_cache.period_start")
        .execute()

    // Parse and return
}
```

---

## 8. Table Reference

### Core Tables

| Table Name                                   | Purpose                                    |
|----------------------------------------------|--------------------------------------------|
| `parent_display_metrics`                     | Parent card configuration                  |
| `child_display_metrics`                      | Child metric configuration + sections      |
| `parent_child_display_metrics_aggregations`  | Links parents/children to aggregations     |
| `aggregation_results_cache`                  | Actual data values                         |
| `aggregation_metrics_periods`                | Chart configuration per period             |
| `display_screens_parent_metrics`             | Screen → parent card mapping               |

### Key Columns

**parent_display_metrics**:
- `parent_metric_id` (PK) - e.g., `'DISP_PROTEIN_SERVINGS'`
- `parent_name` - Display name (e.g., "Protein Intake")
- `default_period` - Default period to show
- `default_unit` - Default unit (e.g., "gram")

**child_display_metrics**:
- `child_metric_id` (PK) - e.g., `'DISP_PROTEIN_BREAKFAST'`
- `parent_metric_id` (FK) - Links to parent
- `section_id` - Groups children into tabs (e.g., `'SECTION_PROTEIN_TIMING'`)
- `child_name` - Display name (e.g., "Protein: Breakfast")
- `data_series_order` - Stacking order in charts

**parent_child_display_metrics_aggregations**:
- `parent_metric_id` - NULL for child-only aggregations
- `child_metric_id` - NULL for parent-only aggregations
- `agg_metric_id` - Links to aggregation_results_cache
- `period_type` - Period this mapping applies to
- `calculation_type_id` - SUM, AVG, etc.

**aggregation_results_cache**:
- `user_id` - User this data belongs to
- `agg_metric_id` - Links to aggregation metric
- `period_type` - hourly, daily, weekly, etc.
- `calculation_type_id` - SUM, AVG, etc.
- `period_start` - Start of time period (use for X-axis)
- `period_end` - End of time period
- `value` - The actual numeric value
- `data_points_count` - Number of raw entries aggregated

**aggregation_metrics_periods**:
- `agg_metric_id` - Which aggregation
- `period_id` - Which period (hourly, daily, etc.)
- `chart_type` - bar_vertical, bar_stacked, line, etc.
- `bars` - Number of bars to display
- `days` - Number of days covered
- `x_axis_granularity` - hour, day, week
- `y_axis_label` - Label for Y-axis (e.g., "Grams")

---

## 9. Testing Queries

Use these to verify data exists:

### Check Parent Data
```sql
SELECT * FROM aggregation_results_cache
WHERE user_id = '02cc8441-5f01-4634-acfc-59e6f6a5705a'
  AND agg_metric_id = 'AGG_PROTEIN_GRAMS'
  AND period_type = 'weekly'
ORDER BY period_start;
```

### Check Child Data (Timing)
```sql
SELECT * FROM aggregation_results_cache
WHERE user_id = '02cc8441-5f01-4634-acfc-59e6f6a5705a'
  AND agg_metric_id IN (
    'AGG_PROTEIN_BREAKFAST_GRAMS',
    'AGG_PROTEIN_LUNCH_GRAMS',
    'AGG_PROTEIN_DINNER_GRAMS'
  )
  AND period_type = 'weekly'
ORDER BY agg_metric_id;
```

### Check Child Data (Type)
```sql
SELECT * FROM aggregation_results_cache
WHERE user_id = '02cc8441-5f01-4634-acfc-59e6f6a5705a'
  AND agg_metric_id LIKE 'AGG_PROTEIN_TYPE_%'
  AND period_type = 'weekly'
ORDER BY agg_metric_id;
```

---

## 10. Common Pitfalls

### ❌ Wrong: Using ambiguous column names
```sql
SELECT parent_metric_id, value  -- Ambiguous!
FROM parent_display_metrics pdm
JOIN aggregation_results_cache arc ...
```

### ✅ Correct: Always use table aliases
```sql
SELECT pdm.parent_metric_id, arc.value
FROM parent_display_metrics pdm
JOIN aggregation_results_cache arc ...
```

---

### ❌ Wrong: Forgetting to filter by user_id
```sql
SELECT * FROM aggregation_results_cache
WHERE agg_metric_id = 'AGG_PROTEIN_GRAMS'
-- Will return all users' data!
```

### ✅ Correct: Always filter by user
```sql
SELECT * FROM aggregation_results_cache
WHERE agg_metric_id = 'AGG_PROTEIN_GRAMS'
  AND user_id = :user_id
```

---

### ❌ Wrong: Hardcoding calculation_type_id
```sql
WHERE arc.calculation_type_id = 'AVG'
-- Daily should use SUM, not AVG!
```

### ✅ Correct: Use from mapping table
```sql
JOIN parent_child_display_metrics_aggregations pcdma ...
WHERE arc.calculation_type_id = pcdma.calculation_type_id
```

---

## Questions?

Contact backend with:
- Table name
- Column name
- User ID
- SQL query attempted
- Expected vs actual results

---

**Last Updated**: 2025-10-23
**Verified**: ✅ All queries tested against production schema
