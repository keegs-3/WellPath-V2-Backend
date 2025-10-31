#!/usr/bin/env python3
"""
Simple historical score generator - duplicates current scores with backdated timestamps
"""

import psycopg2
from datetime import datetime, timedelta
import random
import json
from psycopg2.extras import Json

DATABASE_URL = "postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:6543/postgres?sslmode=require"

PATIENT_ID = "8b79ce33-02b8-4f49-8268-3204130efa82"

def backdate_table(cur, table_name, patient_id, days_back, new_date):
    """Backdate a single score table"""
    # Get all column names (including id and created_at for proper indexing)
    cur.execute(f"""
        SELECT column_name
        FROM information_schema.columns
        WHERE table_name = '{table_name}'
          AND table_schema = 'public'
        ORDER BY ordinal_position
    """)
    all_columns = [row[0] for row in cur.fetchall()]

    # Get template rows with all columns
    cur.execute(f"""
        SELECT *
        FROM {table_name}
        WHERE patient_id = %s
        ORDER BY calculated_at DESC
        LIMIT 1000
    """, (patient_id,))

    template_rows = cur.fetchall()
    if not template_rows:
        return 0

    # Columns to insert (exclude id and created_at)
    insert_columns = [col for col in all_columns if col not in ('id', 'created_at')]

    count = 0
    for template_row in template_rows:
        # Build VALUES list using column name mapping
        values = []
        for col in insert_columns:
            col_index = all_columns.index(col)
            value = template_row[col_index]

            if col == 'calculated_at':
                values.append(new_date)
            elif 'percentage' in col.lower() and value is not None:
                # Add slight variation to percentages
                varied = float(value) + random.uniform(-2, 2)
                values.append(max(0, min(100, varied)))
            elif col == 'pillar_scores' and value is not None:
                values.append(Json(value))
            else:
                values.append(value)

        # Insert
        placeholders = ','.join(['%s'] * len(insert_columns))
        col_names = ','.join(insert_columns)

        cur.execute(f"""
            INSERT INTO {table_name} ({col_names})
            VALUES ({placeholders})
        """, values)
        count += 1

    return count

def backdate_scores(days_back=90):
    """Duplicate current scores going back N days with slight variations"""
    conn = psycopg2.connect(DATABASE_URL)
    cur = conn.cursor()

    try:
        print(f"Backdating ALL scores for {days_back} days")
        print("="*80)

        tables = [
            'patient_wellpath_scores_history',
            'patient_pillar_scores_history',
            'patient_component_scores_history',
            'patient_item_scores_history'
        ]

        total_created = 0

        # Create historical entries for each day
        for day_offset in range(-days_back, 0):
            new_date = datetime.now() + timedelta(days=day_offset)

            day_total = 0
            for table_name in tables:
                count = backdate_table(cur, table_name, PATIENT_ID, days_back, new_date)
                day_total += count

            total_created += day_total

            if day_offset % 10 == 0:
                print(f"  Day {day_offset} ({new_date.date()}): Created {day_total} scores")

        conn.commit()

        print(f"\n✅ Created {total_created} historical scores across all tables")

        # Show stats for each table
        for table_name in tables:
            cur.execute(f"""
                SELECT
                    COUNT(*) as total,
                    MIN(calculated_at)::date as earliest,
                    MAX(calculated_at)::date as latest
                FROM {table_name}
                WHERE patient_id = %s
            """, (PATIENT_ID,))

            stats = cur.fetchone()
            print(f"\n{table_name}:")
            print(f"  Total: {stats[0]}, Range: {stats[1]} to {stats[2]}")

    except Exception as e:
        conn.rollback()
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()
    finally:
        cur.close()
        conn.close()

if __name__ == '__main__':
    backdate_scores(days_back=90)
