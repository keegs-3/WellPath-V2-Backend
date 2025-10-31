#!/usr/bin/env python3
"""
Add comprehensive education content for 14 missing biometrics.

Missing Biometrics:
- Blood Pressure (Diastolic), Deep Sleep, DunedinPACE, Grip Strength,
  Height, Hip-to-Waist Ratio, OMICmAge, REM Sleep,
  Skeletal Muscle Mass to Fat-Free Mass, Steps/Day, Visceral Fat,
  Water Intake, WellPath PACE, WellPath PhenoAge
"""

import psycopg2

DATABASE_URL = "postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres"

# =============================================================================
# BIOMETRIC EDUCATION CONTENT - 14 MISSING BIOMETRICS
# =============================================================================

BIOMETRIC_EDUCATION_REMAINING = {

    'Blood Pressure (Diastolic)': {
        'education': """**Understanding Diastolic Blood Pressure**

Diastolic blood pressure (the bottom number) measures the pressure in your arteries when your heart rests between beats. It reflects the resistance in your blood vessels and vascular health.

**The Longevity Connection:**
- Elevated diastolic pressure increases heart disease risk
- High diastolic BP damages blood vessel walls
- Associated with stroke risk, especially in younger adults
- Reflects arterial stiffness and vascular health
- Both high and very low diastolic pressure problematic
- Optimal diastolic BP crucial for brain health and dementia prevention

**Optimal Ranges:**
- Optimal: 60-80 mmHg
- Normal: 60-80 mmHg
- Elevated: 80-89 mmHg
- Stage 1 Hypertension: 90-99 mmHg
- Stage 2 Hypertension: ≥100 mmHg
- Too low: <60 mmHg (may indicate issues)

**Why Both Numbers Matter:**
- Systolic (top): Pressure when heart beats
- Diastolic (bottom): Pressure when heart rests
- Pulse pressure (difference): Reflects arterial stiffness
- Isolated diastolic hypertension more common in younger adults
- Both contribute to cardiovascular risk

**Causes of High Diastolic Pressure:**
- Excess sodium intake
- Chronic stress
- Obesity
- Physical inactivity
- Excessive alcohol consumption
- Smoking
- Sleep apnea
- Kidney disease
- Thyroid disorders
- Certain medications

**How to Lower Diastolic Blood Pressure:**

**Dietary Approaches (Most Effective):**
- DASH diet (Dietary Approaches to Stop Hypertension)
- Reduce sodium to <2,300mg (ideally <1,500mg)
- Increase potassium-rich foods (bananas, sweet potatoes, spinach)
- Increase magnesium-rich foods (nuts, seeds, leafy greens)
- Limit processed foods
- Reduce alcohol consumption
- Increase fruits and vegetables
- Whole grains instead of refined

**Lifestyle Interventions:**
- Regular aerobic exercise (150+ minutes weekly)
- Weight loss if overweight (5-10% reduces BP significantly)
- Stress management (meditation, yoga, deep breathing)
- Adequate sleep (7-9 hours)
- Quit smoking
- Limit caffeine if sensitive

**Supplements (Evidence-Based):**
- Magnesium: 300-500mg daily
- Potassium: From food or supplement (if not contraindicated)
- Omega-3 (EPA/DHA): 2-4g daily
- CoQ10: 100-200mg daily
- Garlic extract: 600-1,200mg daily
- Hibiscus tea: 2-3 cups daily

**Exercise Specifics:**
- Aerobic exercise most effective (walking, jogging, cycling, swimming)
- 30+ minutes, 5-7 days per week
- Resistance training also beneficial (2-3x weekly)
- Avoid heavy weightlifting if BP very high
- Monitor BP response to exercise

**When to See a Doctor:**
- Diastolic >90 mmHg consistently
- Diastolic >110 mmHg (urgent)
- Symptoms: Severe headache, chest pain, vision changes
- May need medication if lifestyle changes insufficient

**Medications (If Needed):**
- ACE inhibitors
- ARBs (Angiotensin Receptor Blockers)
- Calcium channel blockers
- Thiazide diuretics
- Often combination therapy needed

**Monitoring:**
- Home BP monitoring recommended
- Check at same time daily (morning before medications)
- Sit quietly 5 minutes before measuring
- Average multiple readings
- Recheck every 1-3 months

**Special Considerations:**
- Very low diastolic (<60) may reduce heart perfusion
- Pulse pressure (systolic - diastolic) >60 indicates stiff arteries
- White coat hypertension: Elevated only in medical settings
- Isolated diastolic hypertension more common in younger people
- May progress to systolic hypertension with age""",
        'recommendations_primary': 'DASH diet with sodium <2,300mg daily, aerobic exercise 150+ min weekly, weight loss if overweight, stress management, adequate sleep',
        'therapeutics_primary': 'ACE inhibitors or ARBs first-line; magnesium 300-500mg, omega-3 2-4g, CoQ10 100-200mg daily; medications if >90mmHg persistently'
    },

    'Deep Sleep': {
        'education': """**Understanding Deep Sleep (N3/Slow-Wave Sleep)**

Deep sleep, also called N3 or slow-wave sleep, is the most restorative sleep stage. During deep sleep, your brain waves slow dramatically, growth hormone is released, and physical restoration occurs.

**The Longevity Connection:**
- Critical for physical restoration and muscle recovery
- Enhances immune function and disease resistance
- Clears brain waste products (beta-amyloid, tau protein)
- Essential for memory consolidation
- Supports metabolic health and glucose regulation
- Growth hormone release peaks during deep sleep
- Insufficient deep sleep accelerates biological aging
- Associated with reduced dementia risk

**Optimal Amounts:**
- Adults: 1.5-2 hours per night (15-25% of total sleep)
- Decreases naturally with age:
  - Age 20-30: 20-25% of sleep
  - Age 40-50: 10-15% of sleep
  - Age 60+: 5-10% of sleep
- Most deep sleep occurs in first half of night

**Why Deep Sleep Matters:**
- Physical restoration and tissue repair
- Immune system strengthening
- Brain waste clearance (glymphatic system)
- Memory consolidation
- Hormone regulation (growth hormone, cortisol)
- Metabolic health
- Cellular repair and regeneration

**What Reduces Deep Sleep:**

**Lifestyle Factors:**
- Alcohol consumption (fragments sleep)
- Late caffeine (after 2 PM)
- Late exercise (within 3 hours of bed)
- Irregular sleep schedule
- Stress and anxiety
- Late meals
- Screen time before bed (blue light)
- Warm bedroom temperature
- Noise and light exposure

**Medical Conditions:**
- Sleep apnea (major deep sleep disruptor)
- Chronic pain
- Depression and anxiety
- Restless leg syndrome
- Periodic limb movement disorder
- Medications (some SSRIs, beta-blockers)
- Alcohol dependence

**How to Increase Deep Sleep:**

**Sleep Hygiene (Most Important):**
- Consistent sleep schedule (same bedtime/wake time)
- Cool bedroom (65-68°F / 18-20°C)
- Completely dark room (blackout curtains, eye mask)
- Quiet environment (white noise if needed)
- Comfortable mattress and pillow
- Reserve bed for sleep only

**Evening Routine:**
- No caffeine after 2 PM
- No alcohol (especially within 3 hours of bed)
- Light dinner 3+ hours before bed
- Avoid fluids 2 hours before bed
- Dim lights 2 hours before bed
- No screens 1 hour before bed (or blue light blockers)
- Relaxation practices (reading, meditation, stretching)

**Daytime Habits:**
- Morning sunlight exposure (10-30 minutes)
- Regular exercise (but not within 3 hours of bed)
- Manage stress
- Limit daytime napping (<30 minutes, before 3 PM)

**Supplements (Evidence-Based):**
- Magnesium glycinate: 300-500mg before bed
- Glycine: 3g before bed
- L-theanine: 200-400mg evening
- Apigenin (from chamomile): 50mg
- Melatonin: 0.3-1mg (low dose, 2 hours before bed)
- Ashwagandha: 300-600mg evening

**Advanced Strategies:**
- Temperature manipulation (hot bath 1-2 hours before bed raises core temp, then drop promotes sleep)
- Sauna (afternoon/evening promotes deep sleep)
- Resistance training (earlier in day)
- Carbohydrates with dinner (may increase deep sleep)
- Meditation and mindfulness practices
- Avoid antihistamines (reduce deep sleep)

**Sleep Tracking:**
- Wearables (Oura Ring, WHOOP, Apple Watch)
- Not 100% accurate but useful for trends
- Track: Total sleep, deep sleep %, sleep efficiency
- Compare interventions over weeks

**When Deep Sleep is Too Low:**
- Check for sleep apnea (sleep study if snoring, fatigue)
- Review medications with doctor
- Assess alcohol use
- Evaluate stress levels
- Consider cognitive behavioral therapy for insomnia (CBT-I)

**Special Considerations:**
- Deep sleep naturally declines with age
- Sleep apnea severely disrupts deep sleep (get tested)
- Alcohol may help fall asleep but destroys deep sleep quality
- Most deep sleep in first 3-4 hours (early bedtime helps)
- Can't "catch up" on deep sleep - consistency key
- Some medications suppress deep sleep (discuss with doctor)""",
        'recommendations_primary': 'Consistent sleep schedule, cool dark quiet room 65-68°F, no caffeine after 2PM, no alcohol, morning sunlight exposure, evening wind-down routine',
        'therapeutics_primary': 'Magnesium glycinate 300-500mg, glycine 3g before bed; treat sleep apnea if present; CBT-I for chronic insomnia; avoid sleep-disrupting medications'
    },

    'Grip Strength': {
        'education': """**Understanding Grip Strength**

Grip strength is a simple measure of hand and forearm strength, but it's remarkably predictive of overall health, functional capacity, and longevity. It's considered a "biomarker of aging."

**The Longevity Connection:**
- One of the strongest predictors of all-cause mortality
- Each 5 kg decrease associated with 16% higher death risk
- Predicts cardiovascular disease and events
- Reflects overall muscle mass and function
- Associated with cognitive function and brain health
- Predicts disability, frailty, and falls in older adults
- Correlates with bone density
- Lower grip strength = faster biological aging

**Optimal Ranges:**

**Men:**
- Age 20-39: >48 kg (106 lbs)
- Age 40-59: >43 kg (95 lbs)
- Age 60+: >35 kg (77 lbs)

**Women:**
- Age 20-39: >28 kg (62 lbs)
- Age 40-59: >25 kg (55 lbs)
- Age 60+: >21 kg (46 lbs)

**Strength Categories (Relative):**
- Weak: <25th percentile for age/sex
- Below average: 25-50th percentile
- Average: 50-75th percentile
- Strong: 75-90th percentile
- Very strong: >90th percentile

**Why Grip Strength Matters:**
- Reflects overall muscle mass and strength
- Indicates neuromuscular function
- Predicts functional independence
- Associated with protein intake and nutrition
- Marker of physical reserve and resilience
- Correlates with frailty and disability risk

**Causes of Low Grip Strength:**

**Modifiable Factors:**
- Muscle disuse and sedentary lifestyle
- Inadequate protein intake
- Poor nutrition
- Obesity (dilutes relative strength)
- Lack of resistance training
- Chronic inflammation

**Medical Conditions:**
- Sarcopenia (age-related muscle loss)
- Arthritis (hand, wrist, elbow)
- Carpal tunnel syndrome
- Neurological disorders
- Chronic diseases (heart failure, COPD, kidney disease)
- Vitamin D deficiency
- Low testosterone (men)

**How to Improve Grip Strength:**

**Specific Grip Training:**
- Dead hangs from pull-up bar (3-4x weekly)
- Farmer's carries (heavy dumbbells, walk)
- Plate pinches (pinch weight plates together)
- Grippers (Captains of Crush or similar)
- Fat bar training
- Towel pull-ups
- Wrist curls and reverse wrist curls
- Deadlifts (builds grip strength)

**General Strength Training:**
- Full-body resistance training 2-4x weekly
- Compound lifts (deadlifts, rows, pull-ups)
- Progressive overload
- Focus on pulling exercises
- Don't use straps (build grip naturally)

**Nutrition:**
- Adequate protein: 1.6-2.2 g/kg body weight
- Distribute protein throughout day (30g per meal)
- Creatine monohydrate: 5g daily
- Vitamin D: Optimize to 40-60 ng/mL
- Omega-3 fatty acids
- Adequate calories (don't under-eat)

**Supplements for Muscle/Strength:**
- Creatine monohydrate: 5g daily (most effective)
- Vitamin D3: 2,000-5,000 IU (if deficient)
- Protein powder: If dietary intake insufficient
- HMB: 3g daily (especially older adults)
- Beta-alanine: 3-6g daily
- Leucine: 2-3g with meals

**Training Program Example:**
- Day 1: Deadlifts, farmer's carries, dead hangs
- Day 2: Pull-ups (or rows), wrist curls, grippers
- Day 3: Rest or light activity
- Day 4: Full body strength training
- Progressive overload: Add weight or reps weekly

**Measuring Progress:**
- Use hand dynamometer (Jamar standard)
- Test 3 times each hand, record best
- Retest monthly
- Should see 10-20% improvement in 3 months
- Both absolute strength and relative to body weight matter

**For Older Adults:**
- Never too late to improve grip strength
- Start light, progress gradually
- Focus on functional movements
- Consider supervised training initially
- Resistance bands and light weights effective

**Medical Evaluation If:**
- Grip strength <20kg men, <13kg women
- Rapid decline in grip strength
- Associated with fatigue, weight loss
- Pain with gripping
- Check: Testosterone, vitamin D, thyroid, inflammation markers

**Special Considerations:**
- Men typically 2x stronger grip than women
- Dominant hand ~10% stronger than non-dominant
- Asymmetry >20% may indicate injury or neurological issue
- Obesity lowers relative grip strength
- Arthritis may limit grip strength improvement
- Norms vary by race/ethnicity slightly""",
        'recommendations_primary': 'Resistance training 2-4x weekly with focus on pulling exercises, deadlifts, farmer carries, dead hangs; protein 1.6-2.2g/kg daily, creatine 5g daily',
        'therapeutics_primary': 'Creatine monohydrate 5g daily, vitamin D to optimize >40ng/mL, HMB 3g daily for older adults; treat underlying arthritis, optimize testosterone if low'
    },

    'Height': {
        'education': """**Understanding Height as a Health Metric**

While height itself is largely genetically determined, adult height loss is an important indicator of bone health, spinal integrity, and overall aging. Height should be stable in adulthood, and any decrease warrants investigation.

**The Longevity Connection:**
- Height loss >2 cm associated with increased fracture risk
- Accelerated height loss predicts mortality in older adults
- Indicates vertebral compression fractures (often silent)
- Reflects bone density and osteoporosis progression
- Associated with disc degeneration and spinal health
- Height loss >3 cm linked to cardiovascular mortality
- Marker of frailty and functional decline

**Normal Adult Height Patterns:**
- Should be stable ages 20-40
- Natural compression 0.5-1 cm by age 50
- 1-2 cm loss by age 70 (normal aging)
- >2-3 cm loss abnormal, investigate
- Accelerated loss (>0.5 cm/year) concerning

**Why Height Loss Matters:**

**Indicates:**
- Vertebral compression fractures
- Osteoporosis progression
- Disc degeneration
- Spinal stenosis
- Kyphosis (forward curvature)
- Poor posture habits
- Muscle weakness (core, back)

**Causes of Height Loss:**

**Skeletal Causes:**
- Osteoporosis (most common)
- Vertebral compression fractures
- Disc degeneration and compression
- Spinal stenosis
- Osteoarthritis of spine

**Postural Causes:**
- Kyphosis (hunched posture)
- Poor posture habits
- Weak core and back muscles
- Hip flexor tightness
- Rounded shoulders

**Medical Conditions:**
- Vitamin D deficiency
- Calcium deficiency
- Hyperparathyroidism
- Hyperthyroidism
- Cushing's syndrome
- Chronic glucocorticoid use
- Hypogonadism
- Celiac disease (malabsorption)

**How to Prevent Height Loss:**

**Bone Health (Critical):**
- Adequate calcium: 1,000-1,200 mg daily
- Vitamin D: Optimize to 40-60 ng/mL
- Vitamin K2: 90-180 mcg daily
- Magnesium: 300-500 mg daily
- Weight-bearing exercise
- Resistance training 2-3x weekly
- Adequate protein (1.2-1.6 g/kg)

**Postural and Spinal Health:**
- Core strengthening exercises
- Back extension exercises
- Yoga or Pilates (spinal flexibility)
- Proper ergonomics (sitting, standing)
- Avoid prolonged sitting
- Stretch hip flexors regularly
- Sleep on supportive mattress

**Exercise Specifics:**
- Weight-bearing: Walking, jogging, dancing
- Resistance training: Squats, deadlifts, rows
- Core: Planks, bird dogs, dead bugs
- Back extensions: Superman, reverse hypers
- Balance training: Single-leg stands
- Avoid: High-impact if osteoporotic

**Supplements for Bone Health:**
- Vitamin D3: 2,000-5,000 IU daily
- Calcium citrate: 500mg 2x daily (with meals)
- Vitamin K2 (MK-7): 90-180 mcg daily
- Magnesium glycinate: 300-500 mg evening
- Boron: 3-6 mg daily
- Collagen peptides: 10-15g daily
- Strontium (if osteoporotic): 680mg daily

**Monitoring Height:**
- Measure annually (same time of day)
- Stand barefoot, back to wall
- Look straight ahead (not up or down)
- Measure at top of head
- Track over time
- Loss >1 cm/year warrants evaluation

**When to See a Doctor:**
- Height loss >2-3 cm total
- Rapid height loss (>0.5 cm/year)
- Back pain with height loss
- History of fractures
- Risk factors for osteoporosis
- Abnormal spinal curvature

**Medical Evaluation May Include:**
- DEXA scan (bone density)
- Spine X-rays (vertebral fractures)
- Vitamin D and calcium levels
- Parathyroid hormone (PTH)
- Thyroid function
- Consider MRI if neurological symptoms

**Medications (If Osteoporotic):**
- Bisphosphonates (alendronate, risedronate)
- Denosumab (Prolia)
- Teriparatide (bone-building)
- Raloxifene (postmenopausal women)
- Hormone replacement (case-by-case)

**Reversing Height Loss:**
- Posture correction can regain 1-2 cm
- Spinal decompression exercises
- Core strengthening
- True bone loss irreversible but stoppable
- Focus on preventing further loss

**Special Considerations:**
- Women at higher risk (menopause, osteoporosis)
- Height loss accelerates after age 70
- Smoking accelerates bone loss
- Excessive alcohol harmful to bones
- Thyroid medication may affect bone density
- Proton pump inhibitors reduce calcium absorption
- Measure height consistently (morning vs evening difference)""",
        'recommendations_primary': 'Weight-bearing exercise, resistance training 2-3x weekly, adequate calcium 1000-1200mg and vitamin D optimized to 40-60ng/mL, core strengthening, posture awareness',
        'therapeutics_primary': 'Vitamin D3 2000-5000 IU, calcium citrate 500mg 2x daily, vitamin K2 90-180mcg, magnesium 300-500mg; bisphosphonates if osteoporotic; annual height monitoring'
    },

    'Hip-to-Waist Ratio': {
        'education': """**Understanding Hip-to-Waist Ratio**

Hip-to-waist ratio (WHR) is the ratio of your waist circumference to your hip circumference. It's a powerful predictor of health risk, often better than BMI, because it indicates abdominal fat distribution.

**The Longevity Connection:**
- Stronger predictor of cardiovascular disease than BMI
- High WHR associated with 2-3x higher heart disease risk
- Predicts type 2 diabetes independent of weight
- Associated with all-cause mortality
- Indicates metabolic syndrome
- Correlates with insulin resistance
- Reflects visceral (dangerous) fat accumulation
- High WHR = accelerated biological aging

**Optimal Ranges:**

**Men:**
- Optimal: <0.90
- Moderate risk: 0.90-0.99
- High risk: ≥1.0

**Women:**
- Optimal: <0.80
- Moderate risk: 0.80-0.85
- High risk: ≥0.86

**How to Measure:**
1. Measure waist at narrowest point (usually just above belly button)
2. Measure hips at widest point (around buttocks)
3. Divide waist by hips
4. Example: 32" waist ÷ 40" hips = 0.80 ratio

**Why WHR Matters More Than BMI:**
- Indicates fat distribution (not just amount)
- Abdominal fat more metabolically dangerous
- Visceral fat produces inflammatory compounds
- Independent predictor of health outcomes
- Can have normal BMI but unhealthy WHR
- Reflects metabolic health better than weight

**Health Risks of High WHR:**

**Cardiovascular:**
- Coronary artery disease
- Heart attack and stroke
- Hypertension
- Atherosclerosis
- Peripheral artery disease

**Metabolic:**
- Type 2 diabetes
- Insulin resistance
- Metabolic syndrome
- Dyslipidemia (abnormal cholesterol)
- Non-alcoholic fatty liver disease

**Other Risks:**
- Certain cancers (breast, colon, endometrial)
- Sleep apnea
- Chronic inflammation
- Dementia and cognitive decline
- Premature death

**Causes of High WHR:**

**Lifestyle Factors:**
- Excess calorie intake
- High refined carbohydrate diet
- Sedentary lifestyle
- Chronic stress (cortisol)
- Poor sleep (<7 hours)
- Excessive alcohol
- Smoking

**Hormonal Factors:**
- Insulin resistance
- High cortisol (stress hormone)
- Low testosterone (men)
- Menopause (women)
- Growth hormone deficiency
- Thyroid dysfunction
- Polycystic ovary syndrome (PCOS)

**How to Improve Hip-to-Waist Ratio:**

**Dietary Approaches (Most Effective):**
- Caloric deficit (if overweight)
- Low glycemic index foods
- Reduce refined carbohydrates and sugar
- Increase protein (25-30% of calories)
- Increase fiber (30-40g daily)
- Healthy fats (omega-3, olive oil, avocados)
- Limit alcohol (<1-2 drinks/day)
- Intermittent fasting (if appropriate)

**Specific Dietary Patterns:**
- Mediterranean diet
- Low-carb or ketogenic (for insulin resistance)
- High-protein diet
- Anti-inflammatory diet
- Avoid: Processed foods, sugary drinks, trans fats

**Exercise (Critical for Abdominal Fat):**
- Resistance training: 3-4x weekly (builds muscle, burns fat)
- High-intensity interval training (HIIT): 2-3x weekly
- Aerobic exercise: 150-300 min weekly
- Core exercises: Planks, deadlifts, squats
- Non-exercise activity: Walk 10,000+ steps daily
- Note: Cannot spot-reduce fat, but exercise targets visceral fat

**Stress Management:**
- Meditation or mindfulness
- Adequate sleep (7-9 hours)
- Stress reduction techniques
- Yoga or tai chi
- Time in nature
- Social connection

**Supplements (Evidence-Based):**
- Omega-3 (EPA/DHA): 2-4g daily (reduces inflammation)
- Vitamin D: Optimize to 40-60 ng/mL
- Magnesium: 300-500mg daily
- Berberine: 500mg 3x daily (improves insulin sensitivity)
- Chromium: 200-400mcg daily
- Green tea extract: 400-600mg EGCG daily
- Fiber supplements: Psyllium husk 5-10g daily

**Hormonal Optimization:**
- Optimize testosterone (men): Resistance training, adequate sleep, zinc
- Manage cortisol: Stress reduction, adaptogens (ashwagandha)
- Improve insulin sensitivity: Low-carb diet, exercise, berberine
- Thyroid optimization if needed

**Monitoring Progress:**
- Measure WHR monthly
- Track waist circumference (more sensitive than weight)
- Expect 0.5-1 inch waist loss per month with good adherence
- Improvement in WHR = reduced visceral fat
- Even small improvements (0.02-0.05) meaningful

**Realistic Expectations:**
- Abdominal fat responds to caloric deficit + exercise
- Takes 3-6 months to see significant changes
- Fat loss not linear (plateaus normal)
- Visceral fat (internal) lost faster than subcutaneous
- Consistency more important than perfection

**Medical Interventions (If Needed):**
- Metformin (for insulin resistance)
- GLP-1 agonists (semaglutide, liraglutide)
- Testosterone replacement (men with low T)
- Thyroid hormone (if hypothyroid)
- Bariatric surgery (severe obesity)

**Special Considerations:**
- Women naturally have lower WHR than men
- WHR increases with age (especially post-menopause)
- Genetics influence fat distribution
- Some ethnicities have different risk thresholds
- Cannot change skeletal structure (hip width)
- Focus on waist reduction, not hip reduction
- Body recomposition (muscle gain + fat loss) optimal""",
        'recommendations_primary': 'Caloric deficit if overweight, resistance training 3-4x weekly, HIIT 2-3x weekly, low glycemic diet, adequate sleep 7-9hr, stress management, limit alcohol',
        'therapeutics_primary': 'Omega-3 2-4g daily, vitamin D optimization, berberine 500mg 3x daily for insulin resistance; metformin or GLP-1 agonists if indicated; optimize testosterone/thyroid'
    },

    'REM Sleep': {
        'education': """**Understanding REM Sleep**

REM (Rapid Eye Movement) sleep is the dream stage of sleep, critical for emotional regulation, memory consolidation, creativity, and brain health. It typically occurs in cycles throughout the night, increasing in duration toward morning.

**The Longevity Connection:**
- Essential for emotional processing and mental health
- Critical for memory consolidation and learning
- Protects against cognitive decline and dementia
- Regulates mood and emotional resilience
- Supports creativity and problem-solving
- Insufficient REM linked to increased mortality risk
- REM disruption associated with depression and anxiety
- Important for brain waste clearance

**Optimal Amounts:**
- Adults: 90-120 minutes per night (20-25% of total sleep)
- 4-6 REM cycles per night (cycling every 90 min)
- REM periods lengthen throughout night:
  - First cycle: 5-10 minutes REM
  - Final cycle: 30-60 minutes REM
- Most REM occurs in last third of sleep (hours 5-8)

**REM Sleep by Age:**
- Infants: 50% of sleep
- Children: 25-30% of sleep
- Adults: 20-25% of sleep
- Older adults: 15-20% of sleep (natural decline)

**Why REM Sleep Matters:**
- Memory consolidation (especially emotional memories)
- Learning and skill acquisition
- Emotional regulation and processing
- Brain development and plasticity
- Creativity and problem-solving
- Neurotransmitter balance
- Dreaming and unconscious processing
- Preparation for wakefulness

**What Reduces REM Sleep:**

**Substances:**
- Alcohol (most disruptive to REM)
- Cannabis/THC (suppresses REM)
- Antidepressants (SSRIs, SNRIs)
- Beta-blockers
- Benzodiazepines
- Stimulants late in day
- Nicotine

**Sleep Disorders:**
- Sleep apnea (fragments REM)
- Restless leg syndrome
- Periodic limb movement disorder
- REM sleep behavior disorder
- Narcolepsy

**Lifestyle Factors:**
- Sleep deprivation (cuts REM short)
- Irregular sleep schedule
- Late bedtime (misses REM-rich hours)
- Stress and anxiety
- Depression
- Fever or illness
- Withdrawal from REM-suppressing substances

**How to Increase REM Sleep:**

**Sleep Duration (Most Important):**
- Get full 7-9 hours (REM peaks in later hours)
- Extend sleep to 8+ hours if REM-deprived
- Earlier bedtime (more total sleep = more REM)
- Avoid sleep debt (REM rebounds after deprivation)
- Consistent sleep schedule

**Sleep Environment:**
- Cool room (65-68°F / 18-20°C)
- Completely dark (blackout curtains)
- Quiet or white noise
- Comfortable mattress/pillow
- Avoid disruptions in final sleep hours

**Timing Optimization:**
- Go to bed early enough for 8 hours
- Wake naturally if possible (alarm cuts REM)
- Morning light exposure (regulates circadian rhythm)
- Avoid late naps (may reduce REM need)

**Avoid REM Suppressants:**
- No alcohol (especially within 4 hours of bed)
- Avoid cannabis if using for sleep
- Review medications with doctor
- No stimulants after 2 PM

**Sleep Hygiene:**
- Consistent sleep/wake times
- Wind-down routine
- Limit screen time before bed
- Manage stress
- Regular exercise (but not late)
- Light dinner 3+ hours before bed

**Supplements (Limited Evidence for REM):**
- Magnesium glycinate: 300-500mg before bed (improves sleep quality)
- Glycine: 3g before bed (may enhance REM)
- Melatonin: 0.3-1mg (regulates sleep cycles)
- 5-HTP: 100-300mg evening (serotonin precursor, use cautiously)
- Galantamine: 4-8mg (can increase REM, use sparingly)
- L-theanine: 200-400mg evening
- Choline: 500mg before bed (vivid dreams, more REM)

**For REM Rebound (After Deprivation):**
- Allow 2-3 weeks of consistent 8+ hour sleep
- Body will naturally increase REM percentage
- May experience vivid dreams during rebound
- Avoid alcohol during recovery period
- Patience - REM normalizes over time

**Medication Considerations:**
- SSRIs/SNRIs: Discuss REM suppression with doctor
- Don't stop medications without guidance
- Some newer antidepressants less REM-suppressing
- Beta-blockers: Ask about alternatives if REM concerns
- Benzodiazepines: Use short-term only

**Sleep Tracking:**
- Wearables: Oura Ring, WHOOP, Apple Watch
- Not 100% accurate for REM specifically
- Track trends over weeks
- Look for REM % and distribution
- Aim for 90+ minutes REM per night

**When REM is Too Low:**
- Extend total sleep time first
- Eliminate alcohol completely
- Review all medications
- Treat underlying sleep disorders (apnea, RLS)
- Manage stress and mental health
- Consider sleep study if persistent

**Special Considerations:**
- Alcohol destroys REM even in small amounts
- Cannabis withdrawal may cause REM rebound (vivid dreams)
- Antidepressants necessary for some despite REM impact
- REM naturally decreases with age
- Sleep apnea severely disrupts REM
- REM behavior disorder (acting out dreams) needs medical evaluation
- Lucid dreaming techniques can increase REM awareness

**Signs of Insufficient REM:**
- Poor emotional regulation
- Difficulty with learning/memory
- Mood disturbances
- Reduced creativity
- Lack of dreaming recall
- Morning grogginess despite adequate sleep hours
- Increased stress reactivity""",
        'recommendations_primary': 'Extend total sleep to 8+ hours, consistent early bedtime, eliminate alcohol completely, avoid REM-suppressing medications, cool dark quiet sleep environment, stress management',
        'therapeutics_primary': 'Magnesium glycinate 300-500mg before bed, glycine 3g evening; treat sleep apnea if present; review REM-suppressing medications with doctor; choline 500mg may enhance REM'
    },

    'Steps/Day': {
        'education': """**Understanding Daily Step Count**

Daily step count is a simple, accessible measure of physical activity that strongly predicts health outcomes and longevity. More steps per day correlate with reduced risk of chronic disease and premature death.

**The Longevity Connection:**
- Each 1,000 additional daily steps reduces mortality risk by 6-10%
- 7,000+ steps associated with significantly lower death risk
- Protects against cardiovascular disease
- Reduces type 2 diabetes risk by up to 40%
- Associated with lower cancer risk
- Improves cognitive function and brain health
- Reduces depression and anxiety
- Maintains functional independence in aging

**Optimal Daily Targets:**
- Minimal benefit threshold: 4,000 steps
- Moderate health benefits: 7,000-8,000 steps
- Optimal for longevity: 8,000-10,000 steps
- Maximum benefit: 10,000-12,000 steps
- Beyond 12,000: Minimal additional benefit for longevity
- Intensity matters: Brisk steps > slow steps

**Steps by Category:**
- Sedentary: <5,000 steps/day
- Low active: 5,000-7,499 steps/day
- Somewhat active: 7,500-9,999 steps/day
- Active: 10,000-12,499 steps/day
- Highly active: ≥12,500 steps/day

**Why Steps Matter:**
- Marker of overall activity level
- Easy to track and understand
- Linked to metabolic health
- Reflects non-exercise activity thermogenesis (NEAT)
- Maintains cardiovascular fitness
- Weight management
- Bone density maintenance
- Reduces sitting time

**Health Benefits by Step Count:**

**4,000-7,000 Steps:**
- Reduced mortality risk vs sedentary
- Some cardiovascular protection
- Modest metabolic benefits
- Better than nothing

**7,000-10,000 Steps:**
- 50-70% lower mortality risk
- Significant cardiovascular benefits
- Improved glucose regulation
- Weight maintenance
- Better mood and energy
- Reduced chronic disease risk

**10,000+ Steps:**
- Maximum longevity benefits
- Optimal cardiovascular health
- Best metabolic outcomes
- Enhanced fitness
- Improved body composition

**Causes of Low Step Count:**
- Sedentary job (desk work)
- Car-dependent lifestyle
- Urban design (lack of walkability)
- Physical limitations or pain
- Weather barriers
- Lack of time or motivation
- Depression or low energy
- Chronic illness or disability

**How to Increase Daily Steps:**

**Walking Strategies:**
- Morning walk (before work)
- Walk breaks every hour at work
- Walking meetings
- Park farther away
- Take stairs instead of elevator
- Walk during phone calls
- Walk after meals (benefits glucose)
- Walk dog (or volunteer to walk dogs)

**Lifestyle Integration:**
- Walk for errands instead of driving
- Use public transit (involves more walking)
- Walk to lunch
- Take walking routes to destinations
- Walk while waiting (airport, appointments)
- Pace while thinking or planning
- Walk while listening to podcasts/audiobooks

**Home and Work:**
- Treadmill desk or standing desk
- Walk during TV commercials
- Do household chores
- Walk around house/office regularly
- Set hourly movement reminders
- Pace during video calls

**Social and Recreational:**
- Walk with friends/family
- Join walking group
- Walk meetings instead of sitting
- Explore new neighborhoods
- Hiking on weekends
- Mall walking (weather-protected)
- Walk to social events

**Step Intensity (Important):**
- Brisk walking (100+ steps/min) > slow walking
- Higher intensity = greater health benefits
- Aim for some brisk-paced walking
- Mix of paces throughout day acceptable
- 3,000 brisk steps = ~30 min moderate exercise

**Tracking Steps:**
- Smartphone (built-in accelerometer)
- Fitness trackers (Fitbit, Garmin, etc.)
- Smartwatches (Apple Watch, etc.)
- Pedometers
- Track daily and weekly trends
- Set incremental goals

**Building Up Gradually:**
- Start where you are (baseline week)
- Add 500-1,000 steps per week
- Example progression:
  - Week 1: 5,000 steps
  - Week 2: 6,000 steps
  - Week 3: 7,000 steps
  - Week 4: 8,000 steps
- Consistency more important than perfection
- Allow flexibility on difficult days

**For Sedentary Individuals:**
- Start with 15-minute walks
- Focus on reducing sitting time first
- Set minimum goal (5,000 steps)
- Build slowly over months
- Celebrate small increases
- Find walking partner for accountability

**Complementary Exercise:**
- Steps don't replace structured exercise
- Also do: Resistance training 2-3x weekly
- Add: Higher-intensity cardio 1-2x weekly
- Include: Flexibility and balance work
- Steps are base layer of activity

**Step Goals for Specific Populations:**

**Older Adults (65+):**
- Minimum: 3,000-5,000 steps
- Moderate: 5,000-7,000 steps
- Active: 7,000+ steps
- Focus on fall prevention and balance

**Weight Loss:**
- Target: 10,000-15,000 steps
- Combine with caloric deficit
- Higher steps support weight maintenance
- Increase NEAT (non-exercise activity)

**Chronic Disease Management:**
- Diabetes: 7,000-10,000 steps (glucose control)
- Heart disease: Build to 7,000+ gradually
- Arthritis: Moderate pace, appropriate footwear
- Consult doctor for specific conditions

**Overcoming Barriers:**

**Physical Limitations:**
- Pool walking (low impact)
- Chair exercises (if mobility limited)
- Arm bike or rowing (if legs limited)
- Physical therapy for pain
- Appropriate footwear and orthotics

**Time Constraints:**
- Short walks throughout day (5-10 min)
- Active commute
- Lunch break walks
- Walk and talk meetings
- Wake 15 min earlier

**Motivation:**
- Set specific daily goal
- Track progress visibly
- Reward milestones
- Walking challenges with friends
- Vary routes for interest
- Join step competition

**Special Considerations:**
- Quality (intensity) > quantity
- Some structured exercise may be more efficient
- 10,000 is guideline, not magic number
- Individual variation in needs
- Joint health: Good shoes, appropriate surfaces
- Step count declines with age (adjust targets)
- Weekend warriors: Spread steps throughout week better

**When More Steps Don't Help:**
- Beyond ~12,000 steps, benefits plateau
- Overtraining risk if combining with intense exercise
- Joint stress if poor form or footwear
- Balance step volume with recovery
- Quality exercise may be more important for some goals""",
        'recommendations_primary': 'Target 8000-10000 steps daily, include brisk-paced walking, integrate walking into daily routines, take movement breaks every hour, walk after meals, build up gradually',
        'therapeutics_primary': 'No specific therapeutics needed; proper footwear important; address joint pain if limiting; treat underlying conditions affecting mobility; consider physical therapy if mobility limited'
    },

    'Visceral Fat': {
        'education': """**Understanding Visceral Fat**

Visceral fat is the dangerous fat stored deep in the abdomen, surrounding internal organs (liver, pancreas, intestines). Unlike subcutaneous fat (under skin), visceral fat is metabolically active and produces inflammatory compounds.

**The Longevity Connection:**
- Strongest predictor of metabolic disease and early death
- Visceral fat more dangerous than total body fat
- Each 10 cm² increase in visceral fat = 7% higher mortality risk
- Major driver of insulin resistance and type 2 diabetes
- Causes chronic inflammation throughout body
- Directly linked to cardiovascular disease
- Associated with dementia and cognitive decline
- High visceral fat = accelerated biological aging

**Optimal Ranges (by imaging):**
- Low risk: <100 cm² (MRI/CT measurement)
- Moderate risk: 100-160 cm²
- High risk: >160 cm²

**Estimates (waist circumference):**

**Men:**
- Low risk: <94 cm (37 inches)
- Moderate risk: 94-102 cm (37-40 inches)
- High risk: >102 cm (>40 inches)

**Women:**
- Low risk: <80 cm (31.5 inches)
- Moderate risk: 80-88 cm (31.5-34.5 inches)
- High risk: >88 cm (>34.5 inches)

**Why Visceral Fat is Dangerous:**
- Produces inflammatory cytokines (IL-6, TNF-α)
- Secretes hormones that disrupt metabolism
- Causes insulin resistance
- Increases liver fat (NAFLD)
- Elevates blood pressure
- Worsens cholesterol profile
- Promotes blood clotting
- Infiltrates organs, impairing function

**Health Risks of Excess Visceral Fat:**

**Metabolic:**
- Type 2 diabetes
- Insulin resistance
- Metabolic syndrome
- Non-alcoholic fatty liver disease (NAFLD)
- Dyslipidemia

**Cardiovascular:**
- Coronary artery disease
- Heart attack and stroke
- Hypertension
- Atherosclerosis
- Atrial fibrillation

**Other:**
- Certain cancers (colon, breast, pancreatic)
- Sleep apnea
- Dementia and Alzheimer's disease
- Chronic inflammation
- Premature death

**Causes of Excess Visceral Fat:**

**Dietary:**
- Excess refined carbohydrates and sugar
- High fructose intake (especially liquid sugars)
- Trans fats
- Excessive calorie intake
- Alcohol (especially beer and spirits)
- Low fiber intake

**Lifestyle:**
- Sedentary behavior
- Chronic stress (cortisol)
- Poor sleep (<6-7 hours)
- Smoking

**Hormonal:**
- Insulin resistance
- High cortisol (chronic stress)
- Low testosterone (men)
- Menopause (women)
- Growth hormone deficiency
- Hypothyroidism

**How to Reduce Visceral Fat:**

**Dietary Interventions (Most Effective):**
- Caloric deficit (500-750 cal/day)
- Low glycemic index diet
- Reduce added sugars dramatically
- Eliminate sugary beverages
- Reduce refined carbohydrates
- Increase protein (25-30% of calories)
- Increase fiber (30-40g daily)
- Healthy fats (omega-3, olive oil, nuts)
- Limit alcohol (<1-2 drinks/day, ideally none)
- Mediterranean or low-carb diet

**Specific Foods to Reduce Visceral Fat:**
- Soluble fiber: Oats, beans, apples, flaxseed
- Protein: Lean meats, fish, eggs, legumes
- Omega-3: Fatty fish, walnuts, chia seeds
- Vegetables: Especially cruciferous and leafy greens
- Green tea
- Avoid: Soda, fruit juice, white bread, pastries

**Exercise (Critical - Targets Visceral Fat):**
- Aerobic exercise: 150-300 min weekly (most effective for visceral fat)
- High-intensity interval training (HIIT): 2-3x weekly
- Resistance training: 2-3x weekly (builds muscle, improves metabolism)
- Walking: 8,000-10,000 steps daily
- Note: Exercise preferentially reduces visceral fat over subcutaneous

**Exercise Specifics for Visceral Fat:**
- Moderate intensity: 30-60 min most days
- Vigorous exercise more effective than light
- HIIT burns visceral fat efficiently
- Consistency more important than intensity
- Combine cardio + strength training

**Stress Management (Important):**
- Chronic stress elevates cortisol → visceral fat
- Meditation or mindfulness daily
- Adequate sleep (7-9 hours)
- Stress reduction techniques
- Yoga or tai chi
- Social support
- Time in nature

**Sleep Optimization:**
- 7-9 hours per night
- Consistent sleep schedule
- Poor sleep → increased cortisol → visceral fat
- Sleep apnea treatment if present

**Supplements (Evidence-Based):**
- Omega-3 (EPA/DHA): 2-4g daily (reduces inflammation, visceral fat)
- Vitamin D: Optimize to 40-60 ng/mL
- Probiotics: Multi-strain (gut health linked to visceral fat)
- Berberine: 500mg 3x daily (improves insulin sensitivity)
- Green tea extract: 400-600mg EGCG daily
- Fiber supplements: Psyllium husk 5-10g daily
- Magnesium: 300-500mg daily

**Hormonal Optimization:**
- Optimize insulin sensitivity: Low-carb diet, exercise, berberine
- Manage cortisol: Stress reduction, adaptogenic herbs
- Testosterone optimization (men): Resistance training, adequate sleep
- Thyroid optimization if needed

**Intermittent Fasting:**
- 16:8 fasting (16 hours fast, 8 hour eating window)
- Effective for visceral fat reduction
- Not necessary but can be helpful tool
- Combine with caloric restriction

**Monitoring Progress:**
- Waist circumference (most practical)
- Measure monthly at belly button level
- DEXA scan (gold standard for body composition)
- Bioelectrical impedance (less accurate for visceral fat)
- Expect 1-2 cm waist loss per month with good adherence

**Realistic Timeline:**
- Visceral fat responds faster than subcutaneous fat
- 3-6 months for significant reduction
- Consistency critical
- Some people lose visceral fat very quickly, others slower
- Genetic variation in fat distribution

**Medical Interventions:**
- Metformin (if diabetic or pre-diabetic)
- GLP-1 agonists (semaglutide, liraglutide) - very effective
- SGLT2 inhibitors
- Testosterone replacement (men with low T)
- Bariatric surgery (severe obesity)

**What Doesn't Work:**
- Spot reduction exercises (can't target visceral fat specifically)
- Abdominal crunches alone (don't reduce visceral fat)
- Fat-burning supplements (minimal effect)
- Detoxes or cleanses

**Special Populations:**

**Postmenopausal Women:**
- Visceral fat increases after menopause
- Hormone replacement may help (discuss with doctor)
- Exercise and diet even more critical
- Resistance training preserves muscle, metabolism

**Men with Low Testosterone:**
- Low T associated with visceral fat
- Resistance training boosts T naturally
- Consider TRT if clinically low
- Weight loss can improve T levels

**Priority Actions for Visceral Fat Reduction:**
1. Create caloric deficit
2. Reduce refined carbs and sugar dramatically
3. Start aerobic exercise (30-60 min most days)
4. Add resistance training 2-3x weekly
5. Optimize sleep (7-9 hours)
6. Manage chronic stress
7. Limit alcohol

**Special Considerations:**
- Visceral fat is first to go with weight loss (good news!)
- Exercise without weight loss still reduces visceral fat
- Normal-weight individuals can still have high visceral fat
- Ethnicity affects risk thresholds (Asians at lower thresholds)
- Genetics influence fat distribution but lifestyle still critical
- After menopause, women accumulate more visceral fat""",
        'recommendations_primary': 'Caloric deficit, low glycemic diet with reduced refined carbs/sugar, aerobic exercise 150-300min weekly, HIIT 2-3x weekly, resistance training, adequate sleep 7-9hr, stress management',
        'therapeutics_primary': 'Omega-3 2-4g daily, vitamin D optimization, berberine 500mg 3x daily, probiotics; GLP-1 agonists or metformin if indicated; optimize testosterone/thyroid if deficient'
    },

    'Water Intake': {
        'education': """**Understanding Water Intake and Hydration**

Adequate water intake is fundamental for every physiological process. Even mild dehydration impairs physical and cognitive performance, and chronic dehydration accelerates aging.

**The Longevity Connection:**
- Proper hydration maintains cellular function
- Prevents kidney stones and urinary tract infections
- Supports cardiovascular function (blood volume)
- Enables detoxification and waste removal
- Maintains brain function and cognition
- Chronic dehydration linked to faster biological aging
- Associated with reduced longevity in older adults
- Prevents constipation and digestive issues

**Optimal Daily Intake:**

**General Guidelines:**
- Men: 3.7 liters (125 oz, ~15 cups) total fluids/day
- Women: 2.7 liters (91 oz, ~11 cups) total fluids/day
- ~80% from beverages, ~20% from food
- Individual needs vary widely

**Factors Increasing Water Needs:**
- Exercise and physical activity
- Hot/humid climate
- High altitude
- Illness (fever, vomiting, diarrhea)
- Pregnancy and breastfeeding
- High fiber diet
- High protein diet
- Caffeine and alcohol consumption

**Signs of Adequate Hydration:**
- Pale yellow urine (lemonade color)
- Urinating every 2-4 hours
- No persistent thirst
- Moist lips and mouth
- Good skin turgor
- Clear thinking and good energy

**Signs of Dehydration:**

**Mild (1-2% body water loss):**
- Thirst
- Darker urine
- Dry mouth
- Fatigue
- Reduced urine output

**Moderate (3-5% loss):**
- Significant thirst
- Very dark urine
- Dizziness
- Headache
- Dry skin
- Rapid heartbeat
- Reduced physical performance

**Severe (>5% loss):**
- Extreme thirst
- No urination or very dark urine
- Confusion, irritability
- Rapid breathing
- Sunken eyes
- Medical emergency

**Benefits of Proper Hydration:**
- Maintains body temperature
- Lubricates joints
- Protects spinal cord and tissues
- Removes waste through urination, sweating
- Supports digestion
- Prevents constipation
- Maintains blood pressure
- Improves cognitive function
- Enhances physical performance
- Supports kidney function
- Healthy skin appearance
- May aid weight management

**Water Intake Recommendations by Activity:**

**Sedentary:**
- Minimum: 8 cups (64 oz) water/day
- Plus fluids from food

**Moderate Activity:**
- 10-12 cups (80-96 oz)/day
- More on exercise days

**High Activity/Athletes:**
- 12-16+ cups (96-128 oz)/day
- Replace fluids lost in sweat
- Weigh before/after exercise (replace each lb lost with 16-20 oz)

**Hot Weather:**
- Increase by 2-4 cups/day
- More if exercising in heat
- Monitor urine color

**How to Stay Hydrated:**

**Habits and Strategies:**
- Start day with 16 oz water
- Drink water with each meal
- Carry water bottle everywhere
- Set reminders to drink
- Drink before/during/after exercise
- Drink when thirsty (don't ignore thirst)
- Eat water-rich foods (fruits, vegetables)
- Flavor water with lemon, cucumber, mint

**Hydration Schedule:**
- Morning: 16 oz upon waking
- Before meals: 8 oz (aids digestion)
- With meals: 8-16 oz
- Between meals: Sip regularly
- Before bed: 4-8 oz (not too much to avoid nighttime urination)
- Before/during exercise: 7-10 oz per 10-20 min

**Best Hydration Sources:**
- Plain water (best)
- Sparkling water (unsweetened)
- Herbal teas (uncaffeinated)
- Water-rich foods: Cucumbers, watermelon, lettuce, celery, oranges
- Coconut water (natural electrolytes)
- Milk (also provides nutrients)

**Moderate Hydration Sources:**
- Coffee and tea (caffeinated) - still count toward fluids but diuretic effect
- 100% fruit juice (but high in sugar, dilute or limit)
- Broths and soups

**Poor Hydration Sources:**
- Sugary drinks (soda, energy drinks)
- Alcohol (dehydrating)
- Excessive caffeine

**Special Populations:**

**Athletes:**
- Hydrate before exercise (16-20 oz 2 hrs before)
- During: 7-10 oz every 10-20 min
- After: Replace 150% of fluid lost (via sweat)
- Consider electrolytes for >1 hr intense exercise

**Older Adults:**
- Thirst mechanism less sensitive
- Need to drink on schedule, not just when thirsty
- Risk of dehydration higher
- May need reminder system

**Pregnant/Breastfeeding:**
- Pregnant: Add 300 mL (~10 oz)/day
- Breastfeeding: Add 700 mL (~24 oz)/day
- Monitor urine color

**Kidney Stones History:**
- Increase to 3 liters (12 cups)/day
- Prevents stone formation
- Dilutes urine

**Overhydration (Hyponatremia):**
- Rare but dangerous
- Drinking excessive water (>1 liter/hour)
- Dilutes blood sodium
- Symptoms: Nausea, headache, confusion, seizures
- Risk: Endurance athletes, psychiatric conditions
- Prevention: Don't force excessive water, consume electrolytes

**Electrolyte Balance:**
- With normal diet, plain water sufficient
- Add electrolytes if:
  - Intense exercise >1 hour
  - Hot weather exertion
  - Illness with vomiting/diarrhea
  - Very low sodium diet
- Sources: Coconut water, electrolyte drinks, broths

**Monitoring Hydration Status:**
- Urine color: Pale yellow optimal
- Frequency: Every 2-4 hours
- Thirst: Should be minimal
- Weigh daily (consistent weight = good hydration)
- Skin turgor test (pinch skin, should snap back)

**Common Mistakes:**
- Waiting until very thirsty
- Only drinking with meals
- Substituting sugary drinks for water
- Chugging large amounts at once (sip throughout day better)
- Forgetting to hydrate before/during exercise
- Drinking only caffeine in morning

**Hydration and Health Conditions:**

**Kidney Disease:**
- May need fluid restriction (follow doctor guidance)
- Monitor carefully

**Heart Failure:**
- Often fluid restricted
- Follow medical advice

**Diabetes:**
- May have increased thirst/urination
- Stay hydrated but monitor
- Thirst can indicate high blood sugar

**Medications Affecting Hydration:**
- Diuretics: Increase fluid needs
- Laxatives: Can dehydrate
- Some blood pressure medications

**Water Quality:**
- Filtered water recommended (removes contaminants)
- Bottled vs tap depends on local water quality
- Avoid plastic bottles (BPA exposure)
- Use glass or stainless steel containers

**Temperature of Water:**
- Room temperature: Best absorption
- Cold water: Fine, may feel more refreshing
- Hot water: Herbal teas count toward hydration
- Personal preference matters for adherence

**Tips for Increasing Water Intake:**
- Flavor with fruit, herbs (lemon, berries, mint, cucumber)
- Use a marked water bottle (tracks intake)
- Set phone reminders
- Drink water before coffee/tea
- Keep water visible and accessible
- Make it a habit with existing routines

**Dehydration Risk Factors:**
- Older age
- Chronic illnesses
- Intense exercise
- Hot/humid environment
- High altitude
- Fever, vomiting, diarrhea
- Diabetes
- Burns
- Excessive sweating

**When to Seek Medical Attention:**
- Severe thirst despite drinking
- Very dark urine or no urination
- Dizziness or lightheadedness
- Rapid heartbeat
- Confusion
- Severe diarrhea or vomiting
- Signs of heat illness""",
        'recommendations_primary': 'Drink 8-12 cups water daily (more if active), start day with 16oz water, carry water bottle, drink before/with meals, eat water-rich foods, monitor urine color (pale yellow)',
        'therapeutics_primary': 'Plain water optimal; electrolyte drinks for intense exercise >1hr or hot weather; coconut water for natural electrolytes; avoid sugary drinks and excessive caffeine'
    },

    'Skeletal Muscle Mass to Fat-Free Mass': {
        'education': """**Understanding Skeletal Muscle to Fat-Free Mass Ratio**

This metric reflects the proportion of skeletal muscle within total fat-free (lean) mass. It indicates muscle quality and functional capacity, beyond just total lean mass.

**The Longevity Connection:**
- Higher skeletal muscle mass predicts longer lifespan
- Preserves functional independence in aging
- Protects against sarcopenia (age-related muscle loss)
- Associated with better metabolic health
- Reduces frailty risk
- Maintains strength and mobility
- Higher muscle mass = better survival after illness/surgery
- Muscle as "longevity organ" (secretes beneficial myokines)

**Optimal Ranges:**
- Varies by age, sex, and measurement method
- DEXA scan most accurate
- Higher ratio = better (more skeletal muscle)
- Men typically have higher ratio than women
- Ratio declines with age (muscle loss accelerates after 50)

**Typical Values (DEXA):**

**Men:**
- Age 20-39: 75-85% of fat-free mass is skeletal muscle
- Age 40-59: 70-80%
- Age 60+: 65-75%

**Women:**
- Age 20-39: 70-80% of fat-free mass is skeletal muscle
- Age 40-59: 65-75%
- Age 60+: 60-70%

**Why This Ratio Matters:**
- Skeletal muscle is metabolically active
- Produces beneficial hormones (myokines)
- Supports glucose metabolism
- Maintains bone density
- Enables functional movement
- Protects against falls and fractures
- Muscle quality > muscle quantity

**Causes of Low Skeletal Muscle Mass:**

**Lifestyle:**
- Sedentary behavior
- Inadequate protein intake
- Insufficient resistance training
- Chronic caloric restriction
- Poor sleep
- Excessive cardio without strength training

**Medical:**
- Sarcopenia (age-related muscle loss)
- Cachexia (disease-related wasting)
- Chronic illness
- Hormonal imbalances (low testosterone, growth hormone)
- Malabsorption
- Thyroid disorders
- Chronic inflammation

**How to Increase Skeletal Muscle Mass:**

**Resistance Training (Essential):**
- Lift weights 3-4x per week
- Progressive overload (gradually increase weight)
- Compound exercises: Squats, deadlifts, bench press, rows
- Full body routine or split routine
- 3-4 sets of 8-12 reps
- Focus on major muscle groups
- Allow recovery between sessions

**Protein Intake (Critical):**
- 1.6-2.2 g/kg body weight daily
- Distribute throughout day (30-40g per meal)
- High-quality sources: Meat, fish, eggs, dairy, whey
- Leucine-rich foods trigger muscle protein synthesis
- Post-workout protein (20-40g within 2 hours)
- Older adults may need higher intake (up to 2.0 g/kg)

**Nutrition Strategy:**
- Adequate total calories (can't build muscle in deficit)
- Caloric surplus for muscle gain (+250-500 cal/day)
- Carbohydrates around workouts (fuel and recovery)
- Healthy fats (hormones, inflammation)
- Micronutrients (vitamin D, magnesium, zinc)

**Specific Training Programs:**

**Beginner (3x weekly):**
- Full body workouts
- 5-6 exercises per session
- Squats, deadlifts, bench, rows, overhead press
- 3 sets of 10-12 reps
- Progress weight weekly

**Intermediate (4x weekly):**
- Upper/lower split
- More volume per muscle group
- 6-8 exercises per session
- Include isolation exercises
- Periodize training

**Advanced:**
- Body part splits
- Higher volume and frequency
- Advanced techniques (supersets, drop sets)
- Careful programming and recovery

**Supplements for Muscle Gain:**
- Creatine monohydrate: 5g daily (most effective)
- Whey protein: 20-40g post-workout
- Leucine: 2-3g with meals
- HMB: 3g daily (especially older adults)
- Vitamin D3: Optimize to 40-60 ng/mL
- Omega-3: 2-4g daily (reduces inflammation)
- Beta-alanine: 3-6g daily

**Recovery and Sleep:**
- 7-9 hours sleep nightly (muscle repair occurs during sleep)
- Growth hormone released during deep sleep
- Rest days between intense sessions
- Manage stress (cortisol breaks down muscle)
- Active recovery (walking, stretching)

**For Older Adults (50+):**
- Resistance training even more critical
- Start slowly, build progressively
- Focus on form and safety
- May need more protein (1.8-2.0 g/kg)
- Prioritize compound movements
- Balance and stability exercises
- Consult trainer initially
- Never too late to start!

**Hormonal Optimization:**
- Testosterone (men): Resistance training, adequate sleep, zinc, magnesium
- Growth hormone: High-intensity exercise, deep sleep, intermittent fasting
- Insulin sensitivity: Resistance training, low-glycemic diet
- Thyroid: Optimize if low (affects muscle metabolism)

**Measuring Progress:**
- DEXA scan (gold standard) - every 6-12 months
- Bioelectrical impedance (less accurate but convenient)
- Strength gains (progressive overload)
- Body measurements (arms, chest, thighs)
- Mirror and photos
- Functional tests (push-ups, sit-stands)

**Realistic Expectations:**

**Beginners:**
- Gain 1-2 lbs muscle per month (men)
- Gain 0.5-1 lb muscle per month (women)
- "Newbie gains" accelerate progress first year

**Intermediate:**
- 0.5-1 lb muscle per month (men)
- 0.25-0.5 lb per month (women)
- Slower but steady progress

**Advanced:**
- 0.25-0.5 lb per month (men)
- 0.1-0.25 lb per month (women)
- Very slow, requires perfect program

**Older Adults:**
- Can still gain muscle!
- Slower rate than younger adults
- Focus on maintaining and small gains
- Strength improvements even without size gains

**Common Mistakes:**
- Insufficient protein intake
- Not progressively overloading
- Too much cardio, not enough strength training
- Inadequate recovery/sleep
- Inconsistent training
- Not eating enough calories
- Skipping major compound lifts

**Cardio and Muscle Mass:**
- Too much cardio interferes with muscle gain
- Moderate cardio (2-3x weekly, 20-30 min) compatible
- High-volume endurance training counterproductive
- HIIT better than steady-state for muscle preservation
- Prioritize strength training for muscle goals

**Special Considerations:**
- Women can build muscle (won't get "bulky" without drugs)
- Older adults respond to training (never too late!)
- Genetics influence muscle-building rate
- Some gain muscle easily, others struggle
- Consistency over years yields results
- Muscle memory: Easier to regain lost muscle

**Medical Interventions (if needed):**
- Testosterone replacement (men with clinically low T)
- Growth hormone (rarely, specific deficiencies)
- Treat underlying thyroid, metabolic issues
- Physical therapy for mobility limitations

**Body Recomposition:**
- Can lose fat and gain muscle simultaneously
- Works best for beginners or detrained individuals
- Requires high protein, resistance training, modest deficit
- Slower than pure bulk or cut
- Sustainable long-term approach""",
        'recommendations_primary': 'Resistance training 3-4x weekly with progressive overload, protein 1.6-2.2g/kg daily distributed throughout day, adequate sleep 7-9hr, compound exercises (squats, deadlifts, rows)',
        'therapeutics_primary': 'Creatine monohydrate 5g daily, whey protein 20-40g post-workout, vitamin D optimization >40ng/mL, HMB 3g daily for older adults; optimize testosterone/thyroid if deficient'
    },

    'OMICmAge': {
        'education': """**Understanding OMICmAge (Epigenetic Age Clock)**

OMICmAge is a "next-generation" epigenetic biological age clock based on DNA methylation patterns. It estimates your biological age - how old your body appears at the cellular level - which may differ significantly from your chronological (calendar) age.

**The Longevity Connection:**
- Predicts all-cause mortality better than chronological age
- Each year of epigenetic age acceleration = 2-6% higher mortality risk
- Reflects cumulative effects of lifestyle, stress, and disease
- Associated with age-related diseases (cancer, heart disease, dementia)
- Reversible with lifestyle interventions
- Lower biological age = extended healthspan and lifespan
- Tracks response to longevity interventions

**Understanding the Metric:**
- Based on DNA methylation at specific CpG sites
- Methylation changes as cells age (epigenetic drift)
- OMICmAge trained on large datasets to predict health outcomes
- Measured from blood sample
- Reported as "biological age" in years

**Optimal Ranges:**
- Biological age < chronological age (negative age acceleration)
- Age acceleration: Biological age - chronological age
- Optimal: 5+ years younger than chronological age
- Acceptable: Within 2-3 years of chronological age
- Concerning: 5+ years older than chronological age

**What OMICmAge Reflects:**
- Cellular aging and senescence
- Cumulative oxidative stress and inflammation
- DNA damage and repair capacity
- Metabolic health
- Immune system aging (immunosenescence)
- Overall healthspan and disease risk

**Factors That Accelerate Biological Aging:**

**Lifestyle:**
- Smoking (single worst factor)
- Excessive alcohol
- Poor diet (high processed foods, sugar)
- Sedentary behavior
- Chronic stress
- Sleep deprivation
- Environmental toxins

**Medical:**
- Obesity (especially visceral fat)
- Chronic inflammation
- Metabolic syndrome and diabetes
- Cardiovascular disease
- Chronic infections
- Autoimmune diseases
- Mental health disorders

**How to Slow/Reverse Biological Aging:**

**Dietary Interventions (Strong Evidence):**
- Mediterranean diet
- Reduce refined carbs and added sugars
- Increase fruits and vegetables (antioxidants)
- Omega-3 fatty acids (anti-inflammatory)
- Adequate protein (muscle preservation)
- Caloric restriction or time-restricted eating
- Polyphenol-rich foods (berries, green tea, dark chocolate)
- Cruciferous vegetables (epigenetic benefits)

**Exercise (Proven Effective):**
- Aerobic exercise: 150-300 min weekly
- Resistance training: 2-3x weekly
- High-intensity interval training
- Combination training most effective
- Regular physical activity slows epigenetic aging
- Even starting exercise later in life beneficial

**Sleep Optimization:**
- 7-9 hours quality sleep nightly
- Consistent sleep schedule
- Poor sleep accelerates aging
- Deep sleep critical for cellular repair
- Treat sleep disorders (apnea)

**Stress Management:**
- Chronic stress accelerates epigenetic aging
- Meditation and mindfulness
- Social support and connection
- Stress reduction techniques
- Yoga, tai chi
- Nature exposure

**Avoiding Accelerators:**
- Don't smoke (or quit immediately)
- Limit alcohol (<1-2 drinks/day, ideally none)
- Avoid environmental toxins
- Limit ultra-processed foods
- Reduce chronic inflammation

**Supplements (Evidence-Based for Biological Age):**
- NMN (Nicotinamide Mononucleotide): 250-500mg daily
- NR (Nicotinamide Riboside): 250-500mg daily
- Resveratrol: 250-500mg daily (with fats)
- Quercetin: 500-1000mg daily
- Fisetin: 100-500mg daily (senolytic)
- Omega-3 (EPA/DHA): 2-4g daily
- Vitamin D3: Optimize to 40-60 ng/mL
- Spermidine: 1-2mg daily (autophagy inducer)
- Alpha-lipoic acid: 300-600mg daily

**Advanced Interventions:**
- Metformin: 500-1000mg daily (if appropriate)
- Rapamycin: Low-dose pulsed (under medical supervision)
- Senolytics: Dasatinib + quercetin (periodic, under supervision)
- NAD+ boosters: NMN, NR
- Hyperbaric oxygen therapy
- Sauna (heat hormesis)
- Cold exposure

**Monitoring and Testing:**
- Epigenetic age testing: TruAge, GrimAge, myDNAge
- Retest every 6-12 months
- Track age acceleration trend
- Assess intervention effectiveness
- Costs $200-500 per test

**Realistic Expectations:**
- Can reverse biological age 1-5 years with interventions
- Takes 6-12 months to see changes
- Consistency critical
- Some respond better than others
- Genetics play a role but lifestyle dominant
- Younger biological age achievable at any chronological age

**Research-Backed Interventions:**

**Diet Studies:**
- Mediterranean diet reduces epigenetic age
- Caloric restriction slows aging clocks
- High vegetable intake associated with younger biological age

**Exercise Studies:**
- Regular exercisers have 9+ years younger biological age
- Both aerobic and resistance training effective
- High fitness level = slower epigenetic aging

**Supplement Studies:**
- NMN/NR shown to reverse aspects of aging in trials
- Omega-3 preserves telomeres and reduces epigenetic age
- Vitamin D deficiency accelerates aging

**Special Populations:**

**Older Adults:**
- Can still reverse biological aging
- Interventions effective at any age
- Focus on exercise, diet, sleep
- Social connection important

**Those with Chronic Disease:**
- Controlling disease slows aging
- Medications (metformin) may help
- Lifestyle even more critical
- Work with physician

**Optimization Protocol (Comprehensive):**

**Tier 1 (Essential):**
1. Don't smoke
2. Exercise regularly (combo aerobic + strength)
3. Mediterranean-style diet
4. 7-9 hours quality sleep
5. Manage stress
6. Maintain healthy weight

**Tier 2 (Evidence-Based):**
7. Omega-3 supplementation
8. Vitamin D optimization
9. Time-restricted eating (16:8)
10. Social connection
11. Purpose and meaning

**Tier 3 (Advanced):**
12. NMN/NR supplementation
13. Senolytics (periodic)
14. Metformin (if appropriate)
15. Sauna and cold exposure
16. Hyperbaric oxygen (if accessible)

**Limitations of Epigenetic Clocks:**
- Not perfect predictors (population-level trends)
- Test-to-test variability exists
- Different clocks give different results
- Environmental factors can transiently affect readings
- Best used for tracking trends over time

**Special Considerations:**
- OMICmAge one of several epigenetic clocks (GrimAge, PhenoAge, DunedinPACE also used)
- Each clock emphasizes different aspects of aging
- Multi-clock testing provides fuller picture
- Single test less informative than trend over time
- Biological age younger than chronological age is goal""",
        'recommendations_primary': 'Mediterranean diet, exercise 150+ min weekly (aerobic + strength), 7-9hr quality sleep, stress management, don\'t smoke, limit alcohol, maintain healthy weight, social connection',
        'therapeutics_primary': 'NMN/NR 250-500mg daily, omega-3 2-4g, vitamin D optimization, resveratrol 250-500mg, quercetin 500-1000mg; metformin if appropriate; periodic senolytics under supervision'
    },

    'DunedinPACE': {
        'education': """**Understanding DunedinPACE (Pace of Aging Clock)**

DunedinPACE (Pace of Aging, Computed from the Epigenome) is unique among aging clocks - it measures the *rate* of biological aging, not just biological age. It tells you how fast you're aging relative to the passage of calendar time.

**The Longevity Connection:**
- Predicts healthspan and lifespan
- Higher PACE = faster aging = shorter healthspan
- Each 1-year increase in PACE associated with increased mortality risk
- Predicts age-related disease onset
- Reflects cumulative lifestyle effects
- Reversible with interventions
- Tracks effectiveness of anti-aging strategies

**Understanding the Metric:**
- PACE = 1.0 means aging at normal rate (1 biological year per calendar year)
- PACE < 1.0 means aging slower than normal (e.g., 0.8 = aging 0.8 years per calendar year)
- PACE > 1.0 means aging faster than normal (e.g., 1.2 = aging 1.2 years per calendar year)
- Based on DNA methylation from blood sample
- Developed from Dunedin Study (longitudinal cohort)

**Optimal Ranges:**
- Optimal: 0.6-0.9 (aging slower than average)
- Good: 0.9-1.0 (aging at normal rate)
- Concerning: 1.0-1.2 (aging faster than average)
- High risk: >1.2 (significantly accelerated aging)

**What DunedinPACE Reflects:**
- Rate of decline in organ function
- Cellular aging speed
- Accumulation of biological damage
- System-level aging (multi-organ)
- Real-time aging process (not just accumulated damage)

**Difference from Other Clocks:**
- Most clocks measure biological age (static snapshot)
- PACE measures rate of aging (dynamic process)
- More sensitive to recent lifestyle changes
- Better for tracking intervention effects
- Predicts future decline, not just current state

**Factors That Accelerate Aging Rate (Higher PACE):**

**Lifestyle:**
- Smoking (most significant accelerator)
- Excessive alcohol consumption
- Poor diet quality
- Physical inactivity
- Chronic sleep deprivation
- High stress
- Social isolation

**Metabolic:**
- Obesity and excess body fat
- Insulin resistance
- Metabolic syndrome
- Chronic inflammation
- Oxidative stress

**Environmental:**
- Air pollution exposure
- Toxin exposure
- Chronic infections
- UV radiation (excessive sun)

**How to Slow Aging Rate (Lower PACE):**

**Exercise (Most Effective):**
- Aerobic exercise: 150-300 min weekly
- Resistance training: 2-3x weekly
- HIIT: 2-3x weekly
- Combination training optimal
- Higher fitness = slower PACE
- Even moderate activity beneficial

**Diet Quality:**
- Mediterranean diet
- High fruit and vegetable intake
- Whole grains over refined
- Lean proteins
- Healthy fats (omega-3, olive oil)
- Limit processed foods and added sugars
- Adequate but not excessive calories

**Weight and Body Composition:**
- Maintain healthy BMI (18.5-24.9)
- Reduce visceral fat
- Preserve muscle mass
- Avoid yo-yo dieting
- Gradual sustainable weight loss if needed

**Sleep:**
- 7-9 hours nightly
- Consistent schedule
- Good sleep quality
- Address sleep disorders

**Stress Management:**
- Mindfulness and meditation
- Social support
- Purpose and meaning
- Relaxation techniques
- Work-life balance

**Avoid Accelerators:**
- Don't smoke (or quit)
- Limit alcohol (≤1-2 drinks/day)
- Minimize environmental toxins
- Sun protection (but get vitamin D)

**Supplements to Slow Aging Rate:**
- Omega-3 (EPA/DHA): 2-4g daily (anti-inflammatory)
- Vitamin D3: Optimize to 40-60 ng/mL
- Magnesium: 300-500mg daily
- NAD+ boosters: NMN 250-500mg or NR 250-500mg
- Resveratrol: 250-500mg daily
- Quercetin: 500-1000mg daily
- Spermidine: 1-2mg daily
- Alpha-lipoic acid: 300-600mg

**Advanced Interventions:**
- Metformin: 500-1000mg daily (if appropriate)
- Rapamycin: Low-dose pulsed protocol (medical supervision)
- Senolytics: Periodic (dasatinib + quercetin)
- Time-restricted eating (16:8 or similar)
- Caloric restriction (15-25% reduction if appropriate)

**Monitoring Progress:**
- Retest every 6-12 months
- Track PACE over time
- Goal: Reduce PACE below 1.0
- Even small reductions (0.1-0.2) meaningful
- Assess intervention effectiveness

**Research Findings:**

**Exercise Studies:**
- Regular exercisers have PACE 0.2-0.3 lower
- High fitness associated with PACE 0.8-0.9
- Both aerobic and strength training slow PACE
- Starting exercise reduces PACE within months

**Dietary Studies:**
- Mediterranean diet lowers PACE
- High vegetable intake associated with slower aging
- Processed food consumption accelerates PACE

**Lifestyle Studies:**
- Smoking increases PACE by 0.15-0.25
- Obesity accelerates PACE significantly
- Social connection slows aging rate

**Realistic Expectations:**
- Can reduce PACE 0.1-0.3 with comprehensive interventions
- Takes 3-6 months to see changes
- Younger individuals may have more room to improve
- Consistency critical
- Combining interventions synergistic

**Protocol for Lowering PACE:**

**Foundation (Everyone):**
1. Exercise 200+ min weekly (mix of cardio + strength)
2. Mediterranean-style diet
3. 7-9 hours quality sleep
4. Don't smoke, limit alcohol
5. Stress management
6. Maintain healthy weight

**Optimization:**
7. Omega-3 supplementation
8. Vitamin D optimization
9. NAD+ boosters (NMN/NR)
10. Time-restricted eating
11. Social engagement

**Advanced (Under Guidance):**
12. Metformin
13. Periodic senolytics
14. Caloric restriction protocols
15. Cold/heat exposure
16. Hyperbaric oxygen

**Special Populations:**

**Younger Adults (20-40):**
- Prevention mode
- Establish healthy habits
- Target PACE <1.0
- Build metabolic reserve

**Middle Age (40-60):**
- Critical window for intervention
- Can significantly impact healthspan
- Target PACE 0.8-1.0
- Address metabolic changes

**Older Adults (60+):**
- Can still slow aging rate
- Focus on function preservation
- Reduce frailty risk
- Target PACE <1.2 (or lower)

**Clinical Significance:**
- PACE predicts:
  - Grip strength decline
  - Cognitive decline
  - Facial aging
  - Disease onset
  - Disability and frailty
  - Mortality

**Comparing to Other Clocks:**
- DunedinPACE: Rate of aging (speed)
- GrimAge, PhenoAge: Biological age (accumulated damage)
- Both informative, measure different aspects
- PACE more sensitive to recent changes
- Use together for complete picture

**Limitations:**
- Population-level trends (individual variation)
- Affected by acute illness (wait to test if sick)
- Test-to-test variability
- Best used for longitudinal tracking
- Single test less informative

**Special Considerations:**
- Developed specifically to track aging rate
- Validated against physical/cognitive decline
- Sensitive to lifestyle interventions
- Useful for personalizing anti-aging protocols
- Goal: Keep PACE as low as possible""",
        'recommendations_primary': 'Exercise 200+ min weekly (cardio + strength), Mediterranean diet, maintain healthy weight, 7-9hr sleep, stress management, don\'t smoke, social engagement, metabolic health optimization',
        'therapeutics_primary': 'Omega-3 2-4g daily, vitamin D optimization, NMN/NR 250-500mg, resveratrol 250-500mg, magnesium 300-500mg; metformin if appropriate; time-restricted eating'
    },

    'WellPath PACE': {
        'education': """**Understanding WellPath PACE**

WellPath PACE is WellPath's proprietary implementation of the Pace of Aging calculation, measuring how fast you're biologically aging. It integrates multiple biomarkers and lifestyle factors to provide a comprehensive aging rate assessment.

**The Longevity Connection:**
- Lower PACE = slower biological aging = longer healthspan
- Predicts healthy aging trajectory
- Tracks effectiveness of lifestyle interventions
- Identifies accelerated aging early
- Guides personalized optimization strategies
- Reflects cumulative impact of health behaviors

**Understanding Your WellPath PACE:**
- 1.0 = Normal aging rate (1 biological year per calendar year)
- <1.0 = Slower than normal aging (optimal)
- >1.0 = Faster than normal aging (needs intervention)
- Combines epigenetic, metabolic, and functional markers
- Updated as you track biomarkers over time

**What Influences WellPath PACE:**

**Biomarkers:**
- Metabolic markers (HbA1c, insulin sensitivity)
- Inflammatory markers (hsCRP)
- Cardiovascular markers (lipid panel, blood pressure)
- Kidney function (Cystatin C)
- Liver function
- Body composition

**Lifestyle Factors:**
- Physical activity and exercise
- Diet quality and nutrition
- Sleep quantity and quality
- Stress levels
- Substance use (alcohol, tobacco)
- Social connection

**Functional Measures:**
- Grip strength
- Cardiovascular fitness
- Cognitive function
- Physical performance

**How to Improve Your WellPath PACE:**

**Exercise (Top Priority):**
- Target: 200+ minutes weekly
- Mix aerobic (running, cycling) and resistance (weights)
- Include HIIT 2-3x weekly
- Build to higher intensities gradually
- Track fitness improvements
- Make exercise non-negotiable habit

**Nutrition Optimization:**
- Mediterranean or similar anti-inflammatory diet
- 7-9 servings fruits/vegetables daily
- Lean proteins (fish, poultry, legumes)
- Whole grains over refined
- Healthy fats (olive oil, nuts, avocados)
- Limit added sugars and processed foods
- Stay hydrated (8-12 cups water daily)

**Metabolic Health:**
- Maintain healthy weight (BMI 18.5-24.9)
- Reduce visceral fat
- Optimize insulin sensitivity
- Monitor blood glucose
- Manage lipid panel
- Control blood pressure

**Sleep Optimization:**
- 7-9 hours nightly
- Consistent sleep schedule
- Cool, dark, quiet room
- Address sleep disorders
- Track sleep quality
- Prioritize deep and REM sleep

**Stress Management:**
- Daily mindfulness or meditation
- Regular relaxation practices
- Social support network
- Work-life balance
- Purpose and meaning
- Professional help if needed

**Avoid Aging Accelerators:**
- No smoking (quit if needed)
- Limit alcohol (≤1-2 drinks/day)
- Minimize environmental toxins
- Reduce chronic inflammation
- Avoid prolonged sitting

**WellPath-Specific Recommendations:**
- Follow pillar-specific guidance
- Address markers flagged as suboptimal
- Track progress in all health dimensions
- Use WellPath scoring to guide priorities
- Leverage behavior tracking features

**Supplements for PACE Optimization:**
- Follow WellPath supplement recommendations
- Omega-3: 2-4g EPA/DHA daily
- Vitamin D: Optimize to 40-60 ng/mL
- NAD+ boosters: NMN 250-500mg
- Magnesium: 300-500mg daily
- Resveratrol: 250-500mg daily
- Probiotics: Multi-strain formula

**Monitoring Your PACE:**
- WellPath recalculates as you update data
- Track trend over months (not day-to-day)
- Goal: Progressive reduction in PACE
- Small improvements (0.05-0.1) meaningful
- Use to assess intervention effectiveness
- Compare to previous scores

**Interpretation:**

**PACE 0.6-0.8 (Excellent):**
- Aging significantly slower than normal
- Maintain current habits
- Fine-tune optimization
- Very positive long-term outlook

**PACE 0.8-1.0 (Good):**
- Aging at or slightly below normal rate
- Continue healthy behaviors
- Identify areas for improvement
- On track for healthy aging

**PACE 1.0-1.2 (Needs Improvement):**
- Aging faster than optimal
- Requires lifestyle modifications
- Address key risk factors
- Follow WellPath recommendations

**PACE >1.2 (Concerning):**
- Significantly accelerated aging
- Urgent lifestyle changes needed
- Address multiple risk factors
- Consider medical consultation
- Follow comprehensive intervention protocol

**Personalization:**
- WellPath PACE integrates your unique data
- Recommendations tailored to your markers
- Focus on highest-impact interventions
- Track what moves your PACE most
- Adjust strategies based on response

**Timeline for Improvement:**
- Initial changes: 1-3 months (early markers improve)
- Meaningful PACE reduction: 3-6 months
- Sustained improvement: 6-12 months
- Long-term optimization: Ongoing
- Consistency key to success

**Integration with WellPath System:**
- PACE reflects all pillar scores
- Improving any pillar helps PACE
- Markers contribute weighted to PACE
- Behaviors tracked impact PACE
- Education modules guide optimization

**Action Plan Based on PACE:**

**If PACE >1.2:**
1. Immediate: Stop smoking, reduce alcohol
2. Week 1: Start daily walking (30+ min)
3. Week 2: Clean up diet (add vegetables, remove processed foods)
4. Week 3: Establish sleep routine
5. Month 2: Add resistance training
6. Month 3: Implement stress management
7. Ongoing: Track and adjust

**If PACE 1.0-1.2:**
1. Increase exercise intensity/duration
2. Refine diet quality
3. Optimize sleep
4. Add targeted supplements
5. Address specific weak markers
6. Enhance recovery practices

**If PACE <1.0:**
1. Maintain current habits
2. Fine-tune optimization
3. Experiment with advanced strategies
4. Focus on longevity practices
5. Help others improve their PACE

**Special Considerations:**
- PACE improves with comprehensive approach
- Single intervention less effective than multiple
- Synergy between lifestyle factors
- Younger biological age possible at any chronological age
- WellPath provides tools and tracking
- Community support enhances success

**Limitations:**
- Calculation based on available markers
- More complete data = more accurate PACE
- Affected by acute illness (temporary)
- Population-level algorithm (individual variation)
- Best used for tracking personal trends

**Goal Setting:**
- Short-term (3 months): Reduce PACE by 0.05-0.10
- Medium-term (6 months): Reduce PACE by 0.10-0.20
- Long-term (12+ months): Achieve PACE <1.0
- Ongoing: Maintain or continue reducing

**Success Factors:**
- Consistency over perfection
- Address multiple dimensions simultaneously
- Use WellPath tracking and feedback
- Celebrate small improvements
- Adjust based on what works for you
- Stay engaged with the process""",
        'recommendations_primary': 'Follow WellPath pillar recommendations, exercise 200+ min weekly, Mediterranean diet, 7-9hr sleep, stress management, maintain healthy weight, address flagged biomarkers, track progress',
        'therapeutics_primary': 'Follow WellPath supplement recommendations, omega-3 2-4g, vitamin D optimization, NAD+ boosters (NMN 250-500mg), magnesium 300-500mg; address specific marker deficiencies'
    },

    'WellPath PhenoAge': {
        'education': """**Understanding WellPath PhenoAge**

WellPath PhenoAge is WellPath's implementation of the Phenotypic Age calculation, which estimates biological age based on clinical biomarkers. It reflects the aging of your organ systems and predicts mortality risk better than chronological age.

**The Longevity Connection:**
- Each year of phenotypic age acceleration increases mortality risk
- Predicts onset of age-related diseases
- Reflects cumulative health of multiple organ systems
- Reversible with lifestyle and medical interventions
- Lower PhenoAge = extended healthspan and lifespan
- Tracks effectiveness of anti-aging strategies

**Understanding Your WellPath PhenoAge:**
- Reported as biological age in years
- Compare to your chronological age
- Optimal: 5-10+ years younger than chronological age
- Acceptable: Within 3 years of chronological age
- Concerning: 5+ years older than chronological age

**Biomarkers Influencing PhenoAge:**

**Metabolic:**
- Glucose and HbA1c (glucose control)
- Albumin (nutritional status, liver function)
- Creatinine (kidney function)
- Alkaline phosphatase (liver/bone health)

**Hematologic:**
- White blood cell count (immune function, inflammation)
- Red cell distribution width (RDW) - reflects cellular aging
- Mean corpuscular volume (MCV) - red blood cell size

**Inflammatory:**
- C-reactive protein (hsCRP)
- Lymphocyte percentage

**Other:**
- Chronological age (baseline)
- Blood pressure (cardiovascular stress)

**What PhenoAge Reflects:**
- Multi-system biological aging
- Metabolic health
- Inflammatory status
- Organ function (kidney, liver)
- Cardiovascular aging
- Immune system aging
- Nutritional status

**How to Improve Your WellPath PhenoAge:**

**Optimize Glucose Control:**
- Reduce refined carbohydrates and added sugars
- Increase fiber (vegetables, whole grains)
- Exercise regularly (improves insulin sensitivity)
- Maintain healthy weight
- Monitor HbA1c (goal <5.7%)
- Consider berberine or metformin if pre-diabetic

**Support Kidney Function:**
- Stay well-hydrated (8-12 cups water daily)
- Maintain healthy blood pressure (<130/80)
- Limit NSAIDs (ibuprofen, naproxen)
- Moderate protein intake (don't overdo it)
- Control blood sugar
- Avoid nephrotoxic substances

**Support Liver Health:**
- Limit alcohol (<1-2 drinks/day, ideally none)
- Maintain healthy weight (avoid fatty liver)
- Eat liver-supporting foods (cruciferous veggies)
- Avoid excessive fructose
- Consider milk thistle, NAC supplements
- Regular exercise

**Reduce Inflammation:**
- Anti-inflammatory diet (Mediterranean)
- Omega-3 supplementation (2-4g EPA/DHA)
- Regular exercise
- Adequate sleep (7-9 hours)
- Stress management
- Maintain healthy weight
- Address chronic infections

**Optimize Blood Markers:**
- Albumin: Adequate protein intake, liver health
- RDW: Address nutritional deficiencies (iron, B12, folate)
- WBC: Manage inflammation, avoid chronic stress
- MCV: Optimize B12 and folate status
- Alkaline phosphatase: Bone and liver health

**Exercise:**
- Aerobic: 150-300 min weekly
- Resistance training: 2-3x weekly
- Improves glucose control, reduces inflammation
- Supports all organ systems
- Reduces biological age markers

**Nutrition:**
- Mediterranean or DASH diet
- High in fruits, vegetables, whole grains
- Lean proteins (fish, poultry, legumes)
- Healthy fats (olive oil, nuts, fatty fish)
- Adequate but not excessive protein
- Limit processed foods and added sugars

**Cardiovascular Health:**
- Maintain healthy blood pressure (<130/80)
- Optimize lipid panel
- Regular aerobic exercise
- Heart-healthy diet
- Stress management
- Don't smoke, limit alcohol

**Supplements to Improve PhenoAge:**
- Omega-3 (EPA/DHA): 2-4g daily (anti-inflammatory)
- Vitamin D3: Optimize to 40-60 ng/mL
- B-complex: For methylation, homocysteine
- Magnesium: 300-500mg daily
- NAC: 600-1200mg daily (liver support, antioxidant)
- Berberine: 500mg 3x daily (glucose control)
- Curcumin: 500-1000mg daily (anti-inflammatory)
- Resveratrol: 250-500mg daily

**Medical Interventions:**
- Metformin: If pre-diabetic or diabetic (anti-aging benefits)
- Blood pressure medications if needed (ACE inhibitors, ARBs)
- Statin if indicated (cardiovascular protection)
- Address specific marker abnormalities
- Regular health screening

**Monitoring Your PhenoAge:**
- WellPath recalculates as biomarkers update
- Retest blood work every 3-6 months
- Track PhenoAge trend over time
- Goal: Reduce by 1-5 years within 6-12 months
- Assess intervention effectiveness

**Interpretation:**

**PhenoAge 5-10+ years younger:**
- Excellent biological aging profile
- Maintain current strategies
- Continue healthy lifestyle
- Very positive prognosis

**PhenoAge 0-5 years younger:**
- Good biological aging
- Room for optimization
- Refine lifestyle factors
- Address any suboptimal markers

**PhenoAge same or slightly older:**
- Average biological aging
- Implement comprehensive interventions
- Focus on key biomarkers
- Significant improvement possible

**PhenoAge 5+ years older:**
- Accelerated biological aging
- Urgent lifestyle modifications needed
- Address all modifiable risk factors
- Consider medical interventions
- Work closely with healthcare provider

**Timeline for Improvement:**
- Some markers improve quickly (glucose, inflammation): 1-3 months
- Structural changes (kidney function): 3-6 months
- Meaningful PhenoAge reduction: 3-6 months
- Sustained improvement: 6-12 months
- Long-term optimization: Ongoing

**Priority Actions:**

**If PhenoAge >5 years older:**
1. Comprehensive blood work review
2. Address highest-risk markers first
3. Implement anti-inflammatory diet
4. Start regular exercise program
5. Optimize sleep and stress
6. Consider metformin (with doctor)
7. Aggressive lifestyle intervention

**If PhenoAge 0-5 years older:**
1. Fine-tune diet quality
2. Increase exercise intensity
3. Optimize specific biomarkers
4. Add targeted supplements
5. Enhance recovery practices

**If PhenoAge younger:**
1. Maintain current habits
2. Continue optimization
3. Experiment with advanced strategies
4. Focus on healthspan extension

**Integration with WellPath:**
- PhenoAge integrates multiple biomarkers from WellPath tracking
- Recommendations personalized to your profile
- Pillar scores reflect PhenoAge components
- Comprehensive approach addresses all factors
- Track progress across all dimensions

**Special Considerations:**
- PhenoAge based on commonly available biomarkers
- More accessible than epigenetic testing
- Strong predictor of mortality and morbidity
- Responds to lifestyle interventions
- Regular monitoring important
- Comprehensive blood panel needed for accuracy

**Research Evidence:**
- Developed from NHANES data (large population studies)
- Validated against mortality outcomes
- Predicts disease risk across organ systems
- Lifestyle interventions shown to reverse PhenoAge
- Exercise and diet most impactful

**Limitations:**
- Based on population averages
- Individual variation in response
- Acute illness temporarily affects markers
- Some factors genetic (less modifiable)
- Best used for longitudinal tracking

**Success Strategies:**
- Address multiple biomarkers simultaneously
- Consistency over perfection
- Regular monitoring (every 3-6 months)
- Celebrate improvements
- Adjust strategies based on results
- Use WellPath tools and recommendations
- Stay engaged with optimization process""",
        'recommendations_primary': 'Anti-inflammatory diet, reduce refined carbs/sugar, exercise 150-300min weekly, optimize glucose control, support liver/kidney function, manage inflammation, 7-9hr sleep, stress management',
        'therapeutics_primary': 'Omega-3 2-4g daily, vitamin D optimization, berberine 500mg 3x daily, NAC 600-1200mg, B-complex, magnesium 300-500mg; metformin if pre-diabetic; address specific marker deficiencies'
    }
}

# All 14 biometrics education content complete!
# Ready to run script to populate database.

# =============================================================================
# DATABASE UPDATE FUNCTION
# =============================================================================

def populate_biometric_education():
    """Populate education content for remaining biometrics"""
    conn = psycopg2.connect(DATABASE_URL)
    cur = conn.cursor()

    try:
        print("="*80)
        print("POPULATING REMAINING BIOMETRIC EDUCATION")
        print("="*80)
        print()

        # Update biometrics
        biometric_count = 0
        for biometric_name, content in BIOMETRIC_EDUCATION_REMAINING.items():
            cur.execute("""
                UPDATE biometrics_base
                SET
                    education = %s,
                    recommendations_primary = COALESCE(recommendations_primary, %s),
                    therapeutics_secondary = COALESCE(therapeutics_secondary, %s),
                    updated_at = NOW()
                WHERE biometric_name = %s
                  AND is_active = true
            """, (
                content['education'],
                content.get('recommendations_primary'),
                content.get('therapeutics_primary'),
                biometric_name
            ))

            if cur.rowcount > 0:
                print(f"✓ Updated biometric: {biometric_name}")
                biometric_count += 1
            else:
                print(f"⚠ Biometric not found or inactive: {biometric_name}")

        conn.commit()

        print()
        print("="*80)
        print("SUMMARY")
        print("="*80)
        print(f"Biometrics updated: {biometric_count}")
        print()
        print("✅ Biometric education content population complete!")
        print()
        print("Next step: Create biometric education sections parser")

    except Exception as e:
        conn.rollback()
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()
        raise
    finally:
        cur.close()
        conn.close()

if __name__ == '__main__':
    print("BIOMETRIC EDUCATION CONTENT SCRIPT - COMPLETE")
    print()
    print(f"Biometrics to update: {len(BIOMETRIC_EDUCATION_REMAINING)}")
    print()

    biometric_names = sorted(BIOMETRIC_EDUCATION_REMAINING.keys())
    print("Biometrics with comprehensive education content:")
    for name in biometric_names:
        print(f"  - {name}")

    print()
    print("All 14 missing biometrics now have comprehensive education content!")
    print()

    # Running database update
    populate_biometric_education()
    print("Database update complete!")
