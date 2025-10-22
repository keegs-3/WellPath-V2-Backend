#!/usr/bin/env python3
"""
Test to confirm the gender matching bug in biomarker scorer
"""

import sys
sys.path.insert(0, '/Users/keegs/Documents/GitHub/WellPath-V2-Backend')

from scoring_engine.biomarker_scorer import BiomarkerScorer

scorer = BiomarkerScorer()

# Test DHEA-S for male patient
patient_info = {
    'age': 72,
    'sex': 'male'
}

# This should use the MALE sub-config
result = scorer.score_value('dhea_s', 182.3, patient_info)

print("="*80)
print("DHEA-S = 182.3 for 72-year-old MALE")
print("="*80)
print(f"Score returned: {result.get('score', 'N/A')}")
print(f"Range label: {result.get('range_label', 'N/A')}")
print()

# Calculate what it SHOULD be with male ranges
male_min, male_max = 150, 349.99
position = (182.3 - male_min) / (male_max - male_min)
male_score = (0 + 7 * position) / 10.0

print(f"Expected (MALE ranges [150-350] linear 0->7):")
print(f"  Position: {position:.6f}")
print(f"  Score: {male_score:.6f}")
print()

# Calculate what it would be with female ranges
female_min, female_max = 30, 274.99
position_f = (182.3 - female_min) / (female_max - female_min)
female_score = (0 + 7 * position_f) / 10.0

print(f"What we'd get with FEMALE ranges [30-275] linear 0->7:")
print(f"  Position: {position_f:.6f}")
print(f"  Score: {female_score:.6f}")
print()

if abs(result.get('score', 0) - female_score) < 0.001:
    print("❌ BUG CONFIRMED: API is using FEMALE ranges for MALE patient!")
elif abs(result.get('score', 0) - male_score) < 0.001:
    print("✅ CORRECT: API is using MALE ranges")
else:
    print(f"❓ UNKNOWN: Score {result.get('score')} doesn't match either")

print()
print("Patient info passed:")
print(f"  {patient_info}")
print()

# Let's test the _get_sub_config method directly
config = scorer.marker_config['dhea_s']
sub = scorer._get_sub_config(config['subs'], patient_info)
print(f"Sub-config selected:")
print(f"  Sex in sub: {sub.get('sex', 'N/A')}")
print(f"  Number of ranges: {len(sub.get('ranges', []))}")
if sub.get('ranges'):
    first_range = sub['ranges'][0]
    print(f"  First range: {first_range.get('label', 'N/A')} [{first_range.get('min')}, {first_range.get('max')}]")
