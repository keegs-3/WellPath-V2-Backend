"""
Core Adherence Agent

The AdherenceAgent uses Claude to intelligently evaluate recommendation adherence
by automatically understanding what to measure from natural language goals.

Key Features:
- Automatic metric identification from goals ("10,000 steps" → looks for step data)
- Context-aware adjustments (travel, injury, illness modes)
- Hierarchical scoring (recommendation → pillar → overall)
- Transparent reasoning for all scores
"""

import os
import logging
from datetime import date, datetime, timedelta
from typing import Dict, List, Optional, Any, Tuple
from uuid import UUID
import json

from anthropic import Anthropic

from database.postgres_client import get_db_connection
from .context_builder import ContextBuilder

logger = logging.getLogger(__name__)


class AdherenceAgent:
    """
    AI-powered adherence evaluation agent.

    Uses Claude to:
    1. Parse natural language recommendation goals
    2. Identify what metrics to look for
    3. Find relevant patient data
    4. Calculate adherence scores
    5. Apply contextual adjustments (modes)
    6. Provide transparent reasoning
    """

    def __init__(self, anthropic_api_key: Optional[str] = None, db_connection=None):
        """
        Initialize Adherence Agent.

        Args:
            anthropic_api_key: Anthropic API key (defaults to env var)
            db_connection: Optional database connection
        """
        self.client = Anthropic(api_key=anthropic_api_key or os.getenv('ANTHROPIC_API_KEY'))
        self.db = db_connection or get_db_connection()
        self.context_builder = ContextBuilder(self.db)
        self.model = "claude-sonnet-4-20250514"

    async def calculate_daily_scores(
        self,
        patient_id: UUID,
        score_date: Optional[date] = None
    ) -> Dict[str, Any]:
        """
        Calculate all adherence scores for a patient on a given date.

        This is the main entry point for daily scoring. It:
        1. Gets patient context
        2. Scores each active recommendation
        3. Aggregates by pillar
        4. Calculates overall score
        5. Stores all scores in database

        Args:
            patient_id: Patient UUID
            score_date: Date to calculate scores for (defaults to today)

        Returns:
            Dictionary with all scores and metadata
        """
        if score_date is None:
            score_date = date.today()

        logger.info(f"Calculating daily scores for patient {patient_id} on {score_date}")
        start_time = datetime.now()

        # Build comprehensive context
        context = await self.context_builder.build_full_context(patient_id, score_date)

        # Get active modes for adjustments
        active_modes = context['active_modes']
        mode_adjustments = self._build_mode_adjustments(active_modes)

        # Score each recommendation
        recommendation_scores = []
        for rec in context['recommendations']['active_recommendations']:
            score_result = await self.evaluate_recommendation(
                patient_id=patient_id,
                recommendation=rec,
                context=context,
                score_date=score_date,
                mode_adjustments=mode_adjustments
            )
            recommendation_scores.append(score_result)

            # Store individual recommendation score
            await self._store_recommendation_score(score_result)

        # Aggregate by pillar
        pillar_scores = await self._calculate_pillar_scores(
            patient_id=patient_id,
            recommendation_scores=recommendation_scores,
            score_date=score_date
        )

        # Calculate overall score
        overall_score = await self._calculate_overall_score(
            patient_id=patient_id,
            pillar_scores=pillar_scores,
            score_date=score_date,
            active_modes=active_modes,
            mode_adjustments=mode_adjustments
        )

        execution_time = (datetime.now() - start_time).total_seconds()

        result = {
            "patient_id": str(patient_id),
            "score_date": score_date.isoformat(),
            "overall_score": overall_score,
            "pillar_scores": pillar_scores,
            "recommendation_scores": recommendation_scores,
            "active_modes": active_modes,
            "execution_time_seconds": execution_time
        }

        # Log execution
        await self._log_execution(
            patient_id=patient_id,
            agent_type='adherence_evaluator',
            duration_ms=int(execution_time * 1000),
            status='success',
            input_data={"score_date": score_date.isoformat()},
            output_data={"overall_score": overall_score['adherence_percentage']}
        )

        logger.info(f"Completed scoring for patient {patient_id}: {overall_score['adherence_percentage']}%")

        return result

    async def evaluate_recommendation(
        self,
        patient_id: UUID,
        recommendation: Dict[str, Any],
        context: Dict[str, Any],
        score_date: date,
        mode_adjustments: Optional[Dict[str, Any]] = None
    ) -> Dict[str, Any]:
        """
        Evaluate adherence for a single recommendation using AI.

        The agent automatically:
        1. Understands what to measure from the goal
        2. Searches for relevant data
        3. Calculates adherence percentage
        4. Applies mode adjustments
        5. Provides reasoning

        Args:
            patient_id: Patient UUID
            recommendation: Recommendation details dict
            context: Full patient context
            score_date: Date to evaluate for
            mode_adjustments: Optional mode-based adjustments

        Returns:
            Dictionary with score, reasoning, and metadata
        """
        # Prepare agent prompt
        prompt = self._build_evaluation_prompt(
            recommendation=recommendation,
            context=context,
            score_date=score_date,
            mode_adjustments=mode_adjustments
        )

        # Get available patient data for this date
        patient_data = await self._get_patient_data_for_date(
            patient_id=patient_id,
            score_date=score_date
        )

        # Call Claude to evaluate
        try:
            response = self.client.messages.create(
                model=self.model,
                max_tokens=2000,
                temperature=0.3,  # Lower temperature for consistent scoring
                system=self._get_system_prompt(),
                messages=[{
                    "role": "user",
                    "content": f"{prompt}\n\nAvailable Patient Data:\n{json.dumps(patient_data, indent=2)}"
                }]
            )

            # Parse agent response
            response_text = response.content[0].text
            evaluation = self._parse_evaluation_response(response_text)

            # Apply any additional adjustments
            final_score = evaluation['adherence_percentage']
            adjustments_applied = evaluation.get('adjustments', {})

            if mode_adjustments:
                final_score, mode_adj = self._apply_mode_adjustments(
                    base_score=final_score,
                    recommendation=recommendation,
                    mode_adjustments=mode_adjustments
                )
                adjustments_applied['mode_adjustments'] = mode_adj

            result = {
                "patient_id": str(patient_id),
                "patient_recommendation_id": recommendation['patient_recommendation_id'],
                "recommendation_id": recommendation['rec_id'],
                "recommendation_title": recommendation['title'],
                "pillar": recommendation['pillar'],
                "score_date": score_date.isoformat(),
                "adherence_percentage": round(final_score, 1),
                "base_score": evaluation['adherence_percentage'],
                "score_quality": evaluation.get('score_quality', 'measured'),
                "data_sources_used": evaluation.get('data_sources', []),
                "calculation_reasoning": evaluation.get('reasoning', ''),
                "adjustments_applied": adjustments_applied,
                "confidence_score": evaluation.get('confidence', 85),
                "tokens_used": response.usage.input_tokens + response.usage.output_tokens
            }

            return result

        except Exception as e:
            logger.error(f"Error evaluating recommendation {recommendation['rec_id']}: {str(e)}")
            # Return no-data score
            return {
                "patient_id": str(patient_id),
                "patient_recommendation_id": recommendation['patient_recommendation_id'],
                "recommendation_id": recommendation['rec_id'],
                "recommendation_title": recommendation['title'],
                "pillar": recommendation['pillar'],
                "score_date": score_date.isoformat(),
                "adherence_percentage": 0.0,
                "score_quality": "no_data",
                "calculation_reasoning": f"Error during evaluation: {str(e)}",
                "error": str(e)
            }

    def _get_system_prompt(self) -> str:
        """Get the system prompt that defines agent behavior."""
        return """You are an expert health adherence evaluation agent for WellPath, a primary care platform.

Your role is to evaluate how well a patient adhered to a health recommendation on a specific date.

Key Principles:
1. AUTOMATIC METRIC IDENTIFICATION: From a natural language goal like "Get 10,000 steps daily", you automatically know to look for step count data. No configuration needed.

2. INTELLIGENT DATA SEARCH: Look through all available patient data sources to find relevant metrics.

3. CONTEXT AWARENESS: Consider the patient's situation (travel, injury, illness) when scoring.

4. PARTIAL CREDIT: Give appropriate credit for partial achievement (8,000 steps = 80% for a 10,000 step goal).

5. TRANSPARENCY: Always explain your reasoning clearly.

Common Goal Patterns:
- "Get X steps daily" → Look for step count data
- "Sleep X-Y hours" → Look for sleep duration data
- "Eat X servings of Y" → Look for food log/nutrition data
- "Exercise X times per week" → Look for workout/activity data
- "Limit X to Y per week" → Look for consumption logs (inverse scoring)

Response Format:
Provide a JSON response with:
{
  "adherence_percentage": 0-100,
  "score_quality": "measured" | "estimated" | "partial_data" | "no_data",
  "data_sources": ["source1", "source2"],
  "reasoning": "Brief explanation of how you calculated this score",
  "confidence": 0-100,
  "adjustments": {} // any adjustments made
}

Be concise but thorough. Focus on facts and data."""

    def _build_evaluation_prompt(
        self,
        recommendation: Dict[str, Any],
        context: Dict[str, Any],
        score_date: date,
        mode_adjustments: Optional[Dict[str, Any]] = None
    ) -> str:
        """Build the evaluation prompt for Claude."""
        prompt_parts = [
            f"Evaluate adherence for the following recommendation on {score_date.isoformat()}:",
            f"\nRecommendation: {recommendation['title']}",
            f"Goal: {recommendation['agent_goal'] or recommendation['overview']}",
            f"Pillar: {recommendation['pillar']}",
            f"Type: {recommendation['recommendation_type']}"
        ]

        if recommendation['agent_context']:
            prompt_parts.append(f"\nSpecial Considerations: {json.dumps(recommendation['agent_context'])}")

        if recommendation['personal_target']:
            prompt_parts.append(f"\nPersonal Target: {json.dumps(recommendation['personal_target'])}")

        if mode_adjustments:
            prompt_parts.append(f"\nActive Modes: {json.dumps(mode_adjustments)}")

        prompt_parts.append("\nTarget Biomarkers (for context):")
        if recommendation['primary_biomarkers']:
            prompt_parts.append(f"  Primary: {', '.join(recommendation['primary_biomarkers'])}")
        if recommendation['secondary_biomarkers']:
            prompt_parts.append(f"  Secondary: {', '.join(recommendation['secondary_biomarkers'])}")

        return "\n".join(prompt_parts)

    async def _get_patient_data_for_date(
        self,
        patient_id: UUID,
        score_date: date
    ) -> Dict[str, Any]:
        """
        Retrieve all patient data from WellPath's aggregation system.

        Queries:
        - aggregation_results_cache: Aggregated metrics (steps, sleep, nutrition, etc.)
        - patient_data_entries: Raw instance data
        """
        data = {
            "date": score_date.isoformat(),
            "aggregated_metrics": {},
            "raw_entries": []
        }

        # Get aggregated data for this date
        query_aggregations = """
        SELECT
            agg_metric_id,
            period_type,
            calculation_type_id,
            value,
            data_points_count
        FROM aggregation_results_cache
        WHERE patient_id = %s
          AND period_start::date <= %s
          AND period_end::date >= %s
          AND is_stale = false
        ORDER BY agg_metric_id, period_type
        """

        with self.db.cursor() as cursor:
            cursor.execute(query_aggregations, (str(patient_id), score_date, score_date))
            for row in cursor.fetchall():
                metric_key = f"{row[0]}_{row[1]}_{row[2]}"
                data['aggregated_metrics'][metric_key] = {
                    "metric": row[0],
                    "period": row[1],
                    "calc_type": row[2],
                    "value": float(row[3]) if row[3] else None,
                    "data_points": row[4]
                }

        # Get raw data entries for this date
        query_entries = """
        SELECT
            field_id,
            value_quantity,
            value_text,
            value_category,
            entry_timestamp
        FROM patient_data_entries
        WHERE patient_id = %s
          AND entry_date = %s
        ORDER BY entry_timestamp
        """

        with self.db.cursor() as cursor:
            cursor.execute(query_entries, (str(patient_id), score_date))
            for row in cursor.fetchall():
                data['raw_entries'].append({
                    "field": row[0],
                    "quantity": float(row[1]) if row[1] else None,
                    "text": row[2],
                    "category": row[3],
                    "time": row[4].isoformat() if row[4] else None
                })

        return data

    def _parse_evaluation_response(self, response_text: str) -> Dict[str, Any]:
        """Parse Claude's evaluation response."""
        try:
            # Try to extract JSON from response
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

            evaluation = json.loads(json_str)

            # Validate required fields
            if 'adherence_percentage' not in evaluation:
                raise ValueError("Missing adherence_percentage in response")

            # Ensure percentage is in valid range
            evaluation['adherence_percentage'] = max(0, min(100, float(evaluation['adherence_percentage'])))

            return evaluation

        except Exception as e:
            logger.error(f"Error parsing evaluation response: {str(e)}")
            logger.error(f"Response text: {response_text}")
            # Return default no-data response
            return {
                "adherence_percentage": 0,
                "score_quality": "no_data",
                "reasoning": "Unable to parse agent response",
                "confidence": 0,
                "data_sources": []
            }

    def _build_mode_adjustments(self, active_modes: List[Dict[str, Any]]) -> Dict[str, Any]:
        """Build adjustment parameters from active modes."""
        if not active_modes:
            return {}

        adjustments = {}
        for mode in active_modes:
            mode_type = mode['type']
            config = mode.get('config', {})

            adjustments[mode_type] = {
                "since": mode['start_date'],
                "config": config,
                "notes": mode.get('notes')
            }

        return adjustments

    def _apply_mode_adjustments(
        self,
        base_score: float,
        recommendation: Dict[str, Any],
        mode_adjustments: Dict[str, Any]
    ) -> Tuple[float, Dict[str, Any]]:
        """
        Apply mode-based adjustments to a score.

        For example, if in travel mode, reduce movement targets by 30%.
        If the user achieves 70% of the reduced target, that counts as 100%.
        """
        adjusted_score = base_score
        applied_adjustments = {}

        # This is a simplified version - in production, the agent would handle this
        for mode_type, mode_data in mode_adjustments.items():
            config = mode_data.get('config', {})

            # Example: Travel mode reduces movement targets
            if mode_type == 'travel' and recommendation['pillar'] == 'movement':
                reduction_factor = config.get('reduce_exercise_targets', 0.7)
                # If they hit 70% of original target, that's 100% considering the mode
                adjusted_score = min(100, base_score / reduction_factor)
                applied_adjustments['travel_adjustment'] = f"Score adjusted for travel mode ({int((1 - reduction_factor) * 100)}% reduction)"

            # Example: Injury mode for affected movements
            elif mode_type == 'injury' and recommendation['pillar'] == 'movement':
                # More lenient scoring during injury
                adjusted_score = min(100, base_score * 1.2)
                applied_adjustments['injury_adjustment'] = "Score boosted 20% due to injury mode"

        return adjusted_score, applied_adjustments

    async def _calculate_pillar_scores(
        self,
        patient_id: UUID,
        recommendation_scores: List[Dict[str, Any]],
        score_date: date
    ) -> List[Dict[str, Any]]:
        """
        Aggregate recommendation scores by pillar.
        """
        pillar_groups = {}

        for score in recommendation_scores:
            pillar = score['pillar']
            if pillar not in pillar_groups:
                pillar_groups[pillar] = []
            pillar_groups[pillar].append(score)

        pillar_scores = []
        for pillar, scores in pillar_groups.items():
            # Calculate average adherence for pillar
            valid_scores = [s['adherence_percentage'] for s in scores if s.get('score_quality') != 'no_data']
            avg_adherence = sum(valid_scores) / len(valid_scores) if valid_scores else 0

            pillar_score = {
                "pillar": pillar,
                "adherence_percentage": round(avg_adherence, 1),
                "active_recommendations": len(scores),
                "recommendations_scored": len(valid_scores),
                "component_scores": {s['recommendation_title']: s['adherence_percentage'] for s in scores}
            }

            pillar_scores.append(pillar_score)

            # Store in database
            await self._store_pillar_score(patient_id, score_date, pillar_score)

        return pillar_scores

    async def _calculate_overall_score(
        self,
        patient_id: UUID,
        pillar_scores: List[Dict[str, Any]],
        score_date: date,
        active_modes: List[Dict[str, Any]],
        mode_adjustments: Dict[str, Any]
    ) -> Dict[str, Any]:
        """
        Calculate overall adherence score from pillar scores.
        """
        if not pillar_scores:
            overall_score = {
                "adherence_percentage": 0.0,
                "active_recommendations": 0,
                "recommendations_scored": 0,
                "pillar_breakdown": {}
            }
        else:
            # Weight all pillars equally for now
            avg_adherence = sum(p['adherence_percentage'] for p in pillar_scores) / len(pillar_scores)

            overall_score = {
                "adherence_percentage": round(avg_adherence, 1),
                "active_recommendations": sum(p['active_recommendations'] for p in pillar_scores),
                "recommendations_scored": sum(p['recommendations_scored'] for p in pillar_scores),
                "pillar_breakdown": {p['pillar']: p['adherence_percentage'] for p in pillar_scores}
            }

        # Store in database
        await self._store_overall_score(patient_id, score_date, overall_score, active_modes, mode_adjustments)

        return overall_score

    async def _store_recommendation_score(self, score: Dict[str, Any]) -> None:
        """Store recommendation score in database."""
        query = """
        INSERT INTO agent_adherence_scores (
            patient_id, patient_recommendation_id, recommendation_id, score_date,
            adherence_percentage, score_quality, data_sources_used,
            calculation_reasoning, adjustments_applied, confidence_score
        ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        ON CONFLICT (patient_id, patient_recommendation_id, score_date)
        DO UPDATE SET
            adherence_percentage = EXCLUDED.adherence_percentage,
            score_quality = EXCLUDED.score_quality,
            data_sources_used = EXCLUDED.data_sources_used,
            calculation_reasoning = EXCLUDED.calculation_reasoning,
            adjustments_applied = EXCLUDED.adjustments_applied,
            confidence_score = EXCLUDED.confidence_score,
            updated_at = NOW()
        """

        # Get recommendation UUID from rec_id
        rec_uuid = await self._get_recommendation_uuid(score['recommendation_id'])

        with self.db.cursor() as cursor:
            cursor.execute(query, (
                score['patient_id'],
                score['patient_recommendation_id'],
                rec_uuid,
                score['score_date'],
                score['adherence_percentage'],
                score.get('score_quality', 'measured'),
                score.get('data_sources_used', []),
                score.get('calculation_reasoning', ''),
                json.dumps(score.get('adjustments_applied', {})),
                score.get('confidence_score', 85)
            ))
            self.db.commit()

    async def _store_pillar_score(self, patient_id: UUID, score_date: date, pillar_score: Dict[str, Any]) -> None:
        """Store pillar score in database."""
        # Get pillar UUID
        pillar_uuid = await self._get_pillar_uuid(pillar_score['pillar'])

        query = """
        INSERT INTO agent_pillar_scores (
            patient_id, pillar_id, score_date,
            adherence_percentage, active_recommendations, recommendations_scored,
            component_scores
        ) VALUES (%s, %s, %s, %s, %s, %s, %s)
        ON CONFLICT (patient_id, pillar_id, score_date)
        DO UPDATE SET
            adherence_percentage = EXCLUDED.adherence_percentage,
            active_recommendations = EXCLUDED.active_recommendations,
            recommendations_scored = EXCLUDED.recommendations_scored,
            component_scores = EXCLUDED.component_scores,
            updated_at = NOW()
        """

        with self.db.cursor() as cursor:
            cursor.execute(query, (
                str(patient_id),
                pillar_uuid,
                score_date,
                pillar_score['adherence_percentage'],
                pillar_score['active_recommendations'],
                pillar_score['recommendations_scored'],
                json.dumps(pillar_score['component_scores'])
            ))
            self.db.commit()

    async def _store_overall_score(
        self,
        patient_id: UUID,
        score_date: date,
        overall_score: Dict[str, Any],
        active_modes: List[Dict[str, Any]],
        mode_adjustments: Dict[str, Any]
    ) -> None:
        """Store overall score in database."""
        query = """
        INSERT INTO agent_overall_scores (
            patient_id, score_date,
            adherence_percentage, active_recommendations, recommendations_scored,
            pillar_scores, active_mode, mode_adjustments
        ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        ON CONFLICT (patient_id, score_date)
        DO UPDATE SET
            adherence_percentage = EXCLUDED.adherence_percentage,
            active_recommendations = EXCLUDED.active_recommendations,
            recommendations_scored = EXCLUDED.recommendations_scored,
            pillar_scores = EXCLUDED.pillar_scores,
            active_mode = EXCLUDED.active_mode,
            mode_adjustments = EXCLUDED.mode_adjustments,
            updated_at = NOW()
        """

        active_mode = active_modes[0]['type'] if active_modes else None

        with self.db.cursor() as cursor:
            cursor.execute(query, (
                str(patient_id),
                score_date,
                overall_score['adherence_percentage'],
                overall_score['active_recommendations'],
                overall_score['recommendations_scored'],
                json.dumps(overall_score['pillar_breakdown']),
                active_mode,
                json.dumps(mode_adjustments)
            ))
            self.db.commit()

    async def _get_recommendation_uuid(self, rec_id: str) -> UUID:
        """Get recommendation UUID from rec_id."""
        with self.db.cursor() as cursor:
            cursor.execute("SELECT id FROM recommendations_base WHERE rec_id = %s", (rec_id,))
            row = cursor.fetchone()
            return row[0] if row else None

    async def _get_pillar_uuid(self, pillar_name: str) -> UUID:
        """Get pillar UUID from pillar name."""
        with self.db.cursor() as cursor:
            cursor.execute("SELECT id FROM pillars_base WHERE pillar_name = %s", (pillar_name,))
            row = cursor.fetchone()
            return row[0] if row else None

    async def _log_execution(
        self,
        patient_id: UUID,
        agent_type: str,
        duration_ms: int,
        status: str,
        input_data: Dict[str, Any],
        output_data: Dict[str, Any],
        error_message: Optional[str] = None
    ) -> None:
        """Log agent execution for monitoring."""
        query = """
        INSERT INTO agent_execution_log (
            patient_id, agent_type, duration_ms, status,
            input_data, output_data, error_message, model_version
        ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        """

        try:
            with self.db.cursor() as cursor:
                cursor.execute(query, (
                    str(patient_id),
                    agent_type,
                    duration_ms,
                    status,
                    json.dumps(input_data),
                    json.dumps(output_data),
                    error_message,
                    self.model
                ))
                self.db.commit()
        except Exception as e:
            logger.error(f"Error logging execution: {str(e)}")
