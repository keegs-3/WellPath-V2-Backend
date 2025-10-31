#!/usr/bin/env python3
"""
Fix biometric pillar assignments and create missing display_metrics
"""

import psycopg2
import uuid

DATABASE_URL = "postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:6543/postgres?sslmode=require"

# Pillar fixes
PILLAR_FIXES = {
    'Total Sleep': 'Restorative Sleep',
    'Water Intake': 'Healthful Nutrition',
    'Steps/Day': 'Movement + Exercise',
    'WellPath PhenoAge': 'Core Care',
    'WellPath PACE': 'Core Care',
    'OMICmAge': 'Core Care',
    'DunedinPACE': 'Core Care'
}

# Display metrics to create
# Format: (biometric_name, metric_name, chart_type, pillar, category, description)
DISPLAY_METRICS_TO_CREATE = [
    ('Blood Pressure (Diastolic)', 'Diastolic Blood Pressure', 'trend_line', 'Core Care', 'vitals',
     'Track your diastolic blood pressure over time'),

    ('Blood Pressure (Systolic)', 'Systolic Blood Pressure', 'trend_line', 'Core Care', 'vitals',
     'Track your systolic blood pressure over time'),

    ('Bodyfat', 'Body Fat Percentage', 'trend_line', 'Healthful Nutrition', 'body_composition',
     'Monitor your body fat percentage trends'),

    ('Hip-to-Waist Ratio', 'Hip-to-Waist Ratio', 'trend_line', 'Healthful Nutrition', 'body_composition',
     'Track your waist-to-hip ratio as an indicator of metabolic health'),

    ('Skeletal Muscle Mass to Fat-Free Mass', 'Skeletal Muscle to Fat-Free Mass Ratio', 'trend_line', 'Movement + Exercise', 'body_composition',
     'Monitor muscle quality and metabolic health'),

    ('Visceral Fat', 'Visceral Fat', 'gauge', 'Healthful Nutrition', 'body_composition',
     'Track visceral fat levels around organs'),

    ('Grip Strength', 'Grip Strength', 'trend_line', 'Movement + Exercise', 'fitness',
     'Monitor grip strength as a predictor of overall health'),

    ('HRV', 'Heart Rate Variability (HRV)', 'trend_line', 'Restorative Sleep', 'fitness',
     'Track HRV to measure stress resilience and recovery'),

    ('Steps/Day', 'Daily Steps', 'bar_vertical', 'Movement + Exercise', 'fitness',
     'Monitor your daily step count'),

    ('Total Sleep', 'Total Sleep Duration', 'trend_line', 'Restorative Sleep', 'sleep',
     'Track total sleep duration per night'),

    ('Water Intake', 'Daily Water Intake', 'bar_vertical', 'Healthful Nutrition', 'hydration',
     'Monitor daily water consumption'),

    ('WellPath PhenoAge', 'WellPath PhenoAge', 'current_value', 'Core Care', 'bioage',
     'Your biological age based on blood biomarkers'),

    ('WellPath PACE', 'WellPath PACE', 'gauge', 'Core Care', 'bioage',
     'Your current pace of aging'),

    ('OMICmAge', 'OMICm Age', 'current_value', 'Core Care', 'bioage',
     'Biological age from DNA methylation patterns'),

    ('DunedinPACE', 'Dunedin PACE', 'gauge', 'Core Care', 'bioage',
     'Rate of biological aging measurement')
]

def fix_pillar_assignments(cur):
    """Fix incorrect pillar assignments"""
    print("\n" + "="*80)
    print("FIXING PILLAR ASSIGNMENTS")
    print("="*80)

    for biometric_name, correct_pillar in PILLAR_FIXES.items():
        cur.execute("""
            UPDATE biometrics_base
            SET pillars = %s, updated_at = NOW()
            WHERE biometric_name = %s
            RETURNING biometric_name, pillars
        """, (correct_pillar, biometric_name))

        result = cur.fetchone()
        if result:
            print(f"✓ {result[0]}: {result[1]}")
        else:
            print(f"❌ {biometric_name}: Not found")

    print(f"\nFixed {len(PILLAR_FIXES)} biometric pillar assignments")

def create_display_metrics(cur):
    """Create missing display_metrics"""
    print("\n" + "="*80)
    print("CREATING DISPLAY METRICS")
    print("="*80)

    # Get the next metric_id number
    cur.execute("""
        SELECT metric_id FROM display_metrics
        WHERE metric_id LIKE 'DISP_DM_%'
        ORDER BY metric_id DESC
        LIMIT 1
    """)

    result = cur.fetchone()
    if result:
        last_id = int(result[0].split('_')[-1])
        next_id = last_id + 1
    else:
        next_id = 1

    created = 0

    for biometric_name, metric_name, chart_type, pillar, category, description in DISPLAY_METRICS_TO_CREATE:
        metric_id = f"DISP_DM_{next_id}"

        # Check if it already exists
        cur.execute("""
            SELECT metric_id FROM display_metrics
            WHERE metric_name = %s
        """, (metric_name,))

        if cur.fetchone():
            print(f"⚠️  {metric_name}: Already exists, skipping")
            continue

        # Create the display metric
        cur.execute("""
            INSERT INTO display_metrics (
                id, metric_id, metric_name, description,
                pillar, chart_type_id,
                is_active, is_primary,
                created_at, updated_at
            ) VALUES (
                %s, %s, %s, %s,
                %s, %s,
                %s, %s,
                NOW(), NOW()
            )
            RETURNING metric_id, metric_name
        """, (
            str(uuid.uuid4()), metric_id, metric_name, description,
            pillar, chart_type,
            True, False
        ))

        result = cur.fetchone()
        if result:
            print(f"✓ {result[0]}: {result[1]} ({chart_type})")
            created += 1
            next_id += 1
        else:
            print(f"❌ Failed to create: {metric_name}")

    print(f"\nCreated {created} new display metrics")
    return created

def main():
    try:
        conn = psycopg2.connect(DATABASE_URL)
        cur = conn.cursor()

        print("="*80)
        print("BIOMETRIC PILLAR FIXES & DISPLAY METRIC CREATION")
        print("="*80)

        # Step 1: Fix pillar assignments
        fix_pillar_assignments(cur)

        # Step 2: Create display metrics
        created = create_display_metrics(cur)

        # Commit changes
        conn.commit()

        print("\n" + "="*80)
        print("✅ COMPLETE")
        print("="*80)
        print(f"Fixed {len(PILLAR_FIXES)} pillar assignments")
        print(f"Created {created} display metrics")

        # Show summary
        cur.execute("""
            SELECT COUNT(*) FROM display_metrics WHERE is_active = true
        """)
        total = cur.fetchone()[0]
        print(f"Total active display metrics: {total}")

        cur.close()
        conn.close()

    except Exception as e:
        print(f"\n❌ Error: {e}")
        import traceback
        traceback.print_exc()
        if 'conn' in locals():
            conn.rollback()

if __name__ == '__main__':
    main()
