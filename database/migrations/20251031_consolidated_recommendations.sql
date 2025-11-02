-- Consolidated Recommendations
-- Clean, agent-ready recommendations with readable IDs


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'increase_fiber_intake',
    'Increase Fiber Intake',
    'Fiber supports metabolic health, digestive function, and cardiovascular resilience. It helps the body eliminate excess cholesterol, regulates blood sugar, and promotes a healthier gut microbiome. Found in foods like oats, beans, flaxseed, and psyllium, soluble fiber is a foundational component of a longevity-supportive diet.',
    'Increase daily fiber intake through whole foods',
    'nutrition',
    'Dietary',
    'ApoB,Fasting Glucose,HOMA-IR,HbA1c,LDL',
    'Fasting Glucose,Fasting Insulin,HOMA-IR,hsCRP',
    '',
    '',
    'BMI,Blood Pressure (Diastolic),Blood Pressure (Systolic),Bodyfat',
    '',
    75,
    'LI019,LI020,LI021',
    '',
    '{"has_difficulty_levels": true, "source_base_id": "REC0001"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'prioritize_healthy_fats_over_saturated_fats',
    'Prioritize Healthy Fats Over Saturated Fats',
    'Swapping saturated fats for healthier fats like olive oil, avocados, nuts, and fatty fish supports heart and brain health, lowers systemic inflammation, and promotes metabolic balance. These fats are core components of dietary patterns linked to increased longevity and reduced chronic disease risk.',
    'Prioritize healthy fats (olive oil, avocado, nuts, fish) over saturated fats',
    'nutrition',
    'Dietary',
    'HbA1c,LDL,Omega-3 Index,Total Cholesterol,Triglycerides,hsCRP',
    'Fasting Glucose,Fasting Insulin,HDL,HOMA-IR,hsCRP',
    '',
    '',
    'BMI,Blood Pressure (Diastolic),Blood Pressure (Systolic),Bodyfat,Hip-to-Waist Ratio,Skeletal Muscle Mass to Fat-Free Mass',
    '',
    70,
    'LI016,LI017,LI018',
    '',
    '{"has_difficulty_levels": true, "source_base_id": "REC0002"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'incorporate_zone_2_cardio_for_mitochondrial_and_ca',
    'Incorporate Zone 2 Cardio for Mitochondrial and Cardiovascular Health',
    'Zone 2 cardio involves sustained, moderate-intensity aerobic exercise that keeps your heart rate within a range that maximizes fat oxidation and mitochondrial efficiency. Training in this zone improves metabolic flexibility, insulin sensitivity, and cardiovascular resilience. It''s foundational for longevity, endurance, and energy metabolism. You should be able to maintain conversation, but feel like you’re working.',
    'Perform Zone 2 cardio (moderate intensity, conversational pace) regularly',
    'movement',
    'Activity',
    'Fasting Insulin,HOMA-IR,hsCRP',
    'ApoB,Fasting Glucose,HDL,HbA1c,Triglycerides',
    '',
    'Blood Pressure (Diastolic),Blood Pressure (Systolic),HRV,Resting Heart Rate,VO2 Max',
    'Bodyfat,Deep Sleep,Hip-to-Waist Ratio,REM Sleep,Total Sleep',
    '',
    85,
    'LI022,LI023,LI024',
    '',
    '{"has_difficulty_levels": true, "source_base_id": "REC0003"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'prioritize_79_hours_of_consistent_sleep_for_recove',
    'Prioritize 7–9 Hours of Consistent Sleep for Recovery and Longevity',
    'Consistently getting 7–9 hours of sleep supports cellular repair, metabolic regulation, hormonal balance, and cognitive performance. Sleep is when your body consolidates memory, clears neural waste, and recalibrates critical systems like immune response and glucose control. Building a foundation of sufficient sleep — and doing it consistently — is one of the most powerful longevity levers available.',
    'Sleep 7-9 hours consistently each night',
    'sleep',
    'Behavior',
    'Cortisol,Fasting Glucose,Fasting Insulin,HOMA-IR,HbA1c,Neutrophil/Lymphocyte Ratio',
    'ApoB,Free Testosterone,HDL,Testosterone,Triglycerides,Vitamin D,hsCRP',
    '',
    'Deep Sleep,HRV,REM Sleep,Resting Heart Rate,Total Sleep',
    'BMI,Blood Pressure (Diastolic),Blood Pressure (Systolic),Bodyfat',
    '',
    95,
    'LI025,LI026,LI141,LI142,LI143',
    '',
    '{"has_difficulty_levels": true, "source_base_id": "REC0004"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'reduce_or_eliminate_alcohol_consumption',
    'Reduce or Eliminate Alcohol Consumption',
    'Alcohol affects liver health, metabolic function, sleep quality, inflammation, and hormonal balance. For users with elevated GGT, ALT, hsCRP, or disrupted sleep, moderating or removing alcohol intake can lead to significant improvements in biomarker trends and subjective well-being over a 3–4 month protocol.',
    'Reduce or eliminate alcohol consumption',
    'nutrition',
    'Behavior',
    'ALT,AST,Fasting Glucose,Fasting Insulin,GGT,HOMA-IR,hsCRP',
    'Cortisol,HDL,Testosterone,Triglycerides,hsCRP',
    '',
    'Blood Pressure (Diastolic),Blood Pressure (Systolic),REM Sleep,Resting Heart Rate,Total Sleep',
    'BMI,Bodyfat,Deep Sleep,HRV,Weight',
    '',
    75,
    'LI027,LI028,LI029',
    '',
    '{"has_difficulty_levels": true, "source_base_id": "REC0005"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'increase_protein_intake',
    'Increase Protein Intake',
    'Protein is essential for building and maintaining lean muscle, supporting metabolic health, and promoting satiety. Regularly including high-quality protein sources in your meals enhances recovery, supports healthy aging, and helps maintain energy and body composition.',
    'Increase protein intake to support muscle maintenance',
    'nutrition',
    'Dietary',
    'Albumin,ApoB,Fasting Glucose,Fasting Insulin,HOMA-IR,HbA1c',
    'HDL,SHBG,Triglycerides,Vitamin B12,hsCRP',
    '',
    'Blood Pressure (Diastolic),Blood Pressure (Systolic),Grip Strength,Skeletal Muscle Mass to Fat-Free Mass',
    'BMI,Bodyfat,Grip Strength,Hip-to-Waist Ratio',
    '',
    80,
    'LI030,LI031,LI032',
    '',
    '{"has_difficulty_levels": true, "source_base_id": "REC0006"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'increase_vegetable_intake',
    'Increase Vegetable Intake',
    'Regular vegetable intake supports metabolic health, cardiovascular resilience, and digestive function. Vegetables provide essential micronutrients, fiber, and phytonutrients linked to healthy aging, inflammation reduction, and chronic disease risk reduction.',
    'Eat more vegetables daily for micronutrients and fiber',
    'nutrition',
    'Dietary',
    'ApoB,Fasting Glucose,Fasting Insulin,HOMA-IR,HbA1c,LDL,Total Cholesterol,Triglycerides,hsCRP',
    'Estradiol,Fasting Glucose,Homocysteine,Magnesium (RBC),Potassium,Triglycerides,Vitamin B12,eGFR,hsCRP',
    'Omega-3 Index',
    'BMI,Blood Pressure (Diastolic),Blood Pressure (Systolic),Bodyfat',
    'BMI,Bodyfat,Deep Sleep,Hip-to-Waist Ratio,REM Sleep,Total Sleep',
    '',
    85,
    'LI033,LI034,LI035',
    '',
    '{"has_difficulty_levels": true, "source_base_id": "REC0007"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'increase_fruit_intake',
    'Increase Fruit Intake',
    'Regular fruit intake provides essential vitamins, minerals, antioxidants, and fiber. Eating a variety of fruits supports metabolic health, immune function, healthy aging, and helps lower risk of chronic diseases.',
    'Include fruits in daily diet for antioxidants and fiber',
    'nutrition',
    'Dietary',
    'ApoB,LDL,Neutrophil/Lymphocyte Ratio,hsCRP',
    'Estradiol,Fasting Glucose,Homocysteine,Magnesium (RBC),Potassium,Triglycerides,Vitamin B12,eGFR',
    'Neutrophil/Lymphocyte Ratio',
    'Blood Pressure (Diastolic),Blood Pressure (Systolic)',
    'BMI,Bodyfat,Hip-to-Waist Ratio',
    '',
    70,
    'LI036,LI037,LI038',
    '',
    '{"has_difficulty_levels": true, "source_base_id": "REC0008"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'reduce_added_sugar_intake',
    'Reduce Added Sugar Intake',
    'Added sugar contributes to metabolic dysfunction, inflammation, and increased chronic disease risk. Reducing daily added sugar improves energy, supports healthy weight, and protects long-term cardiometabolic health. For this recommendation, a serving is any food or drink with about 8–12g of added sugar (e.g., 1 cookie, sweetened yogurt, granola bar, or can of soda). If the item is over 15g, count as 2 servings.',
    'Reduce added sugar and refined carbohydrate intake',
    'nutrition',
    'Dietary',
    'ALT,AST,ApoB,Fasting Glucose,Fasting Insulin,GGT,HOMA-IR,HbA1c,Triglycerides,hsCRP',
    'HDL,Lymphocytes,Neutrophil/Lymphocyte Ratio,Neutrophils,White Blood Cell Count',
    '',
    'BMI,Blood Pressure (Diastolic),Blood Pressure (Systolic),Bodyfat,Hip-to-Waist Ratio',
    '',
    '',
    80,
    'LI039,LI040,LI041',
    '',
    '{"has_difficulty_levels": true, "source_base_id": "REC0009"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'reduce_processed_meat_intake',
    'Reduce Processed Meat Intake',
    'High intake of processed meats is linked to increased cancer, cardiovascular, and metabolic disease risk. Reducing processed meat supports longevity and promotes healthier eating.',
    'Reduce or eliminate processed meat consumption',
    'nutrition',
    'Dietary',
    'ApoB,Fasting Insulin,HOMA-IR,HbA1c,LDL,hsCRP',
    'Ferritin,HDL,HOMA-IR,Lymphocytes,Neutrophil/Lymphocyte Ratio,Neutrophils,Triglycerides,White Blood Cell Count,hsCRP',
    '',
    'Blood Pressure (Diastolic),Blood Pressure (Systolic)',
    'BMI,Bodyfat,Hip-to-Waist Ratio',
    '',
    70,
    'LI042,LI043,LI044,LI045,LI046',
    '',
    '{"has_difficulty_levels": true, "source_base_id": "REC0010"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'increase_whole_grain_intake',
    'Increase Whole Grain Intake',
    'Whole grains are rich in fiber, vitamins, and minerals that support metabolic, digestive, and cardiovascular health. Regular intake is linked to longevity and reduced risk.',
    'Choose whole grains over refined grains',
    'nutrition',
    'Dietary',
    'ApoB,Fasting Glucose,Fasting Insulin,HOMA-IR,HbA1c,LDL,Total Cholesterol,hsCRP',
    'HDL,Magnesium (RBC),Neutrophil/Lymphocyte Ratio,Triglycerides,Vitamin B12',
    '',
    'Blood Pressure (Diastolic),Blood Pressure (Systolic)',
    'BMI,Bodyfat',
    '',
    65,
    'LI047,LI048,LI049',
    '',
    '{"has_difficulty_levels": true, "source_base_id": "REC0011"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'increase_legume_intake',
    'Increase Legume Intake',
    'Legumes provide plant-based protein, fiber, and micronutrients that promote metabolic, digestive, and cardiovascular health. Regular intake supports longevity and gut health.',
    'Include legumes (beans, lentils) in diet regularly',
    'nutrition',
    'Dietary',
    'ApoB,Fasting Glucose,Fasting Insulin,HOMA-IR,HbA1c,LDL,Neutrophil/Lymphocyte Ratio,Total Cholesterol,hsCRP',
    'Fasting Glucose,Fasting Insulin,Folate (RBC),Folate Serum,HDL,HOMA-IR,Homocysteine,Triglycerides,Vitamin B12,hsCRP',
    '',
    'Blood Pressure (Diastolic),Blood Pressure (Systolic)',
    'BMI,Bodyfat,Hip-to-Waist Ratio,Skeletal Muscle Mass to Fat-Free Mass',
    '',
    65,
    'LI050,LI051,LI052',
    '',
    '{"has_difficulty_levels": true, "source_base_id": "REC0012"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'reduce_caffeine_intake',
    'Reduce Caffeine Intake',
    'High caffeine intake (over 400mg/day) can disrupt sleep, increase anxiety, and impact blood pressure. Reducing intake supports better sleep, energy, and cardiometabolic health. 1 regular cup of coffee ≈ 100mg, 1 espresso ≈ 60–80mg, 1 energy drink ≈ 80–120mg, 1 cup of tea ≈ 40mg.',
    'Follow reduce caffeine intake recommendation',
    'nutrition',
    'Dietary',
    'ALT,AST,Fasting Glucose,Fasting Insulin,Folate (RBC),GGT,HOMA-IR,HbA1c,Homocysteine',
    'Cortisol',
    '',
    '',
    'Blood Pressure (Diastolic),Blood Pressure (Systolic),Deep Sleep,Grip Strength,REM Sleep,Resting Heart Rate,Total Sleep,VO2 Max',
    '',
    40,
    'LI053,LI054,LI055',
    '',
    '{"has_difficulty_levels": true, "source_base_id": "REC0013"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'optimize_caffeine_source',
    'Optimize Caffeine Source',
    'Certain sources of caffeine—like energy drinks, pre-workout supplements, and high-caffeine sodas—are associated with greater cardiovascular, anxiety, and metabolic risk. Replacing these with coffee or tea provides a gentler, more stable source of caffeine, along with antioxidant and metabolic benefits.',
    'Follow optimize caffeine source recommendation',
    'nutrition',
    'Dietary',
    'ALT,AST,Fasting Glucose,Fasting Insulin,GGT,HOMA-IR,HbA1c,Magnesium (RBC)',
    '',
    '',
    '',
    'Deep Sleep,REM Sleep,Total Sleep',
    '',
    25,
    'LI059,LI060,LI061,LI062,LI063',
    '',
    '{"has_difficulty_levels": true, "source_base_id": "REC0014"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'optimize_caffeine_timing',
    'Optimize Caffeine Timing',
    'Consuming caffeine late in the day can disrupt sleep, delay circadian rhythms, and reduce sleep quality. To support optimal sleep and energy, finish all coffee, tea, energy drinks, and other sources of caffeine by 2pm.',
    'Follow optimize caffeine timing recommendation',
    'nutrition',
    'Behavior',
    'Cortisol,Homocysteine',
    'ALT,AST,Fasting Glucose,Fasting Insulin,GGT,HOMA-IR,HbA1c',
    '',
    'Deep Sleep,REM Sleep,Resting Heart Rate,Total Sleep',
    'Blood Pressure (Diastolic),Blood Pressure (Systolic)',
    '',
    45,
    'LI064,LI065,LI066',
    '',
    '{"has_difficulty_levels": true, "source_base_id": "REC0015"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'daily_meal_frequency',
    'Daily Meal Frequency',
    'Regular meal frequency supports stable energy, muscle maintenance, metabolic health, and balanced nutrient intake. Eating too few meals can increase fatigue and undernutrition risk.',
    'Follow daily meal frequency recommendation',
    'lifestyle',
    'Behavior',
    'Fasting Glucose,Fasting Insulin,HDL,HOMA-IR,Triglycerides,hsCRP',
    'Homocysteine',
    '',
    '',
    'BMI,Blood Pressure (Diastolic),Blood Pressure (Systolic),Deep Sleep,REM Sleep,Resting Heart Rate,Total Sleep,Weight',
    '',
    50,
    'LI067,LI068,LI069',
    '',
    '{"has_difficulty_levels": true, "source_base_id": "REC0016"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'time_restricted_eating',
    'Time Restricted Eating',
    'Intermittent fasting with a daily eating window of 10 hours or less (14+ hours fasting) may support metabolic health, weight management, and circadian rhythms.',
    'Practice time-restricted eating or intermittent fasting',
    'lifestyle',
    'Behavior',
    'Fasting Glucose,Fasting Insulin,HOMA-IR,HbA1c,hsCRP',
    'LDL,Triglycerides',
    '',
    'BMI,Bodyfat',
    'Blood Pressure (Diastolic),Blood Pressure (Systolic),Deep Sleep,REM Sleep',
    '',
    60,
    'LI070,LI071,LI072',
    '',
    '{"has_difficulty_levels": true, "source_base_id": "REC0017"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'first_meal_timing',
    'First Meal Timing',
    'Aligning the timing of your first meal with your natural circadian rhythm may improve metabolic health, energy levels, and blood sugar control. ',
    'Follow first meal timing recommendation',
    'lifestyle',
    'Behavior',
    'ApoB,Fasting Glucose,Fasting Insulin,HOMA-IR',
    'Cortisol,hsCRP',
    '',
    '',
    'Blood Pressure (Diastolic),Blood Pressure (Systolic),Bodyfat,Deep Sleep,REM Sleep,Total Sleep',
    '',
    45,
    'LI073,LI074,LI075',
    '',
    '{"has_difficulty_levels": true, "source_base_id": "REC0018"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'final_meal_timing',
    'Final Meal Timing',
    'Eating your final meal well before bedtime supports digestion, sleep quality, and circadian health. Early final meal timing may improve blood sugar, fat metabolism, and reduce nighttime reflux or discomfort.',
    'Follow final meal timing recommendation',
    'lifestyle',
    'Behavior',
    'ApoB,Cortisol,Fasting Glucose,Fasting Insulin,HOMA-IR,hsCRP',
    'LDL,Triglycerides',
    '',
    'HRV,Resting Heart Rate,Total Sleep',
    'BMI,Bodyfat,REM Sleep',
    '',
    55,
    'LI076,LI077,LI078',
    '',
    '{"has_difficulty_levels": true, "source_base_id": "REC0019"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'daily_water_intake',
    'Daily Water Intake',
    'Adequate hydration supports energy, metabolism, brain function, and healthy skin. Drinking enough water daily can improve mood, cognition, and overall well-being.',
    'Follow daily water intake recommendation',
    'lifestyle',
    'Dietary',
    'BUN,Calcium (Ionized),Calcium (Serum),Cortisol,Creatinine,Fasting Glucose,Sodium,eGFR',
    'HDL,Hematocrit,Hemoglobin,hsCRP',
    '',
    'Resting Heart Rate',
    'BMI,Blood Pressure (Diastolic),Blood Pressure (Systolic),Bodyfat',
    '',
    70,
    'LI079,LI080,LI081,LI082',
    '',
    '{"has_difficulty_levels": true, "source_base_id": "REC0020"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'daily_whole_food_meals',
    'Daily Whole Food Meals',
    'Emphasizing whole, minimally processed foods at meals supports metabolic health, lowers inflammation, and improves gut health and satiety.',
    'Follow daily whole food meals recommendation',
    'lifestyle',
    'Dietary',
    'ApoB,Fasting Glucose,Fasting Insulin,HOMA-IR,Homocysteine,LDL,Triglycerides,hsCRP',
    'Cortisol',
    '',
    'BMI,Blood Pressure (Diastolic),Blood Pressure (Systolic),Bodyfat',
    'Deep Sleep,REM Sleep,Total Sleep',
    '',
    75,
    'LI083,LI084,LI085,LI086',
    '',
    '{"has_difficulty_levels": true, "source_base_id": "REC0021"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'daily_ultra_processed_foods',
    'Daily Ultra-Processed Foods',
    'Ultra-processed foods (e.g., packaged snacks, sweetened beverages, fast food) increase risk for metabolic disease and inflammation. Reducing intake supports long-term health.',
    'Follow daily ultra-processed foods recommendation',
    'lifestyle',
    'Dietary',
    'ApoB,Fasting Glucose,Fasting Insulin,HOMA-IR,HbA1c,LDL,Triglycerides,hsCRP',
    'HDL',
    '',
    'BMI,Blood Pressure (Diastolic),Blood Pressure (Systolic),Bodyfat,Hip-to-Waist Ratio',
    'Deep Sleep,HRV,REM Sleep,Total Sleep',
    '',
    75,
    'LI083,LI086,LI087,LI088',
    '',
    '{"has_difficulty_levels": true, "source_base_id": "REC0022"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'daily_takeoutdelivery_meals',
    'Daily Takeout/Delivery Meals',
    'Regular takeout or delivery meals, especially from fast food or chain restaurants, are often higher in calories, sodium, and unhealthy fats. Reducing takeout improves dietary quality and supports health.',
    'Follow daily takeout/delivery meals recommendation',
    'lifestyle',
    'Behavior',
    'ApoB,Fasting Glucose,Fasting Insulin,HOMA-IR,HbA1c,LDL,Triglycerides,hsCRP',
    'HDL',
    '',
    'BMI,Blood Pressure (Diastolic),Blood Pressure (Systolic),Bodyfat,Hip-to-Waist Ratio',
    'Deep Sleep,HRV,REM Sleep,Total Sleep',
    '',
    55,
    'LI089,LI090,LI091,LI092,LI093',
    '',
    '{"has_difficulty_levels": true, "source_base_id": "REC0023"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'daily_plant_based_meals',
    'Daily Plant-Based Meals',
    'Plant-based meals support cardiovascular, metabolic, and gut health by increasing fiber, phytonutrients, and healthy fats while lowering inflammation.',
    'Follow daily plant-based meals recommendation',
    'lifestyle',
    'Dietary',
    'ApoB,Fasting Glucose,Fasting Insulin,Folate (RBC),Folate Serum,HDL,HOMA-IR,Homocysteine,LDL,Magnesium (RBC),Total Cholesterol,Vitamin B12,Vitamin D,hsCRP',
    'Cortisol',
    '',
    'BMI,Blood Pressure (Diastolic),Blood Pressure (Systolic),Bodyfat,Hip-to-Waist Ratio,Resting Heart Rate',
    'Deep Sleep,REM Sleep,Total Sleep',
    '',
    60,
    'LI033,LI035,LI050,LI052,LI084,LI094,LI095,LI096',
    '',
    '{"has_difficulty_levels": true, "source_base_id": "REC0024"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'zone_2_cardio_sessions',
    'Zone 2 Cardio Sessions',
    'Zone 2 cardio—sustained, moderate-intensity aerobic activity—improves metabolic, mitochondrial, and cardiovascular health.',
    'Perform Zone 2 cardio (moderate intensity, conversational pace) regularly',
    'movement',
    'Behavior',
    'Fasting Insulin,HOMA-IR,hsCRP',
    'ApoB,HDL,HbA1c,LDL,Triglycerides',
    '',
    'Blood Pressure (Diastolic),Blood Pressure (Systolic),Bodyfat,Deep Sleep,HRV,Hip-to-Waist Ratio,REM Sleep,Resting Heart Rate,Total Sleep,VO2 Max',
    'Deep Sleep,REM Sleep,Total Sleep',
    '',
    85,
    'LI022,LI023,LI024,LI097,LI098,LI099,LI100,LI101,LI102,LI103',
    '',
    '{"has_difficulty_levels": true, "source_base_id": "REC0025"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'daily_steps',
    'Daily Steps',
    'Daily step count is a simple, powerful marker of physical activity and metabolic health. Increasing steps improves cardiovascular, cognitive, and overall health.',
    'Walk daily to improve cardiovascular health',
    'movement',
    'Behavior',
    'Fasting Insulin,HOMA-IR,hsCRP',
    'ApoB,Fasting Glucose,Fasting Insulin,HDL,HbA1c,Triglycerides,hsCRP',
    '',
    'Blood Pressure (Diastolic),Blood Pressure (Systolic),Bodyfat,Hip-to-Waist Ratio,Resting Heart Rate,VO2 Max',
    'BMI,Deep Sleep,HRV,Hip-to-Waist Ratio,REM Sleep,Total Sleep',
    '',
    90,
    'LI097,LI098,LI099,LI100,LI101,LI102,LI103,LI104,LI105,LI118',
    '',
    '{"has_difficulty_levels": true, "source_base_id": "REC0026"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'strength_training_sessions',
    'Strength Training Sessions',
    'Strength training supports muscle, bone, and metabolic health, improves longevity, and reduces injury risk.',
    'Perform strength training to maintain muscle mass and bone density',
    'movement',
    'Behavior',
    'Fasting Insulin,Free Testosterone,HDL,HOMA-IR,HbA1c,Testosterone,hsCRP',
    'Fasting Glucose,Homocysteine,Triglycerides,Vitamin D',
    '',
    'Bodyfat,Grip Strength,Skeletal Muscle Mass to Fat-Free Mass',
    'Blood Pressure (Diastolic),Blood Pressure (Systolic),Deep Sleep,REM Sleep,Resting Heart Rate,Total Sleep,VO2 Max',
    '',
    90,
    'LI100,LI106,LI107,LI108,LI109,LI110,LI124',
    '',
    '{"has_difficulty_levels": true, "source_base_id": "REC0027"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'strength_training_duration',
    'Strength Training Duration',
    'The total weekly time spent on strength training is a key driver for muscle adaptation and longevity.',
    'Perform strength training to maintain muscle mass and bone density',
    'movement',
    'Behavior',
    'Fasting Insulin,Free Testosterone,HDL,HOMA-IR,HbA1c,Testosterone,hsCRP',
    'Fasting Glucose,Homocysteine,Triglycerides,Vitamin D',
    '',
    'Bodyfat,Grip Strength,Skeletal Muscle Mass to Fat-Free Mass',
    'Blood Pressure (Diastolic),Blood Pressure (Systolic),Deep Sleep,REM Sleep,Resting Heart Rate,Total Sleep,VO2 Max',
    '',
    70,
    'LI106,LI107,LI108,LI109,LI110,LI111,LI112,LI113',
    '',
    '{"has_difficulty_levels": true, "source_base_id": "REC0028"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'hiit_sessions',
    'HIIT Sessions',
    'HIIT improves aerobic/anaerobic fitness, insulin sensitivity, and heart health with time-efficient, intense intervals.',
    'Follow hiit sessions recommendation',
    'lifestyle',
    'Behavior',
    'ApoB,Fasting Insulin,HOMA-IR,hsCRP',
    'ApoB,Fasting Glucose,Fasting Insulin,Free Testosterone,HDL,HOMA-IR,HbA1c,Homocysteine,LDL,Testosterone,Triglycerides,hsCRP',
    '',
    'Blood Pressure (Diastolic),Blood Pressure (Systolic),Bodyfat,Deep Sleep,HRV,Hip-to-Waist Ratio,REM Sleep,Resting Heart Rate,Total Sleep,VO2 Max',
    'BMI,Bodyfat,Deep Sleep,Grip Strength,Hip-to-Waist Ratio,REM Sleep,Resting Heart Rate,Skeletal Muscle Mass to Fat-Free Mass,Total Sleep',
    '',
    75,
    'LI114,LI115,LI116,LI117',
    '',
    '{"has_difficulty_levels": true, "source_base_id": "REC0029"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'hiit_duration',
    'HIIT Duration',
    'Short, focused HIIT bursts provide substantial cardiovascular and metabolic benefits.',
    'Follow hiit duration recommendation',
    'lifestyle',
    'Behavior',
    'Fasting Insulin,HOMA-IR,hsCRP',
    'ApoB,HDL,HbA1c,LDL',
    '',
    'Blood Pressure (Diastolic),Blood Pressure (Systolic),Bodyfat,Deep Sleep,HRV,Hip-to-Waist Ratio,REM Sleep,Resting Heart Rate,Total Sleep,VO2 Max',
    'Deep Sleep,REM Sleep,Total Sleep',
    '',
    65,
    'LI114,LI115,LI116,LI117',
    '',
    '{"has_difficulty_levels": true, "source_base_id": "REC0030"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'daily_active_time',
    'Daily Active Time',
    'Building more daily movement boosts mood, metabolism, heart health, and helps maintain a healthy weight. Active time is a core pillar of physical and mental resilience.',
    'Follow daily active time recommendation',
    'lifestyle',
    'Behavior',
    'Fasting Insulin,HOMA-IR,hsCRP',
    'ApoB,Fasting Glucose,Fasting Insulin,HDL,HbA1c,Triglycerides,hsCRP',
    '',
    'Blood Pressure (Diastolic),Blood Pressure (Systolic),Bodyfat,Resting Heart Rate,VO2 Max',
    'BMI,Deep Sleep,HRV,Hip-to-Waist Ratio,REM Sleep,Total Sleep',
    '',
    70,
    'LI118,LI119,LI120,LI121,LI122',
    '',
    '{"has_difficulty_levels": true, "source_base_id": "REC0031"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'sedentary_time',
    'Sedentary Time',
    'Reducing prolonged sitting lowers cardiometabolic and cognitive risk, improves posture, and supports more sustained energy throughout the day.',
    'Follow sedentary time recommendation',
    'lifestyle',
    'Behavior',
    'Fasting Insulin,HOMA-IR,hsCRP',
    'ApoB,Fasting Glucose,Fasting Insulin,HDL,HbA1c,Triglycerides,hsCRP',
    '',
    'Blood Pressure (Diastolic),Blood Pressure (Systolic),Bodyfat,Resting Heart Rate,VO2 Max',
    'BMI,Deep Sleep,HRV,Hip-to-Waist Ratio,REM Sleep,Total Sleep',
    '',
    75,
    'LI118,LI121',
    '',
    '{"has_difficulty_levels": true, "source_base_id": "REC0032"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'weekly_mobility_sessions',
    'Weekly Mobility Sessions',
    'Regular mobility sessions improve flexibility, joint health, and recovery—helping you move better and reduce injury risk as you get stronger.',
    'Follow weekly mobility sessions recommendation',
    'movement',
    'Behavior',
    'Cortisol',
    'Fasting Glucose,Fasting Insulin',
    '',
    'Deep Sleep,HRV,Total Sleep',
    'Blood Pressure (Diastolic),Blood Pressure (Systolic),REM Sleep,Resting Heart Rate',
    '',
    60,
    'LI123,LI124,LI125,LI126',
    '',
    '{"has_difficulty_levels": true, "source_base_id": "REC0033"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'weekly_mobility_minutes',
    'Weekly Mobility Minutes',
    'Short, frequent mobility work helps restore movement patterns, prevent stiffness, and builds a foundation for lifelong resilience.',
    'Follow weekly mobility minutes recommendation',
    'movement',
    'Behavior',
    'Cortisol',
    'Cortisol,Fasting Glucose,Fasting Insulin,Homocysteine',
    '',
    'Blood Pressure (Diastolic),Blood Pressure (Systolic),Deep Sleep,HRV,Total Sleep',
    'Blood Pressure (Diastolic),Blood Pressure (Systolic),Deep Sleep,REM Sleep,Resting Heart Rate,Total Sleep',
    '',
    55,
    'LI123,LI124,LI125,LI126',
    '',
    '{"has_difficulty_levels": true, "source_base_id": "REC0034"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'weekly_post_meal_activity_minutes',
    'Weekly Post-Meal Activity Minutes',
    'Moving after meals improves blood sugar control, supports digestion, and can reduce cardiometabolic risk—especially when made a regular habit.',
    'Follow weekly post-meal activity minutes recommendation',
    'lifestyle',
    'Behavior',
    'ApoB,HOMA-IR,HbA1c,hsCRP',
    'Fasting Glucose,Fasting Insulin,Triglycerides',
    '',
    'Blood Pressure (Diastolic),Blood Pressure (Systolic)',
    'BMI,Bodyfat,Deep Sleep,Hip-to-Waist Ratio,REM Sleep,Total Sleep',
    '',
    50,
    'LI120,LI122,LI127,LI128,LI129,LI130,LI131',
    '',
    '{"has_difficulty_levels": true, "source_base_id": "REC0035"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'weekly_post_meal_activity_sessions',
    'Weekly Post-Meal Activity Sessions',
    'Frequent post-meal movement supports digestion and helps stabilize glucose—just a few sessions per week makes a difference.',
    'Follow weekly post-meal activity sessions recommendation',
    'lifestyle',
    'Behavior',
    'ApoB,HOMA-IR,HbA1c,hsCRP',
    'Fasting Glucose,Fasting Insulin,Triglycerides',
    '',
    'Blood Pressure (Diastolic),Blood Pressure (Systolic)',
    'BMI,Bodyfat,Deep Sleep,Hip-to-Waist Ratio,REM Sleep,Total Sleep',
    '',
    50,
    'LI127,LI128,LI129,LI130,LI131',
    '',
    '{"has_difficulty_levels": true, "source_base_id": "REC0036"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'weekly_exercise_snacks',
    'Weekly Exercise Snacks',
    '“Exercise snacks”—short bursts of movement—improve metabolic health, mood, and energy, and make movement more achievable in busy schedules.',
    'Follow weekly exercise snacks recommendation',
    'movement',
    'Behavior',
    'Fasting Insulin,HOMA-IR,HbA1c',
    'ApoB,Fasting Glucose,Fasting Insulin,Triglycerides,hsCRP',
    '',
    'Blood Pressure (Diastolic),Blood Pressure (Systolic),VO2 Max',
    'BMI,Bodyfat,Deep Sleep,Hip-to-Waist Ratio,REM Sleep,Total Sleep',
    '',
    45,
    'LI132,LI133,LI134',
    '',
    '{"has_difficulty_levels": true, "source_base_id": "REC0037"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'sleep_timing_consistency',
    'Sleep Timing Consistency',
    'Consistent bedtimes strengthen circadian rhythm, improve rest quality, and make mornings more predictable—key for resilience.',
    'Follow sleep timing consistency recommendation',
    'sleep',
    'Behavior',
    'Cortisol,Fasting Glucose,HOMA-IR,Neutrophil/Lymphocyte Ratio,SHBG,hsCRP',
    'ApoB,HDL,HbA1c,LDL,RDW,Testosterone,Triglycerides,Vitamin B12',
    '',
    'Blood Pressure (Diastolic),Blood Pressure (Systolic),Deep Sleep,HRV,REM Sleep,Total Sleep',
    'BMI,Bodyfat,Hip-to-Waist Ratio,Skeletal Muscle Mass to Fat-Free Mass,VO2 Max',
    '',
    70,
    'LI138,LI139,LI140,LI141,LI142,LI143',
    '',
    '{"has_difficulty_levels": true, "source_base_id": "REC0039"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'wake_time_consistency',
    'Wake Time Consistency',
    'Consistent wake times anchor the circadian clock, support better sleep quality, and improve daily energy patterns.',
    'Follow wake time consistency recommendation',
    'lifestyle',
    'Behavior',
    'Cortisol,Fasting Glucose,HOMA-IR,Neutrophil/Lymphocyte Ratio,SHBG,hsCRP',
    'ApoB,HDL,HbA1c,LDL,RDW,Testosterone,Triglycerides,Vitamin B12',
    '',
    'Blood Pressure (Diastolic),Blood Pressure (Systolic),Deep Sleep,HRV,REM Sleep,Total Sleep',
    'BMI,Bodyfat,Hip-to-Waist Ratio,Skeletal Muscle Mass to Fat-Free Mass,VO2 Max',
    '',
    65,
    'LI058,LI138,LI139,LI140,LI141,LI142,LI143',
    '',
    '{"has_difficulty_levels": true, "source_base_id": "REC0040"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'daily_early_morning_natural_light_exposure',
    'Daily Early Morning Natural Light Exposure',
    'Early natural light helps regulate your body clock, boost mood, and support healthy sleep.',
    'Follow daily early morning natural light exposure recommendation',
    'lifestyle',
    'Behavior',
    'Vitamin D',
    'Cortisol,HOMA-IR,Homocysteine,hsCRP',
    '',
    'Blood Pressure (Diastolic),Blood Pressure (Systolic),HRV',
    'Deep Sleep,REM Sleep,Total Sleep',
    '',
    65,
    'LI144,LI145,LI146',
    '',
    '{"has_difficulty_levels": true, "source_base_id": "REC0041"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'large_meals_3_hours_before_bed',
    'Large Meals ≤3 Hours Before Bed',
    'Reducing late large meals helps support digestion, sleep quality, and metabolic health.',
    'Follow large meals ≤3 hours before bed recommendation',
    'lifestyle',
    'Behavior',
    'Fasting Glucose,Fasting Insulin,HOMA-IR,HbA1c,hsCRP',
    'Cortisol,LDL,Triglycerides',
    '',
    'BMI,Bodyfat',
    'Blood Pressure (Diastolic),Blood Pressure (Systolic),Bodyfat,Deep Sleep,Hip-to-Waist Ratio,REM Sleep,Total Sleep',
    '',
    50,
    'LI147,LI148,LI149',
    '',
    '{"has_difficulty_levels": true, "source_base_id": "REC0042"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'food_intake_2_hours_before_bed',
    'Food Intake ≤2 Hours Before Bed',
    'Avoiding all food close to bedtime supports restful sleep, digestion, and overnight recovery.',
    'Follow food intake ≤2 hours before bed recommendation',
    'lifestyle',
    'Behavior',
    'Fasting Glucose,Fasting Insulin,HOMA-IR,HbA1c,hsCRP',
    'Cortisol,LDL,Triglycerides',
    '',
    'BMI,Bodyfat',
    'Blood Pressure (Diastolic),Blood Pressure (Systolic),Bodyfat,Deep Sleep,Hip-to-Waist Ratio,REM Sleep,Total Sleep',
    '',
    50,
    'LI147,LI148,LI149',
    '',
    '{"has_difficulty_levels": true, "source_base_id": "REC0043"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'alcohol_intake_3_4_hours_before_bed',
    'Alcohol Intake ≤3-4 Hours Before Bed',
    'Limiting alcohol before bed improves sleep quality, supports healthy metabolism, and reduces next-day grogginess.',
    'Follow alcohol intake ≤3-4 hours before bed recommendation',
    'nutrition',
    'Behavior',
    'Fasting Glucose,Fasting Insulin',
    'Cortisol,HOMA-IR,HbA1c,Triglycerides',
    '',
    'Blood Pressure (Diastolic),Blood Pressure (Systolic)',
    'Deep Sleep,HRV,REM Sleep,Resting Heart Rate,Total Sleep',
    '',
    45,
    'LI150,LI153',
    '',
    '{"has_difficulty_levels": true, "source_base_id": "REC0044"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'digital_device_time_2_hours_before_bed',
    'Digital Device Time ≤2 Hours Before Bed',
    'Reducing screen time before bed supports melatonin production, sleep onset, and better nightly rest.',
    'Follow digital device time ≤2 hours before bed recommendation',
    'lifestyle',
    'Behavior',
    'Cortisol,Fasting Glucose,Fasting Insulin,HOMA-IR,HbA1c',
    'ApoB,Free Testosterone,HDL,Testosterone,Triglycerides,Vitamin D,hsCRP',
    '',
    'Deep Sleep,HRV,REM Sleep,Resting Heart Rate,Total Sleep',
    'BMI,Blood Pressure (Diastolic),Blood Pressure (Systolic),Bodyfat',
    '',
    50,
    'LI151,LI152',
    '',
    '{"has_difficulty_levels": true, "source_base_id": "REC0045"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'breathwork_or_mindfulness_sessions',
    'Breathwork or Mindfulness Sessions',
    'Breathwork and mindfulness can lower stress, support emotional health, and improve focus.',
    'Practice mindfulness or meditation regularly',
    'stress',
    'Behavior',
    '',
    'Cortisol,Fasting Glucose,Fasting Insulin,HOMA-IR,HbA1c,Homocysteine,hsCRP',
    '',
    'HRV',
    'Blood Pressure (Diastolic),Blood Pressure (Systolic),Deep Sleep,REM Sleep,Total Sleep',
    '',
    60,
    'LI154,LI155,LI156',
    '',
    '{"has_difficulty_levels": true, "source_base_id": "REC0046"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'social_interaction_events',
    'Social Interaction Events',
    'Social events help strengthen relationships, build connection, and boost overall mental health.',
    'Engage in regular social interaction',
    'connection',
    'Behavior',
    '',
    'Cortisol,Homocysteine,Vitamin D,hsCRP',
    '',
    '',
    'Blood Pressure (Diastolic),Blood Pressure (Systolic),Deep Sleep,HRV,REM Sleep,Total Sleep',
    '',
    70,
    'LI157,LI158,LI159,LI160',
    '',
    '{"has_difficulty_levels": true, "source_base_id": "REC0047"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'gratitude_practice',
    'Gratitude Practice',
    'Gratitude practice builds resilience, positivity, and supports emotional well-being.',
    'Follow gratitude practice recommendation',
    'lifestyle',
    'Behavior',
    '',
    'Cortisol,hsCRP',
    '',
    'Blood Pressure (Diastolic),Blood Pressure (Systolic),HRV',
    'Deep Sleep,REM Sleep,Total Sleep',
    '',
    45,
    'LI161,LI162,LI163,LI166',
    '',
    '{"has_difficulty_levels": true, "source_base_id": "REC0048"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'journaling_or_reflection_sessions',
    'Journaling or Reflection Sessions',
    'Journaling or reflection helps process emotions, clarify goals, and reduce stress.',
    'Follow journaling or reflection sessions recommendation',
    'lifestyle',
    'Behavior',
    'HbA1c',
    'Cortisol,Fasting Glucose,Fasting Insulin,HOMA-IR,hsCRP',
    '',
    'Blood Pressure (Diastolic),Blood Pressure (Systolic)',
    'Deep Sleep,REM Sleep,Resting Heart Rate,Total Sleep',
    '',
    40,
    'LI164,LI165,LI166',
    '',
    '{"has_difficulty_levels": true, "source_base_id": "REC0049"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'outdoor_time_minutes',
    'Outdoor Time (minutes)',
    'Outdoor time improves mood, focus, vitamin D, and overall well-being.',
    'Follow outdoor time (minutes) recommendation',
    'lifestyle',
    'Behavior',
    'ApoB',
    'Cortisol,Fasting Insulin,HOMA-IR,Homocysteine,Vitamin D,hsCRP',
    '',
    'Blood Pressure (Diastolic),Blood Pressure (Systolic),HRV,VO2 Max',
    'Deep Sleep,REM Sleep,Total Sleep',
    '',
    55,
    'LI167,LI168,LI169,LI170,LI177',
    '',
    '{"has_difficulty_levels": true, "source_base_id": "REC0050"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'morning_outdoor_time_minutes',
    'Morning Outdoor Time (minutes)',
    'Morning outdoor time supports circadian rhythm, energy, and mood.',
    'Follow morning outdoor time (minutes) recommendation',
    'lifestyle',
    'Behavior',
    '',
    'Cortisol,Homocysteine,Vitamin D',
    '',
    'Blood Pressure (Diastolic),Blood Pressure (Systolic)',
    'Deep Sleep,REM Sleep,Total Sleep',
    '',
    60,
    'LI171,LI172,LI173,LI174,LI175,LI176,LI177',
    '',
    '{"has_difficulty_levels": true, "source_base_id": "REC0051"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'digital_device_time_minutes',
    'Digital Device Time (minutes)',
    'Reducing non-work screen time supports better focus, healthier sleep patterns, and improved mental well-being. Non-work screen time refers to recreational or passive use of digital devices outside of job-related responsibilities—such as watching videos, scrolling social media, playing games, or browsing aimlessly.',
    'Follow digital device time (minutes) recommendation',
    'lifestyle',
    'Behavior',
    'ApoB',
    'Cortisol,Fasting Insulin,HOMA-IR,Homocysteine,Vitamin D,hsCRP',
    '',
    'Blood Pressure (Diastolic),Blood Pressure (Systolic),HRV,VO2 Max',
    'Deep Sleep,REM Sleep,Total Sleep',
    '',
    45,
    'LI178,LI179,LI180',
    '',
    '{"has_difficulty_levels": true, "source_base_id": "REC0052"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'brain_training_activity_minutes',
    'Brain Training Activity (minutes)',
    'Brain training supports cognitive health, focus, and lifelong learning.',
    'Follow brain training activity (minutes) recommendation',
    'lifestyle',
    'Behavior',
    '',
    'Cortisol',
    '',
    '',
    'Deep Sleep,REM Sleep,Total Sleep',
    '',
    40,
    'LI181,LI182,LI183',
    '',
    '{"has_difficulty_levels": true, "source_base_id": "REC0053"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'daily_social_interaction_time_minutes',
    'Daily Social Interaction Time (minutes)',
    'Daily social connection boosts mood, resilience, and cognitive health.',
    'Engage in regular social interaction',
    'connection',
    'Behavior',
    '',
    'Cortisol,Homocysteine,Vitamin D,hsCRP',
    '',
    '',
    'Blood Pressure (Diastolic),Blood Pressure (Systolic),Deep Sleep,HRV,REM Sleep,Total Sleep',
    '',
    65,
    'LI184,LI185,LI186,LI187,LI188,LI189,LI190',
    '',
    '{"has_difficulty_levels": true, "source_base_id": "REC0054"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'daily_smoking_cigarettes',
    'Daily Smoking (cigarettes)',
    'Reducing smoking immediately improves cardiovascular and lung health.',
    'Follow daily smoking (cigarettes) recommendation',
    'lifestyle',
    'Behavior',
    'ApoB',
    'HDL,Homocysteine,Triglycerides,White Blood Cell Count,hsCRP',
    '',
    'Blood Pressure (Diastolic),Blood Pressure (Systolic),VO2 Max',
    'Resting Heart Rate',
    '',
    100,
    'LI191,LI192,LI193,LI194,LI195',
    '',
    '{"has_difficulty_levels": true, "source_base_id": "REC0055"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'daily_brushing_timesday',
    'Daily Brushing (times/day)',
    'Brushing daily is foundational for oral health, reducing risk of cavities and gum disease.',
    'Follow daily brushing (times/day) recommendation',
    'lifestyle',
    'Behavior',
    'ApoB,HbA1c',
    'Fasting Glucose,Fasting Insulin,HOMA-IR,hsCRP',
    '',
    'Blood Pressure (Diastolic),Blood Pressure (Systolic)',
    '',
    '',
    65,
    'LI196,LI197,LI198,LI199,LI200',
    '',
    '{"has_difficulty_levels": true, "source_base_id": "REC0056"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'daily_flossing',
    'Daily Flossing',
    'Regular flossing removes plaque and supports healthy gums, lowering long-term oral health risks.',
    'Follow daily flossing recommendation',
    'lifestyle',
    'Behavior',
    'ApoB,HbA1c',
    'Fasting Glucose,Fasting Insulin,HOMA-IR,hsCRP',
    '',
    'Blood Pressure (Diastolic),Blood Pressure (Systolic)',
    '',
    '',
    60,
    'LI199',
    '',
    '{"has_difficulty_levels": true, "source_base_id": "REC0057"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'daily_skincare_routine',
    'Daily Skincare Routine',
    'Consistent skincare protects the skin barrier, supports appearance, and reduces long-term damage.',
    'Follow daily skincare routine recommendation',
    'lifestyle',
    'Behavior',
    '',
    'hsCRP',
    '',
    '',
    '',
    '',
    30,
    'LI203,LI204',
    '',
    '{"has_difficulty_levels": true, "source_base_id": "REC0058"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'daily_sunscreen_use',
    'Daily Sunscreen Use',
    'Daily sunscreen use protects against sunburn, premature aging, and reduces skin cancer risk.',
    'Follow daily sunscreen use recommendation',
    'lifestyle',
    'Behavior',
    '',
    'Vitamin D,hsCRP',
    '',
    '',
    '',
    '',
    55,
    'LI201,LI202',
    '',
    '{"has_difficulty_levels": true, "source_base_id": "REC0059"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'autologous_stem_cell_therapy',
    'Autologous Stem Cell Therapy',
    'Stem cell therapies use a person’s own or donor-derived stem cells to promote tissue regeneration, immune modulation, and may slow aspects of aging. Early human studies show benefit for orthopedic, cardiovascular, and immune function, but protocols are experimental and not widely regulated.',
    'Follow autologous stem cell therapy recommendation',
    'lifestyle',
    'Behavior',
    '',
    '',
    '',
    '',
    '',
    '',
    30,
    '',
    '',
    '{"has_difficulty_levels": false, "source_base_id": "REC0164"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'platelet_rich_plasma_prp_injections',
    'Platelet-Rich Plasma (PRP) Injections',
    'PRP therapy involves concentrating your own platelets and injecting them into tissues to accelerate repair and reduce inflammation. Used for joints, tendons, hair regrowth, and skin rejuvenation. Data are strongest for orthopedic injury, with early research in anti-aging.',
    'Follow platelet-rich plasma (prp) injections recommendation',
    'lifestyle',
    'Behavior',
    '',
    'Albumin,Creatine Kinase,hsCRP',
    '',
    'HRV',
    'Bodyfat,Grip Strength',
    '',
    20,
    '',
    '',
    '{"has_difficulty_levels": false, "source_base_id": "REC0165"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'fecal_microbiota_transplantation_fmt',
    'Fecal Microbiota Transplantation (FMT)',
    'FMT introduces healthy donor gut bacteria into the colon to restore microbiome diversity. Clinically validated for C. difficile infection; under research for metabolic, immune, and neurodegenerative diseases.',
    'Follow fecal microbiota transplantation (fmt) recommendation',
    'lifestyle',
    'Behavior',
    '',
    'Creatine Kinase,Platelet Count,hsCRP',
    '',
    'HRV',
    'Grip Strength',
    '',
    15,
    '',
    '',
    '{"has_difficulty_levels": false, "source_base_id": "REC0166"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'exosome_therapy',
    'Exosome Therapy',
    'Exosomes are cell-derived vesicles thought to mediate many benefits of stem cells—anti-inflammatory, tissue repair, and cellular communication. Mostly experimental, with pilot evidence for arthritis, skin, and neurological conditions.',
    'Follow exosome therapy recommendation',
    'lifestyle',
    'Behavior',
    '',
    'Albumin,White Blood Cell Count,hsCRP',
    '',
    '',
    'BMI,HRV',
    '',
    20,
    '',
    '',
    '{"has_difficulty_levels": false, "source_base_id": "REC0167"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'young_plasma_exchange_plasma_dilution',
    'Young Plasma Exchange / Plasma Dilution',
    '“Young blood” or plasma dilution therapies aim to remove pro-aging factors from the blood. Inspired by animal studies, early trials in humans show some improvements in biomarkers, but long-term safety and benefits remain unproven.',
    'Follow young plasma exchange / plasma dilution recommendation',
    'lifestyle',
    'Behavior',
    'ApoB',
    'Homocysteine,hsCRP',
    '',
    'Blood Pressure (Diastolic),Blood Pressure (Systolic),HRV',
    '',
    '',
    15,
    '',
    '',
    '{"has_difficulty_levels": false, "source_base_id": "REC0168"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'senolytic_drug_protocol_dasatinib_quercetin_fiseti',
    'Senolytic Drug Protocol (Dasatinib + Quercetin, Fisetin, Navitoclax, etc.)',
    'Senolytics are agents that selectively destroy senescent (“zombie”) cells. Dasatinib + quercetin, fisetin, and navitoclax have been studied in animals and early-phase human trials for reducing markers of aging, improving physical function, and organ health.',
    'Follow senolytic drug protocol (dasatinib + quercetin, fisetin, navitoclax, etc.) recommendation',
    'lifestyle',
    'Behavior',
    '',
    'Albumin,Homocysteine,hsCRP',
    '',
    'Blood Pressure (Systolic),HRV',
    'BMI',
    '',
    15,
    '',
    '',
    '{"has_difficulty_levels": false, "source_base_id": "REC0169"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'whole_body_cryotherapy',
    'Whole-Body Cryotherapy',
    'Cryotherapy involves brief exposure to very cold temperatures to reduce inflammation, support recovery, and possibly improve mood/metabolic health. Data strongest for pain/recovery; anti-aging effects are speculative.',
    'Follow whole-body cryotherapy recommendation',
    'lifestyle',
    'Behavior',
    '',
    'Homocysteine,White Blood Cell Count,hsCRP',
    'Fasting Insulin,HOMA-IR,Lp(a),Omega-3 Index',
    'Blood Pressure (Systolic),HRV',
    'BMI',
    '',
    25,
    '',
    '',
    '{"has_difficulty_levels": false, "source_base_id": "REC0170"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'hyperbaric_oxygen_therapy_hbot',
    'Hyperbaric Oxygen Therapy (HBOT)',
    'HBOT exposes the body to pure oxygen at high pressure, promoting tissue repair, stem cell release, and (in small studies) telomere lengthening and improved cognition in aging adults.',
    'Follow hyperbaric oxygen therapy (hbot) recommendation',
    'lifestyle',
    'Behavior',
    '',
    'Cortisol,Creatine Kinase,hsCRP',
    'Fasting Insulin,HOMA-IR,Lp(a),Omega-3 Index',
    'HRV',
    'Resting Heart Rate',
    '',
    20,
    '',
    '',
    '{"has_difficulty_levels": false, "source_base_id": "REC0171"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'photobiomodulation_rednir_light_therapy',
    'Photobiomodulation (Red/NIR Light Therapy)',
    'Red and near-infrared light exposure is thought to improve mitochondrial function, reduce inflammation, support skin/brain health, and possibly slow aging processes. Data are mixed but growing for cognitive, mood, and skin outcomes.',
    'Follow photobiomodulation (red/nir light therapy) recommendation',
    'lifestyle',
    'Behavior',
    '',
    'Hemoglobin,Homocysteine,hsCRP',
    'Fasting Insulin,HOMA-IR,Lp(a),Omega-3 Index',
    'Blood Pressure (Diastolic),Blood Pressure (Systolic),HRV',
    '',
    '',
    25,
    '',
    '',
    '{"has_difficulty_levels": false, "source_base_id": "REC0172"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'autophagyparabiosis_protocol_fasting_mimetic_drugs',
    'Autophagy/Parabiosis Protocol (fasting-mimetic drugs, plasma exchange, etc.)',
    'These protocols seek to stimulate autophagy (cellular recycling), reduce senescent factors, and rejuvenate tissue health. Most are investigational, with benefit/risk still under study.',
    'Practice time-restricted eating or intermittent fasting',
    'lifestyle',
    'Behavior',
    '',
    'Creatine Kinase,Vitamin D,hsCRP',
    'Fasting Insulin,HOMA-IR,Lp(a),Omega-3 Index',
    'HRV',
    'Total Sleep',
    '',
    25,
    '',
    '',
    '{"has_difficulty_levels": false, "source_base_id": "REC0173"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'continuous_glucose_monitor_cgm',
    'Continuous Glucose Monitor (CGM)',
    'CGMs provide real-time blood sugar data in response to food, exercise, sleep, and stress—empowering personalized optimization and early detection of metabolic risk.',
    'Follow continuous glucose monitor (cgm) recommendation',
    'lifestyle',
    'Behavior',
    '',
    'Fasting Glucose,HOMA-IR,hsCRP',
    'Fasting Insulin,Lp(a),Omega-3 Index',
    'HRV',
    'Bodyfat',
    '',
    20,
    '',
    '',
    '{"has_difficulty_levels": false, "source_base_id": "REC0174"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'sleep_tracker',
    'Sleep Tracker',
    'Sleep trackers (Oura, WHOOP, Apple Watch, etc.) monitor sleep duration, stages, and variability—enabling targeted sleep routines and nudges for recovery.',
    'Follow sleep tracker recommendation',
    'sleep',
    'Behavior',
    'HbA1c',
    'Fasting Glucose,Fasting Insulin,HOMA-IR',
    'Lp(a),Omega-3 Index',
    '',
    '',
    '',
    35,
    '',
    '',
    '{"has_difficulty_levels": false, "source_base_id": "REC0175"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'movement_activity_tracker',
    'Movement & Activity Tracker',
    'Activity trackers (Fitbit, Garmin, Apple, etc.) provide insight on daily steps, activity minutes, heart rate, and support adherence to movement goals.',
    'Follow movement & activity tracker recommendation',
    'lifestyle',
    'Behavior',
    '',
    'Cortisol,Testosterone,hsCRP',
    '',
    'Total Sleep',
    'Deep Sleep,HRV,REM Sleep',
    '',
    30,
    '',
    '',
    '{"has_difficulty_levels": false, "source_base_id": "REC0176"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'heart_rate_hrv_monitor',
    'Heart Rate & HRV Monitor',
    'Devices that track HR and HRV (Oura, WHOOP, chest straps) help gauge fitness, recovery, and stress response—guiding readiness and recovery protocols.',
    'Follow heart rate & hrv monitor recommendation',
    'lifestyle',
    'Behavior',
    'HbA1c',
    'HDL,hsCRP',
    '',
    'HRV,VO2 Max',
    'Resting Heart Rate,Steps/Day',
    '',
    60,
    '',
    '',
    '{"has_difficulty_levels": false, "source_base_id": "REC0177"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'blood_pressure_monitor_home',
    'Blood Pressure Monitor (Home)',
    'Home BP monitoring enables early detection of hypertension, tracking trends, and medication adjustment outside clinic visits.',
    'Follow blood pressure monitor (home) recommendation',
    'lifestyle',
    'Behavior',
    '',
    'Cortisol,hsCRP',
    '',
    'HRV',
    'BMI,Blood Pressure (Systolic),Resting Heart Rate',
    '',
    25,
    '',
    '',
    '{"has_difficulty_levels": false, "source_base_id": "REC0178"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'body_composition_analyzer',
    'Body Composition Analyzer',
    'Smart scales and impedance devices help monitor progress in muscle gain, fat loss, and metabolic health for ongoing adjustment.',
    'Follow body composition analyzer recommendation',
    'lifestyle',
    'Behavior',
    '',
    'Homocysteine,Uric Acid,hsCRP',
    '',
    'Blood Pressure (Diastolic),Blood Pressure (Systolic),HRV',
    '',
    '',
    35,
    '',
    '',
    '{"has_difficulty_levels": false, "source_base_id": "REC0179"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'stress_tracker',
    'Stress Tracker',
    'Wearables and apps estimate stress via HRV, skin conductance, or sleep/activity patterns—surfacing trends and supporting behavioral change.',
    'Implement stress management practices',
    'stress',
    'Behavior',
    '',
    'Fasting Insulin,Testosterone,hsCRP',
    '',
    '',
    'BMI,Bodyfat,Hip-to-Waist Ratio,Skeletal Muscle Mass to Fat-Free Mass,Visceral Fat',
    '',
    25,
    '',
    '',
    '{"has_difficulty_levels": false, "source_base_id": "REC0180"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'grip_strength_dynamometer',
    'Grip Strength Dynamometer',
    'Grip strength is a powerful predictor of frailty, resilience, and longevity. Tracking monthly identifies early loss and guides strength recs.',
    'Perform strength training to maintain muscle mass and bone density',
    'movement',
    'Behavior',
    '',
    'Cortisol,DHEA-S,hsCRP',
    '',
    'HRV',
    'BMI,Blood Pressure (Systolic),Resting Heart Rate',
    '',
    25,
    '',
    '',
    '{"has_difficulty_levels": false, "source_base_id": "REC0181"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'smart_pill_dispensermedication_tracker',
    'Smart Pill Dispenser/Medication Tracker',
    'Medication trackers help reduce missed doses, ensure therapy success, and provide reminders for prescription or supplement protocols.',
    'Follow smart pill dispenser/medication tracker recommendation',
    'lifestyle',
    'Behavior',
    '',
    'Albumin,Testosterone,Vitamin D',
    '',
    'Grip Strength',
    'Bodyfat,Skeletal Muscle Mass to Fat-Free Mass',
    '',
    25,
    '',
    '',
    '{"has_difficulty_levels": false, "source_base_id": "REC0182"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'sauna_therapy',
    'Sauna Therapy',
    'Sauna bathing is linked to reduced cardiovascular, dementia, and all-cause mortality risk—possibly via hormesis, improved vascular function, and stress reduction.',
    'Use sauna therapy for cardiovascular and longevity benefits',
    'optimization',
    'Behavior',
    'LDL',
    'Cortisol,HDL,Magnesium (RBC),Total Cholesterol,Vitamin B12,Vitamin D,hsCRP',
    '',
    'Blood Pressure (Diastolic),Blood Pressure (Systolic),HRV',
    'Resting Heart Rate',
    '',
    20,
    '',
    '',
    '{"has_difficulty_levels": true, "source_base_id": "REC0183"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'cold_exposure_cold_plunge',
    'Cold Exposure / Cold Plunge',
    'Cold exposure activates brown fat, boosts mood, may support immune health, and builds resilience via hormesis.',
    'Practice cold exposure therapy',
    'optimization',
    'Behavior',
    'LDL',
    'Cortisol,HDL,Neutrophils,Total Cholesterol,White Blood Cell Count,hsCRP',
    '',
    'Blood Pressure (Diastolic),Blood Pressure (Systolic),HRV',
    'Resting Heart Rate',
    '',
    40,
    '',
    '',
    '{"has_difficulty_levels": true, "source_base_id": "REC0184"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'hepa_air_purifier_use',
    'HEPA Air Purifier Use',
    'Clean indoor air reduces exposure to allergens, pollutants, and improves lung and cognitive health—especially in urban environments.',
    'Follow hepa air purifier use recommendation',
    'lifestyle',
    'Behavior',
    '',
    'Cortisol,Eosinophils,Neutrophils,White Blood Cell Count,hsCRP',
    '',
    'Blood Pressure (Systolic),HRV',
    'BMI,Blood Pressure (Systolic),HRV,Resting Heart Rate,Total Sleep',
    '',
    35,
    '',
    '',
    '{"has_difficulty_levels": true, "source_base_id": "REC0185"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'blue_light_blocking_protocol',
    'Blue Light Blocking Protocol',
    'Reducing blue light at night supports melatonin production, circadian rhythm, and sleep quality.',
    'Follow blue light blocking protocol recommendation',
    'lifestyle',
    'Behavior',
    '',
    'Cortisol,Eosinophils,Magnesium (RBC),TSH,White Blood Cell Count,hsCRP',
    '',
    'HRV',
    'BMI,Blood Pressure (Systolic),Deep Sleep,HRV,REM Sleep,Total Sleep',
    '',
    35,
    '',
    '',
    '{"has_difficulty_levels": true, "source_base_id": "REC0186"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'professional_therapy',
    'Professional Therapy',
    'Working with a licensed therapist helps improve emotional health, reduce stress, and build long-term psychological resilience.',
    'Follow professional therapy recommendation',
    'lifestyle',
    'Behavior',
    '',
    'Cortisol,DHEA-S,Magnesium (RBC),TSH,hsCRP',
    'Fasting Insulin,HOMA-IR,Lp(a),Omega-3 Index',
    'Blood Pressure (Systolic),HRV',
    'BMI,Deep Sleep,REM Sleep,Total Sleep',
    '',
    35,
    '',
    '',
    '{"has_difficulty_levels": true, "source_base_id": "REC0187"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'psychedelic_assisted_therapy',
    'Psychedelic-Assisted Therapy',
    'Psychedelic-assisted therapy (e.g., ketamine, psilocybin) may promote deep psychological breakthroughs, reduce depression, and support emotional healing.',
    'Follow psychedelic-assisted therapy recommendation',
    'lifestyle',
    'Behavior',
    '',
    'Cortisol,DHEA-S,Homocysteine,hsCRP',
    'Fasting Insulin,HOMA-IR,Lp(a),Omega-3 Index',
    'Blood Pressure (Systolic),HRV',
    'BMI,Total Sleep',
    '',
    65,
    '',
    '',
    '{"has_difficulty_levels": true, "source_base_id": "REC0188"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'digital_mental_health_tools',
    'Digital Mental Health Tools',
    'Digital mental health apps offer guided support for mood, focus, anxiety, and self-reflection. They expand access to structured tools outside of therapy.',
    'Follow digital mental health tools recommendation',
    'lifestyle',
    'Behavior',
    '',
    'Cortisol,Homocysteine,hsCRP',
    '',
    'Blood Pressure (Systolic),HRV',
    'BMI,Total Sleep',
    '',
    35,
    '',
    '',
    '{"has_difficulty_levels": true, "source_base_id": "REC0189"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'community_engagement',
    'Community Engagement',
    'Meaningful connection to community—through clubs, faith groups, volunteering, or shared hobbies—supports emotional health, purpose, and even longevity.',
    'Follow community engagement recommendation',
    'lifestyle',
    'Behavior',
    '',
    'Cortisol,Homocysteine,hsCRP',
    '',
    'Blood Pressure (Diastolic),Blood Pressure (Systolic),HRV',
    'BMI,Total Sleep',
    '',
    30,
    '',
    '',
    '{"has_difficulty_levels": true, "source_base_id": "REC0190"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'purpose_meaning_work',
    'Purpose & Meaning Work',
    'A clear sense of purpose has been linked to better physical and mental health, greater life satisfaction, and lower mortality risk—especially when integrated daily.',
    'Follow purpose & meaning work recommendation',
    'lifestyle',
    'Behavior',
    '',
    'Cortisol,DHEA-S,Homocysteine,hsCRP',
    '',
    'Blood Pressure (Diastolic),Blood Pressure (Systolic),HRV',
    'HRV,Total Sleep',
    '',
    60,
    '',
    '',
    '{"has_difficulty_levels": true, "source_base_id": "REC0191"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;


INSERT INTO recommendations_base (
    rec_id, title, overview, agent_goal, pillar, recommendation_type,
    primary_biomarkers, secondary_biomarkers, tertiary_biomarkers,
    primary_biometrics, secondary_biometrics, tertiary_biometrics,
    raw_impact, evidence, contraindications,
    agent_context, agent_enabled, is_active
) VALUES (
    'financial_wellness_habits',
    'Financial Wellness Habits',
    'Financial stress negatively impacts mental and physical health. Basic money tracking builds control, reduces anxiety, and enables long-term wellbeing and security.',
    'Follow financial wellness habits recommendation',
    'lifestyle',
    'Behavior',
    '',
    'Cortisol,DHEA-S,hsCRP',
    'Fasting Insulin,HOMA-IR,Lp(a),Omega-3 Index',
    'Blood Pressure (Systolic),HRV',
    'BMI,HRV,Total Sleep',
    '',
    55,
    '',
    '',
    '{"has_difficulty_levels": true, "source_base_id": "REC0192"}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;
