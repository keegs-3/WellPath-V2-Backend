#!/usr/bin/env python3
"""
Standalone Survey Scoring Validation Script

This script:
1. Loads survey data from preliminary_data CSV
2. Runs preliminary_data scoring script directly (ground truth)
3. Runs WellPath V2 Backend SurveyScorer (our implementation)
4. Compares the two outputs and reports discrepancies

This allows us to validate the custom scoring logic is working correctly
before integrating into the full API.
"""

import sys
import pandas as pd
from pathlib import Path
import subprocess
import json

# Add parent directory to path to import scoring_engine
sys.path.insert(0, str(Path(__file__).parent.parent))

# Paths
PRELIMINARY_DATA_DIR = Path('/Users/keegs/Documents/GitHub/preliminary_data')
SURVEY_CSV = PRELIMINARY_DATA_DIR / 'data' / 'synthetic_patient_survey.csv'
BIOMARKER_CSV = PRELIMINARY_DATA_DIR / 'data' / 'dummy_lab_results_full.csv'
GROUND_TRUTH_CSV = PRELIMINARY_DATA_DIR / 'WellPath_Score_Survey' / 'synthetic_patient_pillar_scores_survey_with_max_pct.csv'

# Test patient ID
TEST_PATIENT_ID = '83a28af3-82ef-4ddb-8860-ac23275a5c32'


def load_ground_truth(patient_id: str):
    """Load expected scores from preliminary_data output."""
    print(f"Loading ground truth scores from preliminary_data output...")

    truth_df = pd.read_csv(GROUND_TRUTH_CSV)
    patient_truth = truth_df[truth_df['patient_id'] == patient_id]

    if len(patient_truth) == 0:
        raise ValueError(f"Patient {patient_id} not found in ground truth")

    truth_row = patient_truth.iloc[0].to_dict()

    # Extract pillar scores (columns ending with _Pct)
    pillar_scores = {}
    pillar_names = [
        'Healthful Nutrition',
        'Movement + Exercise',
        'Restorative Sleep',
        'Cognitive Health',
        'Stress Management',
        'Connection + Purpose',
        'Core Care'
    ]

    for pillar_name in pillar_names:
        pct_col = f"{pillar_name}_Pct"
        if pct_col in truth_row:
            pillar_scores[pillar_name] = float(truth_row[pct_col])

    print(f"✓ Loaded ground truth for {len(pillar_scores)} pillars")
    return pillar_scores


def test_api_scoring(patient_id: str):
    """
    Test scoring via the FastAPI endpoint.
    This requires the API to be running.
    """
    print(f"\nTesting API scoring for patient {patient_id}...")

    try:
        import requests
        response = requests.post(
            f"http://localhost:8000/api/v1/scores/calculate",
            json={"patient_id": patient_id}
        )

        if response.status_code != 200:
            print(f"  ⚠️  API returned status {response.status_code}")
            print(f"  Response: {response.text}")
            return None

        data = response.json()

        # Extract survey pillar scores from API response
        pillar_scores = {}

        # We want survey_details, not the combined pillar_scores
        if 'survey_details' in data and 'pillar_scores' in data['survey_details']:
            for pillar, scores in data['survey_details']['pillar_scores'].items():
                if 'percentage' in scores:
                    pillar_scores[pillar] = float(scores['percentage'])

        # Fallback: check for pillar_scores in the response
        elif 'pillar_scores' in data:
            for pillar_obj in data['pillar_scores']:
                pillar_name = pillar_obj.get('pillar_name')
                percentage = pillar_obj.get('percentage', 0)
                if pillar_name:
                    pillar_scores[pillar_name] = float(percentage)

        # Also check for survey_scores structure
        elif 'survey_scores' in data and 'pillar_scores' in data['survey_scores']:
            for pillar, scores in data['survey_scores']['pillar_scores'].items():
                if 'percentage' in scores:
                    pillar_scores[pillar] = float(scores['percentage'])

        print(f"✓ Retrieved API scores for {len(pillar_scores)} pillars")
        if not pillar_scores:
            print(f"  Response structure: {list(data.keys())}")

        return pillar_scores

    except ImportError:
        print("  ⚠️  requests library not installed, skipping API test")
        return None
    except Exception as e:
        print(f"  ⚠️  API test failed: {e}")
        import traceback
        traceback.print_exc()
        return None


def compare_scores(calculated: dict, ground_truth: dict, tolerance: float = 1.0):
    """Compare calculated scores with ground truth."""
    print(f"\n{'='*80}")
    print("SCORE COMPARISON")
    print(f"{'='*80}")
    print(f"{'Pillar':<30} {'Calculated':<15} {'Ground Truth':<15} {'Diff':<10} {'Status'}")
    print(f"{'-'*80}")

    all_match = True
    max_diff = 0.0

    for pillar in sorted(ground_truth.keys()):
        calc_score = calculated.get(pillar, 0.0)
        truth_score = ground_truth.get(pillar, 0.0)
        diff = abs(calc_score - truth_score)
        max_diff = max(max_diff, diff)

        status = "✓ MATCH" if diff <= tolerance else "✗ MISMATCH"
        if diff > tolerance:
            all_match = False

        print(f"{pillar:<30} {calc_score:<15.2f} {truth_score:<15.2f} {diff:<10.2f} {status}")

    print(f"{'-'*80}")
    print(f"Maximum difference: {max_diff:.2f}%")

    if all_match:
        print(f"\n✅ All scores match within tolerance ({tolerance}%)")
    else:
        print(f"\n❌ Some scores differ by more than tolerance ({tolerance}%)")

    return all_match


def main():
    """Main validation function."""
    print("="*80)
    print("SURVEY SCORING VALIDATION")
    print("="*80)

    try:
        # Load ground truth from preliminary_data
        ground_truth = load_ground_truth(TEST_PATIENT_ID)

        print("\n" + "="*80)
        print("GROUND TRUTH (from preliminary_data)")
        print("="*80)
        for pillar, score in sorted(ground_truth.items()):
            print(f"  {pillar:<30} {score:>6.2f}%")

        # Test API scoring
        api_scores = test_api_scoring(TEST_PATIENT_ID)

        if api_scores:
            print("\n" + "="*80)
            print("API SCORES (from WellPath V2 Backend)")
            print("="*80)
            for pillar, score in sorted(api_scores.items()):
                print(f"  {pillar:<30} {score:>6.2f}%")

            # Compare scores
            matches = compare_scores(api_scores, ground_truth, tolerance=1.0)

            if matches:
                print("\n✅ VALIDATION PASSED: Survey scoring matches preliminary_data output")
                return 0
            else:
                print("\n❌ VALIDATION FAILED: Survey scoring differs from preliminary_data output")
                print("\nNext Steps:")
                print("1. Review the custom scoring functions in survey_scorer.py")
                print("2. Ensure QUESTION_CONFIG is properly loaded")
                print("3. Check that all custom scoring functions are being called")
                return 1
        else:
            print("\n⚠️  Could not test API scoring")
            print("Please ensure the API is running: uvicorn api.main:app --reload --port 8000")
            return 2

    except Exception as e:
        print(f"\n❌ ERROR: {e}")
        import traceback
        traceback.print_exc()
        return 1


if __name__ == "__main__":
    sys.exit(main())
