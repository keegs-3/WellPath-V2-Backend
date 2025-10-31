#!/usr/bin/env python3
"""
Reset and populate fresh test data for the app user (test.patient.21@wellpath.com).

This script:
1. Cleans all existing data for the user
2. Generates comprehensive realistic test data
3. Runs aggregations to populate the cache
"""

import os
import psycopg2
from psycopg2.extras import RealDictCursor
from datetime import datetime, timedelta
import random
import subprocess

# Database connection
DB_URL = os.getenv('DATABASE_URL', 'postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres')

# App user (the one used in the Swift app)
APP_USER_ID = '8b79ce33-02b8-4f49-8268-3204130efa82'
APP_USER_EMAIL = 'test.patient.21@wellpath.com'

def clean_existing_data(conn):
    """Delete all existing data for the app user."""
    print(f"🧹 Cleaning existing data for {APP_USER_EMAIL}...")

    with conn.cursor() as cur:
        # Count before deletion
        cur.execute("SELECT COUNT(*) FROM patient_data_entries WHERE patient_id = %s", (APP_USER_ID,))
        entries_count = cur.fetchone()[0]

        cur.execute("SELECT COUNT(*) FROM patient_biomarker_readings WHERE patient_id = %s", (APP_USER_ID,))
        biomarkers_count = cur.fetchone()[0]

        cur.execute("SELECT COUNT(*) FROM patient_biometric_readings WHERE patient_id = %s", (APP_USER_ID,))
        biometrics_count = cur.fetchone()[0]

        cur.execute("SELECT COUNT(*) FROM aggregation_results_cache WHERE patient_id = %s", (APP_USER_ID,))
        cache_count = cur.fetchone()[0]

        print(f"  Current data:")
        print(f"    - {entries_count} data entries")
        print(f"    - {biomarkers_count} biomarker readings")
        print(f"    - {biometrics_count} biometric readings")
        print(f"    - {cache_count} cached aggregations")

        # Delete data
        cur.execute("DELETE FROM patient_data_entries WHERE patient_id = %s", (APP_USER_ID,))
        cur.execute("DELETE FROM patient_biomarker_readings WHERE patient_id = %s", (APP_USER_ID,))
        cur.execute("DELETE FROM patient_biometric_readings WHERE patient_id = %s", (APP_USER_ID,))
        cur.execute("DELETE FROM aggregation_results_cache WHERE patient_id = %s", (APP_USER_ID,))
        cur.execute("DELETE FROM patient_survey_responses WHERE patient_id = %s", (APP_USER_ID,))

        conn.commit()

        print(f"✅ Cleaned all existing data for {APP_USER_EMAIL}")

def generate_comprehensive_data(conn):
    """Generate comprehensive test data."""
    print(f"\n📊 Generating comprehensive test data for {APP_USER_EMAIL}...")

    # Use the existing comprehensive test data script
    result = subprocess.run(
        ['python3', 'scripts/generate_comprehensive_test_data.py', APP_USER_ID],
        capture_output=True,
        text=True
    )

    if result.returncode != 0:
        print(f"⚠️  Error generating data: {result.stderr}")
        print("Trying alternative script...")

        # Try the massive test data script instead
        result = subprocess.run(
            ['python3', 'scripts/generate_massive_test_data.py'],
            capture_output=True,
            text=True,
            input=f"{APP_USER_ID}\n"
        )

        if result.returncode != 0:
            print(f"❌ Failed to generate data: {result.stderr}")
            return False

    print(result.stdout)
    return True

def run_aggregations(conn):
    """Run aggregation calculations to populate the cache."""
    print(f"\n🔢 Running aggregations for {APP_USER_EMAIL}...")

    # Use the process_all_aggregations_for_user script
    result = subprocess.run(
        ['python3', 'scripts/process_all_aggregations_for_user.py', APP_USER_ID],
        capture_output=True,
        text=True
    )

    if result.returncode != 0:
        print(f"⚠️  Error running aggregations: {result.stderr}")
        print("Trying alternative aggregation script...")

        # Try process_aggregations.py
        result = subprocess.run(
            ['python3', 'scripts/process_aggregations.py'],
            capture_output=True,
            text=True,
            env={**os.environ, 'USER_ID': APP_USER_ID}
        )

        if result.returncode != 0:
            print(f"❌ Failed to run aggregations: {result.stderr}")
            return False

    print(result.stdout)
    return True

def verify_data(conn):
    """Verify the generated data."""
    print(f"\n✅ Verifying generated data for {APP_USER_EMAIL}...")

    with conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute("""
            SELECT
                (SELECT COUNT(*) FROM patient_data_entries WHERE patient_id = %s) as entries,
                (SELECT COUNT(*) FROM patient_biomarker_readings WHERE patient_id = %s) as biomarkers,
                (SELECT COUNT(*) FROM patient_biometric_readings WHERE patient_id = %s) as biometrics,
                (SELECT COUNT(*) FROM aggregation_results_cache WHERE patient_id = %s) as cache,
                (SELECT COUNT(DISTINCT field_id) FROM patient_data_entries WHERE patient_id = %s) as unique_fields,
                (SELECT MIN(entry_timestamp) FROM patient_data_entries WHERE patient_id = %s) as earliest_entry,
                (SELECT MAX(entry_timestamp) FROM patient_data_entries WHERE patient_id = %s) as latest_entry
        """, (APP_USER_ID, APP_USER_ID, APP_USER_ID, APP_USER_ID, APP_USER_ID, APP_USER_ID, APP_USER_ID))

        stats = cur.fetchone()

    print(f"\n📈 Final Summary:")
    print(f"  User: {APP_USER_EMAIL}")
    print(f"  UUID: {APP_USER_ID}")
    print(f"  ")
    print(f"  Data Generated:")
    print(f"    ✅ {stats['entries']:,} data entries")
    print(f"    ✅ {stats['biomarkers']:,} biomarker readings")
    print(f"    ✅ {stats['biometrics']:,} biometric readings")
    print(f"    ✅ {stats['cache']:,} cached aggregations")
    print(f"  ")
    print(f"  Coverage:")
    print(f"    📊 {stats['unique_fields']} unique field types")
    print(f"    📅 Date range: {stats['earliest_entry'].date()} to {stats['latest_entry'].date()}")
    print(f"  ")
    print(f"🎉 Ready to use in the Swift app!")

def main():
    conn = psycopg2.connect(DB_URL)

    try:
        print("=" * 80)
        print("Reset and Populate App User Data")
        print("=" * 80)
        print(f"User: {APP_USER_EMAIL}")
        print(f"UUID: {APP_USER_ID}")
        print("=" * 80)
        print()

        # Step 1: Clean existing data
        clean_existing_data(conn)

        # Step 2: Generate comprehensive data
        if not generate_comprehensive_data(conn):
            print("\n⚠️  Data generation had issues, but continuing to aggregations...")

        # Step 3: Run aggregations
        if not run_aggregations(conn):
            print("\n⚠️  Aggregation had issues, but data is still available...")

        # Step 4: Verify
        verify_data(conn)

    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()
    finally:
        conn.close()

if __name__ == '__main__':
    main()
