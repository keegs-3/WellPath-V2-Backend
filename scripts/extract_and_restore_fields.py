#!/usr/bin/env python3
"""
Extract and Restore Missing data_entry_fields

This script:
1. Reads missing field_ids
2. Extracts ONLY the INSERT INTO data_entry_fields statements (no CREATE TABLE, no reference inserts)
3. Executes them with ON CONFLICT DO NOTHING
4. Verifies restoration

This avoids schema mismatch issues with evolved database structure.
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

def extract_field_inserts(migration_file, target_fields):
    """
    Extract INSERT INTO data_entry_fields statements for target fields.
    Returns list of (field_id, insert_statement) tuples.
    """
    inserts = []

    try:
        with open(migration_file, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()

        # Pattern to match INSERT INTO data_entry_fields statements
        # Matches multi-line INSERT statements
        pattern = r"INSERT\s+INTO\s+data_entry_fields\s*\([^)]+\)\s*VALUES\s*\n?\s*\(([^;]+?)\)\s*(?:ON\s+CONFLICT[^;]+)?;"

        for match in re.finditer(pattern, content, re.IGNORECASE | re.DOTALL):
            values_part = match.group(1)

            # Extract field_id from the values (first value is usually field_id)
            field_id_match = re.search(r"'(DEF_[A-Z_0-9]+)'", values_part)
            if field_id_match:
                field_id = field_id_match.group(1)

                if field_id in target_fields:
                    # Get full insert statement
                    full_insert = match.group(0)
                    inserts.append((field_id, full_insert))

    except Exception as e:
        print(f"   ⚠️  Error processing {migration_file}: {e}")

    return inserts

def main():
    print("="*80)
    print("EXTRACT AND RESTORE MISSING DATA_ENTRY_FIELDS")
    print("="*80)

    # Step 1: Load missing field_ids
    print("\n📋 Loading missing field_ids...")
    with open('/tmp/missing_fields_valid.txt', 'r') as f:
        missing_fields = set(line.strip() for line in f if line.strip())

    print(f"   ✓ Found {len(missing_fields)} missing fields to restore")

    # Step 2: Connect to database
    print("\n🔌 Connecting to database...")
    conn = psycopg2.connect(DATABASE_URL)
    cur = conn.cursor()

    # Step 3: Get current fields
    print("\n🔍 Checking current data_entry_fields...")
    cur.execute("SELECT field_id FROM data_entry_fields")
    existing_fields = set(row[0] for row in cur.fetchall())
    print(f"   ✓ Found {len(existing_fields)} existing fields")

    # Filter to only truly missing fields
    truly_missing = missing_fields - existing_fields
    print(f"   ✓ {len(truly_missing)} fields need restoration")

    if len(truly_missing) == 0:
        print("\n✅ All fields are already present!")
        cur.close()
        conn.close()
        return

    # Step 4: Scan all migrations for INSERT statements
    print("\n🔍 Extracting INSERT statements from migrations...")
    migrations_dir = 'supabase/migrations'
    all_inserts = []  # list of (field_id, insert_sql)

    for filename in sorted(os.listdir(migrations_dir)):
        if not filename.endswith('.sql'):
            continue

        filepath = os.path.join(migrations_dir, filename)
        inserts = extract_field_inserts(filepath, truly_missing)

        if inserts:
            print(f"   Found {len(inserts)} fields in {filename}")
            all_inserts.extend(inserts)

    # Deduplicate by field_id (keep last occurrence)
    field_insert_map = {}
    for field_id, insert_sql in all_inserts:
        field_insert_map[field_id] = insert_sql

    print(f"\n   ✓ Extracted {len(field_insert_map)} unique field INSERT statements")

    # Step 5: Execute INSERT statements
    print("\n🔄 Executing INSERT statements...")
    restored_count = 0
    errors = []

    for field_id, insert_sql in field_insert_map.items():
        try:
            # Ensure it has ON CONFLICT DO NOTHING
            if 'ON CONFLICT' not in insert_sql.upper():
                # Add it before the semicolon
                insert_sql = insert_sql.rstrip(';') + ' ON CONFLICT (field_id) DO NOTHING;'

            cur.execute(insert_sql)
            conn.commit()
            restored_count += 1

            if restored_count % 10 == 0:
                print(f"   Restored {restored_count}/{len(field_insert_map)} fields...")

        except Exception as e:
            error_msg = str(e)[:200]
            errors.append((field_id, error_msg))
            print(f"   ❌ {field_id}: {error_msg}")
            conn.rollback()

    print(f"\n   ✓ Restored {restored_count} fields")
    print(f"   ❌ {len(errors)} errors")

    # Step 6: Verify restoration
    print("\n✅ Verifying restoration...")
    cur.execute("SELECT COUNT(*) as total, COUNT(*) FILTER (WHERE is_active = true) as active FROM data_entry_fields")
    total, active = cur.fetchone()
    print(f"   Total fields: {total}")
    print(f"   Active fields: {active}")

    # Check still missing
    cur.execute("SELECT field_id FROM data_entry_fields")
    current_fields = set(row[0] for row in cur.fetchall())
    still_missing = truly_missing - current_fields

    print(f"\n   Still missing: {len(still_missing)} fields")

    if len(still_missing) > 0 and len(still_missing) <= 50:
        print("\n   Missing fields:")
        for field in sorted(still_missing):
            print(f"     - {field}")

    # Step 7: Summary
    print("\n" + "="*80)
    print("RESTORATION SUMMARY")
    print("="*80)
    print(f"✅ Restored {restored_count} data_entry_fields")
    print(f"⚠️  {len(still_missing)} fields still missing")
    print(f"❌ {len(errors)} errors encountered")

    if len(still_missing) > 0:
        # Save still missing to file for next iteration
        with open('/tmp/still_missing_fields.txt', 'w') as f:
            for field in sorted(still_missing):
                f.write(field + '\n')
        print(f"\n📄 Still-missing fields saved to /tmp/still_missing_fields.txt")

    cur.close()
    conn.close()

if __name__ == '__main__':
    main()
