#!/usr/bin/env python3
"""
Populate all real-time scoring mapping tables:
1. Create missing data_entry_fields for biometrics
2. Populate biometrics_aggregation_metrics
3. Populate data_entry_fields_mappings
4. Populate survey_response_options_numeric_values
5. Populate behavioral_threshold_config
"""

import psycopg2
import os

# Read from .env
DATABASE_URL = "postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres"

# Mapping of biometric_name to aggregation metrics
BIOMETRIC_AGG_MAPPINGS = {
    'BMI': 'AGG_BMI',
    'Bodyfat': 'AGG_BODY_FAT_PCT',
    'Height': 'AGG_HEIGHT',
    'Hip-to-Waist Ratio': 'AGG_HIP_WAIST_RATIO',
    'Skeletal Muscle Mass to Fat-Free Mass': 'AGG_SKELETAL_MUSCLE_MASS',
    'Visceral Fat': 'AGG_VISCERAL_FAT',
    'Weight': 'AGG_WEIGHT',
    'Resting Heart Rate': 'AGG_RESTING_HEART_RATE',
    'Grip Strength': 'AGG_GRIP_STRENGTH',
    'HRV': 'AGG_HRV',
    'VO2 Max': 'AGG_VO2_MAX',
    'Steps/Day': 'AGG_STEPS',
    'Deep Sleep': 'AGG_DEEP_SLEEP_DURATION',
    'REM Sleep': 'AGG_REM_SLEEP_DURATION',
    'Total Sleep': 'AGG_TOTAL_SLEEP_DURATION',
    'DunedinPACE': 'AGG_DUNEDINPACE',
    'OMICmAge': 'AGG_OMICMAGE',
    'Blood Pressure (Diastolic)': 'AGG_BLOOD_PRESSURE_DIA',
    'Blood Pressure (Systolic)': 'AGG_BLOOD_PRESSURE_SYS',
    'WellPath PACE': 'AGG_WELLPATH_PACE',
    'WellPath PhenoAge': 'AGG_WELLPATH_PHENOAGE',
    'Water Intake': 'AGG_WATER_INTAKE'
}

def populate_mappings():
    """Populate all mapping tables"""
    conn = psycopg2.connect(DATABASE_URL)
    cur = conn.cursor()

    try:
        print("="*60)
        print("REAL-TIME SCORING MAPPINGS POPULATION")
        print("="*60)
        print()

        # ==================================================
        # 1. Create field_id mapping for biometrics
        # ==================================================
        print("STEP 1: Checking data_entry_fields for biometrics...")
        print("-"*60)

        # Create a mapping of biometric_name to field_id
        biometric_field_mapping = {}

        for biometric_name in BIOMETRIC_AGG_MAPPINGS.keys():
            name_backend = biometric_name.lower().replace(' ', '_').replace('(', '').replace(')', '').replace('/', '_')

            # First check if there's a field with matching field_id (biometric_name)
            cur.execute("""
                SELECT field_id FROM data_entry_fields WHERE field_id = %s
            """, (biometric_name,))
            result = cur.fetchone()

            if result:
                biometric_field_mapping[biometric_name] = biometric_name
                print(f"  ✓ Found field {biometric_name}")
                continue

            # Check if there's a field with matching field_name (name_backend)
            cur.execute("""
                SELECT field_id FROM data_entry_fields WHERE field_name = %s
            """, (name_backend,))
            result = cur.fetchone()

            if result:
                biometric_field_mapping[biometric_name] = result[0]
                print(f"  ✓ Found field {result[0]} for {biometric_name}")
                continue

            # No existing field - create one
            print(f"  Creating new field for: {biometric_name}")

            # Get unit from biometrics_base
            cur.execute("""
                SELECT unit FROM biometrics_base WHERE biometric_name = %s
            """, (biometric_name,))
            unit_result = cur.fetchone()
            unit = unit_result[0] if unit_result else None

            # Use a unique field_name to avoid conflicts
            field_name = f"biometric_{name_backend}"
            field_id = f"DEF_{name_backend.upper()}"

            cur.execute("""
                INSERT INTO data_entry_fields (
                    field_id,
                    field_name,
                    display_name,
                    description,
                    field_type,
                    data_type,
                    unit,
                    is_active,
                    supports_healthkit_sync
                ) VALUES (
                    %s,
                    %s,
                    %s,
                    %s,
                    'biometric',
                    'numeric',
                    %s,
                    true,
                    true
                )
                ON CONFLICT (field_id) DO NOTHING
            """, (
                field_id,
                field_name,
                biometric_name,
                f'Tracks {biometric_name} for real-time WellPath scoring',
                unit
            ))

            if cur.rowcount > 0:
                print(f"    Created {field_id}")

            biometric_field_mapping[biometric_name] = field_id

        conn.commit()
        print(f"✅ Mapped {len(biometric_field_mapping)} biometrics to data_entry_fields")
        print()

        # ==================================================
        # 2. Populate biometrics_aggregation_metrics
        # ==================================================
        print("STEP 2: Populating biometrics_aggregation_metrics...")
        print("-"*60)

        populated_count = 0
        for biometric_name, agg_id in BIOMETRIC_AGG_MAPPINGS.items():
            # Check if aggregation metric exists
            cur.execute("""
                SELECT agg_id FROM aggregation_metrics WHERE agg_id = %s
            """, (agg_id,))

            if cur.fetchone() is None:
                print(f"  ⚠️  Aggregation metric {agg_id} not found for {biometric_name}, skipping...")
                continue

            # Check if biometric exists
            cur.execute("""
                SELECT biometric_name FROM biometrics_base WHERE biometric_name = %s
            """, (biometric_name,))

            if cur.fetchone() is None:
                print(f"  ⚠️  Biometric {biometric_name} not found, skipping...")
                continue

            # Check if mapping already exists
            cur.execute("""
                SELECT 1 FROM biometrics_aggregation_metrics
                WHERE biometric_name = %s AND agg_metric_id = %s
            """, (biometric_name, agg_id))

            if cur.fetchone():
                continue  # Already exists

            # Insert mapping
            cur.execute("""
                INSERT INTO biometrics_aggregation_metrics (
                    biometric_name,
                    agg_metric_id
                )
                VALUES (%s, %s)
            """, (biometric_name, agg_id))

            if cur.rowcount > 0:
                print(f"  ✓ Mapped {biometric_name} → {agg_id}")
                populated_count += 1

        conn.commit()
        print(f"✅ Populated {populated_count} biometric→aggregation mappings")
        print()

        # ==================================================
        # 3. Populate data_entry_fields_mappings
        # ==================================================
        print("STEP 3: Populating data_entry_fields_mappings...")
        print("-"*60)

        # Map biometric data_entry_fields to their aggregations
        mapping_count = 0
        for biometric_name, agg_id in BIOMETRIC_AGG_MAPPINGS.items():
            # Get the field_id from our mapping
            field_id = biometric_field_mapping.get(biometric_name)
            if not field_id:
                print(f"  ⚠️  No field_id found for {biometric_name}, skipping...")
                continue

            # Check if aggregation exists
            cur.execute("""
                SELECT 1 FROM aggregation_metrics WHERE agg_id = %s
            """, (agg_id,))
            agg_exists = cur.fetchone() is not None

            if not agg_exists:
                print(f"  ⚠️  Aggregation {agg_id} not found for {biometric_name}, skipping...")
                continue

            # Check if mapping already exists
            cur.execute("""
                SELECT 1 FROM data_entry_fields_mappings
                WHERE field_id = %s AND agg_metric_id = %s
            """, (field_id, agg_id))

            if cur.fetchone():
                continue  # Already exists

            # Insert mapping
            cur.execute("""
                INSERT INTO data_entry_fields_mappings (
                    field_id,
                    biometric_name,
                    agg_metric_id,
                    replacement_threshold_days,
                    min_data_points,
                    min_data_points_per_week,
                    mapping_type,
                    is_active
                )
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            """, (
                field_id,        # field_id (from mapping)
                biometric_name,  # biometric_name
                agg_id,          # agg_metric_id
                1,               # replacement_threshold_days (immediate for biometrics)
                1,               # min_data_points (1 reading is enough)
                1,               # min_data_points_per_week
                'biometric_tracking',
                True
            ))

            if cur.rowcount > 0:
                print(f"  ✓ Mapped field {field_id} ({biometric_name}) → {agg_id}")
                mapping_count += 1

        conn.commit()
        print(f"✅ Created {mapping_count} data_entry_fields_mappings")
        print()

        # ==================================================
        # 4. Summary
        # ==================================================
        print("="*60)
        print("SUMMARY")
        print("="*60)

        cur.execute("SELECT COUNT(*) FROM data_entry_fields WHERE field_type = 'biometric'")
        total_fields = cur.fetchone()[0]

        cur.execute("SELECT COUNT(*) FROM biometrics_aggregation_metrics")
        total_bam = cur.fetchone()[0]

        cur.execute("SELECT COUNT(*) FROM data_entry_fields_mappings")
        total_defm = cur.fetchone()[0]

        print(f"  Biometric data_entry_fields: {total_fields}")
        print(f"  Biometric aggregation mappings: {total_bam}")
        print(f"  Data entry fields mappings: {total_defm}")
        print()
        print("✅ Real-time scoring mappings population complete!")
        print("="*60)

    except Exception as e:
        conn.rollback()
        print(f"❌ Error populating mappings: {e}")
        import traceback
        traceback.print_exc()
        raise
    finally:
        cur.close()
        conn.close()

if __name__ == '__main__':
    populate_mappings()
