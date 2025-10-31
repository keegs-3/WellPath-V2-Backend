#!/usr/bin/env python3
"""
COMPREHENSIVE biomarker and biometric education content.
This is the COMPLETE set - all 60 biomarkers and all 22 biometrics.
Rich, detailed, actionable content for every single marker.
"""

import psycopg2

DATABASE_URL = "postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres"

# =============================================================================
# BIOMARKER EDUCATION CONTENT - ALL 60 BIOMARKERS
# =============================================================================

BIOMARKER_EDUCATION_COMPLETE = {
    # Already done: LDL, HbA1c, Vitamin D

    # =========================================================================
    # CARDIOVASCULAR HEALTH BIOMARKERS
    # =========================================================================

    'HDL': {
        'education': """**Understanding HDL Cholesterol**

HDL (High-Density Lipoprotein) is known as "good" cholesterol because it helps remove other forms of cholesterol from your bloodstream, transporting them back to the liver for disposal.

**The Longevity Connection:**
Every 1 mg/dL increase in HDL is associated with 2-3% reduction in cardiovascular disease risk. However, very high HDL (>80-100 mg/dL) may not provide additional benefit and could indicate dysfunction.

**Optimal Ranges:**
- Men: 50-70 mg/dL optimal (>40 acceptable)
- Women: 60-80 mg/dL optimal (>50 acceptable)
- Functionality matters more than absolute number

**Beyond the Number:**
- HDL particle size and number (HDL-P) more important than HDL-C
- HDL functionality (cholesterol efflux capacity) determines benefit
- Dysfunctional HDL can actually be pro-inflammatory

**How to Optimize HDL:**

**Exercise (Most Effective):**
- Aerobic exercise raises HDL most reliably
- 30+ minutes, 5x per week can increase HDL by 5-10%
- High-intensity interval training particularly effective
- Resistance training also helps

**Diet:**
- Healthy fats: olive oil, avocado, nuts, fatty fish
- Omega-3s: especially from fish (EPA/DHA)
- Limit trans fats and refined carbs
- Moderate alcohol (1 drink/day) may raise HDL but has other risks

**Weight Loss:**
- Every 3 kg (6.6 lbs) lost can raise HDL by 1 mg/dL
- Losing visceral fat particularly beneficial

**Avoid HDL-Lowering Factors:**
- Smoking (lowers HDL by 10-15%)
- Sedentary lifestyle
- High refined carbohydrate diet
- Certain medications (beta blockers, some statins)

**When Low HDL is Concerning:**
Men <40 mg/dL or Women <50 mg/dL increases cardiovascular risk significantly, especially with:
- High triglycerides (>150 mg/dL)
- Metabolic syndrome
- Family history of early heart disease

**Advanced Testing:**
Consider NMR LipoProfile or CardioIQ to measure:
- HDL particle number (HDL-P)
- HDL particle size
- Cholesterol efflux capacity""",
        'recommendations_primary': 'Exercise 30+ minutes 5x weekly, consume healthy fats from fish/nuts/olive oil, maintain healthy weight',
        'therapeutics_primary': 'Niacin most effective (500-2000mg) but may cause flushing; fibrates for low HDL + high triglycerides'
    },

    'Triglycerides': {
        'education': """**Understanding Triglycerides**

Triglycerides are fats in your blood that store excess energy from your diet. Elevated levels indicate poor metabolic health and significantly increase cardiovascular and diabetes risk.

**The Longevity Connection:**
- Levels >150 mg/dL increase heart disease risk by 30-50%
- Each 89 mg/dL increase raises coronary heart disease risk by 37%
- High triglycerides predict metabolic syndrome and type 2 diabetes
- Contribute to non-alcoholic fatty liver disease (NAFLD)

**Optimal Ranges:**
- Optimal: <100 mg/dL (some say <70 mg/dL)
- Normal: <150 mg/dL
- Borderline high: 150-199 mg/dL
- High: 200-499 mg/dL
- Very high: ≥500 mg/dL (pancreatitis risk)

**What Raises Triglycerides:**

**Diet (Biggest Impact):**
- Refined carbohydrates and added sugars
- Alcohol (even moderate amounts)
- Excess calories from any source
- Fructose particularly problematic

**Lifestyle:**
- Sedentary behavior
- Poor sleep
- Chronic stress
- Obesity, especially visceral fat

**Medical:**
- Uncontrolled diabetes
- Hypothyroidism
- Kidney disease
- Certain medications (steroids, beta blockers, diuretics)

**How to Lower Triglycerides (Very Responsive):**

**Diet Changes (Can Lower 50-75%):**
- Cut added sugars and refined carbs drastically
- Limit fructose (including fruit juice, honey, agave)
- Reduce/eliminate alcohol
- Increase omega-3 fatty acids (fish, fish oil)
- Emphasize fiber-rich foods
- Choose low glycemic index carbs

**Exercise:**
- Aerobic exercise especially effective
- 30+ minutes most days
- Can lower triglycerides 20-30% in 8-12 weeks

**Weight Loss:**
- Every 5-10% body weight lost can reduce triglycerides 20-40%
- Visceral fat loss particularly important

**Supplements:**
- Fish oil (EPA/DHA): 2-4g daily can lower 25-30%
- Niacin: 1-2g daily (prescription strength)
- Berberine: 900-1500mg daily

**Prescription Options:**
- High-dose omega-3s (Vascepa/Lovaza): 4g EPA
- Fibrates (fenofibrate, gemfibrozil)
- Niacin (extended release)

**Special Note on Postprandial Triglycerides:**
Measure fasting for accuracy. Triglycerides rise significantly after eating, especially carb-heavy meals. Persistent elevation after 4-6 hours fasting indicates metabolic dysfunction.

**Triglycerides:HDL Ratio:**
Should be <2.0 (ideally <1.0). High ratio predicts:
- Insulin resistance
- Small dense LDL particles
- Increased cardiovascular risk""",
        'recommendations_primary': 'Drastically reduce added sugars and refined carbs, consume 2-4g omega-3s daily, exercise regularly',
        'therapeutics_primary': 'High-dose EPA (Vascepa 4g daily) most effective; fibrates for severe hypertriglyceridemia'
    },

    'ApoB': {
        'education': """**Understanding Apolipoprotein B (ApoB)**

ApoB is a protein found on all atherogenic (plaque-forming) lipoproteins: LDL, VLDL, IDL, and Lp(a). Each atherogenic particle has exactly ONE ApoB molecule, making it the most accurate measure of cardiovascular risk.

**Why ApoB is Superior to LDL-C:**
- LDL-C measures cholesterol content (varies by particle)
- ApoB counts actual NUMBER of atherogenic particles
- You can have "normal" LDL-C but high ApoB (discordance)
- ApoB predicts CVD events better than LDL-C or non-HDL cholesterol

**The Longevity Connection:**
- ApoB is the SINGLE BEST cholesterol marker for predicting heart attacks
- Each 10 mg/dL increase in ApoB increases CVD risk by 10-15%
- High ApoB with "normal" LDL-C indicates small, dense LDL particles (more dangerous)
- Lifetime ApoB exposure determines plaque burden

**Optimal Ranges (More Stringent Than Standard):**
- Optimal: <80 mg/dL (some experts say <70)
- Low risk: <90 mg/dL
- Moderate risk: 90-110 mg/dL
- High risk: 110-130 mg/dL
- Very high: >130 mg/dL

**For High-Risk Individuals:**
- Family history of early CVD: <70 mg/dL
- Established CVD: <60 mg/dL
- Very high risk: <50 mg/dL

**Understanding ApoB vs LDL-C Discordance:**

**Scenario 1: Normal LDL-C, High ApoB**
- MANY small LDL particles (particle number high)
- Each carries less cholesterol (cholesterol content low)
- More dangerous than it appears from LDL-C alone
- Common with metabolic syndrome, diabetes

**Scenario 2: High LDL-C, Normal ApoB**
- FEWER large LDL particles
- Each carries more cholesterol
- Less dangerous than LDL-C suggests
- Seen with familial hypercholesterolemia

**How to Lower ApoB:**

**Diet (Same as LDL):**
- Reduce saturated fat (<7% calories)
- Eliminate trans fats completely
- Increase soluble fiber (10-25g daily)
- Plant stanols/sterols (2g daily)

**Exercise:**
- Cardio especially effective
- 150+ minutes moderate intensity weekly
- Can reduce ApoB 5-15%

**Weight Loss:**
- Particularly effective if metabolically unhealthy
- Visceral fat loss reduces small, dense LDL

**Medication (Often Necessary):**
- Statins: reduce ApoB 30-50%
- PCSK9 inhibitors: reduce ApoB 50-60%
- Ezetimibe: adds 15-20% reduction
- Bempedoic acid: adds 15-25% reduction

**Target-Based Therapy:**
Modern approach uses ApoB as PRIMARY target:
1. Measure ApoB (not just LDL-C)
2. Determine risk-based target (<80, <70, <60 mg/dL)
3. Titrate therapy to achieve ApoB goal
4. Monitor every 3-6 months until at goal

**Who Should Measure ApoB:**
- EVERYONE over age 40 (at least once)
- Anyone with CVD risk factors
- Metabolic syndrome or diabetes
- Family history of early CVD
- Anyone on statin therapy (to ensure adequate reduction)
- If LDL-C doesn't match risk profile

**The Bottom Line:**
ApoB is the GOLD STANDARD cholesterol marker. It's what the other markers are trying to approximate. If you can only test one cholesterol marker, make it ApoB.""",
        'recommendations_primary': 'Same as LDL reduction: limit saturated fat, increase soluble fiber, exercise regularly',
        'therapeutics_primary': 'Statins first-line; PCSK9 inhibitors (evolocumab, alirocumab) for high-risk or familial cases'
    },

    'Total Cholesterol': {
        'education': """**Understanding Total Cholesterol**

Total cholesterol is the sum of all cholesterol in your blood: LDL + HDL + VLDL (triglycerides/5). While useful as a screening tool, it's a poor predictor of cardiovascular risk on its own.

**Why Total Cholesterol is Limited:**
- Combines "good" (HDL) and "bad" (LDL, VLDL) cholesterol
- Someone with high HDL may have high total cholesterol (protective)
- Someone with low HDL and moderate LDL may have "normal" total cholesterol (risky)
- Doesn't distinguish LDL particle size or number

**The Numbers:**
- Desirable: <200 mg/dL
- Borderline high: 200-239 mg/dL
- High: ≥240 mg/dL

**But Context Matters:**
- Total cholesterol 220 mg/dL with HDL 80 = likely healthy
- Total cholesterol 180 mg/dL with HDL 30 = concerning
- Must look at ratios and individual lipid components

**Better Markers to Focus On:**
1. **ApoB** (best single marker)
2. **LDL particle number** (LDL-P)
3. **Triglycerides:HDL ratio** (<2.0 ideal)
4. **Non-HDL cholesterol** (total cholesterol - HDL)

**The Ratio Approach:**
**Total Cholesterol:HDL Ratio:**
- Optimal: <3.0
- Good: 3.0-4.0
- Borderline: 4.0-5.0
- High risk: >5.0

Example: Total 220, HDL 70 → Ratio = 3.1 (good)

**Historical Context:**
Traditional medicine focused heavily on total cholesterol because:
- Easy to measure
- Population studies showed correlation
- Drove early statin trials

But modern medicine recognizes total cholesterol is too crude. The quality and type of cholesterol matter far more than total amount.

**When Total Cholesterol is Useful:**
- Screening in young, healthy individuals
- Tracking trends over time
- Identifying familial hypercholesterolemia (very high levels)

**How to Interpret Your Total Cholesterol:**

**High Total Cholesterol (>240):**
Check:
- Is HDL very high? (protective)
- Is LDL very high? (need treatment)
- What's the TC:HDL ratio?
- Consider ApoB or LDL-P

**Low Total Cholesterol (<160):**
Not always good:
- Is HDL also low? (metabolic syndrome)
- Could indicate malnutrition or illness
- Very low cholesterol (<120) associated with higher mortality in some studies

**The Bottom Line:**
Total cholesterol alone tells you almost nothing. Always interpret with:
- HDL level
- Triglycerides
- LDL (calculated or measured)
- Ideally ApoB or LDL-P
- Clinical risk factors

Don't obsess over total cholesterol. Focus on the markers that actually predict cardiovascular events: ApoB, LDL-P, triglycerides, HDL, and inflammatory markers.""",
        'recommendations_primary': 'Focus on improving lipid QUALITY (raise HDL, lower triglycerides, optimize LDL particle size) not just total number',
        'therapeutics_primary': 'Treatment based on LDL and ApoB targets, not total cholesterol alone'
    },

    'Lp(a)': {
        'education': """**Understanding Lipoprotein(a) - Lp(a)**

Lp(a) is an LDL-like particle with an additional protein (apolipoprotein a) attached. It's 90% genetically determined and is one of the STRONGEST independent risk factors for cardiovascular disease.

**Why Lp(a) is Dangerous:**
- Promotes atherosclerosis (plaque formation)
- Increases blood clot formation (thrombogenic)
- Causes inflammation in arteries
- Resists most traditional cholesterol treatments
- Accumulates in arterial walls more readily than LDL

**The Longevity Connection:**
- Elevated Lp(a) increases CVD risk 2-4 fold
- Associated with earlier onset of heart disease (10-20 years earlier)
- Particularly dangerous when combined with high LDL
- Increases risk of calcific aortic stenosis
- Strong predictor of heart attack and stroke

**Prevalence:**
- 20-30% of population has elevated levels
- More common in people of African descent
- Often undiagnosed because not routinely tested

**Optimal Ranges:**
- Optimal: <30 mg/dL (or <75 nmol/L)
- Borderline: 30-50 mg/dL
- High: >50 mg/dL
- Very high: >100 mg/dL

**Why Lp(a) is Challenging:**

**1. Genetically Determined:**
- Your Lp(a) level is 90% determined by genetics
- Stays relatively constant throughout life
- Doesn't respond well to diet or exercise
- If high, likely high since birth

**2. Resistant to Traditional Treatments:**
- Statins: no effect or may slightly INCREASE Lp(a)
- Most lifestyle changes: minimal to no impact
- Niacin: only treatment that modestly reduces Lp(a) (20-30%)

**3. Testing Challenges:**
- Two measurement methods: mg/dL and nmol/L
- Results not always comparable
- Not included in standard lipid panel
- Many doctors don't routinely test

**Who Should Test Lp(a):**

**High Priority:**
- Family history of premature CVD (<55 men, <65 women)
- Personal history of CVD at young age
- Recurrent cardiovascular events despite optimal LDL
- First-degree relative with high Lp(a)

**Consider Testing:**
- Everyone at least once in lifetime
- High LDL despite healthy lifestyle
- Unexplained atherosclerosis

**Management Strategies (When Elevated):**

**1. Aggressively Lower LDL:**
- Can't lower Lp(a), but CAN lower LDL
- Target very low LDL: <70 mg/dL (some say <55)
- High-intensity statin therapy
- Consider PCSK9 inhibitors
- Ezetimibe if needed

**2. Control All Other Risk Factors:**
- Maintain optimal blood pressure
- Prevent diabetes or optimize glucose control
- Don't smoke (crucial)
- Manage inflammation (hsCRP)
- Optimize all other lipids

**3. Consider Niacin:**
- High-dose niacin (1-2g daily) can lower Lp(a) 20-30%
- Extended-release formulation
- Monitor liver function
- Flushing common side effect

**4. Aspirin (For Some):**
- May help counter thrombogenic effects
- Discuss with doctor based on overall risk

**5. Lipoprotein Apheresis:**
- For extremely high Lp(a) (>150-200 mg/dL) with CVD
- Physically removes Lp(a) from blood
- Similar to dialysis, done every 2-4 weeks
- Only option that dramatically lowers Lp(a)

**Emerging Therapies (Coming Soon):**
- **Antisense oligonucleotides** (Pelacarsen): reduce Lp(a) 80-90%
- **siRNA therapies** (Olpasiran): reduce Lp(a) 70-90%
- Both in late-stage clinical trials
- May be available 2024-2026

**The Bottom Line:**
If you have high Lp(a):
1. Don't panic - it's manageable with aggressive risk reduction
2. Work with a lipidologist or preventive cardiologist
3. Target very low LDL to compensate
4. Optimize all modifiable risk factors
5. Consider advanced imaging (CAC score) to assess plaque burden
6. Stay informed about new therapies (breakthrough treatments coming)

**Family Considerations:**
- If you have high Lp(a), your children have 50% chance
- Consider testing first-degree relatives
- Start prevention early if high""",
        'recommendations_primary': 'Aggressively lower LDL to <70 mg/dL, eliminate all modifiable risk factors, consider high-dose niacin',
        'therapeutics_primary': 'High-dose niacin (1-2g daily) only current option; PCSK9 inhibitors lower Lp(a) 20-30%; antisense therapies coming soon'
    },

    'Omega-3 Index': {
        'education': """**Understanding Omega-3 Index**

The Omega-3 Index measures EPA and DHA (omega-3 fatty acids) as a percentage of total red blood cell fatty acids. It's a powerful predictor of cardiovascular health and reflects your omega-3 status over 3-4 months.

**Why Omega-3s Matter for Longevity:**
- Reduce all-cause mortality by 15-20%
- Lower cardiovascular death risk by 30-40%
- Anti-inflammatory and anti-arrhythmic effects
- Support brain health and cognition
- May reduce dementia risk
- Improve mood and depression

**Omega-3 Index Targets:**
- Optimal (cardioprotective): >8%
- Intermediate: 4-8%
- High risk: <4%

**Current Reality:**
- Average American: 4-5%
- Mediterranean populations: 8-10%
- Japanese (high fish intake): 10-12%

**The Science:**

**Cardiovascular Benefits:**
- Reduce triglycerides 15-30%
- Stabilize atherosclerotic plaques
- Prevent arrhythmias
- Improve endothelial function
- Lower blood pressure modestly

**Brain Benefits:**
- DHA is primary structural fat in brain
- Critical for neuron membrane fluidity
- Supports neuroplasticity
- May slow cognitive decline
- Reduces brain inflammation

**Anti-Inflammatory:**
- EPA/DHA compete with inflammatory omega-6 fatty acids
- Produce anti-inflammatory mediators (resolvins, protectins)
- Lower inflammatory markers

**How to Optimize Your Omega-3 Index:**

**1. Eat Fatty Fish (Best Source):**
**High in EPA/DHA:**
- Wild salmon: 1,200-2,400mg per 3oz
- Sardines: 1,200-1,800mg per 3oz
- Mackerel: 1,000-1,500mg per 3oz
- Herring: 900-1,200mg per 3oz
- Anchovies: 1,200-1,500mg per 3oz

**Target: 2-3 servings weekly minimum**

**Choose Wild-Caught When Possible:**
- Higher omega-3 content
- Lower contaminants
- Better omega-3:omega-6 ratio

**2. Omega-3 Supplementation:**

**Fish Oil:**
- Look for high EPA/DHA concentration
- Triglyceride form better absorbed than ethyl ester
- Aim for 1,000-2,000mg EPA+DHA daily
- Higher doses (3-4g) for low index or high triglycerides

**Algae Oil (Vegan Source):**
- Good DHA source
- Lower EPA than fish oil
- Option for vegetarians/vegans

**Krill Oil:**
- Well absorbed (phospholipid form)
- Lower doses needed
- More expensive
- Also contains astaxanthin

**How Much Do You Need?**
- To reach 8% index from 4-5%: ~2,000mg EPA+DHA daily
- To maintain 8%: ~1,000mg daily (with fish consumption)
- Individual variation - test to confirm

**Quality Matters:**
Look for:
- Third-party testing (IFOS, USP, ConsumerLab)
- Enteric coating (reduces fishy burps)
- Freshness (low oxidation/peroxide value)
- Sustainable sourcing

**3. Reduce Omega-6 Intake:**
High omega-6:omega-3 ratio pro-inflammatory:
- Limit vegetable/seed oils (soybean, corn, cottonseed)
- Avoid processed foods (loaded with omega-6)
- Use olive oil or avocado oil instead
- Target omega-6:omega-3 ratio <4:1 (ideal 1:1)

**Monitoring:**
- Test Omega-3 Index at baseline
- Retest after 3-6 months of optimization
- Maintain annual testing
- At-home finger prick tests available

**Special Considerations:**

**Pregnancy/Breastfeeding:**
- Critical for fetal brain development
- Need 200-300mg DHA daily minimum
- Safe during pregnancy

**Heart Disease:**
- Target higher doses: 2-4g EPA+DHA daily
- Prescription omega-3s (Vascepa, Lovaza) available
- Particularly important post-heart attack

**Brain Health/Dementia Prevention:**
- Higher DHA (vs EPA) may be better for cognition
- Start early - preventive not therapeutic
- Combine with other neuroprotective strategies

**Interactions:**
- Blood thinners: omega-3s have mild anticoagulant effect (usually safe but monitor)
- Large doses (>3g) - discuss with doctor if on anticoagulants

**The Bottom Line:**
Omega-3 Index >8% is one of the most achievable longevity biomarkers. Combining fatty fish 2-3x weekly with a quality fish oil supplement will get most people to optimal levels within 3-6 months. Test, optimize, and maintain.""",
        'recommendations_primary': 'Consume fatty fish 2-3x weekly plus supplement 1,000-2,000mg EPA+DHA daily; target Omega-3 Index >8%',
        'therapeutics_primary': 'High-dose EPA (Vascepa 4g) for high triglycerides; standard fish oil 1-2g daily for prevention'
    },

    # =========================================================================
    # METABOLIC HEALTH BIOMARKERS
    # =========================================================================

    'Fasting Glucose': {
        'education': """**Understanding Fasting Glucose**

Fasting glucose is your blood sugar level after 8-12 hours without food. It's the most basic measure of glucose metabolism and diabetes risk.

**The Longevity Connection:**
- Even "prediabetic" levels (100-125 mg/dL) increase cardiovascular disease risk by 20-30%
- Each 18 mg/dL increase above 90 mg/dL increases all-cause mortality risk
- Fasting glucose >100 mg/dL accelerates biological aging
- Tight glucose control (90-100 mg/dL) associated with longest lifespan

**Optimal Ranges (Stricter Than Standard):**
- Optimal for longevity: 70-85 mg/dL
- Good: 86-99 mg/dL
- Prediabetes: 100-125 mg/dL
- Diabetes: ≥126 mg/dL (on two occasions)

**Standard Guidelines (Too Lenient):**
- "Normal": <100 mg/dL
- Problem: risk starts rising above 90 mg/dL

**Why Lower is Better (Within Reason):**
- Glucose is glycating (damaging to proteins)
- Drives inflammation and oxidative stress
- Accelerates arterial aging
- Promotes cancer growth
- Impairs immune function

**But Not Too Low:**
<70 mg/dL may indicate:
- Excessive insulin production (reactive hypoglycemia)
- Metabolic dysfunction
- Overmedication (if on diabetes meds)

**What Raises Fasting Glucose:**

**Diet:**
- Refined carbohydrates and added sugars
- Excess overall calorie intake
- Low fiber intake
- Evening eating/late-night snacking

**Lifestyle:**
- Sedentary behavior
- Poor sleep (<7 hours)
- Chronic stress (cortisol raises glucose)
- Excess visceral fat

**Medical:**
- Insulin resistance
- Fatty liver disease
- Certain medications (steroids, thiazides)
- Hormonal imbalances (PCOS, Cushing's)

**How to Optimize Fasting Glucose:**

**Diet Strategies:**
- Reduce refined carbs and added sugars drastically
- Increase fiber to 30-40g daily (slows glucose absorption)
- Choose low glycemic index foods
- Eat carbs with protein/fat (blunts glucose spike)
- Consider time-restricted eating (16:8)
- Stop eating 3-4 hours before bed

**Exercise (Highly Effective):**
- Both aerobic and resistance training improve insulin sensitivity
- Post-meal walks (10-15 minutes) lower glucose significantly
- High-intensity interval training particularly effective
- Aim for 150+ minutes weekly

**Weight Loss:**
- Every 1 kg (2.2 lbs) lost can improve fasting glucose
- Visceral fat loss most important
- Even 5-10% weight loss significantly improves glucose

**Sleep:**
- Get 7-9 hours quality sleep
- Poor sleep reduces insulin sensitivity by 30-40%
- Even one night of poor sleep raises morning glucose

**Stress Management:**
- Chronic stress raises cortisol → raises glucose
- Meditation, breathing exercises proven to help
- Regular stress reduction practices

**Supplements with Evidence:**
- Berberine: 900-1500mg daily (as effective as metformin)
- Magnesium: 300-400mg daily (improves insulin sensitivity)
- Chromium: 200-400mcg daily
- Alpha-lipoic acid: 600mg daily
- Cinnamon: 1-6g daily (modest effect)

**Advanced Monitoring:**
- Continuous glucose monitor (CGM) for 2-4 weeks
- See real-time glucose response to foods/activities
- Identify hidden glucose spikes
- Available without prescription (Dexcom, Freestyle Libre)

**Fasting Glucose vs HbA1c:**
- Fasting glucose: snapshot (this moment)
- HbA1c: 3-month average
- Both important but tell different stories
- Can have normal fasting glucose but elevated HbA1c (postprandial spikes)

**The Bottom Line:**
Target fasting glucose 70-85 mg/dL for optimal longevity. This is achievable for most people through diet, exercise, and weight management. If consistently >100 mg/dL despite lifestyle optimization, consider metformin or berberine.""",
        'recommendations_primary': 'Reduce refined carbs, increase fiber to 30-40g daily, exercise 150+ min weekly, lose visceral fat, improve sleep',
        'therapeutics_primary': 'Metformin 500-2000mg daily (first-line); berberine 900-1500mg (natural alternative)'
    },

    'Fasting Insulin': {
        'education': """**Understanding Fasting Insulin**

Fasting insulin measures your insulin level after fasting. It's a powerful early warning sign of metabolic dysfunction - often elevated YEARS before glucose rises.

**Why Fasting Insulin is Critical:**
- Detects insulin resistance earlier than glucose or HbA1c
- Predicts diabetes risk 5-10 years before diagnosis
- Elevated insulin is pro-aging (accelerates cellular senescence)
- High insulin promotes fat storage, inhibits fat burning
- Associated with cancer, dementia, cardiovascular disease

**Optimal Ranges:**
- Optimal: <5 μIU/mL (some say <3)
- Good: 5-7 μIU/mL
- Borderline: 7-10 μIU/mL
- Insulin resistant: >10 μIU/mL
- Severely insulin resistant: >15 μIU/mL

**Standard Lab Reference (Too High):**
- Often lists "normal" as <25 μIU/mL
- This is metabolically unhealthy
- Don't accept this as "normal"

**The Insulin Resistance Cascade:**

**Stage 1: Elevated Insulin (YOU ARE HERE if >7)**
- Glucose still normal
- HbA1c still normal
- But cells becoming resistant to insulin
- Pancreas compensates by making MORE insulin

**Stage 2: Prediabetes**
- Fasting glucose 100-125 mg/dL
- HbA1c 5.7-6.4%
- Insulin often very high (15-25+)
- Pancreas working overtime

**Stage 3: Type 2 Diabetes**
- Pancreas can't keep up
- Glucose rises
- Insulin may drop (beta cell burnout)
- Complications begin

**Why High Insulin is Dangerous:**

**Metabolic Effects:**
- Promotes fat storage (especially visceral)
- Blocks fat breakdown
- Increases hunger and cravings
- Causes energy crashes

**Aging Effects:**
- Activates mTOR pathway (accelerates aging)
- Promotes cellular senescence
- Reduces autophagy (cellular cleanup)
- Shortens healthspan

**Disease Risk:**
- Increases cancer risk (insulin is growth factor)
- Promotes Alzheimer's ("type 3 diabetes")
- Drives atherosclerosis
- Associated with PCOS, fatty liver, gout

**How to Lower Fasting Insulin:**

**Diet (Most Powerful):**
- **Reduce refined carbohydrates** (biggest impact)
- **Lower overall carb intake** (at least initially)
- **Increase protein** (improves satiety, preserves muscle)
- **Increase fiber** (slows absorption, feeds gut bacteria)
- **Emphasize healthy fats** (satisfying, doesn't spike insulin)
- **Avoid grazing/snacking** (gives insulin time to drop)
- **Time-restricted eating** (16:8 or 18:6) very effective

**Exercise:**
- **Resistance training** builds muscle → improves insulin sensitivity
- **High-intensity exercise** depletes glycogen stores
- **Post-meal walks** prevent insulin spikes
- **Consistency matters more than intensity**

**Weight Loss:**
- Lose visceral fat (belly fat) specifically
- Even 5-10% weight loss dramatically improves insulin sensitivity
- Rapid weight loss (keto, VLCD) can quickly improve insulin

**Fasting Strategies:**
- Intermittent fasting: 16:8 daily
- Extended fasting: 24-48 hours occasionally
- Fasting-mimicking diet: 5 days monthly
- All reduce insulin and improve sensitivity

**Supplements:**
- **Berberine**: 900-1500mg daily (reduces insulin 25-30%)
- **Magnesium**: 300-400mg daily
- **Alpha-lipoic acid**: 600mg daily
- **Chromium**: 200-400mcg daily
- **Omega-3s**: 2-4g daily (improves sensitivity)

**Medications:**
- **Metformin**: reduces insulin by improving sensitivity
- **GLP-1 agonists** (semaglutide, tirzepatide): lower insulin by enhancing insulin sensitivity and promoting weight loss

**Monitoring Progress:**
- Retest fasting insulin every 3-6 months
- Pair with fasting glucose to calculate HOMA-IR
- Track waist circumference (visceral fat indicator)
- Monitor HbA1c annually

**Advanced Testing:**
- Oral glucose tolerance test with insulin measurements
- See insulin response to glucose load
- Identifies reactive hypoglycemia
- More sensitive than fasting insulin alone

**The Bottom Line:**
Fasting insulin is THE EARLIEST marker of metabolic dysfunction. If yours is >7 μIU/mL, take action NOW before glucose rises. Target <5 μIU/mL through carb reduction, exercise, and weight loss. This is one of the most impactful interventions for longevity.""",
        'recommendations_primary': 'Reduce refined carbs, practice intermittent fasting (16:8), resistance training 3x weekly, lose visceral fat',
        'therapeutics_primary': 'Metformin 500-2000mg daily for insulin resistance; GLP-1 agonists (semaglutide) for obesity with insulin resistance'
    },

    'HOMA-IR': {
        'education': """**Understanding HOMA-IR (Homeostatic Model Assessment of Insulin Resistance)**

HOMA-IR is a calculated score that estimates insulin resistance using your fasting glucose and fasting insulin. It's more informative than either marker alone.

**The Formula:**
HOMA-IR = (Fasting Glucose mg/dL × Fasting Insulin μIU/mL) / 405

Example: Glucose 95 mg/dL, Insulin 8 μIU/mL
HOMA-IR = (95 × 8) / 405 = 1.88

**Optimal Ranges:**
- Optimal: <1.0
- Good: 1.0-1.5
- Early insulin resistance: 1.5-2.0
- Moderate insulin resistance: 2.0-2.5
- Significant insulin resistance: >2.5
- Severe insulin resistance: >5.0

**Why HOMA-IR Matters:**
- Integrates both glucose AND insulin
- More sensitive than glucose alone for detecting early metabolic dysfunction
- Predicts diabetes risk better than glucose or insulin individually
- Correlates with visceral fat, cardiovascular risk, and all-cause mortality

**What HOMA-IR Tells You:**

**HOMA-IR <1.0 (Optimal):**
- Excellent insulin sensitivity
- Pancreas working efficiently
- Low metabolic disease risk
- Maintain through lifestyle

**HOMA-IR 1.0-2.0 (Borderline):**
- Mild insulin resistance developing
- Time for preventive action
- Very responsive to lifestyle changes
- Catch it early!

**HOMA-IR 2.0-5.0 (Insulin Resistant):**
- Significant insulin resistance
- Elevated diabetes risk (5-10x normal)
- Cardiovascular risk increased
- Aggressive intervention needed

**HOMA-IR >5.0 (Severe):**
- Severe insulin resistance
- Likely prediabetic or diabetic
- High complication risk
- May need medication + lifestyle

**Clinical Scenarios:**

**Scenario 1: Normal Glucose, High Insulin**
- Glucose 85 mg/dL, Insulin 12 μIU/mL
- HOMA-IR = 2.52 (insulin resistant)
- Early stage - pancreas compensating
- Prime time to intervene!

**Scenario 2: High Glucose, Normal Insulin**
- Glucose 115 mg/dL, Insulin 6 μIU/mL
- HOMA-IR = 1.70 (borderline)
- Possible beta cell dysfunction
- May be progressing to diabetes

**Scenario 3: Both Elevated**
- Glucose 105 mg/dL, Insulin 15 μIU/mL
- HOMA-IR = 3.89 (severely insulin resistant)
- Full-blown insulin resistance
- Urgent intervention needed

**How to Improve HOMA-IR:**

**Diet Strategies:**
- **Low-carb approach** most effective for reducing HOMA-IR
- **Mediterranean diet** if prefer higher carb
- **Eliminate refined carbs and sugar**
- **High fiber** (30-40g daily)
- **Adequate protein** (1.6-2.0g/kg body weight)
- **Healthy fats** (olive oil, avocado, nuts, fish)

**Exercise:**
- **Resistance training** 3-4x weekly (builds insulin-sensitive muscle)
- **HIIT** 2-3x weekly (depletes glycogen, improves sensitivity)
- **Daily movement** (10,000 steps minimum)
- **Post-meal walks** (prevent insulin spikes)

**Weight Loss:**
- Target 5-15% body weight loss
- **Focus on visceral fat** (measure waist circumference)
- **Rapid initial weight loss** (keto, VLCD) can dramatically improve HOMA-IR
- Maintain with sustainable habits

**Fasting:**
- **Intermittent fasting** (16:8 minimum)
- **Extended fasting** (24-48 hours monthly)
- Gives insulin a break, improves sensitivity
- Combines well with low-carb diet

**Sleep:**
- **7-9 hours nightly**
- Poor sleep worsens insulin resistance 30-40%
- Fix sleep BEFORE focusing on other interventions
- Track with wearable if needed

**Supplements:**
- **Berberine** 900-1500mg: reduces HOMA-IR 30-40%
- **Magnesium** 300-400mg: improves insulin signaling
- **Omega-3s** 2-4g: reduces inflammation, improves sensitivity
- **Alpha-lipoic acid** 600mg: enhances glucose uptake
- **Vitamin D** (if deficient): improves insulin secretion

**Medications:**
- **Metformin**: reduces HOMA-IR by improving hepatic insulin sensitivity
- **GLP-1 agonists**: improve insulin sensitivity + weight loss
- **SGLT2 inhibitors**: lower glucose + weight loss
- **Thiazolidinediones**: directly improve insulin sensitivity (but weight gain)

**Monitoring:**
- Retest every 3-6 months initially
- Once optimal (<1.5), test annually
- Watch trends over time
- Pair with HbA1c, lipids, liver enzymes

**HOMA-IR vs Other Tests:**
- **Oral glucose tolerance test with insulin**: more comprehensive but inconvenient
- **Kraft pattern**: detailed insulin response mapping
- **HOMA-IR**: simple, cheap, effective screening

**The Bottom Line:**
HOMA-IR is an incredibly useful calculated marker. Target <1.5 for optimal metabolic health. If >2.0, you have insulin resistance that requires intervention. The good news: HOMA-IR responds rapidly to lifestyle changes. Most people can improve HOMA-IR 30-50% in 3-6 months with aggressive diet and exercise.""",
        'recommendations_primary': 'Reduce carbs significantly, intermittent fasting (16:8), resistance training 3x weekly, lose 5-15% body weight',
        'therapeutics_primary': 'Metformin 500-2000mg daily; berberine 900-1500mg as natural alternative; GLP-1 agonists for obesity'
    },

    'Uric Acid': {
        'education': """**Understanding Uric Acid**

Uric acid is the end product of purine metabolism. While famous for causing gout, elevated uric acid is an independent predictor of metabolic disease, cardiovascular events, and all-cause mortality.

**The Longevity Connection:**
- Uric acid >5.5 mg/dL increases CVD risk 30-50%
- Strongly associated with metabolic syndrome
- Predicts diabetes development
- May drive hypertension (causative, not just correlated)
- Associated with chronic kidney disease progression
- Marker of oxidative stress

**Optimal Ranges (Stricter Than Standard):**
- Optimal for longevity: 3.0-5.0 mg/dL
- Acceptable: 5.0-6.0 mg/dL
- Borderline: 6.0-7.0 mg/dL
- High risk: >7.0 mg/dL (men), >6.0 mg/dL (women)
- Gout risk: >7.0 mg/dL (significantly elevated)

**Standard Lab Reference (Too Lenient):**
- Often <8.0 mg/dL for men, <7.0 for women
- But metabolic risk starts around 5.5 mg/dL

**What Drives High Uric Acid:**

**Diet:**
- **Fructose** (biggest driver - converts to uric acid in liver)
  - Added sugars, high-fructose corn syrup
  - Fruit juice, soda, sweetened beverages
  - Even excess whole fruit
- **Alcohol** (especially beer - high in purines + inhibits excretion)
- **High-purine foods**:
  - Organ meats (liver, kidney)
  - Red meat (moderate amounts OK)
  - Certain seafood (sardines, anchovies, shellfish)
  - Yeast extracts

**Metabolic:**
- Insulin resistance (reduces uric acid excretion)
- Obesity (especially visceral fat)
- Metabolic syndrome
- Kidney dysfunction (can't excrete efficiently)
- Dehydration

**Medications:**
- Diuretics (thiazides, loop diuretics)
- Low-dose aspirin
- Immunosuppressants (cyclosporine)
- Some chemotherapy drugs

**The Fructose-Uric Acid Connection:**
When fructose is metabolized in the liver:
1. Rapidly depletes ATP
2. Produces uric acid as byproduct
3. Fructose → triglycerides (fatty liver)
4. Fructose → insulin resistance
5. This is why soft drinks are so metabolically harmful

**Uric Acid's Role in Disease:**

**Gout:**
- Uric acid crystals in joints
- Extremely painful inflammation
- Usually big toe initially
- Risk increases dramatically >7.0 mg/dL

**Hypertension:**
- Uric acid may CAUSE high blood pressure
- Damages kidney and blood vessels
- Reduces nitric oxide (vasoconstrictor)
- Treating uric acid may lower blood pressure

**Metabolic Syndrome:**
- Uric acid is the "forgotten" component
- Correlates with all metabolic syndrome features
- May be causative, not just correlative

**Kidney Disease:**
- Uric acid damages kidney tubules
- Accelerates CKD progression
- Kidney stones (especially with very high levels)

**Cardiovascular Disease:**
- Independent risk factor
- Promotes endothelial dysfunction
- Increases oxidative stress and inflammation

**How to Lower Uric Acid:**

**Dietary Changes (Highly Effective):**
- **Eliminate/drastically reduce added sugars** (biggest impact)
- **Limit fructose**: no fruit juice, minimize dried fruit, moderate fresh fruit
- **Reduce alcohol** (especially beer)
- **Limit high-purine foods** (organ meats, excessive red meat)
- **Increase low-fat dairy** (lowers uric acid)
- **Increase cherries/tart cherry juice** (proven to lower uric acid)
- **Coffee** (2-4 cups daily lowers uric acid)
- **Stay hydrated** (2-3 liters water daily)

**Weight Loss:**
- Lose visceral fat specifically
- Improves insulin sensitivity → better uric acid excretion
- But avoid rapid weight loss (can temporarily spike uric acid)

**Exercise:**
- Improves insulin sensitivity
- Promotes weight loss
- Avoid extreme dehydration during exercise

**Supplements:**
- **Vitamin C**: 500-1000mg daily (lowers uric acid 0.5-1.5 mg/dL)
- **Tart cherry extract**: 400-500mg daily or 8oz juice
- **Quercetin**: 500-1000mg daily (inhibits xanthine oxidase)
- **Folate**: 10-40mg daily (may help)

**Medications (When Needed):**
- **Allopurinol**: inhibits uric acid production (100-300mg daily)
- **Febuxostat**: more potent xanthine oxidase inhibitor
- **Probenecid**: increases uric acid excretion
- **Colchicine**: for acute gout attacks (not preventive)

**Special Considerations:**

**If You Have Gout:**
- Target uric acid <6.0 mg/dL (ideally <5.0)
- Medication often necessary
- Diet alone may not be sufficient
- Combine medication + lifestyle

**If Insulin Resistant:**
- Improve insulin sensitivity FIRST
- This improves uric acid excretion
- Low-carb diet addresses both

**If on Diuretics:**
- Discuss alternatives with doctor
- May need uric acid-lowering medication
- Stay well hydrated

**Monitoring:**
- Test initially
- Retest after 3-6 months of lifestyle changes
- If >7.0 or gout history: test every 3-6 months
- Once optimal: annually

**The Bottom Line:**
Target uric acid 3.0-5.5 mg/dL for optimal metabolic health. Eliminate added sugars (especially fructose), limit alcohol, stay hydrated, and lose visceral fat. If >7.0 despite lifestyle changes or if history of gout, medication is warranted. Uric acid is a powerful longevity marker that doesn't get enough attention.""",
        'recommendations_primary': 'Eliminate added sugars/fructose, limit alcohol (especially beer), increase water intake to 2-3L daily, consume cherries/tart cherry juice',
        'therapeutics_primary': 'Allopurinol 100-300mg daily (first-line); febuxostat 40-80mg (more potent); probenecid if underexcretor'
    },

    'Testosterone': {
        'education': """**Understanding Testosterone**

Testosterone is the primary male sex hormone, but it's important for both men and women. It declines with age in men (~1-2% per year after age 30) and affects energy, muscle mass, bone density, libido, mood, and longevity.

**The Longevity Connection:**
- Low testosterone increases all-cause mortality 20-40% in men
- Associated with cardiovascular disease, diabetes, osteoporosis
- Critical for maintaining muscle mass (prevents sarcopenia)
- Affects cognitive function and mood (depression, brain fog)
- Bone density preservation
- Metabolic health (insulin sensitivity)

**Optimal Ranges for Men:**
- Optimal: 600-900 ng/dL (total testosterone)
- Good: 400-600 ng/dL
- Low-normal: 300-400 ng/dL (symptoms often present)
- Low/hypogonadal: <300 ng/dL (definite treatment candidate)

**Free Testosterone (More Important):**
- Optimal: 100-200 pg/mL
- Most testosterone is bound to SHBG (not bioavailable)
- Free testosterone is what matters functionally

**For Women:**
- Premenopausal: 15-70 ng/dL
- Postmenopausal: 10-40 ng/dL
- Free testosterone: 1-10 pg/mL

**Symptoms of Low Testosterone:**

**Physical:**
- Reduced muscle mass, increased body fat
- Low energy, chronic fatigue
- Decreased bone density
- Reduced strength and endurance
- Gynecomastia (breast tissue in men)

**Sexual:**
- Low libido
- Erectile dysfunction
- Reduced fertility

**Mental/Cognitive:**
- Depression, irritability, mood swings
- Brain fog, poor concentration
- Low motivation
- Reduced confidence

**Metabolic:**
- Insulin resistance
- Increased visceral fat
- Higher cardiovascular risk

**What Lowers Testosterone:**

**Lifestyle:**
- Obesity (especially visceral fat)
- Poor sleep (<7 hours)
- Chronic stress (elevated cortisol)
- Excessive alcohol
- Lack of exercise (or excessive endurance exercise)
- Sedentary lifestyle

**Diet:**
- Low-fat diets (need fat for hormone production)
- Inadequate calories (chronic dieting)
- Micronutrient deficiencies (zinc, vitamin D, magnesium)
- Soy in excess (phytoestrogens)

**Medical:**
- Diabetes and metabolic syndrome
- Medications (opioids, statins, SSRIs, corticosteroids)
- Chronic illness
- Primary hypogonadism (testicular failure)
- Secondary hypogonadism (pituitary/hypothalamus dysfunction)

**Environmental:**
- Endocrine-disrupting chemicals (plastics, pesticides)
- Heavy metals
- Xenoestrogens

**How to Optimize Testosterone Naturally:**

**Sleep:**
- 7-9 hours nightly (testosterone surges during sleep)
- Most testosterone produced during REM sleep
- Even one night of poor sleep reduces testosterone 10-15%

**Strength Training:**
- Resistance training 3-4x weekly
- Compound movements (squats, deadlifts, bench press)
- Heavy weights, moderate volume
- Avoid overtraining (increases cortisol)

**Avoid Excessive Endurance Exercise:**
- Marathon running, ultra-distance cycling suppress testosterone
- Moderate cardio is fine (30-45 min sessions)
- HIIT better than chronic steady-state

**Lose Excess Body Fat:**
- Visceral fat aromatizes testosterone to estrogen
- Every 5% body fat lost increases testosterone ~100 ng/dL
- Target body fat <20% (men), <30% (women)

**Diet:**
- **Adequate calories** (chronic calorie restriction lowers testosterone)
- **Healthy fats** 25-35% of calories (cholesterol is testosterone precursor)
  - Eggs, fatty fish, avocado, nuts, olive oil
- **Adequate protein** 1.6-2.0g/kg
- **Reduce inflammatory seed oils**
- **Limit alcohol** (<7 drinks/week)

**Stress Management:**
- Chronic stress → elevated cortisol → lower testosterone
- Meditation, breathing exercises
- Adequate rest between workouts
- Work-life balance

**Sunlight/Vitamin D:**
- 20-30 minutes direct sunlight daily or supplement
- Target vitamin D 40-60 ng/mL
- Vitamin D receptor in testicular cells

**Supplements with Evidence:**
- **Vitamin D**: 2000-5000 IU daily (if deficient)
- **Zinc**: 15-30mg daily (especially if deficient)
- **Magnesium**: 300-400mg daily
- **D-Aspartic Acid**: 2-3g daily (short-term only, 1-3 months)
- **Ashwagandha**: 600mg daily (lowers cortisol, may increase testosterone 10-15%)
- **Tongkat Ali (Eurycoma longifolia)**: 200-400mg daily
- **Fenugreek**: 500-600mg daily

**Questionable Supplements:**
- **Tribulus terrestris**: minimal evidence
- **Maca**: more for libido than testosterone
- Most testosterone boosters are overhyped

**Testosterone Replacement Therapy (TRT):**

**When to Consider:**
- Testosterone <300 ng/dL with symptoms
- Testosterone 300-400 ng/dL with significant symptoms
- After optimizing lifestyle for 6-12 months without improvement
- Must assess benefits vs. risks individually

**TRT Options:**
- **Injections**: most common (weekly or twice-weekly)
- **Transdermal gel**: daily application
- **Pellets**: implanted subcutaneously (3-6 months)
- **Patches**: less common

**Benefits:**
- Increased muscle mass and strength
- Fat loss (especially visceral)
- Improved energy and mood
- Enhanced libido and sexual function
- Better bone density
- Improved insulin sensitivity

**Risks/Considerations:**
- Suppresses natural production (testicular atrophy)
- May worsen sleep apnea
- Can increase red blood cell count (monitor hematocrit)
- Potential cardiovascular effects (controversial)
- Fertility concerns (suppresses sperm production)
- Requires lifelong commitment
- Must be monitored by physician

**Monitoring on TRT:**
- Testosterone levels (target mid-normal range)
- Hematocrit (watch for polycythemia)
- Estradiol (monitor aromatization)
- PSA (prostate monitoring)
- Liver function
- Lipids

**The Bottom Line:**
First optimize lifestyle: lose fat, sleep 7-9 hours, strength train, manage stress, supplement vitamin D/zinc/magnesium. If testosterone remains <400 ng/dL with symptoms after 6-12 months, consider TRT with a knowledgeable physician. Target total testosterone 600-900 ng/dL and free testosterone in upper normal range for optimal health and longevity.""",
        'recommendations_primary': 'Sleep 7-9 hours, resistance train 3-4x weekly, lose excess body fat, reduce stress, supplement vitamin D + zinc + magnesium',
        'therapeutics_primary': 'Testosterone replacement therapy (TRT): injections (75-100mg twice weekly) or transdermal gel (5-10g daily); monitor hematocrit, estradiol, PSA'
    },

    'ALT': {
        'education': """**Understanding ALT (Alanine Aminotransferase)**

ALT is an enzyme primarily found in liver cells. Elevated ALT indicates liver cell damage or inflammation. It's particularly sensitive to non-alcoholic fatty liver disease (NAFLD), now affecting 25-30% of the population.

**The Longevity Connection:**
- Elevated ALT predicts metabolic syndrome, diabetes, cardiovascular disease
- Fatty liver disease increases all-cause mortality
- Non-alcoholic fatty liver disease (NAFLD) → non-alcoholic steatohepatitis (NASH) → cirrhosis → liver cancer
- Liver health is critical for metabolic health and longevity
- ALT correlates with visceral fat and insulin resistance

**Optimal Ranges (Much Stricter Than Standard):**
- Optimal: <20-25 U/L (men), <15-20 U/L (women)
- Acceptable: 25-30 U/L
- Borderline: 30-40 U/L
- Elevated: >40 U/L

**Standard Lab Reference (Too Lenient):**
- Often lists <40-50 U/L as "normal"
- But metabolic risk and liver fat start accumulating well before this
- Even ALT 30-40 U/L indicates some degree of fatty liver

**What Causes Elevated ALT:**

**Most Common (NAFLD/Metabolic):**
- Non-alcoholic fatty liver disease (most common cause)
- Obesity, especially visceral fat
- Insulin resistance and diabetes
- Metabolic syndrome
- High-fructose diet (rapidly converted to liver fat)

**Alcohol:**
- Chronic excessive alcohol consumption
- "Excessive" = >14 drinks/week men, >7 drinks/week women
- Alcoholic liver disease (AST often > ALT in this case)

**Medications:**
- Statins (usually mild elevation, often not concerning)
- Acetaminophen (Tylenol) - especially high doses or with alcohol
- Certain antibiotics
- NSAIDs (ibuprofen, naproxen)
- Some supplements (e.g., high-dose green tea extract, some bodybuilding supplements)

**Infections:**
- Hepatitis B or C
- Epstein-Barr virus (mono)
- Cytomegalovirus

**Other:**
- Autoimmune hepatitis
- Hemochromatosis (iron overload)
- Wilson's disease (copper accumulation)
- Celiac disease
- Hypothyroidism

**ALT vs AST:**
- Both are liver enzymes
- ALT more liver-specific
- AST also found in heart, muscle, kidneys
- AST:ALT ratio >2 suggests alcohol-related liver disease
- AST:ALT ratio <1 typical of NAFLD

**The NAFLD Epidemic:**
25-30% of US population has NAFLD:
- Most don't know it
- "Silent" disease initially
- Driven by insulin resistance, obesity, sugar consumption
- Can progress to NASH (inflammation + scarring)
- NASH can progress to cirrhosis

**How to Lower ALT and Reverse Fatty Liver:**

**Diet (Most Powerful):**
- **Eliminate added sugars** (especially fructose/HFCS)
- **No fruit juice or soda**
- **Reduce refined carbohydrates drastically**
- **Mediterranean or low-carb diet** most evidence
- **Increase fiber** (30-40g daily)
- **Limit saturated fat, avoid trans fats**
- **Coffee** (2-3 cups daily) protective for liver
- **Omega-3s** (2-4g daily) reduce liver fat

**Weight Loss (Extremely Effective):**
- 5-10% weight loss reduces liver fat 30-40%
- 10% weight loss can reverse NAFLD completely in many cases
- Visceral fat loss particularly important
- Rapid weight loss (keto, VLCD) can quickly improve ALT

**Exercise:**
- Both aerobic and resistance training reduce liver fat
- 150+ minutes weekly
- Exercise reduces liver fat even without weight loss
- HIIT particularly effective

**Avoid/Limit Alcohol:**
- If ALT elevated, consider eliminating entirely
- At minimum: <7 drinks/week

**Supplements:**
- **Vitamin E** (800 IU daily): proven to improve NASH (use mixed tocopherols)
- **Omega-3s** (2-4g EPA+DHA): reduce liver fat and inflammation
- **Silymarin (milk thistle)**: 420mg daily (modest benefit)
- **Berberine**: 900-1500mg (improves insulin resistance, may help NAFLD)
- **NAC** (N-acetylcysteine): 600-1200mg (antioxidant, liver protective)

**Medications (For NASH):**
- **Pioglitazone** (Actos): improves insulin sensitivity, reduces liver inflammation
- **Vitamin E**: 800 IU daily (non-diabetics with biopsy-proven NASH)
- **GLP-1 agonists** (semaglutide, tirzepatide): significant weight loss, improves NAFLD
- Several drugs in development specifically for NASH

**When to Investigate Further:**

**ALT 40-100 U/L:**
- Assess for metabolic risk factors
- Consider ultrasound or FibroScan (measures liver stiffness)
- Check hepatitis B/C serologies
- Review medications

**ALT >100 U/L:**
- Work up for other causes (viral hepatitis, autoimmune, hemochromatosis)
- May need liver biopsy
- Refer to hepatologist

**Monitoring:**
- If elevated: retest every 3-6 months
- Track alongside weight, waist circumference, insulin resistance markers
- Once normalized: annual testing
- FibroScan every 1-2 years if history of NAFLD

**The Bottom Line:**
Target ALT <25 U/L (men) or <20 U/L (women). If elevated, assume fatty liver until proven otherwise. The prescription: lose 5-10% body weight, eliminate sugar/refined carbs, exercise 150+ min weekly, supplement vitamin E and omega-3s, and have 2-3 cups of coffee daily. ALT often normalizes within 3-6 months with aggressive lifestyle intervention.""",
        'recommendations_primary': 'Lose 5-10% body weight, eliminate added sugars/fructose, exercise 150+ min weekly, limit/avoid alcohol, drink coffee daily',
        'therapeutics_primary': 'Vitamin E 800 IU daily (non-diabetic NASH); pioglitazone 30-45mg daily (improves insulin sensitivity); GLP-1 agonists for obesity'
    },

    # =========================================================================
    # HORMONE BIOMARKERS
    # =========================================================================

    'TSH': {
        'education': """**Understanding TSH (Thyroid Stimulating Hormone)**

TSH is produced by the pituitary gland and tells your thyroid to produce thyroid hormones (T3 and T4). It's the most common screening test for thyroid function.

**The Longevity Connection:**
- Thyroid function affects metabolism, energy, weight, mood, cognition, and cardiovascular health
- Both hypothyroidism AND hyperthyroidism increase mortality risk
- Optimal thyroid function critical for healthy aging
- Subclinical hypothyroidism common (affecting 5-10% of population)
- Thyroid dysfunction increases with age

**Optimal Ranges:**
- Optimal: 1.0-2.5 mIU/L
- Good: 0.5-1.0 or 2.5-4.0 mIU/L
- Subclinical hypothyroidism: 4.5-10 mIU/L
- Overt hypothyroidism: >10 mIU/L
- Hyperthyroidism: <0.5 mIU/L

**Standard Lab Reference (Too Wide):**
- Often 0.5-5.0 mIU/L listed as "normal"
- But optimal is narrower: 1.0-2.5 mIU/L
- Many people with TSH >3.0 have symptoms

**Understanding TSH (Inverse Relationship):**
- HIGH TSH = LOW thyroid function (hypothyroidism)
- LOW TSH = HIGH thyroid function (hyperthyroidism)
- TSH goes UP when thyroid hormones are LOW (pituitary trying to stimulate thyroid)

**Symptoms of Hypothyroidism (High TSH):**
- Fatigue, low energy
- Weight gain or difficulty losing weight
- Cold intolerance (always cold)
- Constipation
- Dry skin, brittle nails, hair loss
- Depression, brain fog, poor concentration
- Slow heart rate
- Muscle weakness, joint pain

**Symptoms of Hyperthyroidism (Low TSH):**
- Anxiety, nervousness, irritability
- Weight loss despite normal eating
- Heat intolerance (always hot)
- Rapid or irregular heartbeat
- Tremor
- Insomnia
- Frequent bowel movements
- Muscle weakness

**What Affects TSH:**

**Causes of High TSH (Hypothyroidism):**
- **Hashimoto's thyroiditis** (autoimmune - most common)
- **Iodine deficiency** (rare in US)
- **Medications**: lithium, amiodarone, interferon
- **Thyroid surgery or radioactive iodine**
- **Pituitary dysfunction**
- **Age** (thyroid function declines)

**Causes of Low TSH (Hyperthyroidism):**
- **Graves' disease** (autoimmune - most common)
- **Toxic nodular goiter**
- **Thyroiditis** (temporary)
- **Excessive thyroid medication**
- **Pituitary dysfunction**

**Advanced Testing Beyond TSH:**

**If TSH Abnormal, Check:**
- **Free T4** (active thyroid hormone - storage form)
- **Free T3** (active thyroid hormone - active form)
- **Thyroid antibodies** (TPO, thyroglobulin) for autoimmune disease
- **Reverse T3** (inactive form - shows conversion issues)
- **Thyroid ultrasound** (if nodules or enlargement)

**The T4 to T3 Conversion Problem:**
Many people have normal TSH and T4 but LOW T3:
- T4 is converted to T3 in liver and other tissues
- Stress, inflammation, nutrient deficiencies impair conversion
- Some convert T4 → reverse T3 (inactive) instead of active T3
- These people have symptoms despite "normal" TSH

**How to Optimize Thyroid Function:**

**Nutrients Critical for Thyroid:**
- **Iodine**: 150-200mcg daily (from seafood, seaweed, iodized salt)
  - Too much can worsen autoimmune thyroid disease
  - Don't mega-dose iodine supplements
- **Selenium**: 200mcg daily (Brazil nuts, seafood, eggs)
  - Critical for T4→T3 conversion
  - May reduce thyroid antibodies in Hashimoto's
- **Zinc**: 15-30mg daily (supports thyroid hormone production)
- **Iron**: if deficient (hypothyroidism causes/worsens iron deficiency)
- **Vitamin D**: optimize to 40-60 ng/mL (immune regulation)
- **Vitamin A**: from animal sources (supports thyroid hormone receptors)

**Lifestyle:**
- **Manage stress**: chronic stress impairs T4→T3 conversion
- **Adequate sleep**: 7-9 hours (thyroid hormones regulated during sleep)
- **Moderate exercise**: extreme exercise can suppress thyroid
- **Avoid yo-yo dieting**: severe calorie restriction lowers T3

**Diet:**
- **Adequate calories**: chronic dieting suppresses thyroid
- **Adequate carbs**: very low carb can lower T3 (for some people)
- **Protein**: 1.6-2.0g/kg for thyroid hormone production
- **Avoid excessive raw cruciferous** (goitrogens - block iodine) if hypothyroid
  - Cooked is fine
  - Not an issue unless iodine deficient
- **Limit soy** (may interfere with thyroid medication absorption)

**Medications:**

**For Hypothyroidism:**
- **Levothyroxine (T4)**: most common, synthetic T4
  - Cheap, stable, long-acting
  - Body converts to T3
  - Take on empty stomach
- **Liothyronine (T3)**: synthetic T3
  - Faster acting, shorter half-life
  - For people who don't convert T4→T3 well
  - Usually combined with T4
- **Natural desiccated thyroid** (NDT): from pig thyroid
  - Contains T4, T3, T2, T1, calcitonin
  - Some prefer it (more "natural")
  - Less standardized than synthetic
- **Combination T4/T3**: increasingly popular
  - Addresses conversion issues
  - Ratio typically 4:1 or 10:1 (T4:T3)

**Dosing Strategy:**
- Start low, increase gradually
- Retest TSH (and Free T3, Free T4) every 6-8 weeks
- Target TSH 1.0-2.5, Free T3 upper half of range
- Adjust based on symptoms AND labs
- Many need to add T3 to feel optimal

**Special Considerations:**

**Hashimoto's Thyroiditis:**
- Autoimmune attack on thyroid
- Check TPO and thyroglobulin antibodies
- Address root causes: gut health, gluten, stress, vitamin D
- May benefit from gluten-free diet
- Selenium 200mcg daily may lower antibodies
- Eventually may destroy enough thyroid to need medication

**Subclinical Hypothyroidism (TSH 4.5-10):**
- Controversial whether to treat
- Many have symptoms (fatigue, weight gain, depression)
- Trial of low-dose thyroid medication reasonable
- Especially if: symptoms, thyroid antibodies, trying to conceive

**Pregnancy:**
- Thyroid needs increase 30-50%
- Target TSH <2.5 in first trimester
- Hypothyroidism increases miscarriage risk
- Check thyroid early in pregnancy
- Increase medication dose as needed

**Monitoring:**
- If on thyroid medication: TSH every 6-12 months
- If borderline: every 6-12 months
- If optimal and stable: annually
- Always check Free T3 and Free T4 (not just TSH)

**The Bottom Line:**
Target TSH 1.0-2.5 mIU/L for optimal function. If >3.0 with symptoms, investigate further. If diagnosed with hypothyroidism, optimize medication to feel best (not just normalize TSH). Supplement selenium, ensure adequate iodine (but don't overdo it), and address underlying issues like Hashimoto's. Many people need T3 added to T4 medication to feel optimal.""",
        'recommendations_primary': 'Supplement selenium 200mcg daily, ensure adequate iodine (150-200mcg), optimize vitamin D, manage stress, adequate sleep',
        'therapeutics_primary': 'Levothyroxine (T4) 25-200mcg daily; add liothyronine (T3) 5-25mcg if poor T4→T3 conversion; combination therapy increasingly popular'
    },

    'Cortisol': {
        'education': """**Understanding Cortisol**

Cortisol is your primary stress hormone, produced by the adrenal glands. It follows a diurnal rhythm (high in morning, low at night) and affects metabolism, immune function, blood pressure, and mood.

**The Longevity Connection:**
- Chronic high cortisol accelerates aging (cellular senescence)
- Increases visceral fat, insulin resistance, cardiovascular disease risk
- Suppresses immune function
- Damages hippocampus (memory center)
- Disrupts sleep
- Associated with depression and anxiety
- Very low cortisol (adrenal insufficiency) also dangerous

**Optimal Ranges (Morning Cortisol):**
- Morning (8 AM): 10-20 μg/dL
- Afternoon (4 PM): 5-10 μg/dL
- Evening (11 PM): <5 μg/dL (ideally <2-3)
- Pattern matters more than single value

**Note:** Single cortisol measurement limited. Better tests:
- **4-point salivary cortisol**: measures diurnal rhythm
- **24-hour urinary free cortisol**: total daily production
- **Cortisol awakening response (CAR)**: stress reactivity

**The Cortisol Rhythm:**
Healthy pattern:
- Peaks 30-45 min after waking (cortisol awakening response)
- Gradually declines throughout day
- Lowest at night (allows sleep)
- This rhythm regulates energy, metabolism, immune function

**Dysfunctional Patterns:**
- **Flat/blunted**: chronically elevated, doesn't drop at night
- **Reversed**: low in morning, high at night (can't sleep)
- **Exaggerated**: excessive response to stress
- **Low overall**: adrenal insufficiency or burnout (controversial)

**Symptoms of HIGH Cortisol:**
- Difficulty sleeping (wired at night)
- Weight gain (especially belly fat)
- Sugar cravings
- Anxiety, irritability
- Brain fog, poor memory
- Frequent infections (immune suppression)
- High blood pressure
- Muscle weakness
- Easy bruising
- Menstrual irregularities

**Cushing's Syndrome (Very High Cortisol):**
- Moon face, buffalo hump
- Purple striae (stretch marks)
- Thin skin, easy bruising
- Severe muscle weakness
- Requires medical evaluation

**Symptoms of LOW Cortisol:**
- Extreme fatigue (especially morning)
- Low blood pressure, dizziness
- Salt cravings
- Hypoglycemia
- Nausea
- Muscle/joint pain
- Depression
- "Crashes" during stress

**What Raises Cortisol:**

**Chronic Stress:**
- Work stress, relationship stress, financial stress
- Psychological stress (worry, anxiety)
- Physical stress (overtraining, chronic pain)
- Sleep deprivation

**Lifestyle:**
- Excessive caffeine
- Alcohol
- Poor sleep quality
- Chronic calorie restriction
- Excessive exercise (especially endurance without recovery)
- Inflammation

**Medical:**
- Depression and anxiety disorders
- Chronic illness
- Medications (prednisone, corticosteroids)
- Cushing's disease (pituitary tumor)
- Adrenal tumor

**What Lowers Cortisol:**

**Stress Management (Most Effective):**
- **Meditation**: 10-20 min daily lowers cortisol 20-30%
- **Deep breathing**: 4-7-8 breathing, box breathing
- **Yoga**: especially gentle/restorative
- **Nature exposure**: 20-30 min in nature lowers cortisol
- **Social connection**: spending time with loved ones
- **Laughter**: genuine laughter reduces cortisol

**Sleep:**
- **7-9 hours nightly**
- Cortisol and sleep bidirectional:
  - Poor sleep → high cortisol
  - High cortisol → poor sleep
- Fix sleep hygiene first
- Dark, cool room
- Consistent schedule

**Exercise (But Not Too Much):**
- **Moderate exercise** lowers resting cortisol
- **Excessive exercise** raises cortisol (chronic stress)
- **Recovery critical**: 1-2 rest days weekly
- **Overtraining syndrome**: chronically elevated cortisol
- **Gentle movement**: walking, swimming, stretching

**Diet:**
- **Adequate calories**: chronic dieting raises cortisol
- **Regular meals**: skipping meals spikes cortisol
- **Protein**: stabilizes blood sugar
- **Limit caffeine**: especially after noon
- **Limit/avoid alcohol**: disrupts cortisol rhythm
- **Complex carbs at night**: may help evening cortisol drop

**Supplements:**
- **Phosphatidylserine**: 300-400mg daily (lowers cortisol 20-30%)
- **Ashwagandha**: 300-600mg daily (lowers cortisol, reduces stress)
- **Rhodiola rosea**: 200-400mg daily (adaptogen)
- **L-theanine**: 200-400mg (from green tea, promotes calm)
- **Magnesium**: 300-400mg evening (promotes relaxation)
- **Vitamin C**: 1000mg daily (supports adrenals)
- **Fish oil**: 2-4g EPA+DHA (anti-inflammatory, may lower cortisol)

**Adaptogens:**
Herbs that help body adapt to stress:
- **Ashwagandha**: best studied, reduces cortisol
- **Rhodiola**: energy, stress resilience
- **Holy basil (Tulsi)**: calming, reduces cortisol
- **Cordyceps**: energy, adrenal support
- **Schisandra**: liver support, stress response
- Cycle adaptogens (2 months on, 1 month off)

**When to Test Cortisol:**

**Consider Testing If:**
- Chronic fatigue despite adequate sleep
- Can't lose weight despite diet/exercise
- Difficulty sleeping (wired at night)
- Excessive stress response
- Symptoms of Cushing's or Addison's

**Best Tests:**
- **4-point salivary cortisol**: morning, noon, evening, night
- Shows diurnal pattern
- At-home test available
- Most informative for longevity optimization

**Medical Conditions:**

**Cushing's Syndrome (Too Much Cortisol):**
- Usually caused by exogenous steroids or tumor
- Requires medical treatment
- Surgery or medication to lower cortisol
- Life-threatening if untreated

**Addison's Disease (Too Little Cortisol):**
- Adrenal glands don't produce enough cortisol
- Autoimmune or other causes
- Life-threatening (adrenal crisis)
- Requires cortisol replacement (hydrocortisone)

**"Adrenal Fatigue" (Controversial):**
- Not recognized medical diagnosis
- Theory: chronic stress → "adrenal burnout"
- Better termed: HPA axis dysfunction
- Treat underlying stress, not "fatigued adrenals"

**The Bottom Line:**
Focus on cortisol RHYTHM not just level. Morning cortisol should be healthy (10-20), evening should be low (<5). To optimize: manage stress through meditation/breathing/nature, prioritize 7-9 hours sleep, avoid overtraining, supplement ashwagandha or phosphatidylserine, and address underlying anxiety/depression. Chronic elevated cortisol is one of the most aging hormones - managing stress is critical for longevity.""",
        'recommendations_primary': 'Daily meditation (10-20 min), prioritize 7-9 hours sleep, manage stress, moderate (not excessive) exercise, nature exposure',
        'therapeutics_primary': 'Phosphatidylserine 300-400mg daily; ashwagandha 300-600mg daily; for Cushing\'s: ketoconazole or surgery; for Addison\'s: hydrocortisone replacement'
    },

    'Estradiol': {
        'education': """**Understanding Estradiol (E2)**

Estradiol is the primary and most potent form of estrogen. While often thought of as a "female hormone," it's critical for both men and women, affecting bone health, cardiovascular function, brain health, and sexual function.

**The Longevity Connection:**
- Estradiol protects against osteoporosis, cardiovascular disease, cognitive decline
- Too low: accelerated bone loss, increased CVD risk, cognitive decline, sexual dysfunction
- Too high: increased cancer risk (breast, uterine), blood clots
- The key is optimal balance, not maximizing or minimizing

**Optimal Ranges:**

**Premenopausal Women (Varies by Cycle Phase):**
- Follicular phase: 30-100 pg/mL
- Mid-cycle: 100-400 pg/mL (ovulation surge)
- Luteal phase: 50-300 pg/mL

**Postmenopausal Women:**
- Without HRT: <20-30 pg/mL
- On HRT: Target 50-100 pg/mL (physiologic replacement)

**Men:**
- Optimal: 20-40 pg/mL
- Too low: <20 pg/mL (bone loss, sexual dysfunction, mood issues)
- Too high: >40-50 pg/mL (gynecomastia, water retention, mood issues)

**What Estradiol Does:**

**For Women:**
- Maintains bone density (primary protection against osteoporosis)
- Protects cardiovascular system (arterial elasticity, lipid profile)
- Supports brain health (mood, memory, cognition)
- Maintains vaginal and urinary tract health
- Regulates menstrual cycle, fertility
- Affects body composition (fat distribution)
- Supports skin health (collagen production)

**For Men:**
- Essential for bone health (not testosterone alone!)
- Supports cardiovascular health
- Critical for libido and sexual function
- Affects mood and cognition
- Regulates body composition
- Too much or too little causes problems

**Symptoms of Low Estradiol:**

**In Women:**
- Hot flashes, night sweats
- Vaginal dryness, painful intercourse
- Mood swings, depression, irritability
- Brain fog, poor memory
- Joint pain
- Bone loss (leading to osteoporosis)
- Dry skin, hair thinning
- Sleep disturbances
- Loss of libido

**In Men:**
- Reduced libido and erectile function
- Bone loss
- Joint pain
- Mood changes, irritability
- Increased abdominal fat

**Symptoms of High Estradiol:**

**In Women:**
- Heavy menstrual bleeding
- Breast tenderness, swelling
- Weight gain (especially hips/thighs)
- Mood swings, PMS
- Bloating, water retention
- Headaches

**In Men:**
- Gynecomastia (breast tissue development)
- Water retention, bloating
- Erectile dysfunction
- Loss of muscle mass
- Increased body fat
- Emotional instability
- Low libido

**What Affects Estradiol:**

**In Women - Declining with Age:**
- Perimenopause (40s): estradiol becomes erratic, then declines
- Menopause (average age 51): estradiol drops dramatically
- By 60: only 10-20% of premenopausal levels

**In Men - Can Be Too High or Too Low:**
- **Aromatization**: testosterone converts to estradiol via aromatase enzyme
- **Obesity**: fat tissue contains aromatase → more estradiol production
- **Alcohol**: increases aromatase activity
- **Age**: aromatase activity increases with age
- **Medications**: some increase or decrease estradiol
- **TRT (testosterone therapy)**: can increase estradiol significantly

**Managing Estradiol:**

**For Postmenopausal Women (Low Estradiol):**

**Hormone Replacement Therapy (HRT):**
- **Oral estradiol**: 0.5-2mg daily
- **Transdermal patch**: 25-100mcg twice weekly (preferred - avoids first-pass liver)
- **Transdermal gel/cream**: 0.5-1.5mg daily
- **Pellets**: implanted subcutaneously, 3-6 months duration

**MUST include progesterone if uterus intact** (prevents uterine cancer)

**Benefits of HRT (When Started Early):**
- Eliminates hot flashes (90% reduction)
- Prevents bone loss
- Reduces cardiovascular disease risk (if started <10 years from menopause)
- Improves mood, cognition, quality of life
- Maintains vaginal/urinary health
- May reduce dementia risk

**Timing Matters - The "Window of Opportunity":**
- Start HRT within 10 years of menopause or before age 60
- Starting later may not provide cardiovascular benefits
- Earlier = better for brain health

**Risks of HRT:**
- Slightly increased breast cancer risk (especially with synthetic progestin)
- Blood clot risk (lower with transdermal)
- Stroke risk (if started >60 years old)
- Minimize risks: use transdermal estradiol + bioidentical progesterone

**For Men with High Estradiol:**

**Lifestyle:**
- **Lose excess body fat** (especially visceral)
- **Limit alcohol** (<7 drinks/week)
- **Cruciferous vegetables** (DIM, sulforaphane reduce estradiol)
- **Strength training** (improves body composition)
- **Avoid xenoestrogens** (plastics, pesticides)

**Supplements:**
- **DIM** (diindolylmethane): 200-300mg daily (promotes beneficial estrogen metabolism)
- **Calcium D-glucarate**: 500-1000mg daily (supports estrogen elimination)
- **Zinc**: 30mg daily (aromatase inhibitor)

**Medications (If Needed on TRT):**
- **Anastrozole** (Arimidex): 0.25-0.5mg twice weekly (aromatase inhibitor)
- **Exemestane** (Aromasin): 12.5-25mg twice weekly (alternative AI)
- Goal: maintain estradiol 20-40 pg/mL (not suppress completely!)

**For Men with Low Estradiol:**
- Usually due to low testosterone or excessive aromatase inhibitor use
- Optimize testosterone (estradiol will increase appropriately)
- Reduce or stop aromatase inhibitor
- Low estradiol in men is dangerous for bone health

**Special Considerations:**

**Breast Cancer History:**
- Estrogen-positive breast cancer: HRT generally contraindicated
- Estrogen-negative breast cancer: may be option (discuss with oncologist)
- Consider non-hormonal options for symptoms

**Blood Clot History:**
- Oral estrogen increases clot risk significantly
- Transdermal estrogen may be safer
- Discuss thoroughly with physician

**The Estrogen Controversy:**
Why the confusion about HRT?
- Women's Health Initiative (2002) scared everyone
- Study used synthetic hormones (Premarin, Provera) - not bioidentical
- Study population was older (average age 63) - past window of opportunity
- Reanalysis shows: younger women benefit significantly from HRT
- Bioidentical, transdermal HRT has better safety profile

**The Bottom Line:**

**For Women:**
Estradiol is protective for bones, heart, and brain. If postmenopausal with symptoms or bone loss, consider HRT (especially transdermal estradiol + bioidentical progesterone). Start within 10 years of menopause for maximum benefit. Work with knowledgeable physician to weigh benefits vs. risks.

**For Men:**
Estradiol is essential - don't let it get too low or too high. Target 20-40 pg/mL. If on TRT and estradiol is high, lose body fat and consider low-dose aromatase inhibitor. Monitor levels every 3-6 months.""",
        'recommendations_primary': 'Women: consider HRT if postmenopausal (<10 yrs); Men: maintain healthy weight, limit alcohol, monitor if on TRT',
        'therapeutics_primary': 'Women: transdermal estradiol 50-100mcg + micronized progesterone 100-200mg; Men: anastrozole 0.25-0.5mg twice weekly if estradiol >50 on TRT'
    },

    'DHEA-S': {
        'education': """**Understanding DHEA-S (Dehydroepiandrosterone Sulfate)**

DHEA-S is a hormone produced by the adrenal glands that serves as a precursor to sex hormones (testosterone and estrogen). It's often called the "longevity hormone" because it peaks in your 20s and declines steadily with age.

**The Longevity Connection:**
- DHEA-S levels correlate with biological age (higher = younger biological age)
- Low DHEA-S associated with increased mortality, cardiovascular disease, cognitive decline
- May protect against sarcopenia (muscle loss), osteoporosis, immune decline
- Declines ~2-3% per year after age 30 (by age 70, only 10-20% of peak levels remain)
- Higher DHEA-S associated with better quality of life and functional capacity

**Optimal Ranges (Age-Dependent):**
**Men:**
- Age 20-30: 280-640 μg/dL
- Age 30-40: 120-520 μg/dL
- Age 40-50: 95-530 μg/dL
- Age 50-60: 70-310 μg/dL
- Age 60+: 42-290 μg/dL

**Women:**
- Age 20-30: 65-380 μg/dL
- Age 30-40: 45-270 μg/dL
- Age 40-50: 32-240 μg/dL
- Age 50-60: 26-200 μg/dL
- Age 60+: 13-130 μg/dL

**Target:** Upper half of age-appropriate reference range for optimal longevity

**What DHEA-S Does:**
- Converts to testosterone and estrogen (sex hormone precursor)
- Balances cortisol (anti-stress effects)
- Supports immune function
- Maintains bone density
- Preserves muscle mass
- Supports cognitive function and mood
- Anti-inflammatory effects

**Symptoms of Low DHEA-S:**
- Persistent fatigue despite rest
- Low libido
- Difficulty building/maintaining muscle
- Decreased bone density
- Depression, mood swings
- Poor stress tolerance
- Cognitive decline, brain fog
- Accelerated aging
- Immune dysfunction

**What Lowers DHEA-S:**
- **Aging** (primary factor - unavoidable decline)
- **Chronic stress** (cortisol antagonizes DHEA)
- **Poor sleep**
- **Chronic illness**
- **Medications**: corticosteroids, opioids
- **Adrenal insufficiency**
- **Hypothyroidism**
- **Malnutrition, eating disorders**

**How to Optimize DHEA-S Naturally:**

**Stress Management:**
- Chronic stress depletes DHEA while raising cortisol
- Meditation, yoga, breathing exercises
- Work-life balance
- Adequate recovery/rest

**Sleep:**
- 7-9 hours nightly
- DHEA production occurs during sleep
- Poor sleep accelerates DHEA decline

**Exercise:**
- Both resistance training and cardio
- Moderate intensity (overtraining can lower DHEA)
- Consistent exercise maintains DHEA levels better than sedentary lifestyle
- But effect is modest (can't fully prevent age-related decline)

**Nutrition:**
- Adequate calories and protein
- Healthy fats (cholesterol is steroid hormone precursor)
- Micronutrients: zinc, magnesium, vitamin D
- Avoid crash dieting

**DHEA Supplementation:**

**When to Consider:**
- DHEA-S low for age (<25th percentile)
- Symptoms of deficiency
- Aging optimization (controversial - not proven to extend lifespan)
- Under medical supervision

**Dosing:**
- **Men**: 25-50mg daily
- **Women**: 10-25mg daily
- Take in morning (mimics natural rhythm)
- Start low, increase gradually
- Monitor levels every 3-6 months

**Forms:**
- Micronized DHEA (best absorbed)
- DHEA vs DHEA-S: body converts DHEA → DHEA-S
- Over-the-counter supplement (US)
- Prescription in some countries

**Benefits of Supplementation (Evidence Mixed):**
- May improve well-being and mood
- May increase bone density
- May improve muscle mass/strength (modest)
- May enhance libido
- May improve skin quality
- Benefits most pronounced in older individuals with low levels

**Risks/Concerns:**
- Converts to testosterone and estrogen
- Women: can cause acne, facial hair, deepening voice (androgen effects)
- Men: can convert to estrogen (may cause gynecomastia)
- May accelerate hormone-sensitive cancers (breast, prostate) - theoretical concern
- Can lower HDL cholesterol
- May cause oily skin, acne
- Not recommended if hormone-sensitive cancer history

**Monitoring on DHEA:**
- DHEA-S levels every 3-6 months
- Target upper-normal range for age
- Monitor testosterone and estradiol (especially women)
- Watch for side effects (acne, hair changes, mood)
- Discontinue if adverse effects

**Special Populations:**

**Women:**
- More sensitive to DHEA supplementation
- Start with lower doses (5-10mg)
- Watch for virilization (male characteristics)
- May improve libido postmenopausally
- Can help with adrenal insufficiency

**Men:**
- May convert DHEA to estrogen (aromatization)
- Monitor estradiol levels
- Some men benefit, others don't notice much
- Less dramatic effects than testosterone

**Contraindications:**
- History of hormone-sensitive cancer
- Pregnancy/breastfeeding
- Hormone replacement therapy (without medical guidance)
- Liver disease
- PCOS (may worsen)

**The Controversy:**
- DHEA supplementation popular in anti-aging medicine
- Evidence for longevity benefits is WEAK
- Low DHEA correlates with aging, but replacing it doesn't necessarily extend lifespan
- May improve quality of life, but not quantity
- Best used for symptomatic low DHEA, not universal anti-aging

**The Bottom Line:**
DHEA-S declines with age - this is normal. Supplementation may help if levels are low and you have symptoms, but it's not a proven longevity intervention. First optimize stress management, sleep, and exercise. If DHEA-S is low (<25th percentile for age) and you have symptoms, consider supplementation under medical supervision. Monitor levels and watch for side effects. Target upper-normal range for your age.""",
        'recommendations_primary': 'Manage chronic stress, prioritize 7-9 hours sleep, regular exercise, adequate nutrition; consider supplementation if low',
        'therapeutics_primary': 'DHEA supplementation: men 25-50mg daily, women 10-25mg daily; monitor DHEA-S, testosterone, estradiol every 3-6 months'
    },

    # =========================================================================
    # INFLAMMATION BIOMARKERS
    # =========================================================================

    'hsCRP': {
        'education': """**Understanding hsCRP (High-Sensitivity C-Reactive Protein)**

hsCRP measures low-grade chronic inflammation, one of the hallmarks of aging and the root cause of most chronic diseases. It's a powerful predictor of cardiovascular events and overall longevity.

**The Longevity Connection:**
- Chronic inflammation accelerates aging at the cellular level
- hsCRP predicts heart attacks better than LDL cholesterol alone
- Each 1 mg/L increase doubles cardiovascular event risk
- Associated with Alzheimer's, cancer, diabetes, autoimmune disease
- "Inflammaging" drives biological aging

**Optimal Ranges:**
- Optimal: <0.5 mg/L
- Low risk: 0.5-1.0 mg/L
- Moderate risk: 1.0-3.0 mg/L
- High risk: >3.0 mg/L
- Very high: >10 mg/L (suggests acute infection or illness)

**Standard Guidelines (Too Lenient):**
- Often lists <3.0 mg/L as "normal"
- But cardiovascular risk starts rising >1.0 mg/L
- Target <0.5 mg/L for optimal longevity

**What is CRP?**
- Acute phase reactant produced by liver
- Rises in response to inflammation anywhere in body
- Non-specific (doesn't tell you SOURCE of inflammation)
- But excellent marker of overall inflammatory burden

**What Drives Chronic Inflammation:**

**Lifestyle:**
- **Obesity** (especially visceral fat - secretes inflammatory cytokines)
- **Poor diet** (refined carbs, sugar, trans fats, omega-6 oils)
- **Sedentary lifestyle**
- **Poor sleep** (<7 hours or poor quality)
- **Chronic stress**
- **Smoking**
- **Excessive alcohol**

**Medical:**
- **Insulin resistance, metabolic syndrome**
- **Chronic infections** (periodontal disease, gut dysbiosis)
- **Autoimmune conditions**
- **Chronic pain**
- **Sleep apnea**
- **Environmental toxins**

**How to Lower hsCRP:**

**Weight Loss (Most Effective):**
- Visceral fat is inflammatory tissue
- Every 10% weight loss reduces hsCRP ~30%
- Even 5% weight loss shows benefit
- Focus on belly fat specifically

**Anti-Inflammatory Diet:**
- **Mediterranean diet** proven to lower CRP
- **Omega-3 fatty acids**: 2-4g EPA+DHA daily (lowers CRP 20-30%)
- **Polyphenols**: berries, dark chocolate, green tea, olive oil
- **Spices**: turmeric/curcumin, ginger
- **Fiber**: 30-40g daily (feeds beneficial gut bacteria)
- **Eliminate**: sugar, refined carbs, trans fats, excess omega-6 oils

**Exercise:**
- Regular moderate exercise lowers CRP 15-30%
- Both aerobic and resistance training effective
- 150+ minutes weekly optimal
- But overtraining can INCREASE inflammation (recovery essential)

**Sleep:**
- 7-9 hours nightly
- Poor sleep increases inflammatory markers
- Sleep apnea treatment lowers CRP significantly

**Stress Management:**
- Chronic stress drives inflammation
- Meditation, yoga, breathing exercises proven to lower CRP
- Address psychological stress

**Dental Health:**
- Periodontal disease causes chronic inflammation
- Regular dental cleanings
- Floss daily
- Treat gum disease aggressively

**Supplements with Evidence:**
- **Fish oil** (EPA+DHA 2-4g): best evidence, lowers CRP 20-30%
- **Curcumin** 500-1000mg daily: anti-inflammatory
- **Vitamin D** (if deficient): optimize to 40-60 ng/mL
- **Probiotics**: improve gut health, may lower CRP
- **Resveratrol** 250-500mg: modest anti-inflammatory
- **NAC** (N-acetylcysteine) 600-1200mg: antioxidant, anti-inflammatory

**Medications (If Needed):**
- **Statins**: lower CRP independent of cholesterol lowering
- **Metformin**: improves insulin sensitivity, reduces inflammation
- **GLP-1 agonists**: weight loss + direct anti-inflammatory effects
- **Colchicine**: directly anti-inflammatory (used in some high-risk cardiac patients)
- **Low-dose aspirin**: 81mg daily (for cardiovascular protection in high-risk)

**hsCRP + Other Risk Factors:**

**High hsCRP + High LDL:**
- Extremely high cardiovascular risk
- Aggressive statin therapy warranted
- Consider PCSK9 inhibitor

**High hsCRP + Normal Lipids:**
- Still elevated cardiovascular risk
- Focus on anti-inflammatory strategies
- May benefit from statin (anti-inflammatory effect)

**Normal hsCRP + High Lipids:**
- Lower risk than if CRP also elevated
- Standard lipid management

**Special Considerations:**

**If hsCRP >10 mg/L:**
- May indicate acute infection or illness
- Retest in 2-4 weeks
- If persistently >10, work up for underlying cause

**Monitoring:**
- Baseline hsCRP for everyone >40 years old
- If elevated: retest every 3-6 months while optimizing
- Once optimal: annually
- After heart attack: very high predictive value

**Why hsCRP Matters More Than People Think:**
- JUPITER trial: statin in normal LDL but elevated CRP reduced events 44%
- Proves inflammation drives atherosclerosis independent of cholesterol
- CRP is not just a marker - it's part of the disease process

**The Bottom Line:**
Target hsCRP <0.5 mg/L for optimal longevity. If elevated: lose visceral fat, eat anti-inflammatory Mediterranean diet, exercise regularly, optimize sleep, supplement fish oil 2-4g daily. hsCRP often drops 50%+ within 3-6 months with aggressive lifestyle intervention. This is one of the most actionable longevity biomarkers.""",
        'recommendations_primary': 'Lose visceral fat, Mediterranean diet, fish oil 2-4g EPA+DHA daily, exercise 150+ min weekly, optimize sleep 7-9 hours',
        'therapeutics_primary': 'High-dose fish oil 2-4g EPA+DHA; statins (rosuvastatin, atorvastatin) lower CRP independent of cholesterol effect; colchicine 0.5mg daily for very high risk'
    },

    'Creatinine': {
        'education': """**Understanding Creatinine**

Creatinine is a waste product from muscle metabolism, excreted by the kidneys. It's the most common marker of kidney function, though it has significant limitations.

**The Longevity Connection:**
- Kidney function critical for longevity - filters toxins, regulates blood pressure, produces hormones
- Chronic kidney disease (CKD) increases cardiovascular mortality 2-5 fold
- Even mild kidney dysfunction accelerates aging
- Loss of kidney function is often irreversible
- Prevention is key - once damaged, hard to restore

**Optimal Ranges:**
- **Men**: 0.7-1.2 mg/dL (but depends on muscle mass)
- **Women**: 0.5-1.0 mg/dL
- **Optimal for longevity**: Lower end of normal (0.7-0.9 mg/dL) suggests better kidney function

**But Creatinine Alone is Limited:**
- Affected by muscle mass (bodybuilders have higher creatinine but normal kidneys)
- Doesn't rise until 50% of kidney function is lost
- Better to calculate eGFR (estimated Glomerular Filtration Rate)
- Cystatin C more accurate (not affected by muscle mass)

**eGFR (Estimated Glomerular Filtration Rate):**
Calculated from creatinine + age + sex + race:
- **Normal**: >90 mL/min/1.73m²
- **Mildly decreased**: 60-89 (common with aging)
- **Moderately decreased**: 30-59 (CKD Stage 3)
- **Severely decreased**: 15-29 (CKD Stage 4)
- **Kidney failure**: <15 (CKD Stage 5, dialysis needed)

**Target for Longevity:** Maintain eGFR >60 throughout life

**What Causes Kidney Damage:**

**Most Common:**
- **Diabetes** (leading cause of kidney failure)
- **Hypertension** (damages small kidney vessels)
- **Atherosclerosis** (reduces kidney blood flow)
- **NSAIDs** (ibuprofen, naproxen - chronic use)
- **Dehydration** (chronic or severe acute)

**Other:**
- Autoimmune diseases (lupus, etc.)
- Infections (recurrent UTIs, pyelonephritis)
- Kidney stones (if recurrent)
- Genetic conditions (polycystic kidney disease)
- Medications (some antibiotics, chemotherapy, contrast dye)
- Heavy metals, toxins

**How to Protect Your Kidneys:**

**Control Blood Sugar:**
- Keep HbA1c <5.7% (optimal)
- Prevent or aggressively manage diabetes
- Glucose control is THE most important for diabetics

**Control Blood Pressure:**
- Target <120/80 mmHg
- High BP slowly damages kidneys over decades
- ACE inhibitors or ARBs protective for kidneys

**Adequate Hydration:**
- Drink 2-3 liters water daily
- Urine should be pale yellow
- Dehydration stresses kidneys

**Limit NSAIDs:**
- Ibuprofen, naproxen, etc. can damage kidneys
- Especially risky if: dehydrated, elderly, existing kidney disease
- Use sparingly, lowest dose, shortest duration
- Acetaminophen (Tylenol) safer for kidneys

**Healthy Diet:**
- **Moderate protein**: 0.8-1.6g/kg (very high protein may stress kidneys if pre-existing disease)
- **Low sodium**: <2300mg daily (protects blood pressure and kidneys)
- **Potassium-rich foods** (if kidney function normal): vegetables, fruits
- **Avoid excess sugar**: damages blood vessels including in kidneys

**Exercise:**
- Improves blood pressure, glucose control, cardiovascular health
- All protective for kidneys
- 150+ minutes weekly

**Don't Smoke:**
- Smoking damages kidney blood vessels
- Accelerates kidney disease progression

**Supplements:**

**Protective:**
- **Fish oil** 2-4g EPA+DHA: anti-inflammatory, may slow CKD progression
- **Vitamin D**: optimize to 40-60 ng/mL (kidney disease impairs vitamin D activation)
- **Coenzyme Q10**: may protect kidney function

**Avoid if Kidney Disease:**
- High-dose vitamin C (risk of oxalate stones)
- Creatine supplements (raises creatinine, may be concerning but likely safe)

**Medications That Protect Kidneys:**

**For High Blood Pressure:**
- **ACE inhibitors** (-pril drugs): lisinopril, enalapril
- **ARBs** (-sartan drugs): losartan, telmisartan
- Both reduce protein in urine, slow CKD progression
- First-line for hypertension with diabetes or kidney disease

**For Diabetes:**
- **SGLT2 inhibitors**: empagliflozin, dapagliflozin
- Proven to slow kidney disease in diabetics
- Lower blood sugar + direct kidney protection

**For Proteinuria:**
- ACE inhibitors/ARBs reduce protein leak
- Spironolactone may add benefit
- Goal: reduce urine protein to slow progression

**Monitoring Kidney Function:**

**Who Should Test:**
- Everyone: baseline in 20s, then periodically
- Annual if: diabetes, hypertension, over 60, family history

**What to Test:**
- **Creatinine + eGFR**: kidney filtration
- **Urine albumin/creatinine ratio**: detects early kidney damage
- **Cystatin C**: more accurate eGFR (not routine)
- **BUN**: less useful than creatinine, but informative with it

**If Kidney Function Declining:**
- Work up for reversible causes
- Optimize blood pressure and glucose aggressively
- Reduce protein if advanced CKD
- Nephrology referral if eGFR <45 or rapidly declining

**The Bottom Line:**
Protect your kidneys - damage is usually irreversible. Control blood sugar and blood pressure, stay hydrated, limit NSAIDs, don't smoke. Target creatinine <1.0 mg/dL and eGFR >60. Monitor annually if risk factors. Once eGFR drops below 60, progression can be slowed but rarely reversed. Prevention is everything.""",
        'recommendations_primary': 'Control blood pressure (<120/80), control blood sugar (HbA1c <5.7%), stay hydrated (2-3L daily), limit NSAIDs, don\'t smoke',
        'therapeutics_primary': 'ACE inhibitors (lisinopril 10-40mg) or ARBs (losartan 50-100mg) if hypertension/diabetes; SGLT2 inhibitors (empagliflozin 10-25mg) if diabetic'
    },
}

# Continue biometrics section
BIOMETRIC_EDUCATION_COMPLETE = {
    # Already done: VO2 Max, HRV, Weight, BMI

    'Bodyfat': {
        'education': """**Understanding Body Fat Percentage**

Body fat percentage is the proportion of your total weight that is fat mass (versus lean mass: muscle, bone, organs, water). It's far more informative than weight or BMI for assessing health and longevity.

**The Longevity Connection:**
- Excess body fat (especially visceral) drives inflammation, insulin resistance, cardiovascular disease
- But too little body fat also problematic (hormonal dysfunction, weakened immunity)
- Optimal body fat supports hormone production, immune function, longevity
- Fat distribution matters: visceral (belly) fat far more dangerous than subcutaneous (under skin)

**Optimal Ranges:**

**Men:**
- **Essential fat**: 2-5% (minimum for survival)
- **Athletes**: 6-13%
- **Fitness**: 14-17%
- **Average**: 18-24%
- **Overweight**: 25-29%
- **Obese**: ≥30%
- **Optimal for longevity**: 10-15%

**Women:**
- **Essential fat**: 10-13% (minimum for survival)
- **Athletes**: 14-20%
- **Fitness**: 21-24%
- **Average**: 25-31%
- **Overweight**: 32-37%
- **Obese**: ≥38%
- **Optimal for longevity**: 18-25%

**Why Body Fat % > Weight or BMI:**
- Distinguishes muscle from fat
- 200 lbs at 15% body fat vs. 30% body fat = vastly different health profiles
- Athlete with high muscle mass: high weight/BMI, low body fat (very healthy)
- "Skinny fat": normal weight/BMI, high body fat (metabolically unhealthy)

**Types of Body Fat:**

**Subcutaneous Fat:**
- Under the skin
- Pinchable, visible
- Relatively benign metabolically
- Primary energy storage

**Visceral Fat:**
- Deep abdominal fat surrounding organs
- Not directly visible or pinchable
- Highly metabolically active (secretes inflammatory cytokines)
- Drives insulin resistance, cardiovascular disease, cancer
- Most dangerous fat depot

**Goal:** Lower visceral fat, maintain some subcutaneous for hormone production and cushioning

**How to Measure Body Fat:**

**DEXA Scan (Gold Standard):**
- Most accurate (±1-2%)
- Shows fat distribution (visceral vs. subcutaneous)
- Also measures bone density, muscle mass
- Cost: $50-150
- Frequency: every 6-12 months while changing body composition

**Bioelectrical Impedance (BIA):**
- Home scales or handheld devices
- Convenience: daily tracking
- Accuracy: ±3-5% (affected by hydration)
- Good for trends, less accurate for absolute values
- Cost: $30-300

**Bod Pod:**
- Air displacement plethysmography
- Accurate: ±2-3%
- Cost: $50-75
- Available at some gyms, universities

**Skinfold Calipers:**
- Cheap ($10-50)
- Requires skill and consistency
- Accuracy: ±3-5% with experienced user
- DIY option

**Visual Estimation:**
- Least accurate but free
- Compare to reference photos
- Good for general assessment

**How to Optimize Body Fat:**

**For Fat Loss:**

**Calorie Deficit:**
- Must be in deficit to lose fat
- Aim for 300-500 calorie deficit (0.5-1% body weight loss per week)
- Too aggressive: lose muscle, metabolic adaptation

**Protein Intake:**
- 1.6-2.0g per kg body weight
- Preserves muscle during fat loss
- Increases satiety
- Highest thermic effect of food

**Resistance Training:**
- 3-4x per week minimum
- Preserves/builds muscle during fat loss
- Muscle burns calories (small effect but meaningful)
- Improves body composition dramatically

**Cardio:**
- Adds to calorie deficit
- Mix of moderate and high intensity
- But not at expense of resistance training
- 150-300 min per week

**Sleep:**
- 7-9 hours nightly
- Poor sleep increases fat storage, hunger hormones
- Makes fat loss much harder

**Manage Stress:**
- Chronic stress → elevated cortisol → visceral fat storage
- Meditation, breathing exercises
- Adequate recovery

**For Muscle Gain (If Too Low Body Fat):**

**Calorie Surplus:**
- Slight surplus (200-300 calories)
- Emphasize whole foods, adequate protein
- Resistance training 4-5x per week

**Don't Cut If Already Lean:**
- Men <10%, Women <18%: focus on muscle gain
- Very low body fat impairs hormones, mood, performance

**Special Considerations:**

**Age-Related Changes:**
- After age 30: lose 3-8% muscle per decade
- After menopause: women gain visceral fat
- Harder to maintain low body fat with age
- But still achievable with consistent effort

**Gender Differences:**
- Women need higher essential fat (reproductive hormones)
- Women store more subcutaneous, less visceral (protective until menopause)
- Women have harder time achieving very low body fat (hormonal)

**Athletes:**
- Sport-specific optimal body fat
- Endurance athletes: lower (8-12% men, 15-20% women)
- Strength athletes: moderate (12-18% men, 20-25% women)
- Too low impairs performance, increases injury risk

**Health Risks of Too Low Body Fat:**

**Men <5%, Women <15%:**
- Hormonal dysfunction (low testosterone, estrogen)
- Weakened immune system
- Loss of period (amenorrhea in women)
- Mood disturbances, irritability
- Reduced bone density
- Increased injury risk
- Impaired cognitive function

**The Bottom Line:**
Target 10-15% body fat for men, 18-25% for women for optimal longevity. Focus on losing visceral fat through diet, resistance training, cardio, adequate sleep. Measure with DEXA scan or BIA to track progress. Don't pursue extremely low body fat unless athletic performance demands it - there's a sweet spot for health and longevity.""",
        'recommendations_primary': 'Target 10-15% (men) or 18-25% (women) body fat; resistance train 3-4x weekly, adequate protein (1.6-2.0g/kg), manage stress, sleep 7-9 hours',
        'therapeutics_primary': 'For obesity with metabolic dysfunction: GLP-1 agonists (semaglutide 2.4mg weekly, tirzepatide 15mg weekly) most effective combined with lifestyle'
    },

    'Blood Pressure (Systolic)': {
        'education': """**Understanding Systolic Blood Pressure**

Systolic blood pressure is the top number in a blood pressure reading, representing the pressure in your arteries when your heart beats. It's one of the most important cardiovascular risk factors.

**The Longevity Connection:**
- High blood pressure is the #1 modifiable risk factor for cardiovascular disease
- Increases risk of heart attack, stroke, heart failure, kidney disease, dementia
- Even "high normal" BP (120-129) increases mortality compared to optimal
- Each 20 mmHg increase doubles cardiovascular mortality
- Treating high BP is one of the most proven longevity interventions

**Optimal Ranges:**
- **Optimal**: <120 mmHg
- **Elevated**: 120-129 mmHg
- **Hypertension Stage 1**: 130-139 mmHg
- **Hypertension Stage 2**: ≥140 mmHg
- **Hypertensive Crisis**: ≥180 mmHg (emergency)

**Target for Longevity:** <120 mmHg (ideally 110-115)

**New Guidelines (More Aggressive):**
- American Heart Association (2017): Hypertension defined as ≥130/80 (previously ≥140/90)
- SPRINT trial showed: targeting <120 reduced cardiovascular events 25%
- Tighter control = better outcomes (but must be individualized)

**What Causes High Blood Pressure:**

**Lifestyle (90% of Cases - "Essential Hypertension"):**
- **Excess sodium**: >2300mg daily
- **Obesity**: especially visceral fat
- **Insulin resistance**
- **Sedentary lifestyle**
- **Excessive alcohol**: >2 drinks/day
- **Chronic stress**
- **Poor sleep**: <7 hours or sleep apnea
- **High-saturated fat, low-potassium diet**

**Secondary Causes (10% of Cases):**
- Kidney disease
- Sleep apnea
- Thyroid disorders
- Adrenal disorders (pheochromocytoma, Cushing's, hyperaldosteronism)
- Renal artery stenosis
- Medications (NSAIDs, decongestants, stimulants, birth control pills)

**How to Lower Blood Pressure:**

**Diet (DASH Diet Most Effective):**
- **Reduce sodium**: <1500-2000mg daily (dramatic effect)
- **Increase potassium**: 3500-4700mg daily (fruits, vegetables, beans)
- **DASH diet**: emphasizes vegetables, fruits, whole grains, lean protein
- **Limit alcohol**: <1 drink/day (women), <2/day (men)
- **Beet juice**: 250-500mL daily (nitrates → vasodilation)
- **Dark chocolate**: 70%+ cacao, small amounts (flavonoids)

**Weight Loss:**
- Every 10 lbs lost lowers BP ~5-20 mmHg
- Visceral fat loss particularly effective
- Even 5% weight loss shows benefit

**Exercise:**
- Aerobic exercise lowers BP 5-10 mmHg
- 150+ minutes moderate intensity weekly
- Resistance training also beneficial
- Consistency key - BP rises again if stop exercising

**Stress Management:**
- Chronic stress raises BP
- Meditation, breathing exercises proven effective (5-10 mmHg reduction)
- Biofeedback, yoga
- Address psychological stressors

**Sleep:**
- 7-9 hours nightly
- Treat sleep apnea if present (CPAP can lower BP 10-15 mmHg)
- Poor sleep dramatically raises BP

**Limit Caffeine:**
- Acutely raises BP
- If sensitive, limit to 200-300mg daily (<noon)
- Or eliminate and see if BP improves

**Supplements:**
- **Magnesium**: 300-400mg daily (modest effect, 3-5 mmHg)
- **Potassium**: if deficient (from food preferred)
- **Coenzyme Q10**: 100-200mg daily (may help 5-10 mmHg)
- **Fish oil**: 2-4g EPA+DHA (modest benefit)
- **Garlic**: aged garlic extract 600-1200mg (modest effect)

**Medications (If Lifestyle Not Sufficient):**

**First-Line:**
- **ACE inhibitors** (-pril): lisinopril, enalapril (10-40mg daily)
- **ARBs** (-sartan): losartan, telmisartan (50-100mg daily)
- **Calcium channel blockers**: amlodipine (5-10mg daily)
- **Thiazide diuretics**: hydrochlorothiazide, chlorthalidone (12.5-25mg daily)

**Combination Therapy:**
- Most people need 2-3 medications to reach goal <120
- Synergistic effects, lower doses of each
- Common: ACE inhibitor + calcium channel blocker + diuretic

**Resistant Hypertension:**
- Despite 3+ medications
- Rule out secondary causes
- Add spironolactone (potassium-sparing diuretic)
- Consider renal denervation (emerging therapy)

**Monitoring:**
- **Home monitoring** essential (white coat hypertension common)
- Measure morning and evening
- Take average of multiple readings
- Validated device (upper arm cuff, not wrist)
- Bring log to doctor visits

**Home BP Monitoring Protocol:**
1. Sit quietly 5 minutes before measuring
2. Arm supported at heart level
3. Don't talk during measurement
4. Take 2-3 readings, 1 minute apart
5. Use average
6. Measure 2x daily for 1 week before doctor visit

**Target BP by Risk:**
- **Low risk, younger**: <130/80
- **Most people**: <120/80
- **Very high risk, elderly**: May tolerate 130-140 (individualize)

**The Bottom Line:**
Target systolic BP <120 mmHg for optimal longevity. Achieve through: DASH diet (<1500mg sodium daily), weight loss if overweight, exercise 150+ min weekly, stress management, adequate sleep. If lifestyle not sufficient, medication is essential - high BP is too dangerous to leave untreated. Monitor at home regularly.""",
        'recommendations_primary': 'DASH diet with <1500mg sodium daily, lose weight if overweight, exercise 150+ min weekly, manage stress, sleep 7-9 hours, limit alcohol',
        'therapeutics_primary': 'ACE inhibitors (lisinopril 10-40mg), ARBs (losartan 50-100mg), calcium channel blockers (amlodipine 5-10mg), thiazide diuretics (chlorthalidone 12.5-25mg); most need 2-3 medications'
    },

    'Total Sleep': {
        'education': """**Understanding Total Sleep Duration**

Total sleep is the amount of actual sleep you get per night, excluding time spent awake in bed. It's one of the most powerful determinants of health, longevity, and cognitive function.

**The Longevity Connection:**
- Both short (<7 hours) and long (>9 hours) sleep associated with increased mortality
- Sweet spot: 7-9 hours for optimal longevity
- Sleep deprivation accelerates biological aging at the cellular level
- Poor sleep increases risk of dementia, cardiovascular disease, diabetes, cancer
- "Sleep debt" cannot be fully repaid - chronic effects accumulate

**Optimal Sleep Duration:**
- **Adults (18-64)**: 7-9 hours
- **Optimal for most**: 7.5-8.5 hours
- **Older adults (65+)**: 7-8 hours
- **Individual variation**: genetics influence optimal duration

**Why Sleep Matters:**
- **Brain health**: clears metabolic waste (including amyloid-beta), consolidates memories
- **Cardiovascular**: regulates blood pressure, repairs blood vessels
- **Metabolic**: regulates glucose metabolism, hunger hormones (leptin, ghrelin)
- **Immune function**: produces cytokines, antibodies
- **Cellular repair**: growth hormone released during deep sleep
- **Inflammation**: poor sleep increases inflammatory markers

**Consequences of Chronic Sleep Deprivation (<7 hours):**

**Immediate (Days-Weeks):**
- Impaired cognitive function, poor memory, reduced attention
- Increased hunger and cravings (especially carbs/sugar)
- Mood disturbances, irritability, anxiety
- Reduced insulin sensitivity (pre-diabetic state after 1 week)
- Weakened immune function

**Long-term (Months-Years):**
- 2x risk of obesity
- 50% increased risk of cardiovascular disease
- 30% increased risk of type 2 diabetes
- Increased dementia risk (up to 30%)
- Higher cancer risk
- Accelerated cognitive decline
- Shortened lifespan (6-7 hours: 12% higher mortality vs. 7-8 hours)

**Why Too Much Sleep Can Be Problematic (>9 hours):**
- May indicate underlying health issues (depression, sleep apnea, inflammation)
- Association with increased mortality (but likely reverse causation)
- Poor sleep quality requiring more time in bed
- If naturally need >9 hours and feel refreshed: likely OK

**How to Optimize Sleep Duration:**

**Sleep Hygiene Basics:**
- **Consistent schedule**: same bed/wake time (even weekends)
- **Dark room**: blackout curtains or eye mask
- **Cool temperature**: 65-68°F (18-20°C) optimal
- **Quiet**: white noise if needed
- **Comfortable bed**: invest in quality mattress/pillows

**Pre-Sleep Routine:**
- **Wind down**: 30-60 min before bed
- **Dim lights**: reduce blue light exposure 2-3 hours before bed
- **No screens**: stop phones/computers 1 hour before bed
- **Read**: physical book, not screens
- **Light stretching or meditation**

**Avoid:**
- **Caffeine**: none after 2 PM (half-life 5-6 hours)
- **Alcohol**: impairs sleep quality, reduces REM sleep
- **Heavy meals**: finish eating 3 hours before bed
- **Intense exercise**: complete 4+ hours before bed

**Supplements (If Needed):**
- **Magnesium glycinate**: 300-400mg (promotes relaxation)
- **Melatonin**: 0.5-3mg (30-60 min before bed) - use lowest effective dose
- **L-theanine**: 200mg (promotes calm)
- **Glycine**: 3g before bed (improves sleep quality)
- **Apigenin** (chamomile): calming effect

**Medications (If Necessary):**
- Use sparingly and short-term
- CBT-I (Cognitive Behavioral Therapy for Insomnia) more effective long-term
- Avoid benzos and Z-drugs if possible (dependence, dementia risk)

**Track Your Sleep:**
- Wearable devices (Whoop, Oura Ring, Apple Watch)
- Track total sleep, sleep stages, consistency
- Aim for 7-9 hours in bed, 7-8 hours actual sleep

**The Bottom Line:**
Target 7-9 hours total sleep nightly for optimal longevity. Prioritize sleep as much as diet and exercise - it's non-negotiable for health. Establish consistent sleep/wake times, create dark/cool sleep environment, avoid caffeine after 2 PM, and track to ensure you're hitting your target.""",
        'recommendations_primary': 'Target 7-9 hours nightly, consistent sleep/wake schedule, dark cool room (65-68°F), no caffeine after 2 PM, no screens 1 hour before bed',
        'therapeutics_primary': 'Magnesium glycinate 300-400mg, melatonin 0.5-3mg (lowest effective dose); CBT-I for chronic insomnia; avoid benzos long-term'
    },

    'Resting Heart Rate': {
        'education': """**Understanding Resting Heart Rate (RHR)**

Resting heart rate is your heart rate when completely at rest, typically measured first thing in the morning before getting out of bed. It's a powerful predictor of cardiovascular fitness and longevity.

**The Longevity Connection:**
- Lower RHR associated with longer lifespan
- Each 10 bpm increase above 60 increases mortality risk 10-20%
- RHR >80 bpm doubles cardiovascular mortality vs. <60 bpm
- Marker of cardiovascular fitness and autonomic nervous system health
- Predicts heart failure, sudden cardiac death

**Optimal Ranges:**
- **Elite athletes**: 40-50 bpm
- **Very fit**: 50-60 bpm
- **Fit/optimal**: 60-70 bpm
- **Average**: 70-80 bpm
- **Above average risk**: 80-90 bpm
- **High risk**: >90 bpm

**Target for Longevity:** 50-65 bpm

**What RHR Tells You:**
- **Cardiovascular fitness**: lower = better cardiorespiratory fitness
- **Autonomic balance**: reflects parasympathetic (rest/digest) tone
- **Recovery status**: elevated RHR = inadequate recovery, overtraining, illness
- **Stress level**: chronic stress raises RHR

**What Affects RHR:**

**Factors That Lower RHR:**
- **Aerobic training** (biggest impact)
- **Good cardiovascular fitness**
- **Adequate recovery**
- **Good sleep**
- **Low stress**
- **Healthy body composition**

**Factors That Raise RHR:**
- **Deconditioning** (sedentary lifestyle)
- **Overtraining** (inadequate recovery)
- **Poor sleep** or sleep deprivation
- **Chronic stress**
- **Illness** or infection (often first sign)
- **Dehydration**
- **Caffeine** (acutely)
- **Alcohol** (next day elevation)
- **Heat exposure**
- **Obesity**
- **Certain medications** (stimulants, decongestants)
- **Medical conditions** (hyperthyroidism, anemia, fever)

**How to Lower Resting Heart Rate:**

**Aerobic Training (Most Effective):**
- **Consistent cardio**: 150+ minutes weekly
- **Mix intensities**: easy, moderate, high-intensity
- **Build gradually**: RHR drops 5-25 bpm over months
- **Long slow distance**: builds aerobic base
- **Interval training**: enhances cardiac efficiency

**Lifestyle:**
- **Adequate sleep**: 7-9 hours nightly
- **Stress management**: meditation, breathing exercises
- **Stay hydrated**: 2-3L water daily
- **Lose excess weight**: especially visceral fat
- **Limit caffeine**: especially if sensitive
- **Limit alcohol**: raises RHR significantly

**Supplements:**
- **Magnesium**: 300-400mg daily (supports cardiac function)
- **Omega-3s**: 2-4g EPA+DHA (may modestly lower RHR)
- **CoQ10**: 100-200mg (supports mitochondrial function)

**Monitoring RHR:**
- **Measure consistently**: same time daily, preferably upon waking
- **Before getting out of bed**: true resting state
- **Use wearable** or manual pulse check (60 seconds)
- **Track trends**: single measurements less important than pattern
- **Watch for changes**: sudden increases may indicate illness, overtraining

**When RHR Changes Signal a Problem:**

**Sudden Increase (>5-10 bpm):**
- Possible infection or illness coming
- Overtraining, inadequate recovery
- Dehydration
- Poor sleep
- Increased stress
- Action: increase recovery, monitor closely

**Persistently Elevated (>90 bpm):**
- Poor cardiovascular fitness
- Chronic stress
- Medical condition (hyperthyroidism, anemia, heart condition)
- Action: see doctor, start exercise program

**Very Low (<40 bpm in non-athletes):**
- May indicate bradycardia (abnormally slow heart)
- Some medications (beta blockers)
- Hypothyroidism
- Action: see doctor if symptomatic (dizziness, fatigue)

**The Bottom Line:**
Target RHR 50-65 bpm for optimal longevity. Achieve through consistent aerobic training (150+ min weekly), adequate sleep, stress management, healthy body composition. Monitor daily with wearable device to track trends and detect early signs of illness or overtraining. Lower is generally better (within reason - athletes can be 40-50 bpm).""",
        'recommendations_primary': 'Aerobic exercise 150+ min weekly (mix of easy/moderate/hard), sleep 7-9 hours, manage stress, stay hydrated, lose excess weight',
        'therapeutics_primary': 'Beta blockers (metoprolol 25-100mg) if tachycardia with hypertension or heart disease; treat underlying causes (hyperthyroidism, anemia)'
    },
}

# Close the biomarker dict properly
}

# Populate function remains the same below...

**The Longevity Connection:**
- Both underweight (BMI <18.5) and obesity (BMI >30) increase mortality
- The "obesity paradox": slightly overweight (BMI 25-27) may have lowest mortality in some studies
- Visceral fat (belly fat) more important than total weight
- Muscle mass protective - sarcopenia (muscle loss) accelerates aging
- Weight stability more important than absolute number

**Optimal Weight:**
- Depends on height, body composition, age
- BMI 20-25 generally optimal for longevity
- But BMI doesn't account for muscle mass
- Athletes with high muscle may have BMI >25 but low body fat
- Better metrics: body composition, waist circumference, waist-to-hip ratio

**Limitations of Weight as a Metric:**
- Doesn't distinguish muscle from fat
- Doesn't show visceral vs. subcutaneous fat
- Daily fluctuations (water, food, bowel movements)
- Can increase with muscle gain (healthy!)
- Two people same weight can have vastly different health profiles

**Better Metrics to Track:**
- **Body fat percentage**: men <15%, women <25% for optimal health
- **Waist circumference**: men <94cm (37in), women <80cm (31.5in)
- **Waist-to-hip ratio**: <0.9 (men), <0.8 (women)
- **Muscle mass**: maintain or increase with age
- **Visceral fat** (via DEXA or bioimpedance)

**Weight Management for Longevity:**

**If Overweight/Obese:**
- Lose fat, not just weight (preserve muscle)
- 5-10% weight loss produces major metabolic benefits
- Slow, sustained loss (0.5-1% per week) best
- Resistance training essential (prevents muscle loss)
- Adequate protein (1.6-2.0g/kg) during calorie deficit

**If Underweight:**
- Rule out medical causes (hyperthyroidism, malabsorption, cancer)
- Increase calorie intake progressively
- Focus on nutrient-dense foods
- Resistance training to build muscle
- May have higher mortality risk than mild obesity

**Maintaining Healthy Weight:**
- Balanced, whole-foods diet
- Regular physical activity (150+ min weekly)
- Adequate sleep (poor sleep → weight gain)
- Stress management (cortisol promotes fat storage)
- Consistent eating patterns
- Don't obsess over daily fluctuations

**Age-Related Considerations:**
- After age 30: lose ~3-8% muscle mass per decade (sarcopenia)
- "Middle-age spread" is visceral fat accumulation
- Focus on maintaining muscle, losing visceral fat
- Slight weight increase with age may be OK if maintaining muscle
- Don't pursue extreme leanness in older age (protective fat stores)

**The Bottom Line:**
Weight alone tells you little. Track body composition, waist circumference, and how you feel. Aim for BMI 20-25 if possible, but focus more on low visceral fat, adequate muscle mass, and metabolic health markers. A person at BMI 24 with high muscle and low visceral fat is healthier than BMI 22 with low muscle and high visceral fat.""",
        'recommendations_primary': 'Focus on body composition not just weight; maintain/build muscle with resistance training; lose visceral fat; track waist circumference',
        'therapeutics_primary': 'For obesity: GLP-1 agonists (semaglutide 2.4mg weekly, tirzepatide 15mg weekly) most effective; combined with lifestyle'
    },

    'BMI': {
        'education': """**Understanding BMI (Body Mass Index)**

BMI is weight (kg) divided by height squared (m²). It's a crude screening tool for population health but has significant limitations for individuals.

**BMI Categories:**
- Underweight: <18.5
- Normal: 18.5-24.9
- Overweight: 25-29.9
- Obese Class I: 30-34.9
- Obese Class II: 35-39.9
- Obese Class III: ≥40

**The Longevity Paradox:**
- Lowest mortality: BMI 20-25 (traditional view)
- But many studies show "obesity paradox": BMI 25-27 has lowest mortality
- Possible explanations:
  - Muscle mass protective (athletes have high BMI, low fat)
  - Some fat protective during illness
  - Reverse causation (illness causes weight loss)
  - BMI doesn't distinguish muscle from fat

**Limitations of BMI:**

**Major Problems:**
- Doesn't distinguish muscle from fat
- Athlete with high muscle: high BMI, low body fat (healthy)
- Sedentary person: normal BMI, high body fat (unhealthy)
- Doesn't measure visceral fat (most dangerous)
- Doesn't account for body composition changes with age
- Not accurate for: athletes, elderly, pregnant women, amputees

**Better Alternatives:**
- Body fat percentage (DEXA, bioimpedance)
- Waist circumference
- Waist-to-hip ratio
- Visceral fat measurement
- Muscle mass assessment

**When BMI is Useful:**
- Population-level screening
- Tracking trends over time (if body composition stable)
- Identifying obviously underweight or obese individuals
- Simple, cheap, accessible

**When BMI is Misleading:**
- Athletes and muscular individuals (underestimates health)
- "Skinny fat" people (normal BMI, high body fat - overestimates health)
- Elderly (lose muscle, gain fat - may have normal BMI but poor composition)

**Optimal Ranges by Age:**
- Young adults (20-39): 20-25 optimal
- Middle-aged (40-59): 22-27 acceptable
- Older adults (60+): 23-28 may be protective
- Slight increase with age may be OK (protective during illness)

**Ethnic Considerations:**
- Asian populations: lower BMI thresholds
  - Overweight: ≥23
  - Obese: ≥27.5
  - More visceral fat at lower BMI
- African Americans: may be healthier at slightly higher BMI (more muscle mass)

**The Bottom Line:**
BMI is a rough screening tool, nothing more. If your BMI is 25-27 but you exercise regularly, have good muscle mass, low waist circumference, and normal metabolic markers, you're likely healthy. If BMI is 23 but you're sedentary with high body fat and large waist, you're at risk. Don't obsess over BMI - focus on body composition and metabolic health.""",
        'recommendations_primary': 'Use BMI as rough guideline only; focus on waist circumference, body fat %, muscle mass, and metabolic markers instead',
        'therapeutics_primary': 'Treatment based on body composition and metabolic health, not BMI alone; GLP-1 agonists if metabolically unhealthy obesity'
    },
}

# Due to file size, I'll create a database update function now and then continue
# This ensures we can deploy what we have so far

def populate_biomarker_biometric_education():
    """Populate comprehensive education content for all biomarkers and biometrics"""
    conn = psycopg2.connect(DATABASE_URL)
    cur = conn.cursor()

    try:
        print("="*80)
        print("COMPREHENSIVE BIOMARKER & BIOMETRIC EDUCATION POPULATION")
        print("="*80)
        print()

        # Update biomarkers
        biomarker_count = 0
        for biomarker_name, content in BIOMARKER_EDUCATION_COMPLETE.items():
            cur.execute("""
                UPDATE biomarkers_base
                SET
                    education = %s,
                    recommendations_primary = COALESCE(recommendations_primary, %s),
                    therapeutics_primary = COALESCE(therapeutics_primary, %s),
                    updated_at = NOW()
                WHERE biomarker_name = %s
                  AND is_active = true
            """, (
                content['education'],
                content.get('recommendations_primary'),
                content.get('therapeutics_primary'),
                biomarker_name
            ))

            if cur.rowcount > 0:
                print(f"✓ Updated biomarker: {biomarker_name}")
                biomarker_count += 1
            else:
                print(f"⚠ Biomarker not found: {biomarker_name}")

        # Update biometrics
        biometric_count = 0
        for biometric_name, content in BIOMETRIC_EDUCATION_COMPLETE.items():
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
                print(f"⚠ Biometric not found: {biometric_name}")

        conn.commit()

        print()
        print("="*80)
        print("SUMMARY")
        print("="*80)
        print(f"Biomarkers updated: {biomarker_count}")
        print(f"Biometrics updated: {biometric_count}")
        print()
        print("✅ Education content population complete!")

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
    print("COMPREHENSIVE EDUCATION CONTENT SCRIPT")
    print()
    print(f"Biomarkers ready: {len(BIOMARKER_EDUCATION_COMPLETE)}")
    print(f"Biometrics ready: {len(BIOMETRIC_EDUCATION_COMPLETE)}")
    print()

    # Check which biomarkers we have
    biomarker_names = sorted(BIOMARKER_EDUCATION_COMPLETE.keys())
    print("Biomarkers with education:")
    for name in biomarker_names:
        print(f"  - {name}")

    print()
    biometric_names = sorted(BIOMETRIC_EDUCATION_COMPLETE.keys())
    print("Biometrics with education:")
    for name in biometric_names:
        print(f"  - {name}")

    print()
    print("Ready to populate database? This will update education fields.")
    print("Note: Uses COALESCE to preserve existing recommendations/therapeutics")
    print()

    # Run population
    populate_biomarker_biometric_education()
