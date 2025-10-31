"""
WellPath Adherence Tracking System

This module provides comprehensive adherence tracking for recommendations, medications,
supplements, and peptides using 14 core algorithm types.

Components:
- tracker: Track adherence metrics over time
- calculator: Calculate adherence scores using configured algorithms
- config_generator: Generate recommendation configs from Airtable data

Usage:
    from scoring_engine.adherence import AdherenceTracker, AdherenceCalculator

    tracker = AdherenceTracker(patient_id="123")
    calculator = AdherenceCalculator(config_id="REC0001.1")
    score = calculator.calculate_score(tracker.get_data())
"""

from .tracker import AdherenceTracker
from .calculator import AdherenceCalculator

__all__ = ['AdherenceTracker', 'AdherenceCalculator']
