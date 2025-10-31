"""
Zone-Based Scoring Algorithm

Assigns scores based on which zone the actual value falls into.
Supports 5-tier zone system with configurable ranges and scores.
"""

from typing import Dict, Any, Union, List
from dataclasses import dataclass
from .binary_threshold import EvaluationPeriod, SuccessCriteria, CalculationMethod


@dataclass
class Zone:
    """Represents a scoring zone with range and score."""
    min_value: Union[float, int]
    max_value: Union[float, int]
    score: float
    label: str
    
    def contains(self, value: Union[float, int]) -> bool:
        """Check if value falls within this zone (inclusive of boundaries)."""
        return self.min_value <= value <= self.max_value


@dataclass
class ZoneBasedConfig:
    zones: List[Zone]
    unit: str
    measurement_type: str = "duration"
    evaluation_period: EvaluationPeriod = EvaluationPeriod.DAILY
    success_criteria: SuccessCriteria = SuccessCriteria.SIMPLE_TARGET
    calculation_method: CalculationMethod = CalculationMethod.SUM
    calculation_fields: Union[str, Dict[str, Any]] = "value"
    grace_range: bool = False
    boundary_handling: str = "strict"
    frequency_requirement: str = "daily"
    description: str = ""


class ZoneBasedAlgorithm:
    """Zone-based scoring algorithm implementation."""
    
    def __init__(self, config: ZoneBasedConfig, frequency_target: int = None):
        self.config = config
        self.frequency_target = frequency_target  # For frequency-based evaluation
        self._validate_zones()
        
    def calculate_dual_progress(self, daily_values: List[Union[float, int]], current_day: int) -> Dict[str, float]:
        """
        Calculate dual progress metrics for zone-based goals.
        
        For frequency-based zone goals (like "optimal zone 3 of 7 days"):
        - Progress: (optimal_days_achieved / total_days) × 100
        - Potential: (optimal_days_achieved + remaining_days) / total_days × 100
        """
        if current_day > len(daily_values):
            current_day = len(daily_values)
            
        total_week_days = len(daily_values)  # Usually 7
        optimal_score = max(zone.score for zone in self.config.zones) if self.config.zones else 100
        
        if current_day == 0:
            return {
                'progress_towards_goal': 0.0,
                'max_potential_adherence': 100.0,
                'optimal_zone_days': 0,
                'current_day': 0,
                'remaining_days': total_week_days
            }
        
        # Count optimal zone days achieved so far
        optimal_zone_days = 0
        current_scores = []
        
        for day_idx in range(current_day):
            daily_value = daily_values[day_idx]
            score = self.calculate_score(daily_value)
            current_scores.append(score)
            
            if score == optimal_score:
                optimal_zone_days += 1
        
        # Check if this is frequency-based (like "3 of 7 days") or average-based
        is_frequency_based = (hasattr(self, 'frequency_target') and self.frequency_target is not None) or \
                           ('of 7' in self.config.frequency_requirement.lower())
        
        if is_frequency_based:
            # Weighted zone-based frequency: each day contributes based on zone score
            target_days = getattr(self, 'frequency_target', None)
            if target_days is None:
                # Extract from frequency requirement text as fallback
                import re
                match = re.search(r'(\d+)\s+of\s+7', self.config.frequency_requirement)
                target_days = int(match.group(1)) if match else 3
            
            # Each target day is worth (100% / target_days) of total progress
            points_per_target_day = 100.0 / target_days
            
            # Calculate weighted progress: each day contributes based on its zone score
            progress_towards_goal = 0.0
            for score in current_scores:
                # Zone score as percentage of optimal (e.g., 80/100 = 80%)
                zone_percentage = score / optimal_score
                # This day contributes: zone_percentage × points_per_target_day
                progress_towards_goal += zone_percentage * points_per_target_day
            
            # Cap progress at 100%
            progress_towards_goal = min(progress_towards_goal, 100.0)
            
            # Max potential: current progress + remaining days at optimal
            remaining_days = total_week_days - current_day
            max_additional = remaining_days * points_per_target_day
            max_potential_adherence = min(progress_towards_goal + max_additional, 100.0)
        else:
            # Average-based: traditional zone scoring
            current_average_score = sum(current_scores) / len(current_scores)
            progress_towards_goal = current_average_score
            
            # Max potential - assume remaining days hit optimal zone
            remaining_days = total_week_days - current_day
            if remaining_days > 0:
                total_score = sum(current_scores) + (remaining_days * optimal_score)
                max_potential_adherence = total_score / total_week_days
            else:
                max_potential_adherence = current_average_score
            
        return {
            'progress_towards_goal': progress_towards_goal,
            'max_potential_adherence': max_potential_adherence,
            'optimal_zone_days': optimal_zone_days,
            'current_day': current_day,
            'remaining_days': total_week_days - current_day,
            'total_days': total_week_days
        }
    
    def calculate_score(self, actual_value: Union[float, int]) -> float:
        """
        Calculate score based on which zone the value falls into.
        
        Args:
            actual_value: The measured value to evaluate
            
        Returns:
            Score based on the zone the value falls into
        """
        # Sort zones by min_value to ensure we find the first matching zone
        sorted_zones = sorted(self.config.zones, key=lambda z: z.min_value)
        
        for zone in sorted_zones:
            if zone.contains(actual_value):
                if self.config.grace_range and self.config.boundary_handling == "graduated":
                    return self._apply_graduated_scoring(actual_value, zone)
                return zone.score
        
        # Value doesn't fall in any zone - return 0
        return 0.0
    
    def _apply_graduated_scoring(self, value: Union[float, int], zone: Zone) -> float:
        """Apply graduated scoring near zone boundaries."""
        zone_width = zone.max_value - zone.min_value
        if zone_width == 0:
            return zone.score
        
        # Calculate position within zone (0.0 to 1.0)
        position = (value - zone.min_value) / zone_width
        
        # Apply a small gradient based on position
        gradient_factor = 0.95 + (0.05 * position)  # 95% to 100% of zone score
        return zone.score * gradient_factor
    
    def _validate_zones(self):
        """Validate zone configuration."""
        if not self.config.zones:
            raise ValueError("Zone-based algorithm requires zones to be defined")
        
        # Allow both 3-tier and 5-tier zones
        valid_zone_counts = [3, 5]
        if len(self.config.zones) not in valid_zone_counts:
            raise ValueError(f"Zone-based algorithm requires {valid_zone_counts} zones, got {len(self.config.zones)}")
        
        # Sort zones by min_value for validation
        sorted_zones = sorted(self.config.zones, key=lambda z: z.min_value)
        
        # Check for gaps or overlaps (allow adjacent zones where max = next min)
        for i in range(len(sorted_zones) - 1):
            current_zone = sorted_zones[i]
            next_zone = sorted_zones[i + 1]
            
            # Allow small gaps (< 0.1) to account for floating point precision
            gap = next_zone.min_value - current_zone.max_value
            if gap >= 0.1:
                raise ValueError(f"Gap between zones: {current_zone.label} and {next_zone.label}")
            
            if current_zone.max_value > next_zone.min_value:
                raise ValueError(f"Overlap between zones: {current_zone.label} and {next_zone.label}")
    
    def validate_config(self) -> bool:
        """Validate the configuration parameters."""
        required_fields = [
            "zones", "unit", "measurement_type", "evaluation_period",
            "success_criteria", "calculation_method", "calculation_fields"
        ]
        
        for field in required_fields:
            if not hasattr(self.config, field):
                raise ValueError(f"Missing required field: {field}")
        
        self._validate_zones()
        return True
    
    def calculate_weekly_frequency_score(self, daily_values: List[Union[float, int]], target_zone_score: float = 100) -> float:
        """Calculate weekly score based on frequency of hitting target zone."""
        if not self.frequency_target:
            # No frequency requirement, return average of daily scores
            daily_scores = [self.calculate_score(value) for value in daily_values]
            return sum(daily_scores) / len(daily_scores)
        
        # Count days that hit the target zone (e.g., optimal sleep = 100 points)
        target_days = 0
        for value in daily_values:
            if self.calculate_score(value) >= target_zone_score:
                target_days += 1
        
        # Calculate achievement ratio
        if target_days >= self.frequency_target:
            return 100.0  # Full achievement
        else:
            return (target_days / self.frequency_target) * 100
    
    def get_formula(self) -> str:
        """Return the algorithm formula as a string."""
        if self.frequency_target:
            return f"frequency-based: score based on hitting target zone {self.frequency_target} days per week"
        return "score based on which zone actual_value falls into"
    
    def calculate_progressive_scores(self, daily_values: List[Union[float, int]]) -> List[float]:
        """
        Calculate progressive adherence scores as they would appear each day to the user.
        
        For zone-based algorithms: Each day is independent, shows that day's zone score.
        
        Args:
            daily_values: List of daily measured values (7 days)
            
        Returns:
            List of progressive scores (what user sees each day)
        """
        progressive_scores = []
        
        for value in daily_values:
            score = self.calculate_score(value)
            progressive_scores.append(score)
        
        return progressive_scores
    
    def get_zone_info(self) -> str:
        """Return information about all zones."""
        info = []
        for zone in self.config.zones:
            info.append(f"{zone.label}: [{zone.min_value}-{zone.max_value}] {zone.score} points")
        return "\n".join(info)


def create_sleep_duration_zones() -> List[Zone]:
    """Create standard sleep duration zones (in hours)."""
    return [
        Zone(0, 5, 20, "Very Poor"),
        Zone(5, 6, 40, "Poor"),
        Zone(6, 7, 60, "Fair"),
        Zone(7, 9, 100, "Good"),
        Zone(9, 12, 80, "Excessive")
    ]


def create_daily_zone_based(
    zones: List[Zone],
    unit: str,
    grace_range: bool = False,
    boundary_handling: str = "strict",
    description: str = ""
) -> ZoneBasedAlgorithm:
    """Create a daily zone-based algorithm."""
    config = ZoneBasedConfig(
        zones=zones,
        unit=unit,
        grace_range=grace_range,
        boundary_handling=boundary_handling,
        evaluation_period=EvaluationPeriod.DAILY,
        description=description
    )
    return ZoneBasedAlgorithm(config)


def create_frequency_zone_based(
    zones: List[Zone],
    unit: str,
    frequency_requirement: str,
    grace_range: bool = False,
    boundary_handling: str = "strict",
    description: str = ""
) -> ZoneBasedAlgorithm:
    """Create a frequency-based zone-based algorithm."""
    config = ZoneBasedConfig(
        zones=zones,
        unit=unit,
        grace_range=grace_range,
        boundary_handling=boundary_handling,
        evaluation_period=EvaluationPeriod.ROLLING_7_DAY,
        success_criteria=SuccessCriteria.FREQUENCY_TARGET,
        frequency_requirement=frequency_requirement,
        description=description
    )
    return ZoneBasedAlgorithm(config)


def calculate_zone_based_dual_progress(
    daily_values: List[Union[float, int]], 
    current_day: int,
    zones: List[Dict[str, Any]],
    unit: str = "units",
    **kwargs
) -> Dict[str, float]:
    """
    Calculate dual progress for zone-based goals
    
    Args:
        daily_values: List of daily measured values
        current_day: Current day (1-7)
        zones: List of zone configurations
        unit: Unit of measurement
        **kwargs: Additional parameters from config schema
        
    Returns:
        Dict with progress_towards_goal and max_potential_adherence
    """
    # Convert zone dictionaries to Zone objects
    zone_objects = []
    for zone_dict in zones:
        # Handle different zone format: range array vs min/max values
        if 'range' in zone_dict:
            min_val, max_val = zone_dict['range']
        else:
            min_val = zone_dict.get('min_value', zone_dict.get('min', 0))
            max_val = zone_dict.get('max_value', zone_dict.get('max', 100))
            
        zone = Zone(
            min_value=min_val,
            max_value=max_val,
            score=zone_dict.get('score', 50),
            label=zone_dict.get('label', f'Zone {len(zone_objects) + 1}')
        )
        zone_objects.append(zone)
    
    # Create temporary config and algorithm instance
    config = ZoneBasedConfig(
        zones=zone_objects,
        unit=unit,
        grace_range=kwargs.get('grace_range', False),
        boundary_handling=kwargs.get('boundary_handling', 'strict'),
        frequency_requirement=kwargs.get('frequency_requirement', 'daily')
    )
    
    frequency_target = kwargs.get('frequency_target', kwargs.get('required_days'))
    algorithm = ZoneBasedAlgorithm(config, frequency_target)
    return algorithm.calculate_dual_progress(daily_values, current_day)