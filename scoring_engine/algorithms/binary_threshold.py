"""
Binary Threshold Scoring Algorithm

Evaluates whether a measured value meets or exceeds a threshold.
Returns success_value if threshold is met, failure_value otherwise.
"""

from typing import Dict, Any, Union, List
from dataclasses import dataclass
from enum import Enum


class ComparisonOperator(Enum):
    GTE = ">="
    GT = ">"
    EQ = "="
    LT = "<"
    LTE = "<="


class EvaluationPeriod(Enum):
    DAILY = "daily"
    ROLLING_7_DAY = "rolling_7_day"


class SuccessCriteria(Enum):
    SIMPLE_TARGET = "simple_target"
    FREQUENCY_TARGET = "frequency_target"


class CalculationMethod(Enum):
    SUM = "sum"
    AVERAGE = "average"
    DIFFERENCE = "difference"
    COUNT = "count"
    MAX = "max"
    MIN = "min"
    LAST_VALUE = "last_value"
    EXISTS = "exists"


@dataclass
class BinaryThresholdConfig:
    threshold: Union[float, int, bool]
    success_value: float = 100
    failure_value: float = 0
    measurement_type: str = "binary"
    evaluation_period: EvaluationPeriod = EvaluationPeriod.DAILY
    success_criteria: SuccessCriteria = SuccessCriteria.SIMPLE_TARGET
    calculation_method: CalculationMethod = CalculationMethod.EXISTS
    calculation_fields: Union[str, Dict[str, Any]] = "value"
    comparison_operator: ComparisonOperator = ComparisonOperator.GTE
    frequency_requirement: str = "daily"
    description: str = ""


class BinaryThresholdAlgorithm:
    """Binary threshold scoring algorithm implementation."""
    
    def __init__(self, config: BinaryThresholdConfig):
        self.config = config
    
    def calculate_score(self, actual_value: Union[float, int, bool]) -> float:
        """
        Calculate score based on binary threshold logic.
        
        Args:
            actual_value: The measured value to evaluate
            
        Returns:
            Score (success_value or failure_value)
        """
        if self._meets_threshold(actual_value):
            return self.config.success_value
        else:
            return self.config.failure_value
    
    def _meets_threshold(self, actual_value: Union[float, int, bool]) -> bool:
        """Check if actual value meets the threshold criteria."""
        threshold = self.config.threshold
        operator = self.config.comparison_operator
        
        if operator == ComparisonOperator.GTE:
            return actual_value >= threshold
        elif operator == ComparisonOperator.GT:
            return actual_value > threshold
        elif operator == ComparisonOperator.EQ:
            return actual_value == threshold
        elif operator == ComparisonOperator.LT:
            return actual_value < threshold
        elif operator == ComparisonOperator.LTE:
            return actual_value <= threshold
        else:
            raise ValueError(f"Unknown comparison operator: {operator}")
    
    def validate_config(self) -> bool:
        """Validate the configuration parameters."""
        required_fields = [
            "threshold", "success_value", "failure_value", 
            "measurement_type", "evaluation_period", "success_criteria",
            "calculation_method", "calculation_fields"
        ]
        
        for field in required_fields:
            if not hasattr(self.config, field):
                raise ValueError(f"Missing required field: {field}")
        
        return True
    
    def calculate_dual_progress(self, daily_values: List[Union[float, int]], current_day: int) -> Dict[str, float]:
        """
        Calculate dual progress metrics for binary threshold goals.
        
        Handles both daily and weekly evaluation patterns.
        """
        if current_day > len(daily_values):
            current_day = len(daily_values)
            
        # Check if this is a weekly constraint (like "≤3 servings per week")
        is_weekly_constraint = (
            (hasattr(self.config, 'frequency_requirement') and 
             'weekly' in str(self.config.frequency_requirement).lower()) or
            (hasattr(self.config, 'calculation_method') and 
             'weekly' in str(self.config.calculation_method).lower())
        )
        
        if is_weekly_constraint and self.config.comparison_operator in [ComparisonOperator.LTE, ComparisonOperator.LT]:
            # Weekly constraint goal - track progressive consumption vs limit
            weekly_total = sum(daily_values[:current_day])
            threshold = self.config.threshold
            
            if weekly_total > threshold:
                # Exceeded limit - failed
                progress_towards_goal = 0.0
                max_potential_adherence = 0.0
            else:
                # Still within limit - show progress as percentage of limit used
                # But goal is to stay ≤ limit, so successful completion = staying within bounds
                # Progress should reflect "safe consumption" within limits
                total_week_days = len(daily_values)
                days_completed = current_day
                
                # Progress = days completed without violation / total days
                progress_towards_goal = (days_completed / total_week_days) * 100
                
                # Max potential = 100% if we can stay within limit for remaining days
                remaining_days = total_week_days - current_day
                max_potential_adherence = 100.0 if remaining_days >= 0 else progress_towards_goal
                
            return {
                'progress_towards_goal': progress_towards_goal,
                'max_potential_adherence': max_potential_adherence,
                'weekly_total': weekly_total,
                'weekly_limit': threshold,
                'constraint_violated': weekly_total > threshold,
                'remaining_allowance': max(0, threshold - weekly_total)
            }
        else:
            # Daily goal - use daily weighting system
            total_week_days = len(daily_values)
            successful_days = 0
            
            for day_idx in range(current_day):
                daily_value = daily_values[day_idx]
                if self._meets_threshold(daily_value):
                    successful_days += 1
            
            progress_towards_goal = (successful_days / total_week_days) * 100
            
            # Max potential: assume remaining days are successful
            remaining_days = total_week_days - current_day
            max_possible_successes = successful_days + remaining_days
            max_potential_adherence = (max_possible_successes / total_week_days) * 100
            
            return {
                'progress_towards_goal': progress_towards_goal,
                'max_potential_adherence': max_potential_adherence,
                'successful_days': successful_days,
                'current_day': current_day,
                'remaining_days': remaining_days
            }
    
    def calculate_progressive_scores(self, daily_values: List[Union[float, int]]) -> List[float]:
        """
        Calculate progressive adherence scores as they would appear each day to the user.
        
        For buildup goals (>=): Shows that day's performance.
        For countdown/limit goals (<=): Shows 100% as long as weekly goal is still achievable.
        
        Args:
            daily_values: List of daily measured values (7 days)
            
        Returns:
            List of progressive scores (what user sees each day)
        """
        progressive_scores = []
        
        # For daily goals, always show that day's actual performance
        # Progressive scoring = that day's binary result (100% or 0%)
        for value in daily_values:
            score = self.calculate_score(value)
            progressive_scores.append(score)
        
        return progressive_scores
    
    def get_formula(self) -> str:
        """Return the algorithm formula as a string."""
        op = self.config.comparison_operator.value
        return f"if (actual_value {op} {self.config.threshold}) then {self.config.success_value} else {self.config.failure_value}"


def create_daily_binary_threshold(
    threshold: Union[float, int, bool],
    success_value: float = 100,
    failure_value: float = 0,
    comparison_operator: str = ">=",
    description: str = ""
) -> BinaryThresholdAlgorithm:
    """Create a daily binary threshold algorithm."""
    config = BinaryThresholdConfig(
        threshold=threshold,
        success_value=success_value,
        failure_value=failure_value,
        comparison_operator=ComparisonOperator(comparison_operator),
        evaluation_period=EvaluationPeriod.DAILY,
        description=description
    )
    return BinaryThresholdAlgorithm(config)


def create_frequency_binary_threshold(
    threshold: Union[float, int, bool],
    frequency_requirement: str,
    success_value: float = 100,
    failure_value: float = 0,
    comparison_operator: str = ">=",
    description: str = ""
) -> BinaryThresholdAlgorithm:
    """Create a frequency-based binary threshold algorithm."""
    config = BinaryThresholdConfig(
        threshold=threshold,
        success_value=success_value,
        failure_value=failure_value,
        comparison_operator=ComparisonOperator(comparison_operator),
        evaluation_period=EvaluationPeriod.ROLLING_7_DAY,
        success_criteria=SuccessCriteria.FREQUENCY_TARGET,
        frequency_requirement=frequency_requirement,
        description=description
    )
    return BinaryThresholdAlgorithm(config)

def calculate_binary_threshold_dual_progress(
    daily_values: List[Union[float, int]], 
    current_day: int,
    threshold: float,
    **kwargs
) -> Dict[str, float]:
    from .binary_threshold import BinaryThresholdAlgorithm, BinaryThresholdConfig, ComparisonOperator, EvaluationPeriod, CalculationMethod
    
    # Map comparison operators
    comparison_op = kwargs.get('comparison_operator', '>=')
    if comparison_op == '>=':
        comp_op = ComparisonOperator.GTE
    elif comparison_op == '<=':
        comp_op = ComparisonOperator.LTE
    elif comparison_op == '>':
        comp_op = ComparisonOperator.GT
    elif comparison_op == '<':
        comp_op = ComparisonOperator.LT
    elif comparison_op == '==':
        comp_op = ComparisonOperator.EQ
    else:
        comp_op = ComparisonOperator.GTE
    
    config = BinaryThresholdConfig(
        threshold=threshold,
        success_value=kwargs.get('success_value', 100),
        failure_value=kwargs.get('failure_value', 0),
        comparison_operator=comp_op,
        evaluation_period=EvaluationPeriod.ROLLING_7_DAY if kwargs.get('evaluation_period') == 'weekly' else EvaluationPeriod.DAILY,
        calculation_method=CalculationMethod.SUM if kwargs.get('calculation_method') == 'weekly_sum' else CalculationMethod.EXISTS,
        frequency_requirement=kwargs.get('frequency_requirement', 'daily')
    )
    algorithm = BinaryThresholdAlgorithm(config)
    return algorithm.calculate_dual_progress(daily_values, current_day)

