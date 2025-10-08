"""Scoring endpoints."""

from fastapi import APIRouter, HTTPException, Depends
from typing import List, Dict, Any
from datetime import datetime

from database.supabase_client import get_supabase
from database.models import (
    PatientScoreRequest,
    PatientScoreResponse,
    PillarScore,
    CalculateScoreRequest
)

router = APIRouter()


@router.post("/calculate", response_model=PatientScoreResponse)
async def calculate_patient_scores(
    request: PatientScoreRequest,
    supabase=Depends(get_supabase)
):
    """
    Calculate WellPath scores for a patient.

    This endpoint:
    1. Fetches patient's biomarker and survey data from Supabase
    2. Runs the scoring algorithms
    3. Returns pillar scores and overall score
    """
    try:
        # TODO: Implement actual scoring logic
        # For now, return mock data

        pillar_scores = [
            PillarScore(
                pillar_id="pillar_1",
                pillar_name="Healthful Nutrition",
                score=75.5,
                max_score=100.0,
                percentage=75.5
            ),
            PillarScore(
                pillar_id="pillar_2",
                pillar_name="Movement & Exercise",
                score=82.3,
                max_score=100.0,
                percentage=82.3
            ),
        ]

        overall_score = sum(p.score for p in pillar_scores)
        overall_max = sum(p.max_score for p in pillar_scores)

        return PatientScoreResponse(
            patient_id=request.patient_id,
            overall_score=overall_score,
            overall_max_score=overall_max,
            overall_percentage=(overall_score / overall_max * 100) if overall_max > 0 else 0,
            pillar_scores=pillar_scores,
            calculated_at=datetime.now()
        )

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Scoring failed: {str(e)}")


@router.get("/patient/{patient_id}", response_model=PatientScoreResponse)
async def get_patient_scores(
    patient_id: str,
    supabase=Depends(get_supabase)
):
    """Get cached scores for a patient."""
    try:
        # TODO: Fetch from pillar_scores table
        response = supabase.table("pillar_scores") \
            .select("*") \
            .eq("patient_id", patient_id) \
            .execute()

        if not response.data:
            raise HTTPException(status_code=404, detail="Patient scores not found")

        # Transform database records to response model
        # TODO: Implement proper transformation

        return PatientScoreResponse(
            patient_id=patient_id,
            overall_score=0,
            overall_max_score=0,
            overall_percentage=0,
            pillar_scores=[],
            calculated_at=datetime.now()
        )

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch scores: {str(e)}")


@router.get("/pillar/{pillar_id}")
async def get_pillar_breakdown(
    pillar_id: str,
    patient_id: str,
    supabase=Depends(get_supabase)
):
    """Get detailed breakdown for a specific pillar."""
    try:
        # TODO: Implement pillar breakdown
        # This should show which biomarkers/survey questions contributed to the pillar score

        return {
            "pillar_id": pillar_id,
            "patient_id": patient_id,
            "contributors": []
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch breakdown: {str(e)}")
