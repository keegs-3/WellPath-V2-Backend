#!/usr/bin/env python3
"""
Test perfect patient scoring - should get 90% (72% markers + 18% survey, 0% education)
"""
import requests

SUPABASE_URL = 'https://csotzmardnvrpdhlogjm.supabase.co'
SUPABASE_SERVICE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNzb3R6bWFyZG52cnBkaGxvZ2ptIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1OTMyNDgxMSwiZXhwIjoyMDc0OTAwODExfQ.X1belKzZ6vBmAh4K9-kS0x5DcWiRFp6lnFPPFA28Rxk'

# Use existing patient with ID
user_id = '1758fa60-a306-440e-8ae6-9e68fd502bc2'

url = f'{SUPABASE_URL}/functions/v1/calculate-wellpath-score'
headers = {
    'Authorization': f'Bearer {SUPABASE_SERVICE_KEY}',
    'Content-Type': 'application/json'
}
data = {'patient_id': user_id}

print(f"Testing patient: {user_id}")
print("Expected: 90% if perfect (72% markers + 18% survey)")
print("="*60)

response = requests.post(url, headers=headers, json=data, timeout=30)

if response.status_code == 200:
    result = response.json()

    print(f"\nOverall Score: {result['overall_score']*100:.1f}%\n")

    print("Pillar Breakdown:")
    print("="*60)

    for pillar in result['pillar_scores']:
        name = pillar['pillar_name']
        final = pillar['final_score'] * 100

        markers_pct = (pillar['markers_score'] / pillar['markers_max'] * 100) if pillar['markers_max'] > 0 else 0
        survey_pct = (pillar['survey_score'] / pillar['survey_max'] * 100) if pillar['survey_max'] > 0 else 0

        print(f"\n{name}: {final:.1f}%")
        print(f"  Markers: {pillar['markers_score']:.1f}/{pillar['markers_max']:.1f} ({markers_pct:.1f}%)")
        print(f"  Survey:  {pillar['survey_score']:.1f}/{pillar['survey_max']:.1f} ({survey_pct:.1f}%)")
        print(f"  Education: {pillar['education_score']:.1f}/{pillar['education_max']:.1f}")

else:
    print(f"Error: {response.status_code}")
    print(response.text)
