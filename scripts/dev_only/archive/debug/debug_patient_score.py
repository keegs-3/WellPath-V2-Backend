#!/usr/bin/env python3
"""
Debug scoring for specific patient
"""
import requests
import json

SUPABASE_URL = 'https://csotzmardnvrpdhlogjm.supabase.co'
SUPABASE_SERVICE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNzb3R6bWFyZG52cnBkaGxvZ2ptIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1OTMyNDgxMSwiZXhwIjoyMDc0OTAwODExfQ.X1belKzZ6vBmAh4K9-kS0x5DcWiRFp6lnFPPFA28Rxk'

user_id = '00ecf02f-66fe-4b43-9b34-0e577dd7f38b'

url = f'{SUPABASE_URL}/functions/v1/calculate-wellpath-score'
headers = {
    'Authorization': f'Bearer {SUPABASE_SERVICE_KEY}',
    'Content-Type': 'application/json'
}
data = {'patient_id': user_id}

response = requests.post(url, headers=headers, json=data, timeout=30)

if response.status_code == 200:
    result = response.json()

    print("Expected: 59.5% overall")
    print(f"Got:      {result['overall_score']*100:.1f}% overall\n")

    print("Expected vs Actual Pillar Scores:")
    print("="*60)

    expected = {
        "Healthful Nutrition": 56.3,
        "Movement + Exercise": 57.6,
        "Restorative Sleep": 58.2,
        "Cognitive Health": 55.7,
        "Stress Management": 62.9,
        "Connection + Purpose": 66.8,
        "Core Care": 58.8
    }

    for pillar in result['pillar_scores']:
        name = pillar['pillar_name']
        actual = pillar['final_score'] * 100
        exp = expected.get(name, 0)
        diff = actual - exp

        print(f"\n{name}:")
        print(f"  Expected: {exp:.1f}%")
        print(f"  Actual:   {actual:.1f}%")
        print(f"  Diff:     {diff:+.1f}%")
        print(f"  Markers:  {pillar['markers_score']:.1f}/{pillar['markers_max']:.1f}")
        print(f"  Survey:   {pillar['survey_score']:.1f}/{pillar['survey_max']:.1f}")

else:
    print(f"Error: {response.status_code}")
    print(response.text)
