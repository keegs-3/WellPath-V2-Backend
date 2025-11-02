"""
Recommendation Matcher

Uses AI to match patients to appropriate recommendations based on their
biomarker and biometric data, behavioral patterns, and health goals.
"""

import os
import logging
from datetime import date
from typing import Dict, List, Optional, Any
from uuid import UUID
import json

from anthropic import Anthropic

from database.postgres_client import get_db_connection
from .context_builder import ContextBuilder

logger = logging.getLogger(__name__)


class RecommendationMatcher:
    """
    AI-powered recommendation matching system.

    Analyzes patient data to suggest appropriate recommendations:
    - Primary biomarkers out of range
    - Biometric concerns
    - Behavioral patterns
    - User preferences and capacity
    """

    def __init__(self, anthropic_api_key: Optional[str] = None, db_connection=None):
        """Initialize Recommendation Matcher."""
        self.client = Anthropic(api_key=anthropic_api_key or os.getenv('ANTHROPIC_API_KEY'))
        self.db = db_connection or get_db_connection()
        self.context_builder = ContextBuilder(self.db)
        self.model = "claude-sonnet-4-20250514"

    async def match_recommendations_for_patient(
        self,
        patient_id: UUID,
        max_recommendations: int = 10,
        difficulty_preference: str = "progressive"  # 'easy', 'moderate', 'progressive'
    ) -> List[Dict[str, Any]]:
        """
        Match patient to appropriate recommendations using AI.

        Args:
            patient_id: Patient UUID
            max_recommendations: Maximum number to recommend
            difficulty_preference: Difficulty approach

        Returns:
            List of recommended recommendations with reasoning
        """
        logger.info(f"Matching recommendations for patient {patient_id}")

        # Build patient context
        context = await self.context_builder.build_full_context(patient_id, date.today())

        # Get all available recommendations
        available_recs = await self._get_available_recommendations()

        # Use AI to match
        matches = await self._ai_match_recommendations(
            context=context,
            available_recommendations=available_recs,
            max_recommendations=max_recommendations,
            difficulty_preference=difficulty_preference
        )

        return matches

    async def assign_recommendations_to_patient(
        self,
        patient_id: UUID,
        recommendation_ids: List[str],
        start_date: Optional[date] = None
    ) -> List[Dict[str, Any]]:
        """
        Assign recommendations to a patient.

        Args:
            patient_id: Patient UUID
            recommendation_ids: List of rec_ids to assign
            start_date: When to start (defaults to today)

        Returns:
            List of created patient_recommendations
        """
        if start_date is None:
            start_date = date.today()

        assigned = []

        for rec_id in recommendation_ids:
            # Get recommendation UUID
            with self.db.cursor() as cursor:
                cursor.execute(
                    "SELECT id FROM recommendations_base WHERE rec_id = %s",
                    (rec_id,)
                )
                row = cursor.fetchone()
                if not row:
                    logger.warning(f"Recommendation {rec_id} not found")
                    continue

                rec_uuid = row[0]

            # Insert patient_recommendation
            query = """
            INSERT INTO patient_recommendations (
                patient_id, recommendation_id, status, assigned_date, start_date
            ) VALUES (%s, %s, 'active', %s, %s)
            ON CONFLICT (patient_id, recommendation_id) DO NOTHING
            RETURNING id, recommendation_id
            """

            with self.db.cursor() as cursor:
                cursor.execute(query, (
                    patient_id,
                    rec_uuid,
                    start_date,
                    start_date
                ))
                result = cursor.fetchone()
                if result:
                    assigned.append({
                        "patient_recommendation_id": str(result[0]),
                        "recommendation_id": str(result[1]),
                        "rec_id": rec_id,
                        "status": "active",
                        "start_date": start_date.isoformat()
                    })
                self.db.commit()

        logger.info(f"Assigned {len(assigned)} recommendations to patient {patient_id}")
        return assigned

    async def _get_available_recommendations(self) -> List[Dict[str, Any]]:
        """Get all available recommendations from database."""
        query = """
        SELECT
            rec_id,
            title,
            overview,
            agent_goal,
            pillar,
            recommendation_type,
            primary_biomarkers,
            secondary_biomarkers,
            tertiary_biomarkers,
            primary_biometrics,
            secondary_biometrics,
            tertiary_biometrics,
            level,
            contraindications
        FROM recommendations_base
        WHERE is_active = true
          AND agent_enabled = true
        ORDER BY rec_id
        """

        with self.db.cursor() as cursor:
            cursor.execute(query)
            rows = cursor.fetchall()

        recommendations = []
        for row in rows:
            recommendations.append({
                "rec_id": row[0],
                "title": row[1],
                "overview": row[2],
                "agent_goal": row[3],
                "pillar": row[4],
                "type": row[5],
                "primary_biomarkers": row[6].split(',') if row[6] else [],
                "secondary_biomarkers": row[7].split(',') if row[7] else [],
                "tertiary_biomarkers": row[8].split(',') if row[8] else [],
                "primary_biometrics": row[9].split(',') if row[9] else [],
                "secondary_biometrics": row[10].split(',') if row[10] else [],
                "tertiary_biometrics": row[11].split(',') if row[11] else [],
                "difficulty_level": row[12],
                "contraindications": row[13]
            })

        return recommendations

    async def _ai_match_recommendations(
        self,
        context: Dict[str, Any],
        available_recommendations: List[Dict[str, Any]],
        max_recommendations: int,
        difficulty_preference: str
    ) -> List[Dict[str, Any]]:
        """Use AI to match patient to recommendations."""

        prompt = self._build_matching_prompt(
            context=context,
            available_recommendations=available_recommendations,
            max_recommendations=max_recommendations,
            difficulty_preference=difficulty_preference
        )

        try:
            response = self.client.messages.create(
                model=self.model,
                max_tokens=4000,
                temperature=0.5,
                system=self._get_matching_system_prompt(),
                messages=[{
                    "role": "user",
                    "content": prompt
                }]
            )

            response_text = response.content[0].text
            matches = self._parse_matching_response(response_text)

            logger.info(f"AI matched {len(matches)} recommendations")
            return matches

        except Exception as e:
            logger.error(f"Error in AI matching: {str(e)}")
            return []

    def _get_matching_system_prompt(self) -> str:
        """System prompt for recommendation matching."""
        return """You are an expert physician assistant helping match patients to personalized health recommendations.

Your role is to analyze patient biomarkers, biometrics, and health data, then recommend the most appropriate health interventions.

Matching Principles:
1. **Primary Priority**: Target significantly out-of-range biomarkers first
2. **Secondary Priority**: Address borderline biomarkers and biometric concerns
3. **Behavioral Consideration**: Don't recommend what they already do well
4. **Capacity Awareness**: Don't overwhelm - start with achievable changes
5. **Progressive Difficulty**: Build confidence with early wins

Biomarker Priority Levels:
- **Primary**: Recommendation directly targets this biomarker (strongest impact)
- **Secondary**: Recommendation has moderate impact
- **Tertiary**: Recommendation has minor/indirect impact

Response Format (JSON):
{
  "matches": [
    {
      "rec_id": "REC0001.1",
      "priority": 1,
      "reasoning": "Why this recommendation fits this patient",
      "target_biomarkers": ["LDL", "ApoB"],
      "expected_impact": "Brief description of expected benefit",
      "difficulty_appropriate": true
    }
  ]
}

Order recommendations by priority (most important first).
Only recommend what the patient can realistically achieve."""

    def _build_matching_prompt(
        self,
        context: Dict[str, Any],
        available_recommendations: List[Dict[str, Any]],
        max_recommendations: int,
        difficulty_preference: str
    ) -> str:
        """Build prompt for recommendation matching."""

        prompt_parts = [
            f"Match this patient to the top {max_recommendations} most appropriate recommendations.",
            f"Difficulty Preference: {difficulty_preference}",
            "\n=== PATIENT DATA ===\n"
        ]

        # Patient biomarkers
        bio = context['biomarkers']
        if bio['out_of_range']:
            prompt_parts.append(f"Out of Range Biomarkers ({len(bio['out_of_range'])}):")
            for b in bio['out_of_range'][:10]:
                prompt_parts.append(
                    f"  - {b['biomarker']}: {b['value']} ({b['deviation']} - optimal: {b['optimal_range']})"
                )

        # Patient biometrics
        if context['biometrics']['readings']:
            prompt_parts.append(f"\nBiometric Readings:")
            for name, data in list(context['biometrics']['readings'].items())[:5]:
                prompt_parts.append(f"  - {name}: {data['value']} {data['unit']}")

        # Behavioral data (what they already do)
        if context['behavioral_data']['tracked_behaviors']:
            prompt_parts.append(f"\nCurrent Behaviors:")
            for behavior, entries in list(context['behavioral_data']['tracked_behaviors'].items())[:5]:
                if entries:
                    latest = entries[0]
                    prompt_parts.append(f"  - {behavior}: {latest['value']} (recent entry)")

        # Available recommendations
        prompt_parts.append("\n=== AVAILABLE RECOMMENDATIONS ===\n")
        for rec in available_recommendations:
            prompt_parts.append(f"\n{rec['rec_id']}: {rec['title']}")
            if rec['agent_goal']:
                prompt_parts.append(f"  Goal: {rec['agent_goal']}")
            prompt_parts.append(f"  Pillar: {rec['pillar']}")
            prompt_parts.append(f"  Difficulty: Level {rec['difficulty_level']}")

            if rec['primary_biomarkers']:
                prompt_parts.append(f"  Primary Biomarkers: {', '.join(rec['primary_biomarkers'])}")
            if rec['secondary_biomarkers']:
                prompt_parts.append(f"  Secondary Biomarkers: {', '.join(rec['secondary_biomarkers'])}")

        return "\n".join(prompt_parts)

    def _parse_matching_response(self, response_text: str) -> List[Dict[str, Any]]:
        """Parse AI matching response."""
        try:
            if "```json" in response_text:
                json_start = response_text.find("```json") + 7
                json_end = response_text.find("```", json_start)
                json_str = response_text[json_start:json_end].strip()
            elif "{" in response_text:
                json_start = response_text.find("{")
                json_end = response_text.rfind("}") + 1
                json_str = response_text[json_start:json_end]
            else:
                raise ValueError("No JSON found in response")

            result = json.loads(json_str)
            return result.get('matches', [])

        except Exception as e:
            logger.error(f"Error parsing matching response: {str(e)}")
            return []
