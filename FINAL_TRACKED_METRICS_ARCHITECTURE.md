# Final Tracked Metrics Architecture

**Date**: 2025-10-23
**Status**: Production Ready ✅
**Pattern**: Apple Health Modal with Data Series

---

## Complete Flow

```
pillars_base (navigation)
  ↓
display_screens (navigation)
  ↓
parent_display_metrics (THE CARD ON SCREEN)
  ├─ Main chart (chart_type_id)
  ├─ Unit toggle (supported_units)
  ├─ Summary stats
  ├─ [Show More] button
  └─ About section (about_what, about_why, about_optimal_target, about_quick_tips)
  ↓
Tap [Show More] → MODAL with sections
  ↓
parent_detail_sections (TABS IN MODAL - each section IS a chart)
  ├─ section_chart_type_id (defines THE chart for this section)
  └─ child_display_metrics (DATA SERIES/LABELS in the section chart)
      └─ child_name (becomes label in chart: "Breakfast", "Deep", etc.)
```

---

## Key Architectural Principle

**Each section IS a single chart with children as data series.**

NOT this:
```
❌ Section: "Timing"
    └─ Child: Breakfast (separate chart)
    └─ Child: Lunch (separate chart)
    └─ Child: Dinner (separate chart)
```

BUT this:
```
✅ Section: "Timing" (ONE chart with section_chart_type_id='bar_vertical')
    └─ Data Series: Breakfast (bar #1 in chart)
    └─ Data Series: Lunch (bar #2 in chart)
    └─ Data Series: Dinner (bar #3 in chart)
```

---

## Database Tables

### `parent_display_metrics` - The Card

The metric card shown on screen.

**Key Columns**:
- `parent_metric_id` - Identifier
- `parent_name` - Display name ("Protein Intake")
- `chart_type_id` → chart_types - Chart for parent card
- `supported_units` - JSONB array for toggle (["servings", "grams"])
- `default_unit` - Default if no user preference
- `about_what` - "What is this metric?"
- `about_why` - "Why does it matter?"
- `about_optimal_target` - "What's the optimal range?"
- `about_quick_tips` - "Actionable tips"

**Example** (Protein):
```sql
parent_metric_id: 'DISP_PROTEIN_SERVINGS'
parent_name: 'Protein Intake'
chart_type_id: 'bar_vertical'
supported_units: ["servings", "grams"]
default_unit: 'servings'
about_what: 'Protein is a macronutrient...'
about_why: 'Adequate protein supports muscle...'
```

---

### `parent_detail_sections` - Modal Tabs

Tabs in the "Show More" modal. **Each section IS a chart.**

**Key Columns**:
- `section_id` - Identifier
- `parent_metric_id` → parent_display_metrics
- `section_name` - Tab label ("Timing", "Type", "Variety")
- `section_icon` - Icon for tab
- `section_chart_type_id` → chart_types - **THE chart for this entire section**
- `display_order` - Tab order (1, 2, 3)
- `is_default_tab` - Opens first

**Example** (Protein Timing):
```sql
section_id: 'SECTION_PROTEIN_TIMING'
parent_metric_id: 'DISP_PROTEIN_SERVINGS'
section_name: 'Timing'
section_icon: 'clock'
section_chart_type_id: 'bar_vertical'  ← ONE chart with 3 bars
display_order: 1
is_default_tab: true
```

---

### `child_display_metrics` - Data Series

The labels/data series within a section's chart.

**Key Columns**:
- `child_metric_id` - Identifier
- `parent_metric_id` → parent_display_metrics
- `section_id` → parent_detail_sections (can be NULL for non-modal children)
- `child_name` - **Label in the chart** ("Breakfast", "Deep Sleep")
- `data_series_order` - Order in section chart (renamed from display_order_in_parent)
- `chart_label_order` - Order within category (renamed from display_order_in_category)
- `supported_units` - Can override parent if needed
- `inherit_parent_unit` - Whether to use parent's toggle

**Example** (Protein Breakfast):
```sql
child_metric_id: 'DISP_PROTEIN_BREAKFAST'
parent_metric_id: 'DISP_PROTEIN_SERVINGS'
section_id: 'SECTION_PROTEIN_TIMING'
child_name: 'Protein: Breakfast'  ← Becomes bar label
data_series_order: 1  ← First bar in chart
inherit_parent_unit: true  ← Uses parent's servings/grams toggle
```

---

## Protein Example - Complete Structure

### Parent Card (On Screen)

```
┌─────────────────────────────────────────┐
│  Protein Intake                         │
│  ══════════════════                     │
│  [● Servings | Grams]   ← Toggle       │
│                                         │
│  Current: 3.5 servings                  │
│  ╔═══════════════════════════════════╗  │
│  ║  [Bar Chart: Last 7 Days]         ║  │ ← chart_type_id='bar_vertical'
│  ╚═══════════════════════════════════╝  │
│                                         │
│  [Show More]                            │
│                                         │
│  About Protein                          │
│  ──────────────                         │
│  Protein is a macronutrient...          │ ← about_what
│                                         │
│  Why It Matters                         │
│  Adequate protein supports...           │ ← about_why
│                                         │
│  Optimal Target                         │
│  0.8-1.2g per kg body weight...         │ ← about_optimal_target
│                                         │
│  Quick Tips                             │
│  • Spread across meals                  │ ← about_quick_tips
│  • Include variety                      │
└─────────────────────────────────────────┘
```

### Modal Section 1: Timing (Default Tab)

```
┌─────────────────────────────────────────┐
│  Protein Intake                      [X]│
│  ═══════════════                        │
│  [Timing] [Type] [Variety]  ← Tabs     │
│  ════════                               │
│                                         │
│  ╔═══════════════════════════════════╗  │
│  ║     ONE CHART (bar_vertical)      ║  │
│  ║                                   ║  │
│  ║   1.5  1.0  2.0                   ║  │
│  ║   ║    ║    ║                     ║  │
│  ║   ║    ║    ║                     ║  │
│  ║   ▓    ▓    ▓                     ║  │
│  ╚═══▓════▓════▓═════════════════════╝  │
│     B'fast Lunch Dinner                 │
│                                         │
│  Summary:                               │
│  • Breakfast: 1.5 servings              │
│  • Lunch: 1.0 servings                  │
│  • Dinner: 2.0 servings                 │
└─────────────────────────────────────────┘
```

### Modal Section 2: Type

```
┌─────────────────────────────────────────┐
│  Protein Intake                      [X]│
│  ═══════════════                        │
│  [Timing] [Type] [Variety]              │
│        ════════                         │
│                                         │
│  ╔═══════════════════════════════════╗  │
│  ║  ONE CHART (comparison_view)      ║  │
│  ║                                   ║  │
│  ║   Plant-Based    40%              ║  │
│  ║   ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ 48g            ║  │
│  ║                                   ║  │
│  ║   Animal-Based   60%              ║  │
│  ║   ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ 72g    ║  │
│  ╚═══════════════════════════════════╝  │
└─────────────────────────────────────────┘
```

---

## SQL Queries

### 1. Load Parent Card

```sql
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
WHERE parent_metric_id = 'DISP_PROTEIN_SERVINGS';
```

### 2. Load Modal Sections (Tabs)

```sql
SELECT
  section_id,
  section_name,
  section_icon,
  section_chart_type_id,
  display_order,
  is_default_tab
FROM parent_detail_sections
WHERE parent_metric_id = 'DISP_PROTEIN_SERVINGS'
  AND is_active = true
ORDER BY display_order;
```

**Result**:
```
section_id               | section_name | section_chart_type_id | is_default_tab
-------------------------|--------------|----------------------|---------------
SECTION_PROTEIN_TIMING   | Timing       | bar_vertical         | true
SECTION_PROTEIN_TYPE     | Type         | comparison_view      | false
SECTION_PROTEIN_VARIETY  | Variety      | bar_horizontal       | false
```

### 3. Load Data Series for Section

```sql
SELECT
  child_metric_id,
  child_name,
  data_series_order,
  supported_units,
  inherit_parent_unit
FROM child_display_metrics
WHERE section_id = 'SECTION_PROTEIN_TIMING'
  AND is_active = true
ORDER BY data_series_order;
```

**Result**:
```
child_metric_id         | child_name          | data_series_order
------------------------|---------------------|------------------
DISP_PROTEIN_BREAKFAST  | Protein: Breakfast  | 1
DISP_PROTEIN_LUNCH      | Protein: Lunch      | 2
DISP_PROTEIN_DINNER     | Protein: Dinner     | 3
```

### 4. Get Data for Section Chart

For each data series, fetch its aggregation:

```sql
-- For Breakfast bar
SELECT
  arc.value,
  arc.period_start,
  arc.period_end
FROM aggregation_results_cache arc
JOIN parent_child_display_metrics_aggregations pca
  ON pca.agg_metric_id = arc.agg_metric_id
WHERE pca.child_metric_id = 'DISP_PROTEIN_BREAKFAST'
  AND arc.user_id = :user_id
  AND arc.period_type = 'weekly'
  AND arc.calculation_type_id = 'AVG'
ORDER BY arc.period_end DESC
LIMIT 7;

-- Repeat for Lunch, Dinner
```

Then combine into ONE chart with 3 bars/series.

---

## Mobile Implementation (Swift)

### Load Parent Card

```swift
struct ParentMetric {
    let id: String
    let name: String
    let chartType: String
    let supportedUnits: [String]
    let defaultUnit: String
    let about: AboutContent
}

struct AboutContent {
    let what: String
    let why: String
    let optimalTarget: String
    let quickTips: String
}

func loadParentCard(parentId: String) async -> ParentMetric {
    let parent = await database.fetchParent(parentId)

    // Render card
    renderChart(type: parent.chartType, data: await fetchAggregation(parent.id))
    renderToggle(units: parent.supportedUnits, default: parent.defaultUnit)
    renderAbout(parent.about)

    return parent
}
```

### Show More Tapped → Load Modal

```swift
func onShowMoreTapped(parentId: String) async {
    // 1. Load sections
    let sections = await database.fetchSections(parentId: parentId)

    // 2. Find default tab
    let defaultSection = sections.first(where: { $0.isDefaultTab }) ?? sections[0]

    // 3. Load data series for default section
    let dataSeries = await database.fetchDataSeries(sectionId: defaultSection.id)

    // 4. Fetch aggregation data for each series
    var chartData: [[ChartDataPoint]] = []
    for series in dataSeries {
        let data = await fetchAggregation(childId: series.id)
        chartData.append(data)
    }

    // 5. Render ONE chart with multiple series
    renderSectionChart(
        type: defaultSection.chartType,  // e.g., "bar_vertical"
        labels: dataSeries.map { $0.name },  // ["Breakfast", "Lunch", "Dinner"]
        data: chartData  // [[1.5, 2.0, ...], [1.0, 1.5, ...], [2.0, 1.8, ...]]
    )

    // 6. Show modal
    presentModal(sections: sections, selectedSection: defaultSection)
}
```

### Tab Swiped → Load New Section

```swift
func onTabChanged(newSection: Section) async {
    // 1. Load data series for this section
    let dataSeries = await database.fetchDataSeries(sectionId: newSection.id)

    // 2. Fetch data for each series
    var chartData: [[ChartDataPoint]] = []
    for series in dataSeries {
        let data = await fetchAggregation(childId: series.id)
        chartData.append(data)
    }

    // 3. Render section's chart with data series
    renderSectionChart(
        type: newSection.chartType,
        labels: dataSeries.map { $0.name },
        data: chartData
    )
}
```

---

## Chart Types Reference

Available `chart_type_id` values:

| chart_type_id | Usage |
|---------------|-------|
| `bar_vertical` | Vertical bars (time series, comparisons) |
| `bar_horizontal` | Horizontal bars (rankings, distributions) |
| `bar_stacked` | Stacked bars (part-to-whole, like sleep stages) |
| `comparison_view` | Side-by-side comparison |
| `trend_line` | Line chart for trends |
| `sleep_stages_horizontal` | Sleep timeline (specialized) |
| `current_value` | Single value display |
| `gauge` | Radial gauge/progress |
| `heatmap` | Heatmap visualization |

---

## Summary

### Parent Card
- ONE chart (`chart_type_id`)
- Unit toggle (`supported_units`)
- About section (4 text fields)
- [Show More] button

### Modal Sections
- Tabs (`parent_detail_sections`)
- Each section = ONE chart (`section_chart_type_id`)
- Children = Data series/labels in that chart
- Swipeable/paginated

### Data Flow
```
User sees parent card
  ↓
Taps [Show More]
  ↓
Modal opens with sections (tabs)
  ↓
Default section's chart renders with multiple data series
  ↓
User swipes to next tab
  ↓
New section's chart renders with its data series
```

**Production ready!** 🎉
