#!/usr/bin/env python3
"""
Identify which old metrics should be recreated as charts
"""

import psycopg2

# Database connection
conn_string = "postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres"
conn = psycopg2.connect(conn_string)
cur = conn.cursor()

# Get old display metrics with their widget types
print("=== CHARTABLE METRICS BY TYPE ===\n")
cur.execute("""
    SELECT widget_type, COUNT(*) as count
    FROM z_old_display_metrics
    GROUP BY widget_type
    ORDER BY count DESC
""")

widget_counts = cur.fetchall()
for widget_type, count in widget_counts:
    print(f"{widget_type or 'None':20} : {count:3} metrics")

# Get metrics that should definitely be charts
chartable_types = ['chart', 'trend_line', 'progress_bar', 'gauge']

print(f"\n\n=== CHARTABLE METRICS (widget_type in {chartable_types}) ===\n")
cur.execute("""
    SELECT pillar, display_metric_id, display_name, widget_type
    FROM z_old_display_metrics
    WHERE widget_type IN ('chart', 'trend_line', 'progress_bar', 'gauge')
    ORDER BY pillar, display_name
""")

chartable_by_pillar = {}
chartable_rows = cur.fetchall()
for row in chartable_rows:
    pillar, display_metric_id, display_name, widget_type = row
    pillar = pillar or 'No Pillar'
    if pillar not in chartable_by_pillar:
        chartable_by_pillar[pillar] = []
    chartable_by_pillar[pillar].append({
        'id': display_metric_id,
        'name': display_name,
        'type': widget_type
    })

for pillar in sorted(chartable_by_pillar.keys()):
    print(f"\n{pillar} ({len(chartable_by_pillar[pillar])} metrics):")
    for metric in chartable_by_pillar[pillar]:
        print(f"  {metric['id']:50} | {metric['name']:45} | {metric['type']}")

print(f"\n\nTotal chartable metrics: {len(chartable_rows)}")

# Identify priority metrics (those that match Apple Health pattern)
priority_metrics = [
    'sleep', 'cardio', 'strength', 'steps', 'water',
    'protein', 'vegetable', 'fruit', 'fiber',
    'calories', 'active', 'meditation', 'stress'
]

print(f"\n\n=== PRIORITY METRICS (matching Apple Health pattern) ===\n")
for keyword in priority_metrics:
    cur.execute("""
        SELECT display_metric_id, display_name, pillar, widget_type
        FROM z_old_display_metrics
        WHERE LOWER(display_name) LIKE %s
          AND widget_type IN ('chart', 'trend_line', 'progress_bar', 'gauge')
        ORDER BY display_name
    """, (f'%{keyword}%',))

    results = cur.fetchall()
    if results:
        print(f"\n{keyword.upper()}:")
        for row in results:
            print(f"  {row[0]:50} | {row[1]:45} | {row[3]}")

cur.close()
conn.close()
