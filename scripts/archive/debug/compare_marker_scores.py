#!/usr/bin/env python3
"""
Detailed comparison of API vs Ground Truth marker scoring for patient 1a8a56a1
"""

import json

# Load API response
with open('/Users/keegs/Downloads/response_1759979103406.json') as f:
    api_data = json.load(f)

# Ground truth from breakdown.txt
gt_data = {
    "Healthful Nutrition": {"raw": 161.30, "max": 258.00},
    "Movement + Exercise": {"raw": 83.58, "max": 130.00},
    "Restorative Sleep": {"raw": 47.82, "max": 98.00},
    "Cognitive Health": {"raw": 74.80, "max": 139.00},
    "Stress Management": {"raw": 78.77, "max": 140.00},
    "Connection + Purpose": {"raw": 1.06, "max": 10.00},
    "Core Care": {"raw": 87.24, "max": 137.00}
}

# Extract API biomarker scores
api_biomarkers = {}
for pillar_name, gt in gt_data.items():
    api_breakdown = api_data['breakdown'][pillar_name]['components']['biomarker']
    api_biomarkers[pillar_name] = {
        "raw": api_breakdown['raw_score'],
        "max": api_breakdown['max_score']
    }

# Compare
print("=" * 100)
print(f"{'PILLAR':<25} {'GT RAW':>12} {'API RAW':>12} {'DIFF':>12} {'GT MAX':>12} {'API MAX':>12} {'MAX DIFF':>12}")
print("=" * 100)

total_raw_diff = 0
total_max_diff = 0

for pillar in gt_data.keys():
    gt = gt_data[pillar]
    api = api_biomarkers[pillar]

    raw_diff = api['raw'] - gt['raw']
    max_diff = api['max'] - gt['max']

    total_raw_diff += abs(raw_diff)
    total_max_diff += abs(max_diff)

    print(f"{pillar:<25} {gt['raw']:>12.2f} {api['raw']:>12.2f} {raw_diff:>12.2f} {gt['max']:>12.2f} {api['max']:>12.2f} {max_diff:>12.2f}")

print("=" * 100)
print(f"{'TOTAL ABSOLUTE DIFFERENCE':<25} {'':<12} {'':<12} {total_raw_diff:>12.2f} {'':<12} {'':<12} {total_max_diff:>12.2f}")
print("=" * 100)

# Count markers from API
api_marker_count = len(api_data['breakdown']['detailed_biomarker_contributions'])
print(f"\nAPI has {api_marker_count} biomarkers")

# Check which markers might be different
print("\nChecking for major discrepancies (>5 point difference):")
for pillar, gt in gt_data.items():
    api = api_biomarkers[pillar]
    raw_diff = abs(api['raw'] - gt['raw'])
    max_diff = abs(api['max'] - gt['max'])

    if raw_diff > 5 or max_diff > 5:
        print(f"  ⚠️  {pillar}: raw_diff={raw_diff:.2f}, max_diff={max_diff:.2f}")
