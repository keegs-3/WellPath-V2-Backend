"""
Test script for Agentic Adherence System

Run this to validate the system end-to-end.
"""

import asyncio
import sys
from datetime import date
from uuid import UUID

# Add parent directory to path
sys.path.insert(0, '/Users/keegs/Documents/WellPath/wellpath-v2-backend')

from services.adherence_agent.agent import AdherenceAgent
from services.adherence_agent.nudge_generator import NudgeGenerator
from services.adherence_agent.challenge_creator import ChallengeCreator
from services.adherence_agent.context_builder import ContextBuilder


async def test_context_builder(patient_id: UUID):
    """Test context building."""
    print("\n" + "="*60)
    print("TESTING: Context Builder")
    print("="*60)

    builder = ContextBuilder()
    context = await builder.build_full_context(patient_id, date.today())

    print(f"\n✓ Built context for patient {patient_id}")
    print(f"  - Biomarkers: {context['biomarkers']['reading_count']}")
    print(f"  - Active Recommendations: {context['recommendations']['count']}")
    print(f"  - Active Modes: {len(context['active_modes'])}")

    if context['recent_adherence'].get('has_history'):
        print(f"  - Recent Adherence: {context['recent_adherence']['avg_last_7_days']}%")

    if context['biomarkers']['out_of_range']:
        print(f"  - Out of Range Biomarkers: {len(context['biomarkers']['out_of_range'])}")

    return context


async def test_adherence_agent(patient_id: UUID):
    """Test daily scoring."""
    print("\n" + "="*60)
    print("TESTING: Adherence Agent (Daily Scoring)")
    print("="*60)

    agent = AdherenceAgent()
    result = await agent.calculate_daily_scores(
        patient_id=patient_id,
        score_date=date.today()
    )

    print(f"\n✓ Calculated daily scores for patient {patient_id}")
    print(f"  - Overall Score: {result['overall_score']['adherence_percentage']}%")
    print(f"  - Active Recommendations: {result['overall_score']['active_recommendations']}")
    print(f"  - Recommendations Scored: {result['overall_score']['recommendations_scored']}")
    print(f"  - Execution Time: {result['execution_time_seconds']:.2f}s")

    print(f"\n  Pillar Breakdown:")
    for pillar in result['pillar_scores']:
        print(f"    - {pillar['pillar']}: {pillar['adherence_percentage']}%")

    print(f"\n  Recommendation Scores:")
    for rec in result['recommendation_scores'][:5]:  # Show first 5
        print(f"    - {rec['recommendation_title']}: {rec['adherence_percentage']}%")

    return result


async def test_nudge_generator(patient_id: UUID):
    """Test nudge generation."""
    print("\n" + "="*60)
    print("TESTING: Nudge Generator")
    print("="*60)

    generator = NudgeGenerator()
    nudges = await generator.generate_nudges_for_patient(
        patient_id=patient_id,
        max_nudges=2
    )

    print(f"\n✓ Generated {len(nudges)} nudges for patient {patient_id}")

    for i, nudge in enumerate(nudges, 1):
        print(f"\n  Nudge {i}:")
        print(f"    Title: {nudge['title']}")
        print(f"    Message: {nudge['message']}")
        print(f"    Tone: {nudge['tone']}")
        print(f"    Type: {nudge['nudge_type']}")

    return nudges


async def test_challenge_creator(patient_id: UUID):
    """Test challenge creation."""
    print("\n" + "="*60)
    print("TESTING: Challenge Creator")
    print("="*60)

    creator = ChallengeCreator()
    challenge = await creator.create_challenge_for_patient(patient_id=patient_id)

    if challenge:
        print(f"\n✓ Created challenge for patient {patient_id}")
        print(f"  Title: {challenge['challenge_title']}")
        print(f"  Description: {challenge['challenge_description']}")
        print(f"  Goal: {challenge['challenge_goal']}")
        print(f"  Difficulty: {challenge['difficulty_level']}/3")
        print(f"  Duration: {challenge['duration_days']} days")
    else:
        print(f"\n⚠ No challenge created (no appropriate opportunity)")

    return challenge


async def main():
    """Run all tests."""
    print("\n" + "="*60)
    print("WellPath Agentic Adherence System - Test Suite")
    print("="*60)

    # Get patient ID from command line or use default
    if len(sys.argv) > 1:
        patient_id = UUID(sys.argv[1])
    else:
        # Use a test patient ID - replace with actual patient from your database
        print("\nUsage: python test_agent_system.py <patient-uuid>")
        print("Using default test patient ID...")
        patient_id = UUID("00000000-0000-0000-0000-000000000001")

    print(f"\nTesting with Patient ID: {patient_id}")

    try:
        # Run tests
        context = await test_context_builder(patient_id)
        scores = await test_adherence_agent(patient_id)
        nudges = await test_nudge_generator(patient_id)
        challenge = await test_challenge_creator(patient_id)

        # Summary
        print("\n" + "="*60)
        print("TEST SUMMARY")
        print("="*60)
        print(f"✓ Context Builder: SUCCESS")
        print(f"✓ Adherence Agent: SUCCESS")
        print(f"✓ Nudge Generator: SUCCESS ({len(nudges)} nudges)")
        print(f"✓ Challenge Creator: {'SUCCESS' if challenge else 'NO OPPORTUNITY'}")
        print("\nAll systems operational! 🚀")

    except Exception as e:
        print(f"\n❌ ERROR: {str(e)}")
        import traceback
        traceback.print_exc()
        sys.exit(1)


if __name__ == "__main__":
    asyncio.run(main())
