"""
Adherence Tracker - Track patient adherence to recommendations over time

This module handles fetching and organizing patient adherence data for scoring.
"""

import os
import sys
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Any
import pandas as pd

# Add parent directory to path for imports
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from utils.data_fetcher import PatientDataFetcher
from database.postgres_client import PostgresClient


class AdherenceTracker:
    """Track patient adherence to recommendations"""

    def __init__(self, patient_id: str, db_client=None):
        """
        Initialize adherence tracker

        Args:
            patient_id: Patient UUID
            db_client: Optional PatientDataFetcher instance
        """
        self.patient_id = patient_id
        if db_client:
            self.data_fetcher = db_client
        else:
            # Initialize with default postgres client
            pg_client = PostgresClient()
            self.data_fetcher = PatientDataFetcher(pg_client)

    def get_recommendation_data(
        self,
        recommendation_id: str,
        start_date: Optional[datetime] = None,
        end_date: Optional[datetime] = None
    ) -> pd.DataFrame:
        """
        Get adherence data for a specific recommendation

        Args:
            recommendation_id: Recommendation ID (e.g., "REC0001.1")
            start_date: Start date for data range (default: 30 days ago)
            end_date: End date for data range (default: today)

        Returns:
            DataFrame with adherence tracking data
        """
        if not end_date:
            end_date = datetime.now()
        if not start_date:
            start_date = end_date - timedelta(days=30)

        # Fetch tracked metrics for this recommendation
        # This would query the adherence_tracking table in Supabase
        query = f"""
        SELECT
            date,
            metric_name,
            value,
            unit,
            source
        FROM adherence_tracking
        WHERE patient_id = '{self.patient_id}'
        AND recommendation_id = '{recommendation_id}'
        AND date BETWEEN '{start_date.date()}' AND '{end_date.date()}'
        ORDER BY date, metric_name
        """

        try:
            data = self.data_fetcher.query(query)
            return pd.DataFrame(data) if data else pd.DataFrame()
        except Exception as e:
            print(f"Error fetching adherence data: {e}")
            return pd.DataFrame()

    def get_metric_data(
        self,
        metric_name: str,
        start_date: Optional[datetime] = None,
        end_date: Optional[datetime] = None
    ) -> pd.DataFrame:
        """
        Get data for a specific tracked metric

        Args:
            metric_name: Name of the metric (e.g., "daily_fiber_grams")
            start_date: Start date for data range
            end_date: End date for data range

        Returns:
            DataFrame with metric values over time
        """
        if not end_date:
            end_date = datetime.now()
        if not start_date:
            start_date = end_date - timedelta(days=30)

        query = f"""
        SELECT
            date,
            value,
            unit,
            source
        FROM tracked_metrics
        WHERE patient_id = '{self.patient_id}'
        AND metric_name = '{metric_name}'
        AND date BETWEEN '{start_date.date()}' AND '{end_date.date()}'
        ORDER BY date
        """

        try:
            data = self.data_fetcher.query(query)
            return pd.DataFrame(data) if data else pd.DataFrame()
        except Exception as e:
            print(f"Error fetching metric data: {e}")
            return pd.DataFrame()

    def get_active_goals(self) -> List[Dict[str, Any]]:
        """
        Get patient's active recommendation goals

        Returns:
            List of active goal configurations
        """
        query = f"""
        SELECT
            recommendation_id,
            config_id,
            start_date,
            target_end_date,
            current_level,
            status
        FROM patient_goals
        WHERE patient_id = '{self.patient_id}'
        AND status = 'active'
        ORDER BY start_date DESC
        """

        try:
            data = self.data_fetcher.query(query)
            return data if data else []
        except Exception as e:
            print(f"Error fetching active goals: {e}")
            return []
