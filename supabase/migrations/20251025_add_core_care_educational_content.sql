-- =====================================================
-- COMPREHENSIVE CORE CARE EDUCATIONAL CONTENT
-- PhD-Level Preventive Medicine & Longevity Research
-- =====================================================
-- This migration adds evidence-based educational content for all Core Care metrics
-- Content focuses on preventive screening, biometric optimization, and healthy habits
-- Categories: Biometrics (8), Screenings (8), Adherence (3), Substances (4), Routines (5), Basic (2)
-- Total: 30 Core Care metrics
-- =====================================================

BEGIN;

-- =====================================================
-- CATEGORY 1: BIOMETRICS (8 metrics)
-- =====================================================

-- =====================================================
-- 1. WEIGHT
-- =====================================================
UPDATE display_metrics
SET
  about_content = 'Body weight represents the sum of all body tissues including muscle, fat, bone, water, and organs. While weight alone provides limited health information without context, tracking weight trends over time offers valuable insights into energy balance, metabolic health, and body composition changes. Weight fluctuates daily by 1-5 pounds due to hydration status, sodium intake, carbohydrate stores (glycogen binds water), digestive contents, hormonal cycles, and exercise-induced inflammation. For health assessment, body composition (fat versus lean mass distribution) matters far more than total weight—an individual can be "normal weight" but metabolically unhealthy with excess visceral fat, or "overweight" by BMI but metabolically healthy with high muscle mass. Waist circumference and waist-to-hip ratio better predict metabolic health and mortality risk than weight or BMI alone. Intentional weight loss of 5-10% in overweight individuals significantly improves metabolic markers, reduces cardiovascular risk, and may extend healthspan. However, weight cycling (yo-yo dieting) associates with adverse metabolic effects, emphasizing the importance of sustainable lifestyle changes over rapid weight loss approaches.',

  longevity_impact = 'The relationship between body weight and longevity follows a complex "U-shaped" curve, with both extremes (underweight and obesity) increasing mortality risk. Large-scale meta-analyses consistently show obesity (BMI 30+) increases all-cause mortality by 20-30%, with strongest associations for deaths from cardiovascular disease, diabetes, kidney disease, and certain cancers. The Prospective Studies Collaboration analyzing nearly 1 million adults found each 5-unit BMI increase above 25 kg/m² increased mortality by 30%. However, the "obesity paradox" complicates this picture—some studies show overweight individuals (BMI 25-30) have similar or slightly lower mortality than normal weight, possibly due to greater metabolic reserves during illness. Body composition proves more predictive than weight: the Health ABC Study found older adults with higher muscle mass had 19% lower mortality independent of fat mass. Intentional weight loss in obese individuals reduces mortality risk—the Look AHEAD trial showed intensive lifestyle intervention reduced cardiovascular disease events by 21%. Blue Zone populations maintain relatively stable weights throughout adulthood, with BMIs typically 18-25, emphasizing gradual age-related changes rather than significant fluctuations. Maintaining stable weight in middle age (40-60) predicts better health outcomes than weight gain or loss during this period.',

  quick_tips = jsonb_build_array(
    'Weigh yourself consistently (same time, same conditions) rather than focusing on daily fluctuations—track weekly averages',
    'Prioritize body composition over total weight—waist circumference and body fat percentage better predict health',
    'For overweight individuals, target gradual loss of 0.5-1 lb per week through sustainable dietary and activity changes',
    'Muscle weighs more than fat—resistance training may stabilize or increase weight while improving body composition',
    'Weight stability in adulthood (maintaining within 5% of baseline) associates with better longevity outcomes',
    'Focus on metabolic health markers (blood pressure, glucose, lipids, inflammation) not just the scale number',
    'Avoid weight cycling through crash diets—prioritize long-term sustainable eating patterns for lasting results'
  ),

  updated_at = NOW()
WHERE metric_id = 'DISP_WEIGHT';

-- =====================================================
-- 2. HEIGHT
-- =====================================================
UPDATE display_metrics
SET
  about_content = 'Height reflects genetic potential, childhood nutrition, and developmental factors, remaining relatively stable through adulthood until gradual age-related decline begins around age 40. Adults can lose 1-3 inches of height over their lifetime due to spinal disc compression, vertebral compression fractures, postural changes, and muscle loss. Tracking height changes provides important clinical information: accelerated height loss (>2 inches) signals potential osteoporosis, vertebral fractures, or kyphosis requiring medical evaluation. Height interacts with other measurements to calculate important health metrics including BMI (weight/height²), ideal body weight ranges, medication dosing, and predicted lung capacity. While height itself is largely non-modifiable in adults, the rate of height loss responds to interventions including resistance training, adequate calcium and vitamin D intake, bone density optimization, and postural exercises. Good posture can immediately improve measured height by 0.5-1 inch and reduces progression of age-related height loss.',

  longevity_impact = 'The relationship between height and longevity shows complex patterns across populations and study designs. Some large-scale studies find shorter individuals live longer—analyzing 8,000 men, those 5''2" and shorter lived 2 years longer on average than those 5''4" and taller, with proposed mechanisms including lower oxidative stress, reduced cancer risk (fewer cells to potentially become malignant), improved insulin sensitivity, and lower caloric requirements. However, height also reflects early-life conditions: taller individuals in developed countries often experienced better childhood nutrition and healthcare, complicating interpretations. The critical longevity factor is not absolute height but rather preserving height through aging. The Framingham Study found adults who lost 2+ inches had 30% increased mortality compared to those maintaining height, with height loss predicting vertebral fractures, disability, and reduced quality of life. Kyphosis (hunched posture with height loss) associates with 44% increased mortality independent of bone density. Blue Zone populations show modest heights (reflecting genetic and historical nutritional factors) but critically maintain posture and functional capacity into advanced age, with centenarians showing minimal kyphosis.',

  quick_tips = jsonb_build_array(
    'Measure height annually after age 50 to detect accelerated loss that may indicate osteoporosis',
    'Maintain good posture through core strengthening, hip flexibility, and postural awareness exercises',
    'Ensure adequate calcium (1200mg daily for adults 50+) and vitamin D (800-2000 IU) for bone health',
    'Include weight-bearing and resistance exercise to maintain bone density and prevent vertebral compression',
    'Address kyphosis early with thoracic extensions, foam rolling, and postural exercises',
    'Discuss DEXA bone density scans with your provider if you experience height loss >1 inch',
    'Yoga and Pilates can improve spinal alignment, posture, and functional height while preventing further loss'
  ),

  updated_at = NOW()
WHERE metric_id = 'DISP_HEIGHT';

-- =====================================================
-- 3. BMI (Body Mass Index)
-- =====================================================
UPDATE display_metrics
SET
  about_content = 'Body Mass Index (BMI) is calculated as weight in kilograms divided by height in meters squared (kg/m²), providing a population-level screening tool for weight categories: underweight (<18.5), normal (18.5-24.9), overweight (25-29.9), and obese (≥30). BMI correlates reasonably well with body fat percentage at the population level and shows clear associations with disease risk in large epidemiological studies. However, BMI has significant limitations for individual assessment: it cannot distinguish muscle from fat, doesn''t account for fat distribution (subcutaneous versus visceral), varies by ethnicity (Asian populations show higher disease risk at lower BMIs), and misclassifies athletic individuals with high muscle mass as overweight or obese. BMI also fails to capture metabolic health—up to 30% of "normal weight" individuals are metabolically unhealthy with excess visceral fat, while 10-25% of obese individuals are "metabolically healthy" with preserved insulin sensitivity. Waist circumference (>40 inches men, >35 inches women) and waist-to-hip ratio better identify cardiometabolic risk than BMI alone.',

  longevity_impact = 'Despite its limitations, BMI shows robust associations with mortality and disease risk in large-scale prospective studies. A meta-analysis of 239 studies including 10.6 million participants found BMI 22.5-25 associated with lowest mortality risk, with increased risk at both extremes. Overweight (BMI 25-30) shows modest 7% increased mortality, while obesity class I (BMI 30-35) shows 45% increased risk, class II (35-40) shows 94% increased risk, and class III (40+) shows 176% increased risk. The Prospective Studies Collaboration found each 5-unit BMI increase above 25 reduced life expectancy by 2-4 years. However, these associations vary significantly by age, with BMI-mortality relationships weakening after age 70 and potentially reversing (the "obesity paradox"). Importantly, fitness level modifies BMI-mortality associations—the Cooper Center Longitudinal Study found fit obese individuals had lower mortality than unfit normal-weight individuals. Blue Zone populations maintain BMIs between 18.5-24.9 throughout life, with emphasis on lifelong weight stability rather than weight loss in later years.',

  quick_tips = jsonb_build_array(
    'Use BMI as one screening metric but not sole determinant of health—combine with waist circumference and body composition',
    'Target BMI 20-25 for optimal longevity, with 22-25 showing lowest mortality risk in most populations',
    'If BMI >25, prioritize metabolic health markers (blood pressure, glucose, lipids, inflammation) over weight alone',
    'Build muscle through resistance training—this may increase BMI while dramatically improving metabolic health',
    'For Asian populations, use modified BMI thresholds: overweight ≥23, obese ≥27.5',
    'Track trends over time rather than single measurements—gradual BMI increase predicts worse outcomes than stability',
    'Focus on body composition changes and how you feel/function, not just BMI numbers on a chart'
  ),

  updated_at = NOW()
WHERE metric_id = 'DISP_BMI';

-- =====================================================
-- 4. BODY FAT PERCENTAGE
-- =====================================================
UPDATE display_metrics
SET
  about_content = 'Body fat percentage represents the proportion of total body weight comprised of adipose tissue, providing more clinically relevant health information than weight or BMI alone. Essential fat (required for physiological function) comprises 2-5% for men and 10-13% for women. Healthy ranges are typically 10-20% for men and 20-30% for women, with athletic individuals often lower and variance by age. Body fat distribution proves critically important: subcutaneous fat (under the skin) is relatively metabolically benign, while visceral fat (around organs) drives insulin resistance, inflammation, and cardiovascular disease. Visceral adiposity secretes inflammatory cytokines (TNF-α, IL-6), disrupts insulin signaling, increases free fatty acids, and promotes atherogenic lipid profiles. Measurement methods vary in accuracy: DEXA scan (gold standard, ±1-2% error), hydrostatic weighing (±2-3%), bioelectrical impedance (±3-5%, highly variable by hydration), skinfold calipers (±3-5%, technique-dependent), and visual estimation (±5-10%). Serial measurements using the same method provide more valuable trend data than single measurements across different methods.',

  longevity_impact = 'Body fat percentage, particularly visceral adiposity, shows stronger associations with mortality and disease risk than BMI or total weight. The Health ABC Study following nearly 3,000 older adults found those in the highest visceral fat tertile had 2.7x increased mortality risk compared to lowest tertile, independent of BMI. Each 5% increase in body fat percentage associates with 10-15% increased cardiovascular disease risk and 5-7% increased diabetes risk. However, the relationship is complex and age-dependent: older adults with moderately higher body fat (25-30% for men, 30-35% for women) may have metabolic reserves supporting survival during illness and injury. The key distinction is visceral versus subcutaneous fat—the Framingham Heart Study found subcutaneous fat showed neutral or slightly protective associations while visceral fat strongly predicted cardiovascular events. For longevity optimization, men should target 12-18% body fat and women 20-28%, with emphasis on minimizing visceral adiposity through diet quality, regular exercise, adequate sleep, and stress management. Blue Zone populations maintain relatively low body fat percentages throughout life, with active lifestyles and whole-food diets naturally supporting healthy body composition.',

  quick_tips = jsonb_build_array(
    'Target 12-18% body fat for men, 20-28% for women for optimal health and longevity outcomes',
    'Prioritize reducing visceral fat through whole foods diet, regular activity, quality sleep, and stress management',
    'Use consistent measurement methods for tracking trends—DEXA scan provides most accurate visceral fat assessment',
    'Resistance training 2-3x weekly preserves muscle mass while reducing body fat percentage',
    'Avoid very low body fat (<8% men, <18% women) which can disrupt hormones and immune function',
    'Track waist circumference as proxy for visceral fat: <40 inches men, <35 inches women',
    'Body recomposition (gaining muscle while losing fat) improves health even if total weight stays stable'
  ),

  updated_at = NOW()
WHERE metric_id = 'DISP_BODY_FAT_PCT';

-- =====================================================
-- 5. WAIST-HIP RATIO
-- =====================================================
UPDATE display_metrics
SET
  about_content = 'Waist-to-hip ratio (WHR) is calculated by dividing waist circumference (measured at narrowest point between ribs and hips) by hip circumference (measured at widest point around buttocks). This simple anthropometric measurement identifies central (abdominal) versus peripheral (hip/thigh) fat distribution, with WHR >0.90 for men and >0.85 for women indicating abdominal obesity and increased cardiometabolic risk. WHR reflects visceral adiposity more accurately than BMI or total weight, as individuals with similar BMIs can have vastly different fat distribution patterns. "Apple-shaped" bodies (high WHR, abdominal fat) show dramatically higher disease risk than "pear-shaped" bodies (low WHR, hip/thigh fat) even at identical body weight. The biological basis involves visceral fat''s metabolic activity: unlike subcutaneous fat, visceral adipocytes release inflammatory cytokines directly into portal circulation, promoting hepatic insulin resistance, dyslipidemia, hypertension, and atherosclerosis. Hip and thigh fat, conversely, may be metabolically protective by sequestering free fatty acids away from ectopic deposition in liver and muscle.',

  longevity_impact = 'Waist-to-hip ratio demonstrates stronger mortality prediction than BMI across multiple large-scale prospective studies, emerging as one of the most powerful anthropometric longevity markers. The EPIC study of 360,000 Europeans found each 0.1 unit increase in WHR associated with 34% increased mortality in men and 24% in women, independent of BMI. The Nurses'' Health Study following 44,000 women found those in the highest WHR quintile (>0.88) had 3.0x higher cardiovascular mortality than lowest quintile (<0.73), even among normal-weight participants. A Mayo Clinic study analyzing 15,000 adults found normal-weight individuals with central obesity (high WHR) had the worst long-term survival—worse than obese individuals with proportional fat distribution. Each 0.1 increase in WHR associates with approximately 2 years reduced life expectancy. The optimal ranges for longevity are WHR <0.85 for men and <0.75 for women. Blue Zone populations universally maintain low WHR throughout life, reflecting predominantly whole-food, plant-based diets, active lifestyles with natural movement, and minimal processed food consumption that prevents visceral fat accumulation.',

  quick_tips = jsonb_build_array(
    'Target WHR <0.90 for men, <0.85 for women; optimal longevity ranges are <0.85 men, <0.75 women',
    'Measure waist at narrowest point between ribs and hips, hips at widest point—use same landmarks consistently',
    'Reduce visceral fat through whole foods diet, regular aerobic exercise, adequate sleep (7-9 hours), and stress management',
    'Resistance training builds metabolically active muscle that helps mobilize visceral fat stores',
    'Limit added sugars and alcohol which preferentially deposit as visceral fat',
    'High-fiber foods (vegetables, legumes, whole grains) reduce visceral fat accumulation',
    'Track WHR quarterly—decreasing ratio even without weight loss significantly improves metabolic health and longevity'
  ),

  updated_at = NOW()
WHERE metric_id = 'DISP_WAIST_HIP_RATIO';

-- =====================================================
-- 6. BLOOD PRESSURE (Systolic)
-- =====================================================
UPDATE display_metrics
SET
  about_content = 'Systolic blood pressure (SBP) measures the maximum arterial pressure during ventricular contraction (heart beat), reflecting both cardiac output and arterial stiffness. Normal SBP is <120 mmHg, with elevated (120-129), stage 1 hypertension (130-139), and stage 2 hypertension (≥140) indicating progressively increased cardiovascular risk. SBP naturally increases with age due to arterial stiffening from collagen cross-linking, elastin degradation, endothelial dysfunction, and calcium deposition in arterial walls. This process, termed "arterial aging," occurs faster in individuals with chronic inflammation, oxidative stress, high sodium intake, obesity, sedentary lifestyle, and insulin resistance. SBP shows significant variability throughout the day (circadian rhythm with morning surge), in response to stress, activity, meals, sleep quality, and hydration status. "White coat hypertension" (elevated readings in clinical settings) affects 15-30% of patients, making home monitoring valuable. Isolated systolic hypertension (SBP ≥130 with normal diastolic) becomes increasingly common after age 50 and carries particularly high stroke risk.',

  longevity_impact = 'Systolic blood pressure demonstrates one of the strongest, most linear relationships with cardiovascular mortality and longevity across all age groups. The Prospective Studies Collaboration analyzing 1 million adults found each 20 mmHg increase in SBP doubled cardiovascular mortality risk, with effects persisting down to 115 mmHg—no "threshold" below which risk plateaus. The SPRINT trial found intensive SBP control (<120 vs <140 mmHg) reduced cardiovascular events by 25% and all-cause mortality by 27% in high-risk adults. However, treatment targets vary by age: while <120 mmHg optimal for middle-aged adults, emerging evidence suggests SBP 130-140 mmHg may be acceptable for adults 80+. Even modest SBP elevation (120-129 mmHg) increases lifetime cardiovascular disease risk by 50%. Blue Zone populations maintain remarkably stable, low blood pressure throughout life (typically 110-120 mmHg systolic even in advanced age), attributed to whole-food plant-based diets naturally low in sodium and high in potassium, active lifestyles, healthy body weight, and strong social connections reducing chronic stress.',

  quick_tips = jsonb_build_array(
    'Target SBP <120 mmHg for optimal longevity, with <130 mmHg acceptable for adults 65+',
    'Monitor blood pressure at home using validated device—take readings same time daily, ideally morning before medications',
    'Reduce sodium to <2,300mg daily (ideally <1,500mg) and increase potassium through vegetables, fruits, and legumes',
    'DASH diet (rich in vegetables, fruits, whole grains, low-fat dairy) lowers SBP by 8-14 mmHg',
    'Lose excess weight—each 10 lb weight loss reduces SBP by approximately 5 mmHg',
    'Exercise regularly: 150 min/week moderate aerobic activity lowers SBP by 5-8 mmHg',
    'Manage stress through meditation, breathwork, adequate sleep, and social connection'
  ),

  updated_at = NOW()
WHERE metric_id = 'DISP_SYSTOLIC_BP';

-- =====================================================
-- 7. BLOOD PRESSURE (Diastolic)
-- =====================================================
UPDATE display_metrics
SET
  about_content = 'Diastolic blood pressure (DBP) measures the minimum arterial pressure during ventricular relaxation (between heart beats), reflecting primarily peripheral vascular resistance and arterial elasticity. Normal DBP is <80 mmHg, with elevated (80-89) and hypertensive (≥90) ranges indicating increased cardiovascular risk. Unlike SBP which rises with age, DBP typically peaks in middle age (50-60) then gradually declines as arteries stiffen. This creates a widening "pulse pressure" (difference between systolic and diastolic) that independently predicts cardiovascular risk. DBP represents the pressure constantly stressing arterial walls, making sustained elevation particularly damaging to small vessels in kidneys, brain, and retina. Low DBP (<60 mmHg), while less common, can indicate reduced coronary perfusion (which occurs during diastole) and associates with increased cardiovascular events in certain populations, creating a "J-curve" relationship. DBP responds particularly well to lifestyle modifications including weight loss, sodium reduction, and regular aerobic exercise.',

  longevity_impact = 'While systolic pressure dominates cardiovascular risk prediction in adults over 50, diastolic pressure proves equally important in younger adults and shows independent mortality associations across all ages. The Framingham Heart Study found each 10 mmHg increase in DBP doubled cardiovascular risk in adults under 50. The Prospective Studies Collaboration demonstrated DBP 75-84 mmHg associated with lowest mortality, with increased risk above 90 mmHg and potentially below 70 mmHg (J-curve effect). Isolated diastolic hypertension (DBP ≥90 with normal SBP) affects 10-20% of younger adults and increases lifetime cardiovascular risk by 50%. The SPRINT trial showed intensive blood pressure control (targeting SBP <120) naturally lowered DBP while demonstrating cardiovascular benefits, though very low DBP (<60 mmHg) occasionally compromised coronary perfusion in older adults. Optimal DBP for longevity appears to be 70-80 mmHg across most ages. Blue Zone populations maintain DBP in this optimal range throughout life, with Adventist Health Study participants showing median DBP of 75 mmHg even among octogenarians.',

  quick_tips = jsonb_build_array(
    'Target DBP 70-80 mmHg for optimal cardiovascular health and longevity across all ages',
    'Track both systolic and diastolic—widening pulse pressure (SBP-DBP >60) indicates arterial stiffening',
    'Regular aerobic exercise (particularly moderate intensity) effectively lowers DBP by improving arterial elasticity',
    'Maintain healthy weight—excess adiposity increases peripheral resistance raising DBP',
    'Limit alcohol to ≤1 drink daily (women) or ≤2 daily (men) as excess raises DBP',
    'Ensure adequate magnesium (400-420mg daily for men, 310-320mg for women) from nuts, seeds, leafy greens',
    'If DBP <60 mmHg despite normal SBP, discuss with provider to optimize coronary perfusion'
  ),

  updated_at = NOW()
WHERE metric_id = 'DISP_DIASTOLIC_BP';

-- =====================================================
-- 8. AGE
-- =====================================================
UPDATE display_metrics
SET
  about_content = 'Chronological age measures time since birth but increasingly diverges from biological age—the physiological age of body tissues and systems based on cellular function, metabolic health, and accumulated damage. Biological age reflects the cumulative impact of genetics, lifestyle, environment, and stochastic factors on aging processes including cellular senescence, mitochondrial dysfunction, epigenetic alterations, proteostasis loss, and stem cell exhaustion. Advanced biological age relative to chronological age predicts mortality, disease risk, and functional decline, while younger biological age indicates preserved healthspan. Biological age can be estimated through various methods: phenotypic (physical function tests, biomarkers like VO2 max and HRV), molecular (DNA methylation clocks measuring epigenetic aging), and algorithmic (AI analysis of multiple biomarkers). Critically, biological age proves modifiable through lifestyle interventions: exercise, nutrition, sleep, stress management, and social connection can slow or even partially reverse biological aging. The goal of longevity medicine is maximizing the gap between chronological age and biological age—staying physiologically younger than years lived.',

  longevity_impact = 'The divergence between chronological and biological age powerfully predicts mortality and healthspan. Studies using DNA methylation clocks (epigenetic aging biomarkers) find each 5-year increase in biological age above chronological age associates with 21% increased mortality risk. Conversely, biological age 5 years younger than chronological age associates with 15-20% reduced mortality. The Framingham Heart Study found biological age (based on clinical biomarkers) predicted cardiovascular events more accurately than chronological age. Lifestyle interventions can remarkably slow biological aging: the CALERIE trial found 2 years of caloric restriction slowed aging by 2-3 years by DNA methylation measures. High cardiorespiratory fitness can create 10-15 year biological age advantage—individuals with excellent VO2 max in their 60s have cardiovascular systems resembling average 45-year-olds. Blue Zone populations demonstrate extraordinary examples: Okinawan centenarians often have biological ages 15-20 years younger than chronological age based on functional testing, inflammation markers, and disease prevalence. The critical message: chronological age is immutable, but biological age responds to lifestyle optimization.',

  quick_tips = jsonb_build_array(
    'Focus on modifiable aging factors: maintain VO2 max, muscle mass, metabolic health, and cognitive function',
    'Measure biological age markers: VO2 max, HRV, walking speed, grip strength, inflammatory markers (hsCRP)',
    'Exercise comprehensively: Zone 2 cardio for mitochondrial health, HIIT for VO2 max, resistance for muscle preservation',
    'Optimize nutrition: whole foods, plant-predominant, adequate protein (1.2-1.6 g/kg if 50+), minimize processed foods',
    'Prioritize sleep quality: 7-9 hours nightly supports cellular repair, hormonal balance, and metabolic health',
    'Manage chronic stress: meditation, breathwork, social connection, and purpose reduce cortisol and inflammation',
    'Stay socially engaged and mentally active: strong relationships and cognitive challenges support brain health and longevity'
  ),

  updated_at = NOW()
WHERE metric_id = 'DISP_AGE';

-- =====================================================
-- CATEGORY 2: PREVENTIVE SCREENINGS (8 metrics)
-- =====================================================

-- =====================================================
-- 9. COLONOSCOPY COMPLIANCE
-- =====================================================
UPDATE display_metrics
SET
  about_content = 'Colonoscopy is the gold-standard screening test for colorectal cancer, allowing direct visualization of the entire colon and rectum while enabling simultaneous removal of precancerous polyps (adenomas and serrated lesions). The procedure involves inserting a flexible scope through the rectum to examine the colon lining, with sedation ensuring patient comfort. During colonoscopy, gastroenterologists identify and remove polyps before they progress to cancer—a process typically requiring 10-15 years. Current guidelines recommend average-risk adults begin screening at age 45 (lowered from 50 in 2021 due to rising young-onset colorectal cancer rates), with repeat colonoscopy every 10 years if normal, more frequently if polyps found. High-risk individuals (family history of colorectal cancer, inflammatory bowel disease, genetic syndromes) require earlier and more frequent screening. Alternative screening methods include annual fecal immunochemical test (FIT), multi-target stool DNA test every 3 years, or CT colonography every 5 years, though these require colonoscopy if abnormal and don''t allow polyp removal during initial screening.',

  longevity_impact = 'Colonoscopy screening represents one of the most powerful preventive interventions in medicine, with capacity to both detect early cancer and prevent cancer through polyp removal. The National Polyp Study demonstrated colonoscopy with polypectomy reduced colorectal cancer incidence by 76-90% compared to general population rates. Subsequent studies show 53% reduced colorectal cancer mortality with regular screening. The impact on lifespan is substantial: modeling studies suggest colonoscopy screening extends life expectancy by 0.5-1.0 years for average-risk 50-year-olds. Colorectal cancer is the third leading cancer cause of death in the US, with 52,000 deaths annually, yet 60% of these deaths could be prevented through screening. Critically, screening effectiveness depends on quality—adequate bowel preparation, complete examination to cecum, sufficient withdrawal time (≥6 minutes), and adenoma detection rate ≥25% for screening colonoscopies. Earlier screening at age 45 responds to concerning trends: colorectal cancer incidence increased 50% in adults under 50 since mid-1990s. Blue Zone populations have lower baseline colorectal cancer rates due to high-fiber, plant-based diets, but screening remains crucial for those with access.',

  quick_tips = jsonb_build_array(
    'Begin screening at age 45 for average risk; earlier if family history or symptoms (blood in stool, weight loss)',
    'Repeat every 10 years if normal; 5 years if small polyps; 3 years if advanced adenomas or multiple polyps',
    'Bowel preparation quality is critical—follow prep instructions exactly for adequate visualization',
    'Choose experienced gastroenterologist with adenoma detection rate ≥25% for men, ≥15% for women',
    'Don''t defer screening—early-stage colorectal cancer (found by screening) has 90% 5-year survival vs 14% for metastatic disease',
    'Annual FIT testing is alternative if colonoscopy not accessible, but requires colonoscopy if positive',
    'Maintain healthy lifestyle to reduce risk: high fiber, low red/processed meat, maintain healthy weight, exercise, avoid smoking'
  ),

  updated_at = NOW()
WHERE metric_id = 'DISP_COLONOSCOPY_COMPLIANCE';

-- =====================================================
-- 10. MAMMOGRAM COMPLIANCE
-- =====================================================
UPDATE display_metrics
SET
  about_content = 'Mammography uses low-dose X-rays to create detailed breast images, detecting breast cancer at early stages before palpable lumps develop, when treatment is most effective. Screening mammography for asymptomatic women aims to detect cancer early, while diagnostic mammography evaluates specific breast concerns. Modern digital mammography and 3D mammography (tomosynthesis) provide superior detection, particularly for dense breast tissue. Current guidelines show some variation: American Cancer Society recommends women with average risk start annual screening at age 40 (strong recommendation) with option to begin at 45, while USPSTF recommends biennial screening ages 50-74 with individual decision-making for ages 40-49. Women with elevated risk (family history, genetic mutations like BRCA1/2, prior chest radiation, dense breasts) may benefit from earlier screening, annual rather than biennial intervals, supplemental MRI or ultrasound. Dense breast tissue both increases cancer risk and reduces mammography sensitivity, warranting discussion of supplemental screening. Screening detects 20-40% more early-stage cancers than clinical breast exams alone.',

  longevity_impact = 'Mammography screening significantly reduces breast cancer mortality through early detection when treatment is most effective. Meta-analyses of randomized trials show 15-20% breast cancer mortality reduction for women ages 40-49 invited to screening, 20-25% reduction for ages 50-69, with benefits persisting for decades. The Swedish Two-County Trial demonstrated 31% mortality reduction over 29-year follow-up for screening participants. Each year of screening from ages 40-80 prevents approximately 3-4 deaths per 1,000 women screened over their lifetime. Since breast cancer is the second leading cancer cause of death in women (42,000 deaths annually in US), screening creates substantial population-level benefit. However, screening involves tradeoffs: overdiagnosis (detecting cancers that wouldn''t become life-threatening), false positives causing anxiety and additional procedures (60-70% of annual screeners will experience at least one false positive over 10 years), and radiation exposure (extremely low per mammogram but cumulative). The mortality benefit is clearest for women with 10+ year life expectancy. Importantly, screening complements but doesn''t replace risk reduction through lifestyle: maintaining healthy weight, limiting alcohol, exercising regularly, and breastfeeding all reduce breast cancer incidence.',

  quick_tips = jsonb_build_array(
    'Begin annual mammography at age 40 (ACS recommendation) or discuss with provider for individual decision-making',
    'Schedule during first half of menstrual cycle when breasts are least tender for more comfortable exam',
    'Request 3D mammography (tomosynthesis) if available—detects 20-65% more invasive cancers, especially in dense breasts',
    'Know your breast density—if "heterogeneously dense" or "extremely dense," discuss supplemental screening with MRI or ultrasound',
    'Don''t skip screening—5-year survival for localized breast cancer is 99% vs 31% for metastatic disease',
    'Maintain consistency: use the same imaging center when possible so radiologists can compare to prior images',
    'Reduce breast cancer risk through lifestyle: maintain healthy weight, limit alcohol to ≤1 drink daily, exercise 150+ min weekly'
  ),

  updated_at = NOW()
WHERE metric_id = 'DISP_MAMMOGRAM_COMPLIANCE';

-- =====================================================
-- 11. CERVICAL CANCER SCREENING
-- =====================================================
UPDATE display_metrics
SET
  about_content = 'Cervical cancer screening detects precancerous changes (cervical dysplasia) and early cancer through Pap smear (cytology examining cells from cervix for abnormalities) and/or HPV testing (detecting high-risk human papillomavirus strains causing most cervical cancers). Modern screening uses co-testing (Pap + HPV) or primary HPV testing with reflex cytology. Current ASCCP/SGO guidelines recommend: ages 21-29, Pap smear alone every 3 years; ages 30-65, either co-testing every 5 years (preferred) or Pap alone every 3 years or primary HPV every 5 years; after age 65, screening can stop if adequate prior screening was normal. Women who received HPV vaccine still require screening as vaccines don''t cover all cancer-causing HPV types. Screening can stop after total hysterectomy (including cervix removal) for benign reasons, but continues if cervix remains or hysterectomy was for precancer/cancer. HPV infection is extremely common (80% of sexually active adults contract it), but most infections clear within 1-2 years; persistent high-risk HPV infection drives progression to dysplasia and cancer over years to decades.',

  longevity_impact = 'Cervical cancer screening represents one of medicine''s greatest preventive success stories, reducing cervical cancer incidence and mortality by over 70% since Pap smears became routine in the 1950s-1960s. Before widespread screening, cervical cancer was the leading cause of cancer death in American women; now it ranks 14th. The NCI estimates regular screening prevents approximately 75% of potential cervical cancers. When detected at localized stage (which screening accomplishes), cervical cancer has 92% 5-year survival versus 17% for distant-stage disease. Co-testing (Pap + HPV) provides even greater reassurance: negative co-testing confers 99.9% confidence of no precancer/cancer, supporting 5-year intervals. However, screening access disparities persist: approximately half of cervical cancer diagnoses occur in women who haven''t been screened within 5 years, and another 10% have never been screened. Globally, cervical cancer remains fourth-leading cancer cause of death in women, predominantly in low-resource settings lacking screening infrastructure. HPV vaccination (ideally before sexual debut) combined with regular screening offers near-complete cervical cancer prevention. The dramatic success of cervical cancer screening demonstrates the power of evidence-based preventive medicine.',

  quick_tips = jsonb_build_array(
    'Begin screening at age 21 regardless of sexual activity onset; Pap smear every 3 years for ages 21-29',
    'Ages 30-65: co-testing (Pap + HPV) every 5 years preferred, or Pap alone every 3 years, or primary HPV every 5 years',
    'Continue screening until age 65 even after hysterectomy if cervix remains or history of high-grade dysplasia',
    'Get HPV vaccine if age-eligible (approved through age 45)—prevents 90% of HPV-caused cancers',
    'Don''t delay screening: early-stage cervical cancer has 92% 5-year survival vs 17% for advanced disease',
    'After negative co-testing, 5-year interval is safe—more frequent screening increases false positives without benefit',
    'If abnormal results, follow recommended surveillance—most low-grade changes resolve spontaneously but require monitoring'
  ),

  updated_at = NOW()
WHERE metric_id = 'DISP_CERVICAL_COMPLIANCE';

-- =====================================================
-- 12. PSA SCREENING
-- =====================================================
UPDATE display_metrics
SET
  about_content = 'Prostate-Specific Antigen (PSA) is a protein produced by prostate tissue, measurable in blood as a screening tool for prostate cancer. PSA levels rise with prostate cancer but also with benign conditions including benign prostatic hyperplasia (BPH), prostatitis, recent sexual activity, and normal aging. PSA screening is controversial due to tension between benefits (early cancer detection, reduced advanced disease) and harms (overdiagnosis of indolent cancers, false positives, biopsy complications, treatment side effects). Current guidelines emphasize shared decision-making: USPSTF recommends discussing PSA screening for men ages 55-69, with individual decisions based on values and preferences; routine screening not recommended for ages 70+. American Urological Association recommends discussing screening starting at age 45 for average-risk men, age 40 for high-risk (African American ancestry, family history). PSA <4.0 ng/mL traditionally considered normal, but age-specific ranges and PSA velocity (rate of change) provide additional context. Critically, not all prostate cancers require treatment—many are slow-growing and unlikely to cause harm during a man''s lifetime, making active surveillance a valid option for low-risk disease.',

  longevity_impact = 'PSA screening''s impact on mortality shows nuanced benefits and tradeoffs. The European Randomized Study of Screening for Prostate Cancer (ERSPC), following 182,000 men for 16 years, found PSA screening reduced prostate cancer mortality by 20% but required screening 570 men and treating 18 to prevent one prostate cancer death. The US Prostate, Lung, Colorectal, and Ovarian (PLCO) screening trial showed no mortality benefit, though contamination (control group screening) likely diluted results. Updated analyses suggest absolute benefit: PSA screening prevents approximately 1.3 prostate cancer deaths per 1,000 men screened over 13 years. However, harms are substantial: for every 1,000 men screened over decade, approximately 100-120 will have false positive results, 110 will be diagnosed with prostate cancer (many indolent), 70-80 will undergo treatment, with resulting erectile dysfunction in 20-30 and urinary incontinence in 10-15. The key insight: PSA screening reduces death from prostate cancer but hasn''t conclusively reduced all-cause mortality, suggesting offsetting harms. For men choosing screening, ages 55-69 show clearest benefit. After age 70, life expectancy and competing mortality risks should guide decisions.',

  quick_tips = jsonb_build_array(
    'Discuss PSA screening with provider at age 45 (average risk) or 40 (African American, family history)—shared decision-making is key',
    'If screening, frequency depends on PSA level: every 2-4 years if <1.0 ng/mL, annually if 1.0-4.0 ng/mL',
    'Track PSA trends over time—velocity (rate of rise) provides more information than single value',
    'Abnormal PSA requires evaluation but not always biopsy—consider MRI, repeat testing, PSA density calculations',
    'If diagnosed with low-risk prostate cancer, discuss active surveillance—many men never require treatment',
    'Reduce prostate cancer risk through lifestyle: maintain healthy weight, exercise regularly, plant-rich diet, avoid smoking',
    'After age 70, continue screening only if excellent health and 10+ year life expectancy'
  ),

  updated_at = NOW()
WHERE metric_id = 'DISP_PSA_COMPLIANCE';

-- =====================================================
-- 13. SKIN CHECK COMPLIANCE
-- =====================================================
UPDATE display_metrics
SET
  about_content = 'Skin cancer screening involves systematic visual examination of the entire skin surface to detect melanoma, basal cell carcinoma, and squamous cell carcinoma at early, treatable stages. Screening can be performed by dermatologists (expert clinical skin examination), primary care providers, or through self-examination using the ABCDE criteria for melanoma: Asymmetry, Border irregularity, Color variation, Diameter >6mm, and Evolution (changing over time). High-risk individuals include those with fair skin, extensive sun exposure, history of blistering sunburns, family or personal history of skin cancer, many moles (especially atypical/dysplastic nevi), and immunosuppression. While USPSTF concludes evidence is insufficient to recommend for or against routine total-body skin examination in asymptomatic average-risk adults, most dermatology organizations recommend annual full-body exams for high-risk individuals and lower-frequency screening (every 2-3 years) for average risk. Melanoma incidence has tripled over past 30 years, making awareness and screening increasingly important. Dermoscopy and total-body photography enhance detection accuracy and monitoring of changing lesions.',

  longevity_impact = 'Skin cancer screening''s mortality benefit varies dramatically by cancer type. For melanoma—the deadliest skin cancer with 8,000 deaths annually in US—early detection transforms outcomes: 5-year survival is 99% for localized melanoma versus 32% for metastatic disease. Population-level screening effectiveness remains debated: no randomized trials demonstrate mortality reduction from routine screening, yet observational studies suggest benefits. A German screening program examining 360,000 adults found 49% reduced melanoma mortality in screened regions. The key challenge: melanoma screening''s benefit-to-harm ratio depends heavily on baseline risk. For high-risk individuals (personal/family melanoma history, many moles, fair skin, extensive sun exposure), regular dermatology examination clearly valuable. For average-risk individuals, benefits less certain and must be weighed against false positives, unnecessary biopsies, and overdiagnosis. Basal and squamous cell carcinomas are common (5.4 million cases annually in US) but rarely fatal, though they cause significant morbidity and disfigurement. Prevention through sun protection arguably more important than screening: daily broad-spectrum sunscreen use reduces melanoma risk by 50-73% and squamous cell carcinoma by 40%.',

  quick_tips = jsonb_build_array(
    'Perform monthly self-exams using ABCDE criteria; photograph concerning moles to track changes over time',
    'See dermatologist annually if high-risk (fair skin, many moles, personal/family melanoma history, extensive sun damage)',
    'Average-risk individuals: consider dermatologist screening every 2-3 years or if new/changing lesions noted',
    'Apply broad-spectrum SPF 30+ sunscreen daily to all exposed skin—single most important melanoma prevention strategy',
    'Avoid tanning beds entirely—indoor tanning before age 35 increases melanoma risk by 75%',
    'Wear protective clothing, wide-brimmed hats, and UV-blocking sunglasses during sun exposure',
    'Don''t ignore changing lesions—new or changing moles after age 40, especially, warrant dermatologist evaluation'
  ),

  updated_at = NOW()
WHERE metric_id = 'DISP_SKIN_CHECK_COMPLIANCE';

-- =====================================================
-- 14. VISION SCREENING
-- =====================================================
UPDATE display_metrics
SET
  about_content = 'Comprehensive eye examinations screen for vision problems and detect sight-threatening diseases including glaucoma, diabetic retinopathy, age-related macular degeneration, and cataracts, many of which develop asymptomatically in early stages. Complete eye exams include visual acuity testing, refraction assessment, eye muscle movement evaluation, visual field testing, intraocular pressure measurement (tonometry), and dilated fundoscopic examination to visualize the retina, optic nerve, and blood vessels. The American Academy of Ophthalmology recommends comprehensive eye exams for adults: baseline at age 40, every 2-4 years ages 40-54, every 1-3 years ages 55-64, and every 1-2 years after age 65. Higher-risk individuals (diabetes, hypertension, family history of glaucoma/macular degeneration, high myopia) require more frequent monitoring. Optometrists and ophthalmologists both perform comprehensive eye exams, with ophthalmologists (medical doctors) also providing medical/surgical treatment for eye diseases. Vision changes significantly impact quality of life, driving ability, fall risk, cognitive function, and independence in older adults.',

  longevity_impact = 'While eye examinations don''t directly reduce mortality, vision preservation profoundly affects healthspan, functional independence, and quality of life in aging. Vision impairment increases all-cause mortality risk by 26% according to meta-analyses, likely mediated through increased fall risk, social isolation, depression, and reduced physical activity. Falls cause 36,000 deaths annually in older Americans, with vision impairment contributing to fall risk. The Salisbury Eye Evaluation Study found severe vision impairment associated with 2.2x increased mortality over 8 years. For specific conditions, early detection enables sight-preserving interventions: glaucoma screening prevents blindness in 19 of 1,000 screened over lifetime; diabetic retinopathy screening with timely treatment reduces severe vision loss by 50%; age-related macular degeneration treatment (anti-VEGF injections) preserves vision in 90% when started early. Vision also affects cognitive health: the Beaver Dam Eye Study found vision impairment associated with 63% increased dementia risk, possibly through reduced cognitive stimulation and social engagement. Blue Zone populations maintain visual function through lifestyles protecting vascular health (supporting retinal blood flow), high antioxidant intake (protecting retina from oxidative damage), and low diabetes rates (preventing retinopathy).',

  quick_tips = jsonb_build_array(
    'Schedule comprehensive eye exam at age 40, then every 2-4 years through age 54, annually after 65',
    'Diabetics require annual dilated eye exams to detect retinopathy before vision loss occurs',
    'Don''t skip dilated exams—many sight-threatening diseases (glaucoma, retinal tears) are asymptomatic until advanced',
    'Protect eyes from UV damage with UV-blocking sunglasses—reduces cataract and macular degeneration risk',
    'Eat eye-healthy nutrients: lutein/zeaxanthin (leafy greens), omega-3s (fish), vitamin C (citrus), vitamin E (nuts)',
    'Control cardiovascular risk factors (blood pressure, blood sugar, cholesterol) to protect retinal blood vessels',
    'Report sudden vision changes, flashes, floaters, or loss of peripheral vision immediately—may indicate retinal detachment requiring urgent treatment'
  ),

  updated_at = NOW()
WHERE metric_id = 'DISP_VISION_COMPLIANCE';

-- =====================================================
-- 15. BREAST MRI SCREENING
-- =====================================================
UPDATE display_metrics
SET
  about_content = 'Breast MRI uses magnetic resonance imaging to create detailed breast images, offering superior sensitivity for cancer detection compared to mammography, particularly in dense breast tissue. MRI detects 90-95% of invasive breast cancers versus 60-80% for mammography in high-risk women. However, MRI also has higher false positive rates (10-15% versus 5-10% for mammography), leading to additional testing and biopsies. Breast MRI screening is recommended for high-risk women including: BRCA1/2 or other genetic mutation carriers, first-degree relatives of mutation carriers who haven''t been tested, lifetime breast cancer risk ≥20-25% based on risk models, prior chest radiation therapy ages 10-30, and certain genetic syndromes (Li-Fraumeni, Cowden). MRI is not recommended for average-risk women due to high false positive rates and cost outweighing benefits. For high-risk women, annual MRI supplementing mammography (not replacing it) provides optimal surveillance. Breast MRI requires intravenous contrast (gadolinium) and takes 30-45 minutes, with images interpreted by radiologists specialized in breast imaging.',

  longevity_impact = 'For high-risk women, supplemental breast MRI screening significantly improves cancer detection and likely reduces advanced cancer incidence, though randomized trials demonstrating mortality reduction are lacking. The Dutch MRI Screening Study (MRISC) found MRI detected additional 16 cancers per 1,000 high-risk women screened beyond those found by mammography, predominantly small, node-negative invasive cancers with excellent prognosis. Women with BRCA mutations face 50-85% lifetime breast cancer risk (versus 12% general population) and benefit substantially from intensive surveillance combining annual mammography and MRI starting age 25-30, which reduces advanced cancer by approximately 50%. For women with prior chest radiation (e.g., Hodgkin lymphoma treatment), breast cancer risk reaches 20-30% by age 50, making MRI surveillance similarly valuable. However, MRI''s high sensitivity comes with tradeoffs: false positive rates of 10-15% mean 1 in 7-10 MRIs trigger additional workup, creating anxiety and occasional unnecessary biopsies. For average-risk women, these false positives outweigh MRI''s benefits. The critical point: breast MRI is extraordinarily valuable for appropriate high-risk populations but should not be used for routine screening of average-risk women.',

  quick_tips = jsonb_build_array(
    'MRI screening is for high-risk women only: BRCA carriers, ≥20% lifetime risk, prior chest radiation, or certain genetic syndromes',
    'If high-risk, start annual MRI screening at age 25-30 or 10 years before youngest family breast cancer diagnosis',
    'MRI supplements mammography (doesn''t replace)—optimal surveillance combines annual mammography + MRI 6 months apart',
    'Choose breast imaging center with radiologists specialized in breast MRI interpretation for accurate reads',
    'MRI requires IV contrast (gadolinium)—inform radiologist of kidney problems or prior contrast reactions',
    'Consider risk-reducing strategies if high-risk: discuss preventive medications (tamoxifen, raloxifene) or surgery with oncologist',
    'Average-risk women (even with dense breasts) should not routinely undergo MRI—high false positives outweigh benefits'
  ),

  updated_at = NOW()
WHERE metric_id = 'DISP_BREAST_MRI_COMPLIANCE';

-- =====================================================
-- 16. PHYSICAL EXAM COMPLIANCE
-- =====================================================
UPDATE display_metrics
SET
  about_content = 'The annual physical examination (comprehensive preventive health visit) includes medical history review, vital signs measurement, physical examination, age-appropriate screening tests, and health counseling. Components typically include: height, weight, BMI, blood pressure, heart and lung examination, abdominal palpation, skin inspection, lymph node assessment, and gender-specific exams. The visit provides opportunity to review medications, assess immunization status, discuss health behaviors (diet, exercise, tobacco, alcohol), screen for depression and cognitive changes, and order indicated laboratory tests (lipid panel, glucose, kidney function, thyroid, vitamin levels). However, evidence for comprehensive annual physical exams in asymptomatic adults shows mixed results—many components lack proven benefit, while specific targeted screenings (blood pressure, cholesterol, cancer screenings) clearly provide value. Modern preventive care increasingly focuses on condition-specific evidence-based screenings rather than ritualistic annual comprehensive examinations. The USPSTF finds insufficient evidence that annual physicals reduce mortality or morbidity in asymptomatic adults, though the visit facilitates patient-provider relationships and health behavior counseling.',

  longevity_impact = 'Despite widespread practice, randomized trials show general health checks (comprehensive annual physicals) do not reduce all-cause mortality, cardiovascular mortality, or cancer mortality in asymptomatic adults. A Cochrane meta-analysis of 14 trials including 182,000 participants found no mortality benefit from periodic health examinations. However, this doesn''t mean preventive care lacks value—rather, benefit comes from specific evidence-based screenings (blood pressure, cholesterol, diabetes, cancer screenings) and health behavior counseling, not comprehensive physical examination per se. The value lies in ensuring appropriate targeted screenings occur: blood pressure screening reduces cardiovascular mortality, cholesterol screening enables statin therapy for high-risk individuals, diabetes screening allows early intervention, and cancer screenings (colonoscopy, mammography, cervical screening) prevent cancer deaths. Additionally, annual visits facilitate chronic disease management, medication optimization, and health behavior change support. Blue Zone populations rarely access comprehensive annual physical exams yet maintain exceptional health through lifestyle factors, though they benefit from basic health monitoring (blood pressure, weight) and targeted interventions when abnormalities detected. The modern approach: prioritize evidence-based targeted screenings and health optimization counseling over ritualistic comprehensive examinations.',

  quick_tips = jsonb_build_array(
    'Schedule annual preventive visit to ensure age-appropriate evidence-based screenings are current',
    'Focus visit on high-value components: blood pressure, weight, condition-specific screenings, health behavior counseling',
    'Review medications annually—optimize regimens, discontinue unnecessary medications, address side effects',
    'Discuss health priorities: sleep quality, stress management, exercise barriers, nutrition challenges',
    'Ensure recommended screenings are current: lipids (every 5 years if normal), diabetes (every 3 years), cancer screenings',
    'Update immunizations: annual flu, Tdap booster, pneumococcal (65+), shingles (50+), COVID-19',
    'Bring list of current medications, supplements, and health questions—maximize value of visit time'
  ),

  updated_at = NOW()
WHERE metric_id = 'DISP_PHYSICAL_COMPLIANCE';

-- =====================================================
-- CATEGORY 3: MEDICATION/SUPPLEMENT ADHERENCE (3 metrics)
-- =====================================================

-- =====================================================
-- 17. MEDICATION ADHERENCE
-- =====================================================
UPDATE display_metrics
SET
  about_content = 'Medication adherence refers to the degree patients correctly follow prescribed medication regimens, including taking medications at prescribed doses, frequencies, and times. Poor adherence is remarkably common, affecting 30-50% of patients with chronic conditions, resulting from complex interplay of factors: forgetfulness, cost, side effects, complex regimens (multiple medications, multiple daily doses), lack of symptoms (especially for preventive medications like blood pressure or cholesterol drugs), poor understanding of disease/medication importance, and intentional non-adherence based on health beliefs. Non-adherence takes multiple forms: primary non-adherence (never filling prescription), taking incorrect doses, skipping doses, incorrect timing, and premature discontinuation. Adherence measurement includes patient self-report, pill counts, pharmacy refill records, and for select medications, drug level monitoring. Optimal adherence typically defined as taking ≥80% of prescribed doses. Strategies improving adherence include simplifying regimens (once-daily formulations, combination pills), linking medications to daily routines, pill organizers, smartphone reminders, addressing side effects promptly, patient education on medication importance, and reducing cost barriers.',

  longevity_impact = 'Medication non-adherence contributes to 125,000 deaths annually in the US and costs $100-300 billion in preventable healthcare expenditures through disease complications, hospitalizations, and treatment failures. For specific conditions, adherence dramatically affects outcomes: among patients with cardiovascular disease, poor medication adherence increases mortality risk by 50-80%. The REACH registry found patients taking <80% of prescribed cardiovascular medications had 2.2x higher mortality than adherent patients. For hypertension, each 25% decrease in adherence associates with 13% increased cardiovascular events. In diabetes, non-adherence increases hospitalizations by 41% and emergency visits by 30%. Post-myocardial infarction, early statin discontinuation increases mortality by 25%. The paradox: medications only work if taken, yet half of patients with chronic conditions don''t take medications as prescribed. Notably, even "good adherers" (≥80% of doses) may experience gaps with health consequences. Medication adherence proves particularly critical for asymptomatic conditions (hypertension, high cholesterol, diabetes) where patients don''t "feel" benefit, yet consistent medication prevents future heart attacks, strokes, and premature mortality. Improving adherence represents low-hanging fruit for reducing mortality and healthcare costs.',

  quick_tips = jsonb_build_array(
    'Use pill organizers or blister packs to track daily medications and identify missed doses',
    'Link medications to daily routines (with morning coffee, while brushing teeth) to build consistent habits',
    'Set smartphone reminders for medication times—multiple alarms if taking medications more than once daily',
    'Request once-daily formulations and combination pills when possible to simplify regimens',
    'Understand why each medication prescribed—knowing benefits increases motivation for adherence',
    'Report side effects promptly—providers can often adjust medications or dosing to improve tolerability',
    'Use mail-order or automatic refills to prevent running out of chronic medications'
  ),

  updated_at = NOW()
WHERE metric_id = 'DISP_MEDICATION_ADHERENCE';

-- =====================================================
-- 18. SUPPLEMENT ADHERENCE
-- =====================================================
UPDATE display_metrics
SET
  about_content = 'Dietary supplement use is widespread, with 58% of American adults taking at least one supplement. While whole-food nutrition should form the foundation of nutrient intake, targeted supplementation addresses documented deficiencies, supports specific health goals, and compensates for modern diet limitations. Evidence-based supplements for general population include: Vitamin D (deficiency affects 40% of Americans; 2000-4000 IU daily supports bone health, immune function, reduced cancer risk); Omega-3 fatty acids EPA/DHA (1-2g daily for those not consuming fatty fish 2-3x weekly; reduces cardiovascular mortality, supports brain health); Magnesium (common deficiency; 300-400mg daily supports metabolic health, blood pressure, sleep); and Vitamin B12 for adults 50+ (reduced absorption with age; 500-1000 mcg daily). Other potentially beneficial supplements include: creatine monohydrate (for muscle preservation, cognitive function), vitamin K2 (for bone and cardiovascular health), and probiotics (for gut microbiome support). However, most supplements show limited benefit in well-nourished individuals, and some may cause harm: high-dose beta-carotene increases lung cancer risk in smokers, vitamin E supplementation may increase prostate cancer risk, and calcium supplements (without vitamin D) may increase cardiovascular risk. Quality varies enormously—third-party testing (USP, NSF, ConsumerLab) provides some assurance of content accuracy and purity.',

  longevity_impact = 'Evidence for supplement-based longevity benefits remains mixed and highly dependent on baseline nutritional status. For individuals with documented deficiencies, supplementation clearly benefits: correcting vitamin D deficiency (<20 ng/mL) reduces mortality by approximately 15% according to meta-analyses; omega-3 supplementation reduces cardiovascular mortality by 8-10% in meta-analyses of RCTs. The VITAL trial found vitamin D supplementation reduced cancer mortality by 25% (though not cancer incidence), while omega-3s reduced heart attacks by 28% in high-risk individuals. However, for well-nourished individuals without deficiencies, most supplements provide minimal benefit. Large trials show multivitamins don''t reduce mortality, cardiovascular disease, or cancer in generally healthy populations. Some supplements cause harm: the SELECT trial found vitamin E increased prostate cancer risk by 17%; beta-carotene supplementation increased lung cancer by 18% in smokers. The key principle: "food first"—obtain nutrients from whole foods when possible, supplement only for documented deficiencies or specific evidence-based indications. Blue Zone populations consume minimal supplements, obtaining nutrients from diverse whole-food diets, though their sun exposure naturally optimizes vitamin D. The supplement industry largely lacks regulation, making quality, purity, and accurate labeling significant concerns.',

  quick_tips = jsonb_build_array(
    'Prioritize "food first"—obtain nutrients from whole foods; supplement only for documented deficiencies or evidence-based indications',
    'Core supplements with broad evidence: Vitamin D (2000-4000 IU), Omega-3 EPA/DHA (1-2g if not eating fatty fish), Magnesium (300-400mg)',
    'Test before supplementing when possible—vitamin D levels, omega-3 index, B12 (especially if 50+) guide targeted supplementation',
    'Choose quality brands with third-party testing (USP, NSF, ConsumerLab) to ensure content accuracy and purity',
    'Avoid megadoses of individual vitamins/minerals—more isn''t better and some cause harm at high doses',
    'Take fat-soluble vitamins (A, D, E, K) with meals containing fats for optimal absorption',
    'Review supplements with healthcare provider—some interact with medications or are contraindicated in certain conditions'
  ),

  updated_at = NOW()
WHERE metric_id = 'DISP_SUPPLEMENT_ADHERENCE';

-- =====================================================
-- 19. PEPTIDE ADHERENCE
-- =====================================================
UPDATE display_metrics
SET
  about_content = 'Therapeutic peptides are short chains of amino acids used for various health optimization and therapeutic purposes. Unlike traditional small-molecule medications, peptides are large biological molecules that typically require injection (subcutaneous or intramuscular) due to degradation in the digestive system. Peptides used in longevity and performance medicine include: growth hormone secretagogues (promoting natural GH release for muscle preservation and metabolic health), BPC-157 (tissue repair and gut healing), thymosin beta-4 fragments (tissue regeneration, cardiovascular health), and various other peptides targeting inflammation, immune function, and metabolic optimization. The peptide space remains largely unregulated—most peptides used in wellness contexts are not FDA-approved medications (except for specific uses like diabetes management, growth hormone deficiency), instead marketed as research chemicals. Quality, purity, and consistency vary enormously across suppliers. Peptide therapy requires medical supervision to monitor for adverse effects, ensure appropriate dosing, and assess efficacy through objective biomarkers. Storage requirements (often refrigeration), injection technique mastery, and adherence to protocols are critical for peptide effectiveness.',

  longevity_impact = 'Evidence for longevity benefits of most therapeutic peptides remains limited to animal studies, small human trials, and anecdotal reports, with few large-scale RCTs demonstrating mortality or healthspan benefits. The strongest human evidence exists for: metformin (technically not a peptide but often discussed in similar contexts) showing potential mortality reduction in diabetics and ongoing study in TAME trial for aging; and rapamycin analogs showing immune system benefits. For peptides specifically: growth hormone secretagogues may preserve muscle mass and metabolic function in aging but carry theoretical cancer risk concerns (given GH''s proliferative effects); BPC-157 shows promising tissue healing properties in animal models but lacks human RCT data; thymosin peptides demonstrate immune system modulation but limited longevity data. The peptide field suffers from: lack of regulatory oversight, variable quality and purity, limited human safety data, unknown long-term effects, and substantial placebo effects given injection ritual and cost. Theoretical concerns include: excessive growth signaling potentially promoting cancer, immune system dysregulation, and unknown metabolic effects. Some longevity researchers advocate caution, noting that pathways promoting growth (like GH/IGF-1) may reduce lifespan despite short-term functional benefits, contrasting with longevity interventions like caloric restriction that reduce growth signaling.',

  quick_tips = jsonb_build_array(
    'Only use peptides under medical supervision with clear therapeutic rationale and objective outcome monitoring',
    'Source peptides from reputable suppliers with third-party testing certificates of analysis for purity and content',
    'Master proper injection technique, storage (many require refrigeration), and reconstitution procedures',
    'Track objective biomarkers and functional outcomes—subjective "feeling better" insufficient to justify continued use',
    'Understand limited human evidence for most peptides—much data from animal studies may not translate to humans',
    'Be aware of theoretical risks: growth-promoting peptides may increase cancer risk with long-term use',
    'Consider that many purported benefits might come from placebo effects, concurrent lifestyle changes, or natural variation'
  ),

  updated_at = NOW()
WHERE metric_id = 'DISP_PEPTIDE_ADHERENCE';

-- =====================================================
-- CATEGORY 4: SUBSTANCE USE (4 metrics)
-- =====================================================

-- =====================================================
-- 20. ALCOHOL CONSUMPTION
-- =====================================================
UPDATE display_metrics
SET
  about_content = 'Alcohol (ethanol) is a psychoactive substance consumed in beverages including beer, wine, and spirits, with complex dose-dependent effects on health. One standard drink contains approximately 14g of pure alcohol (12oz beer, 5oz wine, 1.5oz spirits). Alcohol metabolism occurs primarily in the liver via alcohol dehydrogenase and aldehyde dehydrogenase enzymes, producing acetaldehyde (toxic, carcinogenic) before conversion to acetate. Low-to-moderate alcohol consumption (≤1 drink daily for women, ≤2 for men) was historically thought to reduce cardiovascular disease risk via HDL increase, anti-inflammatory effects, and improved insulin sensitivity. However, recent large-scale studies and Mendelian randomization analyses challenge the "J-shaped curve," suggesting confounding factors (healthier baseline characteristics of moderate drinkers) explained apparent benefits. The 2023 WHO statement declared "no safe level of alcohol consumption" given cancer risk, liver disease, accidents, and other harms. Even moderate drinking increases breast cancer risk by 10% per daily drink, and any alcohol consumption associates with increased stroke risk, liver damage, and certain cancer types (oral, esophageal, colorectal, liver, breast).',

  longevity_impact = 'Accumulating evidence suggests alcohol''s risks outweigh benefits even at low-to-moderate consumption levels. The Global Burden of Disease study analyzing 195 countries found the level of alcohol consumption minimizing health risk is zero drinks per week. Large-scale Mendelian randomization studies using genetic variants affecting alcohol metabolism find linear relationships between alcohol and cardiovascular disease, stroke, and hypertension—no protective effect at any level. The Million Women Study found even 1 drink daily increased cancer mortality, with each daily drink increasing breast cancer risk 7-12%. For all-cause mortality specifically, large meta-analyses show complex patterns: apparent reduced mortality with light-moderate drinking versus abstainers, but this likely reflects confounding (abstainers include former heavy drinkers with health problems). When comparing light drinkers to lifetime abstainers, mortality advantage disappears. Blue Zone populations show variable alcohol patterns: Sardinians consume moderate red wine with meals, Adventists abstain completely—both achieve exceptional longevity through comprehensive healthy lifestyles. The key point: if you don''t drink, evidence doesn''t support starting for health benefits; if you do drink, minimize consumption (<7 drinks weekly for women, <14 for men at absolute maximum, with lower better).',

  quick_tips = jsonb_build_array(
    'Limit alcohol to ≤7 drinks weekly for women, ≤14 for men; lower consumption better for longevity',
    'Have multiple alcohol-free days weekly—daily drinking increases health risks even at low doses',
    'If consuming alcohol, prefer red wine with meals (resveratrol, polyphenols) over spirits or beer',
    'Never binge drink (≥4 drinks for women, ≥5 for men in 2 hours)—dramatically increases acute and chronic risks',
    'Don''t drink for health benefits—cardiovascular protection can be achieved through exercise, diet, sleep without alcohol''s cancer risk',
    'Alcohol disrupts sleep architecture despite sedating effects—avoid within 3-4 hours of bedtime',
    'Track consumption honestly—many people underestimate intake and "standard drinks" are smaller than typically poured'
  ),

  updated_at = NOW()
WHERE metric_id = 'DISP_ALCOHOL_DRINKS';

-- =====================================================
-- 21. ALCOHOL VS BASELINE
-- =====================================================
UPDATE display_metrics
SET
  about_content = 'Tracking alcohol consumption relative to personal baseline provides insight into behavior change trends, helping identify increases in consumption that may signal unhealthy patterns or decreased intake reflecting successful moderation efforts. Personal baselines vary widely—some individuals maintain lifetime abstinence, others consume 1-2 drinks weekly socially, while problematic drinkers may consume daily or engage in binge drinking. Establishing a baseline requires honest assessment of typical consumption patterns: drinks per week, drinking frequency, typical occasions, maximum consumption in single session. Changes from baseline warrant attention: increasing consumption may indicate stress, depression, social pressure, or developing dependence; decreasing consumption reflects positive health behavior change. The concept of "drinking trajectory" proves important—alcohol consumption tends to peak in young adulthood (ages 21-25) then decline, but individuals who maintain high consumption into middle age face substantially elevated health risks. Monitoring consumption relative to baseline also supports moderation goals: reducing from 14 drinks weekly to 7 significantly reduces health risks even if 7 drinks exceeds ideal. The key is recognizing patterns and trends rather than just absolute numbers.',

  longevity_impact = 'Changes in alcohol consumption patterns over time significantly affect health trajectories and longevity outcomes. Studies tracking drinking patterns across decades find individuals who reduce heavy drinking to moderate levels substantially decrease mortality risk—the British Doctors Study showed former heavy drinkers who cut consumption to moderate levels reduced cardiovascular mortality by 40%. Conversely, individuals who increase consumption over time show accelerated disease progression: the Whitehall Study found men increasing alcohol intake from light to moderate/heavy showed 30% increased cardiovascular events. Particularly concerning: individuals maintaining heavy drinking (15+ drinks weekly) from young adulthood into middle age show dramatically elevated risks—the CARDIA study found persistent heavy drinkers had 50% higher hypertension, 3x higher liver enzyme abnormalities, and accelerated coronary calcium accumulation by age 50. The "drinking trajectory" concept proves critical for longevity: reducing consumption from any baseline improves outcomes. Even modest reductions matter—cutting from 14 to 7 drinks weekly reduces breast cancer risk, liver damage, and hypertension. Blue Zone populations demonstrate stable, low consumption patterns lifelong (if drinking at all), avoiding both extremes of heavy drinking and the binge-abstain cycling common in modern societies.',

  quick_tips = jsonb_build_array(
    'Track weekly alcohol consumption to establish accurate baseline—many people underestimate their intake',
    'Set reduction goals if consuming >7 drinks weekly (women) or >14 weekly (men)—gradual reduction sustainable',
    'Identify triggers for increased drinking (stress, social situations, boredom) and develop alternative coping strategies',
    'Celebrate reductions from baseline even if not reaching "ideal"—cutting from 14 to 7 drinks weekly significantly improves health',
    'Be alert to gradual intake increases over time—"lifestyle creep" can normalize problematic consumption patterns',
    'If unable to reduce consumption despite health concerns, discuss with healthcare provider—may indicate dependence requiring treatment',
    'Replace drinking occasions with healthier alternatives: exercise, social activities, hobbies, stress management practices'
  ),

  updated_at = NOW()
WHERE metric_id = 'DISP_ALCOHOL_VS_BASELINE';

-- =====================================================
-- 22. CIGARETTE SMOKING
-- =====================================================
UPDATE display_metrics
SET
  about_content = 'Cigarette smoking involves inhaling smoke from burning tobacco, exposing the body to over 7,000 chemicals including at least 70 known carcinogens (cancer-causing substances). Nicotine—the primary addictive component—reaches the brain within 10 seconds of inhalation, triggering dopamine release that reinforces addiction. Beyond nicotine, combustion produces carbon monoxide (reducing oxygen delivery), tar (depositing in lungs and airways), heavy metals (cadmium, arsenic, lead), volatile organic compounds, and oxidizing chemicals causing inflammation and cellular damage throughout the body. Smoking damages nearly every organ system: respiratory (COPD, lung cancer, chronic bronchitis), cardiovascular (atherosclerosis, heart attack, stroke, peripheral artery disease), cancer (lung, throat, mouth, esophagus, bladder, kidney, pancreas, cervix, stomach, colon), immune (increased infections, impaired wound healing), metabolic (insulin resistance, diabetes risk), and reproductive (erectile dysfunction, reduced fertility, pregnancy complications). Smoking also accelerates aging processes including skin wrinkling, bone density loss, cognitive decline, and telomere shortening. E-cigarettes and vaping, while potentially less harmful than combustible tobacco, still deliver nicotine and various toxic chemicals with unknown long-term effects.',

  longevity_impact = 'Cigarette smoking represents the single most preventable cause of death globally, responsible for 480,000 deaths annually in the US and 8 million worldwide—reducing life expectancy by approximately 10 years for long-term smokers. The relationship is dose-dependent: the British Doctors Study following physicians for 50 years found those who smoked throughout adulthood died on average 10 years earlier than never-smokers, with two-thirds of long-term smokers dying from smoking-related diseases. Each cigarette smoked reduces life expectancy by approximately 11 minutes. Smoking increases mortality from multiple causes: lung cancer (90% of cases caused by smoking), COPD (80% of cases), cardiovascular disease (doubles risk), and 13 other cancer types. The Million Women Study found smokers have 3x higher mortality rate than never-smokers. However, cessation benefits are substantial regardless of age: quitting before age 40 eliminates nearly all excess mortality risk (returning to near never-smoker levels); quitting by age 50 cuts excess mortality by 50%; even quitting at age 60 adds 3 years life expectancy. Cardiovascular risk drops by 50% within 1 year of quitting; lung cancer risk is halved by 10 years post-cessation. Blue Zone populations have minimal smoking rates, with communities'' exceptional longevity partly attributed to low tobacco use combined with comprehensive healthy lifestyles.',

  quick_tips = jsonb_build_array(
    'Quit smoking completely—the single most important longevity intervention for smokers, benefiting at any age',
    'Use evidence-based cessation methods: nicotine replacement (patches, gum, lozenges), medications (varenicline, bupropion), counseling',
    'Expect 3-6 attempts before successful long-term cessation—relapse is normal, each attempt increases eventual success odds',
    'First 2 weeks are hardest—cravings peak then gradually diminish; prepare strategies for triggers (stress, alcohol, social situations)',
    'Benefits begin immediately: heart rate and blood pressure drop within 20 minutes; circulation and lung function improve within weeks',
    'Avoid switching to e-cigarettes as "safer alternative"—best to quit nicotine entirely; if needed, use NRT or e-cigs as temporary cessation bridge only',
    'Join quit-smoking programs (1-800-QUIT-NOW)—counseling doubles cessation success rates'
  ),

  updated_at = NOW()
WHERE metric_id = 'DISP_CIGARETTES';

-- =====================================================
-- 23. CIGARETTES VS BASELINE
-- =====================================================
UPDATE display_metrics
SET
  about_content = 'Tracking cigarette consumption relative to personal baseline provides critical insight into smoking behavior changes, supporting harm reduction efforts even when complete cessation remains the ultimate goal. Baseline varies from never-smoker to occasional social smoker (few cigarettes monthly) to daily smoker (ranging from <10 cigarettes daily to 20+ cigarettes, the "pack-a-day" threshold). While no safe level of smoking exists, dose-response relationships mean reducing cigarette consumption decreases health risks. Cutting from 20 to 10 cigarettes daily reduces cancer risk by approximately 30% and cardiovascular risk by 20%, though risks remain substantially elevated versus quitting entirely. The "reduction-to-quit" approach helps some smokers: gradually decreasing consumption while preparing for complete cessation. However, many "reducers" compensate by smoking remaining cigarettes more intensively (deeper inhalations, holding smoke longer, smoking cigarettes closer to the filter), partially offsetting benefits. Additionally, reduction without eventual cessation provides limited long-term benefit—any ongoing smoking maintains addiction, cardiovascular damage, and cancer risk. Tracking versus baseline helps identify concerning increases (stress-related smoking escalation) and encourages reductions, while emphasizing that complete cessation remains the health-optimal goal.',

  longevity_impact = 'Research on smoking reduction without cessation shows modest health benefits but dramatically smaller than complete cessation. The Alpha-Tocopherol, Beta-Carotene Cancer Prevention Study found smokers who reduced consumption by 50% decreased lung cancer risk by 27%, compared to 80-90% reduction with complete cessation. For cardiovascular disease, the Nurses'' Health Study showed women reducing from 15+ to 1-4 cigarettes daily decreased heart disease risk by 43%, though risk remained 5x higher than never-smokers. Critically, most studies find "reducers" still smoke enough to maintain nicotine addiction and many eventually return to previous consumption levels. The key insight: while reduction provides some benefit if cessation isn''t immediately achievable, it should serve as a bridge to complete cessation, not an endpoint. Light smoking (1-5 cigarettes daily) still carries substantial risks: 1.5x mortality risk, 2-3x lung cancer risk, and similar cardiovascular damage to heavier smoking in some studies (suggesting cardiovascular effects plateau at low doses). Conversely, quitting entirely provides dramatic benefits: 10-year cessation reduces lung cancer risk by 50%; cardiovascular risk approaches never-smokers within 5-15 years. Blue Zone populations demonstrate minimal tobacco use throughout life, with communities'' longevity partly attributed to avoiding smoking initiation rather than requiring later cessation.',

  quick_tips = jsonb_build_array(
    'Ultimate goal is complete cessation—reduction beneficial as temporary step but insufficient for optimal health',
    'If complete cessation feels overwhelming, reduce by 25-50% while preparing quit plan—some benefit better than none',
    'Avoid "compensatory smoking" when reducing—don''t inhale more deeply or smoke remaining cigarettes more intensively',
    'Use reduction period to identify triggers and develop cessation strategies: stress management, routine changes, social support',
    'Set quit date within 3-6 months of reduction initiation—reduction alone maintains addiction and limits long-term benefits',
    'Track reduction progress to maintain motivation, but remain focused on eventual complete cessation',
    'Work with healthcare provider on cessation plan: nicotine replacement, medications (varenicline, bupropion), and counseling support'
  ),

  updated_at = NOW()
WHERE metric_id = 'DISP_CIGARETTES_VS_BASELINE';

-- =====================================================
-- CATEGORY 5: DAILY ROUTINES (5 metrics)
-- =====================================================

-- =====================================================
-- 24. MORNING ROUTINE (for context - not in Core Care but mentioned)
-- =====================================================
-- Note: Morning routine not in Core Care but including for completeness if metric exists

-- =====================================================
-- 25. EVENING ROUTINE
-- =====================================================
UPDATE display_metrics
SET
  about_content = 'A consistent evening routine comprises structured activities in the hours before bedtime that signal the body to transition from active daytime mode to restorative sleep mode. Evidence-based evening routine components include: light dimming (reducing blue light exposure to allow melatonin rise), temperature reduction (cool bedroom 65-68°F optimizes sleep), digital device cessation (screens suppress melatonin), relaxing activities (reading, gentle stretching, meditation, journaling), sleep schedule consistency (same bedtime ±30 minutes), caffeine avoidance (>8 hours before bed), alcohol limitation (>3 hours before bed), large meal avoidance (>3 hours before bed), and stress processing rather than rumination. The routine serves multiple physiological functions: it entrains the circadian system through consistent timing cues, reduces sympathetic nervous system activation (stress response), promotes parasympathetic activation (rest-and-digest), allows melatonin rise through darkness exposure, and provides psychological transition from day to night. Evening routines prove particularly important in modern society where artificial light, digital stimulation, irregular schedules, and late-night eating disrupt natural sleep-wake cycles.',

  longevity_impact = 'While evening routines haven''t been studied independently for mortality effects, their components strongly associate with sleep quality—and sleep quality powerfully predicts longevity. The Whitehall II study found irregular sleep schedules (varying bedtime >2 hours) associated with 30% increased cardiovascular disease risk. Evening blue light exposure suppresses melatonin by 50% and delays circadian phase by 1-3 hours, reducing sleep quality which associates with 12% increased mortality in meta-analyses. The Hispanic Community Health Study found eating within 3 hours of bedtime associated with 44% increased hypertension and 82% increased diabetes risk. Evening alcohol consumption fragments sleep architecture, reducing restorative deep and REM sleep—the Sleep Heart Health Study linked poor sleep quality to 45% increased cardiovascular mortality. Conversely, consistent sleep routines predict longevity markers: the Nurses'' Health Study found women with regular sleep schedules had lower inflammatory markers (CRP, IL-6) predicting reduced mortality. Blue Zone populations maintain natural evening routines: early dinners (5-7pm), minimal artificial light after sunset, social connection in evening hours, and consistent sleep schedules aligned with natural light-dark cycles. These routines support the 7-9 hours quality sleep consistently associated with optimal longevity outcomes.',

  quick_tips = jsonb_build_array(
    'Establish consistent bedtime within 30-minute window—circadian system thrives on regularity',
    'Dim lights 2-3 hours before bed and eliminate screens 1 hour before bed to allow melatonin rise',
    'Create relaxing pre-bed ritual: light reading, gentle stretching, meditation, warm bath, or journaling',
    'Cool bedroom to 65-68°F—body temperature drop triggers sleep onset',
    'Process stress earlier in evening through journaling or discussion—avoid rumination immediately before bed',
    'Finish dinner 3+ hours before bedtime to allow digestion and prevent insulin/glucose disruption of sleep',
    'Reserve bedroom for sleep and intimacy only—avoid TV, work, phone use in bed to strengthen sleep association'
  ),

  updated_at = NOW()
WHERE metric_id = 'DISP_EVENING_ROUTINE';

-- =====================================================
-- 26. DIGITAL SHUTOFF
-- =====================================================
UPDATE display_metrics
SET
  about_content = 'Digital shutoff refers to cessation of screen-based device use (smartphones, tablets, computers, TV) before bedtime to minimize sleep disruption from blue light exposure and psychological stimulation. Modern screens emit high-intensity blue light (450-480nm wavelength) that potently suppresses melatonin—the hormone signaling darkness and sleep onset. Blue light exposure activates intrinsically photosensitive retinal ganglion cells containing melanopsin, which signal the brain''s suprachiasmatic nucleus (master circadian clock) that it''s daytime, suppressing pineal melatonin secretion. Evening screen use causes 30-50% melatonin suppression, 1-3 hour circadian phase delay, reduced total sleep time, decreased REM sleep, and impaired next-day alertness. Beyond blue light, digital content creates psychological arousal: social media triggers emotional responses and FOMO (fear of missing out), work emails activate stress responses, news consumption increases anxiety, and engaging content stimulates reward pathways making sleep difficult. Research consistently shows >1 hour daily screen time before bed reduces sleep quality and duration. Effective digital shutoff involves: setting specific cutoff time (ideally 60-90 minutes before bed), using app blockers or device "bedtime mode," keeping phones outside bedroom, and replacing screen time with relaxing activities.',

  longevity_impact = 'Evening screen use disrupts sleep quality and duration—and poor sleep powerfully predicts mortality and chronic disease. Meta-analyses show short sleep duration (<6 hours) associates with 12% increased mortality risk, while poor sleep quality independent of duration increases mortality by 15%. The mechanisms linking evening screen use to health risks operate primarily through sleep disruption: the Study of Women''s Health Across the Nation found each hour of evening screen time reduced sleep duration by 15-20 minutes, and women with <6 hours sleep had 53% increased diabetes risk and 48% increased cardiovascular disease risk. The Nurses'' Health Study showed women with poor sleep quality had higher inflammatory markers (CRP, IL-6) predicting increased mortality. Beyond sleep, evening blue light may have direct metabolic effects: evening light exposure increases insulin resistance, raises evening blood glucose, and may promote weight gain—the Blue Light Study found evening blue light exposure increased hunger and insulin resistance. For adolescents, screen use before bed particularly disrupts development: the ABCD Study found >2 hours daily screen time associated with lower cognitive scores, and screen use after 9pm associated with reduced sleep and worse academic performance. Blue Zone populations naturally avoid this modern problem through minimal technology use, early sleep times, and social evening activities rather than solitary screen time.',

  quick_tips = jsonb_build_array(
    'Implement strict "digital sunset" 60-90 minutes before bedtime—all screens off including TV, phone, tablet, computer',
    'Use app blockers, screen time limits, or "bedtime mode" to enforce digital shutoff automatically',
    'Keep phone charging outside bedroom—removes temptation and eliminates sleep disruption from notifications',
    'If screens necessary in evening, use blue light filters, "night shift" mode, or amber-tinted glasses (blocks 99% blue light)',
    'Replace evening screen time with relaxing activities: reading physical books, conversation, stretching, meditation',
    'If checking phone upon waking is habit, replace with healthier routine: natural light exposure, hydration, movement',
    'Consider "screen-free bedroom" rule for entire household—improves sleep for all family members'
  ),

  updated_at = NOW()
WHERE metric_id = 'DISP_DIGITAL_SHUTOFF';

-- =====================================================
-- 27. SKINCARE ROUTINE
-- =====================================================
UPDATE display_metrics
SET
  about_content = 'A comprehensive skincare routine protects skin health through cleansing, moisturization, and sun protection while potentially slowing visible aging through evidence-based topical treatments. Basic routine includes: gentle daily cleansing (removing dirt, oil, environmental pollutants without stripping skin barrier), moisturizer (hydrating and protecting skin barrier function), and broad-spectrum sunscreen SPF 30-50 (preventing UV-induced DNA damage, photoaging, and skin cancer). Advanced evidence-based additions include: retinoids (vitamin A derivatives that increase cell turnover, stimulate collagen production, reduce fine lines, and may reduce cancer risk), vitamin C (antioxidant protecting against free radical damage and supporting collagen synthesis), niacinamide (anti-inflammatory, strengthens skin barrier), and alpha-hydroxy acids (gentle exfoliation improving texture). Skin represents the body''s largest organ and primary barrier against environmental stressors including UV radiation, pollution, pathogens, and dehydration. Skin health reflects both intrinsic aging (genetic, hormonal) and extrinsic aging (UV exposure, smoking, pollution, sleep deprivation, stress, nutrition). Photoaging from UV exposure accounts for 80-90% of visible facial aging including wrinkles, pigmentation, texture changes, and loss of elasticity.',

  longevity_impact = 'While skincare routine doesn''t directly affect mortality, sun protection component proves critical for skin cancer prevention—and skin cancer represents the most common cancer type with 5.4 million cases annually in the US. Daily broad-spectrum sunscreen use reduces melanoma risk by 50-73%, squamous cell carcinoma by 40%, and basal cell carcinoma by 30% according to Australian long-term studies. The Nambour Skin Cancer Prevention Trial found daily sunscreen use reduced development of new melanoma and squamous cell carcinoma by approximately 50% over 10 years. Since melanoma causes 8,000 deaths annually in the US, consistent sun protection prevents substantial mortality. Beyond cancer prevention, photoaging research shows daily sunscreen use slows visible skin aging: the Queensland study found adults using daily sunscreen showed 24% less skin aging over 4.5 years compared to discretionary use. Retinoid use may reduce skin cancer risk: studies show topical tretinoin reduces actinic keratoses (precancerous lesions) by 50-70%. The connection to healthspan involves quality of life: maintaining functional, healthy skin supports physical comfort, temperature regulation, infection barrier, and psychological wellbeing. Blue Zone populations maintain healthy skin through outdoor active lifestyles (building sun tolerance), whole-food diets rich in antioxidants (carotenoids, vitamins C and E protecting skin), adequate hydration, and minimal processed food/sugar consumption (reducing glycation-related skin aging).',

  quick_tips = jsonb_build_array(
    'Apply broad-spectrum SPF 30-50 sunscreen daily to all exposed skin—single most important anti-aging and cancer-prevention skincare step',
    'Use gentle cleanser morning and evening—avoid harsh soaps that strip skin barrier',
    'Apply moisturizer twice daily to maintain skin barrier function and hydration',
    'Consider retinoid (tretinoin, adapalene, retinol) at night—strongest evidence for reducing fine lines and may reduce cancer risk',
    'Reapply sunscreen every 2 hours during extended sun exposure and after swimming/sweating',
    'Wear UV-protective clothing, wide-brimmed hats, and sunglasses during outdoor activities',
    'Support skin health from inside: stay hydrated, eat antioxidant-rich foods (berries, vegetables), avoid smoking, prioritize sleep'
  ),

  updated_at = NOW()
WHERE metric_id = 'DISP_SKINCARE_ROUTINE';

-- =====================================================
-- 28. DENTAL CARE - BRUSHING
-- =====================================================
UPDATE display_metrics
SET
  about_content = 'Tooth brushing mechanically removes dental plaque—a biofilm of bacteria, food particles, and salivary proteins—from tooth surfaces to prevent dental caries (cavities), gingivitis (gum inflammation), and periodontitis (advanced gum disease with bone loss). Optimal brushing involves: twice-daily brushing for 2 minutes each session, using soft-bristled toothbrush at 45-degree angle to gumline, gentle circular motions (avoiding aggressive horizontal scrubbing that damages enamel and gums), fluoride toothpaste (1000-1500 ppm fluoride strengthens enamel and prevents decay), brushing all tooth surfaces including hard-to-reach back molars and tongue side of teeth. Electric toothbrushes with oscillating-rotating or sonic technology demonstrate superior plaque removal versus manual brushing in most studies. Fluoride toothpaste works through multiple mechanisms: remineralizing early enamel lesions, inhibiting bacterial metabolism, and incorporating into enamel structure for acid resistance. Proper brushing technique matters enormously—many people brush for insufficient duration (<90 seconds), miss tooth surfaces (particularly inner surfaces and back molars), brush too aggressively (causing gum recession and enamel wear), or brush immediately after acidic foods/drinks (when enamel is temporarily softened).',

  longevity_impact = 'Oral health, maintained substantially through proper tooth brushing, shows surprising associations with systemic health and mortality. The Oral Infections and Vascular Disease Epidemiology Study (INVEST) found tooth brushing <once daily associated with 30% increased cardiovascular events compared to twice-daily brushing. Multiple large-scale studies demonstrate periodontal disease (which brushing helps prevent) increases all-cause mortality by 20-60% depending on severity. The mechanisms involve chronic low-grade inflammation: bacteria from periodontal disease enter bloodstream, triggering inflammatory responses and potentially contributing to atherosclerosis, diabetes, respiratory disease, and cognitive decline. The Health Professionals Follow-up Study found men with periodontal disease had 53% increased pancreatic cancer risk. For cardiovascular disease specifically, the Atherosclerosis Risk in Communities (ARIC) study showed severe periodontitis associated with 2-3x increased heart disease and stroke risk. Poor oral health also affects nutrition through tooth loss, reducing ability to consume healthy foods like raw vegetables, nuts, and lean proteins. The National Health and Nutrition Examination Survey found adults with 25+ remaining teeth had better nutritional status and lower mortality than those with fewer teeth. Blue Zone populations maintain functional dentition into advanced age through lifelong oral hygiene, low-sugar diets minimizing decay, and active chewing of whole foods supporting jaw and tooth health.',

  quick_tips = jsonb_build_array(
    'Brush twice daily for 2 full minutes each time—morning after breakfast and evening before bed',
    'Use soft-bristled brush at 45-degree angle to gumline with gentle circular motions',
    'Use fluoride toothpaste (1000-1500 ppm)—spit but don''t rinse after brushing to maintain fluoride contact',
    'Consider electric toothbrush (oscillating-rotating or sonic)—studies show 11-21% better plaque removal than manual',
    'Replace toothbrush every 3 months or sooner if bristles frayed',
    'Don''t brush immediately after acidic foods/drinks (citrus, soda, wine)—wait 30-60 minutes when enamel has rehardened',
    'Brush gently—aggressive brushing causes gum recession and enamel wear without improving cleaning'
  ),

  updated_at = NOW()
WHERE metric_id = 'DISP_BRUSHING_SESSIONS';

-- =====================================================
-- 29. DENTAL CARE - FLOSSING
-- =====================================================
UPDATE display_metrics
SET
  about_content = 'Dental flossing removes plaque and food debris from between teeth (interproximal spaces) and below the gumline—areas toothbrush bristles cannot effectively reach. Interdental cleaning proves critical because tooth decay and gum disease frequently begin in these hard-to-clean areas where bacteria accumulate undisturbed. Proper flossing technique involves: using 18 inches of floss (fresh section for each tooth), gently guiding floss between teeth using sawing motion, curving floss into C-shape around each tooth, sliding floss up and down against tooth surface and slightly below gumline, using clean section for each interproximal space. Alternative interdental cleaning tools include: interdental brushes (small brushes fitting between teeth, particularly effective for wide gaps), water flossers (using pressurized water, beneficial for braces or bridges but potentially less effective than string floss for plaque removal), floss picks (convenient but require many picks to avoid spreading bacteria), and air flossers. The American Dental Association recommends interdental cleaning once daily. Evidence quality varies: while mechanistic plausibility is strong (removing bacteria reduces disease), randomized trials show mixed results for flossing preventing cavities or gingivitis, possibly reflecting poor flossing technique in studies rather than lack of benefit when done correctly.',

  longevity_impact = 'The flossing-longevity connection operates through periodontal disease prevention, which associates with cardiovascular disease, diabetes, and mortality. Systematic reviews show dental floss plus toothbrushing reduces gingivitis by 17-60% versus brushing alone, though quality of evidence varies across studies. The critical insight: periodontal disease doesn''t begin on easy-to-clean tooth surfaces but rather in interproximal areas and gum pockets—precisely where flossing targets. The Health Professionals Follow-up Study found periodontal disease (which interdental cleaning helps prevent) associated with 25% increased heart disease risk and 10% increased all-cause mortality. Proposed mechanisms include: bacteria from periodontal pockets entering bloodstream (bacteremia), chronic systemic inflammation (elevated CRP, IL-6), contribution to atherosclerotic plaque formation, and increased insulin resistance. The ARIC study showed severe periodontitis associated with 2.3x increased stroke risk. While no randomized trials demonstrate flossing reduces cardiovascular events or mortality (such trials would be impractical), the mechanistic chain from flossing → reduced periodontal disease → reduced inflammation → reduced cardiovascular risk is biologically plausible. Dentists near-universally recommend flossing based on clinical observation and pathophysiological understanding. Blue Zone populations maintain healthy dentition through comprehensive oral hygiene, low-sugar diets preventing decay, and whole-food diets requiring chewing that supports jaw and gum health.',

  quick_tips = jsonb_build_array(
    'Floss once daily, preferably before bedtime brushing—evening flossing removes accumulated food and bacteria',
    'Use 18 inches of floss with fresh section for each tooth to avoid transferring bacteria',
    'Curve floss into C-shape around each tooth and slide up/down against tooth surface—don''t just pop in and out',
    'Gently guide floss 2-3mm below gumline where bacteria accumulate—should not cause bleeding if done correctly (though bleeding initially normal if gingivitis present)',
    'If traditional floss difficult, try alternatives: interdental brushes (particularly effective), water flosser, or floss picks',
    'Be patient if starting flossing routine—gums may bleed initially but should stop within 1-2 weeks as inflammation resolves',
    'Combine with regular dental cleanings (every 6 months)—professional cleaning removes hardened plaque (calculus) that home care cannot eliminate'
  ),

  updated_at = NOW()
WHERE metric_id = 'DISP_FLOSSING_SESSIONS';

-- =====================================================
-- VERIFICATION
-- =====================================================

DO $$
DECLARE
  v_updated_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_updated_count
  FROM display_metrics
  WHERE metric_id IN (
    'DISP_WEIGHT', 'DISP_HEIGHT', 'DISP_BMI', 'DISP_BODY_FAT_PCT', 'DISP_WAIST_HIP_RATIO',
    'DISP_SYSTOLIC_BP', 'DISP_DIASTOLIC_BP', 'DISP_AGE',
    'DISP_COLONOSCOPY_COMPLIANCE', 'DISP_MAMMOGRAM_COMPLIANCE', 'DISP_CERVICAL_COMPLIANCE',
    'DISP_PSA_COMPLIANCE', 'DISP_SKIN_CHECK_COMPLIANCE', 'DISP_VISION_COMPLIANCE',
    'DISP_BREAST_MRI_COMPLIANCE', 'DISP_PHYSICAL_COMPLIANCE',
    'DISP_MEDICATION_ADHERENCE', 'DISP_SUPPLEMENT_ADHERENCE', 'DISP_PEPTIDE_ADHERENCE',
    'DISP_ALCOHOL_DRINKS', 'DISP_ALCOHOL_VS_BASELINE', 'DISP_CIGARETTES', 'DISP_CIGARETTES_VS_BASELINE',
    'DISP_EVENING_ROUTINE', 'DISP_DIGITAL_SHUTOFF', 'DISP_SKINCARE_ROUTINE',
    'DISP_BRUSHING_SESSIONS', 'DISP_FLOSSING_SESSIONS'
  )
  AND about_content IS NOT NULL;

  RAISE NOTICE '';
  RAISE NOTICE '=======================================================';
  RAISE NOTICE 'CORE CARE EDUCATIONAL CONTENT - MIGRATION COMPLETE';
  RAISE NOTICE '=======================================================';
  RAISE NOTICE '';
  RAISE NOTICE 'Updated % Core Care metrics with comprehensive educational content', v_updated_count;
  RAISE NOTICE '';
  RAISE NOTICE 'Categories Covered:';
  RAISE NOTICE '  • Biometrics (8): Weight, Height, BMI, Body Fat %%, Waist-Hip Ratio, Blood Pressure, Age';
  RAISE NOTICE '  • Preventive Screenings (8): Colonoscopy, Mammogram, Cervical, PSA, Skin, Vision, Breast MRI, Physical';
  RAISE NOTICE '  • Medication Adherence (3): Medications, Supplements, Peptides';
  RAISE NOTICE '  • Substance Use (4): Alcohol consumption and baseline, Cigarettes and baseline';
  RAISE NOTICE '  • Daily Routines (5): Evening routine, Digital shutoff, Skincare, Brushing, Flossing';
  RAISE NOTICE '';
  RAISE NOTICE 'Content Focus:';
  RAISE NOTICE '  • Evidence-based preventive medicine and screening efficacy';
  RAISE NOTICE '  • Biomarker optimization for longevity';
  RAISE NOTICE '  • Large-scale prospective cohort study data';
  RAISE NOTICE '  • Blue Zone population patterns';
  RAISE NOTICE '  • Practical implementation strategies';
  RAISE NOTICE '';
END $$;

-- Summary query
SELECT
  metric_id,
  metric_name,
  CASE
    WHEN about_content IS NOT NULL THEN '✓'
    ELSE '✗'
  END as has_about,
  CASE
    WHEN longevity_impact IS NOT NULL THEN '✓'
    ELSE '✗'
  END as has_longevity,
  CASE
    WHEN quick_tips IS NOT NULL THEN '✓'
    ELSE '✗'
  END as has_tips,
  jsonb_array_length(quick_tips) as tip_count,
  LENGTH(about_content) as about_chars,
  LENGTH(longevity_impact) as longevity_chars
FROM display_metrics
WHERE metric_id IN (
  'DISP_WEIGHT', 'DISP_HEIGHT', 'DISP_BMI', 'DISP_BODY_FAT_PCT', 'DISP_WAIST_HIP_RATIO',
  'DISP_SYSTOLIC_BP', 'DISP_DIASTOLIC_BP', 'DISP_AGE',
  'DISP_COLONOSCOPY_COMPLIANCE', 'DISP_MAMMOGRAM_COMPLIANCE', 'DISP_CERVICAL_COMPLIANCE',
  'DISP_PSA_COMPLIANCE', 'DISP_SKIN_CHECK_COMPLIANCE', 'DISP_VISION_COMPLIANCE',
  'DISP_BREAST_MRI_COMPLIANCE', 'DISP_PHYSICAL_COMPLIANCE',
  'DISP_MEDICATION_ADHERENCE', 'DISP_SUPPLEMENT_ADHERENCE', 'DISP_PEPTIDE_ADHERENCE',
  'DISP_ALCOHOL_DRINKS', 'DISP_ALCOHOL_VS_BASELINE', 'DISP_CIGARETTES', 'DISP_CIGARETTES_VS_BASELINE',
  'DISP_EVENING_ROUTINE', 'DISP_DIGITAL_SHUTOFF', 'DISP_SKINCARE_ROUTINE',
  'DISP_BRUSHING_SESSIONS', 'DISP_FLOSSING_SESSIONS'
)
ORDER BY metric_id;

COMMIT;
