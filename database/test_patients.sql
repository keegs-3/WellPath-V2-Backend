-- Quick Test Patients for Agent Testing

-- Patient 1: Struggling (elevated LDL, low activity)
INSERT INTO patients (patient_id, email, first_name, last_name, date_of_birth, medical_practice_id, assigned_clinician_id)
SELECT
    '11111111-1111-1111-1111-111111111111'::uuid,
    'struggling@test.com',
    'John',
    'Struggling',
    '1975-05-15',
    medical_practice_id,
    assigned_clinician_id
FROM patients WHERE patient_id = '8b79ce33-02b8-4f49-8268-3204130efa82'
LIMIT 1
ON CONFLICT DO NOTHING;

-- Add some biomarkers
INSERT INTO patient_biomarker_readings (patient_id, biomarker_name, value, unit, test_date) VALUES
    ('11111111-1111-1111-1111-111111111111', 'LDL', 160, 'milligrams_per_deciliter', CURRENT_DATE - 30),
    ('11111111-1111-1111-1111-111111111111', 'HbA1c', 6.1, 'percent', CURRENT_DATE - 30),
    ('11111111-1111-1111-1111-111111111111', 'Fasting Glucose', 105, 'milligrams_per_deciliter', CURRENT_DATE - 30),
    ('11111111-1111-1111-1111-111111111111', 'HDL', 42, 'milligrams_per_deciliter', CURRENT_DATE - 30),
    ('11111111-1111-1111-1111-111111111111', 'Triglycerides', 180, 'milligrams_per_deciliter', CURRENT_DATE - 30)
ON CONFLICT DO NOTHING;

-- Add biometrics
INSERT INTO patient_biometric_readings (patient_id, biometric_name, value, unit, recorded_at) VALUES
    ('11111111-1111-1111-1111-111111111111', 'BMI', 28.5, 'kg_per_m2', CURRENT_DATE),
    ('11111111-1111-1111-1111-111111111111', 'Bodyfat', 28, 'percent', CURRENT_DATE),
    ('11111111-1111-1111-1111-111111111111', 'Blood Pressure (Systolic)', 135, 'mmHg', CURRENT_DATE),
    ('11111111-1111-1111-1111-111111111111', 'Resting Heart Rate', 75, 'bpm', CURRENT_DATE)
ON CONFLICT DO NOTHING;


-- Patient 2: High Performer (all optimal, high activity)
INSERT INTO patients (patient_id, email, first_name, last_name, date_of_birth, medical_practice_id, assigned_clinician_id)
SELECT
    '22222222-2222-2222-2222-222222222222'::uuid,
    'highperformer@test.com',
    'Jane',
    'Athlete',
    '1985-08-20',
    medical_practice_id,
    assigned_clinician_id
FROM patients WHERE patient_id = '8b79ce33-02b8-4f49-8268-3204130efa82'
LIMIT 1
ON CONFLICT DO NOTHING;

-- Optimal biomarkers
INSERT INTO patient_biomarker_readings (patient_id, biomarker_name, value, unit, test_date) VALUES
    ('22222222-2222-2222-2222-222222222222', 'LDL', 75, 'milligrams_per_deciliter', CURRENT_DATE - 30),
    ('22222222-2222-2222-2222-222222222222', 'HbA1c', 5.0, 'percent', CURRENT_DATE - 30),
    ('22222222-2222-2222-2222-222222222222', 'Fasting Glucose', 85, 'milligrams_per_deciliter', CURRENT_DATE - 30),
    ('22222222-2222-2222-2222-222222222222', 'HDL', 72, 'milligrams_per_deciliter', CURRENT_DATE - 30),
    ('22222222-2222-2222-2222-222222222222', 'Triglycerides', 65, 'milligrams_per_deciliter', CURRENT_DATE - 30)
ON CONFLICT DO NOTHING;

-- Optimal biometrics
INSERT INTO patient_biometric_readings (patient_id, biometric_name, value, unit, recorded_at) VALUES
    ('22222222-2222-2222-2222-222222222222', 'BMI', 21.5, 'kg_per_m2', CURRENT_DATE),
    ('22222222-2222-2222-2222-222222222222', 'Bodyfat', 16, 'percent', CURRENT_DATE),
    ('22222222-2222-2222-2222-222222222222', 'Blood Pressure (Systolic)', 115, 'mmHg', CURRENT_DATE),
    ('22222222-2222-2222-2222-222222222222', 'Resting Heart Rate', 52, 'bpm', CURRENT_DATE),
    ('22222222-2222-2222-2222-222222222222', 'VO2 Max', 48, 'ml_per_kg_per_min', CURRENT_DATE)
ON CONFLICT DO NOTHING;

SELECT 'Test patients created!' as status;
SELECT patient_id, first_name, last_name, email FROM patients WHERE patient_id::text LIKE '1111%' OR patient_id::text LIKE '2222%';
