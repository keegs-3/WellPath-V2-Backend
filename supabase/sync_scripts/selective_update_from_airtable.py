#!/usr/bin/env python3
"""
Selective Update Airtable CSVs to Supabase
Allows specifying which tables to update via command line arguments

Usage:
    python selective_update_from_airtable.py intake_metrics_raw intake_markers_raw
    python selective_update_from_airtable.py --all  # Update all tables
"""

import os
import sys
import csv
import argparse
import psycopg2
from psycopg2.extras import RealDictCursor
from pathlib import Path

# Database connection
DATABASE_URL = os.getenv('DATABASE_URL',
    'postgresql://postgres.csotzmardnvrpdhlogjm:qLa4sE9zV1yvxCP4@aws-1-us-west-1.pooler.supabase.com:6543/postgres'
)

# Use local ALL_AIRTABLE directory
SCRIPT_DIR = Path(__file__).parent
PROJECT_ROOT = SCRIPT_DIR.parent.parent
CSV_DIR = PROJECT_ROOT / "ALL_AIRTABLE" / "csvs"


def connect_db():
    """Connect to Supabase PostgreSQL."""
    return psycopg2.connect(DATABASE_URL, cursor_factory=RealDictCursor)


def table_exists(conn, table_name: str) -> bool:
    """Check if table exists in database."""
    with conn.cursor() as cur:
        cur.execute("""
            SELECT EXISTS (
                SELECT FROM information_schema.tables
                WHERE table_schema = 'public'
                AND table_name = %s
            )
        """, (table_name,))
        return cur.fetchone()['exists']


def get_table_columns(conn, table_name: str) -> set:
    """Get all column names for a table."""
    with conn.cursor() as cur:
        cur.execute("""
            SELECT column_name
            FROM information_schema.columns
            WHERE table_schema = 'public'
            AND table_name = %s
        """, (table_name,))
        return {row['column_name'] for row in cur.fetchall()}


def sanitize_column_name(name: str) -> str:
    """Convert Airtable column names to PostgreSQL-safe names."""
    return name.lower().replace(' ', '_').replace('(', '').replace(')', '').replace('-', '_')


def get_existing_record_ids(conn, table_name: str) -> set:
    """Get all existing record_ids from the table."""
    with conn.cursor() as cur:
        cur.execute(f"SELECT record_id FROM {table_name}")
        return {row['record_id'] for row in cur.fetchall()}


def update_table_from_csv(conn, table_name: str, csv_path: str) -> dict:
    """Update table from CSV file."""
    # Read CSV
    print(f"  Reading CSV...", end=' ', flush=True)
    with open(csv_path, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        rows = list(reader)

    if not rows:
        return {'status': 'skipped', 'reason': 'empty CSV', 'updates': 0, 'inserts': 0}

    print(f"{len(rows)} rows", end=' ', flush=True)

    # Get table columns
    table_columns = get_table_columns(conn, table_name)

    # Get CSV columns that exist in table
    csv_columns = {sanitize_column_name(k): k for k in rows[0].keys()}
    valid_columns = {k: v for k, v in csv_columns.items() if k in table_columns}

    if 'record_id' not in valid_columns:
        return {'status': 'skipped', 'reason': 'no record_id column', 'updates': 0, 'inserts': 0}

    # Get existing record IDs
    existing_ids = get_existing_record_ids(conn, table_name)

    updates = 0
    inserts = 0
    errors = 0

    for row in rows:
        record_id = row.get('record_id')
        if not record_id:
            errors += 1
            continue

        try:
            # Build data dict with only valid columns
            data = {}
            for db_col, csv_col in valid_columns.items():
                if csv_col in row and row[csv_col]:
                    value = row[csv_col]
                    # Handle comma-separated Airtable linked records - take first only
                    if db_col in ['metric_types_vfinal', 'calculated_metrics_vfinal', 'screening_compliance_matrix']:
                        value = value.split(',')[0].strip()
                    data[db_col] = value

            if record_id in existing_ids:
                # UPDATE existing row
                if len(data) > 1:  # More than just record_id
                    set_clauses = []
                    params = []
                    for col, val in data.items():
                        if col != 'record_id':
                            set_clauses.append(f"{col} = %s")
                            params.append(val)

                    if set_clauses:
                        params.append(record_id)
                        query = f"UPDATE {table_name} SET {', '.join(set_clauses)} WHERE record_id = %s"
                        with conn.cursor() as cur:
                            cur.execute(query, params)
                        updates += 1
            else:
                # INSERT new row
                columns = list(data.keys())
                values = list(data.values())
                placeholders = ','.join(['%s'] * len(columns))
                columns_str = ','.join(columns)
                query = f"INSERT INTO {table_name} ({columns_str}) VALUES ({placeholders})"
                with conn.cursor() as cur:
                    cur.execute(query, values)
                inserts += 1

        except Exception as e:
            errors += 1
            print(f"\n    ERROR on record {record_id}: {str(e)}")

    conn.commit()
    return {'status': 'success', 'updates': updates, 'inserts': inserts, 'errors': errors}


def main():
    parser = argparse.ArgumentParser(description='Selectively update Supabase tables from Airtable CSVs')
    parser.add_argument('tables', nargs='*', help='Table names to update (e.g., intake_metrics_raw)')
    parser.add_argument('--all', action='store_true', help='Update all tables')
    parser.add_argument('--list', action='store_true', help='List available CSV files')

    args = parser.parse_args()

    # List available CSVs if requested
    if args.list:
        csv_files = sorted(Path(CSV_DIR).glob('*.csv'))
        print(f"\nAvailable CSV files in {CSV_DIR}:\n")
        for csv_file in csv_files:
            print(f"  - {csv_file.stem}")
        print(f"\nTotal: {len(csv_files)} files\n")
        return

    # Validate arguments
    if not args.all and not args.tables:
        parser.error("Must specify table names or use --all flag")
        return

    print(f"\n{'='*80}")
    print(f"SELECTIVE UPDATE AIRTABLE CSVS TO SUPABASE")
    print(f"{'='*80}\n")

    # Determine which tables to update
    if args.all:
        csv_files = sorted(Path(CSV_DIR).glob('*.csv'))
        table_names = [f.stem for f in csv_files]
        print(f"Updating ALL {len(table_names)} tables\n")
    else:
        table_names = args.tables
        print(f"Updating {len(table_names)} tables: {', '.join(table_names)}\n")

    # Connect to database
    conn = connect_db()

    results = []

    for i, table_name in enumerate(table_names, 1):
        csv_path = CSV_DIR / f"{table_name}.csv"

        print(f"[{i}/{len(table_names)}] {table_name}...", end=' ', flush=True)

        # Check if CSV exists
        if not csv_path.exists():
            results.append({
                'table': table_name,
                'status': 'skipped',
                'reason': 'CSV file not found',
                'updates': 0,
                'inserts': 0
            })
            print(f"⊘ CSV not found")
            continue

        # Check if table exists
        if not table_exists(conn, table_name):
            results.append({
                'table': table_name,
                'status': 'skipped',
                'reason': 'table does not exist',
                'updates': 0,
                'inserts': 0
            })
            print(f"⊘ table not in Supabase")
            continue

        try:
            result = update_table_from_csv(conn, table_name, str(csv_path))
            result['table'] = table_name
            results.append(result)

            if result['status'] == 'success':
                print(f"✓ {result['updates']} updates, {result['inserts']} inserts")
            else:
                print(f"⊘ {result['reason']}")

        except Exception as e:
            results.append({
                'table': table_name,
                'status': 'error',
                'reason': str(e),
                'updates': 0,
                'inserts': 0
            })
            print(f"✗ {str(e)[:60]}")

        sys.stdout.flush()

    conn.close()

    # Print summary
    print(f"\n{'='*80}")
    print(f"SUMMARY")
    print(f"{'='*80}\n")

    successful = [r for r in results if r['status'] == 'success']
    skipped = [r for r in results if r['status'] == 'skipped']
    errored = [r for r in results if r['status'] == 'error']

    print(f"Total tables processed: {len(table_names)}")
    print(f"  ✓ Successfully updated: {len(successful)}")
    print(f"  ⊘ Skipped: {len(skipped)}")
    print(f"  ✗ Errors: {len(errored)}\n")

    if successful:
        total_updates = sum(r['updates'] for r in successful)
        total_inserts = sum(r['inserts'] for r in successful)
        print(f"Total rows updated: {total_updates}")
        print(f"Total rows inserted: {total_inserts}\n")

    if successful:
        print("Successfully Updated Tables:")
        for r in successful:
            print(f"  ✓ {r['table']}: {r['updates']} updates, {r['inserts']} inserts")

    if skipped:
        print(f"\nSkipped Tables:")
        for r in skipped:
            print(f"  ⊘ {r['table']}: {r['reason']}")

    if errored:
        print(f"\nErrors:")
        for r in errored:
            print(f"  ✗ {r['table']}: {r['reason'][:60]}")

    print(f"\n{'='*80}\n")


if __name__ == '__main__':
    main()
