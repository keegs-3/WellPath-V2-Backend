#!/usr/bin/env python3
"""
Compare old vs current display metrics using direct SQL
"""

import psycopg2
import os

# Database connection
conn_string = "postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres"
conn = psycopg2.connect(conn_string)
cur = conn.cursor()

# Get old display metrics
print("=== OLD DISPLAY METRICS (Archived) ===\n")
cur.execute("""
    SELECT display_metric_id, display_name, pillar, widget_type
    FROM z_old_display_metrics
    ORDER BY pillar, display_name
""")

old_metrics = {}
old_rows = cur.fetchall()
for row in old_rows:
    display_metric_id, display_name, pillar, widget_type = row
    pillar = pillar or 'No Pillar'
    if pillar not in old_metrics:
        old_metrics[pillar] = []
    old_metrics[pillar].append({
        'display_metric_id': display_metric_id,
        'display_name': display_name,
        'pillar': pillar,
        'widget_type': widget_type
    })

for pillar in sorted(old_metrics.keys()):
    print(f"\n{pillar}:")
    for row in old_metrics[pillar]:
        print(f"  {row['display_metric_id']:50} | {row['display_name']:35} | {row['widget_type']}")

print(f"\nTotal old metrics: {len(old_rows)}")

# Get current display metrics
print("\n\n=== CURRENT DISPLAY METRICS ===\n")
cur.execute("""
    SELECT display_metric_id, display_name, pillar, widget_type
    FROM display_metrics
    ORDER BY pillar, display_name
""")

current_metrics = {}
current_rows = cur.fetchall()
for row in current_rows:
    display_metric_id, display_name, pillar, widget_type = row
    pillar = pillar or 'No Pillar'
    if pillar not in current_metrics:
        current_metrics[pillar] = []
    current_metrics[pillar].append({
        'display_metric_id': display_metric_id,
        'display_name': display_name,
        'pillar': pillar,
        'widget_type': widget_type
    })

for pillar in sorted(current_metrics.keys()):
    print(f"\n{pillar}:")
    for row in current_metrics[pillar]:
        print(f"  {row['display_metric_id']:50} | {row['display_name']:35} | {row['widget_type']}")

print(f"\nTotal current metrics: {len(current_rows)}")

# Find what's missing
print("\n\n=== MISSING METRICS (in old but not in current) ===\n")
old_ids = {row[0] for row in old_rows}
current_ids = {row[0] for row in current_rows}
missing_ids = old_ids - current_ids

missing_by_pillar = {}
for row in old_rows:
    if row[0] in missing_ids:
        pillar = row[2] or 'No Pillar'
        if pillar not in missing_by_pillar:
            missing_by_pillar[pillar] = []
        missing_by_pillar[pillar].append({
            'display_metric_id': row[0],
            'display_name': row[1]
        })

for pillar in sorted(missing_by_pillar.keys()):
    print(f"\n{pillar}:")
    for row in missing_by_pillar[pillar]:
        print(f"  {row['display_metric_id']:50} | {row['display_name']}")

print(f"\nTotal missing: {len(missing_ids)}")

# Close connection
cur.close()
conn.close()
