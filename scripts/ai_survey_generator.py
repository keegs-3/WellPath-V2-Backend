"""
AI-Powered Survey Response Generator

Uses Claude to generate realistic survey responses that match patient archetypes
and their biomarker/biometric profiles.
"""

import sys
import os
from uuid import UUID
import json

sys.path.insert(0, '/Users/keegs/Documents/WellPath/wellpath-v2-backend')

from dotenv import load_dotenv
load_dotenv('/Users/keegs/Documents/WellPath/wellpath-v2-backend/.env')

from anthropic import Anthropic
from database.postgres_client import get_db_connection


def get_patient_profile(patient_id: str):
    """Get patient's biomarkers and biometrics."""
    db = get_db_connection()

    profile = {
        "biomarkers": {},
        "biometrics": {}
    }

    # Get biomarkers
    with db.cursor() as cursor:
        cursor.execute("""
            SELECT biomarker_name, value, unit
            FROM patient_biomarker_readings
            WHERE patient_id = %s
            ORDER BY biomarker_name
        """, (patient_id,))

        for row in cursor.fetchall():
            profile["biomarkers"][row[0]] = {
                "value": float(row[1]),
                "unit": row[2]
            }

    # Get biometrics
    with db.cursor() as cursor:
        cursor.execute("""
            SELECT DISTINCT ON (biometric_name) biometric_name, value, unit
            FROM patient_biometric_readings
            WHERE patient_id = %s
            ORDER BY biometric_name, recorded_at DESC
        """, (patient_id,))

        for row in cursor.fetchall():
            profile["biometrics"][row[0]] = {
                "value": float(row[1]),
                "unit": row[2]
            }

    db.close()
    return profile


def get_survey_questions():
    """Get all survey questions with their response options."""
    db = get_db_connection()

    questions = []

    with db.cursor() as cursor:
        cursor.execute("""
            SELECT DISTINCT
                sq.question_number,
                sq.question_text,
                ARRAY_AGG(DISTINCT sro.option_text ORDER BY sro.option_text) as options
            FROM survey_questions_base sq
            LEFT JOIN survey_response_options sro ON sro.question_number = sq.question_number
            WHERE sq.question_number IS NOT NULL
            GROUP BY sq.question_number, sq.question_text
            ORDER BY sq.question_number
        """)

        for row in cursor.fetchall():
            questions.append({
                "number": float(row[0]),
                "text": row[1],
                "options": [opt for opt in row[2] if opt] if row[2] else []
            })

    db.close()
    return questions


def generate_responses_with_ai(patient_profile, questions, archetype):
    """Use AI to generate realistic survey responses."""

    client = Anthropic(api_key=os.getenv('ANTHROPIC_API_KEY'))

    # Build prompt
    prompt = f"""Generate realistic survey responses for a {archetype} patient.

Patient Profile:
{json.dumps(patient_profile, indent=2)}

Key Biomarker Summary:
- LDL: {patient_profile['biomarkers'].get('LDL', {}).get('value', 'N/A')}
- HbA1c: {patient_profile['biomarkers'].get('HbA1c', {}).get('value', 'N/A')}
- Fasting Glucose: {patient_profile['biomarkers'].get('Fasting Glucose', {}).get('value', 'N/A')}

Key Biometric Summary:
- BMI: {patient_profile['biometrics'].get('BMI', {}).get('value', 'N/A')}
- Body Fat: {patient_profile['biometrics'].get('Bodyfat', {}).get('value', 'N/A')}

Survey Questions (first 50 - answer these realistically for a {archetype} patient):
{json.dumps(questions[:50], indent=2)}

Instructions:
- For "struggling" archetype: Answer honestly with poor/moderate behaviors that MATCH the poor biomarkers
- For "high_performer" archetype: Answer with excellent behaviors that MATCH optimal markers
- For "inconsistent" archetype: Answer with excellent behaviors DESPITE poor markers (lying/unaware)

Response Format (JSON):
{{
  "responses": [
    {{
      "question_number": 2.01,
      "response_text": "Moderately healthy"
    }}
  ]
}}

Answer based on the patient's actual health metrics!"""

    try:
        response = client.messages.create(
            model="claude-sonnet-4-20250514",
            max_tokens=8000,
            temperature=0.7,
            messages=[{"role": "user", "content": prompt}]
        )

        response_text = response.content[0].text

        # Parse JSON
        if "```json" in response_text:
            json_start = response_text.find("```json") + 7
            json_end = response_text.find("```", json_start)
            json_str = response_text[json_start:json_end].strip()
        else:
            json_start = response_text.find("{")
            json_end = response_text.rfind("}") + 1
            json_str = response_text[json_start:json_end]

        result = json.loads(json_str)
        return result.get('responses', [])

    except Exception as e:
        print(f"Error generating responses: {e}")
        return []


def main():
    """Generate complete realistic survey for John Struggling."""
    patient_id = '11111111-1111-1111-1111-111111111111'

    print("="*70)
    print("AI Survey Response Generator")
    print("="*70)
    print(f"\nPatient: John Struggling ({patient_id})")
    print("Archetype: struggling")

    # Get patient data
    print("\n1. Fetching patient profile...")
    profile = get_patient_profile(patient_id)
    print(f"   ✓ {len(profile['biomarkers'])} biomarkers")
    print(f"   ✓ {len(profile['biometrics'])} biometrics")

    # Get survey questions
    print("\n2. Fetching survey questions...")
    questions = get_survey_questions()
    print(f"   ✓ {len(questions)} total questions")

    # Generate responses with AI (do in batches)
    print("\n3. Generating realistic responses with AI...")
    print("   (Processing 50 questions at a time...)")

    all_responses = []
    for i in range(0, min(len(questions), 150), 50):
        batch = questions[i:i+50]
        print(f"   Batch {i//50 + 1}: Questions {i+1}-{min(i+50, len(questions))}")
        responses = generate_responses_with_ai(profile, batch, "struggling")
        all_responses.extend(responses)
        print(f"   ✓ Generated {len(responses)} responses")

    print(f"\n✓ Total responses generated: {len(all_responses)}")

    # Store in database
    print("\n4. Storing in database...")
    db = get_db_connection()

    # Clear existing
    with db.cursor() as cursor:
        cursor.execute("DELETE FROM patient_survey_responses WHERE patient_id = %s", (patient_id,))
        db.commit()

    stored = 0
    for resp in all_responses:
        question_num = resp['question_number']
        response_text = resp['response_text']

        # Find option ID
        with db.cursor() as cursor:
            cursor.execute("""
                SELECT id FROM survey_response_options
                WHERE question_number = %s
                  AND option_text = %s
                LIMIT 1
            """, (float(question_num), response_text))

            row = cursor.fetchone()
            if row:
                cursor.execute("""
                    INSERT INTO patient_survey_responses (
                        patient_id, question_number, response_option_id,
                        response_text, completed_at
                    ) VALUES (%s, %s, %s, %s, CURRENT_TIMESTAMP)
                """, (patient_id, float(question_num), row[0], response_text))
                stored += 1

    db.commit()
    db.close()

    print(f"✓ Stored {stored} responses in database")
    print("\n" + "="*70)
    print("✅ Complete! John Struggling now has realistic survey responses")
    print("="*70)


if __name__ == "__main__":
    main()
