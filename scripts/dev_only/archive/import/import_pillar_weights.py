#!/usr/bin/env python3
"""
Import pillar weights from marker_config.json into scoring_marker_pillar_weights table

This imports the existing hardcoded weights to make the system database-driven.
Context-specific weights (age/gender) are left empty for now - can be added later.
"""

import sys
import json
import psycopg2
from pathlib import Path

# Supabase connection
DB_CONFIG = {
    'host': 'aws-1-us-west-1.pooler.supabase.com',
    'database': 'postgres',
    'user': 'postgres.csotzmardnvrpdhlogjm',
    'password': 'qLa4sE9zV1yvxCP4',
    'port': 6543
}

# Pillar name mapping (config uses shortened names)
PILLAR_MAP = {
    "Healthful Nutrition": "Healthful Nutrition",
    "Movement + Exercise": "Movement + Exercise",
    "Restorative Sleep": "Restorative Sleep",
    "Cognitive Health": "Cognitive Health",
    "Stress Management": "Stress Management",
    "Connection + Purpose": "Connection + Purpose",
    "Core Care": "Core Care"
}

def main():
    # Load marker_config.json
    config_path = Path(__file__).parent.parent.parent / 'scoring_engine' / 'configs' / 'marker_config.json'

    if not config_path.exists():
        print(f"❌ marker_config.json not found at {config_path}")
        return

    with open(config_path) as f:
        marker_config = json.load(f)

    print(f"✓ Loaded marker_config.json with {len(marker_config)} markers")

    # Connect to database
    conn = psycopg2.connect(**DB_CONFIG)
    cur = conn.cursor()

    # Get marker name mapping from database
    cur.execute("""
        SELECT biomarker_name, 'biomarker' as type FROM biomarkers_base
        UNION ALL
        SELECT biometric_name AS biomarker_name, 'biometric' as type FROM biometrics_base
    """)
    db_markers = {row[0]: row[1] for row in cur.fetchall()}  # name -> type

    print(f"✓ Loaded {len(db_markers)} markers from database")

    # Track statistics
    markers_processed = 0
    weights_inserted = 0
    weights_skipped = 0
    markers_not_found = []

    # Process each marker in config
    for marker_key, config in marker_config.items():
        marker_name = config['name']

        # Find this marker in database by name
        if marker_name not in db_markers:
            markers_not_found.append(marker_name)
            continue

        marker_type = db_markers[marker_name]
        markers_processed += 1

        # Insert pillar weights
        pillar_weights = config.get('pillar_weights', {})

        for pillar, weight in pillar_weights.items():
            if weight == 0:
                weights_skipped += 1
                continue

            # Map pillar name
            full_pillar_name = PILLAR_MAP.get(pillar, pillar)

            try:
                # Use name-based foreign keys (so much easier to read!)
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
                    """, (marker_name, full_pillar_name, weight, f'Imported from marker_config.json ({marker_key})'))
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
                    """, (marker_name, full_pillar_name, weight, f'Imported from marker_config.json ({marker_key})'))

                weights_inserted += 1

            except Exception as e:
                print(f"⚠️  Error inserting weight for {marker_name} -> {pillar}: {e}")
                conn.rollback()
                continue

        if markers_processed % 10 == 0:
            print(f"  Processed {markers_processed} markers...")
            conn.commit()

    # Final commit
    conn.commit()

    # Summary
    print("\n" + "="*80)
    print("IMPORT SUMMARY")
    print("="*80)
    print(f"✓ Markers processed: {markers_processed}")
    print(f"✓ Weights inserted: {weights_inserted}")
    print(f"  Weights skipped (zero): {weights_skipped}")

    if markers_not_found:
        print(f"\n⚠️  Markers not found in database ({len(markers_not_found)}):")
        for marker in markers_not_found[:10]:
            print(f"    - {marker}")
        if len(markers_not_found) > 10:
            print(f"    ... and {len(markers_not_found) - 10} more")

    # Verification query
    print("\n" + "="*80)
    print("VERIFICATION")
    print("="*80)

    cur.execute("""
        SELECT pillar_name, COUNT(*) as weight_count
        FROM scoring_marker_pillar_weights
        WHERE is_active = true
        GROUP BY pillar_name
        ORDER BY pillar_name
    """)

    print("\nWeights per pillar:")
    for row in cur.fetchall():
        print(f"  {row[0]}: {row[1]} weights")

    cur.execute("""
        SELECT
            COUNT(DISTINCT biomarker_name) + COUNT(DISTINCT biometric_name) as unique_markers
        FROM scoring_marker_pillar_weights
        WHERE is_active = true
    """)
    unique_markers = cur.fetchone()[0]
    print(f"\nUnique markers with weights: {unique_markers}")

    cur.close()
    conn.close()

    print("\n✅ Import complete!")

if __name__ == "__main__":
    main()
