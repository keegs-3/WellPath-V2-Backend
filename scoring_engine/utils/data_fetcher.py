"""
Fetch patient data from PostgreSQL and convert to pandas DataFrames.
Uses direct SQL queries for maximum performance.
"""

import pandas as pd
from typing import Dict, Optional
from database.postgres_client import PostgresClient


class PatientDataFetcher:
    """Fetches and transforms patient data for scoring algorithms."""

    def __init__(self, db: PostgresClient):
        self.db = db

    def get_patient_survey_responses(self, patient_id: str) -> pd.DataFrame:
        """
        Fetch patient survey responses with question metadata.

        Returns DataFrame with all data needed for survey scoring.
        """
        query = """
        SELECT
            pr.patient_id,
            pr.question_id,
            pr.response_option_id,
            pr.created_at as response_date,
            sq.question,
            sq.pillar_id,
            p.name as pillar_name,
            sro.option_text,
            sro.score_value,
            -- Get linked calculated metrics via junction table
            ARRAY_AGG(DISTINCT cm.name) FILTER (WHERE cm.name IS NOT NULL) as calculated_metrics
        FROM patient_responses pr
        JOIN survey_questions sq ON pr.question_id = sq.record_id
        LEFT JOIN pillars p ON sq.pillar_id = p.record_id
        LEFT JOIN survey_response_options sro ON pr.response_option_id = sro.record_id
        LEFT JOIN survey_question_calculated_metrics sqcm ON sq.record_id = sqcm.survey_question_id
        LEFT JOIN calculated_metrics_vfinal cm ON sqcm.calculated_metric_id = cm.record_id
        WHERE pr.patient_id = %s
        GROUP BY pr.patient_id, pr.question_id, pr.response_option_id, pr.created_at,
                 sq.question, sq.pillar_id, p.name, sro.option_text, sro.score_value
        ORDER BY pr.created_at DESC
        """

        rows = self.db.execute_query(query, (patient_id,))
        return pd.DataFrame(rows)

    def get_patient_biomarkers(self, patient_id: str) -> pd.DataFrame:
        """
        Fetch patient biomarker data with marker metadata.

        Returns DataFrame with biomarker values, ranges, and pillar mappings.
        """
        query = """
        SELECT
            pb.patient_id,
            pb.marker_id,
            pb.value,
            pb.unit,
            pb.measured_at,
            im.name as marker_name,
            im.category,
            -- Get linked metrics via junction table
            ARRAY_AGG(DISTINCT mt.name) FILTER (WHERE mt.name IS NOT NULL) as metric_types,
            ARRAY_AGG(DISTINCT cm.name) FILTER (WHERE cm.name IS NOT NULL) as calculated_metrics,
            -- Pillar weights for this marker
            JSON_OBJECT_AGG(
                p.name,
                bpw.weight
            ) FILTER (WHERE p.name IS NOT NULL) as pillar_weights
        FROM patient_biomarkers pb
        JOIN intake_markers im ON pb.marker_id = im.record_id
        LEFT JOIN intake_metric_metric_types immt ON im.record_id = immt.intake_metric_id
        LEFT JOIN metric_types_vfinal mt ON immt.metric_type_id = mt.record_id
        LEFT JOIN intake_metric_calculated_metrics imcm ON im.record_id = imcm.intake_metric_id
        LEFT JOIN calculated_metrics_vfinal cm ON imcm.calculated_metric_id = cm.record_id
        LEFT JOIN biomarker_pillar_weights bpw ON im.record_id = bpw.biomarker_id
        LEFT JOIN pillars p ON bpw.pillar_id = p.record_id
        WHERE pb.patient_id = %s
        GROUP BY pb.patient_id, pb.marker_id, pb.value, pb.unit, pb.measured_at,
                 im.name, im.category
        ORDER BY pb.measured_at DESC
        """

        rows = self.db.execute_query(query, (patient_id,))
        return pd.DataFrame(rows)

    def get_patient_metric_tracking(
        self,
        patient_id: str,
        days: int = 30,
        metric_type_id: Optional[str] = None
    ) -> pd.DataFrame:
        """
        Fetch patient's daily tracked metrics (steps, sleep, etc.).

        Args:
            patient_id: Patient UUID
            days: Number of days to fetch (default 30)
            metric_type_id: Optional filter for specific metric

        Returns:
            DataFrame with daily metric values
        """
        query = """
        SELECT
            pmt.patient_id,
            pmt.metric_type_id,
            pmt.date,
            pmt.value,
            pmt.unit,
            mt.name as metric_name,
            mt.tracking_method,
            mt.data_type,
            mt.source_type,
            p.name as pillar_name
        FROM patient_metric_tracking pmt
        JOIN metric_types_vfinal mt ON pmt.metric_type_id = mt.record_id
        LEFT JOIN pillars p ON mt.pillar_id = p.record_id
        WHERE pmt.patient_id = %s
          AND pmt.date >= CURRENT_DATE - INTERVAL '%s days'
        """

        params = [patient_id, days]

        if metric_type_id:
            query += " AND pmt.metric_type_id = %s"
            params.append(metric_type_id)

        query += " ORDER BY pmt.date DESC, mt.name"

        rows = self.db.execute_query(query, tuple(params))
        return pd.DataFrame(rows)

    def get_patient_recommendation_adherence(
        self,
        patient_id: str,
        recommendation_id: Optional[str] = None,
        days: int = 30
    ) -> pd.DataFrame:
        """
        Fetch patient's recommendation adherence tracking.

        Returns DataFrame with daily adherence data and algorithm configs.
        """
        query = """
        SELECT
            pra.patient_id,
            pra.recommendation_id,
            pra.date,
            pra.completed,
            pra.metric_value,
            r.name as recommendation_name,
            r.algorithm_type,
            r.config,
            r.recommendation_type,
            p.name as pillar_name
        FROM patient_recommendation_adherence pra
        JOIN recommendations_v2 r ON pra.recommendation_id = r.record_id
        LEFT JOIN pillars p ON r.pillar_id = p.record_id
        WHERE pra.patient_id = %s
          AND pra.date >= CURRENT_DATE - INTERVAL '%s days'
        """

        params = [patient_id, days]

        if recommendation_id:
            query += " AND pra.recommendation_id = %s"
            params.append(recommendation_id)

        query += " ORDER BY pra.date DESC"

        rows = self.db.execute_query(query, tuple(params))
        return pd.DataFrame(rows)

    def get_patient_details(self, patient_id: str) -> Optional[Dict]:
        """Get patient demographic and profile information."""
        query = """
        SELECT
            pd.*,
            u.email,
            u.first_name,
            u.last_name
        FROM patient_details pd
        LEFT JOIN auth_users u ON pd.id = u.id
        WHERE pd.id = %s
        """

        return self.db.execute_single(query, (patient_id,))

    def get_all_patient_data(self, patient_id: str, days: int = 30) -> Dict[str, pd.DataFrame]:
        """
        Fetch all patient data needed for comprehensive scoring.

        Returns:
            Dict with DataFrames for:
            - survey: Survey responses
            - biomarkers: Biomarker data
            - metrics: Daily tracked metrics
            - adherence: Recommendation adherence
            - patient_info: Patient demographics
        """
        return {
            'survey': self.get_patient_survey_responses(patient_id),
            'biomarkers': self.get_patient_biomarkers(patient_id),
            'metrics': self.get_patient_metric_tracking(patient_id, days),
            'adherence': self.get_patient_recommendation_adherence(patient_id, days),
            'patient_info': self.get_patient_details(patient_id)
        }

    def get_pillar_weights(self) -> pd.DataFrame:
        """
        Fetch pillar weighting configuration from database.

        Returns DataFrame with weights for biomarkers, surveys, metrics across pillars.
        """
        query = """
        SELECT
            'biomarker' as source_type,
            bpw.biomarker_id as source_id,
            im.name as source_name,
            p.name as pillar_name,
            bpw.weight
        FROM biomarker_pillar_weights bpw
        JOIN intake_markers im ON bpw.biomarker_id = im.record_id
        JOIN pillars p ON bpw.pillar_id = p.record_id

        UNION ALL

        SELECT
            'survey' as source_type,
            sqw.question_id as source_id,
            sq.question as source_name,
            p.name as pillar_name,
            sqw.weight
        FROM survey_question_pillar_weights sqw
        JOIN survey_questions sq ON sqw.question_id = sq.record_id
        JOIN pillars p ON sqw.pillar_id = p.record_id
        """

        rows = self.db.execute_query(query)
        return pd.DataFrame(rows)
