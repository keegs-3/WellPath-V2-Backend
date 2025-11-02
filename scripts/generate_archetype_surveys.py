"""
Generate realistic survey responses based on patient archetype.

Archetypes:
- high_performer: Claims and demonstrates excellent health
- struggling: Claims struggling behaviors that match poor markers
- inconsistent: Claims good behaviors but markers show otherwise (our current test case)
"""

import sys
import os

sys.path.insert(0, '/Users/keegs/Documents/WellPath/wellpath-v2-backend')

from dotenv import load_dotenv
load_dotenv('/Users/keegs/Documents/WellPath/wellpath-v2-backend/.env')

from database.postgres_client import get_db_connection


# Response mappings for struggling patient
STRUGGLING_RESPONSES = {
    "2.01": "Moderately healthy",  # diet quality
    "2.03": "2",  # meals per day
    "2.07": "Several times per week",  # takeout
    "2.09": "No",  # track protein
    "2.11": "75",  # protein grams (lower)
    "2.13": "2-3 times per week",  # processed meat
    "2.15": "Less than once a week",  # fatty fish
    "2.17": "About half",  # plant protein
    "2.19": "1-2",  # fruit servings
    "2.21": "A few times per week",  # whole grains
    "2.23": "A few times per week",  # legumes
    # Exercise
    "3.01": "Moderately active",  # activity level
    "3.03": "Occasionally (1-2 times per week)",  # cardio frequency
    "3.07": "Occasionally (1-2 times per week)",  # strength frequency
    # Sleep
    "4.01": "<6 hours",  # sleep duration
    "4.03": "No",  # sleep timing consistency
}

# Response mappings for high performer
HIGH_PERFORMER_RESPONSES = {
    "2.01": "Very healthy",
    "2.03": "3",
    "2.07": "Rarely",
    "2.09": "Yes",
    "2.11": "150",
    "2.13": "Never or almost never",
    "2.15": "5+ times per week",
    "2.17": "Almost entirely plant-based or Vegan",
    "2.19": "5 or more",
    "2.21": "Daily",
    "2.23": "Daily",
    "3.01": "Very active",
    "3.03": "Frequently (5+ times per week)",
    "3.07": "Frequently (5+ times per week)",
    "4.01": "7-9 hours",
    "4.03": "Yes",
}


def generate_survey_for_archetype(patient_id: str, archetype: str):
    """Generate survey responses for a patient based on archetype."""

    # Choose response set
    if archetype == "struggling":
        response_map = STRUGGLING_RESPONSES
    elif archetype == "high_performer":
        response_map = HIGH_PERFORMER_RESPONSES
    elif archetype == "inconsistent":
        # Claims high performer but has struggling results
        response_map = HIGH_PERFORMER_RESPONSES
    else:
        raise ValueError(f"Unknown archetype: {archetype}")

    db = get_db_connection()

    # Clear existing responses
    with db.cursor() as cursor:
        cursor.execute("DELETE FROM patient_survey_responses WHERE patient_id = %s", (patient_id,))
        db.commit()

    inserted = 0

    # For each mapped response, insert it
    for question_num, response_text in response_map.items():
        # Find the response option ID
        with db.cursor() as cursor:
            cursor.execute("""
                SELECT id FROM survey_response_options
                WHERE question_number = %s
                  AND option_text = %s
                LIMIT 1
            """, (float(question_num), response_text))

            row = cursor.fetchone()
            if row:
                option_id = row[0]

                # Insert response
                cursor.execute("""
                    INSERT INTO patient_survey_responses (
                        patient_id, question_number, response_option_id, response_text, completed_at
                    ) VALUES (%s, %s, %s, %s, CURRENT_TIMESTAMP)
                """, (patient_id, float(question_num), option_id, response_text))
                inserted += 1

    db.commit()
    print(f"✓ Generated {inserted} {archetype} survey responses for patient {patient_id}")
    db.close()


if __name__ == "__main__":
    # Generate struggling responses for John
    generate_survey_for_archetype(
        '11111111-1111-1111-1111-111111111111',
        'struggling'
    )

    # Keep inconsistent (perfect claims) for Jane as a test
    print("\nJohn: Claims struggling behaviors (matches his poor markers)")
    print("Jane: Will test separately")
