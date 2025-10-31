"""
Context Builder for Adherence Agent

Aggregates user context from multiple data sources to provide comprehensive
patient information for intelligent agent decision-making.
"""

from datetime import date, datetime, timedelta
from typing import Dict, List, Optional, Any
import logging
from uuid import UUID

from database.postgres_client import get_db_connection

logger = logging.getLogger(__name__)


class ContextBuilder:
    """
    Builds comprehensive user context from existing WellPath data sources.

    Data Sources:
    - patient_biomarker_readings: Lab results and biomarker data
    - patient_biometric_readings: Vitals and biometric measurements
    - patient_survey_responses: Initial assessment and behavioral data
    - patient_behavioral_values: Tracked metrics from user engagement
    - patient_recommendations: Active recommendations and their history
    - patient_modes: Current modes (travel, injury, illness)
    - display_metrics: User engagement with tracked metrics
    """

    def __init__(self, db_connection=None):
        """
        Initialize Context Builder.

        Args:
            db_connection: Optional database connection. If not provided, will create one.
        """
        self.db = db_connection or get_db_connection()

    async def build_full_context(
        self,
        patient_id: UUID,
        as_of_date: Optional[date] = None
    ) -> Dict[str, Any]:
        """
        Build complete patient context for agent decision-making.

        Args:
            patient_id: Patient UUID
            as_of_date: Date to build context for (defaults to today)

        Returns:
            Dictionary containing comprehensive patient context
        """
        if as_of_date is None:
            as_of_date = date.today()

        logger.info(f"Building context for patient {patient_id} as of {as_of_date}")

        context = {
            "patient_id": str(patient_id),
            "as_of_date": as_of_date.isoformat(),
            "biomarkers": await self.get_biomarker_context(patient_id, as_of_date),
            "biometrics": await self.get_biometric_context(patient_id, as_of_date),
            "recommendations": await self.get_recommendation_context(patient_id, as_of_date),
            "behavioral_data": await self.get_behavioral_context(patient_id, as_of_date),
            "active_modes": await self.get_active_modes(patient_id, as_of_date),
            "recent_adherence": await self.get_recent_adherence(patient_id, as_of_date),
            "engagement_patterns": await self.get_engagement_patterns(patient_id),
        }

        return context

    async def get_biomarker_context(
        self,
        patient_id: UUID,
        as_of_date: date,
        lookback_days: int = 90
    ) -> Dict[str, Any]:
        """
        Get patient's biomarker readings and out-of-range markers.

        Returns most recent readings within lookback period.
        """
        query = """
        SELECT
            pbr.biomarker_name,
            pbr.value,
            pbr.units,
            pbr.reading_date,
            bb.category,
            bd.optimal_min,
            bd.optimal_max,
            bd.reference_min,
            bd.reference_max
        FROM patient_biomarker_readings pbr
        JOIN biomarkers_base bb ON pbr.biomarker_name = bb.biomarker_name
        LEFT JOIN biomarkers_detail bd ON bb.biomarker_name = bd.biomarker
        WHERE pbr.patient_id = %s
          AND pbr.reading_date >= %s
          AND pbr.reading_date <= %s
        ORDER BY pbr.biomarker_name, pbr.reading_date DESC
        """

        start_date = as_of_date - timedelta(days=lookback_days)

        with self.db.cursor() as cursor:
            cursor.execute(query, (patient_id, start_date, as_of_date))
            rows = cursor.fetchall()

        # Group by biomarker, taking most recent reading
        biomarkers = {}
        out_of_range = []

        for row in rows:
            biomarker_name = row[0]
            if biomarker_name not in biomarkers:
                value = float(row[1]) if row[1] is not None else None
                optimal_min = float(row[6]) if row[6] is not None else None
                optimal_max = float(row[7]) if row[7] is not None else None

                biomarkers[biomarker_name] = {
                    "value": value,
                    "units": row[2],
                    "reading_date": row[3].isoformat() if row[3] else None,
                    "category": row[4],
                    "optimal_range": {
                        "min": optimal_min,
                        "max": optimal_max
                    }
                }

                # Check if out of optimal range
                if value is not None and optimal_min is not None and optimal_max is not None:
                    if value < optimal_min or value > optimal_max:
                        deviation = "low" if value < optimal_min else "high"
                        out_of_range.append({
                            "biomarker": biomarker_name,
                            "value": value,
                            "optimal_range": f"{optimal_min}-{optimal_max}",
                            "deviation": deviation,
                            "category": row[4]
                        })

        return {
            "readings": biomarkers,
            "out_of_range": out_of_range,
            "reading_count": len(biomarkers)
        }

    async def get_biometric_context(
        self,
        patient_id: UUID,
        as_of_date: date,
        lookback_days: int = 30
    ) -> Dict[str, Any]:
        """
        Get patient's recent biometric measurements.
        """
        query = """
        SELECT
            pbr.biometric_name,
            pbr.value,
            pbr.unit,
            pbr.recorded_at,
            bb.category
        FROM patient_biometric_readings pbr
        JOIN biometrics_base bb ON pbr.biometric_name = bb.biometric_name
        WHERE pbr.patient_id = %s
          AND DATE(pbr.recorded_at) >= %s
          AND DATE(pbr.recorded_at) <= %s
        ORDER BY pbr.biometric_name, pbr.recorded_at DESC
        """

        start_date = as_of_date - timedelta(days=lookback_days)

        with self.db.cursor() as cursor:
            cursor.execute(query, (patient_id, start_date, as_of_date))
            rows = cursor.fetchall()

        # Group by biometric, taking most recent
        biometrics = {}
        for row in rows:
            biometric_name = row[0]
            if biometric_name not in biometrics:
                biometrics[biometric_name] = {
                    "value": float(row[1]) if row[1] is not None else None,
                    "unit": row[2],
                    "recorded_at": row[3].isoformat() if row[3] else None,
                    "category": row[4]
                }

        return {
            "readings": biometrics,
            "reading_count": len(biometrics)
        }

    async def get_recommendation_context(
        self,
        patient_id: UUID,
        as_of_date: date
    ) -> Dict[str, Any]:
        """
        Get patient's active recommendations with their details.
        """
        query = """
        SELECT
            pr.id as patient_rec_id,
            rb.rec_id,
            rb.title,
            rb.overview,
            rb.agent_goal,
            rb.agent_context,
            rb.pillar,
            rb.recommendation_type,
            rb.primary_biomarkers,
            rb.secondary_biomarkers,
            rb.primary_biometrics,
            rb.secondary_biometrics,
            pr.status,
            pr.assigned_date,
            pr.start_date,
            pr.personal_target,
            pr.agent_notes,
            pr.last_agent_evaluation
        FROM patient_recommendations pr
        JOIN recommendations_base rb ON pr.recommendation_id = rb.id
        WHERE pr.patient_id = %s
          AND pr.status = 'active'
          AND pr.assigned_date <= %s
        ORDER BY pr.assigned_date
        """

        with self.db.cursor() as cursor:
            cursor.execute(query, (patient_id, as_of_date))
            rows = cursor.fetchall()

        recommendations = []
        pillars = set()

        for row in rows:
            rec = {
                "patient_recommendation_id": str(row[0]),
                "rec_id": row[1],
                "title": row[2],
                "overview": row[3],
                "agent_goal": row[4],
                "agent_context": row[5],
                "pillar": row[6],
                "recommendation_type": row[7],
                "primary_biomarkers": row[8].split(',') if row[8] else [],
                "secondary_biomarkers": row[9].split(',') if row[9] else [],
                "primary_biometrics": row[10].split(',') if row[10] else [],
                "secondary_biometrics": row[11].split(',') if row[11] else [],
                "status": row[12],
                "assigned_date": row[13].isoformat() if row[13] else None,
                "start_date": row[14].isoformat() if row[14] else None,
                "personal_target": row[15],
                "agent_notes": row[16],
                "last_evaluated": row[17].isoformat() if row[17] else None
            }
            recommendations.append(rec)
            pillars.add(row[6])

        return {
            "active_recommendations": recommendations,
            "count": len(recommendations),
            "pillars": list(pillars)
        }

    async def get_behavioral_context(
        self,
        patient_id: UUID,
        as_of_date: date,
        lookback_days: int = 30
    ) -> Dict[str, Any]:
        """
        Get patient's behavioral data from tracked metrics.
        """
        query = """
        SELECT
            pbv.biometric_name,
            pbv.value,
            pbv.recorded_at,
            bb.category
        FROM patient_behavioral_values pbv
        JOIN biometrics_base bb ON pbv.biometric_name = bb.biometric_name
        WHERE pbv.patient_id = %s
          AND DATE(pbv.recorded_at) >= %s
          AND DATE(pbv.recorded_at) <= %s
        ORDER BY pbv.biometric_name, pbv.recorded_at DESC
        """

        start_date = as_of_date - timedelta(days=lookback_days)

        with self.db.cursor() as cursor:
            cursor.execute(query, (patient_id, start_date, as_of_date))
            rows = cursor.fetchall()

        # Aggregate behavioral data
        behaviors = {}
        for row in rows:
            behavior_name = row[0]
            if behavior_name not in behaviors:
                behaviors[behavior_name] = []

            behaviors[behavior_name].append({
                "value": float(row[1]) if row[1] is not None else None,
                "recorded_at": row[2].isoformat() if row[2] else None
            })

        return {
            "tracked_behaviors": behaviors,
            "behavior_count": len(behaviors),
            "total_entries": sum(len(v) for v in behaviors.values())
        }

    async def get_active_modes(
        self,
        patient_id: UUID,
        as_of_date: date
    ) -> List[Dict[str, Any]]:
        """
        Get patient's active modes (travel, injury, illness, etc.).
        """
        query = """
        SELECT
            id,
            mode_type,
            start_date,
            end_date,
            mode_config,
            notes
        FROM patient_modes
        WHERE patient_id = %s
          AND start_date <= %s
          AND (end_date IS NULL OR end_date >= %s)
          AND is_active = true
        ORDER BY start_date DESC
        """

        with self.db.cursor() as cursor:
            cursor.execute(query, (patient_id, as_of_date, as_of_date))
            rows = cursor.fetchall()

        modes = []
        for row in rows:
            modes.append({
                "id": str(row[0]),
                "type": row[1],
                "start_date": row[2].isoformat() if row[2] else None,
                "end_date": row[3].isoformat() if row[3] else None,
                "config": row[4],
                "notes": row[5]
            })

        return modes

    async def get_recent_adherence(
        self,
        patient_id: UUID,
        as_of_date: date,
        lookback_days: int = 30
    ) -> Dict[str, Any]:
        """
        Get patient's recent adherence scores from agent system.
        """
        query = """
        SELECT
            score_date,
            adherence_percentage,
            active_recommendations,
            recommendations_scored,
            pillar_scores
        FROM agent_overall_scores
        WHERE patient_id = %s
          AND score_date >= %s
          AND score_date <= %s
        ORDER BY score_date DESC
        """

        start_date = as_of_date - timedelta(days=lookback_days)

        with self.db.cursor() as cursor:
            cursor.execute(query, (patient_id, start_date, as_of_date))
            rows = cursor.fetchall()

        if not rows:
            return {"has_history": False}

        scores = []
        for row in rows:
            scores.append({
                "date": row[0].isoformat(),
                "score": float(row[1]),
                "active_recs": row[2],
                "scored_recs": row[3],
                "pillar_scores": row[4]
            })

        # Calculate trends
        recent_scores = [s["score"] for s in scores[:7]]  # Last 7 days
        avg_recent = sum(recent_scores) / len(recent_scores) if recent_scores else 0

        return {
            "has_history": True,
            "scores": scores,
            "avg_last_7_days": round(avg_recent, 1),
            "trend": "improving" if len(recent_scores) >= 2 and recent_scores[0] > recent_scores[-1] else "stable"
        }

    async def get_engagement_patterns(
        self,
        patient_id: UUID,
        lookback_days: int = 30
    ) -> Dict[str, Any]:
        """
        Analyze patient engagement patterns.
        """
        # This would analyze when user logs data, responds to nudges, etc.
        # For now, return a placeholder
        return {
            "last_active": date.today().isoformat(),
            "avg_entries_per_day": 0,
            "preferred_time": "morning"  # Would be calculated from actual data
        }

    def format_context_for_agent(self, context: Dict[str, Any]) -> str:
        """
        Format context into a natural language prompt for the agent.

        Args:
            context: Full context dictionary

        Returns:
            Formatted string for agent consumption
        """
        sections = []

        # Patient overview
        sections.append(f"Patient ID: {context['patient_id']}")
        sections.append(f"Assessment Date: {context['as_of_date']}")

        # Active modes
        if context['active_modes']:
            mode_strs = [f"{m['type']} (since {m['start_date']})" for m in context['active_modes']]
            sections.append(f"\nActive Modes: {', '.join(mode_strs)}")

        # Biomarkers
        bio = context['biomarkers']
        sections.append(f"\nBiomarkers: {bio['reading_count']} recent readings")
        if bio['out_of_range']:
            oor_list = [f"{b['biomarker']}: {b['value']} ({b['deviation']})" for b in bio['out_of_range'][:5]]
            sections.append(f"Out of Range: {', '.join(oor_list)}")

        # Active recommendations
        recs = context['recommendations']
        sections.append(f"\nActive Recommendations: {recs['count']}")
        sections.append(f"Pillars: {', '.join(recs['pillars'])}")

        # Recent adherence
        if context['recent_adherence'].get('has_history'):
            adh = context['recent_adherence']
            sections.append(f"\nRecent Adherence: {adh['avg_last_7_days']}% (7-day avg)")
            sections.append(f"Trend: {adh['trend']}")

        return "\n".join(sections)
