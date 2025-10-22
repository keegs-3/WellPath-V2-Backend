"""
Adherence Calculator - Calculate adherence scores using configured algorithms

This module loads recommendation configs and calculates adherence scores using
the appropriate algorithm type for each recommendation.
"""

import json
import os
from typing import Dict, Any, Optional
import pandas as pd

# Import all algorithm types
import sys
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from algorithms.binary_threshold import BinaryThresholdAlgorithm
from algorithms.minimum_frequency import MinimumFrequencyAlgorithm
from algorithms.weekly_elimination import WeeklyEliminationAlgorithm
from algorithms.proportional import ProportionalAlgorithm
from algorithms.zone_based import ZoneBasedAlgorithm
from algorithms.composite_weighted import CompositeWeightedAlgorithm
from algorithms.sleep_composite import SleepCompositeAlgorithm
from algorithms.categorical_filter_threshold import CategoricalFilterThresholdAlgorithm
from algorithms.constrained_weekly_allowance import ConstrainedWeeklyAllowanceAlgorithm
from algorithms.proportional_frequency_hybrid import ProportionalFrequencyHybridAlgorithm
from algorithms.baseline_consistency import BaselineConsistencyAlgorithm
from algorithms.weekend_variance import WeekendVarianceAlgorithm
from algorithms.completion_based import CompletionBasedAlgorithm
from algorithms.therapeutic_adherence import TherapeuticAdherenceAlgorithm


class AdherenceCalculator:
    """Calculate adherence scores for recommendations"""

    # Map algorithm names to classes
    ALGORITHM_MAP = {
        'BINARY-THRESHOLD': BinaryThresholdAlgorithm,
        'MINIMUM-FREQUENCY': MinimumFrequencyAlgorithm,
        'WEEKLY-ELIMINATION': WeeklyEliminationAlgorithm,
        'PROPORTIONAL': ProportionalAlgorithm,
        'ZONE-BASED': ZoneBasedAlgorithm,
        'ZONE-BASED-5TIER': ZoneBasedAlgorithm,
        'COMPOSITE-WEIGHTED': CompositeWeightedAlgorithm,
        'SLEEP-COMPOSITE': SleepCompositeAlgorithm,
        'CATEGORICAL-FILTER-DAILY': CategoricalFilterThresholdAlgorithm,
        'CATEGORICAL-FILTER-FREQUENCY': CategoricalFilterThresholdAlgorithm,
        'CONSTRAINED-WEEKLY-ALLOWANCE': ConstrainedWeeklyAllowanceAlgorithm,
        'PROPORTIONAL-FREQUENCY-HYBRID': ProportionalFrequencyHybridAlgorithm,
        'BASELINE-CONSISTENCY': BaselineConsistencyAlgorithm,
        'WEEKEND-VARIANCE': WeekendVarianceAlgorithm,
        'COMPLETION-BASED': CompletionBasedAlgorithm,
        'THERAPEUTIC-ADHERENCE': TherapeuticAdherenceAlgorithm,
        'SINGLE': CompletionBasedAlgorithm,  # Medications/supplements use completion
        'STACK': CompositeWeightedAlgorithm,  # Stacked supplements use composite
    }

    def __init__(self, config_id: Optional[str] = None, config_path: Optional[str] = None):
        """
        Initialize adherence calculator

        Args:
            config_id: Config ID to load (e.g., "REC0001.1-PROPORTIONAL")
            config_path: Direct path to config file (overrides config_id)
        """
        self.config = None
        self.algorithm = None

        if config_path:
            self.load_config_from_path(config_path)
        elif config_id:
            self.load_config(config_id)

    def load_config(self, config_id: str):
        """
        Load configuration by ID

        Args:
            config_id: Config ID (e.g., "REC0001.1-PROPORTIONAL")
        """
        # Try to find config file
        config_dir = os.path.join(
            os.path.dirname(__file__),
            'configs'
        )

        # Handle both with and without extension
        config_file = config_id if config_id.endswith('.json') else f"{config_id}.json"
        config_path = os.path.join(config_dir, config_file)

        if not os.path.exists(config_path):
            raise FileNotFoundError(f"Config not found: {config_path}")

        self.load_config_from_path(config_path)

    def load_config_from_path(self, config_path: str):
        """
        Load configuration from file path

        Args:
            config_path: Path to config JSON file
        """
        with open(config_path, 'r') as f:
            self.config = json.load(f)

        # Initialize the appropriate algorithm
        algorithm_type = self.config.get('algorithm_type', '').upper()

        if algorithm_type not in self.ALGORITHM_MAP:
            raise ValueError(f"Unknown algorithm type: {algorithm_type}")

        AlgorithmClass = self.ALGORITHM_MAP[algorithm_type]
        self.algorithm = AlgorithmClass(self.config)

    def calculate_score(self, data: pd.DataFrame) -> Dict[str, Any]:
        """
        Calculate adherence score from tracking data

        Args:
            data: DataFrame with patient tracking data

        Returns:
            Dict with:
                - progress_towards_goal: 0-100 score
                - max_potential_adherence: 0-100 score
                - days_compliant: Number of compliant days
                - total_days: Total days evaluated
                - details: Algorithm-specific details
        """
        if not self.algorithm:
            raise ValueError("No algorithm loaded. Call load_config() first.")

        if data.empty:
            return {
                'progress_towards_goal': 0.0,
                'max_potential_adherence': 0.0,
                'days_compliant': 0,
                'total_days': 0,
                'details': {}
            }

        # Calculate score using algorithm
        result = self.algorithm.calculate_score(data)

        return result

    def get_algorithm_info(self) -> Dict[str, Any]:
        """
        Get information about the loaded algorithm

        Returns:
            Dict with algorithm type, config ID, and parameters
        """
        if not self.config:
            return {}

        return {
            'config_id': self.config.get('config_id', ''),
            'algorithm_type': self.config.get('algorithm_type', ''),
            'recommendation_id': self.config.get('recommendation_id', ''),
            'title': self.config.get('title', ''),
            'parameters': self.config.get('schema', {})
        }

    @staticmethod
    def list_available_configs() -> list:
        """
        List all available recommendation configs

        Returns:
            List of config IDs
        """
        config_dir = os.path.join(
            os.path.dirname(__file__),
            'configs'
        )

        if not os.path.exists(config_dir):
            return []

        configs = [
            f.replace('.json', '')
            for f in os.listdir(config_dir)
            if f.endswith('.json') and not f.startswith('.')
        ]

        return sorted(configs)

    @staticmethod
    def get_config_by_recommendation(recommendation_id: str) -> list:
        """
        Get all config IDs for a recommendation

        Args:
            recommendation_id: Recommendation ID (e.g., "REC0001")

        Returns:
            List of config IDs for this recommendation
        """
        all_configs = AdherenceCalculator.list_available_configs()
        return [c for c in all_configs if c.startswith(recommendation_id)]
