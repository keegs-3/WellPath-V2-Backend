import requests
import json

url = 'https://csotzmardnvrpdhlogjm.supabase.co/functions/v1/calculate-wellpath-score'
headers = {
    'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNzb3R6bWFyZG52cnBkaGxvZ2ptIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTcyNzY0NTQyNywiZXhwIjoyMDQzMjIxNDI3fQ.WaYbRuLZUqF-jrF_RMC5_RlPQnfwUIr0PkUWsZOZFWs',
    'Content-Type': 'application/json'
}
data = {'patient_id': '1758fa60-a306-440e-8ae6-9e68fd502bc2'}

response = requests.post(url, headers=headers, json=data)
print(f"Status Code: {response.status_code}")
print(f"Response:")
print(json.dumps(response.json(), indent=2))
