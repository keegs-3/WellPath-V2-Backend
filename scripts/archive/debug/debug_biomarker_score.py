"""Debug biomarker scoring for Connection + Purpose."""

from database.postgres_client import PostgresClient
from scoring_engine.scoring_service import WellPathScoringService

db = PostgresClient()
service = WellPathScoringService(db)

patient_id = "1a8a56a1-360f-456c-837f-34201b13d445"

# Get scores
results = service.calculate_patient_scores(patient_id)

# Extract biomarker details for Connection + Purpose
conn_purpose_data = results['biomarker_details'].get('pillar_scores', {}).get('Connection + Purpose', {})

print("=" * 80)
print("CONNECTION + PURPOSE BIOMARKER SCORING")
print("=" * 80)
print(f"\nRaw Score: {conn_purpose_data.get('raw_score', 0)}")
print(f"Max Score: {conn_purpose_data.get('max_score', 0)}")
print(f"Percentage: {conn_purpose_data.get('percentage', 0)}%")
print(f"\nExpected from ground truth:")
print(f"  Raw Score: 1.06")
print(f"  Max Score: 10.00")
print(f"  Percentage: 10.6%")

# Check what markers contributed
if 'contributing_markers' in conn_purpose_data:
    print(f"\nContributing markers:")
    for marker in conn_purpose_data['contributing_markers']:
        print(f"  - {marker}")
