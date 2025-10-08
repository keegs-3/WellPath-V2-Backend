"""
Baseline Consistency Algorithm

Day 1 sets the baseline sleep_time value. Each subsequent day within the variance threshold 
earns the specified daily weight percentage. Supports weekdays-only mode or all days.

Algorithm logic:
- Day 1 automatically provides the baseline and earns the first daily_weight percentage
- Each subsequent day within variance_threshold of Day 1 baseline earns daily_weight percentage
- Days outside the threshold earn 0%
- Final score is sum of all earned percentages

For weekdays-only mode:
- Only evaluates Monday-Friday (days 1-5)
- Weekend days are ignored in scoring

For all days mode:
- Evaluates all 7 days in the week
"""

from typing import Dict, List, Any, Tuple
import statistics
from datetime import datetime, timedelta


def calculate_baseline_consistency_score(
    daily_data: List[Dict[str, Any]], 
    config: Dict[str, Any]
) -> Tuple[float, float, Dict[str, Any]]:
    """
    Calculate baseline consistency score based on Day 1 baseline with variance checking.
    
    Args:
        daily_data: List of daily measurement dictionaries
        config: Algorithm configuration containing schema parameters
        
    Returns:
        Tuple of (progress_score, max_potential_score, details)
    """
    schema = config.get('schema', {})
    tracked_metrics = schema.get('tracked_metrics', [])
    
    if not tracked_metrics:
        return 0.0, 0.0, {"error": "No tracked metrics specified"}
    
    metric = tracked_metrics[0]
    baseline_day = schema.get('baseline_day', 1)
    variance_threshold = schema.get('variance_threshold', 60.0)
    comparison_operator = schema.get('comparison_operator', '<=')
    weekdays_only = schema.get('weekdays_only', False)
    daily_weight = schema.get('daily_weight', 20.0)
    required_days = schema.get('required_days', 5 if weekdays_only else 7)
    total_days = schema.get('total_days', 7)
    
    # Filter and sort data by day
    valid_data = []
    for day_data in daily_data:
        if metric in day_data and day_data[metric] is not None:
            valid_data.append(day_data)
    
    if len(valid_data) < baseline_day:
        return 0.0, daily_weight * required_days, {
            "error": f"Insufficient data: need at least {baseline_day} days for baseline",
            "available_days": len(valid_data)
        }
    
    # Sort by day to ensure proper ordering
    valid_data.sort(key=lambda x: x.get('day', 0))
    
    # Establish baseline from specified day (1-indexed)
    baseline_value = valid_data[baseline_day - 1][metric]
    
    # Calculate max potential (guaranteed baseline day + possible additional days)
    max_potential = daily_weight * required_days
    
    # Start with baseline day score (guaranteed)
    earned_score = daily_weight
    successful_days = 1
    day_details = []
    
    # Add baseline day to details
    day_details.append({
        "day": baseline_day,
        "value": baseline_value,
        "baseline": baseline_value,
        "variance": 0.0,
        "within_threshold": True,
        "score_earned": daily_weight,
        "is_baseline_day": True
    })
    
    # Evaluate remaining days
    evaluation_days = []
    if weekdays_only:
        # Only evaluate weekdays (days 1-5)
        evaluation_days = [i for i in range(1, min(6, len(valid_data) + 1)) if i != baseline_day]
    else:
        # Evaluate all available days except baseline day
        evaluation_days = [i for i in range(1, min(total_days + 1, len(valid_data) + 1)) if i != baseline_day]
    
    for day_num in evaluation_days:
        if day_num - 1 < len(valid_data):
            day_data = valid_data[day_num - 1]
            day_value = day_data[metric]
            variance = abs(day_value - baseline_value)
            
            # Check if within threshold
            within_threshold = False
            if comparison_operator == '<=':
                within_threshold = variance <= variance_threshold
            elif comparison_operator == '<':
                within_threshold = variance < variance_threshold
            elif comparison_operator == '>=':
                within_threshold = variance >= variance_threshold
            elif comparison_operator == '>':
                within_threshold = variance > variance_threshold
            
            score_earned = daily_weight if within_threshold else 0.0
            earned_score += score_earned
            
            if within_threshold:
                successful_days += 1
            
            day_details.append({
                "day": day_num,
                "value": day_value,
                "baseline": baseline_value,
                "variance": variance,
                "within_threshold": within_threshold,
                "score_earned": score_earned,
                "is_baseline_day": False
            })
    
    # Cap the earned score at max potential
    final_score = min(earned_score, max_potential)
    
    details = {
        "algorithm": "baseline_consistency",
        "baseline_day": baseline_day,
        "baseline_value": baseline_value,
        "variance_threshold": variance_threshold,
        "weekdays_only": weekdays_only,
        "daily_weight": daily_weight,
        "successful_days": successful_days,
        "total_evaluated_days": len(evaluation_days) + 1,  # +1 for baseline day
        "required_days": required_days,
        "day_details": day_details,
        "earned_score": earned_score,
        "final_score": final_score,
        "max_potential": max_potential
    }
    
    return final_score, max_potential, details


def baseline_consistency(daily_data: List[Dict[str, Any]], config: Dict[str, Any]) -> Dict[str, Any]:
    """
    Main entry point for baseline consistency algorithm.
    
    Args:
        daily_data: List of daily measurement data
        config: Full algorithm configuration
        
    Returns:
        Dictionary containing scores and algorithm details
    """
    progress_score, max_potential, details = calculate_baseline_consistency_score(daily_data, config)
    
    return {
        "progress_score": progress_score,
        "max_potential_score": max_potential,
        "algorithm_details": details,
        "scoring_method": "baseline_consistency"
    }


def calculate_baseline_consistency_dual_progress(
    daily_values: List[float], 
    current_day: int, 
    **schema_params
) -> Dict[str, Any]:
    """
    Calculate dual progress for baseline consistency algorithm day by day.
    
    Args:
        daily_values: List of daily metric values  
        current_day: Current day (1-7)
        **schema_params: Schema parameters from config
        
    Returns:
        Dictionary with progress_towards_goal and max_potential_adherence
    """
    # Extract parameters
    baseline_day = schema_params.get('baseline_day', 1)
    variance_threshold = schema_params.get('variance_threshold', 60.0)
    comparison_operator = schema_params.get('comparison_operator', '<=')
    weekdays_only = schema_params.get('weekdays_only', False)
    daily_weight = schema_params.get('daily_weight', 20.0)
    required_days = schema_params.get('required_days', 5 if weekdays_only else 7)
    
    # Maximum possible score
    max_potential = daily_weight * required_days
    
    # Can't have progress before baseline day
    if current_day < baseline_day:
        return {
            'progress_towards_goal': 0.0,
            'max_potential_adherence': max_potential
        }
    
    # Get baseline value from baseline day
    baseline_value = daily_values[baseline_day - 1]
    
    # Start with baseline day score (guaranteed)
    earned_score = daily_weight
    
    # Evaluate days up to current_day
    evaluation_days = []
    if weekdays_only:
        # Only evaluate weekdays (days 1-5)
        evaluation_days = [i for i in range(1, min(6, current_day + 1)) if i != baseline_day]
    else:
        # Evaluate all days except baseline day
        evaluation_days = [i for i in range(1, current_day + 1) if i != baseline_day]
    
    for day_num in evaluation_days:
        if day_num - 1 < len(daily_values):
            day_value = daily_values[day_num - 1]
            variance = abs(day_value - baseline_value)
            
            # Check if within threshold
            within_threshold = False
            if comparison_operator == '<=':
                within_threshold = variance <= variance_threshold
            elif comparison_operator == '<':
                within_threshold = variance < variance_threshold
            elif comparison_operator == '>=':
                within_threshold = variance >= variance_threshold
            elif comparison_operator == '>':
                within_threshold = variance > variance_threshold
            
            if within_threshold:
                earned_score += daily_weight
    
    # Cap at max potential
    final_progress = min(earned_score, max_potential)
    
    return {
        'progress_towards_goal': final_progress,
        'max_potential_adherence': max_potential
    }