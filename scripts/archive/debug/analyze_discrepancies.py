#!/usr/bin/env python3
"""
Deep dive into the 4 biomarkers with scoring discrepancies
"""

import json
import sys
sys.path.insert(0, '/Users/keegs/Documents/GitHub/WellPath-V2-Backend')

from scoring_engine.biomarker_scorer import BiomarkerScorer

# Load API response
with open('/Users/keegs/Downloads/response_1759979103406.json') as f:
    api_data = json.load(f)

# Load marker config
with open('/Users/keegs/Documents/GitHub/WellPath-V2-Backend/scoring_engine/configs/marker_config.json') as f:
    marker_config = json.load(f)

# Patient info
patient_info = {
    'age': 72,
    'sex': 'male'
}

# The 4 problematic biomarkers
biomarkers = {
    'DHEA-S': 182.3,
    'Estradiol': 17.8,
    'Ferritin': 110.5,
    'VO2 Max': 37.5
}

scorer = BiomarkerScorer()

print("=" * 120)
print("DETAILED ANALYSIS OF SCORING DISCREPANCIES")
print("=" * 120)
print()

for marker_name, value in biomarkers.items():
    print(f"\n{'='*120}")
    print(f"MARKER: {marker_name} = {value}")
    print(f"{'='*120}")

    # Get marker config
    marker_cfg = marker_config.get(marker_name)
    if not marker_cfg:
        print(f"❌ Not found in marker_config.json")
        continue

    print(f"\nPillar Weights:")
    for pillar, weight in marker_cfg['pillar_weights'].items():
        if weight > 0:
            print(f"  {pillar}: {weight}")

    # Find matching sub-config
    matched_sub = None
    for sub in marker_cfg['sub_configs']:
        # Check gender
        if sub['gender'] != 'both' and sub['gender'] != patient_info['sex']:
            continue

        # Check age
        age_min = sub.get('age_min', 0)
        age_max = sub.get('age_max', 999)
        if not (age_min <= patient_info['age'] <= age_max):
            continue

        matched_sub = sub
        break

    if not matched_sub:
        print(f"❌ No matching sub-config for age={patient_info['age']}, sex={patient_info['sex']}")
        continue

    print(f"\nMatched Sub-Config:")
    print(f"  Gender: {matched_sub['gender']}")
    print(f"  Age Range: {matched_sub.get('age_min', 0)}-{matched_sub.get('age_max', 999)}")
    print(f"  Score Type: {matched_sub.get('score_type', 'N/A')}")

    print(f"\nRanges:")
    for rng in matched_sub['ranges']:
        range_label = rng['range']
        min_val = rng.get('min', '-∞')
        max_val = rng.get('max', '∞')
        score = rng.get('score', 'N/A')
        score_type = rng.get('score_type', matched_sub.get('score_type', 'fixed'))

        # Check if value falls in this range
        in_range = False
        if 'min' in rng and 'max' in rng:
            in_range = rng['min'] <= value <= rng['max']
        elif 'min' in rng:
            in_range = value >= rng['min']
        elif 'max' in rng:
            in_range = value <= rng['max']

        marker = "👉" if in_range else "  "

        print(f"  {marker} {range_label}: [{min_val}, {max_val}] -> score={score} (type={score_type})")

        if in_range and score_type == 'linear':
            # Calculate linear score
            score_start = rng.get('score_start', 0)
            score_end = rng.get('score_end', 0)
            range_min = rng.get('min')
            range_max = rng.get('max')

            if range_min is not None and range_max is not None and range_max != range_min:
                position = (value - range_min) / (range_max - range_min)
                linear_score = score_start + (score_end - score_start) * position
                normalized = linear_score / 10.0

                print(f"     LINEAR CALCULATION:")
                print(f"       position = ({value} - {range_min}) / ({range_max} - {range_min}) = {position:.6f}")
                print(f"       linear_score = {score_start} + ({score_end} - {score_start}) * {position:.6f} = {linear_score:.6f}")
                print(f"       normalized = {linear_score:.6f} / 10.0 = {normalized:.6f}")

    # Score using scorer
    result = scorer.score_patient_biomarkers({marker_name: value}, patient_info)

    # Find this marker in API response
    api_marker = None
    for item in api_data['breakdown']['detailed_biomarker_contributions']:
        if item['marker_name'] == marker_name:
            api_marker = item
            break

    print(f"\nSCORER OUTPUT:")
    if result.get('marker_details'):
        detail = result['marker_details'][0]
        print(f"  Raw Score: {detail['score']:.6f}")
        print(f"  Range: {detail['range_label']}")

    print(f"\nAPI RESPONSE:")
    if api_marker:
        print(f"  Raw Score: {api_marker['normalized_score']:.6f}")
        print(f"  Range: {api_marker['range_label']}")

    print()

print("=" * 120)
