"""
Weekend Variance Algorithm

Days 1-5 (weekdays) establish the baseline sleep_time_consistency. These days contribute 
100% to max potential but 0% to progress (baseline establishment phase).

Days 6-7 (weekend) are scored against the established baseline:
- Both weekend days within variance threshold = 100% progress
- One weekend day within threshold = 50% progress  
- No weekend days within threshold = 0% progress

Algorithm logic:
- Days 1-5: Calculate average sleep_time to establish baseline (0% progress, 100% potential)
- Days 6-7: Compare each day against baseline with variance threshold
- Weekend day scoring: weekend_day_weight per successful day
- Final progress score based on weekend performance only
"""

from typing import Dict, List, Any, Tuple
import statistics
from datetime import datetime, timedelta


def calculate_weekend_variance_score(
    daily_data: List[Dict[str, Any]], 
    config: Dict[str, Any]
) -> Tuple[float, float, Dict[str, Any]]:
    """
    Calculate weekend variance score based on weekday baseline establishment.
    
    Args:
        daily_data: List of daily measurement dictionaries
        config: Algorithm configuration containing schema parameters
        
    Returns:
        Tuple of (progress_score, max_potential_score, details)
    """
    schema = config.get('schema', {})
    tracked_metrics = schema.get('tracked_metrics', [])
    calculated_metrics = schema.get('calculated_metrics', [])
    
    if not tracked_metrics:
        return 0.0, 0.0, {"error": "No tracked metrics specified"}
    
    metric = tracked_metrics[0]
    weekday_baseline_days = schema.get('weekday_baseline_days', 5)
    weekend_days = schema.get('weekend_days', 2)
    variance_threshold = schema.get('variance_threshold', 90.0)
    comparison_operator = schema.get('comparison_operator', '<=')
    weekend_day_weight = schema.get('weekend_day_weight', 50.0)
    total_days = schema.get('total_days', 7)
    
    # Filter and sort data by day
    valid_data = []
    for day_data in daily_data:
        if metric in day_data and day_data[metric] is not None:
            valid_data.append(day_data)
    
    if len(valid_data) < weekday_baseline_days:
        return 0.0, 100.0, {
            "error": f"Insufficient weekday data: need {weekday_baseline_days} days for baseline",
            "available_days": len(valid_data)
        }
    
    # Sort by day to ensure proper ordering
    valid_data.sort(key=lambda x: x.get('day', 0))
    
    # Extract weekday data (days 1-5)
    weekday_data = valid_data[:weekday_baseline_days]
    weekday_values = [day[metric] for day in weekday_data]
    
    # Calculate baseline from weekdays (this creates sleep_time_consistency)
    baseline_value = statistics.mean(weekday_values)
    
    # Max potential is always 100%
    max_potential = 100.0
    
    # Weekdays contribute 0% to progress (baseline establishment only)
    progress_score = 0.0
    successful_weekend_days = 0
    
    # Prepare details for weekdays
    day_details = []
    for i, day_data in enumerate(weekday_data, 1):
        day_details.append({
            "day": i,
            "value": day_data[metric],
            "baseline": baseline_value,
            "variance": None,  # Not applicable for baseline days
            "within_threshold": None,  # Not applicable for baseline days
            "score_earned": 0.0,  # Always 0 for baseline establishment
            "is_baseline_day": True,
            "day_type": "weekday"
        })
    
    # Evaluate weekend days (days 6-7)
    weekend_start_idx = weekday_baseline_days
    available_weekend_days = min(weekend_days, len(valid_data) - weekend_start_idx)
    
    for i in range(available_weekend_days):
        day_idx = weekend_start_idx + i
        day_num = day_idx + 1
        day_data = valid_data[day_idx]
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
        
        score_earned = weekend_day_weight if within_threshold else 0.0
        progress_score += score_earned
        
        if within_threshold:
            successful_weekend_days += 1
        
        day_details.append({
            "day": day_num,
            "value": day_value,
            "baseline": baseline_value,
            "variance": variance,
            "within_threshold": within_threshold,
            "score_earned": score_earned,
            "is_baseline_day": False,
            "day_type": "weekend"
        })
    
    # Handle missing weekend days
    for i in range(available_weekend_days, weekend_days):
        day_num = weekend_start_idx + i + 1
        day_details.append({
            "day": day_num,
            "value": None,
            "baseline": baseline_value,
            "variance": None,
            "within_threshold": False,
            "score_earned": 0.0,
            "is_baseline_day": False,
            "day_type": "weekend",
            "missing": True
        })
    
    # Cap progress score at 100%
    final_score = min(progress_score, max_potential)
    
    details = {
        "algorithm": "weekend_variance",
        "baseline_value": baseline_value,
        "baseline_calculation": "mean of weekday values",
        "weekday_values": weekday_values,
        "variance_threshold": variance_threshold,
        "weekend_day_weight": weekend_day_weight,
        "successful_weekend_days": successful_weekend_days,
        "total_weekend_days": weekend_days,
        "available_weekend_days": available_weekend_days,
        "weekday_baseline_days": weekday_baseline_days,
        "day_details": day_details,
        "progress_score": progress_score,
        "final_score": final_score,
        "max_potential": max_potential,
        "calculated_metrics": {
            "sleep_time_consistency": baseline_value
        } if calculated_metrics else {}
    }
    
    return final_score, max_potential, details


def weekend_variance(daily_data: List[Dict[str, Any]], config: Dict[str, Any]) -> Dict[str, Any]:
    """
    Main entry point for weekend variance algorithm.
    
    Args:
        daily_data: List of daily measurement data
        config: Full algorithm configuration
        
    Returns:
        Dictionary containing scores and algorithm details
    """
    progress_score, max_potential, details = calculate_weekend_variance_score(daily_data, config)
    
    return {
        "progress_score": progress_score,
        "max_potential_score": max_potential,
        "algorithm_details": details,
        "scoring_method": "weekend_variance"
    }


def calculate_weekend_variance_dual_progress(
    daily_values: List[float], 
    current_day: int, 
    **schema_params
) -> Dict[str, Any]:
    """
    Calculate dual progress for weekend variance algorithm day by day.
    
    Args:
        daily_values: List of daily metric values  
        current_day: Current day (1-7)
        **schema_params: Schema parameters from config
        
    Returns:
        Dictionary with progress_towards_goal and max_potential_adherence
    """
    # Extract parameters
    weekday_baseline_days = schema_params.get('weekday_baseline_days', 5)
    weekend_days = schema_params.get('weekend_days', 2)
    variance_threshold = schema_params.get('variance_threshold', 90.0)
    comparison_operator = schema_params.get('comparison_operator', '<=')
    weekend_day_weight = schema_params.get('weekend_day_weight', 50.0)
    
    # Max potential is always 100%
    max_potential = 100.0
    
    # During baseline establishment phase (days 1-5), no progress but full potential
    if current_day <= weekday_baseline_days:
        return {
            'progress_towards_goal': 0.0,
            'max_potential_adherence': max_potential
        }
    
    # Calculate baseline from weekdays (days 1-5)
    import statistics
    weekday_values = daily_values[:weekday_baseline_days]
    baseline_value = statistics.mean(weekday_values)
    
    # Evaluate weekend days (days 6-7) up to current_day
    progress_score = 0.0
    weekend_start_idx = weekday_baseline_days
    
    for day_idx in range(weekend_start_idx, min(current_day, weekday_baseline_days + weekend_days)):
        day_value = daily_values[day_idx]
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
            progress_score += weekend_day_weight
    
    # Cap progress at max potential
    final_progress = min(progress_score, max_potential)
    
    return {
        'progress_towards_goal': final_progress,
        'max_potential_adherence': max_potential
    }