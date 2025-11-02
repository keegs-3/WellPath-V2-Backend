"""
Match and assign recommendations to a patient using AI.
"""

import sys
import os
from uuid import UUID
from datetime import date

sys.path.insert(0, '/Users/keegs/Documents/WellPath/wellpath-v2-backend')

from dotenv import load_dotenv
load_dotenv('/Users/keegs/Documents/WellPath/wellpath-v2-backend/.env')

from services.adherence_agent.recommendation_matcher import RecommendationMatcher


async def main(patient_id_str: str):
    """Match and assign recommendations."""
    patient_id = UUID(patient_id_str)

    print("="*70)
    print(f"AI Recommendation Matching for Patient {patient_id}")
    print("="*70)

    matcher = RecommendationMatcher()

    # Match recommendations
    print("\n🤖 Using AI to analyze patient and match recommendations...\n")
    matches = await matcher.match_recommendations_for_patient(
        patient_id=patient_id,
        max_recommendations=12,
        difficulty_preference="progressive"
    )

    if not matches:
        print("❌ No matches returned by AI")
        return

    print(f"✓ AI recommended {len(matches)} recommendations:\n")

    for i, match in enumerate(matches, 1):
        print(f"{i}. {match.get('rec_id', 'UNKNOWN')}")
        print(f"   Priority: {match.get('priority', 'N/A')}")
        print(f"   Reasoning: {match.get('reasoning', 'No reasoning provided')}")
        if match.get('target_biomarkers'):
            print(f"   Targets: {', '.join(match['target_biomarkers'])}")
        print()

    # Ask to assign
    print("="*70)
    response = input(f"Assign these {len(matches)} recommendations to patient? (y/n): ")

    if response.lower() == 'y':
        rec_ids = [m['rec_id'] for m in matches]
        assigned = await matcher.assign_recommendations_to_patient(
            patient_id=patient_id,
            recommendation_ids=rec_ids,
            start_date=date.today()
        )

        print(f"\n✓ Assigned {len(assigned)} recommendations to patient!")
        print("\nReady to run agent scoring! 🚀")
    else:
        print("\nNo recommendations assigned.")


if __name__ == "__main__":
    import asyncio

    if len(sys.argv) < 2:
        print("Usage: python match_and_assign.py <patient-uuid>")
        sys.exit(1)

    asyncio.run(main(sys.argv[1]))
