-- Restructure pillar about tables to use sections (like wellpath_score_about)
-- Remove duplication, add cross-references

-- =====================================================
-- 1. DROP UNIQUE CONSTRAINTS
-- =====================================================

ALTER TABLE wellpath_pillars_about DROP CONSTRAINT IF EXISTS unique_pillar_about;
ALTER TABLE wellpath_pillars_behaviors_about DROP CONSTRAINT IF EXISTS unique_pillar_behaviors_about;
ALTER TABLE wellpath_pillars_markers_about DROP CONSTRAINT IF EXISTS unique_pillar_markers_about;

-- =====================================================
-- 2. ADD COLUMNS TO wellpath_pillars_about
-- =====================================================

ALTER TABLE wellpath_pillars_about
ADD COLUMN IF NOT EXISTS section_title TEXT,
ADD COLUMN IF NOT EXISTS display_order INTEGER DEFAULT 1;

-- =====================================================
-- 3. BACKUP EXISTING DATA
-- =====================================================

CREATE TEMP TABLE pillars_about_backup AS
SELECT * FROM wellpath_pillars_about;

CREATE TEMP TABLE behaviors_about_backup AS
SELECT * FROM wellpath_pillars_behaviors_about;

CREATE TEMP TABLE markers_about_backup AS
SELECT * FROM wellpath_pillars_markers_about;

-- =====================================================
-- 4. CLEAR EXISTING ROWS
-- =====================================================

DELETE FROM wellpath_pillars_about;
DELETE FROM wellpath_pillars_behaviors_about;
DELETE FROM wellpath_pillars_markers_about;
DELETE FROM wellpath_pillars_education_about;

-- =====================================================
-- 5. CREATE NEW SECTIONED CONTENT FOR wellpath_pillars_about
-- Brief summaries with cross-references
-- =====================================================

-- Movement + Exercise
INSERT INTO wellpath_pillars_about (pillar_id, section_title, about_content, display_order, is_active) VALUES
('recp0marLNu65GGhd', 'What Is Movement + Exercise?',
'Movement and exercise represent powerful interventions that influence virtually every system in your body. This pillar measures your capacity for physical activity, from daily movement patterns to structured exercise, and assesses how these behaviors manifest in measurable fitness and metabolic markers.',
1, true),

('recp0marLNu65GGhd', 'How This Pillar Is Scored',
'Your Movement + Exercise score combines:
• **Biomarkers (54%)**: Cardiovascular markers, metabolic health, body composition proxies
• **Behaviors (36%)**: Activity patterns, exercise frequency, movement quality
• **Education (10%)**: Completion of exercise learning modules

For detailed information on what specific behaviors and biomarkers we track, see the Movement + Exercise Behaviors and Movement + Exercise Markers sections below.',
2, true),

('recp0marLNu65GGhd', 'Why This Matters for Longevity',
'Exercise is arguably the single most potent longevity intervention available. Regular movement affects cardiovascular health, metabolic function, muscle mass preservation, bone density, cognitive function, mental health, and immune system function—influencing lifespan and healthspan more than most medical treatments.',
3, true);

-- Healthful Nutrition
INSERT INTO wellpath_pillars_about (pillar_id, section_title, about_content, display_order, is_active) VALUES
('recgGEypX3ghJay5R', 'What Is Healthful Nutrition?',
'Healthful nutrition is your body''s foundation, providing fuel, building blocks, and protective compounds that influence every biological process. This pillar measures how your dietary choices and eating patterns impact both immediate metabolic health and long-term disease risk.',
1, true),

('recgGEypX3ghJay5R', 'How This Pillar Is Scored',
'Your Healthful Nutrition score combines:
• **Biomarkers (56%)**: Metabolic, cardiovascular, and inflammatory consequences of diet
• **Behaviors (34%)**: Dietary choices, eating patterns, nutritional habits
• **Education (10%)**: Completion of nutrition learning modules

See the Healthful Nutrition Behaviors and Healthful Nutrition Markers sections for comprehensive details on what we measure.',
2, true),

('recgGEypX3ghJay5R', 'Why This Matters for Longevity',
'Diet quality is one of the most powerful determinants of chronic disease risk and longevity. The foods you eat influence inflammation, oxidative stress, metabolic health, cardiovascular function, cancer risk, and cognitive decline—making nutrition a cornerstone of healthy aging.',
3, true);

-- Restorative Sleep
INSERT INTO wellpath_pillars_about (pillar_id, section_title, about_content, display_order, is_active) VALUES
('rec6QXhDyyqwyuLdd', 'What Is Restorative Sleep?',
'Restorative sleep is your body''s essential recovery and repair period. This pillar measures sleep quality, duration, and consistency, along with the metabolic and inflammatory consequences that poor sleep creates.',
1, true),

('rec6QXhDyyqwyuLdd', 'How This Pillar Is Scored',
'Your Restorative Sleep score combines:
• **Biomarkers (52%)**: Metabolic, inflammatory, and stress markers affected by sleep
• **Behaviors (38%)**: Sleep patterns, quality, duration, and sleep hygiene
• **Education (10%)**: Completion of sleep learning modules

For details on sleep behaviors and biomarkers we track, see the Restorative Sleep Behaviors and Restorative Sleep Markers sections.',
2, true),

('rec6QXhDyyqwyuLdd', 'Why This Matters for Longevity',
'Sleep is fundamental to health and longevity. Both short (<7 hours) and long (>9 hours) sleep duration associate with increased mortality. Quality sleep affects brain health, immune function, metabolic regulation, cardiovascular health, and cellular repair processes critical for longevity.',
3, true);

-- Stress Management
INSERT INTO wellpath_pillars_about (pillar_id, section_title, about_content, display_order, is_active) VALUES
('reclbVFCBWmPyvvhP', 'What Is Stress Management?',
'Stress management encompasses your ability to regulate stress responses, maintain emotional equilibrium, and prevent chronic stress activation from damaging your health. This pillar measures both your subjective stress experience and the physiological toll stress takes on your body.',
1, true),

('reclbVFCBWmPyvvhP', 'How This Pillar Is Scored',
'Your Stress Management score combines:
• **Biomarkers (48%)**: Physiological consequences of chronic stress activation
• **Behaviors (42%)**: Stress levels, coping strategies, resilience practices
• **Education (10%)**: Completion of stress management learning modules

See the Stress Management Behaviors and Stress Management Markers sections for comprehensive measurement details.',
2, true),

('reclbVFCBWmPyvvhP', 'Why This Matters for Longevity',
'Chronic stress accelerates biological aging through multiple mechanisms: elevated cortisol, inflammation, oxidative stress, telomere shortening, and immune suppression. Effective stress management is essential for preventing stress-related disease and maintaining longevity.',
3, true);

-- Cognitive Health
INSERT INTO wellpath_pillars_about (pillar_id, section_title, about_content, display_order, is_active) VALUES
('recIdXMUiA9tWGVL8', 'What Is Cognitive Health?',
'Cognitive health encompasses brain function, mental clarity, memory, and the neurological resilience that maintains cognitive performance throughout aging. This pillar measures both subjective cognitive experience and objective markers of brain and vascular health.',
1, true),

('recIdXMUiA9tWGVL8', 'How This Pillar Is Scored',
'Your Cognitive Health score combines:
• **Biomarkers (50%)**: Vascular health, metabolic function, and micronutrients supporting brain health
• **Behaviors (40%)**: Cognitive engagement, mental stimulation, brain-healthy lifestyle practices
• **Education (10%)**: Completion of cognitive health learning modules

For details on cognitive behaviors and biomarkers, see the Cognitive Health Behaviors and Cognitive Health Markers sections.',
2, true),

('recIdXMUiA9tWGVL8', 'Why This Matters for Longevity',
'Cognitive decline is not an inevitable part of aging. Brain health depends heavily on vascular health, metabolic function, inflammation control, and active cognitive engagement. Maintaining cognitive function is critical for both healthspan and quality of life in later years.',
3, true);

-- Connection + Purpose
INSERT INTO wellpath_pillars_about (pillar_id, section_title, about_content, display_order, is_active) VALUES
('recWHZ0F3RQskqHtH', 'What Is Connection + Purpose?',
'Connection and purpose encompass the social relationships, community engagement, and sense of meaning that make life worth living. This pillar recognizes that social and psychological wellbeing have profound impacts on physical health and longevity.',
1, true),

('recWHZ0F3RQskqHtH', 'How This Pillar Is Scored',
'Your Connection + Purpose score combines:
• **Biomarkers (28%)**: Inflammatory and stress markers indirectly reflecting social wellbeing
• **Behaviors (62%)**: Relationship quality, social engagement, sense of purpose
• **Education (10%)**: Completion of connection and purpose learning modules

This pillar is primarily behavioral (62%) given the limited biomarkers available for social health. See Connection + Purpose Behaviors and Connection + Purpose Markers sections for details.',
2, true),

('recWHZ0F3RQskqHtH', 'Why This Matters for Longevity',
'Social isolation and lack of purpose are as harmful to longevity as smoking or obesity. Strong social connections, meaningful relationships, and sense of purpose reduce mortality risk, improve immune function, decrease inflammation, and protect against cognitive decline and depression.',
3, true);

-- Core Care
INSERT INTO wellpath_pillars_about (pillar_id, section_title, about_content, display_order, is_active) VALUES
('recOT0nP41iwVDLKR', 'What Is Core Care?',
'Core Care encompasses the foundational preventive healthcare practices that catch problems early and maintain baseline health. This pillar measures engagement with routine screenings, health monitoring, and proactive care that forms the foundation of longevity medicine.',
1, true),

('recOT0nP41iwVDLKR', 'How This Pillar Is Scored',
'Your Core Care score combines:
• **Biomarkers (60%)**: Foundational health markers everyone should monitor
• **Behaviors (30%)**: Preventive care engagement, screening completion, health monitoring
• **Education (10%)**: Completion of preventive care learning modules

For comprehensive details on core care behaviors and biomarkers, see the Core Care Behaviors and Core Care Markers sections.',
2, true),

('recOT0nP41iwVDLKR', 'Why This Matters for Longevity',
'Preventive care and early detection are cornerstones of longevity medicine. Regular screening catches cancer, cardiovascular disease, and metabolic dysfunction at treatable stages. Monitoring foundational biomarkers allows proactive intervention before disease develops.',
3, true);

SELECT '✅ Created wellpath_pillars_about sections (3 per pillar, 21 total)' as status;
