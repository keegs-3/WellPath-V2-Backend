#!/usr/bin/env python3
"""
Generate historical WellPath scores for testing charts
Creates scores going back 90 days with realistic variation
"""

import psycopg2
from datetime import datetime, timedelta
import random
import uuid

DATABASE_URL = "postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres?sslmode=require"

# Patient to generate scores for
PATIENT_ID = "8b79ce33-02b8-4f49-8268-3204130efa82"

# Pillars in scoring system
PILLARS = [
    "Healthful Nutrition",
    "Movement + Exercise",
    "Restorative Sleep",
    "Stress Management",
    "Cognitive Health",
    "Connection + Purpose",
    "Core Care"
]

# Components per pillar
COMPONENTS = ["markers", "behaviors", "education"]

def generate_score_with_trend(base_score, day_offset, trend="improving"):
    """
    Generate realistic score with trend and variation

    Args:
        base_score: Starting score (0-100)
        day_offset: Days from now (negative for past)
        trend: 'improving', 'declining', or 'stable'
    """
    # Add trend component
    if trend == "improving":
        trend_adjustment = abs(day_offset) * 0.15  # Gradual improvement
    elif trend == "declining":
        trend_adjustment = abs(day_offset) * -0.1  # Gradual decline
    else:  # stable
        trend_adjustment = 0

    # Add random daily variation (±3 points)
    daily_variation = random.uniform(-3, 3)

    # Add weekly pattern (slightly higher on weekends)
    date = datetime.now() + timedelta(days=day_offset)
    if date.weekday() >= 5:  # Weekend
        weekly_adjustment = random.uniform(1, 3)
    else:
        weekly_adjustment = 0

    score = base_score + trend_adjustment + daily_variation + weekly_adjustment

    # Clamp to 0-100
    return max(0, min(100, score))

def generate_historical_scores(days_back=90):
    """Generate historical scores for all levels"""
    conn = psycopg2.connect(DATABASE_URL)
    cur = conn.cursor()

    try:
        print(f"Generating {days_back} days of historical scores for patient {PATIENT_ID}")
        print("="*80)

        # Delete existing scores for this patient to start fresh
        cur.execute("DELETE FROM patient_item_scores_history WHERE patient_id = %s", (PATIENT_ID,))
        cur.execute("DELETE FROM patient_component_scores_history WHERE patient_id = %s", (PATIENT_ID,))
        cur.execute("DELETE FROM patient_pillar_scores_history WHERE patient_id = %s", (PATIENT_ID,))
        cur.execute("DELETE FROM patient_wellpath_scores_history WHERE patient_id = %s", (PATIENT_ID,))

        print(f"✓ Cleared existing scores")

        # Pillar base scores and trends
        pillar_config = {
            "Healthful Nutrition": {"base": 72, "trend": "improving"},
            "Movement + Exercise": {"base": 68, "trend": "improving"},
            "Restorative Sleep": {"base": 75, "trend": "stable"},
            "Stress Management": {"base": 65, "trend": "improving"},
            "Cognitive Health": {"base": 70, "trend": "stable"},
            "Connection + Purpose": {"base": 80, "trend": "stable"},
            "Core Care": {"base": 85, "trend": "improving"}
        }

        total_scores_created = 0

        # Generate scores for each day
        for day_offset in range(-days_back, 1):  # -90 to 0 (today)
            calculated_at = datetime.now() + timedelta(days=day_offset)

            # Calculate WellPath score
            pillar_scores = {}
            wellpath_total = 0

            for pillar in PILLARS:
                config = pillar_config[pillar]
                pillar_score = generate_score_with_trend(
                    config["base"],
                    day_offset,
                    config["trend"]
                )
                pillar_scores[pillar] = pillar_score
                wellpath_total += pillar_score

            wellpath_score = wellpath_total / len(PILLARS)

            # Insert WellPath score
            import json
            pillar_scores_json = json.dumps({pillar: score for pillar, score in pillar_scores.items()})

            cur.execute("""
                INSERT INTO patient_wellpath_scores_history (
                    patient_id,
                    overall_score,
                    overall_max_score,
                    overall_percentage,
                    pillar_scores,
                    total_items_scored,
                    calculated_at
                ) VALUES (%s, %s, %s, %s, %s, %s, %s)
            """, (PATIENT_ID, wellpath_total, len(PILLARS) * 100, wellpath_score, pillar_scores_json, 100, calculated_at))
            total_scores_created += 1

            # Insert Pillar scores
            for pillar, score in pillar_scores.items():
                cur.execute("""
                    INSERT INTO patient_pillar_scores_history (
                        patient_id,
                        pillar_name,
                        pillar_score,
                        pillar_max_score,
                        pillar_percentage,
                        calculated_at
                    ) VALUES (%s, %s, %s, %s, %s, %s)
                """, (PATIENT_ID, pillar, score, 100, score, calculated_at))
                total_scores_created += 1

                # Insert Component scores (markers, behaviors, education)
                for component in COMPONENTS:
                    # Component scores vary ±5 points from pillar
                    component_score = generate_score_with_trend(
                        score + random.uniform(-5, 5),
                        day_offset,
                        pillar_config[pillar]["trend"]
                    )

                    cur.execute("""
                        INSERT INTO patient_component_scores_history (
                            patient_id,
                            pillar_name,
                            component_type,
                            component_score,
                            component_max_score,
                            component_percentage,
                            calculated_at
                        ) VALUES (%s, %s, %s, %s, %s, %s, %s)
                    """, (PATIENT_ID, pillar, component, component_score, 100, component_score, calculated_at))
                    total_scores_created += 1

            # Show progress every 10 days
            if day_offset % 10 == 0:
                print(f"  Day {day_offset}: WellPath={wellpath_score:.1f}")

        conn.commit()

        print("\n" + "="*80)
        print(f"✅ Generated {total_scores_created} historical scores")
        print("="*80)

        # Show summary
        cur.execute("""
            SELECT
                COUNT(*) as total_scores,
                MIN(calculated_at)::date as earliest_date,
                MAX(calculated_at)::date as latest_date,
                ROUND(AVG(overall_percentage), 1) as avg_score,
                ROUND(MIN(overall_percentage), 1) as min_score,
                ROUND(MAX(overall_percentage), 1) as max_score
            FROM patient_wellpath_scores_history
            WHERE patient_id = %s
        """, (PATIENT_ID,))

        summary = cur.fetchone()
        print(f"\nSummary:")
        print(f"  Total WellPath scores: {summary[0]}")
        print(f"  Date range: {summary[1]} to {summary[2]}")
        print(f"  Average score: {summary[3]}%")
        print(f"  Score range: {summary[4]}% - {summary[5]}%")

        # Show pillar scores
        print(f"\nPillar Scores (latest):")
        cur.execute("""
            SELECT
                pillar_name,
                ROUND(pillar_percentage, 1) as score
            FROM patient_pillar_scores_history
            WHERE patient_id = %s
              AND calculated_at = (
                  SELECT MAX(calculated_at)
                  FROM patient_pillar_scores_history
                  WHERE patient_id = %s
              )
            ORDER BY pillar_name
        """, (PATIENT_ID, PATIENT_ID))

        for pillar, score in cur.fetchall():
            print(f"  {pillar}: {score}")

    except Exception as e:
        conn.rollback()
        print(f"\n❌ Error: {e}")
        import traceback
        traceback.print_exc()
        raise
    finally:
        cur.close()
        conn.close()

if __name__ == '__main__':
    print("HISTORICAL WELLPATH SCORES GENERATOR")
    print()
    generate_historical_scores(days_back=90)
    print()
    print("✅ Historical scores ready for chart testing!")
