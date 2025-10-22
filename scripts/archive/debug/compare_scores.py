"""Compare API scores with ground truth."""

import json
import requests

# Ground truth from breakdown file
ground_truth = {
    "overall": 59.4,
    "pillars": {
        "Healthful Nutrition": {
            "total": 62.5,
            "markers": {"raw": 161.30, "max": 258.0, "norm": 62.5, "contribution": 45.0},
            "survey": {"raw": 80.50, "max": 83.0, "norm": 97.0, "contribution": 17.5}
        },
        "Movement + Exercise": {
            "total": 54.9,
            "markers": {"raw": 83.58, "max": 130.0, "norm": 64.3, "contribution": 34.7},
            "survey": {"raw": 42.60, "max": 76.0, "norm": 56.1, "contribution": 20.2}
        },
        "Restorative Sleep": {
            "total": 54.0,
            "markers": {"raw": 47.82, "max": 98.0, "norm": 48.8, "contribution": 30.7},
            "survey": {"raw": 56.20, "max": 73.0, "norm": 77.0, "contribution": 20.8}
        },
        "Cognitive Health": {
            "total": 57.4,
            "markers": {"raw": 74.80, "max": 139.0, "norm": 53.8, "contribution": 19.4},
            "survey": {"raw": 27.60, "max": 42.0, "norm": 65.7, "contribution": 35.5}
        },
        "Stress Management": {
            "total": 77.1,
            "markers": {"raw": 78.77, "max": 140.0, "norm": 56.3, "contribution": 15.2},
            "survey": {"raw": 57.00, "max": 66.0, "norm": 86.4, "contribution": 54.4}
        },
        "Connection + Purpose": {
            "total": 31.1,
            "markers": {"raw": 1.06, "max": 10.0, "norm": 10.6, "contribution": 1.9},
            "survey": {"raw": 16.20, "max": 40.0, "norm": 40.5, "contribution": 29.2}
        },
        "Core Care": {
            "total": 79.1,
            "markers": {"raw": 87.24, "max": 137.0, "norm": 63.7, "contribution": 31.5},
            "survey": {"raw": 357.30, "max": 385.0, "norm": 92.8, "contribution": 37.6}
        }
    }
}

# Get API scores
patient_id = "1a8a56a1-360f-456c-837f-34201b13d445"
response = requests.get(f"http://localhost:8000/api/v1/scores/patient/{patient_id}?include_breakdown=true")
api_data = response.json()

print("=" * 100)
print("SCORE COMPARISON: API vs Ground Truth")
print("=" * 100)

print(f"\n{'OVERALL':<30} API: {api_data['overall_score']:6.2f}%  |  GT: {ground_truth['overall']:6.2f}%  |  Diff: {api_data['overall_score'] - ground_truth['overall']:+6.2f}%")

print("\n" + "=" * 100)
print(f"{'PILLAR':<30} {'API Total':>10} {'GT Total':>10} {'Diff':>8} | {'API M%':>8} {'GT M%':>8} | {'API S%':>8} {'GT S%':>8}")
print("=" * 100)

for pillar_name in ground_truth['pillars'].keys():
    api_pillar = api_data['breakdown'][pillar_name]
    gt_pillar = ground_truth['pillars'][pillar_name]

    api_total = api_pillar['total_score']
    gt_total = gt_pillar['total']
    diff = api_total - gt_total

    api_marker_norm = api_pillar['components']['biomarker']['normalized']
    gt_marker_norm = gt_pillar['markers']['norm']

    api_survey_norm = api_pillar['components']['survey']['normalized']
    gt_survey_norm = gt_pillar['survey']['norm']

    print(f"{pillar_name:<30} {api_total:>10.2f} {gt_total:>10.2f} {diff:>+8.2f} | {api_marker_norm:>8.2f} {gt_marker_norm:>8.2f} | {api_survey_norm:>8.2f} {gt_survey_norm:>8.2f}")

print("\n" + "=" * 100)
print("DETAILED BREAKDOWN: Connection + Purpose (largest discrepancy)")
print("=" * 100)

conn_api = api_data['breakdown']['Connection + Purpose']
conn_gt = ground_truth['pillars']['Connection + Purpose']

print(f"\nMarkers:")
print(f"  API:  raw={conn_api['components']['biomarker']['raw_score']:6.2f} / max={conn_api['components']['biomarker']['max_score']:6.2f} = {conn_api['components']['biomarker']['normalized']:5.2f}%")
print(f"  GT:   raw={conn_gt['markers']['raw']:6.2f} / max={conn_gt['markers']['max']:6.2f} = {conn_gt['markers']['norm']:5.2f}%")
print(f"  DIFF: {conn_api['components']['biomarker']['raw_score'] - conn_gt['markers']['raw']:+6.2f} raw score")

print(f"\nSurvey:")
print(f"  API:  raw={conn_api['components']['survey']['raw_score']:6.2f} / max={conn_api['components']['survey']['max_score']:6.2f} = {conn_api['components']['survey']['normalized']:5.2f}%")
print(f"  GT:   raw={conn_gt['survey']['raw']:6.2f} / max={conn_gt['survey']['max']:6.2f} = {conn_gt['survey']['norm']:5.2f}%")
print(f"  DIFF: {conn_api['components']['survey']['raw_score'] - conn_gt['survey']['raw']:+6.2f} raw score")
