"""
Challenge Creator

Creates dynamic, bite-sized challenges based on patient context.

Challenges are created when:
- User is struggling with adherence
- User is in a mode (travel, injury) that makes normal goals hard
- User needs motivation
- User reaches a milestone and is ready for next level
"""

import os
import logging
from datetime import date, datetime, timedelta
from typing import Dict, List, Optional, Any
from uuid import UUID
import json

from anthropic import Anthropic

from database.postgres_client import get_db_connection
from .context_builder import ContextBuilder

logger = logging.getLogger(__name__)


class ChallengeCreator:
    """
    AI-powered challenge generation system.

    Creates contextual challenges that:
    - Are achievable in user's current situation
    - Build on successes
    - Provide alternatives during constraints
    - Gradually increase difficulty
    - Feel motivating, not overwhelming
    """

    def __init__(self, anthropic_api_key: Optional[str] = None, db_connection=None):
        """
        Initialize Challenge Creator.

        Args:
            anthropic_api_key: Anthropic API key
            db_connection: Optional database connection
        """
        self.client = Anthropic(api_key=anthropic_api_key or os.getenv('ANTHROPIC_API_KEY'))
        self.db = db_connection or get_db_connection()
        self.context_builder = ContextBuilder(self.db)
        self.model = "claude-sonnet-4-20250514"

    async def create_challenge_for_patient(
        self,
        patient_id: UUID,
        trigger_context: Optional[Dict[str, Any]] = None
    ) -> Optional[Dict[str, Any]]:
        """
        Create a contextual challenge for a patient.

        Args:
            patient_id: Patient UUID
            trigger_context: Optional specific trigger (e.g., injury, travel)

        Returns:
            Created challenge or None
        """
        logger.info(f"Creating challenge for patient {patient_id}")

        # Build patient context
        context = await self.context_builder.build_full_context(patient_id, date.today())

        # Determine if challenge is appropriate
        challenge_opportunity = await self._evaluate_challenge_need(
            patient_id,
            context,
            trigger_context
        )

        if not challenge_opportunity:
            logger.info(f"No challenge opportunity for patient {patient_id}")
            return None

        # Generate challenge using AI
        challenge = await self._generate_challenge(
            patient_id=patient_id,
            opportunity=challenge_opportunity,
            context=context
        )

        if challenge:
            # Store in database
            await self._store_challenge(challenge)

        return challenge

    async def _evaluate_challenge_need(
        self,
        patient_id: UUID,
        context: Dict[str, Any],
        trigger_context: Optional[Dict[str, Any]] = None
    ) -> Optional[Dict[str, Any]]:
        """
        Evaluate whether a challenge would be appropriate and beneficial.

        Returns challenge opportunity or None.
        """
        # Check if user already has active challenges
        active_challenges = await self._get_active_challenges(patient_id)
        if len(active_challenges) >= 2:
            logger.info(f"Patient {patient_id} already has {len(active_challenges)} active challenges")
            return None

        opportunities = []

        # Trigger: Active mode (travel, injury, illness)
        if context['active_modes']:
            mode = context['active_modes'][0]
            opportunities.append({
                "trigger": f"{mode['type']}_mode",
                "reason": f"Create adapted challenge for {mode['type']} mode",
                "data": {
                    "mode": mode['type'],
                    "config": mode.get('config'),
                    "notes": mode.get('notes')
                },
                "difficulty": 1,  # Easier during constrained modes
                "duration_days": 7
            })

        # Trigger: Low adherence (needs achievable win)
        if context['recent_adherence'].get('has_history'):
            avg_score = context['recent_adherence']['avg_last_7_days']

            if avg_score < 50:
                opportunities.append({
                    "trigger": "low_adherence",
                    "reason": "Create small, achievable challenge to build momentum",
                    "data": {
                        "current_score": avg_score,
                        "struggling_areas": []  # Could identify specific pillars
                    },
                    "difficulty": 1,
                    "duration_days": 3  # Short duration for quick win
                })

            # High adherence - ready for level up
            elif avg_score >= 80:
                opportunities.append({
                    "trigger": "high_achiever",
                    "reason": "User is ready for next-level challenge",
                    "data": {
                        "current_score": avg_score,
                        "streak": len([s for s in context['recent_adherence']['scores'][:7] if s['score'] >= 75])
                    },
                    "difficulty": 3,  # Higher difficulty
                    "duration_days": 14
                })

        # Explicit trigger passed in
        if trigger_context:
            opportunities.append({
                "trigger": trigger_context.get('type', 'custom'),
                "reason": trigger_context.get('reason', 'External trigger'),
                "data": trigger_context,
                "difficulty": trigger_context.get('difficulty', 2),
                "duration_days": trigger_context.get('duration_days', 7)
            })

        # Return highest priority opportunity
        return opportunities[0] if opportunities else None

    async def _generate_challenge(
        self,
        patient_id: UUID,
        opportunity: Dict[str, Any],
        context: Dict[str, Any]
    ) -> Optional[Dict[str, Any]]:
        """
        Generate a specific challenge using AI.
        """
        prompt = self._build_challenge_prompt(opportunity, context)

        try:
            response = self.client.messages.create(
                model=self.model,
                max_tokens=800,
                temperature=0.7,
                system=self._get_challenge_system_prompt(),
                messages=[{
                    "role": "user",
                    "content": prompt
                }]
            )

            response_text = response.content[0].text
            challenge_data = self._parse_challenge_response(response_text)

            # Calculate dates
            start_date = date.today()
            end_date = start_date + timedelta(days=opportunity['duration_days'])

            # Build challenge object
            challenge = {
                "patient_id": str(patient_id),
                "recommendation_id": challenge_data.get('related_recommendation'),
                "challenge_title": challenge_data['title'],
                "challenge_description": challenge_data['description'],
                "challenge_goal": challenge_data['goal'],
                "difficulty_level": opportunity['difficulty'],
                "duration_days": opportunity['duration_days'],
                "start_date": start_date,
                "end_date": end_date,
                "trigger_reason": opportunity,
                "context_factors": {
                    "active_modes": [m['type'] for m in context.get('active_modes', [])],
                    "recent_adherence": context['recent_adherence'].get('avg_last_7_days'),
                    "trigger_type": opportunity['trigger']
                },
                "generation_reasoning": challenge_data.get('reasoning', ''),
                "status": "active",
                "completion_percentage": 0,
                "tokens_used": response.usage.input_tokens + response.usage.output_tokens
            }

            return challenge

        except Exception as e:
            logger.error(f"Error generating challenge: {str(e)}")
            return None

    def _get_challenge_system_prompt(self) -> str:
        """System prompt for challenge generation."""
        return """You are an expert health coach creating short-term, achievable challenges for WellPath users.

Challenge Design Principles:
1. **Achievable**: User should feel it's within reach
2. **Specific**: Clear, measurable goal (e.g., "Walk 15 minutes after lunch 3 times")
3. **Time-bound**: Usually 3-14 days
4. **Contextual**: Adapted to user's situation (travel, injury, etc.)
5. **Motivating**: Should feel exciting, not burdensome

Challenge Difficulty Levels:
- **Level 1 (Beginner)**: Small step up from current state, very achievable
- **Level 2 (Intermediate)**: Moderate stretch, requires some effort
- **Level 3 (Advanced)**: Significant challenge, for high performers

Special Situations:
- **Travel Mode**: Challenges using hotel gyms, walking at airports, etc.
- **Injury Mode**: Alternative activities that don't aggravate injury
- **Low Adherence**: Extra small, quick-win challenges
- **High Adherence**: Level-up challenges to maintain engagement

Examples:
- Travel: "Find 3 healthy meal options at your hotel restaurant this week"
- Injury: "Do 10 minutes of upper body exercises daily while knee heals"
- Low Adherence: "Walk for 10 minutes today - that's it!"
- High Achiever: "Hit 12,000 steps every day this week"

Response Format (JSON):
{
  "title": "Catchy challenge name (4-6 words)",
  "description": "What the challenge involves (2-3 sentences)",
  "goal": "Specific, measurable goal statement",
  "related_recommendation": "rec_id if applicable",
  "reasoning": "Why this challenge fits the user's situation"
}"""

    def _build_challenge_prompt(
        self,
        opportunity: Dict[str, Any],
        context: Dict[str, Any]
    ) -> str:
        """Build prompt for challenge generation."""
        prompt_parts = [
            f"Create a personalized health challenge:",
            f"\nTrigger: {opportunity['trigger']}",
            f"Reason: {opportunity['reason']}",
            f"Difficulty Level: {opportunity['difficulty']} (1=beginner, 2=intermediate, 3=advanced)",
            f"Duration: {opportunity['duration_days']} days"
        ]

        # Add opportunity context
        if opportunity.get('data'):
            prompt_parts.append(f"\nSituation: {json.dumps(opportunity['data'], indent=2)}")

        # Add patient context
        if context.get('active_modes'):
            modes = ', '.join([m['type'] for m in context['active_modes']])
            prompt_parts.append(f"\nActive Modes: {modes}")

        if context['recent_adherence'].get('has_history'):
            avg = context['recent_adherence']['avg_last_7_days']
            prompt_parts.append(f"\nRecent Adherence: {avg}%")

        # Add active recommendations for context
        if context['recommendations']['active_recommendations']:
            rec_titles = [r['title'] for r in context['recommendations']['active_recommendations'][:3]]
            prompt_parts.append(f"\nActive Recommendations: {', '.join(rec_titles)}")

        return "\n".join(prompt_parts)

    def _parse_challenge_response(self, response_text: str) -> Dict[str, Any]:
        """Parse AI response into structured challenge data."""
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

            challenge_data = json.loads(json_str)

            # Validate required fields
            required = ['title', 'description', 'goal']
            for field in required:
                if field not in challenge_data:
                    raise ValueError(f"Missing required field: {field}")

            return challenge_data

        except Exception as e:
            logger.error(f"Error parsing challenge response: {str(e)}")
            # Return fallback
            return {
                "title": "Daily Movement Challenge",
                "description": "Small steps lead to big changes. This challenge helps you build momentum.",
                "goal": "Complete any form of movement for at least 10 minutes today",
                "reasoning": "Fallback challenge due to parsing error"
            }

    async def _store_challenge(self, challenge: Dict[str, Any]) -> None:
        """Store generated challenge in database."""
        query = """
        INSERT INTO agent_challenges (
            patient_id, recommendation_id, challenge_title, challenge_description,
            challenge_goal, difficulty_level, duration_days, start_date, end_date,
            trigger_reason, context_factors, generation_reasoning, status,
            completion_percentage
        ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        RETURNING id
        """

        # Get recommendation UUID if provided
        rec_uuid = None
        if challenge.get('recommendation_id'):
            with self.db.cursor() as cursor:
                cursor.execute(
                    "SELECT id FROM recommendations_base WHERE rec_id = %s",
                    (challenge['recommendation_id'],)
                )
                row = cursor.fetchone()
                rec_uuid = row[0] if row else None

        with self.db.cursor() as cursor:
            cursor.execute(query, (
                UUID(challenge['patient_id']),
                rec_uuid,
                challenge['challenge_title'],
                challenge['challenge_description'],
                challenge['challenge_goal'],
                challenge['difficulty_level'],
                challenge['duration_days'],
                challenge['start_date'],
                challenge['end_date'],
                json.dumps(challenge['trigger_reason']),
                json.dumps(challenge['context_factors']),
                challenge['generation_reasoning'],
                challenge['status'],
                challenge['completion_percentage']
            ))
            self.db.commit()
            challenge_id = cursor.fetchone()[0]
            logger.info(f"Stored challenge {challenge_id} for patient {challenge['patient_id']}")

    async def _get_active_challenges(self, patient_id: UUID) -> List[Dict[str, Any]]:
        """Get active challenges for a patient."""
        query = """
        SELECT
            id,
            challenge_title,
            challenge_goal,
            start_date,
            end_date,
            completion_percentage
        FROM agent_challenges
        WHERE patient_id = %s
          AND status = 'active'
          AND end_date >= CURRENT_DATE
        ORDER BY start_date DESC
        """

        with self.db.cursor() as cursor:
            cursor.execute(query, (patient_id,))
            rows = cursor.fetchall()

        challenges = []
        for row in rows:
            challenges.append({
                "id": str(row[0]),
                "title": row[1],
                "goal": row[2],
                "start_date": row[3].isoformat() if row[3] else None,
                "end_date": row[4].isoformat() if row[4] else None,
                "completion": row[5]
            })

        return challenges

    async def update_challenge_progress(
        self,
        challenge_id: UUID,
        completion_percentage: float
    ) -> None:
        """
        Update challenge completion percentage.

        Args:
            challenge_id: Challenge UUID
            completion_percentage: 0-100
        """
        # Determine status based on completion
        status = 'active'
        if completion_percentage >= 100:
            status = 'completed'

        query = """
        UPDATE agent_challenges
        SET completion_percentage = %s,
            status = %s,
            updated_at = NOW()
        WHERE id = %s
        """

        with self.db.cursor() as cursor:
            cursor.execute(query, (completion_percentage, status, challenge_id))
            self.db.commit()

        logger.info(f"Updated challenge {challenge_id}: {completion_percentage}% complete")

    async def get_challenges_for_patient(
        self,
        patient_id: UUID,
        include_completed: bool = False
    ) -> List[Dict[str, Any]]:
        """
        Get challenges for a patient.

        Args:
            patient_id: Patient UUID
            include_completed: Whether to include completed challenges

        Returns:
            List of challenges
        """
        query = """
        SELECT
            id,
            challenge_title,
            challenge_description,
            challenge_goal,
            difficulty_level,
            start_date,
            end_date,
            status,
            completion_percentage,
            created_at
        FROM agent_challenges
        WHERE patient_id = %s
        """

        if not include_completed:
            query += " AND status IN ('active', 'pending')"

        query += " ORDER BY created_at DESC LIMIT 10"

        with self.db.cursor() as cursor:
            cursor.execute(query, (patient_id,))
            rows = cursor.fetchall()

        challenges = []
        for row in rows:
            challenges.append({
                "id": str(row[0]),
                "title": row[1],
                "description": row[2],
                "goal": row[3],
                "difficulty": row[4],
                "start_date": row[5].isoformat() if row[5] else None,
                "end_date": row[6].isoformat() if row[6] else None,
                "status": row[7],
                "completion": row[8],
                "created_at": row[9].isoformat() if row[9] else None
            })

        return challenges
