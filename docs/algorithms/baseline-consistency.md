# Baseline Consistency Algorithm (SC-BASELINE-CONSISTENCY)

Maintains baseline values with variance tolerance for consistent health behaviors.

## Overview

The Baseline Consistency algorithm establishes a baseline value from a specified day and tracks how consistently subsequent days stay within a defined variance threshold. It's designed for health behaviors where maintaining consistency around an established baseline is more important than hitting absolute targets.

## Algorithm Types

### SC-BASELINE-CONSISTENCY
**Purpose:** Consistency tracking around established baseline values  
**Pattern:** Day 1 sets baseline, subsequent days scored based on variance from baseline  
**Evaluation:** Daily with cumulative scoring  
**Scoring:** Incremental (daily_weight per compliant day)

## Configuration Schema

```json
{
  "config_id": "SC-BASELINE-CONSISTENCY-WAKE_TIME_30MIN",
  "scoring_method": "baseline_consistency",
  "configuration_json": {
    "method": "baseline_consistency",
    "formula": "baseline_day_1 + daily_weight_per_compliant_day",
    "evaluation_pattern": "daily_baseline_consistency",
    "schema": {
      "measurement_type": "baseline_consistency",
      "evaluation_period": "daily",
      "success_criteria": "variance_threshold",
      "calculation_method": "baseline_deviation",
      "tracked_metrics": ["wake_time"],
      "baseline_day": 1,
      "variance_threshold": 30.0,
      "comparison_operator": "<=",
      "weekdays_only": false,
      "daily_weight": 20.0,
      "required_days": 7,
      "total_days": 7,
      "unit": "minutes",
      "progress_direction": "consistency",
      "frequency_requirement": "daily",
      "description": "Baseline consistency scoring for wake time maintenance"
    }
  },
  "metadata": {
    "recommendation_text": "Maintain consistent wake times within 30 minutes",
    "recommendation_id": "REC0039.1",
    "metric_id": "wake_time"
  }
}
```

## Implementation

### Python Usage

```python
from algorithms.baseline_consistency import calculate_baseline_consistency_score

# Daily wake times (in minutes from midnight)
daily_data = [
    {"day": 1, "wake_time": 420},  # 7:00 AM - baseline
    {"day": 2, "wake_time": 435},  # 7:15 AM - within 30min
    {"day": 3, "wake_time": 405},  # 6:45 AM - within 30min
    {"day": 4, "wake_time": 480},  # 8:00 AM - outside threshold
    {"day": 5, "wake_time": 425},  # 7:05 AM - within 30min
]

config = {
    "schema": {
        "tracked_metrics": ["wake_time"],
        "baseline_day": 1,
        "variance_threshold": 30.0,
        "comparison_operator": "<=",
        "weekdays_only": False,
        "daily_weight": 20.0,
        "required_days": 7
    }
}

score, max_potential, details = calculate_baseline_consistency_score(daily_data, config)
# Returns: score=80.0 (4/5 days compliant), max_potential=140.0, details=algorithm_breakdown
```

### Direct Function Usage

```python
from algorithms.baseline_consistency import baseline_consistency

result = baseline_consistency(daily_data, config)
print(f"Progress Score: {result['progress_score']}")
print(f"Max Potential: {result['max_potential_score']}")
```

## Scoring Logic

### Baseline Establishment
1. **Baseline Day**: Specified day (default: Day 1) automatically sets the baseline value
2. **Guaranteed Score**: Baseline day always earns its daily_weight percentage
3. **Reference Point**: All subsequent days compared against this baseline value

### Variance Calculation
```python
def calculate_daily_score(day_value, baseline_value, variance_threshold):
    variance = abs(day_value - baseline_value)
    
    if variance <= variance_threshold:
        return daily_weight  # Full points for staying within threshold
    else:
        return 0.0          # No points for exceeding variance
```

### Progressive Scoring
- **Cumulative**: Each compliant day adds daily_weight to total score
- **Cap**: Total score cannot exceed (daily_weight × required_days)
- **Baseline Guarantee**: Baseline day always contributes its weight

### Comparison Operators

| Operator | Logic | Use Case |
|----------|-------|----------|
| `<=` | variance ≤ threshold | "Within 30 minutes" (default) |
| `<` | variance < threshold | "Strictly less than threshold" |
| `>=` | variance ≥ threshold | "At least X variance" (unusual) |
| `>` | variance > threshold | "More than X variance" (unusual) |

## Parameters

### Core Parameters
- **baseline_day**: Which day establishes the baseline (default: 1)
- **variance_threshold**: Maximum allowed deviation from baseline
- **comparison_operator**: How to evaluate variance (default: "<=")
- **daily_weight**: Points earned per compliant day (default: 20.0)

### Evaluation Parameters
- **weekdays_only**: Only evaluate Monday-Friday (default: false)
- **required_days**: Days needed for full score (default: 7, or 5 if weekdays_only)
- **total_days**: Total evaluation period (default: 7)

## Use Cases

### Perfect Fits for Baseline Consistency
- **Sleep schedule maintenance**: "Maintain consistent wake times"
- **Weight stability**: "Keep weight within 2 pounds of baseline"
- **Meal timing**: "Eat first meal within 1 hour of established time"
- **Exercise consistency**: "Maintain workout duration within 15 minutes"
- **Medication timing**: "Take medication within 30 minutes of usual time"

### Weekdays-Only Mode
```json
{
  "weekdays_only": true,
  "required_days": 5,
  "description": "Maintain work schedule consistency Monday-Friday"
}
```

### Not Suitable For
- **Absolute targets**: "Sleep exactly 8 hours" → Use SC-BINARY-THRESHOLD
- **Improvement goals**: "Increase step count" → Use SC-PROPORTIONAL
- **Frequency patterns**: "Exercise 3+ times per week" → Use SC-MINIMUM-FREQUENCY
- **Zero tolerance**: "No smoking" → Use SC-WEEKLY-ELIMINATION

## Validation Rules

1. **Baseline Day**: Must be ≥ 1 and ≤ total_days
2. **Variance Threshold**: Must be positive number
3. **Daily Weight**: Must be positive (typically 20.0 for 5-day goals, 14.3 for 7-day goals)
4. **Required Days**: Must be ≤ total_days
5. **Tracked Metrics**: Exactly one metric must be specified

## Testing

```python
def test_baseline_consistency():
    # Test wake time consistency
    daily_data = [
        {"day": 1, "wake_time": 420},  # 7:00 AM baseline
        {"day": 2, "wake_time": 440},  # 7:20 AM (within 30min)
        {"day": 3, "wake_time": 460},  # 7:40 AM (outside 30min)
        {"day": 4, "wake_time": 410},  # 6:50 AM (within 30min)
    ]
    
    config = {
        "schema": {
            "tracked_metrics": ["wake_time"],
            "baseline_day": 1,
            "variance_threshold": 30.0,
            "daily_weight": 25.0,
            "required_days": 4
        }
    }
    
    score, max_potential, details = calculate_baseline_consistency_score(daily_data, config)
    
    assert score == 75.0      # 3/4 compliant days (baseline + 2 others)
    assert max_potential == 100.0  # 4 days × 25.0 points
    assert details["successful_days"] == 3
    
    print("Baseline consistency tests passed!")
```

## Real-World Examples

### Wake Time Consistency
```json
{
  "config_id": "SC-BASELINE-CONSISTENCY-WAKE_TIME_30MIN",
  "recommendation_text": "Maintain consistent wake times within 30 minutes",
  "schema": {
    "tracked_metrics": ["wake_time"],
    "baseline_day": 1,
    "variance_threshold": 30.0,
    "unit": "minutes"
  }
}
```

### Weight Maintenance
```json
{
  "config_id": "SC-BASELINE-CONSISTENCY-WEIGHT_2LBS",
  "recommendation_text": "Keep weight stable within 2 pounds",
  "schema": {
    "tracked_metrics": ["body_weight"],
    "baseline_day": 1,
    "variance_threshold": 2.0,
    "unit": "pounds"
  }
}
```

### Workout Duration Consistency
```json
{
  "config_id": "SC-BASELINE-CONSISTENCY-WORKOUT_15MIN",
  "recommendation_text": "Maintain consistent workout duration",
  "schema": {
    "tracked_metrics": ["exercise_duration"],
    "baseline_day": 1,
    "variance_threshold": 15.0,
    "weekdays_only": true,
    "required_days": 5,
    "unit": "minutes"
  }
}
```

## Dual Progress Tracking

The algorithm supports progressive scoring showing cumulative adherence:

```python
# Day-by-day progress for wake time consistency
Day 1: 7:00 AM → 20.0% (baseline established, 1/5 days)
Day 2: 7:15 AM → 40.0% (within threshold, 2/5 days)  
Day 3: 8:00 AM → 40.0% (outside threshold, still 2/5 days)
Day 4: 6:50 AM → 60.0% (within threshold, 3/5 days)
Day 5: 7:05 AM → 80.0% (within threshold, 4/5 days)
```

## Algorithm Insights

### Innovation Points
1. **Baseline Flexibility**: Works with any user's natural patterns, not fixed targets
2. **Consistency Focus**: Rewards maintaining established habits rather than changing them
3. **Realistic Tolerance**: Allows for natural variance while promoting consistency
4. **Guaranteed Progress**: Baseline day always counts, preventing zero scores

### Clinical Applications
- **Circadian rhythm maintenance**: Sleep/wake consistency
- **Medication adherence**: Timing consistency more important than exact times
- **Weight management**: Stability goals rather than loss/gain targets
- **Habit reinforcement**: Maintaining established healthy routines

---

*For absolute target goals, see [SC-BINARY-THRESHOLD](binary-threshold.md)*  
*For improvement goals, see [SC-PROPORTIONAL](proportional.md)*  
*For weekend/weekday differences, see [SC-WEEKEND-VARIANCE](weekend-variance.md)*