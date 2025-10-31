#!/usr/bin/env python3
"""
Map all display_metrics to appropriate display_screens
Creates mappings for both primary (summary) and detail (breakdown) screens
"""

import psycopg2
from collections import defaultdict

DATABASE_URL = "postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres"

# Screen keyword mappings - comprehensive coverage of all 45 screens
SCREEN_KEYWORDS = {
    # Healthful Nutrition
    'SCREEN_PROTEIN': ['protein'],
    'SCREEN_FIBER': ['fiber'],
    'SCREEN_VEGETABLES': ['vegetable', 'veggie'],
    'SCREEN_FRUITS': ['fruit'],
    'SCREEN_WHOLE_GRAINS': ['whole grain', 'grain'],
    'SCREEN_LEGUMES': ['legume', 'bean'],
    'SCREEN_HYDRATION': ['water', 'hydration'],
    'SCREEN_HEALTHY_FATS': ['fat', 'mufa', 'pufa', 'saturated', 'omega'],
    'SCREEN_ADDED_SUGAR': ['sugar', 'added sugar'],
    'SCREEN_MEAL_TIMING': ['meal time', 'eating window', 'first meal', 'last meal', 'meal buffer', 'meal delay', 'fasting', 'fast', 'breakfast', 'lunch', 'dinner', 'snack', 'total meals', 'large meals', 'mindful eating'],
    'SCREEN_MEAL_QUALITY': ['plant based', 'plant protein', 'whole food', 'takeout', 'processed meat', 'red meat', 'fatty fish', 'seed', 'total servings', 'plant-based meals'],
    'SCREEN_NUTRITION_QUALITY': ['ultraprocessed', 'quality'],

    # Movement + Exercise
    'SCREEN_STEPS': ['step'],
    'SCREEN_CARDIO': ['cardio', 'zone 2'],
    'SCREEN_STRENGTH': ['strength training', 'strength sessions'],
    'SCREEN_HIIT': ['hiit'],
    'SCREEN_MOBILITY': ['mobility'],
    'SCREEN_ACTIVITY': ['walking', 'exercise snack', 'calculated active', 'calculated exercise', 'active vs calculated', 'sedentary'],
    'SCREEN_POST_MEAL_ACTIVITY': ['post meal activity', 'post-meal activity', 'post meal exercise', 'post-meal exercise'],
    'SCREEN_FITNESS_METRICS': ['vo2 max', 'resting hr', 'resting heart rate', 'grip strength', 'calories', 'hrv', 'heart rate variability'],

    # Restorative Sleep
    'SCREEN_SLEEP_ANALYSIS': ['total sleep', 'sleep analysis'],
    'SCREEN_SLEEP': ['sleep duration', 'time in bed'],
    'SCREEN_SLEEP_CONSISTENCY': ['wake time consistency'],
    'SCREEN_SLEEP_QUALITY': ['sleep efficiency', 'sleep environment', 'sleep latency', 'rem', 'deep', 'core', 'awake', 'cycles', 'episodes'],
    'SCREEN_SLEEP_TIMING': ['sleep window', 'sleep routine', 'last drink', 'last screen', 'wearable usage'],

    # Core Care
    'SCREEN_BIOMETRICS': ['weight', 'bmi', 'body fat', 'bodyfat', 'waist', 'hip', 'visceral', 'skeletal muscle', 'height', 'phenoage', 'pace', 'omicmage', 'dunedin', 'age', 'blood pressure', 'diastolic', 'systolic'],
    'SCREEN_COMPLIANCE': ['compliance', 'mammogram', 'colonoscopy', 'cervical', 'psa', 'vision', 'skin check', 'breast mri', 'physical', 'screening', 'years since', 'months since'],
    'SCREEN_MEDICATIONS': ['medication', 'supplement', 'peptide', 'adherence'],
    'SCREEN_SKINCARE': ['sunscreen', 'skincare routine'],
    'SCREEN_ORAL_HEALTH': ['brushing', 'flossing'],
    'SCREEN_SUBSTANCES': ['alcohol', 'cigarette', 'smoking', 'caffeine'],
    'SCREEN_ROUTINES': ['evening routine', 'digital shutoff', 'morning routine'],

    # Cognitive Health
    'SCREEN_BRAIN_TRAINING': ['brain training'],
    'SCREEN_COGNITIVE_METRICS': ['focus', 'memory', 'mood'],
    'SCREEN_LIGHT_EXPOSURE': ['sunlight', 'light exposure', 'morning light'],
    'SCREEN_JOURNALING': ['journaling'],

    # Connection + Purpose
    'SCREEN_SOCIAL': ['social'],
    'SCREEN_MINDFULNESS': ['mindfulness'],
    'SCREEN_OUTDOOR_TIME': ['outdoor'],
    'SCREEN_GRATITUDE': ['gratitude'],
    'SCREEN_SCREEN_TIME': ['screen time'],
    'SCREEN_WELLNESS': ['stress level', 'stress management'],

    # Stress Management
    'SCREEN_MEDITATION': ['meditation'],
    'SCREEN_BREATHWORK': ['breathwork'],
}

# Patterns for PRIMARY vs DETAIL classification
PRIMARY_PATTERNS = [
    '_GRAMS', '_DURATION', '_SESSIONS', '_SERVINGS', '_COUNT',
    '_INTAKE', '_CONSUMPTION', '_TOTAL', 'ANALYSIS', 'CONSISTENCY',
    'EFFICIENCY', 'QUALITY', 'SCORE', 'RATE', 'USAGE', 'ADHERENCE',
    'COMPLIANCE', 'MAX', 'MIN', 'AVG', 'RATING'
]

DETAIL_PATTERNS = [
    '_TIMING', '_BY_MEAL', '_BY_', '_SOURCE', '_TYPE', '_PCT',
    '_RATIO', '_VS_', '_CYCLES', '_EPISODES', '_VARIETY',
    '_MEAL_', '_BREAKFAST', '_LUNCH', '_DINNER', '_SNACK',
    '_FACTORS', '_SWAPS', '_COMPARISON'
]

def match_metric_to_screen(metric_name, metric_id):
    """Find the best matching screen for a metric"""
    name_lower = metric_name.lower()
    id_lower = metric_id.lower()

    # Try exact keyword matches
    for screen_id, keywords in SCREEN_KEYWORDS.items():
        for keyword in keywords:
            if keyword in name_lower or keyword in id_lower:
                return screen_id

    return None

def is_primary_metric(metric_id):
    """Determine if metric belongs on PRIMARY (summary) or DETAIL (breakdown) screen"""
    id_upper = metric_id.upper()

    # Check if it matches DETAIL patterns first (more specific)
    for pattern in DETAIL_PATTERNS:
        if pattern in id_upper:
            return False

    # Check if it matches PRIMARY patterns
    for pattern in PRIMARY_PATTERNS:
        if pattern in id_upper:
            return True

    # Default to PRIMARY for unmatched metrics
    return True

def generate_mappings():
    """Generate metric-to-screen mappings"""
    conn = psycopg2.connect(DATABASE_URL)
    cur = conn.cursor()

    print("="*80)
    print("MAPPING ALL DISPLAY_METRICS TO SCREENS")
    print("="*80)

    # Get all active display_metrics
    cur.execute("""
        SELECT metric_id, metric_name, pillar, chart_type_id
        FROM display_metrics
        WHERE is_active = true
        ORDER BY pillar, metric_name
    """)
    all_metrics = cur.fetchall()
    print(f"\n✓ Found {len(all_metrics)} active display_metrics")

    # Get all screens with their primary/detail IDs
    cur.execute("""
        SELECT
            ds.screen_id,
            ds.name,
            ds.pillar,
            dsp.primary_screen_id,
            dsd.detail_screen_id
        FROM display_screens ds
        LEFT JOIN display_screens_primary dsp ON ds.screen_id = dsp.display_screen_id
        LEFT JOIN display_screens_detail dsd ON ds.screen_id = dsd.display_screen_id
        WHERE ds.is_active = true
        ORDER BY ds.pillar, ds.display_order
    """)
    screens = cur.fetchall()
    print(f"✓ Found {len(screens)} active display_screens\n")

    # Create screen lookup
    screen_lookup = {
        screen_id: {
            'name': name,
            'pillar': pillar,
            'primary_screen_id': primary_screen_id,
            'detail_screen_id': detail_screen_id
        }
        for screen_id, name, pillar, primary_screen_id, detail_screen_id in screens
    }

    # Map metrics to screens
    primary_mappings = defaultdict(list)  # primary_screen_id -> [metrics]
    detail_mappings = defaultdict(list)   # detail_screen_id -> [metrics]
    unmapped = []

    for metric_id, metric_name, pillar, chart_type in all_metrics:
        screen_id = match_metric_to_screen(metric_name, metric_id)

        if not screen_id or screen_id not in screen_lookup:
            unmapped.append((metric_id, metric_name, pillar))
            continue

        screen_info = screen_lookup[screen_id]
        is_primary = is_primary_metric(metric_id)

        if is_primary:
            if screen_info['primary_screen_id']:
                primary_mappings[screen_info['primary_screen_id']].append({
                    'metric_id': metric_id,
                    'metric_name': metric_name,
                    'chart_type': chart_type
                })
        else:
            if screen_info['detail_screen_id']:
                detail_mappings[screen_info['detail_screen_id']].append({
                    'metric_id': metric_id,
                    'metric_name': metric_name,
                    'chart_type': chart_type
                })

    # Print summary
    print("="*80)
    print("MAPPING SUMMARY")
    print("="*80)
    print(f"Primary screen mappings: {len(primary_mappings)} screens, {sum(len(m) for m in primary_mappings.values())} metrics")
    print(f"Detail screen mappings: {len(detail_mappings)} screens, {sum(len(m) for m in detail_mappings.values())} metrics")
    print(f"Unmapped metrics: {len(unmapped)}")

    if unmapped:
        print(f"\n⚠️  Unmapped Metrics ({len(unmapped)}):")
        for metric_id, metric_name, pillar in unmapped[:10]:
            print(f"  - {metric_id}: {metric_name} ({pillar})")
        if len(unmapped) > 10:
            print(f"  ... and {len(unmapped) - 10} more")

    # Show screens with most metrics
    print(f"\n📊 Top Primary Screens (by metric count):")
    sorted_primary = sorted(primary_mappings.items(), key=lambda x: len(x[1]), reverse=True)
    for screen_id, metrics in sorted_primary[:10]:
        screen_name = next((s['name'] for s in screen_lookup.values() if s['primary_screen_id'] == screen_id), screen_id)
        print(f"  {screen_name}: {len(metrics)} metrics")

    print(f"\n📊 Top Detail Screens (by metric count):")
    sorted_detail = sorted(detail_mappings.items(), key=lambda x: len(x[1]), reverse=True)
    for screen_id, metrics in sorted_detail[:10]:
        screen_name = next((s['name'] for s in screen_lookup.values() if s['detail_screen_id'] == screen_id), screen_id)
        print(f"  {screen_name}: {len(metrics)} metrics")

    # Generate SQL
    print("\n" + "="*80)
    print("GENERATING SQL MIGRATION")
    print("="*80)

    sql_parts = []

    sql_parts.append("""-- =====================================================
-- Map All Display Metrics to Screens
-- =====================================================
-- Generated: 2025-10-28
-- Maps all 202 display_metrics to primary/detail screens
-- =====================================================

BEGIN;

-- Clear existing mappings (if any)
DELETE FROM display_screens_primary_display_metrics;
DELETE FROM display_screens_detail_display_metrics;

-- =====================================================
-- PRIMARY SCREEN MAPPINGS (Summary Metrics)
-- =====================================================

INSERT INTO display_screens_primary_display_metrics
(primary_screen_id, metric_id, display_order, is_featured)
VALUES
""")

    # Generate PRIMARY mappings
    primary_values = []
    for screen_id, metrics in sorted(primary_mappings.items()):
        for idx, metric in enumerate(metrics):
            primary_values.append(
                f"('{screen_id}', '{metric['metric_id']}', {idx + 1}, {str(idx == 0).lower()})"
            )

    if primary_values:
        sql_parts.append(",\n".join(primary_values))
        sql_parts.append(";\n\n")
    else:
        sql_parts.append("-- No primary mappings\n;\n\n")

    sql_parts.append("""-- =====================================================
-- DETAIL SCREEN MAPPINGS (Breakdown Metrics)
-- =====================================================

INSERT INTO display_screens_detail_display_metrics
(detail_screen_id, metric_id, display_order)
VALUES
""")

    # Generate DETAIL mappings
    detail_values = []
    for screen_id, metrics in sorted(detail_mappings.items()):
        for idx, metric in enumerate(metrics):
            detail_values.append(
                f"('{screen_id}', '{metric['metric_id']}', {idx + 1})"
            )

    if detail_values:
        sql_parts.append(",\n".join(detail_values))
        sql_parts.append(";\n\n")
    else:
        sql_parts.append("-- No detail mappings\n;\n\n")

    sql_parts.append("""-- =====================================================
-- VERIFICATION
-- =====================================================

DO $$
DECLARE
  primary_links INT;
  detail_links INT;
  total_metrics INT;
  unmapped INT;
BEGIN
  SELECT COUNT(*) INTO primary_links FROM display_screens_primary_display_metrics;
  SELECT COUNT(*) INTO detail_links FROM display_screens_detail_display_metrics;
  SELECT COUNT(*) INTO total_metrics FROM display_metrics WHERE is_active = true;

  -- Count metrics that aren't in either junction table
  SELECT COUNT(*) INTO unmapped
  FROM display_metrics dm
  WHERE dm.is_active = true
    AND NOT EXISTS (
      SELECT 1 FROM display_screens_primary_display_metrics
      WHERE metric_id = dm.metric_id
    )
    AND NOT EXISTS (
      SELECT 1 FROM display_screens_detail_display_metrics
      WHERE metric_id = dm.metric_id
    );

  RAISE NOTICE '✅ Display Metrics Mapped to Screens';
  RAISE NOTICE '';
  RAISE NOTICE 'Mappings:';
  RAISE NOTICE '  Primary screens: % metrics', primary_links;
  RAISE NOTICE '  Detail screens: % metrics', detail_links;
  RAISE NOTICE '  Total metrics: %', total_metrics;
  RAISE NOTICE '  Unmapped: % metrics', unmapped;
  RAISE NOTICE '';

  IF unmapped > 0 THEN
    RAISE WARNING '⚠️  % metrics are not mapped to any screen', unmapped;
  END IF;
END $$;

-- Show screens with metric counts
SELECT
  ds.name,
  ds.pillar,
  COUNT(DISTINCT pdm.metric_id) as primary_metrics,
  COUNT(DISTINCT ddm.metric_id) as detail_metrics,
  COUNT(DISTINCT pdm.metric_id) + COUNT(DISTINCT ddm.metric_id) as total_metrics
FROM display_screens ds
LEFT JOIN display_screens_primary dsp ON ds.screen_id = dsp.display_screen_id
LEFT JOIN display_screens_detail dsd ON ds.screen_id = dsd.display_screen_id
LEFT JOIN display_screens_primary_display_metrics pdm ON dsp.primary_screen_id = pdm.primary_screen_id
LEFT JOIN display_screens_detail_display_metrics ddm ON dsd.detail_screen_id = ddm.detail_screen_id
WHERE ds.is_active = true
GROUP BY ds.screen_id, ds.name, ds.pillar, ds.display_order
ORDER BY total_metrics DESC, ds.pillar, ds.display_order
LIMIT 20;

COMMIT;
""")

    # Write SQL to file
    output_file = 'supabase/migrations/20251028_map_all_display_metrics_to_screens.sql'
    with open(output_file, 'w') as f:
        f.write(''.join(sql_parts))

    print(f"✅ SQL migration generated: {output_file}")
    print(f"   Primary mappings: {len(primary_values)} links")
    print(f"   Detail mappings: {len(detail_values)} links")
    print(f"   Total: {len(primary_values) + len(detail_values)} metric-screen links")

    cur.close()
    conn.close()

    return output_file

if __name__ == '__main__':
    generate_mappings()
