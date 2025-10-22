#!/usr/bin/env python3
"""
Debug the differences in Healthful Nutrition and Movement + Exercise scoring
"""

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
    protein_intake_score,
    calorie_intake_score,
    score_movement_pillar,
    movement_questions,
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

# Debug Healthful Nutrition questions
print("=" * 80)
print("HEALTHFUL NUTRITION DEBUG")
print("=" * 80)

nutrition_questions = {
    '2.11': 'Weight (kg)',
    '2.12': 'Height (cm)',
    '2.01': 'Daily calorie intake',
    '2.02': 'Protein servings breakfast',
    '2.03': 'Protein servings lunch',
    '2.04': 'Protein servings dinner',
}

print("\nKey nutrition responses:")
for qid, desc in nutrition_questions.items():
    answer = survey_dict.get(qid, 'N/A')
    print(f"  {qid} ({desc}): {answer}")

# Check if protein/calorie questions use custom scoring
print("\nCustom scoring functions:")
for qid in ['2.01', '2.02', '2.03', '2.04', '2.11', '2.12']:
    if qid in QUESTION_CONFIG:
        config = QUESTION_CONFIG[qid]
        if 'score_fn' in config:
            print(f"  {qid}: Has custom score_fn = {config['score_fn'].__name__}")
        else:
            print(f"  {qid}: Uses response_scores")

# Test protein scoring
print("\nTesting protein_intake_score:")
if '2.02' in survey_dict:
    breakfast_protein = survey_dict['2.02']
    print(f"  Breakfast protein answer: {breakfast_protein}")
    try:
        score = protein_intake_score(breakfast_protein, weight_lb, age, sex)
        print(f"  Score: {score}")
    except Exception as e:
        print(f"  Error: {e}")

# Test calorie scoring
print("\nTesting calorie_intake_score:")
if '2.01' in survey_dict:
    calorie_answer = survey_dict['2.01']
    print(f"  Calorie answer: {calorie_answer}")
    try:
        score = calorie_intake_score(calorie_answer, weight_lb, age, sex)
        print(f"  Score: {score}")
    except Exception as e:
        print(f"  Error: {e}")

# Debug Movement questions
print("\n" + "=" * 80)
print("MOVEMENT + EXERCISE DEBUG")
print("=" * 80)

movement_question_ids = {
    '3.01': 'Steps per day',
    '3.02': 'Cardio frequency',
    '3.03': 'Cardio duration',
    '3.04': 'Strength training frequency',
    '3.05': 'Strength training duration',
    '3.06': 'HIIT frequency',
    '3.07': 'HIIT duration',
    '3.08': 'Mobility frequency',
    '3.09': 'Mobility duration',
}

print("\nKey movement responses:")
for qid, desc in movement_question_ids.items():
    answer = survey_dict.get(qid, 'N/A')
    print(f"  {qid} ({desc}): {answer}")

# Test movement scoring
print("\nTesting score_movement_pillar:")
print(f"  movement_questions keys: {list(movement_questions.keys())}")
try:
    move_scores = score_movement_pillar(survey_dict, movement_questions)
    print(f"\nMovement scores returned:")
    for (move_type, pillar), score in move_scores.items():
        print(f"    {move_type} -> {pillar}: {score}")
except Exception as e:
    print(f"  Error: {e}")
    import traceback
    traceback.print_exc()

db.close()
