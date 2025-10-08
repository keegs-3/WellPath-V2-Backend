"""Pydantic models for API requests/responses."""

from typing import Optional, List, Dict, Any
from datetime import datetime, date
from pydantic import BaseModel, Field


class PillarScore(BaseModel):
    """Pillar score model."""
    pillar_id: str
    pillar_name: str
    score: float
    max_score: float
    percentage: float


class PatientScoreRequest(BaseModel):
    """Request to calculate patient scores."""
    patient_id: str
    include_breakdown: bool = False


class PatientScoreResponse(BaseModel):
    """Patient score calculation response."""
    patient_id: str
    overall_score: float
    overall_max_score: float
    overall_percentage: float
    pillar_scores: List[PillarScore]
    calculated_at: datetime
    breakdown: Optional[Dict[str, Any]] = None


class BiomarkerInput(BaseModel):
    """Biomarker data input."""
    marker_id: str
    value: float
    unit: str
    measured_at: datetime


class SurveyResponse(BaseModel):
    """Survey response input."""
    question_id: str
    response_option_id: str
    value: Optional[Any] = None


class CalculateScoreRequest(BaseModel):
    """Request to calculate scores with data."""
    patient_id: str
    biomarkers: Optional[List[BiomarkerInput]] = []
    survey_responses: Optional[List[SurveyResponse]] = []


class HealthCheckResponse(BaseModel):
    """Health check response."""
    status: str
    version: str
    database: str
    timestamp: datetime
