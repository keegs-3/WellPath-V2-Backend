#!/usr/bin/env python3
"""
Import missing pillar weights for markers that exist in database with different names
"""

import psycopg2

# Supabase connection
DB_CONFIG = {
    'host': 'aws-1-us-west-1.pooler.supabase.com',
    'database': 'postgres',
    'user': 'postgres.csotzmardnvrpdhlogjm',
    'password': 'qLa4sE9zV1yvxCP4',
    'port': 6543
}

# Missing weights from marker_config.json
# Format: (marker_name_in_db, pillar_name, weight)
MISSING_WEIGHTS = [
    # Bodyfat (was "% Bodyfat" in config)
    ('Bodyfat', 'Cognitive Health', 5),
    ('Bodyfat', 'Healthful Nutrition', 7),
    ('Bodyfat', 'Movement + Exercise', 6),
    ('Bodyfat', 'Restorative Sleep', 4),
    ('Bodyfat', 'Stress Management', 4),

    # Blood Pressure - Systolic (was "Blood Pressure - Systolic" in config)
    ('Blood Pressure (Systolic)', 'Core Care', 8),
    ('Blood Pressure (Systolic)', 'Healthful Nutrition', 5),
    ('Blood Pressure (Systolic)', 'Movement + Exercise', 5),
    ('Blood Pressure (Systolic)', 'Restorative Sleep', 3),
    ('Blood Pressure (Systolic)', 'Stress Management', 4),

    # Blood Pressure - Diastolic (was "Blood Pressure - Diastolic" in config)
    ('Blood Pressure (Diastolic)', 'Core Care', 8),
    ('Blood Pressure (Diastolic)', 'Healthful Nutrition', 5),
    ('Blood Pressure (Diastolic)', 'Movement + Exercise', 5),
    ('Blood Pressure (Diastolic)', 'Restorative Sleep', 3),
    ('Blood Pressure (Diastolic)', 'Stress Management', 3),

    # Cortisol (was "Cortisol (Morning)" in config)
    ('Cortisol', 'Cognitive Health', 6),
    ('Cortisol', 'Connection + Purpose', 5),
    ('Cortisol', 'Movement + Exercise', 2),
    ('Cortisol', 'Restorative Sleep', 5),
    ('Cortisol', 'Stress Management', 8),

    # Neutrophil/Lymphocyte Ratio (was "Neutrocyte/Lymphocyte Ratio" in config)
    ('Neutrophil/Lymphocyte Ratio', 'Cognitive Health', 5),
    ('Neutrophil/Lymphocyte Ratio', 'Core Care', 4),
    ('Neutrophil/Lymphocyte Ratio', 'Healthful Nutrition', 4),
    ('Neutrophil/Lymphocyte Ratio', 'Movement + Exercise', 3),
    ('Neutrophil/Lymphocyte Ratio', 'Restorative Sleep', 2),
    ('Neutrophil/Lymphocyte Ratio', 'Stress Management', 6),
]

def main():
    conn = psycopg2.connect(**DB_CONFIG)
    cur = conn.cursor()

    # Get marker types
    cur.execute("""
        SELECT biomarker_name, 'biomarker' as type FROM biomarkers_base
        WHERE biomarker_name IN (
            'Bodyfat',
            'Blood Pressure (Systolic)',
            'Blood Pressure (Diastolic)',
            'Cortisol',
            'Neutrophil/Lymphocyte Ratio'
        )
        UNION ALL
        SELECT biometric_name AS biomarker_name, 'biometric' as type FROM biometrics_base
        WHERE biometric_name IN (
            'Bodyfat',
            'Blood Pressure (Systolic)',
            'Blood Pressure (Diastolic)',
            'Cortisol',
            'Neutrophil/Lymphocyte Ratio'
        )
    """)
    marker_types = {row[0]: row[1] for row in cur.fetchall()}

    print(f"Found {len(marker_types)} markers in database:")
    for name, mtype in marker_types.items():
        print(f"  - {name} ({mtype})")

    weights_inserted = 0
    weights_failed = 0

    for marker_name, pillar_name, weight in MISSING_WEIGHTS:
        if marker_name not in marker_types:
            print(f"⚠️  Marker not found in database: {marker_name}")
            weights_failed += 1
            continue

        marker_type = marker_types[marker_name]

        try:
            if marker_type == 'biometric':
                cur.execute("""
                    INSERT INTO scoring_marker_pillar_weights (
                        biometric_name, pillar_name, weight, notes
                    )
                    VALUES (%s, %s, %s, %s)
                    ON CONFLICT (biomarker_name, biometric_name, pillar_name, age_min, age_max, gender, risk_level, condition_tag)
                    DO UPDATE SET
                        weight = EXCLUDED.weight,
                        updated_at = NOW()
                """, (marker_name, pillar_name, weight, f'Imported missing weight (name mismatch in marker_config.json)'))
            else:
                cur.execute("""
                    INSERT INTO scoring_marker_pillar_weights (
                        biomarker_name, pillar_name, weight, notes
                    )
                    VALUES (%s, %s, %s, %s)
                    ON CONFLICT (biomarker_name, biometric_name, pillar_name, age_min, age_max, gender, risk_level, condition_tag)
                    DO UPDATE SET
                        weight = EXCLUDED.weight,
                        updated_at = NOW()
                """, (marker_name, pillar_name, weight, f'Imported missing weight (name mismatch in marker_config.json)'))

            weights_inserted += 1
            print(f"✓ Inserted {marker_name} → {pillar_name}: {weight}")

        except Exception as e:
            print(f"⚠️  Error inserting {marker_name} → {pillar_name}: {e}")
            weights_failed += 1
            conn.rollback()
            continue

    conn.commit()

    print("\n" + "="*80)
    print("IMPORT SUMMARY")
    print("="*80)
    print(f"✓ Weights inserted: {weights_inserted}")
    print(f"✗ Weights failed: {weights_failed}")

    # Verify new totals
    print("\n" + "="*80)
    print("NEW TOTALS BY PILLAR")
    print("="*80)

    cur.execute("""
        SELECT
            pillar_name,
            COUNT(*) as marker_count,
            SUM(weight) as total_weight
        FROM scoring_marker_pillar_weights
        WHERE is_active = true
        GROUP BY pillar_name
        ORDER BY pillar_name;
    """)

    expected = {
        'Cognitive Health': 139,
        'Connection + Purpose': 10,
        'Core Care': 137,
        'Healthful Nutrition': 260,
        'Movement + Exercise': 130,
        'Restorative Sleep': 98,
        'Stress Management': 143
    }

    print(f"\n{'Pillar':<25} {'Actual':<10} {'Expected':<10} {'Diff':<10}")
    print("-" * 55)

    for pillar_name, marker_count, total_weight in cur.fetchall():
        exp = expected.get(pillar_name, 0)
        diff = int(total_weight) - exp
        status = "✓" if diff == 0 else "✗"
        print(f"{status} {pillar_name:<23} {int(total_weight):<10} {exp:<10} {diff:<10}")

    cur.close()
    conn.close()

    print("\n✅ Import complete!")

if __name__ == "__main__":
    main()
