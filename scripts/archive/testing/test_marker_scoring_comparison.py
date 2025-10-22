#!/usr/bin/env python3
"""
Compare marker scoring between CSV runner and database-driven scorer.
This will help identify any discrepancies in the scoring logic.
"""

import sys
import pandas as pd
from pathlib import Path

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).parent))

from scoring_engine.biomarker_scorer import BiomarkerScorer

# Load ground truth data
gt_file = Path(__file__).parent.parent / "preliminary_data" / "WellPath_Score_Markers" / "marker_pillar_summary.csv"
lab_file = Path(__file__).parent.parent / "preliminary_data" / "data" / "dummy_lab_results_full.csv"

print(f"Loading ground truth from: {gt_file}")
print(f"Loading lab data from: {lab_file}")

gt_df = pd.read_csv(gt_file)
lab_df = pd.read_csv(lab_file)

# Test patient
test_patient_id = "83a28af3-82ef-4ddb-8860-ac23275a5c32"

# Get ground truth scores
gt_row = gt_df[gt_df['patient_id'] == test_patient_id].iloc[0]
print(f"\nGround Truth for patient {test_patient_id}:")
print(f"  Healthful Nutrition: {gt_row['Healthful Nutrition_Total']:.2f} / {gt_row['Healthful Nutrition_Max']:.2f} = {gt_row['Healthful Nutrition_Pct']:.2f}%")
print(f"  Core Care: {gt_row['Core Care_Total']:.2f} / {gt_row['Core Care_Max']:.2f} = {gt_row['Core Care_Pct']:.2f}%")

# Get lab values for this patient
lab_row = lab_df[lab_df['patient_id'] == test_patient_id].iloc[0]

# Create patient info
patient_info = {
    'age': lab_row.get('age', 0),
    'sex': lab_row.get('sex', '').lower()
}

print(f"\nPatient info: age={patient_info['age']}, sex={patient_info['sex']}")

# Extract biomarker values (skip metadata columns)
metadata_cols = ['patient_id', 'sex', 'age', 'menopausal_status', 'cycle_phase', 'unique_condition', 'phenoage', 'dnam_phenoage']
biomarkers = {}
for col in lab_row.index:
    if col not in metadata_cols and pd.notna(lab_row[col]):
        biomarkers[col] = lab_row[col]

print(f"\nFound {len(biomarkers)} biomarker values")

# Score using database-driven scorer
scorer = BiomarkerScorer()
result = scorer.score_patient_biomarkers(biomarkers, patient_info)

print(f"\nDatabase Scorer Results:")
pillar_scores = result['pillar_scores']
for pillar, scores in pillar_scores.items():
    if pillar == 'Healthful Nutrition' or pillar == 'Core Care':
        print(f"  {pillar}: {scores['total_weighted_score']:.2f} / {scores['max_score']:.2f} = {scores['percentage']:.2f}%")

# Compare
print("\nComparison:")
print(f"  Healthful Nutrition:")
print(f"    GT:  {gt_row['Healthful Nutrition_Total']:.2f} / {gt_row['Healthful Nutrition_Max']:.2f}")
api_hn = pillar_scores.get('Healthful Nutrition', {})
print(f"    API: {api_hn.get('total_weighted_score', 0):.2f} / {api_hn.get('max_score', 0):.2f}")
print(f"    Diff: {abs(gt_row['Healthful Nutrition_Total'] - api_hn.get('total_weighted_score', 0)):.2f}")

print(f"\n  Core Care:")
print(f"    GT:  {gt_row['Core Care_Total']:.2f} / {gt_row['Core Care_Max']:.2f}")
api_cc = pillar_scores.get('Core Care', {})
print(f"    API: {api_cc.get('total_weighted_score', 0):.2f} / {api_cc.get('max_score', 0):.2f}")
print(f"    Diff: {abs(gt_row['Core Care_Total'] - api_cc.get('total_weighted_score', 0)):.2f}")

# Show first 5 marker scores for debugging
print("\nFirst 5 markers scored:")
for i, detail in enumerate(result.get('marker_details', [])[:5]):
    print(f"  {detail['marker']}: {detail['value']} -> score={detail['score']:.3f}, range={detail['range_label']}")
