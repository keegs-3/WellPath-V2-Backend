#!/usr/bin/env python3
"""
Populate aggregation mappings for protein and calorie tracking questions.
Simple binary logic: if user tracks ANY data → "Yes", otherwise keep original answer.
"""

import psycopg2

DATABASE_URL = "postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres"

# Mappings for tracking questions
TRACKING_MAPPINGS = [
    {
        'response_option_id': 'RO_2.09-1',  # "Yes" for protein tracking
        'question_number': 2.09,
        'agg_metric_id': 'AGG_PROTEIN_GRAMS',
        'threshold_low': 0.001,  # Any value > 0
        'threshold_high': None,  # No upper limit
        'calculation_type_id': 'SUM',
        'period_type': 'daily',
        'min_data_points': 1,  # Just need 1 data point
        'lookback_days': 7,  # Check last week
        'notes': 'If user has tracked any protein in last 7 days → "Yes" (score 1.0)'
    },
    {
        'response_option_id': 'RO_2.59-1',  # "Yes" for calorie tracking
        'question_number': 2.59,
        'agg_metric_id': 'AGG_CALORIES',
        'threshold_low': 0.001,  # Any value > 0
        'threshold_high': None,  # No upper limit
        'calculation_type_id': 'SUM',
        'period_type': 'daily',
        'min_data_points': 1,  # Just need 1 data point
        'lookback_days': 7,  # Check last week
        'notes': 'If user has tracked any calories in last 7 days → "Yes" (score 1.0)'
    }
]

def populate_tracking_mappings():
    """Populate tracking question aggregation mappings"""
    conn = psycopg2.connect(DATABASE_URL)
    cur = conn.cursor()

    try:
        print("="*60)
        print("TRACKING QUESTION AGGREGATION MAPPINGS")
        print("="*60)
        print()

        created_count = 0

        for mapping in TRACKING_MAPPINGS:
            # Check if already exists
            cur.execute("""
                SELECT 1 FROM survey_response_options_aggregations
                WHERE response_option_id = %s
            """, (mapping['response_option_id'],))

            if cur.fetchone():
                print(f"  - Mapping already exists for {mapping['response_option_id']}")
                continue

            # Insert mapping
            cur.execute("""
                INSERT INTO survey_response_options_aggregations (
                    response_option_id,
                    question_number,
                    agg_metric_id,
                    threshold_low,
                    threshold_high,
                    calculation_type_id,
                    period_type,
                    min_data_points,
                    lookback_days,
                    notes,
                    is_active
                )
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            """, (
                mapping['response_option_id'],
                mapping['question_number'],
                mapping['agg_metric_id'],
                mapping['threshold_low'],
                mapping['threshold_high'],
                mapping['calculation_type_id'],
                mapping['period_type'],
                mapping['min_data_points'],
                mapping['lookback_days'],
                mapping['notes'],
                True
            ))

            print(f"  ✓ Created mapping for Q{mapping['question_number']}: {mapping['agg_metric_id']}")
            created_count += 1

        conn.commit()

        print()
        print("="*60)
        print("SUMMARY")
        print("="*60)
        print(f"  Created: {created_count} new mappings")
        print()
        print("✅ Tracking question mappings complete!")
        print("="*60)
        print()
        print("How it works:")
        print("  • Q2.09 (protein): If AGG_PROTEIN_GRAMS > 0 → auto-update to 'Yes' (1.0)")
        print("  • Q2.59 (calories): If AGG_CALORIES > 0 → auto-update to 'Yes' (1.0)")
        print("  • Users who answered 'No' or 'No, but aware' will be upgraded once they track")

    except Exception as e:
        conn.rollback()
        print(f"❌ Error populating mappings: {e}")
        import traceback
        traceback.print_exc()
        raise
    finally:
        cur.close()
        conn.close()

if __name__ == '__main__':
    populate_tracking_mappings()
