"""Scoring endpoints."""

from fastapi import APIRouter, HTTPException, Depends
from typing import List, Dict, Any
from datetime import datetime

from database.postgres_client import PostgresClient
from database.models import (
    PatientScoreRequest,
    PatientScoreResponse,
    PillarScore,
    CalculateScoreRequest
)
from scoring_engine.scoring_service import WellPathScoringService

router = APIRouter()


def get_scoring_service() -> WellPathScoringService:
    """Dependency to get scoring service instance."""
    db = PostgresClient()
    return WellPathScoringService(db)


@router.post("/calculate", response_model=PatientScoreResponse)
async def calculate_patient_scores(
    request: PatientScoreRequest,
    scoring_service: WellPathScoringService = Depends(get_scoring_service)
):
    """
    Calculate WellPath scores for a patient.

    This endpoint:
    1. Fetches patient's biomarker and survey data from Supabase
    2. Runs the scoring algorithms
    3. Returns pillar scores and overall score
    """
    try:
        # Calculate comprehensive scores
        results = scoring_service.calculate_patient_scores(request.patient_id)

        # Transform to response model
        pillar_scores = [
            PillarScore(
                pillar_id=f"pillar_{i}",
                pillar_name=pillar_name,
                score=score,
                max_score=100.0,
                percentage=score
            )
            for i, (pillar_name, score) in enumerate(results['pillar_scores'].items())
        ]

        return PatientScoreResponse(
            patient_id=request.patient_id,
            overall_score=results['overall_score'],
            overall_max_score=100.0,
            overall_percentage=results['overall_score'],
            pillar_scores=pillar_scores,
            calculated_at=datetime.now()
        )

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Scoring failed: {str(e)}")


@router.get("/patient/{patient_id}", response_model=PatientScoreResponse)
async def get_patient_scores(
    patient_id: str,
    include_breakdown: bool = True,
    scoring_service: WellPathScoringService = Depends(get_scoring_service)
):
    """Get cached scores for a patient."""
    try:
        # Calculate scores fresh (in production, this would fetch from cache)
        results = scoring_service.calculate_patient_scores(patient_id)

        # Transform to response model
        pillar_scores = [
            PillarScore(
                pillar_id=f"pillar_{i}",
                pillar_name=pillar_name,
                score=score,
                max_score=100.0,
                percentage=score
            )
            for i, (pillar_name, score) in enumerate(results['pillar_scores'].items())
        ]

        # Build breakdown if requested
        breakdown = None
        if include_breakdown:
            breakdown = scoring_service.get_score_breakdown(patient_id)

        return PatientScoreResponse(
            patient_id=patient_id,
            overall_score=results['overall_score'],
            overall_max_score=100.0,
            overall_percentage=results['overall_score'],
            pillar_scores=pillar_scores,
            calculated_at=datetime.now(),
            breakdown=breakdown
        )

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch scores: {str(e)}")


@router.post("/test/survey-only")
async def test_survey_scoring(
    request: PatientScoreRequest,
    scoring_service: WellPathScoringService = Depends(get_scoring_service)
):
    """
    TEST ENDPOINT: Get survey-only scores (no biomarkers, no combination).
    This is for validation purposes only.
    """
    try:
        # Calculate comprehensive scores
        results = scoring_service.calculate_patient_scores(request.patient_id)

        # Return only survey_details
        return {
            "patient_id": request.patient_id,
            "survey_scores": results.get('survey_details', {}),
            "calculated_at": datetime.now()
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Scoring failed: {str(e)}")


@router.get("/pillar/{pillar_name}")
async def get_pillar_breakdown(
    pillar_name: str,
    patient_id: str,
    scoring_service: WellPathScoringService = Depends(get_scoring_service)
):
    """Get detailed breakdown for a specific pillar."""
    try:
        breakdown = scoring_service.get_pillar_breakdown(patient_id, pillar_name)
        return breakdown

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch breakdown: {str(e)}")
