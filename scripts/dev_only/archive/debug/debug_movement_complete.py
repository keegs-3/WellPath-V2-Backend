#!/usr/bin/env python3
"""Debug Movement scoring in detail."""

import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent))
sys.path.insert(0, str(Path('/Users/keegs/Documents/GitHub/preliminary_data/scripts')))

from database.postgres_client import PostgresClient
from scoring_engine.utils.data_fetcher import PatientDataFetcher

# Import preliminary_data modules
from wellpath_score_runner_survey_v2 import (
    QUESTION_CONFIG,
    PILLARS,
    pillar_map,
    movement_questions,
    score_movement_pillar,
    SLEEP_ISSUES,
)

# Test patient
PATIENT_ID = '83a28af3-82ef-4ddb-8860-ac23275a5c32'

# Connect to database
db = PostgresClient()
fetcher = PatientDataFetcher(db)

# Fetch patient data
surveys_df = fetcher.get_patient_survey_responses(PATIENT_ID)
patient_info = fetcher.get_patient_details(PATIENT_ID)

# Convert to dict
survey_dict = {}
for _, row in surveys_df.iterrows():
    survey_dict[row['question_id']] = row['response_value']

age = patient_info.get('age', 30)
sex = patient_info.get('sex', 'male')
weight_lb = patient_info.get('weight_lb', 150)

print(f"Patient: {PATIENT_ID}")
print(f"Age: {age}, Sex: {sex}, Weight: {weight_lb} lb")
print(f"Total responses: {len(survey_dict)}")
print()

# Track weighted scores per pillar
pillar_weighted = {p: 0.0 for p in PILLARS}
pillar_max = {p: 0.0 for p in PILLARS}

print("="*80)
print("MOVEMENT PILLAR SCORING BREAKDOWN")
print("="*80)

# Score movement pillar
print("\n1. Movement exercises (Cardio, Strength, Flexibility, HIIT):")
move_scores = score_movement_pillar(survey_dict, movement_questions)
for (move_type, pillar), score in move_scores.items():
    if score:
        pillar_weighted[pillar] += score
    max_weight = movement_questions[move_type]["pillar_weights"][pillar]
    pillar_max[pillar] += max_weight
    print(f"   {move_type} -> {pillar}: score={score}, max_weight={max_weight}")

print(f"\n   Subtotal Movement: {pillar_weighted['Movement']}/{pillar_max['Movement']}")

# Score other questions that contribute to Movement
print("\n2. Other questions contributing to Movement:")
for qid in ['2.11', '3.21']:
    if qid in QUESTION_CONFIG:
        config = QUESTION_CONFIG[qid]
        pillar_weights = config.get('pillar_weights', {})
        if 'Movement' in pillar_weights and pillar_weights['Movement'] > 0:
            answer = survey_dict.get(qid, "")

            # Calculate score
            if "score_fn" in config:
                from wellpath_score_runner_survey_v2 import protein_intake_score
                score = protein_intake_score(answer, weight_lb, age)
            else:
                score = config["response_scores"].get(str(answer).strip(), 0)

            # Scale to 0-1 if >1
            score_scaled = score / 10 if score is not None and score > 1 else score

            # Apply weight
            weight_for_movement = pillar_weights['Movement']
            contribution = score_scaled * weight_for_movement

            pillar_weighted['Movement'] += contribution
            pillar_max['Movement'] += weight_for_movement

            print(f"   {qid}: answer=\"{answer}\", raw_score={score}, scaled={score_scaled}, weight={weight_for_movement}, contribution={contribution}")

print(f"\n   Subtotal Movement: {pillar_weighted['Movement']}/{pillar_max['Movement']}")

# Check sleep issues (some contribute to Movement)
print("\n3. Sleep issues (Restless legs contributes to Movement):")
for issue, freq_qid, pillar_wts in SLEEP_ISSUES:
    if 'Movement' in pillar_wts and pillar_wts['Movement'] > 0:
        print(f"   {issue} ({freq_qid}): max_weight={pillar_wts['Movement']}")
        pillar_max['Movement'] += pillar_wts['Movement']

print(f"\n   Final Movement: {pillar_weighted['Movement']}/{pillar_max['Movement']}")

# Calculate percentage
pct = (pillar_weighted['Movement'] / pillar_max['Movement']) * 100
print(f"\n{'='*80}")
print(f"FINAL MOVEMENT PERCENTAGE: {pct:.2f}%")
print(f"EXPECTED: 35.53%")
print(f"DIFFERENCE: {pct - 35.53:.2f}%")
print(f"{'='*80}")
