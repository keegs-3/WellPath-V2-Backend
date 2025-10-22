#!/usr/bin/env python3
"""
Education Score Component

Calculates the education score for each pillar based on patient engagement
with educational articles.

Scoring Logic:
- Each pillar has 4 core articles
- Each article viewed = 2.5 points (2.5% of total pillar score)
- Maximum education score per pillar = 10 points (10% of total pillar score)
- Combined with Survey (variable) + Biomarkers (variable) = 100% total

Requirements for "viewed":
- Time spent >= min_engagement_seconds (default 30s) OR
- Scroll percentage >= 80%
"""

from typing import Dict, Optional
from database.postgres_client import PostgresClient


PILLARS = [
    "Cognitive Health",
    "Connection + Purpose",
    "Core Care",
    "Healthful Nutrition",
    "Movement + Exercise",
    "Restorative Sleep",
    "Stress Management"
]

POINTS_PER_ARTICLE = 2.5  # Each article = 2.5% of pillar score
MAX_ARTICLES_PER_PILLAR = 4  # Maximum 4 articles per pillar
MAX_EDUCATION_SCORE = 10.0  # Maximum 10% per pillar


class EducationScorer:
    """Calculates education scores based on article engagement."""

    def __init__(self, db: PostgresClient):
        self.db = db

    def get_education_score(self, patient_id: str, pillar: str) -> float:
        """
        Calculate education score for a specific pillar.

        Args:
            patient_id: Patient UUID
            pillar: Pillar name (e.g., "Cognitive Health")

        Returns:
            Education score (0.0 to 10.0)
        """
        query = """
        SELECT COUNT(DISTINCT ee.module_id) as articles_viewed
        FROM education_engagement ee
        JOIN education_modules em ON ee.module_id = em.record_id
        WHERE ee.patient_id = %s
          AND ee.pillar = %s
          AND (
              ee.time_spent_seconds >= COALESCE(em.min_engagement_seconds, 30)
              OR ee.scroll_percentage >= 80
              OR ee.completed = TRUE
          )
        """

        result = self.db.execute_single(query, (patient_id, pillar))
        if not result:
            return 0.0

        articles_viewed = min(result['articles_viewed'], MAX_ARTICLES_PER_PILLAR)
        score = articles_viewed * POINTS_PER_ARTICLE

        return min(score, MAX_EDUCATION_SCORE)

    def get_all_education_scores(self, patient_id: str) -> Dict[str, float]:
        """
        Calculate education scores for all pillars.

        Args:
            patient_id: Patient UUID

        Returns:
            Dictionary of pillar -> education_score (0.0 to 10.0)
        """
        scores = {}
        for pillar in PILLARS:
            scores[pillar] = self.get_education_score(patient_id, pillar)
        return scores

    def get_education_percentage(self, patient_id: str, pillar: str) -> float:
        """
        Get education score as a percentage of maximum possible.

        Args:
            patient_id: Patient UUID
            pillar: Pillar name

        Returns:
            Percentage (0.0 to 100.0)
        """
        score = self.get_education_score(patient_id, pillar)
        return (score / MAX_EDUCATION_SCORE) * 100.0

    def get_articles_viewed(self, patient_id: str, pillar: Optional[str] = None) -> list:
        """
        Get list of articles the patient has viewed.

        Args:
            patient_id: Patient UUID
            pillar: Optional pillar filter

        Returns:
            List of dicts with article info
        """
        if pillar:
            query = """
            SELECT
                em.record_id as id,
                em.pillars as pillar,
                em.title,
                em.description,
                ee.viewed_at,
                ee.time_spent_seconds,
                ee.scroll_percentage,
                ee.completed
            FROM education_engagement ee
            JOIN education_modules em ON ee.module_id = em.record_id
            WHERE ee.patient_id = %s AND ee.pillar = %s
            ORDER BY ee.viewed_at DESC
            """
            results = self.db.execute_query(query, (patient_id, pillar))
        else:
            query = """
            SELECT
                em.record_id as id,
                em.pillars as pillar,
                em.title,
                em.description,
                ee.viewed_at,
                ee.time_spent_seconds,
                ee.scroll_percentage,
                ee.completed
            FROM education_engagement ee
            JOIN education_modules em ON ee.module_id = em.record_id
            WHERE ee.patient_id = %s
            ORDER BY ee.viewed_at DESC
            """
            results = self.db.execute_query(query, (patient_id,))

        articles = []
        for row in results:
            articles.append({
                'id': row['id'],
                'pillar': row['pillar'],
                'title': row['title'],
                'description': row['description'],
                'viewed_at': row['viewed_at'],
                'time_spent_seconds': row['time_spent_seconds'],
                'scroll_percentage': row['scroll_percentage'],
                'completed': row['completed']
            })
        return articles

    def get_available_articles(self, patient_id: str, pillar: Optional[str] = None) -> list:
        """
        Get list of articles available to the patient (not yet viewed or all).

        Args:
            patient_id: Patient UUID
            pillar: Optional pillar filter

        Returns:
            List of dicts with article info
        """
        if pillar:
            query = """
            SELECT
                em.record_id as id,
                em.pillars as pillar,
                em.title,
                em.description,
                em.delivery_method as content_url,
                EXISTS(
                    SELECT 1 FROM education_engagement ee
                    WHERE ee.patient_id = %s AND ee.module_id = em.record_id
                ) as viewed
            FROM education_modules em
            WHERE em.pillars LIKE %s
            ORDER BY em.record_id
            """
            results = self.db.execute_query(query, (patient_id, f'%{pillar}%'))
        else:
            query = """
            SELECT
                em.record_id as id,
                em.pillars as pillar,
                em.title,
                em.description,
                em.delivery_method as content_url,
                EXISTS(
                    SELECT 1 FROM education_engagement ee
                    WHERE ee.patient_id = %s AND ee.module_id = em.record_id
                ) as viewed
            FROM education_modules em
            ORDER BY em.pillars, em.record_id
            """
            results = self.db.execute_query(query, (patient_id,))

        articles = []
        for row in results:
            articles.append({
                'id': row['id'],
                'pillar': row['pillar'],
                'title': row['title'],
                'description': row['description'],
                'content_url': row['content_url'],
                'viewed': row['viewed']
            })
        return articles

    def get_education_summary(self, patient_id: str) -> Dict:
        """
        Get comprehensive education engagement summary.

        Args:
            patient_id: Patient UUID

        Returns:
            Dictionary with scores and progress for all pillars
        """
        summary = {
            'total_articles_viewed': 0,
            'total_possible_articles': 28,  # 4 per pillar × 7 pillars
            'overall_education_percentage': 0.0,
            'pillars': {}
        }

        total_score = 0.0
        for pillar in PILLARS:
            score = self.get_education_score(patient_id, pillar)
            articles = self.get_articles_viewed(patient_id, pillar)

            summary['pillars'][pillar] = {
                'score': score,
                'max_score': MAX_EDUCATION_SCORE,
                'percentage': (score / MAX_EDUCATION_SCORE) * 100.0,
                'articles_viewed': len(articles),
                'articles_remaining': MAX_ARTICLES_PER_PILLAR - len(articles)
            }

            summary['total_articles_viewed'] += len(articles)
            total_score += score

        # Overall percentage (average across all pillars)
        summary['overall_education_percentage'] = (total_score / (MAX_EDUCATION_SCORE * len(PILLARS))) * 100.0

        return summary
