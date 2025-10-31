#!/usr/bin/env python3
"""Test if we can manually insert into patient_item_scores_history"""

import psycopg2
import uuid
from datetime import datetime, timezone

# Connection string
conn_string = "postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres"

try:
    conn = psycopg2.connect(conn_string)
    cur = conn.cursor()

    # Test patient
    patient_id = '8b79ce33-02b8-4f49-8268-3204130efa82'

    # Get patient info
    cur.execute("""
        SELECT biological_sex, date_part('year', age(date_of_birth)) as age
        FROM patients
        WHERE patient_id = %s
    """, (patient_id,))

    patient = cur.fetchone()
    if not patient:
        print("Patient not found!")
        exit(1)

    gender, age = patient
    print(f"Patient: gender={gender}, age={age}")

    # Get a sample biomarker from score items
    cur.execute("""
        SELECT
            biomarker_name,
            pillar_name,
            patient_value,
            patient_value_numeric,
            raw_score,
            normalized_score,
            patient_normalized_score_male,
            max_normalized_score_male,
            raw_weight,
            data_collected_at,
            batch_id
        FROM patient_wellpath_score_items
        WHERE patient_id = %s
        AND biomarker_name IS NOT NULL
        LIMIT 1
    """, (patient_id,))

    item = cur.fetchone()
    if not item:
        print("No score items found!")
        exit(1)

    biomarker_name, pillar_name, patient_value, patient_value_numeric, \
    raw_score, normalized_score, patient_normalized_score_male, \
    max_normalized_score_male, raw_weight, data_collected_at, batch_id = item

    print(f"Sample item: {biomarker_name} in {pillar_name}")
    print(f"Batch ID: {batch_id}")

    # Try to insert a history record
    test_batch_id = str(uuid.uuid4())
    calculated_at = datetime.now(timezone.utc)

    insert_sql = """
        INSERT INTO patient_item_scores_history (
            patient_id,
            batch_id,
            calculated_at,
            pillar_name,
            component_type,
            item_type,
            biomarker_name,
            biometric_name,
            question_number,
            function_name,
            education_module_id,
            item_name,
            item_display_name,
            patient_value,
            patient_value_numeric,
            patient_gender,
            patient_age,
            raw_score,
            normalized_score,
            score_band,
            raw_weight,
            item_weight_in_pillar,
            patient_score_contribution,
            max_score_contribution,
            item_percentage,
            data_collected_at,
            data_source
        ) VALUES (
            %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s
        ) RETURNING id
    """

    patient_score = patient_normalized_score_male if gender == 'male' else 0
    max_score = max_normalized_score_male if gender == 'male' else 0
    item_percentage = (patient_score / max_score * 100) if max_score > 0 else 0

    values = (
        patient_id,
        test_batch_id,
        calculated_at,
        pillar_name,
        'markers',  # component_type for biomarker
        'biomarker',  # item_type
        biomarker_name,  # biomarker_name
        None,  # biometric_name
        None,  # question_number
        None,  # function_name
        None,  # education_module_id
        biomarker_name,  # item_name
        biomarker_name,  # item_display_name
        patient_value,
        patient_value_numeric,
        gender,
        int(age),
        raw_score,
        normalized_score,
        None,  # score_band
        raw_weight,
        max_score,  # item_weight_in_pillar
        patient_score,  # patient_score_contribution
        max_score,  # max_score_contribution
        item_percentage,
        data_collected_at,
        None  # data_source
    )

    print("\nAttempting insert...")
    cur.execute(insert_sql, values)
    inserted_id = cur.fetchone()[0]

    conn.commit()

    print(f"✅ Successfully inserted record with ID: {inserted_id}")

    # Verify it exists
    cur.execute("SELECT COUNT(*) FROM patient_item_scores_history WHERE id = %s", (inserted_id,))
    count = cur.fetchone()[0]
    print(f"✅ Verified: {count} record found")

    # Clean up
    cur.execute("DELETE FROM patient_item_scores_history WHERE id = %s", (inserted_id,))
    conn.commit()
    print("✅ Cleanup complete")

except Exception as e:
    print(f"❌ Error: {e}")
    import traceback
    traceback.print_exc()
finally:
    if 'conn' in locals():
        conn.close()
