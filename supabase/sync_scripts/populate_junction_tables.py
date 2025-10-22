#!/usr/bin/env python3
"""
Populate junction tables from Airtable CSV exports
Handles comma-separated linked records from Airtable
"""

import os
import csv
import psycopg2
from psycopg2.extras import execute_values
from pathlib import Path

DATABASE_URL = os.getenv('DATABASE_URL',
    'postgresql://postgres.csotzmardnvrpdhlogjm:qLa4sE9zV1yvxCP4@aws-1-us-west-1.pooler.supabase.com:6543/postgres'
)

# Use local ALL_AIRTABLE directory (self-contained)
SCRIPT_DIR = Path(__file__).parent
PROJECT_ROOT = SCRIPT_DIR.parent.parent
CSV_DIR = str(PROJECT_ROOT / "ALL_AIRTABLE" / "csvs")


def connect_db():
    return psycopg2.connect(DATABASE_URL)


def populate_intake_metric_junction_tables(conn):
    """Populate junction tables for intake_metrics_raw"""

    csv_path = f"{CSV_DIR}/intake_metrics_raw.csv"

    with open(csv_path, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        rows = list(reader)

    metric_types_links = []
    calc_metrics_links = []

    for row in rows:
        intake_metric_id = row['record_id']

        # Parse metric_types_vfinal (comma-separated)
        if row.get('metric_types_vfinal'):
            metric_type_ids = [mid.strip() for mid in row['metric_types_vfinal'].split(',')]
            for metric_type_id in metric_type_ids:
                if metric_type_id:
                    metric_types_links.append((intake_metric_id, metric_type_id))

        # Parse calculated_metrics_vfinal (comma-separated)
        if row.get('calculated_metrics_vfinal'):
            calc_metric_ids = [cid.strip() for cid in row['calculated_metrics_vfinal'].split(',')]
            for calc_metric_id in calc_metric_ids:
                if calc_metric_id:
                    calc_metrics_links.append((intake_metric_id, calc_metric_id))

    # Insert metric_types links
    if metric_types_links:
        with conn.cursor() as cur:
            execute_values(
                cur,
                """
                INSERT INTO intake_metric_metric_types (intake_metric_id, metric_type_id)
                VALUES %s
                ON CONFLICT (intake_metric_id, metric_type_id) DO NOTHING
                """,
                metric_types_links
            )
        print(f"  ✓ Inserted {len(metric_types_links)} intake_metric -> metric_type links")

    # Insert calculated_metrics links
    if calc_metrics_links:
        with conn.cursor() as cur:
            execute_values(
                cur,
                """
                INSERT INTO intake_metric_calculated_metrics (intake_metric_id, calculated_metric_id)
                VALUES %s
                ON CONFLICT (intake_metric_id, calculated_metric_id) DO NOTHING
                """,
                calc_metrics_links
            )
        print(f"  ✓ Inserted {len(calc_metrics_links)} intake_metric -> calculated_metric links")


def populate_survey_question_junction_tables(conn):
    """Populate junction tables for survey_questions"""

    csv_path = f"{CSV_DIR}/survey_questions.csv"

    with open(csv_path, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        rows = list(reader)

    metric_types_links = []
    calc_metrics_links = []
    screening_links = []

    for row in rows:
        question_id = row['record_id']

        # Parse metric_types_vfinal
        if row.get('metric_types_vfinal'):
            metric_type_ids = [mid.strip() for mid in row['metric_types_vfinal'].split(',')]
            for metric_type_id in metric_type_ids:
                if metric_type_id:
                    metric_types_links.append((question_id, metric_type_id))

        # Parse calculated_metrics_vfinal
        if row.get('calculated_metrics_vfinal'):
            calc_metric_ids = [cid.strip() for cid in row['calculated_metrics_vfinal'].split(',')]
            for calc_metric_id in calc_metric_ids:
                if calc_metric_id:
                    calc_metrics_links.append((question_id, calc_metric_id))

        # Parse screening_compliance_matrix
        if row.get('screening_compliance_matrix'):
            screening_ids = [sid.strip() for sid in row['screening_compliance_matrix'].split(',')]
            for screening_id in screening_ids:
                if screening_id:
                    screening_links.append((question_id, screening_id))

    # Insert metric_types links
    if metric_types_links:
        with conn.cursor() as cur:
            execute_values(
                cur,
                """
                INSERT INTO survey_question_metric_types (survey_question_id, metric_type_id)
                VALUES %s
                ON CONFLICT (survey_question_id, metric_type_id) DO NOTHING
                """,
                metric_types_links
            )
        print(f"  ✓ Inserted {len(metric_types_links)} survey_question -> metric_type links")

    # Insert calculated_metrics links
    if calc_metrics_links:
        with conn.cursor() as cur:
            execute_values(
                cur,
                """
                INSERT INTO survey_question_calculated_metrics (survey_question_id, calculated_metric_id)
                VALUES %s
                ON CONFLICT (survey_question_id, calculated_metric_id) DO NOTHING
                """,
                calc_metrics_links
            )
        print(f"  ✓ Inserted {len(calc_metrics_links)} survey_question -> calculated_metric links")

    # Insert screening_compliance links
    if screening_links:
        with conn.cursor() as cur:
            execute_values(
                cur,
                """
                INSERT INTO survey_question_screening_compliance (survey_question_id, screening_compliance_id)
                VALUES %s
                ON CONFLICT (survey_question_id, screening_compliance_id) DO NOTHING
                """,
                screening_links
            )
        print(f"  ✓ Inserted {len(screening_links)} survey_question -> screening_compliance links")


def main():
    print(f"\n{'='*80}")
    print("POPULATE JUNCTION TABLES FROM AIRTABLE CSVS")
    print(f"{'='*80}\n")

    conn = connect_db()

    try:
        print("Populating intake_metrics_raw junction tables...")
        populate_intake_metric_junction_tables(conn)

        print("\nPopulating survey_questions junction tables...")
        populate_survey_question_junction_tables(conn)

        conn.commit()
        print(f"\n{'='*80}")
        print("✓ All junction tables populated successfully!")
        print(f"{'='*80}\n")

    except Exception as e:
        conn.rollback()
        print(f"\n✗ ERROR: {e}\n")
        raise
    finally:
        conn.close()


if __name__ == '__main__':
    main()
