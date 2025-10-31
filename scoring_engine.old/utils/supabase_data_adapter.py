"""
Adapter to convert Supabase data to pandas DataFrames.
This bridges the gap between database queries and CSV-based scoring runners.
"""

import pandas as pd
from typing import Dict, Any, List, Optional
from supabase import Client


class SupabaseDataAdapter:
    """Converts Supabase data to DataFrame format for scoring runners."""

    def __init__(self, supabase: Client):
        self.supabase = supabase

    def get_patient_survey_data(self, patient_id: str) -> pd.DataFrame:
        """
        Fetch patient survey responses and convert to DataFrame.

        Returns DataFrame with columns:
        - patient_id
        - question_id
        - response_option_id
        - value
        - question_text
        - pillar
        - etc.
        """
        response = self.supabase.table("patient_responses") \
            .select("""
                *,
                survey_questions (
                    question,
                    pillar_id,
                    pillars (name)
                ),
                survey_response_options (
                    option_text,
                    score_value
                )
            """) \
            .eq("patient_id", patient_id) \
            .execute()

        if not response.data:
            return pd.DataFrame()

        return pd.DataFrame(response.data)

    def get_patient_biomarker_data(self, patient_id: str) -> pd.DataFrame:
        """
        Fetch patient biomarker data and convert to DataFrame.

        Returns DataFrame with columns:
        - patient_id
        - marker_id
        - value
        - unit
        - measured_at
        - marker_name
        - pillar
        - normal_range
        """
        response = self.supabase.table("patient_biomarkers") \
            .select("""
                *,
                intake_markers (
                    name,
                    unit,
                    normal_min,
                    normal_max
                )
            """) \
            .eq("patient_id", patient_id) \
            .execute()

        if not response.data:
            return pd.DataFrame()

        return pd.DataFrame(response.data)

    def get_patient_metric_tracking_data(self, patient_id: str, days: int = 30) -> pd.DataFrame:
        """
        Fetch patient's daily tracked metrics (like steps, sleep, etc.).

        Returns DataFrame with columns:
        - patient_id
        - metric_type_id
        - date
        - value
        - metric_name
        - tracking_method
        """
        response = self.supabase.table("patient_metric_tracking") \
            .select("""
                *,
                metric_types_vfinal (
                    name,
                    unit,
                    tracking_method,
                    data_type
                )
            """) \
            .eq("patient_id", patient_id) \
            .gte("date", f"now() - interval '{days} days'") \
            .execute()

        if not response.data:
            return pd.DataFrame()

        return pd.DataFrame(response.data)

    def get_patient_recommendation_adherence(
        self,
        patient_id: str,
        recommendation_id: Optional[str] = None
    ) -> pd.DataFrame:
        """
        Fetch patient's recommendation adherence tracking data.

        Returns DataFrame with columns:
        - patient_id
        - recommendation_id
        - date
        - completed
        - metric_value
        - algorithm_type
        """
        query = self.supabase.table("patient_recommendation_tracking") \
            .select("""
                *,
                recommendations_v2 (
                    name,
                    algorithm_type,
                    config
                )
            """) \
            .eq("patient_id", patient_id)

        if recommendation_id:
            query = query.eq("recommendation_id", recommendation_id)

        response = query.execute()

        if not response.data:
            return pd.DataFrame()

        return pd.DataFrame(response.data)

    def get_all_patient_data(self, patient_id: str) -> Dict[str, pd.DataFrame]:
        """
        Fetch all patient data needed for comprehensive scoring.

        Returns dict with keys:
        - 'survey': Survey responses DataFrame
        - 'biomarkers': Biomarker data DataFrame
        - 'metrics': Daily tracked metrics DataFrame
        - 'adherence': Recommendation adherence DataFrame
        """
        return {
            'survey': self.get_patient_survey_data(patient_id),
            'biomarkers': self.get_patient_biomarker_data(patient_id),
            'metrics': self.get_patient_metric_tracking_data(patient_id),
            'adherence': self.get_patient_recommendation_adherence(patient_id)
        }

    def get_pillar_weights(self) -> pd.DataFrame:
        """
        Fetch pillar weighting configuration.

        Returns DataFrame with pillar weights for different data sources.
        """
        # Fetch from multiple weight tables
        biomarker_weights = self.supabase.table("biomarker_pillar_weights").select("*").execute()
        survey_weights = self.supabase.table("survey_question_pillar_weights").select("*").execute()

        # Combine into single weights DataFrame
        # TODO: Implement proper combination logic

        return pd.DataFrame()

    @staticmethod
    def dataframe_to_csv_format(df: pd.DataFrame) -> str:
        """
        Convert DataFrame to CSV string format.
        Useful for debugging or saving intermediate results.
        """
        return df.to_csv(index=False)

    @staticmethod
    def load_algorithm_config(algorithm_type: str, recommendation_id: str, supabase: Client) -> Dict[str, Any]:
        """
        Load algorithm configuration for a specific recommendation.

        Args:
            algorithm_type: e.g., 'binary_threshold', 'proportional'
            recommendation_id: The recommendation record ID
            supabase: Supabase client

        Returns:
            Algorithm configuration dict
        """
        response = supabase.table("recommendations_v2") \
            .select("config") \
            .eq("record_id", recommendation_id) \
            .single() \
            .execute()

        if not response.data:
            raise ValueError(f"Recommendation {recommendation_id} not found")

        return response.data.get("config", {})
