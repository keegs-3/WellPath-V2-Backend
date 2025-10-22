"""
WellPath Scoring Service - Database-driven scoring engine
Adapts the existing scoring runners to work with Supabase data
"""

import pandas as pd
import json
from pathlib import Path
from typing import Dict, List, Optional
from database.postgres_client import PostgresClient
from scoring_engine.utils.data_fetcher import PatientDataFetcher
from scoring_engine.biomarker_scorer import BiomarkerScorer
from scoring_engine.survey_scorer import SurveyScorer


class WellPathScoringService:
    """Main scoring service that orchestrates biomarker and survey scoring."""

    # Pillar weights configuration from Scoring factors.xlsx (markers + survey + education = 1.0)
    PILLAR_WEIGHTS = {
        "Healthful Nutrition": {"markers": 0.72, "survey": 0.18, "education": 0.10},
        "Movement + Exercise": {"markers": 0.54, "survey": 0.36, "education": 0.10},
        "Restorative Sleep": {"markers": 0.63, "survey": 0.27, "education": 0.10},
        "Cognitive Health": {"markers": 0.36, "survey": 0.54, "education": 0.10},
        "Stress Management": {"markers": 0.27, "survey": 0.63, "education": 0.10},
        "Connection + Purpose": {"markers": 0.18, "survey": 0.72, "education": 0.10},
        "Core Care": {"markers": 0.495, "survey": 0.405, "education": 0.10}
    }

    def __init__(self, db: PostgresClient):
        self.db = db
        self.data_fetcher = PatientDataFetcher(db)
        self.biomarker_scorer = BiomarkerScorer()
        self.survey_scorer = SurveyScorer()

        # Load marker name mapping
        mapping_path = Path(__file__).parent / 'configs' / 'marker_name_mapping.json'
        with open(mapping_path) as f:
            self.marker_name_mapping = json.load(f)

    def calculate_patient_scores(self, patient_id: str) -> Dict:
        """
        Calculate comprehensive WellPath scores for a patient.

        Returns:
            Dict with pillar scores, biomarker details, survey details, and overall score
        """
        # Fetch patient data (no fallback - let errors surface)
        biomarkers_df = self.data_fetcher.get_patient_biomarkers(patient_id)
        surveys_df = self.data_fetcher.get_patient_survey_responses(patient_id)
        patient_info = self.data_fetcher.get_patient_details(patient_id)

        # Transform biomarker DataFrame to dict for scorer using mapping table
        biomarker_dict = {}
        unmapped_markers = []

        if not biomarkers_df.empty:
            for _, row in biomarkers_df.iterrows():
                marker_name = row['marker_name']

                # Use mapping table to get config key
                if marker_name in self.marker_name_mapping:
                    marker_key = self.marker_name_mapping[marker_name]
                    biomarker_dict[marker_key] = float(row['value'])
                else:
                    unmapped_markers.append(marker_name)

        # Log unmapped markers for debugging
        if unmapped_markers:
            print(f"⚠️  Unmapped markers: {unmapped_markers}")

        print(f"📊 Biomarker dict size: {len(biomarker_dict)} markers")
        if len(biomarker_dict) > 0:
            print(f"   Sample markers: {list(biomarker_dict.keys())[:5]}")

        # Score biomarkers
        biomarker_results = self.biomarker_scorer.score_patient_biomarkers(
            biomarker_dict,
            patient_info
        )

        print(f"📈 Biomarker results: {len(biomarker_results.get('pillar_scores', {}))} pillars scored")

        # Score surveys using database-based scoring
        print(f"📋 Survey DataFrame shape: {surveys_df.shape}")
        if not surveys_df.empty:
            print(f"   Sample survey data: {surveys_df.head(3).to_dict('records')}")

        survey_results = self.survey_scorer.score_patient_surveys(
            surveys_df,
            patient_info
        )

        print(f"📊 Survey results: {len(survey_results.get('pillar_scores', {}))} pillars scored")

        # Combine scores using PILLAR_WEIGHTS
        combined_pillar_scores = {}
        for pillar, weights in self.PILLAR_WEIGHTS.items():
            # Get component scores
            marker_score = 0
            if pillar in biomarker_results['pillar_scores']:
                marker_score = biomarker_results['pillar_scores'][pillar]['percentage']

            survey_score = 0
            if pillar in survey_results['pillar_scores']:
                survey_score = survey_results['pillar_scores'][pillar]['percentage']

            # Education score (set to 0 to match GT - no education tracking yet)
            education_score = 0

            # Weighted combination
            combined_score = (
                marker_score * weights['markers'] +
                survey_score * weights['survey'] +
                education_score * weights['education']
            )

            combined_pillar_scores[pillar] = round(combined_score, 2)

        # Calculate overall score
        overall_score = sum(combined_pillar_scores.values()) / len(combined_pillar_scores) if combined_pillar_scores else 0

        return {
            'patient_id': patient_id,
            'overall_score': round(overall_score, 2),
            'pillar_scores': combined_pillar_scores,
            'biomarker_details': biomarker_results,
            'survey_details': survey_results,
            'adherence_details': {},
            'patient_info': patient_info
        }

    def _get_mock_scores(self, patient_id: str) -> Dict:
        """Return mock scores when database is unavailable."""
        pillar_scores = {
            "Healthful Nutrition": 75.0,
            "Movement + Exercise": 68.0,
            "Restorative Sleep": 82.0,
            "Cognitive Health": 71.0,
            "Stress Management": 65.0,
            "Connection + Purpose": 78.0,
            "Core Care": 73.0
        }

        overall_score = sum(pillar_scores.values()) / len(pillar_scores)

        return {
            'patient_id': patient_id,
            'overall_score': round(overall_score, 2),
            'pillar_scores': pillar_scores,
            'biomarker_details': {},
            'survey_details': {},
            'adherence_details': {},
            'patient_info': None
        }

    def _calculate_biomarker_scores(
        self,
        biomarkers_df: pd.DataFrame,
        patient_info: Dict
    ) -> Dict[str, Dict]:
        """
        Calculate biomarker scores for each pillar.

        Uses the ranges and scoring logic from the marker config.
        """
        if biomarkers_df.empty:
            return {}

        pillar_scores = {}

        # Get pillar weights for each biomarker
        for _, row in biomarkers_df.iterrows():
            marker_name = row['marker_name']
            value = row['value']

            # Score this biomarker value
            marker_score = self._score_biomarker_value(
                marker_name,
                value,
                patient_info
            )

            # For now, assign to a default pillar based on marker category
            # TODO: Load actual pillar weights from database
            pillar = self._get_marker_pillar(row.get('category', 'unknown'))
            pillar_weights = {pillar: 10}

            # Distribute score to pillars based on weights
            for pillar, weight in pillar_weights.items():
                if pillar not in pillar_scores:
                    pillar_scores[pillar] = {
                        'markers': [],
                        'total_score': 0,
                        'max_score': 0,
                        'weighted_score': 0
                    }

                weighted_contribution = marker_score * (weight / 10.0)  # Normalize weight
                pillar_scores[pillar]['markers'].append({
                    'name': marker_name,
                    'value': value,
                    'raw_score': marker_score,
                    'weight': weight,
                    'weighted_contribution': weighted_contribution
                })
                pillar_scores[pillar]['total_score'] += marker_score
                pillar_scores[pillar]['max_score'] += 10  # Max score per marker is 10
                pillar_scores[pillar]['weighted_score'] += weighted_contribution

        return pillar_scores

    def _get_marker_pillar(self, category: str) -> str:
        """Map marker category to pillar (simplified for now)."""
        category_pillar_map = {
            'Cardiovascular': 'Core Care',
            'Metabolic': 'Healthful Nutrition',
            'Hormonal': 'Core Care',
            'Inflammatory': 'Core Care',
            'Cognitive': 'Cognitive Health',
            'Sleep': 'Restorative Sleep',
        }
        return category_pillar_map.get(category, 'Core Care')

    def _score_biomarker_value(
        self,
        marker_name: str,
        value: float,
        patient_info: Dict
    ) -> float:
        """
        Score a single biomarker value based on ranges.

        This uses hardcoded ranges for now - in production, these would come
        from the database or a config file.
        """
        # TODO: Load scoring ranges from database
        # For now, return a simple score based on value being in normal range

        # Example scoring logic (would be replaced with actual range-based scoring)
        if marker_name.lower() in ['total_cholesterol', 'ldl']:
            if value <= 200:
                return 10.0
            elif value <= 240:
                return 7.0
            else:
                return 0.0
        elif marker_name.lower() == 'hdl':
            if value >= 60:
                return 10.0
            elif value >= 40:
                return 7.0
            else:
                return 0.0
        else:
            # Default scoring
            return 7.0

    def _calculate_survey_scores(self, survey_df: pd.DataFrame) -> Dict[str, Dict]:
        """
        Calculate survey scores for each pillar.

        Each question has a score_value from the response option and contributes
        to one or more pillars.
        """
        if survey_df.empty:
            return {}

        pillar_scores = {}

        for _, row in survey_df.iterrows():
            pillar = row.get('pillar_name')
            if not pillar:
                continue

            if pillar not in pillar_scores:
                pillar_scores[pillar] = {
                    'questions': [],
                    'total_score': 0,
                    'max_score': 0
                }

            score_value = row.get('score_value', 0)
            question_text = row.get('question', 'Unknown')

            pillar_scores[pillar]['questions'].append({
                'question': question_text,
                'response': row.get('option_text'),
                'score': score_value
            })
            pillar_scores[pillar]['total_score'] += score_value
            pillar_scores[pillar]['max_score'] += 10  # Assuming max 10 per question

        return pillar_scores

    def _calculate_adherence_scores(self, adherence_df: pd.DataFrame) -> Dict:
        """
        Calculate adherence scores from recommendation tracking data.

        Uses the 14 adherence algorithms to score daily tracking.
        """
        if adherence_df.empty:
            return {}

        # TODO: Implement adherence algorithm scoring
        # This would use the algorithm configs from the database
        # and apply them to the daily adherence data

        return {
            'total_recommendations': len(adherence_df['recommendation_id'].unique()),
            'adherence_rate': adherence_df['completed'].mean() if len(adherence_df) > 0 else 0
        }

    def _combine_pillar_scores(
        self,
        biomarker_scores: Dict,
        survey_scores: Dict,
        adherence_scores: Dict
    ) -> Dict[str, float]:
        """
        Combine biomarker, survey, and adherence scores into final pillar scores.

        Uses the PILLAR_WEIGHTS configuration to weight each component.
        """
        combined_scores = {}

        for pillar, weights in self.PILLAR_WEIGHTS.items():
            # Get component scores
            marker_score = 0
            if pillar in biomarker_scores:
                marker_total = biomarker_scores[pillar]['total_score']
                marker_max = biomarker_scores[pillar]['max_score']
                marker_score = (marker_total / marker_max * 100) if marker_max > 0 else 0

            survey_score = 0
            if pillar in survey_scores:
                survey_total = survey_scores[pillar]['total_score']
                survey_max = survey_scores[pillar]['max_score']
                survey_score = (survey_total / survey_max * 100) if survey_max > 0 else 0

            # Education score (set to 0 - no education tracking yet)
            education_score = 0

            # Weighted combination
            final_score = (
                marker_score * weights['markers'] +
                survey_score * weights['survey'] +
                education_score * weights['education']
            )

            combined_scores[pillar] = round(final_score, 2)

        return combined_scores

    def _calculate_overall_score(self, pillar_scores: Dict[str, float]) -> float:
        """Calculate overall WellPath score from pillar scores."""
        if not pillar_scores:
            return 0.0

        # Equal weight for all pillars
        return round(sum(pillar_scores.values()) / len(pillar_scores), 2)

    def get_detailed_marker_contributions(self, patient_id: str) -> List[Dict]:
        """
        Get detailed breakdown of individual biomarker contributions to each pillar.

        Returns list of markers with their values, scores, and pillar contributions.
        """
        # Fetch patient data
        biomarkers_df = self.data_fetcher.get_patient_biomarkers(patient_id)
        patient_info = self.data_fetcher.get_patient_details(patient_id)

        # Transform biomarker DataFrame to dict
        biomarker_dict = {}
        if not biomarkers_df.empty:
            for _, row in biomarkers_df.iterrows():
                marker_name = row['marker_name']
                if marker_name in self.marker_name_mapping:
                    marker_key = self.marker_name_mapping[marker_name]
                    biomarker_dict[marker_key] = float(row['value'])

        # Score each biomarker and get detailed contributions
        marker_contributions = []
        for marker_key, value in biomarker_dict.items():
            result = self.biomarker_scorer.score_value(marker_key, value, patient_info)

            if 'error' not in result:
                marker_detail = {
                    'marker_name': result['marker'],
                    'lab_value': result['value'],
                    'raw_score': result['score'],  # Normalized 0-1
                    'range_label': result['range_label'],
                    'pillar_contributions': []
                }

                # Add pillar-specific contributions
                for pillar, contribution in result['pillar_contributions'].items():
                    marker_detail['pillar_contributions'].append({
                        'pillar': pillar,
                        'weight': contribution['weight'],
                        'weighted_score': contribution['weighted_score'],
                        'max_score': contribution['max_score'],
                        'percentage': (contribution['weighted_score'] / contribution['max_score'] * 100) if contribution['max_score'] > 0 else 0
                    })

                marker_contributions.append(marker_detail)

        return marker_contributions

    def get_detailed_survey_contributions(self, patient_id: str) -> List[Dict]:
        """
        Get detailed breakdown of individual survey question contributions to each pillar.

        Returns list of questions with their responses, scores, and pillar contributions.
        """
        # Fetch survey data
        surveys_df = self.data_fetcher.get_patient_survey_responses(patient_id)
        patient_info = self.data_fetcher.get_patient_details(patient_id)

        # Score surveys
        survey_results = self.survey_scorer.score_patient_surveys(surveys_df, patient_info)

        # Extract question details
        question_contributions = []
        for question in survey_results.get('question_details', []):
            question_contributions.append({
                'question_id': question.get('question_id'),
                'question_text': question.get('question'),
                'response': question.get('answer'),  # Field is called 'answer' in survey_scorer
                'raw_score': question.get('raw_score'),
                'pillar': question.get('pillar'),
                'weight': question.get('weight'),
                'weighted_score': question.get('weighted_score'),
                'max_weighted': question.get('max_weighted')
            })

        return question_contributions

    def get_score_breakdown(self, patient_id: str) -> Dict:
        """
        Get detailed breakdown of all pillar scores showing individual component contributions.

        Returns survey, biomarker, and education contributions for each pillar.
        """
        from scoring_engine.education_scorer import EducationScorer

        # Get all scores
        scores = self.calculate_patient_scores(patient_id)

        # Get education scores separately
        education_scorer = EducationScorer(self.db)
        education_scores = education_scorer.get_all_education_scores(patient_id)

        breakdown = {}
        for pillar_name in scores['pillar_scores'].keys():
            # Extract scores from the detailed results
            # Survey scores are in survey_details -> pillar_scores -> pillar_name -> percentage
            survey_pillar_data = scores['survey_details'].get('pillar_scores', {}).get(pillar_name, {})
            survey_score = survey_pillar_data.get('percentage', 0) if isinstance(survey_pillar_data, dict) else 0
            survey_raw_score = survey_pillar_data.get('raw_score', 0) if isinstance(survey_pillar_data, dict) else 0
            survey_max_score = survey_pillar_data.get('max_score', 0) if isinstance(survey_pillar_data, dict) else 0

            # Biomarker scores are in biomarker_details -> pillar_scores -> pillar_name -> percentage
            biomarker_pillar_data = scores['biomarker_details'].get('pillar_scores', {}).get(pillar_name, {})
            biomarker_score = biomarker_pillar_data.get('percentage', 0) if isinstance(biomarker_pillar_data, dict) else 0
            biomarker_raw_score = biomarker_pillar_data.get('raw_score', 0) if isinstance(biomarker_pillar_data, dict) else 0
            biomarker_max_score = biomarker_pillar_data.get('max_score', 0) if isinstance(biomarker_pillar_data, dict) else 0

            # Get weight from PILLAR_WEIGHTS
            weights = self.PILLAR_WEIGHTS.get(pillar_name, {})

            breakdown[pillar_name] = {
                'total_score': scores['pillar_scores'][pillar_name],
                'components': {
                    'survey': {
                        'raw_score': survey_raw_score,
                        'max_score': survey_max_score,
                        'normalized': round(survey_score, 2),
                        'weight': weights.get('survey', 0),
                        'contribution': round(survey_score * weights.get('survey', 0), 2)
                    },
                    'biomarker': {
                        'raw_score': biomarker_raw_score,
                        'max_score': biomarker_max_score,
                        'normalized': round(biomarker_score, 2),
                        'weight': weights.get('markers', 0),
                        'contribution': round(biomarker_score * weights.get('markers', 0), 2)
                    },
                    'education': {
                        'raw_score': education_scores.get(pillar_name, 0),
                        'max_score': 10.0,
                        'normalized': round(education_scores.get(pillar_name, 0) * 10, 2),
                        'weight': weights.get('education', 0),
                        'contribution': round(education_scores.get(pillar_name, 0) * 10 * weights.get('education', 0) / 100, 2)
                    }
                }
            }

        # Add detailed individual contributions
        breakdown['detailed_biomarker_contributions'] = self.get_detailed_marker_contributions(patient_id)
        breakdown['detailed_survey_contributions'] = self.get_detailed_survey_contributions(patient_id)

        return breakdown

    def get_pillar_breakdown(self, patient_id: str, pillar_name: str) -> Dict:
        """
        Get detailed breakdown of a specific pillar score.

        Returns all contributing factors: biomarkers, survey questions, adherence.
        """
        scores = self.calculate_patient_scores(patient_id)

        return {
            'pillar_name': pillar_name,
            'total_score': scores['pillar_scores'].get(pillar_name, 0),
            'biomarker_contribution': scores['biomarker_details'].get(pillar_name, {}),
            'survey_contribution': scores['survey_details'].get(pillar_name, {}),
            'adherence_contribution': scores['adherence_details']
        }
