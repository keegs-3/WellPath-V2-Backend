#!/usr/bin/env python3
"""
Quick test script to debug why API isn't fetching survey responses.
"""

import sys
import os

# Add current directory to path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from database.postgres_client import PostgresClient
from scoring_engine.utils.data_fetcher import PatientDataFetcher
from scoring_engine.survey_scorer import SurveyScorer

# Test patient ID
PATIENT_ID = '0cc07ac6-5344-4e0a-a52b-a0ded20ccdd7'

print("=" * 80)
print("TESTING SURVEY DATA FETCH")
print("=" * 80)

# 1. Test database connection
print("\n1. Testing database connection...")
try:
    db = PostgresClient()
    print("✓ PostgresClient initialized successfully")
    print(f"   DATABASE_URL: {db.connection_string[:50]}...")
except Exception as e:
    print(f"✗ Failed to initialize PostgresClient: {e}")
    sys.exit(1)

# 2. Test data fetcher
print("\n2. Testing PatientDataFetcher...")
try:
    data_fetcher = PatientDataFetcher(db)
    print("✓ PatientDataFetcher initialized successfully")
except Exception as e:
    print(f"✗ Failed to initialize PatientDataFetcher: {e}")
    sys.exit(1)

# 3. Fetch survey responses
print(f"\n3. Fetching survey responses for patient {PATIENT_ID}...")
try:
    surveys_df = data_fetcher.get_patient_survey_responses(PATIENT_ID)
    print(f"✓ Fetched {len(surveys_df)} survey responses")

    if len(surveys_df) > 0:
        print(f"\n   First 5 responses:")
        print(surveys_df.head(5).to_string())
        print(f"\n   DataFrame columns: {list(surveys_df.columns)}")
        print(f"   DataFrame shape: {surveys_df.shape}")
    else:
        print("   ⚠️  No survey responses found!")

except Exception as e:
    print(f"✗ Failed to fetch survey responses: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)

# 4. Get patient details
print(f"\n4. Fetching patient details...")
try:
    patient_info = data_fetcher.get_patient_details(PATIENT_ID)
    print(f"✓ Patient info: {patient_info}")
except Exception as e:
    print(f"✗ Failed to fetch patient details: {e}")
    import traceback
    traceback.print_exc()

# 5. Test survey scorer
print(f"\n5. Testing SurveyScorer...")
try:
    survey_scorer = SurveyScorer()
    print("✓ SurveyScorer initialized successfully")

    # Try to score the surveys
    print(f"\n6. Scoring surveys...")
    survey_results = survey_scorer.score_patient_surveys(surveys_df, patient_info)

    print(f"✓ Survey scoring complete!")
    print(f"\n   Pillar scores:")
    for pillar, scores in survey_results.get('pillar_scores', {}).items():
        print(f"   - {pillar}: {scores}")

    print(f"\n   Total questions fetched: {len(survey_results.get('question_details', []))}")

except Exception as e:
    print(f"✗ Failed to score surveys: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)

print("\n" + "=" * 80)
print("TEST COMPLETE")
print("=" * 80)
