# WellPath Metrics Data Flow Visualization

## Current System (Confused)

```
USER ENTRY                    DISPLAY
┌─────────────┐              ┌──────────────────┐
│ Start Time  │──┐           │  "Active Time"   │
│ End Time    │  │  ???  ──> │  (looks like a   │
└─────────────┘  │           │   metric, but    │
                 │           │   is calculated) │
metric_types    calculated   └──────────────────┘
  _vfinal       _metrics
                _vfinal

Problem: Where does the calculation happen?
         How do we aggregate across days?
         Can users log multiple sessions?
```

## New System (Clear)

```
LAYER 1:           LAYER 2:              LAYER 3:                LAYER 4:              LAYER 5:
DATA ENTRY         EVENTS                INSTANCE CALC           AGGREGATION           DISPLAY
┌──────────┐      ┌──────────────┐      ┌───────────────┐      ┌──────────────┐     ┌─────────────┐
│ start_   │      │  Activity    │      │  session_     │      │ daily_       │     │ "Active     │
│ time     │─────>│  Session     │─────>│  duration     │─────>│ active_time  │────>│  Time       │
│          │      │  (Event)     │      │  = end-start  │      │  = SUM       │     │  Today"     │
│ end_     │      │              │      │               │      │              │     │             │
│ time     │      │  Multiple    │      │  Per Session  │      │  Per Day     │     │ Progress    │
│          │      │  per day OK  │      │               │      │              │     │ Bar         │
│ activity_│      │              │      │               │      │              │     │             │
│ type     │      │              │      │               │      ├──────────────┤     ├─────────────┤
│ (opt)    │      │              │      │               │      │ weekly_      │     │ "This       │
└──────────┘      └──────────────┘      └───────────────┘      │ active_time  │     │  Week"      │
                                                                │  = SUM 7d    │     │             │
data_entry_       event_types            instance_             └──────────────┘     │ Trend Line  │
  fields                                  calculations                               │             │
                                                                aggregation_          └─────────────┘
What user         How events              Math per              metrics
actually          are defined             event                                      display_
types                                                           Math across           metrics
                                                                time periods
                                                                                     What users
                                                                                     see
```

## Example: Tracking a Morning Run

### Step 1: User Entry (data_entry_fields)
```
User opens app:
"Log Activity"

Fills in:
├─ Start Time: 07:00 AM     (DEF_001)
├─ End Time: 07:45 AM       (DEF_002)
└─ Activity Type: Running   (DEF_003)

Taps "Save"
```

### Step 2: Event Created (event_types)
```
System creates:
Event: Physical Activity Session (EVT_001)
├─ Date: 2025-10-10
├─ Start: 07:00
├─ End: 07:45
└─ Type: Running

Status: Saved ✓
```

### Step 3: Instance Calculation (instance_calculations)
```
System calculates immediately:

IC_001: session_duration
  Formula: end_time - start_time
  Input: 07:45 - 07:00
  Output: 45 minutes

User sees confirmation:
"Nice! 45 minutes of activity logged"
```

### Step 4: Aggregation (aggregation_metrics)
```
System updates aggregations:

AGG_001: daily_active_time (Today)
  Previous: 0 minutes
  + This session: 45 minutes
  = Total today: 45 minutes

AGG_002: weekly_active_time (Rolling 7 days)
  Mon: 30 min
  Tue: 0 min
  Wed: 20 min
  Thu: 40 min
  Fri: 35 min
  Sat: 0 min
  Sun: 0 min
  TODAY: 45 min
  = Total this week: 170 minutes

AGG_003: activity_sessions_count
  Sessions today: 1
  Sessions this week: 5
```

### Step 5: Display Updates (display_metrics)
```
Dashboard shows:

┌─────────────────────────────┐
│  🏃 Active Time Today       │
│  ████████████░░░  45/60 min │
│  75% of daily goal          │
│  ↑ Great progress!          │
└─────────────────────────────┘

┌─────────────────────────────┐
│  📊 This Week's Activity    │
│  170 minutes total          │
│  ▁▃▅▇▆▁█ (trend line)      │
│  ↑ Up 15% from last week    │
└─────────────────────────────┘
```

## Multiple Sessions Same Day

### Scenario: User logs SECOND activity

```
LAYER 1: DATA ENTRY
User logs afternoon walk:
├─ Start: 2:00 PM
├─ End: 2:30 PM
└─ Type: Walking

LAYER 2: EVENT
Second event created:
Event ID: EVT_001_instance_2
├─ Same event type
├─ Different time
└─ Independent record

LAYER 3: CALCULATION
IC_001 calculated again:
  30 minutes

LAYER 4: AGGREGATION (AUTO-UPDATE)
AGG_001: daily_active_time
  Morning run: 45 min
  + Afternoon walk: 30 min
  = Total: 75 minutes ✨

AGG_003: sessions_count
  Sessions today: 2 ✨

LAYER 5: DISPLAY (AUTO-REFRESH)
Dashboard now shows:
"75 minutes today from 2 sessions"
Progress bar: 125% of goal
```

## Comparison: Time-Based vs Count-Based Metrics

### Active Time (Duration-based)
```
User logs:          Session 1: 45 min
                    Session 2: 30 min
                    Session 3: 15 min

Instance Calc:      Each calculated independently
Aggregation:        SUM = 90 minutes total
Display:            "90 minutes of activity today"
```

### Activity Sessions (Count-based)
```
User logs:          Session 1
                    Session 2
                    Session 3

Instance Calc:      None needed (just count events)
Aggregation:        COUNT = 3 sessions
Display:            "3 activity sessions today"
```

### Activity Consistency (Derived from Duration)
```
Data Source:        Last 7 days of AGG_001 (daily_active_time)
                    [30, 0, 45, 40, 35, 0, 75]

Aggregation:        Calculate coefficient of variation
                    = STDEV / MEAN
                    = 25.3 / 32.1
                    = 0.79 (moderately consistent)

Display:            "Activity Consistency: Good"
                    (with trend indicator)
```

## Data Relationships

```
data_entry_fields
        ↓ (used by)
   event_types
        ↓ (generates)
   EVENT INSTANCES
        ↓ (triggers)
instance_calculations
        ↓ (feeds into)
aggregation_metrics
        ↓ (presented via)
  display_metrics
```

## Why This is Better

### Problem: "Where do I add time-restricted eating?"

**OLD WAY (Confused):**
```
Do I add to metric_types? But it's calculated...
Do I add to calculated_metrics? But how does it aggregate?
What if I want daily AND weekly views?
```

**NEW WAY (Clear):**
```
1. data_entry_fields:
   - first_meal_time
   - last_meal_time

2. event_types:
   - Daily Eating Window (uses those fields)

3. instance_calculations:
   - eating_window_duration = last - first

4. aggregation_metrics:
   - daily_eating_window (pass-through)
   - weekly_avg_eating_window (average over 7 days)
   - eating_window_consistency (STDEV over 7 days)

5. display_metrics:
   - "Today's Eating Window: 10.5 hours"
   - "Weekly Average: 11.2 hours"
   - "Consistency: Excellent"
```

Each layer has ONE job. Clear dependencies. Easy to debug.

## Migration Path

```
OLD TABLE: metric_types_vfinal
Record: "activity_start_time"
  ↓
NEW TABLE: data_entry_fields
Record: DEF_001
  field_name: activity_start_time
  field_type: timestamp
  input_method: manual

────────────────────────────

OLD TABLE: calculated_metrics_vfinal
Record: "active_time"
  ↓
NEW TABLES (split into 3):

1. event_types: EVT_001 (Activity Session)
2. instance_calculations: IC_001 (session_duration)
3. aggregation_metrics: AGG_001 (daily_active_time)
```

## Summary

Your current system tries to be everything at once. The new system separates concerns:

- **data_entry_fields**: What users type
- **event_types**: How we structure those inputs
- **instance_calculations**: Math per event
- **aggregation_metrics**: Math across time
- **display_metrics**: How we show it

Each layer is testable, maintainable, and understandable.
