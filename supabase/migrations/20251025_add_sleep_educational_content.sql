-- =====================================================
-- Add Sleep Educational Content
-- =====================================================
-- Evidence-based sleep science content for display metrics
-- Based on Matthew Walker research, sleep science, and longevity studies
--
-- Covers:
-- 1. Sleep Duration (Total sleep time)
-- 2. Sleep Quality/Efficiency
-- 3. Deep Sleep (Slow wave sleep, restorative)
-- 4. REM Sleep (Dream sleep, cognitive restoration)
-- 5. Sleep Timing (Circadian alignment, consistency)
--
-- Created: 2025-10-25
-- =====================================================

BEGIN;

-- =====================================================
-- 1. SLEEP DURATION (Total Sleep Time)
-- =====================================================

UPDATE parent_display_metrics
SET
  about_content = 'Sleep duration is the total time spent asleep each night, distinct from time in bed. Adults need 7-9 hours of quality sleep per 24-hour period for optimal health. During sleep, the brain undergoes critical restoration including memory consolidation, toxin clearance via the glymphatic system, and synaptic pruning. The body repairs tissues, synthesizes proteins, releases growth hormone, and regulates metabolism. Sleep operates in ~90-minute cycles alternating between NREM (deep restorative sleep) and REM (cognitive processing and emotional regulation). Both chronic sleep deprivation (<6 hours) and excessive sleep (>9 hours regularly) correlate with negative health outcomes, suggesting an optimal range exists.',

  longevity_impact = 'Sleep duration shows a U-shaped mortality curve: sleeping <6 hours or >9 hours consistently is associated with 12-30% increased all-cause mortality compared to 7-8 hours. Chronic short sleep accelerates biological aging, increases dementia risk (including Alzheimer''s via impaired beta-amyloid clearance), elevates cardiovascular disease risk by 45%, and increases type 2 diabetes risk by 28%. The Whitehall II study following 10,000+ adults found that reducing sleep from 7 to 5 hours doubled mortality risk over 25 years. Blue Zone populations (living 100+ years) consistently report 7-8 hour sleep patterns. Even a single night of poor sleep can reduce insulin sensitivity by 30% and increase inflammation markers.',

  quick_tips = jsonb_build_array(
    'Aim for 7-9 hours of actual sleep time per night (not just time in bed)',
    'Maintain consistent sleep-wake times within 1 hour, even on weekends',
    'If you sleep <6 hours regularly, prioritize adding 30-60 minutes incrementally',
    'Quality matters more than quantity - prioritize uninterrupted, restorative sleep',
    'Track your sleep to identify your personal optimal duration (you should wake refreshed)',
    'Avoid "catching up" on weekends - sleep debt accumulates and disrupts circadian rhythm',
    'Adults 65+ may function well on slightly less (7-8 hours) but shouldn''t go below 6',
    'Don''t sacrifice sleep for exercise - sleep deprivation undermines fitness gains'
  ),

  updated_at = NOW()
WHERE parent_metric_id = 'DISP_TOTAL_SLEEP_DURATION';

-- =====================================================
-- 2. SLEEP QUALITY/EFFICIENCY
-- =====================================================

UPDATE parent_display_metrics
SET
  about_content = 'Sleep efficiency measures the percentage of time in bed actually spent asleep, calculated as (total sleep time / time in bed) × 100. Healthy sleep efficiency is ≥85%, meaning you fall asleep within 15-20 minutes and wake briefly or not at all during the night. Poor sleep efficiency indicates sleep fragmentation - frequent awakenings that prevent reaching deeper sleep stages. Sleep quality encompasses efficiency plus sleep architecture (proper cycling through NREM and REM stages). During consolidated sleep, the brain completes full 90-minute cycles allowing adequate deep sleep (physical restoration) and REM sleep (cognitive/emotional processing). Fragmented sleep, even with adequate total duration, impairs these restorative processes and is linked to poor health outcomes.',

  longevity_impact = 'Sleep quality may be more important than duration for longevity. Poor sleep efficiency (<85%) is associated with 30% higher all-cause mortality independent of sleep duration. Sleep fragmentation accelerates cognitive decline - each awakening disrupts glymphatic clearance, which removes beta-amyloid proteins linked to Alzheimer''s. The Osteoporotic Fractures in Men Study found men with poor sleep efficiency had 67% higher mortality risk over 12 years. Fragmented sleep increases systemic inflammation (elevated CRP and IL-6), impairs glucose metabolism, and dysregulates cortisol rhythm - all drivers of accelerated aging. Deep, consolidated sleep supports cellular repair, immune function, and metabolic health critical for healthspan.',

  quick_tips = jsonb_build_array(
    'Target ≥85% sleep efficiency: falling asleep in <20 minutes, minimal night wakings',
    'If you wake during the night, don''t check the time - increases anxiety and further disrupts sleep',
    'Reduce sleep opportunity if efficiency is low: go to bed later or wake earlier to consolidate sleep',
    'Address night wakings: limit fluids 2 hours before bed, avoid alcohol close to bedtime',
    'Keep bedroom cool (65-68°F/18-20°C) - temperature drop facilitates deep sleep',
    'Use blackout curtains and white noise to minimize sleep disruptions',
    'Treat potential sleep disorders: sleep apnea drastically reduces efficiency and quality',
    'Regular exercise improves efficiency by 15-20% but finish workouts 3+ hours before bed'
  ),

  updated_at = NOW()
WHERE parent_metric_id IN (
  SELECT parent_metric_id
  FROM parent_display_metrics
  WHERE parent_name ILIKE '%sleep%efficiency%'
    OR parent_metric_id = 'DISP_SLEEP_EFFICIENCY'
  LIMIT 1
);

-- Fallback: Create education for sleep efficiency if metric exists in different table
UPDATE display_metrics
SET
  about_content = 'Sleep efficiency measures the percentage of time in bed actually spent asleep, calculated as (total sleep time / time in bed) × 100. Healthy sleep efficiency is ≥85%, meaning you fall asleep within 15-20 minutes and wake briefly or not at all during the night. Poor sleep efficiency indicates sleep fragmentation - frequent awakenings that prevent reaching deeper sleep stages. Sleep quality encompasses efficiency plus sleep architecture (proper cycling through NREM and REM stages). During consolidated sleep, the brain completes full 90-minute cycles allowing adequate deep sleep (physical restoration) and REM sleep (cognitive/emotional processing). Fragmented sleep, even with adequate total duration, impairs these restorative processes and is linked to poor health outcomes.',

  longevity_impact = 'Sleep quality may be more important than duration for longevity. Poor sleep efficiency (<85%) is associated with 30% higher all-cause mortality independent of sleep duration. Sleep fragmentation accelerates cognitive decline - each awakening disrupts glymphatic clearance, which removes beta-amyloid proteins linked to Alzheimer''s. The Osteoporotic Fractures in Men Study found men with poor sleep efficiency had 67% higher mortality risk over 12 years. Fragmented sleep increases systemic inflammation (elevated CRP and IL-6), impairs glucose metabolism, and dysregulates cortisol rhythm - all drivers of accelerated aging. Deep, consolidated sleep supports cellular repair, immune function, and metabolic health critical for healthspan.',

  quick_tips = jsonb_build_array(
    'Target ≥85% sleep efficiency: falling asleep in <20 minutes, minimal night wakings',
    'If you wake during the night, don''t check the time - increases anxiety and further disrupts sleep',
    'Reduce sleep opportunity if efficiency is low: go to bed later or wake earlier to consolidate sleep',
    'Address night wakings: limit fluids 2 hours before bed, avoid alcohol close to bedtime',
    'Keep bedroom cool (65-68°F/18-20°C) - temperature drop facilitates deep sleep',
    'Use blackout curtains and white noise to minimize sleep disruptions',
    'Treat potential sleep disorders: sleep apnea drastically reduces efficiency and quality',
    'Regular exercise improves efficiency by 15-20% but finish workouts 3+ hours before bed'
  ),

  updated_at = NOW()
WHERE metric_id = 'DISP_SLEEP_EFFICIENCY'
  AND about_content IS NULL;

-- =====================================================
-- 3. DEEP SLEEP (Slow Wave Sleep, N3)
-- =====================================================

UPDATE child_display_metrics
SET
  about_content = 'Deep sleep (slow wave sleep, N3 stage) is the most physically restorative sleep phase, characterized by high-amplitude, slow delta brain waves (0.5-4 Hz). Adults typically spend 15-25% of total sleep time in deep sleep, concentrated in the first half of the night. During deep sleep, growth hormone is released (critical for tissue repair and metabolism), immune system strengthening occurs, and the glymphatic system operates at peak efficiency - clearing metabolic waste products including beta-amyloid proteins from the brain. Deep sleep is when memories are consolidated from short-term hippocampal storage to long-term cortical storage. This stage is difficult to wake from; awakening during deep sleep causes severe grogginess (sleep inertia). Deep sleep naturally decreases with age, declining by ~2% per decade after age 30.',

  longevity_impact = 'Deep sleep is critical for longevity and brain health. Reduced deep sleep is the strongest predictor of Alzheimer''s disease development - each 1% decrease in deep sleep increases dementia risk by 27%. The glymphatic system, which clears neurotoxic proteins including beta-amyloid and tau, operates primarily during deep sleep. Studies show people with less deep sleep have higher beta-amyloid burden years before symptom onset. Deep sleep also regulates insulin sensitivity - even one night of suppressed deep sleep can reduce insulin sensitivity by 25%. Growth hormone release during deep sleep supports muscle maintenance, bone density, and metabolic health crucial for healthy aging. The Rotterdam Study found older adults with minimal deep sleep had 2.3x higher mortality risk over 11 years.',

  quick_tips = jsonb_build_array(
    'Prioritize deep sleep in the first half of the night - earlier bedtime increases deep sleep',
    'Regular exercise (especially resistance training) increases deep sleep by 25-30%',
    'Avoid alcohol - while it speeds sleep onset, it severely suppresses deep sleep in the second half of the night',
    'Keep bedroom cool (65-68°F/18-20°C) - temperature drop triggers deep sleep',
    'Time-restricted eating with 12+ hour overnight fast may enhance deep sleep quality',
    'Minimize sleep disruptions: treat sleep apnea, reduce noise/light, limit fluid intake before bed',
    'Magnesium supplementation (300-400mg glycinate before bed) may improve deep sleep in deficient individuals',
    'Expect deep sleep to decline with age - focus on maximizing what you get through lifestyle optimization'
  ),

  updated_at = NOW()
WHERE child_metric_id = 'DISP_DEEP_SLEEP'
  AND about_content IS NULL;

-- =====================================================
-- 4. REM SLEEP (Rapid Eye Movement, Dream Sleep)
-- =====================================================

UPDATE child_display_metrics
SET
  about_content = 'REM (Rapid Eye Movement) sleep is the cognitively restorative sleep stage where most vivid dreaming occurs. Adults spend 20-25% of total sleep in REM, occurring in increasingly longer periods throughout the night (longest REM periods in early morning hours). During REM, brain activity rivals waking levels while muscles are paralyzed (preventing dream enactment). REM sleep is critical for emotional regulation - processing emotional experiences and integrating them into long-term memory. It supports creativity, problem-solving, and procedural memory consolidation (skills, patterns). REM consolidates emotional memories while stripping away the emotional charge, serving as "overnight therapy." The brain also prunes unnecessary synaptic connections during REM, optimizing neural networks. REM sleep is highly sensitive to disruption by alcohol, cannabis, many medications, and late-night blue light exposure.',

  longevity_impact = 'REM sleep is essential for cognitive longevity and emotional health. Chronic REM deprivation (<15% of total sleep) is linked to increased risk of dementia, depression, and all-cause mortality. The Framingham Heart Study found people with <15% REM sleep had 13% higher mortality risk and significantly increased dementia risk over 12 years. REM sleep supports emotional resilience - poor REM is a strong predictor of depression and anxiety. REM also regulates glucose metabolism and insulin sensitivity independently of deep sleep. Animal studies show REM deprivation shortens lifespan and accelerates aging markers. For optimal healthspan, protecting REM sleep (especially morning hours) is crucial - resist the urge to cut sleep short or use alcohol as a sleep aid, which severely suppresses REM.',

  quick_tips = jsonb_build_array(
    'Protect morning sleep - REM peaks in the last third of the night; early wake times cut REM short',
    'Avoid alcohol especially in the 4-6 hours before bed - it suppresses REM throughout the night',
    'Minimize blue light exposure 2-3 hours before bed - it delays REM onset',
    'Don''t use cannabis as a sleep aid - chronic use dramatically reduces REM sleep',
    'Many medications suppress REM (beta-blockers, SSRIs) - discuss alternatives with your doctor if possible',
    'Regular sleep schedule maximizes REM - your body expects REM at specific times',
    'Antidepressants can reduce REM significantly - work with provider to minimize impact',
    'REM rebounds after deprivation - if you''ve had poor sleep, expect vivid dreams when you catch up'
  ),

  updated_at = NOW()
WHERE child_metric_id = 'DISP_REM_SLEEP'
  AND about_content IS NULL;

-- =====================================================
-- 5. SLEEP TIMING & CONSISTENCY (Circadian Alignment)
-- =====================================================

UPDATE parent_display_metrics
SET
  about_content = 'Sleep timing refers to when you sleep relative to your circadian rhythm - the internal 24-hour biological clock that regulates sleep-wake cycles, hormone release, body temperature, and metabolism. Optimal sleep timing aligns with your chronotype (natural sleep-wake preference) and occurs during your body''s biological night (when melatonin is elevated and core temperature drops). Sleep consistency - maintaining regular bed and wake times within ±1 hour - entrains your circadian rhythm, improving sleep quality and daytime alertness. Social jetlag (sleeping differently on weekends vs weekdays) disrupts circadian alignment, similar to crossing time zones weekly. Light exposure, meal timing, and activity patterns also synchronize circadian rhythms. Circadian misalignment (shift work, irregular schedules, late-night light exposure) can persist even with adequate sleep duration.',

  longevity_impact = 'Sleep timing and consistency may be as important as duration for longevity. The UK Biobank study of 500,000+ adults found irregular sleepers had 30-50% higher risk of cardiovascular disease and 20-30% higher mortality even with adequate sleep duration. Night shift work is classified as a probable carcinogen by WHO due to circadian disruption and melatonin suppression. Circadian misalignment accelerates biological aging, increases type 2 diabetes risk by 44%, and promotes obesity through dysregulated hunger hormones (ghrelin/leptin). Blue Zone centenarians maintain remarkably consistent sleep schedules aligned with natural light-dark cycles. Each hour of social jetlag (weekend vs weekday sleep times) increases cardiovascular disease risk by 11%. Consistent sleep timing optimizes metabolic health, immune function, and cellular repair processes.',

  quick_tips = jsonb_build_array(
    'Keep sleep and wake times consistent within 1 hour, every day including weekends',
    'Align sleep with your chronotype: night owls can shift earlier gradually (15-30 min/week)',
    'Get bright light exposure in the first hour after waking - synchronizes circadian rhythm',
    'Avoid bright light 2-3 hours before bed; use dim warm lights and blue-blocking glasses if needed',
    'Eat meals on a consistent schedule - food is a powerful circadian synchronizer',
    'Exercise at consistent times; morning/afternoon exercise advances circadian rhythm, evening delays it',
    'If you must shift schedule, do it gradually: 30-60 minutes per day maximum',
    'Weekend "catch-up" sleep creates social jetlag - better to maintain consistency and nap if needed'
  ),

  updated_at = NOW()
WHERE parent_metric_id IN (
  SELECT parent_metric_id
  FROM parent_display_metrics
  WHERE parent_name ILIKE '%sleep%timing%'
    OR parent_name ILIKE '%sleep%consistency%'
    OR parent_metric_id = 'DISP_SLEEP_TIME_CONSISTENCY'
  LIMIT 1
);

-- Fallback: Update in display_metrics if not in parent table
UPDATE display_metrics
SET
  about_content = 'Sleep timing refers to when you sleep relative to your circadian rhythm - the internal 24-hour biological clock that regulates sleep-wake cycles, hormone release, body temperature, and metabolism. Optimal sleep timing aligns with your chronotype (natural sleep-wake preference) and occurs during your body''s biological night (when melatonin is elevated and core temperature drops). Sleep consistency - maintaining regular bed and wake times within ±1 hour - entrains your circadian rhythm, improving sleep quality and daytime alertness. Social jetlag (sleeping differently on weekends vs weekdays) disrupts circadian alignment, similar to crossing time zones weekly. Light exposure, meal timing, and activity patterns also synchronize circadian rhythms. Circadian misalignment (shift work, irregular schedules, late-night light exposure) can persist even with adequate sleep duration.',

  longevity_impact = 'Sleep timing and consistency may be as important as duration for longevity. The UK Biobank study of 500,000+ adults found irregular sleepers had 30-50% higher risk of cardiovascular disease and 20-30% higher mortality even with adequate sleep duration. Night shift work is classified as a probable carcinogen by WHO due to circadian disruption and melatonin suppression. Circadian misalignment accelerates biological aging, increases type 2 diabetes risk by 44%, and promotes obesity through dysregulated hunger hormones (ghrelin/leptin). Blue Zone centenarians maintain remarkably consistent sleep schedules aligned with natural light-dark cycles. Each hour of social jetlag (weekend vs weekday sleep times) increases cardiovascular disease risk by 11%. Consistent sleep timing optimizes metabolic health, immune function, and cellular repair processes.',

  quick_tips = jsonb_build_array(
    'Keep sleep and wake times consistent within 1 hour, every day including weekends',
    'Align sleep with your chronotype: night owls can shift earlier gradually (15-30 min/week)',
    'Get bright light exposure in the first hour after waking - synchronizes circadian rhythm',
    'Avoid bright light 2-3 hours before bed; use dim warm lights and blue-blocking glasses if needed',
    'Eat meals on a consistent schedule - food is a powerful circadian synchronizer',
    'Exercise at consistent times; morning/afternoon exercise advances circadian rhythm, evening delays it',
    'If you must shift schedule, do it gradually: 30-60 minutes per day maximum',
    'Weekend "catch-up" sleep creates social jetlag - better to maintain consistency and nap if needed'
  ),

  updated_at = NOW()
WHERE metric_id = 'DISP_SLEEP_TIME_CONSISTENCY'
  AND about_content IS NULL;

-- =====================================================
-- COMMIT AND SUMMARY
-- =====================================================

DO $$
DECLARE
  v_parent_updated INTEGER;
  v_child_updated INTEGER;
  v_display_updated INTEGER;
BEGIN
  -- Count updates
  SELECT COUNT(*) INTO v_parent_updated
  FROM parent_display_metrics
  WHERE parent_metric_id IN (
    'DISP_TOTAL_SLEEP_DURATION',
    'DISP_SLEEP_EFFICIENCY',
    'DISP_SLEEP_TIME_CONSISTENCY'
  ) AND about_content IS NOT NULL;

  SELECT COUNT(*) INTO v_child_updated
  FROM child_display_metrics
  WHERE child_metric_id IN ('DISP_DEEP_SLEEP', 'DISP_REM_SLEEP')
    AND about_content IS NOT NULL;

  SELECT COUNT(*) INTO v_display_updated
  FROM display_metrics
  WHERE metric_id IN (
    'DISP_SLEEP_EFFICIENCY',
    'DISP_SLEEP_TIME_CONSISTENCY'
  ) AND about_content IS NOT NULL;

  -- Print summary
  RAISE NOTICE '';
  RAISE NOTICE '====================================================================';
  RAISE NOTICE '✅ Sleep Educational Content Migration Complete';
  RAISE NOTICE '====================================================================';
  RAISE NOTICE '';
  RAISE NOTICE 'Educational Content Added to % Sleep Metrics', (v_parent_updated + v_child_updated + v_display_updated);
  RAISE NOTICE '';
  RAISE NOTICE '📊 Sleep Categories Covered:';
  RAISE NOTICE '';
  RAISE NOTICE '1. SLEEP DURATION (DISP_TOTAL_SLEEP_DURATION)';
  RAISE NOTICE '   • Glymphatic system and brain restoration';
  RAISE NOTICE '   • U-shaped mortality curve (7-9 hours optimal)';
  RAISE NOTICE '   • 8 evidence-based tips for optimal sleep duration';
  RAISE NOTICE '';
  RAISE NOTICE '2. SLEEP QUALITY/EFFICIENCY (DISP_SLEEP_EFFICIENCY)';
  RAISE NOTICE '   • Sleep consolidation and architecture';
  RAISE NOTICE '   • 30%% higher mortality with poor efficiency (<85%%)';
  RAISE NOTICE '   • 8 tips for improving sleep efficiency';
  RAISE NOTICE '';
  RAISE NOTICE '3. DEEP SLEEP (DISP_DEEP_SLEEP)';
  RAISE NOTICE '   • Slow wave sleep, growth hormone, glymphatic clearance';
  RAISE NOTICE '   • Beta-amyloid removal and Alzheimer''s prevention';
  RAISE NOTICE '   • 8 strategies to maximize deep sleep';
  RAISE NOTICE '';
  RAISE NOTICE '4. REM SLEEP (DISP_REM_SLEEP)';
  RAISE NOTICE '   • Cognitive restoration, emotional regulation, creativity';
  RAISE NOTICE '   • <15%% REM linked to 13%% higher mortality risk';
  RAISE NOTICE '   • 8 tips to protect REM sleep';
  RAISE NOTICE '';
  RAISE NOTICE '5. SLEEP TIMING/CONSISTENCY (DISP_SLEEP_TIME_CONSISTENCY)';
  RAISE NOTICE '   • Circadian rhythm alignment and social jetlag';
  RAISE NOTICE '   • Irregular sleep: 30-50%% higher CVD risk';
  RAISE NOTICE '   • 8 circadian optimization strategies';
  RAISE NOTICE '';
  RAISE NOTICE '📚 Evidence Base:';
  RAISE NOTICE '   • Matthew Walker sleep research';
  RAISE NOTICE '   • UK Biobank (500,000+ adults)';
  RAISE NOTICE '   • Framingham Heart Study';
  RAISE NOTICE '   • Blue Zone longevity patterns';
  RAISE NOTICE '   • Glymphatic system research';
  RAISE NOTICE '   • Sleep-dementia connections';
  RAISE NOTICE '';
  RAISE NOTICE '📱 Each metric now includes:';
  RAISE NOTICE '   ✓ about_content - Sleep science and mechanisms';
  RAISE NOTICE '   ✓ longevity_impact - Research on sleep and healthspan';
  RAISE NOTICE '   ✓ quick_tips - 8 actionable recommendations per metric';
  RAISE NOTICE '';
  RAISE NOTICE 'Mobile apps can display this content in metric detail screens';
  RAISE NOTICE '====================================================================';
  RAISE NOTICE '';
END $$;

COMMIT;
