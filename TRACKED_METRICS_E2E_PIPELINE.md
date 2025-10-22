# Tracked Metrics End-to-End Pipeline

## Overview
Complete flow from data entry → storage → aggregation → scoring → display

---

## Pipeline Stages

### 1. Data Entry (Mobile App)
**User enters data through various input types**

#### Input Field Types:
- **Numeric** (e.g., "How many servings of vegetables?")
- **Boolean** (e.g., "Did you exercise today?")
- **Single Select** (e.g., "Sleep quality: Poor/Fair/Good/Excellent")
- **Multi-Select** (e.g., "Which exercises did you do?")
- **Time Duration** (e.g., "How long did you sleep?")
- **Free Text** (e.g., "Notes about your day")

#### Status: ✅ COMPLETE
- Table: `data_entry_fields`
- Fields define: field_type, display_name, options, validation rules

---

### 2. Raw Data Storage
**User responses stored as raw entries**

#### Table: `patient_data_entry_responses`
```sql
- id (uuid)
- user_id (uuid)
- field_id (uuid) → references data_entry_fields
- response_value (text) -- Raw response as entered
- response_numeric (numeric) -- Parsed numeric value if applicable
- recorded_at (timestamptz)
```

#### Status: ✅ COMPLETE
- Raw data persists indefinitely
- No aggregation at this level
- Source of truth for all calculations

---

### 3. Metric Mapping
**Link data entry fields to metrics for aggregation**

#### Table: `data_entry_field_metric_mapping`
```sql
- id (uuid)
- field_id (uuid) → data_entry_fields
- metric_id (uuid) → display_metrics
- value_mapping (jsonb) -- How to convert field values to metric values
```

#### Examples:
```json
// Boolean field → numeric metric
{
  "true": 1,
  "false": 0
}

// Single select → numeric
{
  "Poor": 1,
  "Fair": 2,
  "Good": 3,
  "Excellent": 4
}

// Multi-select → count or sum
{
  "aggregation_type": "count",
  "items": ["Cardio", "Strength", "Flexibility"]
}
```

#### Status: ⚠️ IN PROGRESS
- Table exists
- Need to populate mappings for all fields
- Need validation logic

---

### 4. Metric Definitions
**Central catalog of all trackable metrics**

#### Table: `display_metrics`
```sql
- id (uuid)
- metric_key (text) -- Unique identifier (e.g., 'vegetable_servings')
- display_name (text)
- unit (text) -- 'servings', 'minutes', 'count', etc.
- category (text) -- 'nutrition', 'exercise', 'sleep', etc.
- data_type (text) -- 'numeric', 'boolean', 'duration'
- is_active (boolean)
```

#### Status: ✅ COMPLETE
- Centralized metric catalog
- Used across aggregation, scoring, and display

---

### 5. Aggregation Configuration
**Define how metrics are aggregated over time**

#### Table: `aggregation_metrics`
```sql
- id (uuid)
- metric_id (uuid) → display_metrics
- aggregation_type (text) -- 'sum', 'avg', 'min', 'max', 'count', 'last'
- source_table (text) -- Where raw data lives
- calculation_formula (text) -- SQL expression if needed
```

#### Table: `aggregation_periods`
```sql
- id (uuid)
- period_key (text) -- 'daily', 'weekly_7', 'monthly_30', 'rolling_7', 'rolling_30'
- display_name (text)
- days (integer) -- Number of days in period
- is_rolling (boolean) -- true for rolling windows
```

#### Status: ✅ COMPLETE
- Aggregation rules defined
- Period configurations set

---

### 6. Aggregation Execution
**Calculate aggregated values for each metric/period**

#### Table: `aggregation_metrics_periods`
```sql
- id (uuid)
- user_id (uuid)
- metric_id (uuid)
- period_id (uuid)
- period_start (date)
- period_end (date)
- aggregated_value (numeric)
- source_count (integer) -- Number of raw data points
- calculated_at (timestamptz)
```

#### Process:
1. **Trigger**: New data entry → queue aggregation
2. **Worker**: Process queue, run aggregation SQL
3. **Storage**: Write aggregated values to table
4. **Update**: Recalculate affected rolling windows

#### Status: ⚠️ NEEDS WORK
- Need aggregation worker/cron job
- Need to handle rolling windows
- Need to optimize for performance

---

### 7. WellPath Scoring Integration
**Map aggregated metrics to WellPath score items**

#### Flow:
```
aggregation_metrics_periods
  → behavior score calculation
  → patient_wellpath_score_items (item_type='tracked_metric')
  → pillar scores
  → overall WellPath score
```

#### Scoring Rules:
- Each metric has target ranges (in `metric_scoring_ranges` or similar)
- Aggregated value compared to target
- Score calculated (0-1 scale)
- Weighted by pillar component weights
- Rolled into overall WellPath score

#### Status: 🔴 TODO
- Need to create scoring range tables
- Need to integrate with calculate-wellpath-score Edge Function
- Need to add 'tracked_metric' item_type handling

---

### 8. Chart Configuration
**Define how metrics are visualized**

#### Table: `chart_display_config`
```sql
- id (uuid)
- display_metric_id (uuid)
- chart_type (text) -- 'line', 'bar', 'heatmap', 'gauge', etc.
- config (jsonb) -- Chart-specific settings
```

#### Chart Types:
- **Line Chart**: Time series trends
- **Bar Chart**: Comparisons across periods
- **Heatmap**: Daily patterns over weeks/months
- **Gauge**: Current vs target
- **Progress Bar**: Percentage of goal
- **Scatter**: Correlation between metrics

#### Status: ✅ COMPLETE
- Table structure exists
- Chart type mappings defined
- Config schema documented

---

### 9. Display Screen Mapping
**Organize metrics into app screens/sections**

#### Table: `display_screens`
```sql
- id (uuid)
- screen_key (text) -- 'nutrition', 'sleep', 'exercise', etc.
- display_name (text)
- icon (text)
- sort_order (integer)
```

#### Table: `display_screen_metrics`
```sql
- id (uuid)
- screen_id (uuid)
- display_metric_id (uuid)
- sort_order (integer)
- is_pinned (boolean)
- is_primary (boolean) -- Main metric for this screen
```

#### Status: ✅ COMPLETE
- Screen structure defined
- Metric assignments working

---

### 10. Mobile App Display
**Frontend fetches and displays data**

#### API Endpoints Needed:
```
GET /metrics/user/:userId
  → Returns all metrics for user with latest values

GET /metrics/user/:userId/:metricId/history
  → Returns time series data for specific metric
  → Query params: period, startDate, endDate

GET /metrics/user/:userId/:metricId/chart
  → Returns chart data + config for rendering

GET /screens/:screenId/metrics
  → Returns all metrics for a specific screen
```

#### Status: 🔴 TODO
- Need to create Supabase RPC functions
- Need mobile app integration
- Need real-time updates setup

---

## Current Gaps & Next Steps

### Immediate Priorities:

1. **Aggregation Worker** 🔴
   - Create cron job or Edge Function to process aggregations
   - Handle queue from `wellpath_score_calculation_queue`
   - Calculate daily/rolling window aggregations

2. **Scoring Integration** 🔴
   - Define target ranges for each metric
   - Integrate tracked metrics into WellPath score calculation
   - Add tracked_metric item_type to scoring logic

3. **API Layer** 🔴
   - Create RPC functions for mobile app
   - Set up real-time subscriptions
   - Add caching layer

4. **Data Population** ⚠️
   - Complete field → metric mappings
   - Populate chart configurations
   - Set up initial screen layouts

5. **Testing** 🔴
   - End-to-end flow testing
   - Performance testing with realistic data volumes
   - Edge case handling

---

## Open Questions

1. **Aggregation Frequency**
   - How often should rolling windows recalculate?
   - Daily batch job vs real-time?

2. **Score Update Trigger**
   - Recalculate WellPath score on every data entry?
   - Batch updates daily?
   - Use thresholds (only if value changes significantly)?

3. **Historical Data**
   - How far back do we calculate aggregations?
   - Do we backfill when adding new metrics?

4. **Goal Setting**
   - Where do patient goals live?
   - How do goals affect scoring?
   - Can goals change over time?

5. **Data Entry Prompts**
   - When/how often to prompt users?
   - Push notifications?
   - Adaptive prompting based on adherence?

---

## Success Criteria

✅ **Complete E2E Flow When:**
1. User enters "5 servings of vegetables" in app
2. Data saved to `patient_data_entry_responses`
3. Aggregation worker calculates 30-day rolling average
4. Score calculated: 5 servings = 100% of target
5. WellPath score updates with new behavior score
6. Mobile app shows:
   - Updated WellPath score
   - Vegetable intake line chart
   - 30-day average badge
   - Progress toward goal

---

## Timeline Estimate

- **Phase 1: Aggregation Worker** (1-2 weeks)
- **Phase 2: Scoring Integration** (1 week)
- **Phase 3: API Layer** (1 week)
- **Phase 4: Mobile Integration** (2-3 weeks)
- **Phase 5: Testing & Polish** (1 week)

**Total: 6-8 weeks to full production**

---

*Last Updated: 2025-10-18*
