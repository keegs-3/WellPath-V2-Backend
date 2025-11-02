"""
Adherence API Endpoints

API routes for the agentic adherence system.
"""

from fastapi import APIRouter, HTTPException, Depends, Query
from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any
from datetime import date, datetime
from uuid import UUID

from services.adherence_agent.agent import AdherenceAgent
from services.adherence_agent.nudge_generator import NudgeGenerator
from services.adherence_agent.challenge_creator import ChallengeCreator
from database.postgres_client import get_db_connection

router = APIRouter(prefix="/adherence", tags=["adherence"])


# ============================================
# REQUEST/RESPONSE MODELS
# ============================================

class CalculateScoresRequest(BaseModel):
    """Request to calculate daily adherence scores."""
    patient_id: UUID
    score_date: Optional[date] = None

class CalculateScoresResponse(BaseModel):
    """Response from daily score calculation."""
    patient_id: str
    score_date: str
    overall_score: float
    pillar_scores: List[Dict[str, Any]]  # List of pillar score dicts
    active_recommendations: int
    recommendations_scored: int
    execution_time_seconds: float


class SetModeRequest(BaseModel):
    """Request to set a patient mode."""
    patient_id: UUID
    mode_type: str = Field(..., pattern="^(travel|injury|illness|high_stress|recovery|custom)$")
    start_date: date
    end_date: Optional[date] = None
    notes: Optional[str] = None
    mode_config: Optional[Dict[str, Any]] = None


class GenerateNudgesRequest(BaseModel):
    """Request to generate nudges."""
    patient_id: UUID
    max_nudges: int = Field(default=3, ge=1, le=5)


class CreateChallengeRequest(BaseModel):
    """Request to create a challenge."""
    patient_id: UUID
    trigger_context: Optional[Dict[str, Any]] = None


class UpdateChallengeProgressRequest(BaseModel):
    """Request to update challenge progress."""
    completion_percentage: float = Field(..., ge=0, le=100)


class MarkNudgeDeliveredRequest(BaseModel):
    """Request to mark nudge as delivered."""
    user_response: Optional[str] = Field(None, pattern="^(helpful|not_helpful|dismissed)$")


# ============================================
# SCORING ENDPOINTS
# ============================================

@router.post("/calculate-daily", response_model=CalculateScoresResponse)
async def calculate_daily_scores(request: CalculateScoresRequest):
    """
    Calculate all adherence scores for a patient on a specific date.

    This endpoint:
    - Scores each active recommendation
    - Aggregates scores by pillar
    - Calculates overall adherence
    - Applies mode adjustments
    - Stores all scores in database

    **Use Case**: Run daily via cron job or on-demand for specific patients
    """
    try:
        agent = AdherenceAgent()
        result = await agent.calculate_daily_scores(
            patient_id=request.patient_id,
            score_date=request.score_date
        )

        return CalculateScoresResponse(
            patient_id=result['patient_id'],
            score_date=result['score_date'],
            overall_score=result['overall_score']['adherence_percentage'],
            pillar_scores=result['pillar_scores'],
            active_recommendations=result['overall_score']['active_recommendations'],
            recommendations_scored=result['overall_score']['recommendations_scored'],
            execution_time_seconds=result['execution_time_seconds']
        )

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error calculating scores: {str(e)}")


@router.get("/scores/{patient_id}/{score_date}")
async def get_scores_for_date(
    patient_id: UUID,
    score_date: date
):
    """
    Get adherence scores for a specific patient and date.

    Returns:
    - Overall score
    - Pillar breakdown
    - Individual recommendation scores
    - Active modes
    """
    try:
        db = get_db_connection()

        # Get overall score
        with db.cursor() as cursor:
            cursor.execute("""
                SELECT
                    adherence_percentage,
                    active_recommendations,
                    recommendations_scored,
                    pillar_scores,
                    active_mode,
                    mode_adjustments
                FROM agent_overall_scores
                WHERE patient_id = %s AND score_date = %s
            """, (patient_id, score_date))

            row = cursor.fetchone()
            if not row:
                raise HTTPException(status_code=404, detail="No scores found for this date")

            overall = {
                "adherence_percentage": float(row[0]),
                "active_recommendations": row[1],
                "recommendations_scored": row[2],
                "pillar_scores": row[3],
                "active_mode": row[4],
                "mode_adjustments": row[5]
            }

        # Get recommendation scores
        with db.cursor() as cursor:
            cursor.execute("""
                SELECT
                    aas.recommendation_id,
                    rb.title,
                    rb.pillar,
                    aas.adherence_percentage,
                    aas.score_quality,
                    aas.calculation_reasoning
                FROM agent_adherence_scores aas
                JOIN recommendations_base rb ON aas.recommendation_id = rb.id
                WHERE aas.patient_id = %s AND aas.score_date = %s
                ORDER BY rb.pillar, rb.title
            """, (patient_id, score_date))

            recommendation_scores = []
            for row in cursor.fetchall():
                recommendation_scores.append({
                    "recommendation_id": str(row[0]),
                    "title": row[1],
                    "pillar": row[2],
                    "adherence_percentage": float(row[3]),
                    "score_quality": row[4],
                    "reasoning": row[5]
                })

        return {
            "patient_id": str(patient_id),
            "score_date": score_date.isoformat(),
            "overall": overall,
            "recommendations": recommendation_scores
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching scores: {str(e)}")


@router.get("/history/{patient_id}")
async def get_adherence_history(
    patient_id: UUID,
    days: int = Query(default=30, ge=1, le=90)
):
    """
    Get adherence history for a patient.

    Returns daily scores for the specified number of days.
    """
    try:
        db = get_db_connection()

        with db.cursor() as cursor:
            cursor.execute("""
                SELECT
                    score_date,
                    adherence_percentage,
                    active_recommendations,
                    recommendations_scored,
                    pillar_scores,
                    active_mode
                FROM agent_overall_scores
                WHERE patient_id = %s
                  AND score_date >= CURRENT_DATE - INTERVAL '%s days'
                ORDER BY score_date DESC
            """, (patient_id, days))

            history = []
            for row in cursor.fetchall():
                history.append({
                    "date": row[0].isoformat(),
                    "score": float(row[1]),
                    "active_recs": row[2],
                    "scored_recs": row[3],
                    "pillar_scores": row[4],
                    "active_mode": row[5]
                })

        # Calculate trends
        if len(history) >= 7:
            recent_7 = [h['score'] for h in history[:7]]
            previous_7 = [h['score'] for h in history[7:14]] if len(history) >= 14 else []

            trend = {
                "current_avg": sum(recent_7) / len(recent_7),
                "previous_avg": sum(previous_7) / len(previous_7) if previous_7 else None,
                "direction": "improving" if previous_7 and sum(recent_7) > sum(previous_7) else "stable"
            }
        else:
            trend = {"current_avg": sum([h['score'] for h in history]) / len(history) if history else 0}

        return {
            "patient_id": str(patient_id),
            "days_returned": len(history),
            "history": history,
            "trend": trend
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching history: {str(e)}")


# ============================================
# MODE ENDPOINTS
# ============================================

@router.post("/modes/set")
async def set_patient_mode(request: SetModeRequest):
    """
    Set a patient mode (travel, injury, illness, etc.).

    Modes adjust how adherence is calculated and what expectations are set.
    """
    try:
        db = get_db_connection()

        query = """
        INSERT INTO patient_modes (
            patient_id, mode_type, start_date, end_date, notes, mode_config, is_active
        ) VALUES (%s, %s, %s, %s, %s, %s, true)
        RETURNING id
        """

        with db.cursor() as cursor:
            cursor.execute(query, (
                request.patient_id,
                request.mode_type,
                request.start_date,
                request.end_date,
                request.notes,
                request.mode_config
            ))
            db.commit()
            mode_id = cursor.fetchone()[0]

        return {
            "mode_id": str(mode_id),
            "patient_id": str(request.patient_id),
            "mode_type": request.mode_type,
            "start_date": request.start_date.isoformat(),
            "message": f"{request.mode_type.title()} mode activated"
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error setting mode: {str(e)}")


@router.get("/modes/active/{patient_id}")
async def get_active_modes(patient_id: UUID):
    """
    Get active modes for a patient.
    """
    try:
        db = get_db_connection()

        with db.cursor() as cursor:
            cursor.execute("""
                SELECT
                    id,
                    mode_type,
                    start_date,
                    end_date,
                    notes,
                    mode_config
                FROM patient_modes
                WHERE patient_id = %s
                  AND is_active = true
                  AND start_date <= CURRENT_DATE
                  AND (end_date IS NULL OR end_date >= CURRENT_DATE)
                ORDER BY start_date DESC
            """, (patient_id,))

            modes = []
            for row in cursor.fetchall():
                modes.append({
                    "mode_id": str(row[0]),
                    "type": row[1],
                    "start_date": row[2].isoformat() if row[2] else None,
                    "end_date": row[3].isoformat() if row[3] else None,
                    "notes": row[4],
                    "config": row[5]
                })

        return {
            "patient_id": str(patient_id),
            "active_modes": modes,
            "count": len(modes)
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching modes: {str(e)}")


@router.delete("/modes/{mode_id}")
async def end_mode(mode_id: UUID):
    """
    End a patient mode.
    """
    try:
        db = get_db_connection()

        with db.cursor() as cursor:
            cursor.execute("""
                UPDATE patient_modes
                SET end_date = CURRENT_DATE,
                    is_active = false,
                    updated_at = NOW()
                WHERE id = %s
                RETURNING mode_type
            """, (mode_id,))
            db.commit()

            row = cursor.fetchone()
            if not row:
                raise HTTPException(status_code=404, detail="Mode not found")

        return {
            "mode_id": str(mode_id),
            "mode_type": row[0],
            "ended_at": date.today().isoformat(),
            "message": f"{row[0].title()} mode ended"
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error ending mode: {str(e)}")


# ============================================
# NUDGE ENDPOINTS
# ============================================

@router.post("/nudges/generate")
async def generate_nudges(request: GenerateNudgesRequest):
    """
    Generate personalized nudges for a patient.

    The AI analyzes the patient's context and creates appropriate nudges.
    """
    try:
        generator = NudgeGenerator()
        nudges = await generator.generate_nudges_for_patient(
            patient_id=request.patient_id,
            max_nudges=request.max_nudges
        )

        return {
            "patient_id": str(request.patient_id),
            "nudges_generated": len(nudges),
            "nudges": nudges
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error generating nudges: {str(e)}")


@router.get("/nudges/pending/{patient_id}")
async def get_pending_nudges(
    patient_id: UUID,
    limit: int = Query(default=10, ge=1, le=20)
):
    """
    Get pending nudges for a patient.

    Returns nudges that haven't been delivered yet.
    """
    try:
        generator = NudgeGenerator()
        nudges = await generator.get_pending_nudges(
            patient_id=patient_id,
            limit=limit
        )

        return {
            "patient_id": str(patient_id),
            "pending_nudges": len(nudges),
            "nudges": nudges
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching nudges: {str(e)}")


@router.post("/nudges/{nudge_id}/delivered")
async def mark_nudge_delivered(
    nudge_id: UUID,
    request: MarkNudgeDeliveredRequest
):
    """
    Mark a nudge as delivered and optionally record user response.
    """
    try:
        generator = NudgeGenerator()
        await generator.mark_nudge_delivered(
            nudge_id=nudge_id,
            user_response=request.user_response
        )

        return {
            "nudge_id": str(nudge_id),
            "delivered": True,
            "user_response": request.user_response
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error marking nudge delivered: {str(e)}")


# ============================================
# CHALLENGE ENDPOINTS
# ============================================

@router.post("/challenges/create")
async def create_challenge(request: CreateChallengeRequest):
    """
    Create a contextual challenge for a patient.

    The AI creates a bite-sized, achievable challenge based on the patient's situation.
    """
    try:
        creator = ChallengeCreator()
        challenge = await creator.create_challenge_for_patient(
            patient_id=request.patient_id,
            trigger_context=request.trigger_context
        )

        if not challenge:
            return {
                "patient_id": str(request.patient_id),
                "challenge_created": False,
                "message": "No appropriate challenge opportunity at this time"
            }

        return {
            "patient_id": str(request.patient_id),
            "challenge_created": True,
            "challenge": challenge
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error creating challenge: {str(e)}")


@router.get("/challenges/{patient_id}")
async def get_challenges(
    patient_id: UUID,
    include_completed: bool = Query(default=False)
):
    """
    Get challenges for a patient.
    """
    try:
        creator = ChallengeCreator()
        challenges = await creator.get_challenges_for_patient(
            patient_id=patient_id,
            include_completed=include_completed
        )

        return {
            "patient_id": str(patient_id),
            "challenges": challenges,
            "count": len(challenges)
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching challenges: {str(e)}")


@router.patch("/challenges/{challenge_id}/progress")
async def update_challenge_progress(
    challenge_id: UUID,
    request: UpdateChallengeProgressRequest
):
    """
    Update challenge completion percentage.
    """
    try:
        creator = ChallengeCreator()
        await creator.update_challenge_progress(
            challenge_id=challenge_id,
            completion_percentage=request.completion_percentage
        )

        return {
            "challenge_id": str(challenge_id),
            "completion_percentage": request.completion_percentage,
            "updated": True
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error updating challenge: {str(e)}")


# ============================================
# INSIGHTS ENDPOINT
# ============================================

@router.get("/insights/{patient_id}")
async def get_adherence_insights(patient_id: UUID):
    """
    Get comprehensive adherence insights for a patient.

    Returns:
    - Current adherence status
    - Trends
    - Strengths and areas for improvement
    - Active modes
    - Recent nudges and challenges
    """
    try:
        from services.adherence_agent.context_builder import ContextBuilder

        builder = ContextBuilder()
        context = await builder.build_full_context(patient_id, date.today())

        # Build insights
        insights = {
            "patient_id": str(patient_id),
            "as_of_date": date.today().isoformat(),
            "current_status": {
                "overall_adherence": context['recent_adherence'].get('avg_last_7_days', 0),
                "trend": context['recent_adherence'].get('trend', 'unknown'),
                "active_recommendations": context['recommendations']['count'],
                "pillars": context['recommendations']['pillars']
            },
            "active_modes": context['active_modes'],
            "areas_of_concern": []
        }

        # Identify areas of concern
        if context['biomarkers'].get('out_of_range'):
            insights['areas_of_concern'] = [
                {
                    "type": "biomarker",
                    "biomarker": b['biomarker'],
                    "value": b['value'],
                    "deviation": b['deviation']
                }
                for b in context['biomarkers']['out_of_range'][:3]
            ]

        return insights

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error generating insights: {str(e)}")
