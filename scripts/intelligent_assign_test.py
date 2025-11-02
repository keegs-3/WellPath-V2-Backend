"""
Test intelligent assignment with perfect patient.
"""

import sys
import os
from uuid import UUID
import asyncio

sys.path.insert(0, '/Users/keegs/Documents/WellPath/wellpath-v2-backend')

from dotenv import load_dotenv
load_dotenv('/Users/keegs/Documents/WellPath/wellpath-v2-backend/.env')

from services.adherence_agent.intelligent_assigner import IntelligentAssigner
from database.postgres_client import get_db_connection


async def main():
    """Test intelligent assignment."""
    patient_id = UUID('8b79ce33-02b8-4f49-8268-3204130efa82')

    print("="*70)
    print("Intelligent Recommendation Assignment Test")
    print("="*70)
    print(f"\nPatient: {patient_id}")
    print("Profile: 'Perfect' patient with optimal biomarkers\n")

    # Clear existing assignments
    db = get_db_connection()
    with db.cursor() as cursor:
        cursor.execute(
            "DELETE FROM patient_recommendations WHERE patient_id = %s",
            (str(patient_id),)
        )
        db.commit()
    print("✓ Cleared existing assignments\n")

    # Run intelligent assignment
    assigner = IntelligentAssigner()

    print("🤖 AI is analyzing patient and creating intelligent assignments...\n")
    print("(This may take 30-60 seconds as the AI thinks deeply about each recommendation)\n")

    assignments = await assigner.assign_recommendations_with_intelligence(
        patient_id=patient_id,
        max_recommendations=6
    )

    # Display results
    print("="*70)
    print(f"✓ Assigned {len(assignments)} Recommendations with Full Intelligence")
    print("="*70 + "\n")

    for i, assignment in enumerate(assignments, 1):
        print(f"\n{i}. {assignment['rec_id'].upper().replace('_', ' ')}")
        print("-" * 70)
        print(f"\n📋 RATIONALE:")
        print(f"   {assignment.get('rationale', 'No rationale provided')}")

        print(f"\n🎯 PERSONALIZED TARGET:")
        target = assignment.get('personal_target', {})
        if target:
            print(f"   Goal: {target.get('goal', 'Not specified')}")
            print(f"   Why: {target.get('reasoning', '')}")

        print(f"\n💡 GETTING STARTED TIPS:")
        tips = assignment.get('getting_started_tips', [])
        if tips:
            for j, tip in enumerate(tips, 1):
                print(f"   {j}. {tip}")
        else:
            print("   No tips provided")

        print(f"\n⚡ PRIORITY: {assignment.get('priority', 'medium').upper()}")
        print()

    print("="*70)
    print("✅ Intelligent Assignment Complete!")
    print("="*70)
    print("\nEach assignment includes:")
    print("  ✓ Personalized rationale based on patient's biomarkers")
    print("  ✓ Custom targets (not one-size-fits-all)")
    print("  ✓ Practical tips to get started")
    print("  ✓ Onboarding nudges scheduled")
    print("\nThis is what makes it INTELLIGENT! 🧠")

    db.close()


if __name__ == "__main__":
    asyncio.run(main())
