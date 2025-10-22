# Minimum Frequency Algorithm

## Overview

**Minimum Frequency** scores based on achieving a threshold on a minimum number of days within a weekly evaluation period. Success requires meeting the criteria on at least X days per week.

## Algorithm Type

- **Pattern**: Minimum Achievement Frequency
- **Evaluation Period**: Weekly (7 days)
- **Scoring**: Binary (100 or 0)
- **Logic**: Count successful days, compare to minimum requirement

## Formula

```python
def calculate_minimum_frequency_score(daily_values, daily_threshold, daily_comparison, required_days):
    """
    Calculate score based on minimum days meeting threshold per week
    
    Args:
        daily_values: List of daily measurements for the week [day1, day2, ..., day7]
        daily_threshold: The threshold value for each day
        daily_comparison: Comparison operator ("<=", ">=", "==")
        required_days: Minimum number of days that must meet threshold
    
    Returns:
        100 if successful_days >= required_days, else 0
    """
    successful_days = 0
    
    for daily_value in daily_values:
        if daily_comparison == "<=":
            if daily_value <= daily_threshold:
                successful_days += 1
        elif daily_comparison == ">=":
            if daily_value >= daily_threshold:
                successful_days += 1
        elif daily_comparison == "==":
            if daily_value == daily_threshold:
                successful_days += 1
    
    return 100 if successful_days >= required_days else 0
```

## Use Cases

### Exercise Frequency

- **Goal**: Exercise for 30+ minutes on at least 3 days per week
- **Logic**: Count days where `daily_exercise_minutes >= 30`
- **Success**: If count >= 3 days → Score = 100
- **Failure**: If count < 3 days → Score = 0

### Food Limitation

- **Goal**: Limit ultra-processed foods to ≤1 serving on at least 2 days per week
- **Logic**: Count days where `dietary_ultraprocessed_meals <= 1`
- **Success**: If count >= 2 days → Score = 100
- **Failure**: If count < 2 days → Score = 0

## Configuration Examples

### Basic Exercise Configuration

```json
{
  "config_id": "SC-MIN-FREQ-EXERCISE_30MIN_3DAYS",
  "scoring_method": "minimum_frequency",
  "schema": {
    "daily_threshold": 30,
    "daily_comparison": ">=",
    "required_days": 3,
    "total_days": 7
  }
}
```

### Food Quality Configuration

```json
{
  "config_id": "SC-MIN-FREQ-LIMIT_PROCESSED_2DAYS",
  "scoring_method": "minimum_frequency",
  "schema": {
    "daily_threshold": 1,
    "daily_comparison": "<=",
    "required_days": 2,
    "total_days": 7
  }
}
```

## Behavioral Science

This algorithm type is ideal for:

- **Habit Formation**: Building consistent behaviors without perfection pressure
- **Sustainable Changes**: Allows flexibility while maintaining minimum standards
- **Realistic Goals**: Recognizes that 100% compliance isn't always feasible
- **Progress Tracking**: Clear binary feedback on weekly achievement

## Related Algorithms

- [Weekly Elimination](SC-WEEKLY-ELIMINATION.md) - For elimination goals
- [Proportional Frequency Hybrid](proportional-frequency-hybrid.md) - For partial credit
- [Binary Threshold](binary-threshold.md) - For daily requirements