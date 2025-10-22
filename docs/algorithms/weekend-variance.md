# Weekend Variance Algorithm (SC-WEEKEND-VARIANCE)

Different scoring criteria for weekdays vs. weekends, accounting for realistic lifestyle differences.

## Overview

The Weekend Variance algorithm recognizes that many health behaviors naturally differ between weekdays and weekends. It establishes a baseline from weekday patterns (Monday-Friday) and then scores weekend performance based on acceptable variance from that baseline. This approach accommodates real-world lifestyle differences while maintaining health consistency.

## Algorithm Types

### SC-WEEKEND-VARIANCE
**Purpose:** Weekday baseline establishment with weekend variance tolerance  
**Pattern:** Days 1-5 establish baseline (0% progress), Days 6-7 scored against baseline  
**Evaluation:** Baseline establishment + weekend variance scoring  
**Scoring:** Weekend-only progress (weekend_day_weight per compliant weekend day)

## Configuration Schema

```json
{
  "config_id": "SC-WEEKEND-VARIANCE-SLEEP_TIME_90MIN",
  "scoring_method": "weekend_variance",
  "configuration_json": {
    "method": "weekend_variance",
    "formula": "weekday_baseline_establishment + weekend_variance_scoring",
    "evaluation_pattern": "weekday_baseline_weekend_variance",
    "schema": {
      "measurement_type": "weekend_variance",
      "evaluation_period": "weekly",
      "success_criteria": "weekend_baseline_variance",
      "calculation_method": "baseline_deviation_weekend",
      "tracked_metrics": ["sleep_time"],
      "calculated_metrics": ["sleep_time_consistency"],
      "weekday_baseline_days": 5,
      "weekend_days": 2,
      "variance_threshold": 90.0,
      "comparison_operator": "<=",
      "weekend_day_weight": 50.0,
      "total_days": 7,
      "unit": "minutes",
      "progress_direction": "weekend_consistency",
      "frequency_requirement": "weekend",
      "description": "Weekend variance scoring for sleep time flexibility"
    }
  },
  "metadata": {
    "recommendation_text": "Maintain consistent sleep times with weekend flexibility",
    "recommendation_id": "REC0040.2",
    "metric_id": "sleep_time_consistency"
  }
}
```

## Implementation

### Python Usage

```python
from algorithms.weekend_variance import calculate_weekend_variance_score

# Sleep times throughout the week (in minutes from midnight)
daily_data = [
    {"day": 1, "sleep_time": 630},  # 10:30 PM Monday
    {"day": 2, "sleep_time": 645},  # 10:45 PM Tuesday  
    {"day": 3, "sleep_time": 615},  # 10:15 PM Wednesday
    {"day": 4, "sleep_time": 660},  # 11:00 PM Thursday
    {"day": 5, "sleep_time": 630},  # 10:30 PM Friday
    {"day": 6, "sleep_time": 720},  # 12:00 AM Saturday (within 90min of 635 avg)
    {"day": 7, "sleep_time": 780},  # 1:00 AM Sunday (outside 90min threshold)
]

config = {
    "schema": {
        "tracked_metrics": ["sleep_time"],
        "calculated_metrics": ["sleep_time_consistency"],
        "weekday_baseline_days": 5,
        "weekend_days": 2,
        "variance_threshold": 90.0,
        "comparison_operator": "<=",
        "weekend_day_weight": 50.0
    }
}

score, max_potential, details = calculate_weekend_variance_score(daily_data, config)
# Returns: score=50.0 (1/2 weekend days compliant), max_potential=100.0
```

### Direct Function Usage

```python
from algorithms.weekend_variance import weekend_variance

result = weekend_variance(daily_data, config)
print(f"Progress Score: {result['progress_score']}")
print(f"Max Potential: {result['max_potential_score']}")
```

## Scoring Logic

### Phase 1: Baseline Establishment (Days 1-5)
1. **Weekday Data Collection**: Collect values from Monday-Friday
2. **Baseline Calculation**: Calculate mean of weekday values
3. **Progress Contribution**: 0% (baseline establishment only)
4. **Potential Contribution**: 100% (full potential available)

### Phase 2: Weekend Evaluation (Days 6-7)
```python
def calculate_weekend_score(weekend_value, baseline, variance_threshold):
    variance = abs(weekend_value - baseline)
    
    if variance <= variance_threshold:
        return weekend_day_weight  # Full points for staying within threshold
    else:
        return 0.0                # No points for exceeding variance
```

### Progressive Scoring
- **Baseline Phase**: Days 1-5 show 0% progress, 100% potential
- **Weekend Phase**: Each compliant weekend day adds weekend_day_weight
- **Final Score**: Sum of weekend day scores (capped at 100%)

### Comparison Operators

| Operator | Logic | Use Case |
|----------|-------|----------|
| `<=` | variance ≤ threshold | "Within 90 minutes" (default) |
| `<` | variance < threshold | "Strictly less than threshold" |
| `>=` | variance ≥ threshold | "At least X variance" (unusual) |
| `>` | variance > threshold | "More than X variance" (unusual) |

## Parameters

### Core Parameters
- **weekday_baseline_days**: Days for baseline establishment (default: 5)
- **weekend_days**: Weekend days to evaluate (default: 2)
- **variance_threshold**: Maximum allowed deviation from baseline
- **weekend_day_weight**: Points per compliant weekend day (default: 50.0)

### Evaluation Parameters
- **comparison_operator**: How to evaluate variance (default: "<=")
- **total_days**: Total evaluation period (default: 7)
- **calculated_metrics**: Optional derived metrics (e.g., "sleep_time_consistency")

## Use Cases

### Perfect Fits for Weekend Variance
- **Sleep schedule flexibility**: "Consistent weekday bedtime, later weekends"
- **Exercise timing**: "Morning workouts weekdays, flexible weekend timing"
- **Meal schedule**: "Regular meal times weekdays, relaxed weekends"
- **Work-life balance**: "Strict schedule weekdays, flexible weekends"
- **Social accommodations**: "Early weekday routines, social weekend flexibility"

### Real-World Scenarios
```json
{
  "scenario": "Work schedule sleep",
  "weekday_pattern": "10:30 PM bedtime Monday-Friday",
  "weekend_allowance": "Up to 90 minutes later on weekends",
  "tolerance": "12:00 AM Saturday/Sunday still compliant"
}
```

### Not Suitable For
- **Consistent daily targets**: "Same bedtime every night" → Use SC-BASELINE-CONSISTENCY
- **Absolute targets**: "Exercise exactly 30 minutes" → Use SC-BINARY-THRESHOLD
- **Frequency patterns**: "Exercise 3+ times per week" → Use SC-MINIMUM-FREQUENCY
- **Gradual improvement**: "Increase step count" → Use SC-PROPORTIONAL

## Validation Rules

1. **Weekday Data**: Must have sufficient weekday days for baseline calculation
2. **Weekend Days**: Must be ≤ (total_days - weekday_baseline_days)
3. **Variance Threshold**: Must be positive number
4. **Weekend Day Weight**: Must be positive (typically 50.0 for 2-day weekends)
5. **Tracked Metrics**: Exactly one metric must be specified

## Testing

```python
def test_weekend_variance():
    # Test sleep time with weekend flexibility
    daily_data = [
        # Weekdays: establish baseline around 10:30 PM (630 minutes)
        {"day": 1, "sleep_time": 630},  # 10:30 PM
        {"day": 2, "sleep_time": 645},  # 10:45 PM
        {"day": 3, "sleep_time": 615},  # 10:15 PM
        {"day": 4, "sleep_time": 630},  # 10:30 PM
        {"day": 5, "sleep_time": 650},  # 10:50 PM
        # Baseline = 634 minutes (10:34 PM average)
        
        # Weekends: test variance tolerance
        {"day": 6, "sleep_time": 720},  # 12:00 AM (86 min later - within 90min)
        {"day": 7, "sleep_time": 750},  # 12:30 AM (116 min later - outside 90min)
    ]
    
    config = {
        "schema": {
            "tracked_metrics": ["sleep_time"],
            "variance_threshold": 90.0,
            "weekend_day_weight": 50.0
        }
    }
    
    score, max_potential, details = calculate_weekend_variance_score(daily_data, config)
    
    assert score == 50.0     # 1/2 weekend days compliant
    assert max_potential == 100.0
    assert details["baseline_value"] == 634.0  # Mean of weekday values
    assert details["successful_weekend_days"] == 1
    
    print("Weekend variance tests passed!")
```

## Real-World Examples

### Sleep Schedule with Weekend Flexibility
```json
{
  "config_id": "SC-WEEKEND-VARIANCE-SLEEP_TIME_90MIN",
  "recommendation_text": "Maintain work schedule sleep with weekend flexibility",
  "schema": {
    "tracked_metrics": ["sleep_time"],
    "variance_threshold": 90.0,
    "weekend_day_weight": 50.0,
    "unit": "minutes"
  }
}
```

### Exercise Timing Flexibility
```json
{
  "config_id": "SC-WEEKEND-VARIANCE-WORKOUT_TIME_120MIN",
  "recommendation_text": "Consistent weekday workout times, flexible weekends",
  "schema": {
    "tracked_metrics": ["first_exercise_time"],
    "variance_threshold": 120.0,
    "weekend_day_weight": 50.0,
    "unit": "minutes"
  }
}
```

### Meal Schedule Balance
```json
{
  "config_id": "SC-WEEKEND-VARIANCE-BREAKFAST_TIME_60MIN",
  "recommendation_text": "Regular weekday breakfast, relaxed weekend timing",
  "schema": {
    "tracked_metrics": ["first_meal_time"],
    "variance_threshold": 60.0,
    "weekend_day_weight": 50.0,
    "unit": "minutes"
  }
}
```

## Dual Progress Tracking

The algorithm shows distinct baseline establishment and weekend evaluation phases:

```python
# Day-by-day progress for sleep schedule with weekend flexibility
Day 1: 10:30 PM → 0.0% (baseline establishment, no progress yet)
Day 2: 10:45 PM → 0.0% (still establishing baseline)
Day 3: 10:15 PM → 0.0% (baseline establishment continues)
Day 4: 10:30 PM → 0.0% (baseline establishment continues)
Day 5: 10:50 PM → 0.0% (baseline complete: avg = 10:34 PM)
Day 6: 12:00 AM → 50.0% (within 90min variance - compliant!)
Day 7: 1:00 AM → 50.0% (outside variance - no additional progress)
```

## Algorithm Insights

### Innovation Points
1. **Realistic Flexibility**: Acknowledges natural weekday/weekend differences
2. **Baseline Establishment**: Uses actual user patterns, not arbitrary targets
3. **Social Accommodation**: Allows for weekend social activities while maintaining weekday structure
4. **Work-Life Balance**: Recognizes structured weekdays vs. flexible weekends

### Clinical Applications
- **Circadian rhythm management**: Maintains weekday consistency with weekend flexibility
- **Medication timing**: Strict weekday adherence with weekend tolerance
- **Exercise scheduling**: Accommodates work schedules and weekend activities
- **Nutrition timing**: Regular weekday meals with social weekend flexibility

### Behavioral Science
- **Habit maintenance**: Preserves weekday routines while allowing weekend variation
- **Sustainability**: More realistic than rigid daily requirements
- **Social integration**: Accounts for weekend social activities and commitments
- **Stress reduction**: Reduces anxiety about perfect daily consistency

## Calculated Metrics Integration

The algorithm can generate calculated metrics for downstream use:

```json
{
  "calculated_metrics": ["sleep_time_consistency"],
  "calculation": "mean(weekday_sleep_times)",
  "usage": "Baseline value becomes sleep_time_consistency metric"
}
```

---

*For strict daily consistency, see [SC-BASELINE-CONSISTENCY](baseline-consistency.md)*  
*For absolute targets, see [SC-BINARY-THRESHOLD](binary-threshold.md)*  
*For frequency-based goals, see [SC-MINIMUM-FREQUENCY](minimum-frequency.md)*