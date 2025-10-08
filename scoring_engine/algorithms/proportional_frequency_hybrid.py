"""
Proportional Frequency Hybrid Algorithm

Combines proportional daily scoring with frequency-based weekly evaluation.
Solves the issue where partial progress gets no credit in frequency patterns.
"""

from typing import Dict, Any, List, Union, Tuple
from dataclasses import dataclass
from .binary_threshold import EvaluationPeriod, SuccessCriteria, CalculationMethod


@dataclass
class ProportionalFrequencyHybridConfig:
    required_qualifying_days: int
    unit: str
    measurement_type: str = "hybrid_quantity_frequency"
    evaluation_period: EvaluationPeriod = EvaluationPeriod.ROLLING_7_DAY
    success_criteria: SuccessCriteria = SuccessCriteria.FREQUENCY_TARGET
    calculation_method: CalculationMethod = CalculationMethod.SUM
    daily_minimum_threshold: float = 0
    total_days: int = 7
    minimum_threshold: float = 0
    maximum_cap: float = 100
    partial_credit: bool = True
    progress_direction: str = "buildup"
    description: str = ""
    
    # Accept either daily_target or daily_threshold
    daily_target: float = None
    daily_threshold: float = None
    daily_comparison: str = ">="  # Default for buildup goals
    
    def __post_init__(self):
        """Validate that either daily_target or daily_threshold is provided"""
        if self.daily_target is None and self.daily_threshold is None:
            raise ValueError("Either daily_target or daily_threshold must be provided")
        if self.daily_target is not None and self.daily_threshold is not None:
            raise ValueError("Cannot provide both daily_target and daily_threshold")
    
    @property
    def target_value(self) -> float:
        """Get the target/threshold value regardless of which parameter was used"""
        return self.daily_target if self.daily_target is not None else self.daily_threshold
    
    @property
    def is_threshold_goal(self) -> bool:
        """Check if this is a threshold goal (like sedentary time) vs target goal (like steps)"""
        return self.daily_threshold is not None


class ProportionalFrequencyHybridAlgorithm:
    """Proportional Frequency Hybrid scoring algorithm implementation."""
    
    def __init__(self, config: ProportionalFrequencyHybridConfig):
        self.config = config
        self._validate_config()
    
    def _validate_config(self):
        """Validate configuration parameters."""
        if self.config.target_value <= 0:
            raise ValueError("daily_target or daily_threshold must be greater than 0")
        
        if self.config.required_qualifying_days <= 0:
            raise ValueError("required_qualifying_days must be greater than 0")
        
        if self.config.required_qualifying_days > self.config.total_days:
            raise ValueError("required_qualifying_days cannot exceed total_days")
        
        if self.config.daily_minimum_threshold < 0:
            raise ValueError("daily_minimum_threshold must be >= 0")
    
    def calculate_daily_score(self, actual_value: Union[float, int, Dict]) -> float:
        """
        Calculate proportional score for a single day.
        
        Args:
            actual_value: The measured value to evaluate for one day
                         Can be a number (for direct comparison) or dict (for ratio comparison)
            
        Returns:
            Score as percentage of daily target (0-100)
        """
        if hasattr(self.config, 'comparison_mode') and self.config.comparison_mode == 'metric_ratio':
            # Handle ratio comparison (like whole_food_meals / total_meals)
            if isinstance(actual_value, dict):
                numerator = actual_value.get('comparison_metric', 0)
                denominator = actual_value.get('primary_metric', 1)
                
                if denominator <= 0:
                    return 0.0
                    
                ratio = numerator / denominator
                percentage = ratio * 100  # Convert ratio to percentage
                return min(percentage, self.config.maximum_cap)
            else:
                return 0.0
        else:
            # Standard numeric comparison
            if isinstance(actual_value, dict):
                actual_value = actual_value.get('primary_metric', 0)
            
            # Handle threshold vs target goals
            if self.config.is_threshold_goal:
                # Threshold goals (like sedentary time): binary pass/fail
                if self.config.daily_comparison == "<=":
                    return 100.0 if actual_value <= self.config.target_value else 0.0
                elif self.config.daily_comparison == "<":
                    return 100.0 if actual_value < self.config.target_value else 0.0
                elif self.config.daily_comparison == ">=":
                    return 100.0 if actual_value >= self.config.target_value else 0.0
                elif self.config.daily_comparison == ">":
                    return 100.0 if actual_value > self.config.target_value else 0.0
                else:
                    return 0.0
            else:
                # Target goals (like steps): proportional scoring
                if actual_value <= 0:
                    return 0.0
                
                # Calculate base percentage
                percentage = (actual_value / self.config.target_value) * 100
                
                # Apply maximum cap
                return min(percentage, self.config.maximum_cap)
    
    def calculate_weekly_score(self, daily_values: List[Union[float, int]]) -> float:
        """
        Calculate weekly score using proportional frequency hybrid method.
        
        Args:
            daily_values: List of measured values for each day (length should match total_days)
            
        Returns:
            Weekly score as percentage (0-100)
        """
        if len(daily_values) != self.config.total_days:
            raise ValueError(f"Expected {self.config.total_days} daily values, got {len(daily_values)}")
        
        # Calculate daily scores
        daily_scores = [self.calculate_daily_score(value) for value in daily_values]
        
        # Filter qualifying days (above minimum threshold)
        if hasattr(self.config, 'comparison_mode') and self.config.comparison_mode == 'metric_ratio':
            # For ratio comparison, include all days
            qualifying_data = [
                (score, value) 
                for score, value in zip(daily_scores, daily_values)
            ]
        else:
            qualifying_data = [
                (score, value) 
                for score, value in zip(daily_scores, daily_values) 
                if value >= self.config.daily_minimum_threshold
            ]
        
        # Check if we have enough qualifying days
        if len(qualifying_data) < self.config.required_qualifying_days:
            return self.config.minimum_threshold
        
        # Sort by score descending and take top N
        qualifying_data.sort(key=lambda x: x[0], reverse=True)
        top_scores = [score for score, _ in qualifying_data[:self.config.required_qualifying_days]]
        
        # Calculate average of top qualifying days
        weekly_score = sum(top_scores) / len(top_scores)
        
        # Apply minimum threshold and maximum cap
        weekly_score = max(weekly_score, self.config.minimum_threshold)
        weekly_score = min(weekly_score, self.config.maximum_cap)
        
        return weekly_score
    
    def calculate_progressive_scores(self, daily_values: List[Union[float, int]]) -> List[float]:
        """
        Calculate progressive adherence scores as they would appear each day to the user.
        
        For proportional frequency hybrid: Shows 100% as long as weekly goal is still achievable.
        
        Args:
            daily_values: List of daily measured values (7 days)
            
        Returns:
            List of progressive scores (what user sees each day)
        """
        progressive_scores = []
        
        for day_idx in range(len(daily_values)):
            # Calculate current qualifying days up to this point
            current_values = daily_values[:day_idx + 1]
            if hasattr(self.config, 'comparison_mode') and self.config.comparison_mode == 'metric_ratio':
                # For ratio comparison, count all days (no minimum threshold)
                qualifying_count = len(current_values)
            else:
                qualifying_count = sum(1 for value in current_values if value >= self.config.daily_minimum_threshold)
            
            remaining_days = len(daily_values) - (day_idx + 1)
            can_still_achieve = (qualifying_count + remaining_days) >= self.config.required_qualifying_days
            
            if qualifying_count >= self.config.required_qualifying_days:
                progressive_scores.append(100.0)  # Already achieved
            elif can_still_achieve:
                progressive_scores.append(100.0)  # Still possible
            else:
                progressive_scores.append(0.0)   # Impossible now
        
        return progressive_scores
    
    def calculate_dual_progress(self, daily_values: List[Union[float, int]], current_day: int) -> Dict[str, float]:
        """
        Calculate dual progress metrics for proportional frequency hybrid goals.
        
        For hybrid goals combining proportional scoring with frequency requirements:
        - Progress: Current average of qualifying days (or projected if few days)
        - Potential: Best possible weekly score if remaining days perform optimally
        """
        if current_day > len(daily_values):
            current_day = len(daily_values)
            
        if current_day == 0:
            return {
                'progress_towards_goal': 0.0,
                'max_potential_adherence': 100.0,
                'qualifying_days_so_far': 0,
                'required_qualifying_days': self.config.required_qualifying_days,
                'current_day': 0,
                'remaining_days': len(daily_values)
            }
        
        # Calculate current daily scores and qualifying days
        current_values = daily_values[:current_day]
        current_daily_scores = [self.calculate_daily_score(value) for value in current_values]
        
        # Count qualifying days so far
        if hasattr(self.config, 'comparison_mode') and self.config.comparison_mode == 'metric_ratio':
            # For ratio comparison, include all days (partial credit for all ratios)
            qualifying_data = [
                (score, value) 
                for score, value in zip(current_daily_scores, current_values)
            ]
        else:
            # Standard threshold filtering
            qualifying_data = [
                (score, value) 
                for score, value in zip(current_daily_scores, current_values) 
                if value >= self.config.daily_minimum_threshold
            ]
        
        qualifying_days_so_far = len(qualifying_data)
        
        # Progress calculation - each day contributes (daily_score / required_days) to weekly goal
        # Each day can contribute max (100% / required_days) to weekly goal
        max_daily_contribution = 100.0 / self.config.required_qualifying_days
        
        # Calculate daily contributions (daily_score / required_days), capped at max
        daily_contributions = []
        for score in current_daily_scores:
            contribution = score / self.config.required_qualifying_days
            capped_contribution = min(contribution, max_daily_contribution)
            daily_contributions.append(capped_contribution)
        
        # Take the top X contributions
        daily_contributions.sort(reverse=True)  # Best contributions first
        top_contributions = daily_contributions[:self.config.required_qualifying_days]
        
        # Sum the top contributions for current progress
        progress_towards_goal = sum(top_contributions)
        
        # Max potential calculation - assume remaining days achieve max daily contribution
        remaining_days = len(daily_values) - current_day
        all_potential_contributions = daily_contributions.copy()
        
        # Add max daily contributions for remaining days
        all_potential_contributions.extend([max_daily_contribution] * remaining_days)
        
        # Take top X contributions for potential calculation
        all_potential_contributions.sort(reverse=True)
        top_potential_contributions = all_potential_contributions[:self.config.required_qualifying_days]
        
        # Sum the top potential contributions
        max_potential_adherence = sum(top_potential_contributions)
        
        return {
            'progress_towards_goal': progress_towards_goal,
            'max_potential_adherence': max_potential_adherence,
            'qualifying_days_so_far': qualifying_days_so_far,
            'required_qualifying_days': self.config.required_qualifying_days,
            'current_day': current_day,
            'remaining_days': remaining_days,
            'can_still_achieve': (qualifying_days_so_far + remaining_days) >= self.config.required_qualifying_days
        }
    
    def get_daily_breakdown(self, daily_values: List[Union[float, int]]) -> Dict[str, Any]:
        """
        Get detailed breakdown of daily and weekly scoring.
        
        Args:
            daily_values: List of measured values for each day
            
        Returns:
            Dictionary with daily scores, qualifying days, and weekly result
        """
        if len(daily_values) != self.config.total_days:
            raise ValueError(f"Expected {self.config.total_days} daily values, got {len(daily_values)}")
        
        # Calculate daily scores
        daily_scores = [self.calculate_daily_score(value) for value in daily_values]
        
        # Identify qualifying days
        qualifying_days = []
        for i, (score, value) in enumerate(zip(daily_scores, daily_values)):
            if value >= self.config.daily_minimum_threshold:
                qualifying_days.append({
                    'day': i + 1,
                    'value': value,
                    'score': score,
                    'qualifies': True
                })
            else:
                qualifying_days.append({
                    'day': i + 1,
                    'value': value,
                    'score': score,
                    'qualifies': False
                })
        
        # Sort qualifying days by score and identify top performers
        qualifying_only = [day for day in qualifying_days if day['qualifies']]
        qualifying_only.sort(key=lambda x: x['score'], reverse=True)
        top_days = qualifying_only[:self.config.required_qualifying_days]
        
        # Calculate weekly score
        weekly_score = self.calculate_weekly_score(daily_values)
        
        return {
            'daily_breakdown': qualifying_days,
            'total_qualifying_days': len(qualifying_only),
            'required_qualifying_days': self.config.required_qualifying_days,
            'top_performing_days': top_days,
            'weekly_score': weekly_score,
            'target_met': len(qualifying_only) >= self.config.required_qualifying_days
        }


def create_proportional_frequency_hybrid(
    daily_target: float,
    required_qualifying_days: int,
    unit: str,
    daily_minimum_threshold: float = 0,
    total_days: int = 7,
    maximum_cap: float = 100,
    minimum_threshold: float = 0,
    description: str = ""
) -> ProportionalFrequencyHybridAlgorithm:
    """
    Factory function to create a proportional frequency hybrid algorithm.
    
    Args:
        daily_target: Target value for 100% daily score
        required_qualifying_days: Number of top days to average for weekly score
        unit: Measurement unit
        daily_minimum_threshold: Minimum value to qualify as valid day
        total_days: Total evaluation period length
        maximum_cap: Maximum weekly score cap
        minimum_threshold: Minimum weekly score floor
        description: Description of the algorithm instance
        
    Returns:
        Configured ProportionalFrequencyHybridAlgorithm instance
    """
    config = ProportionalFrequencyHybridConfig(
        daily_target=daily_target,
        required_qualifying_days=required_qualifying_days,
        unit=unit,
        daily_minimum_threshold=daily_minimum_threshold,
        total_days=total_days,
        minimum_threshold=minimum_threshold,
        maximum_cap=maximum_cap,
        description=description
    )
    
    return ProportionalFrequencyHybridAlgorithm(config)


def calculate_proportional_frequency_hybrid_dual_progress(
    daily_values: List[Union[float, int]], 
    current_day: int,
    **kwargs
) -> Dict[str, float]:
    """
    Calculate dual progress for proportional frequency hybrid goals
    
    Args:
        daily_values: List of daily measured values
        current_day: Current day (1-7)
        **kwargs: Additional parameters from config schema
        
    Returns:
        Dict with progress_towards_goal and max_potential_adherence
    """
    # Extract parameters - accept either daily_target or daily_threshold
    daily_target = kwargs.get('daily_target')
    daily_threshold = kwargs.get('daily_threshold')
    required_qualifying_days = kwargs.get('required_qualifying_days')
    unit = kwargs.get('unit', 'units')
    
    if not required_qualifying_days:
        raise ValueError("required_qualifying_days is required")
    
    # Create temporary config and algorithm instance
    config = ProportionalFrequencyHybridConfig(
        required_qualifying_days=required_qualifying_days,
        unit=unit,
        daily_target=daily_target,
        daily_threshold=daily_threshold,
        daily_comparison=kwargs.get('daily_comparison', '>='),
        daily_minimum_threshold=kwargs.get('daily_minimum_threshold', 0),
        total_days=kwargs.get('total_days', 7),
        minimum_threshold=kwargs.get('minimum_threshold', 0),
        maximum_cap=kwargs.get('maximum_cap', 100),
        partial_credit=kwargs.get('partial_credit', True),
        progress_direction=kwargs.get('progress_direction', 'buildup')
    )
    
    algorithm = ProportionalFrequencyHybridAlgorithm(config)
    return algorithm.calculate_dual_progress(daily_values, current_day)