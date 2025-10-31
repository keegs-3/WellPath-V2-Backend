#!/usr/bin/env python3
"""
Process Protein Aggregations with Time and Type Filtering
==========================================================
Custom aggregation processor for protein that handles:
1. Time-based filtering (breakfast/lunch/dinner)
2. Type-based filtering (6 protein types)
"""

import os
import psycopg2
from psycopg2.extras import RealDictCursor
from datetime import datetime, timedelta
from collections import defaultdict

DB_URL = os.getenv('DATABASE_URL', 'postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres')

def get_period_bounds(period_id, reference_date):
    """Get start and end dates for a period"""
    if period_id == 'daily':
        return reference_date, reference_date
    elif period_id == 'weekly':
        start = reference_date - timedelta(days=6)
        return start, reference_date
    elif period_id == 'monthly':
        start = reference_date - timedelta(days=29)
        return start, reference_date
    elif period_id == '6month':
        start = reference_date - timedelta(days=179)
        return start, reference_date
    elif period_id == 'yearly':
        start = reference_date - timedelta(days=364)
        return start, reference_date

def process_timing_aggregations(conn, user_id):
    """Process protein aggregations by meal time"""
    print("\n📊 Processing Timing Aggregations (Breakfast/Lunch/Dinner)")

    with conn.cursor() as cur:
        cur.execute("SELECT CURRENT_DATE")
        reference_date = cur.fetchone()[0]

    # Define meal time ranges
    meal_times = {
        'AGG_PROTEIN_BREAKFAST_GRAMS': (5, 11),   # 5am-11am
        'AGG_PROTEIN_LUNCH_GRAMS': (11, 16),      # 11am-4pm
        'AGG_PROTEIN_DINNER_GRAMS': (16, 22),     # 4pm-10pm
    }

    for agg_id, (start_hour, end_hour) in meal_times.items():
        meal_name = agg_id.replace('AGG_PROTEIN_', '').replace('_GRAMS', '').title()
        print(f"\n  {meal_name} ({start_hour}:00-{end_hour}:00)")

        for period_id in ['daily', 'weekly', 'monthly', '6month', 'yearly']:
            period_start, period_end = get_period_bounds(period_id, reference_date)

            # Query protein entries filtered by time
            with conn.cursor(cursor_factory=RealDictCursor) as cur:
                cur.execute("""
                    SELECT
                        SUM(value_quantity) as total_grams,
                        AVG(value_quantity) as avg_grams,
                        COUNT(*) as data_points
                    FROM patient_data_entries
                    WHERE user_id = %s
                      AND field_id = 'DEF_PROTEIN_GRAMS'
                      AND source IN ('manual', 'healthkit', 'import', 'api')
                      AND entry_date BETWEEN %s AND %s
                      AND EXTRACT(HOUR FROM entry_timestamp) >= %s
                      AND EXTRACT(HOUR FROM entry_timestamp) < %s
                """, (user_id, period_start, period_end, start_hour, end_hour))

                result = cur.fetchone()

                if result and result['total_grams']:
                    # Write SUM
                    cur.execute("""
                        INSERT INTO aggregation_results_cache
                        (user_id, agg_metric_id, period_type, calculation_type_id, period_start, period_end, value, data_points_count, last_computed_at, is_stale)
                        VALUES (%s, %s, %s, 'SUM', %s, %s, %s, %s, NOW(), false)
                        ON CONFLICT (user_id, agg_metric_id, period_type, calculation_type_id, period_start)
                        DO UPDATE SET value = EXCLUDED.value, data_points_count = EXCLUDED.data_points_count, last_computed_at = NOW(), is_stale = false
                    """, (user_id, agg_id, period_id, period_start, period_end, result['total_grams'], result['data_points']))

                    # Write AVG
                    cur.execute("""
                        INSERT INTO aggregation_results_cache
                        (user_id, agg_metric_id, period_type, calculation_type_id, period_start, period_end, value, data_points_count, last_computed_at, is_stale)
                        VALUES (%s, %s, %s, 'AVG', %s, %s, %s, %s, NOW(), false)
                        ON CONFLICT (user_id, agg_metric_id, period_type, calculation_type_id, period_start)
                        DO UPDATE SET value = EXCLUDED.value, data_points_count = EXCLUDED.data_points_count, last_computed_at = NOW(), is_stale = false
                    """, (user_id, agg_id, period_id, period_start, period_end, result['avg_grams'], result['data_points']))

                    conn.commit()
                    print(f"    ✅ {period_id}: {result['total_grams']:.1f}g total, {result['avg_grams']:.1f}g avg ({result['data_points']} entries)")
                else:
                    print(f"    ⏭️  {period_id}: No data")

def process_type_aggregations(conn, user_id):
    """Process protein aggregations by type"""
    print("\n📊 Processing Type Aggregations (6 Protein Types)")

    with conn.cursor() as cur:
        cur.execute("SELECT CURRENT_DATE")
        reference_date = cur.fetchone()[0]

    # Map protein types to aggregation IDs
    type_mapping = {
        'processed_meat': 'AGG_PROTEIN_TYPE_PROCESSED_MEAT',
        'red_meat': 'AGG_PROTEIN_TYPE_RED_MEAT',
        'fatty_fish': 'AGG_PROTEIN_TYPE_FATTY_FISH',
        'lean_protein': 'AGG_PROTEIN_TYPE_LEAN_PROTEIN',
        'plant_based': 'AGG_PROTEIN_TYPE_PLANT_BASED',
        'supplement': 'AGG_PROTEIN_TYPE_SUPPLEMENT',
    }

    for protein_type, agg_id in type_mapping.items():
        type_name = protein_type.replace('_', ' ').title()
        print(f"\n  {type_name}")

        for period_id in ['daily', 'weekly', 'monthly', '6month', 'yearly']:
            period_start, period_end = get_period_bounds(period_id, reference_date)

            # Query protein entries filtered by type
            # Join with protein_type entries via event_instance_id
            with conn.cursor(cursor_factory=RealDictCursor) as cur:
                cur.execute("""
                    SELECT
                        SUM(pde_grams.value_quantity) as total_grams,
                        AVG(pde_grams.value_quantity) as avg_grams,
                        COUNT(*) as data_points
                    FROM patient_data_entries pde_grams
                    JOIN patient_data_entries pde_type
                      ON pde_grams.event_instance_id = pde_type.event_instance_id
                      AND pde_type.field_id = 'DEF_PROTEIN_TYPE'
                      AND pde_type.value_reference = %s
                    WHERE pde_grams.user_id = %s
                      AND pde_grams.field_id = 'DEF_PROTEIN_GRAMS'
                      AND pde_grams.source IN ('manual', 'healthkit', 'import', 'api')
                      AND pde_grams.entry_date BETWEEN %s AND %s
                """, (protein_type, user_id, period_start, period_end))

                result = cur.fetchone()

                if result and result['total_grams']:
                    # Write SUM
                    cur.execute("""
                        INSERT INTO aggregation_results_cache
                        (user_id, agg_metric_id, period_type, calculation_type_id, period_start, period_end, value, data_points_count, last_computed_at, is_stale)
                        VALUES (%s, %s, %s, 'SUM', %s, %s, %s, %s, NOW(), false)
                        ON CONFLICT (user_id, agg_metric_id, period_type, calculation_type_id, period_start)
                        DO UPDATE SET value = EXCLUDED.value, data_points_count = EXCLUDED.data_points_count, last_computed_at = NOW(), is_stale = false
                    """, (user_id, agg_id, period_id, period_start, period_end, result['total_grams'], result['data_points']))

                    # Write AVG
                    cur.execute("""
                        INSERT INTO aggregation_results_cache
                        (user_id, agg_metric_id, period_type, calculation_type_id, period_start, period_end, value, data_points_count, last_computed_at, is_stale)
                        VALUES (%s, %s, %s, 'AVG', %s, %s, %s, %s, NOW(), false)
                        ON CONFLICT (user_id, agg_metric_id, period_type, calculation_type_id, period_start)
                        DO UPDATE SET value = EXCLUDED.value, data_points_count = EXCLUDED.data_points_count, last_computed_at = NOW(), is_stale = false
                    """, (user_id, agg_id, period_id, period_start, period_end, result['avg_grams'], result['data_points']))

                    conn.commit()
                    print(f"    ✅ {period_id}: {result['total_grams']:.1f}g total, {result['avg_grams']:.1f}g avg ({result['data_points']} entries)")
                else:
                    print(f"    ⏭️  {period_id}: No data")

def process_hourly_aggregations(conn, user_id, target_date=None):
    """Process hourly protein aggregations for daily view (parent card)"""
    print("\n📊 Processing Hourly Aggregations (for Daily parent view)")

    with conn.cursor() as cur:
        if target_date:
            reference_date = target_date
        else:
            # Use the most recent date with data
            cur.execute("""
                SELECT MAX(entry_date)
                FROM patient_data_entries
                WHERE user_id = %s AND field_id = 'DEF_PROTEIN_GRAMS'
            """, (user_id,))
            reference_date = cur.fetchone()[0] or datetime.now().date()

    print(f"  Processing date: {reference_date}")

    # For hourly period, period_start and period_end are the same day
    period_start, period_end = reference_date, reference_date

    # For each hour of the day (0-23)
    for hour in range(24):
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            # Query protein for this specific hour
            cur.execute("""
                SELECT
                    SUM(value_quantity) as total_grams,
                    COUNT(*) as data_points
                FROM patient_data_entries
                WHERE user_id = %s
                  AND field_id = 'DEF_PROTEIN_GRAMS'
                  AND source IN ('manual', 'healthkit', 'import', 'api')
                  AND entry_date = %s
                  AND EXTRACT(HOUR FROM entry_timestamp) = %s
            """, (user_id, reference_date, hour))

            result = cur.fetchone()

            if result and result['total_grams']:
                # Store as hourly period with hour-specific period_start timestamp
                # This allows mobile to query for "hourly" period and get 24 data points
                hour_timestamp = datetime.combine(reference_date, datetime.min.time()) + timedelta(hours=hour)

                cur.execute("""
                    INSERT INTO aggregation_results_cache
                    (user_id, agg_metric_id, period_type, calculation_type_id, period_start, period_end, value, data_points_count, last_computed_at, is_stale)
                    VALUES (%s, 'AGG_PROTEIN_GRAMS', 'hourly', 'SUM', %s, %s, %s, %s, NOW(), false)
                    ON CONFLICT (user_id, agg_metric_id, period_type, calculation_type_id, period_start)
                    DO UPDATE SET value = EXCLUDED.value, data_points_count = EXCLUDED.data_points_count, last_computed_at = NOW(), is_stale = false
                """, (user_id, hour_timestamp, period_end, result['total_grams'], result['data_points']))

                conn.commit()
                print(f"    ✅ Hour {hour:02d}:00: {result['total_grams']:.1f}g ({result['data_points']} entries)")

def main():
    conn = psycopg2.connect(DB_URL)

    try:
        print("=" * 80)
        print("🍗 Processing Protein Aggregations (Custom)")
        print("=" * 80)

        # Get test user
        test_user_id = '02cc8441-5f01-4634-acfc-59e6f6a5705a'

        # Process hourly aggregations (for parent card daily view)
        # Uses most recent date with data
        process_hourly_aggregations(conn, test_user_id)

        # Process timing aggregations (for modal Timing tab)
        process_timing_aggregations(conn, test_user_id)

        # Process type aggregations (for modal Type tab)
        process_type_aggregations(conn, test_user_id)

        print("\n" + "=" * 80)
        print("✅ Protein aggregations complete!")
        print("=" * 80)

    except Exception as e:
        conn.rollback()
        print(f"\n❌ Error: {e}")
        raise
    finally:
        conn.close()

if __name__ == "__main__":
    main()
