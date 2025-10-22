"""
Education API Router

Endpoints for tracking and retrieving educational content engagement.
"""

from fastapi import APIRouter, HTTPException, Body
from pydantic import BaseModel, Field
from typing import Optional, List, Dict
from datetime import datetime

from database.postgres_client import PostgresClient
from scoring_engine.education_scorer import EducationScorer


router = APIRouter(tags=["education"])
db = PostgresClient()
education_scorer = EducationScorer(db)


# Pydantic Models
class ArticleEngagement(BaseModel):
    """Model for tracking article engagement."""
    patient_id: str = Field(..., description="Patient UUID")
    module_id: str = Field(..., description="Education module ID (record_id from Airtable)")
    time_spent_seconds: int = Field(0, ge=0, description="Time spent reading article (seconds)")
    scroll_percentage: int = Field(0, ge=0, le=100, description="How far the user scrolled (0-100%)")
    completed: bool = Field(False, description="Whether the article was completed (scroll >= 80%)")


class Article(BaseModel):
    """Model for article information."""
    id: str
    pillar: str
    title: str
    description: Optional[str] = None
    content_url: Optional[str] = None
    viewed: Optional[bool] = False


class EducationScoreResponse(BaseModel):
    """Model for education score response."""
    pillar: str
    score: float = Field(..., ge=0, le=10, description="Education score (0-10 points)")
    percentage: float = Field(..., ge=0, le=100, description="Percentage of max education score")
    articles_viewed: int
    articles_remaining: int


class EducationSummaryResponse(BaseModel):
    """Model for comprehensive education summary."""
    total_articles_viewed: int
    total_possible_articles: int
    overall_education_percentage: float
    pillars: Dict[str, dict]


# Endpoints

@router.get("/articles")
async def get_available_articles(
    patient_id: str,
    pillar: Optional[str] = None
) -> List[Article]:
    """
    Get all available educational articles, optionally filtered by pillar.

    Args:
        patient_id: Patient UUID
        pillar: Optional pillar filter (e.g., "Cognitive Health")

    Returns:
        List of articles with viewed status
    """
    try:
        articles = education_scorer.get_available_articles(patient_id, pillar)
        return [Article(**article) for article in articles]
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching articles: {str(e)}")


@router.get("/articles/viewed")
async def get_viewed_articles(
    patient_id: str,
    pillar: Optional[str] = None
) -> List[dict]:
    """
    Get articles the patient has already viewed.

    Args:
        patient_id: Patient UUID
        pillar: Optional pillar filter

    Returns:
        List of viewed articles with engagement data
    """
    try:
        articles = education_scorer.get_articles_viewed(patient_id, pillar)
        return articles
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching viewed articles: {str(e)}")


@router.post("/engage")
async def track_article_engagement(engagement: ArticleEngagement):
    """
    Track when a patient views/engages with an educational article.

    This endpoint should be called:
    - When user opens an article (with time_spent_seconds=0)
    - Periodically while reading (to update time_spent)
    - When user scrolls (to update scroll_percentage)
    - When user completes (scroll >= 80%)

    Args:
        engagement: Article engagement data

    Returns:
        Success message with updated education score
    """
    try:
        # Get module info to determine pillar
        query_module = "SELECT pillars FROM education_modules WHERE record_id = %s"
        result = db.execute_single(query_module, (engagement.module_id,))

        if not result:
            raise HTTPException(status_code=404, detail=f"Education module '{engagement.module_id}' not found")

        pillar = result['pillars']  # Note: this might be comma-separated, take first
        if ',' in pillar:
            pillar = pillar.split(',')[0].strip()

        # Auto-mark as completed if scroll >= 80%
        completed = engagement.completed or engagement.scroll_percentage >= 80

        # Insert or update engagement record
        query = """
        INSERT INTO education_engagement (
            patient_id, module_id, pillar,
            time_spent_seconds, scroll_percentage, completed,
            viewed_at, updated_at
        )
        VALUES (%s, %s, %s, %s, %s, %s, NOW(), NOW())
        ON CONFLICT (patient_id, module_id)
        DO UPDATE SET
            time_spent_seconds = GREATEST(education_engagement.time_spent_seconds, EXCLUDED.time_spent_seconds),
            scroll_percentage = GREATEST(education_engagement.scroll_percentage, EXCLUDED.scroll_percentage),
            completed = education_engagement.completed OR EXCLUDED.completed,
            updated_at = NOW()
        RETURNING id
        """

        db.execute_single(
            query,
            (
                engagement.patient_id,
                engagement.module_id,
                pillar,
                engagement.time_spent_seconds,
                engagement.scroll_percentage,
                completed
            )
        )

        # Get updated education score for this pillar
        score = education_scorer.get_education_score(engagement.patient_id, pillar)
        percentage = education_scorer.get_education_percentage(engagement.patient_id, pillar)

        return {
            "message": "Engagement tracked successfully",
            "module_id": engagement.module_id,
            "pillar": pillar,
            "education_score": score,
            "education_percentage": percentage,
            "completed": completed
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error tracking engagement: {str(e)}")


@router.get("/score/{patient_id}")
async def get_education_scores(patient_id: str) -> Dict[str, float]:
    """
    Get education scores for all pillars.

    Args:
        patient_id: Patient UUID

    Returns:
        Dictionary of pillar -> education_score (0.0 to 10.0)
    """
    try:
        scores = education_scorer.get_all_education_scores(patient_id)
        return scores
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error calculating education scores: {str(e)}")


@router.get("/score/{patient_id}/{pillar}")
async def get_pillar_education_score(
    patient_id: str,
    pillar: str
) -> EducationScoreResponse:
    """
    Get detailed education score for a specific pillar.

    Args:
        patient_id: Patient UUID
        pillar: Pillar name (e.g., "Cognitive Health")

    Returns:
        Detailed education score information
    """
    try:
        score = education_scorer.get_education_score(patient_id, pillar)
        percentage = education_scorer.get_education_percentage(patient_id, pillar)
        articles = education_scorer.get_articles_viewed(patient_id, pillar)

        return EducationScoreResponse(
            pillar=pillar,
            score=score,
            percentage=percentage,
            articles_viewed=len(articles),
            articles_remaining=4 - len(articles)
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error calculating education score: {str(e)}")


@router.get("/summary/{patient_id}")
async def get_education_summary(patient_id: str) -> EducationSummaryResponse:
    """
    Get comprehensive education engagement summary for a patient.

    Args:
        patient_id: Patient UUID

    Returns:
        Complete summary with scores and progress for all pillars
    """
    try:
        summary = education_scorer.get_education_summary(patient_id)
        return EducationSummaryResponse(**summary)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error generating education summary: {str(e)}")


@router.delete("/engagement/{patient_id}/{article_id}")
async def delete_article_engagement(patient_id: str, article_id: str):
    """
    Delete an article engagement record (admin/testing only).

    Args:
        patient_id: Patient UUID
        article_id: Article ID

    Returns:
        Success message
    """
    try:
        query = "DELETE FROM education_engagement WHERE patient_id = %s AND article_id = %s"
        db.execute_query(query, (patient_id, article_id))
        return {"message": "Engagement record deleted successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error deleting engagement: {str(e)}")
