#!/usr/bin/env python3
"""
Fast historical score generator - commits every 10 days for better performance
"""

import psycopg2
from datetime import datetime, timedelta
import random
from psycopg2.extras import Json, execute_batch

DATABASE_URL = "postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:6543/postgres?sslmode=require"

PATIENT_ID = "8b79ce33-02b8-4f49-8268-3204130efa82"

def backdate_table_batch(cur, table_name, patient_id, template_rows, all_columns, insert_columns, new_date):
    """Backdate a table using batch insert"""
    if not template_rows:
        return 0

    # Build batch of values
    batch_values = []
    for template_row in template_rows:
        values = []
        for col in insert_columns:
            col_index = all_columns.index(col)
            value = template_row[col_index]

            if col == 'calculated_at':
                values.append(new_date)
            elif 'percentage' in col.lower() and value is not None:
                varied = float(value) + random.uniform(-2, 2)
                values.append(max(0, min(100, varied)))
            elif col == 'pillar_scores' and value is not None:
                values.append(Json(value))
            else:
                values.append(value)

        batch_values.append(tuple(values))

    # Batch insert
    placeholders = ','.join(['%s'] * len(insert_columns))
    col_names = ','.join(insert_columns)

    execute_batch(cur, f"""
        INSERT INTO {table_name} ({col_names})
        VALUES ({placeholders})
    """, batch_values, page_size=100)

    return len(batch_values)

def backdate_scores(days_back=30):
    """Duplicate current scores going back N days - commits every 10 days"""
    conn = psycopg2.connect(DATABASE_URL)
    cur = conn.cursor()

    try:
        print(f"Backdating scores for {days_back} days (commits every 10 days)")
        print("="*80)

        tables = [
            'patient_wellpath_scores_history',
            'patient_pillar_scores_history',
            'patient_component_scores_history',
            'patient_item_scores_history'
        ]

        # Pre-fetch template data and column info for each table
        table_data = {}
        for table_name in tables:
            # Get columns
            cur.execute(f"""
                SELECT column_name
                FROM information_schema.columns
                WHERE table_name = '{table_name}'
                  AND table_schema = 'public'
                ORDER BY ordinal_position
            """)
            all_columns = [row[0] for row in cur.fetchall()]
            insert_columns = [col for col in all_columns if col not in ('id', 'created_at')]

            # Get template rows
            cur.execute(f"""
                SELECT *
                FROM {table_name}
                WHERE patient_id = %s
                ORDER BY calculated_at DESC
                LIMIT 1000
            """, (PATIENT_ID,))
            template_rows = cur.fetchall()

            table_data[table_name] = {
                'all_columns': all_columns,
                'insert_columns': insert_columns,
                'template_rows': template_rows
            }

        print(f"✓ Loaded template data from all tables")

        total_created = 0
        commit_interval = 10

        # Create historical entries for each day
        for day_offset in range(-days_back, 0):
            new_date = datetime.now() + timedelta(days=day_offset)

            day_total = 0
            for table_name in tables:
                data = table_data[table_name]
                count = backdate_table_batch(
                    cur, table_name, PATIENT_ID,
                    data['template_rows'],
                    data['all_columns'],
                    data['insert_columns'],
                    new_date
                )
                day_total += count

            total_created += day_total

            # Commit every 10 days
            if (day_offset + days_back) % commit_interval == 0:
                conn.commit()
                print(f"  Day {day_offset} ({new_date.date()}): Created {day_total} scores [COMMITTED]")
            elif day_offset % 10 == 0:
                print(f"  Day {day_offset} ({new_date.date()}): Created {day_total} scores")

        # Final commit
        conn.commit()

        print(f"\n✅ Created {total_created} historical scores across all tables")

        # Show stats for each table
        for table_name in tables:
            cur.execute(f"""
                SELECT
                    COUNT(*) as total,
                    MIN(calculated_at)::date as earliest,
                    MAX(calculated_at)::date as latest,
                    COUNT(DISTINCT calculated_at::date) as unique_dates
                FROM {table_name}
                WHERE patient_id = %s
            """, (PATIENT_ID,))

            stats = cur.fetchone()
            print(f"\n{table_name}:")
            print(f"  Total: {stats[0]}, Dates: {stats[3]}, Range: {stats[1]} to {stats[2]}")

    except Exception as e:
        conn.rollback()
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()
    finally:
        cur.close()
        conn.close()

if __name__ == '__main__':
    # Start with 30 days instead of 90 for faster testing
    backdate_scores(days_back=30)
