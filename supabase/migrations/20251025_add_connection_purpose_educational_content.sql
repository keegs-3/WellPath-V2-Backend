-- Migration: Add educational content for Connection & Purpose metrics
-- Based on Harvard Study of Adult Development, Blue Zone research, ikigai studies, and nature exposure literature
-- Created: 2025-10-25

-- Social Connection metrics
UPDATE display_metrics
SET
  about_content = 'Social connection represents the quality and quantity of meaningful relationships in your life. Research from the Harvard Study of Adult Development—the longest study of human happiness spanning 85+ years—demonstrates that strong relationships are the most powerful predictor of life satisfaction and longevity. Social connections influence health through multiple biological pathways: reducing systemic inflammation, lowering cortisol levels, strengthening immune function, and regulating cardiovascular responses to stress. The psychosocial mechanism operates through perceived social support, which buffers against stress-induced physiological damage. Loneliness and social isolation trigger chronic stress responses comparable to smoking and obesity, activating inflammatory pathways that accelerate cellular aging. Blue Zone populations demonstrate consistent patterns of social embeddedness, with strong intergenerational ties and daily face-to-face interactions that contribute to their exceptional longevity.',
  longevity_impact = 'Social isolation increases mortality risk by 26-32%, comparable to smoking 15 cigarettes daily. Meta-analyses of 148 studies (308,849 participants) show that strong social relationships improve survival odds by 50%. Loneliness is associated with 29% increased risk of coronary heart disease and 32% increased stroke risk. Social integration correlates with lower inflammatory markers (CRP, IL-6), slower cognitive decline, and reduced dementia risk. The Alameda County Study found that socially isolated individuals had 2-3 times higher mortality across all causes. In Blue Zones, strong social networks contribute to 7-10 additional years of healthy lifespan. Quality matters more than quantity: emotionally close relationships provide greater longevity benefits than larger but superficial networks.',
  quick_tips = jsonb_build_array(
    'Schedule weekly face-to-face interactions with close friends or family—video calls provide 60% of in-person benefits',
    'Join community groups aligned with your interests (book clubs, sports teams, volunteer organizations) to build weak ties that buffer isolation',
    'Practice active-constructive responding: when others share good news, respond enthusiastically and ask elaborative questions',
    'Cultivate 3-5 close relationships through regular contact and vulnerability—research shows this range optimizes health benefits',
    'Prioritize quality over quantity: one intimate conversation weekly provides more longevity benefit than daily superficial interactions',
    'Build intergenerational connections through mentoring or community service—Blue Zone populations emphasize age-diverse social networks',
    'Create rituals of connection: regular dinners, walking groups, or shared activities that provide consistent social touchpoints',
    'Limit social media to < 30 min/day—excessive use correlates with increased loneliness despite appearing "connected"'
  )
WHERE metric_name ILIKE '%social%interaction%'
   OR metric_name ILIKE '%relationship%'
   OR metric_name ILIKE '%social%connection%';

-- Purpose & Meaning / Ikigai metrics
UPDATE display_metrics
SET
  about_content = 'Purpose and meaning—conceptualized in Japanese culture as "ikigai" (reason for being)—represent the psychological sense that one''s life has direction, goals, and significance beyond oneself. Purpose operates through psychoneuroimmunological pathways: individuals with strong life purpose show lower cortisol awakening response, reduced inflammatory cytokines (IL-6, TNF-alpha), and more favorable epigenetic aging markers. The psychosocial mechanism involves goal-directed behavior that provides structure, motivation for health-promoting activities, and resilience against adversity. Purpose dampens threat-related neural activity in the amygdala while enhancing prefrontal regulation. In Blue Zones, particularly Okinawa, ikigai provides daily motivation and social role across the lifespan—even centenarians maintain purpose through community contribution, teaching, or tending gardens. Purpose is distinct from happiness: it involves meaning even through difficulty, creating eudaimonic well-being that supports long-term health.',
  longevity_impact = 'Strong sense of purpose reduces all-cause mortality by 15-23% over 5-14 year follow-up periods across multiple cohorts. The Rush Memory and Aging Project found that high purpose reduced Alzheimer''s risk by 52% and cognitive decline by 30%, even controlling for depressive symptoms. Purpose predicts lower risk of stroke (44% reduction), myocardial infarction (27% reduction), and reduced need for healthcare services. Biological mediators include 33% lower inflammatory gene expression (CTRA profile), healthier diurnal cortisol patterns, and longer telomeres. In Okinawan studies, individuals with clear ikigai lived 7+ years longer than those without. Purpose promotes longevity independent of other factors by motivating health behaviors, providing stress resilience, and reducing allostatic load through meaningful engagement.',
  quick_tips = jsonb_build_array(
    'Identify your ikigai intersection: what you love + what you''re good at + what the world needs + what provides livelihood',
    'Engage in generative activities that benefit others: mentoring, volunteering, or sharing expertise—Blue Zone elders maintain purpose through contribution',
    'Set personally meaningful long-term goals (3-5 years) that align with core values, not external expectations',
    'Create daily purpose rituals: begin each morning identifying one meaningful contribution you''ll make that day',
    'Pursue "flow" activities that challenge your skills while serving something larger than yourself',
    'Connect current tasks to ultimate values: reframe daily work through the lens of broader impact or meaning',
    'Develop a "legacy project": something you''ll create, teach, or build that will outlast you',
    'Practice "job crafting": redesign aspects of work or daily activities to align with personal strengths and values',
    'Cultivate relationships that reinforce purpose—Blue Zone populations embed purpose in social roles and community expectations'
  )
WHERE metric_name ILIKE '%purpose%'
   OR metric_name ILIKE '%meaning%'
   OR metric_name ILIKE '%ikigai%';

-- Gratitude metrics
UPDATE display_metrics
SET
  about_content = 'Gratitude represents the psychological state of appreciating positive aspects of life—both large and small—and recognizing the sources of goodness outside oneself. Gratitude operates through multiple psychobiological mechanisms: it shifts attention from threat to reward, activating ventral striatum and medial prefrontal cortex reward circuits while dampening amygdala reactivity. This cognitive reappraisal reduces stress hormone production and sympathetic nervous system activation. Gratitude practices increase parasympathetic tone (heart rate variability), reduce inflammatory markers, and improve sleep quality through reduced pre-sleep worry. The psychosocial pathway involves strengthening social bonds—expressing gratitude enhances relationship quality, creates reciprocal positive interactions, and builds social capital. Gratitude also promotes health behaviors: grateful individuals exercise more, attend medical appointments, and engage in preventive care. Neuroplasticity research shows that regular gratitude practice strengthens neural pathways for positive emotion processing within 8-12 weeks.',
  longevity_impact = 'Regular gratitude practice (3x weekly) reduces inflammatory biomarkers by 7-12%, including CRP and IL-6, over 8-16 week interventions. Grateful disposition predicts lower blood pressure (average 6-7 mmHg reduction), reduced cardiac inflammatory markers, and 16% longer survival post-acute coronary syndrome. Gratitude improves sleep duration (25+ min/night) and quality, which independently supports longevity. Meta-analyses show gratitude interventions reduce depressive symptoms (d=0.31) and increase positive affect (d=0.39), psychological states linked to longevity. Gratitude strengthens social relationships—each standard deviation increase in gratitude predicts 23% more social support, a key longevity determinant. Long-term gratitude practice may slow epigenetic aging through reduced oxidative stress and enhanced cellular repair during improved sleep. The cumulative effect: grateful individuals show health profiles consistent with 5-7 years younger biological age.',
  quick_tips = jsonb_build_array(
    'Write 3 specific things you''re grateful for, 3x weekly—specificity (not generic statements) maximizes benefit',
    'Practice "gratitude visits": write and deliver a letter of appreciation to someone who positively impacted your life',
    'Use the "morning gratitude minute": upon waking, identify 3 things you appreciate before checking your phone',
    'Reframe challenges through gratitude: identify one unexpected benefit or learning from difficult situations',
    'Create a gratitude jar: write daily appreciations on slips and review monthly to counteract negativity bias',
    'Practice relational gratitude: tell someone each day specifically why you appreciate them—strengthens social bonds',
    'Use gratitude as stress intervention: when stressed, list 5 things going well to activate parasympathetic response',
    'Avoid gratitude comparison: focus on what you have rather than what you lack relative to others',
    'Combine with savoring: pause to fully experience positive moments while acknowledging appreciation'
  )
WHERE metric_name ILIKE '%gratitude%';

-- Outdoor Time / Nature Exposure metrics
UPDATE display_metrics
SET
  about_content = 'Outdoor time and nature exposure represent contact with natural environments, from brief urban green space visits to extended wilderness immersion. Nature exposure operates through multiple interacting mechanisms: reduction in rumination and stress-related neural activity, enhanced parasympathetic nervous system activation, increased phytoncide exposure (airborne plant compounds that boost immune function), improved circadian regulation through natural light, and vitamin D synthesis. The "attention restoration theory" explains how natural environments provide effortless fascination that replenishes directed attention capacity depleted by urban living. Nature also reduces physiological stress responses: 20-30 minutes in green spaces lowers cortisol by 21-24%, reduces blood pressure, and decreases heart rate. The Japanese practice of "shinrin-yoku" (forest bathing) demonstrates that phytoncides from trees increase natural killer cell activity (immune function) by 40-50% for up to 30 days post-exposure. Blue Zone populations integrate outdoor time through walking-based transportation, outdoor work, and garden-centered social activities.',
  longevity_impact = 'Living near green spaces (within 300m) reduces all-cause mortality by 4-12% across multiple cohorts. Nature exposure decreases cardiovascular mortality by 8-16% through blood pressure reduction, stress attenuation, and increased physical activity. Forest bathing increases natural killer cell count by 40% and anti-cancer protein expression by 48%, with effects persisting 30 days. Regular nature exposure (120+ min/week) predicts lower rates of hypertension, type 2 diabetes, cardiovascular disease, and premature mortality. Mechanisms include 15% reduction in cortisol, improved immune function, reduced inflammatory markers, and enhanced sleep quality. Mental health benefits—reduced depression and anxiety—indirectly support longevity through better health behaviors. Blue Zone populations average 60-90 min daily outdoor time through lifestyle integration, contributing to their exceptional healthspan. Dose-response effects plateau around 200-300 min/week of nature contact.',
  quick_tips = jsonb_build_array(
    'Target 120+ minutes weekly in natural environments—benefits plateau around 200-300 min/week across multiple studies',
    'Practice "forest bathing": slow, mindful walks in wooded areas 2-4 hours monthly boost immune function for 30 days',
    'Use the "20-5-3 rule": 20 min in nature 3x/week, 5 hours monthly in semi-wild areas, 3 days annually in wilderness',
    'Maximize morning outdoor time (6-10am) to optimize circadian entrainment and vitamin D synthesis',
    'Choose "green exercise": outdoor physical activity provides additive benefits beyond indoor exercise',
    'Create daily micro-doses: 5-10 min barefoot contact with grass or soil to reduce cortisol and inflammation',
    'Visit blue spaces (lakes, oceans, rivers) for enhanced benefits—water presence amplifies stress reduction',
    'During nature time, leave devices behind or on airplane mode—divided attention eliminates restoration benefits',
    'Cultivate indoor nature: 3+ houseplants, nature sounds, or window views provide 40-60% of outdoor benefits when access is limited'
  )
WHERE metric_name ILIKE '%outdoor%'
   OR metric_name ILIKE '%nature%';

-- Mindfulness / Present-Moment Awareness metrics
UPDATE display_metrics
SET
  about_content = 'Mindfulness represents the psychological capacity to maintain present-moment awareness with non-judgmental acceptance of thoughts, emotions, and bodily sensations. Mindfulness operates through multiple neurobiological pathways: strengthening prefrontal cortical regulation of the amygdala (reducing stress reactivity), enhancing insula activation (improving interoceptive awareness), and increasing activity in the default mode network associated with self-awareness. Regular mindfulness practice induces structural brain changes within 8 weeks: increased gray matter density in the hippocampus (learning and memory), reduced amygdala volume (stress reactivity), and enhanced prefrontal cortex thickness (executive function). Physiologically, mindfulness reduces sympathetic nervous system activation, lowers cortisol production, and increases parasympathetic tone measured through heart rate variability. The psychosocial mechanism involves de-centering from ruminative thought patterns, reducing emotional reactivity, and improving attention regulation—all of which support health-promoting behaviors and reduce allostatic load from chronic stress.',
  longevity_impact = 'Mindfulness meditation practice (8+ weeks, 20-30 min daily) increases telomerase activity by 17-43%, suggesting slower cellular aging. Long-term meditators show 7-8 years slower brain aging measured by cortical thickness. Mindfulness-based interventions reduce inflammatory markers (CRP, IL-6) by 10-15% and improve immune function (antibody response to vaccination). Meta-analyses demonstrate reduced blood pressure (average 4-5 mmHg systolic), improved glycemic control (HbA1c reduction 0.4%), and enhanced cardiovascular health. Mindfulness reduces mortality risk indirectly through mechanisms: 30% reduction in depression/anxiety (conditions linked to 1.5-2x mortality), improved sleep quality, reduced chronic pain, and enhanced health behavior adherence. Telomere length preservation suggests mindfulness may slow epigenetic aging by 10-15% over multi-year practice. Blue Zone Seventh-day Adventists incorporate meditative practices into daily routines, contributing to their 7-10 year longevity advantage.',
  quick_tips = jsonb_build_array(
    'Start with 5-10 minutes daily—consistency matters more than duration; benefits emerge within 8 weeks of regular practice',
    'Use "STOP" technique throughout day: Stop, Take a breath, Observe sensations/thoughts, Proceed mindfully',
    'Practice mindful breathing: 4-7-8 pattern (inhale 4 sec, hold 7 sec, exhale 8 sec) activates parasympathetic response',
    'Apply mindfulness to routine activities: eating, walking, showering—transforms daily tasks into practice opportunities',
    'Use body scan meditation: systematically attend to bodily sensations from toes to head for 10-15 minutes',
    'Practice "noting": silently label thoughts as "thinking," emotions as "feeling" to create meta-awareness',
    'Integrate formal + informal practice: 20 min seated meditation + mindful moments throughout day provides optimal benefit',
    'Use apps like Headspace or Insight Timer for guided practices—structured programs improve adherence in beginners',
    'Join group meditation (weekly or monthly)—social accountability increases practice consistency by 40-60%'
  )
WHERE metric_name ILIKE '%mindful%'
   OR metric_name ILIKE '%present%moment%'
   OR metric_name ILIKE '%awareness%';

-- Screen Time / Digital Wellness metrics
UPDATE display_metrics
SET
  about_content = 'Screen time represents total daily exposure to digital devices (smartphones, computers, tablets, television), with digital wellness referring to healthy technology use patterns. Excessive screen time disrupts health through multiple mechanisms: blue light exposure suppresses melatonin production (disrupting circadian rhythms), sedentary behavior reduces metabolic health, social media use triggers social comparison and loneliness despite apparent connectivity, and constant notifications fragment attention creating chronic low-grade stress. Neurobiologically, excessive screen use—particularly social media—activates dopaminergic reward pathways similar to addictive substances, reducing capacity for delayed gratification and sustained attention. Evening screen exposure delays circadian phase by 1.5-3 hours, reducing sleep quality and duration. The psychosocial mechanism involves displacement of health-promoting activities: each hour of screen time correlates with reduced physical activity, less face-to-face social interaction, and decreased outdoor exposure. Problematic smartphone use shows association with elevated cortisol, reduced parasympathetic tone, and increased inflammatory markers through chronic stress pathway activation.',
  longevity_impact = 'Excessive screen time (>6-8 hours daily) increases all-cause mortality risk by 12-25% through multiple pathways: increased sedentary behavior, reduced sleep quality, social isolation, and mental health deterioration. Each 1-hour increase in daily television viewing after age 25 reduces life expectancy by 22 minutes. High social media use (>2 hours daily) doubles depression and anxiety risk, conditions associated with 1.5-2x mortality. Screen time before bed reduces sleep duration by 30-60 min/night on average—chronic sleep restriction increases mortality risk by 15%. Excessive screen use correlates with 23% increased obesity risk, 18% increased type 2 diabetes risk, and elevated cardiovascular disease risk through reduced physical activity and disrupted metabolic function. Blue light exposure suppresses melatonin by 50%, disrupting circadian rhythms linked to cancer risk, metabolic dysfunction, and accelerated aging. Conversely, reducing recreational screen time to <2 hours daily improves healthspan markers and may recover 1-3 years of healthy life expectancy.',
  quick_tips = jsonb_build_array(
    'Implement the "20-20-20 rule": every 20 min of screen use, look at something 20 feet away for 20 seconds to reduce eye strain',
    'Use "screen sunset" protocol: no screens 60-90 min before bed to protect melatonin production and sleep quality',
    'Set daily screen time limits: <2 hours recreational screen time; use iOS Screen Time or Android Digital Wellbeing to track',
    'Create phone-free zones: bedrooms, dining areas, first/last hour of day—reclaim spaces for rest and connection',
    'Use grayscale mode to reduce dopaminergic appeal of colorful apps—decreases compulsive checking by 30-40%',
    'Batch notifications: check 3-4 times daily rather than responding immediately—constant alerts elevate cortisol chronically',
    'Replace evening screens with longevity-promoting activities: reading, conversation, outdoor walks, or intimate connection',
    'Use blue light filters after sunset if screens necessary—reduces melatonin suppression by 60% compared to unfiltered exposure',
    'Practice "digital sabbath": 24-hour screen-free period weekly to reset attention and reconnect with non-digital activities'
  )
WHERE metric_name ILIKE '%screen%time%'
   OR metric_name ILIKE '%digital%'
   OR metric_name ILIKE '%screen%';

-- Stress Management / Overall Stress metrics
UPDATE display_metrics
SET
  about_content = 'Stress management encompasses the ability to regulate physiological and psychological responses to perceived demands or threats. Chronic stress—the persistent activation of stress response systems—represents one of the most potent accelerators of biological aging and disease risk. Stress operates through the hypothalamic-pituitary-adrenal (HPA) axis and sympathetic nervous system, producing cortisol and catecholamines that mobilize energy resources. While acute stress is adaptive, chronic activation leads to allostatic load: cumulative wear-and-tear across multiple physiological systems. Chronic stress accelerates cellular aging through multiple pathways: telomere attrition (stress reduces telomerase by 30-50%), oxidative damage, chronic inflammation (elevated IL-6, TNF-alpha, CRP), impaired immune function, and dysregulated metabolic processes. Psychologically, chronic stress impairs prefrontal executive function while hyperactivating the amygdala, creating vulnerability to anxiety, depression, and maladaptive coping behaviors. Blue Zone populations demonstrate lower chronic stress through strong social support, purpose-driven lifestyles, daily stress-reduction practices (prayer, meditation, napping), and slower-paced living patterns.',
  longevity_impact = 'Chronic stress increases all-cause mortality by 20-40% and accelerates biological aging by 6-10 years measured through epigenetic clocks and telomere length. High perceived stress predicts 43% increased cardiovascular disease risk, 60% increased metabolic syndrome risk, and doubles risk of coronary heart disease events. Chronic stress elevates inflammatory markers 20-30%, creating pro-inflammatory state that accelerates atherosclerosis, neurodegeneration, and cancer progression. Stress-related telomere shortening equivalent to 9-17 years of accelerated aging has been documented in chronic caregiving stress studies. Effective stress management interventions reverse these effects: stress reduction programs increase telomerase activity by 17-43%, reduce inflammatory markers by 10-20%, and improve cardiovascular risk profiles. Blue Zone populations exhibit 30-50% lower cortisol levels and healthier diurnal cortisol patterns compared to Western populations. Managing stress through evidence-based practices may recover 5-10 years of biological age and reduce disease risk across all major causes of mortality.',
  quick_tips = jsonb_build_array(
    'Practice daily stress-reduction ritual: 10-20 min of meditation, deep breathing, or progressive muscle relaxation',
    'Use physiological sigh technique: two inhales through nose, extended exhale through mouth—rapidly reduces acute stress',
    'Maintain strong social support network: confiding relationships buffer stress impact by 40-60% across studies',
    'Engage in regular physical activity: 150 min/week moderate exercise reduces cortisol and improves stress resilience',
    'Prioritize sleep: 7-9 hours nightly—sleep deprivation amplifies stress reactivity by 30-40% and impairs emotional regulation',
    'Practice cognitive reframing: identify stress-amplifying thought patterns and consciously shift to balanced perspectives',
    'Build recovery into daily routine: micro-breaks every 90 min, true lunch break, and complete evening disconnection from work',
    'Adopt Blue Zone stress-reduction practices: daily nature time, purpose-driven activities, strong community ties, and sacred quiet time',
    'Limit stress-amplifying inputs: excessive news consumption, toxic relationships, overcommitment—protect attention and energy',
    'Seek professional support when needed: therapy provides 50-70% improvement in stress management and prevents chronic escalation'
  )
WHERE metric_name ILIKE '%stress%management%'
   OR metric_name ILIKE '%stress%level%'
   OR (metric_name ILIKE '%stress%' AND metric_name NOT ILIKE '%oxidative%');

-- Verify updates
DO $$
DECLARE
  updated_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO updated_count
  FROM display_metrics
  WHERE about_content IS NOT NULL
    AND longevity_impact IS NOT NULL
    AND quick_tips IS NOT NULL
    AND (
      metric_name ILIKE '%social%'
      OR metric_name ILIKE '%purpose%'
      OR metric_name ILIKE '%gratitude%'
      OR metric_name ILIKE '%outdoor%'
      OR metric_name ILIKE '%nature%'
      OR metric_name ILIKE '%mindful%'
      OR metric_name ILIKE '%screen%'
      OR metric_name ILIKE '%stress%'
    );

  RAISE NOTICE 'Updated educational content for % Connection & Purpose metrics', updated_count;
END $$;
