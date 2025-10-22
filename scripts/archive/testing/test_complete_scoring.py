#!/usr/bin/env python3
"""Test complete WellPath scoring with all components"""

import sys
sys.path.insert(0, '/Users/keegs/Documents/GitHub/WellPath-V2-Backend')

from scoring_engine.scoring_service import WellPathScoringService
from database.postgres_client import PostgresClient

# Initialize
db = PostgresClient()
scoring_service = WellPathScoringService(db)

# Test patient with survey responses
patient_id = '83a28af3-82ef-4ddb-8860-ac23275a5c32'

print(f"Testing complete WellPath scoring for patient {patient_id}")
print("=" * 70)

# Calculate complete score
result = scoring_service.calculate_patient_scores(patient_id)

print(f"\n🎯 Overall WellPath Score: {result.get('overall_score', 0):.2f}")
print("\n📊 Pillar Breakdown (Weighted Combined Scores):")
print("-" * 70)

# Get component details
biomarker_details = result.get('biomarker_details', {})
survey_details = result.get('survey_details', {})
pillar_scores = result.get('pillar_scores', {})

# Get actual weights from scoring service
WEIGHTS = scoring_service.PILLAR_WEIGHTS

for pillar_name, final_score in pillar_scores.items():
    # Get raw component scores
    marker_pct = biomarker_details.get('pillar_scores', {}).get(pillar_name, {}).get('percentage', 0)
    survey_pct = survey_details.get('pillar_scores', {}).get(pillar_name, {}).get('percentage', 0)
    education_pct = 70  # Hardcoded placeholder

    # Get weights
    weights = WEIGHTS.get(pillar_name, {'markers': 0.5, 'survey': 0.4, 'education': 0.1})

    # Calculate contributions
    marker_contrib = marker_pct * weights['markers']
    survey_contrib = survey_pct * weights['survey']
    education_contrib = education_pct * weights['education']

    print(f"\n{pillar_name}:")
    print(f"  Final Score:      {final_score:.2f}")
    print(f"  Components (raw → weighted):")
    print(f"    - Biomarkers:   {marker_pct:5.1f}% × {weights['markers']:.0%} = {marker_contrib:5.2f}")
    print(f"    - Survey:       {survey_pct:5.1f}% × {weights['survey']:.0%} = {survey_contrib:5.2f}")
    print(f"    - Education:    {education_pct:5.1f}% × {weights['education']:.0%} = {education_contrib:5.2f}")

print("\n" + "=" * 70)
print("✅ Complete scoring test finished!")
