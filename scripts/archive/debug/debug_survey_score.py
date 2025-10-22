#!/usr/bin/env python3
"""
Debug survey scoring for patient 0cc07ac6-5344-4e0a-a52b-a0ded20ccdd7
Compare ground truth CSV scoring vs API scoring
"""

import pandas as pd
import sys
sys.path.insert(0, 'scripts')

# Load CSVs
patient_survey = pd.read_csv("data/synthetic_patient_survey.csv")
biomarker_df = pd.read_csv("data/dummy_lab_results_full.csv")

# Get patient
patient_id = '0cc07ac6-5344-4e0a-a52b-a0ded20ccdd7'
patient_row = patient_survey[patient_survey['patient_id'] == patient_id].iloc[0]
profile = biomarker_df[biomarker_df['patient_id'] == patient_id].iloc[0]

weight_lb = profile['weight_lb']
age = profile['age']
sex = profile.get('sex', 'male')

print(f"Patient: {patient_id}")
print(f"Age: {age}, Sex: {sex}, Weight: {weight_lb}lb")
print()

# Import scoring functions
from wellpath_score_runner_survey_v2 import (
    FREQ_SCORES, DUR_SCORES, movement_questions, score_movement_pillar
)

# Score movement pillar
move_scores = score_movement_pillar(patient_row, movement_questions)

print("Movement Pillar Scores:")
total_movement = 0
for (move_type, pillar), score in move_scores.items():
    print(f"  {move_type} ({pillar}): {score:.2f}")
    total_movement += score

print(f"\nTotal Movement Score: {total_movement:.2f}")
