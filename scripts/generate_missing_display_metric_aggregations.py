#!/usr/bin/env python3
"""
Generate missing display_metrics_aggregations mappings.

This script analyzes display_metrics that are missing aggregation mappings
and intelligently creates them based on naming patterns and existing aggregation metrics.
"""

import os
import psycopg2
from psycopg2.extras import RealDictCursor
import re

# Database connection
DB_URL = os.getenv('DATABASE_URL', 'postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres')

def get_missing_display_metrics(conn):
    """Get display metrics that don't have aggregation mappings."""
    with conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute("""
            SELECT dm.metric_id, dm.metric_name, dm.pillar
            FROM display_metrics dm
            LEFT JOIN display_metrics_aggregations dma ON dm.metric_id = dma.metric_id
            WHERE dma.metric_id IS NULL
            ORDER BY dm.pillar, dm.metric_id
        """)
        return cur.fetchall()

def get_all_aggregation_metrics(conn):
    """Get all available aggregation metrics."""
    with conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute("""
            SELECT agg_id, metric_name, display_name
            FROM aggregation_metrics
            WHERE is_active = true
            ORDER BY agg_id
        """)
        return cur.fetchall()

def get_aggregation_periods(conn, agg_id):
    """Get available periods for an aggregation metric."""
    with conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute("""
            SELECT period_id
            FROM aggregation_metrics_periods
            WHERE agg_metric_id = %s
        """, (agg_id,))
        return [row['period_id'] for row in cur.fetchall()]

def normalize_name(name):
    """Normalize a name for matching."""
    return re.sub(r'[^a-z0-9]', '', name.lower())

def find_matching_agg_metric(display_metric, agg_metrics):
    """
    Find matching aggregation metric(s) for a display metric.

    Returns list of (agg_id, confidence) tuples.
    """
    display_id = display_metric['metric_id']
    display_name = display_metric['metric_name']

    # Remove DISP_ prefix
    clean_id = display_id.replace('DISP_', '')

    matches = []

    for agg in agg_metrics:
        agg_id = agg['agg_id']
        agg_name = agg['metric_name']
        agg_display = agg['display_name']

        # Remove AGG_ prefix
        clean_agg_id = agg_id.replace('AGG_', '')

        # Exact ID match (highest confidence)
        if clean_id == clean_agg_id:
            matches.append((agg_id, 100))
            continue

        # Normalized name match
        norm_display = normalize_name(display_name)
        norm_agg_name = normalize_name(agg_name)
        norm_agg_display = normalize_name(agg_display)

        # Check if names contain each other
        if norm_display in norm_agg_name or norm_agg_name in norm_display:
            matches.append((agg_id, 80))
        elif norm_display in norm_agg_display or norm_agg_display in norm_display:
            matches.append((agg_id, 70))
        # Partial match in IDs
        elif clean_id in clean_agg_id or clean_agg_id in clean_id:
            # Check if it's a meaningful match (not just one letter)
            if len(clean_id) >= 4 and len(clean_agg_id) >= 4:
                matches.append((agg_id, 60))

    # Sort by confidence
    matches.sort(key=lambda x: x[1], reverse=True)
    return matches

def determine_periods_and_calc_types(display_metric, agg_id):
    """
    Determine appropriate periods and calculation types for a display metric.

    Returns list of (period, calc_type) tuples.
    """
    metric_name = display_metric['metric_name'].lower()
    metric_id = display_metric['metric_id'].lower()

    # Default periods
    periods = ['daily', 'weekly', 'monthly']

    # Determine calculation type based on metric nature
    # Counts, totals, sums should use SUM for daily, AVG for aggregated periods
    # Averages, rates, percentages should use AVG
    # Special cases for specific metrics

    if any(word in metric_name or word in metric_id for word in ['sessions', 'count', 'total', 'grams', 'servings', 'minutes']):
        # Accumulative metrics: SUM for daily, AVG for longer periods
        return [
            ('daily', 'SUM'),
            ('weekly', 'AVG'),
            ('monthly', 'AVG')
        ]
    elif any(word in metric_name or word in metric_id for word in ['percentage', 'pct', 'rate', 'ratio', 'efficiency', 'score']):
        # Ratios and percentages: AVG across all periods
        return [
            ('daily', 'AVG'),
            ('weekly', 'AVG'),
            ('monthly', 'AVG')
        ]
    elif any(word in metric_name or word in metric_id for word in ['variety', 'diversity']):
        # Variety metrics: typically count distinct
        return [
            ('daily', 'COUNT_DISTINCT'),
            ('weekly', 'COUNT_DISTINCT'),
            ('monthly', 'COUNT_DISTINCT')
        ]
    else:
        # Default to AVG for all periods
        return [
            ('daily', 'AVG'),
            ('weekly', 'AVG'),
            ('monthly', 'AVG')
        ]

def generate_sql_mappings(conn):
    """Generate SQL for missing display metric aggregations."""
    missing_metrics = get_missing_display_metrics(conn)
    agg_metrics = get_all_aggregation_metrics(conn)

    print(f"Found {len(missing_metrics)} display metrics without aggregation mappings")
    print(f"Available aggregation metrics: {len(agg_metrics)}")
    print()

    sql_statements = []
    matched_count = 0
    unmatched = []

    for display_metric in missing_metrics:
        matches = find_matching_agg_metric(display_metric, agg_metrics)

        if not matches:
            unmatched.append(display_metric)
            continue

        # Use the best match (highest confidence)
        best_match_id, confidence = matches[0]

        # Only use high-confidence matches (60+)
        if confidence < 60:
            unmatched.append(display_metric)
            continue

        # Get available periods for this aggregation metric
        available_periods = get_aggregation_periods(conn, best_match_id)

        if not available_periods:
            print(f"⚠️  Skipping {display_metric['metric_id']}: No periods configured for {best_match_id}")
            unmatched.append(display_metric)
            continue

        # Determine periods and calculation types
        period_calc_pairs = determine_periods_and_calc_types(display_metric, best_match_id)

        # Filter to only available periods
        valid_pairs = [
            (period, calc) for period, calc in period_calc_pairs
            if period in available_periods
        ]

        if not valid_pairs:
            print(f"⚠️  Skipping {display_metric['metric_id']}: No valid period/calc combinations")
            unmatched.append(display_metric)
            continue

        matched_count += 1

        # Generate INSERT statements
        for display_order, (period, calc_type) in enumerate(valid_pairs, start=1):
            sql = f"""INSERT INTO display_metrics_aggregations (metric_id, agg_metric_id, period_type, calculation_type_id, display_order)
VALUES ('{display_metric['metric_id']}', '{best_match_id}', '{period}', '{calc_type}', {display_order})
ON CONFLICT (metric_id, agg_metric_id, period_type, calculation_type_id) DO NOTHING;"""
            sql_statements.append(sql)

        print(f"✅ {display_metric['metric_id']:30} → {best_match_id:35} (confidence: {confidence}%) - {len(valid_pairs)} mappings")

    print()
    print(f"Successfully matched: {matched_count} display metrics")
    print(f"Could not match: {len(unmatched)} display metrics")

    if unmatched:
        print("\nUnmatched display metrics:")
        for metric in unmatched[:20]:  # Show first 20
            print(f"  - {metric['metric_id']:30} ({metric['metric_name']})")
        if len(unmatched) > 20:
            print(f"  ... and {len(unmatched) - 20} more")

    return sql_statements

def main():
    conn = psycopg2.connect(DB_URL)

    try:
        print("=" * 80)
        print("Generating Missing Display Metric Aggregation Mappings")
        print("=" * 80)
        print()

        sql_statements = generate_sql_mappings(conn)

        if sql_statements:
            print()
            print("=" * 80)
            print(f"Generated {len(sql_statements)} SQL INSERT statements")
            print("=" * 80)
            print()

            # Write to file
            output_file = 'supabase/migrations/20251025_populate_missing_display_metric_aggregations.sql'
            with open(output_file, 'w') as f:
                f.write("-- =====================================================\n")
                f.write("-- Populate Missing Display Metric Aggregations\n")
                f.write("-- =====================================================\n")
                f.write("-- Auto-generated by generate_missing_display_metric_aggregations.py\n")
                f.write("-- =====================================================\n\n")
                f.write("BEGIN;\n\n")

                for sql in sql_statements:
                    f.write(sql + "\n\n")

                f.write("-- Verification\n")
                f.write("DO $$\n")
                f.write("DECLARE\n")
                f.write("  v_total_metrics INTEGER;\n")
                f.write("  v_metrics_with_aggs INTEGER;\n")
                f.write("  v_coverage_pct NUMERIC;\n")
                f.write("BEGIN\n")
                f.write("  SELECT COUNT(*) INTO v_total_metrics FROM display_metrics;\n")
                f.write("  SELECT COUNT(DISTINCT metric_id) INTO v_metrics_with_aggs FROM display_metrics_aggregations;\n")
                f.write("  v_coverage_pct := ROUND((v_metrics_with_aggs::NUMERIC / v_total_metrics) * 100, 1);\n")
                f.write("  \n")
                f.write("  RAISE NOTICE '';\n")
                f.write("  RAISE NOTICE '✅ Display Metric Aggregation Mapping Complete!';\n")
                f.write("  RAISE NOTICE '';\n")
                f.write("  RAISE NOTICE 'Summary:';\n")
                f.write("  RAISE NOTICE '  Total display metrics: %', v_total_metrics;\n")
                f.write("  RAISE NOTICE '  Metrics with aggregations: %', v_metrics_with_aggs;\n")
                f.write("  RAISE NOTICE '  Coverage: %%', v_coverage_pct;\n")
                f.write("  RAISE NOTICE '';\n")
                f.write("END $$;\n\n")
                f.write("COMMIT;\n")

            print(f"SQL written to: {output_file}")
            print()
            print("Review the file and run it with:")
            print(f"  psql <connection-string> -f {output_file}")
        else:
            print("\n⚠️  No SQL statements generated")

    finally:
        conn.close()

if __name__ == '__main__':
    main()
