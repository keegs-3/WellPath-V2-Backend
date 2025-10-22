#!/usr/bin/env python3
"""
Compare API response vs Ground Truth breakdown
"""

import json

# Load API response
with open('/Users/keegs/Downloads/response_1760021007192.json') as f:
    api_data = json.load(f)

# Parse ground truth from breakdown file
gt_pillars = {}
with open('/Users/keegs/Documents/GitHub/WellPath-V2-Backend/outputs/breakdowns/patient_0cc07ac6-5344-4e0a-a52b-a0ded20ccdd7_comprehensive_breakdown.txt') as f:
    content = f.read()

    # Extract pillar scores from GT
    for line in content.split('\n'):
        if 'Healthful Nutrition:' in line and 'raw' in line.lower():
            parts = line.split('/')
            gt_pillars['Healthful Nutrition'] = {'raw': float(parts[0].split(':')[1].strip()), 'max': float(parts[1].strip())}
        elif 'Movement + Exercise:' in line and 'raw' in line.lower():
            parts = line.split('/')
            gt_pillars['Movement + Exercise'] = {'raw': float(parts[0].split(':')[1].strip()), 'max': float(parts[1].strip())}
        elif 'Restorative Sleep:' in line and 'raw' in line.lower():
            parts = line.split('/')
            gt_pillars['Restorative Sleep'] = {'raw': float(parts[0].split(':')[1].strip()), 'max': float(parts[1].strip())}
        elif 'Cognitive Health:' in line and 'raw' in line.lower():
            parts = line.split('/')
            gt_pillars['Cognitive Health'] = {'raw': float(parts[0].split(':')[1].strip()), 'max': float(parts[1].strip())}
        elif 'Stress Management:' in line and 'raw' in line.lower():
            parts = line.split('/')
            gt_pillars['Stress Management'] = {'raw': float(parts[0].split(':')[1].strip()), 'max': float(parts[1].strip())}
        elif 'Connection + Purpose:' in line and 'raw' in line.lower():
            parts = line.split('/')
            gt_pillars['Connection + Purpose'] = {'raw': float(parts[0].split(':')[1].strip()), 'max': float(parts[1].strip())}
        elif 'Core Care:' in line and 'raw' in line.lower():
            parts = line.split('/')
            gt_pillars['Core Care'] = {'raw': float(parts[0].split(':')[1].strip()), 'max': float(parts[1].strip())}

print("=" * 120)
print("API vs GROUND TRUTH COMPARISON")
print("=" * 120)
print()

# Compare each pillar
total_raw_diff = 0
total_max_diff = 0

for pillar_name in gt_pillars.keys():
    gt = gt_pillars[pillar_name]

    # Get API pillar data
    api_pillar = api_data['breakdown'][pillar_name]

    # Calculate totals from components
    api_raw = api_pillar['components']['biomarker']['raw_score'] + api_pillar['components']['survey']['raw_score']
    api_max = api_pillar['components']['biomarker']['max_possible'] + api_pillar['components']['survey']['max_possible']

    raw_diff = abs(api_raw - gt['raw'])
    max_diff = abs(api_max - gt['max'])

    total_raw_diff += raw_diff
    total_max_diff += max_diff

    print(f"{pillar_name}:")
    print(f"  GT:  Raw={gt['raw']:.2f}, Max={gt['max']:.2f}")
    print(f"  API: Raw={api_raw:.2f}, Max={api_max:.2f}")
    print(f"  Diff: Raw={raw_diff:.2f}, Max={max_diff:.2f}")

    if raw_diff > 0.01 or max_diff > 0.01:
        print(f"  ❌ MISMATCH!")

        # Show component breakdown
        print(f"    API Biomarker: raw={api_pillar['components']['biomarker']['raw_score']:.2f}, max={api_pillar['components']['biomarker']['max_possible']:.2f}")
        print(f"    API Survey: raw={api_pillar['components']['survey']['raw_score']:.2f}, max={api_pillar['components']['survey']['max_possible']:.2f}")
    else:
        print(f"  ✅ MATCH")
    print()

print("=" * 120)
print(f"TOTAL ABSOLUTE DIFFERENCES:")
print(f"  Raw Score Diff: {total_raw_diff:.2f}")
print(f"  Max Score Diff: {total_max_diff:.2f}")
print("=" * 120)
