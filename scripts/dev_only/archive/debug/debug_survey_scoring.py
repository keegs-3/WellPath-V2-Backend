#!/usr/bin/env python3
"""
Debug survey scoring by comparing API output with preliminary_data output
"""

import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent))

from database.postgres_client import PostgresClient
from scoring_engine.utils.data_fetcher import PatientDataFetcher
from scoring_engine.survey_scorer_complete import score_patient_complete

# Test patient
PATIENT_ID = '83a28af3-82ef-4ddb-8860-ac23275a5c32'

# Connect to database
db = PostgresClient()
fetcher = PatientDataFetcher(db)

# Fetch patient data
print("Fetching patient data...")
surveys_df = fetcher.get_patient_survey_responses(PATIENT_ID)
patient_info = fetcher.get_patient_details(PATIENT_ID)

print(f"\n✓ Loaded {len(surveys_df)} survey responses")
print(f"✓ Patient info: age={patient_info.get('age')}, sex={patient_info.get('sex')}, weight_lb={patient_info.get('weight_lb')}")

# Convert to dict
survey_dict = {}
for _, row in surveys_df.iterrows():
    survey_dict[row['question_id']] = row['response_value']

print(f"\n✓ Converted to dict with {len(survey_dict)} questions")

# Show first 10 responses
print("\nFirst 10 survey responses:")
for i, (q, a) in enumerate(list(survey_dict.items())[:10]):
    print(f"  {q}: {a}")

# Score using complete logic
print("\n" + "="*80)
print("SCORING")
print("="*80)

pillar_percentages = score_patient_complete(
    patient_row=survey_dict,
    age=patient_info.get('age', 30),
    sex=patient_info.get('sex', 'male'),
    weight_lb=patient_info.get('weight_lb', 150)
)

print("\nCalculated Scores:")
for pillar, pct in sorted(pillar_percentages.items()):
    print(f"  {pillar:<30} {pct:>6.2f}%")

# Load ground truth
print("\n" + "="*80)
print("GROUND TRUTH")
print("="*80)

import pandas as pd
truth_df = pd.read_csv('/Users/keegs/Documents/GitHub/preliminary_data/WellPath_Score_Survey/synthetic_patient_pillar_scores_survey_with_max_pct.csv')
truth_row = truth_df[truth_df['patient_id'] == PATIENT_ID].iloc[0]

ground_truth = {
    'Healthful Nutrition': truth_row['Healthful Nutrition_Pct'],
    'Movement + Exercise': truth_row['Movement + Exercise_Pct'],
    'Restorative Sleep': truth_row['Restorative Sleep_Pct'],
    'Cognitive Health': truth_row['Cognitive Health_Pct'],
    'Stress Management': truth_row['Stress Management_Pct'],
    'Connection + Purpose': truth_row['Connection + Purpose_Pct'],
    'Core Care': truth_row['Core Care_Pct']
}

print("\nGround Truth Scores:")
for pillar, pct in sorted(ground_truth.items()):
    print(f"  {pillar:<30} {pct:>6.2f}%")

# Compare
print("\n" + "="*80)
print("COMPARISON")
print("="*80)
print(f"{'Pillar':<30} {'Calculated':>12} {'Ground Truth':>12} {'Diff':>8}")
print("-" * 80)

for pillar in sorted(ground_truth.keys()):
    calc = pillar_percentages.get(pillar, 0.0)
    truth = ground_truth.get(pillar, 0.0)
    diff = calc - truth
    status = "✓" if abs(diff) <= 1.0 else "✗"
    print(f"{pillar:<30} {calc:>11.2f}% {truth:>11.2f}% {diff:>7.2f}% {status}")
