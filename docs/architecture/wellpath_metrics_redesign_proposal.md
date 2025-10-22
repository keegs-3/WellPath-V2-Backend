# WellPath Metrics System Redesign Proposal
## Architectural Overhaul with Data Preservation

**Date**: October 10, 2025  
**Status**: PROPOSAL - For Review  
**Impact**: High - Complete metrics architecture redesign  

---

## Executive Summary

Your current system conflates three distinct concepts:
1. **Data Entry Fields** (start_time, end_time)
2. **Calculated Metrics** (active_time = end - start)  
3. **Aggregated Metrics** (daily_active_time = SUM of sessions)

This proposal creates a clean separation using new tables while preserving all existing data in `metric_types_vfinal` and `calculated_metrics_vfinal`.

---

## Current State Analysis

### Problems Identified

**metric_types_vfinal Issues:**
- Mixing atomic inputs (time fields) with display concepts (active_time)
- No clear distinction between what users enter vs. what system calculates
- Difficult to understand data flow from entry to aggregation

**calculated_metrics_vfinal Issues:**
- Contains both event-level calculations AND daily aggregations
- Unclear dependency chains (what depends on what)
- Hard to add new derived metrics without confusion

### What We Keep

**DO NOT DELETE:**
- `metric_types_vfinal` - Archive as historical reference
- `calculated_metrics_vfinal` - Archive as historical reference
- All existing data and relationships

---

## Proposed New Architecture

### Core Philosophy

```
USER ENTERS → EVENTS/SESSIONS → INSTANCE CALCULATIONS → DAILY AGGREGATIONS → DISPLAY METRICS
```

Clear separation of:
1. What users physically input
2. How we calculate individual instances
3. How we aggregate across time periods
4. What we show in dashboards

---

## New Table Structures

### Table 1: `data_entry_fields`
**Purpose**: Atomic user inputs - the raw data points users actually enter

```
Fields:
- field_id (Primary, Text): "DEF_001"
- field_name (Text): "activity_start_time"
- field_type (Single Select): 
  * timestamp
  * duration
  * quantity
  * category
  * boolean
- display_name (Text): "When did you start?"
- data_type (Single Select): datetime, number, text, boolean
- validation_rules (Long Text, JSON):
  {
    "required": true,
    "format": "HH:MM",
    "min": null,
    "max": null
  }
- unit (Link to units_v3): For quantities only
- input_method (Single Select): manual, healthkit, wearable, calculated
- used_in_events (Link to event_types): Which event types use this field
- description (Long Text): "The time the activity began"
- is_active (Checkbox): true/false
- created_date (Date)
- modified_date (Date)
```

**Example Records:**
```
field_id: DEF_001
field_name: activity_start_time
field_type: timestamp
display_name: Start Time
data_type: datetime
validation_rules: {"required": true, "format": "HH:MM"}
input_method: manual

field_id: DEF_002
field_name: activity_end_time
field_type: timestamp
display_name: End Time
data_type: datetime
validation_rules: {"required": true, "format": "HH:MM"}
input_method: manual

field_id: DEF_003
field_name: activity_type
field_type: category
display_name: Activity Type
data_type: text
validation_rules: {"allowed_values": ["exercise", "work", "leisure"]}
input_method: manual
```

---

### Table 2: `event_types`
**Purpose**: Define trackable events/sessions that users log

```
Fields:
- event_type_id (Primary, Text): "EVT_001"
- event_name (Text): "Physical Activity Session"
- event_category (Single Select): activity, nutrition, sleep, social, health_measurement
- description (Long Text): "A discrete period of physical activity"
- required_fields (Link to data_entry_fields): Links to DEF_001, DEF_002, DEF_003
- optional_fields (Link to data_entry_fields): Additional contextual fields
- instance_calculations (Long Text, JSON):
  [
    {
      "calc_id": "IC_001",
      "name": "session_duration",
      "formula": "end_time - start_time",
      "unit": "minutes",
      "depends_on": ["activity_start_time", "activity_end_time"]
    }
  ]
- display_template (Long Text): "You were active for {duration} minutes"
- icon (Text): emoji or icon name
- color (Text): hex code
- is_active (Checkbox)
- allows_multiple_per_day (Checkbox): true
- created_date (Date)
- modified_date (Date)
```

**Example Record:**
```
event_type_id: EVT_001
event_name: Physical Activity Session
event_category: activity
description: A discrete period of physical activity with start/end times
required_fields: [DEF_001 (start_time), DEF_002 (end_time)]
optional_fields: [DEF_003 (activity_type), DEF_015 (intensity_level)]
instance_calculations: [
  {
    "calc_id": "IC_001",
    "name": "session_duration",
    "formula": "end_time - start_time",
    "unit": "minutes"
  }
]
allows_multiple_per_day: true
```

---

### Table 3: `instance_calculations`
**Purpose**: Calculations that happen per individual event/session

```
Fields:
- calc_id (Primary, Text): "IC_001"
- calc_name (Text): "session_duration"
- display_name (Text): "Duration"
- parent_event_type (Link to event_types): Which event this calculates for
- calculation_method (Single Select):
  * difference (time)
  * difference (numeric)
  * sum
  * average
  * ratio
  * formula
  * lookup
- formula_definition (Long Text, JSON):
  {
    "method": "difference",
    "field_end": "activity_end_time",
    "field_start": "activity_start_time",
    "output_unit": "minutes"
  }
- depends_on_fields (Link to data_entry_fields): Which fields are needed
- output_unit (Link to units_v3)
- output_data_type (Single Select): number, duration, boolean, text
- is_displayed_to_user (Checkbox): Show in event summary?
- validation_rules (Long Text, JSON):
  {
    "min_value": 0,
    "max_value": 1440,
    "must_be_positive": true
  }
- description (Long Text)
- is_active (Checkbox)
- created_date (Date)
```

**Example Records:**
```
calc_id: IC_001
calc_name: session_duration
display_name: Session Duration
parent_event_type: EVT_001 (Activity Session)
calculation_method: difference
formula_definition: {
  "method": "difference",
  "field_end": "activity_end_time",
  "field_start": "activity_start_time",
  "output_unit": "minutes"
}
depends_on_fields: [DEF_001, DEF_002]
output_unit: minute
is_displayed_to_user: true

calc_id: IC_002
calc_name: eating_window_duration
display_name: Eating Window
parent_event_type: EVT_005 (Eating Window Event)
calculation_method: difference
formula_definition: {
  "method": "difference",
  "field_end": "last_meal_time",
  "field_start": "first_meal_time",
  "output_unit": "hours"
}
output_unit: hour
is_displayed_to_user: true
```

---

### Table 4: `aggregation_metrics`
**Purpose**: How we roll up events/calculations across time periods

```
Fields:
- agg_metric_id (Primary, Text): "AGG_001"
- metric_name (Text): "daily_active_time"
- display_name (Text): "Daily Active Time"
- description (Long Text): "Total minutes of physical activity per day"
- aggregation_period (Single Select):
  * daily
  * weekly
  * monthly
  * rolling_7_day
  * rolling_30_day
- source_type (Single Select):
  * instance_calculation
  * data_entry_field
  * other_aggregation_metric
- source_reference (Long Text): Which calc/field/metric to aggregate
  {
    "source_id": "IC_001",
    "source_name": "session_duration"
  }
- aggregation_method (Single Select):
  * sum
  * average
  * count
  * max
  * min
  * median
  * standard_deviation
  * consistency_score
- calculation_details (Long Text, JSON):
  {
    "method": "sum",
    "source": "IC_001",
    "filter": {
      "event_type": "EVT_001"
    },
    "grouping": "daily"
  }
- output_unit (Link to units_v3)
- target_value (Number): Optional target for this metric
- target_range_min (Number)
- target_range_max (Number)
- display_category (Single Select): activity, nutrition, sleep, etc.
- pillar (Link to pillars table)
- is_displayed_in_dashboard (Checkbox)
- display_order (Number)
- chart_type (Single Select): line, bar, gauge, trend, heatmap
- is_active (Checkbox)
- created_date (Date)
```

**Example Records:**
```
agg_metric_id: AGG_001
metric_name: daily_active_time
display_name: Daily Active Time
description: Total minutes of physical activity across all sessions each day
aggregation_period: daily
source_type: instance_calculation
source_reference: {"source_id": "IC_001", "source_name": "session_duration"}
aggregation_method: sum
calculation_details: {
  "method": "sum",
  "source": "IC_001",
  "filter": {"event_type": "EVT_001"},
  "grouping": "daily"
}
output_unit: minute
target_value: 30
display_category: activity
is_displayed_in_dashboard: true

agg_metric_id: AGG_002
metric_name: weekly_activity_consistency
display_name: Weekly Activity Consistency
description: Standard deviation of daily active minutes over rolling 7 days
aggregation_period: rolling_7_day
source_type: other_aggregation_metric
source_reference: {"source_id": "AGG_001", "source_name": "daily_active_time"}
aggregation_method: consistency_score
calculation_details: {
  "method": "coefficient_of_variation",
  "source": "AGG_001",
  "window": "7_days",
  "lower_is_better": true
}
output_unit: score
is_displayed_in_dashboard: true
```

---

### Table 5: `display_metrics`
**Purpose**: Final presentation layer for dashboards and reports

```
Fields:
- display_metric_id (Primary, Text): "DM_001"
- display_name (Text): "Active Time This Week"
- metric_description (Long Text): User-facing description
- source_aggregation (Link to aggregation_metrics): Which aggregation feeds this
- display_type (Single Select):
  * current_value
  * trend_line
  * comparison
  * progress_bar
  * gauge
  * heatmap
  * streak_counter
- display_format (Long Text, JSON):
  {
    "value_format": "##.# minutes",
    "comparison": "vs_last_week",
    "show_trend_arrow": true,
    "color_coding": {
      "above_target": "green",
      "near_target": "yellow",
      "below_target": "red"
    }
  }
- dashboard_section (Single Select): overview, activity, nutrition, sleep, etc.
- display_priority (Number): 1-100, higher = more prominent
- show_in_mobile (Checkbox)
- show_in_web (Checkbox)
- requires_minimum_data_points (Number): Don't show until X data points exist
- is_active (Checkbox)
- created_date (Date)
```

**Example Record:**
```
display_metric_id: DM_001
display_name: Your Active Time Today
metric_description: Total minutes of physical activity logged today
source_aggregation: AGG_001 (daily_active_time)
display_type: progress_bar
display_format: {
  "value_format": "## minutes",
  "target": 30,
  "show_percentage": true,
  "color_coding": {
    "0-10": "red",
    "11-25": "yellow",
    "26+": "green"
  }
}
dashboard_section: overview
display_priority: 10
show_in_mobile: true
requires_minimum_data_points: 1
```

---

## Migration Examples

### Example 1: Active Time
**Current Confused State:**
- metric_types_vfinal: start_time, end_time (data entry)
- calculated_metrics_vfinal: active_time (shown as metric, but actually calculated)

**New Clean State:**

1. **data_entry_fields**:
   - DEF_001: activity_start_time (what user enters)
   - DEF_002: activity_end_time (what user enters)

2. **event_types**:
   - EVT_001: Physical Activity Session (uses DEF_001 and DEF_002)

3. **instance_calculations**:
   - IC_001: session_duration = end_time - start_time (per session)

4. **aggregation_metrics**:
   - AGG_001: daily_active_time = SUM(session_duration) grouped by day
   - AGG_002: weekly_active_time = SUM(daily_active_time) over 7 days

5. **display_metrics**:
   - DM_001: "Your Active Time Today" (shows AGG_001)
   - DM_002: "Active Time This Week" (shows AGG_002)
   - DM_003: "Activity Consistency Score" (uses AGG_001 with consistency calculation)

---

### Example 2: Eating Window
**Current State:**
- metric_types_vfinal: first_meal_time, last_meal_time
- calculated_metrics_vfinal: eating_window_duration

**New State:**

1. **data_entry_fields**:
   - DEF_010: first_meal_time
   - DEF_011: last_meal_time

2. **event_types**:
   - EVT_005: Daily Eating Window

3. **instance_calculations**:
   - IC_002: eating_window_duration = last_meal_time - first_meal_time

4. **aggregation_metrics**:
   - AGG_010: daily_eating_window = IC_002 (just pass through, one per day)
   - AGG_011: avg_weekly_eating_window = AVERAGE(daily_eating_window) over 7 days
   - AGG_012: eating_window_consistency = STDEV(daily_eating_window) over 7 days

5. **display_metrics**:
   - DM_010: "Today's Eating Window"
   - DM_011: "Weekly Eating Window Average"

---

### Example 3: Sleep Duration
**Current State:**
- metric_types_vfinal: sleep_start_time, wake_time
- calculated_metrics_vfinal: sleep_duration

**New State:**

1. **data_entry_fields**:
   - DEF_020: sleep_start_time
   - DEF_021: wake_time

2. **event_types**:
   - EVT_010: Sleep Session

3. **instance_calculations**:
   - IC_010: sleep_duration = wake_time - sleep_start_time (handles cross-midnight)

4. **aggregation_metrics**:
   - AGG_020: nightly_sleep_duration = IC_010 (one per night)
   - AGG_021: avg_weekly_sleep = AVERAGE(nightly_sleep_duration) over 7 nights
   - AGG_022: sleep_consistency_score = based on STDEV over 7 nights

5. **display_metrics**:
   - DM_020: "Last Night's Sleep"
   - DM_021: "Your Sleep This Week"
   - DM_022: "Sleep Consistency"

---

## Key Benefits of New Structure

### For Users
- **Clear Understanding**: "Active Time" shows total, but they know they log sessions with start/end
- **Flexible Tracking**: Can log multiple sessions per day
- **Better Insights**: See both total time AND consistency metrics
- **Retroactive Entry**: Can manually add past sessions

### For Developers
- **Type Safety**: Clear data types at each layer
- **Easy to Extend**: Add new events without touching existing calculations
- **Debugging**: Can trace from display metric back through aggregation to source events
- **Testable**: Each layer can be unit tested independently

### For System
- **Scalable**: Adding new metrics doesn't require schema changes
- **Maintainable**: Clear separation of concerns
- **Performant**: Can optimize queries at each layer
- **Flexible**: Can change display without touching data collection

---

## Implementation Strategy

### Phase 1: Create New Tables (Week 1)
- [ ] Create all 5 new tables in Airtable
- [ ] Set up relationships between tables
- [ ] Create example records for documentation

### Phase 2: Dual-Track Migration (Weeks 2-4)
- [ ] Map existing metric_types_vfinal to data_entry_fields
- [ ] Map existing calculated_metrics_vfinal to instance_calculations and aggregation_metrics
- [ ] Create migration scripts to populate new tables from old
- [ ] Run both systems in parallel for testing

### Phase 3: Application Updates (Weeks 5-8)
- [ ] Update data entry flows to use event_types
- [ ] Update calculation engine to use new table structures
- [ ] Update dashboard to use display_metrics
- [ ] Extensive testing with real user data

### Phase 4: Deprecation (Week 9+)
- [ ] Mark old tables as deprecated (DO NOT DELETE)
- [ ] Route all new data through new system
- [ ] Monitor for issues
- [ ] Archive old tables once confident

---

## Data Preservation Strategy

**OLD TABLES (Keep Forever):**
- `metric_types_vfinal` - Rename to `metric_types_vfinal_ARCHIVE_2025`
- `calculated_metrics_vfinal` - Rename to `calculated_metrics_vfinal_ARCHIVE_2025`

**MIGRATION LOG TABLE:**
Create `migration_log` to track what was moved where:
```
- old_table (Text)
- old_record_id (Text)
- new_table (Text)
- new_record_id (Text)
- migration_date (Date)
- migration_notes (Long Text)
```

---

## Rollback Plan

If things go wrong:
1. New tables are additive, so old system still intact
2. Can flip feature flag to route back to old tables
3. No data loss because we never delete old tables
4. Maximum 24 hours to rollback

---

## Questions for Discussion

1. **Naming**: Do these table names make sense to your team?
2. **Relationships**: Are there other relationships we need between tables?
3. **Timeline**: Is 9 weeks realistic for your team size?
4. **Priority**: Which metrics should we migrate first? (Suggest: active_time, eating_window, sleep_duration)
5. **Integrations**: What external systems (HealthKit, wearables) need to be updated?

---

## Next Steps

1. **Review this proposal** with your team
2. **Prioritize questions** above
3. **Create detailed spec** for Phase 1 (new table creation)
4. **I can help build**:
   - Migration scripts
   - Example records for all 5 tables
   - Data validation rules
   - API endpoints for new structure

---

## Appendix: Complete Field Mapping

### Physical Activity Example

**OLD SYSTEM:**
```
metric_types_vfinal:
- TM_START_TIME: activity start (data entry)
- TM_END_TIME: activity end (data entry)

calculated_metrics_vfinal:
- CALC_ACTIVE_TIME: shown as "metric" but actually calculated
```

**NEW SYSTEM:**
```
data_entry_fields:
- DEF_001: activity_start_time (atomic input)
- DEF_002: activity_end_time (atomic input)
- DEF_003: activity_type (optional context)

event_types:
- EVT_001: Physical Activity Session
  * uses DEF_001, DEF_002, DEF_003
  * allows_multiple_per_day: true

instance_calculations:
- IC_001: session_duration
  * formula: DEF_002 - DEF_001
  * unit: minutes
  * shown to user after each session

aggregation_metrics:
- AGG_001: daily_active_time
  * SUM(IC_001) grouped by date
  * target: 30 minutes
  
- AGG_002: weekly_active_time
  * SUM(AGG_001) over rolling 7 days
  * target: 210 minutes

- AGG_003: activity_sessions_count
  * COUNT(EVT_001) per day
  * tracks frequency, not duration

- AGG_004: activity_consistency_score
  * STDEV(AGG_001) over 7 days
  * lower = more consistent

display_metrics:
- DM_001: "Active Minutes Today"
  * source: AGG_001
  * format: progress_bar with target
  * color_coded

- DM_002: "This Week's Activity"
  * source: AGG_002
  * format: trend_line chart
  * comparison to last week

- DM_003: "Activity Streak"
  * source: AGG_003
  * format: streak_counter
  * days with at least one session
```

---

**END OF PROPOSAL**

This is a complete architectural redesign that maintains all your existing data while creating a much cleaner, more maintainable system going forward. The new structure makes the data flow crystal clear: user input → events → calculations → aggregations → display.

Ready to discuss and refine?
