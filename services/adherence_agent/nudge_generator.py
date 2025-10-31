"""
Nudge Generator

Creates personalized, dynamic nudges using AI based on patient context,
adherence patterns, and current situation.

Replaces static nudge library with intelligent, contextual messaging.
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


class NudgeGenerator:
    """
    AI-powered nudge generation system.

    Creates personalized nudges that:
    - Celebrate wins
    - Encourage progress
    - Provide education
    - Offer support during struggles
    - Adapt to user's mode (travel, injury, etc.)
    """

    def __init__(self, anthropic_api_key: Optional[str] = None, db_connection=None):
        """
        Initialize Nudge Generator.

        Args:
            anthropic_api_key: Anthropic API key
            db_connection: Optional database connection
        """
        self.client = Anthropic(api_key=anthropic_api_key or os.getenv('ANTHROPIC_API_KEY'))
        self.db = db_connection or get_db_connection()
        self.context_builder = ContextBuilder(self.db)
        self.model = "claude-sonnet-4-20250514"

    async def generate_nudges_for_patient(
        self,
        patient_id: UUID,
        max_nudges: int = 3,
        target_date: Optional[date] = None
    ) -> List[Dict[str, Any]]:
        """
        Generate contextual nudges for a patient.

        Args:
            patient_id: Patient UUID
            max_nudges: Maximum number of nudges to generate
            target_date: Date to generate nudges for (defaults to today)

        Returns:
            List of generated nudges
        """
        if target_date is None:
            target_date = date.today()

        logger.info(f"Generating up to {max_nudges} nudges for patient {patient_id}")

        # Build patient context
        context = await self.context_builder.build_full_context(patient_id, target_date)

        # Determine nudge opportunities
        opportunities = await self._identify_nudge_opportunities(patient_id, context)

        if not opportunities:
            logger.info(f"No nudge opportunities found for patient {patient_id}")
            return []

        # Generate nudges using AI
        nudges = []
        for opportunity in opportunities[:max_nudges]:
            nudge = await self._generate_nudge(
                patient_id=patient_id,
                opportunity=opportunity,
                context=context,
                target_date=target_date
            )
            if nudge:
                nudges.append(nudge)
                # Store in database
                await self._store_nudge(nudge)

        logger.info(f"Generated {len(nudges)} nudges for patient {patient_id}")
        return nudges

    async def _identify_nudge_opportunities(
        self,
        patient_id: UUID,
        context: Dict[str, Any]
    ) -> List[Dict[str, Any]]:
        """
        Identify opportunities for nudges based on patient context.

        Opportunities include:
        - Low adherence that needs support
        - High adherence to celebrate
        - Milestones reached
        - Concerning patterns
        - Mode changes (travel, injury)
        """
        opportunities = []

        # Check recent adherence
        if context['recent_adherence'].get('has_history'):
            recent_scores = context['recent_adherence']['scores'][:7]  # Last 7 days
            avg_score = context['recent_adherence']['avg_last_7_days']

            # Low adherence - needs support
            if avg_score < 50:
                opportunities.append({
                    "type": "adherence_support",
                    "reason": "low_adherence",
                    "data": {
                        "avg_score": avg_score,
                        "trend": context['recent_adherence']['trend']
                    },
                    "priority": "high"
                })

            # Moderate adherence - encouragement
            elif 50 <= avg_score < 75:
                opportunities.append({
                    "type": "adherence_support",
                    "reason": "moderate_adherence",
                    "data": {
                        "avg_score": avg_score,
                        "trend": context['recent_adherence']['trend']
                    },
                    "priority": "medium"
                })

            # High adherence - celebration
            elif avg_score >= 85:
                opportunities.append({
                    "type": "celebration",
                    "reason": "high_adherence",
                    "data": {
                        "avg_score": avg_score,
                        "streak_days": len([s for s in recent_scores if s['score'] >= 80])
                    },
                    "priority": "medium"
                })

            # Improving trend - recognition
            if context['recent_adherence']['trend'] == 'improving':
                opportunities.append({
                    "type": "insight",
                    "reason": "improving_trend",
                    "data": {
                        "current_score": recent_scores[0]['score'],
                        "previous_score": recent_scores[-1]['score']
                    },
                    "priority": "medium"
                })

        # Active modes require special support
        if context['active_modes']:
            mode = context['active_modes'][0]
            opportunities.append({
                "type": "adherence_support",
                "reason": f"{mode['type']}_mode_active",
                "data": {
                    "mode": mode['type'],
                    "since": mode['start_date'],
                    "notes": mode.get('notes')
                },
                "priority": "high"
            })

        # Out of range biomarkers
        if context['biomarkers']['out_of_range']:
            for bio in context['biomarkers']['out_of_range'][:2]:  # Top 2
                # Find recommendations targeting this biomarker
                target_recs = [
                    rec for rec in context['recommendations']['active_recommendations']
                    if bio['biomarker'] in rec.get('primary_biomarkers', [])
                ]

                if target_recs:
                    opportunities.append({
                        "type": "insight",
                        "reason": "biomarker_out_of_range",
                        "data": {
                            "biomarker": bio['biomarker'],
                            "value": bio['value'],
                            "deviation": bio['deviation'],
                            "recommendations": [r['title'] for r in target_recs]
                        },
                        "priority": "high"
                    })

        # Sort by priority
        priority_order = {"high": 0, "medium": 1, "low": 2}
        opportunities.sort(key=lambda x: priority_order.get(x['priority'], 3))

        return opportunities

    async def _generate_nudge(
        self,
        patient_id: UUID,
        opportunity: Dict[str, Any],
        context: Dict[str, Any],
        target_date: date
    ) -> Optional[Dict[str, Any]]:
        """
        Generate a specific nudge using AI.
        """
        prompt = self._build_nudge_prompt(opportunity, context)

        try:
            response = self.client.messages.create(
                model=self.model,
                max_tokens=500,
                temperature=0.7,  # Higher temperature for creative messaging
                system=self._get_nudge_system_prompt(),
                messages=[{
                    "role": "user",
                    "content": prompt
                }]
            )

            response_text = response.content[0].text
            nudge_data = self._parse_nudge_response(response_text)

            # Add metadata
            nudge = {
                "patient_id": str(patient_id),
                "recommendation_id": opportunity.get('recommendation_id'),
                "title": nudge_data['title'],
                "message": nudge_data['message'],
                "tone": nudge_data.get('tone', 'encouraging'),
                "nudge_type": opportunity['type'],
                "trigger_reason": opportunity,
                "personalization_factors": {
                    "active_modes": [m['type'] for m in context.get('active_modes', [])],
                    "recent_adherence": context['recent_adherence'].get('avg_last_7_days'),
                    "opportunity_type": opportunity['reason']
                },
                "generation_reasoning": nudge_data.get('reasoning', ''),
                "scheduled_for": datetime.now() + timedelta(hours=2),  # Schedule for 2 hours from now
                "tokens_used": response.usage.input_tokens + response.usage.output_tokens
            }

            return nudge

        except Exception as e:
            logger.error(f"Error generating nudge: {str(e)}")
            return None

    def _get_nudge_system_prompt(self) -> str:
        """System prompt for nudge generation."""
        return """You are a compassionate health coach creating personalized nudges for WellPath users.

Your nudges should:
1. Be warm, supportive, and non-judgmental
2. Celebrate progress, no matter how small
3. Provide actionable encouragement
4. Be concise (2-3 sentences max)
5. Feel personal, not generic
6. Adapt to user's current situation (travel, injury, etc.)

Tone Guidelines:
- CELEBRATING: Genuine excitement, recognition of achievement
- ENCOURAGING: Supportive, motivational, belief in their ability
- EDUCATIONAL: Helpful, informative, empowering with knowledge
- SUPPORTIVE: Compassionate, understanding, meeting them where they are

Avoid:
- Guilt or shame
- Medical advice
- Overly formal language
- Generic platitudes
- Overwhelming complexity

Response Format (JSON):
{
  "title": "Short engaging title (5-8 words)",
  "message": "Main nudge message (2-3 sentences)",
  "tone": "celebrating|encouraging|educational|supportive",
  "reasoning": "Brief explanation of approach"
}"""

    def _build_nudge_prompt(
        self,
        opportunity: Dict[str, Any],
        context: Dict[str, Any]
    ) -> str:
        """Build prompt for nudge generation."""
        prompt_parts = [
            f"Create a personalized nudge for the following situation:",
            f"\nOpportunity Type: {opportunity['type']}",
            f"Reason: {opportunity['reason']}",
            f"Priority: {opportunity['priority']}"
        ]

        # Add context
        if opportunity.get('data'):
            prompt_parts.append(f"\nDetails: {json.dumps(opportunity['data'], indent=2)}")

        # Add patient context
        if context.get('active_modes'):
            modes = [m['type'] for m in context['active_modes']]
            prompt_parts.append(f"\nActive Modes: {', '.join(modes)}")

        if context['recent_adherence'].get('has_history'):
            avg = context['recent_adherence']['avg_last_7_days']
            prompt_parts.append(f"\nRecent Adherence: {avg}% (7-day average)")

        # Add pillar context
        if context['recommendations']['active_recommendations']:
            rec_count = context['recommendations']['count']
            pillars = ', '.join(context['recommendations']['pillars'])
            prompt_parts.append(f"\nActive Recommendations: {rec_count} across {pillars}")

        return "\n".join(prompt_parts)

    def _parse_nudge_response(self, response_text: str) -> Dict[str, Any]:
        """Parse AI response into structured nudge data."""
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

            nudge_data = json.loads(json_str)

            # Validate required fields
            if 'title' not in nudge_data or 'message' not in nudge_data:
                raise ValueError("Missing required fields in nudge")

            return nudge_data

        except Exception as e:
            logger.error(f"Error parsing nudge response: {str(e)}")
            # Return fallback
            return {
                "title": "Keep Going!",
                "message": "You're making progress on your health journey. Every step counts!",
                "tone": "encouraging",
                "reasoning": "Fallback nudge due to parsing error"
            }

    async def _store_nudge(self, nudge: Dict[str, Any]) -> None:
        """Store generated nudge in database."""
        query = """
        INSERT INTO agent_nudges (
            patient_id, recommendation_id, title, message, tone, nudge_type,
            trigger_reason, personalization_factors, generation_reasoning,
            scheduled_for
        ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        RETURNING id
        """

        # Get recommendation UUID if rec_id provided
        rec_uuid = None
        if nudge.get('recommendation_id'):
            with self.db.cursor() as cursor:
                cursor.execute(
                    "SELECT id FROM recommendations_base WHERE rec_id = %s",
                    (nudge['recommendation_id'],)
                )
                row = cursor.fetchone()
                rec_uuid = row[0] if row else None

        with self.db.cursor() as cursor:
            cursor.execute(query, (
                UUID(nudge['patient_id']),
                rec_uuid,
                nudge['title'],
                nudge['message'],
                nudge['tone'],
                nudge['nudge_type'],
                json.dumps(nudge['trigger_reason']),
                json.dumps(nudge['personalization_factors']),
                nudge['generation_reasoning'],
                nudge['scheduled_for']
            ))
            self.db.commit()
            nudge_id = cursor.fetchone()[0]
            logger.info(f"Stored nudge {nudge_id} for patient {nudge['patient_id']}")

    async def get_pending_nudges(
        self,
        patient_id: UUID,
        limit: int = 10
    ) -> List[Dict[str, Any]]:
        """
        Get pending nudges for a patient.

        Args:
            patient_id: Patient UUID
            limit: Maximum number of nudges to return

        Returns:
            List of pending nudges
        """
        query = """
        SELECT
            id,
            title,
            message,
            tone,
            nudge_type,
            scheduled_for,
            created_at
        FROM agent_nudges
        WHERE patient_id = %s
          AND delivered_at IS NULL
          AND scheduled_for <= NOW()
        ORDER BY scheduled_for ASC
        LIMIT %s
        """

        with self.db.cursor() as cursor:
            cursor.execute(query, (patient_id, limit))
            rows = cursor.fetchall()

        nudges = []
        for row in rows:
            nudges.append({
                "id": str(row[0]),
                "title": row[1],
                "message": row[2],
                "tone": row[3],
                "type": row[4],
                "scheduled_for": row[5].isoformat() if row[5] else None,
                "created_at": row[6].isoformat() if row[6] else None
            })

        return nudges

    async def mark_nudge_delivered(
        self,
        nudge_id: UUID,
        user_response: Optional[str] = None
    ) -> None:
        """
        Mark a nudge as delivered and optionally record user response.

        Args:
            nudge_id: Nudge UUID
            user_response: Optional user response ('helpful', 'not_helpful', 'dismissed')
        """
        query = """
        UPDATE agent_nudges
        SET delivered_at = NOW(),
            user_response = %s,
            response_timestamp = CASE WHEN %s IS NOT NULL THEN NOW() ELSE NULL END
        WHERE id = %s
        """

        with self.db.cursor() as cursor:
            cursor.execute(query, (user_response, user_response, nudge_id))
            self.db.commit()

        logger.info(f"Marked nudge {nudge_id} as delivered with response: {user_response}")
