#!/usr/bin/env python3
"""Check which aggregations exist in the database"""

import psycopg2

DB_URL = 'postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres'

NEEDED_AGGS = [
    'AGG_PROTEIN_GRAMS',
    'AGG_PROTEIN_BREAKFAST_GRAMS',
    'AGG_PROTEIN_LUNCH_GRAMS',
    'AGG_PROTEIN_DINNER_GRAMS',
    'AGG_PROTEIN_PER_KILOGRAM_BODY_WEIGHT',
    'AGG_PLANTBASED_PROTEIN',
    'AGG_PLANTBASED_PROTEIN_PERCENTAGE',
    'AGG_STEPS',
    'AGG_FIBER_GRAMS',
    'AGG_FIBER_SERVINGS',
    'AGG_FIBER_SOURCE_COUNT',
    'AGG_WATER_OUNCES',
    'AGG_WEIGHT',
    'AGG_BMI',
    'AGG_CARDIO_DURATION',
    'AGG_CARDIO_SESSIONS',
    'AGG_CARDIO_CALORIES',
    'AGG_TOTAL_SLEEP_DURATION',
    'AGG_REM_SLEEP_DURATION',
    'AGG_DEEP_SLEEP_DURATION',
    'AGG_AWAKE_DURATION'
]

def main():
    conn = psycopg2.connect(DB_URL)

    try:
        with conn.cursor() as cur:
            for agg_id in NEEDED_AGGS:
                cur.execute("SELECT agg_id, metric_name FROM aggregation_metrics WHERE agg_id = %s", (agg_id,))
                result = cur.fetchone()
                if result:
                    print(f"✅ {agg_id:50s} → {result[1]}")
                else:
                    print(f"❌ {agg_id:50s} MISSING")
    finally:
        conn.close()

if __name__ == '__main__':
    main()
