#!/usr/bin/env python3
"""
Comprehensive Output Field Restoration

Extracts INSERT INTO data_entry_fields from all output field migration files
and executes them individually to restore output fields.
"""

import psycopg2
import os
import re

def read_database_url():
    env_path = os.path.join(os.path.dirname(__file__), '..', '.env')
    with open(env_path) as f:
        for line in f:
            if line.startswith('DATABASE_URL='):
                return line.split('=', 1)[1].strip()
    raise ValueError("DATABASE_URL not found in .env file")

DATABASE_URL = read_database_url()

# Migrations that define output fields
OUTPUT_FIELD_MIGRATIONS = [
    "20251021_create_field_registry.sql",
    "20251021_add_session_counts_to_field_registry.sql",
    "20251021_create_duration_output_fields.sql",
    "20251021_create_distance_output_fields.sql",
]

def extract_field_inserts_from_file(filepath):
    """
    Extract individual field INSERT statements from a migration file.
    Returns list of (field_id, insert_sql) tuples.
    """
    inserts = []

    try:
        with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()

        # Remove CREATE TABLE, CREATE INDEX statements
        # Only keep INSERT INTO data_entry_fields portions

        # Pattern 1: Multi-value INSERT
        # INSERT INTO data_entry_fields (...) VALUES (...), (...), (...)
        pattern1 = r"INSERT\s+INTO\s+data_entry_fields\s*\([^)]+\)\s*VALUES\s*((?:\([^)]+\)\s*,?\s*)+)\s*(?:ON\s+CONFLICT[^;]+)?;"

        for match in re.finditer(pattern1, content, re.IGNORECASE | re.DOTALL):
            values_section = match.group(1)

            # Split by ),( to get individual value sets
            # But handle nested parentheses in jsonb
            value_sets = []
            depth = 0
            current_set = ""

            for char in values_section:
                if char == '(':
                    if depth > 0:
                        current_set += char
                    depth += 1
                elif char == ')':
                    depth -= 1
                    if depth == 0:
                        if current_set.strip():
                            value_sets.append(current_set.strip())
                        current_set = ""
                    else:
                        current_set += char
                elif depth > 0:
                    current_set += char

            # For each value set, extract field_id and create individual INSERT
            for value_set in value_sets:
                field_id_match = re.search(r"'(DEF_[A-Z_0-9]+)'", value_set)
                if field_id_match:
                    field_id = field_id_match.group(1)

                    # Reconstruct individual INSERT statement
                    # Extract column list from original
                    col_match = re.search(r"INSERT\s+INTO\s+data_entry_fields\s*\(([^)]+)\)", match.group(0), re.IGNORECASE)
                    if col_match:
                        columns = col_match.group(1)
                        insert_sql = f"INSERT INTO data_entry_fields ({columns}) VALUES ({value_set}) ON CONFLICT (field_id) DO NOTHING;"
                        inserts.append((field_id, insert_sql))

    except Exception as e:
        print(f"Error processing {filepath}: {e}")

    return inserts

def main():
    print("="*80)
    print("COMPREHENSIVE OUTPUT FIELD RESTORATION")
    print("="*80)

    conn = psycopg2.connect(DATABASE_URL)
    cur = conn.cursor()

    # Get starting count
    cur.execute("SELECT COUNT(*) FROM data_entry_fields")
    starting_count = cur.fetchone()[0]
    print(f"\n📊 Starting field count: {starting_count}")

    all_inserts = []

    # Extract from all migrations
    print("\n🔍 Extracting output field definitions...")
    for migration in OUTPUT_FIELD_MIGRATIONS:
        filepath = f"supabase/migrations/{migration}"

        if not os.path.exists(filepath):
            print(f"   ⚠️  {migration} not found")
            continue

        inserts = extract_field_inserts_from_file(filepath)
        if inserts:
            print(f"   Found {len(inserts)} fields in {migration}")
            all_inserts.extend(inserts)

    # Deduplicate by field_id (keep last)
    field_map = {}
    for field_id, insert_sql in all_inserts:
        field_map[field_id] = insert_sql

    print(f"\n   ✓ Total unique output fields to restore: {len(field_map)}")

    # Execute inserts
    print("\n🔄 Restoring output fields...")
    restored = 0
    errors = []

    for field_id, insert_sql in field_map.items():
        try:
            cur.execute(insert_sql)
            conn.commit()
            restored += 1

            if restored % 20 == 0:
                print(f"   Restored {restored}/{len(field_map)} fields...")

        except Exception as e:
            error_msg = str(e)[:150]
            errors.append((field_id, error_msg))
            conn.rollback()

    print(f"\n   ✅ Restored {restored} fields")
    print(f"   ❌ {len(errors)} errors")

    # Final count
    cur.execute("SELECT COUNT(*) as total, COUNT(*) FILTER (WHERE is_active = true) as active FROM data_entry_fields")
    total, active = cur.fetchone()

    print(f"\n📊 Final field count: {total} total, {active} active")
    print(f"   Added: {total - starting_count} fields")

    if errors and len(errors) <= 20:
        print("\n❌ Errors:")
        for field_id, error in errors:
            print(f"   {field_id}: {error}")

    cur.close()
    conn.close()

    print("\n" + "="*80)
    print("RESTORATION COMPLETE")
    print("="*80)

if __name__ == '__main__':
    main()
