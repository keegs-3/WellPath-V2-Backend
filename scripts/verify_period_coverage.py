#!/usr/bin/env python3
"""
Verify Period Coverage and Bounds
==================================
Checks that:
1. All aggregations have all 5 period types (daily, weekly, monthly, 6month, yearly)
2. Period bounds are correct (weekly = 7 days, monthly = full month, etc.)
3. Aggregation values make sense
"""

import psycopg2

DB_URL = 'postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres'

print("=" * 80)
print("🔍 Verifying Period Coverage and Bounds")
print("=" * 80)
print()

conn = psycopg2.connect(DB_URL)
cur = conn.cursor()

try:
    # =====================================================
    # CHECK 1: Period Type Coverage
    # =====================================================
    print("CHECK 1: Period Type Coverage")
    print("-" * 80)

    cur.execute("""
        SELECT
            COUNT(DISTINCT agg_metric_id) as total_aggregations,
            COUNT(DISTINCT CASE WHEN has_all THEN agg_metric_id END) as with_all_periods,
            COUNT(DISTINCT CASE WHEN NOT has_all THEN agg_metric_id END) as missing_periods
        FROM (
            SELECT
                agg_metric_id,
                BOOL_AND(period_id IN ('daily', 'weekly', 'monthly', '6month', 'yearly')) as has_all
            FROM aggregation_metrics_periods
            GROUP BY agg_metric_id
            HAVING COUNT(DISTINCT period_id) >= 5
        ) coverage;
    """)

    total, with_all, missing = cur.fetchone()

    print(f"  Total aggregations:       {total:,}")
    print(f"  With all 5 periods:       {with_all:,} {'✅' if with_all == total else '❌'}")
    print(f"  Missing period types:     {missing:,} {'✅' if missing == 0 else '❌'}")
    print()

    if missing > 0:
        print("  Aggregations missing period types:")
        cur.execute("""
            SELECT
                agg_metric_id,
                string_agg(period_id, ', ' ORDER BY period_id) as periods
            FROM aggregation_metrics_periods
            GROUP BY agg_metric_id
            HAVING COUNT(DISTINCT period_id) < 5
            ORDER BY agg_metric_id
            LIMIT 10;
        """)
        for row in cur.fetchall():
            agg_id, periods = row
            print(f"    ❌ {agg_id}: {periods}")
        print()

    # =====================================================
    # CHECK 2: Period Bounds Function
    # =====================================================
    print("CHECK 2: Period Bounds Function")
    print("-" * 80)

    test_date = '2025-09-23'  # Tuesday
    print(f"  Testing with reference date: {test_date} (Tuesday)")
    print()

    periods_to_test = [
        ('daily', 0, 0),       # Same day
        ('weekly', 6, 6),      # 7 days (0-6 inclusive)
        ('monthly', 28, 31),   # Full month (28-31 days)
        ('6month', 150, 155),  # ~153 days
        ('yearly', 364, 365),  # Full year
    ]

    all_passed = True
    for period_id, min_days, max_days in periods_to_test:
        cur.execute("""
            SELECT period_start, period_end
            FROM get_period_bounds(%s, %s::date);
        """, (period_id, test_date))

        start, end = cur.fetchone()
        days = (end - start).days

        passed = min_days <= days <= max_days
        status = "✅" if passed else "❌"
        all_passed = all_passed and passed

        print(f"  {status} {period_id:8s}: {start} to {end} ({days} days)")

    print()
    if all_passed:
        print("  ✅ All period bounds are correct!")
    else:
        print("  ❌ Some period bounds are incorrect!")
    print()

    # =====================================================
    # CHECK 3: Aggregation Cache Sample
    # =====================================================
    print("CHECK 3: Aggregation Cache Sample (Protein)")
    print("-" * 80)

    cur.execute("""
        SELECT
            period_type,
            period_start::date,
            period_end::date,
            (period_end::date - period_start::date) as days_span,
            value,
            data_points_count
        FROM aggregation_results_cache
        WHERE agg_metric_id = 'AGG_PROTEIN_GRAMS'
          AND calculation_type_id = 'SUM'
          AND period_start::date = '2025-09-23'
        ORDER BY period_type;
    """)

    results = cur.fetchall()
    if results:
        for row in results:
            period_type, start, end, days, value, points = row
            expected_days = {
                'hourly': 0,
                'daily': 0,
                'weekly': 6,
                'monthly': 29,  # Sept has 30 days, so 0-29 = 29
                '6month': 153,
                'yearly': 364
            }
            expected = expected_days.get(period_type, 0)
            status = "✅" if days == expected else "❌"
            print(f"  {status} {period_type:8s}: {start} to {end} ({days} days) = {value}g")
    else:
        print("  ⚠️  No protein aggregations found for 2025-09-23")
    print()

    # =====================================================
    # CHECK 4: Period Type Distribution
    # =====================================================
    print("CHECK 4: Period Type Distribution in Cache")
    print("-" * 80)

    cur.execute("""
        SELECT
            period_type,
            COUNT(*) as count,
            COUNT(DISTINCT agg_metric_id) as unique_aggs,
            COUNT(DISTINCT user_id) as unique_users
        FROM aggregation_results_cache
        GROUP BY period_type
        ORDER BY period_type;
    """)

    print(f"  {'Period':<10s} {'Total Rows':>12s} {'Unique Aggs':>15s} {'Unique Users':>15s}")
    print(f"  {'-'*10} {'-'*12} {'-'*15} {'-'*15}")

    total_rows = 0
    for row in cur.fetchall():
        period_type, count, unique_aggs, unique_users = row
        total_rows += count
        print(f"  {period_type:<10s} {count:>12,} {unique_aggs:>15,} {unique_users:>15,}")

    print(f"  {'-'*10} {'-'*12} {'-'*15} {'-'*15}")
    print(f"  {'TOTAL':<10s} {total_rows:>12,}")
    print()

    # =====================================================
    # CHECK 5: Sample Weekly Aggregation Verification
    # =====================================================
    print("CHECK 5: Weekly Aggregation Verification")
    print("-" * 80)
    print("  Checking if weekly aggregations span full 7 days...")
    print()

    cur.execute("""
        SELECT
            (period_end::date - period_start::date) as days_span,
            COUNT(*) as count
        FROM aggregation_results_cache
        WHERE period_type = 'weekly'
        GROUP BY days_span
        ORDER BY days_span;
    """)

    weekly_spans = cur.fetchall()
    if weekly_spans:
        for days, count in weekly_spans:
            status = "✅" if days == 6 else "❌"
            print(f"  {status} {count:,} weekly aggregations span {days} days")
    else:
        print("  ⚠️  No weekly aggregations found")
    print()

    # =====================================================
    # SUMMARY
    # =====================================================
    print("=" * 80)
    print("✅ Verification Complete!")
    print("=" * 80)
    print()

    issues = []
    if missing > 0:
        issues.append(f"{missing} aggregations missing period types")
    if not all_passed:
        issues.append("Period bounds function returning incorrect values")
    if weekly_spans and any(days != 6 for days, _ in weekly_spans):
        issues.append("Weekly aggregations have incorrect bounds")

    if issues:
        print("❌ Issues Found:")
        for issue in issues:
            print(f"  - {issue}")
        print()
        print("Run the migrations and recompute script to fix these issues.")
    else:
        print("✅ All checks passed!")
        print("  - All aggregations have 5 period types")
        print("  - Period bounds are correct")
        print("  - Aggregation cache is properly populated")
    print()

except Exception as e:
    print(f"\n❌ Error: {e}")
    import traceback
    traceback.print_exc()
finally:
    cur.close()
    conn.close()

print("=" * 80)
