#!/usr/bin/env python3
"""
Populate mappings between check-in questions and survey questions.
When patients complete check-ins, their responses automatically update behavioral values history.
"""

import psycopg2
import json

DATABASE_URL = "postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres"

# Mappings from check-in questions to survey questions
CHECKIN_SURVEY_MAPPINGS = [
    # ===============================================
    # COGNITIVE HEALTH MAPPINGS
    # ===============================================
    {
        'survey_question_number': 5.01,
        'checkin_question_id': 'Q-COG-001',  # "How would you rate your mental clarity right now?"
        'conversion_method': 'direct',  # Use check-in rating directly
        'conversion_config': None,
        'min_checkin_responses': 3,  # Need at least 3 check-ins
        'lookback_days': 14,  # Average over last 2 weeks
        'update_frequency': 'weekly',
        'notes': 'Maps mental clarity check-ins to cognitive function rating. Averages last 2 weeks of check-ins.'
    },
    {
        'survey_question_number': 5.02,
        'checkin_question_id': 'Q-COG-005',  # "How many memory incidents have you noticed today?"
        'conversion_method': 'threshold',  # If memory incidents > threshold, mark as "Yes" (has concerns)
        'conversion_config': {
            'threshold': 1.5,  # More than 1-2 incidents per day average
            'score_if_above': 0.2,  # "Yes" - has concerns (lower score)
            'score_if_below': 1.0   # "No" - no concerns (higher score)
        },
        'min_checkin_responses': 5,  # Need at least 5 days of data
        'lookback_days': 14,  # Average over last 2 weeks
        'update_frequency': 'weekly',
        'notes': 'If average memory incidents > 1.5/day, marks "Yes" (has concerns). Otherwise "No".'
    },

    # ===============================================
    # SOCIAL/CONNECTION MAPPINGS
    # ===============================================
    {
        'survey_question_number': 7.01,
        'checkin_question_id': 'Q047-MID-01',  # "How has your social interaction routine been going?"
        'conversion_method': 'direct',
        'conversion_config': None,
        'min_checkin_responses': 2,
        'lookback_days': 14,
        'update_frequency': 'weekly',
        'notes': 'Maps social interaction routine rating to quality of social relationships.'
    },
    {
        'survey_question_number': 7.04,
        'checkin_question_id': 'Q054-MID-01',  # "How has your daily social interaction been going?"
        'conversion_method': 'direct',
        'conversion_config': None,
        'min_checkin_responses': 2,
        'lookback_days': 14,
        'update_frequency': 'weekly',
        'notes': 'Maps daily social interaction rating to satisfaction with social interaction amount.'
    },
    {
        'survey_question_number': 7.09,
        'checkin_question_id': 'Q047-MID-01',  # "How has your social interaction routine been going?"
        'conversion_method': 'direct',
        'conversion_config': None,
        'min_checkin_responses': 2,
        'lookback_days': 14,
        'update_frequency': 'weekly',
        'notes': 'Maps social interaction routine to comfort in social situations (proxy measure).'
    },

    # ===============================================
    # MENTAL HEALTH / DEPRESSION MAPPING
    # ===============================================
    {
        'survey_question_number': 10.14,
        'checkin_question_id': 'Q148MID-02',  # "What effects have you noticed since starting your antidepressant medication?"
        'conversion_method': 'scaled',  # Scale the medication effects response
        'conversion_config': {
            'scale_factor': 1.0  # Direct scaling
        },
        'min_checkin_responses': 2,
        'lookback_days': 14,
        'update_frequency': 'weekly',
        'notes': 'Maps antidepressant medication effects to depression rating (inverse relationship expected).'
    },
]

def populate_checkin_survey_mappings():
    """Populate check-in to survey question mappings"""
    conn = psycopg2.connect(DATABASE_URL)
    cur = conn.cursor()

    try:
        print("="*60)
        print("CHECK-IN TO SURVEY QUESTION MAPPINGS")
        print("="*60)
        print()

        created_count = 0
        skipped_count = 0

        for mapping in CHECKIN_SURVEY_MAPPINGS:
            # Check if mapping already exists
            cur.execute("""
                SELECT 1 FROM survey_questions_checkin_mappings
                WHERE survey_question_number = %s
                  AND checkin_question_id = %s
            """, (mapping['survey_question_number'], mapping['checkin_question_id']))

            if cur.fetchone():
                print(f"  - Mapping already exists: Q{mapping['survey_question_number']} ← {mapping['checkin_question_id']}")
                skipped_count += 1
                continue

            # Verify survey question exists
            cur.execute("""
                SELECT question_text FROM survey_questions_base
                WHERE question_number = %s
            """, (mapping['survey_question_number'],))

            survey_q = cur.fetchone()
            if not survey_q:
                print(f"  ⚠️  Survey question Q{mapping['survey_question_number']} not found, skipping...")
                continue

            # Verify check-in question exists
            cur.execute("""
                SELECT question_text FROM checkin_questions
                WHERE question_id = %s
            """, (mapping['checkin_question_id'],))

            checkin_q = cur.fetchone()
            if not checkin_q:
                print(f"  ⚠️  Check-in question {mapping['checkin_question_id']} not found, skipping...")
                continue

            # Insert mapping
            cur.execute("""
                INSERT INTO survey_questions_checkin_mappings (
                    survey_question_number,
                    checkin_question_id,
                    conversion_method,
                    conversion_config,
                    min_checkin_responses,
                    lookback_days,
                    update_frequency,
                    notes,
                    is_active
                )
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
            """, (
                mapping['survey_question_number'],
                mapping['checkin_question_id'],
                mapping['conversion_method'],
                json.dumps(mapping['conversion_config']) if mapping['conversion_config'] else None,
                mapping['min_checkin_responses'],
                mapping['lookback_days'],
                mapping['update_frequency'],
                mapping['notes'],
                True
            ))

            print(f"  ✓ Created: Q{mapping['survey_question_number']} ← {mapping['checkin_question_id']} ({mapping['conversion_method']})")
            created_count += 1

        conn.commit()

        print()
        print("="*60)
        print("SUMMARY")
        print("="*60)
        print(f"  Created: {created_count} new mappings")
        print(f"  Skipped (already exists): {skipped_count}")
        print()

        # Show summary by survey question
        cur.execute("""
            SELECT
                sqcm.survey_question_number,
                sq.question_text,
                COUNT(*) as mapping_count
            FROM survey_questions_checkin_mappings sqcm
            JOIN survey_questions_base sq ON sqcm.survey_question_number = sq.question_number
            WHERE sqcm.is_active = true
            GROUP BY sqcm.survey_question_number, sq.question_text
            ORDER BY sqcm.survey_question_number
        """)

        mappings_summary = cur.fetchall()
        if mappings_summary:
            print("Mapped Survey Questions:")
            print("-"*60)
            for q_num, q_text, count in mappings_summary:
                # Truncate long question text
                q_text_short = (q_text[:70] + '...') if len(q_text) > 70 else q_text
                print(f"  Q{q_num}: {q_text_short}")
                print(f"         ({count} check-in mapping{'s' if count > 1 else ''})")
            print()

        print("✅ Check-in to survey mappings complete!")
        print("="*60)
        print()
        print("How it works:")
        print("  1. Patient completes a check-in question")
        print("  2. Response is recorded in patient_checkin_responses")
        print("  3. Trigger calculates average over lookback period")
        print("  4. Converts to survey score using conversion method")
        print("  5. Creates new entry in patient_behavioral_values_history")
        print("  6. data_source = 'check_in_update'")

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
    populate_checkin_survey_mappings()
