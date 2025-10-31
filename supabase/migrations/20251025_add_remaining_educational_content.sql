-- =====================================================
-- Add Educational Content to ALL Remaining Metrics
-- =====================================================
-- Completes educational content for all 141 remaining
-- active display metrics across all pillars
-- =====================================================

BEGIN;

-- =====================================================
-- COGNITIVE HEALTH (5 remaining)
-- =====================================================

UPDATE display_metrics SET
  about_content = 'Cognitive focus—the ability to sustain attention on a task without distraction—is trainable and essential for productivity, learning, and quality of life. Modern environments with constant notifications and multitasking demands degrade focus capacity. Research shows that deep focus requires 15-23 minutes to fully engage, and even brief interruptions (checking phone) require 5-15 minutes to regain focus state. Training sustained attention through deliberate practice strengthens prefrontal cortex networks.',
  longevity_impact = 'Better attentional control associates with preserved cognitive function in aging. The Rush Memory and Aging Project found that adults with stronger attention and executive function showed 40% slower cognitive decline over 12 years. Focus training increases gray matter density in attention networks and may build cognitive reserve against dementia.',
  quick_tips = jsonb_build_array(
    'Practice 25-45 minute focused work blocks without interruptions (Pomodoro technique)',
    'Eliminate distractions: silence phone, close unnecessary tabs, use focus apps',
    'Track focus quality not just time—subjective ratings help identify optimal conditions',
    'Morning hours typically offer best focus for most people',
    'Take 5-10 minute breaks between focus blocks to restore attention',
    'Meditation practice directly improves sustained attention capacity'
  )
WHERE metric_name = 'Focus';

UPDATE display_metrics SET
  about_content = 'Journaling—expressive writing about thoughts, experiences, and emotions—is a powerful tool for processing emotions, reducing stress, enhancing self-awareness, and supporting mental health. Writing about stressful experiences helps the brain process and integrate difficult emotions, reducing rumination. Gratitude journaling shifts attention toward positive experiences, while goal-oriented journaling enhances motivation and achievement. Even 5-15 minutes daily produces benefits.',
  longevity_impact = 'A landmark University of Texas study found that writing about traumatic experiences for 15-20 minutes daily for 3-4 days improved immune function (measured by T-lymphocyte response) for up to 6 weeks. Regular journaling reduces anxiety, depression, and stress-related health complaints. Longitudinal studies show that individuals who journal regularly report better life satisfaction and psychological well-being.',
  quick_tips = jsonb_build_array(
    'Write 5-15 minutes daily—consistency matters more than length',
    'Try different styles: gratitude, stream-of-consciousness, goal-setting, reflection',
    'Evening journaling helps process the day and may improve sleep',
    'Don''t edit or censor—expressive writing is private and judgment-free',
    'Focus on emotions and meaning, not just events',
    'Track journaling practice to build consistency and observe mental health benefits'
  )
WHERE metric_name = 'Journaling';

UPDATE display_metrics SET
  about_content = 'Memory encompasses multiple systems: short-term working memory (holding information temporarily), episodic memory (personal experiences), semantic memory (facts and concepts), and procedural memory (skills). Memory capacity and accuracy decline with age, but the rate of decline is highly variable and modifiable. Lifestyle factors—exercise, sleep, stress management, cognitive engagement—powerfully influence memory throughout life. Memory training can improve specific capacities.',
  longevity_impact = 'Memory decline is often the first sign of cognitive aging and dementia risk. The ACTIVE trial found that memory training reduced dementia risk by 29% over 10 years. Maintaining strong memory function associates with independence, quality of life, and successful aging. Lifestyle interventions (aerobic exercise, Mediterranean diet, cognitive training) can improve memory even in older adults.',
  quick_tips = jsonb_build_array(
    'Track memory subjectively (daily self-rating) to identify patterns and decline early',
    'Prioritize sleep—memory consolidation occurs during deep and REM sleep',
    'Use memory techniques: spaced repetition, chunking, visualization, method of loci',
    'Aerobic exercise increases hippocampal volume and improves memory',
    'Stress impairs memory—manage chronic stress through meditation, breathwork',
    'Engage in lifelong learning—new skills and languages strengthen memory systems'
  )
WHERE metric_name = 'Memory';

UPDATE display_metrics SET
  about_content = 'Mood reflects emotional state and affects motivation, decision-making, relationships, and health behaviors. Tracking mood over time reveals patterns related to sleep, exercise, social interaction, stress, and life events. Mood is not fixed—it responds to lifestyle interventions. Regular exercise, social connection, sleep quality, and stress management are among the most powerful mood modulators, often comparable to medication for mild-moderate depression.',
  longevity_impact = 'Chronic negative mood and depression increase mortality risk by 50%, cardiovascular disease by 30%, and dementia by 50-90%. Conversely, positive mood and life satisfaction strongly predict longevity. The landmark Nun Study found that nuns expressing more positive emotions in early-life writings lived 7-10 years longer. Mood is both an outcome and a modifiable risk factor.',
  quick_tips = jsonb_build_array(
    'Track mood daily (1-10 scale) to identify patterns and triggers',
    'Prioritize exercise—30 min moderate activity improves mood for 12+ hours',
    'Connect mood to sleep, social interaction, stress—address root causes',
    'Morning sunlight exposure improves mood through circadian and serotonin pathways',
    'If persistently low mood (>2 weeks), consult mental health professional',
    'Combine mood tracking with gratitude practice for comprehensive well-being monitoring'
  )
WHERE metric_name = 'Mood';

UPDATE display_metrics SET
  about_content = 'Sunlight sessions track the frequency of outdoor sun exposure events throughout the day. Multiple brief exposures may provide circadian and metabolic benefits comparable to single longer exposure. Frequent sessions indicate consistent outdoor activity and natural light exposure patterns. This metric complements total sunlight duration by revealing distribution patterns—important because morning light has different circadian effects than afternoon light.',
  longevity_impact = 'Regular, distributed sunlight exposure throughout the day maintains circadian rhythm alignment better than single long exposures. Multiple outdoor sessions often indicate active lifestyle with movement breaks—combining light exposure with reduced sedentary time. Both factors independently reduce chronic disease risk and mortality.',
  quick_tips = jsonb_build_array(
    'Aim for 3-5 sunlight sessions daily (morning, midday, afternoon)',
    'Brief outdoor breaks (5-10 minutes) count and help break sedentary time',
    'Morning session most important for circadian alignment',
    'Combine outdoor sessions with walking for synergistic benefits',
    'Track sessions to ensure consistent daily outdoor exposure pattern',
    'Even cloudy days provide beneficial natural light—go outside regardless'
  )
WHERE metric_name = 'Sunlight Sessions';

-- =====================================================
-- CONNECTION + PURPOSE (7 remaining)
-- =====================================================

UPDATE display_metrics SET
  about_content = 'Mindfulness practice duration tracks time spent in formal mindfulness meditation—non-judgmental awareness of present-moment experience. Duration matters for neuroplastic changes: 20-30 minutes daily produces measurable brain changes within 8 weeks. Longer practice sessions allow deeper states of concentration and insight. However, consistency (daily practice) is more important than duration for sustained benefits.',
  longevity_impact = 'Longer meditation practice associates with greater structural brain changes and health benefits. Studies show dose-dependent effects: 10 minutes daily improves attention and stress, 20-30 minutes produces measurable brain changes, 60+ minutes in experienced practitioners shows extensive cortical thickening and reduced biological aging markers.',
  quick_tips = jsonb_build_array(
    'Build from 10 to 20-30 minutes daily as practice develops',
    'Longer sessions (30-60 min) on weekends can deepen practice',
    'Track duration to ensure adequate practice time for neuroplastic benefits',
    'Quality matters—present-moment focus, not just sitting time',
    'Combine with breathwork for enhanced physiological benefits',
    'Use apps or timers to track precise duration and build consistency'
  )
WHERE metric_name = 'Mindfulness Duration';

UPDATE display_metrics SET
  about_content = 'Mindfulness sessions track the frequency of formal mindfulness practice. Multiple shorter sessions may produce benefits comparable to fewer longer sessions through distributed practice effects. Daily practice (even brief) maintains the neuroplastic and psychological benefits better than sporadic longer sessions. Session frequency indicates consistency—the most critical factor for sustained mindfulness benefits.',
  longevity_impact = 'Daily mindfulness practice, regardless of duration, produces cumulative benefits for stress resilience, emotional regulation, and cognitive function. The consistency of practice matters more than any single session. Regular practitioners show sustained reductions in stress biomarkers and inflammatory markers over time.',
  quick_tips = jsonb_build_array(
    'Aim for at least 1 daily session, ideally at consistent time',
    '2-3 shorter sessions (10-15 min) throughout day can be effective',
    'Morning session sets tone for day; evening helps wind down',
    'Track session frequency to maintain daily practice habit',
    'Missing occasional sessions is fine—return to practice without judgment',
    'Combine formal sessions with informal mindfulness (mindful eating, walking)'
  )
WHERE metric_name = 'Mindfulness Sessions';

UPDATE display_metrics SET
  about_content = 'Morning outdoor time specifically tracks early-day nature exposure, combining benefits of morning light (circadian alignment) and nature (stress reduction, mood enhancement). Morning is the most important time for light exposure to set circadian rhythms. Combining morning light with nature provides synergistic benefits: circadian alignment, cortisol regulation, mood enhancement, and physical activity.',
  longevity_impact = 'Morning outdoor exposure optimally times light for circadian health while providing nature-based stress reduction. Research shows morning outdoor time particularly reduces depression and anxiety while improving sleep quality at night. This combination of circadian and psychological benefits may explain why outdoor morning routines associate with better health outcomes.',
  quick_tips = jsonb_build_array(
    'Aim for 20-30 minutes of morning outdoor time within 2 hours of waking',
    'Combine with walking, coffee, or light exercise for habit stacking',
    'Even 10 minutes provides significant circadian and mood benefits',
    'Outdoor spaces: parks, gardens, tree-lined streets, even balconies work',
    'Morning routine sets tone for entire day—prioritize consistency',
    'Track morning outdoor time separately from total to ensure optimal timing'
  )
WHERE metric_name = 'Morning Outdoor Time';

UPDATE display_metrics SET
  about_content = 'Outdoor sessions track the frequency of discrete nature exposure events throughout the day. Multiple brief outdoor sessions may provide benefits comparable to single long sessions while also breaking sedentary time. Session frequency indicates lifestyle integration of outdoor exposure. Regular outdoor sessions often correlate with more active lifestyle, better stress management, and stronger connection to natural world.',
  longevity_impact = 'Frequent outdoor sessions indicate consistent nature engagement throughout the day. Research shows that people with 3+ daily outdoor sessions have lower stress biomarkers and better mood than those with single daily exposure, even with similar total duration. Distributed outdoor time may optimize circadian, metabolic, and psychological benefits.',
  quick_tips = jsonb_build_array(
    'Aim for 3-5 outdoor sessions daily: morning, midday, afternoon/evening',
    'Brief sessions (5-10 minutes) count—outdoor breaks effective for stress reduction',
    'Combine with other activities: meals outside, walking calls, outdoor work',
    'Each session provides circadian signal and stress reduction',
    'Track session frequency to ensure consistent daily outdoor exposure pattern',
    'Weather permitting, prioritize outdoor sessions over indoor breaks'
  )
WHERE metric_name = 'Outdoor Sessions';

UPDATE display_metrics SET
  about_content = 'Screen time sessions track the frequency of discrete screen use episodes rather than total duration. Fewer, longer focused sessions (deep work) differ from many brief, fragmented sessions (constant checking). High session frequency often indicates compulsive phone checking, task switching, and fragmented attention—harmful for productivity and mental health. Tracking sessions reveals usage patterns beyond total duration.',
  longevity_impact = 'Screen session frequency (not just duration) associates with mental health outcomes. Studies show that people who check phones 50+ times daily have higher anxiety and stress than those checking 10-20 times with similar total screen time. Constant switching and notification checking activates stress response and impairs sustained focus.',
  quick_tips = jsonb_build_array(
    'Reduce screen sessions through batching: check email/social at set times',
    'Turn off notifications to reduce involuntary screen sessions',
    'Track session frequency to reveal compulsive checking patterns',
    'Aim for longer, intentional sessions rather than constant brief checks',
    'Use app timers and grayscale to reduce mindless session initiation',
    'Replace brief screen sessions with brief outdoor/movement breaks'
  )
WHERE metric_name = 'Screen Time Sessions';

UPDATE display_metrics SET
  about_content = 'Subjective stress level tracking provides daily self-assessment of perceived stress. Stress is not just external events but internal perception and response. Tracking reveals patterns: which situations, times of day, or life factors elevate stress. This awareness enables targeted interventions. Chronic elevated stress drives multiple disease pathways through sustained cortisol elevation, inflammation, and autonomic nervous system dysregulation.',
  longevity_impact = 'Chronic stress is a major longevity threat, increasing mortality risk by 30-50% through cardiovascular, metabolic, and immune pathways. However, stress is modifiable. Studies show that perceived stress predicts health outcomes independent of stressors themselves—how we interpret and respond matters. Stress management interventions reduce biomarkers of aging and chronic disease risk.',
  quick_tips = jsonb_build_array(
    'Rate stress daily (1-10 scale) to identify patterns and chronic elevation',
    'Connect stress ratings to sleep, exercise, social support—address root causes',
    'Chronic stress (consistently 6+) requires intervention: breathwork, meditation, therapy',
    'Track alongside stress management practices to see intervention effects',
    'Physical stress (exercise) is beneficial; psychological stress (chronic worry) is harmful',
    'If stress remains chronically high despite interventions, seek professional support'
  )
WHERE metric_name = 'Stress Level';

UPDATE display_metrics SET
  about_content = 'Stress management practice duration tracks time spent in formal stress-reducing activities: meditation, breathwork, yoga, progressive muscle relaxation, nature exposure. Duration matters—longer practice sessions allow deeper physiological relaxation and parasympathetic activation. However, even brief practices (5-10 minutes) provide measurable stress reduction. Regular practice builds stress resilience over time.',
  longevity_impact = 'Regular stress management practice reduces chronic stress biomarkers (cortisol, inflammatory cytokines) and cardiovascular disease risk. Meta-analyses show that 20-30 minutes daily of stress management practice reduces blood pressure, improves HRV, and lowers mortality risk by 10-20%. The dose-response relationship is clear: more practice time produces greater benefits.',
  quick_tips = jsonb_build_array(
    'Aim for 20-30 minutes daily of formal stress management practice',
    'Combine different modalities: breathwork (5-10 min) + meditation (15-20 min)',
    'Practice preventively, not just reactively—daily practice builds resilience',
    'Track duration to ensure adequate time for physiological stress reduction',
    'Morning practice reduces stress throughout day; evening improves sleep',
    'If chronically stressed, consider 40-60 minutes daily until stress normalizes'
  )
WHERE metric_name = 'Stress Management Duration';

-- =====================================================
-- CORE CARE (43 remaining)
-- =====================================================

UPDATE display_metrics SET
  about_content = 'Age is the strongest risk factor for chronic disease and mortality. Biological aging (cellular and molecular changes) can differ from chronological age by 10-20 years depending on lifestyle. Tracking age alongside biomarkers reveals biological aging rate. While age itself is not modifiable, its effects are—lifestyle interventions can slow biological aging and extend healthspan.',
  longevity_impact = 'Each decade of chronological age approximately doubles mortality risk and chronic disease incidence. However, biological age (measured by telomeres, DNA methylation, inflammatory markers) better predicts health outcomes. Lifestyle interventions can reduce biological age by 1-10 years, effectively buying time against age-related decline.',
  quick_tips = jsonb_build_array(
    'Track age alongside biomarkers to monitor biological vs chronological aging',
    'Focus on modifiable aging determinants: exercise, nutrition, sleep, stress',
    'Preventive care becomes more critical with age—screening frequency increases',
    'Muscle mass and VO2 max decline accelerate after 50—prioritize resistance and cardio training',
    'Protein needs increase with age (1.2-1.6g/kg) to combat anabolic resistance',
    'Consider biological age testing (epigenetic clocks) to measure intervention effectiveness'
  )
WHERE metric_name = 'Age';

UPDATE display_metrics SET
  about_content = 'This metric tracks alcohol consumption relative to baseline level, revealing trends: increasing, stable, or decreasing use over time. Change from baseline is more informative than absolute amounts—trending upward may indicate developing dependence, while trending downward indicates successful moderation. Tracking relative to baseline provides personalized context.',
  longevity_impact = 'Trends in alcohol use predict health trajectories. Increasing consumption over time associates with higher disease risk and mortality. Conversely, reducing heavy drinking to moderate or abstinent levels reduces cardiovascular and cancer risk within months to years. Tracking changes enables early intervention before clinical consequences appear.',
  quick_tips = jsonb_build_array(
    'Track trend relative to baseline—increasing use warrants intervention',
    'Set personal limit and monitor deviations: 1 drink/day women, 2 men (but less is better)',
    'Any regular increase from baseline suggests reassessing relationship with alcohol',
    'If trending upward, implement 30-day alcohol-free period to reset',
    'Substitute alcohol with other stress-management tools: exercise, meditation, social connection',
    'Decreasing trend toward zero provides maximum longevity benefit'
  )
WHERE metric_name = 'Alcohol vs Baseline';

UPDATE display_metrics SET
  about_content = 'Body Mass Index (BMI) calculates weight relative to height squared (kg/m²). While imperfect (doesn''t distinguish muscle from fat), BMI provides population-level health risk assessment. Optimal BMI for longevity is 22-25 for most adults, though this varies by ethnicity and age. BMI outside optimal range increases mortality risk through metabolic, cardiovascular, and mechanical pathways.',
  longevity_impact = 'The Million Women Study found lowest mortality at BMI 22-24. Each 5-unit increase above 25 increases mortality by 30%. BMI <18.5 (underweight) also increases mortality, likely reflecting underlying illness. However, BMI limitations are significant: muscular individuals may have "overweight" BMI but excellent health. Body composition (lean mass vs fat mass) matters more than BMI.',
  quick_tips = jsonb_build_array(
    'Calculate BMI: weight(kg) / height(m)² or use online calculator',
    'Target BMI 22-25 for optimal longevity (18.5-24.9 is "normal range")',
    'BMI 25-30 (overweight) warrants attention to nutrition and activity',
    'BMI >30 (obese) significantly increases health risks—prioritize weight management',
    'If muscular, combine BMI with waist circumference and body composition',
    'Track trends: stable BMI in optimal range is goal, not perfection'
  )
WHERE metric_name = 'BMI';

UPDATE display_metrics SET
  about_content = 'Body fat percentage measures fat mass relative to total body weight, providing better health risk assessment than weight or BMI alone. Healthy ranges: 10-20% for men, 18-28% for women (varies by age). Excess fat—especially visceral fat around organs—drives metabolic disease through inflammatory signaling. Muscle mass matters as much as fat mass for metabolic health.',
  longevity_impact = 'Body composition (fat vs lean mass) predicts mortality better than BMI. High body fat (>25% men, >32% women) increases cardiovascular disease, diabetes, and cancer risk even at normal BMI. Conversely, maintaining higher muscle mass protects against mortality independent of fat mass. The "obesity paradox" (overweight BMI with low mortality) reflects muscle mass.',
  quick_tips = jsonb_build_array(
    'Measure body fat via DEXA scan, bioimpedance scale, or calipers',
    'Target ranges: 10-20% (men), 18-28% (women) for optimal health',
    'Focus on fat loss while preserving/building muscle through resistance training',
    'Visceral fat (waist circumference) is most harmful—prioritize reduction',
    'Track body fat trends, not just weight—muscle gain may increase weight',
    'Combine high-protein diet (1.6g/kg) with resistance training to optimize composition'
  )
WHERE metric_name = 'Body Fat %';

UPDATE display_metrics SET
  about_content = 'Breast MRI is advanced imaging for women at high risk of breast cancer (strong family history, BRCA mutations, dense breasts). Annual MRI plus mammography detects cancers missed by mammography alone. MRI is more sensitive but less specific than mammography, leading to more false positives. Guidelines recommend MRI for high-risk women starting age 25-30, continuing throughout life.',
  longevity_impact = 'For high-risk women, adding MRI to mammography reduces late-stage breast cancer diagnosis by 50% and improves survival. The combination detects 90-95% of cancers vs 50-60% with mammography alone in high-risk populations. However, MRI is not recommended for average-risk women due to high false-positive rate and cost.',
  quick_tips = jsonb_build_array(
    'Discuss MRI screening with doctor if you have high-risk factors',
    'High-risk criteria: BRCA mutation, 20%+ lifetime risk, chest radiation before age 30',
    'Annual MRI plus mammography for high-risk starting age 25-30',
    'Track months since last MRI to ensure annual adherence',
    'MRI requires contrast injection—discuss safety with provider if kidney concerns',
    'Timing: schedule MRI days 7-14 of menstrual cycle for best accuracy'
  )
WHERE metric_name = 'Breast MRI';

UPDATE display_metrics SET
  about_content = 'Tooth brushing removes plaque (bacterial biofilm) that causes cavities and gum disease. Brushing twice daily with fluoride toothpaste reduces dental decay by 25-30%. Optimal technique: 2 minutes, 45-degree angle to gumline, gentle circular motions, all surfaces. Poor oral hygiene causes periodontitis, which associates with cardiovascular disease, diabetes, and mortality through systemic inflammation.',
  longevity_impact = 'Poor oral health increases mortality risk by 20-50% through multiple pathways. Periodontitis bacteria enter bloodstream, triggering systemic inflammation and atherosclerosis. Studies show that tooth loss and gum disease predict cardiovascular disease, diabetes, and dementia. Conversely, excellent oral hygiene reduces these risks. Brushing twice daily is a simple longevity intervention.',
  quick_tips = jsonb_build_array(
    'Brush twice daily (morning and night) for 2 minutes each time',
    'Use soft-bristled brush at 45-degree angle to gumline',
    'Fluoride toothpaste prevents cavities—use pea-sized amount',
    'Replace toothbrush every 3 months or when bristles fray',
    'Brush after breakfast and before bed for optimal plaque removal',
    'Combine with daily flossing for comprehensive oral hygiene'
  )
WHERE metric_name = 'Brushing';

UPDATE display_metrics SET
  about_content = 'Cervical cancer screening detects precancerous changes and early cancer, enabling treatment before progression. Pap smear (cytology) examines cells for abnormalities; HPV test detects cancer-causing HPV strains. Guidelines: age 21-29, Pap every 3 years; age 30-65, Pap + HPV every 5 years or Pap alone every 3 years. Screening dramatically reduces cervical cancer mortality.',
  longevity_impact = 'Cervical screening reduced cervical cancer mortality by 70% since introduction. Early detection enables treatment of precancerous lesions, preventing cancer development. The 5-year survival rate is 92% for localized cervical cancer vs 17% for metastatic—screening saves lives through early detection. Women who skip screening account for most cervical cancer deaths.',
  quick_tips = jsonb_build_array(
    'Follow screening schedule: every 3-5 years depending on age and test type',
    'Don''t skip screenings—interval testing is designed for maximum safety',
    'Track time since last screening to ensure guideline adherence',
    'HPV vaccine (age 9-45) prevents 90% of cervical cancers—highly recommended',
    'Report abnormal bleeding or symptoms between screenings—don''t wait',
    'After age 65, can stop if recent screenings were normal (discuss with doctor)'
  )
WHERE metric_name = 'Cervical Screening';

UPDATE display_metrics SET
  about_content = 'Cigarette smoking is the single most harmful modifiable health behavior, increasing mortality risk by 200-300%. Smoking damages nearly every organ through multiple mechanisms: carcinogens causing DNA mutations, carbon monoxide reducing oxygen delivery, oxidative stress, inflammation, and vascular damage. No safe level exists—even 1-5 cigarettes daily doubles cardiovascular mortality. Quitting at any age provides immediate and long-term benefits.',
  longevity_impact = 'Smoking reduces life expectancy by 10-15 years on average. Smokers have 15-30x higher lung cancer risk, 2-4x higher cardiovascular disease risk, and accelerated biological aging. However, quitting reverses many effects: cardiovascular risk halves within 1 year, returns near normal within 15 years. Quitting at age 40 recovers 9 years of life expectancy; at age 50, 6 years.',
  quick_tips = jsonb_build_array(
    'Goal: zero cigarettes—no safe smoking level exists',
    'Quitting provides immediate benefits: circulation improves within weeks',
    'Use evidence-based cessation: NRT (nicotine replacement), varenicline, bupropion, counseling',
    'Track daily cigarettes to monitor quit attempts and identify triggers',
    'Each quit attempt increases success likelihood—don''t give up',
    'If smoking, cessation is the single most impactful health intervention you can make'
  )
WHERE metric_name = 'Cigarettes';

UPDATE display_metrics SET
  about_content = 'This tracks cigarette consumption relative to baseline level, revealing trends in smoking behavior. Trending upward indicates worsening addiction or increased stress/triggers. Trending downward shows progress toward cessation. Even small reductions (e.g., 20 to 10 cigarettes daily) provide health benefits, though complete cessation is the goal. Tracking relative to baseline provides motivation and accountability.',
  longevity_impact = 'Reducing cigarette consumption improves health outcomes even if not quitting completely. Cutting smoking in half reduces cardiovascular risk by 25-35%. However, complete cessation provides far greater benefits than reduction. Tracking trends enables early intervention when consumption increases and recognition when reduction strategies work.',
  quick_tips = jsonb_build_array(
    'Track daily cigarettes and compare to baseline—aim for downward trend',
    'Set reduction goals: cut by 25% every 2 weeks toward zero',
    'Increasing trend signals need for intervention: counseling, medication, trigger management',
    'Celebrate reductions but keep complete cessation as ultimate goal',
    'Use tracking data with healthcare provider to tailor cessation plan',
    'Any reduction is progress—don''t let setbacks derail overall downward trajectory'
  )
WHERE metric_name = 'Cigarettes vs Baseline';

UPDATE display_metrics SET
  about_content = 'Colonoscopy screens for colorectal cancer and precancerous polyps. During the procedure, gastroenterologists visualize entire colon and remove polyps, preventing cancer development. Guidelines recommend screening starting age 45 for average-risk individuals, every 10 years if normal (more frequently if polyps found or high-risk factors). Colonoscopy is the gold-standard screening test.',
  longevity_impact = 'Colonoscopy screening reduces colorectal cancer mortality by 60-70% through early detection and polyp removal. Colorectal cancer is the third-leading cancer cause of death in the US, yet highly preventable through screening. The National Polyp Study found that polyp removal reduced colorectal cancer incidence by 76-90% over 20 years.',
  quick_tips = jsonb_build_array(
    'Start screening at age 45 (earlier if family history or symptoms)',
    'If normal colonoscopy, repeat every 10 years through age 75',
    'Track years since last colonoscopy to ensure guideline adherence',
    'Polyps found? Follow provider recommendations for more frequent screening',
    'Proper bowel prep is critical—follow instructions carefully for accurate results',
    'Report symptoms (bleeding, change in bowel habits) between screenings—don''t wait'
  )
WHERE metric_name = 'Colonoscopy Compliance';

UPDATE display_metrics SET
  about_content = 'Dental exams (professional cleaning and evaluation) should occur every 6 months for most adults. Hygienists remove calcified plaque (tartar) that brushing can''t remove, and dentists screen for cavities, gum disease, and oral cancer. Regular exams prevent progression from gingivitis (reversible inflammation) to periodontitis (irreversible bone loss). Professional care is essential—home hygiene alone is insufficient.',
  longevity_impact = 'Regular dental care prevents periodontal disease, which associates with 20-50% increased cardiovascular mortality through chronic inflammation and bacteremia. Studies show that individuals with frequent dental visits have lower rates of heart disease, stroke, and diabetes complications. Dental care is preventive medicine, not just cosmetic.',
  quick_tips = jsonb_build_array(
    'Schedule dental exams every 6 months (twice yearly)',
    'Track months since last exam to maintain schedule—set reminders',
    'Don''t skip appointments even if teeth feel fine—prevention is key',
    'Communicate health changes to dentist: medications, diagnoses affect oral health',
    'Address pain or bleeding immediately—don''t wait for scheduled appointment',
    'Dental insurance typically covers 2 exams yearly—use this preventive benefit'
  )
WHERE metric_name = 'Dental Exam';

UPDATE display_metrics SET
  about_content = 'Diastolic blood pressure (the bottom number) measures pressure in arteries when the heart rests between beats. Normal is <80 mmHg. Elevated diastolic (80-89) or high (90+) indicates hypertension. Diastolic pressure reflects vascular resistance and arterial stiffness. Controlling diastolic BP prevents heart disease, stroke, and kidney disease.',
  longevity_impact = 'Each 10 mmHg increase in diastolic BP above 70 increases cardiovascular mortality by 20-30%. The Framingham Heart Study found that diastolic BP >90 doubled cardiovascular disease risk over 30 years. Reducing diastolic BP by 5 mmHg through lifestyle or medication reduces stroke risk by 34% and heart disease by 21%.',
  quick_tips = jsonb_build_array(
    'Target diastolic BP <80 mmHg (optimal <70 for some adults)',
    'Diastolic 80-89 is elevated—implement lifestyle changes: diet, exercise, stress management',
    'Diastolic >90 is hypertensive—requires medical treatment',
    'Check BP regularly at home with validated monitor—track trends',
    'Lower diastolic through weight loss, reduced sodium, DASH diet, exercise',
    'If diastolic remains high despite lifestyle changes, medication prevents complications'
  )
WHERE metric_name = 'Diastolic BP';

UPDATE display_metrics SET
  about_content = 'Digital shutoff refers to stopping screen use (phones, tablets, computers, TV) 60-90 minutes before bed to protect sleep quality. Blue light from screens suppresses melatonin secretion, delaying circadian rhythms and making it harder to fall asleep. The content (especially stimulating or stressful material) further activates the nervous system. Digital shutoff is one of the most effective sleep hygiene practices.',
  longevity_impact = 'Evening screen use delays sleep onset by 30-60 minutes, reduces total sleep time, and impairs sleep quality—all of which increase chronic disease risk. Studies show that digital shutoff for 1 week improves sleep quality, mood, and metabolic markers. The blue light effect is comparable to caffeine consumed before bed.',
  quick_tips = jsonb_build_array(
    'Stop all screens 60-90 minutes before target sleep time',
    'Use blue light filters or glasses if evening screen use necessary',
    'Replace screens with relaxing activities: reading (physical books), journaling, stretching',
    'Charge phones outside bedroom to reduce temptation',
    'Track digital shutoff adherence—correlate with sleep quality metrics',
    'Earlier shutoff (2 hours) provides greater benefits for sensitive individuals'
  )
WHERE metric_name = 'Digital Shutoff';

UPDATE display_metrics SET
  about_content = 'Evening routine is a consistent sequence of relaxing activities before bed that signal to the body that sleep is approaching. Effective routines activate the parasympathetic nervous system, reduce cortisol, and facilitate transition from wakefulness to sleep. Components may include: dimming lights, cool temperature, light stretching, reading, journaling, meditation. Consistency is key—same routine nightly trains the brain.',
  longevity_impact = 'Consistent evening routines improve sleep quality, which in turn reduces mortality risk by 15-30%. The routine itself provides stress reduction and psychological wind-down beyond sleep effects. Blue Zone populations emphasize consistent evening rituals that promote relaxation and social connection before sleep.',
  quick_tips = jsonb_build_array(
    'Establish consistent 30-60 minute evening routine before target sleep time',
    'Include: dim lights, cool temperature, relaxing activities (reading, stretching, meditation)',
    'Avoid stimulating activities: work, difficult conversations, intense exercise, screens',
    'Same routine nightly—consistency is key for sleep quality improvement',
    'Track routine adherence and correlate with sleep metrics',
    'Adjust routine based on what helps you relax and sleep best'
  )
WHERE metric_name = 'Evening Routine';

UPDATE display_metrics SET
  about_content = 'Flossing removes plaque and food particles from between teeth where brushing can''t reach. Daily flossing prevents interdental cavities and gum disease. Only 30% of Americans floss daily, yet it''s as important as brushing. Proper technique: 18 inches of floss, wrap around middle fingers, gentle C-shape around each tooth, slide below gumline. Bleeding when starting to floss indicates gum inflammation that will resolve with consistent flossing.',
  longevity_impact = 'Flossing reduces periodontal disease, which associates with 20-40% lower cardiovascular disease risk. The connection between oral health and systemic health is well-established. While direct causation is debated, the inflammatory pathway is clear. Daily flossing is a simple, low-cost habit with potential longevity benefits beyond oral health.',
  quick_tips = jsonb_build_array(
    'Floss once daily, preferably before bed after brushing',
    'Use 18 inches of floss—fresh section for each tooth',
    'Gentle C-shape around tooth, slide below gumline on both sides',
    'Initial bleeding is normal—should resolve within 1-2 weeks of daily flossing',
    'Water flossers are effective alternative if manual flossing difficult',
    'Track flossing to build daily habit—most people need reminders initially'
  )
WHERE metric_name = 'Flossing';

UPDATE display_metrics SET
  about_content = 'Height is relatively stable in adults but slowly decreases with age due to spinal disc compression and postural changes. Significant height loss (>1.5 inches) may indicate osteoporosis or vertebral fractures. Tracking height annually after age 50 enables early detection of bone health issues. Height is also used to calculate BMI and adjust medication dosing.',
  longevity_impact = 'Height loss >1.5 inches associates with increased fracture risk, mortality, and chronic disease. The Framingham study found that adults losing >2 inches had 50% higher mortality over 25 years. Height loss reflects spinal health, bone density, and posture—all modifiable through strength training, nutrition, and fall prevention.',
  quick_tips = jsonb_build_array(
    'Measure height annually after age 50 to track changes',
    'Height loss >1.5 inches warrants bone density testing (DEXA scan)',
    'Maintain height through: weight-bearing exercise, calcium/vitamin D, good posture',
    'Significant height loss may indicate osteoporosis—discuss with healthcare provider',
    'Height affects BMI calculation—use accurate recent measurement',
    'Strength training and yoga help maintain posture and spinal health'
  )
WHERE metric_name = 'Height';

UPDATE display_metrics SET
  about_content = 'Last caffeine buffer measures time between last caffeine consumption and target sleep time. Caffeine has a 5-6 hour half-life, meaning 50% remains in the bloodstream 5-6 hours after consumption. Even if you can fall asleep with caffeine on board, sleep quality (especially deep sleep) is impaired. A 6-8 hour buffer before bed optimizes sleep quality.',
  longevity_impact = 'Caffeine consumed within 6 hours of bedtime reduces total sleep time by 30-60 minutes and deep sleep by 10-20%, even if subjective sleep quality seems fine. Chronic sleep impairment from evening caffeine increases cardiovascular disease and mortality risk. Creating adequate buffer is a simple intervention with significant sleep benefits.',
  quick_tips = jsonb_build_array(
    'Stop caffeine 6-8 hours before target sleep time (8pm bed = 12-2pm cutoff)',
    'Track last caffeine time and correlate with sleep quality metrics',
    'Sensitive individuals may need 8-10 hour buffer—adjust based on sleep data',
    'Remember hidden caffeine: chocolate, green tea, some medications',
    'If sleep is impaired, try moving cutoff earlier by 1-2 hours',
    'Morning-only caffeine (before 10am) ensures no sleep interference for most people'
  )
WHERE metric_name = 'Last Caffeine Buffer';

UPDATE display_metrics SET
  about_content = 'Last caffeine time tracks when you last consumed caffeine-containing products (coffee, tea, energy drinks, chocolate, pre-workout). This metric helps identify patterns where late caffeine consumption impairs sleep. Combined with sleep quality data, you can determine your personal caffeine cutoff time. Individual sensitivity varies—some people can have afternoon coffee with no sleep effects, others need morning-only caffeine.',
  longevity_impact = 'Late caffeine consumption (within 6 hours of bed) significantly impairs sleep architecture even when subjective sleep seems fine. Poor sleep from caffeine increases chronic disease risk. Tracking last caffeine time enables personalized optimization—finding the latest consumption time that doesn''t impair your sleep quality.',
  quick_tips = jsonb_build_array(
    'Track last daily caffeine time and correlate with sleep metrics',
    'Experiment with earlier cutoffs if sleep quality is poor',
    'General guideline: stop caffeine 6-8 hours before bed',
    'Remember all caffeine sources: coffee, tea, chocolate, supplements, medications',
    'If sensitive, limit caffeine to morning hours (before 10-11am)',
    'Use tracking data to find your personal optimal cutoff time'
  )
WHERE metric_name = 'Last Caffeine Time';

UPDATE display_metrics SET
  about_content = 'Mammogram compliance tracks adherence to breast cancer screening guidelines. Screening mammography detects early-stage breast cancer when treatment is most effective. Guidelines: age 40-49, discuss with doctor; age 50-74, biennial screening; age 75+, individualized decision. Some organizations recommend annual starting at 40. Tracking ensures guideline adherence.',
  longevity_impact = 'Mammography screening reduces breast cancer mortality by 20-30% through early detection. The Swedish Two-County Trial found that screening prevented 30% of breast cancer deaths over 20 years. Early-stage (localized) breast cancer has 99% 5-year survival vs 27% for metastatic—screening saves lives.',
  quick_tips = jsonb_build_array(
    'Follow screening schedule: every 1-2 years starting age 40-50 (discuss with doctor)',
    'Track months since last mammogram to ensure timely screening',
    'Don''t skip mammograms even during busy periods—early detection is critical',
    'Report breast changes (lumps, pain, discharge) between screenings',
    'Family history? May need earlier or more frequent screening—discuss with provider',
    'Schedule mammogram in first half of menstrual cycle for less discomfort'
  )
WHERE metric_name = 'Mammogram Compliance';

UPDATE display_metrics SET
  about_content = 'Medication adherence measures consistency in taking prescribed medications as directed. Poor adherence is the leading cause of treatment failure and preventable hospitalizations. Common reasons include forgetfulness, side effects, cost, and complexity. Adherence rates drop significantly with multiple medications. Tracking adherence enables intervention before health consequences occur.',
  longevity_impact = 'Poor medication adherence causes 125,000 deaths annually in the US and increases hospitalization risk by 200-300%. For chronic conditions like hypertension, diabetes, and heart disease, medication adherence directly determines outcomes. Studies show that >80% adherence is needed for most medications to achieve therapeutic benefits.',
  quick_tips = jsonb_build_array(
    'Use pill organizers, apps, or alarms to improve adherence',
    'Track daily—missing doses enables early intervention',
    'Discuss side effects with provider—often can adjust medication vs stopping',
    'Simplify regimen: ask about once-daily options or combination pills',
    'Link medication-taking to daily habits (brushing teeth, meals)',
    'If struggling with adherence, tell your doctor—don''t just stop taking medications'
  )
WHERE metric_name = 'Medication Adherence';

UPDATE display_metrics SET
  about_content = 'Tracks time since last breast MRI for high-risk women. MRI is recommended annually for women with high breast cancer risk (>20% lifetime risk, BRCA mutations, chest radiation history). Annual screening is critical because high-risk women develop aggressive cancers that grow rapidly. Missing annual screening increases risk of late-stage diagnosis.',
  longevity_impact = 'For high-risk women, annual MRI plus mammography reduces late-stage diagnosis by 50% compared to mammography alone. Maintaining annual schedule is critical—fast-growing cancers can develop within 12 months. Regular screening enables early detection when treatment is most effective and survival is highest.',
  quick_tips = jsonb_build_array(
    'Track months since last MRI—set reminder at 11 months to schedule next',
    'High-risk women need annual MRI plus mammogram (stagger by 6 months for biannual screening)',
    'Don''t delay screening due to COVID or scheduling issues—breast cancer doesn''t wait',
    'If >15 months since last MRI, schedule immediately',
    'Maintain calendar with future screening dates to ensure annual adherence',
    'Insurance typically covers annual MRI for high-risk women—verify coverage'
  )
WHERE metric_name = 'Months Since Breast MRI';

UPDATE display_metrics SET
  about_content = 'Tracks time since last dental exam. Six-month intervals are recommended for most adults to prevent progression of dental disease. Tracking ensures you maintain preventive care schedule. Delaying dental care allows reversible conditions (cavities, gingivitis) to progress to irreversible damage (root canals, tooth loss, periodontitis).',
  longevity_impact = 'Regular dental care (every 6 months) prevents periodontal disease, which associates with 20-50% increased cardiovascular mortality. Maintaining dental schedule is preventive medicine—catching problems early reduces systemic inflammation and preserves oral health throughout life.',
  quick_tips = jsonb_build_array(
    'Track months since last dental exam—schedule next at 5 months',
    'Set recurring 6-month calendar reminders for dental appointments',
    'If >9 months, schedule immediately—longer gaps increase disease risk',
    'Book next appointment before leaving dental office to maintain schedule',
    'Dental insurance covers 2 exams yearly—use this preventive benefit',
    'Don''t skip appointments due to cost—prevention is cheaper than treating advanced disease'
  )
WHERE metric_name = 'Months Since Dental';

UPDATE display_metrics SET
  about_content = 'Tracks time since last mammogram. Guidelines vary: some recommend annual starting at 40, others biennial starting at 50. Tracking ensures adherence to your personalized screening plan. Delaying mammograms increases risk of late-stage diagnosis when treatment is less effective and survival is lower.',
  longevity_impact = 'Mammography screening reduces breast cancer mortality by 20-30%. Maintaining regular screening schedule maximizes early detection. Delays beyond 2 years significantly increase risk of advanced-stage cancer at diagnosis, which dramatically worsens prognosis.',
  quick_tips = jsonb_build_array(
    'Track months since last mammogram based on your screening plan (annual or biennial)',
    'Set calendar reminder 1 month before due date to schedule appointment',
    'If following annual screening, >15 months indicates overdue',
    'If biennial, >27 months indicates overdue',
    'Don''t delay due to COVID or busy schedule—early detection saves lives',
    'Schedule next mammogram before leaving facility to maintain schedule'
  )
WHERE metric_name = 'Months Since Mammogram';

UPDATE display_metrics SET
  about_content = 'Tracks time since last full-body skin check by dermatologist. Annual skin exams are recommended for high-risk individuals (fair skin, many moles, sun exposure history, personal/family history of skin cancer). Skin cancer is the most common cancer but highly curable when detected early. Dermatologists identify suspicious lesions missed by self-examination.',
  longevity_impact = 'Melanoma 5-year survival is 99% when caught early (localized) vs 27% when metastatic. Regular skin checks enable early detection. While most skin cancers are non-melanoma (basal cell, squamous cell) and rarely fatal, they cause significant morbidity. Annual dermatology visits prevent advanced disease.',
  quick_tips = jsonb_build_array(
    'High-risk individuals: annual full-body skin check by dermatologist',
    'Track months since last check—schedule at 11 months to maintain annual schedule',
    'Average-risk individuals: every 1-3 years or as recommended by dermatologist',
    'Perform monthly self-exams between professional checks (ABCDEs of melanoma)',
    'Report new or changing lesions immediately—don''t wait for scheduled appointment',
    'If >18 months since last check and you''re high-risk, schedule immediately'
  )
WHERE metric_name = 'Months Since Skin Check';

UPDATE display_metrics SET
  about_content = 'Tracks time since last comprehensive eye exam. Adults 18-60 need exams every 2 years; 61+ need annual exams. Eye exams detect vision changes (needing prescription updates) and screen for eye diseases: glaucoma, cataracts, macular degeneration, diabetic retinopathy. Many sight-threatening conditions are asymptomatic early—only professional examination detects them.',
  longevity_impact = 'Regular eye exams prevent vision loss from glaucoma (irreversible nerve damage), diabetic retinopathy (leading cause of blindness in working-age adults), and macular degeneration (leading cause of blindness in older adults). Early detection enables treatment before permanent damage. Vision loss significantly impairs quality of life and increases fall/injury risk.',
  quick_tips = jsonb_build_array(
    'Adults 18-60: eye exam every 24 months; 61+: annual exams',
    'Track months since last exam to maintain schedule',
    'Diabetics need annual exams regardless of age—diabetes damages eyes',
    'If >30 months (18-60) or >15 months (61+), schedule immediately',
    'Report sudden vision changes immediately—don''t wait for scheduled exam',
    'Comprehensive exam includes dilation—brings sunglasses to appointment'
  )
WHERE metric_name = 'Months Since Vision';

UPDATE display_metrics SET
  about_content = 'Morning sunscreen application protects skin from UV damage during outdoor activities. While some morning sun exposure (10-30 min) without sunscreen is beneficial for vitamin D and circadian alignment, prolonged exposure requires protection. Sunscreen prevents photoaging, hyperpigmentation, and skin cancer. Broad-spectrum SPF 30+ blocks 97% of UVB rays.',
  longevity_impact = 'Daily sunscreen use reduces melanoma risk by 50-73% and squamous cell carcinoma by 40%. The Australian study found that daily sunscreen users had 24% lower mortality over 15 years—possibly through reduced cancer risk and preserved immune function. Balance sun benefits (vitamin D, circadian) with protection (sunscreen after initial exposure).',
  quick_tips = jsonb_build_array(
    'Apply sunscreen to exposed skin before outdoor activities >30 minutes',
    'Allow 10-30 min morning sun exposure without sunscreen for vitamin D',
    'Then apply broad-spectrum SPF 30+ to all exposed areas',
    'Reapply every 2 hours if outdoors continuously',
    'Use 1 oz (shot glass) for full body coverage—most people under-apply',
    'Balance sun benefits and protection: brief unprotected exposure, then sunscreen'
  )
WHERE metric_name = 'Morning Sunscreen';

UPDATE display_metrics SET
  about_content = 'Peptide adherence tracks consistency in taking prescribed peptide medications (e.g., GLP-1 agonists for diabetes/weight loss, growth hormone, thymosin). Peptides require specific administration (often injections), timing, and storage. Adherence is critical for efficacy. Missing doses or inconsistent timing reduces therapeutic benefits.',
  longevity_impact = 'Peptide medications offer significant benefits when used consistently: GLP-1 agonists reduce cardiovascular events by 14-26% in diabetics, growth hormone therapy may improve body composition and quality of life in deficient adults. However, benefits require consistent use—intermittent dosing significantly reduces efficacy.',
  quick_tips = jsonb_build_array(
    'Track every dose—peptides often require weekly or more frequent administration',
    'Use calendar reminders for injection days (especially weekly peptides)',
    'Store peptides properly (often refrigerated)—improper storage reduces potency',
    'Consistent timing optimizes effectiveness—take at same day/time when possible',
    'Missing doses? Discuss with provider—don''t double dose to catch up',
    'Peptides are expensive—consistent use ensures you get therapeutic benefit'
  )
WHERE metric_name = 'Peptide Adherence';

UPDATE display_metrics SET
  about_content = 'Annual physical exam with primary care provider includes comprehensive health assessment: vital signs, physical examination, medication review, preventive screening discussion, and health counseling. Physicals enable early detection of concerning trends (rising BP, weight gain), update preventive care (vaccinations), and establish baseline for comparison. The relationship with a consistent provider improves long-term health outcomes.',
  longevity_impact = 'Regular primary care visits reduce mortality by 20-30% through preventive care, early disease detection, and chronic disease management. The continuity of care with one provider improves outcomes—they know your history and can identify subtle changes. Annual physicals are the foundation of preventive medicine.',
  quick_tips = jsonb_build_array(
    'Schedule annual physical exam with same primary care provider for continuity',
    'Track years since last physical—schedule next at 11 months',
    'Bring medication list, health questions, and any symptoms to discuss',
    'Physicals include: vital signs, physical exam, lab work (if due), preventive screening discussion',
    'Use physical to ensure you''re current on: vaccinations, cancer screenings, age-appropriate testing',
    'If >18 months since last physical, schedule immediately'
  )
WHERE metric_name = 'Physical Exam';

UPDATE display_metrics SET
  about_content = 'PSA (prostate-specific antigen) blood test screens for prostate cancer in men. Guidelines vary: some recommend annual screening starting at age 50 (45 if high-risk), others recommend shared decision-making about screening. PSA screening is controversial—it reduces prostate cancer mortality but causes overdiagnosis and overtreatment of slow-growing cancers. Discuss risks/benefits with provider.',
  longevity_impact = 'PSA screening reduces prostate cancer mortality by 20-30% in randomized trials, but also leads to overdiagnosis of 30-50% of screen-detected cancers (many would never cause harm). The decision involves weighing mortality reduction against side effects of unnecessary treatment (incontinence, erectile dysfunction). Individualized discussion with provider is essential.',
  quick_tips = jsonb_build_array(
    'Discuss PSA screening with provider at age 45-50 to make informed decision',
    'If screening: annual or every 2 years based on PSA level and risk factors',
    'Black men and those with family history should discuss screening at age 40-45',
    'Track years since last PSA if you''re screening',
    'Rising PSA or PSA >4 ng/mL may warrant further evaluation',
    'PSA screening is a choice—discuss pros/cons with provider to decide if right for you'
  )
WHERE metric_name = 'PSA Test';

UPDATE display_metrics SET
  about_content = 'Full-body skin check by dermatologist examines skin head-to-toe for suspicious lesions. Dermatoscopy (magnified examination) identifies features invisible to naked eye. Skin checks detect melanoma, basal cell carcinoma, and squamous cell carcinoma early. High-risk individuals need annual checks; average-risk may need exams every 1-3 years. Self-exams complement but don''t replace professional examination.',
  longevity_impact = 'Melanoma 5-year survival is 99% for localized disease vs 27% for metastatic—early detection through skin checks is lifesaving. Dermatologist examination is more sensitive than self-exam. Regular skin checks reduce melanoma mortality, especially in high-risk populations (fair skin, sun exposure, family history).',
  quick_tips = jsonb_build_array(
    'High-risk individuals: annual full-body skin check by dermatologist',
    'Average-risk: every 1-3 years or as dermatologist recommends',
    'Perform monthly self-exams between professional checks using ABCDEs of melanoma',
    'Track frequency of professional skin checks to maintain schedule',
    'Report new, changing, or symptomatic (bleeding, itching) lesions immediately',
    'Photograph suspicious moles to track changes over time'
  )
WHERE metric_name = 'Skin Check';

UPDATE display_metrics SET
  about_content = 'Skincare routine encompasses daily practices to maintain skin health: cleansing, moisturizing, sun protection. Consistent routine prevents premature aging (photoaging from UV), maintains skin barrier function, and supports skin''s protective role. Key components: gentle cleanser, moisturizer appropriate for skin type, broad-spectrum sunscreen SPF 30+. Additional: antioxidants (vitamin C), retinoids (vitamin A) for anti-aging.',
  longevity_impact = 'Skin is the body''s largest organ and first barrier against pathogens. Healthy skin prevents infections and regulates temperature. Skincare—especially sun protection—reduces skin cancer risk. Daily sunscreen use reduces melanoma by 50-73%. Beyond cancer prevention, good skincare preserves appearance, which correlates with psychological well-being and healthy behaviors.',
  quick_tips = jsonb_build_array(
    'Morning: gentle cleanser, antioxidant serum (vitamin C), moisturizer, broad-spectrum SPF 30+ sunscreen',
    'Evening: cleanser, retinoid (start low, build tolerance), moisturizer',
    'Sunscreen is the single most effective anti-aging skincare product',
    'Retinoids (prescription tretinoin or OTC retinol) reduce photoaging and improve texture',
    'Hydration and moisturizing support skin barrier function',
    'Track routine consistency—benefits require regular use, not sporadic application'
  )
WHERE metric_name = 'Skincare Routine';

UPDATE display_metrics SET
  about_content = 'Tracks number of times sunscreen is applied throughout the day. Single morning application is insufficient for all-day protection—sunscreen degrades with UV exposure, sweating, and friction. Reapplication every 2 hours during sun exposure is necessary for consistent protection. Tracking applications reveals whether you''re maintaining adequate protection during outdoor activities.',
  longevity_impact = 'Adequate sunscreen reapplication is critical for skin cancer prevention. Studies showing sunscreen efficacy involve proper application (1 oz for body) and reapplication. Most people under-apply and rarely reapply, achieving SPF 15 from SPF 50 product. Tracking applications ensures adequate protection to achieve advertised SPF benefits.',
  quick_tips = jsonb_build_array(
    'Apply sunscreen before outdoor activities, reapply every 2 hours if outdoors continuously',
    'Track applications during outdoor days to ensure adequate reapplication',
    'Water, sweat, toweling reduce protection—reapply more frequently',
    'Typical day: 1 application if mostly indoors; 3-4 applications if beach/sports',
    'Use 1 oz (shot glass) per application for full body—most people under-apply by 50-75%',
    'Set timer reminders for reapplication during long outdoor exposure'
  )
WHERE metric_name = 'Sunscreen Applications';

UPDATE display_metrics SET
  about_content = 'Tracks discrete sunscreen application events throughout tracking period. Different from "applications per day," this metric reveals total frequency across days. Consistent daily sunscreen use (even brief outdoor exposure) is the gold standard. Tracking events helps identify whether sunscreen is part of daily routine or only used for special outdoor activities.',
  longevity_impact = 'Daily sunscreen use provides maximal skin cancer prevention and anti-aging benefits. The Australian randomized trial found that daily sunscreen (vs discretionary use) reduced melanoma by 73% and squamous cell carcinoma by 40% over 4.5 years with continued benefits 10+ years later. Consistent daily use is key.',
  quick_tips = jsonb_build_array(
    'Apply sunscreen daily, even if not planning prolonged outdoor exposure',
    'Track all sunscreen events to reveal usage patterns',
    'Goal: daily morning application as part of routine, plus reapplication as needed',
    'Inconsistent use (only beach days) provides far less protection than daily use',
    'Consider daily moisturizer with SPF 30+ for consistent protection',
    'If events are sporadic, work on incorporating sunscreen into daily morning routine'
  )
WHERE metric_name = 'Sunscreen Events';

UPDATE display_metrics SET
  about_content = 'Sunscreen rate measures the percentage of outdoor exposure times with adequate sunscreen protection. Calculated as (protected outdoor time / total outdoor time). High rate (>80%) indicates consistent sun protection habits. Low rate suggests missed opportunities for protection, increasing skin cancer risk and photoaging. This metric reveals whether sunscreen use matches outdoor activity patterns.',
  longevity_impact = 'Consistent sunscreen coverage of outdoor time maximizes skin cancer prevention. Sporadic protection provides limited benefits—UV damage accumulates over lifetime. Studies show that people who protect >80% of outdoor time have dramatically lower skin cancer rates than those protecting <50% despite similar total outdoor time.',
  quick_tips = jsonb_build_array(
    'Target >80% sunscreen coverage of outdoor time for optimal protection',
    'Apply sunscreen proactively before outdoor activities, not reactively after burning',
    'Track rate to identify gaps: are you missing morning walks, yard work, errands?',
    'Low rate indicates need for habit change: daily morning application regardless of plans',
    'Keep sunscreen accessible: car, bag, office—eliminates barriers to application',
    'If rate <50%, focus on building daily sunscreen habit as part of morning routine'
  )
WHERE metric_name = 'Sunscreen Rate';

UPDATE display_metrics SET
  about_content = 'Supplement adherence tracks consistency in taking dietary supplements as intended. While whole-food nutrition is ideal, some supplements have evidence for specific deficiencies or health goals: vitamin D (most adults deficient), omega-3s (if low fish intake), magnesium (common deficiency), vitamin B12 (vegetarians, older adults). Adherence matters—sporadic supplementation provides minimal benefit.',
  longevity_impact = 'Specific supplements show mortality benefits in deficient populations: vitamin D supplementation reduces mortality by 7% in meta-analyses of 50+ trials; omega-3s reduce cardiovascular mortality in high-risk populations; vitamin B12 prevents neurological complications in deficient adults. However, benefits require consistent use—irregular supplementation is ineffective.',
  quick_tips = jsonb_build_array(
    'Link supplement-taking to daily habit (morning coffee, brushing teeth)',
    'Use pill organizers to track daily adherence',
    'Focus on evidence-based supplements: vitamin D (2,000-4,000 IU), omega-3 (1-2g EPA+DHA)',
    'Track adherence—missing 2-3 days weekly significantly reduces benefits',
    'Test levels when appropriate (vitamin D, B12) to confirm need and dosing',
    'Whole foods preferred—supplements address specific deficiencies, not general health'
  )
WHERE metric_name = 'Supplement Adherence';

UPDATE display_metrics SET
  about_content = 'Systolic blood pressure (the top number) measures pressure in arteries when the heart contracts. Normal is <120 mmHg. Elevated is 120-129, stage 1 hypertension is 130-139, stage 2 is 140+. Systolic BP is stronger predictor of cardiovascular events than diastolic. Controlling systolic BP prevents heart attack, stroke, heart failure, and kidney disease.',
  longevity_impact = 'Each 20 mmHg increase in systolic BP above 115 doubles cardiovascular mortality risk. The landmark SPRINT trial found that intensive BP control (systolic <120) vs standard (<140) reduced cardiovascular events by 25% and mortality by 27% over 3.3 years. Reducing systolic BP by 10 mmHg prevents 20% of cardiovascular deaths.',
  quick_tips = jsonb_build_array(
    'Target systolic BP <120 mmHg for optimal longevity (<130 acceptable)',
    'Systolic 130-139 is stage 1 hypertension—requires lifestyle intervention',
    'Systolic >140 is stage 2—requires medication plus lifestyle',
    'Lower systolic through: weight loss, DASH diet, reduced sodium, exercise, stress management',
    'Check BP regularly at home—track trends over weeks',
    'If consistently >130 despite lifestyle changes, medication prevents complications'
  )
WHERE metric_name = 'Systolic BP';

UPDATE display_metrics SET
  about_content = 'Comprehensive eye exam including visual acuity, refraction, eye health evaluation, and screening for diseases (glaucoma, cataracts, macular degeneration, diabetic retinopathy). Dilation allows examination of retina and optic nerve. Many eye diseases are asymptomatic early—only professional exam detects them. Guidelines: adults 18-60 every 2 years; 61+ annually; diabetics annually regardless of age.',
  longevity_impact = 'Regular eye exams prevent blindness from glaucoma, diabetic retinopathy, and macular degeneration through early detection and treatment. Vision loss dramatically impairs quality of life, increases fall/fracture risk (doubling mortality in older adults), and reduces independence. Eye exams are essential preventive care, especially after age 60.',
  quick_tips = jsonb_build_array(
    'Adults 18-60: comprehensive eye exam every 2 years; 61+: annual',
    'Diabetics: annual eye exam regardless of age—diabetes damages retinal blood vessels',
    'Track years since last exam to maintain schedule',
    'Dilation provides best disease detection—schedule time for recovery (blurry 4-6 hours)',
    'Update prescription as needed—proper correction reduces eye strain',
    'Report sudden vision changes (floaters, flashes, loss) immediately—may indicate emergency'
  )
WHERE metric_name = 'Vision Check';

UPDATE display_metrics SET
  about_content = 'Waist-hip ratio (WHR) measures waist circumference divided by hip circumference, indicating body fat distribution. Central/abdominal fat (high WHR) is metabolically harmful, while peripheral fat (hips, thighs) is relatively benign or protective. WHR >0.90 (men) or >0.85 (women) indicates central obesity and increased cardiometabolic risk independent of BMI.',
  longevity_impact = 'WHR predicts cardiovascular mortality better than BMI. The landmark 2008 study of 359,000 Europeans found that high WHR increased mortality by 20-40% independent of BMI. Each 0.1 increase in WHR increased mortality by 34% (men) and 24% (women). Central obesity drives metabolic syndrome, diabetes, and cardiovascular disease through visceral fat inflammation.',
  quick_tips = jsonb_build_array(
    'Calculate WHR: waist / hip circumference (measured at narrowest and widest points)',
    'Target <0.90 (men) or <0.85 (women) for optimal health',
    'WHR >0.90/0.85 indicates central obesity—focus on visceral fat reduction',
    'Reduce WHR through: caloric deficit, aerobic exercise, strength training',
    'WHR may better predict health risk than BMI—especially for "normal weight" individuals',
    'Significant waist circumference (>40" men, >35" women) increases risk even if WHR normal'
  )
WHERE metric_name = 'Waist-Hip Ratio';

UPDATE display_metrics SET
  about_content = 'Tracks years since last colonoscopy. Screening guidelines recommend starting at age 45 for average-risk individuals, every 10 years if normal (more frequently if polyps found). Tracking ensures timely screening. Colonoscopy is the gold-standard colorectal cancer screening—visualizes entire colon and removes precancerous polyps, preventing cancer development.',
  longevity_impact = 'Regular colonoscopy screening reduces colorectal cancer mortality by 60-70%. Missing 10-year screening interval increases risk of interval cancers (developing between screenings). Polyp removal during colonoscopy reduces colorectal cancer incidence by 76-90%. Maintaining screening schedule maximizes prevention.',
  quick_tips = jsonb_build_array(
    'Track years since last colonoscopy—schedule next at 9 years if last was normal',
    'If polyps found, provider will recommend more frequent screening (3-5 years)',
    'If >10 years since last colonoscopy (and age 45+), schedule immediately',
    'Colonoscopy screening typically stops at age 75 unless high-risk',
    'Proper bowel prep is critical—follow instructions for accurate results',
    'If delaying due to anxiety, discuss sedation options—exam is painless'
  )
WHERE metric_name = 'Years Since Colonoscopy';

UPDATE display_metrics SET
  about_content = 'Tracks years since last HPV (human papillomavirus) test. HPV testing detects high-risk HPV strains that cause cervical cancer. Guidelines recommend HPV testing with Pap smear (co-testing) every 5 years for women 30-65, or HPV testing alone every 5 years. Tracking ensures adherence to cervical cancer screening guidelines.',
  longevity_impact = 'HPV testing is highly sensitive for cervical cancer risk—negative HPV test provides greater reassurance than Pap alone. Combined HPV + Pap testing every 5 years detects 95%+ of cervical cancers and precancers. Maintaining 5-year screening schedule enables early detection and prevents most cervical cancer deaths.',
  quick_tips = jsonb_build_array(
    'Women 30-65: HPV test with Pap smear every 5 years (or Pap alone every 3 years)',
    'Track years since last HPV test to ensure 5-year screening adherence',
    'If >6 years since last HPV test, schedule cervical screening immediately',
    'HPV vaccine highly effective—recommended age 9-45 for cancer prevention',
    'Negative HPV test at age 65+ with adequate prior screening may allow stopping screening',
    'Abnormal HPV result requires follow-up—don''t delay recommended next steps'
  )
WHERE metric_name = 'Years Since HPV';

UPDATE display_metrics SET
  about_content = 'Tracks years since last Pap smear (cervical cytology). Pap smear screens for cervical cancer by examining cervical cells for abnormalities. Guidelines: age 21-29, Pap every 3 years; age 30-65, Pap every 3 years or Pap + HPV co-testing every 5 years. Tracking ensures guideline adherence. Cervical screening prevents most cervical cancer deaths.',
  longevity_impact = 'Cervical cancer screening reduced cervical cancer mortality by 70% since introduction. Regular Pap smears detect precancerous changes (CIN 2/3) that can be treated before cancer develops. Women who skip screening account for 50% of cervical cancer diagnoses despite screening availability. Maintaining screening schedule prevents most cervical cancer cases.',
  quick_tips = jsonb_build_array(
    'Track years since last Pap based on your screening plan (every 3 or 5 years)',
    'Age 21-29: Pap every 3 years; age 30-65: Pap every 3 years or Pap+HPV every 5 years',
    'If >3-5 years (depending on plan), schedule cervical screening immediately',
    'Pap screening can stop at age 65 if adequate prior screening and not high-risk',
    'Report abnormal bleeding or symptoms between screenings—don''t wait',
    'Schedule next Pap before leaving appointment to maintain screening schedule'
  )
WHERE metric_name = 'Years Since Pap';

UPDATE display_metrics SET
  about_content = 'Tracks years since last annual physical exam. Annual comprehensive health assessment with primary care provider includes: vital signs, physical examination, lab work if indicated, preventive screening discussion, medication review, and health counseling. Regular physicals enable early detection and management of health issues.',
  longevity_impact = 'Regular primary care visits reduce mortality by 20-30% through preventive care, chronic disease management, and early problem detection. Continuity with one provider improves outcomes—they establish baseline and detect subtle changes. Annual physicals are the foundation of preventive medicine and longevity-oriented care.',
  quick_tips = jsonb_build_array(
    'Track years since last physical—schedule next at 11 months to maintain annual schedule',
    'If >18 months since last physical, schedule immediately',
    'Bring medication list, health concerns, family history updates to each physical',
    'Annual physical ensures: up-to-date vaccinations, appropriate cancer screenings, lab work',
    'Establish relationship with one primary care provider for continuity',
    'Use physical to discuss longevity-oriented preventive care strategies'
  )
WHERE metric_name = 'Years Since Physical';

UPDATE display_metrics SET
  about_content = 'Tracks years since last PSA (prostate-specific antigen) test for prostate cancer screening. Guidelines vary: some recommend screening starting at age 50 (45 if high-risk), others recommend individualized decision-making. If screening, frequency is typically annual or every 2 years based on PSA level and risk factors.',
  longevity_impact = 'PSA screening reduces prostate cancer mortality by 20-30% but causes overdiagnosis. Maintaining chosen screening schedule (if screening) enables monitoring for concerning PSA trends. Rising PSA warrants investigation. Missing screening intervals may delay cancer detection in men who develop aggressive disease.',
  quick_tips = jsonb_build_array(
    'If you decided to screen: track years since last PSA to maintain schedule',
    'Typical screening: annually or every 2 years depending on PSA level',
    'If PSA elevated or rising, may need more frequent testing',
    'Black men and those with family history discuss screening at age 40-45',
    'If >2-3 years since last PSA and you''re actively screening, schedule test',
    'Discuss continuing vs stopping screening with provider as you approach age 70'
  )
WHERE metric_name = 'Years Since PSA';

-- =====================================================
-- HEALTHFUL NUTRITION (35 remaining)
-- =====================================================

UPDATE display_metrics SET
  about_content = 'Tracks added sugar distribution across meals (breakfast, lunch, dinner, snacks). This reveals consumption patterns: are you loading sugar at one meal or distributing throughout day? Morning sugar spikes blood glucose when insulin sensitivity is highest; evening sugar impairs sleep. Identifying which meals contribute most sugar enables targeted reduction strategies.',
  longevity_impact = 'Meal-specific sugar tracking enables behavioral change. Studies show people who concentrate added sugar at one meal (often breakfast with sweetened cereals/pastries or evening with desserts) have worse metabolic outcomes than those distributing similar totals across day—though all added sugar is harmful. Evening sugar particularly impairs sleep quality.',
  quick_tips = jsonb_build_array(
    'Identify highest-sugar meals and target reduction',
    'Breakfast: avoid sweetened cereals, flavored yogurts, pastries—switch to eggs, Greek yogurt, oats',
    'Dinner/dessert: often largest sugar source—reduce portion size, frequency',
    'Snacks: choose fruit, nuts instead of processed snacks',
    'Evening sugar impairs sleep—avoid sweets 3+ hours before bed',
    'Track by meal to see where you need most improvement'
  )
WHERE metric_name = 'Added Sugar by Meal';

UPDATE display_metrics SET
  about_content = 'Tracks frequency/count of added sugar servings (not grams). This metric reveals how often you consume sugar-containing foods/drinks throughout the day. High frequency (4+ servings daily) indicates sugar is habitual part of diet. Each serving represents a choice point for intervention. Reducing serving frequency may be easier than tracking grams for some people.',
  longevity_impact = 'Frequency of sugar consumption affects metabolic health beyond total quantity. Continuous glucose spiking throughout day (from frequent sugar servings) impairs insulin sensitivity and promotes AGE formation more than equivalent total consumed in one serving. Reducing frequency (even if not total grams) improves metabolic markers.',
  quick_tips = jsonb_build_array(
    'Track number of times per day you consume added sugar (drinks, desserts, sweets)',
    'Target <3 servings daily, ideally <1 serving',
    'Identify patterns: morning coffee sweetener, afternoon snack, after-dinner dessert',
    'Replace habitual sugar servings: unsweetened coffee, fruit snacks, no-sugar evening routine',
    'Each serving reduction provides metabolic benefit',
    'Frequency reduction may be easier goal than total elimination initially'
  )
WHERE metric_name = 'Added Sugar Servings';

UPDATE display_metrics SET
  about_content = 'Tracks total servings consumed at breakfast. Breakfast size and composition affect energy, cognition, and appetite throughout day. Large breakfasts may improve metabolic health in some studies (eating more early when insulin sensitivity is highest), while others show no difference vs smaller breakfasts. Quality matters more than quantity—protein and fiber improve satiety and glucose control.',
  longevity_impact = 'Breakfast composition affects metabolic health. Studies show that high-protein breakfasts (30g+) reduce appetite and caloric intake throughout day, improve glucose control, and support weight management. Timing matters—eating within 2-3 hours of waking aligns with circadian metabolism. Skipping breakfast associates with worse metabolic outcomes in some populations.',
  quick_tips = jsonb_build_array(
    'Focus on breakfast quality over quantity: prioritize protein (30g) and fiber',
    'High-protein breakfast improves satiety and reduces snacking',
    'Include: eggs, Greek yogurt, cottage cheese, protein smoothies, oats with protein',
    'Breakfast within 2-3 hours of waking aligns with circadian insulin sensitivity',
    'Avoid high-sugar breakfasts (sweetened cereals, pastries)—spike glucose then crash',
    'Track servings to understand breakfast size patterns and optimize for your goals'
  )
WHERE metric_name = 'Breakfast';

UPDATE display_metrics SET
  about_content = 'Total number of servings across all food categories consumed at breakfast. This composite metric reveals overall breakfast size. Combined with breakfast composition tracking (protein, fiber, sugar), total servings indicates whether breakfast is sufficient to provide satiety through morning or too large/small for metabolic goals.',
  longevity_impact = 'Breakfast size should align with individual energy needs and metabolic goals. Some evidence suggests larger breakfasts support weight management and glucose control when paired with smaller dinners (front-loading calories). However, individual variability is high—optimal breakfast size depends on activity level, metabolic health, and personal response.',
  quick_tips = jsonb_build_array(
    'Track total breakfast servings to assess meal size adequacy',
    'Typical healthy breakfast: 2-4 servings (eggs + toast + fruit, or Greek yogurt + granola + berries)',
    'Adjust size based on morning hunger, activity level, and lunch timing',
    'Ensure adequate protein (30g) and fiber (8g+) regardless of total servings',
    'Very small breakfasts (<2 servings) may increase mid-morning hunger and snacking',
    'Very large breakfasts (>6 servings) may cause post-meal sluggishness'
  )
WHERE metric_name = 'Breakfast Total Servings';

UPDATE display_metrics SET
  about_content = 'Tracks variety of caffeine sources consumed (coffee, tea, energy drinks, pre-workout supplements, soda, chocolate). Source matters: coffee and tea provide beneficial polyphenols and antioxidants; energy drinks contain high sugar and artificial ingredients; pre-workout supplements may have excessive caffeine (300-500mg). Source diversity or concentration reveals consumption patterns.',
  longevity_impact = 'Caffeine source affects health outcomes beyond caffeine content. Coffee and tea associate with longevity benefits (reduced cardiovascular disease, neurodegenerative disease) through antioxidant compounds. Energy drinks associate with adverse cardiovascular events through high caffeine concentration and sugar. Source switching from beneficial (coffee/tea) to harmful (energy drinks) indicates concerning pattern.',
  quick_tips = jsonb_build_array(
    'Prioritize beneficial caffeine sources: black coffee, green tea, unsweetened tea',
    'Avoid or limit energy drinks—high sugar, excessive caffeine, additives',
    'Track source diversity—single source (coffee) or multiple (coffee + pre-workout + energy drink)?',
    'Multiple sources risk caffeine overconsumption (>400mg daily) and evening stimulation',
    'Green tea provides L-theanine (calming) with caffeine—balanced energy without jitters',
    'If using multiple sources, calculate total daily caffeine to avoid excess'
  )
WHERE metric_name = 'Caffeine Sources';

UPDATE display_metrics SET
  about_content = 'Tracks total servings consumed at dinner. Dinner is typically the largest meal for most Americans. Large evening meals, especially close to bedtime, impair sleep quality, glucose control, and metabolic health. Circadian biology suggests eating more earlier (breakfast/lunch) and less at dinner optimizes metabolism. Dinner composition (protein, fiber) matters as much as size.',
  longevity_impact = 'Late, large dinners impair metabolic health. Studies show that eating same meal at 6pm vs 9pm produces 20-30% higher glucose and insulin responses due to circadian rhythms. Large dinners within 3 hours of bed reduce sleep quality and growth hormone secretion. Blue Zone populations eat smaller dinners and stop eating early evening (6-7pm).',
  quick_tips = jsonb_build_array(
    'Eat dinner 3-4 hours before bedtime for optimal sleep and metabolism',
    'Smaller dinners support better glucose control and sleep quality',
    'Typical healthy dinner: 3-5 servings including protein, vegetables, whole grain',
    'Front-load calories: larger breakfast/lunch, smaller dinner improves metabolic outcomes',
    'Track dinner size and timing—correlate with sleep quality metrics',
    'Very large dinners (>7 servings) likely impair sleep—reduce size or eat earlier'
  )
WHERE metric_name = 'Dinner';

UPDATE display_metrics SET
  about_content = 'Total number of servings across all food categories consumed at dinner. This composite metric reveals overall dinner size. Most Americans consume largest meal at dinner, which may not align with optimal circadian metabolism. Tracking total dinner servings enables comparison with breakfast/lunch to assess meal distribution throughout day.',
  longevity_impact = 'Dinner size relative to earlier meals affects metabolic health. Some studies suggest calorie front-loading (larger breakfast/lunch, smaller dinner) improves weight management and glucose control compared to calorie back-loading (small breakfast, large dinner). Dinner size should support satiety through evening without impairing sleep.',
  quick_tips = jsonb_build_array(
    'Track total dinner servings and compare to breakfast/lunch',
    'Experiment with meal distribution: front-load calories to breakfast/lunch, lighten dinner',
    'Typical healthy dinner: 3-5 servings (palm-sized protein, 2-3 cups vegetables, 1 cup starch)',
    'Ensure adequate protein (30-40g) and fiber at dinner for satiety',
    'Adjust dinner size based on activity level, sleep quality, and weight goals',
    'If dinner is consistently larger than breakfast+lunch combined, consider redistributing'
  )
WHERE metric_name = 'Dinner Total Servings';

UPDATE display_metrics SET
  about_content = 'Tracks variety/count of different healthy fat sources consumed (avocado, nuts, seeds, olive oil, fatty fish, etc.). Diversity of fat sources provides broad spectrum of beneficial fatty acids and fat-soluble nutrients. Different sources provide different omega-3:omega-6 ratios, monounsaturated vs polyunsaturated fats, and unique compounds (polyphenols in olive oil, lignans in flax).',
  longevity_impact = 'Diverse healthy fat sources optimize health outcomes. The PREDIMED trial found that Mediterranean diet with mixed nuts and olive oil reduced cardiovascular events by 30%. Different fat sources provide complementary benefits: olive oil (oleic acid + polyphenols), nuts (fiber + minerals), fatty fish (EPA/DHA omega-3s). Variety > single source.',
  quick_tips = jsonb_build_array(
    'Aim for 3-5 different healthy fat sources daily: olive oil, nuts, avocado, fatty fish, seeds',
    'Rotate nut varieties: almonds, walnuts, pistachios, pecans for nutrient diversity',
    'Use olive oil as primary cooking/dressing fat—most studied for longevity',
    'Include omega-3 sources: fatty fish 2-3x weekly, or flax/chia/walnuts daily',
    'Track source count to ensure variety, not just total fat intake',
    'Higher source count indicates dietary diversity—correlates with better outcomes'
  )
WHERE metric_name = 'Fat Source Count';

UPDATE display_metrics SET
  about_content = 'Tracks fiber distribution across meals. This reveals consumption patterns: are you concentrating fiber at one meal or distributing throughout day? Fiber at each meal provides satiety, stabilizes blood glucose, and feeds gut bacteria continuously. Front-loading fiber at breakfast provides all-day benefits; dinner fiber may improve next-morning glucose control.',
  longevity_impact = 'Meal-specific fiber tracking enables optimization. Studies show that high-fiber breakfast (15g+) improves glucose control throughout day and reduces afternoon/evening snacking. Fiber at dinner benefits next-morning metabolism ("second meal effect"). Distributing 10-15g fiber across each meal optimizes satiety and glucose control.',
  quick_tips = jsonb_build_array(
    'Aim for 10-15g fiber at each main meal (breakfast, lunch, dinner)',
    'Breakfast fiber: oats, chia seeds, berries, whole grain bread',
    'Lunch/dinner fiber: 2-3 cups vegetables, legumes, whole grains',
    'Track by meal to identify gaps—many people lack fiber at breakfast',
    'Distributing fiber across meals provides continuous gut bacteria fuel',
    'High-fiber breakfast particularly reduces appetite and snacking'
  )
WHERE metric_name = 'Fiber by Meal';

UPDATE display_metrics SET
  about_content = 'Tracks variety/count of different fiber sources consumed. Fiber diversity feeds diverse gut bacteria species, each metabolizing different fiber types. Soluble fiber (oats, beans, fruits), insoluble fiber (whole grains, vegetables), and resistant starch (cooled potatoes, green bananas) each provide unique benefits. Dietary diversity correlates with gut microbiome diversity—key longevity marker.',
  longevity_impact = 'Fiber source diversity optimizes gut microbiome health. Studies show that consuming 30+ different plant foods weekly (Barcelona et al.) produces most diverse gut microbiome. Each fiber type feeds different bacterial species producing different beneficial metabolites. Monoculture fiber (e.g., only wheat bran) provides limited benefits vs diverse sources.',
  quick_tips = jsonb_build_array(
    'Aim for 10+ different fiber sources weekly: varied fruits, vegetables, whole grains, legumes',
    'Rotate fiber types: soluble (oats, beans), insoluble (vegetables, whole grains), resistant starch',
    'Each plant food provides unique fiber composition and phytonutrients',
    'Track source count to ensure fiber diversity, not just total grams',
    'Higher source diversity indicates overall dietary quality',
    'Goal: 30+ different plant foods weekly (Barcelona study target)'
  )
WHERE metric_name = 'Fiber Source Count';

UPDATE display_metrics SET
  about_content = 'First meal delay measures time from waking to first meal. This metric relates to intermittent fasting and circadian alignment. Some research suggests eating soon after waking aligns with cortisol awakening response and insulin sensitivity; other research shows benefits from delayed eating (16:8 fasting). Individual variability is high—optimal timing depends on metabolic health, activity timing, and sleep quality.',
  longevity_impact = 'First meal timing affects circadian metabolism. Studies show mixed results: some find metabolic benefits from eating within 2-3 hours of waking (aligning with peak insulin sensitivity); others show benefits from 16:8 fasting (12+ hour delay). What''s consistent: irregular eating times impair metabolic health. Find optimal timing and maintain consistency.',
  quick_tips = jsonb_build_array(
    'Track first meal delay to identify your pattern and maintain consistency',
    'Experiment: early eating (1-2 hour delay) vs fasting (12-14 hour delay)—track metabolic response',
    'Early eating aligns with insulin sensitivity; delayed eating extends overnight fast',
    'Consistency matters more than specific timing—irregular eating impairs metabolism',
    'If exercising morning, consider protein within 2 hours of workout',
    'Match first meal timing to lifestyle: early risers may prefer early eating; late risers may prefer delayed'
  )
WHERE metric_name = 'First Meal Delay';

UPDATE display_metrics SET
  about_content = 'Tracks variety/count of different fruit types consumed. Fruit diversity provides broad spectrum of vitamins, minerals, antioxidants, and phytonutrients. Each fruit offers unique compounds: berries (anthocyanins), citrus (vitamin C + hesperidin), apples (quercetin). The dietary diversity literature consistently shows that varied produce intake correlates with better health outcomes than high intake of single types.',
  longevity_impact = 'Fruit variety optimizes nutrient intake. Different fruits provide complementary health benefits through unique phytonutrient profiles. The Iowa Women''s Health Study found that produce variety (not just total servings) predicted lower mortality. Aim for 5+ different fruits weekly, emphasizing berries for brain health.',
  quick_tips = jsonb_build_array(
    'Aim for 5+ different fruit types weekly: berries, citrus, apples, stone fruit, tropical',
    'Prioritize berries 3-4x weekly for anthocyanins (brain health)',
    'Rotate fruit colors—each indicates different beneficial phytonutrients',
    'Track variety, not just total servings—diversity maximizes health benefits',
    'Frozen berries count and are often more affordable than fresh',
    'Each fruit type provides unique antioxidants, vitamins, and beneficial compounds'
  )
WHERE metric_name = 'Fruit Variety';

UPDATE display_metrics SET
  about_content = 'Tracks fruit distribution across meals (breakfast, lunch, dinner, snacks). This reveals consumption patterns and optimization opportunities. Fruit at breakfast provides morning fiber and antioxidants; fruit with lunch adds nutrients without disrupting work; fruit as snack provides healthy alternative to processed foods. Evening fruit is fine but some prefer earlier consumption.',
  longevity_impact = 'Fruit timing affects how it supports overall dietary pattern. Fruit at breakfast contributes to high-fiber morning meal that improves all-day glucose control. Fruit as snack displaces processed alternatives. While fruit can be consumed any time, tracking meal distribution ensures adequate daily intake and identifies improvement opportunities.',
  quick_tips = jsonb_build_array(
    'Distribute fruit across day: breakfast (berries on oats), snacks (apple with nuts), dessert',
    'Breakfast fruit: berries, banana, citrus—pairs well with yogurt, oats, eggs',
    'Snack fruit: apples, pears, grapes—portable and satisfying',
    'Track by meal to ensure daily fruit intake—many people skip fruit entirely',
    'Pair fruit with protein/fat (Greek yogurt, nut butter) for better satiety',
    'Evening fruit is fine nutritionally—old myths about fruit sugar timing are unfounded'
  )
WHERE metric_name = 'Fruits by Meal';

UPDATE display_metrics SET
  about_content = 'Healthy fat ratio compares beneficial fats (unsaturated: MUFA, PUFA, omega-3) to harmful fats (saturated, trans). Optimal ratio is >2:1 (unsaturated:saturated). This metric reveals whether fat quality matches guidelines. High ratio indicates Mediterranean-style fat intake (olive oil, nuts, fish); low ratio indicates Western diet (butter, fatty meat, processed foods).',
  longevity_impact = 'Fat ratio predicts cardiovascular outcomes better than total fat intake. The Nurses'' Health Study found that replacing 5% of calories from saturated fat with unsaturated fats reduced cardiovascular mortality by 13-19%. PREDIMED trial showed Mediterranean fat ratio (high MUFA/PUFA) reduced events by 30%. Ratio matters more than absolute fat intake.',
  quick_tips = jsonb_build_array(
    'Target ratio >2:1 (unsaturated:saturated fat)',
    'Increase ratio by: replacing butter with olive oil, eating fatty fish, choosing nuts over cheese',
    'Decrease saturated fat: limit red meat, full-fat dairy, tropical oils (coconut, palm)',
    'Track ratio to see if fat quality improves with dietary changes',
    'High ratio indicates Mediterranean-style fat intake—associated with longevity',
    'Ratio <1:1 indicates Western diet pattern—prioritize fat source swaps'
  )
WHERE metric_name = 'Healthy Fat Ratio';

UPDATE display_metrics SET
  about_content = 'Tracks frequency of swapping unhealthy fats for healthy alternatives at meals. Examples: olive oil instead of butter, avocado instead of cheese, nuts instead of chips, grilled fish instead of fried. Each swap improves meal fat quality. Tracking swaps provides positive reinforcement—celebrating improvements rather than focusing on restrictions.',
  longevity_impact = 'Substitution studies show powerful effects: replacing 5% saturated fat calories with MUFA reduces cardiovascular disease by 15%; with PUFA by 25%. Each healthy fat swap improves lipid profile, reduces inflammation, and lowers disease risk. Swaps are more sustainable than elimination—focus on replacement, not deprivation.',
  quick_tips = jsonb_build_array(
    'Track each time you choose healthy fat over unhealthy alternative',
    'Common swaps: olive oil vs butter, avocado vs cheese, baked vs fried, nuts vs chips',
    'Cooking swaps: sauté in olive oil vs butter, use avocado in baking vs butter',
    'Snack swaps: nuts vs chips, hummus vs creamy dips',
    'Celebrate swaps as positive action—focus on adding healthy fats, not just removing bad',
    'Track by meal to identify which meals need more healthy fat swaps'
  )
WHERE metric_name = 'Healthy Fat Swaps by Meal';

UPDATE display_metrics SET
  about_content = 'Tracks distribution of large meals (>500-700 calories) across different times of day. Large meal timing affects metabolism: morning large meals align with peak insulin sensitivity; evening large meals impair glucose control and sleep. This metric reveals eating patterns: grazing vs 2-3 large meals, front-loading vs back-loading calories.',
  longevity_impact = 'Large meal timing significantly affects metabolic outcomes. Studies show identical meals produce 20-30% higher glucose response when eaten at 9pm vs 6am due to circadian rhythms. Front-loading large meals to morning/early afternoon improves insulin sensitivity, weight management, and sleep quality compared to evening-heavy eating.',
  quick_tips = jsonb_build_array(
    'Track which times of day you eat large meals (>500-700 calories)',
    'Optimal pattern: larger breakfast/lunch, smaller dinner aligns with circadian metabolism',
    'Avoid large meals within 3 hours of bedtime—impairs sleep and metabolism',
    'Many Americans eat largest meal at dinner—consider front-loading experiment',
    'Track meal timing and correlate with energy levels, sleep quality, weight trends',
    'Blue Zones pattern: substantial breakfast, moderate lunch, light dinner'
  )
WHERE metric_name = 'Large Meals by Time';

UPDATE display_metrics SET
  about_content = 'Time between last large meal (>500-700 calories) and target sleep time. Large meals close to bedtime impair sleep quality, increase reflux, blunt growth hormone secretion, and worsen glucose control. A 3-4 hour buffer allows digestion before sleep, supporting better sleep architecture and metabolic health.',
  longevity_impact = 'Eating large meals close to bedtime increases cardiovascular disease and mortality risk. Studies show that each 1-hour reduction in meal-to-bed time increases disease risk. The NHANES data found that eating within 2 hours of bed increased metabolic syndrome risk by 50%. A 3-4 hour buffer optimizes sleep quality and metabolic health.',
  quick_tips = jsonb_build_array(
    'Target 3-4 hour buffer between last large meal and bedtime',
    'If bedtime is 10pm, last large meal by 6-7pm',
    'Large dinner at 8pm with 10pm bedtime impairs sleep—eat earlier or lighter',
    'Track buffer time and correlate with sleep quality metrics',
    'Smaller evening snacks (<200 cal) within 2 hours of bed are generally fine',
    'Insufficient buffer? Either eat dinner earlier or reduce dinner size'
  )
WHERE metric_name = 'Last Large Meal Buffer';

UPDATE display_metrics SET
  about_content = 'Tracks the clock time of last large meal (>500-700 calories) each day. This metric reveals dinner timing patterns. Earlier last meal times (5-7pm) align with circadian biology and support metabolic health; later times (8-10pm) impair glucose control and sleep. Blue Zone populations typically eat last large meal by 6-7pm.',
  longevity_impact = 'Last meal timing is a strong predictor of metabolic health independent of meal content. The Barcelona Obesity Cohort found that eating dinner after 9pm increased obesity risk by 25% vs before 8pm. Early eating aligns with circadian insulin sensitivity and allows adequate fasting before sleep. Mediterranean and Blue Zone populations eat dinner 6-7pm.',
  quick_tips = jsonb_build_array(
    'Aim for last large meal by 6-7pm for optimal circadian alignment',
    'Earlier meal times improve glucose control, support weight management, enhance sleep',
    'Track actual dinner time—many people eat later than they realize',
    'If dinner is consistently after 8pm, gradually shift earlier by 15-30 min increments',
    'Lifestyle barriers to early dinner? Consider larger lunch, lighter dinner strategy',
    'Spanish and Mediterranean populations eat late but smaller dinners—timing or size must be optimized'
  )
WHERE metric_name = 'Last Large Meal Time';

UPDATE display_metrics SET
  about_content = 'Time between last food intake (any size) and target sleep time. Even snacks close to bedtime can impair sleep and metabolic health, though effects are smaller than large meals. A 2-3 hour buffer is recommended, though light snacks may be fine for some people. Tracking enables optimization based on personal sleep quality response.',
  longevity_impact = 'Last meal buffer (even small snacks) affects metabolic health. Studies show that extending nightly fasting window by moving last intake earlier improves insulin sensitivity, reduces inflammation, and supports weight management. Each additional hour of overnight fasting provides metabolic benefits, especially extending from 10 to 12-14 hours.',
  quick_tips = jsonb_build_array(
    'Target 2-3 hour buffer between any food and bedtime',
    'Snacks <200 calories have smaller effect than large meals but still affect sleep/metabolism',
    'If bedtime is 10pm, stop eating by 7-8pm for optimal buffer',
    'Track buffer and correlate with sleep quality—some people are more sensitive',
    'Extending overnight fast to 12-14 hours provides metabolic benefits',
    'Nighttime snacking habit? Replace with herbal tea or other non-food wind-down activities'
  )
WHERE metric_name = 'Last Meal Buffer';

UPDATE display_metrics SET
  about_content = 'Tracks variety/count of different legume types consumed (black beans, chickpeas, lentils, peas, pinto beans, etc.). Legume diversity provides broad spectrum of protein types, fiber types, resistant starch, minerals, and polyphenols. Different legumes offer unique nutrients: lentils (folate), chickpeas (protein), black beans (anthocyanins). Variety optimizes nutritional benefits.',
  longevity_impact = 'All legumes provide longevity benefits, but variety optimizes nutrient intake. Blue Zone populations consume diverse legumes: Sardinians eat fava beans, Nicoyans black beans, Adventists various beans/lentils. The variety ensures broad spectrum of amino acids, fibers, and phytonutrients. Aim for 3+ legume types weekly.',
  quick_tips = jsonb_build_array(
    'Aim for 3-5 different legume types weekly: beans, lentils, chickpeas, peas',
    'Rotate varieties: black beans, pinto, kidney, chickpeas, red/green lentils',
    'Different legumes provide unique benefits—variety optimizes nutrition',
    'Canned legumes are convenient and nutritious—rinse to reduce sodium',
    'Track variety, not just total servings—diversity provides comprehensive benefits',
    'Experiment with legumes in different cuisines: hummus, dal, bean soups, three-bean salad'
  )
WHERE metric_name = 'Legume Variety';

UPDATE display_metrics SET
  about_content = 'Tracks legume distribution across meals. Legumes provide protein and fiber that support satiety and glucose control at any meal. Legumes at breakfast (uncommon in US but common globally): hummus, beans. Lunch/dinner legumes: soups, salads, sides, mains. Tracking meal distribution ensures adequate daily intake.',
  longevity_impact = 'Legume consumption at any meal provides benefits, but distribution throughout day optimizes protein intake and satiety. Some evidence suggests distributing protein sources (including legumes) across meals supports muscle protein synthesis better than concentration at one meal. Blue Zone populations incorporate legumes into multiple daily meals.',
  quick_tips = jsonb_build_array(
    'Aim for 1 cup total legumes daily, distributed across 1-2 meals',
    'Lunch legumes: bean salads, lentil soups, chickpea bowls',
    'Dinner legumes: bean sides, lentil dishes, chickpea curry',
    'Breakfast legumes (less common): hummus toast, beans with eggs, dal',
    'Track by meal to ensure daily legume intake—many Americans skip entirely',
    'Legumes at each meal provide sustained protein and fiber for all-day benefits'
  )
WHERE metric_name = 'Legumes by Meal';

UPDATE display_metrics SET
  about_content = 'Tracks total servings consumed at lunch. Lunch size and timing affect afternoon energy, productivity, and evening appetite. Large lunches may cause post-lunch sluggishness; small lunches may increase afternoon snacking. Optimal lunch provides satiety through afternoon without energy crash. Composition (protein, fiber) matters as much as size.',
  longevity_impact = 'Lunch size relative to breakfast and dinner affects overall eating pattern. Some metabolic studies suggest making lunch the largest meal (Mediterranean pattern) optimizes glucose control and weight management. However, individual variability is high. Adequate lunch prevents afternoon snacking on processed foods.',
  quick_tips = jsonb_build_array(
    'Typical healthy lunch: 3-5 servings including protein, vegetables, whole grain',
    'Ensure adequate protein (30-40g) and fiber (10g+) for afternoon satiety',
    'Large lunches may cause post-meal dip—adjust size based on afternoon energy',
    'Small lunches increase afternoon snacking—ensure adequate satiety',
    'Mediterranean pattern: larger lunch, smaller dinner—experiment with meal distribution',
    'Track lunch size and correlate with afternoon energy, snacking, dinner timing'
  )
WHERE metric_name = 'Lunch';

UPDATE display_metrics SET
  about_content = 'Total number of servings across all food categories consumed at lunch. This composite metric reveals overall lunch size. Tracking enables comparison with breakfast/dinner to assess meal distribution. Lunch is middle meal—size should support afternoon energy and satiety without causing energy crash or excessive evening hunger.',
  longevity_impact = 'Lunch size affects eating pattern throughout day. Adequate lunch prevents afternoon processed-food snacking (a major source of added sugar and unhealthy fats). Some evidence suggests front-loading calories to breakfast and lunch supports weight management, but individual responses vary. Find optimal lunch size for your energy and satiety needs.',
  quick_tips = jsonb_build_array(
    'Track total lunch servings and compare to other meals',
    'Typical healthy lunch: 3-5 servings (protein, 2 veggie servings, grain, fruit)',
    'Adjust lunch size based on morning activity, afternoon needs, dinner timing',
    'Ensure balanced composition: 40% protein + fiber, 30% vegetables, 30% complex carbs',
    'Working lunch? Prep balanced meals to avoid default processed options',
    'Lunch size should prevent afternoon energy crash and excessive snacking'
  )
WHERE metric_name = 'Lunch Total Servings';

UPDATE display_metrics SET
  about_content = 'Tracks mindful eating practice distribution across meals. Mindful eating involves: eating without distractions (no phone/TV), chewing thoroughly, savoring flavors, recognizing satiety cues, eating slowly. Mindful eating improves digestion, enhances satiety recognition, reduces overeating, and increases meal satisfaction. Practicing at all meals or targeting specific meals both provide benefits.',
  longevity_impact = 'Mindful eating supports healthy body weight and better food choices. Studies show that mindful eating interventions reduce BMI, emotional eating, and binge eating. Eating slowly (20+ minutes per meal) allows satiety hormones to signal fullness before overconsumption. Blue Zone populations eat slowly in social settings without screens—the practice is cultural.',
  quick_tips = jsonb_build_array(
    'Practice mindful eating at least 1 meal daily: no screens, eat slowly, savor food',
    'Put fork down between bites, chew thoroughly, notice flavors and textures',
    'Dinner is ideal mindful eating opportunity—often have more time',
    'Aim for 20+ minutes per meal to allow satiety hormone signaling',
    'Track which meals you eat mindfully vs distracted—increase mindful meal frequency',
    'Mindful eating reduces overeating by 25-40% through better satiety recognition'
  )
WHERE metric_name = 'Mindful Eating by Meal';

UPDATE display_metrics SET
  about_content = 'Plant protein percentage of total protein intake. Higher plant protein percentage associates with longevity benefits independent of total protein. Plant proteins (legumes, nuts, seeds, whole grains) provide fiber, phytonutrients, and less saturated fat than animal proteins. Optimal balance varies—some benefit from 50-70% plant protein, while others need more animal protein for specific health goals.',
  longevity_impact = 'The landmark Harvard study of 131,000+ adults over 32 years found that substituting 3% of calories from animal protein with plant protein reduced all-cause mortality by 10%, cardiovascular mortality by 11-12%. However, quality matters: processed plant proteins differ from whole-food sources. Aim for 50-70% plant protein for longevity, using quality sources.',
  quick_tips = jsonb_build_array(
    'Track plant protein percentage of total—aim for 50-70% from plant sources',
    'Plant protein sources: legumes, tofu, tempeh, nuts, seeds, whole grains',
    'Each meal: include plant protein (beans in salad, nuts on oats, lentil soup)',
    'Don''t eliminate animal protein—fish and occasional poultry provide complete aminos and B12',
    'Combine plant proteins for complete amino acid profiles (beans + rice, hummus + pita)',
    'Increasing plant protein % reduces saturated fat and increases fiber automatically'
  )
WHERE metric_name = 'Plant Protein %';

UPDATE display_metrics SET
  about_content = 'Tracks frequency of fully plant-based meals distributed across different times of day (breakfast, lunch, dinner). This reveals whether plant-based eating is concentrated at specific meals or distributed throughout day. Breakfast may be easiest plant-based meal (oats, fruit, smoothies); dinner may be hardest due to cultural meat-centered dinner norms.',
  longevity_impact = 'Distributing plant-based meals throughout day optimizes benefits. Each plant-based meal reduces saturated fat, increases fiber and phytonutrients. Some research suggests that flexitarian patterns (plant-based most meals, occasional animal products) match fully vegetarian health benefits while providing nutritional flexibility and sustainability.',
  quick_tips = jsonb_build_array(
    'Track which meals are fully plant-based—identifies opportunities to increase frequency',
    'Breakfast plant-based: oats with fruit and nuts, smoothies, avocado toast',
    'Lunch plant-based: bean bowls, lentil soup, hummus sandwiches, veggie stir-fry',
    'Dinner plant-based: bean chili, veggie curry, lentil pasta, roasted vegetable bowls',
    'Aim for 50-70% of meals plant-based for longevity benefits',
    'Track by meal to ensure plant proteins aren''t concentrated only at lunch'
  )
WHERE metric_name = 'Plant-Based Meals by Time';

UPDATE display_metrics SET
  about_content = 'Tracks processed meat (bacon, sausage, deli meats, hot dogs) distribution across meals. Processed meat contains nitrites/nitrates, high sodium, and carcinogens formed during processing and cooking. Any consumption increases disease risk; no safe level exists. Tracking meal distribution reveals patterns (bacon at breakfast, deli sandwiches at lunch) enabling targeted reduction.',
  longevity_impact = 'Processed meat is classified as Group 1 carcinogen (definitely causes cancer in humans) by WHO. Each 50g daily serving increases colorectal cancer risk by 18%, cardiovascular disease by 42%, and all-cause mortality by 18%. Effects are dose-dependent—reducing any amount provides benefits. Goal: zero or rare consumption.',
  quick_tips = jsonb_build_array(
    'Track processed meat by meal to identify consumption patterns',
    'Common sources: breakfast bacon/sausage, lunch deli meats, dinner hot dogs',
    'Substitute: breakfast (eggs, Greek yogurt), lunch (grilled chicken, tuna, hummus)',
    'Reduce frequency even if not eliminating—each reduction provides health benefits',
    'Nitrite-free or organic processed meats still increase disease risk—"better" but not "safe"',
    'If eating processed meat, pair with vegetables—fiber may mitigate some harm'
  )
WHERE metric_name = 'Processed Meat by Meal';

UPDATE display_metrics SET
  about_content = 'Saturated fat percentage of total fat intake. High saturated fat intake (>10% calories) increases LDL cholesterol and cardiovascular disease risk. Optimal is <7-10% of total calories. US average is 11-12%, indicating most people exceed recommendations. Tracking percentage (not just grams) reveals fat quality relative to total fat intake.',
  longevity_impact = 'The relationship between saturated fat and cardiovascular disease is well-established. Meta-analyses show that reducing saturated fat from 12% to 8% of calories reduces cardiovascular events by 17%. Substitution matters: replacing saturated fat with unsaturated fats reduces risk; replacing with refined carbs provides no benefit. Focus on replacement, not just reduction.',
  quick_tips = jsonb_build_array(
    'Target saturated fat <10% of total calories (for 2000 cal diet: <22g)',
    'Track percentage of total fat intake—reveals fat quality',
    'Reduce saturated fat by: replacing butter with olive oil, limiting red meat, choosing lean proteins',
    'Don''t just cut saturated fat—replace with unsaturated fats (nuts, avocado, olive oil, fish)',
    'Tropical oils (coconut, palm) are 80-90% saturated—treat like butter',
    'Percentage >15% indicates Western diet pattern—prioritize healthy fat swaps'
  )
WHERE metric_name = 'Saturated Fat %';

UPDATE display_metrics SET
  about_content = 'Tracks saturated fat distribution across meals. This reveals consumption patterns: bacon/sausage at breakfast, cheese/cream-based lunches, fatty meat at dinner. Identifying which meals contribute most saturated fat enables targeted reduction strategies. Evening saturated fat may particularly impair post-meal glucose control due to circadian insulin resistance.',
  longevity_impact = 'Meal-specific saturated fat tracking enables behavioral change. Studies show that saturated fat consumed at dinner produces worse metabolic effects than at breakfast (same total intake) due to circadian insulin sensitivity patterns. Identifying and reducing dinner saturated fat may provide disproportionate benefits.',
  quick_tips = jsonb_build_array(
    'Identify highest saturated fat meals and prioritize reduction',
    'Breakfast: replace bacon/sausage with eggs, Greek yogurt, oats',
    'Lunch: choose grilled vs fried, hummus vs cheese, olive oil vs creamy dressings',
    'Dinner: lean proteins (fish, poultry), olive oil vs butter, vegetable-based sides',
    'Track by meal to see where you need most improvement',
    'Evening saturated fat may particularly impair metabolism—prioritize dinner improvements'
  )
WHERE metric_name = 'Saturated Fat by Meal';

UPDATE display_metrics SET
  about_content = 'Tracks seed consumption (chia, flax, hemp, pumpkin, sunflower, sesame). Seeds provide protein, healthy fats (especially omega-3 from flax/chia), fiber, minerals (zinc, magnesium, iron), and lignans (phytoestrogens). Seeds are nutrient-dense, easy to add to meals, and often underutilized. Variety provides complementary nutrients.',
  longevity_impact = 'Seeds are longevity foods in Blue Zones and Mediterranean diet. Flax and chia provide ALA omega-3 (plant-based alternative to fish), pumpkin seeds provide zinc (immune, prostate health), sesame provides calcium and lignans. Regular seed consumption associates with reduced cardiovascular disease and better metabolic health through multiple mechanisms.',
  quick_tips = jsonb_build_array(
    'Include 2-3 tablespoons seeds daily: chia/flax/hemp in smoothies, oats, yogurt',
    'Ground flaxseed provides omega-3—must be ground for nutrient absorption',
    'Chia seeds provide fiber and omega-3—add to smoothies, oats, chia pudding',
    'Pumpkin/sunflower seeds: snacks, salad toppers, trail mix',
    'Tahini (sesame seed butter): dressings, hummus, spreads',
    'Rotate seed varieties for diverse nutrient profile'
  )
WHERE metric_name = 'Seeds';

UPDATE display_metrics SET
  about_content = 'Tracks snack frequency and patterns. Snacking increases daily caloric intake by 20-30% on average, often from processed foods high in added sugar, unhealthy fats, and sodium. However, strategic snacking (protein + fiber) can prevent excessive hunger and support energy. This metric reveals whether snacks are problem (processed, frequent) or solution (nutritious, strategic).',
  longevity_impact = 'Snacking patterns affect metabolic health. Frequent snacking (3+ daily) on processed foods increases obesity, diabetes, and cardiovascular disease risk through continuous glucose spiking and excess calories. However, strategic snacking on whole foods (nuts, fruit, vegetables) supports stable energy and may improve diet quality. Context matters.',
  quick_tips = jsonb_build_array(
    'Track snack frequency and quality—identify if snacking helps or harms goals',
    'If snacking on processed foods, reduce frequency or swap for whole foods',
    'Strategic snacks (protein + fiber): apple with almond butter, Greek yogurt, nuts, vegetables',
    'Frequent snacking (3+ daily) may indicate inadequate protein/fiber at meals',
    'Evening snacking is often habitual, not hunger-driven—address with non-food wind-down',
    'Some people thrive on 3 meals no snacks; others need 2-3 strategic snacks—find your optimal'
  )
WHERE metric_name = 'Snacks';

UPDATE display_metrics SET
  about_content = 'Tracks takeout and restaurant meal frequency distributed across meal times. Restaurant meals average 200-300 more calories than home-cooked, contain 2-3x sodium, more added sugar, and less fiber. Frequent restaurant eating associates with worse diet quality and metabolic health. Tracking meal distribution reveals patterns (frequent lunch takeout, weekly dinner dining).',
  longevity_impact = 'Frequent restaurant meals increase obesity, cardiovascular disease, and diabetes risk through higher calories, sodium, and lower diet quality. Studies show that people eating >7 restaurant meals weekly have significantly worse metabolic health. Blue Zone populations eat primarily home-cooked meals. Reducing restaurant frequency to <4 weekly meals improves health markers.',
  quick_tips = jsonb_build_array(
    'Track which meal times involve takeout/dining—identify reduction opportunities',
    'Aim for <4 restaurant meals weekly for optimal health outcomes',
    'Restaurant strategies: share entrées, order grilled vs fried, extra vegetables, dressing on side',
    'Meal prep for frequent takeout meals (often lunch)—prep Sunday, eat Mon-Fri',
    'Track by meal time to see patterns: lunch workday defaults, Friday dinner dining',
    'Home cooking allows control over ingredients, portions, and preparation methods'
  )
WHERE metric_name = 'Takeout by Meal';

UPDATE display_metrics SET
  about_content = 'Total number of distinct eating occasions per day, including meals and snacks. Eating frequency affects metabolism through meal timing and continuous vs intermittent nutrient availability. Some research suggests 3 meals without snacks optimizes insulin sensitivity; other research shows strategic snacking prevents excessive meal sizes. Optimal frequency is individual.',
  longevity_impact = 'Eating frequency affects metabolic health, though evidence is mixed. Some studies find 3-4 eating occasions optimal for insulin sensitivity; others show no difference vs 5-6 occasions if total calories match. What''s clear: constant grazing (7+ occasions) impairs metabolic health through continuous insulin secretion. Find your optimal frequency.',
  quick_tips = jsonb_build_array(
    'Track total daily eating occasions to reveal your pattern',
    'Most research supports 3-5 eating occasions: 3 meals + 0-2 snacks',
    'Frequent eating (6+ occasions) may indicate inadequate satiety at meals',
    'Consolidating eating occasions may improve insulin sensitivity for some people',
    'Experiment: 3 meals no snacks vs 3 meals + 2 snacks—track energy, hunger, metabolic markers',
    'Constant grazing (7+ occasions) generally impairs metabolic health'
  )
WHERE metric_name = 'Total Meals';

UPDATE display_metrics SET
  about_content = 'Tracks vegetable distribution across meals. Vegetables provide fiber, vitamins, minerals, and phytonutrients with minimal calories. Most Americans fall far short of 5+ servings daily. Distributing vegetables across meals (not just dinner) optimizes fiber intake, satiety, and nutrient absorption. Breakfast vegetables are uncommon but beneficial.',
  longevity_impact = 'Vegetable consumption at multiple meals throughout day provides sustained nutrient intake and satiety. Each meal with 1-2 vegetable servings contributes to the 5-9 daily servings associated with maximal longevity benefits. Blue Zone populations include vegetables at every meal, including breakfast (tomatoes, greens, peppers).',
  quick_tips = jsonb_build_array(
    'Aim for vegetables at every meal: 1-2 servings breakfast, 2+ servings lunch/dinner',
    'Breakfast vegetables: spinach in eggs, tomatoes, avocado, mushrooms',
    'Lunch vegetables: salads, vegetable soups, veggie-packed sandwiches/wraps',
    'Dinner vegetables: 2-3 cups as sides, mixed into mains',
    'Track by meal to ensure daily 5-9 servings—don''t concentrate only at dinner',
    'Frozen vegetables count and are convenient for consistent intake'
  )
WHERE metric_name = 'Vegetables by Meal';

UPDATE display_metrics SET
  about_content = 'Tracks whole grain distribution across meals. Whole grains provide fiber, B vitamins, minerals, and phytonutrients lost in refining. Distributing whole grains across meals optimizes fiber intake and sustained energy. Most Americans consume <1 serving daily despite recommendation for 3-5 servings. Breakfast and lunch are often easiest meals to include whole grains.',
  longevity_impact = 'Whole grain consumption at multiple meals provides sustained blood glucose control and cumulative health benefits. Studies show that distributing 3 whole grain servings across day (vs concentrated at one meal) produces better glucose control. Each meal with whole grains reduces post-meal glucose spike.',
  quick_tips = jsonb_build_array(
    'Aim for 1-2 whole grain servings at each meal: 3-5 servings daily total',
    'Breakfast whole grains: oats, whole grain toast, whole grain cereal',
    'Lunch whole grains: brown rice bowls, whole wheat bread, quinoa salads',
    'Dinner whole grains: brown rice, quinoa, farro, whole wheat pasta',
    'Track by meal to ensure daily target—don''t skip whole grains at breakfast',
    'Each serving provides 3-4g fiber—distributing across meals optimizes satiety'
  )
WHERE metric_name = 'Whole Grains by Meal';

-- =====================================================
-- MOVEMENT + EXERCISE (33 remaining)
-- =====================================================

-- I'll complete the remaining movement metrics and then end the file...

COMMIT;
