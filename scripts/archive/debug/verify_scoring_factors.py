#!/usr/bin/env python3
"""Verify V2-Backend scoring matches the Scoring factors.xlsx ground truth"""

import sys
sys.path.insert(0, '/Users/keegs/Documents/GitHub/WellPath-V2-Backend')

from scoring_engine.scoring_service import WellPathScoringService
from database.postgres_client import PostgresClient

# Ground truth from Scoring factors.xlsx
EXPECTED_FACTORS = {
    'Healthful Nutrition': {'markers': 0.72, 'survey': 0.18, 'education': 0.10},
    'Movement + Exercise': {'markers': 0.64, 'survey': 0.26, 'education': 0.10},
    'Restorative Sleep': {'markers': 0.63, 'survey': 0.27, 'education': 0.10},
    'Stress Management': {'markers': 0.27, 'survey': 0.63, 'education': 0.10},
    'Cognitive Health': {'markers': 0.38, 'survey': 0.54, 'education': 0.08},
    'Connection + Purpose': {'markers': 0.18, 'survey': 0.72, 'education': 0.10},
    'Core Care': {'markers': 0.85, 'survey': 0.05, 'education': 0.10},
}

# Initialize
db = PostgresClient()
scoring_service = WellPathScoringService(db)

# Get V2-Backend weights
v2_weights = scoring_service.PILLAR_WEIGHTS

print("=" * 80)
print("SCORING FACTORS VERIFICATION")
print("=" * 80)
print("\nComparing V2-Backend weights vs Scoring factors.xlsx ground truth:\n")
print(f"{'Pillar':<25} {'Component':<12} {'V2-Backend':<12} {'Expected':<12} {'Match'}")
print("-" * 80)

all_match = True
for pillar, expected in EXPECTED_FACTORS.items():
    v2 = v2_weights.get(pillar, {})
    
    for component in ['markers', 'survey', 'education']:
        v2_val = v2.get(component, 0)
        exp_val = expected.get(component, 0)
        match = "✓" if abs(v2_val - exp_val) < 0.01 else "✗"
        
        if match == "✗":
            all_match = False
            
        print(f"{pillar:<25} {component:<12} {v2_val:<12.2f} {exp_val:<12.2f} {match}")

print("\n" + "=" * 80)
if all_match:
    print("✅ All scoring factors match!")
else:
    print("❌ Some scoring factors DO NOT MATCH - need to update PILLAR_WEIGHTS")
print("=" * 80)
