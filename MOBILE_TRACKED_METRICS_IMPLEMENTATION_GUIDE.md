# Mobile Tracked Metrics Implementation Guide

**For**: iOS/Swift Development Team
**Date**: 2025-10-23
**Status**: Production Ready ✅

---

## Table of Contents

1. [Quick Start](#quick-start)
2. [Database Tables Reference](#database-tables-reference)
3. [Step-by-Step Implementation](#step-by-step-implementation)
4. [SQL Queries](#sql-queries)
5. [Data Models (Swift)](#data-models-swift)
6. [Rendering Charts](#rendering-charts)
7. [Common Patterns](#common-patterns)
8. [Example: Protein Sources](#example-protein-sources)

---

## Quick Start

### What You're Building

```
┌─────────────────────────────────────┐
│  Nutrition Screen                   │  ← Display Screen
│  ────────────────────────────       │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Protein Intake          [▼] │   │  ← Parent Card
│  │ ═════════════               │   │
│  │ [● Servings | Grams]        │   │  ← Unit Toggle
│  │                             │   │
│  │ ╔═══════════════════════╗   │   │
│  │ ║ [Bar Chart: 7 days]   ║   │   │  ← Main Chart
│  │ ╚═══════════════════════╝   │   │
│  │                             │   │
│  │ Current: 3.5 servings       │   │
│  │                             │   │
│  │ [Show More]  ← Tap this     │   │
│  │                             │   │
│  │ About Protein               │   │
│  │ Protein is essential for... │   │
│  └─────────────────────────────┘   │
└─────────────────────────────────────┘

Tap "Show More" ↓

┌─────────────────────────────────────┐
│  Protein Intake              [✕]    │  ← Modal
│  ═════════════                      │
│  [Timing][Type][Variety][Sources]   │  ← Tabs/Sections
│   ──────                            │
│                                     │
│  ╔═══════════════════════════════╗  │
│  ║  ONE CHART (bar_stacked)      ║  │  ← Section Chart
│  ║                               ║  │
│  ║  3.0                          ║  │
│  ║  2.5  ┌──┐                    ║  │
│  ║  2.0  │░░│ ┌──┐ ┌──┐         ║  │
│  ║  1.5  │░░│ │▓▓│ │░░│         ║  │
│  ║  1.0  │▓▓│ │░░│ │▓▓│         ║  │
│  ║  0.5  │▒▒│ │▒▒│ │▒▒│         ║  │
│  ║       ▀──▀ ▀──▀ ▀──▀         ║  │
│  ║       Mon  Tue  Wed           ║  │
│  ╚═══════════════════════════════╝  │
│                                     │
│  ▒▒ Breakfast   ▓▓ Lunch   ░░ Dinner│  ← Data Series
└─────────────────────────────────────┘
```

**Key Concept**: Each section IS a single chart with children as data series (stacked segments/bars).

---

## Database Tables Reference

### Tables You Need to Query

| Table | Purpose | When to Query |
|-------|---------|---------------|
| `parent_display_metrics` | Parent card data | On screen load |
| `parent_detail_sections` | Modal tabs/sections | When user taps "Show More" |
| `child_display_metrics` | Data series in each section | When loading a section |
| `parent_child_display_metrics_aggregations` | Links children to aggregations | When loading chart data |
| `aggregation_results_cache` | **The actual data values** | When rendering charts |
| `aggregation_periods` | Period configuration (D/W/M/6M/Y) | For period selector |

### Tables You DON'T Need to Query Directly

- `aggregation_metrics` - Metadata only, data comes from cache
- `data_entry_fields` - Backend config, not needed for display
- `instance_calculations` - Backend processing, transparent to mobile

---

## Step-by-Step Implementation

### Step 1: Load Screen → Show Parent Cards

**Query**: Get all parents for a screen

```sql
-- Example: Get parents for "Nutrition" screen
SELECT
  parent_metric_id,
  parent_name,
  parent_description,
  chart_type_id,
  supported_units,
  default_unit,
  about_what,
  about_why,
  about_optimal_target,
  about_quick_tips
FROM parent_display_metrics pdm
JOIN display_screens_metrics dsm ON dsm.metric_id = pdm.parent_metric_id
WHERE dsm.screen_id = 'SCREEN_NUTRITION'
  AND pdm.is_active = true
ORDER BY dsm.display_order;
```

**Returns**: List of parent cards (Protein, Fiber, Fruits, etc.)

### Step 2: Render Parent Card

For each parent:

**A. Render Main Chart**

```sql
-- Get parent's own aggregation data
SELECT
  arc.value,
  arc.period_start,
  arc.period_end
FROM aggregation_results_cache arc
JOIN parent_child_display_metrics_aggregations pca
  ON pca.agg_metric_id = arc.agg_metric_id
WHERE pca.parent_metric_id = :parent_metric_id
  AND arc.user_id = :user_id
  AND arc.period_type = :selected_period  -- 'weekly'
  AND arc.calculation_type_id = 'AVG'
ORDER BY arc.period_start
LIMIT :bars;  -- 7 for weekly
```

**B. Render Unit Toggle** (if supported_units has multiple values)

```json
supported_units: ["servings", "grams"]
```

Show toggle buttons. When user switches units, fetch data with the alternate unit's aggregation.

**C. Render About Section**

Just display the text from `about_what`, `about_why`, `about_optimal_target`, `about_quick_tips`.

### Step 3: User Taps "Show More" → Load Modal

**Query**: Get sections (tabs) for this parent

```sql
SELECT
  section_id,
  section_name,
  section_icon,
  section_chart_type_id,
  display_order,
  is_default_tab
FROM parent_detail_sections
WHERE parent_metric_id = :parent_metric_id
  AND is_active = true
ORDER BY display_order;
```

**Returns**: List of tabs
```
[
  { id: "SECTION_PROTEIN_TIMING", name: "Timing", chart_type: "bar_stacked", is_default: true },
  { id: "SECTION_PROTEIN_TYPE", name: "Type", chart_type: "bar_stacked", is_default: false },
  { id: "SECTION_PROTEIN_VARIETY", name: "Variety", chart_type: "bar_stacked", is_default: false },
  { id: "SECTION_PROTEIN_SOURCES_SERVINGS", name: "Sources", chart_type: "bar_stacked", is_default: false }
]
```

### Step 4: Load Default Section (First Tab)

**Query**: Get data series for the section

```sql
SELECT
  child_metric_id,
  child_name,
  data_series_order
FROM child_display_metrics
WHERE section_id = :section_id
  AND is_active = true
ORDER BY data_series_order;
```

**Example Returns** (for Timing section):
```
[
  { id: "DISP_PROTEIN_BREAKFAST", name: "Protein: Breakfast", order: 1 },
  { id: "DISP_PROTEIN_LUNCH", name: "Protein: Lunch", order: 2 },
  { id: "DISP_PROTEIN_DINNER", name: "Protein: Dinner", order: 3 }
]
```

### Step 5: Fetch Chart Data for Section

**Query**: Get aggregation data for ALL children in the section

```sql
SELECT
  cdm.child_metric_id,
  cdm.child_name,
  cdm.data_series_order,
  arc.value,
  arc.period_start,
  arc.period_end
FROM child_display_metrics cdm
JOIN parent_child_display_metrics_aggregations pca
  ON pca.child_metric_id = cdm.child_metric_id
JOIN aggregation_results_cache arc
  ON arc.agg_metric_id = pca.agg_metric_id
  AND arc.period_type = pca.period_type
  AND arc.calculation_type_id = pca.calculation_type_id
WHERE cdm.section_id = :section_id
  AND arc.user_id = :user_id
  AND arc.period_type = :selected_period  -- 'weekly'
  AND arc.calculation_type_id = :calc_type  -- 'AVG' for weekly
ORDER BY cdm.data_series_order, arc.period_start;
```

**Returns**: Data for ALL series, grouped by child

```
[
  // Breakfast data
  { child_id: "DISP_PROTEIN_BREAKFAST", child_name: "Breakfast", order: 1, value: 1.5, date: "2025-10-16" },
  { child_id: "DISP_PROTEIN_BREAKFAST", child_name: "Breakfast", order: 1, value: 1.2, date: "2025-10-17" },
  { child_id: "DISP_PROTEIN_BREAKFAST", child_name: "Breakfast", order: 1, value: 1.8, date: "2025-10-18" },

  // Lunch data
  { child_id: "DISP_PROTEIN_LUNCH", child_name: "Lunch", order: 2, value: 1.0, date: "2025-10-16" },
  { child_id: "DISP_PROTEIN_LUNCH", child_name: "Lunch", order: 2, value: 0.8, date: "2025-10-17" },

  // Dinner data
  { child_id: "DISP_PROTEIN_DINNER", child_name: "Dinner", order: 3, value: 2.0, date: "2025-10-16" },
  ...
]
```

### Step 6: Render Stacked Bar Chart

Group data by date, stack by child:

```
Date: Oct 16
  ▓▓▓▓▓▓ Breakfast: 1.5
  ░░░░   Lunch: 1.0
  ▒▒▒▒▒▒▒▒ Dinner: 2.0
  Total bar height: 4.5

Date: Oct 17
  ▓▓▓▓▓ Breakfast: 1.2
  ░░░  Lunch: 0.8
  ▒▒▒▒▒▒▒ Dinner: 1.8
  Total bar height: 3.8
```

### Step 7: User Swipes to Next Tab

Repeat Step 4-6 for the new section.

---

## SQL Queries

### Query 1: Get Parent Card Data

```sql
-- Get parent metadata and current value
WITH parent_meta AS (
  SELECT
    parent_metric_id,
    parent_name,
    chart_type_id,
    supported_units,
    default_unit,
    about_what,
    about_why,
    about_optimal_target,
    about_quick_tips
  FROM parent_display_metrics
  WHERE parent_metric_id = $1
),
current_value AS (
  SELECT
    arc.value,
    arc.period_end
  FROM aggregation_results_cache arc
  JOIN parent_child_display_metrics_aggregations pca
    ON pca.agg_metric_id = arc.agg_metric_id
  WHERE pca.parent_metric_id = $1
    AND arc.user_id = $2
    AND arc.period_type = 'daily'
    AND arc.calculation_type_id = 'SUM'
  ORDER BY arc.period_end DESC
  LIMIT 1
)
SELECT
  pm.*,
  cv.value as current_value,
  cv.period_end as current_date
FROM parent_meta pm
CROSS JOIN current_value cv;
```

**Parameters**:
- `$1`: parent_metric_id (e.g., 'DISP_PROTEIN_SERVINGS')
- `$2`: user_id

### Query 2: Get Parent Chart Data (Last 7 Days)

```sql
SELECT
  arc.value,
  arc.period_start,
  arc.period_end
FROM aggregation_results_cache arc
JOIN parent_child_display_metrics_aggregations pca
  ON pca.agg_metric_id = arc.agg_metric_id
WHERE pca.parent_metric_id = $1
  AND arc.user_id = $2
  AND arc.period_type = $3  -- 'weekly'
  AND arc.calculation_type_id = $4  -- 'AVG'
  AND arc.period_end >= CURRENT_DATE - INTERVAL '7 days'
ORDER BY arc.period_start;
```

**Parameters**:
- `$1`: parent_metric_id
- `$2`: user_id
- `$3`: period_type ('daily', 'weekly', 'monthly', '6month', 'yearly')
- `$4`: calculation_type_id ('SUM' for daily, 'AVG' for others)

### Query 3: Get Modal Sections (Tabs)

```sql
SELECT
  section_id,
  section_name,
  section_icon,
  section_chart_type_id,
  display_order,
  is_default_tab
FROM parent_detail_sections
WHERE parent_metric_id = $1
  AND is_active = true
ORDER BY display_order;
```

### Query 4: Get Children for Section

```sql
SELECT
  child_metric_id,
  child_name,
  child_description,
  data_series_order
FROM child_display_metrics
WHERE section_id = $1
  AND is_active = true
ORDER BY data_series_order;
```

### Query 5: Get Section Chart Data (Stacked Bars)

```sql
SELECT
  cdm.child_metric_id,
  cdm.child_name,
  cdm.data_series_order,
  arc.value,
  arc.period_start,
  arc.period_end
FROM child_display_metrics cdm
JOIN parent_child_display_metrics_aggregations pca
  ON pca.child_metric_id = cdm.child_metric_id
JOIN aggregation_results_cache arc
  ON arc.agg_metric_id = pca.agg_metric_id
  AND arc.period_type = pca.period_type
  AND arc.calculation_type_id = pca.calculation_type_id
WHERE cdm.section_id = $1
  AND arc.user_id = $2
  AND arc.period_type = $3
  AND arc.calculation_type_id = $4
  AND arc.period_end >= $5  -- Filter by date range
ORDER BY cdm.data_series_order, arc.period_start;
```

**Parameters**:
- `$1`: section_id
- `$2`: user_id
- `$3`: period_type (inherits from parent card selection)
- `$4`: calculation_type_id ('SUM' for daily, 'AVG' for others)
- `$5`: start_date (e.g., CURRENT_DATE - INTERVAL '7 days')

---

## Data Models (Swift)

### Parent Card

```swift
struct ParentMetric: Identifiable {
    let id: String  // parent_metric_id
    let name: String  // parent_name
    let description: String?
    let chartType: String  // chart_type_id
    let supportedUnits: [String]  // supported_units
    let defaultUnit: String
    let about: AboutContent
    let currentValue: Double?
    let currentDate: Date?
}

struct AboutContent {
    let what: String  // about_what
    let why: String  // about_why
    let optimalTarget: String  // about_optimal_target
    let quickTips: String  // about_quick_tips
}
```

### Section (Modal Tab)

```swift
struct MetricSection: Identifiable {
    let id: String  // section_id
    let name: String  // section_name
    let icon: String  // section_icon
    let chartType: String  // section_chart_type_id
    let displayOrder: Int
    let isDefaultTab: Bool
}
```

### Child (Data Series)

```swift
struct ChildMetric: Identifiable {
    let id: String  // child_metric_id
    let name: String  // child_name
    let description: String?
    let order: Int  // data_series_order
}
```

### Chart Data

```swift
struct ChartDataPoint {
    let value: Double  // arc.value
    let date: Date  // arc.period_end
}

struct SeriesData: Identifiable {
    let id: String  // child_metric_id
    let name: String  // child_name
    let order: Int  // data_series_order
    let dataPoints: [ChartDataPoint]
}
```

---

## Rendering Charts

### Stacked Bar Chart (Swift Charts)

```swift
import Charts

struct ProteinTimingChart: View {
    let seriesData: [SeriesData]  // [Breakfast, Lunch, Dinner]

    var body: some View {
        Chart {
            ForEach(seriesData) { series in
                ForEach(series.dataPoints) { dataPoint in
                    BarMark(
                        x: .value("Date", dataPoint.date, unit: .day),
                        y: .value("Servings", dataPoint.value),
                        stacking: .standard  // THIS IS KEY!
                    )
                    .foregroundStyle(by: .value("Meal", series.name))
                }
            }
        }
        .chartLegend(position: .bottom, spacing: 8)
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { value in
                AxisValueLabel(format: .dateTime.weekday(.abbreviated))
            }
        }
    }
}
```

**Key Point**: `stacking: .standard` makes it a stacked bar chart!

### Example Data Structure for Rendering

```swift
let proteinTimingData: [SeriesData] = [
    SeriesData(
        id: "DISP_PROTEIN_BREAKFAST",
        name: "Breakfast",
        order: 1,
        dataPoints: [
            ChartDataPoint(value: 1.5, date: Date("2025-10-16")),
            ChartDataPoint(value: 1.2, date: Date("2025-10-17")),
            ChartDataPoint(value: 1.8, date: Date("2025-10-18")),
            // ... 7 days total
        ]
    ),
    SeriesData(
        id: "DISP_PROTEIN_LUNCH",
        name: "Lunch",
        order: 2,
        dataPoints: [
            ChartDataPoint(value: 1.0, date: Date("2025-10-16")),
            ChartDataPoint(value: 0.8, date: Date("2025-10-17")),
            // ...
        ]
    ),
    SeriesData(
        id: "DISP_PROTEIN_DINNER",
        name: "Dinner",
        order: 3,
        dataPoints: [
            ChartDataPoint(value: 2.0, date: Date("2025-10-16")),
            ChartDataPoint(value: 1.8, date: Date("2025-10-17")),
            // ...
        ]
    )
]
```

---

## Common Patterns

### Pattern 1: Period Selection

When user changes period (D → W → M → 6M → Y):

1. Update `selected_period` state
2. Determine `calculation_type_id`:
   - Daily: `'SUM'` (show total for day)
   - All others: `'AVG'` (show daily average)
3. Re-fetch chart data with new parameters
4. Update x-axis based on period's `x_axis_granularity`:
   - Daily: Hours (12 AM, 6, 12 PM, 6)
   - Weekly: Days (M, T, W, T, F, S, S)
   - Monthly: Days (1, 5, 10, 15, 20, 25, 30)
   - 6-Month: Weeks
   - Yearly: Months (Jan, Feb, Mar, ...)

### Pattern 2: Unit Toggle

When user toggles units (Servings ↔ Grams):

1. Update `selected_unit` state
2. Find the alternate parent metric:
   - If current is `DISP_PROTEIN_SERVINGS`, switch to `DISP_PROTEIN_GRAMS`
   - If current is `DISP_PROTEIN_GRAMS`, switch to `DISP_PROTEIN_SERVINGS`
3. Re-fetch data using new parent_metric_id
4. Update y-axis label

### Pattern 3: Loading States

```swift
enum LoadingState<T> {
    case idle
    case loading
    case loaded(T)
    case error(Error)
}

@State private var parentState: LoadingState<ParentMetric> = .idle
@State private var sectionsState: LoadingState<[MetricSection]> = .idle
@State private var chartDataState: LoadingState<[SeriesData]> = .idle
```

### Pattern 4: Caching

Cache query results to avoid re-fetching:

```swift
class MetricsCache {
    private var parentCache: [String: ParentMetric] = [:]
    private var sectionsCache: [String: [MetricSection]] = [:]

    func getParent(id: String) async -> ParentMetric? {
        if let cached = parentCache[id] {
            return cached
        }

        let parent = await fetchParent(id: id)
        parentCache[id] = parent
        return parent
    }
}
```

---

## Example: Protein Sources

### Complete Flow

```swift
// 1. User lands on Nutrition screen
let parents = await fetchParents(screenId: "SCREEN_NUTRITION")
// Returns: [Protein, Fiber, Fruits, Vegetables, ...]

// 2. Render Protein parent card
let proteinParent = parents.first { $0.id == "DISP_PROTEIN_SERVINGS" }
let proteinChartData = await fetchParentChartData(
    parentId: proteinParent.id,
    userId: currentUserId,
    period: "weekly",
    calcType: "AVG"
)
renderParentCard(parent: proteinParent, data: proteinChartData)

// 3. User taps "Show More"
let sections = await fetchSections(parentId: proteinParent.id)
// Returns: [Timing, Type, Variety, Sources]

let defaultSection = sections.first { $0.isDefaultTab } ?? sections[0]
// defaultSection = "Timing"

// 4. Load Timing section
let children = await fetchChildren(sectionId: defaultSection.id)
// Returns: [Breakfast, Lunch, Dinner]

let chartData = await fetchSectionChartData(
    sectionId: defaultSection.id,
    userId: currentUserId,
    period: "weekly",
    calcType: "AVG"
)
// Returns: SeriesData for Breakfast, Lunch, Dinner

// 5. Render stacked bar chart
ProteinTimingChart(seriesData: chartData)

// 6. User swipes to "Sources" tab
let sourcesSection = sections.first { $0.id == "SECTION_PROTEIN_SOURCES_SERVINGS" }

let sourceChildren = await fetchChildren(sectionId: sourcesSection.id)
// Returns: [Cottage Cheese, Eggs, Fish, Tofu, Beef, ...] (15 total)

let sourcesChartData = await fetchSectionChartData(
    sectionId: sourcesSection.id,
    userId: currentUserId,
    period: "weekly",
    calcType: "AVG"
)
// Returns: SeriesData for all 15 protein sources

// 7. Render stacked bar with 15 colored segments
ProteinSourcesChart(seriesData: sourcesChartData)
```

---

## Important Notes

### 1. Period Inherits from Parent

When user selects a period on the parent card (e.g., "Weekly"), ALL modal sections use the same period. Don't let users change period within the modal.

### 2. Calculation Type Depends on Period

```swift
func calculationType(for period: String) -> String {
    return period == "daily" ? "SUM" : "AVG"
}
```

- **Daily**: Show TOTAL for that day (SUM)
- **Weekly/Monthly/etc.**: Show DAILY AVERAGE (AVG)

### 3. Empty Data Handling

If a child has no data for a time period, either:
- Show value as 0 (recommended for stacked bars)
- Or omit that segment entirely

### 4. Colors for Data Series

Assign consistent colors to each data series:
```swift
let mealColors: [String: Color] = [
    "Breakfast": .orange,
    "Lunch": .blue,
    "Dinner": .purple
]
```

### 5. Performance

- Fetch chart data for visible section only
- Don't pre-fetch all sections
- Cache parent metadata (changes rarely)
- Don't cache aggregation_results_cache (changes daily)

---

## Testing Checklist

- [ ] Parent card loads with correct data
- [ ] Unit toggle switches between servings/grams
- [ ] Period selector changes chart timeframe
- [ ] "Show More" opens modal with sections
- [ ] Default section loads automatically
- [ ] Tab swipe loads new section
- [ ] Stacked bars show all data series
- [ ] Legend shows all series names with colors
- [ ] Empty data doesn't crash
- [ ] Back button closes modal
- [ ] Chart scrolls/zooms (if supported)

---

## Quick Reference

### Tables → UI Mapping

| Database Table | UI Element |
|----------------|------------|
| `parent_display_metrics` | Parent card |
| `parent_detail_sections` | Modal tabs |
| `child_display_metrics` | Data series labels |
| `aggregation_results_cache` | Chart data points |

### Key Foreign Keys

```
parent_display_metrics.parent_metric_id
  ↓
parent_detail_sections.parent_metric_id
  ↓
child_display_metrics.parent_metric_id + section_id
  ↓
parent_child_display_metrics_aggregations.child_metric_id
  ↓
aggregation_results_cache.agg_metric_id
```

### Period → Calculation Type

| Period | Calculation Type | Meaning |
|--------|-----------------|---------|
| Daily | SUM | Total for that day |
| Weekly | AVG | Daily average over 7 days |
| Monthly | AVG | Daily average over 30 days |
| 6-Month | AVG | Daily average over 26 weeks |
| Yearly | AVG | Daily average over 12 months |

---

## Need Help?

**Questions?** Ask in #backend-mobile-integration Slack channel

**Found a bug?** Report to backend team with:
- Parent metric ID
- Section ID
- User ID
- Period/calc type
- SQL query result

**Documentation**: See `FINAL_TRACKED_METRICS_ARCHITECTURE.md` for full architecture details

---

🎉 **Ready to build!** Start with the Protein parent card and work your way through the sections.
