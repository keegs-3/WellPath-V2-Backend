# Airtable Setup Guide: New 5-Table Metrics Architecture

**Date**: October 10, 2025
**Purpose**: Step-by-step guide to create the new metrics tables in Airtable

---

## Overview

You'll create 5 new tables in your Airtable base:
1. `data_entry_fields` - What users physically type/select
2. `event_types` - How we group fields into trackable events
3. `instance_calculations` - Math per individual event
4. `aggregation_metrics` - Math across time periods
5. `display_metrics` - Final UI presentation

---

## Setup Instructions

### Step 1: Create Base Structure

1. Open your Airtable base
2. Create 5 new tables (don't delete old ones!)
3. Name them exactly:
   - `data_entry_fields`
   - `event_types`
   - `instance_calculations`
   - `aggregation_metrics`
   - `display_metrics`

---

## Table 1: `data_entry_fields`

### Fields to Create

| Field Name | Type | Options/Config |
|------------|------|----------------|
| `field_id` | Single line text | PRIMARY KEY - Format: "DEF_001" |
| `field_name` | Single line text | e.g., "activity_start_time" |
| `field_type` | Single select | Options: timestamp, duration, quantity, category, boolean |
| `display_name` | Single line text | User-facing name |
| `data_type` | Single select | Options: datetime, number, text, boolean |
| `validation_rules` | Long text | JSON format |
| `unit` | Link to another record | Link to `units_v3` table |
| `input_method` | Single select | Options: manual, healthkit, wearable, calculated |
| `used_in_events` | Link to another record | Link to `event_types` (allow multiple) |
| `description` | Long text | |
| `is_active` | Checkbox | |
| `created_date` | Created time | |
| `modified_date` | Last modified time | |

### Example Records (Copy/Paste into Airtable)

```
field_id,field_name,field_type,display_name,data_type,validation_rules,input_method,description,is_active
DEF_001,activity_start_time,timestamp,Start Time,datetime,"{""required"": true, ""format"": ""HH:MM""}",manual,The time the activity session began,TRUE
DEF_002,activity_end_time,timestamp,End Time,datetime,"{""required"": true, ""format"": ""HH:MM""}",manual,The time the activity session ended,TRUE
DEF_003,activity_type,category,Activity Type,text,"{""allowed_values"": [""exercise"", ""work"", ""leisure""]}",manual,Type of activity performed,TRUE
DEF_010,first_meal_time,timestamp,First Meal,datetime,"{""required"": true, ""format"": ""HH:MM""}",manual,Time of first meal/calorie intake,TRUE
DEF_011,last_meal_time,timestamp,Last Meal,datetime,"{""required"": true, ""format"": ""HH:MM""}",manual,Time of last meal/calorie intake,TRUE
DEF_020,sleep_start_time,timestamp,Bedtime,datetime,"{""required"": true, ""format"": ""HH:MM""}",healthkit,Time went to bed,TRUE
DEF_021,wake_time,timestamp,Wake Time,datetime,"{""required"": true, ""format"": ""HH:MM""}",healthkit,Time woke up,TRUE
```

---

## Table 2: `event_types`

### Fields to Create

| Field Name | Type | Options/Config |
|------------|------|----------------|
| `event_type_id` | Single line text | PRIMARY KEY - Format: "EVT_001" |
| `event_name` | Single line text | |
| `event_category` | Single select | Options: activity, nutrition, sleep, social, health_measurement |
| `description` | Long text | |
| `required_fields` | Link to another record | Link to `data_entry_fields` (allow multiple) |
| `optional_fields` | Link to another record | Link to `data_entry_fields` (allow multiple) |
| `instance_calculations` | Long text | JSON array |
| `display_template` | Single line text | |
| `icon` | Single line text | Emoji or icon name |
| `color` | Single line text | Hex code |
| `is_active` | Checkbox | |
| `allows_multiple_per_day` | Checkbox | |
| `created_date` | Created time | |
| `modified_date` | Last modified time | |

### Example Records

```
event_type_id,event_name,event_category,description,instance_calculations,display_template,icon,color,is_active,allows_multiple_per_day
EVT_001,Physical Activity Session,activity,A discrete period of physical activity with start/end times,"[{""calc_id"": ""IC_001"", ""name"": ""session_duration"", ""formula"": ""end_time - start_time"", ""unit"": ""minutes""}]",You were active for {duration} minutes,🏃,#4CAF50,TRUE,TRUE
EVT_005,Daily Eating Window,nutrition,The window between first and last calorie intake,"[{""calc_id"": ""IC_002"", ""name"": ""eating_window_duration"", ""formula"": ""last_meal_time - first_meal_time"", ""unit"": ""hours""}]",Your eating window was {duration} hours,🍽️,#FF9800,TRUE,FALSE
EVT_010,Sleep Session,sleep,Nightly sleep period from bedtime to wake,"[{""calc_id"": ""IC_010"", ""name"": ""sleep_duration"", ""formula"": ""wake_time - sleep_start_time"", ""unit"": ""hours""}]",You slept {duration} hours,😴,#9C27B0,TRUE,FALSE
```

**After importing**: Manually link the required_fields:
- EVT_001 → required_fields: DEF_001, DEF_002
- EVT_005 → required_fields: DEF_010, DEF_011
- EVT_010 → required_fields: DEF_020, DEF_021

---

## Table 3: `instance_calculations`

### Fields to Create

| Field Name | Type | Options/Config |
|------------|------|----------------|
| `calc_id` | Single line text | PRIMARY KEY - Format: "IC_001" |
| `calc_name` | Single line text | |
| `display_name` | Single line text | |
| `parent_event_type` | Link to another record | Link to `event_types` (single) |
| `calculation_method` | Single select | Options: difference, sum, average, ratio, formula, lookup |
| `formula_definition` | Long text | JSON |
| `depends_on_fields` | Link to another record | Link to `data_entry_fields` (allow multiple) |
| `output_unit` | Link to another record | Link to `units_v3` |
| `output_data_type` | Single select | Options: number, duration, boolean, text |
| `is_displayed_to_user` | Checkbox | Show after event entry? |
| `validation_rules` | Long text | JSON |
| `description` | Long text | |
| `is_active` | Checkbox | |
| `created_date` | Created time | |

### Example Records

```
calc_id,calc_name,display_name,calculation_method,formula_definition,output_data_type,is_displayed_to_user,description,is_active
IC_001,session_duration,Session Duration,difference,"{""method"": ""difference"", ""field_end"": ""activity_end_time"", ""field_start"": ""activity_start_time"", ""output_unit"": ""minutes""}",number,TRUE,Duration of a single activity session,TRUE
IC_002,eating_window_duration,Eating Window,difference,"{""method"": ""difference"", ""field_end"": ""last_meal_time"", ""field_start"": ""first_meal_time"", ""output_unit"": ""hours""}",number,TRUE,Daily eating window duration,TRUE
IC_010,sleep_duration,Sleep Duration,difference,"{""method"": ""difference"", ""field_end"": ""wake_time"", ""field_start"": ""sleep_start_time"", ""output_unit"": ""hours"", ""handles_midnight"": true}",number,TRUE,Nightly sleep duration,TRUE
```

**After importing**: Manually link:
- IC_001 → parent_event_type: EVT_001, depends_on_fields: DEF_001, DEF_002
- IC_002 → parent_event_type: EVT_005, depends_on_fields: DEF_010, DEF_011
- IC_010 → parent_event_type: EVT_010, depends_on_fields: DEF_020, DEF_021

---

## Table 4: `aggregation_metrics`

### Fields to Create

| Field Name | Type | Options/Config |
|------------|------|----------------|
| `agg_metric_id` | Single line text | PRIMARY KEY - Format: "AGG_001" |
| `metric_name` | Single line text | |
| `display_name` | Single line text | |
| `description` | Long text | |
| `aggregation_period` | Single select | Options: daily, weekly, monthly, rolling_7_day, rolling_30_day |
| `source_type` | Single select | Options: instance_calculation, data_entry_field, other_aggregation_metric |
| `source_reference` | Long text | JSON with source_id and source_name |
| `aggregation_method` | Single select | Options: sum, average, count, max, min, median, stdev, consistency_score |
| `calculation_details` | Long text | JSON |
| `output_unit` | Link to another record | Link to `units_v3` |
| `target_value` | Number | |
| `target_range_min` | Number | |
| `target_range_max` | Number | |
| `display_category` | Single select | Options: activity, nutrition, sleep, stress, social, health |
| `pillar` | Link to another record | Link to `pillars` |
| `is_displayed_in_dashboard` | Checkbox | |
| `display_order` | Number | |
| `chart_type` | Single select | Options: line, bar, gauge, trend, heatmap |
| `is_active` | Checkbox | |
| `created_date` | Created time | |

### Example Records

```
agg_metric_id,metric_name,display_name,description,aggregation_period,source_type,source_reference,aggregation_method,calculation_details,target_value,display_category,is_displayed_in_dashboard,chart_type,is_active
AGG_001,daily_active_time,Daily Active Time,Total minutes of physical activity across all sessions each day,daily,instance_calculation,"{""source_id"": ""IC_001"", ""source_name"": ""session_duration""}",sum,"{""method"": ""sum"", ""source"": ""IC_001"", ""filter"": {""event_type"": ""EVT_001""}, ""grouping"": ""daily""}",30,activity,TRUE,line,TRUE
AGG_002,weekly_active_time,Weekly Active Time,Rolling 7-day total of active time,rolling_7_day,other_aggregation_metric,"{""source_id"": ""AGG_001"", ""source_name"": ""daily_active_time""}",sum,"{""method"": ""sum"", ""source"": ""AGG_001"", ""window"": ""7_days""}",210,activity,TRUE,bar,TRUE
AGG_003,activity_sessions_count,Activity Session Count,Number of activity sessions per day,daily,instance_calculation,"{""source_id"": ""IC_001""}",count,"{""method"": ""count"", ""source"": ""EVT_001"", ""grouping"": ""daily""}",1,activity,TRUE,gauge,TRUE
AGG_010,daily_eating_window,Today's Eating Window,Daily eating window duration,daily,instance_calculation,"{""source_id"": ""IC_002"", ""source_name"": ""eating_window_duration""}",average,"{""method"": ""pass_through"", ""source"": ""IC_002""}",10,nutrition,TRUE,gauge,TRUE
AGG_020,nightly_sleep_duration,Sleep Duration,Nightly sleep duration,daily,instance_calculation,"{""source_id"": ""IC_010"", ""source_name"": ""sleep_duration""}",average,"{""method"": ""pass_through"", ""source"": ""IC_010""}",8,sleep,TRUE,line,TRUE
```

---

## Table 5: `display_metrics`

### Fields to Create

| Field Name | Type | Options/Config |
|------------|------|----------------|
| `display_metric_id` | Single line text | PRIMARY KEY - Format: "DM_001" |
| `display_name` | Single line text | |
| `metric_description` | Long text | User-facing description |
| `source_aggregation` | Link to another record | Link to `aggregation_metrics` (single) |
| `display_type` | Single select | Options: current_value, trend_line, comparison, progress_bar, gauge, heatmap, streak_counter |
| `display_format` | Long text | JSON |
| `dashboard_section` | Single select | Options: overview, activity, nutrition, sleep, stress, social, health |
| `display_priority` | Number | 1-100, higher = more prominent |
| `show_in_mobile` | Checkbox | |
| `show_in_web` | Checkbox | |
| `requires_minimum_data_points` | Number | |
| `is_active` | Checkbox | |
| `created_date` | Created time | |

### Example Records

```
display_metric_id,display_name,metric_description,display_type,display_format,dashboard_section,display_priority,show_in_mobile,show_in_web,requires_minimum_data_points,is_active
DM_001,Active Time Today,Total minutes of physical activity logged today,progress_bar,"{""value_format"": ""## minutes"", ""target"": 30, ""show_percentage"": true, ""color_coding"": {""0-10"": ""red"", ""11-25"": ""yellow"", ""26+"": ""green""}}",overview,10,TRUE,TRUE,1,TRUE
DM_002,This Week's Activity,Your activity trend over the past 7 days,trend_line,"{""value_format"": ""## minutes"", ""comparison"": ""vs_last_week"", ""show_trend_arrow"": true}",activity,8,TRUE,TRUE,2,TRUE
DM_003,Activity Sessions,Number of activity sessions today,current_value,"{""value_format"": ""# sessions"", ""icon"": ""🏃""}",activity,7,TRUE,TRUE,1,TRUE
DM_010,Today's Eating Window,Your eating window duration today,gauge,"{""value_format"": ""##.# hours"", ""target"": 10, ""min"": 8, ""max"": 12}",nutrition,9,TRUE,TRUE,1,TRUE
DM_020,Sleep Last Night,How much sleep you got last night,progress_bar,"{""value_format"": ""##.# hours"", ""target"": 8, ""show_percentage"": true}",sleep,10,TRUE,TRUE,1,TRUE
```

**After importing**: Manually link source_aggregation:
- DM_001 → AGG_001
- DM_002 → AGG_002
- DM_003 → AGG_003
- DM_010 → AGG_010
- DM_020 → AGG_020

---

## Post-Import Steps

### 1. Set up relationships between tables

After importing all CSVs, you'll need to manually link records:

**data_entry_fields → event_types**:
- Go to each event_types record
- Click on `required_fields` and select the appropriate DEF records

**event_types → instance_calculations**:
- Go to each instance_calculations record
- Set `parent_event_type` to the appropriate EVT record

**instance_calculations → aggregation_metrics**:
- Already handled via source_reference JSON field
- No manual linking needed

**aggregation_metrics → display_metrics**:
- Go to each display_metrics record
- Set `source_aggregation` to the appropriate AGG record

### 2. Archive old tables

**DO NOT DELETE!** Instead:
1. Rename `metric_types_vfinal` → `metric_types_vfinal_ARCHIVE_2025`
2. Rename `calculated_metrics_vfinal` → `calculated_metrics_vfinal_ARCHIVE_2025`
3. Add a note field explaining they're archived

### 3. Test the structure

Create test records to verify the flow:
1. Add a data_entry_fields record
2. Create an event_types that uses it
3. Define an instance_calculation for that event
4. Set up an aggregation_metric
5. Create a display_metric to show it

---

## CSV Import Files Location

All CSV files for import are saved in:
`/Users/keegs/Documents/GitHub/WellPath-V2-Backend/docs/architecture/airtable_import_csvs/`

---

## Questions or Issues?

Refer back to:
- `wellpath_metrics_redesign_proposal.md` - Full architectural spec
- `data_flow_visualization.md` - Visual examples of data flow

---

**Next Steps After Setup**:
1. Build migration scripts to populate from old tables
2. Update backend API to read from new structure
3. Update mobile app to use new data model
