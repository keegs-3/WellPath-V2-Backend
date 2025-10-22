#!/usr/bin/env python3
"""
View detailed score breakdown for a patient
"""
import requests
import json
import sys

SUPABASE_URL = 'https://csotzmardnvrpdhlogjm.supabase.co'
SUPABASE_SERVICE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNzb3R6bWFyZG52cnBkaGxvZ2ptIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1OTMyNDgxMSwiZXhwIjoyMDc0OTAwODExfQ.X1belKzZ6vBmAh4K9-kS0x5DcWiRFp6lnFPPFA28Rxk'

# Use existing patient with ID
user_id = sys.argv[1] if len(sys.argv) > 1 else '1758fa60-a306-440e-8ae6-9e68fd502bc2'

url = f'{SUPABASE_URL}/functions/v1/calculate-wellpath-score'
headers = {
    'Authorization': f'Bearer {SUPABASE_SERVICE_KEY}',
    'Content-Type': 'application/json'
}
data = {'patient_id': user_id}

print(f"Fetching score breakdown for patient: {user_id}")
print("="*80)

response = requests.post(url, headers=headers, json=data, timeout=30)

if response.status_code == 200:
    result = response.json()

    print(f"\nOverall Score: {result['overall_score']*100:.1f}%\n")

    for pillar in result['pillar_scores']:
        name = pillar['pillar_name']
        final = pillar['final_score'] * 100

        markers_pct = (pillar['markers_score'] / pillar['markers_max'] * 100) if pillar['markers_max'] > 0 else 0
        survey_pct = (pillar['survey_score'] / pillar['survey_max'] * 100) if pillar['survey_max'] > 0 else 0

        print(f"\n{'='*80}")
        print(f"{name}: {final:.1f}%")
        print(f"{'='*80}")
        print(f"  Markers: {pillar['markers_score']:.1f}/{pillar['markers_max']:.1f} ({markers_pct:.1f}%)")
        print(f"  Survey:  {pillar['survey_score']:.1f}/{pillar['survey_max']:.1f} ({survey_pct:.1f}%)")
        print(f"  Education: {pillar['education_score']:.1f}/{pillar['education_max']:.1f}")

        if 'scored_items' in pillar and pillar['scored_items']:
            print(f"\n  Items ({len(pillar['scored_items'])} total):")

            # Group by type
            biomarkers = [i for i in pillar['scored_items'] if i['item_type'] == 'biomarker']
            biometrics = [i for i in pillar['scored_items'] if i['item_type'] == 'biometric']
            questions = [i for i in pillar['scored_items'] if i['item_type'] == 'survey_question']
            functions = [i for i in pillar['scored_items'] if i['item_type'] == 'survey_function']

            # Show items scoring less than perfect
            imperfect = [i for i in pillar['scored_items'] if i['normalized_score'] < 1.0]

            if imperfect:
                print(f"\n  ⚠️  IMPERFECT SCORES ({len(imperfect)} items):")
                for item in sorted(imperfect, key=lambda x: x['normalized_score']):
                    contrib = item['pillar_contributions'][0]
                    print(f"    - {item['item_name']} ({item['item_type']}): "
                          f"score={item['normalized_score']:.2f}, "
                          f"weight={contrib['weight']}, "
                          f"weighted={contrib['weighted_score']:.2f}, "
                          f"value={item.get('raw_value', 'N/A')}")

            # Summary by type
            print(f"\n  Summary:")
            if biomarkers:
                bio_perfect = len([i for i in biomarkers if i['normalized_score'] == 1.0])
                print(f"    Biomarkers: {bio_perfect}/{len(biomarkers)} perfect")
            if biometrics:
                met_perfect = len([i for i in biometrics if i['normalized_score'] == 1.0])
                print(f"    Biometrics: {met_perfect}/{len(biometrics)} perfect")
            if questions:
                q_perfect = len([i for i in questions if i['normalized_score'] == 1.0])
                print(f"    Questions: {q_perfect}/{len(questions)} perfect")
            if functions:
                f_perfect = len([i for i in functions if i['normalized_score'] == 1.0])
                print(f"    Functions: {f_perfect}/{len(functions)} perfect")

else:
    print(f"Error: {response.status_code}")
    print(response.text)
