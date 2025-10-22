# Tracked Metrics Data Flow - Clean Architecture

## Current State vs Desired State

### ✅ What We Have (Good):
1. `data_entry_fields` - Input field definitions
2. `event_types` - Event categorization
3. `instance_calculations` - Per-event calculations
4. `aggregation_metrics` - Aggregation definitions
5. `display_metrics` - Display layer
6. `display_screens` - Screen organization

### ❌ What's Messy:
- `aggregation_metrics_biomarkers` - **WRONG**: Should link to display_metrics, not biomarkers
- Multiple mapping tables with unclear relationships
- Unclear flow from data_entry_fields → aggregation_metrics

---

## Correct Data Flow

**CORRECTED ARCHITECTURE:**

### Key Concept: Aggregation Metrics = Base Metric + Periods/Calculations

`aggregation_metrics` is just the BASE metric definition (e.g., "heart_rate", "meals")
- NOT separate entries for "avg_heart_rate_30d", "max_heart_rate_7d", etc.
- Those combinations are stored in `aggregation_metrics_periods`
- Display layer picks which combination to show

### Path 1: Event Components (multi-field instances)
```
┌─────────────────────┐
│ data_entry_fields   │  Event components (e.g., "vegetable_servings" in meal)
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ event_types         │  Categorize events (e.g., "meal")
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│instance_calculations│  Per-event math (e.g., daily_vegetable_total)
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ aggregation_metrics │  BASE metric: "vegetable_intake"
└──────────┬──────────┘
           │
           ▼
┌──────────────────────────┐
│aggregation_metrics_periods│  "vegetable_intake" + 30d + avg
└──────────┬───────────────┘  "vegetable_intake" + 7d + sum
           │                  "vegetable_intake" + 1d + count
           ▼
┌─────────────────────┐
│ display_metrics     │  Picks: "vegetable_intake" + 30d + avg
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ display_screens     │  Screen: "Nutrition"
└─────────────────────┘
```

### Path 2: Standalone Metrics (complete single-field items)
```
┌─────────────────────┐
│ data_entry_fields   │  Standalone: "heart_rate", "weight", "hrv"
└──────────┬──────────┘
           │  (SKIP event_types, instance_calculations)
           │
           ▼
┌─────────────────────┐
│ aggregation_metrics │  BASE metric: "heart_rate"
└──────────┬──────────┘
           │
           ▼
┌──────────────────────────┐
│aggregation_metrics_periods│  "heart_rate" + most_recent
└──────────┬───────────────┘  "heart_rate" + 7d + avg
           │                  "heart_rate" + 30d + max
           ▼
┌─────────────────────┐
│ display_metrics     │  Picks: "heart_rate" + most_recent
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ display_screens     │  Screen: "Vitals"
└─────────────────────┘
```

**KEY RULES**:
1. Every data_entry_field → creates 1 base aggregation_metric
2. Each aggregation_metric → can have multiple period/calculation combinations
3. display_metrics → picks specific period+calculation to show

---

## Table-by-Table Breakdown

### 1. data_entry_fields
**Purpose**: Define all possible user inputs

```
data_entry_fields:
- field_id: "vegetable_servings"
- display_name: "How many servings of vegetables?"
- field_type: "numeric"
- unit: "servings"
```

**Junction Tables**:
- ✅ `display_metrics_data_entry_fields` - Link to what displays in UI
- ❓ Do we need `event_type_fields`? (link fields to event types)

---

### 2. event_types
**Purpose**: Categorize data entry events

```
event_types:
- event_type_id: "meal"
- name: "Meal"
- category: "nutrition"
```

**What's Missing**:
- Need `event_type_fields` to link event types to their fields
- Example: "meal" event has fields: vegetables, protein, carbs, etc.

---

### 3. instance_calculations
**Purpose**: Calculate values for a single event instance

```
instance_calculations:
- calc_id: "total_calories"
- formula: "protein_grams * 4 + carb_grams * 4 + fat_grams * 9"
- depends_on_fields: ["protein_grams", "carb_grams", "fat_grams"]
```

**Junction Tables**:
- ✅ `display_metrics_instance_calculations` - Link to display
- ✅ `aggregation_metrics_dependencies` - Used in aggregations

---

### 4. aggregation_metrics
**Purpose**: Define the BASE metric to aggregate (NOT the period/calculation combo)

**IMPORTANT**: This is just the metric definition, like "heart_rate" or "vegetable_intake"
- NOT "avg_heart_rate_30d" - that's stored in `aggregation_metrics_periods`
- One base metric can have many period/calculation combinations

**Three Aggregation Patterns** (See [TRACKED_METRICS_THREE_PATTERNS.md](./TRACKED_METRICS_THREE_PATTERNS.md) for details):

**Pattern 1: Measurements** (continuous values)
```
dependency_type: "data_entry_field"
Example: heart_rate, weight, glucose
```

**Pattern 2: Events** (complex multi-field)
```
dependency_type: "instance_calculation"
Example: calorie_intake (from meal protein + carbs + fat)
```

**Pattern 3: Counters** (event frequency)
```
dependency_type: "event_type"
Example: meal_frequency (just counting occurrences)
```

**Junction Tables**:
- ✅ `display_metrics_aggregations` - Link agg metrics to display metrics
- ✅ `aggregation_metrics_dependencies` - What feeds this metric (field/calc/event_type)
- ✅ `aggregation_metrics_periods` - Period + calculation type combinations for this metric
- ✅ `biometrics_aggregation_metrics` - Links biometric names to their agg metrics

---

### 5. display_metrics
**Purpose**: What the user sees in the app + which aggregation period/calc to show

```
display_metrics:
- display_metric_id: "vegetable_intake_widget"
- display_name: "Vegetable Intake"
- pillar: "Healthful Nutrition"
- widget_type: "line_chart"
- aggregation_metric_id: "vegetable_intake" (links to base metric)
- period: "30d"
- calculation_type: "avg"
```

**Junction Tables**:
- ✅ `display_metrics_aggregations` - Links to base aggregation_metric + specifies period/calc
- ✅ `display_metrics_readings` - Actual calculated values for users
- ⚠️ `display_metrics_data_entry_fields` - **May be redundant** (should link via aggregation_metrics)
- ⚠️ `display_metrics_instance_calculations` - **May be redundant** (should link via aggregation_metrics)
- ✅ `display_metrics_survey_questions` - Survey questions (different scoring path)

---

### 6. display_screens
**Purpose**: Organize metrics into app screens

```
display_screens:
- screen_id: "nutrition_dashboard"
- name: "Nutrition"
- pillar: "Healthful Nutrition"
```

**What's Missing**:
- Need `display_screen_metrics` to link screens to metrics
- Set display order, featured status, etc.

---

## Architecture Status

### ✅ Tables That Already Exist (Correct!)
- `event_types_data_entry_fields` - Links event types to their input fields
- `display_screens_display_metrics` - Organizes metrics on screens
- `biometrics_aggregation_metrics` - Links biometric names to aggregation metrics
- `display_metrics_aggregations` - Links display to aggregation metrics
- `aggregation_metrics_periods` - Stores period + calculation combos
- `aggregation_metrics_dependencies` - Tracks what feeds into each metric

### ⚠️ Tables to Review
- `display_metrics_data_entry_fields` - **Likely redundant** (should go via aggregation_metrics)
- `display_metrics_instance_calculations` - **Likely redundant** (should go via aggregation_metrics)

### 🔄 Architecture Principle
**Single Path**: All tracked metrics flow through `aggregation_metrics` before reaching `display_metrics`
- Standalone fields: data_entry_fields → aggregation_metrics → display_metrics
- Event fields: data_entry_fields → event_types → instance_calculations → aggregation_metrics → display_metrics

**No direct links** from display_metrics to data_entry_fields or instance_calculations (redundant)

---

## Clean Data Flow Example

### Example: Vegetable Intake (Event-based metric)

```
1. User Input (data_entry_fields):
   - field_id: "vegetable_servings"
   - User enters: 5 servings at 12:30pm

2. Event Type (event_types):
   - event_type_id: "meal"
   - Links to field via event_types_data_entry_fields

3. Instance Calculation (instance_calculations):
   - calc_id: "daily_vegetable_total"
   - SUM of all vegetable_servings entries per day

4. Aggregation Metric - BASE (aggregation_metrics):
   - id: uuid
   - metric_name: "vegetable_intake"
   - source_type: "instance_calculation"
   - source_id: <daily_vegetable_total calc_id>

5. Aggregation Periods (aggregation_metrics_periods):
   - vegetable_intake + 30d + avg
   - vegetable_intake + 7d + sum
   - vegetable_intake + 1d + last

6. Display Metric (display_metrics):
   - display_metric_id: "vegetable_intake_widget"
   - display_name: "Vegetable Intake"
   - Links to aggregation_metric "vegetable_intake"
   - Configured to show: 30d + avg
   - Widget type: line_chart

7. Display Screen (display_screens):
   - screen_id: "nutrition_dashboard"
   - Links to display metric via display_screens_display_metrics

8. User Sees:
   - Nutrition screen → "Vegetable Intake" widget → Line chart showing 30-day average trend
```

### Example: Heart Rate (Standalone metric)

```
1. User Input (data_entry_fields):
   - field_id: "heart_rate"
   - User enters: 72 bpm (or synced from Apple Health)

2. Aggregation Metric - BASE (aggregation_metrics):
   - id: uuid
   - metric_name: "heart_rate"
   - source_type: "data_entry_field"
   - source_id: <heart_rate field_id>

3. Aggregation Periods (aggregation_metrics_periods):
   - heart_rate + most_recent
   - heart_rate + 7d + avg
   - heart_rate + 30d + max

4. Display Metric (display_metrics):
   - display_metric_id: "heart_rate_current"
   - display_name: "Heart Rate"
   - Links to aggregation_metric "heart_rate"
   - Configured to show: most_recent
   - Widget type: gauge

5. Display Screen (display_screens):
   - screen_id: "vitals_dashboard"
   - Links to display metric via display_screens_display_metrics

6. User Sees:
   - Vitals screen → "Heart Rate" widget → Gauge showing current value (72 bpm)
```

---

## Summary of Relationships

### Linear Flow (One Direction):
```
data_entry_fields → aggregation_metrics → aggregation_metrics_periods → display_metrics → display_screens
        ↓                                                                        ↑
  event_types → instance_calculations ──────────────────────────────────────────┘
```

### Junction Tables (Many-to-Many):
- `event_types_data_entry_fields` - Which fields appear in which event types
- `aggregation_metrics_dependencies` - What feeds each aggregation metric (field OR calc)
- `biometrics_aggregation_metrics` - Links biometric names to their metrics
- `display_metrics_aggregations` - Which aggregation metric each display shows
- `display_screens_display_metrics` - Which displays appear on which screens
- `display_metrics_survey_questions` - Survey questions (separate scoring path)

### Redundant Tables (To Remove):
- `display_metrics_data_entry_fields` - ❌ Should go via aggregation_metrics
- `display_metrics_instance_calculations` - ❌ Should go via aggregation_metrics

---

## Next Steps

1. ✅ **Document** correct architecture (DONE!)
2. 🔍 **Verify** existing data follows this pattern
3. ⚠️ **Evaluate** whether to remove redundant junction tables
4. 🔧 **Ensure** every data_entry_field has a corresponding aggregation_metric
5. 🔧 **Create** aggregation worker to populate aggregation_metrics_periods
6. 🔧 **Integrate** tracked metrics into WellPath scoring
7. ⚠️ **Test** end-to-end flow with real data

---

*Last Updated: 2025-10-18*
