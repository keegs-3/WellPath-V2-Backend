#!/usr/bin/env python3
"""
Compare old vs current display metrics to see what needs to be migrated
"""

from supabase import create_client
import os

# Initialize Supabase client
url = "https://csotzmardnvrpdhlogjm.supabase.co"
key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNzb3R6bWFyZG52cnBkaGxvZ2ptIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mjc5MDQ1MDcsImV4cCI6MjA0MzQ4MDUwN30.gPVC3dt2ivzkMRJO1llebBNsjxy0N96WVJqIw0EvOLc"
supabase = create_client(url, key)

# Get old display metrics
print("=== OLD DISPLAY METRICS (Archived) ===\n")
result = supabase.table("z_old_display_metrics")\
    .select("display_metric_id, display_name, pillar, widget_type")\
    .order("pillar")\
    .order("display_name")\
    .execute()

old_metrics = {}
for row in result.data:
    pillar = row['pillar'] or 'No Pillar'
    if pillar not in old_metrics:
        old_metrics[pillar] = []
    old_metrics[pillar].append(row)

for pillar in sorted(old_metrics.keys()):
    print(f"\n{pillar}:")
    for row in old_metrics[pillar]:
        print(f"  {row['display_metric_id']:40} | {row['display_name']:30} | {row['widget_type']}")

print(f"\nTotal old metrics: {len(result.data)}")

# Get current display metrics
print("\n\n=== CURRENT DISPLAY METRICS ===\n")
result2 = supabase.table("display_metrics")\
    .select("display_metric_id, display_name, pillar, widget_type")\
    .order("pillar")\
    .order("display_name")\
    .execute()

current_metrics = {}
for row in result2.data:
    pillar = row['pillar'] or 'No Pillar'
    if pillar not in current_metrics:
        current_metrics[pillar] = []
    current_metrics[pillar].append(row)

for pillar in sorted(current_metrics.keys()):
    print(f"\n{pillar}:")
    for row in current_metrics[pillar]:
        print(f"  {row['display_metric_id']:40} | {row['display_name']:30} | {row['widget_type']}")

print(f"\nTotal current metrics: {len(result2.data)}")

# Find what's missing
print("\n\n=== MISSING METRICS (in old but not in current) ===\n")
old_ids = {row['display_metric_id'] for row in result.data}
current_ids = {row['display_metric_id'] for row in result2.data}
missing_ids = old_ids - current_ids

missing_by_pillar = {}
for row in result.data:
    if row['display_metric_id'] in missing_ids:
        pillar = row['pillar'] or 'No Pillar'
        if pillar not in missing_by_pillar:
            missing_by_pillar[pillar] = []
        missing_by_pillar[pillar].append(row)

for pillar in sorted(missing_by_pillar.keys()):
    print(f"\n{pillar}:")
    for row in missing_by_pillar[pillar]:
        print(f"  {row['display_metric_id']:40} | {row['display_name']}")

print(f"\nTotal missing: {len(missing_ids)}")
