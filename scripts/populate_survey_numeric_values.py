#!/usr/bin/env python3
"""
Populate survey_response_options_numeric_values for weighted survey questions.
Uses the existing score field as the numeric value.
"""

import psycopg2

DATABASE_URL = "postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres"

def populate_survey_numeric_values():
    """Populate numeric values for weighted survey response options"""
    conn = psycopg2.connect(DATABASE_URL)
    cur = conn.cursor()

    try:
        print("="*60)
        print("SURVEY RESPONSE OPTIONS NUMERIC VALUES POPULATION")
        print("="*60)
        print()

        # Get all response options for weighted questions
        cur.execute("""
            SELECT DISTINCT
                sro.id,
                sro.question_number,
                sro.option_text,
                sro.score
            FROM survey_response_options sro
            JOIN wellpath_scoring_question_pillar_weights wspqpw
                ON sro.question_number = wspqpw.question_number
            WHERE wspqpw.weight > 0
                AND wspqpw.is_active = true
                AND wspqpw.question_number IS NOT NULL
                AND sro.score IS NOT NULL
            ORDER BY sro.question_number, sro.score
        """)

        response_options = cur.fetchall()
        print(f"Found {len(response_options)} response options for weighted questions")
        print()

        created_count = 0
        skipped_count = 0

        for response_option_id, question_number, option_text, score in response_options:
            # Check if already exists
            cur.execute("""
                SELECT 1 FROM survey_response_options_numeric_values
                WHERE response_option_id = %s
            """, (response_option_id,))

            if cur.fetchone():
                skipped_count += 1
                continue

            # Insert numeric value mapping
            # For now, use the score as the numeric value
            # This represents the relative "healthfulness" of the response
            cur.execute("""
                INSERT INTO survey_response_options_numeric_values (
                    response_option_id,
                    question_number,
                    numeric_value,
                    numeric_value_unit,
                    conversion_method,
                    notes,
                    is_active
                )
                VALUES (%s, %s, %s, %s, %s, %s, %s)
            """, (
                response_option_id,
                question_number,
                score,  # Use score as numeric value
                'score',  # Unit is 'score' (normalized value)
                'exact',  # Conversion method (score is exact value)
                f'Score-based numeric value for: {option_text}',
                True
            ))

            created_count += 1

            if created_count % 50 == 0:
                print(f"  Created {created_count} numeric value mappings...")

        conn.commit()

        print()
        print("="*60)
        print("SUMMARY")
        print("="*60)
        print(f"  Created: {created_count} new numeric value mappings")
        print(f"  Skipped (already exists): {skipped_count}")
        print(f"  Total in database: {created_count + skipped_count}")
        print()
        print("✅ Survey response numeric values population complete!")
        print("="*60)
        print()
        print("NOTE: This uses the existing 'score' field as the numeric value.")
        print("For behavioral tracking, you may want to refine these mappings")
        print("to represent actual frequencies (e.g., times/week, servings/day).")

    except Exception as e:
        conn.rollback()
        print(f"❌ Error populating numeric values: {e}")
        import traceback
        traceback.print_exc()
        raise
    finally:
        cur.close()
        conn.close()

if __name__ == '__main__':
    populate_survey_numeric_values()
