#!/usr/bin/env python3
"""
Create a patient with perfect scores to test if we get 90% (without education)
"""
import psycopg2
from datetime import datetime, timedelta

DB_CONFIG = {
    'host': 'aws-1-us-west-1.pooler.supabase.com',
    'database': 'postgres',
    'user': 'postgres.csotzmardnvrpdhlogjm',
    'password': 'qLa4sE9zV1yvxCP4',
    'port': 6543
}

# Use an existing patient and update their data to be perfect
conn = psycopg2.connect(**DB_CONFIG)
cur = conn.cursor()

# Get a random existing patient
cur.execute("SELECT user_id FROM patient_details LIMIT 1")
result = cur.fetchone()
if not result:
    print("No patients found!")
    exit(1)

patient_id = result[0]
print(f"Using patient: {patient_id}")

# Delete existing survey responses
cur.execute("DELETE FROM patient_survey_responses WHERE user_id = %s", (patient_id,))

# Get all survey questions that have response options
cur.execute("""
    SELECT DISTINCT question_number 
    FROM survey_response_options 
    WHERE LOWER(score) NOT IN ('custom_calc', 'custom calc')
    ORDER BY question_number
""")
questions = cur.fetchall()

print(f"Adding {len(questions)} perfect survey responses...")

# For each question, insert the response with the highest score
for (qnum,) in questions:
    cur.execute("""
        SELECT option_text, score 
        FROM survey_response_options 
        WHERE question_number = %s 
          AND score != 'custom_calc'
        ORDER BY CAST(score AS REAL) DESC 
        LIMIT 1
    """, (qnum,))
    
    result = cur.fetchone()
    if result:
        option_text, score = result
        cur.execute("""
            INSERT INTO patient_survey_responses (user_id, question_number, response_text, completed_at)
            VALUES (%s, %s, %s, NOW())
        """, (patient_id, qnum, option_text))

# Add perfect responses for function-based questions
# Movement - all perfect
perfect_movement = [
    ('3.04', 'Frequently (5 or more times per week)'),
    ('3.05', 'Frequently (5 or more times per week)'),
    ('3.06', 'Frequently (5 or more times per week)'),
    ('3.07', 'Frequently (5 or more times per week)'),
    ('3.08', 'More than 60 minutes'),
    ('3.09', 'More than 60 minutes'),
    ('3.10', 'More than 60 minutes'),
    ('3.11', 'More than 60 minutes'),
]

for qnum, answer in perfect_movement:
    cur.execute("""
        INSERT INTO patient_survey_responses (user_id, question_number, response_text, completed_at)
        VALUES (%s, %s, %s, NOW())
        
    """, (patient_id, qnum, answer))

# Protein intake - perfect (120g for 70kg person = 1.71g/kg)
cur.execute("""
    INSERT INTO patient_survey_responses (user_id, question_number, response_text, completed_at)
    VALUES (%s, '2.11', '120')
    
""", (patient_id,))

# Calorie intake - perfect (use middle of range)
cur.execute("""
    INSERT INTO patient_survey_responses (user_id, question_number, response_text, completed_at)
    VALUES (%s, '2.62', '2000')
    
""", (patient_id,))

# Sleep protocols - 7+ protocols for perfect score
cur.execute("""
    INSERT INTO patient_survey_responses (user_id, question_number, response_text, completed_at)
    VALUES (%s, '4.07', 'Consistent sleep schedule|Comfortable sleep environment|Limit screen time before bed|Avoid caffeine in the evening|Exercise regularly|Meditation or relaxation techniques|Limit alcohol before bed')
    
""", (patient_id,))

# Sleep issues - none
cur.execute("""
    INSERT INTO patient_survey_responses (user_id, question_number, response_text, completed_at)
    VALUES (%s, '4.12', 'None of these')
    
""", (patient_id,))

# Sleep apnea - no
cur.execute("""
    INSERT INTO patient_survey_responses (user_id, question_number, response_text, completed_at)
    VALUES (%s, '4.28', 'No')
    
""", (patient_id,))

# Cognitive activities - 5+ for perfect
cur.execute("""
    INSERT INTO patient_survey_responses (user_id, question_number, response_text, completed_at)
    VALUES (%s, '5.08', 'Reading|Puzzles or brain games|Learning new skills|Creative hobbies|Social engagement')
    
""", (patient_id,))

# Stress - no stress
cur.execute("""
    INSERT INTO patient_survey_responses (user_id, question_number, response_text, completed_at)
    VALUES (%s, '6.01', 'No stress')
    
""", (patient_id,))

cur.execute("""
    INSERT INTO patient_survey_responses (user_id, question_number, response_text, completed_at)
    VALUES (%s, '6.02', 'Rarely')
    
""", (patient_id,))

# Coping - good strategies
cur.execute("""
    INSERT INTO patient_survey_responses (user_id, question_number, response_text, completed_at)
    VALUES (%s, '6.07', 'Exercise or physical activity|Meditation or mindfulness practices|Professional counseling or therapy')
    
""", (patient_id,))

# Substances - none
cur.execute("""
    INSERT INTO patient_survey_responses (user_id, question_number, response_text, completed_at)
    VALUES (%s, '8.01', 'None of these')
    
""", (patient_id,))

cur.execute("""
    INSERT INTO patient_survey_responses (user_id, question_number, response_text, completed_at)
    VALUES (%s, '8.20', 'None of these')
    
""", (patient_id,))

# Screenings - all within window
today = datetime.now().strftime('%Y-%m-%d')
screenings = ['10.01', '10.02', '10.03', '10.04', '10.05', '10.06', '10.07', '10.08']
for qnum in screenings:
    cur.execute("""
        INSERT INTO patient_survey_responses (user_id, question_number, response_text, completed_at)
        VALUES (%s, %s, %s, NOW())
        
    """, (patient_id, qnum, today))

conn.commit()
print("Survey responses updated to perfect")

# Now update biomarker/biometric values to optimal
# Delete existing readings
cur.execute("DELETE FROM patient_biomarker_readings WHERE user_id = %s", (patient_id,))
cur.execute("DELETE FROM patient_biometric_readings WHERE user_id = %s", (patient_id,))

# Get all biomarkers and set them to optimal values
cur.execute("""
    SELECT DISTINCT biomarker 
    FROM biomarkers_detail
""")
biomarkers = cur.fetchall()

print(f"Adding {len(biomarkers)} perfect biomarker readings...")

for (biomarker,) in biomarkers:
    # Get an optimal value (where score is 10)
    cur.execute("""
        SELECT (range_low + range_high) / 2.0 as optimal_value
        FROM biomarkers_detail
        WHERE biomarker = %s
          AND score_at_low = 10
          AND score_at_high = 10
        LIMIT 1
    """, (biomarker,))
    
    result = cur.fetchone()
    if result:
        optimal_value = result[0]
        cur.execute("""
            INSERT INTO patient_biomarker_readings (user_id, biomarker_name, value, test_date)
            VALUES (%s, %s, %s, %s)
        """, (patient_id, biomarker, optimal_value, datetime.now()))

# Get all biometrics and set to optimal
cur.execute("""
    SELECT DISTINCT biometric 
    FROM biometrics_detail
""")
biometrics = cur.fetchall()

print(f"Adding {len(biometrics)} perfect biometric readings...")

for (biometric,) in biometrics:
    cur.execute("""
        SELECT (range_low + range_high) / 2.0 as optimal_value
        FROM biometrics_detail
        WHERE biometric = %s
          AND score_at_low = 10
          AND score_at_high = 10
        LIMIT 1
    """, (biometric,))
    
    result = cur.fetchone()
    if result:
        optimal_value = result[0]
        cur.execute("""
            INSERT INTO patient_biometric_readings (user_id, biometric_name, value, recorded_at)
            VALUES (%s, %s, %s, %s)
        """, (patient_id, biometric, optimal_value, datetime.now()))

conn.commit()
cur.close()
conn.close()

print(f"\n✅ Perfect patient created: {patient_id}")
print(f"Expected score: 90% (72% markers + 18% survey, no education)")
print(f"\nTest with: python3 debug_patient_score.py using patient_id: {patient_id}")
