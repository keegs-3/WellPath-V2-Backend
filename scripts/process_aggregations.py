#!/usr/bin/env python3
"""
Process Aggregations Worker
Computes aggregated values and writes to aggregation_results_cache
"""

import os
import psycopg2
from psycopg2.extras import RealDictCursor
from datetime import datetime, timedelta

DB_URL = os.getenv('DATABASE_URL', 'postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres')

def get_aggregation_configs(conn):
    """Get all active aggregation configurations"""
    with conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute("""
            SELECT
                am.agg_id,
                am.metric_name,
                am.display_name,
                am.output_unit,
                amd.dependency_type,
                amd.instance_calculation_id,
                amd.data_entry_field_id,
                array_agg(DISTINCT amct.calculation_type_id) as calculation_types,
                array_agg(DISTINCT amp.period_id) as periods
            FROM aggregation_metrics am
            JOIN aggregation_metrics_dependencies amd ON am.agg_id = amd.agg_metric_id
            JOIN aggregation_metrics_calculation_types amct ON am.agg_id = amct.aggregation_metric_id
            JOIN aggregation_metrics_periods amp ON am.agg_id = amp.agg_metric_id
            WHERE am.is_active = true
            GROUP BY am.agg_id, am.metric_name, am.display_name, am.output_unit,
                     amd.dependency_type, amd.instance_calculation_id, amd.data_entry_field_id
            ORDER BY am.agg_id
        """)
        return cur.fetchall()

def get_period_bounds(period_id, reference_date=None, conn=None):
    """Get start and end dates for a period"""
    if reference_date is None:
        # Use database's current date to avoid timezone issues
        if conn:
            with conn.cursor() as cur:
                cur.execute("SELECT CURRENT_DATE")
                reference_date = cur.fetchone()[0]
        else:
            reference_date = datetime.now().date()

    if period_id == 'daily':
        return reference_date, reference_date
    elif period_id == 'hourly':
        # Hourly uses same day for start/end (handled specially in custom processor)
        return reference_date, reference_date
    elif period_id == 'weekly':
        # Last 7 days including today
        start = reference_date - timedelta(days=6)
        return start, reference_date
    elif period_id == 'monthly':
        # Last 30 days including today
        start = reference_date - timedelta(days=29)
        return start, reference_date
    elif period_id == '6month':
        # Last 180 days
        start = reference_date - timedelta(days=179)
        return start, reference_date
    elif period_id == 'yearly':
        # Last 365 days
        start = reference_date - timedelta(days=364)
        return start, reference_date
    else:
        raise ValueError(f"Unknown period_id: {period_id}")

def compute_aggregation(conn, config, user_id, period_id, calc_type):
    """Compute one aggregation for one user, period, and calculation type"""

    # Skip hourly - handled by custom protein aggregations processor
    if period_id == 'hourly':
        return None

    # Skip custom-filtered aggregations (require time/type filtering logic)
    custom_only_aggregations = [
        'AGG_PROTEIN_BREAKFAST_GRAMS',
        'AGG_PROTEIN_LUNCH_GRAMS',
        'AGG_PROTEIN_DINNER_GRAMS',
        'AGG_PROTEIN_TYPE_PROCESSED_MEAT',
        'AGG_PROTEIN_TYPE_RED_MEAT',
        'AGG_PROTEIN_TYPE_FATTY_FISH',
        'AGG_PROTEIN_TYPE_LEAN_PROTEIN',
        'AGG_PROTEIN_TYPE_PLANT_BASED',
        'AGG_PROTEIN_TYPE_SUPPLEMENT',
    ]
    if config['agg_id'] in custom_only_aggregations:
        return None

    # Get period bounds using database's current date
    period_start, period_end = get_period_bounds(period_id, conn=conn)

    # Determine source field
    if config['dependency_type'] == 'instance_calc':
        # Get field_id from instance_calculations.calculation_config
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("""
                SELECT calculation_config->>'output_field' as output_field
                FROM instance_calculations
                WHERE calc_id = %s
            """, (config['instance_calculation_id'],))
            result = cur.fetchone()
            if not result:
                return None
            source_field_id = result['output_field']
            source_filter = "source = 'auto_calculated'"
    else:  # data_field
        source_field_id = config['data_entry_field_id']
        source_filter = "source IN ('manual', 'healthkit', 'import', 'api', 'auto_calculated', 'wellpath_input')"

    # Build aggregation SQL based on calc_type
    agg_function = {
        'AVG': 'AVG(value_quantity)',
        'SUM': 'SUM(value_quantity)',
        'MIN': 'MIN(value_quantity)',
        'MAX': 'MAX(value_quantity)',
        'COUNT': 'COUNT(*)',
        'COUNT_UNIQUE_DAYS': 'COUNT(DISTINCT entry_date)',
        'COUNT_DISTINCT': 'COUNT(DISTINCT value_reference)',  # Counts unique types/sources
        'MEDIAN': 'PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY value_quantity)',
        'STDEV': 'STDDEV(value_quantity)',
    }.get(calc_type)

    if not agg_function:
        print(f"  ⚠️  Unknown calculation type: {calc_type}")
        return None

    # Query the data
    with conn.cursor(cursor_factory=RealDictCursor) as cur:
        query = f"""
            SELECT
                {agg_function} as aggregated_value,
                COUNT(*) as data_points_count
            FROM patient_data_entries
            WHERE patient_id = %s
            AND field_id = %s
            AND {source_filter}
            AND entry_date BETWEEN %s AND %s
        """

        cur.execute(query, (user_id, source_field_id, period_start, period_end))
        result = cur.fetchone()

        if result and result['aggregated_value'] is not None:
            return {
                'value': float(result['aggregated_value']),
                'data_points_count': result['data_points_count'],
                'period_start': period_start,
                'period_end': period_end
            }

    return None

def write_to_cache(conn, user_id, config, period_id, calc_type, result):
    """Write aggregation result to cache"""
    with conn.cursor() as cur:
        cur.execute("""
            INSERT INTO aggregation_results_cache
            (patient_id, agg_metric_id, period_type, calculation_type_id, period_start, period_end, value, data_points_count, last_computed_at, is_stale)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, NOW(), false)
            ON CONFLICT (patient_id, agg_metric_id, period_type, calculation_type_id, period_start)
            DO UPDATE SET
                value = EXCLUDED.value,
                data_points_count = EXCLUDED.data_points_count,
                last_computed_at = NOW(),
                is_stale = false
        """, (
            user_id,
            config['agg_id'],
            period_id,
            calc_type,
            result['period_start'],
            result['period_end'],
            result['value'],
            result['data_points_count']
        ))
    conn.commit()

def main():
    import sys

    conn = psycopg2.connect(DB_URL)

    try:
        print("📊 Processing Aggregations")
        print("=" * 70)

        # Get all aggregation configs
        configs = get_aggregation_configs(conn)
        print(f"\nFound {len(configs)} aggregation configurations")

        # Get patient_id from command line argument or use default
        if len(sys.argv) > 1:
            test_user_id = sys.argv[1]
        else:
            test_user_id = '02cc8441-5f01-4634-acfc-59e6f6a5705a'

        print(f"Processing for patient: {test_user_id}")

        total_computed = 0
        total_skipped = 0

        for config in configs:
            print(f"\n📈 {config['display_name']}")
            print(f"   Source: {config['dependency_type']} ({config['instance_calculation_id'] or config['data_entry_field_id']})")

            # Process each calculation type
            for calc_type in config['calculation_types']:
                # Process each period
                for period_id in config['periods']:
                    result = compute_aggregation(conn, config, test_user_id, period_id, calc_type)

                    if result:
                        write_to_cache(conn, test_user_id, config, period_id, calc_type, result)
                        print(f"   ✅ {period_id} {calc_type}: {result['value']:.2f} ({result['data_points_count']} data points)")
                        total_computed += 1
                    else:
                        print(f"   ⏭️  {period_id} {calc_type}: No data")
                        total_skipped += 1

        # Summary
        print("\n" + "=" * 70)
        print("AGGREGATION COMPLETE")
        print("=" * 70)
        print(f"Total Computed: {total_computed} ✅")
        print(f"Total Skipped: {total_skipped} ⏭️")

        # Show cache contents
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("""
                SELECT
                    agg_metric_id,
                    period_type,
                    calculation_type_id,
                    value,
                    data_points_count
                FROM aggregation_results_cache
                WHERE user_id = %s
                ORDER BY agg_metric_id, period_type, calculation_type_id
            """, (test_user_id,))
            results = cur.fetchall()

        if results:
            print(f"\n📦 Cache Contents ({len(results)} entries):")
            print(f"{'Metric':<30} {'Period':<10} {'Calc':<8} {'Value':<12} {'Points':<8}")
            print("=" * 70)
            for row in results:
                metric_short = row['agg_metric_id'].replace('AGG_', '')[:25]
                print(f"{metric_short:<30} {row['period_type']:<10} {row['calculation_type_id']:<8} {row['value']:>10.2f}  {row['data_points_count']:>6}")

    except Exception as e:
        print(f"\n❌ Error: {e}")
        import traceback
        traceback.print_exc()
    finally:
        conn.close()

if __name__ == "__main__":
    main()
