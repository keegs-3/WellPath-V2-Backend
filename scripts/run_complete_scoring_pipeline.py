#!/usr/bin/env python3
"""
Complete WellPath Scoring Pipeline
Runs the full flow: Aggregations → Edge Functions → Score Calculation
"""

import os
import sys
import requests
import subprocess

# Configuration
SUPABASE_URL = 'https://csotzmardnvrpdhlogjm.supabase.co'
SERVICE_ROLE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNzb3R6bWFyZG52cnBkaGxvZ2ptIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1OTMyNDgxMSwiZXhwIjoyMDc0OTAwODExfQ.X1belKzZ6vBmAh4K9-kS0x5DcWiRFp6lnFPPFA28Rxk'

def run_aggregation_pipeline(user_id=None):
    """Step 1: Run aggregation pipeline"""
    print("\n" + "="*70)
    print("STEP 1: Running Aggregation Pipeline")
    print("="*70)

    # Run the aggregation script
    result = subprocess.run(
        ['python3', 'scripts/process_aggregations.py'],
        capture_output=True,
        text=True
    )

    if result.returncode != 0:
        print(f"❌ Aggregation failed: {result.stderr}")
        return False

    print("✅ Aggregation pipeline completed")
    return True

def run_edge_functions(user_id):
    """Step 2: Run edge functions to update patient tables"""
    print("\n" + "="*70)
    print("STEP 2: Running Edge Functions")
    print("="*70)

    headers = {
        'Authorization': f'Bearer {SERVICE_ROLE_KEY}',
        'Content-Type': 'application/json'
    }

    # Call update-biometric-scores
    print("\n📊 Updating biometric readings...")
    response = requests.post(
        f'{SUPABASE_URL}/functions/v1/update-biometric-scores',
        headers=headers,
        json={'userId': user_id}
    )

    if response.status_code != 200:
        print(f"❌ Biometric update failed: {response.text}")
        return False

    result = response.json()
    print(f"✅ Updated {result.get('biometricsUpdated', 0)} biometrics")

    # Call update-survey-scores
    print("\n📝 Updating survey responses...")
    response = requests.post(
        f'{SUPABASE_URL}/functions/v1/update-survey-scores',
        headers=headers,
        json={'userId': user_id}
    )

    if response.status_code != 200:
        print(f"❌ Survey update failed: {response.text}")
        return False

    result = response.json()
    print(f"✅ Updated {result.get('responsesUpdated', 0)} survey responses")

    return True

def calculate_wellpath_score(user_id):
    """Step 3: Calculate WellPath score"""
    print("\n" + "="*70)
    print("STEP 3: Calculating WellPath Score")
    print("="*70)

    headers = {
        'Authorization': f'Bearer {SERVICE_ROLE_KEY}',
        'Content-Type': 'application/json'
    }

    response = requests.post(
        f'{SUPABASE_URL}/functions/v1/calculate-wellpath-score',
        headers=headers,
        json={'patient_id': user_id}
    )

    if response.status_code != 200:
        print(f"❌ Score calculation failed: {response.text}")
        return False

    result = response.json()
    print(f"✅ Score calculated successfully")
    print(f"   Items scored: {result.get('items_scored', 0)}")

    # Show pillar scores
    print("\n📊 Pillar Scores:")
    for pillar in result.get('pillars', []):
        print(f"   {pillar['pillar_name']}: {pillar['percentage']}% ({pillar['score']:.2f}/{pillar['max']:.2f})")

    return True

def main():
    """Run complete pipeline"""
    print("\n🚀 WellPath Complete Scoring Pipeline")
    print("="*70)

    # Get user ID from command line or use default
    if len(sys.argv) > 1:
        user_id = sys.argv[1]
    else:
        user_id = '1758fa60-a306-440e-8ae6-9e68fd502bc2'  # Perfect patient

    print(f"Patient ID: {user_id}")

    # Run pipeline steps in order
    if not run_aggregation_pipeline(user_id):
        print("\n❌ Pipeline failed at aggregation step")
        sys.exit(1)

    if not run_edge_functions(user_id):
        print("\n❌ Pipeline failed at edge function step")
        sys.exit(1)

    if not calculate_wellpath_score(user_id):
        print("\n❌ Pipeline failed at scoring step")
        sys.exit(1)

    print("\n" + "="*70)
    print("✅ PIPELINE COMPLETE")
    print("="*70)
    print("\nData flow:")
    print("  patient_data_entries")
    print("    ↓")
    print("  aggregation_results_cache")
    print("    ↓")
    print("  patient_biometric_readings + patient_survey_responses")
    print("    ↓")
    print("  WellPath Score ✅")
    print()

if __name__ == "__main__":
    main()
