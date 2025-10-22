#!/usr/bin/env python3
"""Test survey scoring implementation"""

import sys
sys.path.insert(0, '/Users/keegs/Documents/GitHub/WellPath-V2-Backend')

from scoring_engine.utils.data_fetcher import PatientDataFetcher
from scoring_engine.survey_scorer import SurveyScorer
from database.postgres_client import PostgresClient

# Initialize
db = PostgresClient()
fetcher = PatientDataFetcher(db)
survey_scorer = SurveyScorer()

# Test patient with survey responses
patient_id = '83a28af3-82ef-4ddb-8860-ac23275a5c32'

print(f"Testing survey scoring for patient {patient_id}")
print("=" * 60)

# Get survey data
survey_df = fetcher.get_patient_survey_responses(patient_id)
print(f'\n✓ Survey responses: {len(survey_df)} rows')

# Get patient info for scoring context
patient_info = fetcher.get_patient_details(patient_id)
print(f'✓ Patient info: age={patient_info.get("age")}, sex={patient_info.get("sex")}, weight={patient_info.get("weight_lb")} lb')

# Score surveys
print(f'\n🔄 Scoring surveys...')
result = survey_scorer.score_patient_surveys(survey_df, patient_info)

# Show results
print(f'\n📊 Pillar Scores:')
print("-" * 60)
for pillar, data in result['pillar_scores'].items():
    print(f'  {pillar:25s}: {data["percentage"]:6.2f}%  ({data["total_score"]:.2f}/{data["max_score"]:.2f})')

print("\n✅ Survey scoring test complete!")
