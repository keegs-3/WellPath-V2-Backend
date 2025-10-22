-- =====================================================
-- Restructure WellPath Score UI Hierarchy
-- =====================================================
-- New 5-level structure:
-- L0: Overall Score
-- L1: 7 Pillars
-- L2: 4 Component Types per Pillar (biomarkers, biometrics, behaviors, education)
-- L3: Sub-sections within components
-- L4: Individual items (in wellpath_score_display_items table)
-- =====================================================

BEGIN;

-- Update constraints to allow new section types
ALTER TABLE wellpath_score_display_sections
DROP CONSTRAINT IF EXISTS wellpath_score_display_sections_section_type_check;

ALTER TABLE wellpath_score_display_sections
ADD CONSTRAINT wellpath_score_display_sections_section_type_check
CHECK (section_type IN ('overall', 'pillar', 'component', 'subsection', 'category', 'function_group', 'individual_item'));

ALTER TABLE wellpath_score_display_sections
DROP CONSTRAINT IF EXISTS wellpath_score_display_sections_aggregation_type_check;

ALTER TABLE wellpath_score_display_sections
ADD CONSTRAINT wellpath_score_display_sections_aggregation_type_check
CHECK (aggregation_type IN ('pillar_component', 'pillar_rollup', 'function_rollup', 'weighted_average', 'sum', 'custom'));

-- Clear existing sections (will cascade to items due to FK)
TRUNCATE TABLE wellpath_score_display_sections CASCADE;

-- =====================================================
-- LEVEL 0: OVERALL WELLPATH SCORE
-- =====================================================
INSERT INTO wellpath_score_display_sections (section_key, parent_section_key, display_order, depth_level, display_name, icon, description, section_type, aggregation_type, aggregation_source) VALUES
('overall_score', NULL, 0, 0, 'Your WellPath Score', 'heart', 'Your complete health score based on all pillars', 'overall', 'custom', NULL);

-- =====================================================
-- LEVEL 1: 7 PILLARS
-- =====================================================
INSERT INTO wellpath_score_display_sections (section_key, parent_section_key, display_order, depth_level, display_name, icon, description, section_type, aggregation_type, aggregation_source) VALUES
('pillar_core_care', 'overall_score', 1, 1, 'Core Care', 'shield-check', 'Your foundation of health - biomarkers, screenings, and preventive care', 'pillar', 'pillar_rollup', '{"source_type": "pillar", "pillar_name": "Core Care"}'),
('pillar_nutrition', 'overall_score', 2, 1, 'Healthful Nutrition', 'apple', 'What you eat and how it fuels your body', 'pillar', 'pillar_rollup', '{"source_type": "pillar", "pillar_name": "Healthful Nutrition"}'),
('pillar_movement', 'overall_score', 3, 1, 'Movement + Exercise', 'running', 'Physical activity and fitness', 'pillar', 'pillar_rollup', '{"source_type": "pillar", "pillar_name": "Movement + Exercise"}'),
('pillar_sleep', 'overall_score', 4, 1, 'Restorative Sleep', 'moon', 'Sleep quality and quantity', 'pillar', 'pillar_rollup', '{"source_type": "pillar", "pillar_name": "Restorative Sleep"}'),
('pillar_stress', 'overall_score', 5, 1, 'Stress Management', 'brain', 'How you handle stress and build resilience', 'pillar', 'pillar_rollup', '{"source_type": "pillar", "pillar_name": "Stress Management"}'),
('pillar_cognitive', 'overall_score', 6, 1, 'Cognitive Health', 'lightbulb', 'Mental sharpness and brain health', 'pillar', 'pillar_rollup', '{"source_type": "pillar", "pillar_name": "Cognitive Health"}'),
('pillar_connection', 'overall_score', 7, 1, 'Connection + Purpose', 'users', 'Relationships and sense of purpose', 'pillar', 'pillar_rollup', '{"source_type": "pillar", "pillar_name": "Connection + Purpose"}');

-- =====================================================
-- LEVEL 2: 4 COMPONENT TYPES × 7 PILLARS = 28 SECTIONS
-- =====================================================

-- Core Care Components
INSERT INTO wellpath_score_display_sections (section_key, parent_section_key, display_order, depth_level, display_name, icon, description, section_type, aggregation_type, aggregation_source) VALUES
('core_care_biomarkers', 'pillar_core_care', 1, 2, 'Biomarkers', 'test-tube', 'Lab test results', 'component', 'pillar_component', '{"source_type": "pillar_component", "pillar_name": "Core Care", "component": "markers", "item_type": "biomarker"}'),
('core_care_biometrics', 'pillar_core_care', 2, 2, 'Biometrics', 'heart-pulse', 'Physical measurements', 'component', 'pillar_component', '{"source_type": "pillar_component", "pillar_name": "Core Care", "component": "markers", "item_type": "biometric"}'),
('core_care_behaviors', 'pillar_core_care', 3, 2, 'Behaviors', 'activity', 'Survey responses and preventive actions', 'component', 'pillar_component', '{"source_type": "pillar_component", "pillar_name": "Core Care", "component": "survey"}'),
('core_care_education', 'pillar_core_care', 4, 2, 'Education', 'book', 'Health education completion', 'component', 'pillar_component', '{"source_type": "pillar_component", "pillar_name": "Core Care", "component": "education"}');

-- Healthful Nutrition Components
INSERT INTO wellpath_score_display_sections (section_key, parent_section_key, display_order, depth_level, display_name, icon, description, section_type, aggregation_type, aggregation_source) VALUES
('nutrition_biomarkers', 'pillar_nutrition', 1, 2, 'Biomarkers', 'test-tube', 'Nutrition-related lab results', 'component', 'pillar_component', '{"source_type": "pillar_component", "pillar_name": "Healthful Nutrition", "component": "markers", "item_type": "biomarker"}'),
('nutrition_biometrics', 'pillar_nutrition', 2, 2, 'Biometrics', 'heart-pulse', 'Weight, BMI, body composition', 'component', 'pillar_component', '{"source_type": "pillar_component", "pillar_name": "Healthful Nutrition", "component": "markers", "item_type": "biometric"}'),
('nutrition_behaviors', 'pillar_nutrition', 3, 2, 'Behaviors', 'utensils', 'Diet quality and eating habits', 'component', 'pillar_component', '{"source_type": "pillar_component", "pillar_name": "Healthful Nutrition", "component": "survey"}'),
('nutrition_education', 'pillar_nutrition', 4, 2, 'Education', 'book', 'Nutrition education modules', 'component', 'pillar_component', '{"source_type": "pillar_component", "pillar_name": "Healthful Nutrition", "component": "education"}');

-- Movement + Exercise Components
INSERT INTO wellpath_score_display_sections (section_key, parent_section_key, display_order, depth_level, display_name, icon, description, section_type, aggregation_type, aggregation_source) VALUES
('movement_biomarkers', 'pillar_movement', 1, 2, 'Biomarkers', 'test-tube', 'Fitness-related biomarkers', 'component', 'pillar_component', '{"source_type": "pillar_component", "pillar_name": "Movement + Exercise", "component": "markers", "item_type": "biomarker"}'),
('movement_biometrics', 'pillar_movement', 2, 2, 'Biometrics', 'heart-pulse', 'Heart rate, VO2 max, fitness metrics', 'component', 'pillar_component', '{"source_type": "pillar_component", "pillar_name": "Movement + Exercise", "component": "markers", "item_type": "biometric"}'),
('movement_behaviors', 'pillar_movement', 3, 2, 'Behaviors', 'running', 'Exercise habits and activity levels', 'component', 'pillar_component', '{"source_type": "pillar_component", "pillar_name": "Movement + Exercise", "component": "survey"}'),
('movement_education', 'pillar_movement', 4, 2, 'Education', 'book', 'Fitness education modules', 'component', 'pillar_component', '{"source_type": "pillar_component", "pillar_name": "Movement + Exercise", "component": "education"}');

-- Restorative Sleep Components
INSERT INTO wellpath_score_display_sections (section_key, parent_section_key, display_order, depth_level, display_name, icon, description, section_type, aggregation_type, aggregation_source) VALUES
('sleep_biomarkers', 'pillar_sleep', 1, 2, 'Biomarkers', 'test-tube', 'Sleep-related biomarkers', 'component', 'pillar_component', '{"source_type": "pillar_component", "pillar_name": "Restorative Sleep", "component": "markers", "item_type": "biomarker"}'),
('sleep_biometrics', 'pillar_sleep', 2, 2, 'Biometrics', 'moon', 'Sleep tracking metrics', 'component', 'pillar_component', '{"source_type": "pillar_component", "pillar_name": "Restorative Sleep", "component": "markers", "item_type": "biometric"}'),
('sleep_behaviors', 'pillar_sleep', 3, 2, 'Behaviors', 'bed', 'Sleep habits and hygiene', 'component', 'pillar_component', '{"source_type": "pillar_component", "pillar_name": "Restorative Sleep", "component": "survey"}'),
('sleep_education', 'pillar_sleep', 4, 2, 'Education', 'book', 'Sleep education modules', 'component', 'pillar_component', '{"source_type": "pillar_component", "pillar_name": "Restorative Sleep", "component": "education"}');

-- Stress Management Components
INSERT INTO wellpath_score_display_sections (section_key, parent_section_key, display_order, depth_level, display_name, icon, description, section_type, aggregation_type, aggregation_source) VALUES
('stress_biomarkers', 'pillar_stress', 1, 2, 'Biomarkers', 'test-tube', 'Stress hormone levels', 'component', 'pillar_component', '{"source_type": "pillar_component", "pillar_name": "Stress Management", "component": "markers", "item_type": "biomarker"}'),
('stress_biometrics', 'pillar_stress', 2, 2, 'Biometrics', 'heart-pulse', 'HRV, blood pressure, stress indicators', 'component', 'pillar_component', '{"source_type": "pillar_component", "pillar_name": "Stress Management", "component": "markers", "item_type": "biometric"}'),
('stress_behaviors', 'pillar_stress', 3, 2, 'Behaviors', 'brain', 'Stress management practices', 'component', 'pillar_component', '{"source_type": "pillar_component", "pillar_name": "Stress Management", "component": "survey"}'),
('stress_education', 'pillar_stress', 4, 2, 'Education', 'book', 'Stress management education', 'component', 'pillar_component', '{"source_type": "pillar_component", "pillar_name": "Stress Management", "component": "education"}');

-- Cognitive Health Components
INSERT INTO wellpath_score_display_sections (section_key, parent_section_key, display_order, depth_level, display_name, icon, description, section_type, aggregation_type, aggregation_source) VALUES
('cognitive_biomarkers', 'pillar_cognitive', 1, 2, 'Biomarkers', 'test-tube', 'Brain health biomarkers', 'component', 'pillar_component', '{"source_type": "pillar_component", "pillar_name": "Cognitive Health", "component": "markers", "item_type": "biomarker"}'),
('cognitive_biometrics', 'pillar_cognitive', 2, 2, 'Biometrics', 'brain', 'Cognitive performance metrics', 'component', 'pillar_component', '{"source_type": "pillar_component", "pillar_name": "Cognitive Health", "component": "markers", "item_type": "biometric"}'),
('cognitive_behaviors', 'pillar_cognitive', 3, 2, 'Behaviors', 'lightbulb', 'Mental stimulation and cognitive habits', 'component', 'pillar_component', '{"source_type": "pillar_component", "pillar_name": "Cognitive Health", "component": "survey"}'),
('cognitive_education', 'pillar_cognitive', 4, 2, 'Education', 'book', 'Brain health education', 'component', 'pillar_component', '{"source_type": "pillar_component", "pillar_name": "Cognitive Health", "component": "education"}');

-- Connection + Purpose Components
INSERT INTO wellpath_score_display_sections (section_key, parent_section_key, display_order, depth_level, display_name, icon, description, section_type, aggregation_type, aggregation_source) VALUES
('connection_biomarkers', 'pillar_connection', 1, 2, 'Biomarkers', 'test-tube', 'Social health biomarkers', 'component', 'pillar_component', '{"source_type": "pillar_component", "pillar_name": "Connection + Purpose", "component": "markers", "item_type": "biomarker"}'),
('connection_biometrics', 'pillar_connection', 2, 2, 'Biometrics', 'heart-pulse', 'Social engagement metrics', 'component', 'pillar_component', '{"source_type": "pillar_component", "pillar_name": "Connection + Purpose", "component": "markers", "item_type": "biometric"}'),
('connection_behaviors', 'pillar_connection', 3, 2, 'Behaviors', 'users', 'Social connections and purpose', 'component', 'pillar_component', '{"source_type": "pillar_component", "pillar_name": "Connection + Purpose", "component": "survey"}'),
('connection_education', 'pillar_connection', 4, 2, 'Education', 'book', 'Social wellness education', 'component', 'pillar_component', '{"source_type": "pillar_component", "pillar_name": "Connection + Purpose", "component": "education"}');

-- =====================================================
-- LEVEL 3: SUB-SECTIONS (Examples - Core Care Behaviors)
-- =====================================================
INSERT INTO wellpath_score_display_sections (section_key, parent_section_key, display_order, depth_level, display_name, icon, description, section_type, aggregation_type, aggregation_source, quick_tips, longevity_impact) VALUES
('core_care_behaviors_screenings', 'core_care_behaviors', 1, 3, 'Preventive Screenings', 'calendar-check', 'Cancer screenings, checkups, and preventive tests', 'subsection', 'function_rollup',
 '{"source_type": "functions", "function_names": ["screening_dental_score", "screening_skin_check_score", "screening_vision_score", "screening_colonoscopy_score", "screening_mammogram_score", "screening_pap_score", "screening_psa_score", "screening_hpv_score", "screening_breast_mri_score", "screening_dexa_score"]}',
 '["Get age-appropriate cancer screenings", "Regular dental checkups prevent serious issues", "Annual vision exams detect problems early", "Follow screening guidelines for your age and gender"]',
 'Regular screenings can detect cancers and conditions early when they are most treatable, significantly improving outcomes and longevity');

-- Core Care Behaviors - Substances (example sub-section with individual items)
INSERT INTO wellpath_score_display_sections (section_key, parent_section_key, display_order, depth_level, display_name, icon, description, section_type, aggregation_type, aggregation_source, quick_tips, longevity_impact) VALUES
('core_care_behaviors_substances', 'core_care_behaviors', 2, 3, 'Substance Use', 'wine-glass', 'Alcohol, tobacco, and other substances', 'subsection', 'function_rollup',
 '{"source_type": "functions", "function_names": ["substance_alcohol_score", "substance_tobacco_score", "substance_nicotine_score", "substance_recreational_drugs_score", "substance_otc_meds_score"]}',
 '["Limit alcohol to 1-2 drinks per day", "Quit tobacco - it''s the single best thing for your health", "Avoid recreational drug use", "Use medications only as directed"]',
 'Substance use is one of the most significant modifiable risk factors - avoiding tobacco can add 10 years, limiting alcohol can add 2-5 years');

-- =====================================================
-- LEVEL 3: SUB-SECTIONS (Examples - Nutrition Behaviors)
-- =====================================================
INSERT INTO wellpath_score_display_sections (section_key, parent_section_key, display_order, depth_level, display_name, icon, description, section_type, aggregation_type, aggregation_source) VALUES
('nutrition_behaviors_diet_quality', 'nutrition_behaviors', 1, 3, 'Diet Quality', 'apple', 'What you eat and nutritional balance', 'subsection', 'function_rollup',
 '{"source_type": "functions", "function_names": ["nutrition_diet_quality_score", "nutrition_vegetable_intake_score", "nutrition_fruit_intake_score"]}'),

('nutrition_behaviors_meal_timing', 'nutrition_behaviors', 2, 3, 'Meal Timing', 'clock', 'When and how often you eat', 'subsection', 'function_rollup',
 '{"source_type": "functions", "function_names": ["nutrition_meal_frequency_score", "nutrition_fasting_score"]}'),

('nutrition_behaviors_hydration', 'nutrition_behaviors', 3, 3, 'Hydration', 'droplet', 'Water and fluid intake', 'subsection', 'function_rollup',
 '{"source_type": "functions", "function_names": ["nutrition_hydration_score"]}');

COMMIT;

-- =====================================================
-- VERIFICATION
-- =====================================================
SELECT
    'Total Sections' as metric,
    COUNT(*)::text as value
FROM wellpath_score_display_sections

UNION ALL

SELECT
    'Level 0 (Overall)',
    COUNT(*)::text
FROM wellpath_score_display_sections
WHERE depth_level = 0

UNION ALL

SELECT
    'Level 1 (Pillars)',
    COUNT(*)::text
FROM wellpath_score_display_sections
WHERE depth_level = 1

UNION ALL

SELECT
    'Level 2 (Components)',
    COUNT(*)::text
FROM wellpath_score_display_sections
WHERE depth_level = 2

UNION ALL

SELECT
    'Level 3 (Sub-sections)',
    COUNT(*)::text
FROM wellpath_score_display_sections
WHERE depth_level = 3;

-- =====================================================
-- COMMENTS
-- =====================================================
COMMENT ON TABLE wellpath_score_display_sections IS
'Restructured with 5-level hierarchy: L0=Overall, L1=7 Pillars, L2=4 Components per Pillar, L3=Sub-sections, L4=Items (in display_items table)';
