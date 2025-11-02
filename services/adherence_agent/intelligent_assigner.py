"""
Intelligent Recommendation Assignment

Uses AI to:
1. Analyze patient biomarkers and match to recommendations
2. Provide detailed rationale for each assignment
3. Set personalized targets based on current level
4. Generate "getting started" tips
5. Create onboarding nudges
"""

import os
import logging
from datetime import date, datetime
from typing import Dict, List, Optional, Any
from uuid import UUID
import json

from anthropic import Anthropic

from database.postgres_client import get_db_connection

logger = logging.getLogger(__name__)


class IntelligentAssigner:
    """
    AI-powered intelligent recommendation assignment.

    Takes a patient's health data and recommends personalized interventions
    with detailed rationale, custom targets, and onboarding guidance.
    """

    def __init__(self, anthropic_api_key: Optional[str] = None, db_connection=None):
        """Initialize Intelligent Assigner."""
        self.client = Anthropic(api_key=anthropic_api_key or os.getenv('ANTHROPIC_API_KEY'))
        self.db = db_connection or get_db_connection()
        self.model = "claude-sonnet-4-20250514"

    async def assign_recommendations_with_intelligence(
        self,
        patient_id: UUID,
        max_recommendations: int = 8
    ) -> List[Dict[str, Any]]:
        """
        Intelligently assign recommendations to a patient with full AI reasoning.

        Returns list of assignments with:
        - Recommendation details
        - Detailed rationale
        - Personalized target
        - Getting started tips
        - Initial onboarding nudge
        """
        logger.info(f"Intelligently assigning recommendations to patient {patient_id}")

        # Get patient data
        patient_data = await self._get_patient_data(patient_id)

        # Get available recommendations
        available_recs = await self._get_available_recommendations()

        # Use AI to match with full intelligence
        assignments = await self._ai_intelligent_match(
            patient_data=patient_data,
            available_recommendations=available_recs,
            max_recommendations=max_recommendations
        )

        # Store assignments in database
        stored_assignments = []
        for assignment in assignments:
            stored = await self._store_intelligent_assignment(patient_id, assignment)
            if stored:
                stored_assignments.append(stored)

                # Generate onboarding nudge
                await self._generate_onboarding_nudge(patient_id, stored)

        return stored_assignments

    async def _get_patient_data(self, patient_id: UUID) -> Dict[str, Any]:
        """Get comprehensive patient data for matching."""
        data = {
            "patient_id": str(patient_id),
            "biomarkers": {},
            "biometrics": {},
            "survey_responses": []
        }

        # Get biomarkers
        with self.db.cursor() as cursor:
            cursor.execute("""
                SELECT biomarker_name, value, unit
                FROM patient_biomarker_readings
                WHERE patient_id = %s
                ORDER BY biomarker_name
            """, (str(patient_id),))

            for row in cursor.fetchall():
                data['biomarkers'][row[0]] = {
                    "value": float(row[1]) if row[1] else None,
                    "unit": row[2]
                }

        # Get biometrics
        with self.db.cursor() as cursor:
            cursor.execute("""
                SELECT biometric_name, value, unit
                FROM patient_biometric_readings
                WHERE patient_id = %s
                ORDER BY recorded_at DESC
            """, (str(patient_id),))

            for row in cursor.fetchall():
                if row[0] not in data['biometrics']:  # Take most recent
                    data['biometrics'][row[0]] = {
                        "value": float(row[1]) if row[1] else None,
                        "unit": row[2]
                    }

        # Get survey responses (patient's self-reported behaviors)
        with self.db.cursor() as cursor:
            cursor.execute("""
                SELECT
                    sq.question_number,
                    sq.question_text,
                    psr.response_text,
                    psr.response_value
                FROM patient_survey_responses psr
                JOIN survey_questions_base sq ON psr.question_number = sq.question_number
                WHERE psr.patient_id = %s
                ORDER BY psr.question_number
            """, (str(patient_id),))

            for row in cursor.fetchall():
                data['survey_responses'].append({
                    "question": row[1],
                    "response": row[2],
                    "value": float(row[3]) if row[3] else None
                })

        return data

    async def _get_available_recommendations(self) -> List[Dict[str, Any]]:
        """Get all available recommendations."""
        with self.db.cursor() as cursor:
            cursor.execute("""
                SELECT
                    rec_id, title, overview, agent_goal,
                    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
                    primary_biometrics, secondary_biometrics,
                    raw_impact, recommendation_type
                FROM recommendations_base
                WHERE is_active = true AND agent_enabled = true
                ORDER BY raw_impact DESC
            """)

            recs = []
            for row in cursor.fetchall():
                recs.append({
                    "rec_id": row[0],
                    "title": row[1],
                    "overview": row[2],
                    "agent_goal": row[3],
                    "primary_biomarkers": row[4].split(',') if row[4] else [],
                    "secondary_biomarkers": row[5].split(',') if row[5] else [],
                    "tertiary_biomarkers": row[6].split(',') if row[6] else [],
                    "primary_biometrics": row[7].split(',') if row[7] else [],
                    "secondary_biometrics": row[8].split(',') if row[8] else [],
                    "raw_impact": row[9],
                    "type": row[10]
                })

            return recs

    async def _ai_intelligent_match(
        self,
        patient_data: Dict[str, Any],
        available_recommendations: List[Dict[str, Any]],
        max_recommendations: int
    ) -> List[Dict[str, Any]]:
        """Use AI to create intelligent matches with full reasoning."""

        prompt = self._build_intelligent_matching_prompt(patient_data, available_recommendations, max_recommendations)

        try:
            response = self.client.messages.create(
                model=self.model,
                max_tokens=6000,
                temperature=0.5,
                system=self._get_intelligent_matching_system_prompt(),
                messages=[{"role": "user", "content": prompt}]
            )

            response_text = response.content[0].text
            assignments = self._parse_intelligent_assignments(response_text)

            logger.info(f"AI created {len(assignments)} intelligent assignments")
            return assignments

        except Exception as e:
            logger.error(f"Error in intelligent matching: {str(e)}")
            return []

    def _get_intelligent_matching_system_prompt(self) -> str:
        """System prompt for intelligent assignment."""
        # Load enhanced prompt from file
        prompt_path = os.path.join(
            os.path.dirname(__file__),
            'prompts',
            'enhanced_assignment_prompt.txt'
        )

        if os.path.exists(prompt_path):
            with open(prompt_path, 'r') as f:
                return f.read()

        # Fallback to basic prompt
        return """You are an expert physician creating personalized health recommendations.

CRITICAL INSTRUCTIONS:
1. **CHECK SURVEY RESPONSES FIRST**: The patient told you what they're CURRENTLY doing. Don't recommend what they're already doing!
2. **DETECT INCONSISTENCIES**: If biomarkers are perfect but biometrics suggest problems (e.g., high body fat), FLAG THIS! Something doesn't add up.
3. **BE SKEPTICAL**: If patient claims perfect behaviors but has suboptimal results, recommend tracking/accountability, not more behaviors.
4. **DON'T HALLUCINATE**: If a biomarker is in normal range, don't invent problems with it.

For each recommendation you assign, provide:
1. **Detailed Rationale**: Why THIS SPECIFIC patient needs this (use their actual data)
2. **Personalized Target**: Specific goal based on CURRENT level (from survey)
3. **Getting Started Tips**: Practical tips considering what they ALREADY do
4. **Priority**: How urgent (high/medium/low)

Example Good Rationale:
"Your body fat is 32.5% but ALL your biomarkers are perfect and you claim to eat very healthy (150g protein, 5+ fruits, daily veggies). This disconnect suggests either inaccurate tracking or a metabolic issue. Recommend food logging for 2 weeks to identify the gap."

Example Bad Rationale:
"Your cortisol of 12.5 is elevated" ← It's literally mid-range (8-16)!

Response Format (JSON):
{
  "assignments": [
    {
      "rec_id": "food_logging_accountability",
      "rationale": "Use actual patient data, detect inconsistencies, don't make things up",
      "personal_target": {
        "goal": "Specific based on CURRENT level",
        "reasoning": "Why this target vs. generic"
      },
      "getting_started_tips": ["Practical", "tips", "here"],
      "priority": "high"
    }
  ]
}

Be skeptical. Be accurate. Detect bullshit."""

    def _build_intelligent_matching_prompt(
        self,
        patient_data: Dict[str, Any],
        available_recommendations: List[Dict[str, Any]],
        max_recommendations: int
    ) -> str:
        """Build prompt for intelligent matching."""
        prompt_parts = [
            f"Analyze this patient and assign the top {max_recommendations} most appropriate recommendations.\n",
            "=== PATIENT DATA ===\n",
            "Biomarkers:"
        ]

        # Show biomarkers
        for name, data in list(patient_data['biomarkers'].items())[:20]:
            prompt_parts.append(f"  - {name}: {data['value']} {data['unit']}")

        # Show biometrics
        if patient_data['biometrics']:
            prompt_parts.append("\nBiometrics:")
            for name, data in list(patient_data['biometrics'].items())[:10]:
                prompt_parts.append(f"  - {name}: {data['value']} {data['unit']}")

        # Show ALL survey responses (CRITICAL - what patient claims they're doing)
        if patient_data['survey_responses']:
            prompt_parts.append(f"\nPatient's Self-Reported Behaviors ({len(patient_data['survey_responses'])} survey responses):")
            for resp in patient_data['survey_responses']:  # ALL responses, not just 30!
                if resp['response']:  # Only show if they answered
                    prompt_parts.append(f"  Q: {resp['question']}")
                    prompt_parts.append(f"  A: {resp['response']}")
                    prompt_parts.append("")

        # Show available recommendations
        prompt_parts.append(f"\n=== AVAILABLE RECOMMENDATIONS ({len(available_recommendations)}) ===\n")
        for rec in available_recommendations[:30]:  # Top 30 by impact
            prompt_parts.append(f"\n{rec['rec_id']}: {rec['title']} (impact: {rec['raw_impact']}/100)")
            prompt_parts.append(f"  Goal: {rec['agent_goal']}")
            if rec['primary_biomarkers']:
                prompt_parts.append(f"  Targets: {', '.join(rec['primary_biomarkers'][:5])}")

        return "\n".join(prompt_parts)

    def _parse_intelligent_assignments(self, response_text: str) -> List[Dict[str, Any]]:
        """Parse AI response into assignments."""
        try:
            # Handle both markdown code blocks and raw JSON
            if "```json" in response_text:
                json_start = response_text.find("```json") + 7
                json_end = response_text.find("```", json_start)
                json_str = response_text[json_start:json_end].strip()
            elif "```" in response_text:
                # Generic code block
                json_start = response_text.find("```") + 3
                json_end = response_text.find("```", json_start)
                json_str = response_text[json_start:json_end].strip()
            elif "{" in response_text:
                json_start = response_text.find("{")
                json_end = response_text.rfind("}") + 1
                json_str = response_text[json_start:json_end]
            else:
                raise ValueError("No JSON in response")

            # Try parsing with lenient JSON decoder
            result = json.loads(json_str)
            return result.get('assignments', [])

        except json.JSONDecodeError as e:
            # Try fixing common JSON issues
            try:
                # Remove trailing commas
                import re
                json_str_fixed = re.sub(r',(\s*[}\]])', r'\1', json_str)
                result = json.loads(json_str_fixed)
                return result.get('assignments', [])
            except:
                pass

            logger.error(f"Error parsing assignments: {str(e)}")
            logger.error(f"Response text (first 500 chars): {response_text[:500]}")
            # Save full response for debugging
            with open('/tmp/ai_assignment_response.txt', 'w') as f:
                f.write(response_text)
            print(f"\n❌ JSON parsing error. Full response saved to /tmp/ai_assignment_response.txt")
            return []
        except Exception as e:
            logger.error(f"Unexpected error: {str(e)}")
            return []

    async def _store_intelligent_assignment(
        self,
        patient_id: UUID,
        assignment: Dict[str, Any]
    ) -> Optional[Dict[str, Any]]:
        """Store intelligent assignment in database."""
        rec_id = assignment['rec_id']

        # Get recommendation UUID
        with self.db.cursor() as cursor:
            cursor.execute("SELECT id FROM recommendations_base WHERE rec_id = %s", (rec_id,))
            row = cursor.fetchone()
            if not row:
                return None
            rec_uuid = row[0]

        # Extract components into separate columns
        biomarker_connection = assignment.get('biomarker_connection', {})
        trackable_goal = assignment.get('trackable_goal', {})
        progressive_plan = assignment.get('progressive_plan', [])
        implementation_details = assignment.get('implementation_details', {})
        evidence = assignment.get('evidence', [])

        # Build summary agent_notes from biomarker targets
        agent_notes_parts = []
        if biomarker_connection.get('primary_targets'):
            agent_notes_parts.append("TARGET BIOMARKERS:")
            for target in biomarker_connection['primary_targets']:
                agent_notes_parts.append(
                    f"• {target['biomarker']}: {target['current']} → {target['goal']} {target['unit']} "
                    f"(expected: {target.get('expected_impact', 'improvement')})"
                )

        if trackable_goal:
            agent_notes_parts.append(
                f"\nTRACKABLE: {trackable_goal.get('display_name')} = "
                f"{trackable_goal.get('target_value')} {trackable_goal.get('unit')} {trackable_goal.get('period')}"
            )

        agent_notes = "\n".join(agent_notes_parts) if agent_notes_parts else assignment.get('rationale', '')

        # Build personal_target summary
        personal_target = assignment.get('personal_target', {})
        if not personal_target and trackable_goal:
            personal_target = {
                "metric": trackable_goal.get('display_name'),
                "target": trackable_goal.get('target_value'),
                "unit": trackable_goal.get('unit'),
                "current_baseline": trackable_goal.get('current_baseline')
            }

        # Insert with separate columns for each intelligence component
        with self.db.cursor() as cursor:
            cursor.execute("""
                INSERT INTO patient_recommendations (
                    patient_id, recommendation_id, status, assigned_date, start_date,
                    personal_target, agent_notes,
                    biomarker_connection, trackable_goal, progressive_plan,
                    implementation_details, evidence
                ) VALUES (%s, %s, 'active', %s, %s, %s, %s, %s, %s, %s, %s, %s)
                RETURNING id
            """, (
                str(patient_id),
                rec_uuid,
                date.today(),
                date.today(),
                json.dumps(personal_target),
                agent_notes,
                json.dumps(biomarker_connection),
                json.dumps(trackable_goal),
                json.dumps(progressive_plan),
                json.dumps(implementation_details),
                json.dumps(evidence)
            ))

            patient_rec_id = cursor.fetchone()[0]
            self.db.commit()

        return {
            "patient_recommendation_id": str(patient_rec_id),
            "rec_id": rec_id,
            "rationale": assignment.get('rationale'),
            "personal_target": assignment.get('personal_target'),
            "getting_started_tips": assignment.get('getting_started_tips', []),
            "priority": assignment.get('priority', 'medium')
        }

    async def _generate_onboarding_nudge(
        self,
        patient_id: UUID,
        assignment: Dict[str, Any]
    ) -> None:
        """Generate an onboarding nudge for a new recommendation."""
        tips = assignment.get('getting_started_tips', [])
        if not tips:
            return

        # Create nudge message
        nudge_message = f"Getting started with {assignment['rec_id']}:\n\n"
        for i, tip in enumerate(tips[:3], 1):
            nudge_message += f"{i}. {tip}\n"

        # Store nudge
        with self.db.cursor() as cursor:
            cursor.execute("""
                INSERT INTO agent_nudges (
                    patient_id, title, message, tone, nudge_type,
                    trigger_reason, scheduled_for
                ) VALUES (%s, %s, %s, %s, %s, %s, NOW() + INTERVAL '2 hours')
            """, (
                str(patient_id),
                f"Getting Started: {assignment['rec_id'].replace('_', ' ').title()}",
                nudge_message,
                'educational',
                'adherence_support',
                json.dumps({"type": "onboarding", "rec_id": assignment['rec_id']})
            ))
            self.db.commit()
