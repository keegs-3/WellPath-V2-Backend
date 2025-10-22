-- =====================================================
-- Seed data for WellPath Score UI
-- Creates initial hierarchy: Pillars + Behaviors example
-- =====================================================

-- =====================================================
-- LEVEL 0: TOP-LEVEL SECTIONS (Pillars + Behaviors)
-- =====================================================

-- 7 Core Pillars
INSERT INTO wellpath_score_display_sections (section_key, parent_section_key, display_order, depth_level, display_name, icon, description, section_type, aggregation_type, aggregation_source) VALUES
('pillar_core_care', NULL, 1, 0, 'Core Care', 'shield-check', 'Your foundation of health - biomarkers, screenings, and preventive care', 'pillar', 'pillar_component', '{"source_type": "pillar", "pillar_name": "Core Care"}'),
('pillar_nutrition', NULL, 2, 0, 'Healthful Nutrition', 'apple', 'What you eat and how it fuels your body', 'pillar', 'pillar_component', '{"source_type": "pillar", "pillar_name": "Healthful Nutrition"}'),
('pillar_movement', NULL, 3, 0, 'Movement + Exercise', 'running', 'Physical activity and fitness', 'pillar', 'pillar_component', '{"source_type": "pillar", "pillar_name": "Movement + Exercise"}'),
('pillar_sleep', NULL, 4, 0, 'Restorative Sleep', 'moon', 'Sleep quality and quantity', 'pillar', 'pillar_component', '{"source_type": "pillar", "pillar_name": "Restorative Sleep"}'),
('pillar_stress', NULL, 5, 0, 'Stress Management', 'brain', 'How you handle stress and build resilience', 'pillar', 'pillar_component', '{"source_type": "pillar", "pillar_name": "Stress Management"}'),
('pillar_cognitive', NULL, 6, 0, 'Cognitive Health', 'lightbulb', 'Mental sharpness and brain health', 'pillar', 'pillar_component', '{"source_type": "pillar", "pillar_name": "Cognitive Health"}'),
('pillar_connection', NULL, 7, 0, 'Connection + Purpose', 'users', 'Relationships and sense of purpose', 'pillar', 'pillar_component', '{"source_type": "pillar", "pillar_name": "Connection + Purpose"}');

-- Cross-pillar view: Behaviors
INSERT INTO wellpath_score_display_sections (section_key, parent_section_key, display_order, depth_level, display_name, icon, description, section_type, aggregation_type, aggregation_source, longevity_impact) VALUES
('behaviors', NULL, 8, 0, 'Behaviors', 'activity', 'Your daily habits and lifestyle choices', 'category', 'custom', NULL, 'Your daily behaviors are the most controllable factors affecting your longevity - research shows they can add or subtract 10-15 years from your lifespan');

-- =====================================================
-- LEVEL 1: PILLAR COMPONENTS
-- =====================================================

-- Core Care components
INSERT INTO wellpath_score_display_sections (section_key, parent_section_key, display_order, depth_level, display_name, icon, description, section_type, aggregation_type, aggregation_source) VALUES
('core_biomarkers', 'pillar_core_care', 1, 1, 'Biomarkers', 'test-tube', 'Lab test results and key health indicators', 'category', 'pillar_component', '{"source_type": "pillar_component", "pillar_name": "Core Care", "component": "markers", "item_type": "biomarker"}'),
('core_biometrics', 'pillar_core_care', 2, 1, 'Biometrics', 'heart-pulse', 'Physical measurements like blood pressure and heart rate', 'category', 'pillar_component', '{"source_type": "pillar_component", "pillar_name": "Core Care", "component": "markers", "item_type": "biometric"}'),
('core_screenings', 'pillar_core_care', 3, 1, 'Preventive Screenings', 'calendar-check', 'Recommended health screenings and checkups', 'category', 'function_rollup', '{"source_type": "functions", "function_names": ["screening_dental_score", "screening_skin_check_score", "screening_vision_score", "screening_colonoscopy_score", "screening_mammogram_score", "screening_pap_score", "screening_psa_score", "screening_hpv_score", "screening_breast_mri_score", "screening_dexa_score"]}');

-- =====================================================
-- LEVEL 1: BEHAVIORS SUB-CATEGORIES
-- =====================================================
INSERT INTO wellpath_score_display_sections (section_key, parent_section_key, display_order, depth_level, display_name, icon, description, section_type, aggregation_type, aggregation_source, longevity_impact) VALUES
('behaviors_substances', 'behaviors', 1, 1, 'Substance Use', 'wine-glass', 'Alcohol, tobacco, and other substances', 'function_group', 'function_rollup',
 '{"source_type": "functions", "function_names": ["substance_alcohol_score", "substance_tobacco_score", "substance_nicotine_score", "substance_recreational_drugs_score", "substance_otc_meds_score", "substance_other_score"]}',
 'Substance use is one of the most significant modifiable risk factors - avoiding tobacco can add 10 years, and limiting alcohol can add 2-5 years'),

('behaviors_movement', 'behaviors', 2, 1, 'Physical Activity', 'running', 'Exercise and movement patterns', 'function_group', 'function_rollup',
 '{"source_type": "functions", "function_names": ["movement_cardio_score", "movement_strength_score", "movement_flexibility_score", "movement_hiit_score"]}',
 'Regular exercise can add 3-7 years to your lifespan and dramatically improve quality of life'),

('behaviors_sleep', 'behaviors', 3, 1, 'Sleep Habits', 'moon', 'Sleep quality and sleep hygiene', 'function_group', 'function_rollup',
 '{"source_type": "functions", "function_names": ["sleep_protocols_score", "sleep_issues_score", "sleep_apnea_management_score"]}',
 'Quality sleep is essential - chronic sleep deprivation can reduce lifespan by 5+ years');

-- =====================================================
-- LEVEL 2: INDIVIDUAL SUBSTANCES
-- =====================================================
INSERT INTO wellpath_score_display_sections (section_key, parent_section_key, display_order, depth_level, display_name, icon, description, section_type, aggregation_type, aggregation_source, quick_tips, longevity_impact) VALUES
('behaviors_substances_alcohol', 'behaviors_substances', 1, 2, 'Alcohol', 'beer', 'Your alcohol consumption patterns', 'individual_item', 'custom',
 '{"source_type": "function", "function_name": "substance_alcohol_score"}',
 '["Limit to 1-2 drinks per day maximum", "Have at least 2-3 alcohol-free days each week", "Avoid binge drinking (5+ drinks in one sitting)", "Track your intake to stay aware"]',
 'Moderate drinking (1-2 drinks/day) has minimal impact. Heavy drinking (15+ drinks/week) can reduce lifespan by 5-10 years and dramatically increase cancer risk'),

('behaviors_substances_tobacco', 'behaviors_substances', 2, 2, 'Tobacco', 'smoking', 'Cigarettes, cigars, and smokeless tobacco', 'individual_item', 'custom',
 '{"source_type": "function", "function_name": "substance_tobacco_score"}',
 '["Quitting smoking is the single best thing you can do for your health", "Seek support - nicotine replacement, counseling, or medication", "Avoid triggers and high-risk situations", "Benefits begin within 20 minutes of quitting"]',
 'Smoking reduces lifespan by 10+ years on average. Quitting before age 40 eliminates almost all excess risk'),

('behaviors_substances_nicotine', 'behaviors_substances', 3, 2, 'Nicotine (Vaping)', 'wind', 'E-cigarettes and vaping products', 'individual_item', 'custom',
 '{"source_type": "function", "function_name": "substance_nicotine_score"}',
 '["Vaping is not risk-free, especially for non-smokers", "If using to quit smoking, work toward quitting vaping too", "Avoid flavored products which can increase addiction", "Be aware of unknown long-term risks"]',
 'Long-term effects still being studied, but nicotine addiction and respiratory issues are established risks'),

('behaviors_substances_recreational_drugs', 'behaviors_substances', 4, 2, 'Recreational Drugs', 'pill', 'Marijuana and other recreational substances', 'individual_item', 'custom',
 '{"source_type": "function", "function_name": "substance_recreational_drugs_score"}',
 '["Understand the legal and health risks in your area", "Avoid use before age 25 when brain is still developing", "Never drive or operate machinery while impaired", "Seek help if use is affecting daily life"]',
 'Impact varies by substance - some have minimal health impact when used moderately, others carry significant risks'),

('behaviors_substances_otc_meds', 'behaviors_substances', 5, 2, 'OTC Medications', 'capsule', 'Over-the-counter sleep aids and pain relievers', 'individual_item', 'custom',
 '{"source_type": "function", "function_name": "substance_otc_meds_score"}',
 '["Use only as directed on the label", "Don''t use sleep aids regularly - address underlying issues", "Avoid long-term NSAID use without medical supervision", "Talk to your doctor about chronic pain or sleep issues"]',
 'Long-term or excessive OTC medication use can cause liver, kidney, or cognitive issues');

-- =====================================================
-- DISPLAY ITEMS - Example: Alcohol questions
-- =====================================================
INSERT INTO wellpath_score_display_items (section_key, display_order, item_type, item_id, display_name, subtitle, description, show_alternative_responses) VALUES
-- Alcohol questions
('behaviors_substances_alcohol', 1, 'survey_question', '8.05', 'Current Use Level', 'How much do you drink?', 'Your current alcohol consumption pattern', TRUE),
('behaviors_substances_alcohol', 2, 'survey_question', '8.06', 'Duration', 'How long have you been drinking at this level?', 'Length of time at current consumption level', FALSE),
('behaviors_substances_alcohol', 3, 'survey_question', '8.07', 'Trend', 'Is your drinking increasing or decreasing?', 'Changes in your drinking patterns over time', FALSE);

-- Core Care biomarkers (examples)
INSERT INTO wellpath_score_display_items (section_key, display_order, item_type, item_id, display_name, subtitle, description, has_chart, chart_screen_key, longevity_impact) VALUES
('core_biomarkers', 1, 'biomarker', 'LDL', 'LDL Cholesterol', 'Bad cholesterol', 'Low-density lipoprotein - primary target for cardiovascular risk reduction', TRUE, 'biomarker_ldl', 'High LDL increases heart disease risk - the leading cause of death globally'),
('core_biomarkers', 2, 'biomarker', 'HDL', 'HDL Cholesterol', 'Good cholesterol', 'High-density lipoprotein - protective against heart disease', TRUE, 'biomarker_hdl', 'Higher HDL is protective - each 1 mg/dL increase reduces heart disease risk by 2-3%'),
('core_biomarkers', 3, 'biomarker', 'Triglycerides', 'Triglycerides', 'Blood fats', 'Fat molecules in your blood - elevated levels increase cardiovascular risk', TRUE, 'biomarker_triglycerides', NULL),
('core_biomarkers', 4, 'biomarker', 'HbA1c', 'HbA1c', 'Blood sugar control', 'Average blood sugar over the past 2-3 months', TRUE, 'biomarker_hba1c', 'Elevated HbA1c dramatically increases diabetes risk and complications');

-- =====================================================
-- QUESTION CONTENT - Example: Alcohol questions
-- =====================================================
INSERT INTO wellpath_score_question_content (question_number, explanation, why_it_matters, longevity_impact, response_content) VALUES
('8.05',
 'This question assesses your typical weekly alcohol consumption pattern.',
 'Alcohol consumption has a complex relationship with health. While light to moderate drinking may have some cardiovascular benefits, heavy drinking significantly increases risk of liver disease, cancer, and other health issues.',
 'The relationship between alcohol and longevity is U-shaped: abstainers and heavy drinkers have shorter lifespans than light-to-moderate drinkers. However, recent research suggests any amount may increase cancer risk.',
 '{
   "Never": {
     "score": 1.0,
     "longevity_impact": "Avoiding alcohol completely eliminates alcohol-related health risks including certain cancers",
     "tips": ["You''re avoiding all alcohol-related health risks", "Great for liver health and cancer prevention", "Consider being a designated driver for friends"],
     "severity": "optimal"
   },
   "Minimal (1-2 drinks per week)": {
     "score": 0.9,
     "longevity_impact": "Very light drinking has minimal health impact for most people",
     "tips": ["This level is considered very low risk", "Continue to track your intake", "Maintain alcohol-free days"],
     "severity": "good"
   },
   "Light (3-6 drinks per week)": {
     "score": 0.7,
     "longevity_impact": "Light drinking may have neutral to slightly positive cardiovascular effects, but slightly increases cancer risk",
     "tips": ["Consider having 2-3 alcohol-free days per week", "Avoid binge drinking episodes", "Stay hydrated when drinking"],
     "severity": "moderate"
   },
   "Moderate (7-14 drinks per week)": {
     "score": 0.4,
     "longevity_impact": "Moderate drinking increases cancer risk and may affect liver function over time",
     "tips": ["Consider reducing to less than 7 drinks per week", "Track your drinking patterns", "Talk to your doctor about your liver health"],
     "severity": "concerning"
   },
   "Heavy (15+ drinks per week)": {
     "score": 0.0,
     "longevity_impact": "Heavy drinking can reduce lifespan by 5-10 years and dramatically increases risk of liver disease, certain cancers, and other conditions",
     "tips": ["Strongly consider speaking with a healthcare provider", "Explore support resources like AA or SMART Recovery", "Screen for liver function regularly"],
     "severity": "critical",
     "resources": ["National Helpline: 1-800-662-4357", "https://www.samhsa.gov/find-help/national-helpline"]
   }
 }'::jsonb
);

-- =====================================================
-- COMMENTS
-- =====================================================
COMMENT ON TABLE wellpath_score_display_sections IS 'Populated with initial hierarchy including 7 pillars and Behaviors cross-pillar view with Substances example';
