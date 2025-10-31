# Sleep Duration Calculation Architecture

## Overview

Sleep duration is calculated using a clean, Apple Health-compatible formula at the aggregation level (not instance level).

## Formula

```
Sleep Duration = Time in Bed - Time Awake
```

Where:
- **Time in Bed** = Duration of "in_bed" sleep period (single period per night)
- **Time Awake** = SUM of all "awake" period durations (can be multiple)

## Why This Approach?

### ✅ Benefits
1. **Cleaner Logic**: No need to sum all asleep stages (core + deep + rem + unspecified)
2. **More Accurate**: Uses authoritative "in_bed" period as baseline
3. **Resilient**: Works even if some sleep stages are unclassified
4. **Industry Standard**: Matches Apple Health, Fitbit, and Oura calculation methods
5. **Single Source of Truth**: "In bed" period defines the sleep session boundaries

### ❌ Old Approach (Discarded)
```
Sleep Duration = Core + Deep + REM + Unspecified
```

**Problems:**
- Requires perfect stage classification
- Fails if any stages are missing or unclassified
- More complex to debug
- Doesn't match how other health platforms calculate sleep

## Data Flow

### 1. HealthKit Sync Writes Raw Data

For a night of sleep (11:00 PM - 7:00 AM):

```
HealthKit provides 6 sleep periods:

1. In Bed: 11:00 PM - 7:00 AM (480 min)
   event_instance_id: abc-123
   ├─ DEF_SLEEP_PERIOD_START → 11:00 PM
   ├─ DEF_SLEEP_PERIOD_END → 7:00 AM
   ├─ DEF_SLEEP_PERIOD_TYPE → UUID (in_bed)
   └─ DEF_SLEEP_PERIOD_DURATION → 480 min (auto-calculated)

2. Awake: 1:30 AM - 1:50 AM (20 min)
   event_instance_id: abc-124
   └─ DEF_SLEEP_PERIOD_DURATION → 20 min

3. Awake: 4:15 AM - 4:30 AM (15 min)
   event_instance_id: abc-125
   └─ DEF_SLEEP_PERIOD_DURATION → 15 min

4. Core: 11:00 PM - 1:30 AM, 1:50 AM - 2:45 AM, ... (180 min total)
   Multiple event_instance_ids
   └─ OUTPUT_CORE_SLEEP_DURATION → 180 min (sum of all core periods)

5. Deep: 2:45 AM - 4:15 AM (90 min)
   event_instance_id: abc-128
   └─ OUTPUT_DEEP_SLEEP_DURATION → 90 min

6. REM: 4:30 AM - 7:00 AM (150 min)
   event_instance_id: abc-129
   └─ OUTPUT_REM_SLEEP_DURATION → 150 min
```

### 2. Aggregation Processing (Daily)

Runs at the end of the day to calculate daily totals:

```sql
-- Time in bed (only "in_bed" periods)
AGG_TIME_IN_BED_TOTAL =
  SUM(DEF_SLEEP_PERIOD_DURATION)
  WHERE sleep_period_type = 'in_bed'
  = 480 minutes

-- Time awake (all "awake" periods)
AGG_TIME_AWAKE_TOTAL =
  SUM(DEF_SLEEP_PERIOD_DURATION)
  WHERE sleep_period_type = 'awake'
  = 20 + 15 = 35 minutes

-- Sleep duration (formula)
AGG_SLEEP_DURATION_TOTAL =
  AGG_TIME_IN_BED_TOTAL - AGG_TIME_AWAKE_TOTAL
  = 480 - 35 = 445 minutes ✅

-- Individual stages (for breakdown)
AGG_CORE_SLEEP_TOTAL = 180 min
AGG_DEEP_SLEEP_TOTAL = 90 min
AGG_REM_SLEEP_TOTAL = 150 min

-- Validation: 180 + 90 + 150 + 35 = 455 min
-- (Note: 10 min discrepancy is "unspecified" sleep stage)
```

### 3. Display in UI

```
Sleep Card:
┌─────────────────────────────┐
│ Sleep Duration: 7h 25m      │ ← AGG_SLEEP_DURATION_TOTAL
│ Time in Bed: 8h 0m          │ ← AGG_TIME_IN_BED_TOTAL
│ Time Awake: 35m             │ ← AGG_TIME_AWAKE_TOTAL
│ Sleep Efficiency: 92.7%     │ ← (445/480 * 100)
│                             │
│ Sleep Stages:               │
│ ├─ Core: 3h 0m (40%)        │ ← AGG_CORE_SLEEP_TOTAL
│ ├─ Deep: 1h 30m (20%)       │ ← AGG_DEEP_SLEEP_TOTAL
│ └─ REM: 2h 30m (34%)        │ ← AGG_REM_SLEEP_TOTAL
└─────────────────────────────┘
```

## Implementation Details

### Database Tables

**aggregation_metrics:**
```sql
AGG_TIME_IN_BED_TOTAL
- aggregation_method: 'sum'
- source_field_id: 'DEF_SLEEP_PERIOD_DURATION'
- filter: sleep_period_type = 'in_bed'

AGG_TIME_AWAKE_TOTAL
- aggregation_method: 'sum'
- source_field_id: 'DEF_SLEEP_PERIOD_DURATION'
- filter: sleep_period_type = 'awake'

AGG_SLEEP_DURATION_TOTAL
- aggregation_method: 'formula'
- calculation_formula: 'AGG_TIME_IN_BED_TOTAL - AGG_TIME_AWAKE_TOTAL'
```

**aggregation_dependencies:**
```sql
-- Time in bed depends on period type filter
(AGG_TIME_IN_BED_TOTAL, DEF_SLEEP_PERIOD_TYPE, 'filter')

-- Time awake depends on period type filter
(AGG_TIME_AWAKE_TOTAL, DEF_SLEEP_PERIOD_TYPE, 'filter')

-- Sleep duration depends on two metrics
(AGG_SLEEP_DURATION_TOTAL, AGG_TIME_IN_BED_TOTAL, 'input')
(AGG_SLEEP_DURATION_TOTAL, AGG_TIME_AWAKE_TOTAL, 'input')
```

### Processing Function

```sql
CREATE OR REPLACE FUNCTION calculate_formula_aggregation(...)
RETURNS NUMERIC AS $$
BEGIN
    -- Get input values from other aggregation metrics
    -- Apply formula: AGG_TIME_IN_BED_TOTAL - AGG_TIME_AWAKE_TOTAL
    RETURN time_in_bed - time_awake;
END;
$$ LANGUAGE plpgsql;
```

## Edge Cases

### No "In Bed" Period
If HealthKit doesn't provide an "in_bed" period:
- Use MIN(all period starts) to MAX(all period ends)
- Calculate time in bed as span of all periods

### Multiple "In Bed" Periods
If multiple in_bed periods exist (e.g., nap + night sleep):
- Sum all in_bed durations
- Sum all awake durations
- Formula still works correctly

### No "Awake" Periods
If user didn't wake up during sleep:
```
Sleep Duration = Time in Bed - 0 = Time in Bed
Sleep Efficiency = 100%
```

### Unspecified Sleep Stages
If some periods are "unspecified":
```
Total accounted = Core + Deep + REM + Awake + Unspecified
Should equal Time in Bed

If not equal:
- Missing time = Time in Bed - Total accounted
- Display as "Unclassified" in UI
```

## Testing

### Unit Test Data

```python
# Test case: Normal night with awakenings
in_bed_duration = 480  # 8 hours
awake_durations = [20, 15, 10]  # 3 awakenings
core_duration = 180
deep_duration = 90
rem_duration = 165

# Expected results
time_in_bed = 480
time_awake = sum(awake_durations) = 45
sleep_duration = 480 - 45 = 435
sleep_efficiency = 435 / 480 = 90.6%

# Validation
assert core_duration + deep_duration + rem_duration == sleep_duration
```

### Integration Test

1. Write sleep data via HealthKit sync
2. Run instance calculations (durations)
3. Run aggregation processing (daily totals)
4. Query patient_field_aggregations
5. Verify formula results

```sql
-- Verify daily aggregations
SELECT
    aggregation_metric_id,
    value_quantity
FROM patient_field_aggregations
WHERE patient_id = 'test-user-id'
  AND period_type = 'day'
  AND period_start = '2025-10-29'
  AND aggregation_metric_id IN (
      'AGG_TIME_IN_BED_TOTAL',
      'AGG_TIME_AWAKE_TOTAL',
      'AGG_SLEEP_DURATION_TOTAL'
  );

-- Expected:
-- AGG_TIME_IN_BED_TOTAL: 480
-- AGG_TIME_AWAKE_TOTAL: 45
-- AGG_SLEEP_DURATION_TOTAL: 435
```

## Migration

**File:** `supabase/migrations/20251029_fix_sleep_duration_calculation_logic.sql`

**Changes:**
1. Created 3 new aggregation metrics (time in bed, time awake, sleep duration)
2. Added filtering dependencies for period type
3. Created formula evaluation function
4. Updated display metrics descriptions

**Rollback:**
Not needed - new approach runs alongside old structure. Old `CALC_SLEEP_DURATION` instance calculation still exists but is unused.

## Future Enhancements

1. **Sleep Efficiency Alert**: Notify if efficiency drops below 85%
2. **Awake Period Analysis**: Identify patterns in nighttime awakenings
3. **Sleep Debt Tracking**: Calculate cumulative sleep deficit
4. **Optimal Sleep Window**: ML to predict best bedtime based on historical data

## References

- Apple HealthKit: `HKCategoryTypeIdentifierSleepAnalysis`
- Sleep Period Types: `def_ref_sleep_period_types` table
- Aggregation Processing: `process_field_aggregations()` function
- HealthKit Sync: `HealthKitSyncService.swift:123-161`
