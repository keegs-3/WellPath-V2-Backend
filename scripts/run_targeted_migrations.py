#!/usr/bin/env python3
"""
Run Targeted Migrations to Restore Missing Fields

This script runs specific migration files that define missing data_entry_fields.
It skips migrations that cause schema conflicts.
"""

import psycopg2
import os
import subprocess

# Read DATABASE_URL from .env file
def read_database_url():
    env_path = os.path.join(os.path.dirname(__file__), '..', '.env')
    with open(env_path) as f:
        for line in f:
            if line.startswith('DATABASE_URL='):
                return line.split('=', 1)[1].strip()
    raise ValueError("DATABASE_URL not found in .env file")

DATABASE_URL = read_database_url()

# List of migration files to run (in order)
# These define data_entry_fields without major schema conflicts
MIGRATIONS_TO_RUN = [
    '20251021_add_added_sugar_tracking.sql',
    '20251021_add_meal_qualifiers.sql',
    '20251021_add_nutrition_grams_servings_fields.sql',
    '20251021_add_processed_meat_tracking.sql',
    '20251021_add_ultra_processed_food_tracking.sql',
    '20251021_add_water_tracking.sql',
    '20251021_create_biometric_data_entry_fields.sql',
    '20251021_create_field_registry.sql',
    '20251021_create_session_count_fields.sql',
    '20251021_create_distance_output_fields.sql',
    '20251021_create_duration_output_fields.sql',
    '20251021_create_hiit_and_mobility_types.sql',
    '20251021_add_cardio_distance_units.sql',
    '20251021_add_workout_calories_fields.sql',
    '20251024_create_sleep_stages_data_entry_fields_v2.sql',
    '20251025_create_food_timing_reference.sql',
    '20251025_create_protein_meal_timing_fields.sql',
]

def main():
    print("="*80)
    print("RUN TARGETED MIGRATIONS TO RESTORE MISSING FIELDS")
    print("="*80)

    conn = psycopg2.connect(DATABASE_URL)
    cur = conn.cursor()

    # Get starting count
    cur.execute("SELECT COUNT(*) FROM data_entry_fields")
    starting_count = cur.fetchone()[0]
    print(f"\n📊 Starting field count: {starting_count}")

    # Get password from DATABASE_URL
    import re
    match = re.search(r'postgresql://([^:]+):([^@]+)@([^:]+):(\d+)/(\w+)', DATABASE_URL)
    if match:
        _, password, host, port, database = match.groups()
    else:
        print("❌ Could not parse DATABASE_URL")
        return

    # Run each migration
    successful = []
    failed = []

    for migration_file in MIGRATIONS_TO_RUN:
        filepath = f'supabase/migrations/{migration_file}'

        if not os.path.exists(filepath):
            print(f"\n⚠️  {migration_file} - FILE NOT FOUND")
            failed.append((migration_file, "File not found"))
            continue

        print(f"\n🔄 Running {migration_file}...")

        # Run migration using psql command
        cmd = [
            'psql',
            DATABASE_URL,
            '-f', filepath,
            '--quiet'
        ]

        try:
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                timeout=30
            )

            if result.returncode == 0:
                # Check how many fields we have now
                cur.execute("SELECT COUNT(*) FROM data_entry_fields")
                current_count = cur.fetchone()[0]
                added = current_count - starting_count
                starting_count = current_count

                print(f"   ✅ SUCCESS - Added {added} fields (total: {current_count})")
                successful.append((migration_file, added))
            else:
                error = result.stderr[:200] if result.stderr else result.stdout[:200]
                print(f"   ❌ FAILED - {error}")
                failed.append((migration_file, error))

        except subprocess.TimeoutExpired:
            print(f"   ❌ TIMEOUT")
            failed.append((migration_file, "Timeout"))
        except Exception as e:
            print(f"   ❌ ERROR - {str(e)[:200]}")
            failed.append((migration_file, str(e)[:200]))

    # Get final count
    cur.execute("SELECT COUNT(*) as total, COUNT(*) FILTER (WHERE is_active = true) as active FROM data_entry_fields")
    total, active = cur.fetchone()

    # Summary
    print("\n" + "="*80)
    print("MIGRATION SUMMARY")
    print("="*80)
    print(f"✅ Successful: {len(successful)} migrations")
    print(f"❌ Failed: {len(failed)} migrations")
    print(f"\n📊 Final field count: {total} total, {active} active")

    if successful:
        print("\n✅ Successful migrations:")
        for migration, added in successful:
            print(f"   {migration}: +{added} fields")

    if failed:
        print("\n❌ Failed migrations:")
        for migration, error in failed[:10]:
            print(f"   {migration}: {error[:100]}")

    # Check still missing
    with open('/tmp/missing_fields_valid.txt', 'r') as f:
        target_fields = set(line.strip() for line in f if line.strip())

    cur.execute("SELECT field_id FROM data_entry_fields")
    current_fields = set(row[0] for row in cur.fetchall())

    still_missing = target_fields - current_fields
    print(f"\n⚠️  Still missing: {len(still_missing)} fields")

    if len(still_missing) <= 30:
        print("\nStill missing:")
        for field in sorted(still_missing):
            print(f"   - {field}")

    cur.close()
    conn.close()

if __name__ == '__main__':
    main()
