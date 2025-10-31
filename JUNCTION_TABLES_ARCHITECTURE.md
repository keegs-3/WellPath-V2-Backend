# Junction Tables Architecture - Many-to-Many Metrics

## ✅ Migration Complete

Successfully converted from direct FK relationships to junction tables, enabling **many-to-many** relationships between screens and metrics.

---

## Why Junction Tables?

### Use Cases

**1. Cross-Screen Comparisons**
- Show **Alcohol** on both "Substances" screen AND "Sleep Timing" screen
- Show **Steps** on both "Daily Activity" screen AND "Sleep Quality" screen
- Correlate metrics across health domains

**2. Contextual Display**
- Same metric, different context/labels on each screen
- Override chart types based on screen purpose
- Add context-specific descriptions

**3. Flexible Analytics**
- Build "Insights" screens that pull metrics from multiple domains
- Create "Correlations" views without duplicating metrics
- Show comparison metrics alongside primary metrics

---

## New Architecture

### Before (Direct FK)
```
display_metrics
  ├─ primary_screen_id (FK) ← ONE screen only
  └─ detail_screen_id (FK) ← ONE screen only
```
❌ **Limitation**: Metric locked to one screen

### After (Junction Tables)
```
display_screens_primary_display_metrics
  ├─ primary_screen_id (FK)
  └─ metric_id (FK)

display_screens_detail_display_metrics
  ├─ detail_screen_id (FK)
  └─ metric_id (FK)
```
✅ **Flexibility**: Metric can appear on multiple screens

---

## Junction Table Schemas

### `display_screens_primary_display_metrics`

Links primary screens → metrics (many-to-many).

```sql
CREATE TABLE display_screens_primary_display_metrics (
  id uuid PRIMARY KEY,
  primary_screen_id text REFERENCES display_screens_primary(primary_screen_id),
  metric_id text REFERENCES display_metrics(metric_id),

  -- Display configuration
  display_order integer DEFAULT 1,
  is_featured boolean DEFAULT false,       -- Is this the "hero" metric?
  is_comparison boolean DEFAULT false,     -- Comparison/correlation metric?

  -- Context overrides
  override_title text,                     -- Custom title for this context
  override_description text,
  override_chart_type text,                -- Override chart type for this screen
  context_label text,                      -- "Impact on Sleep Quality"
  context_description text,                -- Why this metric is relevant here

  -- Metadata
  metadata jsonb DEFAULT '{}'::jsonb,

  UNIQUE(primary_screen_id, metric_id)
);
```

**Example: Alcohol on Substances Screen**
```json
{
  "primary_screen_id": "SCREEN_SUBSTANCES_PRIMARY",
  "metric_id": "DISP_ALCOHOL_DRINKS",
  "display_order": 1,
  "is_featured": true,
  "is_comparison": false,
  "override_title": null,
  "context_label": "Daily Intake"
}
```

**Example: Alcohol on Sleep Screen** (comparison)
```json
{
  "primary_screen_id": "SCREEN_SLEEP_TIMING_PRIMARY",
  "metric_id": "DISP_ALCOHOL_DRINKS",
  "display_order": 10,
  "is_featured": false,
  "is_comparison": true,
  "override_title": "Alcohol & Sleep",
  "context_label": "Impact on Sleep Quality",
  "context_description": "Alcohol within 3 hours of bedtime can disrupt sleep cycles"
}
```

### `display_screens_detail_display_metrics`

Links detail screens → metrics (many-to-many).

```sql
CREATE TABLE display_screens_detail_display_metrics (
  id uuid PRIMARY KEY,
  detail_screen_id text REFERENCES display_screens_detail(detail_screen_id),
  metric_id text REFERENCES display_metrics(metric_id),

  -- Organization
  section_id text,                         -- Which tab/section?
  display_order integer DEFAULT 1,
  is_comparison boolean DEFAULT false,

  -- Context overrides
  override_title text,
  override_description text,
  override_chart_type text,
  context_label text,
  context_description text,

  -- Metadata
  metadata jsonb DEFAULT '{}'::jsonb,

  UNIQUE(detail_screen_id, metric_id, section_id)
);
```

**Example: Protein Timing on Protein Detail Screen**
```json
{
  "detail_screen_id": "SCREEN_PROTEIN_DETAIL",
  "metric_id": "DISP_PROTEIN_MEAL_TIMING",
  "section_id": "timing",
  "display_order": 1,
  "is_comparison": false
}
```

**Example: Steps on Sleep Detail Screen** (comparison)
```json
{
  "detail_screen_id": "SCREEN_SLEEP_QUALITY_DETAIL",
  "metric_id": "DISP_STEPS",
  "section_id": "activity_correlation",
  "display_order": 1,
  "is_comparison": true,
  "context_label": "Activity & Sleep Quality",
  "context_description": "Physical activity improves sleep quality. See correlations."
}
```

---

## Current Statistics

### Junction Table Counts
- **Primary Screen Links**: 149 links (41 screens, 149 metrics)
- **Detail Screen Links**: 39 links (16 screens, 39 metrics)

### Cross-Screen Metrics
- **Alcohol**: Appears on 2 screens (Substances + Sleep)
- **Steps**: Can appear on Activity + Sleep screens

---

## Example Use Cases

### 1. Sleep & Alcohol Correlation

**Substances Screen (Primary)**
```swift
// Main context: Substance tracking
metric: DISP_ALCOHOL_DRINKS
title: "Alcohol Intake"
chart: bar_vertical
role: primary tracking
```

**Sleep Timing Screen (Detail)**
```swift
// Comparison context: Impact on sleep
metric: DISP_ALCOHOL_DRINKS
title: "Alcohol & Sleep Impact"  // overridden
chart: comparison_view           // overridden
role: correlation analysis
context: "See how drinking affects your sleep quality"
```

### 2. Activity & Sleep Correlation

**Activity Screen (Primary)**
```swift
metric: DISP_STEPS
title: "Daily Steps"
chart: bar_vertical
role: primary tracking
```

**Sleep Quality Screen (Detail)**
```swift
metric: DISP_STEPS
title: "Activity Impact"         // overridden
chart: correlation_scatter       // overridden
role: correlation analysis
section: "activity_correlation"
context: "Physical activity improves sleep. See your pattern."
```

---

## Swift Implementation

### Query Pattern

```swift
// Get metrics for a primary screen
let primaryMetrics = try await supabase
    .from("display_screens_primary_display_metrics")
    .select("*, display_metrics(*)")
    .eq("primary_screen_id", value: "SCREEN_PROTEIN_PRIMARY")
    .order("display_order", ascending: true)
    .execute()
    .value

// Identify featured metric
let featuredMetric = primaryMetrics.first { $0.is_featured }

// Identify comparison metrics
let comparisonMetrics = primaryMetrics.filter { $0.is_comparison }
```

### Rendering Logic

```swift
struct PrimaryScreenView: View {
    let screenLinks: [PrimaryScreenMetricLink]

    var body: some View {
        VStack {
            // Featured metric (large)
            if let featured = screenLinks.first(where: { $0.isFeatured }) {
                MetricChartView(
                    metric: featured.metric,
                    title: featured.overrideTitle ?? featured.metric.metricName,
                    chartType: featured.overrideChartType ?? featured.metric.chartTypeId,
                    large: true
                )
            }

            // Regular metrics
            ForEach(screenLinks.filter { !$0.isFeatured && !$0.isComparison }) { link in
                MetricChartView(
                    metric: link.metric,
                    title: link.overrideTitle ?? link.metric.metricName,
                    chartType: link.overrideChartType ?? link.metric.chartTypeId
                )
            }

            // Comparison section
            if !comparisonMetrics.isEmpty {
                Section("Correlations") {
                    ForEach(comparisonMetrics) { link in
                        ComparisonMetricView(
                            metric: link.metric,
                            contextLabel: link.contextLabel,
                            contextDescription: link.contextDescription
                        )
                    }
                }
            }
        }
    }
}
```

---

## Adding Cross-Screen Metrics

### Example: Add Caffeine to Sleep Screen

```sql
INSERT INTO display_screens_detail_display_metrics (
  detail_screen_id,
  metric_id,
  section_id,
  display_order,
  is_comparison,
  context_label,
  context_description,
  override_chart_type
) VALUES (
  'SCREEN_SLEEP_TIMING_DETAIL',
  'DISP_CAFFEINE_CONSUMED',
  'sleep_factors',
  3,
  true,
  'Caffeine & Sleep',
  'Caffeine consumed within 6 hours of bedtime can delay sleep onset',
  'correlation_view'
);
```

Now `DISP_CAFFEINE_CONSUMED` appears on:
1. **Hydration Screen** (primary context: tracking intake)
2. **Sleep Timing Screen** (comparison context: impact on sleep)

---

## Benefits

1. **Flexible Relationships**: One metric, multiple screens
2. **Contextual Display**: Override titles/charts based on screen purpose
3. **Correlation Analysis**: Show related metrics from different domains
4. **No Duplication**: One metric, multiple contexts - no data duplication
5. **Easy Extensions**: Add metrics to screens without schema changes
6. **Insights Screens**: Build custom "Insights" screens pulling from multiple domains

---

## Database Structure Summary

```
display_screens
  ├─ display_screens_primary
  │   └─ display_screens_primary_display_metrics (junction)
  │       └─ display_metrics
  │
  └─ display_screens_detail
      └─ display_screens_detail_display_metrics (junction)
          └─ display_metrics
```

**Navigation Flow:**
```
Pillar
  → Display Screen
      → Primary Screen (1-4 featured metrics + comparison metrics)
          → "View More" button
      → Detail Screen (comprehensive breakdowns + correlations in sections/tabs)
```

---

## Next Steps

### Backend
1. ✅ Junction tables created
2. ✅ Existing relationships migrated
3. ⏳ Add more cross-screen correlations (caffeine→sleep, exercise→sleep, etc.)
4. ⏳ Populate `context_description` for comparison metrics
5. ⏳ Add `section_config` in detail screens to organize metrics

### Mobile
1. Update queries to use junction tables
2. Handle `is_comparison` flag to render comparison sections
3. Use `override_title` and `override_chart_type` when present
4. Show `context_description` for comparison metrics
5. Build correlation/comparison chart views

---

**Status:** ✅ COMPLETE
**Date:** 2025-10-25
**Tables Created:**
- `display_screens_primary_display_metrics`
- `display_screens_detail_display_metrics`

**Relationships:** Many-to-many (metrics can appear on multiple screens)
**Cross-Screen Metrics:** 1 (Alcohol on Substances + Sleep screens)
