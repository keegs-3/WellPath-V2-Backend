"""Deep comparison of scoring differences."""

import requests
import json

patient_id = "1a8a56a1-360f-456c-837f-34201b13d445"

# Get API data
response = requests.get(f"http://localhost:8000/api/v1/scores/patient/{patient_id}?include_breakdown=true")
api = response.json()

# Ground truth from breakdown file
gt = {
    "Healthful Nutrition": {
        "markers": {"raw": 161.30, "max": 258.0},
        "survey": {"raw": 80.50, "max": 83.0}
    },
    "Connection + Purpose": {
        "markers": {"raw": 1.06, "max": 10.0},
        "survey": {"raw": 16.20, "max": 40.0}
    },
    "Core Care": {
        "markers": {"raw": 87.24, "max": 137.0},
        "survey": {"raw": 357.30, "max": 385.0}
    }
}

print("=" * 100)
print("DETAILED COMPARISON: API vs Ground Truth")
print("=" * 100)

for pillar in ["Healthful Nutrition", "Connection + Purpose", "Core Care"]:
    print(f"\n{pillar.upper()}")
    print("-" * 100)

    api_data = api['breakdown'][pillar]['components']
    gt_data = gt[pillar]

    # Biomarkers
    print(f"\nBiomarkers:")
    print(f"  API:  raw={api_data['biomarker']['raw_score']:8.2f} / max={api_data['biomarker']['max_score']:8.2f}")
    print(f"  GT:   raw={gt_data['markers']['raw']:8.2f} / max={gt_data['markers']['max']:8.2f}")
    print(f"  DIFF: raw={api_data['biomarker']['raw_score'] - gt_data['markers']['raw']:+8.2f} / max={api_data['biomarker']['max_score'] - gt_data['markers']['max']:+8.2f}")

    # Calculate normalized percentages
    api_norm = (api_data['biomarker']['raw_score'] / api_data['biomarker']['max_score'] * 100) if api_data['biomarker']['max_score'] > 0 else 0
    gt_norm = (gt_data['markers']['raw'] / gt_data['markers']['max'] * 100) if gt_data['markers']['max'] > 0 else 0
    print(f"  API normalized: {api_norm:.2f}%")
    print(f"  GT normalized:  {gt_norm:.2f}%")
    print(f"  DIFF: {api_norm - gt_norm:+.2f}%")

    # Survey
    print(f"\nSurvey:")
    print(f"  API:  raw={api_data['survey']['raw_score']:8.2f} / max={api_data['survey']['max_score']:8.2f}")
    print(f"  GT:   raw={gt_data['survey']['raw']:8.2f} / max={gt_data['survey']['max']:8.2f}")
    print(f"  DIFF: raw={api_data['survey']['raw_score'] - gt_data['survey']['raw']:+8.2f} / max={api_data['survey']['max_score'] - gt_data['survey']['max']:+8.2f}")

    api_survey_norm = (api_data['survey']['raw_score'] / api_data['survey']['max_score'] * 100) if api_data['survey']['max_score'] > 0 else 0
    gt_survey_norm = (gt_data['survey']['raw'] / gt_data['survey']['max'] * 100) if gt_data['survey']['max'] > 0 else 0
    print(f"  API normalized: {api_survey_norm:.2f}%")
    print(f"  GT normalized:  {gt_survey_norm:.2f}%")
    print(f"  DIFF: {api_survey_norm - gt_survey_norm:+.2f}%")

# Now check Connection + Purpose biomarker details
print("\n" + "=" * 100)
print("CONNECTION + PURPOSE - INDIVIDUAL BIOMARKER ANALYSIS")
print("=" * 100)

conn_markers = [m for m in api['breakdown']['detailed_biomarker_contributions']
                if any(p['pillar'] == 'Connection + Purpose' for p in m['pillar_contributions'])]

print(f"\nFound {len(conn_markers)} markers contributing to Connection + Purpose:")
total_weighted = 0
for marker in conn_markers:
    for contrib in marker['pillar_contributions']:
        if contrib['pillar'] == 'Connection + Purpose':
            print(f"\n{marker['marker_name']}:")
            print(f"  Lab Value: {marker['lab_value']}")
            print(f"  Raw Score: {marker['raw_score']:.3f}")
            print(f"  Weight: {contrib['weight']}")
            print(f"  Weighted Score: {contrib['weighted_score']:.3f}")
            total_weighted += contrib['weighted_score']

print(f"\nTotal weighted score from individual markers: {total_weighted:.3f}")
print(f"API reports total: {api['breakdown']['Connection + Purpose']['components']['biomarker']['raw_score']:.3f}")
print(f"GT reports total: 1.06")
