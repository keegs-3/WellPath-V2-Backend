# Simplified Display Metrics Architecture

## ✅ MIGRATION COMPLETE

The complex parent/child/section structure has been **replaced with a simple flat structure**. Swift handles UI complexity, database just provides data.

---

## New Database Structure

### 1. `display_metrics` (Simple Flat Table)

```sql
CREATE TABLE display_metrics (
  metric_id text UNIQUE NOT NULL,
  metric_name text NOT NULL,
  description text,

  -- Categorization
  pillar text,
  category text,  -- e.g., "sleep", "nutrition", "activity"

  -- Chart configuration
  chart_type_id text,  -- "bar_vertical", "sleep_stages_horizontal", etc.
  chart_config jsonb,

  -- Unit configuration
  supported_units jsonb,  -- ["hours", "minutes"]
  default_unit text,

  -- Display
  display_order integer,
  is_active boolean,
  icon text,
  color text
);
```

**Example Rows:**
```
metric_id                 | metric_name       | chart_type_id            | category
--------------------------+-------------------+--------------------------+----------
DISP_SLEEP_ANALYSIS       | Sleep Analysis    | sleep_stages_horizontal  | sleep
DISP_PROTEIN_SERVINGS     | Protein           | bar_vertical             | nutrition
DISP_SLEEP_CONSISTENCY    | Sleep Consistency | trend_line               | sleep
```

### 2. `display_metrics_aggregations` (Junction Table)

```sql
CREATE TABLE display_metrics_aggregations (
  metric_id text REFERENCES display_metrics(metric_id),
  agg_metric_id text REFERENCES aggregation_metrics(agg_id),
  period_type text,  -- "daily", "weekly", "monthly"
  calculation_type_id text,  -- "SUM", "AVG"

  -- For multi-series charts
  display_order integer,  -- Order in stacked chart
  series_label text,      -- Label for this series
  series_color text       -- Color for this series
);
```

**Example: Sleep Analysis (4 data series)**
```
metric_id           | agg_metric_id              | period_type | display_order
--------------------+----------------------------+-------------+--------------
DISP_SLEEP_ANALYSIS | AGG_DEEP_SLEEP_DURATION    | daily       | 1
DISP_SLEEP_ANALYSIS | AGG_CORE_SLEEP_DURATION    | daily       | 2
DISP_SLEEP_ANALYSIS | AGG_REM_SLEEP_DURATION     | daily       | 3
DISP_SLEEP_ANALYSIS | AGG_AWAKE_PERIODS_DURATION | daily       | 4
```

**Example: Protein (single aggregation)**
```
metric_id              | agg_metric_id       | period_type
-----------------------+---------------------+-------------
DISP_PROTEIN_SERVINGS  | AGG_PROTEIN_GRAMS   | daily
DISP_PROTEIN_SERVINGS  | AGG_PROTEIN_GRAMS   | weekly
DISP_PROTEIN_SERVINGS  | AGG_PROTEIN_GRAMS   | monthly
```

---

## Mobile Query Examples

### Simple Metric (One Aggregation)

```swift
// 1. Get metric
let metric = try await supabase
    .from("display_metrics")
    .select()
    .eq("metric_id", value: "DISP_PROTEIN_SERVINGS")
    .single()
    .execute()
    .value

// 2. Get aggregation mapping
let aggMapping = try await supabase
    .from("display_metrics_aggregations")
    .select()
    .eq("metric_id", value: "DISP_PROTEIN_SERVINGS")
    .eq("period_type", value: "daily")
    .single()
    .execute()
    .value

// aggMapping.agg_metric_id = "AGG_PROTEIN_GRAMS"

// 3. Get data
let data = try await supabase
    .from("aggregation_results_cache")
    .select()
    .eq("user_id", value: userId)
    .eq("agg_metric_id", value: aggMapping.agg_metric_id)
    .eq("period_type", value: "daily")
    .execute()
    .value

// 4. Render chart
BarChart(data: data)
```

### Complex Metric (Multiple Aggregations)

```swift
// 1. Get metric
let metric = try await supabase
    .from("display_metrics")
    .select()
    .eq("metric_id", value: "DISP_SLEEP_ANALYSIS")
    .single()
    .execute()
    .value

// 2. Get all aggregation mappings (ordered)
let aggMappings = try await supabase
    .from("display_metrics_aggregations")
    .select()
    .eq("metric_id", value: "DISP_SLEEP_ANALYSIS")
    .eq("period_type", value: "daily")
    .order("display_order", ascending: true)
    .execute()
    .value

// aggMappings = [
//   { agg_metric_id: "AGG_DEEP_SLEEP_DURATION", series_label: "Deep" },
//   { agg_metric_id: "AGG_CORE_SLEEP_DURATION", series_label: "Core" },
//   { agg_metric_id: "AGG_REM_SLEEP_DURATION", series_label: "REM" },
//   { agg_metric_id: "AGG_AWAKE_PERIODS_DURATION", series_label: "Awake" }
// ]

// 3. Get data for each series
var chartData: [String: [AggregationResult]] = [:]
for mapping in aggMappings {
    let data = try await supabase
        .from("aggregation_results_cache")
        .select()
        .eq("user_id", value: userId)
        .eq("agg_metric_id", value: mapping.agg_metric_id)
        .eq("period_type", value: "daily")
        .execute()
        .value

    chartData[mapping.series_label] = data
}

// 4. Render stacked horizontal bar
SleepStagesChart(
    deep: chartData["Deep"],
    core: chartData["Core"],
    rem: chartData["REM"],
    awake: chartData["Awake"]
)
```

---

## What Was Removed

### ❌ Dropped Tables:
- `parent_display_metrics` (too complex)
- `child_display_metrics` (too complex)
- `parent_detail_sections` (too complex)
- `parent_child_display_metrics_aggregations` (too complex)

### ✅ Kept Tables:
- `aggregation_results_cache` (the actual data)
- `aggregation_metrics` (what aggregations exist)
- `aggregation_periods` (daily/weekly/monthly)
- `calculation_types` (SUM/AVG/COUNT)

### 📦 Archived:
Old complex tables backed up to:
- `z_old_parent_display_metrics`
- `z_old_child_display_metrics`
- `z_old_parent_detail_sections`
- `z_old_parent_child_display_metrics_aggregations`

---

## Current State

**45 Display Metrics** including:
- Sleep Analysis
- Protein
- Fiber
- Water
- Steps
- Cardio
- Strength
- And more...

**148 Aggregation Mappings** connecting metrics to their data sources

**34 Screen Links** mapping screens to metrics

---

## Swift Implementation Strategy

### Pattern A: Simple Metric View

For metrics with ONE aggregation (Water, Steps, etc.):

```swift
struct SimpleMetricView: View {
    let metric: DisplayMetric
    @StateObject private var viewModel = SimpleMetricViewModel()

    var body: some View {
        BarChart(data: viewModel.aggregationData)
    }
}
```

### Pattern B: Multi-Series Metric View

For metrics with MULTIPLE aggregations (Sleep Analysis):

```swift
struct SleepAnalysisView: View {
    let metric: DisplayMetric
    @StateObject private var viewModel = SleepAnalysisViewModel()

    var body: some View {
        HorizontalStackedBarChart(
            series: viewModel.stageSeries  // Deep, Core, REM, Awake
        )
    }
}
```

### Pattern C: Drill-Down Metric View

For metrics like Protein that need drill-down modals:

```swift
struct ProteinView: View {
    let metric: DisplayMetric
    @StateObject private var viewModel = ProteinViewModel()

    var body: some View {
        VStack {
            // Main chart (total protein)
            BarChart(data: viewModel.totalProtein)

            // "Show More" button
            Button("Show More") {
                showModal = true
            }
        }
        .sheet(isPresented: $showModal) {
            // Hardcoded breakdown views
            TabView {
                ProteinByMealView()  // Queries AGG_PROTEIN_BREAKFAST_GRAMS, etc.
                ProteinByTypeView()  // Queries AGG_PROTEIN_TYPE_LEAN, etc.
            }
        }
    }
}
```

---

## Benefits of This Approach

1. **Simple Database**: Just 2 tables instead of 4 complex related tables
2. **Simple Queries**: 3 queries instead of 5-table joins
3. **Flexible UI**: Swift decides structure, not database
4. **Easy to Maintain**: Add new metrics by just adding rows
5. **Easy to Extend**: New chart types = new Swift views, not new DB tables
6. **No Architecture Confusion**: One clear pattern

---

## Next Steps

1. ✅ Database simplified
2. **Swift**: Create dedicated views for each pattern
3. **Swift**: Update queries to use new flat structure
4. **Backend**: Rename `DISP_PROTEIN_SERVINGS` → `DISP_PROTEIN_GRAMS`
5. **Backend**: Add any missing aggregation mappings

The complex parent/child architecture is gone. Swift can now handle UI complexity while the database stays simple.
