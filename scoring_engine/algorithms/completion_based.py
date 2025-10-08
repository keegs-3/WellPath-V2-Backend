#!/usr/bin/env python3
"""
Completion Based Algorithm
=========================

The simplest algorithm for one-time screening/completion tasks.

Purpose:
- Track completion of screening recommendations (dental cleanings, mammograms, etc.)
- Once completed in the 90-day cycle, shows 100% for remainder of cycle
- Only generated for patients already out of compliance

Key Features:
- Binary completion: 0% (not done) or 100% (completed)
- Persistent progress: stays 100% after completion
- Leverages existing compliance calculated metrics

Usage:
- Recommendations only generated for overdue patients
- Uses compliance calculated metrics (e.g., current_compliance_dental_male_female_0_150_avg_custom_calc)
- Tracks completion within current 90-day recommendation cycle
"""

def calculate_completion_based_dual_progress(daily_values, current_day, calculated_metric=None, **kwargs):
    """
    Calculate dual progress for completion-based screening recommendations.
    
    Args:
        daily_values (list): Daily compliance status values from calculated metric
        current_day (int): Current day in the period (1-based)
        calculated_metric (str): Name of compliance calculated metric to track
        **kwargs: Additional parameters (unused for this simple algorithm)
    
    Returns:
        dict: Contains progress_towards_goal and max_potential_adherence
        
    Algorithm Logic:
        - Since recommendations are only given to out-of-compliance patients
        - Start of cycle: 0% progress (they're overdue)
        - Once completed: 100% progress (and stays 100% for rest of 90-day cycle)
        - Max potential is always 100% (can always complete during cycle)
    """
    
    # Ensure we have data
    if not daily_values or current_day < 1:
        return {
            'progress_towards_goal': 0.0,
            'max_potential_adherence': 100.0,
            'algorithm_details': {
                'algorithm_type': 'completion_based',
                'completion_status': 'no_data',
                'calculated_metric': calculated_metric
            }
        }
    
    # Get current compliance status from calculated metric
    current_index = min(current_day - 1, len(daily_values) - 1)
    current_status = daily_values[current_index] if daily_values else "overdue"
    
    # Determine completion based on compliance status
    if current_status == "compliant":
        # Patient completed the screening during this cycle
        progress = 100.0
        potential = 100.0  # Stays at 100% for remainder of cycle
        completion_status = "completed"
    else:
        # Patient has not yet completed (still overdue/due_soon)
        progress = 0.0
        
        # For demo purposes (7-day week), check if we're at the end
        # In real 90-day cycles, this would check if we're at day 90
        total_days = len(daily_values)
        if current_day >= total_days:
            # End of period - if still not completed, potential drops to 0
            potential = 0.0
        else:
            # Still time left in the cycle to complete
            potential = 100.0
            
        completion_status = "pending"
    
    return {
        'progress_towards_goal': progress,
        'max_potential_adherence': potential,
        'algorithm_details': {
            'algorithm_type': 'completion_based',
            'completion_status': completion_status,
            'current_compliance_status': current_status,
            'calculated_metric': calculated_metric,
            'cycle_day': current_day
        }
    }


def calculate_completion_based_score(daily_values, calculated_metric=None, **kwargs):
    """
    Calculate final score for completion-based algorithm.
    
    Args:
        daily_values (list): Daily compliance status values
        calculated_metric (str): Name of compliance calculated metric
        **kwargs: Additional parameters
    
    Returns:
        dict: Final scoring results
    """
    
    if not daily_values:
        return {
            'final_score': 0.0,
            'completion_status': 'no_data',
            'algorithm_type': 'completion_based'
        }
    
    # Check if completed at any point during the cycle
    completed = any(status == "compliant" for status in daily_values if status)
    
    final_score = 100.0 if completed else 0.0
    
    return {
        'final_score': final_score,
        'completion_status': 'completed' if completed else 'not_completed',
        'algorithm_type': 'completion_based',
        'calculated_metric': calculated_metric,
        'total_days_evaluated': len(daily_values)
    }


# Algorithm metadata for registration
ALGORITHM_INFO = {
    'name': 'completion_based',
    'description': 'Simple completion tracking for screening recommendations',
    'category': 'screening',
    'complexity': 'minimal',
    'use_cases': [
        'Dental cleanings',
        'Mammograms', 
        'Colonoscopies',
        'Vision checkups',
        'Any one-time screening task'
    ],
    'required_parameters': [
        'calculated_metric'  # The compliance calculated metric to track
    ],
    'optional_parameters': [],
    'data_requirements': {
        'daily_values': 'Compliance status from calculated metric (compliant/overdue/due_soon)',
        'evaluation_period': 'cycle',  # 90-day recommendation cycle
        'calculation_method': 'completion_check'
    }
}