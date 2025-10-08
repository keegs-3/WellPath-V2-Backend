"""
Categorical Filter Threshold Algorithm

Applies filtering based on categorical criteria before threshold evaluation.
Supports category-specific thresholds and scoring rules.
"""

from typing import Dict, Any, Union, List
from dataclasses import dataclass
from enum import Enum
from .binary_threshold import EvaluationPeriod, SuccessCriteria, CalculationMethod, ComparisonOperator


@dataclass
class CategoryFilter:
    """Represents a category filter with its criteria and thresholds."""
    category_name: str
    category_values: List[str]  # Values that match this category
    threshold: Union[float, int, bool]
    success_value: float = 100
    failure_value: float = 0
    comparison_operator: ComparisonOperator = ComparisonOperator.GTE
    weight: float = 1.0  # Weight for this category in composite scoring


@dataclass
class CategoricalFilterThresholdConfig:
    category_field: str  # Field name containing the category
    category_filters: List[CategoryFilter]
    default_threshold: Union[float, int, bool] = 0
    default_success_value: float = 50
    default_failure_value: float = 0
    measurement_type: str = "categorical"
    evaluation_period: EvaluationPeriod = EvaluationPeriod.DAILY
    success_criteria: SuccessCriteria = SuccessCriteria.SIMPLE_TARGET
    calculation_method: CalculationMethod = CalculationMethod.LAST_VALUE
    calculation_fields: Union[str, Dict[str, Any]] = "value"
    aggregation_method: str = "weighted_average"  # How to combine multiple category scores
    frequency_requirement: str = "daily"
    description: str = ""


class CategoricalFilterThresholdAlgorithm:
    """Categorical filter threshold algorithm implementation."""
    
    def __init__(self, config: CategoricalFilterThresholdConfig):
        self.config = config
        self._validate_categories()
    
    def calculate_score(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Calculate score based on categorical filtering and thresholds.
        
        Args:
            data: Dictionary containing category field and value field
            
        Returns:
            Dict containing score and detailed breakdown
        """
        category_value = data.get(self.config.category_field)
        measured_value = data.get("value", 0)
        
        if category_value is None:
            raise ValueError(f"Missing category field: {self.config.category_field}")
        
        # Find matching category filter
        matching_filter = self._find_matching_filter(category_value)
        
        if matching_filter:
            # Apply category-specific threshold
            score = self._calculate_threshold_score(
                measured_value, 
                matching_filter.threshold,
                matching_filter.success_value,
                matching_filter.failure_value,
                matching_filter.comparison_operator
            )
            
            return {
                "score": score,
                "matched_category": matching_filter.category_name,
                "category_value": category_value,
                "threshold_used": matching_filter.threshold,
                "measured_value": measured_value,
                "filter_applied": True
            }
        else:
            # Use default threshold
            score = self._calculate_threshold_score(
                measured_value,
                self.config.default_threshold,
                self.config.default_success_value,
                self.config.default_failure_value,
                ComparisonOperator.GTE
            )
            
            return {
                "score": score,
                "matched_category": "default",
                "category_value": category_value,
                "threshold_used": self.config.default_threshold,
                "measured_value": measured_value,
                "filter_applied": False
            }
    
    def calculate_multi_category_score(self, data_list: List[Dict[str, Any]]) -> Dict[str, Any]:
        """
        Calculate score for multiple categorical data points.
        
        Args:
            data_list: List of data dictionaries
            
        Returns:
            Aggregated score and breakdown
        """
        if not data_list:
            return {"score": 0, "breakdown": [], "error": "No data provided"}
        
        category_scores = []
        breakdown = []
        
        for data in data_list:
            result = self.calculate_score(data)
            category_scores.append({
                "score": result["score"],
                "weight": self._get_category_weight(result["matched_category"])
            })
            breakdown.append(result)
        
        # Aggregate scores based on method
        if self.config.aggregation_method == "weighted_average":
            total_weighted_score = sum(cs["score"] * cs["weight"] for cs in category_scores)
            total_weight = sum(cs["weight"] for cs in category_scores)
            final_score = total_weighted_score / total_weight if total_weight > 0 else 0
        
        elif self.config.aggregation_method == "simple_average":
            final_score = sum(cs["score"] for cs in category_scores) / len(category_scores)
        
        elif self.config.aggregation_method == "minimum":
            final_score = min(cs["score"] for cs in category_scores)
        
        elif self.config.aggregation_method == "maximum":
            final_score = max(cs["score"] for cs in category_scores)
        
        else:
            final_score = sum(cs["score"] for cs in category_scores) / len(category_scores)
        
        return {
            "score": final_score,
            "aggregation_method": self.config.aggregation_method,
            "categories_processed": len(data_list),
            "breakdown": breakdown
        }
    
    def _find_matching_filter(self, category_value: str) -> CategoryFilter:
        """Find the filter that matches the given category value."""
        for filter_config in self.config.category_filters:
            if category_value in filter_config.category_values:
                return filter_config
        return None
    
    def _calculate_threshold_score(
        self, 
        actual_value: Union[float, int, bool], 
        threshold: Union[float, int, bool],
        success_value: float,
        failure_value: float,
        comparison_operator: ComparisonOperator
    ) -> float:
        """Calculate binary threshold score."""
        meets_threshold = False
        
        # Handle None threshold
        if threshold is None:
            threshold = 0
        
        # Handle None actual_value
        if actual_value is None:
            actual_value = 0
        
        if comparison_operator == ComparisonOperator.GTE:
            meets_threshold = actual_value >= threshold
        elif comparison_operator == ComparisonOperator.GT:
            meets_threshold = actual_value > threshold
        elif comparison_operator == ComparisonOperator.EQ:
            meets_threshold = actual_value == threshold
        elif comparison_operator == ComparisonOperator.LT:
            meets_threshold = actual_value < threshold
        elif comparison_operator == ComparisonOperator.LTE:
            meets_threshold = actual_value <= threshold
        
        return success_value if meets_threshold else failure_value
    
    def _get_category_weight(self, category_name: str) -> float:
        """Get weight for a category."""
        if category_name == "default":
            return 1.0
        
        for filter_config in self.config.category_filters:
            if filter_config.category_name == category_name:
                return filter_config.weight
        
        return 1.0
    
    def calculate_dual_progress(self, daily_data: List[Dict[str, Any]], current_day: int) -> Dict[str, float]:
        """
        Calculate dual progress metrics for categorical filter threshold goals.
        
        Different logic based on evaluation period and threshold:
        - Daily goals (≤1): Track daily success rate (14.3% per successful day)
        - Weekly constraints (≤1): Any violation kills max potential
        - Elimination (≤0): Any violation = 0% forever
        """
        if current_day > len(daily_data):
            current_day = len(daily_data)
            
        if current_day == 0:
            return {
                'progress_towards_goal': 0.0,
                'max_potential_adherence': 100.0,
                'current_day': 0,
                'remaining_days': len(daily_data),
                'successful_days': 0
            }
        
        # Get evaluation period and threshold from first category filter
        evaluation_period = self.config.evaluation_period.value if hasattr(self.config.evaluation_period, 'value') else str(self.config.evaluation_period)
        threshold = self.config.category_filters[0].threshold if self.config.category_filters else 0
        
        # For weekly evaluation, also check frequency_requirement field
        if evaluation_period == 'daily' and hasattr(self.config, 'frequency_requirement'):
            if self.config.frequency_requirement == 'weekly':
                evaluation_period = 'weekly'
        
        # Calculate scores for completed days
        current_scores = []
        violation_occurred = False
        first_violation_day = None
        
        for day_idx in range(current_day):
            daily_data_point = daily_data[day_idx]
            result = self.calculate_score(daily_data_point)
            score = result['score']
            current_scores.append(score)
            
            # Track violations (score = 0 means threshold exceeded)
            if score == 0:
                violation_occurred = True
                if first_violation_day is None:
                    first_violation_day = day_idx + 1
        
        total_days = len(daily_data)
        remaining_days = total_days - current_day
        successful_days = sum(1 for score in current_scores if score >= 90)
        
        # Different logic based on goal type
        if threshold == 0:  # Elimination goals (REC0014.3)
            # Any violation = 0% progress and 0% potential forever
            if violation_occurred:
                return {
                    'progress_towards_goal': 0.0,
                    'max_potential_adherence': 0.0,
                    'successful_days': 0,
                    'current_day': current_day,
                    'remaining_days': remaining_days,
                    'violation_occurred': True,
                    'violation_day': first_violation_day
                }
            else:
                # No violations yet - progress is % of days completed successfully
                progress = (successful_days / total_days) * 100
                max_potential = 100.0  # Can still achieve 100% if no more violations
                
        elif evaluation_period in ['weekly', 'rolling_7_day'] or str(evaluation_period) == 'EvaluationPeriod.ROLLING_7_DAY':  # Weekly constraint goals (REC0014.2)
            # Calculate weekly total of unhealthy sources
            weekly_total = 0
            for day_idx in range(current_day):
                daily_data_point = daily_data[day_idx]
                weekly_total += daily_data_point.get('value', 0)
            
            # If already exceeded weekly limit, max potential becomes 0
            if weekly_total > threshold:
                max_potential = 0.0
                progress = 0.0
            else:
                # Still within weekly limit
                progress = 100.0 if current_day == total_days else (current_day / total_days) * 100
                
                # Calculate if weekly goal is still achievable
                remaining_capacity = threshold - weekly_total
                if remaining_capacity >= 0:
                    max_potential = 100.0
                else:
                    max_potential = 0.0
                    
        else:  # Daily goals (REC0014.1)
            # Each day is worth 100/7 = 14.3% toward the weekly goal
            progress = (successful_days / total_days) * 100
            
            # Max potential = what we've earned + what's still possible
            max_achievable_days = successful_days + remaining_days
            max_potential = min(100.0, (max_achievable_days / total_days) * 100)
        
        return {
            'progress_towards_goal': progress,
            'max_potential_adherence': max_potential,
            'successful_days': successful_days,
            'current_day': current_day,
            'remaining_days': remaining_days,
            'violation_occurred': violation_occurred,
            'violation_day': first_violation_day
        }
    
    def calculate_progressive_scores(self, daily_data: List[Dict[str, Any]]) -> List[float]:
        """
        Calculate progressive adherence scores as they would appear each day to the user.
        
        For categorical filter threshold: Each day is independent, shows that day's score.
        
        Args:
            daily_data: List of daily data dictionaries (7 days)
            
        Returns:
            List of progressive scores (what user sees each day)
        """
        progressive_scores = []
        
        for data in daily_data:
            result = self.calculate_score(data)
            progressive_scores.append(result['score'])
        
        return progressive_scores
    
    def _validate_categories(self):
        """Validate category filter configuration."""
        if not self.config.category_filters:
            raise ValueError("At least one category filter must be defined")
        
        # Check for duplicate category values across filters
        all_values = set()
        for filter_config in self.config.category_filters:
            for value in filter_config.category_values:
                if value in all_values:
                    raise ValueError(f"Duplicate category value: {value}")
                all_values.add(value)
        
        # Validate weights
        for filter_config in self.config.category_filters:
            if filter_config.weight < 0:
                raise ValueError(f"Category weight cannot be negative: {filter_config.category_name}")
    
    def validate_config(self) -> bool:
        """Validate the configuration parameters."""
        required_fields = ["category_field", "category_filters"]
        
        for field in required_fields:
            if not hasattr(self.config, field):
                raise ValueError(f"Missing required field: {field}")
        
        self._validate_categories()
        return True
    
    def get_formula(self) -> str:
        """Return the algorithm formula as a string."""
        return "filter_by_category(data) then apply_threshold(filtered_value)"
    
    def get_category_info(self) -> str:
        """Return information about all category filters."""
        info = []
        for filter_config in self.config.category_filters:
            values_str = ", ".join(filter_config.category_values)
            info.append(f"{filter_config.category_name}: [{values_str}] threshold={filter_config.threshold}")
        return "\n".join(info)


def create_daily_categorical_filter(
    category_field: str,
    category_filters: List[CategoryFilter],
    default_threshold: Union[float, int, bool] = 0,
    aggregation_method: str = "weighted_average",
    description: str = ""
) -> CategoricalFilterThresholdAlgorithm:
    """Create a daily categorical filter threshold algorithm."""
    config = CategoricalFilterThresholdConfig(
        category_field=category_field,
        category_filters=category_filters,
        default_threshold=default_threshold,
        aggregation_method=aggregation_method,
        evaluation_period=EvaluationPeriod.DAILY,
        description=description
    )
    return CategoricalFilterThresholdAlgorithm(config)


def create_frequency_categorical_filter(
    category_field: str,
    category_filters: List[CategoryFilter],
    frequency_requirement: str,
    default_threshold: Union[float, int, bool] = 0,
    aggregation_method: str = "weighted_average",
    description: str = ""
) -> CategoricalFilterThresholdAlgorithm:
    """Create a frequency-based categorical filter threshold algorithm."""
    config = CategoricalFilterThresholdConfig(
        category_field=category_field,
        category_filters=category_filters,
        default_threshold=default_threshold,
        aggregation_method=aggregation_method,
        evaluation_period=EvaluationPeriod.ROLLING_7_DAY,
        success_criteria=SuccessCriteria.FREQUENCY_TARGET,
        frequency_requirement=frequency_requirement,
        description=description
    )
    return CategoricalFilterThresholdAlgorithm(config)


def calculate_categorical_filter_threshold_dual_progress(
    daily_values: List[Union[float, int, Dict]], 
    current_day: int,
    **kwargs
) -> Dict[str, float]:
    """
    Calculate dual progress for categorical filter threshold goals
    
    Args:
        daily_values: List of daily measured values (may be dicts with category info)
        current_day: Current day (1-7)
        **kwargs: Parameters from config schema including target_categories, threshold, etc.
        
    Returns:
        Dict with progress_towards_goal and max_potential_adherence
    """
    from .binary_threshold import ComparisonOperator
    
    # Extract parameters from kwargs (from config schema)
    target_categories = kwargs.get('target_categories', [])
    threshold = kwargs.get('threshold', 1)
    comparison_operator = kwargs.get('comparison_operator', '<=')
    success_value = kwargs.get('success_value', 100)
    failure_value = kwargs.get('failure_value', 0)
    frequency_requirement = kwargs.get('frequency_requirement', 'daily')
    evaluation_period = kwargs.get('evaluation_period', 'daily')
    
    # Convert comparison operator string to enum
    if isinstance(comparison_operator, str):
        if comparison_operator == '<=':
            comp_op = ComparisonOperator.LTE
        elif comparison_operator == '>=':
            comp_op = ComparisonOperator.GTE
        elif comparison_operator == '<':
            comp_op = ComparisonOperator.LT
        elif comparison_operator == '>':
            comp_op = ComparisonOperator.GT
        elif comparison_operator == '==':
            comp_op = ComparisonOperator.EQ
        else:
            comp_op = ComparisonOperator.LTE
    else:
        comp_op = comparison_operator
    
    # Create a single category filter for the target categories
    # For this algorithm, we'll use a wildcard approach - match any category value
    # since we're already filtering by the unhealthy source count in the data
    filter_obj = CategoryFilter(
        category_name='target_filter',
        category_values=['caffeine_source_count', 'target_category'],  # Match both possible values
        threshold=threshold,
        success_value=success_value,
        failure_value=failure_value,
        comparison_operator=comp_op,
        weight=1.0
    )
    
    # Create config
    config = CategoricalFilterThresholdConfig(
        category_field='category',
        category_filters=[filter_obj],
        default_threshold=0,
        default_success_value=success_value,
        default_failure_value=failure_value,
        aggregation_method='weighted_average',
        frequency_requirement=frequency_requirement
    )
    
    # Set evaluation period
    if evaluation_period == 'weekly' or frequency_requirement == 'weekly':
        config.evaluation_period = EvaluationPeriod.ROLLING_7_DAY
    else:
        config.evaluation_period = EvaluationPeriod.DAILY
    
    # Convert daily_values to proper format for categorical algorithm
    daily_data = []
    for i, value in enumerate(daily_values):
        if isinstance(value, dict):
            # Use the dict directly, ensuring it has the right structure
            data_point = {
                'value': value.get('value', 0),
                'category': 'target_category',  # Use a fixed category that matches our filter
                **value  # Include original data for debugging
            }
            daily_data.append(data_point)
        else:
            # Create data point with count of target categories
            # For simplicity, assume the value represents unhealthy sources count
            daily_data.append({
                'value': value,
                'category': 'target_category'  # Will match the filter
            })
    
    algorithm = CategoricalFilterThresholdAlgorithm(config)
    return algorithm.calculate_dual_progress(daily_data, current_day)