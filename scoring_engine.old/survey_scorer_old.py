"""
Survey Scoring Engine - Uses Supabase survey data
Simplified scorer that uses database response scores
"""

import pandas as pd
from typing import Dict, Optional


class SurveyScorer:
    """Scores survey responses using database response scores."""

    def __init__(self):
        # Simplified - no module import needed
        pass

    def score_patient_surveys(
        self,
        survey_responses: pd.DataFrame,
        patient_info: Optional[Dict] = None
    ) -> Dict:
        """
        Score all survey responses for a patient.

        Args:
            survey_responses: DataFrame with columns:
                - question_id
                - response (the answer text or value)
                - pillar_name
                - score (optional, from response options)
            patient_info: Patient demographics (age, sex, weight, etc.)

        Returns:
            Dict with pillar scores and question details
        """
        if survey_responses.empty:
            return {
                'pillar_scores': {},
                'question_details': []
            }

        # Transform to the format expected by survey_scorer_base
        # It expects a row dict with question IDs as keys
        patient_row = {}

        # Map responses to question IDs
        for _, resp in survey_responses.iterrows():
            q_id = resp.get('question_id', '')
            answer = resp.get('response', '') or resp.get('option_text', '')
            patient_row[q_id] = answer

        # Add patient info if available
        if patient_info:
            patient_row['age'] = patient_info.get('age', 40)
            patient_row['sex'] = patient_info.get('gender', 'M')
            patient_row['weight'] = patient_info.get('weight', 160)
        else:
            # Defaults
            patient_row['age'] = 40
            patient_row['sex'] = 'M'
            patient_row['weight'] = 160

        # Use the survey scoring functions from the base module
        # This would call the comprehensive scoring logic
        # For now, return a simplified structure

        pillar_scores = {}
        question_details = []

        # Group by pillar and sum scores
        for _, resp in survey_responses.iterrows():
            pillar = resp.get('pillar_name', 'Unknown')
            score = float(resp.get('score', 0))

            if pillar not in pillar_scores:
                pillar_scores[pillar] = {
                    'total_score': 0,
                    'max_score': 0,
                    'questions': []
                }

            pillar_scores[pillar]['total_score'] += score
            pillar_scores[pillar]['max_score'] += 10  # Assuming max 10 per question
            pillar_scores[pillar]['questions'].append({
                'question_id': resp.get('question_id'),
                'response': resp.get('response', ''),
                'score': score
            })

            question_details.append({
                'question_id': resp.get('question_id'),
                'pillar': pillar,
                'score': score,
                'response': resp.get('response', '')
            })

        # Calculate percentages
        for pillar in pillar_scores:
            total = pillar_scores[pillar]['total_score']
            max_score = pillar_scores[pillar]['max_score']
            pillar_scores[pillar]['percentage'] = (total / max_score * 100) if max_score > 0 else 0

        return {
            'pillar_scores': pillar_scores,
            'question_details': question_details
        }
