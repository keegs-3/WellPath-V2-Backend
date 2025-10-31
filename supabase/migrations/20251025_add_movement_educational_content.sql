-- =====================================================
-- Add Educational Content for Exercise/Movement Categories
-- =====================================================
-- PhD-level exercise physiology and longevity research
-- Based on Peter Attia's framework and centenarian studies
-- =====================================================

BEGIN;

-- =====================================================
-- 1. CARDIO / ZONE 2 TRAINING
-- =====================================================

UPDATE display_metrics
SET
  about_content = 'Zone 2 cardio training is exercise performed at an intensity where you can still hold a conversation - typically 60-70% of maximum heart rate or at a pace where nasal breathing is still possible. This intensity maximizes mitochondrial biogenesis (creation of new energy-producing mitochondria), improves metabolic flexibility (ability to switch between burning fat and carbs), and enhances oxygen delivery to tissues. Zone 2 training primarily uses Type I muscle fibers and fat oxidation for fuel, building exceptional aerobic base and endurance capacity. Walking is the most accessible Zone 2 activity and provides additional benefits for blood sugar regulation, cardiovascular health, and stress reduction.',

  longevity_impact = 'VO2 max - the maximum rate of oxygen your body can use during exercise - is the single strongest predictor of all-cause mortality. Each 1 MET increase in VO2 max is associated with 13-15% reduction in mortality risk. Zone 2 training is the primary driver of VO2 max improvement. Studies show those in the top quartile for VO2 max have 5x lower mortality risk than those in the bottom quartile. Regular walking (150+ min/week) reduces all-cause mortality by 20-30%, cardiovascular mortality by 31%, and cancer mortality by 15-20%. Zone 2 cardio also improves glucose disposal, insulin sensitivity, and cognitive function - all key longevity markers.',

  quick_tips = jsonb_build_array(
    'Target 180-200 minutes per week of Zone 2 cardio for optimal longevity benefits',
    'Use "talk test": you should be able to speak in full sentences but not sing',
    'Heart rate zone: roughly (180 - age) beats per minute for most people',
    'Walking counts! 150+ minutes of brisk walking per week provides major benefits',
    'Consistency > intensity: 4-5 sessions per week is better than 1-2 long sessions',
    'Morning fasted Zone 2 enhances fat oxidation and metabolic flexibility',
    'Track VO2 max trends - even small improvements (5-10%) significantly reduce mortality risk'
  ),

  updated_at = NOW()
WHERE metric_id IN ('DISP_DM_120', 'DISP_DM_119', 'DISP_DM_118', 'DISP_DM_210', 'DISP_DM_208');

-- =====================================================
-- 2. HIGH INTENSITY INTERVAL TRAINING (HIIT)
-- =====================================================

UPDATE display_metrics
SET
  about_content = 'HIIT involves short bursts of maximal or near-maximal effort (80-95% max heart rate) followed by recovery periods. This training targets Type IIa and Type IIx muscle fibers, dramatically improves VO2 max, increases mitochondrial density, and enhances anaerobic capacity. HIIT stimulates powerful hormonal responses including growth hormone, testosterone, and catecholamines that support muscle preservation and metabolic health. The intensity creates "EPOC" (excess post-exercise oxygen consumption) - your metabolism stays elevated for 24-48 hours post-workout. HIIT is time-efficient but extremely demanding on the nervous system and requires adequate recovery.',

  longevity_impact = 'HIIT provides the most rapid improvements in VO2 max - critical for longevity. Studies show 4-10 weeks of HIIT can improve VO2 max by 10-15%, equivalent to reducing physiological age by 10-15 years. HIIT improves insulin sensitivity more effectively than moderate exercise, enhances endothelial function (blood vessel health), and may increase telomere length (cellular aging marker). The Norwegian HUNT study found just 1 session of high-intensity exercise per week reduced all-cause mortality by 40%. However, excessive HIIT can increase oxidative stress and inflammation - balance is key for longevity.',

  quick_tips = jsonb_build_array(
    'Limit to 1-2 HIIT sessions per week - more is NOT better for longevity',
    'Allow 48-72 hours recovery between HIIT sessions for optimal adaptation',
    '4x4 protocol (4 min hard, 3 min easy, repeat 4x) is research-backed for VO2 max',
    'Warm up thoroughly (10-15 min) to reduce injury risk and optimize performance',
    'HIIT counts: sprints, bike intervals, rowing, uphill runs, Tabata protocols',
    'Skip HIIT if you feel run-down - it requires optimal recovery capacity',
    'Combine with Zone 2 training: HIIT builds peak capacity, Zone 2 builds base'
  ),

  updated_at = NOW()
WHERE metric_id IN ('DISP_DM_110', 'DISP_DM_255', 'DISP_DM_109');

-- =====================================================
-- 3. STRENGTH TRAINING
-- =====================================================

UPDATE display_metrics
SET
  about_content = 'Resistance training creates mechanical tension, metabolic stress, and muscle damage that trigger muscle protein synthesis and neuromuscular adaptations. Strength training builds and preserves lean muscle mass, increases bone mineral density, improves insulin sensitivity, and enhances metabolic rate. Progressive overload - gradually increasing weight, reps, or difficulty - is essential for continued adaptation. Both heavy loads (3-6 reps) and moderate loads (8-12 reps) build strength and muscle, but through different mechanisms. Compound movements (squats, deadlifts, presses) provide the most functional strength and longevity benefits.',

  longevity_impact = 'Muscle mass is a primary predictor of healthspan - sarcopenia (muscle loss) begins at age 30 and accelerates after 60, directly impacting mortality. Grip strength (a proxy for total-body strength) is one of the strongest predictors of all-cause mortality, disability, and cognitive decline. Adults who strength train 2+ times per week have 23% lower all-cause mortality and 31% lower cancer mortality. Resistance training reduces fall risk by 40%, improves bone density (reducing fracture risk), maintains metabolic health, and preserves functional capacity into late life. Strength is the foundation of the "Centenarian Decathlon" - the physical tasks needed for independence at 100.',

  quick_tips = jsonb_build_array(
    'Train each major muscle group 2-3x per week for optimal muscle retention',
    'Focus on compound movements: squat, deadlift, press, pull, carry patterns',
    'Progressive overload is key: increase weight, reps, or difficulty over time',
    'Adults 65+: emphasize stability, eccentric control, and fall prevention exercises',
    'Allow 48 hours between training the same muscle group for recovery',
    'Protein within 2 hours post-workout (20-40g) maximizes muscle protein synthesis',
    'Consistency matters more than perfection: 2 sessions/week beats sporadic heavy training'
  ),

  updated_at = NOW()
WHERE metric_id IN ('DISP_STRENGTH_SESSIONS', 'DISP_DM_108', 'DISP_DM_254', 'DISP_DM_107');

-- =====================================================
-- 4. MOBILITY & FLEXIBILITY
-- =====================================================

UPDATE display_metrics
SET
  about_content = 'Mobility training improves joint range of motion, movement quality, and motor control through active stretching, dynamic movements, and controlled articulations. Unlike passive flexibility, mobility requires strength through full range of motion and neuromuscular coordination. Mobility work enhances proprioception (body awareness), reduces injury risk, improves movement efficiency, and supports better exercise technique. As we age, connective tissue loses elasticity and joints stiffen - regular mobility practice counteracts this decline. Mobility encompasses hip hinges, shoulder rotation, spinal articulation, ankle dorsiflexion, and thoracic rotation - all critical for functional movement.',

  longevity_impact = 'Loss of mobility is a primary driver of functional decline and loss of independence in aging. Hip and ankle mobility strongly predict fall risk - falls are the leading cause of injury death in adults 65+. Studies show regular flexibility training reduces chronic pain (particularly low back and neck), improves balance and coordination, and maintains activities of daily living. The ability to sit and rise from the floor without using hands (the "sitting-rising test") is a powerful predictor of all-cause mortality - mobility makes this possible. Yoga practitioners show slower cellular aging (longer telomeres) and reduced inflammation markers compared to non-practitioners.',

  quick_tips = jsonb_build_array(
    'Practice 15-20 minutes of mobility work daily, especially before bed or workouts',
    'Focus on weak areas: hips, ankles, thoracic spine, and shoulders for most people',
    'Dynamic mobility (moving through ranges) is better than static stretching pre-workout',
    'The "90/90 hip stretch" and "deep squat hold" are foundational mobility drills',
    'Yoga, Pilates, and Tai Chi provide structured mobility with added balance benefits',
    'Sitting-rising test: practice getting up from floor without using hands weekly',
    'Mobility improves with consistent practice - daily beats occasional long sessions'
  ),

  updated_at = NOW()
WHERE metric_id IN ('DISP_DM_112', 'DISP_DM_256', 'DISP_DM_111');

-- =====================================================
-- 5. POST-MEAL ACTIVITY (Movement Snacks)
-- =====================================================

UPDATE display_metrics
SET
  about_content = 'Post-meal activity - brief movement within 30-90 minutes after eating - dramatically improves glucose disposal and insulin sensitivity. Muscle contraction activates GLUT4 transporters independent of insulin, pulling glucose from blood into muscle cells. Even light activity (walking, bodyweight exercises) significantly blunts post-meal glucose spikes. This is especially important after carbohydrate-rich meals. "Movement snacks" - brief activity breaks throughout the day - combat the metabolic consequences of prolonged sitting, which include insulin resistance, lipid accumulation, and reduced mitochondrial function. Breaking up sedentary time has benefits independent of total exercise volume.',

  longevity_impact = 'Post-meal glucose spikes (hyperglycemia) are directly linked to cardiovascular disease, diabetes, dementia, and all-cause mortality - even in non-diabetics. A 10-minute walk after meals reduces 24-hour glucose exposure by 12-22% and improves insulin sensitivity. Studies show breaking up sitting time every 30 minutes reduces mortality risk by 30% compared to continuous sitting, even in people who exercise regularly. Post-meal walking reduces inflammation markers, improves endothelial function, and supports metabolic flexibility. The "Blue Zones" (centenarian hotspots) share a pattern: frequent, low-intensity movement throughout the day rather than isolated exercise sessions.',

  quick_tips = jsonb_build_array(
    'Walk 10-15 minutes after meals, especially after dinner (largest meal for most)',
    'Target: movement within 30-60 minutes post-meal for maximum glucose benefit',
    'Light activity works: walking, stairs, bodyweight squats, or household chores',
    'Dinner walk is crucial - evening glucose spikes disrupt sleep and metabolism',
    'Set timer: break up sitting every 30-60 min with 2-5 minutes of movement',
    'Post-meal activity reduces cravings and improves digestion via gastric motility',
    'Consistency matters more than intensity: daily 10-min walks beat occasional runs'
  ),

  updated_at = NOW()
WHERE metric_id IN ('DISP_DM_133', 'DISP_DM_129', 'DISP_DM_130', 'DISP_DM_132', 'DISP_DM_131',
                    'DISP_DM_117', 'DISP_DM_114', 'DISP_DM_116', 'DISP_DM_115',
                    'DISP_DM_257', 'DISP_DM_113');

-- =====================================================
-- 6. STEPS / DAILY MOVEMENT
-- =====================================================

UPDATE display_metrics
SET
  about_content = 'Daily step count is a comprehensive marker of non-exercise activity thermogenesis (NEAT) - the calories burned through all movement outside of formal exercise. Steps capture walking, household chores, occupational movement, and daily lifestyle activity. Research consistently shows step count correlates with cardiovascular health, metabolic function, and mortality risk. The "10,000 steps" target originated in Japan but lacks scientific basis - benefits begin much lower. Steps provide low-impact cardiovascular stimulus, support joint health, enhance circulation, improve insulin sensitivity, and serve as a buffer against sedentary behavior. Step count is one of the most actionable and trackable health metrics.',

  longevity_impact = 'Step count shows a clear dose-response relationship with mortality: every 1,000 additional steps reduces mortality risk by 6-36% depending on baseline. The steepest benefits occur from 4,000-8,000 steps. Studies show 7,000-8,000 steps/day associates with maximum longevity benefit - more steps don't significantly improve outcomes. Adults averaging 8,000+ steps/day have 51% lower mortality than those averaging <4,000 steps. Step count independently predicts cardiovascular events, diabetes risk, cognitive decline, and cancer mortality. Importantly, step intensity (cadence) matters: 100+ steps/minute provides additional cardiovascular benefits.',

  quick_tips = jsonb_build_array(
    'Target 7,000-8,000 steps daily for optimal longevity - more is OK but not required',
    'Morning walk (even 10 min) improves energy, focus, and sets active tone for day',
    'Walking meetings, parking farther, taking stairs all increase daily steps',
    'Step intensity matters: aim for some brisk walking (100+ steps/min) daily',
    'Weekend warriors beware: consistent daily movement beats sporadic high activity',
    'Indoor alternatives: treadmill, walking pad, stairs, or mall walking in bad weather',
    'Track trends, not perfection: weekly average is more important than daily target'
  ),

  updated_at = NOW()
WHERE metric_id IN ('DISP_DM_106', 'DISP_DM_208', 'DISP_DM_210');

-- =====================================================
-- Summary
-- =====================================================

DO $$
DECLARE
  v_zone2_updated INTEGER;
  v_hiit_updated INTEGER;
  v_strength_updated INTEGER;
  v_mobility_updated INTEGER;
  v_post_meal_updated INTEGER;
  v_steps_updated INTEGER;
  v_total_updated INTEGER;
BEGIN
  -- Count updates per category
  SELECT COUNT(*) INTO v_zone2_updated
  FROM display_metrics
  WHERE metric_id IN ('DISP_DM_120', 'DISP_DM_119', 'DISP_DM_118', 'DISP_DM_210', 'DISP_DM_208')
    AND about_content IS NOT NULL
    AND about_content LIKE '%Zone 2%';

  SELECT COUNT(*) INTO v_hiit_updated
  FROM display_metrics
  WHERE metric_id IN ('DISP_DM_110', 'DISP_DM_255', 'DISP_DM_109')
    AND about_content IS NOT NULL
    AND about_content LIKE '%HIIT%';

  SELECT COUNT(*) INTO v_strength_updated
  FROM display_metrics
  WHERE metric_id IN ('DISP_STRENGTH_SESSIONS', 'DISP_DM_108', 'DISP_DM_254', 'DISP_DM_107')
    AND about_content IS NOT NULL
    AND about_content LIKE '%Resistance training%';

  SELECT COUNT(*) INTO v_mobility_updated
  FROM display_metrics
  WHERE metric_id IN ('DISP_DM_112', 'DISP_DM_256', 'DISP_DM_111')
    AND about_content IS NOT NULL
    AND about_content LIKE '%Mobility training%';

  SELECT COUNT(*) INTO v_post_meal_updated
  FROM display_metrics
  WHERE metric_id IN ('DISP_DM_133', 'DISP_DM_129', 'DISP_DM_130', 'DISP_DM_132', 'DISP_DM_131',
                      'DISP_DM_117', 'DISP_DM_114', 'DISP_DM_116', 'DISP_DM_115',
                      'DISP_DM_257', 'DISP_DM_113')
    AND about_content IS NOT NULL
    AND about_content LIKE '%Post-meal activity%';

  SELECT COUNT(*) INTO v_steps_updated
  FROM display_metrics
  WHERE metric_id IN ('DISP_DM_106', 'DISP_DM_208', 'DISP_DM_210')
    AND about_content IS NOT NULL
    AND about_content LIKE '%Daily step count%';

  v_total_updated := v_zone2_updated + v_hiit_updated + v_strength_updated +
                     v_mobility_updated + v_post_meal_updated + v_steps_updated;

  RAISE NOTICE '';
  RAISE NOTICE '========================================================';
  RAISE NOTICE 'EXERCISE & MOVEMENT EDUCATIONAL CONTENT';
  RAISE NOTICE '========================================================';
  RAISE NOTICE '';
  RAISE NOTICE 'Total metrics updated: %', v_total_updated;
  RAISE NOTICE '';
  RAISE NOTICE '1. CARDIO / ZONE 2 TRAINING (% metrics)', v_zone2_updated;
  RAISE NOTICE '   Topics: VO2 max, mitochondrial biogenesis, fat oxidation';
  RAISE NOTICE '   Research: Top VO2 max quartile = 5x lower mortality';
  RAISE NOTICE '   Target: 180-200 min/week Zone 2';
  RAISE NOTICE '';
  RAISE NOTICE '2. HIIT (% metrics)', v_hiit_updated;
  RAISE NOTICE '   Topics: Type II fibers, VO2 max gains, hormonal response';
  RAISE NOTICE '   Research: 1 session/week = 40%% mortality reduction';
  RAISE NOTICE '   Target: 1-2 sessions/week max (recovery critical)';
  RAISE NOTICE '';
  RAISE NOTICE '3. STRENGTH TRAINING (% metrics)', v_strength_updated;
  RAISE NOTICE '   Topics: Muscle preservation, bone density, grip strength';
  RAISE NOTICE '   Research: 2x/week = 23%% lower all-cause mortality';
  RAISE NOTICE '   Target: 2-3 sessions/week, all major muscle groups';
  RAISE NOTICE '';
  RAISE NOTICE '4. MOBILITY & FLEXIBILITY (% metrics)', v_mobility_updated;
  RAISE NOTICE '   Topics: Range of motion, fall prevention, functional capacity';
  RAISE NOTICE '   Research: Sitting-rising test predicts mortality';
  RAISE NOTICE '   Target: 15-20 min daily mobility work';
  RAISE NOTICE '';
  RAISE NOTICE '5. POST-MEAL ACTIVITY (% metrics)', v_post_meal_updated;
  RAISE NOTICE '   Topics: Glucose disposal, insulin sensitivity, GLUT4 activation';
  RAISE NOTICE '   Research: 10-min walk = 12-22%% glucose reduction';
  RAISE NOTICE '   Target: 10-15 min walk after meals (esp. dinner)';
  RAISE NOTICE '';
  RAISE NOTICE '6. STEPS / DAILY MOVEMENT (% metrics)', v_steps_updated;
  RAISE NOTICE '   Topics: NEAT, cardiovascular health, dose-response';
  RAISE NOTICE '   Research: 7,000-8,000 steps = optimal longevity';
  RAISE NOTICE '   Target: 7,000+ steps daily average';
  RAISE NOTICE '';
  RAISE NOTICE '========================================================';
  RAISE NOTICE 'CONTENT INCLUDES:';
  RAISE NOTICE '========================================================';
  RAISE NOTICE '  about_content: Physiological mechanisms and science';
  RAISE NOTICE '  longevity_impact: Research on lifespan/healthspan';
  RAISE NOTICE '  quick_tips: 7 actionable recommendations per category';
  RAISE NOTICE '';
  RAISE NOTICE 'Framework: Peter Attia longevity exercise principles';
  RAISE NOTICE 'Research: VO2 max, muscle mass, centenarian studies';
  RAISE NOTICE 'Focus: Disease prevention and functional capacity';
  RAISE NOTICE '';
  RAISE NOTICE 'Mobile: Display in metric detail screens';
  RAISE NOTICE '========================================================';
  RAISE NOTICE '';
END $$;

COMMIT;
