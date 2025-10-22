#!/usr/bin/env python3
"""
Trigger the Edge Function to recalculate scores using an anon key.
"""
import requests
import json

# Use the anon key from .env
url = 'https://csotzmardnvrpdhlogjm.supabase.co/functions/v1/calculate-wellpath-score'
anon_key = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNzb3R6bWFyZG52cnBkaGxvZ2ptIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTkzMjQ4MTEsImV4cCI6MjA3NDkwMDgxMX0.Kw5NRNL3uv35HFUaalLMSbXJLBOPXCceexs7Y-4U9S4'

headers = {
    'Authorization': f'Bearer {anon_key}',
    'Content-Type': 'application/json',
    'apikey': anon_key  # Also include as apikey header
}

patient_id = '1758fa60-a306-440e-8ae6-9e68fd502bc2'
data = {'patient_id': patient_id}

print(f"Calling Edge Function for patient {patient_id}...")
response = requests.post(url, headers=headers, json=data, timeout=60)

print(f"\nStatus Code: {response.status_code}")
if response.status_code == 200:
    result = response.json()
    print(f"\n✅ Success!")
    print(f"Items scored: {result.get('items_scored')}")
    print(f"\nPillars:")
    for pillar in result.get('pillars', []):
        print(f"  {pillar['pillar_name']:30s}: {pillar['percentage']:>6s}% ({pillar['item_count']} items)")

    # Show debug info if available
    if '_debug' in result:
        print(f"\nDebug Info:")
        print(json.dumps(result['_debug'], indent=2))
else:
    print(f"❌ Error:")
    try:
        print(json.dumps(response.json(), indent=2))
    except:
        print(response.text)
