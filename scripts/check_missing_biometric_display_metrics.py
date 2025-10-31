#!/usr/bin/env python3
"""
Check which biometrics are missing display_metrics
"""

import psycopg2

DATABASE_URL = "postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:6543/postgres?sslmode=require"

try:
    conn = psycopg2.connect(DATABASE_URL)
    cur = conn.cursor()

    # Check biometrics that have display_metrics
    # Look for display_metrics with names that match or contain the biometric name
    cur.execute("""
        SELECT
            b.biometric_name,
            dm.metric_id,
            dm.metric_name
        FROM biometrics_base b
        LEFT JOIN display_metrics dm ON (
            LOWER(dm.metric_name) LIKE '%' || LOWER(REPLACE(b.biometric_name, '_', ' ')) || '%'
            OR LOWER(dm.metric_name) LIKE '%' || LOWER(REPLACE(b.biometric_name, ' ', '_')) || '%'
            OR LOWER(REPLACE(dm.metric_name, ' ', '')) = LOWER(REPLACE(b.biometric_name, ' ', ''))
        )
        WHERE b.is_active = true
        ORDER BY
            b.biometric_name,
            dm.metric_id
    """)

    results = cur.fetchall()

    print("Biometric Display Metrics Status:")
    print("=" * 80)

    missing = []
    has_metric = {}

    for row in results:
        biometric_name, metric_id, metric_name = row
        if metric_id is None:
            if biometric_name not in missing:
                missing.append(biometric_name)
        else:
            if biometric_name not in has_metric:
                has_metric[biometric_name] = []
            has_metric[biometric_name].append(metric_name)

    # Print biometrics with metrics
    for biometric_name, metrics in sorted(has_metric.items()):
        print(f"✓ {biometric_name}: {', '.join(metrics)}")

    # Print missing biometrics
    for biometric_name in sorted(missing):
        if biometric_name not in has_metric:
            print(f"❌ {biometric_name}: Missing Display Metric")

    print(f'\n{"=" * 80}')
    print(f"Summary: {len([b for b in missing if b not in has_metric])} missing, {len(has_metric)} have metrics")
    print(f'{"=" * 80}')

    missing_final = [b for b in missing if b not in has_metric]
    if missing_final:
        print(f"\nBiometrics Missing Display Metrics:")
        for bm in sorted(missing_final):
            print(f"  - {bm}")

    cur.close()
    conn.close()

except Exception as e:
    print(f"Error: {e}")
    import traceback
    traceback.print_exc()
