# Sleep Date Assignment Architecture

## Overview

Sleep periods are assigned to dates based on **wake time - 1 day**, matching Apple Health's behavior. This ensures that:
- A sleep session from 11 PM Monday → 7 AM Tuesday is assigned to **Monday**
- Weekly/Monthly/Yearly aggregations work correctly from cache
- Naps are handled consistently with main sleep

## Date Assignment Logic

### Rule: Sleep Date = Wake Date - 1 Day

```
Sleep Start: 2025-10-28 23:00
Sleep End:   2025-10-29 07:00
→ Sleep Date: 2025-10-28  (wake date - 1)
```

This applies to **both main sleep and naps**.

## Nap Detection

A sleep event is classified as a nap if **either** criterion is met:

### Criterion 1: Duration < 4 Hours
```sql
total_sleep_duration < 240 minutes
```

### Criterion 2: Multiple Wake Times Same Day
If another sleep event has a **later** wake time on the same calendar day:
```sql
EXISTS (
    another wake time on same date
    WHERE other_wake_time > this_wake_time
)
```

## Implementation

### 1. Database Functions

#### `calculate_sleep_date(event_instance_id)`
Returns the correct sleep date for an event:
```sql
SELECT calculate_sleep_date('uuid-here');
-- Returns: 2025-10-28
```

Logic:
1. Get wake time from `DEF_SLEEP_PERIOD_END`
2. Return `wake_date - 1 day`
3. Fallback to `MIN(entry_date)` if no wake time found

#### `is_nap_sleep_event(event_instance_id)`
Returns `true` if the event is a nap:
```sql
SELECT is_nap_sleep_event('uuid-here');
-- Returns: true/false
```

Logic:
1. Check if `OUTPUT_SLEEP_DURATION < 240 minutes` → Nap
2. Check if another event has later wake time same day → Nap
3. Otherwise → Main sleep

### 2. OUTPUT Field Creation

When creating OUTPUT fields (SLEEP_DURATION, TIME_IN_BED, etc.), use:

```sql
INSERT INTO patient_data_entries (
    patient_id,
    field_id,
    entry_date,  -- ← Important!
    value_quantity,
    event_instance_id
)
SELECT
    patient_id,
    'OUTPUT_SLEEP_DURATION',
    calculate_sleep_date(event_instance_id),  -- ← Use function
    SUM(value_quantity),
    event_instance_id
FROM patient_data_entries
WHERE field_id IN (...)
GROUP BY patient_id, event_instance_id;
```

**DO NOT** use:
- ❌ `MIN(entry_date)` - may split sleep across days
- ❌ `MAX(entry_date)` - may split sleep across days
- ✅ `calculate_sleep_date(event_instance_id)` - correct

### 3. Edge Function Trigger

When new sleep data is inserted, automatically calculate and assign sleep date:

```typescript
// supabase/functions/process-sleep-data/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  )

  const { event_instance_id, patient_id } = await req.json()

  // Calculate sleep date
  const { data: sleepDate } = await supabase
    .rpc('calculate_sleep_date', { p_event_instance_id: event_instance_id })

  // Update all OUTPUT fields for this event with correct date
  await supabase
    .from('patient_data_entries')
    .update({ entry_date: sleepDate })
    .eq('event_instance_id', event_instance_id)
    .in('field_id', [
      'OUTPUT_SLEEP_DURATION',
      'OUTPUT_TIME_IN_BED',
      'OUTPUT_CORE_SLEEP_DURATION',
      'OUTPUT_DEEP_SLEEP_DURATION',
      'OUTPUT_REM_SLEEP_DURATION',
      'OUTPUT_AWAKE_PERIODS_DURATION',
      'OUTPUT_IN_BED_DURATION'
    ])

  return new Response(JSON.stringify({ success: true, sleep_date: sleepDate }))
})
```

## Aggregation Flow

### Before: Incorrect Date Splitting

```
Sleep 11 PM Oct 28 → 7 AM Oct 29

OLD BEHAVIOR:
- Some data assigned to Oct 28
- Some data assigned to Oct 29
- Aggregations split across 2 days
- Weekly view shows incorrect totals
```

### After: Correct Date Assignment

```
Sleep 11 PM Oct 28 → 7 AM Oct 29

NEW BEHAVIOR:
- All data assigned to Oct 28 (wake date - 1)
- Single aggregation on Oct 28
- Weekly/Monthly/Yearly views work correctly
- Matches Apple Health behavior
```

## Verification Query

Check that sleep dates are correctly assigned:

```sql
WITH sleep_events AS (
    SELECT DISTINCT
        pde.event_instance_id,
        pde.entry_date as assigned_sleep_date,
        start_entry.value_timestamp as sleep_start,
        end_entry.value_timestamp as wake_time,
        (end_entry.value_timestamp AT TIME ZONE 'UTC')::date as wake_date,
        (end_entry.value_timestamp AT TIME ZONE 'UTC')::date - INTERVAL '1 day' as expected_sleep_date,
        ROUND((duration.value_quantity / 60.0)::numeric, 1) as duration_hours,
        is_nap_sleep_event(pde.event_instance_id) as is_nap
    FROM patient_data_entries pde
    LEFT JOIN patient_data_entries start_entry
        ON start_entry.event_instance_id = pde.event_instance_id
        AND start_entry.field_id = 'DEF_SLEEP_PERIOD_START'
    LEFT JOIN patient_data_entries end_entry
        ON end_entry.event_instance_id = pde.event_instance_id
        AND end_entry.field_id = 'DEF_SLEEP_PERIOD_END'
    LEFT JOIN patient_data_entries duration
        ON duration.event_instance_id = pde.event_instance_id
        AND duration.field_id = 'OUTPUT_SLEEP_DURATION'
    WHERE pde.field_id = 'OUTPUT_SLEEP_DURATION'
      AND pde.event_instance_id IS NOT NULL
)
SELECT
    assigned_sleep_date,
    expected_sleep_date::date,
    TO_CHAR(sleep_start, 'HH24:MI') as sleep_time,
    TO_CHAR(wake_time, 'HH24:MI') as wake_time,
    duration_hours,
    is_nap,
    CASE WHEN assigned_sleep_date = expected_sleep_date::date
         THEN '✅ Correct'
         ELSE '❌ MISMATCH'
    END as status
FROM sleep_events
ORDER BY assigned_sleep_date DESC, sleep_start DESC;
```

## Mobile App Queries

The mobile app can now use aggregated data for all views:

### Daily View (W button)
```swift
.eq("period_type", value: "weekly")
.eq("calculation_type_id", value: "SUM")
```

### Monthly View (M button)
```swift
.eq("period_type", value: "monthly")
.eq("calculation_type_id", value: "AVG")
```

### 6 Month View (6M button)
```swift
.eq("period_type", value: "6month")
.eq("calculation_type_id", value: "AVG")
```

All views work from cache with correct date grouping!

## Summary

✅ **Sleep Date = Wake Date - 1 Day** (for all sleep events)
✅ **Naps detected** by duration (<4h) or multiple wakes same day
✅ **Naps use same date logic** as main sleep (matching Apple Health)
✅ **Aggregations work correctly** for D/W/M/6M/Y views
✅ **Functions created** for automatic calculation
✅ **Edge function ready** for automatic processing
