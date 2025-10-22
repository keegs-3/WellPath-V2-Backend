#!/usr/bin/env python3
"""
Find which markers are in GT but not in API, causing the score differences
"""

import json
import sys
sys.path.insert(0, '/Users/keegs/Documents/GitHub/preliminary_data')

import pandas as pd

# Load API response
with open('/Users/keegs/Downloads/response_1759979103406.json') as f:
    api_data = json.load(f)

# Load GT lab data
lab_df = pd.read_csv('/Users/keegs/Documents/GitHub/preliminary_data/data/dummy_lab_results_full.csv')
patient_row = lab_df[lab_df['patient_id'] == '1a8a56a1-360f-456c-837f-34201b13d445'].iloc[0]

# Get API marker names
api_markers = {item['marker_name'] for item in api_data['breakdown']['detailed_biomarker_contributions']}

# Get GT marker names (columns with non-null values)
metadata_cols = ['patient_id', 'sex', 'age', 'menopausal_status', 'cycle_phase', 'unique_condition', 'phenoage', 'dnam_phenoage']
gt_markers = set()
for col in patient_row.index:
    if col not in metadata_cols and pd.notna(patient_row[col]):
        gt_markers.add(col)

print(f"API has {len(api_markers)} markers")
print(f"GT has {len(gt_markers)} markers")
print()

# Find markers in GT but not in API
missing_from_api = gt_markers - api_markers
if missing_from_api:
    print(f"❌ {len(missing_from_api)} markers in GT but NOT in API:")
    for marker in sorted(missing_from_api):
        print(f"  - {marker} = {patient_row[marker]}")
else:
    print("✅ All GT markers are in API")

print()

# Find markers in API but not in GT
extra_in_api = api_markers - gt_markers
if extra_in_api:
    print(f"⚠️  {len(extra_in_api)} markers in API but NOT in GT:")
    for marker in sorted(extra_in_api):
        print(f"  - {marker}")
else:
    print("✅ No extra markers in API")
