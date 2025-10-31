#!/usr/bin/env python3
"""
Populate screening types reference table.
Links health screenings to survey questions for automatic score updates.
"""

import psycopg2

DATABASE_URL = "postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres"

# Screening types to populate
SCREENING_TYPES = [
    {
        'screening_type_id': 'CARDIAC_SCREENING',
        'screening_name': 'Cardiac Health Screening',
        'description': 'Cardiac health screenings including stress tests, coronary calcium scans, echocardiograms, and cardiac CT.',
        'survey_question_number': 10.09,
        'recommended_frequency_months': 24,  # Every 2 years
        'category': 'cardiac'
    },
    {
        'screening_type_id': 'SLEEP_STUDY',
        'screening_name': 'Sleep Study Test',
        'description': 'Polysomnography or home sleep apnea testing to diagnose sleep disorders.',
        'survey_question_number': 10.10,
        'recommended_frequency_months': 60,  # Every 5 years or as needed
        'category': 'sleep'
    },
    {
        'screening_type_id': 'IMMUNIZATIONS',
        'screening_name': 'Immunizations',
        'description': 'Up-to-date immunizations including flu, pneumonia, shingles, COVID-19, and age-appropriate vaccines.',
        'survey_question_number': 10.11,
        'recommended_frequency_months': 12,  # Annual check
        'category': 'immunization'
    },

    # Additional common screenings (not yet linked to survey questions)
    {
        'screening_type_id': 'COLONOSCOPY',
        'screening_name': 'Colonoscopy',
        'description': 'Colorectal cancer screening via colonoscopy.',
        'survey_question_number': None,
        'recommended_frequency_months': 120,  # Every 10 years (or as recommended)
        'category': 'cancer'
    },
    {
        'screening_type_id': 'MAMMOGRAM',
        'screening_name': 'Mammogram',
        'description': 'Breast cancer screening mammogram.',
        'survey_question_number': None,
        'recommended_frequency_months': 12,  # Annual for high risk, biennial for average risk
        'category': 'cancer'
    },
    {
        'screening_type_id': 'PROSTATE_SCREENING',
        'screening_name': 'Prostate Cancer Screening',
        'description': 'Prostate cancer screening including PSA test and digital rectal exam.',
        'survey_question_number': None,
        'recommended_frequency_months': 12,  # Annual after age 50
        'category': 'cancer'
    },
    {
        'screening_type_id': 'BONE_DENSITY',
        'screening_name': 'Bone Density Scan (DEXA)',
        'description': 'Bone density screening for osteoporosis.',
        'survey_question_number': None,
        'recommended_frequency_months': 24,  # Every 2 years
        'category': 'metabolic'
    },
    {
        'screening_type_id': 'EYE_EXAM',
        'screening_name': 'Comprehensive Eye Exam',
        'description': 'Comprehensive eye examination including visual acuity, glaucoma, and retinal screening.',
        'survey_question_number': None,
        'recommended_frequency_months': 24,  # Every 2 years
        'category': 'general'
    },
    {
        'screening_type_id': 'HEARING_TEST',
        'screening_name': 'Hearing Test',
        'description': 'Audiometry hearing screening.',
        'survey_question_number': None,
        'recommended_frequency_months': 36,  # Every 3 years
        'category': 'general'
    },
    {
        'screening_type_id': 'SKIN_CANCER_SCREENING',
        'screening_name': 'Skin Cancer Screening',
        'description': 'Full-body skin examination for melanoma and other skin cancers.',
        'survey_question_number': None,
        'recommended_frequency_months': 12,  # Annual
        'category': 'cancer'
    },
]

def populate_screening_types():
    """Populate screening types reference table"""
    conn = psycopg2.connect(DATABASE_URL)
    cur = conn.cursor()

    try:
        print("="*60)
        print("SCREENING TYPES POPULATION")
        print("="*60)
        print()

        created_count = 0
        skipped_count = 0
        linked_count = 0

        for screening in SCREENING_TYPES:
            # Check if already exists
            cur.execute("""
                SELECT 1 FROM screening_types
                WHERE screening_type_id = %s
            """, (screening['screening_type_id'],))

            if cur.fetchone():
                print(f"  - Screening type already exists: {screening['screening_type_id']}")
                skipped_count += 1
                continue

            # Verify survey question exists if provided
            if screening['survey_question_number']:
                cur.execute("""
                    SELECT question_text FROM survey_questions_base
                    WHERE question_number = %s
                """, (screening['survey_question_number'],))

                survey_q = cur.fetchone()
                if not survey_q:
                    print(f"  ⚠️  Survey question Q{screening['survey_question_number']} not found for {screening['screening_name']}")

            # Insert screening type
            cur.execute("""
                INSERT INTO screening_types (
                    screening_type_id,
                    screening_name,
                    description,
                    survey_question_number,
                    recommended_frequency_months,
                    category,
                    is_active
                )
                VALUES (%s, %s, %s, %s, %s, %s, %s)
            """, (
                screening['screening_type_id'],
                screening['screening_name'],
                screening['description'],
                screening['survey_question_number'],
                screening['recommended_frequency_months'],
                screening['category'],
                True
            ))

            link_status = f" → Q{screening['survey_question_number']}" if screening['survey_question_number'] else " (no survey link)"
            print(f"  ✓ Created: {screening['screening_name']}{link_status}")
            created_count += 1
            if screening['survey_question_number']:
                linked_count += 1

        conn.commit()

        print()
        print("="*60)
        print("SUMMARY")
        print("="*60)
        print(f"  Created: {created_count} new screening types")
        print(f"  Linked to survey questions: {linked_count}")
        print(f"  Skipped (already exists): {skipped_count}")
        print()

        # Show summary by category
        cur.execute("""
            SELECT
                category,
                COUNT(*) as count,
                COUNT(survey_question_number) as linked_count
            FROM screening_types
            WHERE is_active = true
            GROUP BY category
            ORDER BY category
        """)

        category_summary = cur.fetchall()
        if category_summary:
            print("Screening Types by Category:")
            print("-"*60)
            for category, count, linked in category_summary:
                print(f"  {category.title()}: {count} types ({linked} linked to survey)")
            print()

        # Show linked screenings
        cur.execute("""
            SELECT
                st.screening_type_id,
                st.screening_name,
                st.survey_question_number,
                sq.question_text
            FROM screening_types st
            JOIN survey_questions_base sq ON st.survey_question_number = sq.question_number
            WHERE st.is_active = true
            ORDER BY st.survey_question_number
        """)

        linked_screenings = cur.fetchall()
        if linked_screenings:
            print("Linked to Survey Questions:")
            print("-"*60)
            for type_id, name, q_num, q_text in linked_screenings:
                q_text_short = (q_text[:60] + '...') if len(q_text) > 60 else q_text
                print(f"  {name}")
                print(f"    Q{q_num}: {q_text_short}")
            print()

        print("✅ Screening types population complete!")
        print("="*60)
        print()
        print("How it works:")
        print("  1. Clinician/patient records a screening in patient_screenings")
        print("  2. If screening_status = 'completed', score → 1.0 ('Yes')")
        print("  3. Otherwise, score → 0.2 ('No')")
        print("  4. Creates entry in patient_behavioral_values_history")
        print("  5. data_source = 'clinician_entry' or 'check_in_update'")

    except Exception as e:
        conn.rollback()
        print(f"❌ Error populating screening types: {e}")
        import traceback
        traceback.print_exc()
        raise
    finally:
        cur.close()
        conn.close()

if __name__ == '__main__':
    populate_screening_types()
