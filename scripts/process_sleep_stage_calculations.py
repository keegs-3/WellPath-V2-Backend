#!/usr/bin/env python3
"""
Process Sleep Stage Instance Calculations and Aggregations
Manually calculates durations and aggregations for all sleep stage data
"""

import psycopg2
from datetime import datetime, timedelta

DB_URL = 'postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:6543/postgres'
USER_ID = '1758fa60-a306-440e-8ae6-9e68fd502bc2'  # test@wellpath.dev

def calculate_durations(conn):
    """
    Calculate duration for each sleep stage from start/end times
    """
    print("\n⏱️  Calculating Sleep Stage Durations...")
    print("=" * 60)

    stage_mappings = [
        ('DEF_DEEP_SLEEP_START', 'DEF_DEEP_SLEEP_END', 'OUTPUT_DEEP_SLEEP_DURATION'),
        ('DEF_CORE_SLEEP_START', 'DEF_CORE_SLEEP_END', 'OUTPUT_CORE_SLEEP_DURATION'),
        ('DEF_REM_SLEEP_START', 'DEF_REM_SLEEP_END', 'OUTPUT_REM_SLEEP_DURATION'),
        ('DEF_AWAKE_PERIODS_START', 'DEF_AWAKE_PERIODS_END', 'OUTPUT_AWAKE_PERIODS_DURATION'),
    ]

    total_calculated = 0

    for start_field, end_field, output_field in stage_mappings:
        with conn.cursor() as cur:
            # Get all events with start/end times
            cur.execute("""
                WITH stage_pairs AS (
                    SELECT
                        start_entry.event_instance_id,
                        start_entry.entry_date,
                        start_entry.value_timestamp as start_time,
                        end_entry.value_timestamp as end_time,
                        EXTRACT(EPOCH FROM (end_entry.value_timestamp - start_entry.value_timestamp)) / 60 as duration_minutes
                    FROM patient_data_entries start_entry
                    JOIN patient_data_entries end_entry
                        ON start_entry.event_instance_id = end_entry.event_instance_id
                        AND start_entry.user_id = end_entry.user_id
                    WHERE start_entry.user_id = %s
                      AND start_entry.field_id = %s
                      AND end_entry.field_id = %s
                      AND start_entry.value_timestamp IS NOT NULL
                      AND end_entry.value_timestamp IS NOT NULL
                )
                INSERT INTO patient_data_entries (
                    user_id,
                    field_id,
                    entry_date,
                    entry_timestamp,
                    value_quantity,
                    source,
                    event_instance_id
                )
                SELECT
                    %s,
                    %s,
                    entry_date,
                    start_time,
                    duration_minutes,
                    'auto_calculated',
                    event_instance_id
                FROM stage_pairs
                ON CONFLICT DO NOTHING
                RETURNING event_instance_id;
            """, (USER_ID, start_field, end_field, USER_ID, output_field))

            count = cur.rowcount
            total_calculated += count
            stage_name = output_field.replace('OUTPUT_', '').replace('_DURATION', '')
            print(f"  {stage_name}: {count} durations calculated")

    conn.commit()
    print("=" * 60)
    print(f"✅ Calculated {total_calculated} sleep stage durations")
    return total_calculated

def process_aggregations(conn):
    """
    Process aggregations for all sleep stage metrics
    """
    print("\n📊 Processing Sleep Stage Aggregations...")
    print("=" * 60)

    agg_metrics = [
        'AGG_DEEP_SLEEP_DURATION',
        'AGG_CORE_SLEEP_DURATION',
        'AGG_REM_SLEEP_DURATION',
        'AGG_AWAKE_PERIODS_DURATION',
    ]

    total_aggregations = 0

    with conn.cursor() as cur:
        # Get all unique dates with sleep stage data
        cur.execute("""
            SELECT DISTINCT entry_date
            FROM patient_data_entries
            WHERE user_id = %s
              AND field_id IN (
                'OUTPUT_DEEP_SLEEP_DURATION',
                'OUTPUT_CORE_SLEEP_DURATION',
                'OUTPUT_REM_SLEEP_DURATION',
                'OUTPUT_AWAKE_PERIODS_DURATION'
              )
            ORDER BY entry_date;
        """, (USER_ID,))

        dates = [row[0] for row in cur.fetchall()]
        print(f"  Processing {len(dates)} days of sleep stage data...")

        for agg_metric in agg_metrics:
            print(f"\n  Processing {agg_metric}...")

            # Get the output field for this aggregation
            cur.execute("""
                SELECT instance_calculation_id
                FROM aggregation_metrics_dependencies
                WHERE agg_metric_id = %s
                  AND dependency_type = 'instance_calc';
            """, (agg_metric,))

            calc_row = cur.fetchone()
            if not calc_row:
                print(f"    ⚠️  No instance calculation found, skipping")
                continue

            calc_id = calc_row[0]

            # Get output field from calculation config
            cur.execute("""
                SELECT calculation_config->>'output_field'
                FROM instance_calculations
                WHERE calc_id = %s;
            """, (calc_id,))

            output_field = cur.fetchone()[0]

            # Process each period type
            for period_type in ['daily', 'weekly', 'monthly']:
                aggregations_created = 0

                for entry_date in dates:
                    # Calculate period bounds
                    if period_type == 'daily':
                        period_start = entry_date
                        period_end = entry_date
                    elif period_type == 'weekly':
                        # Start of week (Monday)
                        days_since_monday = entry_date.weekday()
                        period_start = entry_date - timedelta(days=days_since_monday)
                        period_end = period_start + timedelta(days=6)
                    else:  # monthly
                        period_start = entry_date.replace(day=1)
                        # Last day of month
                        next_month = period_start + timedelta(days=32)
                        period_end = next_month.replace(day=1) - timedelta(days=1)

                    # Calculate aggregation
                    cur.execute("""
                        WITH agg_data AS (
                            SELECT
                                SUM(value_quantity) as total_duration,
                                COUNT(*) as data_points
                            FROM patient_data_entries
                            WHERE user_id = %s
                              AND field_id = %s
                              AND entry_date >= %s
                              AND entry_date <= %s
                        )
                        INSERT INTO aggregation_results_cache (
                            user_id,
                            agg_metric_id,
                            period_type,
                            period_start,
                            period_end,
                            calculation_type_id,
                            value,
                            data_points_count,
                            last_computed_at
                        )
                        SELECT
                            %s,
                            %s,
                            %s,
                            %s,
                            %s,
                            'SUM',
                            COALESCE(total_duration, 0),
                            COALESCE(data_points, 0),
                            NOW()
                        FROM agg_data
                        WHERE total_duration IS NOT NULL
                        ON CONFLICT (user_id, agg_metric_id, period_type, period_start, calculation_type_id)
                        DO UPDATE SET
                            value = EXCLUDED.value,
                            data_points_count = EXCLUDED.data_points_count,
                            last_computed_at = EXCLUDED.last_computed_at
                        RETURNING agg_metric_id;
                    """, (
                        USER_ID, output_field, period_start, period_end,
                        USER_ID, agg_metric, period_type, period_start, period_end
                    ))

                    if cur.rowcount > 0:
                        aggregations_created += 1

                total_aggregations += aggregations_created
                print(f"    {period_type}: {aggregations_created} aggregations")

        conn.commit()

    print("=" * 60)
    print(f"✅ Processed {total_aggregations} aggregations")
    return total_aggregations

def main():
    print("🚀 Processing Sleep Stage Calculations and Aggregations")
    print(f"User ID: {USER_ID}")
    print("=" * 60)

    conn = psycopg2.connect(DB_URL)

    try:
        # Step 1: Calculate durations from start/end times
        durations_calculated = calculate_durations(conn)

        # Step 2: Process aggregations
        aggregations_processed = process_aggregations(conn)

        print("\n" + "=" * 60)
        print("✅ COMPLETE!")
        print("=" * 60)
        print(f"  Durations Calculated: {durations_calculated}")
        print(f"  Aggregations Processed: {aggregations_processed}")
        print("\n🎉 Sleep stage data is now ready for the mobile app!")

    finally:
        conn.close()

if __name__ == '__main__':
    main()
