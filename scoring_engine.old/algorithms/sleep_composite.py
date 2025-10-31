"""
Sleep Composite Scoring Algorithm

Specialized algorithm for comprehensive sleep quality assessment combining:
- Sleep duration (zone-based scoring): 55% weight
- Sleep time consistency (variance-based): 22.5% weight  
- Wake time consistency (variance-based): 22.5% weight

Algorithm Type: sleep_composite
Pattern: Daily composite assessment
Evaluation: Daily with multi-component scoring
Logic: Weighted average of duration zones + consistency variance scoring
"""

from typing import Dict, Any, Union, List
from dataclasses import dataclass
import logging

logger = logging.getLogger(__name__)


@dataclass
class SleepCompositeConfig:
    """Configuration for sleep composite scoring"""
    # Duration component (55% weight)
    duration_weight: float = 0.55
    duration_zones: List[Dict[str, Any]] = None
    
    # Consistency components (22.5% each)
    sleep_consistency_weight: float = 0.225
    wake_consistency_weight: float = 0.225
    variance_thresholds: List[Dict[str, Any]] = None
    
    # Metadata
    unit: str = "composite_score"
    description: str = ""
    
    def __post_init__(self):
        # Default sleep duration zones
        if self.duration_zones is None:
            self.duration_zones = [
                {"range": [0, 6], "score": 0, "label": "Insufficient"},
                {"range": [6, 7], "score": 50, "label": "Low"},
                {"range": [7, 9], "score": 100, "label": "Optimal"},
                {"range": [9, 10], "score": 75, "label": "Long"},
                {"range": [10, 24], "score": 25, "label": "Excessive"}
            ]
        
        # Default variance thresholds for consistency
        if self.variance_thresholds is None:
            self.variance_thresholds = [
                {"max_variance": 60, "score": 100},   # <60 min = 100%
                {"max_variance": 90, "score": 75},    # 60-90 min = 75%
                {"max_variance": 120, "score": 50},   # 90-120 min = 50%
                {"max_variance": 150, "score": 25},   # 120-150 min = 25%
                {"max_variance": float('inf'), "score": 0}  # >150 min = 0%
            ]


class SleepCompositeAlgorithm:
    """Sleep composite algorithm implementation with duration + consistency scoring"""
    
    def __init__(self, config: SleepCompositeConfig):
        self.config = config
    
    def calculate_score(self, sleep_data: Dict[str, Union[float, int]]) -> float:
        """
        Calculate composite sleep score from duration and consistency data.
        
        Args:
            sleep_data: Dict containing:
                - sleep_duration: Hours of sleep (float)
                - sleep_time_consistency: Variance in minutes (float) 
                - wake_time_consistency: Variance in minutes (float)
                
        Returns:
            Composite sleep score (0-100)
        """
        duration = sleep_data.get('sleep_duration', 0)
        sleep_variance = sleep_data.get('sleep_time_consistency', 0)
        wake_variance = sleep_data.get('wake_time_consistency', 0)
        
        # Calculate component scores
        duration_score = self._calculate_duration_score(duration)
        sleep_consistency_score = self._calculate_consistency_score(sleep_variance)
        wake_consistency_score = self._calculate_consistency_score(wake_variance)
        
        # Calculate weighted composite
        composite_score = (
            (duration_score * self.config.duration_weight) +
            (sleep_consistency_score * self.config.sleep_consistency_weight) +
            (wake_consistency_score * self.config.wake_consistency_weight)
        )
        
        # Ensure score is within bounds
        return max(0.0, min(100.0, composite_score))
    
    def _calculate_duration_score(self, duration: float) -> float:
        """Calculate score for sleep duration using zone-based logic"""
        for zone in self.config.duration_zones:
            min_val, max_val = zone["range"]
            if min_val <= duration < max_val:
                return float(zone["score"])
        
        # Handle edge case: exactly at max value of optimal zone
        if duration == 9.0:  # Exactly 9 hours
            return 100.0
        
        # Fallback to last zone for values beyond defined ranges
        return float(self.config.duration_zones[-1]["score"])
    
    def _calculate_consistency_score(self, variance_minutes: float) -> float:
        """Calculate score for sleep/wake consistency using variance thresholds"""
        for threshold in self.config.variance_thresholds:
            if variance_minutes < threshold["max_variance"]:
                return float(threshold["score"])
        
        # Fallback to 0 for extreme variance
        return 0.0
    
    def calculate_progressive_scores(self, daily_sleep_data: List[Dict[str, Union[float, int]]]) -> List[float]:
        """
        Calculate progressive adherence scores for sleep composite assessment.
        
        Args:
            daily_sleep_data: List of daily sleep data dicts (7 days)
            
        Returns:
            List of daily composite scores
        """
        progressive_scores = []
        
        for daily_data in daily_sleep_data:
            score = self.calculate_score(daily_data)
            progressive_scores.append(score)
        
        return progressive_scores
    
    def calculate_dual_progress(self, daily_sleep_data: List[Dict[str, Union[float, int]]], current_day: int) -> Dict[str, float]:
        """
        Calculate dual progress metrics for sleep composite goals.
        
        For sleep composite goals, we track overall sleep quality:
        - Progress: Current average sleep quality score
        - Potential: Best possible average if remaining nights are optimal
        """
        if current_day > len(daily_sleep_data):
            current_day = len(daily_sleep_data)
            
        if current_day == 0:
            return {
                'progress_towards_goal': 0.0,
                'max_potential_adherence': 100.0,
                'current_day': 0,
                'remaining_days': len(daily_sleep_data),
                'current_average_score': 0.0
            }
        
        # Calculate current sleep quality scores using daily weighting system
        # For "all nights" goals, each night's composite score contributes proportionally
        total_week_days = len(daily_sleep_data)
        daily_weight = 100.0 / total_week_days  # 14.3% per day for 7-day week
        
        current_scores = []
        total_progress = 0.0
        
        for day_idx in range(current_day):
            daily_data = daily_sleep_data[day_idx]
            composite_score = self.calculate_score(daily_data)  # 0-100 composite score
            current_scores.append(composite_score)
            
            # Each night contributes its composite score percentage of the daily weight
            # E.g., 45% composite score × 14.3% daily weight = 6.4% weekly progress
            daily_contribution = (composite_score / 100.0) * daily_weight
            total_progress += daily_contribution
        
        progress_towards_goal = total_progress
        
        # Max potential - assume remaining days achieve perfect composite score (100%)
        remaining_days = total_week_days - current_day
        max_additional_progress = remaining_days * daily_weight  # Perfect nights
        max_potential_adherence = total_progress + max_additional_progress
        
        # Calculate current average score for reporting
        current_average_score = sum(current_scores) / len(current_scores) if current_scores else 0
        
        # Count good sleep days (composite score >= 75%)
        good_sleep_days = sum(1 for score in current_scores if score >= 75)
        
        return {
            'progress_towards_goal': progress_towards_goal,
            'max_potential_adherence': max_potential_adherence,
            'current_average_score': current_average_score,
            'good_sleep_days': good_sleep_days,
            'current_day': current_day,
            'remaining_days': remaining_days
        }
    
    def get_component_breakdown(self, sleep_data: Dict[str, Union[float, int]]) -> Dict[str, Any]:
        """
        Get detailed breakdown of component scores for analysis.
        
        Returns:
            Dict with component scores and composite calculation
        """
        duration = sleep_data.get('sleep_duration', 0)
        sleep_variance = sleep_data.get('sleep_time_consistency', 0)
        wake_variance = sleep_data.get('wake_time_consistency', 0)
        
        # Calculate individual components
        duration_score = self._calculate_duration_score(duration)
        sleep_consistency_score = self._calculate_consistency_score(sleep_variance)
        wake_consistency_score = self._calculate_consistency_score(wake_variance)
        
        # Calculate weighted contributions
        duration_contribution = duration_score * self.config.duration_weight
        sleep_contribution = sleep_consistency_score * self.config.sleep_consistency_weight
        wake_contribution = wake_consistency_score * self.config.wake_consistency_weight
        
        composite_score = duration_contribution + sleep_contribution + wake_contribution
        
        return {
            "components": {
                "duration": {
                    "value": duration,
                    "score": duration_score,
                    "weight": self.config.duration_weight,
                    "contribution": duration_contribution
                },
                "sleep_consistency": {
                    "value": sleep_variance,
                    "score": sleep_consistency_score,
                    "weight": self.config.sleep_consistency_weight,
                    "contribution": sleep_contribution
                },
                "wake_consistency": {
                    "value": wake_variance,
                    "score": wake_consistency_score,
                    "weight": self.config.wake_consistency_weight,
                    "contribution": wake_contribution
                }
            },
            "composite_score": composite_score,
            "algorithm": "sleep_composite"
        }
    
    def validate_config(self) -> bool:
        """Validate the configuration parameters"""
        # Check weights sum to 1.0
        total_weight = (self.config.duration_weight + 
                       self.config.sleep_consistency_weight + 
                       self.config.wake_consistency_weight)
        
        if abs(total_weight - 1.0) > 0.001:  # Allow small floating point errors
            raise ValueError(f"Component weights must sum to 1.0, got {total_weight}")
        
        # Validate duration zones
        if not self.config.duration_zones:
            raise ValueError("Duration zones cannot be empty")
        
        # Validate variance thresholds
        if not self.config.variance_thresholds:
            raise ValueError("Variance thresholds cannot be empty")
        
        # Check variance thresholds are in ascending order
        prev_max = 0
        for threshold in self.config.variance_thresholds[:-1]:  # Exclude infinity
            if threshold["max_variance"] <= prev_max:
                raise ValueError("Variance thresholds must be in ascending order")
            prev_max = threshold["max_variance"]
        
        return True
    
    def get_formula(self) -> str:
        """Return the algorithm formula as a string"""
        return (f"({self.config.duration_weight} × duration_zone_score) + "
                f"({self.config.sleep_consistency_weight} × sleep_consistency_score) + "
                f"({self.config.wake_consistency_weight} × wake_consistency_score)")


def create_sleep_composite(
    duration_weight: float = 0.55,
    sleep_consistency_weight: float = 0.225,
    wake_consistency_weight: float = 0.225,
    description: str = ""
) -> SleepCompositeAlgorithm:
    """Create a sleep composite algorithm with standard weights"""
    config = SleepCompositeConfig(
        duration_weight=duration_weight,
        sleep_consistency_weight=sleep_consistency_weight,
        wake_consistency_weight=wake_consistency_weight,
        description=description
    )
    return SleepCompositeAlgorithm(config)


def calculate_sleep_composite_dual_progress(
    daily_values: List[Union[float, int, Dict]], 
    current_day: int,
    **kwargs
) -> Dict[str, float]:
    """
    Calculate dual progress for sleep composite goals
    
    Args:
        daily_values: List of daily sleep data (dicts or single values)
        current_day: Current day (1-7)
        **kwargs: Additional parameters from config schema
        
    Returns:
        Dict with progress_towards_goal and max_potential_adherence
    """
    # Convert simple values to sleep data dicts if needed
    daily_sleep_data = []
    for value in daily_values:
        if isinstance(value, dict):
            daily_sleep_data.append(value)
        else:
            # Convert single value to mock sleep data (for testing)
            daily_sleep_data.append({
                'sleep_duration': value if value > 0 else 7.5,  # Default to 7.5 hours
                'sleep_time_consistency': 30 if value > 0 else 90,  # Good vs poor consistency
                'wake_time_consistency': 30 if value > 0 else 90
            })
    
    # Create temporary config and algorithm instance
    config = SleepCompositeConfig(
        duration_weight=kwargs.get('duration_weight', 0.55),
        sleep_consistency_weight=kwargs.get('sleep_consistency_weight', 0.225),
        wake_consistency_weight=kwargs.get('wake_consistency_weight', 0.225)
    )
    
    algorithm = SleepCompositeAlgorithm(config)
    return algorithm.calculate_dual_progress(daily_sleep_data, current_day)


# Example usage and testing
if __name__ == "__main__":
    # Example 1: Good sleep duration, good consistency
    good_sleep = {
        "sleep_duration": 8.0,          # 8 hours (optimal zone) = 100 points
        "sleep_time_consistency": 15,   # 15 min variance (<60) = 100 points
        "wake_time_consistency": 20     # 20 min variance (<60) = 100 points
    }
    
    algorithm = create_sleep_composite()
    score1 = algorithm.calculate_score(good_sleep)
    breakdown1 = algorithm.get_component_breakdown(good_sleep)
    print("Good sleep example:", score1)
    print("Breakdown:", breakdown1)
    
    # Example 2: Suboptimal sleep duration, poor consistency
    poor_sleep = {
        "sleep_duration": 6.5,          # 6.5 hours (low zone) = 50 points
        "sleep_time_consistency": 45,   # 45 min variance (<60) = 100 points  
        "wake_time_consistency": 75     # 75 min variance (60-90) = 75 points
    }
    
    score2 = algorithm.calculate_score(poor_sleep)
    breakdown2 = algorithm.get_component_breakdown(poor_sleep)
    print("Poor sleep example:", score2)
    print("Breakdown:", breakdown2)
    
    # Example 3: Insufficient sleep, high variance
    bad_sleep = {
        "sleep_duration": 5.5,          # 5.5 hours (insufficient) = 0 points
        "sleep_time_consistency": 180,  # 180 min variance (>150) = 0 points
        "wake_time_consistency": 120    # 120 min variance (90-120) = 50 points
    }
    
    score3 = algorithm.calculate_score(bad_sleep)
    breakdown3 = algorithm.get_component_breakdown(bad_sleep)
    print("Bad sleep example:", score3)
    print("Breakdown:", breakdown3)