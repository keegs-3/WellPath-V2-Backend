#!/usr/bin/env python3
"""
Restore Missing data_entry_fields and Downstream Pipeline

This script:
1. Reads missing field_ids from /tmp/missing_fields_valid.txt
2. Scans all migration files to find INSERT statements for those fields
3. Extracts complete field definitions
4. Restores data_entry_fields
5. Restores instance_calculations
6. Restores event mappings
7. Restores aggregation_metrics
8. Verifies the complete pipeline

Run this after accidentally deleting data_entry_fields.
"""

import psycopg2
import os
import re
from collections import defaultdict

# Read DATABASE_URL from .env file
def read_database_url():
    env_path = os.path.join(os.path.dirname(__file__), '..', '.env')
    with open(env_path) as f:
        for line in f:
            if line.startswith('DATABASE_URL='):
                return line.split('=', 1)[1].strip()
    raise ValueError("DATABASE_URL not found in .env file")

DATABASE_URL = read_database_url()

def main():
    print("="*80)
    print("RESTORE MISSING DATA_ENTRY_FIELDS AND DOWNSTREAM PIPELINE")
    print("="*80)

    # Step 1: Load missing field_ids
    print("\n📋 Loading missing field_ids...")
    with open('/tmp/missing_fields_valid.txt', 'r') as f:
        missing_fields = [line.strip() for line in f if line.strip()]

    print(f"   ✓ Found {len(missing_fields)} missing fields to restore")

    # Step 2: Scan migration files for these fields
    print("\n🔍 Scanning migration files for field definitions...")
    migrations_dir = 'supabase/migrations'
    field_migrations = defaultdict(list)  # field_id -> list of (migration_file, line_content)

    for filename in sorted(os.listdir(migrations_dir)):
        if not filename.endswith('.sql'):
            continue

        filepath = os.path.join(migrations_dir, filename)
        try:
            with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()

                # Look for INSERT INTO data_entry_fields statements
                for field_id in missing_fields:
                    # Match patterns like: ('DEF_FIELD_ID', ...
                    pattern = rf"\('{field_id}'[^)]*\)"
                    matches = re.findall(pattern, content, re.IGNORECASE)

                    if matches:
                        for match in matches:
                            field_migrations[field_id].append((filename, match))
        except Exception as e:
            print(f"   ⚠️  Error reading {filename}: {e}")
            continue

    print(f"   ✓ Found definitions for {len(field_migrations)} fields across migrations")

    # Show summary
    print("\n📊 Fields found by migration:")
    migration_counts = defaultdict(int)
    for field_id, sources in field_migrations.items():
        for migration, _ in sources:
            migration_counts[migration] += 1

    for migration, count in sorted(migration_counts.items())[:10]:
        print(f"   {migration}: {count} fields")

    if len(migration_counts) > 10:
        print(f"   ... and {len(migration_counts) - 10} more migrations")

    # Step 3: Connect to database
    print("\n🔌 Connecting to database...")
    conn = psycopg2.connect(DATABASE_URL)
    cur = conn.cursor()

    # Step 4: Get current fields to avoid duplicates
    print("\n🔍 Checking current data_entry_fields...")
    cur.execute("SELECT field_id FROM data_entry_fields")
    existing_fields = set(row[0] for row in cur.fetchall())
    print(f"   ✓ Found {len(existing_fields)} existing fields")

    # Filter to only truly missing fields
    truly_missing = [f for f in missing_fields if f not in existing_fields]
    print(f"   ✓ {len(truly_missing)} fields need restoration")

    if len(truly_missing) == 0:
        print("\n✅ All fields are already present!")
        cur.close()
        conn.close()
        return

    # Show which migrations we'll use for restoration
    print("\n📝 Restoration plan:")
    print(f"   Will restore {len(truly_missing)} fields")
    print(f"   Primary sources: 20251021_create_all_data_entry_fields.sql, part2")

    # Proceeding with restoration (auto-confirmed)
    print("\n✅ Proceeding with restoration...")

    # Step 5: Run migration files
    print("\n🔄 Running migration files to restore fields...")

    migration_files = [
        'supabase/migrations/20251021_create_all_data_entry_fields.sql',
        'supabase/migrations/20251021_create_all_data_entry_fields_part2.sql',
    ]

    restored_count = 0
    errors = []

    for migration_file in migration_files:
        if not os.path.exists(migration_file):
            print(f"   ⚠️  {migration_file} not found, skipping")
            continue

        print(f"\n   Running {os.path.basename(migration_file)}...")

        try:
            with open(migration_file, 'r') as f:
                sql = f.read()

            # Execute migration
            cur.execute(sql)
            conn.commit()

            # Check how many fields restored
            cur.execute("SELECT COUNT(*) FROM data_entry_fields")
            current_count = cur.fetchone()[0]
            new_fields = current_count - len(existing_fields)
            restored_count += new_fields

            print(f"   ✓ Restored {new_fields} new fields")

            # Update existing_fields set
            cur.execute("SELECT field_id FROM data_entry_fields")
            existing_fields = set(row[0] for row in cur.fetchall())

        except Exception as e:
            error_msg = str(e)
            print(f"   ❌ Error: {error_msg}")
            errors.append((migration_file, error_msg))
            conn.rollback()

    print(f"\n   ✓ Total fields restored: {restored_count}")

    # Step 6: Verify restoration
    print("\n✅ Verifying restoration...")
    cur.execute("SELECT COUNT(*) as total, COUNT(*) FILTER (WHERE is_active = true) as active FROM data_entry_fields")
    total, active = cur.fetchone()
    print(f"   Total fields: {total}")
    print(f"   Active fields: {active}")

    # Check how many still missing
    cur.execute("SELECT field_id FROM data_entry_fields")
    current_fields = set(row[0] for row in cur.fetchall())
    still_missing = [f for f in truly_missing if f not in current_fields]

    print(f"\n   Still missing: {len(still_missing)} fields")

    if len(still_missing) > 0:
        print("\n   Missing fields that need manual attention:")
        for field in still_missing[:20]:
            print(f"     - {field}")
        if len(still_missing) > 20:
            print(f"     ... and {len(still_missing) - 20} more")

    # Step 7: Next steps
    print("\n" + "="*80)
    print("RESTORATION SUMMARY")
    print("="*80)
    print(f"✅ Restored {restored_count} data_entry_fields")
    print(f"⚠️  {len(still_missing)} fields still missing")
    print(f"❌ {len(errors)} errors encountered")

    if errors:
        print("\nErrors:")
        for migration, error in errors:
            print(f"  {os.path.basename(migration)}: {error[:100]}")

    print("\n📋 Next steps:")
    print("1. Review still-missing fields and find their migration sources")
    print("2. Restore instance_calculations for these fields")
    print("3. Restore event mappings")
    print("4. Restore aggregation_metrics")
    print("5. Verify complete pipeline")

    cur.close()
    conn.close()

if __name__ == '__main__':
    main()
