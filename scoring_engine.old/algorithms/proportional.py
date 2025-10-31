"""
Proportional Scoring Algorithm

Calculates score as (actual_value / target) * 100
Supports minimum thresholds, maximum caps, and partial credit.
"""

from typing import Dict, Any, Union, List
from dataclasses import dataclass
from .binary_threshold import EvaluationPeriod, SuccessCriteria, CalculationMethod


@dataclass
class ProportionalConfig:
    target: float
    unit: str
    measurement_type: str = "count"
    evaluation_period: EvaluationPeriod = EvaluationPeriod.DAILY
    success_criteria: SuccessCriteria = SuccessCriteria.SIMPLE_TARGET
    calculation_method: CalculationMethod = CalculationMethod.SUM
    calculation_fields: Union[str, Dict[str, Any]] = "value"
    minimum_threshold: float = 0
    maximum_cap: float = 100
    partial_credit: bool = True
    frequency_requirement: str = "daily"
    description: str = ""
    daily_limit: float = None  # Maximum allowed per day (None = no limit)


class ProportionalAlgorithm:
    """Proportional scoring algorithm implementation."""
    
    def __init__(self, config: ProportionalConfig):
        self.config = config
        
    def calculate_dual_progress(self, daily_values: List[Union[float, int]], current_day: int) -> Dict[str, float]:
        """
        Calculate dual progress metrics for proportional goals.
        
        Uses daily weighting system:
        - Daily completion = actual_value / daily_target
        - Weekly progress = sum of (daily_completion × 1/7) for completed days
        """
        if current_day > len(daily_values):
            current_day = len(daily_values)
            
        total_week_days = len(daily_values)  # Usually 7
        
        # Check if this is weekly evaluation or daily evaluation  
        is_weekly = (self.config.evaluation_period == EvaluationPeriod.ROLLING_7_DAY or
                    'weekly' in self.config.frequency_requirement.lower())
        
        if is_weekly:
            # Weekly cumulative target (like "90 minutes per week")
            # Apply daily limit enforcement if specified
            capped_values = []
            for value in daily_values[:current_day]:
                if self.config.daily_limit is not None:
                    capped_values.append(min(value, self.config.daily_limit))
                else:
                    capped_values.append(value)
            current_total = sum(capped_values)
            weekly_target = self.config.target
            progress_towards_goal = min((current_total / weekly_target) * 100, 100.0)
            
            # For weekly goals, once target is achieved, max potential is also capped
            remaining_days = total_week_days - current_day
            
            if current_total >= weekly_target:
                # Already achieved target - potential is capped at 100%
                max_potential_adherence = 100.0
            elif remaining_days > 0:
                # Could theoretically achieve full target if remaining days are optimal
                max_potential_adherence = 100.0
            else:
                # Final day - max potential is current achievement (capped at 100%)
                max_potential_adherence = min(progress_towards_goal, 100.0)
        else:
            # Daily targets - use daily weighting system
            daily_target = self.config.target
            progress_sum = 0.0
            
            for day_idx in range(current_day):
                daily_value = daily_values[day_idx]
                # Apply daily limit enforcement if specified
                if self.config.daily_limit is not None:
                    daily_value = min(daily_value, self.config.daily_limit)
                daily_completion = min(daily_value / daily_target, 1.0)  # Cap at 100%
                progress_sum += daily_completion * (1 / total_week_days)
            
            progress_towards_goal = progress_sum * 100
            
            # Max potential: assume remaining days achieve 100%
            remaining_days = total_week_days - current_day
            max_possible_additional = remaining_days * (1 / total_week_days)
            max_potential_adherence = (progress_sum + max_possible_additional) * 100
        
        return {
            'progress_towards_goal': progress_towards_goal,
            'max_potential_adherence': max_potential_adherence,
            'current_day': current_day,
            'remaining_days': remaining_days,
            'total_days': total_week_days
        }
    
    def calculate_score(self, actual_value: Union[float, int]) -> float:
        """
        Calculate proportional score.
        
        Args:
            actual_value: The measured value to evaluate
            
        Returns:
            Score as percentage of target (0-100, or up to maximum_cap)
        """
        if self.config.target <= 0:
            raise ValueError("Target must be greater than 0")
        
        # Calculate base percentage
        percentage = (actual_value / self.config.target) * 100
        
        # Apply minimum threshold
        if percentage < self.config.minimum_threshold:
            return self.config.minimum_threshold if self.config.partial_credit else 0
        
        # Apply maximum cap
        return min(percentage, self.config.maximum_cap)
    
    def calculate_progressive_scores(self, daily_values: List[Union[float, int]]) -> List[float]:
        """
        Calculate progressive adherence scores as they would appear each day to the user.
        
        For daily evaluation: Each day shows that day's score independently.
        For weekly evaluation: Each day shows cumulative progress toward weekly target.
        
        Args:
            daily_values: List of daily measured values (7 days)
            
        Returns:
            List of progressive scores (what user sees each day)
        """
        progressive_scores = []
        
        # Check if this is weekly evaluation
        is_weekly = (self.config.evaluation_period == EvaluationPeriod.ROLLING_7_DAY or
                    'weekly' in self.config.frequency_requirement.lower())
        
        if is_weekly:
            # Weekly evaluation: show cumulative progress toward weekly target
            cumulative_total = 0
            for value in daily_values:
                cumulative_total += value
                cumulative_score = min((cumulative_total / self.config.target) * 100, self.config.maximum_cap)
                progressive_scores.append(max(cumulative_score, self.config.minimum_threshold))
        else:
            # Daily evaluation: each day is independent
            for value in daily_values:
                score = self.calculate_score(value)
                progressive_scores.append(score)
        
        return progressive_scores
    
    def validate_config(self) -> bool:
        """Validate the configuration parameters."""
        required_fields = [
            "target", "unit", "measurement_type", "evaluation_period",
            "success_criteria", "calculation_method", "calculation_fields"
        ]
        
        for field in required_fields:
            if not hasattr(self.config, field):
                raise ValueError(f"Missing required field: {field}")
        
        if self.config.target <= 0:
            raise ValueError("Target must be greater than 0")
        
        if self.config.minimum_threshold < 0:
            raise ValueError("Minimum threshold cannot be negative")
        
        if self.config.maximum_cap < self.config.minimum_threshold:
            raise ValueError("Maximum cap cannot be less than minimum threshold")
        
        return True
    
    def get_formula(self) -> str:
        """Return the algorithm formula as a string."""
        return f"(actual_value / {self.config.target}) * 100"


def create_daily_proportional(
    target: float,
    unit: str,
    minimum_threshold: float = 0,
    maximum_cap: float = 100,
    partial_credit: bool = True,
    description: str = ""
) -> ProportionalAlgorithm:
    """Create a daily proportional algorithm."""
    config = ProportionalConfig(
        target=target,
        unit=unit,
        minimum_threshold=minimum_threshold,
        maximum_cap=maximum_cap,
        partial_credit=partial_credit,
        evaluation_period=EvaluationPeriod.DAILY,
        description=description
    )
    return ProportionalAlgorithm(config)


def create_frequency_proportional(
    target: float,
    unit: str,
    frequency_requirement: str,
    minimum_threshold: float = 0,
    maximum_cap: float = 100,
    partial_credit: bool = True,
    description: str = ""
) -> ProportionalAlgorithm:
    """Create a frequency-based proportional algorithm."""
    config = ProportionalConfig(
        target=target,
        unit=unit,
        minimum_threshold=minimum_threshold,
        maximum_cap=maximum_cap,
        partial_credit=partial_credit,
        evaluation_period=EvaluationPeriod.ROLLING_7_DAY,
        success_criteria=SuccessCriteria.FREQUENCY_TARGET,
        frequency_requirement=frequency_requirement,
        description=description
    )
    return ProportionalAlgorithm(config)


def calculate_proportional_dual_progress(
    daily_values: List[Union[float, int]], 
    current_day: int,
    target: float,
    unit: str = "units",
    **kwargs
) -> Dict[str, float]:
    """
    Calculate dual progress for proportional goals
    
    Args:
        daily_values: List of daily measured values
        current_day: Current day (1-7)
        target: Target value for proportional scoring
        unit: Unit of measurement
        **kwargs: Additional parameters from config schema
        
    Returns:
        Dict with progress_towards_goal and max_potential_adherence
    """
    # Map evaluation period
    eval_period = kwargs.get('evaluation_period', 'daily')
    if eval_period in ['weekly', 'rolling_7_day']:
        evaluation_period = EvaluationPeriod.ROLLING_7_DAY
    else:
        evaluation_period = EvaluationPeriod.DAILY
    
    # Create temporary config and algorithm instance
    config = ProportionalConfig(
        target=target,
        unit=unit,
        evaluation_period=evaluation_period,
        frequency_requirement=kwargs.get('frequency_requirement', 'weekly'),
        minimum_threshold=kwargs.get('minimum_threshold', 0),
        maximum_cap=kwargs.get('maximum_cap', 100),
        partial_credit=kwargs.get('partial_credit', True),
        daily_limit=kwargs.get('daily_limit')
    )
    
    algorithm = ProportionalAlgorithm(config)
    return algorithm.calculate_dual_progress(daily_values, current_day)