"""
Quick test with perfect patient - simplified version.
"""

import sys
import os
from uuid import UUID

sys.path.insert(0, '/Users/keegs/Documents/WellPath/wellpath-v2-backend')

from dotenv import load_dotenv
load_dotenv('/Users/keegs/Documents/WellPath/wellpath-v2-backend/.env')

from database.postgres_client import get_db_connection


def get_patient_biomarkers(patient_id):
    """Get patient biomarkers."""
    db = get_db_connection()

    with db.cursor() as cursor:
        cursor.execute("""
            SELECT biomarker_name, value, unit, test_date
            FROM patient_biomarker_readings
            WHERE patient_id = %s
            ORDER BY biomarker_name, test_date DESC
        """, (str(patient_id),))
        return cursor.fetchall()


def assign_test_recommendations(patient_id):
    """Manually assign a few high-impact recommendations for testing."""
    db = get_db_connection()

    # Get some high-impact recs with agent_goal
    with db.cursor() as cursor:
        cursor.execute("""
            SELECT id, rec_id, title, agent_goal, raw_impact
            FROM recommendations_base
            WHERE agent_goal IS NOT NULL
              AND raw_impact IS NOT NULL
            ORDER BY raw_impact DESC
            LIMIT 8
        """)
        recs = cursor.fetchall()

    print(f"✓ Found {len(recs)} high-impact recommendations\n")
    print("Top recommendations to assign:")
    for i, rec in enumerate(recs, 1):
        print(f"{i}. {rec[2]} (impact: {rec[4]}/100)")
        print(f"   Goal: {rec[3]}\n")

    # Assign them
    assigned = []
    for rec in recs:
        rec_uuid = rec[0]
        rec_id = rec[1]

        try:
            with db.cursor() as cursor:
                cursor.execute("""
                    INSERT INTO patient_recommendations (
                        patient_id, recommendation_id, status, assigned_date, start_date
                    ) VALUES (%s, %s, 'active', CURRENT_DATE, CURRENT_DATE)
                    RETURNING id
                """, (str(patient_id), rec_uuid))

                result = cursor.fetchone()
                if result:
                    assigned.append(rec_id)
        except Exception:
            # Already exists, skip
            pass

    db.commit()
    db.close()

    print(f"✓ Assigned {len(assigned)} recommendations to patient!")
    return assigned


def main():
    patient_id = UUID('8b79ce33-02b8-4f49-8268-3204130efa82')

    print("="*70)
    print("Perfect Patient Test - Quick Setup")
    print("="*70)

    # Check biomarkers
    biomarkers = get_patient_biomarkers(patient_id)
    print(f"\n✓ Patient has {len(biomarkers)} biomarker readings")
    print("\nSample biomarkers:")
    for bio in biomarkers[:10]:
        print(f"  - {bio[0]}: {bio[1]} {bio[2]}")

    # Assign recommendations
    print("\n" + "="*70)
    print("Assigning Recommendations")
    print("="*70 + "\n")

    assigned = assign_test_recommendations(patient_id)

    print("\n" + "="*70)
    print("✓ Setup Complete!")
    print("="*70)
    print(f"\nPatient {patient_id} is ready to test!")
    print("\nNext: Test the adherence agent scoring")
    print("Run: curl -X POST http://localhost:8000/api/v1/adherence/calculate-daily \\")
    print(f'  -H "Content-Type: application/json" \\')
    print(f'  -d \'{{"patient_id": "{patient_id}"}}\'')


if __name__ == "__main__":
    main()
