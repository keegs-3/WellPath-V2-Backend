# WellPath Data Flow Funnel - Complete Architecture

## Overview

This document explains how data flows through the WellPath system from user input to display in the mobile app.

---

## The Complete Data Funnel

```
USER INPUT (Mobile App)
    ↓
DATA ENTRY FIELDS (Structure for input)
    ↓
PATIENT DATA ENTRIES (Raw data storage)
    ↓
INSTANCE CALCULATIONS (Auto-calculated fields)
    ↓
AGGREGATION METRICS (Time-based rollups)
    ↓
DISPLAY METRICS (What gets shown in charts/UI)
    ↓
DISPLAY SCREENS (Where metrics appear)
    ↓
MOBILE APP UI (User sees their data)
```

---

## Layer 1: User Input → Data Entry Fields

### What Happens
User enters data in the mobile app (e.g., "I ate 3 servings of fruit today")

### Database Tables
**`data_entry_fields`** - Defines all possible input fields
- 215 active fields
- Examples: `fruit_servings`, `cardio_duration`, `sleep_start_time`

**`patient_data_entries`** - Stores actual user input
```sql
{
  patient_id: "uuid",
  field_id: "fruit_servings",
  field_value: "3",
  event_instance_id: "meal-uuid",
  entry_timestamp: "2025-10-28 12:00:00"
}
```

### How It Gets Populated
1. **Manual entry**: User fills out a check-in form in mobile app
2. **Apple Health sync**: Automatic sync of steps, sleep, heart rate
3. **Lab upload**: Doctor uploads biomarker results
4. **Survey completion**: User answers onboarding/periodic surveys

---

## Layer 2: Instance Calculations (Auto-Population)

### What Happens
When user enters certain fields, other related fields auto-calculate

### Example: Vegetables → Fiber
```
User enters: vegetables = 5 servings
Edge function calculates: fiber ≈ 15g (5 × 3g per serving)
Auto-populates: fiber_grams = 15
```

### Database Tables
**`instance_calculations`** - Calculation definitions
**`event_types_dependencies`** - Links calculations to events

### How It Gets Populated
**Edge Function**: `run-instance-calculations`
- Triggers after `patient_data_entries` insert
- Runs calculations in `display_order`
- Auto-populates dependent fields

**Example calculation_config:**
```json
{
  "operation": "multiply",
  "source_field": "vegetables_servings",
  "multiplier": 3.0,
  "output_unit": "grams"
}
```

---

## Layer 3: Aggregation Metrics (Time-Based Rollups)

### What Happens
Raw data entries get aggregated over time periods (hourly, daily, weekly, monthly)

### Database Tables
**`aggregation_metrics`** - Defines what gets aggregated
- 200+ metrics
- Examples: `AGG_FRUIT_SERVINGS`, `AGG_CARDIO_DURATION`, `AGG_SLEEP_DURATION`

**`aggregation_results_cache`** - Stores calculated aggregations
```sql
{
  patient_id: "uuid",
  agg_metric_id: "AGG_FRUIT_SERVINGS",
  calculation_type_id: "AVG",
  period_type: "monthly",
  period_start: "2025-10-01",
  period_end: "2025-10-31",
  value: 3.5,
  data_point_count: 28
}
```

### How It Gets Populated
**Option 1 - Edge Function** (Real-time):
```typescript
// After data entry
→ Trigger aggregation update
→ Calculate AVG/SUM/COUNT for relevant periods
→ Update aggregation_results_cache
```

**Option 2 - Batch Script** (Nightly):
```python
# Run for all patients
python scripts/process_aggregations.py
```

### Aggregation Types
- **SUM**: Total (e.g., daily steps)
- **AVG**: Average (e.g., monthly fruit servings)
- **COUNT**: Occurrences (e.g., weekly cardio sessions)
- **MIN/MAX**: Extremes (e.g., lowest blood pressure)
- **FIRST/LAST**: Time-based (e.g., first sleep start time)

---

## Layer 4: Display Metrics (UI Layer)

### What Happens
Aggregation metrics get mapped to user-facing display metrics for charts/UI

### Database Tables
**`display_metrics`** - User-facing metric definitions
- 202 active metrics (as of today)
- Examples: "Daily Steps", "Fruit Consumption", "Sleep Duration"

**`display_metrics_aggregations`** - Links display metrics to aggregation metrics
```sql
{
  metric_id: "DISP_DM_9",           -- Daily Steps
  agg_metric_id: "AGG_STEPS",
  period_type: "daily",
  calculation_type_id: "SUM",
  chart_type_id: "bar_vertical"
}
```

### How It Gets Populated
**Manual setup** (one-time):
```sql
-- Create display metric
INSERT INTO display_metrics (metric_id, metric_name, chart_type_id, pillar)
VALUES ('DISP_DM_9', 'Daily Steps', 'bar_vertical', 'Movement + Exercise');

-- Link to aggregation
INSERT INTO display_metrics_aggregations (metric_id, agg_metric_id, period_type)
VALUES ('DISP_DM_9', 'AGG_STEPS', 'daily');
```

**Today's work**: Created 15 missing display_metrics for biometrics!

---

## Layer 5: Display Screens (Navigation Structure)

### What Happens
Display metrics get assigned to specific screens in the app navigation

### Database Tables
**`display_screens`** - Screen definitions
- 45 screens across 7 pillars
- Examples: "Nutrition Overview", "Sleep Analysis", "Movement Dashboard"

**`display_screens_primary`** - Primary screen configs (main chart)
**`display_screens_detail`** - Detail screen configs (drill-down)

**Junction Tables** (Many-to-many mappings):
- `display_screens_primary_display_metrics` - Which metrics on primary screens
- `display_screens_detail_display_metrics` - Which metrics on detail screens

### How It Gets Populated
**Manual setup** (one-time):
```sql
-- Assign "Daily Steps" to Movement primary screen
INSERT INTO display_screens_primary_display_metrics
  (primary_screen_id, metric_id, display_order, is_featured)
VALUES
  ('movement_primary', 'DISP_DM_9', 1, true);
```

**Current Status**:
- ❌ 29/45 primary screens have NO metrics mapped
- This is our next task!

---

## Layer 6: Scoring System (Separate Pipeline)

### What Happens
Raw data gets scored to calculate WellPath health scores

### Database Tables
**Score History Tables** (snapshots, not live):
1. `patient_item_scores_history` - Individual item scores
2. `patient_component_scores_history` - Component scores (markers/behaviors/education)
3. `patient_pillar_scores_history` - 7 pillar scores
4. `patient_wellpath_scores_history` - Overall WellPath score

### How It Gets Populated
**NOT automatic** - must be manually triggered:

**Option 1 - Edge Function**:
```bash
# Call scoring function
POST /functions/v1/calculate-wellpath-score
{
  "patient_id": "uuid",
  "calculation_date": "2025-10-28"
}
```

**Option 2 - Batch Script**:
```bash
python scripts/run_complete_scoring_pipeline.py
```

**What the scoring pipeline does**:
1. Fetches latest biomarker/biometric readings
2. Matches values to optimal ranges → scores
3. Fetches survey responses
4. Matches responses to scoring rules → scores
5. Aggregates scores: Items → Components → Pillars → Overall
6. **Inserts into ALL 4 history tables** (no automatic rollup!)

**Today's work**: Generated 30 days of backdated scores for chart testing!

---

## Complete Example: User Logs Fruit

### Step 1: User Input
```
User: "I ate 4 servings of fruit today"
Mobile app POST: /patient_data_entries
```

### Step 2: Data Entry
```sql
INSERT INTO patient_data_entries (field_id, field_value)
VALUES ('fruit_servings', '4');
```

### Step 3: Instance Calculations
```
Edge function runs:
- Checks if fruit_servings triggers any calculations
- (In this case, no dependent calculations)
```

### Step 4: Aggregation
```
Batch job runs nightly:
- Calculates AVG fruit servings for last 30 days
- Updates aggregation_results_cache
```
```sql
UPDATE aggregation_results_cache
SET value = 3.8, data_point_count = 28
WHERE agg_metric_id = 'AGG_FRUIT_SERVINGS'
  AND period_type = 'monthly';
```

### Step 5: Display Metric
```
Mobile app queries:
SELECT * FROM display_metrics_aggregations
WHERE metric_id = 'DISP_DM_FRUIT'
→ Finds agg_metric_id = 'AGG_FRUIT_SERVINGS'
→ Fetches value from cache: 3.8 servings/day
```

### Step 6: Screen Display
```
Mobile app loads "Nutrition Detail" screen:
→ Queries display_screens_detail_display_metrics
→ Finds DISP_DM_FRUIT assigned to this screen
→ Renders chart showing 3.8 servings/day avg
```

### Step 7: Scoring (Separate)
```
Nightly scoring job runs:
→ Fetches patient fruit avg: 3.8
→ Compares to optimal range: 3-5 servings
→ Calculates score: 95/100
→ Inserts into patient_item_scores_history
```

---

## Current Gaps (As of 2025-10-28)

### ✅ COMPLETE
1. **Data Entry Fields**: All 215 fields defined
2. **Biometrics → Display Metrics**: 22/22 mapped (just completed!)
3. **Historical Scores**: 30 days of test data generated

### ❌ GAPS
1. **Display Metrics → Screens**: Only 16/45 primary screens have metrics
2. **Survey Aggregation Strategy**: 348 questions need aggregation approach
3. **Check-in Integration**: Need to design how check-ins fit in screens

---

## Next Steps

### Priority 1: Map Display Metrics to Screens
**Task**: Assign 202 display_metrics to 45 display_screens
**Files**: Use junction tables `display_screens_*_display_metrics`
**Impact**: Users will actually see their data in the app!

### Priority 2: Survey Aggregation
**Task**: Define aggregation strategy for 348 survey questions
**Challenge**: Some questions are standalone, some are part of functions
**Approach**: Create aggregation_metrics for survey groups

### Priority 3: Check-in Integration
**Task**: Determine where check-ins appear in app nav
**Decision**: Put check-ins on screens vs separate section?
**User's preference**: "check-ins should be part of screens"

---

## Automation Status

### What's Automatic
✅ Instance calculations (edge function after data entry)
✅ Apple Health sync (background job)

### What's Manual/Batch
❌ Aggregation calculations (run nightly or on-demand)
❌ Scoring pipeline (must be triggered)
❌ Display metric creation (one-time setup)
❌ Screen mapping (one-time setup)

### What Should Be Real-Time (Future)
- [ ] Aggregation updates after data entry
- [ ] Score recalculation after new data
- [ ] Dynamic effective response updates

---

## Key Insight: Snapshots vs Live Data

**Important**: Score history tables are **snapshots**, not live queries!

```
❌ WRONG: "Display latest score"
SELECT * FROM patient_wellpath_scores_history
WHERE patient_id = 'uuid'
ORDER BY calculated_at DESC LIMIT 1;

✅ CORRECT: "Calculate current score"
POST /functions/v1/calculate-wellpath-score
→ Runs full pipeline
→ Inserts new snapshot
→ Then query for latest
```

This is why my backdate script had to insert into all 4 tables - they're independent snapshots, not calculated views!

---

## Related Documentation
- `/Users/keegs/Documents/GitHub/WellPath-V2-Backend/docs/scoring/WELLPATH_SCORE_PIPELINE.md`
- `/Users/keegs/Documents/GitHub/WellPath-V2-Backend/EDGE_FUNCTION_DYNAMIC_SCORING.md`
- `/Users/keegs/Documents/GitHub/WellPath-V2-Backend/ITEM_CARDS_NAVIGATION_GUIDE.md`
