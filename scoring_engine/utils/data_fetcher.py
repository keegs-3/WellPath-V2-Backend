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

        NOTE: After foreign key migration, question_id is now a record_id (Airtable ID).
        We JOIN to survey_questions to get the numeric ID for scoring.
        """
        query = """
        SELECT
            sr.patient_id,
            sq."ID" as question_id,
            sr.response_value,
            sr.created_at as response_date
        FROM survey_responses sr
        JOIN survey_questions sq ON sr.question_id = sq.record_id
        WHERE sr.patient_id = %s
        ORDER BY sr.created_at DESC
        """

        rows = self.db.execute_query(query, (patient_id,))
        return pd.DataFrame(rows)

    def get_patient_biomarkers(self, patient_id: str) -> pd.DataFrame:
        """
        Fetch patient biomarker AND biometric data with metadata.

        Returns DataFrame combining:
        - Biomarkers (lab values) from biomarker_readings
        - Biometrics (physical measurements) from biometric_readings

        This matches preliminary_data which scores both together.
        """
        # Fetch biomarkers (lab values)
        biomarker_query = """
        SELECT
            pb.patient_id,
            pb.marker_id as id,
            pb.value,
            pb.unit,
            pb.test_date as measured_at,
            im.name as marker_name,
            'biomarker' as data_type
        FROM biomarker_readings pb
        JOIN intake_markers_raw im ON pb.marker_id = im.record_id
        WHERE pb.patient_id = %s
        ORDER BY pb.test_date DESC
        """

        # Fetch biometrics (physical measurements like BMI, VO2 Max, etc.)
        biometric_query = """
        SELECT
            br.patient_id,
            br.metric_id as id,
            br.value,
            br.unit,
            br.test_date as measured_at,
            imr.name as marker_name,
            'biometric' as data_type
        FROM biometric_readings br
        JOIN intake_metrics_raw imr ON br.metric_id = imr.record_id
        WHERE br.patient_id = %s
        ORDER BY br.test_date DESC
        """

        biomarker_rows = self.db.execute_query(biomarker_query, (patient_id,))
        biometric_rows = self.db.execute_query(biometric_query, (patient_id,))

        # Combine both into single DataFrame
        df_biomarkers = pd.DataFrame(biomarker_rows)
        df_biometrics = pd.DataFrame(biometric_rows)

        # Concatenate and return
        if df_biomarkers.empty and df_biometrics.empty:
            return pd.DataFrame()
        elif df_biomarkers.empty:
            return df_biometrics
        elif df_biometrics.empty:
            return df_biomarkers
        else:
            return pd.concat([df_biomarkers, df_biometrics], ignore_index=True)

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
            u.last_name,
            (SELECT br.value FROM biometric_readings br
             JOIN intake_metrics_raw imr ON br.metric_id = imr.record_id
             WHERE br.patient_id = pd.id AND imr.name = 'Weight'
             ORDER BY br.test_date DESC LIMIT 1) as weight_lb,
            (SELECT br.value FROM biometric_readings br
             JOIN intake_metrics_raw imr ON br.metric_id = imr.record_id
             WHERE br.patient_id = pd.id AND imr.name = 'Height'
             ORDER BY br.test_date DESC LIMIT 1) as height_in
        FROM patient_details pd
        LEFT JOIN auth_users u ON pd.id = u.id
        WHERE pd.id = %s
        """

        result = self.db.execute_single(query, (patient_id,))

        # Convert gender to sex for compatibility
        if result and 'gender' in result:
            gender_map = {'M': 'male', 'F': 'female', 'm': 'male', 'f': 'female', 'male': 'male', 'female': 'female'}
            result['sex'] = gender_map.get(result['gender'], 'unknown') if result['gender'] else 'unknown'

        return result

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
