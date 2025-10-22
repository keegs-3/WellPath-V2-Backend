# Tracked Metrics: Three Aggregation Patterns

## Overview
There are three distinct patterns for how tracked metrics aggregate, determined by the **nature of the data source**.

---

## Pattern 1: Measurements (Continuous Values)

### Characteristics:
- Single numeric value per entry
- Can be recorded multiple times per day
- Each entry is a complete, independent measurement
- Examples: heart rate, weight, HRV, blood glucose, blood pressure

### Data Flow:
```
data_entry_field: "heart_rate"
  ↓ (NO event_type, NO instance_calculation)
aggregation_metric: "heart_rate"
  ↓
aggregation_metrics_dependencies:
  - dependency_type: "data_entry_field"
  - dependency_id: <heart_rate field_id>
  ↓
aggregation_metrics_periods:
  - heart_rate + most_recent (last recorded value)
  - heart_rate + 7d_avg (average over 7 days)
  - heart_rate + 30d_max (highest value in 30 days)
  - heart_rate + 30d_min (lowest value in 30 days)
```

### Example Data:
```
Patient entries:
- 2025-10-18 08:00: 72 bpm
- 2025-10-18 14:30: 85 bpm
- 2025-10-18 20:00: 68 bpm

Aggregations:
- most_recent: 68 bpm
- 1d_avg: 75 bpm
- 7d_avg: 73.5 bpm
```

---

## Pattern 2: Events (Complex Multi-Field)

### Characteristics:
- Multiple fields per occurrence
- Fields roll up into instance calculations
- Each instance has derived values
- Examples: meals (protein + carbs + fat → total_calories), workouts (exercise types + duration → total_time)

### Data Flow:
```
data_entry_fields: ["protein_grams", "carb_grams", "fat_grams"]
  ↓
event_type: "meal"
  ↓
instance_calculation: "total_calories" = (protein * 4) + (carbs * 4) + (fat * 9)
  ↓
aggregation_metric: "calorie_intake"
  ↓
aggregation_metrics_dependencies:
  - dependency_type: "instance_calculation"
  - dependency_id: <total_calories calc_id>
  ↓
aggregation_metrics_periods:
  - calorie_intake + 1d_sum (total calories today)
  - calorie_intake + 7d_avg (average daily calories last 7 days)
  - calorie_intake + 30d_sum (total calories last 30 days)
```

### Example Data:
```
Patient meals:
- 2025-10-18 08:00: Breakfast → 450 calories
- 2025-10-18 12:30: Lunch → 650 calories
- 2025-10-18 18:00: Dinner → 700 calories

Instance calcs:
- daily_total_calories: 1800 calories

Aggregations:
- 1d_sum: 1800 calories
- 7d_avg: 1850 calories/day
- 30d_avg: 1920 calories/day
```

---

## Pattern 3: Counters (Event Frequency)

### Characteristics:
- Just counting occurrences
- No complex calculations needed
- Each occurrence is boolean (happened or didn't)
- Examples: meal count, workout count, meditation sessions, water intake logs

### Data Flow:
```
event_type: "meal"
  ↓ (NO instance_calculation needed - just counting)
aggregation_metric: "meal_frequency"
  ↓
aggregation_metrics_dependencies:
  - dependency_type: "event_type"  ← Different from Pattern 1 & 2!
  - dependency_id: <meal event_type_id>
  ↓
aggregation_metrics_periods:
  - meal_frequency + 1d_count (how many meals today)
  - meal_frequency + 7d_avg (average meals per day last 7 days)
  - meal_frequency + 30d_count (total meals last 30 days)
```

### Example Data:
```
Patient meal events:
- 2025-10-18: 3 meals logged
- 2025-10-17: 4 meals logged
- 2025-10-16: 3 meals logged

Aggregations:
- 1d_count: 3 meals
- 7d_avg: 3.2 meals/day
- 30d_count: 95 meals
```

---

## Comparison Table

| Aspect | Measurements | Events | Counters |
|--------|-------------|--------|----------|
| **Source** | data_entry_field | instance_calculation | event_type |
| **Dependency Type** | "data_entry_field" | "instance_calculation" | "event_type" |
| **Instance Calc** | No | Yes | No |
| **Common Agg Types** | avg, max, min, most_recent | avg, sum, max | count, avg (per day) |
| **Examples** | Heart rate, weight, glucose | Calories, macros, workout time | Meal count, workout count |

---

## Implementation in `aggregation_metrics_dependencies`

### Table Structure:
```sql
aggregation_metrics_dependencies:
- id (uuid)
- aggregation_metric_id (uuid) → aggregation_metrics
- dependency_type (text) → 'data_entry_field' | 'instance_calculation' | 'event_type'
- dependency_id (uuid) → ID in the respective table
- created_at (timestamptz)
```

### Pattern Detection:
```typescript
// Determine aggregation pattern
function getAggregationPattern(metric: AggregationMetric): 'measurement' | 'event' | 'counter' {
  const dep = metric.dependencies[0] // Assume one primary dependency

  if (dep.dependency_type === 'data_entry_field') {
    return 'measurement'
  }
  if (dep.dependency_type === 'instance_calculation') {
    return 'event'
  }
  if (dep.dependency_type === 'event_type') {
    return 'counter'
  }
}
```

---

## Aggregation Worker Logic

### For Measurements:
```sql
-- Calculate 7-day average heart rate
SELECT
  user_id,
  AVG(response_numeric) as avg_heart_rate_7d
FROM patient_data_entry_responses
WHERE field_id = 'heart_rate'
AND recorded_at >= NOW() - INTERVAL '7 days'
GROUP BY user_id
```

### For Events:
```sql
-- Calculate 7-day average calories from meals
WITH daily_calories AS (
  SELECT
    user_id,
    DATE(event_timestamp) as day,
    SUM(calculated_value) as total_calories
  FROM patient_events
  JOIN instance_calculation_results ON ...
  WHERE instance_calculation_id = 'total_calories'
  AND event_timestamp >= NOW() - INTERVAL '7 days'
  GROUP BY user_id, DATE(event_timestamp)
)
SELECT
  user_id,
  AVG(total_calories) as avg_calories_per_day_7d
FROM daily_calories
GROUP BY user_id
```

### For Counters:
```sql
-- Calculate 7-day average meal count
WITH daily_counts AS (
  SELECT
    user_id,
    DATE(event_timestamp) as day,
    COUNT(*) as meal_count
  FROM patient_events
  WHERE event_type_id = 'meal'
  AND event_timestamp >= NOW() - INTERVAL '7 days'
  GROUP BY user_id, DATE(event_timestamp)
)
SELECT
  user_id,
  AVG(meal_count) as avg_meals_per_day_7d
FROM daily_counts
GROUP BY user_id
```

---

## Key Takeaways

1. **Pattern is determined by dependency_type** in `aggregation_metrics_dependencies`
2. **Not all metrics need instance_calculations** - measurements and counters go direct
3. **Event_types can be both:**
   - Source for counters (how many times?)
   - Container for events that have instance calcs (what was calculated?)
4. **One aggregation_metric** can appear in multiple `aggregation_metrics_periods` with different calculation types

---

*Last Updated: 2025-10-18*
