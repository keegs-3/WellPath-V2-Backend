#!/usr/bin/env python3
"""
Safe Airtable CSV Update Script
Purpose: Update existing Supabase tables with new columns from Airtable CSV exports
         WITHOUT deleting existing data or breaking foreign keys

Usage:
    python3 update_table_from_airtable.py --table survey_questions --csv path/to/export.csv
    python3 update_table_from_airtable.py --table intake_metrics_raw --csv path/to/export.csv

This script:
1. Reads the CSV export from Airtable
2. UPDATEs existing rows based on record_id
3. INSERTs new rows that don't exist
4. Preserves all existing data and foreign key relationships
"""

import os
import sys
import csv
import argparse
import psycopg2
from psycopg2.extras import execute_values
from typing import List, Dict, Any


# Database connection from environment
DATABASE_URL = os.getenv('DATABASE_URL',
    'postgresql://postgres.csotzmardnvrpdhlogjm:qLa4sE9zV1yvxCP4@aws-1-us-west-1.pooler.supabase.com:6543/postgres'
)


def connect_db():
    """Connect to Supabase PostgreSQL."""
    return psycopg2.connect(DATABASE_URL)


def get_existing_record_ids(conn, table_name: str) -> set:
    """Get all existing record_ids from the table."""
    with conn.cursor() as cur:
        cur.execute(f"SELECT record_id FROM {table_name}")
        return {row[0] for row in cur.fetchall()}


def read_csv_file(csv_path: str) -> List[Dict[str, Any]]:
    """Read CSV file and return list of row dictionaries."""
    with open(csv_path, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        return list(reader)


def sanitize_column_name(name: str) -> str:
    """Convert Airtable column names to PostgreSQL-safe names."""
    # Replace spaces and special chars with underscores
    return name.lower().replace(' ', '_').replace('(', '').replace(')', '').replace('-', '_')


def update_existing_row(conn, table_name: str, record_id: str, row_data: Dict[str, Any]):
    """Update an existing row with new column values."""
    # Build SET clause for columns that have values
    set_clauses = []
    params = []

    for column, value in row_data.items():
        if column != 'record_id' and value:  # Skip record_id and empty values
            column_safe = sanitize_column_name(column)
            set_clauses.append(f"{column_safe} = %s")
            params.append(value)

    if not set_clauses:
        return  # No columns to update

    # Add record_id to params for WHERE clause
    params.append(record_id)

    query = f"""
        UPDATE {table_name}
        SET {', '.join(set_clauses)}
        WHERE record_id = %s
    """

    with conn.cursor() as cur:
        cur.execute(query, params)


def insert_new_row(conn, table_name: str, row_data: Dict[str, Any]):
    """Insert a new row."""
    # Get column names and values
    columns = [sanitize_column_name(k) for k in row_data.keys()]
    values = list(row_data.values())

    placeholders = ','.join(['%s'] * len(columns))
    columns_str = ','.join(columns)

    query = f"""
        INSERT INTO {table_name} ({columns_str})
        VALUES ({placeholders})
    """

    with conn.cursor() as cur:
        cur.execute(query, values)


def update_table_from_csv(table_name: str, csv_path: str, dry_run: bool = False):
    """
    Main function to update table from CSV.

    Args:
        table_name: Name of the Supabase table to update
        csv_path: Path to the Airtable CSV export
        dry_run: If True, only show what would be done without making changes
    """
    print(f"\n{'='*80}")
    print(f"UPDATING {table_name.upper()} FROM AIRTABLE CSV")
    print(f"{'='*80}\n")

    # Read CSV
    print(f"Reading CSV from: {csv_path}")
    rows = read_csv_file(csv_path)
    print(f"✓ Found {len(rows)} rows in CSV\n")

    # Connect to database
    print("Connecting to Supabase...")
    conn = connect_db()

    try:
        # Get existing record IDs
        print(f"Fetching existing record_ids from {table_name}...")
        existing_ids = get_existing_record_ids(conn, table_name)
        print(f"✓ Found {len(existing_ids)} existing records\n")

        # Process each row
        updates = 0
        inserts = 0
        errors = []

        for i, row in enumerate(rows, 1):
            record_id = row.get('record_id')
            if not record_id:
                errors.append(f"Row {i}: Missing record_id")
                continue

            try:
                if record_id in existing_ids:
                    # Update existing row
                    if not dry_run:
                        update_existing_row(conn, table_name, record_id, row)
                    updates += 1
                    if i % 50 == 0:
                        print(f"  Processed {i}/{len(rows)} rows... ({updates} updates, {inserts} inserts)")
                else:
                    # Insert new row
                    if not dry_run:
                        insert_new_row(conn, table_name, row)
                    inserts += 1
                    if i % 50 == 0:
                        print(f"  Processed {i}/{len(rows)} rows... ({updates} updates, {inserts} inserts)")

            except Exception as e:
                errors.append(f"Row {i} (record_id: {record_id}): {str(e)}")

        # Commit changes
        if not dry_run:
            conn.commit()
            print(f"\n✓ Transaction committed successfully!\n")
        else:
            conn.rollback()
            print(f"\n[DRY RUN] No changes made to database\n")

        # Print summary
        print(f"{'='*80}")
        print(f"SUMMARY")
        print(f"{'='*80}")
        print(f"  Rows updated: {updates}")
        print(f"  Rows inserted: {inserts}")
        print(f"  Total processed: {updates + inserts}")
        print(f"  Errors: {len(errors)}")

        if errors:
            print(f"\n{'='*80}")
            print(f"ERRORS")
            print(f"{'='*80}")
            for error in errors[:20]:  # Show first 20 errors
                print(f"  {error}")
            if len(errors) > 20:
                print(f"  ... and {len(errors) - 20} more errors")

        print(f"\n{'='*80}\n")

    except Exception as e:
        conn.rollback()
        print(f"\n✗ ERROR: {e}\n")
        raise
    finally:
        conn.close()


def main():
    parser = argparse.ArgumentParser(
        description='Update Supabase table from Airtable CSV export (safe, no deletions)'
    )
    parser.add_argument(
        '--table',
        required=True,
        choices=['survey_questions', 'intake_metrics_raw', 'calculated_metrics_vfinal',
                 'metric_types_vfinal', 'screening_compliance_matrix'],
        help='Name of the table to update'
    )
    parser.add_argument(
        '--csv',
        required=True,
        help='Path to the Airtable CSV export file'
    )
    parser.add_argument(
        '--dry-run',
        action='store_true',
        help='Run without making changes (preview only)'
    )

    args = parser.parse_args()

    # Verify CSV exists
    if not os.path.exists(args.csv):
        print(f"ERROR: CSV file not found: {args.csv}")
        sys.exit(1)

    # Run update
    try:
        update_table_from_csv(args.table, args.csv, args.dry_run)
        print("✓ Update completed successfully!")
    except Exception as e:
        print(f"✗ Update failed: {e}")
        sys.exit(1)


if __name__ == '__main__':
    main()
