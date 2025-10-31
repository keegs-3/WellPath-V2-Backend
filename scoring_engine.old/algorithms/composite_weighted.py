"""
Composite Weighted Scoring Algorithm

Calculates weighted average of multiple components.
Each component can have its own scoring method and weight.
"""

from typing import Dict, Any, Union, List
from dataclasses import dataclass
from .binary_threshold import EvaluationPeriod, SuccessCriteria, CalculationMethod


@dataclass
class Component:
    """Represents a component in a composite score."""
    name: str
    weight: float
    target: Union[float, int]
    unit: str
    scoring_method: str  # "proportional", "binary", "zone"
    field_name: str
    parameters: Dict[str, Any] = None  # Additional parameters for the scoring method
    
    def __post_init__(self):
        if self.parameters is None:
            self.parameters = {}


@dataclass
class CompositeWeightedConfig:
    components: List[Component]
    measurement_type: str = "composite"
    evaluation_period: EvaluationPeriod = EvaluationPeriod.DAILY
    success_criteria: SuccessCriteria = SuccessCriteria.SIMPLE_TARGET
    calculation_method: str = "weighted_average"
    calculation_fields: Dict[str, Any] = None
    minimum_threshold: float = 0
    maximum_cap: float = 100
    frequency_requirement: str = "daily"
    description: str = ""
    calculation_notes: Dict[str, Any] = None
    
    def __post_init__(self):
        if self.calculation_fields is None:
            self.calculation_fields = {}
        if self.calculation_notes is None:
            self.calculation_notes = {}


class CompositeWeightedAlgorithm:
    """Composite weighted scoring algorithm implementation."""
    
    def __init__(self, config: CompositeWeightedConfig):
        self.config = config
        self._validate_weights()
        
    def calculate_dual_progress(self, daily_values: List[Union[float, int]], current_day: int) -> Dict[str, float]:
        """
        Calculate dual progress metrics for composite weighted goals.
        
        For composite goals, we treat it as a weekly cumulative target:
        - Progress: Current weekly total vs weekly target  
        - Potential: Current total + remaining potential
        """
        if current_day > len(daily_values):
            current_day = len(daily_values)
            
        # Calculate current achievement (sum of daily values)
        current_total = sum(daily_values[:current_day])
        
        # Weekly target for composite scoring: 7 days * 100 (perfect daily composite score)
        weekly_target = 700
        
        # Progress towards goal
        progress_towards_goal = (current_total / weekly_target) * 100
        
        # Max potential - assume remaining days hit perfect composite score (100)
        remaining_days = len(daily_values) - current_day
        max_possible_additional = remaining_days * 100  # Perfect composite score per remaining day
            
        max_possible_total = current_total + max_possible_additional
        max_potential_adherence = min(100, (max_possible_total / weekly_target) * 100)
        
        return {
            'progress_towards_goal': progress_towards_goal,
            'max_potential_adherence': max_potential_adherence,
            'current_total': current_total,
            'weekly_target': weekly_target,
            'remaining_days': remaining_days,
            'components_count': len(self.config.components)
        }
    
    def calculate_score(self, component_values: Dict[str, Union[float, int]]) -> float:
        """
        Calculate weighted composite score.
        
        Args:
            component_values: Dict mapping component field_names to their values
            
        Returns:
            Weighted composite score (0-100, or up to maximum_cap)
        """
        total_weighted_score = 0.0
        total_weight = 0.0
        
        for component in self.config.components:
            if component.field_name not in component_values:
                raise ValueError(f"Missing value for component: {component.field_name}")
            
            value = component_values[component.field_name]
            component_score = self._calculate_component_score(component, value)
            
            total_weighted_score += component_score * component.weight
            total_weight += component.weight
        
        if total_weight == 0:
            return 0.0
        
        # Calculate weighted average
        composite_score = total_weighted_score / total_weight
        
        # Apply bounds
        composite_score = max(composite_score, self.config.minimum_threshold)
        composite_score = min(composite_score, self.config.maximum_cap)
        
        return composite_score
    
    def _calculate_component_score(self, component: Component, value: Union[float, int]) -> float:
        """Calculate score for a single component."""
        if component.scoring_method == "proportional":
            return self._calculate_proportional_score(component, value)
        elif component.scoring_method == "binary":
            return self._calculate_binary_score(component, value)
        elif component.scoring_method in ["zone", "zone_based", "zone_based_5tier"]:
            return self._calculate_zone_score(component, value)
        else:
            # Default to proportional for unknown methods
            return self._calculate_proportional_score(component, value)
    
    def _calculate_proportional_score(self, component: Component, value: Union[float, int]) -> float:
        """Calculate proportional score for component."""
        if component.target <= 0:
            return 0.0
        
        percentage = (value / component.target) * 100
        
        # Apply component-specific limits if provided
        min_threshold = component.parameters.get("minimum_threshold", 0)
        max_cap = component.parameters.get("maximum_cap", 100)
        
        return max(min_threshold, min(percentage, max_cap))
    
    def _calculate_binary_score(self, component: Component, value: Union[float, int]) -> float:
        """Calculate binary score for component."""
        threshold = component.parameters.get("threshold", component.target)
        success_value = component.parameters.get("success_value", 100)
        failure_value = component.parameters.get("failure_value", 0)
        comparison_op = component.parameters.get("comparison_operator", ">=")
        
        meets_threshold = False
        if comparison_op == ">=":
            meets_threshold = value >= threshold
        elif comparison_op == ">":
            meets_threshold = value > threshold
        elif comparison_op == "=":
            meets_threshold = value == threshold
        elif comparison_op == "<":
            meets_threshold = value < threshold
        elif comparison_op == "<=":
            meets_threshold = value <= threshold
        
        return success_value if meets_threshold else failure_value
    
    def _calculate_zone_score(self, component: Component, value: Union[float, int]) -> float:
        """Calculate zone-based score for component."""
        zones = component.parameters.get("zones", [])
        
        for zone_data in zones:
            min_val = zone_data.get("min", float("-inf"))
            max_val = zone_data.get("max", float("inf"))
            score = zone_data.get("score", 0)
            
            if min_val <= value <= max_val:
                return score
        
        return 0.0
    
    def _validate_weights(self):
        """Validate component weights."""
        if not self.config.components:
            raise ValueError("At least one component must be defined")
        
        total_weight = sum(component.weight for component in self.config.components)
        if total_weight <= 0:
            raise ValueError("Total component weights must be greater than 0")
    
    def calculate_progressive_scores(self, daily_component_values: List[Dict[str, Union[float, int]]]) -> List[float]:
        """
        Calculate progressive adherence scores as they would appear each day to the user.
        
        For composite weighted: Each day is independent, shows that day's composite score.
        
        Args:
            daily_component_values: List of daily component value dictionaries (7 days)
            
        Returns:
            List of progressive scores (what user sees each day)
        """
        progressive_scores = []
        
        for component_values in daily_component_values:
            score = self.calculate_score(component_values)
            progressive_scores.append(score)
        
        return progressive_scores
        
        # Optionally normalize weights to sum to 1.0
        # (keeping original weights for transparency)
    
    def validate_config(self) -> bool:
        """Validate the configuration parameters."""
        required_fields = [
            "components", "measurement_type", "evaluation_period",
            "success_criteria", "calculation_method", "calculation_fields"
        ]
        
        for field in required_fields:
            if not hasattr(self.config, field):
                raise ValueError(f"Missing required field: {field}")
        
        self._validate_weights()
        return True
    
    def get_formula(self) -> str:
        """Return the algorithm formula as a string."""
        return f"weighted average of {len(self.config.components)} components"
    
    def get_component_info(self) -> str:
        """Return information about all components."""
        info = []
        for component in self.config.components:
            info.append(f"{component.name}: weight={component.weight}, target={component.target} {component.unit}")
        return "\n".join(info)


def create_sleep_quality_composite() -> CompositeWeightedAlgorithm:
    """Create a sleep quality composite algorithm with duration and consistency components."""
    duration_component = Component(
        name="Sleep Duration",
        weight=0.7,
        target=8,
        unit="hours",
        scoring_method="zone",
        field_name="sleep_duration",
        parameters={
            "zones": [
                {"min": 0, "max": 5, "score": 20},
                {"min": 5, "max": 6, "score": 40},
                {"min": 6, "max": 7, "score": 60},
                {"min": 7, "max": 9, "score": 100},
                {"min": 9, "max": 12, "score": 80}
            ]
        }
    )
    
    consistency_component = Component(
        name="Schedule Consistency",
        weight=0.3,
        target=60,  # minutes of variation
        unit="minutes",
        scoring_method="binary",
        field_name="schedule_variance",
        parameters={
            "threshold": 60,
            "comparison_operator": "<=",
            "success_value": 100,
            "failure_value": 0
        }
    )
    
    config = CompositeWeightedConfig(
        components=[duration_component, consistency_component],
        description="Sleep quality based on duration and schedule consistency"
    )
    
    return CompositeWeightedAlgorithm(config)


def create_daily_composite(
    components: List[Component],
    minimum_threshold: float = 0,
    maximum_cap: float = 100,
    description: str = ""
) -> CompositeWeightedAlgorithm:
    """Create a daily composite algorithm."""
    config = CompositeWeightedConfig(
        components=components,
        minimum_threshold=minimum_threshold,
        maximum_cap=maximum_cap,
        evaluation_period=EvaluationPeriod.DAILY,
        description=description
    )
    return CompositeWeightedAlgorithm(config)


def create_frequency_composite(
    components: List[Component],
    frequency_requirement: str,
    minimum_threshold: float = 0,
    maximum_cap: float = 100,
    description: str = ""
) -> CompositeWeightedAlgorithm:
    """Create a frequency-based composite algorithm."""
    config = CompositeWeightedConfig(
        components=components,
        minimum_threshold=minimum_threshold,
        maximum_cap=maximum_cap,
        evaluation_period=EvaluationPeriod.ROLLING_7_DAY,
        success_criteria=SuccessCriteria.FREQUENCY_TARGET,
        frequency_requirement=frequency_requirement,
        description=description
    )
    return CompositeWeightedAlgorithm(config)


def calculate_composite_weighted_dual_progress(
    daily_values: List[Union[float, int, Dict[str, Any]]], 
    current_day: int,
    components: List[Dict[str, Any]],
    **kwargs
) -> Dict[str, float]:
    """
    Calculate dual progress for composite weighted goals
    
    Args:
        daily_values: List of daily measured values
        current_day: Current day (1-7)
        components: List of component configurations
        **kwargs: Additional parameters from config schema
        
    Returns:
        Dict with progress_towards_goal and max_potential_adherence
    """
    # Convert component dictionaries to Component objects
    component_objects = []
    for comp_dict in components:
        component = Component(
            name=comp_dict.get('name', 'component'),
            weight=comp_dict.get('weight', 1.0),
            target=comp_dict.get('target', 100),
            unit=comp_dict.get('unit', 'units'),
            scoring_method=comp_dict.get('scoring_method', 'proportional'),
            field_name=comp_dict.get('field_name', 'value'),
            parameters=comp_dict.get('parameters', {})
        )
        component_objects.append(component)
    
    # Create temporary config and algorithm instance
    config = CompositeWeightedConfig(
        components=component_objects,
        minimum_threshold=kwargs.get('minimum_threshold', 0),
        maximum_cap=kwargs.get('maximum_cap', 100),
        frequency_requirement=kwargs.get('frequency_requirement', 'daily')
    )
    
    # Convert component dictionaries to composite scores
    composite_scores = []
    for daily_data in daily_values:
        if isinstance(daily_data, dict):
            # Calculate composite score for this day
            daily_score = 0.0
            total_weight = 0.0
            
            for component in component_objects:
                field_name = component.field_name
                if field_name in daily_data:
                    component_value = daily_data[field_name]
                    component_target = component.target
                    
                    # Calculate component score (0-100)
                    if component_target > 0:
                        component_score = min((component_value / component_target) * 100, 100)
                    else:
                        component_score = 100 if component_value > 0 else 0
                    
                    # Apply weight
                    weighted_score = component_score * component.weight
                    daily_score += weighted_score
                    total_weight += component.weight
            
            # Normalize by total weight
            if total_weight > 0:
                daily_score = daily_score / total_weight
            
            composite_scores.append(daily_score)
        else:
            # Simple numeric value
            composite_scores.append(float(daily_data))
    
    algorithm = CompositeWeightedAlgorithm(config)
    return algorithm.calculate_dual_progress(composite_scores, current_day)