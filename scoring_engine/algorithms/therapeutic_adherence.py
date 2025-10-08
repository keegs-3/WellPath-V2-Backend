#!/usr/bin/env python3
"""
Therapeutic Adherence Algorithm

Tracks adherence to therapeutic interventions (supplements, peptides, medications)
with support for stacked therapeutics (1-3 per recommendation) and complex dosing schedules.

Algorithm Logic:
- Each therapeutic has its own adherence tracking
- Overall recommendation adherence = average of all therapeutics in the stack
- Supports daily, weekly, and custom frequency patterns
- Handles min/max dosage ranges with compliance validation
- Status: scheduled/taken/missed/skipped compliance tracking
"""

def calculate_therapeutic_adherence_dual_progress(daily_values, current_day, therapeutics_config=None, **kwargs):
    """
    Calculate dual progress for therapeutic adherence recommendations.
    
    Args:
        daily_values (list): Daily therapeutic compliance data
        current_day (int): Current day in the tracking period
        therapeutics_config (dict): Configuration for 1-3 therapeutics in stack
        **kwargs: Additional parameters
    
    Returns:
        dict: Dual progress results with therapeutic-specific details
    """
    
    if not daily_values or current_day < 1:
        return {
            'progress_towards_goal': 0.0,
            'max_potential_adherence': 100.0,
            'algorithm_details': {
                'algorithm_type': 'therapeutic_adherence',
                'therapeutics_count': len(therapeutics_config.get('therapeutics', [])) if therapeutics_config else 0,
                'current_status': 'no_data'
            }
        }
    
    # Parse therapeutics configuration
    therapeutics = therapeutics_config.get('therapeutics', []) if therapeutics_config else []
    if not therapeutics:
        # Fallback for single therapeutic
        therapeutics = [{'name': 'therapeutic', 'frequency': 'daily'}]
    
    # Calculate current progress
    current_index = min(current_day - 1, len(daily_values) - 1)
    current_data = daily_values[current_index] if daily_values else {}
    
    # Handle different data formats
    if isinstance(current_data, dict):
        adherence_scores = []
        therapeutic_details = {}
        
        for i, therapeutic in enumerate(therapeutics, 1):
            therapeutic_key = f'therapeutic_{i}'
            therapeutic_status = current_data.get(therapeutic_key, 'scheduled')
            
            # Calculate adherence for this therapeutic
            therapeutic_adherence = calculate_single_therapeutic_adherence(
                therapeutic_status, therapeutic
            )
            adherence_scores.append(therapeutic_adherence['adherence_percent'])
            therapeutic_details[therapeutic_key] = therapeutic_adherence
        
        # Overall adherence is average of all therapeutics
        if adherence_scores:
            progress = sum(adherence_scores) / len(adherence_scores)
        else:
            progress = 0.0
            
    else:
        # Simple format fallback
        progress = 100.0 if str(current_data).lower() in ['taken', 'compliant', '1', 'true'] else 0.0
        therapeutic_details = {'therapeutic_1': {'status': current_data, 'adherence_percent': progress}}
    
    # Calculate potential adherence
    total_days = len(daily_values)
    if current_day >= total_days:
        # End of tracking period
        potential = progress
    else:
        # Still time to improve
        days_completed = current_day
        days_remaining = total_days - current_day
        
        # Current progress weighted by days completed
        current_contribution = (progress * days_completed) / total_days
        
        # Assume perfect adherence for remaining days
        future_contribution = (100.0 * days_remaining) / total_days
        
        potential = current_contribution + future_contribution
    
    return {
        'progress_towards_goal': round(progress, 1),
        'max_potential_adherence': round(min(potential, 100.0), 1),
        'algorithm_details': {
            'algorithm_type': 'therapeutic_adherence',
            'therapeutics_count': len(therapeutics),
            'therapeutic_breakdown': therapeutic_details,
            'current_day': current_day,
            'total_days': total_days
        }
    }


def calculate_single_therapeutic_adherence(status, therapeutic_config):
    """Calculate adherence for a single therapeutic within a stack."""
    
    frequency = therapeutic_config.get('frequency', 'daily')
    
    adherence_mapping = {
        'taken': 100.0,
        'compliant': 100.0,
        'scheduled': 0.0,
        'missed': 0.0,
        'skipped': 0.0,  # Intentionally skipped
        'partial': 50.0,  # Partial dose taken
        'late': 80.0,     # Taken late but within window
        'early': 90.0,    # Taken early
        'not_due': 100.0  # Not scheduled today (still compliant)
    }
    
    # Handle numeric values (legacy support)
    if isinstance(status, (int, float)):
        adherence_percent = float(status) * 100 if status <= 1 else min(float(status), 100.0)
    else:
        adherence_percent = adherence_mapping.get(str(status).lower(), 0.0)
    
    return {
        'status': status,
        'adherence_percent': adherence_percent,
        'frequency': frequency,
        'therapeutic_name': therapeutic_config.get('name', 'unknown')
    }


def calculate_therapeutic_adherence_score(daily_values, therapeutics_config=None, **kwargs):
    """
    Calculate final score for therapeutic adherence recommendation.
    
    Args:
        daily_values (list): Daily therapeutic compliance data
        therapeutics_config (dict): Configuration for therapeutics stack
        **kwargs: Additional parameters
    
    Returns:
        dict: Final scoring results
    """
    
    if not daily_values:
        return {
            'final_score': 0.0,
            'adherence_summary': 'no_data',
            'algorithm_type': 'therapeutic_adherence'
        }
    
    therapeutics = therapeutics_config.get('therapeutics', []) if therapeutics_config else []
    total_scores = []
    therapeutic_breakdown = {}
    
    for day_data in daily_values:
        if isinstance(day_data, dict):
            # Multi-therapeutic day
            day_scores = []
            
            for i, therapeutic in enumerate(therapeutics, 1):
                therapeutic_key = f'therapeutic_{i}'
                therapeutic_status = day_data.get(therapeutic_key, 'missed')
                
                therapeutic_adherence = calculate_single_therapeutic_adherence(
                    therapeutic_status, therapeutic
                )
                day_scores.append(therapeutic_adherence['adherence_percent'])
                
                # Track individual therapeutic performance
                if therapeutic_key not in therapeutic_breakdown:
                    therapeutic_breakdown[therapeutic_key] = []
                therapeutic_breakdown[therapeutic_key].append(therapeutic_adherence['adherence_percent'])
            
            # Average across therapeutics for this day
            if day_scores:
                daily_average = sum(day_scores) / len(day_scores)
                total_scores.append(daily_average)
        else:
            # Single value format
            single_adherence = calculate_single_therapeutic_adherence(day_data, therapeutics[0] if therapeutics else {})
            total_scores.append(single_adherence['adherence_percent'])
    
    # Calculate overall score
    if total_scores:
        final_score = sum(total_scores) / len(total_scores)
    else:
        final_score = 0.0
    
    # Determine adherence summary
    if final_score >= 90:
        adherence_summary = 'excellent'
    elif final_score >= 80:
        adherence_summary = 'good'
    elif final_score >= 70:
        adherence_summary = 'fair'
    elif final_score >= 50:
        adherence_summary = 'poor'
    else:
        adherence_summary = 'very_poor'
    
    # Calculate individual therapeutic performance
    therapeutic_scores = {}
    for therapeutic_key, scores in therapeutic_breakdown.items():
        if scores:
            therapeutic_scores[therapeutic_key] = {
                'average_adherence': sum(scores) / len(scores),
                'days_tracked': len(scores),
                'days_compliant': len([s for s in scores if s >= 90])
            }
    
    return {
        'final_score': round(final_score, 1),
        'adherence_summary': adherence_summary,
        'algorithm_type': 'therapeutic_adherence',
        'total_days': len(daily_values),
        'therapeutic_breakdown': therapeutic_scores,
        'days_with_perfect_adherence': len([score for score in total_scores if score >= 100]),
        'consistency_score': calculate_consistency_score(total_scores)
    }


def calculate_consistency_score(scores):
    """Calculate how consistent the adherence has been (lower variance = higher consistency)."""
    if len(scores) < 2:
        return 100.0
    
    import statistics
    
    try:
        mean_score = statistics.mean(scores)
        variance = statistics.variance(scores)
        
        # Convert variance to consistency score (0-100)
        # Lower variance = higher consistency
        if variance == 0:
            return 100.0
        
        # Normalize variance to consistency score
        consistency = max(0, 100 - (variance / 10))
        return round(consistency, 1)
    except:
        return 50.0  # Default moderate consistency


def generate_therapeutic_adherence_config(therapeutics_data, recommendation_data):
    """
    Generate algorithm configuration for therapeutic adherence recommendations.
    
    Args:
        therapeutics_data (list): List of 1-3 therapeutics with dosing info
        recommendation_data (dict): Recommendation metadata
    
    Returns:
        dict: Complete algorithm configuration
    """
    
    # Build therapeutics configuration
    therapeutics_config = []
    for i, therapeutic in enumerate(therapeutics_data, 1):
        therapeutic_config = {
            'name': therapeutic.get('name', f'therapeutic_{i}'),
            'type': therapeutic.get('type', 'supplement'),
            'dose_min': therapeutic.get('dose_min'),
            'dose_max': therapeutic.get('dose_max'),
            'unit': therapeutic.get('unit'),
            'unit_symbol': therapeutic.get('unit_symbol'),
            'dose_display': therapeutic.get('rollup', ''),
            'frequency': therapeutic.get('frequency', 'daily'),
            'route': therapeutic.get('route', 'oral'),
            'timing': therapeutic.get('timing', 'with_meal')
        }
        therapeutics_config.append(therapeutic_config)
    
    # Generate schema
    schema = {
        'measurement_type': 'therapeutic_adherence',
        'evaluation_period': 'daily',
        'success_criteria': 'adherence_percentage',
        'calculation_method': 'multi_therapeutic_average',
        'therapeutics': therapeutics_config,
        'therapeutics_count': len(therapeutics_config),
        'target_adherence': 90.0,  # 90% adherence target
        'unit': 'percent',
        'progress_direction': 'maximize',
        'required_days': None,  # Ongoing
        'total_days': 30,  # Default 30-day tracking
        'description': f"Adherence tracking for {len(therapeutics_config)} therapeutic intervention(s)"
    }
    
    # Generate full configuration
    config = {
        'config_id': recommendation_data.get('config_id'),
        'config_name': recommendation_data.get('config_name'),
        'scoring_method': 'therapeutic_adherence',
        'configuration_json': {
            'method': 'therapeutic_adherence',
            'formula': f"Average adherence across {len(therapeutics_config)} therapeutic(s)",
            'evaluation_pattern': 'daily_multi_therapeutic',
            'schema': schema
        },
        'metadata': {
            'recommendation_text': recommendation_data.get('level_description', ''),
            'recommendation_id': recommendation_data.get('recommendation_id'),
            'analysis': {
                'algorithm_type': 'therapeutic_adherence',
                'confidence': 1.0,
                'reasoning': f'Multi-therapeutic adherence tracking for {len(therapeutics_config)} intervention(s)'
            },
            'therapeutics_details': therapeutics_config,
            'generated_at': None,  # Will be set during generation
            'title': recommendation_data.get('title', ''),
            'overview': recommendation_data.get('overview', '')
        }
    }
    
    return config