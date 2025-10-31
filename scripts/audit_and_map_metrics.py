#!/usr/bin/env python3
"""
Audit z_old_display_metrics and create comprehensive mapping to new structure
"""

import psycopg2
import csv
import re

# Database connection
conn = psycopg2.connect("postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres")
cur = conn.cursor()

# Get all old display metrics
cur.execute("""
    SELECT display_metric_id, display_name, pillar, widget_type,
           chart_type_id, display_unit, supported_periods, default_period
    FROM z_old_display_metrics
    ORDER BY pillar, display_name
""")

old_metrics = cur.fetchall()

# Get existing aggregation_metrics to check what's available
cur.execute("""
    SELECT agg_id FROM aggregation_metrics
""")
existing_agg_metrics = {row[0] for row in cur.fetchall()}

# Mapping rules for determining new structure
def determine_chart_type(display_name, widget_type):
    """Determine appropriate chart type based on metric name and old widget type"""
    name_lower = display_name.lower()

    # Sleep specific
    if 'sleep stage' in name_lower or 'sleep amount' in name_lower:
        return 'sleep_stages_vertical'

    # Time-based patterns
    if any(x in name_lower for x in ['last meal time', 'wake time', 'bedtime', 'first meal time', 'last drink', 'last caffeine']):
        return 'trend_line'  # Time of day

    # Baseline comparisons
    if 'vs. baseline' in name_lower or 'vs baseline' in name_lower:
        return 'comparison_view'

    # Progress bars (goals)
    if widget_type == 'progress_bar':
        return 'progress_bar'

    # Gauges (consistency, percentages)
    if widget_type == 'gauge' or 'consistency' in name_lower:
        return 'gauge'

    # Streaks
    if 'streak' in name_lower or 'consecutive' in name_lower:
        return 'streak_counter'

    # Heatmaps (patterns across dimensions)
    if 'heatmap' in name_lower:
        return 'heatmap'

    # Duration, sessions, servings, counts → bar charts
    if any(x in name_lower for x in ['duration', 'sessions', 'servings', 'grams', 'count', 'consumption', 'steps']):
        return 'bar_vertical'

    # Ratings, scores, percentages → trend lines
    if any(x in name_lower for x in ['rating', 'score', 'percentage', 'ratio', 'adherence']):
        return 'trend_line'

    # Current values (compliance status, etc.)
    if widget_type == 'current_value':
        # Many current_value metrics should actually be bar charts
        if any(x in name_lower for x in ['sessions', 'meals', 'drinks', 'snacks', 'episodes', 'swaps']):
            return 'bar_vertical'
        return 'current_value'

    # Default based on old widget type
    if widget_type == 'trend_line':
        return 'trend_line'
    if widget_type == 'chart':
        return 'bar_vertical'

    # Fallback
    return 'bar_vertical'


def determine_agg_metric(display_metric_id, display_name, pillar):
    """Generate likely aggregation metric ID"""
    name_lower = display_name.lower()

    # Already using DISP_ prefix? Convert to AGG_
    if display_metric_id.startswith('DISP_'):
        return display_metric_id.replace('DISP_', 'AGG_')

    # Generate from display name
    # Remove special characters and meal qualifiers
    clean_name = display_name.upper()
    clean_name = re.sub(r'\s*\(.*?\)\s*', '', clean_name)  # Remove (parentheses)
    clean_name = re.sub(r':\s*BREAKFAST', '', clean_name)
    clean_name = re.sub(r':\s*LUNCH', '', clean_name)
    clean_name = re.sub(r':\s*DINNER', '', clean_name)
    clean_name = re.sub(r'\s+', '_', clean_name.strip())
    clean_name = re.sub(r'[^A-Z0-9_]', '', clean_name)

    return f'AGG_{clean_name}'


def determine_display_unit(display_name, widget_type):
    """Determine display unit - mapped to valid units_base entries"""
    name_lower = display_name.lower()

    # Map to valid units in units_base table
    if 'duration' in name_lower or 'time' in name_lower or 'latency' in name_lower:
        if 'sleep' in name_lower:
            return 'hours'
        return 'minutes'
    if 'sessions' in name_lower or 'episodes' in name_lower:
        return 'count'  # 'sessions' doesn't exist in units_base
    if 'servings' in name_lower:
        return 'serving'  # singular form exists in units_base
    if 'grams' in name_lower or '(g)' in name_lower:
        return 'gram'  # singular form exists in units_base
    if 'steps' in name_lower:
        return 'steps'
    if 'rating' in name_lower or 'score' in name_lower:
        return 'count'  # 'score' doesn't exist in units_base
    if 'percentage' in name_lower or '%' in name_lower:
        return 'percentage'
    if 'ratio' in name_lower:
        return 'ratio'
    if 'compliance' in name_lower or 'adherence' in name_lower:
        return 'percentage'
    if 'buffer' in name_lower:
        return 'hours'
    if 'drinks' in name_lower or 'cigarettes' in name_lower:
        return 'count'
    if 'months since' in name_lower or 'years since' in name_lower:
        return 'months'
    if 'consumption' in name_lower and 'water' in name_lower:
        return 'fluid_ounce'  # 'ounces' → 'fluid_ounce' in units_base
    if 'calories' in name_lower:
        return 'kilocalorie'  # 'calories' → 'kilocalorie' in units_base
    if 'count' in name_lower:
        return 'count'

    return 'count'


def determine_pattern(display_name, chart_type):
    """Determine which pattern template this metric follows"""
    name_lower = display_name.lower()

    if 'duration' in name_lower:
        return 'DURATION'
    if 'sessions' in name_lower or 'session count' in name_lower:
        return 'SESSION_COUNT'
    if 'servings' in name_lower:
        return 'SERVINGS'
    if 'variety' in name_lower or 'source count' in name_lower:
        return 'VARIETY'
    if 'grams' in name_lower or '(g)' in name_lower:
        return 'GRAMS'
    if 'vs. baseline' in name_lower:
        return 'BASELINE_COMPARISON'
    if 'rating' in name_lower or 'score' in name_lower:
        return 'RATING'
    if chart_type == 'current_value':
        return 'CURRENT_VALUE'
    if 'consistency' in name_lower:
        return 'CONSISTENCY'
    if 'compliance' in name_lower or 'adherence' in name_lower:
        return 'COMPLIANCE'

    return 'GENERAL'


# Create mapping
mapping = []
for row in old_metrics:
    old_id, display_name, pillar, old_widget, old_chart, old_unit, old_periods, old_default = row

    # Determine new structure
    new_chart_type = determine_chart_type(display_name, old_widget)
    agg_metric_id = determine_agg_metric(old_id, display_name, pillar)
    display_unit = determine_display_unit(display_name, old_widget)
    pattern = determine_pattern(display_name, new_chart_type)

    # Check if agg_metric exists
    agg_exists = agg_metric_id in existing_agg_metrics

    # Default supported periods
    supported_periods = ['daily', 'weekly', 'monthly']

    # Add to mapping
    mapping.append({
        'old_id': old_id,
        'display_name': display_name,
        'pillar': pillar or 'No Pillar',
        'pattern': pattern,
        'new_display_metric_id': old_id if old_id.startswith('DISP_') else f'DISP_{old_id}',
        'agg_metric_id': agg_metric_id,
        'agg_exists': 'YES' if agg_exists else 'NO',
        'chart_type_id': new_chart_type,
        'display_unit': display_unit,
        'supported_periods': ','.join(supported_periods),
        'old_widget_type': old_widget or 'None',
        'old_chart_type': old_chart or 'None'
    })

# Write to CSV
output_file = 'outputs/display_metrics_mapping.csv'
with open(output_file, 'w', newline='') as f:
    fieldnames = ['old_id', 'display_name', 'pillar', 'pattern', 'new_display_metric_id',
                  'agg_metric_id', 'agg_exists', 'chart_type_id', 'display_unit',
                  'supported_periods', 'old_widget_type', 'old_chart_type']
    writer = csv.DictWriter(f, fieldnames=fieldnames)
    writer.writeheader()
    writer.writerows(mapping)

print(f"✅ Mapping created: {output_file}")
print(f"\nTotal metrics: {len(mapping)}")

# Summary by pattern
print("\n=== METRICS BY PATTERN ===")
pattern_counts = {}
for m in mapping:
    pattern = m['pattern']
    pattern_counts[pattern] = pattern_counts.get(pattern, 0) + 1

for pattern in sorted(pattern_counts.keys()):
    print(f"{pattern:25} : {pattern_counts[pattern]:3} metrics")

# Summary of missing agg_metrics
missing_agg = [m for m in mapping if m['agg_exists'] == 'NO']
print(f"\n=== MISSING AGGREGATION METRICS ===")
print(f"Total missing: {len(missing_agg)}")
print(f"Total existing: {len(mapping) - len(missing_agg)}")

# Group missing by pattern
missing_by_pattern = {}
for m in missing_agg:
    pattern = m['pattern']
    if pattern not in missing_by_pattern:
        missing_by_pattern[pattern] = []
    missing_by_pattern[pattern].append(m['agg_metric_id'])

print("\nMissing aggregation metrics by pattern:")
for pattern in sorted(missing_by_pattern.keys()):
    print(f"\n{pattern} ({len(missing_by_pattern[pattern])} missing):")
    for agg_id in missing_by_pattern[pattern][:5]:  # Show first 5
        print(f"  - {agg_id}")
    if len(missing_by_pattern[pattern]) > 5:
        print(f"  ... and {len(missing_by_pattern[pattern]) - 5} more")

cur.close()
conn.close()

print(f"\n✅ Audit complete! Review {output_file}")
