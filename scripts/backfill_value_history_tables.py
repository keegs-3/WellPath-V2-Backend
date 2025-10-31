#!/usr/bin/env python3
"""
Backfill unified value history tables from existing data sources:
1. patient_survey_responses → patient_behavioral_values_history
2. patient_biometric_readings → patient_marker_values_history
3. patient_biomarker_results → patient_marker_values_history (if exists)
"""

import psycopg2
from datetime import datetime

DATABASE_URL = "postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres"

def backfill_history():
    """Backfill all value history tables"""
    conn = psycopg2.connect(DATABASE_URL)
    cur = conn.cursor()

    try:
        print("="*60)
        print("BACKFILLING VALUE HISTORY TABLES")
        print("="*60)
        print()

        # ==================================================
        # 1. Backfill Behavioral Values History
        # ==================================================
        print("STEP 1: Backfilling behavioral values from survey responses...")
        print("-"*60)

        cur.execute("""
            INSERT INTO patient_behavioral_values_history (
                patient_id,
                question_number,
                response_option_id,
                response_value,
                response_text,
                data_source,
                source_metadata,
                effective_date,
                created_at
            )
            SELECT
                psr.patient_id,
                psr.question_number,
                psr.response_option_id,
                COALESCE(sro.score, psr.response_value, 0) as response_value,
                psr.response_text,
                'questionnaire_initial' as data_source,
                jsonb_build_object(
                    'original_response_id', psr.id,
                    'backfilled', true
                ) as source_metadata,
                psr.completed_at as effective_date,
                NOW() as created_at
            FROM patient_survey_responses psr
            LEFT JOIN survey_response_options sro ON psr.response_option_id = sro.id
            WHERE NOT EXISTS (
                SELECT 1 FROM patient_behavioral_values_history pbvh
                WHERE pbvh.patient_id = psr.patient_id
                  AND pbvh.question_number = psr.question_number
                  AND pbvh.effective_date = psr.completed_at
            )
        """)

        behavioral_count = cur.rowcount
        print(f"  ✓ Backfilled {behavioral_count} behavioral values")
        print()

        # ==================================================
        # 2. Backfill Marker Values History (Biometrics)
        # ==================================================
        print("STEP 2: Backfilling marker values from biometric readings...")
        print("-"*60)

        cur.execute("""
            INSERT INTO patient_marker_values_history (
                patient_id,
                marker_type,
                marker_name,
                marker_value,
                marker_unit,
                data_source,
                source_metadata,
                reading_date,
                created_at
            )
            SELECT
                pbr.patient_id,
                'biometric' as marker_type,
                pbr.biometric_name as marker_name,
                pbr.value as marker_value,
                pbr.unit as marker_unit,
                CASE
                    WHEN pbr.source = 'manual' THEN 'clinician_web'
                    ELSE 'wellpath_app'
                END as data_source,
                jsonb_build_object(
                    'original_reading_id', pbr.id,
                    'backfilled', true
                ) as source_metadata,
                pbr.recorded_at as reading_date,
                NOW() as created_at
            FROM patient_biometric_readings pbr
            WHERE NOT EXISTS (
                SELECT 1 FROM patient_marker_values_history pmvh
                WHERE pmvh.patient_id = pbr.patient_id
                  AND pmvh.marker_name = pbr.biometric_name
                  AND pmvh.reading_date = pbr.recorded_at
            )
        """)

        biometric_count = cur.rowcount
        print(f"  ✓ Backfilled {biometric_count} biometric values")
        print()

        # ==================================================
        # 3. Check for biomarker data
        # ==================================================
        print("STEP 3: Checking for biomarker data...")
        print("-"*60)

        # Check if patient_biomarker_results table exists
        cur.execute("""
            SELECT table_name
            FROM information_schema.tables
            WHERE table_schema = 'public'
              AND table_name = 'patient_biomarker_results'
        """)

        if cur.fetchone():
            cur.execute("""
                INSERT INTO patient_marker_values_history (
                    patient_id,
                    marker_type,
                    marker_name,
                    marker_value,
                    marker_unit,
                    data_source,
                    source_metadata,
                    reading_date,
                    created_at
                )
                SELECT
                    pbr.patient_id,
                    'biomarker' as marker_type,
                    pbr.biomarker_name as marker_name,
                    pbr.value as marker_value,
                    pbr.unit as marker_unit,
                    'clinician_web' as data_source,
                    jsonb_build_object(
                        'original_result_id', pbr.id,
                        'backfilled', true
                    ) as source_metadata,
                    pbr.result_date as reading_date,
                    NOW() as created_at
                FROM patient_biomarker_results pbr
                WHERE NOT EXISTS (
                    SELECT 1 FROM patient_marker_values_history pmvh
                    WHERE pmvh.patient_id = pbr.patient_id
                      AND pmvh.marker_name = pbr.biomarker_name
                      AND pmvh.reading_date = pbr.result_date
                )
            """)

            biomarker_count = cur.rowcount
            print(f"  ✓ Backfilled {biomarker_count} biomarker values")
        else:
            print(f"  - No biomarker results table found (will populate later)")
            biomarker_count = 0

        print()

        conn.commit()

        # Summary
        print("="*60)
        print("SUMMARY")
        print("="*60)

        cur.execute("SELECT COUNT(*) FROM patient_behavioral_values_history")
        total_behavioral = cur.fetchone()[0]

        cur.execute("SELECT COUNT(*) FROM patient_marker_values_history")
        total_marker = cur.fetchone()[0]

        cur.execute("SELECT COUNT(*) FROM patient_education_values_history")
        total_education = cur.fetchone()[0]

        print(f"  Behavioral values backfilled: {behavioral_count}")
        print(f"  Biometric values backfilled: {biometric_count}")
        print(f"  Biomarker values backfilled: {biomarker_count}")
        print()
        print(f"  Total behavioral history records: {total_behavioral}")
        print(f"  Total marker history records: {total_marker}")
        print(f"  Total education history records: {total_education}")
        print()
        print("✅ Backfill complete!")
        print("="*60)

    except Exception as e:
        conn.rollback()
        print(f"❌ Error backfilling history: {e}")
        import traceback
        traceback.print_exc()
        raise
    finally:
        cur.close()
        conn.close()

if __name__ == '__main__':
    backfill_history()
