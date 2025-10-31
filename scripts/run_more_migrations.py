#!/usr/bin/env python3
"""Run additional migrations for output/calculated fields"""

import subprocess
import psycopg2
import os

def read_database_url():
    env_path = os.path.join(os.path.dirname(__file__), '..', '.env')
    with open(env_path) as f:
        for line in f:
            if line.startswith('DATABASE_URL='):
                return line.split('=', 1)[1].strip()
    raise ValueError("DATABASE_URL not found in .env file")

DATABASE_URL = read_database_url()

MIGRATIONS = [
    "20251021_add_session_counts_to_field_registry.sql",
    "20251021_create_session_count_calculations.sql",
    "20251021_create_missing_instance_calculations.sql",
    "20251021_create_missing_instance_calculations_part1.sql",
    "20251021_create_missing_instance_calculations_part2.sql",
    "20251021_create_all_duration_calculations.sql",
]

def main():
    print("Running additional output field migrations...")
    print("="*60)

    conn = psycopg2.connect(DATABASE_URL)
    cur = conn.cursor()

    # Get starting count
    cur.execute("SELECT COUNT(*) FROM data_entry_fields")
    starting_count = cur.fetchone()[0]
    print(f"Starting field count: {starting_count}")

    for migration in MIGRATIONS:
        filepath = f"supabase/migrations/{migration}"

        if not os.path.exists(filepath):
            print(f"\n⚠️  {migration} - NOT FOUND")
            continue

        print(f"\n🔄 Running {migration}...")

        cmd = ['psql', DATABASE_URL, '-f', filepath, '--quiet']

        try:
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)

            if result.returncode == 0:
                cur.execute("SELECT COUNT(*) FROM data_entry_fields")
                new_count = cur.fetchone()[0]
                added = new_count - starting_count
                starting_count = new_count
                print(f"   ✅ SUCCESS - Added {added} fields (total: {new_count})")
            else:
                error = result.stderr[:150] if result.stderr else "Unknown error"
                print(f"   ❌ FAILED - {error}")

        except Exception as e:
            print(f"   ❌ ERROR - {str(e)[:150]}")

    # Final count
    cur.execute("SELECT COUNT(*) as total, COUNT(*) FILTER (WHERE is_active = true) as active FROM data_entry_fields")
    total, active = cur.fetchone()
    print(f"\n{'='*60}")
    print(f"✅ Final count: {total} total, {active} active")

    cur.close()
    conn.close()

if __name__ == '__main__':
    main()
